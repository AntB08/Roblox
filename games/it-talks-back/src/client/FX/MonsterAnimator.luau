--!strict
-- MonsterAnimator: procedural animation for the 16-joint monster rig (Server/Game/MonsterRig).
--
-- How it stays fluid:
--   1. Every frame builds a TARGET pose from layered parts:
--        base hunch -> locomotion (idle / creep walk / chase sprint, blended by speed)
--        -> overlays (listen, speak, dormant) -> one-shot actions (grab, snuff, look, emerge)
--   2. Each joint channel then follows its target through a damped SPRING (per-joint stiffness
--      and damping). Heavy core joints are tight; arms, hands and jaw are loose, so they lag,
--      overshoot and settle: natural follow-through and overlapping action, for free.
--   3. The walk is a real gait: knees lift on the forward swing, ankles keep the feet flat,
--      the pelvis bobs (lowest at foot contact), sways and twists, the chest counter-twists,
--      arms swing opposite the legs, and the head stays locked forward.
--   4. Actions have anticipation: the grab winds up (leans back, arms pulled up) before lunging.
--   5. The head snaps to new angles every few seconds; the springs give it a creepy overshoot.
-- Vanish bypasses the springs on purpose (hard glitch snaps).
--
-- Axes (see MonsterRig): hanging limbs rx > 0 = forward; elbows bend rx > 0, knees rx < 0;
-- torso/head rx < 0 = lean forward / look down; Jaw rx < 0 = open. Left arm rz < 0 = out.

local MonsterAnimator = {}

export type Channel = { rx: number, ry: number, rz: number, y: number }
export type Pose = { [string]: Channel }
export type Context = {
	speed: number, -- horizontal studs/s
	mood: string, -- Dormant / Calm / Alert / Chase
	action: string?, -- current one-shot action, if any
	actionAlpha: number, -- 0..1 progress through it
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
	stepped: boolean, -- true on the frame a foot lands (footstep sounds)
}

local JOINTS = {
	"Root",
	"Waist",
	"Neck",
	"Jaw",
	"LeftShoulder",
	"RightShoulder",
	"LeftElbow",
	"RightElbow",
	"LeftWrist",
	"RightWrist",
	"LeftHip",
	"RightHip",
	"LeftKnee",
	"RightKnee",
	"LeftAnkle",
	"RightAnkle",
}

-- Spring per joint: frequency (Hz) and damping ratio (1 = no overshoot, < 1 = bouncy).
local SPRING: { [string]: { f: number, z: number } } = {
	Root = { f = 5, z = 0.9 },
	Waist = { f = 4, z = 0.75 },
	Neck = { f = 5, z = 0.55 },
	Jaw = { f = 8, z = 0.45 },
	LeftShoulder = { f = 3.2, z = 0.55 },
	RightShoulder = { f = 3.2, z = 0.55 },
	LeftElbow = { f = 2.8, z = 0.45 },
	RightElbow = { f = 2.8, z = 0.45 },
	LeftWrist = { f = 2.4, z = 0.35 },
	RightWrist = { f = 2.4, z = 0.35 },
	LeftHip = { f = 9, z = 0.95 },
	RightHip = { f = 9, z = 0.95 },
	LeftKnee = { f = 9, z = 0.95 },
	RightKnee = { f = 9, z = 0.95 },
	LeftAnkle = { f = 9, z = 0.9 },
	RightAnkle = { f = 9, z = 0.9 },
}

local CHANNELS = { "rx", "ry", "rz", "y" }
local WALK_STRIDE = 6 -- studs per full gait cycle (two steps)
local RUN_STRIDE = 9.5

local rng = Random.new()

local function zero(): Pose
	local p: Pose = {}
	for _, j in JOINTS do
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

-- Both sides at once: side = -1 left, +1 right (mirrors yaw/roll).
local function pair(p: Pose, joint: string, rx: number, ry: number, rz: number, w: number)
	add(p, "Left" .. joint, rx, -ry, -rz, 0, w)
	add(p, "Right" .. joint, rx, ry, rz, 0, w)
end

