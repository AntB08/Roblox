--!strict
-- State: the shared round/player state every server system reads. It holds no logic beyond
-- bookkeeping, so services can depend on it without depending on each other (RoundService is
-- the only module that orchestrates the others).
--
-- Replication: player attribute "Status", Workspace attributes "RoundState", "RoundEndsAt",
-- "IntermissionEndsAt", "FusesInserted", "FusesTotal", "PowerOn".

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Signal = require(Shared.Packages.Signal)
local Types = require(Shared.Types)

export type Status = Types.Status
export type RoundState = Types.RoundState

local State = {}

State.StatusChanged = Signal.new() -- (player, newStatus, oldStatus)
State.RoundStateChanged = Signal.new() -- (newState)

local statuses: { [Player]: Status } = {}
local roundState: RoundState = "Lobby"
local roundStartedAt = 0

function State.getStatus(player: Player): Status
	return statuses[player] or "Lobby"
end

function State.setStatus(player: Player, status: Status)
	local old = State.getStatus(player)
	if old == status then
		return
	end
	statuses[player] = status
	player:SetAttribute("Status", status)
	State.StatusChanged:Fire(player, status, old)
end

-- In the house and able to act (walking around or hiding).
function State.isInside(player: Player): boolean
	local s = State.getStatus(player)
	return s == "Alive" or s == "Hidden"
end

function State.isFree(player: Player): boolean
	return State.getStatus(player) == "Alive"
end

function State.playersWith(status: Status): { Player }
	local list = {}
	for _, player in Players:GetPlayers() do
		if State.getStatus(player) == status then
			table.insert(list, player)
		end
	end
	return list
end

-- Everyone taking part in the current round (inside, caged or escaped).
function State.participants(): { Player }
	local list = {}
	for _, player in Players:GetPlayers() do
		if State.getStatus(player) ~= "Lobby" then
			table.insert(list, player)
		end
	end
	return list
end

function State.getRoundState(): RoundState
	return roundState
end

function State.isPlaying(): boolean
	return roundState == "Playing"
end

function State.setRoundState(newState: RoundState)
	roundState = newState
	if newState == "Playing" then
		roundStartedAt = os.clock()
	end
	Workspace:SetAttribute("RoundState", newState)
	State.RoundStateChanged:Fire(newState)
end

function State.secondsIntoRound(): number
	return os.clock() - roundStartedAt
end

function State.isPowerOn(): boolean
	return Workspace:GetAttribute("PowerOn") == true
end

-- Root part of a player's character, or nil when there is no usable character.
function State.rootOf(player: Player): BasePart?
	local character = player.Character
	if not character then
		return nil
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return nil
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	return if root and root:IsA("BasePart") then root else nil
end

function State.humanoidOf(player: Player): Humanoid?
	local character = player.Character
	return if character then character:FindFirstChildOfClass("Humanoid") else nil
end

-- Moves a character safely (PivotTo keeps the whole model together).
function State.teleport(player: Player, cframe: CFrame)
	local character = player.Character
	local root = State.rootOf(player)
	if character and root then
		root.AssemblyLinearVelocity = Vector3.zero
		character:PivotTo(cframe)
	end
end

Players.PlayerRemoving:Connect(function(player)
	statuses[player] = nil
end)

return State
