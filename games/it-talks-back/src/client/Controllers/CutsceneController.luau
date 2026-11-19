--!strict
-- CutsceneController: short camera sequences (client only, never block gameplay logic).
--   * Night intro (round start, inside players): exterior pan of the house -> slow dolly down the
--     hallway -> close-up of the monster's face as its eyes flare. Skippable. Ends before the
--     monster wakes (HorrorConfig.Round.StartGrace), so nobody loses time.
--   * Catch (the victim only): face-to-face with it during the grab, then the cage.
--   * Escape (the escaper only): a shot of the house from outside the gate.
-- Letterbox bars and the title live in the authored Overlay GUI.

local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local NetClient = require(Shared.Net.Client)

local Client = script.Parent.Parent
local CameraShaker = require(Client.FX.CameraShaker)

local player = Players.LocalPlayer

local BAR = 0.11 -- letterbox bar height (fraction of the screen)

type Shot = { from: CFrame, to: CFrame, seconds: number, fov: number?, onStart: (() -> ())? }

local CutsceneController = {}

local playing = 0 -- token; increments to cancel
local skipRequested = false

local function overlay(): ScreenGui?
	local gui = player:WaitForChild("PlayerGui"):FindFirstChild("Overlay")
	return if gui and gui:IsA("ScreenGui") then gui else nil
end

local function bars(show: boolean)
	local gui = overlay()
	if not gui then
		return
	end
	local info = TweenInfo.new(if GuiService.ReducedMotionEnabled then 0 else 0.45, Enum.EasingStyle.Quad)
	for _, name in { "LetterTop", "LetterBottom" } do
		local f = gui:FindFirstChild(name)
		if f and f:IsA("Frame") then
			TweenService:Create(f, info, { Size = UDim2.fromScale(1, if show then BAR else 0) }):Play()
		end
	end
end

local function title(text: string, seconds: number)
	local gui = overlay()
	local label = gui and gui:FindFirstChild("CutTitle")
	if not label or not label:IsA("TextLabel") then
		return
	end
	label.Text = text
	label.TextTransparency = 1
	TweenService:Create(label, TweenInfo.new(0.6), { TextTransparency = 0 }):Play()
	task.delay(seconds, function()
		if label.Text == text then
			TweenService:Create(label, TweenInfo.new(0.6), { TextTransparency = 1 }):Play()
		end
	end)
end

local function setSkipHint(on: boolean)
	local gui = overlay()
	local hint = gui and gui:FindFirstChild("SkipHint")
	if hint and hint:IsA("TextLabel") then
		hint.Visible = on
	end
end

local function hudVisible(on: boolean)
	local hud = player:WaitForChild("PlayerGui"):FindFirstChild("HUD")
	if hud and hud:IsA("ScreenGui") then
		hud.Enabled = on
	end
end

local function restore(camera: Camera, fov: number)
	camera.CameraType = Enum.CameraType.Custom
	camera.FieldOfView = fov
	bars(false)
	setSkipHint(false)
	hudVisible(true)
end

