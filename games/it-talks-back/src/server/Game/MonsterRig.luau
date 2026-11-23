--!strict
-- MonsterRig: builds "The Tenant" in code from ROUNDED shapes (SpecialMesh ellipsoids and
-- wedges on plain parts), so no mesh upload is needed. Original design, built around a
-- silhouette that reads instantly in the dark:
--   * a long S-curved "vulture" neck that carries the head low and forward, below the shoulders
--   * a narrow egg-shaped skull with no nose, deep sockets with pinprick eyes, a hanging jaw of
--     needle teeth and a tongue
--   * a wasp-thin waist under a big bony ribcage, high hunched shoulders, sharp shoulder blades,
--     a ridge of spikes down the spine, four tendrils growing out of the back
--   * MISMATCHED arms (the right one is ~25% longer) ending in long, tapered, clawed fingers
--   * bony knobs at elbows and knees, clawed toes, rags at the waist
--
-- 103 Motor6Ds (joint name -> Part1):
--   core 11:    Root->Pelvis, Spine1->Abdomen, Spine2->Waist, Spine3->Chest, Spine4->UpperChest,
--               Neck1..4->Neck<n>Seg, Skull->Head, Jaw->Jaw
--   face 4:     Tongue1->Tongue1, Tongue2->Tongue2, LeftLid, RightLid
--   arms 2x18:  <Side>Clavicle, <Side>Shoulder->UpperArm, <Side>Elbow->LowerArm,
--               <Side>Wrist->Hand, <Side>Thumb<A|B>, <Side>Finger<1-4><A|B|C>
--   legs 2x4:   <Side>Hip->UpperLeg, <Side>Knee->LowerLeg, <Side>Ankle->Foot, <Side>Toe->Toes
--   back 20:    Tendril<1-4><A..E>
--   cloth 12:   Rag<0-5><A|B>
--   mouth 12:   Feeler<0-5><A|B>
-- Decorations (ribs, teeth, claws, sockets, spikes...) are welded, not jointed.
--
-- Rest pose is upright (the hunch and neck curve live in the animation, so the rig is easy to
-- edit in the Animation Editor). Axes: hanging limbs / fingers rx > 0 = forward / curl;
-- knees rx < 0; torso / neck rx < 0 = lean forward; Jaw rx < 0 = open; lids rx < 0 = close.
-- MonsterRig.SPEC is shared with the animation exporter (lune/build-animations.luau).

local MonsterRig = {}

local SKIN = Color3.fromRGB(128, 92, 70) -- raw, flayed-looking flesh
local SKIN_DARK = Color3.fromRGB(92, 60, 46)
local DEAD = Color3.fromRGB(70, 44, 36) -- darker hands, feet and blade-finger tips
local CLOTH = Color3.fromRGB(30, 25, 22)
local BONE = Color3.fromRGB(176, 150, 120) -- the exposed skull
local CLAW = Color3.fromRGB(22, 18, 16)
local MOUTH = Color3.fromRGB(64, 12, 14)
local SOCKET = Color3.fromRGB(6, 5, 6)
local EYE = Color3.fromRGB(255, 236, 214)

local HIP_HEIGHT = 3
-- If the imported meshes face backwards (some importer setups turn models 180 degrees), set this
-- to CFrame.Angles(0, math.pi, 0).
local MESH_ROTATION = CFrame.identity
local applyMeshes: (parts: { [string]: BasePart }) -> boolean

export type Shape = "Ellipsoid" | "Wedge" | "Block"
export type PartSpec = { name: string, size: Vector3, color: Color3, material: Enum.Material, shape: Shape }
export type JointSpec = { name: string, part0: string, part1: string, c0: CFrame, c1: CFrame }
export type DecorSpec = {
	name: string,
	attach: string,
	offset: CFrame,
	size: Vector3,
	color: Color3,
	material: Enum.Material,
	shape: Shape,
	tag: string?,
}

local PARTS: { PartSpec } = {}
local JOINTS: { JointSpec } = {}
local DECOR: { DecorSpec } = {}

local SMOOTH = Enum.Material.SmoothPlastic
local FABRIC = Enum.Material.Fabric
local NEON = Enum.Material.Neon

