--!strict
-- MonsterRig: builds the monster model in code (no uploaded mesh needed for the prototype).
-- A tall, thin, hunched figure (~7.6 studs) with very long arms and a hinged jaw. Original design.
--
-- Skeleton (16 Motor6Ds; Part1 name in brackets). Neutral = upright; the hunch lives in the
-- animation, so the rig stays easy to edit in the Animation Editor:
--   HumanoidRootPart -Root-> [LowerTorso] -Waist-> [UpperTorso] -Neck-> [Head] -Jaw-> [Jaw]
--     UpperTorso -LeftShoulder-> [LeftUpperArm] -LeftElbow-> [LeftLowerArm] -LeftWrist-> [LeftHand]
--     (same on the right)
--     LowerTorso -LeftHip-> [LeftUpperLeg] -LeftKnee-> [LeftLowerLeg] -LeftAnkle-> [LeftFoot]
--     (same on the right)
-- Joint axes (Transform rotations): for limbs that hang down, rx > 0 swings them FORWARD (elbows
-- bend with rx > 0, knees with rx < 0); for upward parts (torso, head), rx < 0 leans forward/down;
-- Jaw rx < 0 opens the mouth.
--
-- The client animates it (FX/MonsterAnimator.luau); the exporter (lune/build-animations.luau)
-- mirrors MonsterRig.SPEC so the exported rig matches exactly.

local MonsterRig = {}

local SKIN = Color3.fromRGB(22, 20, 24)
local CLOTH = Color3.fromRGB(38, 30, 30)
local EYE = Color3.fromRGB(235, 230, 210)

local HIP_HEIGHT = 3

export type PartSpec = { name: string, size: Vector3, color: Color3, material: Enum.Material }
export type JointSpec = { name: string, part0: string, part1: string, c0: CFrame, c1: CFrame }

local PARTS: { PartSpec } = {
	{ name = "LowerTorso", size = Vector3.new(1.6, 0.9, 0.9), color = CLOTH, material = Enum.Material.Fabric },
	{ name = "UpperTorso", size = Vector3.new(2, 2.4, 1), color = CLOTH, material = Enum.Material.Fabric },
	{ name = "Head", size = Vector3.new(1.3, 1.5, 1.3), color = SKIN, material = Enum.Material.SmoothPlastic },
	{ name = "Jaw", size = Vector3.new(1.05, 0.35, 0.95), color = SKIN, material = Enum.Material.SmoothPlastic },
}
for _, side in { "Left", "Right" } do
	local skin, cloth = Enum.Material.SmoothPlastic, Enum.Material.Fabric
	table.insert(
		PARTS,
		{ name = side .. "UpperArm", size = Vector3.new(0.45, 2.3, 0.45), color = SKIN, material = skin }
	)
	table.insert(PARTS, { name = side .. "LowerArm", size = Vector3.new(0.4, 2.2, 0.4), color = SKIN, material = skin })
	table.insert(PARTS, { name = side .. "Hand", size = Vector3.new(0.35, 0.9, 0.25), color = SKIN, material = skin })
	table.insert(
		PARTS,
		{ name = side .. "UpperLeg", size = Vector3.new(0.6, 1.5, 0.6), color = CLOTH, material = cloth }
	)
	table.insert(
		PARTS,
		{ name = side .. "LowerLeg", size = Vector3.new(0.5, 1.4, 0.5), color = CLOTH, material = cloth }
	)
	table.insert(PARTS, { name = side .. "Foot", size = Vector3.new(0.55, 0.2, 1), color = SKIN, material = skin })
end

local JOINTS: { JointSpec } = {
	{
		name = "Root",
		part0 = "HumanoidRootPart",
		part1 = "LowerTorso",
		c0 = CFrame.new(0, -0.55, 0),
		c1 = CFrame.new(),
	},
	{
		name = "Waist",
		part0 = "LowerTorso",
		part1 = "UpperTorso",
		c0 = CFrame.new(0, 0.4, 0),
		c1 = CFrame.new(0, -1.2, 0),
	},
	{
		name = "Neck",
		part0 = "UpperTorso",
		part1 = "Head",
		c0 = CFrame.new(0, 1.2, -0.15),
		c1 = CFrame.new(0, -0.75, 0),
	},
	{ name = "Jaw", part0 = "Head", part1 = "Jaw", c0 = CFrame.new(0, -0.55, 0.2), c1 = CFrame.new(0, 0.1, 0.4) },
}
for i, side in { "Left", "Right" } do
	local x = if i == 1 then -1 else 1
	local function joint(name: string, p0: string, p1: string, c0: CFrame, c1: CFrame)
		table.insert(JOINTS, { name = side .. name, part0 = p0, part1 = side .. p1, c0 = c0, c1 = c1 })
	end
	joint("Shoulder", "UpperTorso", "UpperArm", CFrame.new(1.2 * x, 0.95, 0), CFrame.new(0, 1, 0))
	joint("Elbow", side .. "UpperArm", "LowerArm", CFrame.new(0, -1.05, 0), CFrame.new(0, 1.05, 0))
	joint("Wrist", side .. "LowerArm", "Hand", CFrame.new(0, -1.1, 0), CFrame.new(0, 0.45, 0))
	joint("Hip", "LowerTorso", "UpperLeg", CFrame.new(0.45 * x, -0.35, 0), CFrame.new(0, 0.75, 0))
	joint("Knee", side .. "UpperLeg", "LowerLeg", CFrame.new(0, -0.75, 0), CFrame.new(0, 0.7, 0))
	joint("Ankle", side .. "LowerLeg", "Foot", CFrame.new(0, -0.7, 0), CFrame.new(0, 0.1, 0.25))
