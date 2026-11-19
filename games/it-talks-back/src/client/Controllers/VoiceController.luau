--!strict
-- VoiceController: the monster's voice, played in 3D from its head, plus subtitles when you
-- are close enough to hear it. The server only sends the line's text (MonsterSpeak).
--
-- Two kinds of voice:
--   * Recorded: if Shared/Config/VoiceLines.luau has an uploaded clip for this exact line, it
--     plays that (your own horror voice), with only room reverb added.
--   * Live: Roblox text-to-speech, disguised as a monster. Two layers (normal-low and very low)
--     run through EQ -> Distortion -> Chorus -> Tremolo -> Reverb. Tune in HorrorConfig.Voice.Effects.
-- A camera AudioListener -> AudioDeviceOutput lets the player hear the emitter.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local NetClient = require(Shared.Net.Client)
local HorrorConfig = require(Shared.Config.HorrorConfig)
local VoiceLines = require(Shared.Config.VoiceLines)

local Client = script.Parent.Parent
local Hud = require(Client.UI.Hud)

local player = Players.LocalPlayer
local cfg = HorrorConfig.Voice

local VoiceController = {}

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

type VoiceRig = {
	main: AudioTextToSpeech,
	low: AudioTextToSpeech,
	clip: AudioPlayer,
}

local speaking: VoiceRig? = nil

local function effect<T>(className: string, name: string, parent: Instance, props: { [string]: any }): T
	local inst = Instance.new(className)
	inst.Name = name
	for key, value in props do
		(inst :: any)[key] = value
	end
	inst.Parent = parent
	return inst :: any
end

-- Builds the monster's voice on its head once:
--   live:     [TTS main] + [TTS low layer] -> EQ -> Distortion -> Chorus -> Tremolo -> Reverb -> Emitter
--   recorded: [AudioPlayer clip] ----------------------------------------------> Reverb -> Emitter
local function ensureVoice(head: BasePart): VoiceRig
	local folder = head:FindFirstChild("MonsterVoice")
	if folder then
		return {
			main = folder:FindFirstChild("Main") :: AudioTextToSpeech,
			low = folder:FindFirstChild("Low") :: AudioTextToSpeech,
			clip = folder:FindFirstChild("Clip") :: AudioPlayer,
		}
	end
	local fx = cfg.Effects
	local root = Instance.new("Folder")
	root.Name = "MonsterVoice"

	local main = effect("AudioTextToSpeech", "Main", root, {
		VoiceId = cfg.VoiceId,
		Pitch = cfg.Pitch,
		Speed = cfg.Speed,
		Volume = cfg.Volume,
	}) :: AudioTextToSpeech
	local low = effect("AudioTextToSpeech", "Low", root, {
		VoiceId = cfg.VoiceId,
		Pitch = cfg.LowPitch,
		Speed = cfg.Speed,
		Volume = cfg.Volume * cfg.LowLayerVolume,
	}) :: AudioTextToSpeech
	local clip = effect("AudioPlayer", "Clip", root, { Volume = cfg.Volume }) :: AudioPlayer

	local eq = effect("AudioEqualizer", "EQ", root, {
		LowGain = fx.LowGain,
		MidGain = fx.MidGain,
		HighGain = fx.HighGain,
	})
	local distortion = effect("AudioDistortion", "Distortion", root, { Level = fx.Distortion })
	local chorus = effect("AudioChorus", "Chorus", root, {
		Mix = fx.ChorusMix,
		Rate = fx.ChorusRate,
		Depth = fx.ChorusDepth,
	})
	local tremolo = effect("AudioTremolo", "Tremolo", root, {
		Depth = fx.TremoloDepth,
		Frequency = fx.TremoloFrequency,
	})
	local reverb = effect("AudioReverb", "Reverb", root, {
		DecayTime = fx.ReverbDecay,
		WetLevel = fx.ReverbWet,
		DryLevel = fx.ReverbDry,
	})
	local emitter = Instance.new("AudioEmitter")
	emitter.Name = "VoiceEmitter"
	emitter:SetDistanceAttenuation({ [0] = 1, [15] = 0.9, [40] = 0.45, [75] = 0.12, [110] = 0 } :: any)
	emitter.Parent = head

	wire(main, eq)
	wire(low, eq)
	wire(eq, distortion)
	wire(distortion, chorus)
	wire(chorus, tremolo)
	wire(tremolo, reverb)
	wire(clip, reverb)
	wire(reverb, emitter)
	root.Parent = head
	return { main = main, low = low, clip = clip }
end

local function isRecording(asset: string?): boolean
	return asset ~= nil and asset ~= "" and asset ~= "rbxassetid://0"
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
	local rig = ensureVoice(head)
	speaking = rig
	task.spawn(function()
		local ok, err = pcall(function()
			for _, source in { rig.main, rig.low } do
				if source.IsPlaying then
					source:Pause()
				end
			end
			if rig.clip.IsPlaying then
				rig.clip:Stop()
			end
			local asset = VoiceLines[text]
			if isRecording(asset) then
				-- Your recorded voice for this exact line.
				rig.clip.Asset = asset
				rig.clip.TimePosition = 0
				rig.clip:Play()
				return
			end
			-- Live voice: load both layers, then start them together so they stay in sync.
			for _, source in { rig.main, rig.low } do
				source.Text = text
				source.TimePosition = 0
			end
			rig.main:LoadAsync()
			rig.low:LoadAsync()
			rig.main:Play()
			rig.low:Play()
		end)
		if not ok then
			warn(`[VoiceController] monster voice failed: {err}`) -- subtitles still showed
		end
	end)
end

function VoiceController.isSpeaking(): boolean
	local rig = speaking
	return rig ~= nil and (rig.main.IsPlaying or rig.clip.IsPlaying)
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
