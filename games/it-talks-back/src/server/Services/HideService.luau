--!strict
-- HideService: closets. A free player triggers "Hide" -> they are moved inside, anchored, and
-- their status becomes "Hidden" (the monster cannot see hidden players). "Leave" (the same prompt,
-- or the HUD button via the LeaveHide remote) puts them back in front of the closet.
-- If the monster saw you climb in, it knows: MonsterService asks HideService.sawHide().

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local HorrorConfig = require(Shared.Config.HorrorConfig)
local Signal = require(Shared.Packages.Signal)

local Net = require(script.Parent.Parent.Net)
local Game = script.Parent.Parent.Game
local State = require(Game.State)
local Map = require(Game.Map)
local NoiseService = require(script.Parent.NoiseService)

local MAX_DISTANCE = 10

type Hiding = { closet: Model, at: number }

local HideService = {}
HideService.Priority = 60

HideService.Hid = Signal.new() -- (player, closet)

local occupant: { [Model]: Player } = {}
local hiding: { [Player]: Hiding } = {}
local jammed: { [Model]: true } = {}

local function partOf(closet: Model, name: string): BasePart?
	local p = closet:FindFirstChild(name)
	return if p and p:IsA("BasePart") then p else nil
end

local function setAnchored(player: Player, anchored: boolean)
	local root = State.rootOf(player)
	if root then
		root.Anchored = anchored
	end
end

function HideService.unhide(player: Player, silent: boolean?)
	local record = hiding[player]
	if not record then
		return
	end
	hiding[player] = nil
	occupant[record.closet] = nil
	local front = partOf(record.closet, "Front")
	setAnchored(player, false)
	if front then
		State.teleport(player, front.CFrame + Vector3.new(0, 0.5, 0)) -- facing out into the room
		if not silent then
			NoiseService.emit(front.Position, HorrorConfig.Noise.Closet, "Closet", player)
		end
	end
	if State.getStatus(player) == "Hidden" then
		State.setStatus(player, "Alive")
	end
end

local function hide(player: Player, closet: Model)
	local inside = partOf(closet, "Inside")
	local front = partOf(closet, "Front")
	if not inside or not front then
		return
	end
	occupant[closet] = player
	hiding[player] = { closet = closet, at = os.clock() }
	State.setStatus(player, "Hidden")
	-- Face out of the closet (Inside's -Z is the closet front).
	State.teleport(player, inside.CFrame)
	setAnchored(player, true)
	NoiseService.emit(front.Position, HorrorConfig.Noise.Closet, "Closet", player)
	HideService.Hid:Fire(player, closet)
end

-- The closet a hidden player is in (nil if not hidden).
function HideService.closetOf(player: Player): Model?
	local record = hiding[player]
	return if record then record.closet else nil
end

function HideService.hiddenSince(player: Player): number?
	local record = hiding[player]
	return if record then record.at else nil
end

function HideService.frontOf(closet: Model): Vector3?
	local front = partOf(closet, "Front")
	return if front then front.Position else nil
end

-- Director twist: some closets won't open tonight.
function HideService.setJammed(closet: Model, on: boolean)
	if on then
		jammed[closet] = true
	else
		jammed[closet] = nil
	end
	local front = closet:FindFirstChild("Front")
	local prompt = front and front:FindFirstChild("HidePrompt")
	if prompt and prompt:IsA("ProximityPrompt") then
		prompt.ActionText = if on then "Jammed" else "Hide"
	end
end

function HideService.unjamAll()
	for closet in jammed do
		HideService.setJammed(closet, false)
	end
end

function HideService.reset()
	for player in hiding do
		HideService.unhide(player, true)
	end
end

function HideService:Init()
	Net.handle("LeaveHide", function(player: Player)
		HideService.unhide(player)
	end)
	State.StatusChanged:Connect(function(player: Player, status: string)
		if status ~= "Hidden" and hiding[player] then
			-- Moved out by something else (caught, round over): release the closet quietly.
			local record = hiding[player]
			hiding[player] = nil
			occupant[record.closet] = nil
			setAnchored(player, false)
		end
	end)
	Players.PlayerRemoving:Connect(function(player)
		local record = hiding[player]
		if record then
			occupant[record.closet] = nil
			hiding[player] = nil
		end
	end)
end

function HideService:Start()
	for _, closet in Map.closets() do
		local front = partOf(closet, "Front")
		if not front then
			continue
		end
		local prompt = Instance.new("ProximityPrompt")
		prompt.Name = "HidePrompt"
		prompt.ActionText = "Hide"
		prompt.ObjectText = "Closet"
		prompt.HoldDuration = 0.25
		prompt.MaxActivationDistance = 7
		prompt.RequiresLineOfSight = false
		prompt.Parent = front
		prompt:AddTag("HidePrompt")
		prompt.Triggered:Connect(function(player: Player)
			if hiding[player] and hiding[player].closet == closet then
				HideService.unhide(player)
				return
			end
			if not State.isFree(player) or not State.isPlaying() then
				return
			end
			if jammed[closet] then
				Net.notify(player, "It's jammed shut.", "warning")
				return
			end
			if occupant[closet] then
				Net.notify(player, "Someone is already hiding in there.", "warning")
				return
			end
			local root = State.rootOf(player)
			if not root or (root.Position - front.Position).Magnitude > MAX_DISTANCE then
				return
			end
			hide(player, closet)
		end)
	end
end

return HideService
