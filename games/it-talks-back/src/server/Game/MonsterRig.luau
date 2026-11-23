--!strict
-- MonsterRig: builds "The Tenant" in code (no uploaded mesh needed). Original design: a tall,
-- emaciated, pale figure with a long skull, sunken glowing pinprick eyes, a hinged jaw full of
-- teeth, visible ribs, a spine ridge, arms that reach past its knees ending in long clawed
-- fingers, clawed toes, torn cloth at the waist, and four tendrils growing out of its back.
--
-- 64 Motor6Ds (joint name -> Part1):
--   core 8:     Root->Pelvis, Spine1->Abdomen, Spine2->Chest, Spine3->UpperChest,
--               Neck1->NeckLower, Neck2->NeckUpper, Skull->Head, Jaw->Jaw
--   face 4:     Tongue1->Tongue1, Tongue2->Tongue2, LeftLid, RightLid
--   arms 2x16:  <Side>Clavicle, <Side>Shoulder->UpperArm, <Side>Elbow->LowerArm,
--               <Side>Wrist->Hand, <Side>Finger<1-4><A|B|C> (3 joints x 4 long fingers)
--   legs 2x4:   <Side>Hip->UpperLeg, <Side>Knee->LowerLeg, <Side>Ankle->Foot, <Side>Toe->Toes
--   back 12:    Tendril<1-4><A|B|C>
-- Decorations (ribs, teeth, claws, sockets, cloth...) are welded, not jointed.
--
-- Rest pose is upright (the hunch lives in the animation, so the rig is easy to edit in the
-- Animation Editor). Axes: hanging limbs/fingers rx > 0 = forward/curl; knees rx < 0;
-- torso/neck rx < 0 = lean forward; Jaw rx < 0 = open; lids rx < 0 = close.
-- MonsterRig.SPEC is shared with the animation exporter (lune/build-animations.luau).

local MonsterRig = {}

local SKIN = Color3.fromRGB(150, 146, 134) -- sickly pale: it shows up horribly in a flashlight
local SKIN_DARK = Color3.fromRGB(96, 92, 84)
local CLOTH = Color3.fromRGB(30, 25, 22)
local BONE = Color3.fromRGB(205, 198, 176)
local CLAW = Color3.fromRGB(24, 20, 18)
local MOUTH = Color3.fromRGB(60, 14, 16)
local SOCKET = Color3.fromRGB(8, 6, 7)
local EYE = Color3.fromRGB(255, 236, 214)

local HIP_HEIGHT = 3

export type PartSpec = { name: string, size: Vector3, color: Color3, material: Enum.Material }
export type JointSpec = { name: string, part0: string, part1: string, c0: CFrame, c1: CFrame }
export type DecorSpec = {
	name: string,
	attach: string,
	offset: CFrame,
	size: Vector3,
	color: Color3,
	material: Enum.Material,
	tag: string?,
}

local PARTS: { PartSpec } = {}
local JOINTS: { JointSpec } = {}
local DECOR: { DecorSpec } = {}

local SMOOTH = Enum.Material.SmoothPlastic
local FABRIC = Enum.Material.Fabric
local NEON = Enum.Material.Neon

local function part(name: string, size: Vector3, color: Color3, material: Enum.Material?)
	table.insert(PARTS, { name = name, size = size, color = color, material = material or SMOOTH })
end

local function joint(name: string, part0: string, part1: string, c0: CFrame, c1: CFrame)
	table.insert(JOINTS, { name = name, part0 = part0, part1 = part1, c0 = c0, c1 = c1 })
end

local function decor(
	name: string,
	attach: string,
	offset: CFrame,
	size: Vector3,
	color: Color3,
	material: Enum.Material?,
	tag: string?
)
	table.insert(DECOR, {
		name = name,
		attach = attach,
		offset = offset,
		size = size,
		color = color,
		material = material or SMOOTH,
		tag = tag,
	})
end

-- ===== Core: pelvis, spine, neck, skull ===========================================================
part("Pelvis", Vector3.new(1.3, 0.8, 0.75), SKIN_DARK)
part("Abdomen", Vector3.new(0.95, 0.8, 0.6), SKIN)
part("Chest", Vector3.new(1.75, 1.1, 0.9), SKIN)
part("UpperChest", Vector3.new(1.95, 0.6, 0.85), SKIN)
part("NeckLower", Vector3.new(0.42, 0.45, 0.42), SKIN)
part("NeckUpper", Vector3.new(0.38, 0.4, 0.38), SKIN)
part("Head", Vector3.new(1, 1.45, 1.2), SKIN)
part("Jaw", Vector3.new(0.9, 0.28, 1.15), SKIN_DARK)
part("Tongue1", Vector3.new(0.28, 0.08, 0.45), MOUTH)
part("Tongue2", Vector3.new(0.22, 0.07, 0.42), MOUTH)
part("LeftLid", Vector3.new(0.36, 0.06, 0.26), SKIN_DARK)
part("RightLid", Vector3.new(0.36, 0.06, 0.26), SKIN_DARK)

