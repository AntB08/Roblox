--!strict
-- MonsterFxController: everything that makes the monster *feel* present, all client-side and
-- cosmetic (the server never waits on any of it):
--   * procedural walk: swings the rig's Motor6D.Transform from the root's speed (no anim asset)
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

local Client = script.Parent.Parent
local CameraShaker = require(Client.FX.CameraShaker)
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
	phase: number,
	twitch: CFrame,
	nextTwitch: number,
}

local rig: Rig? = nil
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
			phase = 0,
			twitch = CFrame.identity,
			nextTwitch = 0,
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

local function animate(r: Rig, dt: number)
	local v = r.root.AssemblyLinearVelocity
	local speed = Vector3.new(v.X, 0, v.Z).Magnitude
	local moving = math.clamp(speed / 12, 0, 1.3)
	local before = r.phase
	r.phase += dt * (2 + speed * 0.42)
	local s = math.sin(r.phase)
	local swing = 0.55 * moving
	local m = r.motors
	if m.LeftHip then
		m.LeftHip.Transform = CFrame.Angles(s * swing, 0, 0)
	end
	if m.RightHip then
		m.RightHip.Transform = CFrame.Angles(-s * swing, 0, 0)
	end
	-- Arms dangle and sway a little behind the legs; extra limp swing at speed.
	local sway = math.sin(r.phase * 0.5) * 0.08
	if m.LeftShoulder then
		m.LeftShoulder.Transform = CFrame.Angles(-s * swing * 0.6 + sway, 0, 0.06)
	end
	if m.RightShoulder then
		m.RightShoulder.Transform = CFrame.Angles(s * swing * 0.6 - sway, 0, -0.06)
	end
	if m.Root then
		m.Root.Transform = CFrame.new(0, math.abs(s) * 0.12 * moving, 0) * CFrame.Angles(0, s * 0.05 * moving, 0)
	end
	-- Head twitches when alert / chasing.
	local mood = r.model:GetAttribute("Mood")
	local now = os.clock()
	if (mood == "Alert" or mood == "Chase") and now >= r.nextTwitch and not GuiService.ReducedMotionEnabled then
		r.nextTwitch = now + rng:NextNumber(0.4, 1.6)
		r.twitch = CFrame.Angles(rng:NextNumber(-0.2, 0.2), rng:NextNumber(-0.5, 0.5), rng:NextNumber(-0.35, 0.35))
	elseif mood ~= "Alert" and mood ~= "Chase" then
		r.twitch = r.twitch:Lerp(CFrame.identity, math.min(1, dt * 4))
	end
	if m.Neck then
		m.Neck.Transform = r.twitch
	end
	-- Footstep on every half cycle while walking.
	if moving > 0.15 and math.floor(before / math.pi) ~= math.floor(r.phase / math.pi) then
		r.step.PlaybackSpeed = 0.5 + rng:NextNumber(0, 0.1)
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
	local t = os.clock()
	for i, entry in lights do
		local base = if powerOn then entry.base * 1.7 else entry.base
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

function MonsterFxController:Start()
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
