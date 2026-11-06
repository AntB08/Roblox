--!strict
-- Sfx: 2D one-shot sounds for UI and feedback using the new Audio API
-- (AudioPlayer -> Wire -> AudioFader "SfxBus" -> AudioDeviceOutput). Client only.
-- Placeholder ids (Assets.PLACEHOLDER) are skipped silently so the template runs without audio.
--
--   Sfx.play(Assets.Sounds.Collect)               -- default volume, slight pitch variation
--   Sfx.play(Assets.Sounds.Click, 0.5, 1)         -- volume 0.5, exact pitch
--   Sfx.setVolume(0.8)                            -- SFX bus (0..1), e.g. from settings

local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = require(ReplicatedStorage:WaitForChild("Shared").Config.Assets)

local MAX_CONCURRENT = 16
local READY_TIMEOUT = 2

local Sfx = {}

local root: Folder? = nil
local bus: AudioFader? = nil
local active = 0

local function wire(source: Instance, target: Instance): Wire
	local w = Instance.new("Wire")
	w.SourceInstance = source
	w.TargetInstance = target
	w.Parent = source
	return w
end

local function getBus(): (Folder, AudioFader)
	if root and root.Parent and bus then
		return root, bus
	end
	local folder = Instance.new("Folder")
	folder.Name = "SfxSystem"
	local output = Instance.new("AudioDeviceOutput")
	output.Name = "SfxOutput"
	output.Parent = folder
	local fader = Instance.new("AudioFader")
	fader.Name = "SfxBus"
	fader.Volume = 1
	fader.Parent = folder
	wire(fader, output)
	folder.Parent = SoundService
	root, bus = folder, fader
	return folder, fader
end

function Sfx.play(asset: string, volume: number?, speed: number?)
	if Assets.isPlaceholder(asset) or active >= MAX_CONCURRENT then
		return
	end
	local folder, fader = getBus()
	local player = Instance.new("AudioPlayer")
	player.Asset = asset
	player.Volume = volume or 0.8
	player.PlaybackSpeed = speed or (0.95 + math.random() * 0.1) -- tiny variation avoids fatigue
	player.Parent = folder
	wire(player, fader)
	active += 1

	task.spawn(function()
		local t0 = os.clock()
		while not player.IsReady and os.clock() - t0 < READY_TIMEOUT do
			task.wait()
		end
		if player.IsReady then
			local ended = false
			player.Ended:Once(function()
				ended = true
			end)
			player:Play()
			-- Never wait forever: stop waiting shortly after the clip's length.
			local deadline = os.clock() + player.TimeLength / math.max(player.PlaybackSpeed, 0.01) + 1
			while not ended and os.clock() < deadline do
				task.wait(0.1)
			end
		end
		active -= 1
		player:Destroy()
	end)
end

function Sfx.setVolume(v: number)
	local _, fader = getBus()
	fader.Volume = math.clamp(v, 0, 1)
end

return Sfx
