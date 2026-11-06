--!strict
-- DailyRewardMath: pure date/streak math for the daily reward (unit-tested).
-- Days are UTC day indexes: floor(unixSeconds / 86400). Every server agrees on them, and the
-- client renders "next reward in hh:mm" from nextResetUnix (client clock is fine for display).
--
-- State.lastDay = -1 means "never claimed" (ProfileStore cannot store nil in a template).

export type State = {
	LastDay: number,
	Streak: number,
	Best: number,
	Freezes: number,
}

export type Rules = {
	maxFreezes: number,
	freezeRefillEvery: number,
}

local DAY = 86400

local DailyRewardMath = {}
DailyRewardMath.DAY = DAY

function DailyRewardMath.dayIndex(unix: number): number
	return unix // DAY
end

function DailyRewardMath.nextResetUnix(unix: number): number
	return (unix // DAY + 1) * DAY
end

function DailyRewardMath.secondsUntilReset(unix: number): number
	return DailyRewardMath.nextResetUnix(unix) - unix
end

-- What would claiming on `day` do? Returns (canClaim, nextStreak, usesFreeze).
function DailyRewardMath.evaluate(state: State, day: number): (boolean, number, boolean)
	local last = state.LastDay
	if last < 0 then
		return true, 1, false -- first claim ever
	end
	if last >= day then
		-- Already claimed today (or a server with a skewed clock saved a future day): no claim.
		return false, state.Streak, false
	end
	local gap = day - last
	if gap == 1 then
		return true, state.Streak + 1, false
	end
	if gap == 2 and state.Freezes > 0 then
		return true, state.Streak + 1, true -- one missed day, covered by a freeze
	end
	return true, 1, false -- streak broken: start again (kindly, no penalty beyond that)
end

-- Returns the new state after claiming on `day`, or nil if a claim is not allowed.
-- Never mutates the input.
function DailyRewardMath.claim(state: State, day: number, rules: Rules): (State?, number)
	local canClaim, nextStreak, usesFreeze = DailyRewardMath.evaluate(state, day)
	if not canClaim then
		return nil, state.Streak
	end
	local freezes = state.Freezes
	if usesFreeze then
		freezes -= 1
	end
	if rules.freezeRefillEvery > 0 and nextStreak % rules.freezeRefillEvery == 0 then
		freezes = math.min(rules.maxFreezes, freezes + 1)
	end
	return {
		LastDay = day,
		Streak = nextStreak,
		Best = math.max(state.Best, nextStreak),
		Freezes = freezes,
	},
		nextStreak
end

-- 1-based ladder index for a streak day (loops after the last entry).
function DailyRewardMath.ladderIndex(streak: number, ladderLength: number): number
	assert(ladderLength > 0, "ladderLength must be > 0")
	return ((math.max(streak, 1) - 1) % ladderLength) + 1
end

return table.freeze(DailyRewardMath)