joint("Root", "HumanoidRootPart", "Pelvis", CFrame.new(0, -0.55, 0), CFrame.new())
joint("Spine1", "Pelvis", "Abdomen", CFrame.new(0, 0.35, 0), CFrame.new(0, -0.4, 0))
joint("Spine2", "Abdomen", "Chest", CFrame.new(0, 0.4, 0), CFrame.new(0, -0.55, 0))
joint("Spine3", "Chest", "UpperChest", CFrame.new(0, 0.55, 0), CFrame.new(0, -0.3, 0))
joint("Neck1", "UpperChest", "NeckLower", CFrame.new(0, 0.3, -0.1), CFrame.new(0, -0.22, 0))
joint("Neck2", "NeckLower", "NeckUpper", CFrame.new(0, 0.22, 0), CFrame.new(0, -0.2, 0))
joint("Skull", "NeckUpper", "Head", CFrame.new(0, 0.2, 0), CFrame.new(0, -0.55, 0.12))
-- Jaw hinges at the back of the skull and hangs forward; the tongue rides inside it.
joint("Jaw", "Head", "Jaw", CFrame.new(0, -0.62, 0.35), CFrame.new(0, 0.1, 0.55))
joint("Tongue1", "Jaw", "Tongue1", CFrame.new(0, 0.18, 0.3), CFrame.new(0, 0, 0.22))
joint("Tongue2", "Tongue1", "Tongue2", CFrame.new(0, 0, -0.22), CFrame.new(0, 0, 0.21))
-- Lids hinge at the top of each socket and swing down over the eye.
for i, side in { "Left", "Right" } do
	local x = if i == 1 then -0.24 else 0.24
	joint(side .. "Lid", "Head", side .. "Lid", CFrame.new(x, 0.2, -0.5), CFrame.new(0, 0, 0.13))
end

-- Face: deep sockets, pinprick pupils (tagged MonsterEye), brow, teeth.
for i, side in { "Left", "Right" } do
	local x = if i == 1 then -0.24 else 0.24
	decor(side .. "Socket", "Head", CFrame.new(x, 0.08, -0.56), Vector3.new(0.34, 0.26, 0.1), SOCKET)
	decor(side .. "Eye", "Head", CFrame.new(x, 0.08, -0.62), Vector3.new(0.09, 0.09, 0.04), EYE, NEON, "MonsterEye")
end
decor("Cranium", "Head", CFrame.new(0, 0.38, 0.32) * CFrame.Angles(-0.35, 0, 0), Vector3.new(0.85, 0.9, 1.05), SKIN)
decor(
	"CraniumBack",
	"Head",
	CFrame.new(0, 0.55, 0.75) * CFrame.Angles(-0.6, 0, 0),
	Vector3.new(0.6, 0.6, 0.6),
	SKIN_DARK
)
decor("NoseCavity", "Head", CFrame.new(0, -0.2, -0.61), Vector3.new(0.16, 0.22, 0.04), SOCKET)
for i, side in { "Left", "Right" } do
	local x = if i == 1 then -0.42 else 0.42
	decor(side .. "CheekHollow", "Head", CFrame.new(x, -0.3, -0.35), Vector3.new(0.18, 0.4, 0.5), SKIN_DARK)
end
decor("Brow", "Head", CFrame.new(0, 0.26, -0.58) * CFrame.Angles(0.3, 0, 0), Vector3.new(0.92, 0.12, 0.16), SKIN_DARK)
decor("Cheekbones", "Head", CFrame.new(0, -0.1, -0.55), Vector3.new(0.98, 0.1, 0.12), SKIN_DARK)
decor("Mouth", "Head", CFrame.new(0, -0.52, -0.18), Vector3.new(0.8, 0.2, 0.9), MOUTH)
decor("MouthLower", "Jaw", CFrame.new(0, 0.12, -0.05), Vector3.new(0.75, 0.05, 1), MOUTH)
for k = 0, 6 do
	local x = -0.33 + k * 0.11
	local len = if k == 0 or k == 6 then 0.22 else 0.14
	decor(`ToothUpper{k}`, "Head", CFrame.new(x, -0.66, -0.56), Vector3.new(0.06, len, 0.06), BONE)
	decor(`ToothLower{k}`, "Jaw", CFrame.new(x, 0.2, -0.52), Vector3.new(0.06, len * 0.9, 0.06), BONE)
