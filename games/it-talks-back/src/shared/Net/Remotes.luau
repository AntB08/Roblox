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

local Guard = require(script.Parent.Guard)
local RateLimiter = require(script.Parent.RateLimiter)
local GameConfig = require(script.Parent.Parent.Config.GameConfig)
local HorrorConfig = require(script.Parent.Parent.Config.HorrorConfig)

export type Kind = "Event" | "Function" | "Unreliable"
export type Direction = "ToServer" | "ToClient"
export type Def = {
	kind: Kind,
	direction: Direction,
	args: { Guard.Check }?, -- required for ToServer
	rate: RateLimiter.Config?, -- tokens per second + burst, per player (ToServer)
}

local CALLOUT_ROOMS: { [string]: boolean } = {}
for _, room in HorrorConfig.Callouts do
	CALLOUT_ROOMS[room] = true
end

local Remotes: { [string]: Def } = {
	-- Movement intent. The server owns WalkSpeed, stamina and the flashlight light itself.
	SetSprint = { kind = "Event", direction = "ToServer", args = { Guard.boolean() }, rate = { rate = 8, burst = 16 } },
	SetCrouch = { kind = "Event", direction = "ToServer", args = { Guard.boolean() }, rate = { rate = 4, burst = 8 } },
	SetFlashlight = {
		kind = "Event",
		direction = "ToServer",
		args = { Guard.boolean() },
		rate = { rate = 4, burst = 8 },
	},

	-- "I'm in the <room>!" Teammates see it; the monster hears it (true or not).
	Callout = {
		kind = "Event",
		direction = "ToServer",
		args = { Guard.oneOf(CALLOUT_ROOMS) },
		rate = { rate = 1, burst = 3 },
	},
	-- What the local player just said into their mic (Roblox speech-to-text, client side).
	-- Untrusted text: the server only matches keywords and feeds it to TextGenerator (moderated);
	-- it is never shown to other players.
	Spoke = {
		kind = "Event",
		direction = "ToServer",
		args = { Guard.string(200, 1) },
		rate = { rate = 0.5, burst = 3 },
	},
	-- HUD "Leave" button while hiding (the closet prompt does the same).
	LeaveHide = { kind = "Event", direction = "ToServer", args = {}, rate = { rate = 2, burst = 4 } },

	-- Server -> client
	MonsterSpeak = { kind = "Event", direction = "ToClient" }, -- (text: string, kind: string)
	RoundMessage = { kind = "Event", direction = "ToClient" }, -- (title: string, subtitle: string, seconds: number)
	CalloutShown = { kind = "Event", direction = "ToClient" }, -- (displayName: string, room: string)
	Caught = { kind = "Event", direction = "ToClient" }, -- (victimDisplayName: string, isYou: boolean)

	-- Generic server -> client toast: (text: string, kind: "info"|"success"|"warning"|"error")
	Notify = { kind = "Event", direction = "ToClient" },

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
