--!strict
-- FuseService: the objective. Three fuses spawn at random FuseSpawn markers (at most two per
-- room). A player carries one at a time (attribute "CarryingFuse") and inserts it at the
-- generator. Three inserted -> power on: lights change, the exit gate opens, the monster rages.
--
-- Prompts are created here and checked again on the server when triggered. Clients only hide
-- prompts that don't apply to them (PromptController), which is cosmetic.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local HorrorConfig = require(Shared.Config.HorrorConfig)
local Signal = require(Shared.Packages.Signal)
local Rooms = require(Shared.Rooms)

local Game = script.Parent.Parent.Game
local State = require(Game.State)
local Map = require(Game.Map)
local NoiseService = require(script.Parent.NoiseService)
local DataService = require(script.Parent.DataService)
local Analytics = require(script.Parent.Analytics)

local FUSE_COLOR = Color3.fromRGB(255, 196, 64)
local SLOT_OFF = Color3.fromRGB(38, 38, 38)
local SLOT_ON = Color3.fromRGB(90, 255, 140)
local MAX_PROMPT_DISTANCE = 12 -- server re-check (prompt distance + latency slack)

local FuseService = {}
FuseService.Priority = 60

FuseService.Inserted = Signal.new() -- (player, count, total)
FuseService.PowerRestored = Signal.new()
FuseService.PickedUp = Signal.new() -- (player)

local worldFuses: { [BasePart]: string } = {} -- fuse part -> room
local carried: { [Player]: BasePart } = {} -- the visual welded to the carrier
local inserted = 0
local generatorPrompt: ProximityPrompt? = nil
local rng = Random.new()

local function within(player: Player, position: Vector3, distance: number): boolean
	local root = State.rootOf(player)
	return root ~= nil and (root.Position - position).Magnitude <= distance
end

local function makeFusePart(): BasePart
	local fuse = Instance.new("Part")
	fuse.Name = "Fuse"
	fuse.Shape = Enum.PartType.Cylinder
	fuse.Size = Vector3.new(1.4, 0.7, 0.7)
	fuse.Material = Enum.Material.Neon
	fuse.Color = FUSE_COLOR
	fuse.CastShadow = false
	fuse.CanCollide = false
	fuse.CanQuery = false
	fuse.CanTouch = false
	local light = Instance.new("PointLight")
	light.Color = FUSE_COLOR
	light.Range = 8
	light.Brightness = 1.2
	light.Parent = fuse
	return fuse
end

local function spawnWorldFuse(position: Vector3, room: string)
	local fuse = makeFusePart()
	fuse.Anchored = true
	fuse.CFrame = CFrame.new(position) * CFrame.Angles(0, rng:NextNumber(0, math.pi), math.rad(90))
	fuse:AddTag("Fuse")
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Take Fuse"
	prompt.ObjectText = "Fuse"
	prompt.HoldDuration = 0.4
	prompt.MaxActivationDistance = 8
	prompt.RequiresLineOfSight = false
	prompt:AddTag("FusePrompt")
	prompt.Parent = fuse
	worldFuses[fuse] = room
	fuse.Parent = Workspace

	prompt.Triggered:Connect(function(player: Player)
		if worldFuses[fuse] == nil or not State.isFree(player) or carried[player] then
			return
		end
		if not within(player, fuse.Position, MAX_PROMPT_DISTANCE) then
			return
		end
		worldFuses[fuse] = nil
		fuse:Destroy()
		FuseService.give(player)
		NoiseService.emit(position, HorrorConfig.Noise.FusePickup, "FusePickup", player)
		FuseService.PickedUp:Fire(player)
		Analytics.onboarding(player, "FirstFuse")
	end)
end

-- Attaches a carried fuse to the player's hand (visual) and sets "CarryingFuse".
function FuseService.give(player: Player)
	local character = player.Character
	local hand = character
		and (
			character:FindFirstChild("RightHand")
			or character:FindFirstChild("Right Arm")
			or character:FindFirstChild("HumanoidRootPart")
		)
	if not character or not hand or not hand:IsA("BasePart") then
		return
	end
	local fuse = makeFusePart()
	fuse.Massless = true
	fuse.Anchored = false
	fuse.CFrame = hand.CFrame * CFrame.new(0, -0.6, -0.3)
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = hand
	weld.Part1 = fuse
	weld.Parent = fuse
	fuse.Parent = character
	carried[player] = fuse
	player:SetAttribute("CarryingFuse", true)
end

-- Drops a carried fuse where the player stands (caught, left, round reset).
function FuseService.drop(player: Player, at: Vector3?)
	local fuse = carried[player]
	if not fuse then
		return
	end
	carried[player] = nil
	player:SetAttribute("CarryingFuse", false)
	local position = at or fuse.Position
	fuse:Destroy()
	if State.isPlaying() then
		-- Raycast to the floor so the dropped fuse sits on something.
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Include
		params.FilterDescendantsInstances = { Workspace:FindFirstChild("Map") :: Instance }
		local hit = Workspace:Raycast(position + Vector3.new(0, 2, 0), Vector3.new(0, -30, 0), params)
		local ground = if hit then hit.Position + Vector3.new(0, 0.5, 0) else position
		spawnWorldFuse(ground, Rooms.at(ground) or "Hallway")
	end
