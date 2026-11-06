--!strict
-- CodesService: secure code redemption.
--   * Input is re-normalized here (Shared/Util/CodeFormat.luau); Net already capped the length
--     and rate-limits attempts (Remotes.RedeemCode: 0.2/s, burst 4) against brute force.
--   * Codes live only on the server (Config/Codes.luau + LiveConfig "codes").
--   * Once per player: recorded in the session-locked profile (Data.RedeemedCodes) in the same
--     save as the reward.
--   * Optional global maxUses: reserved with DataStore UpdateAsync (pcall'd), refunded if the
--     redemption does not complete.
-- Returns a result KEY (Types.RedeemResult); the client maps it to a localizable message.

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Server = script.Parent.Parent
local Net = require(Server.Net)
local StaticCodes = require(Server.Config.Codes)
local DataService = require(script.Parent.DataService)
local LiveConfig = require(script.Parent.LiveConfig)
local Analytics = require(script.Parent.Analytics)

local Shared = ReplicatedStorage:WaitForChild("Shared")
local CodeFormat = require(Shared.Util.CodeFormat)
local Types = require(Shared.Types)

local MAX_CODE_COINS = 100_000 -- sanity cap for live-config typos
local USES_STORE_NAME = "CodeGlobalUses_v1"

type CodeDef = StaticCodes.CodeDef

local CodesService = {}

local inFlight: { [Player]: boolean } = {}
local usesStore: DataStore? = nil

local function getUsesStore(): DataStore
	if not usesStore then
		usesStore = DataStoreService:GetDataStore(USES_STORE_NAME)
	end
	return usesStore :: DataStore
end

-- Validates a definition coming from LiveConfig JSON (untrusted shape).
local function sanitize(raw: any): CodeDef?
	if typeof(raw) ~= "table" or typeof(raw.reward) ~= "table" then
		return nil
	end
	local coins = raw.reward.coins
	if typeof(coins) ~= "number" or coins ~= coins or coins < 0 or coins % 1 ~= 0 or coins > MAX_CODE_COINS then
		return nil
	end
	local function optNumber(v: any): number?
		return if typeof(v) == "number" and v == v then v else nil
	end
	return {
		reward = { coins = coins },
		startsAt = optNumber(raw.startsAt),
		expiresAt = optNumber(raw.expiresAt),
		maxUses = optNumber(raw.maxUses),
		minAccountAgeDays = optNumber(raw.minAccountAgeDays),
	}
end

local function lookup(code: string): CodeDef?
	local live = LiveConfig.get("codes")
	if typeof(live) == "table" and live[code] ~= nil then
		return sanitize(live[code])
	end
	return StaticCodes[code]
end

-- delta = +1 reserves a use (fails when sold out), -1 refunds. Yields.
local function changeGlobalUses(code: string, maxUses: number, delta: number): boolean
	local reserved = false
	local ok, err = pcall(function()
		getUsesStore():UpdateAsync(code, function(current: any)
			local n = tonumber(current) or 0
			if delta > 0 and n >= maxUses then
				reserved = false
				return nil -- sold out: abort the write
			end
			reserved = true
			return math.max(0, n + delta)
		end)
	end)
	if not ok then
		warn("[CodesService] uses store error:", err)
	end
	return ok and reserved
end

function CodesService.redeem(player: Player, raw: string): Types.RedeemResult
	local code = CodeFormat.normalize(raw)
	if not code then
		return "INVALID"
	end
	local def = lookup(code)
	if not def then
		return "INVALID"
	end
	local now = os.time()
	if def.startsAt and now < def.startsAt then
		return "INVALID"
	end
	if def.expiresAt and now >= def.expiresAt then
		return "EXPIRED"
	end
	if def.minAccountAgeDays and player.AccountAge < def.minAccountAgeDays then
		return "ACCOUNT_TOO_NEW"
	end

	local data = DataService.get(player)
	if not data then
		return "NOT_LOADED"
	end
	if data.RedeemedCodes[code] then
		return "ALREADY_REDEEMED"
	end
	if inFlight[player] then
		return "BUSY"
	end

	inFlight[player] = true
	local reservedGlobal = false
	if def.maxUses then
		reservedGlobal = changeGlobalUses(code, def.maxUses, 1) -- yields
		if not reservedGlobal then
			inFlight[player] = nil
			return "SOLD_OUT"
		end
	end

	-- Re-check after the yield: player may have left or redeemed elsewhere.
	data = DataService.get(player)
	local result: Types.RedeemResult
	if not data then
		result = "NOT_LOADED"
	elseif data.RedeemedCodes[code] then
		result = "ALREADY_REDEEMED"
	else
		-- Record + grant with no yield in between (same profile save).
		data.RedeemedCodes[code] = now
		DataService.addCoins(player, def.reward.coins, Enum.AnalyticsEconomyTransactionType.Gameplay, "Code")
		Analytics.custom(player, "CodeRedeemed", 1, code)
		result = "OK"
	end

	if reservedGlobal and result ~= "OK" and def.maxUses then
		changeGlobalUses(code, def.maxUses, -1) -- refund the unused slot
	end
	inFlight[player] = nil
	return result
end

function CodesService:Init()
	Net.handle("RedeemCode", function(player: Player, raw: string)
		return CodesService.redeem(player, raw)
	end)
	game:GetService("Players").PlayerRemoving:Connect(function(player)
		inFlight[player] = nil
	end)
end

return CodesService
