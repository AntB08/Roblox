--!nocheck
-- Builds importable Roblox animation files from the game's procedural animation code.
--
--   lune run lune/build-animations
--
-- Writes assets/animations/:
--   ItTalksBack_Animations.rbxm  one file to drag into Studio: the monster rig with all its
--                                KeyframeSequences in an AnimSaves folder (Animation Editor
--                                lists them), plus a folder of R15 player crouch animations
--   Monster_<Name>.rbxm          each monster KeyframeSequence on its own
--   Player_<Name>.rbxm           each player KeyframeSequence on its own
-- The monster poses are sampled from src/client/FX/MonsterAnimator.luau, so the files match
-- what the game shows today. Edit them in the Animation Editor, publish, paste the ids into
-- src/shared/Config/Assets.luau (Animations), and the game plays them instead.

local fs = require("@lune/fs")
local luau = require("@lune/luau")
local roblox = require("@lune/roblox")

local Instance = roblox.Instance
local CFrame = roblox.CFrame
local Vector3 = roblox.Vector3
local Color3 = roblox.Color3
local Enum = roblox.Enum

local OUT = "assets/animations"
local FPS = 20 -- keyframes per second when sampling

-- ===== Load the game's animator with a tiny shim (it expects Roblox's Random) =================
local source = fs.readFile("src/client/FX/MonsterAnimator.luau")
local ShimRandom = {
	new = function()
		local seed = 12345
		return {
			NextNumber = function(_, a, b)
				seed = (seed * 1103515245 + 12345) % 2147483648
				return a + (b - a) * (seed / 2147483648)
			end,
		}
	end,
}
local Animator = luau.load(source, {
	debugName = "MonsterAnimator",
	environment = { Random = ShimRandom, CFrame = CFrame, math = math, table = table },
})()

-- ===== Monster rig (mirror of src/server/Game/MonsterRig.luau) ===============================
local function part(name, size, color, material)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.CanCollide = false
	p.Anchored = false
	p.Massless = true
	return p
end

local function motor(name, p0, p1, c0, c1)
	local m = Instance.new("Motor6D")
	m.Name = name
	m.Part0 = p0
	m.Part1 = p1
	m.C0 = c0
	m.C1 = c1
	m.Parent = p0
	return m
end

local function buildRig()
	local SKIN = Color3.fromRGB(22, 20, 24)
	local CLOTH = Color3.fromRGB(38, 30, 30)
	local model = Instance.new("Model")
	model.Name = "TheTenantRig"
	local root = part("HumanoidRootPart", Vector3.new(2, 2, 1), SKIN)
	root.Transparency = 1
	root.Anchored = true -- so the rig stands still while you animate it
	root.Massless = false
	root.CFrame = CFrame.new(0, 4, 0)
	root.Parent = model
	local torso = part("Torso", Vector3.new(2, 3, 1), CLOTH, Enum.Material.Fabric)
	local head = part("Head", Vector3.new(1.3, 1.6, 1.3), SKIN)
	local la = part("LeftArm", Vector3.new(0.5, 4.4, 0.5), SKIN)
	local ra = part("RightArm", Vector3.new(0.5, 4.4, 0.5), SKIN)
	local ll = part("LeftLeg", Vector3.new(0.7, 3, 0.7), CLOTH, Enum.Material.Fabric)
	local rl = part("RightLeg", Vector3.new(0.7, 3, 0.7), CLOTH, Enum.Material.Fabric)
	for _, p in { torso, head, la, ra, ll, rl } do
		p.Parent = model
	end
	motor("Root", root, torso, CFrame.new(0, 0.5, 0) * CFrame.Angles(math.rad(-12), 0, 0), CFrame.new())
	motor("Neck", torso, head, CFrame.new(0, 1.5, -0.25) * CFrame.Angles(math.rad(18), 0, 0), CFrame.new(0, -0.8, 0))
	motor("LeftShoulder", torso, la, CFrame.new(-1.25, 1.3, 0), CFrame.new(0, 2, 0))
	motor("RightShoulder", torso, ra, CFrame.new(1.25, 1.3, 0), CFrame.new(0, 2, 0))
	motor("LeftHip", root, ll, CFrame.new(-0.5, -1, 0), CFrame.new(0, 1.5, 0))
	motor("RightHip", root, rl, CFrame.new(0.5, -1, 0), CFrame.new(0, 1.5, 0))
	-- Place the parts where the joints put them (the rig is static in the file).
	torso.CFrame = root.CFrame * CFrame.new(0, 0.5, 0) * CFrame.Angles(math.rad(-12), 0, 0)
	head.CFrame = torso.CFrame * CFrame.new(0, 1.5, -0.25) * CFrame.Angles(math.rad(18), 0, 0) * CFrame.new(0, 0.8, 0)
	la.CFrame = torso.CFrame * CFrame.new(-1.25, 1.3, 0) * CFrame.new(0, -2, 0)
	ra.CFrame = torso.CFrame * CFrame.new(1.25, 1.3, 0) * CFrame.new(0, -2, 0)
	ll.CFrame = root.CFrame * CFrame.new(-0.5, -1, 0) * CFrame.new(0, -1.5, 0)
	rl.CFrame = root.CFrame * CFrame.new(0.5, -1, 0) * CFrame.new(0, -1.5, 0)
	for i, x in { -0.3, 0.3 } do
		local eye = part(
			if i == 1 then "LeftEye" else "RightEye",
			Vector3.new(0.22, 0.14, 0.05),
			Color3.fromRGB(235, 230, 210),
			Enum.Material.Neon
		)
		eye.CFrame = head.CFrame * CFrame.new(x, 0.15, -0.66)
		local weld = Instance.new("Weld")
		weld.Part0 = head
		weld.Part1 = eye
		weld.C0 = CFrame.new(x, 0.15, -0.66)
		weld.Parent = eye
		eye.Parent = model
	end
	local humanoid = Instance.new("Humanoid")
	humanoid.RigType = Enum.HumanoidRigType.R15
	humanoid.HipHeight = 3
	local animator = Instance.new("Animator")
	animator.Parent = humanoid
	humanoid.Parent = model
	model.PrimaryPart = root
	return model
