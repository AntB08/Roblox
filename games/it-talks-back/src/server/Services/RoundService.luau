--!strict
-- RoundService: the only orchestrator. Lobby (intermission) -> Playing -> Results -> Lobby.
--
--   Lobby    everyone waits by the house; countdown starts with MinPlayers.
--   Playing  players start in the foyer; the monster wakes after StartGrace seconds.
--            Win: finish the night's tasks (TaskService), the gate opens, step into the ExitZone.
--            Surviving (1+ escape) advances the server to the next night; losing replays it.
--            A round ends when nobody is left inside (escaped / caged / left) or time runs out.
--   Results  a short summary, then everyone returns to the lobby.
--
-- Replication: Workspace attributes "RoundState", "IntermissionEndsAt", "RoundEndsAt" (server
-- time from Workspace:GetServerTimeNow()), player attribute "Status".

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local HorrorConfig = require(Shared.Config.HorrorConfig)
local Rooms = require(Shared.Rooms)

local Net = require(script.Parent.Parent.Net)
local Game = script.Parent.Parent.Game
local State = require(Game.State)
local Map = require(Game.Map)
local FuseService = require(script.Parent.FuseService)
local HideService = require(script.Parent.HideService)
local MonsterService = require(script.Parent.MonsterService)
local MovementService = require(script.Parent.MovementService)
local VoiceService = require(script.Parent.VoiceService)
local DataService = require(script.Parent.DataService)
local Analytics = require(script.Parent.Analytics)
local PlayerLifecycle = require(script.Parent.PlayerLifecycle)
local TaskService = require(script.Parent.TaskService)
local VarietyService = require(script.Parent.VarietyService)

local POLL = 0.25

local RoundService = {}
RoundService.Priority = 10

local cfg = HorrorConfig.Round

local night = 1 -- server-wide: survive to advance, lose to replay

