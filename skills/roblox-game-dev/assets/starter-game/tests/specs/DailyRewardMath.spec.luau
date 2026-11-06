--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local describe, it, expect = JestGlobals.describe, JestGlobals.it, JestGlobals.expect

local DailyRewardMath = require(ReplicatedStorage.Shared.Util.DailyRewardMath)

local DAY = DailyRewardMath.DAY
local RULES = { maxFreezes = 2, freezeRefillEvery = 7 }

local function state(lastDay: number, streak: number, freezes: number?): DailyRewardMath.State
	return { LastDay = lastDay, Streak = streak, Best = streak, Freezes = freezes or 0 }
end

describe("DailyRewardMath day boundaries (UTC)", function()
	it("computes day indexes at exact boundaries", function()
		expect(DailyRewardMath.dayIndex(0)).toBe(0)
		expect(DailyRewardMath.dayIndex(DAY - 1)).toBe(0)
		expect(DailyRewardMath.dayIndex(DAY)).toBe(1)
		-- 2026-11-05T00:00:00Z = 1793836800 -> day 20762
		expect(DailyRewardMath.dayIndex(1793836800)).toBe(20762)
		expect(DailyRewardMath.dayIndex(1793836800 - 1)).toBe(20761)
	end)

	it("computes the next reset and seconds until it", function()
		local t = 1793836800 + 3600 -- 01:00 UTC
		expect(DailyRewardMath.nextResetUnix(t)).toBe(1793836800 + DAY)
		expect(DailyRewardMath.secondsUntilReset(t)).toBe(DAY - 3600)
		expect(DailyRewardMath.secondsUntilReset(1793836800)).toBe(DAY)
	end)
end)

describe("DailyRewardMath.evaluate", function()
	it("allows the first claim ever with streak 1", function()
		local can, nextStreak, freeze = DailyRewardMath.evaluate(state(-1, 0, 1), 100)
		expect(can).toBe(true)
		expect(nextStreak).toBe(1)
		expect(freeze).toBe(false)
	end)
	it("blocks a second claim on the same day", function()
		local can, nextStreak = DailyRewardMath.evaluate(state(100, 4), 100)
		expect(can).toBe(false)
		expect(nextStreak).toBe(4)
	end)
	it("blocks when the saved day is in the future (clock skew)", function()
		expect((DailyRewardMath.evaluate(state(101, 4), 100))).toBe(false)
	end)
	it("continues the streak on the next day", function()
		local can, nextStreak = DailyRewardMath.evaluate(state(99, 4), 100)
		expect(can).toBe(true)
		expect(nextStreak).toBe(5)
	end)
	it("uses a freeze for exactly one missed day", function()
		local can, nextStreak, freeze = DailyRewardMath.evaluate(state(98, 4, 1), 100)
		expect(can).toBe(true)
		expect(nextStreak).toBe(5)
		expect(freeze).toBe(true)
	end)
	it("resets after one missed day with no freeze, or after two missed days", function()
		local _, a = DailyRewardMath.evaluate(state(98, 4, 0), 100)
		local _, b = DailyRewardMath.evaluate(state(97, 4, 2), 100)
		expect(a).toBe(1)
		expect(b).toBe(1)
	end)
end)

describe("DailyRewardMath.claim", function()
	it("returns a new state without mutating the input", function()
		local before = state(99, 6, 1)
		local after, streak = DailyRewardMath.claim(before, 100, RULES)
		expect(after).never.toBeNil()
		expect(streak).toBe(7)
		expect(before.Streak).toBe(6)
		expect(before.LastDay).toBe(99)
		local s = after :: DailyRewardMath.State
		expect(s.LastDay).toBe(100)
		expect(s.Best).toBe(7)
		expect(s.Freezes).toBe(2) -- day 7 refills one freeze (cap 2)
	end)
	it("spends a freeze and never exceeds the cap", function()
		local after = DailyRewardMath.claim(state(98, 2, 1), 100, RULES) :: DailyRewardMath.State
		expect(after.Freezes).toBe(0)
		local capped = DailyRewardMath.claim(state(99, 13, 2), 100, RULES) :: DailyRewardMath.State
		expect(capped.Freezes).toBe(2)
	end)
	it("returns nil when already claimed today", function()
		local after, streak = DailyRewardMath.claim(state(100, 3), 100, RULES)
		expect(after).toBeNil()
		expect(streak).toBe(3)
	end)
	it("keeps Best when a streak resets", function()
		local s = { LastDay = 90, Streak = 10, Best = 10, Freezes = 0 }
		local after = DailyRewardMath.claim(s, 100, RULES) :: DailyRewardMath.State
		expect(after.Streak).toBe(1)
		expect(after.Best).toBe(10)
	end)
end)

describe("DailyRewardMath.ladderIndex", function()
	it("loops over the ladder", function()
		expect(DailyRewardMath.ladderIndex(1, 7)).toBe(1)
		expect(DailyRewardMath.ladderIndex(7, 7)).toBe(7)
		expect(DailyRewardMath.ladderIndex(8, 7)).toBe(1)
		expect(DailyRewardMath.ladderIndex(15, 7)).toBe(1)
		expect(DailyRewardMath.ladderIndex(0, 7)).toBe(1) -- defensive
	end)
end)