end

-- Monster pose tree: which Pose sits under which (parent part -> child parts).
local MONSTER_TREE = {
	HumanoidRootPart = { "Torso", "LeftLeg", "RightLeg" },
	Torso = { "Head", "LeftArm", "RightArm" },
}
-- Part1 name -> joint name in the animator's pose table.
local MONSTER_JOINT = {
	Torso = "Root",
	Head = "Neck",
	LeftArm = "LeftShoulder",
	RightArm = "RightShoulder",
	LeftLeg = "LeftHip",
	RightLeg = "RightHip",
}

local function keyframe(time, transforms, tree, rootName, easing)
	local kf = Instance.new("Keyframe")
	kf.Time = time
	local function addPose(name, parent)
		local pose = Instance.new("Pose")
		pose.Name = name
		pose.CFrame = transforms[name] or CFrame.new()
		pose.EasingStyle = easing or Enum.PoseEasingStyle.Linear
		pose.EasingDirection = Enum.PoseEasingDirection.In
		pose.Weight = 1
		pose.Parent = parent
		for _, child in tree[name] or {} do
			addPose(child, pose)
		end
	end
	addPose(rootName, kf)
	return kf
end

local function sequence(name, loop, priority)
	local seq = Instance.new("KeyframeSequence")
	seq.Name = name
	seq.Loop = loop
	seq.Priority = priority
	return seq
end

