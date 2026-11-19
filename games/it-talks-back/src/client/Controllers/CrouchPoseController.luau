--!strict
-- CrouchPoseController: a real crouch for every crouching player (their "Crouched" attribute is
-- replicated, so each client poses everyone it can see). Layered on top of the default
-- animations after the Animator runs (PreSimulation), so walking while crouched still
-- animates: hips bent forward, knees bent back, torso leaning, whole body lowered.
-- R15 only (the default avatar). R6 characters keep the camera-only crouch.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Assets = require(ReplicatedStorage:WaitForChild("Shared").Config.Assets)

local CROUCH: { [string]: CFrame } = {
	Root = CFrame.new(0, -0.8, 0),
	Waist = CFrame.Angles(-0.35, 0, 0),
	LeftHip = CFrame.Angles(1.0, 0, 0),
	RightHip = CFrame.Angles(1.0, 0, 0),
	LeftKnee = CFrame.Angles(-1.6, 0, 0),
	RightKnee = CFrame.Angles(-1.6, 0, 0),
}
local PARENTS: { [string]: string } = {
	Root = "LowerTorso",
	Waist = "UpperTorso",
	LeftHip = "LeftUpperLeg",
	RightHip = "RightUpperLeg",
	LeftKnee = "LeftLowerLeg",
	RightKnee = "RightLowerLeg",
}
local BLEND_SPEED = 10

local CrouchPoseController = {}

local weights: { [Player]: number } = {}

local function motor(character: Model, joint: string): Motor6D?
	local part = character:FindFirstChild(PARENTS[joint])
	local m = part and part:FindFirstChild(joint)
	return if m and m:IsA("Motor6D") then m else nil
end

-- Published crouch animations (Assets.Animations.Player): the LOCAL player plays them on their
-- own character (character animations replicate), and the procedural pose turns off for all.
local function useTracks(): boolean
	local a = Assets.Animations.Player
	return not Assets.isPlaceholder(a.CrouchIdle) and not Assets.isPlaceholder(a.CrouchWalk)
end

local function runTracks()
	local player = Players.LocalPlayer
	local idle: AnimationTrack? = nil
	local walk: AnimationTrack? = nil
	local function load(character: Model)
		idle, walk = nil, nil
		local humanoid = character:WaitForChild("Humanoid", 10)
		local animator = humanoid and humanoid:WaitForChild("Animator", 10)
		if not animator or not animator:IsA("Animator") then
			return
		end
		local function track(id: string): AnimationTrack
			local anim = Instance.new("Animation")
			anim.AnimationId = id
			local t = animator:LoadAnimation(anim)
			t.Priority = Enum.AnimationPriority.Action -- above the default walk/idle
			return t
		end
		idle = track(Assets.Animations.Player.CrouchIdle)
		walk = track(Assets.Animations.Player.CrouchWalk)
	end
	if player.Character then
		task.spawn(load, player.Character)
	end
	player.CharacterAdded:Connect(load)
	RunService.Heartbeat:Connect(function()
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local i, w = idle, walk
		if not humanoid or not i or not w then
			return
		end
		local crouched = player:GetAttribute("Crouched") == true
		local moving = humanoid.MoveDirection.Magnitude > 0.1
		local wantWalk, wantIdle = crouched and moving, crouched and not moving
		if wantWalk ~= w.IsPlaying then
			if wantWalk then
				w:Play(0.2)
			else
				w:Stop(0.2)
			end
		end
		if wantIdle ~= i.IsPlaying then
			if wantIdle then
				i:Play(0.2)
			else
				i:Stop(0.2)
			end
		end
	end)
end

function CrouchPoseController:Start()
	if useTracks() then
		runTracks()
		return
	end
	Players.PlayerRemoving:Connect(function(p)
		weights[p] = nil
	end)
	RunService.PreSimulation:Connect(function(dt: number)
		for _, p in Players:GetPlayers() do
			local character = p.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if not character or not humanoid or humanoid.RigType ~= Enum.HumanoidRigType.R15 then
				continue
			end
			local want = if p:GetAttribute("Crouched") == true then 1 else 0
			local w = weights[p] or 0
			w += (want - w) * (1 - math.exp(-dt * BLEND_SPEED))
			if w < 0.001 and want == 0 then
				weights[p] = nil
				continue
			end
			weights[p] = w
			for joint, offset in CROUCH do
				local m = motor(character, joint)
				if m then
					m.Transform = m.Transform * CFrame.identity:Lerp(offset, w)
				end
			end
		end
	end)
end

return CrouchPoseController
