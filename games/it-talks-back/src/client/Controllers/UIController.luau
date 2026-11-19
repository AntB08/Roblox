--!strict
-- UIController: wires the authored HUD.
--   * responsive scale: every UIScale named "Responsive" in the HUD follows the viewport
--     (design canvas 1280x720, touch minimum keeps 64 px buttons >= 44 px)
--   * server toasts (Notify remote) and AnimatedButton juice for every button tagged
--     "AnimatedButton"

local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
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

function UIController:Start()
	local hud = Hud.get()
	trove:Add(AnimatedButton.autoWrapTag("AnimatedButton"))
	bindResponsive(hud)
	trove:Add(Toast.listen(NetClient.event("Notify")))
end

return UIController
