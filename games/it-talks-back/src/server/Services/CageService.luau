--!strict
-- CageService: caught players go to the cage in the basement instead of dying. Any free
-- teammate can hold the cage door prompt to let EVERYONE out, but starting the hold is loud,
-- so rescuing is a risk you choose to take.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local HorrorConfig = require(Shared.Config.HorrorConfig)
local Signal = require(Shared.Packages.Signal)

local Net = require(script.Parent.Parent.Net)
local Game = script.Parent.Parent.Game
local State = require(Game.State)
local Map = require(Game.Map)
local NoiseService = require(script.Parent.NoiseService)
local DataService = require(script.Parent.DataService)

local MAX_DISTANCE = 12

local CageService = {}
CageService.Priority = 55

CageService.Rescued = Signal.new() -- (rescuer, freedPlayers)

local rng = Random.new()
local prompt: ProximityPrompt? = nil

local function updatePrompt()
	if prompt then
		local n = #State.playersWith("Caged")
		prompt.Enabled = n > 0
		prompt.ObjectText = if n == 1 then "1 teammate caged" else `{n} teammates caged`
	end
end

function CageService.put(player: Player)
	local inside = Map.one("CageInside")
	State.setStatus(player, "Caged")
	local offset = Vector3.new(rng:NextNumber(-2, 2), 0, rng:NextNumber(-2, 2))
	State.teleport(player, inside.CFrame + offset)
	updatePrompt()
end

local function release(player: Player)
	local outside = Map.one("CageOutside")
	local offset = Vector3.new(rng:NextNumber(-1, 1), 0, rng:NextNumber(-2, 2))
	State.teleport(player, outside.CFrame + offset)
	State.setStatus(player, "Alive")
end

local function rescue(rescuer: Player)
	local freed = State.playersWith("Caged")
	if #freed == 0 then
		return
	end
	for _, player in freed do
		release(player)
	end
	DataService.addCoins(
		rescuer,
		HorrorConfig.Round.RescueCoins,
		Enum.AnalyticsEconomyTransactionType.Gameplay,
		"Rescue"
	)
	DataService.bumpStat(rescuer, "Rescues")
	Net.notify(rescuer, `You freed {#freed} teammate{if #freed == 1 then "" else "s"}!`, "success")
	updatePrompt()
	CageService.Rescued:Fire(rescuer, freed)
end

function CageService:Init()
	State.StatusChanged:Connect(updatePrompt)
end

function CageService:Start()
	local door = Map.one("CageDoor")
	local p = Instance.new("ProximityPrompt")
	p.Name = "RescuePrompt"
	p.ActionText = "Break Lock"
	p.HoldDuration = 2.5
	p.MaxActivationDistance = 8
	p.RequiresLineOfSight = false
	p.Enabled = false
	p:AddTag("RescuePrompt")
	p.Parent = door
	prompt = p

	p.PromptButtonHoldBegan:Connect(function(player: Player)
		if State.isFree(player) then
			NoiseService.emit(door.Position, HorrorConfig.Noise.Rescue, "Rescue", player)
		end
	end)
	p.Triggered:Connect(function(player: Player)
		if not State.isFree(player) or not State.isPlaying() then
			return
		end
		local root = State.rootOf(player)
		if not root or (root.Position - door.Position).Magnitude > MAX_DISTANCE then
			return
		end
		rescue(player)
	end)
	updatePrompt()
end

return CageService