-- Plays shots in order. Returns when done or cancelled/skipped.
local function play(shots: { Shot }, skippable: boolean)
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	playing += 1
	local token = playing
	skipRequested = false
	local baseFov = camera.FieldOfView
	camera.CameraType = Enum.CameraType.Scriptable
	bars(true)
	hudVisible(false)
	setSkipHint(skippable)
	for _, shot in shots do
		if token ~= playing or (skippable and skipRequested) then
			break
		end
		camera.CFrame = shot.from
		camera.FieldOfView = shot.fov or 60
		if shot.onStart then
			task.spawn(shot.onStart)
		end
		local seconds = if GuiService.ReducedMotionEnabled then shot.seconds * 0.6 else shot.seconds
		local tween = TweenService:Create(
			camera,
			TweenInfo.new(seconds, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{ CFrame = shot.to }
		)
		tween:Play()
		local started = os.clock()
		while os.clock() - started < seconds do
			if token ~= playing or (skippable and skipRequested) then
				tween:Cancel()
				break
			end
			task.wait()
		end
	end
	if token == playing then
		restore(camera, baseFov)
	end
end

local function monsterHead(): BasePart?
	for _, m in CollectionService:GetTagged("Monster") do
		local h = m:FindFirstChild("Head")
		if h and h:IsA("BasePart") then
			return h
		end
	end
	return nil
end

local function flareEyes()
	for _, m in CollectionService:GetTagged("Monster") do
		for _, d in m:GetChildren() do
			if d:IsA("BasePart") and d:HasTag("MonsterEye") then
				TweenService:Create(d, TweenInfo.new(0.8), { Color = Color3.fromRGB(255, 50, 35) }):Play()
			end
		end
		local glow = m:FindFirstChild("Head") and (m :: any).Head:FindFirstChild("EyeGlow")
		if glow and glow:IsA("PointLight") then
			TweenService:Create(glow, TweenInfo.new(0.8), { Brightness = 2, Color = Color3.fromRGB(255, 50, 35) })
				:Play()
		end
	end
end

local function nightIntro()
	local night = tonumber(Workspace:GetAttribute("Night")) or 1
	local head = monsterHead()
	local shots: { Shot } = {
		{
			-- Outside: slow pan across the front of the house.
			from = CFrame.lookAt(Vector3.new(-34, 9, 46), Vector3.new(0, 7, 10)),
			to = CFrame.lookAt(Vector3.new(30, 11, 44), Vector3.new(0, 7, 10)),
			seconds = 2.4,
			fov = 55,
			onStart = function()
				title(`NIGHT {night}`, 3.5)
			end,
		},
		{
			-- Inside: creep down the hallway toward the generator.
			from = CFrame.lookAt(Vector3.new(0, 6.5, 17), Vector3.new(0, 5, -30)),
			to = CFrame.lookAt(Vector3.new(0, 5.5, -2), Vector3.new(0, 4.5, -30)),
			seconds = 2.2,
			fov = 65,
		},
	}
	if head then
		local face = head.CFrame
		table.insert(shots, {
			-- Its face, eyes flaring.
			from = CFrame.lookAt((face * CFrame.new(0.6, 0.2, -6)).Position, face.Position),
			to = CFrame.lookAt((face * CFrame.new(0, 0, -2.6)).Position, face.Position),
			seconds = 1.8,
			fov = 45,
			onStart = flareEyes,
		})
	end
	play(shots, true)
end

local function catchScene()
	local head = monsterHead()
	if not head then
		return
	end
	local face = head.CFrame
	CameraShaker.AddTrauma(1)
	-- You're being held right in front of it: hide your own body so the camera sees its face.
	local character = player.Character
	local function setSelfHidden(hidden: boolean)
		if character then
			for _, d in character:GetDescendants() do
				if d:IsA("BasePart") or d:IsA("Decal") then
					(d :: any).LocalTransparencyModifier = if hidden then 1 else 0
				end
			end
		end
	end
	setSelfHidden(true)
	task.delay(1.5, setSelfHidden, false)
	play({
		{
			from = CFrame.lookAt((face * CFrame.new(0, -0.2, -2.2)).Position, face.Position),
			to = CFrame.lookAt((face * CFrame.new(0, 0, -1.5)).Position, face.Position),
			seconds = 1.4,
			fov = 50,
		},
	}, false)
end

local function escapeScene()
	title("ESCAPED", 2.2)
	play({
		{
			from = CFrame.lookAt(Vector3.new(-10, 4, -70), Vector3.new(0, 6, -40)),
			to = CFrame.lookAt(Vector3.new(10, 9, -62), Vector3.new(0, 6, -40)),
			seconds = 2.6,
			fov = 60,
		},
	}, true)
end

function CutsceneController:Start()
	UserInputService.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.Keyboard
			or input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Gamepad1
		then
			skipRequested = true
		end
	end)

	local lastStatus = player:GetAttribute("Status")
	player:GetAttributeChangedSignal("Status"):Connect(function()
		local status = player:GetAttribute("Status")
		if status == "Alive" and lastStatus == "Lobby" and Workspace:GetAttribute("RoundState") == "Playing" then
			task.spawn(nightIntro)
		elseif status == "Escaped" then
			task.spawn(escapeScene)
		end
		lastStatus = status
	end)
	NetClient.event("Caught").OnClientEvent:Connect(function(_name: string, isYou: boolean)
		if isYou then
			task.spawn(catchScene)
		end
	end)
end

return CutsceneController
