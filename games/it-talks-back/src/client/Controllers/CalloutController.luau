--!strict
-- CalloutController: shows teammates' callouts ("Sam: I'm in the Kitchen!") as a toast and a
-- short-lived marker floating over that room. The text is a preset built from a fixed room list
-- and the player's DisplayName, so no free-form player text is shown.

local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local NetClient = require(Shared.Net.Client)
local Theme = require(Shared.UI.Theme)

local Client = script.Parent.Parent
local Toast = require(Client.UI.Toast)

local MARKER_SECONDS = 6

local CalloutController = {}

local function roomCenter(room: string): Vector3?
	for _, inst in CollectionService:GetTagged("RoomVolume") do
		if inst:IsA("BasePart") and inst:GetAttribute("RoomName") == room then
			return inst.Position
		end
	end
	return nil
end

local function showMarker(name: string, room: string)
	local center = roomCenter(room)
	if not center then
		return
	end
	local anchor = Instance.new("Part")
	anchor.Name = "CalloutMarker"
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.CanTouch = false
	anchor.Transparency = 1
	anchor.Size = Vector3.one
	anchor.Position = center
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromOffset(220, 56)
	billboard.AlwaysOnTop = true
	billboard.LightInfluence = 0
	billboard.MaxDistance = 400
	billboard.Parent = anchor
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.TextColor3 = Theme.Color.Warning
	text.TextStrokeTransparency = 0.3
	text.FontFace = Theme.Font.Heavy
	text.TextScaled = true
	text.Text = `{name}: "{room}!"`
	text.Parent = billboard
	anchor.Parent = Workspace
	Debris:AddItem(anchor, MARKER_SECONDS)
end

function CalloutController:Start()
	NetClient.event("CalloutShown").OnClientEvent:Connect(function(name: string, room: string)
		if typeof(name) ~= "string" or typeof(room) ~= "string" then
			return
		end
		local isMe = name == Players.LocalPlayer.DisplayName
		Toast.show(
			if isMe then `You shouted "{room}!" (it heard you too)` else `{name}: "I'm in the {room}!"`,
			"info",
			3
		)
		if not isMe then
			showMarker(name, room)
		end
	end)
end

return CalloutController
