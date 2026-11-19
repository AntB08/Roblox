--!strict
-- CameraShaker: trauma model + Perlin noise (knowledge/05 section 12.1). Client only.
-- Removes last frame's offset BEFORE the default camera runs and adds the new one AFTER, so the
-- shake is purely additive and never fights player input.
--
--   CameraShaker.AddTrauma(0.4)                       -- one-shot
--   CameraShaker.AddTraumaAt(0.8, explosionPos, 60)   -- distance-attenuated
--   CameraShaker.SetSustained("earthquake", 0.35)     -- sustained floor; 0 clears
--   CameraShaker.SetIntensity(0.5)                    -- player setting 0..1
-- Respects GuiService.ReducedMotionEnabled (shake reduced to 25%).

local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local MAX_PITCH = math.rad(3.5)
local MAX_YAW = math.rad(3.5)
local MAX_ROLL = math.rad(2)
local MAX_OFFSET = Vector3.new(0.25, 0.25, 0.15)
local FREQUENCY = 16 -- noise samples per second: 12-25 impacts, 3-6 rumbles
local DECAY = 1.1 -- trauma lost per second

local CameraShaker = {}

local trauma = 0
local intensity = 1
local sustained: { [string]: number } = {}
local seed = math.random() * 1000
local lastOffset = CFrame.identity
local started = false

local function clamp01(x: number): number
	return math.clamp(x, 0, 1)
end

local function sustainedFloor(): number
	local m = 0
	for _, v in sustained do
		m = math.max(m, v)
	end
	return m
end

local function noise(channel: number, t: number): number
	return math.clamp(math.noise(seed + channel * 17.31, t * FREQUENCY, 0) * 2, -1, 1)
end

local function undo()
	local camera = Workspace.CurrentCamera
	if camera and lastOffset ~= CFrame.identity then
		camera.CFrame = camera.CFrame * lastOffset:Inverse()
	end
	lastOffset = CFrame.identity
end

local function apply(dt: number)
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	trauma = math.max(0, trauma - DECAY * dt)
	local level = math.max(trauma, sustainedFloor())
	if level <= 0 then
		return
	end
	local scale = intensity * (if GuiService.ReducedMotionEnabled then 0.25 else 1)
	local shake = level * level * scale
	local t = os.clock()
	local pitch = MAX_PITCH * shake * noise(1, t)
	local yaw = MAX_YAW * shake * noise(2, t)
	local roll = MAX_ROLL * shake * noise(3, t)
	local offset = Vector3.new(
		MAX_OFFSET.X * shake * noise(4, t),
		MAX_OFFSET.Y * shake * noise(5, t),
		MAX_OFFSET.Z * shake * noise(6, t)
	)
	lastOffset = CFrame.new(offset) * CFrame.Angles(pitch, yaw, roll)
	camera.CFrame = camera.CFrame * lastOffset
end

function CameraShaker.Start()
	if started then
		return
	end
	started = true
	RunService:BindToRenderStep("CameraShaker_Undo", Enum.RenderPriority.Camera.Value - 1, undo)
	RunService:BindToRenderStep("CameraShaker_Apply", Enum.RenderPriority.Camera.Value + 1, apply)
end

function CameraShaker.Stop()
	if not started then
		return
	end
	started = false
	RunService:UnbindFromRenderStep("CameraShaker_Undo")
	RunService:UnbindFromRenderStep("CameraShaker_Apply")
	undo()
	trauma = 0
	table.clear(sustained)
end

function CameraShaker.AddTrauma(amount: number)
	CameraShaker.Start()
	trauma = clamp01(trauma + amount)
end

function CameraShaker.AddTraumaAt(amount: number, position: Vector3, radius: number)
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	local d = (camera.CFrame.Position - position).Magnitude
	local falloff = clamp01(1 - d / radius)
	if falloff > 0 then
		CameraShaker.AddTrauma(amount * falloff)
	end
end

function CameraShaker.SetSustained(key: string, level: number)
	CameraShaker.Start()
	sustained[key] = if level > 0 then clamp01(level) else nil
end

function CameraShaker.SetIntensity(value: number)
	intensity = clamp01(value)
end

function CameraShaker.GetTrauma(): number
	return trauma
end

return CameraShaker