local function nightConfig(n: number): TaskService.Night
	local list = HorrorConfig.Nights
	local base = list[math.min(n, #list)]
	local extra = math.max(0, n - #list) * HorrorConfig.ExtraSpeedPerNight
	return {
		fuses = base.fuses,
		tasks = base.tasks,
		monsterSpeed = math.min(HorrorConfig.MaxMonsterSpeed, base.monsterSpeed + extra),
	}
end

local function message(title: string, subtitle: string, seconds: number)
	Net.fireAll("RoundMessage", title, subtitle, seconds)
end

local function serverNow(): number
	return Workspace:GetServerTimeNow()
end

local function sendToLobby(player: Player)
	HideService.unhide(player, true)
	State.teleport(player, Map.lobbySpawn() + Vector3.new(math.random(-6, 6), 0, math.random(-3, 3)))
	State.setStatus(player, "Lobby")
	MovementService.reset(player)
end

local function readyPlayers(): { Player }
	local list = {}
	for _, player in Players:GetPlayers() do
		if State.rootOf(player) then
			table.insert(list, player)
		end
	end
	return list
end

local function intermission()
	State.setRoundState("Lobby")
	Workspace:SetAttribute("RoundEndsAt", 0)
	while true do
		while #readyPlayers() < cfg.MinPlayers do
			Workspace:SetAttribute("IntermissionEndsAt", 0)
			task.wait(1)
		end
		local endsAt = serverNow() + cfg.Intermission
		Workspace:SetAttribute("IntermissionEndsAt", endsAt)
		while serverNow() < endsAt and #readyPlayers() >= cfg.MinPlayers do
			task.wait(POLL)
		end
		if #readyPlayers() >= cfg.MinPlayers then
			Workspace:SetAttribute("IntermissionEndsAt", 0)
			return
		end
	end
end

local function begin(): { Player }
	FuseService.reset()
	HideService.reset()
	MonsterService.reset()
	local tonight = nightConfig(night)
	TaskService.begin(tonight)
	MonsterService.setSpeedMultiplier(tonight.monsterSpeed)
	local flavor = VarietyService.rollNight() -- personality, twist, spawn (after the monster reset)
	Workspace:SetAttribute("Night", night)

	local participants = readyPlayers()
	local starts = Map.playerStarts()
	for i, player in participants do
		local start = starts[(i - 1) % #starts + 1]
		State.teleport(player, start.CFrame) -- markers face north (-Z), into the house
		State.setStatus(player, "Alive")
		MovementService.reset(player)
		DataService.bumpStat(player, "Rounds")
		Analytics.onboarding(player, "FirstRound")
	end
	State.setRoundState("Playing")
	Workspace:SetAttribute("RoundEndsAt", serverNow() + cfg.Duration)
	message(`Night {night}`, `{flavor.blurb} Finish your tasks, then get out the north gate.`, 6)
	task.delay(cfg.StartGrace, function()
		if State.isPlaying() then
			MonsterService.wake()
			if night > 1 then
				VoiceService.say("NightStart", { count = night }, true)
			end
		end
	end)
	return participants
end

local function checkEscapes()
	if not TaskService.isExitOpen() then
		return
	end
	local zone = Map.one("ExitZone")
	local volume = { name = "Exit", cframe = zone.CFrame, size = zone.Size }
	for _, player in State.playersWith("Alive") do
		local root = State.rootOf(player)
		if root and Rooms.contains(volume, root.Position) then
			State.setStatus(player, "Escaped")
			State.teleport(player, Map.lobbySpawn())
			MovementService.reset(player)
			DataService.addCoins(player, cfg.EscapeCoins, Enum.AnalyticsEconomyTransactionType.Gameplay, "Escape")
			DataService.bumpStat(player, "Escapes")
			Analytics.custom(player, "PlayerEscaped", math.floor(State.secondsIntoRound()))
			Analytics.onboarding(player, "FirstEscape")
			Net.notify(player, `You escaped! +{cfg.EscapeCoins} coins`, "success")
			VoiceService.say("Escaped", { name = player.DisplayName }, true)
		end
	end
end

local function play()
	local endsAt = serverNow() + cfg.Duration
	while serverNow() < endsAt do
		task.wait(POLL)
		checkEscapes()
		if #State.playersWith("Alive") + #State.playersWith("Hidden") == 0 then
			break
		end
	end
end

local function results(participants: { Player })
	State.setRoundState("Results")
	MonsterService.sleep()
	local escaped = 0
	local total = 0
	for _, player in participants do
		if player.Parent == Players then
			total += 1
			if State.getStatus(player) == "Escaped" then
				escaped += 1
			end
		end
	end
	local won = escaped > 0
	for _, player in participants do
		if player.Parent == Players then
			Analytics.custom(player, "RoundEnded", escaped, if won then "Win" else "Loss")
		end
	end
	local survivedNight = night
	if won then
		night += 1
		for _, player in participants do
			if player.Parent == Players and State.getStatus(player) == "Escaped" then
				DataService.setBestNight(player, survivedNight)
			end
		end
	end
	if escaped == total and total > 0 then
		message(`Night {survivedNight} survived!`, `Everyone escaped. Night {night} is next.`, cfg.ResultsTime)
	elseif won then
		message(
			`Night {survivedNight} survived`,
			`{escaped} of {total} escaped. Night {night} is next.`,
			cfg.ResultsTime
		)
	else
		message("Nobody escaped", `The Tenant keeps its guests. Night {night} again.`, cfg.ResultsTime)
	end
	task.wait(cfg.ResultsTime)
	for _, player in Players:GetPlayers() do
		if State.getStatus(player) ~= "Lobby" then
			sendToLobby(player)
		end
	end
	FuseService.reset()
	TaskService.reset()
	VarietyService.cleanup()
	MonsterService.reset()
end

function RoundService:Init()
	-- Resetting your character during a round forfeits it (you respawn in the lobby).
	PlayerLifecycle.onCharacter(function(player: Player)
		if State.getStatus(player) ~= "Lobby" and State.getStatus(player) ~= "Escaped" then
			State.setStatus(player, "Lobby")
		end
	end)
	Players.PlayerAdded:Connect(function(player)
		State.setStatus(player, "Lobby")
		player:SetAttribute("Status", "Lobby")
	end)
	for _, player in Players:GetPlayers() do
		player:SetAttribute("Status", "Lobby")
	end
end

function RoundService:Start()
	Workspace:SetAttribute("FusesTotal", HorrorConfig.Fuses.Count)
	Workspace:SetAttribute("Night", night)
	while true do
		local ok, err = pcall(function()
			intermission()
			local participants = begin()
			play()
			results(participants)
		end)
		if not ok then
			warn(`[RoundService] round loop error: {err}`)
			task.wait(3)
		end
	end
end

return RoundService
