--!strict
-- VoiceController: plays the monster's lines as 3D speech from wherever it stands, and shows a
-- subtitle when you are close enough to hear it.
--
-- Audio graph (new Audio API, built locally on each client):
--   AudioTextToSpeech (monster Head) -> Wire -> AudioEmitter (monster Head)
--   AudioListener (camera) -> Wire -> AudioDeviceOutput
-- The emitter's distance curve makes the voice fade with distance, so you hear it "from the
-- basement" or "right behind you". The server only sends the text (MonsterSpeak).

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local NetClient = require(Shared.Net.Client)
local HorrorConfig = require(Shared.Config.HorrorConfig)

local Client = script.Parent.Parent
local Hud = require(Client.UI.Hud)

local player = Players.LocalPlayer
local cfg = HorrorConfig.Voice

local VoiceController = {}

local tts: AudioTextToSpeech? = nil
local subtitleToken = 0

local function wire(source: Instance, target: Instance)
	local w = Instance.new("Wire")
	w.SourceInstance = source
	w.TargetInstance = target
	w.Parent = target
end

-- One listener on the camera for the whole session.
local function ensureListener()
	local camera = Workspace.CurrentCamera
	if not camera or camera:FindFirstChildOfClass("AudioListener") then
		return -- ours, or one the engine made (voice-chat places): either already hears the emitter
	end
	local listener = Instance.new("AudioListener")
	listener.Name = "VoiceListener"
	listener.Parent = camera
	local output = SoundService:FindFirstChild("VoiceOutput")
	if not output then
		output = Instance.new("AudioDeviceOutput")
		output.Name = "VoiceOutput"
		output.Parent = SoundService
	end
	wire(listener, output :: Instance)
end

local function monsterHead(): BasePart?
	for _, m in CollectionService:GetTagged("Monster") do
		local head = m:FindFirstChild("Head")
		if head and head:IsA("BasePart") then
			return head
		end
	end
	return nil
end

local function ensureVoice(head: BasePart): AudioTextToSpeech
	local existing = head:FindFirstChild("Voice")
	if existing and existing:IsA("AudioTextToSpeech") then
		return existing
	end
	local voice = Instance.new("AudioTextToSpeech")
	voice.Name = "Voice"
	voice.VoiceId = cfg.VoiceId
	voice.Pitch = cfg.Pitch
	voice.Speed = cfg.Speed
	voice.Volume = cfg.Volume
	voice.Parent = head
	local emitter = Instance.new("AudioEmitter")
	emitter.Name = "VoiceEmitter"
	emitter:SetDistanceAttenuation({ [0] = 1, [15] = 0.9, [40] = 0.45, [75] = 0.12, [110] = 0 } :: any)
	emitter.Parent = head
	wire(voice, emitter)
	return voice
end

local function showSubtitle(text: string)
	local frame = Hud.find("Bottom/Subtitle") :: Frame
	local line = Hud.find("Bottom/Subtitle/Line") :: TextLabel
	subtitleToken += 1
	local token = subtitleToken
	line.Text = text
	frame.Visible = true
	task.delay(math.clamp(#text * 0.075, 2.5, 7), function()
		if token == subtitleToken then
			frame.Visible = false
		end
	end)
end

local function speak(text: string)
	ensureListener()
	local head = monsterHead()
	if not head then
		return
	end
	-- Subtitles only for players who could actually hear it (spectators in the lobby are far).
	local camera = Workspace.CurrentCamera
	local from = if camera then camera.CFrame.Position else head.Position
	if (from - head.Position).Magnitude <= cfg.HearRange then
		showSubtitle(text)
	end
	local voice = ensureVoice(head)
	tts = voice
	task.spawn(function()
		local ok, err = pcall(function()
			if voice.IsPlaying then
				voice:Pause()
			end
			voice.Text = text
			voice.TimePosition = 0
			voice:LoadAsync()
			voice:Play()
		end)
		if not ok then
			warn(`[VoiceController] text-to-speech failed: {err}`) -- subtitles still showed
		end
	end)
end

function VoiceController.isSpeaking(): boolean
	return tts ~= nil and tts.IsPlaying
end

function VoiceController:Start()
	ensureListener()
	Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(ensureListener)
	NetClient.event("MonsterSpeak").OnClientEvent:Connect(function(text: string, _kind: string)
		if typeof(text) == "string" then
			speak(text)
		end
	end)
	-- Make sure the player hears the voice even when the character reloads.
	player.CharacterAdded:Connect(ensureListener)
end

return VoiceController
