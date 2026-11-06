--!strict
-- Toast: top-center notification stack in its own ScreenGui (knowledge/03 section 11.2).
-- Semantic kinds (color + glyph, never color alone), dedupe with "xN", max 3 visible with a queue,
-- tap to dismiss, reduced motion, PreferredTransparency. Small dynamic instances are built in
-- code (toasts are transient); the persistent HUD is authored in src/gui/HUD.model.json.
--
--   Toast.show("Saved!", "success")
--   Toast.show("Daily reward ready", "info", 4)
--   Toast.listen(NetClient.event("Notify"))   -- server: Net.notify(player, text, kind)
-- Text is shown with RichText: pass player-written text through Toast.escape (and it must have
-- been filtered by the server with TextService before reaching any other player).

local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Theme = require(ReplicatedStorage:WaitForChild("Shared").UI.Theme)

export type Kind = "info" | "success" | "warning" | "error"

local STYLE: { [string]: { color: Color3, glyph: string } } = {
	info = { color = Theme.Color.Primary, glyph = "i" },
	success = { color = Theme.Color.Success, glyph = "✓" },
	warning = { color = Theme.Color.Warning, glyph = "!" },
	error = { color = Theme.Color.Danger, glyph = "×" },
}

local MAX_VISIBLE = 3
local DEFAULT_DURATION = 3
local MAX_WIDTH = 440

type Record = {
	key: string,
	text: string,
	count: number,
	frame: CanvasGroup,
	label: TextLabel,
	pop: UIScale,
	token: number,
	closing: boolean,
}
type Pending = { text: string, kind: string, duration: number }

local Toast = {}

local stack: Frame? = nil
local active: { Record } = {}
local pending: { Pending } = {}
local orderCounter = 0

local function motionTime(t: number): number
	return if GuiService.ReducedMotionEnabled then 0 else t
end

function Toast.escape(text: string): string
	local s = string.gsub(text, "&", "&amp;")
	s = string.gsub(s, "<", "&lt;")
	s = string.gsub(s, ">", "&gt;")
	s = string.gsub(s, '"', "&quot;")
	s = string.gsub(s, "'", "&apos;")
	return s
end

local function getStack(): Frame
	if stack and stack.Parent then
		return stack
	end
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	local gui = playerGui:FindFirstChild("ToastGui")
	if not (gui and gui:IsA("ScreenGui")) then
		local newGui = Instance.new("ScreenGui")
		newGui.Name = "ToastGui"
		newGui.ResetOnSpawn = false
		newGui.DisplayOrder = 100
		newGui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
		newGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
		newGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		newGui.Parent = playerGui
		gui = newGui
	end

	local frame = Instance.new("Frame")
	frame.Name = "Stack"
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Position = UDim2.new(0.5, 0, 0, Theme.Space.md)
	frame.Size = UDim2.new(0.92, 0, 0, 0)
	frame.AutomaticSize = Enum.AutomaticSize.Y
	frame.BackgroundTransparency = 1

	local sizeLimit = Instance.new("UISizeConstraint")
	sizeLimit.MaxSize = Vector2.new(MAX_WIDTH, math.huge)
	sizeLimit.Parent = frame

	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Vertical
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, Theme.Space.sm)
	list.Parent = frame

	frame.Parent = gui
	stack = frame
	return frame
end

local function buildToast(kind: string): (CanvasGroup, TextLabel, UIScale)
	local style = STYLE[kind] or STYLE.info

	local frame = Instance.new("CanvasGroup")
	frame.Name = "Toast"
	frame.Size = UDim2.new(1, 0, 0, 0)
	frame.AutomaticSize = Enum.AutomaticSize.Y
	frame.BackgroundColor3 = Theme.Color.SurfaceRaised
	frame.BackgroundTransparency = 0.06 * GuiService.PreferredTransparency
	frame.GroupTransparency = 1
	frame.Active = true -- receives InputBegan for tap-to-dismiss

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.BorderStrokePosition = Enum.BorderStrokePosition.Inner -- CanvasGroup clips outer strokes
	stroke.Color = style.color
	stroke.Thickness = 2
	stroke.Transparency = 0.35
	stroke.Parent = frame

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, Theme.Space.md)
	padding.PaddingBottom = UDim.new(0, Theme.Space.md)
	padding.PaddingLeft = UDim.new(0, 56) -- 16 margin + 28 icon + 12 gap
	padding.PaddingRight = UDim.new(0, Theme.Space.lg)
	padding.Parent = frame

	local icon = Instance.new("TextLabel")
	icon.Name = "Icon"
	icon.Size = UDim2.fromOffset(28, 28)
	icon.Position = UDim2.fromOffset(-40, -3) -- sits inside the left padding
	icon.BackgroundColor3 = style.color
	icon.Text = style.glyph
	icon.FontFace = Theme.Font.Heavy
	icon.TextSize = Theme.TextSize.body
	icon.TextColor3 = Theme.Color.TextOnAccent
	icon.Parent = frame
	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = Theme.Radius.pill
	iconCorner.Parent = icon

	local label = Instance.new("TextLabel")
	label.Name = "Message"
	label.Size = UDim2.new(1, 0, 0, 0)
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.BackgroundTransparency = 1
	label.RichText = true
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.FontFace = Theme.Font.Medium
	label.TextSize = Theme.TextSize.body
	label.LineHeight = 1.1
	label.TextColor3 = Theme.Color.Text
	label.Parent = frame

	local pop = Instance.new("UIScale")
	pop.Scale = if GuiService.ReducedMotionEnabled then 1 else 0.9
	pop.Parent = frame

	return frame, label, pop
