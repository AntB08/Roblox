--!strict
-- MonsterRig: builds the monster model in code (no uploaded mesh needed for the prototype).
-- A tall, thin, hunched figure: ~7.5 studs, long arms, two pale eyes. Original design.
-- Joints are Motor6Ds so the client can animate it procedurally (MonsterFxController writes
-- Motor6D.Transform from the root's velocity; nothing here plays an animation asset).
--
-- Humanoid uses RigType R15 so HipHeight is honored for a custom body.

local MonsterRig = {}

local SKIN = Color3.fromRGB(22, 20, 24)
local CLOTH = Color3.fromRGB(38, 30, 30)
local EYE = Color3.fromRGB(235, 230, 210)

local HIP_HEIGHT = 3

local function bodyPart(name: string, size: Vector3, color: Color3, material: Enum.Material?): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Massless = true
	p.CastShadow = true
	return p
end

local function motor(name: string, part0: BasePart, part1: BasePart, c0: CFrame, c1: CFrame): Motor6D
	local m = Instance.new("Motor6D")
	m.Name = name
	m.Part0 = part0
	m.Part1 = part1
	m.C0 = c0
	m.C1 = c1
	m.Parent = part0
	return m
end

function MonsterRig.build(name: string): Model
	local model = Instance.new("Model")
	model.Name = name
	model.ModelStreamingMode = Enum.ModelStreamingMode.Persistent

	-- Root: the only colliding part. Bottom of root is HIP_HEIGHT above the floor.
	local root = bodyPart("HumanoidRootPart", Vector3.new(2, 2, 1), SKIN)
	root.Transparency = 1
	root.CanCollide = true
	root.Massless = false
	root.CastShadow = false
	root.Parent = model

	local torso = bodyPart("Torso", Vector3.new(2, 3, 1), CLOTH, Enum.Material.Fabric)
	torso.Parent = model
	local head = bodyPart("Head", Vector3.new(1.3, 1.6, 1.3), SKIN)
	head.Parent = model
	local leftArm = bodyPart("LeftArm", Vector3.new(0.5, 4.4, 0.5), SKIN)
	leftArm.Parent = model
	local rightArm = bodyPart("RightArm", Vector3.new(0.5, 4.4, 0.5), SKIN)
	rightArm.Parent = model
	local leftLeg = bodyPart("LeftLeg", Vector3.new(0.7, 3, 0.7), CLOTH, Enum.Material.Fabric)
	leftLeg.Parent = model
	local rightLeg = bodyPart("RightLeg", Vector3.new(0.7, 3, 0.7), CLOTH, Enum.Material.Fabric)
	rightLeg.Parent = model

	-- Torso sits on the root, leaning forward (hunched).
	motor("Root", root, torso, CFrame.new(0, 0.5, 0) * CFrame.Angles(math.rad(-12), 0, 0), CFrame.new())
	motor("Neck", torso, head, CFrame.new(0, 1.5, -0.25) * CFrame.Angles(math.rad(18), 0, 0), CFrame.new(0, -0.8, 0))
	motor("LeftShoulder", torso, leftArm, CFrame.new(-1.25, 1.3, 0), CFrame.new(0, 2, 0))
	motor("RightShoulder", torso, rightArm, CFrame.new(1.25, 1.3, 0), CFrame.new(0, 2, 0))
	-- Hips are attached to the ROOT so leaning the torso doesn't tilt the legs.
	motor("LeftHip", root, leftLeg, CFrame.new(-0.5, -1, 0), CFrame.new(0, 1.5, 0))
	motor("RightHip", root, rightLeg, CFrame.new(0.5, -1, 0), CFrame.new(0, 1.5, 0))

	-- Eyes: neon dots with a faint light. Clients recolor them by mood.
	for i, x in { -0.3, 0.3 } do
		local eye =
			bodyPart(if i == 1 then "LeftEye" else "RightEye", Vector3.new(0.22, 0.14, 0.05), EYE, Enum.Material.Neon)
		eye.CastShadow = false
		eye.Parent = model
		local weld = Instance.new("Weld")
		weld.Part0 = head
		weld.Part1 = eye
		weld.C0 = CFrame.new(x, 0.15, -0.66)
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
	humanoid.Parent = model

	model.PrimaryPart = root
	model:AddTag("Monster")
	return model
end

-- Height of the root part's center above the floor (for spawning on a floor point).
MonsterRig.RootHeight = HIP_HEIGHT + 1

return MonsterRig