-- Samples the procedural animator into a KeyframeSequence.
-- spec: { speed, mood, action?, seconds, loop, speaking?, cycle? (seconds; overrides length) }
local function bakeMonster(name, spec)
	local state = Animator.newState()
	local ctx = {
		speed = spec.speed or 0,
		mood = spec.mood or "Calm",
		action = nil,
		actionAlpha = 0,
		speaking = spec.speaking or false,
		dt = 1 / 60,
		time = 0,
	}
	-- Settle into the base pose first (so the first keyframe isn't a T-pose).
	for i = 1, 90 do
		ctx.time = i / 60
		Animator.step(state, ctx)
	end
	local length = spec.cycle or spec.seconds
	local seq = sequence(
		name,
		spec.loop,
		if spec.action then Enum.AnimationPriority.Action else Enum.AnimationPriority.Movement
	)
	local frames = math.max(2, math.floor(length * FPS + 0.5))
	local samples = {}
	local substeps = 3
	local t0 = ctx.time
	for f = 0, frames do
		local t = f / frames * length
		if spec.action then
			ctx.action = spec.action
			ctx.actionAlpha = math.clamp(t / length, 0, 1)
		end
		for _ = 1, substeps do
			ctx.dt = (length / frames) / substeps
			ctx.time += ctx.dt
			Animator.step(state, ctx)
		end
		if f == 0 then
			t0 = ctx.time
		end
		local pose = state.pose
		local transforms = {}
		for part1, joint in MONSTER_JOINT do
			transforms[part1] = Animator.toCFrame(pose[joint])
		end
		transforms.HumanoidRootPart = CFrame.new()
		table.insert(samples, { t = t, transforms = transforms })
	end
	-- Loops that aren't a natural cycle (idle noise etc.): ease the last quarter back into the
	-- first frame so the loop point is seamless.
	if spec.loop and not spec.cycle then
		local first = samples[1].transforms
		local n = #samples
		local blendFrom = math.floor(n * 0.75)
		for i = blendFrom, n do
			local w = (i - blendFrom) / (n - blendFrom)
			w = w * w * (3 - 2 * w) -- smoothstep
			for part1, cf in samples[i].transforms do
				samples[i].transforms[part1] = cf:Lerp(first[part1], w)
			end
		end
	end
	for _, sample in samples do
		keyframe(sample.t, sample.transforms, MONSTER_TREE, "HumanoidRootPart").Parent = seq
	end
	return seq
end

-- One walk/run cycle: phase advances by (2 + speed * k) rad/s; a full stride is 2*pi.
local function cycle(speed)
	local k = if speed > 13 then 0.55 else 0.42
	return (2 * math.pi) / (2 + speed * k)
end

local MONSTER = {
	{ "Idle", { speed = 0, seconds = 4, loop = true } },
	{ "Walk", { speed = 9, cycle = cycle(9), loop = true } },
	{ "Run", { speed = 17, mood = "Chase", cycle = cycle(17), loop = true } },
	{ "Listen", { speed = 0, mood = "Alert", seconds = 3, loop = true } },
	{ "Speak", { speed = 0, speaking = true, seconds = 2.5, loop = true } },
	{ "Dormant", { speed = 0, mood = "Dormant", seconds = 3, loop = true } },
	{ "Grab", { action = "Grab", seconds = 1.6, loop = false } },
	{ "Snuff", { action = "Snuff", seconds = 1, loop = false } },
	{ "Look", { action = "Look", seconds = 1.1, loop = false } },
	{ "Vanish", { action = "Vanish", seconds = 0.9, loop = false } },
	{ "Emerge", { action = "Emerge", seconds = 1.2, loop = false } },
}

-- ===== Player (R15) crouch ==================================================================
local R15_TREE = {
	HumanoidRootPart = { "LowerTorso" },
	LowerTorso = { "UpperTorso", "LeftUpperLeg", "RightUpperLeg" },
	UpperTorso = { "Head", "LeftUpperArm", "RightUpperArm" },
	LeftUpperLeg = { "LeftLowerLeg" },
	LeftLowerLeg = { "LeftFoot" },
	RightUpperLeg = { "RightLowerLeg" },
	RightLowerLeg = { "RightFoot" },
	LeftUpperArm = { "LeftLowerArm" },
	LeftLowerArm = { "LeftHand" },
	RightUpperArm = { "RightLowerArm" },
	RightLowerArm = { "RightHand" },
}

-- Same squat as CrouchPoseController, keyed by Part1 name.
local function squat(legSwing)
	local s = legSwing or 0
	return {
		LowerTorso = CFrame.new(0, -0.8, 0),
		UpperTorso = CFrame.Angles(-0.35, 0, 0),
		LeftUpperLeg = CFrame.Angles(1.0 + s * 0.4, 0, 0),
		RightUpperLeg = CFrame.Angles(1.0 - s * 0.4, 0, 0),
		LeftLowerLeg = CFrame.Angles(-1.6 + math.max(0, -s) * 0.4, 0, 0),
		RightLowerLeg = CFrame.Angles(-1.6 + math.max(0, s) * 0.4, 0, 0),
		LeftUpperArm = CFrame.Angles(0.35 - s * 0.3, 0, 0),
		RightUpperArm = CFrame.Angles(0.35 + s * 0.3, 0, 0),
		LeftLowerArm = CFrame.Angles(0.4, 0, 0),
		RightLowerArm = CFrame.Angles(0.4, 0, 0),
	}
end

local function bakeCrouchIdle()
	local seq = sequence("CrouchIdle", true, Enum.AnimationPriority.Movement)
	for i, t in { 0, 1, 2 } do
		local pose = squat(0)
		pose.UpperTorso = CFrame.Angles(-0.35 + (if i == 2 then 0.04 else 0), 0, 0) -- slow breath
		keyframe(t, pose, R15_TREE, "HumanoidRootPart", Enum.PoseEasingStyle.Cubic).Parent = seq
	end
	return seq
end

local function bakeCrouchWalk()
	local seq = sequence("CrouchWalk", true, Enum.AnimationPriority.Movement)
	local length = 1.1
	local frames = 12
	for f = 0, frames do
		local t = f / frames * length
		keyframe(t, squat(math.sin(t / length * math.pi * 2)), R15_TREE, "HumanoidRootPart").Parent = seq
	end
	return seq
end

-- ===== Write files ==========================================================================
fs.writeDir(OUT)
local bundle = Instance.new("Folder")
bundle.Name = "ItTalksBack_Animations"

local rig = buildRig()
local saves = Instance.new("Model")
saves.Name = "AnimSaves" -- the Animation Editor lists KeyframeSequences stored here
saves.Parent = rig
for _, entry in MONSTER do
	local seq = bakeMonster(entry[1], entry[2])
	fs.writeFile(`{OUT}/Monster_{entry[1]}.rbxm`, roblox.serializeModel({ seq }))
	seq.Parent = saves
end
rig.Parent = bundle

local playerFolder = Instance.new("Folder")
playerFolder.Name = "PlayerAnimations_R15"
for _, seq in { bakeCrouchIdle(), bakeCrouchWalk() } do
	fs.writeFile(`{OUT}/Player_{seq.Name}.rbxm`, roblox.serializeModel({ seq }))
	seq.Parent = playerFolder
end
playerFolder.Parent = bundle

fs.writeFile(`{OUT}/ItTalksBack_Animations.rbxm`, roblox.serializeModel({ bundle }))
print(`wrote {#MONSTER} monster + 2 player animations to {OUT}/`)
