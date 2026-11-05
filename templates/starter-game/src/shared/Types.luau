--!strict
-- Types shared by server and client: payload shapes of remotes. Keep them plain data
-- (strings, numbers, booleans, string-keyed tables, Vector3) so they survive the network.

export type ToastKind = "info" | "success" | "warning" | "error"

-- CollectResult (server -> client)
export type CollectResult = {
	ok: boolean,
	amount: number?, -- coins granted
	balance: number?, -- new balance (UI also listens to the leaderstat)
	position: Vector3?, -- where to play the burst
	cooldown: number?, -- seconds until this node is collectable again
	reason: ("TooFar" | "Cooldown" | "NotLoaded" | "Invalid")?,
}

-- Daily reward status (GetDailyStatus / ClaimDaily responses)
export type DailyStatus = {
	canClaim: boolean,
	streak: number,
	nextStreak: number,
	nextRewardCoins: number,
	freezes: number,
	nextResetUnix: number,
}

export type DailyClaimResult = {
	ok: boolean,
	reason: ("AlreadyClaimed" | "NotLoaded" | "Busy")?,
	coins: number?,
	status: DailyStatus?,
}

-- RedeemCode response: a key the client maps to a (localizable) message.
export type RedeemResult =
	"OK"
	| "INVALID"
	| "EXPIRED"
	| "ALREADY_REDEEMED"
	| "SOLD_OUT"
	| "ACCOUNT_TOO_NEW"
	| "BUSY"
	| "NOT_LOADED"
	| "ERROR"

return {}
