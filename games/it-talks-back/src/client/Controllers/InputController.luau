--!strict
-- InputController: sprint / crouch / flashlight / callouts / leave-closet on every input type.
--   Keyboard: Shift (hold) run, C crouch, F light, 1-4 callouts
--   Gamepad:  L3 (hold) run, B crouch, Y light, DPad Up/Right/Down/Left callouts
--   Touch:    the HUD buttons (Actions/*, Callouts/*)
-- It sends intent only; the server decides speed, stamina and what the light does.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local NetClient = require(Shared.Net.Client)
local HorrorConfig = require(Shared.Config.HorrorConfig)

local Client = script.Parent.Parent
local Hud = require(Client.UI.Hud)
local Toast = require(Client.UI.Toast)

local player = Players.LocalPlayer

local CROUCH_OFFSET = Vector3.new(0, -1.6, 0)
local ACTIVE_COLOR = Color3.fromRGB(150, 30, 25)
local IDLE_COLOR = Color3.fromRGB(14, 13, 15)

local KEY_CALLOUTS: { [Enum.KeyCode]: number } = {
	[Enum.KeyCode.One] = 1,
	[Enum.KeyCode.Two] = 2,
	[Enum.KeyCode.Three] = 3,
	[Enum.KeyCode.Four] = 4,
	[Enum.KeyCode.DPadUp] = 1,
	[Enum.KeyCode.DPadRight] = 2,
	[Enum.KeyCode.DPadDown] = 3,
	[Enum.KeyCode.DPadLeft] = 4,
}

local InputController = {}

local sprinting = false
local crouched = false
local lit = false
local lastCallout = -math.huge

local function setButtonActive(button: GuiButton, on: boolean)
	button.BackgroundColor3 = if on then ACTIVE_COLOR else IDLE_COLOR
end

local function setCameraOffset(offset: Vector3)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		TweenService:Create(humanoid, TweenInfo.new(0.2), { CameraOffset = offset }):Play()
	end
end

function InputController.setSprint(on: boolean)
	if sprinting == on then
		return
	end
	sprinting = on
	NetClient.event("SetSprint"):FireServer(on)
	setButtonActive(Hud.find("Actions/SprintButton") :: GuiButton, on)
end

function InputController.setCrouch(on: boolean)
	if player:GetAttribute("Status") ~= "Alive" then
		on = false
	end
	crouched = on
	NetClient.event("SetCrouch"):FireServer(on)
	setCameraOffset(if on then CROUCH_OFFSET else Vector3.zero)
	setButtonActive(Hud.find("Actions/CrouchButton") :: GuiButton, on)
end

function InputController.setLight(on: boolean)
	lit = on
	NetClient.event("SetFlashlight"):FireServer(on)
	setButtonActive(Hud.find("Actions/LightButton") :: GuiButton, on)
end

local function callout(index: number)
	local room = HorrorConfig.Callouts[index]
	local status = player:GetAttribute("Status")
	if not room or (status ~= "Alive" and status ~= "Hidden" and status ~= "Caged") then
		return
	end
	local now = os.clock()
	if now - lastCallout < HorrorConfig.CalloutCooldown then
		Toast.show(`Catch your breath ({math.ceil(HorrorConfig.CalloutCooldown - (now - lastCallout))}s)`, "info", 1.5)
		return
	end
	lastCallout = now
	NetClient.event("Callout"):FireServer(room)
end

local function refreshInputHints()
	local touch = UserInputService.PreferredInput == Enum.PreferredInput.Touch
	local gamepad = UserInputService.PreferredInput == Enum.PreferredInput.Gamepad
	local actions = Hud.find("Actions") :: Frame
	actions.Visible = true
	local keys: { [string]: string } = {
		SprintButton = if gamepad then "L3" else "Shift",
		CrouchButton = if gamepad then "B" else "C",
		LightButton = if gamepad then "Y" else "F",
	}
	for name, key in keys do
		local button = actions:FindFirstChild(name)
		local hint = button and button:FindFirstChild("KeyHint")
		if hint and hint:IsA("TextLabel") then
			hint.Text = key
			hint.Visible = not touch
		end
	end
	local panel = Hud.find("Callouts") :: Frame
	local gamepadKeys = { "Up", "Right", "Down", "Left" }
	for i, room in HorrorConfig.Callouts do
		local button = panel:FindFirstChild(`Callout{room}`)
		local hint = button and button:FindFirstChild("KeyHint")
		if hint and hint:IsA("TextLabel") then
			hint.Text = if gamepad then gamepadKeys[i] else tostring(i)
			hint.Visible = not touch
		end
	end
end

local function bindButtons()
	local sprintButton = Hud.find("Actions/SprintButton") :: GuiButton
	-- Hold to run on touch: press = on, release = off.
	sprintButton.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1
		then
			InputController.setSprint(true)
		end
	end)
	sprintButton.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1
		then
			InputController.setSprint(false)
		end
	end)
	local crouchButton = Hud.find("Actions/CrouchButton") :: GuiButton
	crouchButton.Activated:Connect(function()
		InputController.setCrouch(not crouched)
	end)
	local lightButton = Hud.find("Actions/LightButton") :: GuiButton
	lightButton.Activated:Connect(function()
		InputController.setLight(not lit)
	end)

	local panel = Hud.find("Callouts") :: Frame
	local open = false
	local toggle = Hud.find("Callouts/CalloutToggle") :: GuiButton
	local function setOpen(v: boolean)
		open = v
		for _, room in HorrorConfig.Callouts do
			local b = panel:FindFirstChild(`Callout{room}`)
			if b and b:IsA("GuiButton") then
				b.Visible = v
			end
		end
	end
	toggle.Activated:Connect(function()
		setOpen(not open)
	end)
	for i, room in HorrorConfig.Callouts do
		local b = panel:FindFirstChild(`Callout{room}`)
		if b and b:IsA("GuiButton") then
			b.Activated:Connect(function()
				callout(i)
				if UserInputService.PreferredInput == Enum.PreferredInput.Touch then
					setOpen(false) -- touch: collapse the menu again; keyboard keeps the list
				end
			end)
		end
	end
	-- Keyboard/gamepad players see the room list permanently (keys 1-4).
	local function syncOpen()
		setOpen(UserInputService.PreferredInput ~= Enum.PreferredInput.Touch)
	end
	UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(syncOpen)
	syncOpen()

	local leaveButton = Hud.find("Top/StatusBanner/LeaveButton") :: GuiButton
	leaveButton.Activated:Connect(function()
		NetClient.event("LeaveHide"):FireServer()
	end)
end

function InputController:Start()
	bindButtons()
	refreshInputHints()
	UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(refreshInputHints)

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end
		local key = input.KeyCode
		if key == Enum.KeyCode.LeftShift or key == Enum.KeyCode.RightShift or key == Enum.KeyCode.ButtonL3 then
			InputController.setSprint(true)
		elseif key == Enum.KeyCode.C or key == Enum.KeyCode.ButtonB then
			InputController.setCrouch(not crouched)
		elseif key == Enum.KeyCode.F or key == Enum.KeyCode.ButtonY then
			InputController.setLight(not lit)
		elseif KEY_CALLOUTS[key] then
			callout(KEY_CALLOUTS[key])
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		local key = input.KeyCode
		if key == Enum.KeyCode.LeftShift or key == Enum.KeyCode.RightShift or key == Enum.KeyCode.ButtonL3 then
			InputController.setSprint(false)
		end
	end)

	-- Server-side resets (caught, hidden, new round) clear crouch; mirror it locally.
	player:GetAttributeChangedSignal("Crouched"):Connect(function()
		local on = player:GetAttribute("Crouched") == true
		if on ~= crouched then
			crouched = on
			setCameraOffset(if on then CROUCH_OFFSET else Vector3.zero)
			setButtonActive(Hud.find("Actions/CrouchButton") :: GuiButton, on)
		end
	end)
	player:GetAttributeChangedSignal("Flashlight"):Connect(function()
		lit = player:GetAttribute("Flashlight") == true
		setButtonActive(Hud.find("Actions/LightButton") :: GuiButton, lit)
	end)
	player.CharacterAdded:Connect(function()
		crouched = false
		sprinting = false
		task.defer(function()
			setButtonActive(Hud.find("Actions/CrouchButton") :: GuiButton, false)
			setButtonActive(Hud.find("Actions/SprintButton") :: GuiButton, false)
		end)
	end)
end

return InputController