function MonsterAnimator.newState(): State
	return {
		pose = zero(),
		vel = zero(),
		phase = 0,
		glitch = nil,
		nextGlitch = 0,
		jerk = { rx = 0, ry = 0, rz = 0 },
		nextJerk = 0,
		stepped = false,
	}
end

-- ===== Layers =====================================================================================

local function baseHunch(p: Pose, w: number)
	add(p, "Root", -0.12, 0, 0, 0, w)
	add(p, "Waist", -0.38, 0, 0, 0, w)
	add(p, "Neck", 0.32, 0, 0, 0, w) -- lift the head back up so it stares ahead
	add(p, "Jaw", -0.08, 0, 0, 0, w) -- mouth slightly open
	pair(p, "Shoulder", 0.15, 0, 0.12, w)
	pair(p, "Elbow", 0.35, 0, 0, w)
	pair(p, "Wrist", 0.25, 0, 0, w)
	pair(p, "Hip", 0.12, 0, 0.03, w)
	pair(p, "Knee", -0.25, 0, 0, w)
	pair(p, "Ankle", 0.13, 0, 0, w)
end

local function idle(p: Pose, t: number, w: number)
	local breath = math.sin(t * 1.3)
	add(p, "Waist", breath * 0.035, 0, 0, 0, w)
	add(p, "Root", 0, 0, math.sin(t * 0.35) * 0.04, breath * 0.03, w) -- slow weight shift
	add(p, "Neck", -breath * 0.02, 0, 0, 0, w)
	-- Fingers / wrists twitch irregularly.
	add(p, "LeftWrist", math.noise(t * 3.1, 1) * 0.25, 0, math.noise(t * 2.3, 2) * 0.15, 0, w)
	add(p, "RightWrist", math.noise(t * 2.7, 3) * 0.25, 0, math.noise(t * 2.9, 4) * 0.15, 0, w)
	add(p, "LeftElbow", math.noise(t * 0.9, 5) * 0.12, 0, 0, 0, w)
	add(p, "RightElbow", math.noise(t * 0.8, 6) * 0.12, 0, 0, 0, w)
end

-- One leg's gait angles for phase `ph` (sin ph = how far forward the thigh is).
local function legGait(ph: number, hipAmp: number, kneeLift: number): (number, number, number)
	local hip = math.sin(ph) * hipAmp
	local swing = math.max(0, math.cos(ph)) -- > 0 while the leg travels forward
	local knee = -kneeLift * swing ^ 1.3
	local ankle = -(hip + knee) * 0.75 -- keep the foot roughly flat
	return hip, knee, ankle
end

local function locomotion(p: Pose, phase: number, walkW: number, runW: number)
	local w = walkW + runW
	if w <= 0.001 then
		return
	end
	local hipAmp = 0.5 * walkW + 0.8 * runW
	local kneeLift = 0.9 * walkW + 1.4 * runW
	local lh, lk, la = legGait(phase, hipAmp, kneeLift)
	local rh, rk, ra = legGait(phase + math.pi, hipAmp, kneeLift)
	add(p, "LeftHip", lh, 0, 0, 0, 1)
	add(p, "LeftKnee", lk, 0, 0, 0, 1)
	add(p, "LeftAnkle", la, 0, 0, 0, 1)
	add(p, "RightHip", rh, 0, 0, 0, 1)
	add(p, "RightKnee", rk, 0, 0, 0, 1)
	add(p, "RightAnkle", ra, 0, 0, 0, 1)

	local s = math.sin(phase)
	-- Pelvis: bob (lowest when the legs are spread), sway and twist toward the leading leg.
	local bob = math.cos(2 * phase) * (0.07 * walkW + 0.16 * runW)
	add(p, "Root", -0.12 * runW, s * (0.12 * walkW + 0.18 * runW), math.cos(phase) * 0.05 * walkW, bob, 1)
	-- Chest counter-twists; head cancels most of it so the gaze stays locked.
	add(p, "Waist", -0.1 * runW, -s * (0.18 * walkW + 0.22 * runW), 0, 0, 1)
	add(p, "Neck", 0.25 * runW, s * (0.14 * walkW + 0.2 * runW), 0, 0, 1)

	-- Walk: arms swing loosely opposite the legs (springs add the drag).
	add(p, "LeftShoulder", -s * 0.38, 0, 0, 0, walkW)
	add(p, "RightShoulder", s * 0.38, 0, 0, 0, walkW)
	add(p, "LeftElbow", math.max(0, -s) * 0.3, 0, 0, 0, walkW)
	add(p, "RightElbow", math.max(0, s) * 0.3, 0, 0, 0, walkW)
	-- Run: arms thrown forward, clawing in alternation; jaw hangs open.
	add(p, "LeftShoulder", 1.45 + s * 0.4, 0, -0.1, 0, runW)
	add(p, "RightShoulder", 1.45 - s * 0.4, 0, 0.1, 0, runW)
	add(p, "LeftElbow", 0.25 + math.max(0, s) * 0.5, 0, 0, 0, runW)
	add(p, "RightElbow", 0.25 + math.max(0, -s) * 0.5, 0, 0, 0, runW)
	pair(p, "Wrist", 0.55, 0, 0, runW)
	add(p, "Jaw", -0.42, 0, 0, 0, runW)
