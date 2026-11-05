--!strict
-- PlayerLifecycle: one Trove per player (cleaned on leave) and one per character (cleaned on
-- respawn/leave). Other services attach per-player state here instead of keeping their own
-- Player-keyed tables that leak.
--
--   PlayerLifecycle.troveFor(player)      -> Trove? (lives until PlayerRemoving)
--   PlayerLifecycle.onCharacter(function(player, character, charTrove) ... end)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Trove = require(ReplicatedStorage:WaitForChild("Shared").Packages.Trove)

type Trove = Trove.Trove
type CharacterHandler = (player: Player, character: Model, charTrove: Trove) -> ()

local PlayerLifecycle = {}
PlayerLifecycle.Priority = 160 -- Init early so others can register character handlers

local playerTroves: { [Player]: Trove } = {}
local characterHandlers: { CharacterHandler } = {}

local function onCharacterAdded(player: Player, character: Model, playerTrove: Trove)
	local charTrove = playerTrove:Extend()
	-- Clean when the character leaves the DataModel (respawn, leave, destroy).
	charTrove:Connect(character.AncestryChanged, function(_, parent: Instance?)
		if parent == nil then
			playerTrove:Remove(charTrove) -- Remove() also cleans it
		end
	end)
	for _, handler in characterHandlers do
		task.spawn(handler, player, character, charTrove)
	end
end

local function onPlayerAdded(player: Player)
	if playerTroves[player] then
		return -- PlayerAdded + GetPlayers loop race
	end
	local trove = Trove.new()
	playerTroves[player] = trove
	trove:Connect(player.CharacterAdded, function(character: Model)
		onCharacterAdded(player, character, trove)
	end)
	if player.Character then
		task.spawn(onCharacterAdded, player, player.Character, trove)
	end
end

local function onPlayerRemoving(player: Player)
	local trove = playerTroves[player]
	if trove then
		playerTroves[player] = nil
		trove:Destroy()
	end
end

function PlayerLifecycle.troveFor(player: Player): Trove?
	return playerTroves[player]
end

-- Register during Init. Runs for every current and future character.
function PlayerLifecycle.onCharacter(handler: CharacterHandler)
	table.insert(characterHandlers, handler)
end

function PlayerLifecycle:Start()
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
	for _, player in Players:GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end
end

return PlayerLifecycle
