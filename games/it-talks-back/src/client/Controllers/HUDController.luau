--!strict
-- HUDController: binds the authored HUD to replicated state. Reads only attributes and
-- remotes; it never decides anything.
--   Top/ObjectivePill   what to do now + round/intermission timer
--   Top/StatusBanner    hiding / caged / escaped / spectating (+ Leave button while hiding)
--   Center              big round messages (RoundMessage remote)
--   Bottom/Stamina      sprint stamina (player attribute "Stamina")
-- Also shows "X was caught" toasts and the red flash for the victim (Caught remote).

local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local NetClient = require(Shared.Net.Client)
local HorrorConfig = require(Shared.Config.HorrorConfig)

local Client = script.Parent.Parent
local Hud = require(Client.UI.Hud)
local Toast = require(Client.UI.Toast)
local CameraShaker = require(Client.FX.CameraShaker)

local player = Players.LocalPlayer

local HUDController = {}

local messageToken = 0

local function formatTime(seconds: number): string
	seconds = math.max(0, math.floor(seconds))
	return string.format("%d:%02d", seconds // 60, seconds % 60)
end

local function overlay(): ScreenGui
	local gui = player:WaitForChild("PlayerGui"):WaitForChild("Overlay", 30)
	assert(gui and gui:IsA("ScreenGui"), "[HUDController] PlayerGui.Overlay missing")
	return gui
end

local function showMessage(title: string, subtitle: string, seconds: number)
	local center = Hud.find("Center") :: Frame
	local titleLabel = Hud.find("Center/Title") :: TextLabel
	local subLabel = Hud.find("Center/Subtitle") :: TextLabel
	messageToken += 1
	local token = messageToken
	titleLabel.Text = title
	subLabel.Text = subtitle
	subLabel.Visible = subtitle ~= ""
	center.Visible = true
	titleLabel.TextTransparency = 1
	subLabel.TextTransparency = 1
	local info = TweenInfo.new(if GuiService.ReducedMotionEnabled then 0 else 0.5)
	TweenService:Create(titleLabel, info, { TextTransparency = 0 }):Play()
	TweenService:Create(subLabel, info, { TextTransparency = 0 }):Play()
	task.delay(math.max(1, seconds), function()
		if token ~= messageToken then
			return
		end
		TweenService:Create(titleLabel, info, { TextTransparency = 1 }):Play()
		TweenService:Create(subLabel, info, { TextTransparency = 1 }):Play()
		task.wait(0.5)
		if token == messageToken then
			center.Visible = false
		end
	end)
end

local function flash()
	local frame = overlay():FindFirstChild("Flash") :: Frame?
	if not frame then
		return
	end
	frame.BackgroundTransparency = 0.15
	TweenService:Create(frame, TweenInfo.new(1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		BackgroundTransparency = 1,
	}):Play()
end

function HUDController:Start()
	local objective = Hud.find("Top/ObjectivePill/Objective") :: TextLabel
	local timer = Hud.find("Top/ObjectivePill/Timer") :: TextLabel
	local banner = Hud.find("Top/StatusBanner") :: Frame
	local bannerText = Hud.find("Top/StatusBanner/Text") :: TextLabel
	local leave = Hud.find("Top/StatusBanner/LeaveButton") :: TextButton
	local stamina = Hud.find("Bottom/Stamina") :: Frame
	local staminaFill = Hud.find("Bottom/Stamina/Fill") :: Frame

	local function status(): string
		local s = player:GetAttribute("Status")
		return if typeof(s) == "string" then s else "Lobby"
	end

	local function renderBanner()
		local s = status()
		local text = ""
		if s == "Hidden" then
			text = "Hiding. It can't see you... unless it saw you get in."
		elseif s == "Caged" then
			text = "Caged! A teammate must break the lock. Call out for help."
		elseif s == "Escaped" then
			text = "You escaped!"
		elseif s == "Lobby" and Workspace:GetAttribute("RoundState") == "Playing" then
			text = "Round in progress. You'll join the next one."
		end
		bannerText.Text = text
		banner.Visible = text ~= ""
		leave.Visible = s == "Hidden"
		stamina.Visible = s == "Alive"
	end

	local function renderObjective()
		local s = status()
		local state = Workspace:GetAttribute("RoundState")
		local inserted = tonumber(Workspace:GetAttribute("FusesInserted")) or 0
		local total = tonumber(Workspace:GetAttribute("FusesTotal")) or HorrorConfig.Fuses.Count
		if state == "Playing" and (s == "Alive" or s == "Hidden" or s == "Caged") then
			if Workspace:GetAttribute("PowerOn") == true then
				objective.Text = "Power is on! Get out through the north gate!"
				objective.TextColor3 = Color3.fromRGB(120, 255, 150)
			elseif player:GetAttribute("CarryingFuse") == true then
				objective.Text = `Bring the fuse to the generator  ·  {inserted}/{total}`
				objective.TextColor3 = Color3.fromRGB(255, 200, 70)
			else
				objective.Text = `Find fuses  ·  {inserted}/{total}`
				objective.TextColor3 = Color3.fromRGB(237, 230, 217)
			end
		elseif state == "Playing" then
			objective.Text = "Round in progress"
			objective.TextColor3 = Color3.fromRGB(237, 230, 217)
		elseif state == "Results" then
			objective.Text = "Round over"
			objective.TextColor3 = Color3.fromRGB(237, 230, 217)
		else
			local endsAt = tonumber(Workspace:GetAttribute("IntermissionEndsAt")) or 0
			objective.Text = if endsAt > 0 then "Next round starts in" else "Waiting for players..."
			objective.TextColor3 = Color3.fromRGB(237, 230, 217)
		end
	end

	-- Timer text updates 4x a second (cheap) rather than every frame.
	task.spawn(function()
		while true do
			local now = Workspace:GetServerTimeNow()
			local state = Workspace:GetAttribute("RoundState")
			local endsAt = tonumber(
				if state == "Playing"
					then Workspace:GetAttribute("RoundEndsAt")
					else Workspace:GetAttribute("IntermissionEndsAt")
			) or 0
			timer.Text = if endsAt > now then formatTime(endsAt - now) else ""
			timer.Visible = timer.Text ~= ""
			task.wait(0.25)
		end
	end)

	for _, attr in { "RoundState", "FusesInserted", "FusesTotal", "PowerOn", "IntermissionEndsAt" } do
		Workspace:GetAttributeChangedSignal(attr):Connect(function()
			renderObjective()
			renderBanner()
		end)
	end
	player:GetAttributeChangedSignal("Status"):Connect(function()
		renderObjective()
		renderBanner()
	end)
	player:GetAttributeChangedSignal("CarryingFuse"):Connect(renderObjective)
	player:GetAttributeChangedSignal("Stamina"):Connect(function()
		local v = tonumber(player:GetAttribute("Stamina")) or 1
		staminaFill.Size = UDim2.fromScale(v, 1)
		staminaFill.BackgroundColor3 = if v < 0.25 then Color3.fromRGB(220, 70, 60) else Color3.fromRGB(237, 230, 217)
	end)
	renderObjective()
	renderBanner()

	NetClient.event("RoundMessage").OnClientEvent:Connect(function(title: string, subtitle: string, seconds: number)
		showMessage(title, subtitle, seconds)
	end)
	NetClient.event("Caught").OnClientEvent:Connect(function(name: string, isYou: boolean)
		if isYou then
			flash()
			CameraShaker.AddTrauma(0.9)
			showMessage("CAUGHT", "You're in the cage. A teammate can break the lock.", 4)
		else
			Toast.show(`{name} was caught! The cage is in the basement.`, "error", 4)
		end
	end)
end

return HUDController
