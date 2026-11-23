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
local FPS = 30 -- keyframes per second when sampling

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

-- ===== Monster rig (built from MonsterRig.SPEC, the same table the game uses) =================
local rigSource = fs.readFile("src/server/Game/MonsterRig.luau")
local MonsterRig = luau.load(rigSource, {
	debugName = "MonsterRig",
	environment = {
		Instance = Instance,
		CFrame = CFrame,
		Vector3 = Vector3,
		Color3 = Color3,
		Enum = Enum,
		table = table,
		math = math,
		ipairs = ipairs,
	},
})()
local SPEC = MonsterRig.SPEC

local function buildRig()
	local model = Instance.new("Model")
	model.Name = "TheTenantRig"
	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2, 2, 1)
	root.Transparency = 1
	root.Anchored = true -- so the rig stands still while you animate it
	root.CanCollide = false
	root.CFrame = CFrame.new(0, 4, 0)
	root.Parent = model
	local parts = { HumanoidRootPart = root }
	for _, spec in SPEC.parts do
		local p = Instance.new("Part")
		p.Name = spec.name
		p.Size = spec.size
		p.Color = spec.color
		p.Material = spec.material
		p.CanCollide = false
		p.Massless = true
		p.Parent = model
		parts[spec.name] = p
	end
	for _, j in SPEC.joints do
		local m = Instance.new("Motor6D")
		m.Name = j.name
		m.Part0 = parts[j.part0]
		m.Part1 = parts[j.part1]
		m.C0 = j.c0
		m.C1 = j.c1
		m.Parent = parts[j.part0]
	end
	-- Rest layout.
	local placed = { HumanoidRootPart = true }
	local progress = true
	while progress do
		progress = false
		for _, j in SPEC.joints do
			if placed[j.part0] and not placed[j.part1] then
				parts[j.part1].CFrame = parts[j.part0].CFrame * j.c0 * j.c1:Inverse()
				placed[j.part1] = true
				progress = true
			end
		end
	end
	for _, d in SPEC.decor do
		local host = parts[d.attach]
		local p = Instance.new("Part")
		p.Name = d.name
		p.Size = d.size
		p.Color = d.color
		p.Material = d.material
		p.CanCollide = false
		p.Massless = true
		p.CFrame = host.CFrame * d.offset
		local weld = Instance.new("Weld")
		weld.Part0 = host
		weld.Part1 = p
		weld.C0 = d.offset
		weld.Parent = p
		p.Parent = model
	end
	local humanoid = Instance.new("Humanoid")
	humanoid.RigType = Enum.HumanoidRigType.R15
	humanoid.HipHeight = SPEC.hipHeight
	local animator = Instance.new("Animator")
	animator.Parent = humanoid
	humanoid.Parent = model
	model.PrimaryPart = root
	return model
end

-- Pose tree (parent part -> child parts) and Part1 -> joint name, from the spec.
local MONSTER_TREE = {}
local MONSTER_JOINT = {}
for _, j in SPEC.joints do
	MONSTER_TREE[j.part0] = MONSTER_TREE[j.part0] or {}
	table.insert(MONSTER_TREE[j.part0], j.part1)
	MONSTER_JOINT[j.part1] = j.name
end

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
	for i = 1, 240 do -- springs need a few seconds to reach their steady loop
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
	if spec.loop then -- (cycles too: tendrils/fingers don't share the gait's period)
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

-- (matches MonsterAnimator: phase advances 2*pi per stride of distance)
local function cycle(speed)
	local stride = if speed > 13 then 9.5 else 6
	return stride / speed
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