-- Body parts are ellipsoids unless stated otherwise.
local function part(name: string, size: Vector3, color: Color3, shape: Shape?)
	table.insert(PARTS, { name = name, size = size, color = color, material = SMOOTH, shape = shape or "Ellipsoid" })
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
	shape: Shape?,
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
		shape = shape or "Ellipsoid",
		tag = tag,
	})
end

-- ===== Core: pelvis, wasp waist, ribcage, shoulder yoke, vulture neck, skull =======================
part("Pelvis", Vector3.new(1.1, 0.7, 0.7), SKIN_DARK)
part("Abdomen", Vector3.new(0.62, 0.6, 0.46), SKIN) -- wasp-thin waist, two segments
part("Waist", Vector3.new(0.56, 0.6, 0.42), SKIN)
part("Chest", Vector3.new(1.8, 1.55, 1.15), SKIN) -- big ribcage
part("UpperChest", Vector3.new(2.3, 0.85, 1.05), SKIN) -- high hunched shoulder hump
for k, w in { 0.37, 0.34, 0.31, 0.29 } do
	part(`Neck{k}Seg`, Vector3.new(w, 0.48, w), SKIN) -- four short segments: a smooth S-curve
end
part("Head", Vector3.new(0.82, 1, 1.3), SKIN) -- narrow skull, long front-to-back
part("Jaw", Vector3.new(0.6, 0.26, 0.95), SKIN_DARK)
part("Tongue1", Vector3.new(0.24, 0.09, 0.5), MOUTH)
part("Tongue2", Vector3.new(0.18, 0.08, 0.48), MOUTH)
part("LeftLid", Vector3.new(0.27, 0.06, 0.2), SKIN_DARK)
part("RightLid", Vector3.new(0.27, 0.06, 0.2), SKIN_DARK)

joint("Root", "HumanoidRootPart", "Pelvis", CFrame.new(0, -0.55, 0), CFrame.new())
joint("Spine1", "Pelvis", "Abdomen", CFrame.new(0, 0.28, 0), CFrame.new(0, -0.24, 0))
joint("Spine2", "Abdomen", "Waist", CFrame.new(0, 0.24, 0), CFrame.new(0, -0.24, 0))
joint("Spine3", "Waist", "Chest", CFrame.new(0, 0.24, 0), CFrame.new(0, -0.68, 0))
joint("Spine4", "Chest", "UpperChest", CFrame.new(0, 0.55, 0.05), CFrame.new(0, -0.15, 0))
joint("Neck1", "UpperChest", "Neck1Seg", CFrame.new(0, 0.2, -0.2), CFrame.new(0, -0.18, 0))
for k = 2, 4 do
	joint(`Neck{k}`, `Neck{k - 1}Seg`, `Neck{k}Seg`, CFrame.new(0, 0.18, 0), CFrame.new(0, -0.18, 0))
end
-- The neck plugs into the BACK of the skull, so the face hangs forward of it.
joint("Skull", "Neck4Seg", "Head", CFrame.new(0, 0.18, 0), CFrame.new(0, -0.25, 0.31))
joint("Jaw", "Head", "Jaw", CFrame.new(0, -0.33, 0.3), CFrame.new(0, 0.07, 0.46))
joint("Tongue1", "Jaw", "Tongue1", CFrame.new(0, 0.08, 0.22), CFrame.new(0, 0, 0.24))
joint("Tongue2", "Tongue1", "Tongue2", CFrame.new(0, 0, -0.24), CFrame.new(0, 0, 0.23))
for i, side in { "Left", "Right" } do
	local x = if i == 1 then -0.18 else 0.18
	joint(side .. "Lid", "Head", side .. "Lid", CFrame.new(x, 0.17, -0.5), CFrame.new(0, 0, 0.1))
end

-- Face: no nose, deep sockets with pinprick pupils (tagged MonsterEye), brow, needle teeth.
for i, side in { "Left", "Right" } do
	local x = if i == 1 then -0.18 else 0.18
	-- Narrow sockets slanting down toward the middle: an angry, hateful stare.
	local slant = if x > 0 then 0.35 else -0.35
	decor(
		side .. "Socket",
		"Head",
		CFrame.new(x, 0.08, -0.52) * CFrame.Angles(0, 0, slant),
		Vector3.new(0.3, 0.14, 0.16),
		SOCKET
	)
	decor(
		side .. "Eye",
		"Head",
		CFrame.new(x, 0.08, -0.6),
		Vector3.new(0.06, 0.06, 0.04),
		EYE,
		"Ellipsoid",
		NEON,
		"MonsterEye"
	)
	decor(side .. "CheekHollow", "Head", CFrame.new(x * 1.9, -0.18, -0.22), Vector3.new(0.1, 0.3, 0.45), SKIN_DARK)
