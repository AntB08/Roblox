--!strict
-- Policy: FAIL-CLOSED wrapper around PolicyService:GetPolicyInfoForPlayerAsync.
-- If the call fails, the player is treated as RESTRICTED (no paid random items, no paid
-- trading, no ads, no subscription/commerce offers, no content sharing).
--
--   if Policy.can(player, "PaidRandomItems") then ... end   -- server-side enforcement
--   Client UI reads player attributes Policy_<Feature> (true = allowed) to HIDE features.
--   A client attribute only hides UI: ALWAYS enforce on the server too.

local Players = game:GetService("Players")
local PolicyService = game:GetService("PolicyService")

local Retry = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").Util.Retry)

export type Feature =
	"PaidRandomItems"
	| "PaidItemTrading"
	| "Ads"
	| "Subscriptions"
	| "CommerceProducts"
	| "ContentSharing"

-- Maps each feature to (policy key, value that means ALLOWED).
local FEATURES: { [Feature]: { key: string, allowedWhen: boolean } } = {
	PaidRandomItems = { key = "ArePaidRandomItemsRestricted", allowedWhen = false },
	PaidItemTrading = { key = "IsPaidItemTradingAllowed", allowedWhen = true },
	Ads = { key = "AreAdsAllowed", allowedWhen = true },
	Subscriptions = { key = "IsEligibleToPurchaseSubscription", allowedWhen = true },
	CommerceProducts = { key = "IsEligibleToPurchaseCommerceProduct", allowedWhen = true },
	ContentSharing = { key = "IsContentSharingAllowed", allowedWhen = true },
}

local Policy = {}
Policy.Priority = 150

-- allowed[player][feature] = boolean. Missing => not yet fetched => treated as NOT allowed.
local allowed: { [Player]: { [string]: boolean } } = {}
local fetching: { [Player]: boolean } = {}

local function restrictive(): { [string]: boolean }
	local t = {}
	for feature in FEATURES do
		t[feature] = false
	end
	return t
end

local function publish(player: Player, flags: { [string]: boolean })
	for feature, value in flags do
		player:SetAttribute(`Policy_{feature}`, value)
	end
end

local function fetch(player: Player)
	if allowed[player] or fetching[player] then
		return
	end
	fetching[player] = true
	local ok, info = Retry.call(function()
		return PolicyService:GetPolicyInfoForPlayerAsync(player)
	end, 3)
	fetching[player] = nil
	if player.Parent ~= Players then
		return
	end

	local flags = restrictive()
	if ok and typeof(info) == "table" then
		for feature, spec in FEATURES do
			local value = (info :: any)[spec.key]
			-- Only an explicit "allowed" value unlocks a feature; anything else stays restricted.
			flags[feature] = typeof(value) == "boolean" and value == spec.allowedWhen
		end
	else
		warn(`[Policy] lookup failed for {player.UserId}; fail-closed:`, info)
	end
	allowed[player] = flags
	publish(player, flags)
end

-- Server-side check. Returns false until the lookup has completed (fail-closed).
function Policy.can(player: Player, feature: Feature): boolean
	local flags = allowed[player]
	return flags ~= nil and flags[feature] == true
end

-- Yields until the lookup is done (or the player leaves), then returns the result.
function Policy.canAsync(player: Player, feature: Feature): boolean
	local deadline = os.clock() + 15
	while allowed[player] == nil and player.Parent == Players and os.clock() < deadline do
		if not fetching[player] then
			fetch(player)
		else
			task.wait(0.25)
		end
	end
	return Policy.can(player, feature)
end

function Policy:Start()
	Players.PlayerAdded:Connect(fetch)
	Players.PlayerRemoving:Connect(function(player)
		allowed[player] = nil
		fetching[player] = nil
	end)
	for _, player in Players:GetPlayers() do
		task.spawn(fetch, player)
	end
end

return Policy
