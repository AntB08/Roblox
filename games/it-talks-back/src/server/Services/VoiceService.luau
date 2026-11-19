--!strict
-- VoiceService: what the monster says, and when. Everything goes out through the MonsterSpeak
-- remote; each client turns the text into 3D speech from the monster's head (AudioTextToSpeech)
-- and shows a subtitle if it is close enough to hear.
--
-- Lines come from Server/Config/Lines.luau. For "flavor" kinds (Ambient, Heard, Lost, ...),
-- the service can ask Roblox's TextGenerator for a fresh line that fits the moment. If that is
-- off, slow or fails, the canned line is used. All AI output is sanitized and filtered with
-- TextService before anyone sees or hears it. Hints and catches are always canned so gameplay
-- never depends on the model.
--
--   VoiceService.say("Heard", { room = "Kitchen" })
--   VoiceService.say("Caught", { name = player.DisplayName }, true)  -- urgent: skip cooldown

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local HorrorConfig = require(Shared.Config.HorrorConfig)

local Net = require(script.Parent.Parent.Net)
local Lines = require(script.Parent.Parent.Config.Lines)
local VoiceLines = require(Shared.Config.VoiceLines)
local LiveConfig = require(script.Parent.LiveConfig)

export type Context = { name: string?, room: string?, count: number?, total: number?, said: string? }

local AI_KINDS: { [string]: string } = {
	-- kind -> what to tell the model about the moment
	Ambient = "You are wandering your dark house. Say something unsettling to the guests hiding from you.",
	Heard = "You just heard a noise from the {room}. React to it.",
	Lost = "You were chasing a guest but lost sight of them. Taunt them.",
	FuseInserted = "The guests just put fuse {count} of {total} into your generator. You are annoyed.",
	Escaped = "A guest named {name} just escaped your house. React, still menacing.",
	Rescued = "Someone just freed the guests you locked in your cage. You are furious.",
	Reply = 'A guest named {name} is hiding from you and just said out loud: "{said}". Answer them directly.',
}

local SYSTEM_PROMPT = [[
You are "The Tenant", the creepy owner of a haunted house in a spooky Roblox game for kids and teens.
Guests are trying to find three fuses, restore power and escape. You speak out loud to them.
Rules: reply with ONE short spoken line, at most 14 words. No quotation marks, no emojis,
no stage directions, no swearing, no gore, no threats of real-world harm, nothing about real
people or places. Be eerie, playful and theatrical, like a spooky campfire story.]]

local VoiceService = {}
VoiceService.Priority = 50

local rng = Random.new()
local lastSpoke = 0
local lastLine: { [string]: string } = {}
local generator: TextGenerator? = nil
local aiFailures = 0
local aiBusy = false

local function fill(template: string, ctx: Context): string
	return (
		template:gsub("{(%w+)}", function(key: string): string
			local v = (ctx :: any)[key]
			return if v ~= nil then tostring(v) else `\{{key}\}`
		end)
	)
end

local function isRecorded(line: string): boolean
	local asset = VoiceLines[line]
	return asset ~= nil and asset ~= "" and asset ~= "rbxassetid://0"
end

local function recordedOnly(): boolean
	return HorrorConfig.Voice.Mode == "RecordedOnly"
end