end

-- Body: ribs, spine ridge, sunken belly, torn cloth.
for k = 0, 3 do
	local y = 0.35 - k * 0.24
	local w = 1.6 - k * 0.12
	decor(`Rib{k}`, "Chest", CFrame.new(0, y, -0.47), Vector3.new(w, 0.07, 0.05), SKIN_DARK)
end
decor("Sternum", "Chest", CFrame.new(0, 0.1, -0.48), Vector3.new(0.12, 0.9, 0.05), SKIN_DARK)
for k = 0, 2 do
	decor(`Vertebra{k}`, "Chest", CFrame.new(0, 0.35 - k * 0.35, 0.47), Vector3.new(0.14, 0.18, 0.12), BONE)
end
decor("VertebraLow", "Abdomen", CFrame.new(0, 0, 0.32), Vector3.new(0.14, 0.2, 0.1), BONE)
for k = 0, 5 do
	local x = -0.55 + k * 0.22
	local len = 0.7 + ((k * 37) % 5) * 0.12
	decor(
		`Rag{k}`,
		"Pelvis",
		CFrame.new(x, -0.3 - len / 2, -0.4 + (k % 2) * 0.8) * CFrame.Angles((k % 3 - 1) * 0.08, 0, (k % 2 - 0.5) * 0.12),
		Vector3.new(0.2, len, 0.05),
		CLOTH,
		FABRIC
	)
end

-- ===== Arms: clavicle, upper arm, forearm, hand, four long 3-joint fingers ==========================
for i, side in { "Left", "Right" } do
	local s = if i == 1 then -1 else 1
	part(side .. "Clavicle", Vector3.new(0.7, 0.18, 0.22), SKIN)
	part(side .. "UpperArm", Vector3.new(0.32, 2, 0.32), SKIN)
	part(side .. "LowerArm", Vector3.new(0.27, 2, 0.27), SKIN)
	part(side .. "Hand", Vector3.new(0.48, 0.5, 0.16), SKIN_DARK)
	joint(
		side .. "Clavicle",
		"UpperChest",
		side .. "Clavicle",
		CFrame.new(0.2 * s, 0.15, -0.05),
		CFrame.new(-0.35 * s, 0, 0)
	)
	joint(
		side .. "Shoulder",
		side .. "Clavicle",
		side .. "UpperArm",
		CFrame.new(0.35 * s, 0, 0),
		CFrame.new(0, 0.95, 0)
	)
	joint(side .. "Elbow", side .. "UpperArm", side .. "LowerArm", CFrame.new(0, -0.97, 0), CFrame.new(0, 1, 0))
	joint(side .. "Wrist", side .. "LowerArm", side .. "Hand", CFrame.new(0, -1, 0), CFrame.new(0, 0.23, 0))
	decor(side .. "ElbowKnob", side .. "LowerArm", CFrame.new(0, 0.97, 0.1), Vector3.new(0.3, 0.22, 0.22), SKIN_DARK)
	for f = 1, 4 do
		local fx = (-0.18 + (f - 1) * 0.12) * s
		local base = `{side}Finger{f}`
		local lengths = { 0.45, 0.4, 0.34 }
		if f == 1 or f == 4 then
			lengths = { 0.38, 0.34, 0.3 } -- outer fingers a little shorter
		end
		part(base .. "_1", Vector3.new(0.08, lengths[1], 0.08), SKIN)
		part(base .. "_2", Vector3.new(0.07, lengths[2], 0.07), SKIN)
		part(base .. "_3", Vector3.new(0.06, lengths[3], 0.06), SKIN_DARK)
		joint(base .. "A", side .. "Hand", base .. "_1", CFrame.new(fx, -0.25, 0), CFrame.new(0, lengths[1] / 2, 0))
		joint(
			base .. "B",
			base .. "_1",
			base .. "_2",
			CFrame.new(0, -lengths[1] / 2, 0),
			CFrame.new(0, lengths[2] / 2, 0)
		)
		joint(
			base .. "C",
			base .. "_2",
			base .. "_3",
			CFrame.new(0, -lengths[2] / 2, 0),
			CFrame.new(0, lengths[3] / 2, 0)
		)
		decor(
			base .. "Claw",
			base .. "_3",
			CFrame.new(0, -lengths[3] / 2 - 0.1, -0.02) * CFrame.Angles(0.25, 0, 0),
			Vector3.new(0.05, 0.24, 0.05),
			CLAW
		)
	end
end

