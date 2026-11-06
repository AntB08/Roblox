--!strict
-- Schema: the player-data template, its version, and the migrations between versions.
-- Pure module (no services, no yields) so it is unit-tested in tests/specs/Migrations.spec.luau.
--
-- HOW TO CHANGE THE SCHEMA
--   * Adding a field with a default: just add it to TEMPLATE. Profile:Reconcile() fills it in.
--   * Renaming / retyping / restructuring: bump VERSION, add MIGRATIONS[oldVersion] that turns
--     version N data into N + 1, add a test, and record it in docs/SYSTEMS.md.
--   * NEVER edit or delete an old migration step: profiles from any past version must still load.
--   * Store only JSON-safe values (numbers, strings, booleans, string-keyed tables, arrays with
--     no holes). No Instances, Vector3, Color3, CFrame.

local DataSchema = {}

DataSchema.VERSION = 2

-- NOTE: `typeof(TEMPLATE)` gives other modules a typed Data. Keep the literal complete.
local TEMPLATE = {
	Version = 2,
	Coins = 0,
	Stats = {
		FirstJoin = 0, -- unix seconds
		LastJoin = 0,
		PlaySeconds = 0,
		Collects = 0,
		RobuxSpent = 0,
	},
	Settings = {
		MusicVolume = 0.6,
		ShakeIntensity = 1,
	},
	Daily = {
		LastDay = -1, -- UTC day index of last claim; -1 = never
		Streak = 0,
		Best = 0,
		Freezes = 1,
	},
	RedeemedCodes = {} :: { [string]: number }, -- CODE -> unix time redeemed
	PurchaseIdCache = {} :: { string }, -- last N receipt PurchaseIds (idempotency)
	Onboarding = {} :: { [string]: boolean }, -- once-ever analytics steps
}

export type Data = typeof(TEMPLATE)

DataSchema.TEMPLATE = table.freeze(TEMPLATE)

-- MIGRATIONS[v] upgrades data IN PLACE from version v to v + 1.
-- v1 -> v2 is the worked example: v1 stored `Cash` and `Settings.Music` (boolean); v2 renamed
-- Cash to Coins and replaced the boolean with a 0..1 MusicVolume. Keep it as a pattern (it is
-- harmless for profiles that never had v1 data) or replace it when your game ships v1 for real.
local MIGRATIONS: { [number]: (data: { [string]: any }) -> () } = {
	[1] = function(data)
		data.Coins = (tonumber(data.Coins) or 0) + (tonumber(data.Cash) or 0)
		data.Cash = nil
		local settings = data.Settings
		if typeof(settings) == "table" then
			if typeof(settings.Music) == "boolean" then
				settings.MusicVolume = if settings.Music then 0.6 else 0
			end
			settings.Music = nil
		end
	end,
}
DataSchema.MIGRATIONS = MIGRATIONS

export type MigrateResult = "UpToDate" | "Migrated" | "FromFuture"

-- Upgrades `data` in place to VERSION. Call BEFORE Profile:Reconcile().
-- Returns "FromFuture" (and leaves data untouched) if the data was saved by a NEWER server
-- version; callers should then kick the player rather than risk overwriting newer data.
function DataSchema.migrate(data: { [string]: any }): (MigrateResult, number)
	local from = tonumber(data.Version) or 1
	if from > DataSchema.VERSION then
		return "FromFuture", from
	end
	if from == DataSchema.VERSION then
		return "UpToDate", from
	end
	local version = from
	while version < DataSchema.VERSION do
		local step = MIGRATIONS[version]
		assert(step, `[DataSchema] missing migration for version {version}`)
		step(data)
		version += 1
		data.Version = version
	end
	return "Migrated", from
end

return table.freeze(DataSchema)
