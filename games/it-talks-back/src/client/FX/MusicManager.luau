--!strict
-- MusicManager: background music with the new Audio API (knowledge/05 section 12.5). Client only.
-- Graph: AudioPlayer -> AudioFader(track) -> AudioFader("MusicBus") -> AudioDeviceOutput.
-- Rules (user preference): INSTRUMENTAL tracks only (no vocals, choir, humming), seamless loops
-- (Looping = true + LoopRegion to skip intro/outro), crossfades instead of hard cuts, music bus
-- well under SFX. Placeholder ids are ignored, so the template runs silently until real ids exist.
--
--   MusicManager.Register("Main", "rbxassetid://123", { loopRegion = NumberRange.new(4.0, 92.0) })
--   MusicManager.Play("Main", 2)          -- crossfade over 2 s
--   MusicManager.Duck(0.35, 0.2, 2.5)     -- duck to 35% for 2.5 s (stinger)
--   MusicManager.SetUserVolume(0.8)       -- settings slider (0..1)
-- Test the loop seam in Studio: set TimePosition to loopEnd - 3 and listen.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Assets = require(ReplicatedStorage:WaitForChild("Shared").Config.Assets)

type TrackDef = { asset: string, loopRegion: NumberRange?, volume: number? }
type Track = { def: TrackDef, player: AudioPlayer, fader: AudioFader, tween: Tween? }

local BASE_BUS_VOLUME = 0.4 -- music sits well under SFX

local MusicManager = {}

local defs: { [string]: TrackDef } = {}
local tracks: { [string]: Track } = {}
local current: string? = nil
local userVolume = 1
local duckLevel = 1
local duckToken = 0

local root: Folder? = nil
local output: AudioDeviceOutput? = nil
local bus: AudioFader? = nil

local function wire(source: Instance, target: Instance): Wire
	local w = Instance.new("Wire")
	w.SourceInstance = source
	w.TargetInstance = target
	w.Parent = target
	return w
end

-- Built lazily (no instances created at require time).
local function graph(): (Folder, AudioDeviceOutput, AudioFader)
	if root and output and bus and root.Parent then
		return root, output, bus
	end
	local folder = Instance.new("Folder")
	folder.Name = "MusicSystem"
	local out = Instance.new("AudioDeviceOutput")
	out.Name = "MusicOutput"
	out.Parent = folder
	local fader = Instance.new("AudioFader")
	fader.Name = "MusicBus"
	fader.Volume = BASE_BUS_VOLUME * userVolume * duckLevel
	fader.Parent = folder
	wire(fader, out)
	folder.Parent = SoundService
	root, output, bus = folder, out, fader
	return folder, out, fader
end

local function applyBus(fadeTime: number)
	local _, _, fader = graph()
	local goal = BASE_BUS_VOLUME * userVolume * duckLevel
	if fadeTime <= 0 then
		fader.Volume = goal
	else
		TweenService
			:Create(fader, TweenInfo.new(fadeTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Volume = goal })
			:Play()
	end
end

local function waitReady(player: AudioPlayer, timeout: number): boolean
	local t0 = os.clock()
	while not player.IsReady and os.clock() - t0 < timeout do
		task.wait(0.05)
	end
	return player.IsReady
end

local function getTrack(name: string): Track?
	local existing = tracks[name]
	if existing then
		return existing
	end
	local def = defs[name]
	if not def then
		return nil
	end
	local folder, _, fader = graph()
	local player = Instance.new("AudioPlayer")
	player.Name = name
	player.Asset = def.asset
	player.Looping = true
	if def.loopRegion then
		player.LoopRegion = def.loopRegion -- skip intro/outro so the loop is seamless
	end
	player.Volume = def.volume or 1
	player.Parent = folder

	local trackFader = Instance.new("AudioFader")
	trackFader.Name = name .. "_Fader"
	trackFader.Volume = 0
	trackFader.Parent = folder

	wire(player, trackFader)
	wire(trackFader, fader)

	local t: Track = { def = def, player = player, fader = trackFader, tween = nil }
	tracks[name] = t
	return t
