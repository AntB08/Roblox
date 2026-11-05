--!strict
-- SettingsController: applies saved settings (player attributes "Setting_<Key>", set by the
-- server from the profile) to music volume and camera shake, and sends changes to the server.
--
--   SettingsController.set("MusicVolume", 0.4)   -- e.g. from a settings slider

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared.Config.GameConfig)
local NetClient = require(Shared.Net.Client)

local Client = script.Parent.Parent
local MusicManager = require(Client.FX.MusicManager)
local CameraShaker = require(Client.FX.CameraShaker)

local APPLY: { [string]: (value: number) -> () } = {
	MusicVolume = MusicManager.SetUserVolume,
	ShakeIntensity = CameraShaker.SetIntensity,
}

local SettingsController = {}

function SettingsController.get(key: string): number
	local value = Players.LocalPlayer:GetAttribute(`Setting_{key}`)
	if typeof(value) == "number" then
		return value
	end
	local spec = (GameConfig.Settings :: any)[key]
	return if spec then spec.default else 0
end

function SettingsController.set(key: string, value: number)
	local spec = (GameConfig.Settings :: any)[key]
	if not spec then
		warn("[SettingsController] unknown setting", key)
		return
	end
	local clamped = math.clamp(value, spec.min, spec.max)
	local apply = APPLY[key]
	if apply then
		apply(clamped) -- instant local feedback; the server saves and echoes the attribute
	end
	NetClient.event("SetSetting"):FireServer(key, clamped)
end

function SettingsController:Start()
	local player = Players.LocalPlayer
	for key, apply in APPLY do
		local function sync()
			apply(SettingsController.get(key))
		end
		player:GetAttributeChangedSignal(`Setting_{key}`):Connect(sync)
		sync()
	end
end

return SettingsController