end

local close: (record: Record) -> ()
local open: (text: string, kind: string, duration: number) -> ()

local function schedule(record: Record, duration: number)
	record.token += 1
	local myToken = record.token
	task.delay(duration, function()
		if record.token == myToken and not record.closing then
			close(record)
		end
	end)
end

close = function(record: Record)
	if record.closing then
		return
	end
	record.closing = true
	local info = TweenInfo.new(motionTime(0.18), Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	TweenService:Create(record.pop, info, { Scale = if GuiService.ReducedMotionEnabled then 1 else 0.95 }):Play()
	local fade = TweenService:Create(record.frame, info, { GroupTransparency = 1 })
	fade.Completed:Once(function()
		record.frame:Destroy()
		local index = table.find(active, record)
		if index then
			table.remove(active, index)
		end
		local nextItem = table.remove(pending, 1)
		if nextItem then
			open(nextItem.text, nextItem.kind, nextItem.duration)
		end
	end)
	fade:Play()
end

open = function(text: string, kind: string, duration: number)
	local frame, label, pop = buildToast(kind)
	orderCounter += 1
	frame.LayoutOrder = orderCounter -- newest at the bottom of the stack
	label.Text = text

	local record: Record = {
		key = kind .. "|" .. text,
		text = text,
		count = 1,
		frame = frame,
		label = label,
		pop = pop,
		token = 0,
		closing = false,
	}
	table.insert(active, record)

	frame.InputBegan:Connect(function(input: InputObject)
		local t = input.UserInputType
		if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
			close(record)
		end
	end)

	frame.Parent = getStack()
	TweenService:Create(frame, TweenInfo.new(motionTime(0.2), Enum.EasingStyle.Quad), { GroupTransparency = 0 }):Play()
	TweenService
		:Create(pop, TweenInfo.new(motionTime(0.3), Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
		:Play()
	schedule(record, duration)
end

function Toast.show(text: string, kind: Kind?, duration: number?)
	local k: string = if kind and STYLE[kind] then kind else "info"
	local d = duration or DEFAULT_DURATION
	local key = k .. "|" .. text

	for _, record in active do
		if record.key == key and not record.closing then
			record.count += 1
			record.label.Text = `{text}  <font transparency="0.35">×{record.count}</font>`
			if not GuiService.ReducedMotionEnabled then
				record.pop.Scale = 1.05
				TweenService:Create(record.pop, TweenInfo.new(0.25, Enum.EasingStyle.Back), { Scale = 1 }):Play()
			end
			schedule(record, d)
			return
		end
	end

	if #active >= MAX_VISIBLE then
		for _, item in pending do
			if item.kind == k and item.text == text then
				return
			end
		end
		table.insert(pending, { text = text, kind = k, duration = d })
		return
	end
	open(text, k, d)
end

function Toast.clear()
	table.clear(pending)
	for _, record in table.clone(active) do
		close(record)
	end
end

-- Server -> client toasts. Validates the payload (the server is trusted, but be defensive).
function Toast.listen(remote: RemoteEvent): RBXScriptConnection
	return remote.OnClientEvent:Connect(function(text: unknown, kind: unknown, duration: unknown)
		if typeof(text) ~= "string" then
			return
		end
		local k = if typeof(kind) == "string" and STYLE[kind] then kind else "info"
		local d = if typeof(duration) == "number" then math.clamp(duration, 1, 10) else nil
		Toast.show(text, k :: Kind, d)
	end)
end

return Toast