end

local function fadeTo(t: Track, volume: number, time: number, direction: Enum.EasingDirection, onDone: (() -> ())?)
	if t.tween then
		t.tween:Cancel()
	end
	local tw = TweenService:Create(
		t.fader,
		TweenInfo.new(math.max(time, 0.01), Enum.EasingStyle.Sine, direction),
		{ Volume = volume }
	)
	t.tween = tw
	if onDone then
		tw.Completed:Once(function(state: Enum.PlaybackState)
			if state == Enum.PlaybackState.Completed then
				onDone()
			end
		end)
	end
	tw:Play()
end

-- Returns false (and registers nothing) for placeholder ids.
function MusicManager.Register(
	name: string,
	asset: string,
	opts: { loopRegion: NumberRange?, volume: number? }?
): boolean
	if Assets.isPlaceholder(asset) then
		return false
	end
	defs[name] = { asset = asset, loopRegion = opts and opts.loopRegion, volume = opts and opts.volume }
	return true
end

-- Preload so the first crossfade has no gap (call during loading).
function MusicManager.Preload(names: { string })
	for _, n in names do
		local t = getTrack(n)
		if t then
			task.spawn(waitReady, t.player, 10)
		end
	end
end

function MusicManager.Play(name: string, fadeTime: number?, restart: boolean?)
	local fade = fadeTime or 2
	if current == name then
		return
	end
	local nextTrack = getTrack(name)
	if not nextTrack then
		return -- unknown or placeholder: stay silent
	end
	local prevName = current
	current = name

	task.spawn(function()
		if not waitReady(nextTrack.player, 5) then
			warn(`[MusicManager] track "{name}" failed to load (check asset id and permissions)`)
		end
		if current ~= name then
			return -- another Play() happened while loading
		end
		if restart or not nextTrack.player.IsPlaying then
			nextTrack.player.TimePosition = 0
			nextTrack.player:Play()
		end
		fadeTo(nextTrack, 1, fade, Enum.EasingDirection.Out)

		if prevName then
			local prev = tracks[prevName]
			if prev then
				fadeTo(prev, 0, fade, Enum.EasingDirection.In, function()
					if current ~= prevName then
						prev.player:Stop()
					end
				end)
			end
		end
	end)
end

function MusicManager.Stop(fadeTime: number?)
	local name = current
	current = nil
	if not name then
		return
	end
	local t = tracks[name]
	if t then
		fadeTo(t, 0, fadeTime or 1.5, Enum.EasingDirection.In, function()
			if current ~= name then
				t.player:Stop()
			end
		end)
	end
end

function MusicManager.Duck(level: number, fadeTime: number, holdTime: number)
	duckToken += 1
	local token = duckToken
	duckLevel = math.clamp(level, 0, 1)
	applyBus(fadeTime)
	task.delay(holdTime, function()
		if token ~= duckToken then
			return
		end
		duckLevel = 1
		applyBus(1.0)
	end)
end

function MusicManager.SetUserVolume(v: number)
	userVolume = math.clamp(v, 0, 1)
	applyBus(0.15)
end

-- One-shot instrumental stinger on the music output, ducking the music under it.
function MusicManager.Stinger(asset: string, volume: number?)
	if Assets.isPlaceholder(asset) then
		return
	end
	local folder, out = graph()
	local p = Instance.new("AudioPlayer")
	p.Asset = asset
	p.Volume = (volume or 1) * userVolume
	p.Parent = folder
	wire(p, out)
	task.spawn(function()
		if not waitReady(p, 3) then
			p:Destroy()
			return
		end
		MusicManager.Duck(0.3, 0.15, math.max(p.TimeLength - 0.5, 0.5))
		p.Ended:Once(function()
			p:Destroy()
		end)
		p:Play()
	end)
end

function MusicManager.Current(): string?
	return current
end

return MusicManager