end
decor("Cranium", "Head", CFrame.new(0, 0.23, 0.28) * CFrame.Angles(-0.3, 0, 0), Vector3.new(0.74, 0.7, 0.85), SKIN)
decor("Brow", "Head", CFrame.new(0, 0.2, -0.47) * CFrame.Angles(0.25, 0, 0), Vector3.new(0.68, 0.11, 0.2), SKIN_DARK)
decor("UpperMouth", "Head", CFrame.new(0, -0.33, -0.22), Vector3.new(0.54, 0.13, 0.7), MOUTH)
decor("LowerMouth", "Jaw", CFrame.new(0, 0.1, -0.06), Vector3.new(0.5, 0.06, 0.78), MOUTH)
for k = 0, 8 do
	local x = -0.22 + k * 0.055
	local z = -0.55 + math.abs(k - 4) * 0.035 -- teeth follow the curve of the snout
	local fang = k == 1 or k == 7
	local len = if fang then 0.26 else 0.15
	decor(`ToothUpper{k}`, "Head", CFrame.new(x, -0.38 - len / 2, z), Vector3.new(0.04, len, 0.04), BONE)
	decor(`ToothLower{k}`, "Jaw", CFrame.new(x, 0.12 + len * 0.4, z + 0.03), Vector3.new(0.035, len * 0.8, 0.035), BONE)
end

-- Mouth feelers: six fleshy, jointed feelers hang around the mouth and wriggle (2 joints each).
for k = 0, 5 do
	local x = -0.23 + k * 0.092
	local outer = math.abs(k - 2.5) / 2.5 -- 0 in the middle, 1 at the sides
	local len1 = 0.42 - outer * 0.1
	local len2 = 0.38 - outer * 0.08
	part(`Feeler{k}_1`, Vector3.new(0.085, len1 + 0.05, 0.085), MOUTH)
	part(`Feeler{k}_2`, Vector3.new(0.06, len2 + 0.04, 0.06), CLAW)
	joint(
		`Feeler{k}A`,
		"Head",
		`Feeler{k}_1`,
		CFrame.new(x, -0.42, -0.6 + outer * 0.14) * CFrame.Angles(0.15, 0, (k - 2.5) * 0.06),
		CFrame.new(0, len1 / 2, 0)
	)
	joint(`Feeler{k}B`, `Feeler{k}_1`, `Feeler{k}_2`, CFrame.new(0, -len1 / 2, 0), CFrame.new(0, len2 / 2, 0))
end

-- Body: rib rings, sternum, spine spikes, shoulder blades, hip bones, rags.
for k = 0, 4 do
	decor(
		`Rib{k}`,
		"Chest",
		CFrame.new(0, 0.42 - k * 0.24, -0.02),
		Vector3.new(1.86 - k * 0.12, 0.08, 1.2 - k * 0.07),
		SKIN_DARK
	)
end
decor("Sternum", "Chest", CFrame.new(0, 0.05, -0.56), Vector3.new(0.14, 1.05, 0.08), SKIN_DARK)
decor("Navel", "Abdomen", CFrame.new(0, 0, -0.2), Vector3.new(0.28, 0.38, 0.1), SKIN_DARK)
for k = 0, 5 do
	local host = if k < 2 then "UpperChest" elseif k < 5 then "Chest" else "Abdomen"
	local y = if k < 2 then 0.1 - k * 0.25 elseif k < 5 then 0.45 - (k - 2) * 0.42 else 0.1
	local z = if host == "Abdomen" then 0.22 else 0.5
	decor(
		`Spike{k}`,
		host,
		CFrame.new(0, y, z) * CFrame.Angles(0, math.pi, 0),
		Vector3.new(0.1, 0.32, 0.3),
		BONE,
		"Wedge"
	)
