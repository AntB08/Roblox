--!strict
-- DailyRewardService: 7-day looping streak with one-day "freeze" grace, UTC day boundaries.
-- State lives in the session-locked profile (Data.Daily), so recording the claim and granting
-- the coins happen in the SAME save: they can never diverge, and a second server cannot double
-- claim (it has no active session). Math is in Shared/Util/DailyRewardMath.luau (unit-tested).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(script.Parent.Parent.Net)
local DataService = require(script.Parent.DataService)
local Analytics = require(script.Parent.Analytics)

local Shared = ReplicatedStorage:WaitForChild("Shared")
local DailyRewardMath = require(Shared.Util.DailyRewardMath)
local DailyRewards = require(Shared.Config.DailyRewards)
local Types = require(Shared.Types)

local RULES: DailyRewardMath.Rules = {
	maxFreezes = DailyRewards.MaxFreezes,
	freezeRefillEvery = DailyRewards.FreezeRefillEvery,
}

local DailyRewardService = {}

local function rewardCoins(streak: number): number
	local index = DailyRewardMath.ladderIndex(streak, #DailyRewards.Ladder)
	return DailyRewards.Ladder[index].coins
end

local function buildStatus(state: DailyRewardMath.State, now: number): Types.DailyStatus
	local day = DailyRewardMath.dayIndex(now)
	local canClaim, nextStreak = DailyRewardMath.evaluate(state, day)
	return {
		canClaim = canClaim,
		streak = state.Streak,
		nextStreak = nextStreak,
		nextRewardCoins = rewardCoins(nextStreak),
		freezes = state.Freezes,
		nextResetUnix = DailyRewardMath.nextResetUnix(now),
	}
end

function DailyRewardService.getStatus(player: Player): Types.DailyStatus?
	local data = DataService.get(player)
	if not data then
		return nil
	end
	return buildStatus(data.Daily, os.time())
end

function DailyRewardService.claim(player: Player): Types.DailyClaimResult
	local data = DataService.get(player)
	if not data then
		return { ok = false, reason = "NotLoaded" }
	end
	local now = os.time()
	local day = DailyRewardMath.dayIndex(now)
	local newState, streak = DailyRewardMath.claim(data.Daily, day, RULES)
	if not newState then
		return { ok = false, reason = "AlreadyClaimed", status = buildStatus(data.Daily, now) }
	end

	-- No yields from here: record + grant together.
	local coins = rewardCoins(streak)
	data.Daily.LastDay = newState.LastDay
	data.Daily.Streak = newState.Streak
	data.Daily.Best = newState.Best
	data.Daily.Freezes = newState.Freezes
	DataService.addCoins(player, coins, Enum.AnalyticsEconomyTransactionType.TimedReward, "DailyReward")

	Analytics.custom(player, "DailyClaimed", streak)
	if DataService.markOnboarding(player, "FirstDailyClaim") then
		Analytics.onboarding(player, "FirstDailyClaim")
	end
	return { ok = true, coins = coins, status = buildStatus(data.Daily, now) }
end

function DailyRewardService:Init()
	Net.handle("GetDailyStatus", function(player: Player)
		return DailyRewardService.getStatus(player)
	end)
	Net.handle("ClaimDaily", function(player: Player)
		return DailyRewardService.claim(player)
	end)
end

return DailyRewardService