-- ===== Legs: thigh, shin, foot, toes ================================================================
for i, side in { "Left", "Right" } do
	local s = if i == 1 then -1 else 1
	part(side .. "UpperLeg", Vector3.new(0.45, 1.5, 0.45), SKIN)
	part(side .. "LowerLeg", Vector3.new(0.35, 1.4, 0.35), SKIN)
	part(side .. "Foot", Vector3.new(0.42, 0.18, 0.65), SKIN_DARK)
	part(side .. "Toes", Vector3.new(0.42, 0.12, 0.45), SKIN_DARK)
	joint(side .. "Hip", "Pelvis", side .. "UpperLeg", CFrame.new(0.38 * s, -0.35, 0), CFrame.new(0, 0.75, 0))
	joint(side .. "Knee", side .. "UpperLeg", side .. "LowerLeg", CFrame.new(0, -0.75, 0), CFrame.new(0, 0.7, 0))
	joint(side .. "Ankle", side .. "LowerLeg", side .. "Foot", CFrame.new(0, -0.7, 0), CFrame.new(0, 0.09, 0.1))
	joint(side .. "Toe", side .. "Foot", side .. "Toes", CFrame.new(0, -0.03, -0.32), CFrame.new(0, 0, 0.22))
	decor(side .. "KneeKnob", side .. "LowerLeg", CFrame.new(0, 0.66, -0.12), Vector3.new(0.32, 0.22, 0.18), SKIN_DARK)
	for k = 0, 2 do
		decor(
			`{side}ToeClaw{k}`,
			side .. "Toes",
			CFrame.new((k - 1) * 0.13, -0.02, -0.3) * CFrame.Angles(-0.4, 0, 0),
			Vector3.new(0.06, 0.06, 0.2),
			CLAW
		)
	end
end

-- ===== Back tendrils (4 x 3 segments) ================================================================
local TENDRILS = {
	{ attach = "UpperChest", pos = Vector3.new(-0.45, 0.15, 0.4), tilt = Vector3.new(0.9, 0, -0.35) },
	{ attach = "UpperChest", pos = Vector3.new(0.45, 0.15, 0.4), tilt = Vector3.new(0.9, 0, 0.35) },
	{ attach = "Chest", pos = Vector3.new(-0.3, 0.1, 0.45), tilt = Vector3.new(1.2, 0, -0.6) },
	{ attach = "Chest", pos = Vector3.new(0.3, 0.1, 0.45), tilt = Vector3.new(1.2, 0, 0.6) },
}
for t, def in TENDRILS do
	local lengths = { 1, 0.9, 0.8 }
	local widths = { 0.17, 0.13, 0.09 }
	local prev = def.attach
	for k = 1, 3 do
		local name = `Tendril{t}_{k}`
		local jointName = `Tendril{t}{string.char(64 + k)}`
		part(name, Vector3.new(widths[k], lengths[k], widths[k]), SKIN_DARK)
		local c0 = if k == 1
			then CFrame.new(def.pos) * CFrame.Angles(def.tilt.X, def.tilt.Y, def.tilt.Z)
			else CFrame.new(0, lengths[k - 1] / 2, 0)
		joint(jointName, prev, name, c0, CFrame.new(0, -lengths[k] / 2, 0)) -- grows upward/back
		prev = name
	end
	decor(`Tendril{t}Tip`, `Tendril{t}_3`, CFrame.new(0, 0.48, 0), Vector3.new(0.05, 0.2, 0.05), CLAW)
end

assert(#JOINTS == 64, `[MonsterRig] expected 64 joints, got {#JOINTS}`)

MonsterRig.SPEC = table.freeze({ parts = PARTS, joints = JOINTS, decor = DECOR, hipHeight = HIP_HEIGHT })

-- ===== Build =========================================================================================

local function newPart(name: string, size: Vector3, color: Color3, material: Enum.Material): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Color = color
	p.Material = material
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
		local p = newPart(spec.name, spec.size, spec.color, spec.material)
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

	-- Lay out the rest pose so the model looks right before the first animation frame.
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

	for _, d in DECOR do
		local host = parts[d.attach]
		local p = newPart(d.name, d.size, d.color, d.material)
		p.CastShadow = d.material ~= NEON
		p.CFrame = host.CFrame * d.offset
		local weld = Instance.new("Weld")
		weld.Part0 = host
		weld.Part1 = p
		weld.C0 = d.offset
		weld.Parent = p
		if d.tag then
			p:AddTag(d.tag)
		end
		p.Parent = model
	end

	local glow = Instance.new("PointLight")
	glow.Name = "EyeGlow"
	glow.Color = EYE
	glow.Range = 5
	glow.Brightness = 0.5
	glow.Parent = parts.Head

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