end
for i, side in { "Left", "Right" } do
	local s = if i == 1 then -1 else 1
	decor(
		side .. "Blade",
		"UpperChest",
		CFrame.new(0.5 * s, -0.25, 0.42) * CFrame.Angles(0.25, 0, 0.3 * s),
		Vector3.new(0.55, 0.8, 0.12),
		SKIN_DARK
	)
	decor(side .. "HipBone", "Pelvis", CFrame.new(0.45 * s, 0.15, -0.15), Vector3.new(0.3, 0.3, 0.35), SKIN_DARK)
end
-- Rags: six cloth strips, two jointed segments each, so they sway and trail behind it.
for k = 0, 5 do
	local x = -0.5 + k * 0.2
	local len = 0.7 + ((k * 37) % 5) * 0.13
	local half = len / 2
	local z = -0.36 + (k % 2) * 0.72
	table.insert(PARTS, {
		name = `Rag{k}_1`,
		size = Vector3.new(0.19, half + 0.04, 0.04),
		color = CLOTH,
		material = FABRIC,
		shape = "Block",
	})
	table.insert(
		PARTS,
		{ name = `Rag{k}_2`, size = Vector3.new(0.17, half, 0.035), color = CLOTH, material = FABRIC, shape = "Block" }
	)
	joint(
		`Rag{k}A`,
		"Pelvis",
		`Rag{k}_1`,
		CFrame.new(x, -0.25, z) * CFrame.Angles(0, 0, (k % 2 - 0.5) * 0.14),
		CFrame.new(0, half / 2, 0)
	)
	joint(`Rag{k}B`, `Rag{k}_1`, `Rag{k}_2`, CFrame.new(0, -half / 2, 0), CFrame.new(0, half / 2, 0))
end

-- ===== Arms: mismatched lengths, bony elbows, long tapered clawed fingers ===========================
local ARM = {
	Left = { upper = 1.75, lower = 1.75, finger = 1 },
	Right = { upper = 2.2, lower = 2.2, finger = 1.2 }, -- the long arm
}
for i, side in { "Left", "Right" } do
	local s = if i == 1 then -1 else 1
	local a = ARM[side]
	part(side .. "Clavicle", Vector3.new(0.8, 0.22, 0.26), SKIN)
	part(side .. "UpperArm", Vector3.new(0.3, a.upper + 0.2, 0.3), SKIN)
	part(side .. "LowerArm", Vector3.new(0.24, a.lower + 0.15, 0.24), SKIN)
	part(side .. "Hand", Vector3.new(0.44, 0.58, 0.16), DEAD)
	joint(
		side .. "Clavicle",
		"UpperChest",
		side .. "Clavicle",
		CFrame.new(0.2 * s, 0.12, -0.05),
		CFrame.new(-0.38 * s, 0, 0)
	)
	joint(
		side .. "Shoulder",
		side .. "Clavicle",
		side .. "UpperArm",
		CFrame.new(0.38 * s, 0, 0),
		CFrame.new(0, a.upper / 2, 0)
	)
	joint(
		side .. "Elbow",
		side .. "UpperArm",
		side .. "LowerArm",
		CFrame.new(0, -a.upper / 2, 0),
		CFrame.new(0, a.lower / 2, 0)
	)
	joint(side .. "Wrist", side .. "LowerArm", side .. "Hand", CFrame.new(0, -a.lower / 2, 0), CFrame.new(0, 0.24, 0))
	decor(
		side .. "ShoulderKnob",
		side .. "UpperArm",
		CFrame.new(0, a.upper / 2, 0),
		Vector3.new(0.4, 0.4, 0.4),
		SKIN_DARK
	)
	decor(
		side .. "ElbowKnob",
		side .. "LowerArm",
		CFrame.new(0, a.lower / 2, 0.06),
		Vector3.new(0.34, 0.34, 0.34),
		SKIN_DARK
	)
	decor(side .. "WristKnob", side .. "Hand", CFrame.new(0, 0.24, 0), Vector3.new(0.26, 0.2, 0.22), DEAD)
	-- Thumb: two joints on the inner side of the palm, angled across it.
	local thumb = `{side}Thumb`
	part(thumb .. "_1", Vector3.new(0.09, 0.36 * a.finger, 0.09), DEAD)
	part(thumb .. "_2", Vector3.new(0.07, 0.3 * a.finger, 0.07), CLAW)
	joint(
		thumb .. "A",
		side .. "Hand",
		thumb .. "_1",
		CFrame.new(-0.13 * s, -0.02, -0.1) * CFrame.Angles(0.55, 0, -0.25 * s), -- front of the palm
		CFrame.new(0, 0.16 * a.finger, 0)
	)
	joint(
		thumb .. "B",
		thumb .. "_1",
		thumb .. "_2",
		CFrame.new(0, -0.16 * a.finger, 0),
		CFrame.new(0, 0.13 * a.finger, 0)
	)
	for f = 1, 4 do
		local fx = (-0.15 + (f - 1) * 0.1) * s
		local base = `{side}Finger{f}`
		local scale = a.finger * (if f == 1 or f == 4 then 0.85 else 1)
		local lengths = { 0.46 * scale, 0.4 * scale, 0.34 * scale }
		part(base .. "_1", Vector3.new(0.09, lengths[1] + 0.06, 0.09), DEAD)
		part(base .. "_2", Vector3.new(0.075, lengths[2] + 0.05, 0.075), DEAD)
		part(base .. "_3", Vector3.new(0.06, lengths[3] + 0.04, 0.06), CLAW)
		joint(base .. "A", side .. "Hand", base .. "_1", CFrame.new(fx, -0.27, 0), CFrame.new(0, lengths[1] / 2, 0))
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
			CFrame.new(0, -lengths[3] / 2 - 0.1, -0.02) * CFrame.Angles(0.3, 0, 0),
			Vector3.new(0.05, 0.28, 0.05),
			CLAW
		)
	end
