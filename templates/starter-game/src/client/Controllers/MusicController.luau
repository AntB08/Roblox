--!strict
-- MusicController: registers the tracks from Shared/Config/Assets.luau and starts the main loop.
-- Tracks with placeholder ids are skipped (silent until real, licensed, INSTRUMENTAL ids are set).
-- Add zone/state music by registering more tracks and calling MusicManager.Play(name, fade).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = require(ReplicatedStorage:WaitForChild("Shared").Config.Assets)

local MusicManager = require(script.Parent.Parent.FX.MusicManager)

local MusicController = {}

function MusicController:Start()
	local registered: { string } = {}
	for name, track in Assets.Music do
		if MusicManager.Register(name, track.asset, { loopRegion = track.loopRegion, volume = track.volume }) then
			table.insert(registered, name)
		end
	end
	if #registered == 0 then
		return -- all placeholders
	end
	MusicManager.Preload(registered)
	MusicManager.Play(if table.find(registered, "Main") then "Main" else registered[1], 3)
end

return MusicController
