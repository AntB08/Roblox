--!strict
-- AnimatedButton: adds juice to an EXISTING, authored GuiButton (knowledge/03 section 11.1).
-- Hover (mouse), press (mouse/touch), gamepad selection treated as hover, click cooldown, click
-- sound, reduced motion, enabled/disabled state. Uses a child UIScale, never Size, so it is safe
-- inside UIListLayout/UIGridLayout.
--
--   local btn = AnimatedButton.wrap(hud.Menu.CodesButton, { onActivated = function() ... end })
--   btn:SetEnabled(false)
--   AnimatedButton.autoWrapTag("AnimatedButton")   -- every tagged button in PlayerGui

local CollectionService = game:GetService("CollectionService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Assets = require(ReplicatedStorage:WaitForChild("Shared").Config.Assets)
local Sfx = require(script.Parent.Parent.FX.Sfx)

export type Options = {
	hoverScale: number?,
	pressScale: number?,
	cooldown: number?,
	clickSound: string?, -- asset id; defaults to Assets.Sounds.Click; "" for silent
	onActivated: ((input: InputObject?) -> ())?,
}

local DEFAULT_HOVER = 1.06
local DEFAULT_PRESS = 0.92
local DEFAULT_COOLDOWN = 0.15

local HOVER_INFO = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local PRESS_INFO = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local RELEASE_INFO = TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local AnimatedButton = {}
AnimatedButton.__index = AnimatedButton

type Fields = {
	button: GuiButton,
	scale: UIScale,
	options: Options,
	connections: { RBXScriptConnection },
	selected: boolean,
	enabled: boolean,
	pressed: boolean,
	lastActivated: number,
	baseColor: Color3,
	tween: Tween?,
}
export type AnimatedButton = typeof(setmetatable({} :: Fields, AnimatedButton))

local registry: { [GuiButton]: AnimatedButton } = {}

local function getAnimScale(button: GuiButton): UIScale
	local existing = button:FindFirstChild("AnimScale")
	if existing and existing:IsA("UIScale") then
		return existing
	end
	local scale = Instance.new("UIScale")
	scale.Name = "AnimScale"
	scale.Parent = button
	return scale
end

function AnimatedButton.wrap(button: GuiButton, options: Options?): AnimatedButton
	local existing = registry[button]
	if existing then
		if options and options.onActivated then
			existing.options.onActivated = options.onActivated
		end
		return existing
	end

	local self = setmetatable(
		{
			button = button,
			scale = getAnimScale(button),
			options = options or {},
			connections = {},
			selected = false,
			enabled = button.Interactable,
			pressed = false,
			lastActivated = 0,
			baseColor = button.BackgroundColor3,
			tween = nil,
		} :: Fields,
		AnimatedButton
	)
	registry[button] = self

	button.AutoButtonColor = false -- we provide our own feedback

	table.insert(
		self.connections,
		button:GetPropertyChangedSignal("GuiState"):Connect(function()
			self:_refresh()
		end)
	)
	table.insert(
		self.connections,
		button.SelectionGained:Connect(function()
			self.selected = true
			self:_refresh()
		end)
	)
	table.insert(
		self.connections,
		button.SelectionLost:Connect(function()
			self.selected = false
			self:_refresh()
		end)
	)
	table.insert(
		self.connections,
		button.Activated:Connect(function(input: InputObject?)
			self:_onActivated(input)
		end)
	)
	table.insert(
		self.connections,
		button.Destroying:Connect(function()
			self:Destroy()
		end)
	)

	return self
end

function AnimatedButton._tweenScale(self: AnimatedButton, target: number, info: TweenInfo)
	if self.tween then
		self.tween:Cancel()
		self.tween = nil
	end
	if GuiService.ReducedMotionEnabled then
		self.scale.Scale = 1 -- no scale motion; color feedback still applies
		return
	end
	local tween = TweenService:Create(self.scale, info, { Scale = target })
	self.tween = tween
	tween:Play()
end

function AnimatedButton._refresh(self: AnimatedButton)
	local button = self.button
	if not self.enabled then
		self.pressed = false
		self:_tweenScale(1, HOVER_INFO)
		return
	end

	local state = button.GuiState
	local hoverScale = self.options.hoverScale or DEFAULT_HOVER
	local pressScale = self.options.pressScale or DEFAULT_PRESS

	if state == Enum.GuiState.Press then
		self.pressed = true
		button.BackgroundColor3 = self.baseColor:Lerp(Color3.new(0, 0, 0), 0.15)
		self:_tweenScale(pressScale, PRESS_INFO)
		return
	end

	button.BackgroundColor3 = self.baseColor
	local wasPressed = self.pressed
	self.pressed = false
	local hovered = state == Enum.GuiState.Hover or self.selected
	self:_tweenScale(if hovered then hoverScale else 1, if wasPressed then RELEASE_INFO else HOVER_INFO)
end

function AnimatedButton._onActivated(self: AnimatedButton, input: InputObject?)
	if not self.enabled then
		return
	end
	local now = os.clock()
	if now - self.lastActivated < (self.options.cooldown or DEFAULT_COOLDOWN) then
		return
	end
	self.lastActivated = now

	local sound = self.options.clickSound
	if sound == nil then
		sound = Assets.Sounds.Click
	end
	if sound ~= "" then
		Sfx.play(sound, 0.5)
	end

	-- Gamepad/keyboard activation never enters Press, so give a quick pulse.
	if self.button.GuiState ~= Enum.GuiState.Press and not GuiService.ReducedMotionEnabled then
		self.scale.Scale = self.options.pressScale or DEFAULT_PRESS
		self:_tweenScale(if self.selected then (self.options.hoverScale or DEFAULT_HOVER) else 1, RELEASE_INFO)
	end

	local callback = self.options.onActivated
	if callback then
		task.spawn(callback, input)
	end
end

function AnimatedButton.SetEnabled(self: AnimatedButton, enabled: boolean)
	if self.enabled == enabled then
		return
	end
	self.enabled = enabled
	self.button.Interactable = enabled
	self.button.BackgroundColor3 = if enabled
		then self.baseColor
		else self.baseColor:Lerp(Color3.fromRGB(80, 80, 80), 0.65)
	self:_refresh()
end

function AnimatedButton.SetBaseColor(self: AnimatedButton, color: Color3)
	self.baseColor = color
	if self.enabled then
		self.button.BackgroundColor3 = color
	end
end

function AnimatedButton.OnActivated(self: AnimatedButton, callback: (input: InputObject?) -> ())
	self.options.onActivated = callback
end

function AnimatedButton.Destroy(self: AnimatedButton)
	for _, connection in self.connections do
		connection:Disconnect()
	end
	table.clear(self.connections)
	if self.tween then
		self.tween:Cancel()
		self.tween = nil
	end
	registry[self.button] = nil
end

function AnimatedButton.get(button: GuiButton): AnimatedButton?
	return registry[button]
end

-- Wraps every GuiButton with this CollectionService tag that lives in the local PlayerGui.
function AnimatedButton.autoWrapTag(tag: string, options: Options?): RBXScriptConnection
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local function tryWrap(instance: Instance)
		if instance:IsA("GuiButton") and instance:IsDescendantOf(playerGui) then
			AnimatedButton.wrap(instance, if options then table.clone(options) else nil)
		end
	end
	for _, instance in CollectionService:GetTagged(tag) do
		tryWrap(instance)
	end
	return CollectionService:GetInstanceAddedSignal(tag):Connect(function(instance: Instance)
		task.defer(tryWrap, instance) -- ScreenGuis are cloned into PlayerGui; let ancestry settle
	end)
end

return AnimatedButton