end

function FuseService.isCarrying(player: Player): boolean
	return if carried[player] then true else false
end

-- Rooms that currently contain a fuse lying around (for the monster's hints).
function FuseService.roomsWithFuses(): { [string]: boolean }
	local set = {}
	for _, room in worldFuses do
		set[room] = true
	end
	return set
end

function FuseService.insertedCount(): number
	return inserted
end

local function setSlots()
	for _, slot in Map.parts("FuseSlot") do
		local index = tonumber(slot:GetAttribute("Index")) or 0
		slot.Color = if index <= inserted then SLOT_ON else SLOT_OFF
	end
	Workspace:SetAttribute("FusesInserted", inserted)
	Workspace:SetAttribute("FusesTotal", HorrorConfig.Fuses.Count)
	if generatorPrompt then
		generatorPrompt.ObjectText = `Generator ({inserted}/{HorrorConfig.Fuses.Count})`
	end
end

local function setGate(open: boolean)
	local gate = Map.one("ExitGate")
	local closedCFrame = gate:GetAttribute("ClosedCFrame")
	if typeof(closedCFrame) ~= "CFrame" then
		closedCFrame = gate.CFrame
		gate:SetAttribute("ClosedCFrame", closedCFrame)
	end
	local target = if open then (closedCFrame :: CFrame) + Vector3.new(0, 8.5, 0) else closedCFrame :: CFrame
	gate.CanCollide = not open
	TweenService:Create(gate, TweenInfo.new(if open then 2.5 else 0.01, Enum.EasingStyle.Quad), {
		CFrame = target,
	}):Play()
	for _, sign in Map.parts("ExitSign") do
		sign.Color = if open then Color3.fromRGB(80, 255, 120) else Color3.fromRGB(230, 30, 20)
	end
end

local function onInsert(player: Player)
	if not State.isFree(player) or not carried[player] or not State.isPlaying() then
		return
	end
	local body = Map.one("Generator")
	if not within(player, body.Position, MAX_PROMPT_DISTANCE) then
		return
	end
	local fuse = carried[player]
	carried[player] = nil
	player:SetAttribute("CarryingFuse", false)
	fuse:Destroy()

	inserted += 1
	setSlots()
	DataService.bumpStat(player, "FusesInserted")
	NoiseService.emit(body.Position, HorrorConfig.Noise.FuseInsert, "FuseInsert", player)
	FuseService.Inserted:Fire(player, inserted, HorrorConfig.Fuses.Count)
	if inserted >= HorrorConfig.Fuses.Count then
		Workspace:SetAttribute("PowerOn", true)
		setGate(true)
		FuseService.PowerRestored:Fire()
	end
end

-- New round: clear everything, pick spawn points, close the gate.
function FuseService.reset()
	for fuse in worldFuses do
		fuse:Destroy()
	end
	table.clear(worldFuses)
	for player in carried do
		FuseService.drop(player)
	end
	inserted = 0
	Workspace:SetAttribute("PowerOn", false)
	setSlots()
	setGate(false)
end

function FuseService.spawnRound()
	local spawns = Map.fuseSpawns()
	-- Fisher-Yates shuffle, then take the first Count that respect MaxPerRoom.
	for i = #spawns, 2, -1 do
		local j = rng:NextInteger(1, i)
		spawns[i], spawns[j] = spawns[j], spawns[i]
	end
	local perRoom: { [string]: number } = {}
	local placed = 0
	for _, point in spawns do
		if placed >= HorrorConfig.Fuses.Count then
			break
		end
		local n = perRoom[point.room] or 0
		if n < HorrorConfig.Fuses.MaxPerRoom then
			perRoom[point.room] = n + 1
			placed += 1
			spawnWorldFuse(point.part.Position, point.room)
		end
	end
end

function FuseService:Init()
	State.StatusChanged:Connect(function(player: Player, status: string)
		if status == "Caged" or status == "Lobby" or status == "Escaped" then
			FuseService.drop(player)
		end
	end)
	game:GetService("Players").PlayerRemoving:Connect(function(player)
		FuseService.drop(player)
	end)
end

function FuseService:Start()
	local body = Map.one("Generator")
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "InsertPrompt"
	prompt.ActionText = "Insert Fuse"
	prompt.HoldDuration = 0.8
	prompt.MaxActivationDistance = 8
	prompt.RequiresLineOfSight = false
	prompt.Parent = body
	prompt:AddTag("GeneratorPrompt")
	generatorPrompt = prompt
	prompt.Triggered:Connect(onInsert)
	FuseService.reset()
end

return FuseService