end

-- ===== Legs: thin thighs, bony knees, long feet, clawed toes ========================================
for i, side in { "Left", "Right" } do
	local s = if i == 1 then -1 else 1
	part(side .. "UpperLeg", Vector3.new(0.42, 1.65, 0.42), SKIN)
	part(side .. "LowerLeg", Vector3.new(0.3, 1.55, 0.3), SKIN)
	part(side .. "Foot", Vector3.new(0.36, 0.2, 0.7), DEAD)
	part(side .. "Toes", Vector3.new(0.4, 0.13, 0.48), DEAD)
	joint(side .. "Hip", "Pelvis", side .. "UpperLeg", CFrame.new(0.36 * s, -0.3, 0), CFrame.new(0, 0.75, 0))
	joint(side .. "Knee", side .. "UpperLeg", side .. "LowerLeg", CFrame.new(0, -0.75, 0), CFrame.new(0, 0.7, 0))
	joint(side .. "Ankle", side .. "LowerLeg", side .. "Foot", CFrame.new(0, -0.7, 0), CFrame.new(0, 0.1, 0.1))
	joint(side .. "Toe", side .. "Foot", side .. "Toes", CFrame.new(0, -0.03, -0.33), CFrame.new(0, 0, 0.22))
	decor(side .. "KneeKnob", side .. "LowerLeg", CFrame.new(0, 0.7, -0.08), Vector3.new(0.36, 0.34, 0.32), SKIN_DARK)
	decor(side .. "Heel", side .. "Foot", CFrame.new(0, 0.02, 0.3), Vector3.new(0.3, 0.24, 0.26), DEAD)
	for k = 0, 2 do
		decor(
			`{side}ToeClaw{k}`,
			side .. "Toes",
			CFrame.new((k - 1) * 0.12, -0.02, -0.32) * CFrame.Angles(-0.35, 0, 0),
			Vector3.new(0.06, 0.07, 0.24),
			CLAW
		)
	end
end

