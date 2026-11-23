--!strict
-- MonsterFxController: everything that makes the monster *feel* present, all client-side and
-- cosmetic (the server never waits on any of it):
--   * procedural animation of every state (FX/MonsterAnimator.luau): idle, creep, chase sprint,
--     listen, speak, grab, snuff, look, vanish/emerge (no uploaded animation assets)
--   * eyes change color with its Mood (Calm / Alert / Chase), and twitch when alert
--   * heavy, slow footsteps from its root (3D)
--   * house lights flicker near it
--   * red screen edges + sustained camera shake as it gets close to YOU, stronger when it is
--     chasing you; chase music if a Chase track is set in Assets
--   * dark edges + first-person camera while you hide in a closet

local CollectionService = game:GetService("CollectionService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Assets = require(Shared.Config.Assets)
local NetClient = require(Shared.Net.Client)

local Client = script.Parent.Parent
local CameraShaker = require(Client.FX.CameraShaker)
local MonsterAnimator = require(Client.FX.MonsterAnimator)
local VoiceController = require(script.Parent.VoiceController)
local MusicManager = require(Client.FX.MusicManager)

local player = Players.LocalPlayer

local EYE_COLORS: { [string]: Color3 } = {
	Dormant = Color3.fromRGB(70, 70, 70),
	Calm = Color3.fromRGB(235, 230, 210),
	Alert = Color3.fromRGB(255, 180, 60),
	Chase = Color3.fromRGB(255, 40, 30),
}
local ANIMATE_DISTANCE = 160
local FLICKER_DISTANCE = 30
local DANGER_DISTANCE = 45

local MonsterFxController = {}

type Rig = {
	model: Model,
	root: BasePart,
	head: BasePart,
	motors: { [string]: Motor6D },
	step: Sound,
	anim: MonsterAnimator.State,
	fade: number,
	tracks: { [string]: AnimationTrack },
	baseTrack: string?,
	lastActionUntil: number,
}

-- Seconds each server action lasts (must match MonsterService / TaskService act() calls).
local ACTION_LENGTH: { [string]: number } = { Grab = 1.6, Snuff = 1, Look = 1.1, Vanish = 0.9, Emerge = 1.2 }

local rig: Rig? = nil
local loadTracks: (Model) -> { [string]: AnimationTrack }
local lights: { { part: BasePart, light: PointLight, base: number } } = {}
local rng = Random.new()

local function findRig(): Rig?
	if rig and rig.model.Parent then
		return rig
	end
	rig = nil
	for _, m in CollectionService:GetTagged("Monster") do
		if not m:IsA("Model") then
			continue
		end
		local root = m:FindFirstChild("HumanoidRootPart")
		local head = m:FindFirstChild("Head")
		if not (root and root:IsA("BasePart") and head and head:IsA("BasePart")) then
			continue
		end
		local motors: { [string]: Motor6D } = {}
		for _, d in m:GetDescendants() do
			if d:IsA("Motor6D") then
				motors[d.Name] = d
			end
		end
		local step = Instance.new("Sound")
		step.Name = "Step"
		step.SoundId = Assets.Sounds.MonsterStep
		step.Volume = 1.6
		step.PlaybackSpeed = 0.55
		step.RollOffMode = Enum.RollOffMode.InverseTapered
		step.RollOffMinDistance = 8
		step.RollOffMaxDistance = 70
		step.Parent = root
		rig = {
			model = m,
			root = root,
			head = head,
			motors = motors,
			step = step,
			anim = MonsterAnimator.newState(),
			fade = 0,
			tracks = loadTracks(m),
			baseTrack = nil,
			lastActionUntil = 0,
		}
		return rig
	end
	return nil
end

local function collectLights()
	table.clear(lights)
	for _, part in CollectionService:GetTagged("HouseLight") do
		local light = part:FindFirstChildOfClass("PointLight")
		if part:IsA("BasePart") and light then
			local base = tonumber(part:GetAttribute("BaseBrightness")) or light.Brightness
			table.insert(lights, { part = part, light = light, base = base })
		end
	end
end

-- Published animations (Assets.Animations.Monster): when an Idle id is set, the monster uses
-- AnimationTracks for every state that has an id; the procedural animator still runs for
-- timing (footsteps) but doesn't move the joints.
loadTracks = function(m: Model): { [string]: AnimationTrack }
	local tracks: { [string]: AnimationTrack } = {}
	local humanoid = m:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		return tracks
	end
	for name, id in Assets.Animations.Monster do
		if not Assets.isPlaceholder(id) then
			local anim = Instance.new("Animation")
			anim.AnimationId = id
			local ok, track = pcall(function()
				return animator:LoadAnimation(anim)
			end)
			if ok then
				tracks[name] = track
			else
				warn(`[MonsterFx] could not load monster animation {name} ({id}): {track}`)
			end
		end
	end
	return tracks
end

local function baseStateName(speed: number, mood: any, speaking: boolean): string
	if mood == "Dormant" then
		return "Dormant"
	elseif speed > 11 then
		return "Run"
	elseif speed > 1.5 then
		return "Walk"
	elseif speaking then
		return "Speak"
	elseif mood == "Alert" then
		return "Listen"
	end
	return "Idle"
end

local function playTracks(r: Rig, speed: number, mood: any, speaking: boolean, action: string?, untilT: number)
	local wanted = baseStateName(speed, mood, speaking)
	if not r.tracks[wanted] then
		wanted = "Idle"
	end
	if r.baseTrack ~= wanted then
		local old = r.baseTrack and r.tracks[r.baseTrack]
		if old then
			old:Stop(0.25)
		end
		r.tracks[wanted]:Play(0.25)
		r.baseTrack = wanted
	end
	local walking = r.tracks[wanted]
	if wanted == "Walk" or wanted == "Run" then
		walking:AdjustSpeed(math.clamp(speed / (if wanted == "Run" then 17 else 9), 0.6, 1.6))
	end
	-- One-shot actions: start once per new server action.
	if action and untilT ~= r.lastActionUntil then
		r.lastActionUntil = untilT
		local track = r.tracks[action]
		if track then
			track:Play(0.1)
		end
	end
end

local function animate(r: Rig, dt: number)
	local v = r.root.AssemblyLinearVelocity
	local speed = Vector3.new(v.X, 0, v.Z).Magnitude
	local mood = r.model:GetAttribute("Mood")
	local action = r.model:GetAttribute("Action")
	local untilT = tonumber(r.model:GetAttribute("ActionUntil")) or 0
	local now = Workspace:GetServerTimeNow()
	local activeAction: string? = nil
	local alpha = 0
	if typeof(action) == "string" and now < untilT then
		activeAction = action
		local length = ACTION_LENGTH[action] or 1
		alpha = math.clamp(1 - (untilT - now) / length, 0, 1)
	end
	if GuiService.ReducedMotionEnabled and activeAction == "Vanish" then
		activeAction = nil -- no strobing glitch for reduced-motion players
	end
	local pose = MonsterAnimator.step(r.anim, {
		speed = speed,
		mood = if typeof(mood) == "string" then mood else "Calm",
		action = activeAction,
		actionAlpha = alpha,
		speaking = VoiceController.isSpeaking(),
		dt = dt,
		time = os.clock(),
	})
	if r.tracks.Idle then
		playTracks(r, speed, mood, VoiceController.isSpeaking(), activeAction, untilT)
	else
		for _, name in MonsterAnimator.Joints do
			local motor = r.motors[name]
			if motor then
				motor.Transform = MonsterAnimator.toCFrame(pose[name])
			end
		end
	end
	-- Vanish: fade out while glitching; Emerge: fade back in (local only, cosmetic).
	local fade = 0
	if activeAction == "Vanish" then
		fade = alpha
	elseif activeAction == "Emerge" then
		fade = 1 - math.clamp(alpha * 2, 0, 1)
	end
	if fade ~= r.fade then
		r.fade = fade
		for _, d in r.model:GetDescendants() do
			if d:IsA("BasePart") then
				d.LocalTransparencyModifier = fade
			end
		end
	end
	if r.anim.stepped then
		r.step.PlaybackSpeed = 0.5 + rng:NextNumber(0, 0.1)
		r.step.Volume = if speed > 13 then 2.2 else 1.6
		r.step:Play()
	end
end

local function updateEyes(r: Rig)
	local mood = r.model:GetAttribute("Mood")
	local color = EYE_COLORS[if typeof(mood) == "string" then mood else "Calm"] or EYE_COLORS.Calm
	for _, d in r.model:GetChildren() do
		if d:IsA("BasePart") and d:HasTag("MonsterEye") then
			d.Color = color
		end
	end
	local glow = r.head:FindFirstChild("EyeGlow")
	if glow and glow:IsA("PointLight") then
		glow.Color = color
		glow.Brightness = if mood == "Chase" then 1.4 elseif mood == "Dormant" then 0.1 else 0.6
	end
end

local function updateLights(monsterPos: Vector3?)
	local powerOn = Workspace:GetAttribute("PowerOn") == true
	local lightsOut = Workspace:GetAttribute("LightsOut") == true and not powerOn
	local t = os.clock()
	for i, entry in lights do
		local base = if lightsOut then 0 elseif powerOn then entry.base * 1.7 else entry.base
		local near = monsterPos and (entry.part.Position - monsterPos).Magnitude < FLICKER_DISTANCE
		if near then
			-- Each lamp flickers on its own rhythm.
			local n = math.noise(t * 9, i * 3.7)
			entry.light.Brightness = if n > 0.15 then 0 else base * (0.4 + n)
		else
			entry.light.Brightness = base
		end
		entry.part.Transparency = if entry.light.Brightness < 0.05 then 0.6 else 0
	end
end

local function setEdges(gui: ScreenGui, a: string, b: string, alpha: number)
	for _, name in { a, b } do
		local f = gui:FindFirstChild(name)
		if f and f:IsA("Frame") then
			f.BackgroundTransparency = 1 - alpha
		end
	end
end

-- Server-requested 3D one-shots (knocking in an empty room...): (soundKey, position, times)
local function playAt(soundKey: string, position: Vector3, times: number)
	local id = (Assets.Sounds :: any)[soundKey]
	if typeof(id) ~= "string" or Assets.isPlaceholder(id) or typeof(position) ~= "Vector3" then
		return
	end
	local anchor = Instance.new("Part")
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.CanTouch = false
	anchor.Transparency = 1
	anchor.Size = Vector3.one
	anchor.Position = position
	local sound = Instance.new("Sound")
	sound.SoundId = id
	sound.Volume = 2.2
	sound.PlaybackSpeed = 0.6
	sound.RollOffMode = Enum.RollOffMode.InverseTapered
	sound.RollOffMinDistance = 10
	sound.RollOffMaxDistance = 120
	sound.Parent = anchor
	anchor.Parent = Workspace
	task.spawn(function()
		for _ = 1, math.clamp(math.floor(tonumber(times) or 1), 1, 5) do
			sound.PlaybackSpeed = 0.55 + rng:NextNumber(0, 0.1)
			sound:Play()
			task.wait(0.45)
		end
		task.wait(1)
		anchor:Destroy()
	end)
end

function MonsterFxController:Start()
	NetClient.event("PlaySoundAt").OnClientEvent:Connect(playAt)
	collectLights()
	CollectionService:GetInstanceAddedSignal("HouseLight"):Connect(collectLights)
	local overlay = player:WaitForChild("PlayerGui"):WaitForChild("Overlay", 30) :: ScreenGui?
	local chaseMusic = not Assets.isPlaceholder(Assets.Music.Chase.asset)
	local inChaseMusic = false
	local lastMood: any = nil

	-- Hiding: first-person + dark edges.
	local function syncHide()
		local hidden = player:GetAttribute("Status") == "Hidden"
		local wasFirstPerson = player.CameraMode == Enum.CameraMode.LockFirstPerson
		player.CameraMode = if hidden then Enum.CameraMode.LockFirstPerson else Enum.CameraMode.Classic
		if wasFirstPerson and not hidden then
			-- Leaving first person keeps minimum zoom; push the camera back out once.
			local minZoom = player.CameraMinZoomDistance
			player.CameraMinZoomDistance = 8
			task.delay(0.1, function()
				player.CameraMinZoomDistance = minZoom
			end)
		end
		if overlay then
			setEdges(overlay, "HideX", "HideY", if hidden then 0.85 else 0)
		end
	end
	player:GetAttributeChangedSignal("Status"):Connect(syncHide)
	syncHide()

	RunService.RenderStepped:Connect(function(dt: number)
		local r = findRig()
		local monsterPos = if r then r.root.Position else nil
		local camera = Workspace.CurrentCamera
		if r and camera then
			if (camera.CFrame.Position - r.root.Position).Magnitude < ANIMATE_DISTANCE then
				animate(r, dt)
			end
			local mood = r.model:GetAttribute("Mood")
			if mood ~= lastMood then
				lastMood = mood
				updateEyes(r)
			end
		end
		updateLights(monsterPos)

		-- Danger feedback for the local player.
		local danger = 0
		local character = player.Character
		local myRoot = character and character:FindFirstChild("HumanoidRootPart")
		local status = player:GetAttribute("Status")
		local targeted = r ~= nil and r.model:GetAttribute("TargetUserId") == player.UserId
		if r and myRoot and myRoot:IsA("BasePart") and (status == "Alive" or status == "Hidden") then
			local d = (myRoot.Position - r.root.Position).Magnitude
			danger = math.clamp(1 - (d - 6) / DANGER_DISTANCE, 0, 1)
			if not targeted then
				danger *= 0.45
			end
		end
		if overlay then
			setEdges(overlay, "DangerX", "DangerY", danger * 0.55)
		end
		CameraShaker.SetSustained("monster", if targeted then danger * 0.22 else danger * 0.06)

		if chaseMusic then
			local want = targeted and danger > 0
			if want ~= inChaseMusic then
				inChaseMusic = want
				MusicManager.Play(if want then "Chase" else "Ambient", if want then 0.6 else 3)
			end
		end
	end)
end

return MonsterFxController
