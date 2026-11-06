--!strict
-- RewardBurst: layered pickup feedback at a world position (knowledge/05 section 12.2):
-- coin burst + sparkles + flash + fading PointLight + optional sound + optional small shake.
-- Self-contained (emitter recipes inline). Client only. Instances are cleaned up with Debris.
--
--   RewardBurst.Play(position, { count = 24, color = Color3.fromRGB(255, 215, 90),
--                                sound = Assets.Sounds.Collect, big = false })

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Assets = require(ReplicatedStorage:WaitForChild("Shared").Config.Assets)
local CameraShaker = require(script.Parent.CameraShaker)
local Sfx = require(script.Parent.Sfx)

local NS, NSK = NumberSequence.new, NumberSequenceKeypoint.new
local NR = NumberRange.new

export type Options = { count: number?, color: Color3?, sound: string?, big: boolean?, volume: number? }

local MAX_ACTIVE = 12 -- bursts alive at once (mobile budget)
local MAX_DISTANCE = 200 -- skip bursts too far away to matter
local LIFETIME = 2

local RewardBurst = {}
local active = 0

local function emitter(parent: Instance, props: { [string]: any }): ParticleEmitter
	local e = Instance.new("ParticleEmitter")
	e.Enabled = false -- burst only, via :Emit()
	e.Rate = 0
	for key, value in props do
		(e :: any)[key] = value
	end
	e.Parent = parent
	return e
end

function RewardBurst.Play(position: Vector3, opts: Options?)
	local o: Options = opts or {}
	local camera = Workspace.CurrentCamera
	if active >= MAX_ACTIVE or (camera and (camera.CFrame.Position - position).Magnitude > MAX_DISTANCE) then
		return
	end
	active += 1
	task.delay(LIFETIME, function()
		active -= 1
	end)

	local tint = o.color or Color3.fromRGB(255, 215, 90)

	local anchor = Instance.new("Attachment")
	anchor.Name = "RewardBurst"
	anchor.WorldPosition = position
	anchor.Parent = Workspace.Terrain
	Debris:AddItem(anchor, LIFETIME + 1)

	local coinProps: { [string]: any } = {
		EmissionDirection = Enum.NormalId.Top,
		Lifetime = NR(0.6, 0.9),
		Speed = NR(18, 28),
		SpreadAngle = Vector2.new(35, 35),
		Acceleration = Vector3.new(0, -60, 0),
		Drag = 2,
		Size = NS({ NSK(0, 0.6), NSK(0.8, 0.6), NSK(1, 0) }),
		Rotation = NR(0, 360),
		RotSpeed = NR(-360, 360),
		Color = ColorSequence.new(tint),
		LightEmission = 0.3,
		LightInfluence = 0.2,
	}
	if not Assets.isPlaceholder(Assets.Images.CoinIcon) then
		coinProps.Texture = Assets.Images.CoinIcon -- otherwise the engine's default sparkle
	end
	local coins = emitter(anchor, coinProps)

	local sparks = emitter(anchor, {
		Lifetime = NR(0.25, 0.45),
		Speed = NR(12, 20),
		SpreadAngle = Vector2.new(180, 180),
		Drag = 6,
		Size = NS({ NSK(0, 0.35), NSK(1, 0) }),
		Transparency = NS({ NSK(0, 0), NSK(1, 1) }),
		Color = ColorSequence.new(tint),
		LightEmission = 1,
		LightInfluence = 0,
		ZOffset = 1,
	})

	local flash = emitter(anchor, {
		Lifetime = NR(0.12),
		Speed = NR(0),
		Size = NS({ NSK(0, 0), NSK(0.3, 4), NSK(1, 5) }),
		Transparency = NS({ NSK(0, 0.2), NSK(1, 1) }),
		Color = ColorSequence.new(tint),
		LightEmission = 1,
		LightInfluence = 0,
		Brightness = 3,
		ZOffset = 1.5,
	})

	local light = Instance.new("PointLight")
	light.Color = tint
	light.Range = if o.big then 18 else 10
	light.Brightness = if o.big then 6 else 3
	light.Shadows = false
	light.Parent = anchor

	-- Wait one frame after parenting new emitters before Emit (otherwise the first burst can drop).
	RunService.Heartbeat:Once(function()
		local n = o.count or 24
		coins:Emit(n)
		sparks:Emit(math.floor(n * 0.6))
		flash:Emit(1)
		TweenService:Create(light, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Brightness = 0,
		}):Play()
	end)

	if o.sound then
		Sfx.play(o.sound, o.volume or 0.7)
	end
	if o.big then
		CameraShaker.AddTraumaAt(0.25, position, 40)
	end
end

return RewardBurst
