--!strict
-- Remotes: the SINGLE source of truth for every remote in the game.
-- The server Net module creates them (ReplicatedStorage.Remotes) and validates client->server
-- traffic with `args` + `rate`. The client NetClient looks them up by the same names.
--
-- To add a remote: add an entry here, then
--   server: Net.handle("Name", function(player, ...) ... end)   (ToServer)
--           Net.fire("Name", player, ...) / Net.fireAll("Name", ...)  (ToClient)
--   client: NetClient.event("Name") / NetClient.func("Name")
--
-- Rules: clients send INTENT, never outcomes. Every ToServer remote has `args` checks and a rate.

local Workspace = game:GetService("Workspace")

local Guard = require(script.Parent.Guard)
local RateLimiter = require(script.Parent.RateLimiter)
local GameConfig = require(script.Parent.Parent.Config.GameConfig)

export type Kind = "Event" | "Function" | "Unreliable"
export type Direction = "ToServer" | "ToClient"
export type Def = {
	kind: Kind,
	direction: Direction,
	args: { Guard.Check }?, -- required for ToServer
	rate: RateLimiter.Config?, -- tokens per second + burst, per player (ToServer)
}

local Remotes: { [string]: Def } = {
	-- Example vertical slice ------------------------------------------------------------
	-- Client asks to collect a node it is standing next to. Server re-checks tag, distance,
	-- cooldown, grants coins and answers with CollectResult.
	Collect = {
		kind = "Event",
		direction = "ToServer",
		args = { Guard.instanceOf("BasePart", Workspace) },
		rate = { rate = 3, burst = 5 },
	},
	CollectResult = { kind = "Event", direction = "ToClient" },

	-- Generic server -> client toast: (text: string, kind: "info"|"success"|"warning"|"error")
	Notify = { kind = "Event", direction = "ToClient" },

	-- Daily reward
	GetDailyStatus = { kind = "Function", direction = "ToServer", args = {}, rate = { rate = 1, burst = 5 } },
	ClaimDaily = { kind = "Function", direction = "ToServer", args = {}, rate = { rate = 0.5, burst = 3 } },

	-- Codes (string is normalized + re-checked on the server; rate kept low against brute force)
	RedeemCode = {
		kind = "Function",
		direction = "ToServer",
		args = { Guard.string(40, 1) },
		rate = { rate = 0.2, burst = 4 },
	},

	-- Player settings (persisted in the profile, mirrored to player attributes "Setting_<Key>")
	SetSetting = {
		kind = "Event",
		direction = "ToServer",
		args = { Guard.oneOf(GameConfig.Settings), Guard.number(0, 1) },
		rate = { rate = 5, burst = 10 },
	},

	-- Client error reports: (message, stack?, platform)
	ClientError = {
		kind = "Event",
		direction = "ToServer",
		args = { Guard.string(500), Guard.optional(Guard.string(2000)), Guard.string(20) },
		rate = { rate = 0.2, burst = 5 },
	},
}

return table.freeze(Remotes)