end

local function listen(p: Pose, t: number, w: number)
	add(p, "Neck", 0.1, 0.3, 0.55 + math.sin(t * 0.8) * 0.04, 0, w) -- cocked head
	add(p, "Waist", 0.08, 0.15, 0.06, 0, w)
	-- Hand drifts up beside the head, fingers curled.
	add(p, "RightShoulder", 0.7, 0, 0.35, 0, w)
	add(p, "RightElbow", 1.55, 0, 0, 0, w)
	add(p, "RightWrist", 0.5, 0, 0, 0, w)
end

local function speak(p: Pose, t: number, w: number)
	local syllable = math.max(0, math.noise(t * 9, 9)) -- 0..~0.5, fast and irregular
	add(p, "Jaw", -(0.12 + syllable * 0.9), 0, 0, 0, w)
	add(p, "Neck", math.noise(t * 4, 10) * 0.18, math.noise(t * 2.5, 11) * 0.15, math.noise(t * 3.5, 12) * 0.2, 0, w)
	add(p, "Waist", syllable * 0.06, 0, 0, 0, w)
	pair(p, "Wrist", math.noise(t * 6, 13) * 0.3, 0, 0, w)
end

local function dormant(p: Pose, w: number)
	add(p, "Root", -0.1, 0, 0, -0.55, w)
	add(p, "Waist", -0.7, 0, 0.08, 0, w)
	add(p, "Neck", -0.75, 0, 0.25, 0, w) -- head hanging
	pair(p, "Shoulder", 0.45, 0, 0.05, w)
	pair(p, "Elbow", 0.1, 0, 0, w)
	pair(p, "Hip", 0.55, 0, 0, w)
	pair(p, "Knee", -0.85, 0, 0, w)
	pair(p, "Ankle", 0.3, 0, 0, w)
	add(p, "Jaw", -0.25, 0, 0, 0, w)
end

-- Smooth 0..1 ramp between edges.
local function ramp(a: number, from: number, to: number): number
	local x = math.clamp((a - from) / (to - from), 0, 1)
	return x * x * (3 - 2 * x)
end