end

MonsterRig.SPEC = table.freeze({ parts = PARTS, joints = JOINTS, hipHeight = HIP_HEIGHT })

local function bodyPart(spec: PartSpec): Part
	local p = Instance.new("Part")
	p.Name = spec.name
	p.Size = spec.size
	p.Color = spec.color
	p.Material = spec.material
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Massless = true
	p.CastShadow = true
	return p
end

function MonsterRig.build(name: string): Model
	local model = Instance.new("Model")
	model.Name = name
	model.ModelStreamingMode = Enum.ModelStreamingMode.Persistent

	-- Root: the only colliding part. Bottom of root is HIP_HEIGHT above the floor.
	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2, 2, 1)
	root.Transparency = 1
	root.CanCollide = true
	root.CanTouch = false
	root.CanQuery = false
	root.CastShadow = false
	root.Parent = model

	local parts: { [string]: BasePart } = { HumanoidRootPart = root }
	for _, spec in PARTS do
		local p = bodyPart(spec)
		p.Parent = model
		parts[spec.name] = p
	end
	for _, j in JOINTS do
		local m = Instance.new("Motor6D")
		m.Name = j.name
		m.Part0 = parts[j.part0]
		m.Part1 = parts[j.part1]
		m.C0 = j.c0
		m.C1 = j.c1
		m.Parent = parts[j.part0]
	end

	-- Lay the parts out at rest so the model looks right before the first animation frame.
	local placed: { [string]: boolean } = { HumanoidRootPart = true }
	local progress = true
	while progress do
		progress = false
		for _, j in JOINTS do
			if placed[j.part0] and not placed[j.part1] then
				parts[j.part1].CFrame = parts[j.part0].CFrame * j.c0 * j.c1:Inverse()
				placed[j.part1] = true
				progress = true
			end
		end
	end

	-- Eyes: neon dots with a faint light. Clients recolor them by mood.
	local head = parts.Head
	for i, x in { -0.3, 0.3 } do
		local eye = bodyPart({
			name = if i == 1 then "LeftEye" else "RightEye",
			size = Vector3.new(0.22, 0.14, 0.05),
			color = EYE,
			material = Enum.Material.Neon,
		})
		eye.CastShadow = false
		eye.CFrame = head.CFrame * CFrame.new(x, 0.2, -0.66)
		eye.Parent = model
		local weld = Instance.new("Weld")
		weld.Part0 = head
		weld.Part1 = eye
		weld.C0 = CFrame.new(x, 0.2, -0.66)
		weld.Parent = eye
		eye:AddTag("MonsterEye")
	end
	local glow = Instance.new("PointLight")
	glow.Name = "EyeGlow"
	glow.Color = EYE
	glow.Range = 6
	glow.Brightness = 0.6
	glow.Parent = head

	local humanoid = Instance.new("Humanoid")
	humanoid.RigType = Enum.HumanoidRigType.R15
	humanoid.HipHeight = HIP_HEIGHT
	humanoid.MaxHealth = math.huge
	humanoid.Health = math.huge
	humanoid.BreakJointsOnDeath = false
	humanoid.RequiresNeck = false
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	humanoid.AutoJumpEnabled = false
	humanoid.UseJumpPower = true
	humanoid.JumpPower = 0
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
	local animator = Instance.new("Animator") -- lets clients play published animations on it
	animator.Parent = humanoid
	humanoid.Parent = model

	model.PrimaryPart = root
	model:AddTag("Monster")
	return model
end

-- Height of the root part's center above the floor (for spawning on a floor point).
MonsterRig.RootHeight = HIP_HEIGHT + 1

return MonsterRig
