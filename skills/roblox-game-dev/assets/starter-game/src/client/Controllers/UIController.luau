--!strict
-- UIController: wires the authored HUD.
--   * responsive scale: every UIScale named "Responsive" in the HUD follows the viewport
--     (design canvas 1280x720, touch minimum keeps 64 px buttons >= 44 px)
--   * coin counter bound to the player attribute "Coins" (set by the server's DataService),
--     with a pop on change
--   * server toasts (Notify remote) and AnimatedButton juice for every button tagged
--     "AnimatedButton"

local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared.Config.GameConfig)
local Format = require(Shared.Util.Format)
local NetClient = require(Shared.Net.Client)
local Trove = require(Shared.Packages.Trove)

local Client = script.Parent.Parent
local Hud = require(Client.UI.Hud)
local Toast = require(Client.UI.Toast)
local AnimatedButton = require(Client.UI.AnimatedButton)

local REFERENCE_SHORT_SIDE = 720
local MIN_SCALE_TOUCH = 0.8
local MIN_SCALE_OTHER = 0.6
local MAX_SCALE = 1.4
local TV_BOOST = 1.15

local UIController = {}
UIController.Priority = 100

local trove = Trove.new()

local function computeScale(viewport: Vector2): number
	local scale = math.min(viewport.X, viewport.Y) / REFERENCE_SHORT_SIDE
	if GuiService.ViewportDisplaySize == Enum.DisplaySize.Large then
		scale *= TV_BOOST
	end
	local minScale = if UserInputService.PreferredInput == Enum.PreferredInput.Touch
		then MIN_SCALE_TOUCH
		else MIN_SCALE_OTHER
	return math.clamp(scale, minScale, MAX_SCALE)
end

local function bindResponsive(hud: ScreenGui)
	local function apply()
		local viewport = hud.AbsoluteSize
		if viewport.X <= 0 or viewport.Y <= 0 then
			return
		end
		local scale = computeScale(viewport)
		for _, d in hud:GetDescendants() do
			if d:IsA("UIScale") and d.Name == "Responsive" then
				d.Scale = scale
			end
		end
	end
	trove:Connect(hud:GetPropertyChangedSignal("AbsoluteSize"), apply)
	trove:Connect(UserInputService:GetPropertyChangedSignal("PreferredInput"), apply)
	apply()
end

local function bindCoins()
	local player = Players.LocalPlayer
	local amount = Hud.find("LeftStack/CoinsPill/Amount") :: TextLabel
	local pop = amount:FindFirstChild("Pop") :: UIScale?
	local last: number? = nil

	local function render()
		local value = player:GetAttribute(GameConfig.Currency)
		if typeof(value) ~= "number" then
			amount.Text = "…"
			return
		end
		amount.Text = if value >= 100_000 then Format.abbreviate(value) else Format.commas(value)
		if last ~= nil and value > last and pop and not GuiService.ReducedMotionEnabled then
			pop.Scale = 1.25
			TweenService:Create(pop, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Scale = 1,
			}):Play()
		end
		last = value
	end
	trove:Connect(player:GetAttributeChangedSignal(GameConfig.Currency), render)
	render()
end

function UIController:Start()
	local hud = Hud.get()
	trove:Add(AnimatedButton.autoWrapTag("AnimatedButton"))
	bindResponsive(hud)
	bindCoins()
	trove:Add(Toast.listen(NetClient.event("Notify")))
end

return UIController
