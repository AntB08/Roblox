--!strict
-- VoiceGateService: this game is voice-chat only. Players without voice chat enabled are
-- removed on join with a message saying why (voice chat needs an ID-verified 13+ account).
-- Off in Studio (no voice there), and if Roblox can't answer after a few tries we let the
-- player in rather than kick them for an outage.
-- Toggle: HorrorConfig.RequireVoiceChat.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VoiceChatService = game:GetService("VoiceChatService")

local HorrorConfig = require(ReplicatedStorage:WaitForChild("Shared").Config.HorrorConfig)

local KICK_MESSAGE = "It Talks Back is played with voice chat. Turn on voice chat in your Roblox settings "
	.. "(it needs an ID-verified 13+ account), then rejoin."
local ATTEMPTS = 3

local VoiceGateService = {}
VoiceGateService.Priority = 170 -- before data loads, so blocked players never start a session

local function check(player: Player)
	for attempt = 1, ATTEMPTS do
		local ok, enabled = pcall(function()
			return VoiceChatService:IsVoiceEnabledForUserIdAsync(player.UserId)
		end)
		if ok then
			if not enabled and player.Parent == Players then
				player:Kick(KICK_MESSAGE)
			end
			return
		end
		task.wait(attempt)
	end
	warn(`[VoiceGate] could not check voice for {player.UserId}; letting them in`)
end

function VoiceGateService:Start()
	if not HorrorConfig.RequireVoiceChat or RunService:IsStudio() then
		return
	end
	Players.PlayerAdded:Connect(check)
	for _, player in Players:GetPlayers() do
		task.spawn(check, player)
	end
end

return VoiceGateService
