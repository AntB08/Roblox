--!strict
-- MonsterAnimator: procedural animation for the monster rig (no uploaded animation assets).
-- Each frame it builds a target pose from:
--   locomotion  idle (breathing, slow head drift) / creep walk / hunched chase sprint
--   overlays    Listen (head tilt, still), Speak (head jerks while talking), and one-shot
--               actions from the server: Grab, Snuff, Look, Vanish (violent glitch), Emerge
-- then blends the current pose toward it, so every transition is smooth (except the glitches,
-- which are meant to snap). Poses are per joint: rotations in radians (rx = pitch, ry = yaw,
-- rz = roll) plus a vertical offset. Joint names match Server/Game/MonsterRig.luau.
--
-- Axis cheat sheet for this rig: shoulder/hip rx > 0 swings the limb FORWARD; Root rx < 0 leans
-- the torso forward; Neck rx > 0 looks down.

local MonsterAnimator = {}

export type Pose = { [string]: { rx: number, ry: number, rz: number, y: number } }
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
	phase: number,
	glitch: Pose?,
	nextGlitch: number,
	stepped: boolean, -- set true on the frame a foot lands (for footstep sounds)
}

local JOINTS = { "Root", "Neck", "LeftShoulder", "RightShoulder", "LeftHip", "RightHip" }

local rng = Random.new()

local function zero(): Pose
	local p: Pose = {}
	for _, j in JOINTS do
		p[j] = { rx = 0, ry = 0, rz = 0, y = 0 }
	end
	return p
end

local function add(p: Pose, joint: string, rx: number, ry: number, rz: number, y: number?, weight: number?)
	local w = weight or 1
	local j = p[joint]
	j.rx += rx * w
	j.ry += ry * w
	j.rz += rz * w
	j.y += (y or 0) * w
end

function MonsterAnimator.newState(): State
	return { pose = zero(), phase = 0, glitch = nil, nextGlitch = 0, stepped = false }
end

-- ===== Locomotion layers ===========================================================================

local function idle(p: Pose, t: number, w: number)
	local breath = math.sin(t * 1.4)
	add(p, "Root", -0.06 + breath * 0.025, 0, 0, breath * 0.05, w)
	add(
		p,
		"Neck",
		0.1 + math.noise(t * 0.3, 1) * 0.25,
		math.noise(t * 0.25, 2) * 0.6,
		math.noise(t * 0.2, 3) * 0.35,
		0,
		w
	)
	add(p, "LeftShoulder", 0.05 + math.sin(t * 0.9) * 0.04, 0, 0.08, 0, w)
	add(p, "RightShoulder", 0.05 + math.sin(t * 0.9 + 1) * 0.04, 0, -0.08, 0, w)
	-- Fingers-twitch feel: tiny irregular arm jitters.
	add(p, "RightShoulder", math.noise(t * 6, 4) * 0.05, 0, 0, 0, w)
end

local function walk(p: Pose, phase: number, w: number)
	local s = math.sin(phase)
	-- A slow creep: long stride, uneven (one leg drags a little), shoulders roll.
	add(p, "LeftHip", s * 0.6, 0, 0, 0, w)
	add(p, "RightHip", -s * 0.5, 0, 0, 0, w)
	add(p, "LeftShoulder", -s * 0.35, 0, 0.06, 0, w)
	add(p, "RightShoulder", s * 0.35, 0, -0.06, 0, w)
	add(p, "Root", -0.12, s * 0.08, s * 0.04, math.abs(s) * 0.12, w)
	add(p, "Neck", 0.05, -s * 0.1, 0, 0, w)
end

local function run(p: Pose, phase: number, w: number)
	local s = math.sin(phase)
	-- Hunched sprint, arms reaching forward and clawing, head locked on target.
	add(p, "Root", -0.45, s * 0.12, s * 0.06, math.abs(s) * 0.25, w)
	add(p, "Neck", -0.45, 0, 0, 0, w) -- head up, since the torso pitches down
	add(p, "LeftHip", s * 1.0, 0, 0, 0, w)
	add(p, "RightHip", -s * 1.0, 0, 0, 0, w)
	add(p, "LeftShoulder", 1.15 + s * 0.45, 0, 0.18, 0, w)
	add(p, "RightShoulder", 1.15 - s * 0.45, 0, -0.18, 0, w)
end

-- ===== Overlays ====================================================================================

local function listen(p: Pose, t: number, w: number)
	add(p, "Neck", 0.15, 0.35, 0.55 + math.sin(t * 0.8) * 0.05, 0, w) -- cocked head
	add(p, "Root", -0.05, 0, 0.05, 0, w)
	add(p, "RightShoulder", 0.35, 0, -0.35, 0, w) -- hand drifting up
end

