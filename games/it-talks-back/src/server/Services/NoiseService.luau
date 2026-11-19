--!strict
-- NoiseService: everything the monster can hear. Systems call NoiseService.emit(...) for
-- one-off noises (fuse pickup, closet doors, rescues); this service also listens to footsteps by
-- measuring each inside player's real speed on the server (clients cannot fake being quiet).
--
--   NoiseService.emit(position, radius, "FuseInsert", player)
--   NoiseService.Emitted:Connect(function(noise) ... end)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Signal = require(Shared.Packages.Signal)
local HorrorConfig = require(Shared.Config.HorrorConfig)

local State = require(script.Parent.Parent.Game.State)

export type Noise = {
	position: Vector3,
	radius: number,
	kind: string,
	player: Player?,
	time: number,
}

local FOOTSTEP_INTERVAL = 0.4

local NoiseService = {}
NoiseService.Priority = 80

NoiseService.Emitted = Signal.new() -- (noise: Noise)

function NoiseService.emit(position: Vector3, radius: number, kind: string, player: Player?)
	NoiseService.Emitted:Fire({
		position = position,
		radius = radius,
		kind = kind,
		player = player,
		time = os.clock(),
	} :: Noise)
end

function NoiseService:Start()
	local cfg = HorrorConfig.Player
	while true do
		task.wait(FOOTSTEP_INTERVAL)
		if not State.isPlaying() then
			continue
		end
		for _, player in State.playersWith("Alive") do
			local root = State.rootOf(player)
			if not root then
				continue
			end
			local v = root.AssemblyLinearVelocity
			local speed = Vector3.new(v.X, 0, v.Z).Magnitude
			if speed > cfg.WalkSpeed + 2 then
				NoiseService.emit(root.Position, HorrorConfig.Noise.Sprint, "Sprint", player)
			elseif speed > 4 and player:GetAttribute("Crouched") ~= true then
				NoiseService.emit(root.Position, HorrorConfig.Noise.Walk, "Walk", player)
			end
		end
	end
end

return NoiseService
