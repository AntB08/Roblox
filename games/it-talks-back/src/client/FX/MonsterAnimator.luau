--!strict
-- MonsterAnimator: procedural animation for the 91-joint monster rig (Server/Game/MonsterRig).
--
-- Two levels:
--   1. BODY layer (easy to author): Root, Waist, Neck, Jaw, shoulders, elbows, wrists, hips,
--      knees, ankles + Grip (finger curl / twitch) per hand, Tongue, Tendril (agitation), Lids.
--      Built from layers: base hunch -> idle / creep walk / chase sprint (blended by speed) ->
--      listen / speak / dormant overlays -> one-shot actions (grab, snuff, look, emerge).
--   2. EXPANSION to the 91 real joints: the waist bend is spread over 4 spine joints and the neck
--      over 4 neck joints + skull (so they CURVE instead of hinging), clavicles shrug when arms lift or
--      reach, every finger curls with its own lag and twitch, toes flex, the tongue wriggles,
--      lids blink (never while chasing: it stares), and the 4 back tendrils undulate faster the
--      more agitated it is.
-- Then EVERY joint follows its target through a damped spring with per-group stiffness: tight
-- legs (no foot skating), heavy spine, loose arms, looser fingers, whippy tendrils. That gives
-- follow-through, overlap and overshoot everywhere. Vanish bypasses springs (hard glitch snaps).
--
-- Axes (see MonsterRig): hanging limbs / fingers rx > 0 = forward / curl; knees rx < 0;
-- torso / neck rx < 0 = lean forward; Jaw rx < 0 = open; Lid rx < 0 = close.

local MonsterAnimator = {}

export type Channel = { rx: number, ry: number, rz: number, y: number }
export type Pose = { [string]: Channel }
export type Context = {
	speed: number,
	mood: string,
	action: string?,
	actionAlpha: number,
	speaking: boolean,
	dt: number,
	time: number,
}
export type State = {
	pose: Pose,
	vel: Pose,
	phase: number,
	glitch: Pose?,
	nextGlitch: number,
	jerk: { ry: number, rz: number, rx: number },
	nextJerk: number,
	nextBlink: number,
	stepped: boolean,
}

local SIDES = { "Left", "Right" }

-- ===== The 91 joints and their springs =============================================================
local JOINTS: { string } = {
	"Root",
	"Spine1",
	"Spine2",
	"Spine3",
	"Spine4",
	"Neck1",
	"Neck2",
	"Neck3",
	"Neck4",
	"Skull",
	"Jaw",
	"Tongue1",
	"Tongue2",
}
for _, side in SIDES do
	table.insert(JOINTS, side .. "Lid")
end
for _, side in SIDES do
	for _, j in { "Clavicle", "Shoulder", "Elbow", "Wrist", "ThumbA", "ThumbB" } do
		table.insert(JOINTS, side .. j)
	end
	for f = 1, 4 do
		for _, seg in { "A", "B", "C" } do
			table.insert(JOINTS, `{side}Finger{f}{seg}`)
		end
	end
	for _, j in { "Hip", "Knee", "Ankle", "Toe" } do
		table.insert(JOINTS, side .. j)
	end
end
local TENDRIL_SEGMENTS = 5
for t = 1, 4 do
	for seg = 1, TENDRIL_SEGMENTS do
		table.insert(JOINTS, `Tendril{t}{string.char(64 + seg)}`)
	end
end
for r = 0, 5 do
	table.insert(JOINTS, `Rag{r}A`)
	table.insert(JOINTS, `Rag{r}B`)
