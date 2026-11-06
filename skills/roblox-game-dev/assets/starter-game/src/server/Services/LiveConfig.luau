--!strict
-- LiveConfig: typed wrapper around ConfigService (Creator Hub > Configs) with safe defaults.
-- Server-only (ConfigService throws on the client). If configs never load, every key returns
-- its DEFAULT, so the game always works offline / in Studio / during outages.
--
--   LiveConfig.number("collect_reward", GameConfig.Collect.Reward)
--   LiveConfig.get("codes")                      -- JSON table or nil
--   LiveConfig.onChanged("motd", function(v) ... end)
--   LiveConfig.forPlayerAsync(player, "starter_offer_delay_min", 10)  -- experiments/targeting
--
-- Keys use snake_case. Every key used in code MUST have a DEFAULT here.
-- Replicate only what clients need (attributes / remotes); never send the whole config.

local ConfigService = game:GetService("ConfigService")
local Players = game:GetService("Players")

local Retry = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").Util.Retry)

local DEFAULTS: { [string]: any } = {
	collect_reward = 5, -- number: coins per collect (GameConfig.Collect.Reward is the fallback)
	coin_multiplier = 1, -- number: global event multiplier on gameplay coin sources
	codes = nil, -- JSON: { CODE = { reward = { coins = n }, expiresAt = unix?, maxUses = n? } }
	motd = "", -- string: localization KEY for a message of the day, not raw text
}

local RETRY_SECONDS = 30
local MAX_RETRY_SECONDS = 300

local LiveConfig = {}
LiveConfig.Priority = 180

local snapshot: ConfigSnapshot? = nil
local loaded = false

local function load(attempt: number)
	local ok, result = pcall(function()
		return ConfigService:GetConfigAsync()
	end)
	if ok and result then
		snapshot = result
		loaded = true
		result.UpdateAvailable:Connect(function()
			-- Applies live changes immediately. For round-based games, set a flag instead and
			-- call Refresh() between rounds so values never change mid-match.
			local refreshed, err = pcall(function()
				result:Refresh()
			end)
			if not refreshed then
				warn("[LiveConfig] refresh failed:", err)
			end
		end)
	else
		warn("[LiveConfig] using defaults:", result)
		task.delay(math.min(RETRY_SECONDS * attempt, MAX_RETRY_SECONDS), load, attempt + 1)
	end
end

function LiveConfig.isLoaded(): boolean
	return loaded
end

function LiveConfig.get(key: string): any
	local snap = snapshot
	if snap then
		local ok, value = pcall(snap.GetValue, snap, key)
		if ok and value ~= nil then
			return value
		end
	end
	return DEFAULTS[key]
end

function LiveConfig.number(key: string, fallback: number): number
	local v = LiveConfig.get(key)
	if typeof(v) == "number" and v == v then
		return v
	end
	return fallback
end

function LiveConfig.boolean(key: string, fallback: boolean): boolean
	local v = LiveConfig.get(key)
	if typeof(v) == "boolean" then
		return v
	end
	return fallback
end

function LiveConfig.string(key: string, fallback: string): string
	local v = LiveConfig.get(key)
	if typeof(v) == "string" then
		return v
	end
	return fallback
end

-- Calls fn(newValue) whenever the key changes (after configs have loaded).
function LiveConfig.onChanged(key: string, fn: (any) -> ())
	task.spawn(function()
		while not snapshot do
			task.wait(1)
		end
		local snap = snapshot :: ConfigSnapshot
		snap:GetValueChangedSignal(key):Connect(function()
			fn(LiveConfig.get(key))
		end)
	end)
end

-- Per-player value (targeting rules / Experiments). Yields. Falls back to the global value.
function LiveConfig.forPlayerAsync(player: Player, key: string, fallback: any): any
	local ok, snap = Retry.call(function()
		return ConfigService:GetConfigForPlayerAsync(player)
	end, 2)
	if ok and snap and player.Parent == Players then
		local got, value = pcall((snap :: ConfigSnapshot).GetValue, snap, key)
		if got and value ~= nil then
			return value
		end
	end
	local global = LiveConfig.get(key)
	return if global ~= nil then global else fallback
end

function LiveConfig:Start()
	load(1)
end

return LiveConfig
