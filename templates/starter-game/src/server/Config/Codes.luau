--!strict
-- Codes: SERVER-ONLY list of redeemable codes (never move this to ReplicatedStorage).
-- Live codes can also be added without a publish through LiveConfig key "codes" (JSON with the
-- same shape); a live entry overrides a static one with the same name.
--
-- Shape:
--   CODE = {
--     reward = { coins = 100 },
--     startsAt = unixSeconds?,      -- not redeemable before (UTC)
--     expiresAt = unixSeconds?,     -- not redeemable at/after (UTC)
--     maxUses = number?,            -- global cap across all servers (DataStore counter)
--     minAccountAgeDays = number?,  -- deters alt farming for valuable codes
--   }
-- Keys must already be normalized (UPPERCASE, no spaces, [A-Z0-9_-], 3..32 chars).
-- Post codes on the game's community/social pages; never put links or handles in-game.

export type CodeDef = {
	reward: { coins: number },
	startsAt: number?,
	expiresAt: number?,
	maxUses: number?,
	minAccountAgeDays: number?,
}

local Codes: { [string]: CodeDef } = {
	WELCOME = { reward = { coins = 50 } }, -- example; replace with your launch code
}

return table.freeze(Codes)
