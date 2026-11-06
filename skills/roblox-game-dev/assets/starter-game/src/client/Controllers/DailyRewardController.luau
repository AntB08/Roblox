--!strict
-- DailyRewardController: HUD "Daily" button + badge. On join it asks the server for the status
-- (retrying while data loads) and shows a friendly toast if a reward is ready. No FOMO wording.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Assets = require(Shared.Config.Assets)
local Format = require(Shared.Util.Format)
local NetClient = require(Shared.Net.Client)
local Types = require(Shared.Types)

local Client = script.Parent.Parent
local Hud = require(Client.UI.Hud)
local Toast = require(Client.UI.Toast)
local AnimatedButton = require(Client.UI.AnimatedButton)
local RewardBurst = require(Client.FX.RewardBurst)

local STATUS_RETRIES = 10
local STATUS_RETRY_DELAY = 2

local DailyRewardController = {}

local badge: GuiObject? = nil
local claiming = false

local function setBadge(status: Types.DailyStatus?)
	if badge then
		badge.Visible = status ~= nil and status.canClaim
	end
end

local function untilReset(status: Types.DailyStatus): string
	-- Server-synced clock for display (the client's own clock can be wrong).
	return Format.duration(status.nextResetUnix - Workspace:GetServerTimeNow())
end

local function fetchStatus(): Types.DailyStatus?
	for _ = 1, STATUS_RETRIES do
		local ok, status = NetClient.invoke("GetDailyStatus")
		if ok and typeof(status) == "table" then
			return status
		end
		task.wait(STATUS_RETRY_DELAY) -- nil while the profile is still loading
	end
	return nil
end

local function claim()
	if claiming then
		return
	end
	claiming = true
	local ok, result = NetClient.invoke("ClaimDaily")
	claiming = false
	if not ok or typeof(result) ~= "table" then
		Toast.show("Couldn't reach the server. Try again.", "error")
		return
	end
	local r = result :: Types.DailyClaimResult
	setBadge(r.status)
	if r.ok then
		Toast.show(`Daily reward: +{r.coins or 0} Coins`, "success")
		local character = Players.LocalPlayer.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root and root:IsA("BasePart") then
			RewardBurst.Play(root.Position + Vector3.new(0, 2, 0), {
				count = 32,
				sound = Assets.Sounds.Reward,
				big = true,
			})
		end
	elseif r.reason == "AlreadyClaimed" and r.status then
		Toast.show(`Next reward in {untilReset(r.status)}`, "info")
	elseif r.reason == "NotLoaded" then
		Toast.show("Loading your data…", "info")
	end
end

function DailyRewardController:Start()
	local button = Hud.find("LeftStack/Menu/DailyButton") :: GuiButton
	badge = button:FindFirstChild("Badge") :: GuiObject?
	AnimatedButton.wrap(button, { onActivated = claim })

	local status = fetchStatus()
	setBadge(status)
	if status and status.canClaim then
		Toast.show(`Daily reward ready: +{status.nextRewardCoins} Coins. Tap Daily!`, "info", 5)
	end
end

return DailyRewardController
