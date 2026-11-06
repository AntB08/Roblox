--!strict
-- DailyRewards: the streak ladder. Day N of a streak gets Ladder[((N - 1) % #Ladder) + 1].
-- Shared so the client can render the ladder; the server grants from its own copy.
-- Kind design: one streak "freeze" covers a single missed day; no FOMO wording in UI.

export type Reward = { coins: number }

local DailyRewards = {
	Ladder = {
		{ coins = 25 },
		{ coins = 40 },
		{ coins = 60 },
		{ coins = 80 },
		{ coins = 100 },
		{ coins = 130 },
		{ coins = 200 },
	} :: { Reward },
	StartingFreezes = 1,
	MaxFreezes = 2,
	FreezeRefillEvery = 7, -- +1 freeze (up to MaxFreezes) every 7th streak day
}

return table.freeze(DailyRewards)
