--!strict
-- CalloutService: preset callouts ("I'm in the Kitchen!"). Every participant sees them, and
-- the monster hears them too, whether they are true or not. That makes callouts a lure:
-- shout "Basement!" from the study and it goes downstairs. Lie too often and it stops listening
-- to you (MonsterService keeps the grudge).
--
-- Callouts are preset strings chosen from a fixed list, so no player-written text is involved.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local HorrorConfig = require(Shared.Config.HorrorConfig)
local Signal = require(Shared.Packages.Signal)
local Rooms = require(Shared.Rooms)

local Net = require(script.Parent.Parent.Net)
local State = require(script.Parent.Parent.Game.State)
local Analytics = require(script.Parent.Analytics)

local CalloutService = {}
CalloutService.Priority = 50

-- (player, claimedRoom, actualRoom?)
CalloutService.Called = Signal.new()

local lastCall: { [Player]: number } = {}

function CalloutService:Init()
	Net.handle("Callout", function(player: Player, room: string)
		local status = State.getStatus(player)
		if not State.isPlaying() or (status ~= "Alive" and status ~= "Hidden" and status ~= "Caged") then
			return
		end
		local now = os.clock()
		if now - (lastCall[player] or -math.huge) < HorrorConfig.CalloutCooldown then
			return
		end
		lastCall[player] = now
		local root = State.rootOf(player)
		local actual = if root then Rooms.at(root.Position) else nil
		for _, other in State.participants() do
			Net.fire("CalloutShown", other, player.DisplayName, room)
		end
		Analytics.custom(player, "CalloutUsed", 1, room, if actual == room then "True" else "Lie")
		CalloutService.Called:Fire(player, room, actual)
	end)
	Players.PlayerRemoving:Connect(function(player)
		lastCall[player] = nil
	end)
end

return CalloutService
