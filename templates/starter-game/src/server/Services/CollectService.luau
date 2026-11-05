--!strict
-- CollectService: the EXAMPLE VERTICAL SLICE (server half). Copy this shape for new mechanics.
--
--   client  CollectController: player near a part tagged "CollectNode" presses Collect
--        -> Remotes.Collect:FireServer(node)          (intent only: "I want to collect THIS")
--   server  Net: rate limit + Guard.instanceOf("BasePart", Workspace)
--        -> here: tag check, alive check, distance check, per-node cooldown (all server-side)
--        -> DataService.addCoins (profile = saved by ProfileStore; leaderstats + attribute update;
--           analytics economy event)
--        -> Remotes.CollectResult:FireClient(player, result)
--   client  CollectController: burst particles + sound + toast + HUD pop + tiny camera shake
--
-- The client never tells the server how many coins it gets or that the cooldown is over.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(script.Parent.Parent.Net)
local DataService = require(script.Parent.DataService)
local LiveConfig = require(script.Parent.LiveConfig)
local Analytics = require(script.Parent.Analytics)
local PlayerLifecycle = require(script.Parent.PlayerLifecycle)

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared.Config.GameConfig)
local Types = require(Shared.Types)

local CONFIG = GameConfig.Collect
local MAX_REWARD = 10_000 -- sanity cap against a fat-fingered LiveConfig value

local CollectService = {}

-- cooldownUntil[player][node] = os.clock() time when the node is available again.
-- Node keys are weak so destroyed nodes do not leak; the per-player table is removed by the
-- player's Trove on leave.
local cooldownUntil: { [Player]: { [BasePart]: number } } = {}

local function cooldownsFor(player: Player): { [BasePart]: number }?
	local existing = cooldownUntil[player]
	if existing then
		return existing
	end
	local trove = PlayerLifecycle.troveFor(player)
	if not trove then
		return nil -- player not registered yet (first frames after join)
	end
	local t = setmetatable({}, { __mode = "k" }) :: any
	cooldownUntil[player] = t
	trove:Add(function()
		cooldownUntil[player] = nil
	end)
	return t
end

local function currentReward(): number
	local base = LiveConfig.number("collect_reward", CONFIG.Reward)
	local multiplier = LiveConfig.number("coin_multiplier", 1)
	return math.clamp(math.floor(base * multiplier), 0, MAX_REWARD)
end

local function reply(player: Player, result: Types.CollectResult)
	Net.fire("CollectResult", player, result)
end

local function onCollect(player: Player, node: BasePart)
	-- 1. Is it really a collect node? (Guard already proved it's a BasePart in Workspace.)
	if not node:HasTag(CONFIG.Tag) then
		reply(player, { ok = false, reason = "Invalid" })
		return
	end

	-- 2. Is the player's data loaded and their character alive?
	if DataService.get(player) == nil then
		reply(player, { ok = false, reason = "NotLoaded" })
		return
	end
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not (root and root:IsA("BasePart") and humanoid and humanoid.Health > 0) then
		reply(player, { ok = false, reason = "Invalid" })
		return
	end

	-- 3. In range? Measured to the node's surface, plus latency slack.
	local radius = math.max(node.Size.X, node.Size.Y, node.Size.Z) / 2
	local distance = (root.Position - node.Position).Magnitude - radius
	if distance > CONFIG.MaxDistance + CONFIG.DistanceSlack then
		reply(player, { ok = false, reason = "TooFar" })
		return
	end

	-- 4. Cooldown (server clock only).
	local cooldowns = cooldownsFor(player)
	if not cooldowns then
		reply(player, { ok = false, reason = "NotLoaded" })
		return
	end
	local now = os.clock()
	local readyAt = cooldowns[node]
	if readyAt and now < readyAt then
		reply(player, { ok = false, reason = "Cooldown", cooldown = readyAt - now })
		return
	end

	-- 5. Grant. No yields between the checks above and this write.
	local amount = currentReward()
	if not DataService.addCoins(player, amount, Enum.AnalyticsEconomyTransactionType.Gameplay, "CollectNode") then
		reply(player, { ok = false, reason = "NotLoaded" })
		return
	end
	cooldowns[node] = now + CONFIG.CooldownSeconds

	local data = DataService.get(player)
	if data then
		data.Stats.Collects += 1
		if DataService.markOnboarding(player, "FirstCollect") then
			Analytics.onboarding(player, "FirstCollect")
		end
		if data.Stats.Collects >= 10 and DataService.markOnboarding(player, "TenCollects") then
			Analytics.onboarding(player, "TenCollects")
		end
	end

	reply(player, {
		ok = true,
		amount = amount,
		balance = if data then data.Coins else nil,
		position = node.Position,
		cooldown = CONFIG.CooldownSeconds,
	})
end

function CollectService:Init()
	Net.handle("Collect", onCollect)
end

return CollectService