-- ===== Back tendrils (4 x 3 tapering segments) =====================================================
local TENDRILS = {
	{ attach = "UpperChest", pos = Vector3.new(-0.5, 0.1, 0.38), tilt = Vector3.new(0.9, 0, -0.4) },
	{ attach = "UpperChest", pos = Vector3.new(0.5, 0.1, 0.38), tilt = Vector3.new(0.9, 0, 0.4) },
	{ attach = "Chest", pos = Vector3.new(-0.35, 0.05, 0.5), tilt = Vector3.new(1.25, 0, -0.65) },
	{ attach = "Chest", pos = Vector3.new(0.35, 0.05, 0.5), tilt = Vector3.new(1.25, 0, 0.65) },
}
for t, def in TENDRILS do
	local lengths = { 0.75, 0.68, 0.6, 0.52, 0.45 }
	local widths = { 0.21, 0.18, 0.15, 0.12, 0.09 }
	local prev = def.attach
	for k = 1, 5 do
		local name = `Tendril{t}_{k}`
		local jointName = `Tendril{t}{string.char(64 + k)}`
		part(name, Vector3.new(widths[k], lengths[k] + 0.12, widths[k]), SKIN_DARK)
		local c0 = if k == 1
			then CFrame.new(def.pos) * CFrame.Angles(def.tilt.X, def.tilt.Y, def.tilt.Z)
			else CFrame.new(0, lengths[k - 1] / 2, 0)
		joint(jointName, prev, name, c0, CFrame.new(0, -lengths[k] / 2, 0)) -- grows up and back
		prev = name
	end
	decor(`Tendril{t}Tip`, `Tendril{t}_5`, CFrame.new(0, 0.32, 0), Vector3.new(0.06, 0.26, 0.06), CLAW)
end

assert(#JOINTS == 103, `[MonsterRig] expected 103 joints, got {#JOINTS}`)

MonsterRig.SPEC = table.freeze({ parts = PARTS, joints = JOINTS, decor = DECOR, hipHeight = HIP_HEIGHT })

-- ===== Build =========================================================================================

local MESH_TYPE: { [string]: Enum.MeshType } = {
	Ellipsoid = Enum.MeshType.Sphere, -- a Sphere SpecialMesh stretches to the part's size
	Wedge = Enum.MeshType.Wedge,
}

local function newPart(name: string, size: Vector3, color: Color3, material: Enum.Material, shape: Shape?): Part
	local p = Instance.new("Part")
	local meshType = MESH_TYPE[shape or "Block"]
	if meshType then
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = meshType
		mesh.Parent = p
	end
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

-- Decor that stays even with the meshes (dark socket interiors, glowing eyes, mouth, teeth).
local KEEP_WITH_MESHES: { [string]: boolean } = { Socket = true, Eye = true, UpperMouth = true, LowerMouth = true }

-- Clones M_<PartName> MeshParts from ServerStorage.TenantMeshes onto the rig. Returns true if any
-- were applied. MonsterMeshes (generated) says where each mesh's bounding box sits in its part and
-- its size, so importer recentring / unit scaling doesn't matter.
function applyMeshes(parts: { [string]: BasePart }): boolean
	local ok, source = pcall(function()
		return game:GetService("ServerStorage"):FindFirstChild("TenantMeshes")
	end)
	if not ok or not source then
		return false
	end
	local info = require(script.Parent.Parent.Config.MonsterMeshes) :: any
	local count = 0
	for partName, host in parts do
		local template = source:FindFirstChild("M_" .. partName, true)
		local meta = info[partName]
		if template and template:IsA("MeshPart") and meta then
			local mesh = template:Clone()
			mesh.Name = "Mesh"
			mesh.Anchored = false
			mesh.CanCollide = false
			mesh.CanTouch = false
			mesh.CanQuery = false
			mesh.Massless = true
			mesh.Size = meta.size
			mesh.CFrame = host.CFrame * CFrame.new(meta.center) * MESH_ROTATION
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = host
			weld.Part1 = mesh
			weld.Parent = mesh
			mesh.Parent = host
			host.Transparency = 1
			count += 1
		end
	end
	if count == 0 then
		warn("[MonsterRig] ServerStorage.TenantMeshes has no M_<Part> MeshParts; using primitive shapes")
	end
	return count > 0
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
		local p = newPart(spec.name, spec.size, spec.color, spec.material, spec.shape)
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

	-- High-detail meshes (optional): if the generated meshes were imported into
	-- ServerStorage.TenantMeshes (assets/meshes/README.md), weld a MeshPart onto every body part and
	-- hide the primitive under it. Joints and animation are unchanged.
	local meshMode = applyMeshes(parts)

	for _, d in DECOR do
		if
			meshMode
			and not KEEP_WITH_MESHES[d.name:gsub("^Left", ""):gsub("^Right", "")]
			and not d.name:find("Tooth")
		then
			continue -- the mesh already sculpts ribs, brow, knobs, claws...
		end
		local host = parts[d.attach]
		local p = newPart(d.name, d.size, d.color, d.material, d.shape)
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
