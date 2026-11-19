--!strict
-- SpeechController: lets the monster hear your voice. If you have voice chat on, this runs
-- Roblox speech-to-text on YOUR mic only (AudioDeviceInput.Player = you) and sends each finished
-- phrase to the server (Spoke remote). Teammates still hear your normal spatial voice chat.
-- Needs VoiceChatService.UseAudioApi = Enabled (set in the place file).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local VoiceChatService = game:GetService("VoiceChatService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local NetClient = require(Shared.Net.Client)

local player = Players.LocalPlayer

local MIN_SECONDS_BETWEEN = 2

local SpeechController = {}

function SpeechController:Start()
	local ok, enabled = pcall(function()
		return VoiceChatService:IsVoiceEnabledForUserIdAsync(player.UserId)
	end)
	if not ok or not enabled then
		return -- no voice chat for this account: callouts and text chat still work
	end

	local folder = Instance.new("Folder")
	folder.Name = "MonsterEars"
	local input = Instance.new("AudioDeviceInput")
	input.Name = "Mic"
	input.Player = player
	input.Parent = folder
	local stt = Instance.new("AudioSpeechToText")
	stt.Name = "SpeechToText"
	stt.Enabled = true
	stt.Parent = folder
	local wire = Instance.new("Wire")
	wire.SourceInstance = input
	wire.TargetInstance = stt
	wire.Parent = stt
	folder.Parent = SoundService

	local remote = NetClient.event("Spoke")
	local lastSent = 0
	local lastText = ""
	stt:GetPropertyChangedSignal("Text"):Connect(function()
		local text = stt.Text
		local now = os.clock()
		if text == "" or text == lastText or now - lastSent < MIN_SECONDS_BETWEEN then
			return
		end
		local status = player:GetAttribute("Status")
		if status ~= "Alive" and status ~= "Hidden" and status ~= "Caged" then
			return
		end
		lastText = text
		lastSent = now
		remote:FireServer(text:sub(1, 200))
	end)
end

return SpeechController
