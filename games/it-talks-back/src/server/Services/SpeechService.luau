--!strict
-- SpeechService: the monster hears what players SAY.
--   * Voice: each voice-enabled client runs Roblox speech-to-text on its own mic
--     (SpeechController) and sends the transcript via the Spoke remote.
--   * Text chat: Player.Chatted, while Roblox still lets scripts read chat (until platform-
--     integrated chat is forced in 2027; then only voice keeps working).
--
-- What hearing does:
--   1. Talking is a noise at your position (HorrorConfig.Noise.Voice): talk near it and it comes.
--   2. Naming a room ("I'm in the basement!") works like a callout: it heads there, so you can
--      tell the truth to your team or lie to lure it away.
--   3. If it is close, it answers you, usually with a fresh TextGenerator line about what you
--      said (filtered by TextService), otherwise a canned reply.
-- The transcript is never shown to other players and never stored.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local HorrorConfig = require(Shared.Config.HorrorConfig)
local Rooms = require(Shared.Rooms)

local Net = require(script.Parent.Parent.Net)
local State = require(script.Parent.Parent.Game.State)
local NoiseService = require(script.Parent.NoiseService)
local CalloutService = require(script.Parent.CalloutService)
local VoiceService = require(script.Parent.VoiceService)
local MonsterService = require(script.Parent.MonsterService)

local cfg = HorrorConfig.Speech

local SpeechService = {}
SpeechService.Priority = 30

local lastReply = 0
local lastRoomWord: { [Player]: number } = {}
local rng = Random.new()

-- First room word in the sentence, e.g. "im in the cellar lol" -> "Basement".
function SpeechService.roomIn(text: string): string?
	for word in text:lower():gmatch("%a+") do
		local room = cfg.RoomWords[word]
		if room then
			return room
		end
	end
	return nil
end

local function clean(text: string): string
	local s = text:gsub('[%c"<>{}]', " "):gsub("%s+", " ")
	return (s:match("^%s*(.-)%s*$") or ""):sub(1, 150)
end

local function heard(player: Player, raw: string)
	local status = State.getStatus(player)
	if not State.isPlaying() or (status ~= "Alive" and status ~= "Hidden" and status ~= "Caged") then
		return
	end
	local root = State.rootOf(player)
	if not root then
		return
	end
	local said = clean(raw)
	if #said < 2 then
		return
	end

	-- 1. Talking makes noise (even from a closet - careful).
	NoiseService.emit(root.Position, HorrorConfig.Noise.Voice, "Voice", player)

	-- 2. Room words act like a callout (teammates see it too). Own cooldown so chatter doesn't spam.
	local room = SpeechService.roomIn(said)
	local now = os.clock()
	if room and now - (lastRoomWord[player] or -math.huge) >= HorrorConfig.CalloutCooldown then
		lastRoomWord[player] = now
		local actual = Rooms.at(root.Position)
		for _, other in State.participants() do
			Net.fire("CalloutShown", other, player.DisplayName, room)
		end
		CalloutService.Called:Fire(player, room, actual)
		return -- the callout already makes it speak
	end

	-- 3. Answer if it's close enough to plausibly hear the words.
	local monsterPos = MonsterService.position()
	if not monsterPos or (monsterPos - root.Position).Magnitude > cfg.ReplyRange then
		return
	end
	if now - lastReply < cfg.ReplyCooldown or rng:NextNumber() > cfg.ReplyChance then
		return
	end
	lastReply = now
	VoiceService.say("Reply", { name = player.DisplayName, said = said })
end

function SpeechService:Init()
	Net.handle("Spoke", heard)
	if cfg.ListenToTextChat then
		local function hook(player: Player)
			player.Chatted:Connect(function(message: string)
				-- Empty when platform-integrated chat is on; then this simply does nothing.
				if typeof(message) == "string" and message ~= "" and message:sub(1, 1) ~= "/" then
					heard(player, message)
				end
			end)
		end
		Players.PlayerAdded:Connect(hook)
		for _, player in Players:GetPlayers() do
			hook(player)
		end
	end
	Players.PlayerRemoving:Connect(function(player)
		lastRoomWord[player] = nil
	end)
end

return SpeechService