local function pickCanned(kind: string, ctx: Context): string?
	local pool = Lines[kind]
	if not pool or #pool == 0 then
		return nil
	end
	-- Prefer lines whose placeholders we can fill, and don't repeat the previous line.
	local options = {}
	for _, line in pool do
		local ok = true
		for key in line:gmatch("{(%w+)}") do
			if (ctx :: any)[key] == nil then
				ok = false
			end
		end
		if ok and recordedOnly() and not isRecorded(line) then
			ok = false
		end
		if ok and (line ~= lastLine[kind] or #pool == 1) then
			table.insert(options, line)
		end
	end
	if #options == 0 then
		return nil
	end
	local line = options[rng:NextInteger(1, #options)]
	lastLine[kind] = line
	return fill(line, ctx)
end

-- Strips anything that isn't a short single spoken sentence.
function VoiceService.sanitize(text: string): string?
	local s = text:gsub("[\r\n]+", " "):gsub('["*_#<>%[%]{}]', "")
	-- Multi-byte punctuation must be replaced as whole strings, not in a byte class.
	local swaps: { [string]: string } = {
		["“"] = "",
		["”"] = "",
		["’"] = "'",
		["‘"] = "'",
		["…"] = "...",
		["—"] = ", ",
	}
	for from, to in swaps do
		s = s:gsub(from, to)
	end
	s = s:gsub("%s+", " ")
	s = s:match("^%s*(.-)%s*$") or ""
	if #s < 3 then
		return nil
	end
	if utf8.len(s) == nil then
		return nil
	end
	if #s > 120 then
		s = s:sub(1, 117):gsub("%s+%S*$", "") .. "..."
	end
	return s
end

local function filterForEveryone(text: string): string?
	local listener = Players:GetPlayers()[1]
	if not listener then
		return nil
	end
	local ok, result = pcall(function()
		local filtered = TextService:FilterStringAsync(text, listener.UserId, Enum.TextFilterContext.PublicChat)
		return filtered:GetNonChatStringForBroadcastAsync()
	end)
	if not ok or typeof(result) ~= "string" or result == "" or result:find("#", 1, true) then
		return nil -- filtered (hashes) or failed: drop the AI line entirely
	end
	return result
end

local openAIFailures = 0
local OPENAI_URL = "https://api.openai.com/v1/chat/completions"

-- GPT via HttpService. The key lives in the experience's Secrets store (never in code):
-- Creator Hub > your game > Secrets > name = HorrorConfig.Voice.OpenAI.SecretName, domain api.openai.com.
-- For Studio testing: File > Experience Settings > Security > Local Secrets (and Allow HTTP Requests).
local function generateOpenAI(situation: string): string?
	local oc = HorrorConfig.Voice.OpenAI
	if not oc.Enabled or openAIFailures >= HorrorConfig.Voice.AIMaxFailures then
		return nil
	end
	local ok, result = pcall(function()
		local secret = HttpService:GetSecret(oc.SecretName)
		return HttpService:RequestAsync({
			Url = OPENAI_URL,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
				["Authorization"] = secret:AddPrefix("Bearer "),
			},
			Body = HttpService:JSONEncode({
				model = oc.Model,
				max_tokens = 60,
				temperature = 0.9,
				messages = {
					{ role = "system", content = SYSTEM_PROMPT },
					{ role = "user", content = situation },
				},
			}),
		})
	end)
	local text: string? = nil
	if ok and typeof(result) == "table" and result.Success and typeof(result.Body) == "string" then
		local decoded, data = pcall(HttpService.JSONDecode, HttpService, result.Body)
		local choice = decoded and typeof(data) == "table" and data.choices and data.choices[1]
		local content = choice and choice.message and choice.message.content
		if typeof(content) == "string" then
			text = content
		end
	end
	if not text then
		openAIFailures += 1
		if openAIFailures >= HorrorConfig.Voice.AIMaxFailures then
			local why = if ok and typeof(result) == "table" then `HTTP {result.StatusCode}` else tostring(result)
			warn(`[VoiceService] OpenAI unavailable ({why}); falling back to Roblox TextGenerator / canned lines`)
		end
		return nil
	end
	openAIFailures = 0
	local clean = VoiceService.sanitize(text)
	return if clean then filterForEveryone(clean) else nil
end

-- RecordedOnly mode: GPT can't write new audio, so it chooses which recording fits best.
local function chooseRecorded(kind: string, ctx: Context): string?
	local oc = HorrorConfig.Voice.OpenAI
	if not oc.Enabled or openAIFailures >= HorrorConfig.Voice.AIMaxFailures then
		return nil
	end
	local options = {}
	for _, pool in Lines do
		for _, line in pool do
			if isRecorded(line) and not line:find("{", 1, true) then
				table.insert(options, line)
			end
		end
	end
	if #options < 2 then
		return nil
	end
	local list = {}
	for i, line in options do
		table.insert(list, `{i}. {line}`)
	end
	local situation = fill(AI_KINDS[kind] or "React to the moment.", ctx)
		.. "\nYou can ONLY say one of these recorded lines. Reply with just its number:\n"
		.. table.concat(list, "\n")
	local ok, result = pcall(function()
		local secret = HttpService:GetSecret(oc.SecretName)
		return HttpService:RequestAsync({
			Url = OPENAI_URL,
			Method = "POST",
			Headers = { ["Content-Type"] = "application/json", ["Authorization"] = secret:AddPrefix("Bearer ") },
			Body = HttpService:JSONEncode({
				model = oc.Model,
				max_tokens = 5,
				temperature = 0.7,
				messages = {
					{ role = "system", content = SYSTEM_PROMPT },
					{ role = "user", content = situation },
				},
			}),
		})
	end)
	if not ok or typeof(result) ~= "table" or not result.Success then
		openAIFailures += 1
		return nil
	end
	local decoded, data = pcall(HttpService.JSONDecode, HttpService, result.Body)
	local choice = decoded and typeof(data) == "table" and data.choices and data.choices[1]
	local content = choice and choice.message and choice.message.content
	local index = if typeof(content) == "string" then tonumber(content:match("%d+")) else nil
	openAIFailures = 0
	return if index then options[index] else nil
end

local function generate(kind: string, ctx: Context): string?
	if recordedOnly() then
		return chooseRecorded(kind, ctx) -- never invent text there is no recording for
	end
	local fromGPT = generateOpenAI(fill(AI_KINDS[kind], ctx))
	if fromGPT then
		return fromGPT
	end
	local gen = generator
	if not gen or aiFailures >= HorrorConfig.Voice.AIMaxFailures then
		return nil
	end
	local situation = fill(AI_KINDS[kind], ctx)
	local ok, response = pcall(function()
		return gen:GenerateTextAsync({ UserPrompt = situation, MaxTokens = 40 })
	end)
	if not ok or typeof(response) ~= "table" or typeof(response.GeneratedText) ~= "string" then
		aiFailures += 1
		if aiFailures >= HorrorConfig.Voice.AIMaxFailures then
			warn(`[VoiceService] TextGenerator unavailable ({response}); using canned lines`)
		end
		return nil
	end
	aiFailures = 0
	local clean = VoiceService.sanitize(response.GeneratedText)
	return if clean then filterForEveryone(clean) else nil
end

local function broadcast(text: string, kind: string)
	lastSpoke = os.clock()
	Net.fireAll("MonsterSpeak", text, kind)
end

local function aiEnabled(): boolean
	return HorrorConfig.Voice.UseAI
		and LiveConfig.boolean("monster_ai_dialogue", true)
		and (generator ~= nil or HorrorConfig.Voice.OpenAI.Enabled)
end

-- Says a line of `kind`. Returns false if it stayed quiet (cooldown / no line).
-- urgent = true skips the cooldown (catches, power on) and never waits for AI.
function VoiceService.say(kind: string, ctx: Context?, urgent: boolean?): boolean
	local context: Context = ctx or {}
	if not urgent and os.clock() - lastSpoke < HorrorConfig.Voice.GlobalCooldown then
		return false
	end
	local canned = pickCanned(kind, context)
	if not canned then
		return false
	end
	if urgent or not AI_KINDS[kind] or aiBusy or not aiEnabled() then
		broadcast(canned, kind)
		return true
	end
	-- Try AI with a deadline; whichever finishes first speaks.
	aiBusy = true
	lastSpoke = os.clock() -- reserve the slot so lines don't pile up while we wait
	local done = false
	task.spawn(function()
		local line = generate(kind, context)
		aiBusy = false
		if not done then
			done = true
			broadcast(line or canned, kind)
		end
	end)
	task.delay(HorrorConfig.Voice.AITimeout, function()
		if not done then
			done = true
			broadcast(canned, kind)
		end
	end)
	return true
end

function VoiceService.canSpeak(): boolean
	return os.clock() - lastSpoke >= HorrorConfig.Voice.GlobalCooldown
end

function VoiceService:Init()
	if HorrorConfig.Voice.UseAI then
		local ok, gen = pcall(function()
			local g = Instance.new("TextGenerator")
			g.SystemPrompt = SYSTEM_PROMPT
			g.Temperature = 0.8
			return g
		end)
		if ok then
			generator = gen
		else
			warn("[VoiceService] TextGenerator could not be created; canned lines only")
		end
	end
end

return VoiceService
