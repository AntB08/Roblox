--!strict
-- GameConfig: tuning values shared by server and client. The SERVER is authoritative: the client
-- may read these for display, but every rule is enforced on the server with the server's copy.
-- Values that live-ops may change without a publish belong in LiveConfig (ConfigService) and
-- fall back to these defaults.

local GameConfig = {
	-- Display name of the soft currency (also the leaderstats column and analytics currency).
	Currency = "Coins",

	-- Example vertical slice: walk up to a part tagged "CollectNode" and press Collect.
	Collect = {
		Tag = "CollectNode",
		Reward = 5, -- coins per collect (LiveConfig key "collect_reward" can override)
		CooldownSeconds = 6, -- per player, per node
		MaxDistance = 12, -- studs from HumanoidRootPart to node surface (client shows button within this)
		DistanceSlack = 4, -- extra server tolerance for latency
	},

	-- Settings a player may change through the SetSetting remote. Values are clamped to [min, max].
	Settings = {
		MusicVolume = { min = 0, max = 1, default = 0.6 },
		ShakeIntensity = { min = 0, max = 1, default = 1 },
	},

	-- Persistence
	DataStoreName = "PlayerData_v1", -- change ONLY with a migration plan: a new name = wiped data
	PurchaseIdCacheSize = 100,
}

return table.freeze(GameConfig)
