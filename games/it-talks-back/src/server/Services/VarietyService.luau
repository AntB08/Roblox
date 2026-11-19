--!strict
-- VarietyService: the "director". Item spots are already random; this makes each night FEEL
-- different, even when you replay the same night:
--   * a random monster personality (Stalker / Chatty / Hunter / Listener)
--   * a random night twist (Barricades / Blackout / Fog / JammedClosets / None)
--   * a random monster spawn, away from the foyer
--   * surprise events during the round: power surge, knocking in an empty room, vanishing
-- Tuning: HorrorConfig.Variety. RoundService calls rollNight() at the start and cleanup() at the end.
--
-- Replication: Workspace attributes "Personality", "Twist", "LightsOut" (lamps off: blackout or
-- surge). Clients do the visuals (MonsterFxController).

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local HorrorConfig = require(Shared.Config.HorrorConfig)

local Net = require(script.Parent.Parent.Net)
local Game = script.Parent.Parent.Game
local State = require(Game.State)
local Map = require(Game.Map)
local Rooms = require(Shared.Rooms)
local MonsterService = require(script.Parent.MonsterService)
local HideService = require(script.Parent.HideService)
local NoiseService = require(script.Parent.NoiseService)
local VoiceService = require(script.Parent.VoiceService)

local cfg = HorrorConfig.Variety
local FOYER = Vector3.new(0, 0, 14)

local VarietyService = {}
VarietyService.Priority = 15

export type Night = { personality: string, twist: string, blurb: string }

local rng = Random.new()
local barricades: { Instance } = {}
local baseFog: number? = nil
local twist = "None"
local lastPersonality: string? = nil
local lastTwist: string? = nil
local roundToken = 0

local function weightedTwist(): { id: string, weight: number, blurb: string? }
	local total = 0
	for _, t in cfg.Twists do
		if t.id ~= lastTwist or t.id == "None" then
			total += t.weight
		end
	end
	local roll = rng:NextNumber(0, total)
	for _, t in cfg.Twists do
		if t.id ~= lastTwist or t.id == "None" then
			roll -= t.weight
			if roll <= 0 then
				return t :: any
			end
		end
	end
	return cfg.Twists[1] :: any
end

-- ===== Barricades (keep every room reachable) ======================================================

type Door = { part: BasePart, a: string, b: string }

local function connected(open: { Door }): boolean
	local rooms = { "Hallway", "Kitchen", "Stairs", "Study" }
	local seen: { [string]: boolean } = { Hallway = true }
	local frontier = { "Hallway" }
	while #frontier > 0 do
		local room = table.remove(frontier) :: string
		for _, d in open do
			local other = if d.a == room then d.b elseif d.b == room then d.a else nil
			if other and not seen[other] then
				seen[other] = true
				table.insert(frontier, other)
			end
		end
	end
	for _, room in rooms do
		if not seen[room] then
			return false
		end
	end
	return true -- the basement hangs off Stairs, so Stairs reachable = basement reachable
end

local function board(door: BasePart)
	local model = Instance.new("Model")
	model.Name = "Barricade"
	local wide = door.Size.X > door.Size.Z
	for i = 0, 3 do
		local plank = Instance.new("Part")
		plank.Name = "Plank"
		plank.Anchored = true
		plank.Material = Enum.Material.WoodPlanks
		plank.Color = Color3.fromRGB(92, 64, 44)
		local length = math.max(door.Size.X, door.Size.Z) + 1
		plank.Size = if wide then Vector3.new(length, 0.9, 0.4) else Vector3.new(0.4, 0.9, length)
		local tilt = math.rad(rng:NextNumber(-12, 12))
		local y = -door.Size.Y / 2 + 1.4 + i * 2.1
		plank.CFrame = door.CFrame
			* CFrame.new(0, y, 0)
			* (if wide then CFrame.Angles(0, 0, tilt) else CFrame.Angles(tilt, 0, 0))
		plank.Parent = model
	end
	-- One solid invisible blocker so nothing squeezes between planks (pathfinding sees it too).
	local blocker = Instance.new("Part")
	blocker.Name = "Blocker"
	blocker.Anchored = true
	blocker.Transparency = 1
	blocker.Size = door.Size
	blocker.CFrame = door.CFrame
	blocker.Parent = model
	model.Parent = Workspace
	table.insert(barricades, model)
end

