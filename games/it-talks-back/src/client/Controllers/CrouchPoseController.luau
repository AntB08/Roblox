--!strict
-- CrouchPoseController: a real crouch for every crouching player (their "Crouched" attribute is
-- replicated, so each client poses everyone it can see). Layered on top of the default
-- animations after the Animator runs (PreSimulation), so walking while crouched still
-- animates: hips bent forward, knees bent back, torso leaning, whole body lowered.
-- R15 only (the default avatar). R6 characters keep the camera-only crouch.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

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

function CrouchPoseController:Start()
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