local function speak(p: Pose, t: number, w: number)
	-- Irregular nods and jaw-like jerks of the head while it talks.
	local n = math.noise(t * 7, 9)
	add(p, "Neck", n * 0.3, math.noise(t * 3, 10) * 0.2, math.noise(t * 5, 11) * 0.25, 0, w)
	add(p, "Root", n * 0.05, 0, 0, 0, w)
end

local function action(p: Pose, name: string, a: number, t: number)
	-- `a` is 0..1 through the action; envelope rises fast and eases out at the end.
	local env = math.clamp(math.min(a / 0.15, (1 - a) / 0.2), 0, 1)
	if name == "Grab" then
		local lift = math.clamp(a / 0.3, 0, 1)
		add(p, "Root", -0.35 + lift * 0.25, 0, 0, 0.2 * lift, env)
		add(p, "LeftShoulder", 1.7 + lift * 0.3, 0, 0.25, 0, env)
		add(p, "RightShoulder", 1.7 + lift * 0.3, 0, -0.25, 0, env)
		add(p, "Neck", -0.25 + math.noise(t * 12, 5) * 0.2, 0, math.noise(t * 9, 6) * 0.3, 0, env)
	elseif name == "Snuff" then
		add(p, "RightShoulder", 1.3, 0, -0.2, 0, env)
		add(p, "Root", -0.3, 0, 0, -0.3, env)
		add(p, "Neck", 0.5, 0, 0, 0, env)
	elseif name == "Look" then
		add(p, "Neck", 0, math.sin(a * math.pi * 2) * 1.1, 0, 0, env) -- sweeps its head around
	elseif name == "Emerge" then
		-- Unfolds upward from a crouch.
		local up = 1 - a
		add(p, "Root", -0.9 * up, 0, 0, -1.2 * up, 1)
		add(p, "Neck", 0.6 * up, 0, 0, 0, 1)
		add(p, "LeftShoulder", 0.4 * up, 0, 0.4 * up, 0, 1)
		add(p, "RightShoulder", 0.4 * up, 0, -0.4 * up, 0, 1)
	end
end

local function glitchPose(): Pose
	local p = zero()
	for _, j in JOINTS do
		local k = if j == "Neck" then 1.4 else 0.9
		add(p, j, rng:NextNumber(-k, k), rng:NextNumber(-k, k), rng:NextNumber(-k, k), 0)
	end
	return p
end

-- ===== Frame step ==================================================================================

-- Returns the pose to apply this frame (and updates `state`).
function MonsterAnimator.step(state: State, ctx: Context): Pose
	local target = zero()
	local speed = ctx.speed
	local before = state.phase
	state.phase += ctx.dt * (2 + speed * (if speed > 13 then 0.55 else 0.42))
	state.stepped = speed > 1.5 and math.floor(before / math.pi) ~= math.floor(state.phase / math.pi)

	local runW = math.clamp((speed - 11) / 4, 0, 1)
	local walkW = math.clamp(speed / 6, 0, 1) * (1 - runW)
	local idleW = 1 - math.max(walkW, runW)
	idle(target, ctx.time, idleW)
	walk(target, state.phase, walkW)
	run(target, state.phase, runW)

	if ctx.mood == "Alert" and speed < 2 then
		listen(target, ctx.time, 1)
	end
	if ctx.mood == "Dormant" then
		-- Slumped and still.
		add(target, "Root", -0.5, 0, 0, -0.5)
		add(target, "Neck", 0.9, 0, 0.2)
	end
	if ctx.speaking then
		speak(target, ctx.time, 1)
	end

	local snap = false
	if ctx.action == "Vanish" then
		-- Violent glitching: jump to a new random pose every few frames, no smoothing.
		if ctx.time >= state.nextGlitch or not state.glitch then
			state.glitch = glitchPose()
			state.nextGlitch = ctx.time + rng:NextNumber(0.03, 0.09)
		end
		target = state.glitch :: Pose
		snap = true
	elseif ctx.action then
		action(target, ctx.action, ctx.actionAlpha, ctx.time)
	end

	-- Blend toward the target (fast for actions so grabs feel snappy).
	local rate = if ctx.action == "Grab" then 18 elseif ctx.action then 12 else 7
	local alpha = if snap then 1 else 1 - math.exp(-ctx.dt * rate)
	for _, j in JOINTS do
		local c, tj = state.pose[j], target[j]
		c.rx += (tj.rx - c.rx) * alpha
		c.ry += (tj.ry - c.ry) * alpha
		c.rz += (tj.rz - c.rz) * alpha
		c.y += (tj.y - c.y) * alpha
	end
	return state.pose
end

function MonsterAnimator.toCFrame(j: { rx: number, ry: number, rz: number, y: number }): CFrame
	return CFrame.new(0, j.y, 0) * CFrame.Angles(j.rx, j.ry, j.rz)
end

MonsterAnimator.Joints = JOINTS

return MonsterAnimator