end
assert(#JOINTS == 91, "MonsterAnimator expects the 91-joint rig")

type SpringSpec = { f: number, z: number }
local function springFor(j: string): SpringSpec
	if j:find("Tendril") then
		return { f = 1.9 - (string.byte(j, -1) - 65) * 0.12, z = 0.28 } -- whippy, tips the loosest
	elseif j:find("Rag") then
		return { f = if j:sub(-1) == "A" then 1.6 else 1.3, z = 0.3 } -- cloth: lags and sways
	elseif j:find("Thumb") then
		return { f = 4, z = 0.5 }
	elseif j:find("Finger") then
		return { f = if j:sub(-1) == "A" then 4.5 else 3.6, z = 0.5 }
	elseif j:find("Lid") then
		return { f = 16, z = 0.95 } -- quick blinks
	elseif j:find("Tongue") then
		return { f = 5, z = 0.35 }
	elseif j:find("Hip") or j:find("Knee") or j:find("Ankle") or j:find("Toe") then
		return { f = 9, z = 0.95 } -- tight: feet don't skate
	elseif j == "Root" then
		return { f = 5, z = 0.9 }
	elseif j:find("Spine") then
		return { f = 4.2 - (tonumber(j:sub(-1)) or 1) * 0.4, z = 0.75 } -- upper spine lags the lower
	elseif j:find("Neck") or j == "Skull" then
		return { f = 5, z = 0.55 }
	elseif j == "Jaw" then
		return { f = 8, z = 0.45 }
	elseif j:find("Clavicle") then
		return { f = 4, z = 0.7 }
	elseif j:find("Shoulder") then
		return { f = 3.2, z = 0.55 }
	elseif j:find("Elbow") then
		return { f = 2.8, z = 0.45 }
	elseif j:find("Wrist") then
		return { f = 2.4, z = 0.35 }
	end
	return { f = 5, z = 0.8 }
end
local SPRING: { [string]: SpringSpec } = {}
for _, j in JOINTS do
	SPRING[j] = springFor(j)
end

-- Body-layer channels (what the layers below author).
local BODY = {
	"Root",
	"Waist",
	"Neck",
	"Jaw",
	"Tongue",
	"Tendril",
	"Lids",
	"LeftShoulder",
	"RightShoulder",
	"LeftElbow",
	"RightElbow",
	"LeftWrist",
	"RightWrist",
	"LeftGrip",
	"RightGrip",
	"LeftHip",
	"RightHip",
	"LeftKnee",
	"RightKnee",
	"LeftAnkle",
	"RightAnkle",
}

local CHANNELS = { "rx", "ry", "rz", "y" }
local WALK_STRIDE = 6 -- studs per full gait cycle (two steps)
local RUN_STRIDE = 9.5

local rng = Random.new()

local function zero(list: { string }): Pose
	local p: Pose = {}
	for _, j in list do
		p[j] = { rx = 0, ry = 0, rz = 0, y = 0 }
	end
	return p
end

local function add(p: Pose, joint: string, rx: number, ry: number?, rz: number?, y: number?, weight: number?)
	local w = weight or 1
	local c = p[joint]
	c.rx += rx * w
	c.ry += (ry or 0) * w
	c.rz += (rz or 0) * w
	c.y += (y or 0) * w
end

-- Both sides at once (mirrors yaw/roll).
local function pair(p: Pose, joint: string, rx: number, ry: number, rz: number, w: number)
	add(p, "Left" .. joint, rx, -ry, -rz, 0, w)
	add(p, "Right" .. joint, rx, ry, rz, 0, w)
end

-- Finger curl (rx) and twitch amount (ry) for both hands (not mirrored).
local function grip(p: Pose, curl: number, twitch: number, _unused: number, w: number)
	add(p, "LeftGrip", curl, twitch, 0, 0, w)
	add(p, "RightGrip", curl, twitch, 0, 0, w)
end

function MonsterAnimator.newState(): State
	return {
		pose = zero(JOINTS),
		vel = zero(JOINTS),
		phase = 0,
		glitch = nil,
		nextGlitch = 0,
		jerk = { rx = 0, ry = 0, rz = 0 },
		nextJerk = 0,
		nextBlink = 0,
		stepped = false,
	}
end

-- ===== Body layers ==================================================================================

local function baseHunch(p: Pose)
	add(p, "Root", -0.12)
	add(p, "Waist", -0.42)
	add(p, "Neck", 0.36) -- lift the head so it stares ahead
	add(p, "Jaw", -0.1) -- mouth hangs slightly open
	pair(p, "Shoulder", 0.12, 0, 0.1, 1)
	pair(p, "Elbow", 0.4, 0, 0, 1)
	pair(p, "Wrist", 0.2, 0, 0, 1)
	grip(p, 0.45, 0.6, 0, 1) -- rx = curl, ry = twitch amount
	pair(p, "Hip", 0.12, 0, 0.04, 1)
	pair(p, "Knee", -0.25, 0, 0, 1)
	pair(p, "Ankle", 0.13, 0, 0, 1)
	add(p, "Tendril", 0.15)
end

local function idle(p: Pose, t: number, w: number)
	local breath = math.sin(t * 1.3)
	add(p, "Waist", breath * 0.04, 0, 0, 0, w)
	add(p, "Root", 0, math.sin(t * 0.21) * 0.05, math.sin(t * 0.35) * 0.045, breath * 0.03, w)
	add(p, "Neck", -breath * 0.025, 0, 0, 0, w)
	add(p, "LeftElbow", math.noise(t * 0.9, 5) * 0.14, 0, 0, 0, w)
	add(p, "RightElbow", math.noise(t * 0.8, 6) * 0.14, 0, 0, 0, w)
	add(p, "LeftWrist", math.noise(t * 1.7, 1) * 0.2, 0, math.noise(t * 1.3, 2) * 0.15, 0, w)
	add(p, "RightWrist", math.noise(t * 1.5, 3) * 0.2, 0, math.noise(t * 1.9, 4) * 0.15, 0, w)
	grip(p, 0, 0.4, 0, w) -- extra finger twitching when still
end

local function legGait(ph: number, hipAmp: number, kneeLift: number): (number, number, number)
	local hip = math.sin(ph) * hipAmp
	local swing = math.max(0, math.cos(ph))
	local knee = -kneeLift * swing ^ 1.3
	local ankle = -(hip + knee) * 0.75
	return hip, knee, ankle
end

local function locomotion(p: Pose, phase: number, walkW: number, runW: number)
	if walkW + runW <= 0.001 then
		return
	end
	local hipAmp = 0.5 * walkW + 0.8 * runW
	local kneeLift = 0.9 * walkW + 1.4 * runW
	local lh, lk, la = legGait(phase, hipAmp, kneeLift)
	local rh, rk, ra = legGait(phase + math.pi, hipAmp, kneeLift)
	add(p, "LeftHip", lh)
	add(p, "LeftKnee", lk)
	add(p, "LeftAnkle", la)
	add(p, "RightHip", rh)
	add(p, "RightKnee", rk)
	add(p, "RightAnkle", ra)

	local s = math.sin(phase)
	local bob = math.cos(2 * phase) * (0.07 * walkW + 0.16 * runW)
	add(p, "Root", -0.12 * runW, s * (0.12 * walkW + 0.18 * runW), math.cos(phase) * 0.05 * walkW, bob)
	add(p, "Waist", -0.1 * runW, -s * (0.18 * walkW + 0.22 * runW))
	add(p, "Neck", 0.25 * runW, s * (0.14 * walkW + 0.2 * runW))

	-- Walk: arms swing loosely opposite the legs.
	add(p, "LeftShoulder", -s * 0.38, 0, 0, 0, walkW)
	add(p, "RightShoulder", s * 0.38, 0, 0, 0, walkW)
	add(p, "LeftElbow", math.max(0, -s) * 0.3, 0, 0, 0, walkW)
	add(p, "RightElbow", math.max(0, s) * 0.3, 0, 0, 0, walkW)
	-- Run: arms thrown forward, clawing; hands open and close; jaw and tongue out.
	add(p, "LeftShoulder", 1.45 + s * 0.4, 0, -0.1, 0, runW)
	add(p, "RightShoulder", 1.45 - s * 0.4, 0, 0.1, 0, runW)
	add(p, "LeftElbow", 0.25 + math.max(0, s) * 0.5, 0, 0, 0, runW)
	add(p, "RightElbow", 0.25 + math.max(0, -s) * 0.5, 0, 0, 0, runW)
	pair(p, "Wrist", 0.55, 0, 0, runW)
	add(p, "LeftGrip", -0.35 + math.max(0, s) * 1.1, 0, 0, 0, runW)
	add(p, "RightGrip", -0.35 + math.max(0, -s) * 1.1, 0, 0, 0, runW)
	add(p, "Jaw", -0.45, 0, 0, 0, runW)
	add(p, "Tongue", 0.5, 0.8, 0, 0, runW) -- rx = stick out, ry = wriggle
	add(p, "Tendril", 0.85, 0, 0, 0, runW)
	add(p, "Tendril", 0.2, 0, 0, 0, walkW)
end

local function listen(p: Pose, t: number, w: number)
	add(p, "Neck", 0.1, 0.3, 0.6 + math.sin(t * 0.8) * 0.04, 0, w)
	add(p, "Waist", 0.08, 0.15, 0.06, 0, w)
	add(p, "RightShoulder", 0.7, 0, 0.35, 0, w)
	add(p, "RightElbow", 1.55, 0, 0, 0, w)
	add(p, "RightWrist", 0.5, 0, 0, 0, w)
	add(p, "RightGrip", 0.2, 0.8, 0, 0, w) -- fingers drumming by its ear
	add(p, "Tendril", -0.1, 0, 0, 0, w) -- tendrils go still while it listens
	add(p, "Lids", 0.15, 0, 0, 0, w) -- eyes wide
end

local function speak(p: Pose, t: number, w: number)
	local syllable = math.max(0, math.noise(t * 9, 9))
	add(p, "Jaw", -(0.14 + syllable * 1.0), 0, 0, 0, w)
	add(p, "Tongue", syllable * 0.6, 0.5, 0, 0, w)
	add(p, "Neck", math.noise(t * 4, 10) * 0.18, math.noise(t * 2.5, 11) * 0.15, math.noise(t * 3.5, 12) * 0.2, 0, w)
	add(p, "Waist", syllable * 0.06, 0, 0, 0, w)
	pair(p, "Wrist", math.noise(t * 6, 13) * 0.3, 0, 0, w)
	grip(p, 0, 0.6, 0, w)
	add(p, "Tendril", 0.25, 0, 0, 0, w)
end

local function dormant(p: Pose, w: number)
	add(p, "Root", -0.1, 0, 0, -0.55, w)
	add(p, "Waist", -0.75, 0, 0.08, 0, w)
	add(p, "Neck", -0.85, 0, 0.3, 0, w)
	pair(p, "Shoulder", 0.45, 0, 0.05, w)
	pair(p, "Elbow", 0.1, 0, 0, w)
	grip(p, 0.2, -0.4, 0, w)
	pair(p, "Hip", 0.55, 0, 0, w)
	pair(p, "Knee", -0.85, 0, 0, w)
	pair(p, "Ankle", 0.3, 0, 0, w)
	add(p, "Jaw", -0.3, 0, 0, 0, w)
	add(p, "Tendril", -0.15, 0, 0, 0, w)
end

local function ramp(a: number, from: number, to: number): number
	local x = math.clamp((a - from) / (to - from), 0, 1)
	return x * x * (3 - 2 * x)
end

local function action(p: Pose, name: string, a: number, t: number)
	local env = ramp(a, 0, 0.08) * (1 - ramp(a, 0.85, 1))
	if name == "Grab" then
		local windup = ramp(a, 0, 0.18) * (1 - ramp(a, 0.18, 0.3))
		local lunge = ramp(a, 0.2, 0.32)
		local lift = ramp(a, 0.35, 0.55)
		-- Anticipation: rear back, arms up and out, fingers splayed, mouth opening.
		add(p, "Waist", 0.35, 0, 0, 0, windup * env)
		pair(p, "Shoulder", -0.5, 0, 0.5, windup * env)
		pair(p, "Elbow", 1.2, 0, 0, windup * env)
		grip(p, -0.6, 0, 0, windup * env)
		-- Lunge: arms straight out, fingers open wide.
		add(p, "Waist", -0.2, 0, 0, 0, lunge * env)
		add(p, "Root", -0.1, 0, 0, -0.2, lunge * env)
		pair(p, "Shoulder", 1.45, 0, -0.05, lunge * env)
		pair(p, "Elbow", -0.15, 0, 0, lunge * env)
		pair(p, "Wrist", 0.5, 0, 0, lunge * env)
		grip(p, -0.4, 0, 0, lunge * (1 - lift) * env)
		pair(p, "Knee", -0.4, 0, 0, lunge * env)
		pair(p, "Hip", 0.3, 0, 0, lunge * env)
		-- Lift: fingers clamp shut, head shakes, jaw gapes, tendrils thrash.
		pair(p, "Shoulder", 0.45, 0, 0, lift * env)
		pair(p, "Elbow", 0.3, 0, 0, lift * env)
		grip(p, 1.4, 0, 0, lift * env)
		add(p, "Waist", 0.15, 0, 0, 0, lift * env)
		add(
			p,
			"Neck",
			-0.2 + math.noise(t * 14, 5) * 0.25,
			math.noise(t * 11, 6) * 0.2,
			math.noise(t * 9, 7) * 0.35,
			0,
			lift * env
		)
		add(p, "Jaw", -0.85, 0, 0, 0, math.max(windup, lift) * env)
		add(p, "Tongue", 0.6, 1, 0, 0, lift * env)
		add(p, "Tendril", 1, 0, 0, 0, env)
		add(p, "Lids", 0.2, 0, 0, 0, env)
	elseif name == "Snuff" then
		local down = ramp(a, 0, 0.35) * (1 - ramp(a, 0.65, 1))
		add(p, "Root", 0, 0, 0, -0.45, down)
		add(p, "Waist", -0.75, 0, 0, 0, down)
		add(p, "Neck", -0.35, 0, 0, 0, down)
		pair(p, "Hip", 0.55, 0, 0, down)
		pair(p, "Knee", -0.9, 0, 0, down)
		pair(p, "Ankle", 0.35, 0, 0, down)
		add(p, "RightShoulder", 1.1, 0, -0.1, 0, down)
		add(p, "RightElbow", 0.6, 0, 0, 0, down)
		add(p, "RightGrip", -0.4 + 1.5 * ramp(a, 0.4, 0.5), 0, 0, 0, down) -- reach, then pinch
	elseif name == "Look" then
		local sweep = math.sin(a * math.pi * 2)
		add(p, "Neck", 0, sweep * 1.15, sweep * 0.2, 0, env)
		add(p, "Waist", 0, sweep * 0.35, 0, 0, env)
		add(p, "Lids", 0.15, 0, 0, 0, env)
	elseif name == "Emerge" then
		local fold = 1 - ramp(a, 0, 0.9)
		dormant(p, fold * 1.4)
		add(p, "Neck", 0.9 * fold * ramp(a, 0.3, 0.6), 0, 0, 0, 1)
		add(p, "Tendril", 0.8 * ramp(a, 0.2, 0.5), 0, 0, 0, 1)
	end
end

-- ===== Expansion: body layer -> 91 joints ============================================================

local function copyInto(target: Pose, joint: string, c: Channel, share: number)
	add(target, joint, c.rx * share, c.ry * share, c.rz * share, 0)
end

local function expand(body: Pose, state: State, ctx: Context, blink: number): Pose
	local t = ctx.time
	local target = zero(JOINTS)

	local r = body.Root
	add(target, "Root", r.rx, r.ry, r.rz, r.y)
	-- Spine curves: lower spine takes less, upper more of forward bend; twist mostly up top.
	local w = body.Waist
	add(target, "Spine1", w.rx * 0.2, w.ry * 0.18, w.rz * 0.22)
	add(target, "Spine2", w.rx * 0.24, w.ry * 0.22, w.rz * 0.26) -- the wasp waist bends the most
	add(target, "Spine3", w.rx * 0.28, w.ry * 0.28, w.rz * 0.26)
	add(target, "Spine4", w.rx * 0.28, w.ry * 0.32, w.rz * 0.26)
	local n = body.Neck
	copyInto(target, "Neck1", n, 0.17)
	copyInto(target, "Neck2", n, 0.18)
	copyInto(target, "Neck3", n, 0.19)
	copyInto(target, "Neck4", n, 0.2)
	copyInto(target, "Skull", n, 0.26)
	-- The vulture S-curve: the neck juts forward and down from the shoulders, then curls and the
	-- skull tilts back up so the face looks ahead from below shoulder height.
	add(target, "Neck1", -0.5)
	add(target, "Neck2", -0.35)
	add(target, "Neck3", -0.15)
	add(target, "Neck4", 0.1)
	add(target, "Skull", 0.85)
	copyInto(target, "Jaw", body.Jaw, 1)

	-- Tongue: rx = stick out, ry = how much it wriggles.
	local tg = body.Tongue
	local wriggle = tg.ry
	add(target, "Tongue1", tg.rx * 0.5 + math.sin(t * 9) * 0.25 * wriggle, math.sin(t * 7) * 0.35 * wriggle)
	add(target, "Tongue2", tg.rx * 0.7 + math.sin(t * 9 - 1.2) * 0.4 * wriggle, math.sin(t * 7 - 1.4) * 0.5 * wriggle)

	-- Lids: blink (0..1) closes; body.Lids.rx > 0 opens them wider (staring).
	local lid = -1.3 * blink + body.Lids.rx
	add(target, "LeftLid", lid)
	add(target, "RightLid", lid)

	for i, side in SIDES do
		local sign = if i == 1 then -1 else 1
		local sh = body[side .. "Shoulder"]
		-- Clavicle shrugs as the arm lifts, rolls forward as it reaches.
		local lift = math.max(0, sh.rx - 0.8)
		local reach = math.clamp(sh.rx, 0, 1.6)
		add(target, side .. "Clavicle", 0, sign * reach * 0.18, sign * (0.28 + lift * 0.3)) -- shoulders hunched high
		copyInto(target, side .. "Shoulder", sh, 1)
		copyInto(target, side .. "Elbow", body[side .. "Elbow"], 1)
		copyInto(target, side .. "Wrist", body[side .. "Wrist"], 1)

		-- Fingers: curl from Grip.rx, each finger slightly delayed / different; Grip.ry = twitch.
		local grip = body[side .. "Grip"]
		local curl, twitch = grip.rx, grip.ry
		local open = 1 - math.clamp(curl, 0, 1)
		add(target, side .. "ThumbA", 0.1 + curl * 0.6, 0, -sign * curl * 0.25)
		add(target, side .. "ThumbB", 0.1 + curl * 0.7)
		for f = 1, 4 do
			local jitter = math.noise(t * (1.8 + f * 0.37), f * 3.1 + i * 11) * 0.35 * twitch
			local fanned = (f - 2.5) * 0.12 * open * sign
			local base = `{side}Finger{f}`
			add(target, base .. "A", 0.12 + curl * 0.55 + jitter * 0.6, 0, fanned)
			add(target, base .. "B", 0.08 + curl * 0.75 + jitter)
			add(target, base .. "C", 0.05 + curl * 0.6 + jitter * 0.8)
		end

		copyInto(target, side .. "Hip", body[side .. "Hip"], 1)
		copyInto(target, side .. "Knee", body[side .. "Knee"], 1)
		local ankle = body[side .. "Ankle"]
		copyInto(target, side .. "Ankle", ankle, 1)
		add(target, side .. "Toe", -ankle.rx * 0.35 + math.max(0, -body[side .. "Knee"].rx - 0.6) * 0.3)
	end

	-- Tendrils: travelling waves; agitation speeds them up and widens them.
	local agitation = math.clamp(body.Tendril.rx, -0.2, 1.2)
	local amp = 0.1 + 0.45 * math.max(0, agitation)
	local speedA = 1.1 + 2.6 * math.max(0, agitation)
	for k = 1, 4 do
		for seg = 1, TENDRIL_SEGMENTS do
			local ph = t * speedA + k * 1.7 - seg * 0.75
			local taper = 0.6 + seg * 0.15 -- tips swing wider
			local name = `Tendril{k}{string.char(64 + seg)}`
			add(
				target,
				name,
				amp * taper * math.sin(ph) + (if seg == 1 then -agitation * 0.3 else 0),
				0,
				amp * 0.7 * taper * math.sin(ph * 0.8 + k)
			)
		end
	end

	-- Rags: hang, sway, and trail backward with speed (the springs make them lag behind).
	local trail = -math.min(0.9, ctx.speed * 0.055)
	for r = 0, 5 do
		local sway = math.noise(t * 0.7, r * 2.3) * 0.18
		add(target, `Rag{r}A`, trail + sway, 0, math.noise(t * 0.5, r * 4.1) * 0.12)
		add(target, `Rag{r}B`, trail * 0.6 + sway * 1.3)
	end
	return target
end

-- ===== Frame step ===================================================================================

local function glitchPose(): Pose
	local p = zero(JOINTS)
	for _, j in JOINTS do
		local k = if j:find("Neck") or j == "Skull"
			then 0.8
			elseif j:find("Finger") then 1.2
			elseif j:find("Tendril") then 1.4
			else 0.7
		add(p, j, rng:NextNumber(-k, k), rng:NextNumber(-k, k) * 0.6, rng:NextNumber(-k, k) * 0.6)
	end
	return p
end

local function springStep(state: State, target: Pose, dt: number)
	local steps = math.max(1, math.ceil(dt / (1 / 120)))
	local h = dt / steps
	for _ = 1, steps do
		for _, j in JOINTS do
			local s = SPRING[j]
			local omega = 2 * math.pi * s.f
			local k, c = omega * omega, 2 * s.z * omega
			local x: any, v: any, tj: any = state.pose[j], state.vel[j], target[j]
			for _, ch in CHANNELS do
				local xv = x[ch]
				local vv = v[ch] + (k * (tj[ch] - xv) - c * v[ch]) * h
				v[ch] = vv
				x[ch] = xv + vv * h
			end
		end
	end
end

function MonsterAnimator.step(state: State, ctx: Context): Pose
	local body = zero(BODY)
	local speed = ctx.speed
	local runW = math.clamp((speed - 11) / 4, 0, 1)
	local walkW = math.clamp(speed / 5, 0, 1) * (1 - runW)
	local moveW = math.max(walkW, runW)

	local stride = WALK_STRIDE + (RUN_STRIDE - WALK_STRIDE) * runW
	local before = state.phase
	state.phase += ctx.dt * (2 * math.pi) * math.max(speed, 0) / stride
	state.stepped = moveW > 0.2
		and math.floor((before + math.pi / 2) / math.pi) ~= math.floor((state.phase + math.pi / 2) / math.pi)

	local isDormant = ctx.mood == "Dormant"
	baseHunch(body)
	idle(body, ctx.time, 1 - moveW)
	locomotion(body, state.phase, walkW, runW)
	if ctx.mood == "Alert" and speed < 2 then
		listen(body, ctx.time, 1)
	end
	if isDormant then
		dormant(body, 1)
	end
	if ctx.speaking then
		speak(body, ctx.time, 1)
	end

	-- Head snaps to a new angle every few seconds (springs overshoot = creature-like).
	if ctx.time >= state.nextJerk then
		local calm = ctx.mood == "Calm"
		state.nextJerk = ctx.time + rng:NextNumber(if calm then 1.6 else 0.6, if calm then 4 else 1.8)
		local amount = if ctx.mood == "Chase" then 0.15 else 0.45
		state.jerk = {
			rx = rng:NextNumber(-0.15, 0.15),
			ry = rng:NextNumber(-amount, amount) * 1.3,
			rz = rng:NextNumber(-amount, amount),
		}
	end
	if not isDormant then
		add(body, "Neck", state.jerk.rx, state.jerk.ry, state.jerk.rz)
	end

	if ctx.action == "Vanish" then
		if ctx.time >= state.nextGlitch or not state.glitch then
			state.glitch = glitchPose()
			state.nextGlitch = ctx.time + rng:NextNumber(0.03, 0.09)
		end
		local g = state.glitch :: Pose
		for _, j in JOINTS do
			local c, gj, v = state.pose[j], g[j], state.vel[j]
			c.rx, c.ry, c.rz, c.y = gj.rx, gj.ry, gj.rz, gj.y
			v.rx, v.ry, v.rz, v.y = 0, 0, 0, 0
		end
		return state.pose
	elseif ctx.action then
		action(body, ctx.action, ctx.actionAlpha, ctx.time)
	end

	-- Blinks: every few seconds, never while chasing (it stares); shut while dormant.
	local blink = 0
	if isDormant then
		blink = 1
	elseif ctx.mood ~= "Chase" then
		if ctx.time >= state.nextBlink + 0.16 then
			state.nextBlink = ctx.time + rng:NextNumber(2.5, 6)
		elseif ctx.time >= state.nextBlink then
			blink = 1
		end
	end
	if ctx.action == "Emerge" then
		blink = 1 - ramp(ctx.actionAlpha, 0.4, 0.55) -- eyes snap open as it rises
	end

	springStep(state, expand(body, state, ctx, blink), ctx.dt)
	return state.pose
end

function MonsterAnimator.toCFrame(j: Channel): CFrame
	return CFrame.new(0, j.y, 0) * CFrame.Angles(j.rx, j.ry, j.rz)
end

MonsterAnimator.Joints = JOINTS

return MonsterAnimator