local function placeBarricades()
	local doors: { Door } = {}
	for _, part in Map.parts("Doorway") do
		local a, b = part:GetAttribute("A"), part:GetAttribute("B")
		if typeof(a) == "string" and typeof(b) == "string" then
			table.insert(doors, { part = part, a = a, b = b })
		end
	end
	-- Try random doors; keep a block only if the house stays connected.
	for i = #doors, 2, -1 do
		local j = rng:NextInteger(1, i)
		doors[i], doors[j] = doors[j], doors[i]
	end
	local open = table.clone(doors)
	local blocked = 0
	for _, door in doors do
		if blocked >= cfg.MaxBarricades then
			break
		end
		local without = {}
		for _, d in open do
			if d ~= door then
				table.insert(without, d)
			end
		end
		if connected(without) then
			open = without
			blocked += 1
			board(door.part)
		end
	end
end

-- ===== Night setup ================================================================================

local function farSpawn(): Vector3?
	local options = {}
	for _, point in Map.patrolPoints() do
		if (point.part.Position - FOYER).Magnitude > 35 then
			table.insert(options, point.part.Position)
		end
	end
	return if #options > 0 then options[rng:NextInteger(1, #options)] else nil
end

function VarietyService.rollNight(): Night
	VarietyService.cleanup()
	roundToken += 1

	-- Personality (never the same twice in a row).
	local names: { string } = {}
	local personalities = HorrorConfig.Variety.Personalities :: { [string]: any }
	for name, _ in personalities do
		if name ~= lastPersonality then
			table.insert(names, name)
		end
	end
	table.sort(names)
	local personality = names[rng:NextInteger(1, #names)]
	lastPersonality = personality
	local p = cfg.Personalities[personality]
	MonsterService.setPersona({
		view = p.view,
		hear = p.hear,
		speed = p.speed,
		talk = p.talk,
		memory = p.memory,
		hintTruth = p.hintTruth,
	})

	-- Twist.
	local t = weightedTwist()
	twist = t.id
	lastTwist = t.id
	if twist == "Barricades" then
		placeBarricades()
	elseif twist == "Blackout" then
		Workspace:SetAttribute("LightsOut", true)
	elseif twist == "Fog" then
		local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
		if atmosphere then
			baseFog = baseFog or atmosphere.Density
			atmosphere.Density = cfg.FogDensity
		end
	elseif twist == "JammedClosets" then
		local closets = Map.closets()
		for i = 1, math.min(cfg.JammedClosets, #closets) do
			local j = rng:NextInteger(i, #closets)
			closets[i], closets[j] = closets[j], closets[i]
			HideService.setJammed(closets[i], true)
		end
	end

	-- Spawn somewhere new.
	local at = farSpawn()
	if at then
		MonsterService.placeAt(at)
	end

	Workspace:SetAttribute("Personality", personality)
	Workspace:SetAttribute("Twist", twist)
	local blurb = p.blurb .. (if t.blurb then " " .. t.blurb else "")
	return { personality = personality, twist = twist, blurb = blurb }
end

function VarietyService.cleanup()
	for _, b in barricades do
		b:Destroy()
	end
	table.clear(barricades)
	HideService.unjamAll()
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if atmosphere and baseFog then
		atmosphere.Density = baseFog
	end
	Workspace:SetAttribute("LightsOut", false)
	twist = "None"
end

-- ===== Surprise events ===========================================================================

local function surge()
	if twist == "Blackout" or State.isPowerOn() then
		return
	end
	local token = roundToken
	Workspace:SetAttribute("LightsOut", true)
	VoiceService.say("Surge", nil, true)
	task.delay(cfg.SurgeSeconds, function()
		if token == roundToken and twist ~= "Blackout" then
			Workspace:SetAttribute("LightsOut", false)
		end
	end)
end

local function knock()
	-- A room nobody is in.
	local occupied: { [string]: boolean } = {}
	for _, player in State.playersWith("Alive") do
		local root = State.rootOf(player)
		local room = root and Rooms.at(root.Position)
		if room then
			occupied[room] = true
		end
	end
	local options = {}
	for _, point in Map.patrolPoints() do
		if not occupied[point.room] then
			table.insert(options, point.part.Position)
		end
	end
	if #options == 0 then
		return
	end
	local at = options[rng:NextInteger(1, #options)]
	Net.fireAll("PlaySoundAt", "Thud", at + Vector3.new(0, 3, 0), 3)
	NoiseService.emit(at, 400, "Knock", nil)
	if MonsterService.lure(at) then
		VoiceService.say("Knock")
	end
end

local function vanish()
	MonsterService.vanish()
end

local EVENTS = { surge, knock, vanish }

function VarietyService:Start()
	while true do
		task.wait(rng:NextNumber(cfg.EventEvery.Min, cfg.EventEvery.Max))
		if State.isPlaying() and State.secondsIntoRound() > HorrorConfig.Round.StartGrace + 10 then
			local ok, err = pcall(EVENTS[rng:NextInteger(1, #EVENTS)])
			if not ok then
				warn(`[VarietyService] event failed: {err}`)
			end
		end
	end
end

return VarietyService