local function action(p: Pose, name: string, a: number, t: number)
	local env = ramp(a, 0, 0.08) * (1 - ramp(a, 0.85, 1)) -- fade in fast, out at the end
	if name == "Grab" then
		local windup = ramp(a, 0, 0.18) * (1 - ramp(a, 0.18, 0.3))
		local lunge = ramp(a, 0.2, 0.32)
		local lift = ramp(a, 0.35, 0.55)
		-- Anticipation: rear back, arms pulled up and out, mouth opening.
		add(p, "Waist", 0.35, 0, 0, 0, windup * env)
		pair(p, "Shoulder", -0.5, 0, 0.5, windup * env)
		pair(p, "Elbow", 1.2, 0, 0, windup * env)
		-- Lunge: everything forward, arms straight out.
		add(p, "Waist", -0.2, 0, 0, 0, lunge * env)
		add(p, "Root", -0.1, 0, 0, -0.2, lunge * env)
		pair(p, "Shoulder", 1.45, 0, -0.05, lunge * env)
		pair(p, "Elbow", -0.15, 0, 0, lunge * env)
		pair(p, "Wrist", 0.5, 0, 0, lunge * env)
		pair(p, "Knee", -0.4, 0, 0, lunge * env)
		pair(p, "Hip", 0.3, 0, 0, lunge * env)
		-- Lift and shake the victim, jaw wide.
		pair(p, "Shoulder", 0.45, 0, 0, lift * env)
		pair(p, "Elbow", 0.3, 0, 0, lift * env)
		add(p, "Waist", 0.15, 0, 0, 0, lift * env) -- stand up a little while lifting
		add(
			p,
			"Neck",
			-0.2 + math.noise(t * 14, 5) * 0.25,
			math.noise(t * 11, 6) * 0.2,
			math.noise(t * 9, 7) * 0.35,
			0,
			lift * env
		)
		add(p, "Jaw", -0.75, 0, 0, 0, math.max(windup, lift) * env)
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
		add(p, "RightWrist", 0.9 * ramp(a, 0.4, 0.5), 0, 0, 0, down) -- pinch
	elseif name == "Look" then
		local sweep = math.sin(a * math.pi * 2)
		add(p, "Neck", 0, sweep * 1.15, sweep * 0.2, 0, env)
		add(p, "Waist", 0, sweep * 0.35, 0, 0, env)
	elseif name == "Emerge" then
		-- Unfolds upward from a deep crouch (no envelope: it starts folded).
		local fold = 1 - ramp(a, 0, 0.9)
		dormant(p, fold * 1.4)
		add(p, "Neck", 0.9 * fold * ramp(a, 0.3, 0.6), 0, 0, 0, 1) -- head snaps up first
	end
end

local function glitchPose(): Pose
	local p = zero()
	for _, j in JOINTS do
		local k = if j == "Neck" then 1.4 elseif j == "Jaw" then 0.6 else 0.9
		add(p, j, rng:NextNumber(-k, k), rng:NextNumber(-k, k), rng:NextNumber(-k, k))
	end
	return p
end

-- ===== Frame step =================================================================================

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

-- Returns the pose to apply this frame (and updates `state`).
function MonsterAnimator.step(state: State, ctx: Context): Pose
	local target = zero()
	local speed = ctx.speed
	local runW = math.clamp((speed - 11) / 4, 0, 1)
	local walkW = math.clamp(speed / 5, 0, 1) * (1 - runW)
	local moveW = math.max(walkW, runW)

	-- Gait phase advances with distance travelled, so feet don't skate.
	local stride = WALK_STRIDE + (RUN_STRIDE - WALK_STRIDE) * runW
	local before = state.phase
	state.phase += ctx.dt * (2 * math.pi) * math.max(speed, 0) / stride
	state.stepped = moveW > 0.2
		and math.floor((before + math.pi / 2) / math.pi) ~= math.floor((state.phase + math.pi / 2) / math.pi)

	local dormantW = if ctx.mood == "Dormant" then 1 else 0
	baseHunch(target, 1)
	idle(target, ctx.time, 1 - moveW)
	locomotion(target, state.phase, walkW, runW)
	if ctx.mood == "Alert" and speed < 2 then
		listen(target, ctx.time, 1)
	end
	if dormantW > 0 then
		dormant(target, dormantW)
	end
	if ctx.speaking then
		speak(target, ctx.time, 1)
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
	add(target, "Neck", state.jerk.rx, state.jerk.ry, state.jerk.rz, 0, 1 - dormantW)

	if ctx.action == "Vanish" then
		-- Violent glitching: a new random pose every few frames, no springs.
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
		action(target, ctx.action, ctx.actionAlpha, ctx.time)
	end

	springStep(state, target, ctx.dt)
	return state.pose
end

function MonsterAnimator.toCFrame(j: Channel): CFrame
	return CFrame.new(0, j.y, 0) * CFrame.Angles(j.rx, j.ry, j.rz)
end

MonsterAnimator.Joints = JOINTS

return MonsterAnimator
