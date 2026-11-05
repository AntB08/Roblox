# 07 — Monetization, Economy, Policy & Launch

> Snapshot date: **2026-11-05**. Most facts come from the local official Creator Docs mirror
> (`.sources/Roblox_creator-docs`, last commit 2026-11-05) and were checked against 2025–2026
> newsroom and DevForum coverage. Roblox changes numbers often (rates, fees, thresholds). Before
> you quote a number to the user as current, run `scripts/kb_search.sh "<topic>" docs`.
> Items marked **[UNCERTAIN]** could not be confirmed from a primary source.

---

## TL;DR rules for the bot

1. **Grant developer products only from a receipt handler** (`MarketplaceService.ProcessReceipt`, or the newer `MarketplaceService:BindReceiptHandler`). Never grant from `PromptProductPurchaseFinished`, and never grant from a client remote.
2. **Receipt handling must be idempotent.** Record each `PurchaseId` in the player's saved data, in the same save as the reward. Return `PurchaseGranted`/`Processed` only after that save has gone through. Use ProfileStore (session locked), as described in `04-luau-engineering.md`.
3. **Exactly one** `ProcessReceipt` assignment, in one server Script. It must handle every product ID, including rewarded-ad reward products. If a product is unknown, return `NotProcessedYet`.
4. **Game passes:** check ownership on the server with `UserOwnsGamePassAsync` (pcall and retry) when the player joins. Cache the result on the player (an attribute plus a server table). Update the cache from the **server-side** `PromptGamePassPurchaseFinished` when `wasPurchased == true`.
5. **Never hard-code prices in UI.** Read them with `GetProductInfoAsync(id, Enum.InfoType.Product / GamePass)`. Managed (regional) pricing, price tests, and Roblox Plus discounts all change what each player pays.
6. **Use PolicyService for every gated feature**: paid random items, trading of paid items, ads, subscriptions, commerce, and UGC sharing. If the call fails, treat the player as **restricted**.
7. **Paid random items (eggs, crates, spins, luck boosts):** show every outcome with its numeric % odds (summing to 100%) **before** purchase. Show the updated odds while boosts are active. Give restricted players an alternative path.
8. **No pay-to-win against other players.** Sell cosmetics, convenience, time-savers, VIP perks, and extra content. Paid power in PvP gets downvoted and drives players away.
9. **Price ladder:** offer a cheap first purchase (25–99 R$), a "best value" anchor, and a premium top tier. Typical pass prices: 49 / 99 / 199 / 399 / 799 R$. A starter pack should be the best value in the game.
10. **Economy:** every currency source needs a matching sink. Log both with `AnalyticsService:LogEconomyEvent`. Run trades atomically on the server and give every item a unique ID, so duplication bugs can't happen.
11. **Fill out the Maturity & Compliance Questionnaire honestly** before release. A game with no rating has restricted playability. Base each answer on the most extreme content a player can see. Resubmit whenever an update changes an answer.
12. **Text from one player shown to others** (pet names, signs, custom titles) must go through `TextService:FilterStringAsync` and then the matching `Get...Async` method.
13. **No off-platform links, social handles, Discord invites, or "free Robux" promises inside the game.** Social links belong only in the experience page's Social Links section, and they are visible only to age-checked users 16+.
14. **No real-money or Robux gambling**, simulated or otherwise. "Unplayable" depictions, such as casino scenery, are a questionnaire item.
15. **Original IP only.** Don't use other games' names, characters, music, logos, or brands in titles, thumbnails, or content.
16. **Experience page:** a 512×512 icon, 16:9 1920×1080 thumbnails (up to 10, with at least one custom thumbnail, otherwise there are no Home recommendations), a stable title, and a description whose first ~160 characters are a keyword-rich hook. Never mislead with the thumbnail.
17. **Measure, then iterate:** D1/D7/D30 retention, playtime, payer conversion, ARPPU, and ARPDAU. A/B test with Creator Hub **Experiments** and **Configs** (`ConfigService`).

---

## 1. Revenue map: every way to earn (as of 2026-11)

| Method | What it is | Creator gets | Key constraints |
|---|---|---|---|
| **Passes** (game passes) | One-time purchase of a permanent perk | 70% of price (Robux) | Must belong to the current game. **Cross-game pass/product sales were disabled ~May 29–30, 2026.** Listed passes can be sold outside the game (Home, search, post-Robux-purchase page). |
| **Developer products** | Repeatable purchases (currency, boosts, revives) | 70% | Needs a correct receipt handler. Listed products can sell outside the game **only if** your ProcessReceipt passes Roblox's ongoing checks. |
| **Subscriptions** (in-game) | Auto-renewing monthly perk | **Robux-priced:** 70% every month (min 49 R$). **Local currency** ($2.99/4.99/7.99/9.99/14.99): 70% the first month, **100% from month 2** (paid in Robux at $0.01 = 1 R$) | Robux price can change only once every 60 days, and increases need 30 days' notice. Local-currency prices can't be changed. Check `IsEligibleToPurchaseSubscription`. |
| **Private servers** (paid) | Monthly Robux fee for a private server | 70% | Changing the price **cancels all active subscriptions**. Can't be combined with paid access. Roblox Plus subscribers get paid private servers free, and you earn up to 100 R$/subscriber/month (needs 60+ min there). |
| **Paid access** | Pay to enter the game | Robux: 25–1000 R$, 70%. Local currency: ~70% of a USD tier, minus fees | Kills discovery for most games. Mainly useful for paid closed betas. Not on Xbox. |
| **Avatar items sold in-game** | UGC accessories/clothing from your game | Game owner **40%** commission, item creator 30% | The item creator adds your Place ID to the item's sale locations, and you enable the item in Monetization → Avatar Items. |
| **Avatar creation tokens** | Players create and buy avatar items in your game (`AvatarCreationService`) | Marketplace commissions as both creator and game owner | Requires a Creation Advance and fee, plus Marketplace creator requirements (ID-verified with Plus/Premium). |
| **Immersive ads** | Billboard (image/video) and portal ad units | Per impression/teleport. Paid on the 25th of the following month | Publisher must be 13+ and ID-verified with 2FA. Questionnaire must be approved. Check `AreAdsAllowed`. |
| **Rewarded video ads** | Opt-in full-screen video (6–30 s) for an in-game reward | EPM × impressions | Reward must be a **developer product**, not random, not Robux. Requires a public game with 2k+ unique visitors/month and ID verification. Shown only to users 13+. |
| **Creator Rewards** | Engagement and audience-expansion payouts from Roblox | 5 R$/day per Active Spender (see §2), plus a 35% share of new/returning users' first $100 | Replaced Premium/Engagement-Based Payouts on **July 24, 2025**. 60-day hold. |
| **Roblox Plus incentives** | Earnings from Roblox's subscription (launched Apr 30, 2026) | 250 R$/month for 3 months (≤750 R$) per Plus signup through `PromptRobloxSubscriptionPurchase`. 10% of in-game Robux transfers. Paid-private-server time | 60-day hold on signup earnings. |
| **Robux transfers** | Plus subscribers send 10–500 R$ to another user inside your game | Game earns **10%** (DevEx-eligible) | `PromptRobuxTransferAsync` plus receipts of type `RobuxTransferSender/Receiver`. Replaced "donation pass" games. |
| **Commerce products** | Real-world merch via Shopify | Varies | Creator 18+, ID-verified, 2FA, business info. Buyers are US only, 13+ (18+ in Texas). Check `IsEligibleToPurchaseCommerceProduct`. Bundled digital items require 100k DAU or 1M R$/month. |
| **Creator Store** | Sell models/plugins to other creators | — | Outside the scope of a game. |

**Revenue share basics:** for passes, products, Robux subscriptions, and private servers, the creator receives **70%** of the Robux price after Roblox's 30% platform fee. Roblox Plus discounts (10%, rising to 20% after the 2nd month) are **subsidized by Roblox**, so you still earn 70 R$ on a 100 R$ item even when a Plus subscriber pays only 80–90.

### 1.1 The in-game Shop and Managed Pricing (platform features, 2026)

- **Shop**: Roblox auto-generates a personalized Shop of your passes and developer products. It appears in the in-game menu, and you can enable an optional global Shop button. Open it with `MarketplaceService:OpenShop(player)`. Manage it under Creator Hub → Monetization → Shop, where you can list/unlist products and set categories. Passes are always listed. You can hide the menu entry with `StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.ExperienceShop, false)`, but you should keep it on.
- **Personalized ordering**: `RankProductsAsync` (≤50 items, 10 req/min) and `RecommendTopProductsAsync` (5 req/min). Call them once at join, never in a loop.
- **Managed Pricing** combines **price optimization** and **regional pricing**:
  - **Regional prices** stay between 30% and 100% of your default price, based on the player's "economic location". New items are enrolled by default. Subscriptions and private servers are regionalized automatically.
  - **Price optimization tests** split users into cohorts that see different prices. New prices are applied only if total revenue goes up. Tests run at least every 90 days. You realistically need about **60,000 transactions in 30 days** for a test to be meaningful.
  - Use the **Dynamic Price Check** tool to find hard-coded prices.
  - **Implication:** every price label must come from `GetProductInfoAsync`. Gifting and trading of priced items should check `GetUsersPriceLevelsAsync` to prevent arbitrage (see §6.4).
- **Promoted passes on the Buy Robux page**: an opt-in pass bundled with Robux packages, priced >49 and <801 R$. Create a dedicated pass for this.

---

## 2. Payouts: DevEx and Creator Rewards (verified 2026-11-05)

### DevEx (Developer Exchange)

| Rate | Value | Applies to |
|---|---|---|
| **Standard** | **$0.0038 per Earned Robux** ($114 per 30,000 R$) | Effective Sept 5, 2025, 10am PT. Before that it was $0.0035, and Robux earned before that time still cash out at $0.0035 first. |
| **U.S. 18+ rate** | **$0.0054 per Earned Robux** | Robux from passes, developer products, subscriptions, and private servers bought by **U.S. players age-verified 18+**, in **eligible games**. Announced Apr 30, 2026, effective ~June 8, 2026. The game must be **R15-only**, or use custom characters that meet the articulation rules, for 100% of active playtime. Avatar Settings → "R15 Only". Roblox runs background compliance checks. |

- **Eligibility:** 13+, at least 30,000 Earned Robux, verified email, a DevEx portal (Tipalti) account, a W-9/W-8 tax form, and full ToS compliance.
- **Not Earned Robux:** bought Robux, stipends, trading/resale, Robux received through transfers, gift cards, passes in template games with no real visits, or anything from moderated content.
- **Processing:** ~10 business days for a first request, ~5 for returning participants.
- **Rule of thumb:** a 100 R$ sale earns 70 Earned R$, which is about **$0.27** at the standard rate. 1,000,000 R$ of gross sales is about **$2,660**.

**Bot note:** if you design R15-only character systems, the game may qualify for the 18+ rate. That is a cheap win for a game aimed at older players. Don't force R6 in games meant to monetize adults.

### Creator Rewards (replaced Premium Payouts / Engagement-Based Payouts on July 24, 2025)

- **Daily Engagement Rewards:** **5 Robux per Active Spender per day** when your game is one of the first **three** games that user plays for **10+ minutes** that day. An Active Spender is a user with **≥ $9.99** of Robux/Premium/subscription purchases in the last 60 days who isn't a new or reactivated user.
- **Audience Expansion Rewards:** **35% revenue share on the first $100** of platform-wide purchases, over 60 days, by **New** or **Reactivated** (60+ days lapsed) users you bring in. Qualifying entry routes are your **Share Link**, a direct link as their first session, or a search for your exact game name. They must play 10+ minutes, and your game must average **100+ DAU** over the 60 days.
- Paid in Earned Robux after a **60-day hold**. Dashboard: Monetization → Creator Rewards.
- **Design implications:**
  - Make players *want to open your game first each day*: daily rewards, streaks, and timed events.
  - Make sessions reach 10 minutes. Avoid 3-minute bounce loops.
  - Promote **Share Links** in off-platform marketing.

---

## 3. MarketplaceService code (production-ready patterns)

> Verified against `MarketplaceService.yaml` (2026-11). Notes:
> - `GetProductInfo` is **deprecated**. Use `GetProductInfoAsync`.
> - `Player.MembershipType` is deprecated for Plus/Premium checks. Use `Player.HasRobloxSubscription`.
> - `ProcessReceipt` facts:
>   - It is called when a purchase completes, when a purchase prompt succeeds, and **when the player joins a server**.
>   - It **may run on two servers at once** if the player hops servers.
>   - It has no timeout, so yielding is allowed.
>   - With no callback set, receipts are **auto-acknowledged and lost**.
>   - Receipts include `PurchaseId`, `PlayerId`, `ProductId`, `PlaceIdWherePurchased`, `CurrencySpent`, `CurrencyType`, and `ProductPurchaseChannel` (`InExperience`, `ExperienceDetailsPage`, `AdReward`, `CommerceProduct`).

### 3.1 Product catalog module (single source of truth)

```lua
-- ReplicatedStorage/Shared/ProductCatalog.luau
-- IDs come from Creator Hub. Prices are NOT stored here; always fetch them live.
local ProductCatalog = {}

ProductCatalog.Products = {
	Coins500    = 0000000001, -- developer product IDs
	Coins1200   = 0000000002,
	Revive      = 0000000003,
	StarterPack = 0000000004, -- one-time-per-player enforced in code
	AdReward2x  = 0000000005, -- reward product for rewarded video ads
}

ProductCatalog.Passes = {
	VIP       = 000000101,
	DoubleXP  = 000000102,
	ExtraSlot = 000000103,
}

return ProductCatalog
```

### 3.2 Idempotent receipt processing with ProfileStore (the recommended pattern)

This adapts ProfileStore's official "Caching PurchaseIds" approach. The reward and the `PurchaseId` are written **together** in `Profile.Data`. The receipt is acknowledged only after `Profile.LastSavedData` contains that `PurchaseId`. It is idempotent across rejoins, server hops, and crashes.

```lua
-- ServerScriptService/Monetization/ReceiptHandler.server.luau
-- Assumes a PlayerData module exposing GetProfileAsync(player) that waits for
-- the ProfileStore session (see 04-luau-engineering.md). Template must include:
--   PurchaseIdCache = {}, Coins = 0, Flags = {}, Stats = {RobuxSpent = 0}
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerData = require(ServerScriptService.Data.PlayerData)
local Catalog = require(ReplicatedStorage.Shared.ProductCatalog)

local PURCHASE_ID_CACHE_SIZE = 100
local P = Catalog.Products

-- Each grant function mutates profile.Data ONLY (no yielding, no instances that
-- could fail halfway). Visual effects happen after, outside the transaction.
-- If a grant errors, the pcall fails and the receipt stays open (NotProcessedYet).
local grants: {[number]: (profile: any, player: Player, receipt: any) -> boolean?} = {
	[P.Coins500] = function(profile)
		profile.Data.Coins += 500
	end,
	[P.Coins1200] = function(profile)
		profile.Data.Coins += 1200
	end,
	[P.Revive] = function(profile)
		profile.Data.PendingRevives = (profile.Data.PendingRevives or 0) + 1
	end,
	[P.StarterPack] = function(profile)
		-- UI should hide the offer once owned. If they still bought it (e.g. bought
		-- from another surface), grant a fallback so the purchase isn't wasted.
		if profile.Data.Flags.StarterPack then
			profile.Data.Coins += 1000 -- fallback value, never silently eat Robux
		else
			profile.Data.Flags.StarterPack = true
			profile.Data.Coins += 1000
			profile.Data.Inventory = profile.Data.Inventory or {}
			table.insert(profile.Data.Inventory, "StarterSword")
		end
	end,
	[P.AdReward2x] = function(profile)
		profile.Data.BoostUntil = math.max(profile.Data.BoostUntil or 0, os.time()) + 15 * 60
	end,
}

local function isSaved(profile, purchaseId: string): boolean
	local saved = profile.LastSavedData and profile.LastSavedData.PurchaseIdCache
	return saved ~= nil and table.find(saved, purchaseId) ~= nil
end

local function processReceipt(receipt)
	local player = Players:GetPlayerByUserId(receipt.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet -- retried on next join
	end

	local grant = grants[receipt.ProductId]
	if not grant then
		warn("[Receipt] Unknown product", receipt.ProductId)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local profile = PlayerData.GetProfileAsync(player) -- yields until loaded or nil
	if not profile or not profile:IsActive() then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local cache = profile.Data.PurchaseIdCache
	if not table.find(cache, receipt.PurchaseId) then
		local ok, err = pcall(grant, profile, player, receipt)
		if not ok then
			warn("[Receipt] Grant failed", receipt.PurchaseId, err)
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		while #cache >= PURCHASE_ID_CACHE_SIZE do
			table.remove(cache, 1)
		end
		table.insert(cache, receipt.PurchaseId)
		profile.Data.Stats.RobuxSpent += receipt.CurrencySpent
	end

	-- Wait until the purchase is durably saved, then acknowledge.
	while profile:IsActive() do
		if isSaved(profile, receipt.PurchaseId) then
			-- Optional: fire a client remote here for "Thanks!" VFX.
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
		local before = profile.LastSavedData
		profile:Save()
		if profile.LastSavedData == before then
			profile.OnAfterSave:Wait()
		end
		if not isSaved(profile, receipt.PurchaseId) and profile:IsActive() then
			task.wait(10)
		end
	end
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

-- The ONLY assignment of ProcessReceipt in the whole game.
MarketplaceService.ProcessReceipt = processReceipt
```

Why this is safe:
- **Duplicate delivery:** a second call with the same `PurchaseId` finds it in the cache and doesn't grant again.
- **Two servers:** ProfileStore's session lock means only one server has an active profile. The other gets `IsActive() == false` and returns `NotProcessedYet`.
- **Crash before save:** the receipt was never acknowledged, so Roblox re-delivers it on the next join.

If you **don't** use ProfileStore, the equivalent is a DataStore `UpdateAsync` on a `PurchaseHistory` key for `PurchaseId`. Write the reward in the **same** `UpdateAsync` as the purchase record (same key), or grant first and record second. Never record without granting.

### 3.3 Newer alternative: `BindReceiptHandler` (per-product routing)

`MarketplaceService:BindReceiptHandler(Enum.ReceiptType, handler, filter?)` returns an `RBXScriptConnection`.
- **Filtered handlers** take an array of product IDs. A **catch-all** handler has no filter.
- Bound handlers take precedence over `ProcessReceipt`. Unmatched developer-product receipts fall through to `ProcessReceipt`.
- The handler returns `Enum.ReceiptDecision.Processed` or `Enum.ReceiptDecision.NotProcessedYet`.
- It **is required for Robux transfer receipts** (`RobuxTransferSender`, `RobuxTransferReceiver`).
- Binding the same product twice, or two catch-alls for one type, **throws**.

```lua
-- Same idempotency rules apply; reuse the grant+save logic from 3.2.
local MarketplaceService = game:GetService("MarketplaceService")

local function handleDevProduct(receipt): Enum.ReceiptDecision
	local decision = processReceipt(receipt) -- function from 3.2
	return if decision == Enum.ProductPurchaseDecision.PurchaseGranted
		then Enum.ReceiptDecision.Processed
		else Enum.ReceiptDecision.NotProcessedYet
end

MarketplaceService:BindReceiptHandler(Enum.ReceiptType.DeveloperProduct, handleDevProduct)

-- Robux transfers (Plus feature). Reward the sender only after the receipt arrives.
MarketplaceService:BindReceiptHandler(Enum.ReceiptType.RobuxTransferSender, function(receipt)
	-- receipt.PlayerId, receipt.TransferRequestId, receipt.CurrencySpent
	-- Record TransferRequestId in saved data exactly like PurchaseId, then:
	return Enum.ReceiptDecision.Processed
end)
```

**Choose one style per game.** Recommendation: `ProcessReceipt` (3.2) for products, plus `BindReceiptHandler` only if you add Robux transfers. **[UNCERTAIN]** The docs don't say whether `ProcessReceipt` will be deprecated. As of 2026-11 it isn't.

### 3.4 Game pass ownership with caching

```lua
-- ServerScriptService/Monetization/Passes.server.luau
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Catalog = require(ReplicatedStorage.Shared.ProductCatalog)

local owned: {[Player]: {[number]: boolean}} = {}

local function applyPerk(player: Player, passId: number)
	-- Server-side effects; also mirror to an attribute for client UI.
	if passId == Catalog.Passes.VIP then
		player:SetAttribute("VIP", true)
	elseif passId == Catalog.Passes.DoubleXP then
		player:SetAttribute("XPMultiplier", 2)
	end
end

local function ownsAsync(player: Player, passId: number): boolean
	for attempt = 1, 3 do
		local ok, result = pcall(MarketplaceService.UserOwnsGamePassAsync,
			MarketplaceService, player.UserId, passId)
		if ok then return result end
		task.wait(attempt * 2)
	end
	return false -- fail closed for the moment; recheck later
end

Players.PlayerAdded:Connect(function(player)
	owned[player] = {}
	-- Concurrent calls are transparently batched by the engine.
	for _, passId in Catalog.Passes do
		task.spawn(function()
			if ownsAsync(player, passId) and player.Parent then
				owned[player][passId] = true
				applyPerk(player, passId)
			end
		end)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	owned[player] = nil
end)

-- Fires on the server with the final result; also refreshes the engine cache.
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, wasPurchased)
	if wasPurchased and owned[player] and not owned[player][passId] then
		owned[player][passId] = true
		applyPerk(player, passId)
	end
end)

-- Public API for other server code
local Passes = {}
function Passes.Has(player: Player, passId: number): boolean
	return owned[player] ~= nil and owned[player][passId] == true
end
return Passes
```

Notes:
- `UserOwnsGamePassAsync` results are cached by the engine. A pass bought **outside** the game mid-session can take several minutes to show up. On the next server join it always returns true.
- If you sell a pass that grants items, store "granted" in saved data, so it isn't granted twice and survives resets.

### 3.5 Client: prompting and dynamic prices

```lua
-- StarterPlayerScripts/ShopController.client.luau
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Catalog = require(ReplicatedStorage.Shared.ProductCatalog)
local player = Players.LocalPlayer

local priceCache = {}

local function getPrice(id: number, infoType: Enum.InfoType): number?
	local key = `{infoType.Name}:{id}`
	if priceCache[key] then return priceCache[key] end
	local ok, info = pcall(MarketplaceService.GetProductInfoAsync, MarketplaceService, id, infoType)
	if ok and info and info.PriceInRobux then
		priceCache[key] = info.PriceInRobux -- already includes regional/Plus/test price for this user
		return info.PriceInRobux
	end
	return nil
end

local function bindBuyButton(button: TextButton, id: number, isPass: boolean)
	local infoType = if isPass then Enum.InfoType.GamePass else Enum.InfoType.Product
	task.spawn(function()
		local price = getPrice(id, infoType)
		button.Text = if price then `R$ {price}` else "Buy"
	end)
	button.Activated:Connect(function()
		if isPass then
			MarketplaceService:PromptGamePassPurchase(player, id)
		else
			MarketplaceService:PromptProductPurchase(player, id)
		end
	end)
end
```

- **Prompt UX:** prompt only in response to a player action (a button or a walk-up NPC). Don't pop up a prompt on spawn.
- `PromptProductPurchaseFinished` is fine for closing a "processing…" spinner. It is **not** proof of purchase.
- **Testing:** Studio purchases are mocked and free. Studio does *not* check that a pass belongs to the current game, so verify IDs before publishing.

### 3.6 Roblox Plus signup prompt (earns up to 750 R$ per new subscriber)

```lua
-- Server: offer a small cosmetic for subscribing, never gameplay power.
local MarketplaceService = game:GetService("MarketplaceService")

local function offerPlus(player: Player)
	if player.HasRobloxSubscription then
		-- grant the cosmetic immediately (idempotently, saved flag)
		return
	end
	MarketplaceService:PromptRobloxSubscriptionPurchase(player)
end

-- Verify the status actually changed before rewarding:
local function watch(player: Player)
	player:GetPropertyChangedSignal("HasRobloxSubscription"):Connect(function()
		if player.HasRobloxSubscription then
			-- grant cosmetic + save flag
		end
	end)
end
```

Don't paywall the game behind Plus or Premium, and don't promise Robux you don't control.

---

## 4. Ethical, sustainable monetization design

### 4.1 Principles (what works on Roblox's audience)

- **Players downvote games whose monetization they dislike.** The Like ratio is visible, and retention feeds discovery (§10). Official docs also warn that **timers and appointment mechanics** that can be skipped for money, common elsewhere, are unpopular on Roblox.
- **"Tourists vs locals"** (official framing):
  - **Tourists** hop between games and buy items with *immediate, visible* effects (a flashy tool, a trail, a cool emote).
  - **Locals** stay, and buy long-term value: season passes, VIP, storage, progression accelerators.
  - Sell to both.
- **Sell fun, status, and convenience, not victory.** Good to sell:
  - Cosmetics: skins, trails, auras, emotes, nameplates, pets that don't affect stats.
  - Convenience: auto-collect, extra inventory, fast travel, extra plot slots.
  - Time: 2× XP or coin boosts, *capped so non-payers can still finish*.
  - Content: extra areas, game modes, private servers.
  - Social: VIP chat tag, VIP lounge, gifting.
- **Avoid:** stat weapons that beat free players in PvP; energy systems that stop play; stacking dozens of popups; "limited-time" pressure on every screen; selling things that break the game's balance.
- **Contextual purchases:** offer the thing the player needs *right now*. A revive when they die near the end of a level. More storage when the bag is full. A key when they meet a locked door. These convert far better than a generic shop and feel helpful rather than pushy.
- **Free paths** for everything except cosmetics and VIP. Paying should speed things up, never be the only way.

### 4.2 Product archetypes and typical prices

These are common Roblox price points, not official requirements. Prices ending in 9 match Roblox's own ladder (Robux packages, and the promoted-pass bounds of 49–800).

| Archetype | Type | Typical price (R$) | Notes |
|---|---|---|---|
| Tiny consumable (revive, skip, small coin pack) | Dev product | 15–49 | The impulse tier and the **first-purchase converter**. |
| Starter pack (one per player) | Dev product (flag-gated) or pass | 49–99 | Must be the **best value in the game**, around 3–5× normal value. Show it to new players after their first session milestone, not at spawn. |
| 2× Coins / 2× XP (permanent) | Pass | 99–299 | The classic Roblox pass. Cap its effect in competitive modes. |
| VIP (chat tag, lounge, daily bonus, cosmetic) | Pass | 199–499 | Status plus quality of life. |
| Extra slot / storage / auto-collect | Pass | 99–399 | Convenience. |
| Currency packs | Dev products | 49 / 99 / 199 / 399 / 799 / 1,599+ | Bigger packs get bonus % (e.g. +10%, +20%, +35%). Mark the middle pack **"Best Value"** or **"Most Popular"** (anchoring). |
| Season / battle pass | Pass per season or dev product | 199–499 | Free and premium tracks. Rewards should be reachable in 4–8 weeks of normal play. |
| Subscription (monthly VIP) | Subscription | 49+ R$ or $2.99–$9.99 | Daily login stipend of currency, cosmetic rotation. Must state the price and duration clearly. |
| Private server | Private server | 50–200 R$/month | Popular in roleplay, simulator, and grinding games. |

**Pricing ladder rules:**
1. Have at least one item at ≤49 R$, so the barrier to a first purchase is low.
2. Each step up should roughly double the price and offer **better value per Robux**.
3. A "decoy" anchor (an expensive bundle) makes the mid tier look reasonable.
4. Don't hard-code; let Managed Pricing localize prices.
5. Re-test prices with Experiments or Price Optimization rather than guessing.

### 4.3 First-purchase conversion playbook

- **Show value before asking for money.** The first 5–10 minutes should be pure fun with zero prompts. Onboarding and retention matter more than any price.
- First offer: the starter pack, after the first meaningful milestone (level 3, first rebirth, end of tutorial). It should be one tap from a non-blocking banner.
- **One-time "welcome" discount** for non-payers who have played 2–3 sessions. The official docs recommend welcome offers for first-time purchasers.
- Make the shop easy to find: a HUD button with a badge for new items, plus the Roblox global Shop button.
- Show what buyers get: preview cosmetics on the player's own avatar, and show the 2× effect in numbers.
- After the first purchase, players are far more likely to buy again (ARPPU tooling, §11). Offer appropriate upgrades, not a flood.

### 4.4 Rewarded video ads: design rules (official)

- Rewards worth roughly **3–10 R$**: boosters, soft currency, extra lives, temporary perks. They **can't** be random or Robux. The reward must be a developer product created in the same universe.
- Place them at natural breaks (lobby, after a round, out of lives). One or two clicks, with a clear CTA ("Watch an ad for 2× coins").
- Disclose that it's an ad. Don't let the character take damage while an ad plays (pause damage or use safe zones).
- Optional setting: **"Exclude your most likely purchasers"**, if the same reward can also be bought.
- Flow: client calls `AdService:GetAdAvailabilityNowAsync(Enum.AdFormat.RewardedVideo)` → server calls `AdService:CreateAdRewardFromDevProductId(id)` and `AdService:ShowRewardedVideoAdAsync(player, reward)` → reward granted through **your existing ProcessReceipt** (`ProductPurchaseChannel.AdReward`). Track it with `RegisterAdOpportunityAsync` and placement IDs.
- Full sample: `.sources/.../production/promotion/rewarded-video-ads.md`. Don't add a **second** `ProcessReceipt`. Add the ad reward product to the grants table in §3.2.

---

## 5. Virtual economy design

### 5.1 Model the economy as sources and sinks

| Sources (currency in) | Sinks (currency out) |
|---|---|
| Gameplay rewards (kills, quests, collection) | Upgrades and tools with escalating cost curves |
| Idle/AFK income (cap it!) | Consumables (potions, ammo, revives) |
| Daily login / streaks | Cosmetics (permanent sink, great for whales) |
| Robux purchases (IAP) | Rebirth/prestige resets (convert currency into multipliers) |
| Trading income | Taxes and fees (trade fee, marketplace listing fee, repair cost) |
| Events | Gacha/eggs (paid random rules apply if currency is Robux-bought, §7.3) |

**Rules:**
1. **Design the curves on paper first.** Keep a spreadsheet of income per minute against upgrade cost by level. Costs typically grow geometrically (×1.15–×1.5 per level) while income grows more slowly. This sets "time to next upgrade", and that should rise slowly, not explode.
2. **Every source gets a sink sized to it.** If earnings outpace meaningful things to buy, currency piles up, prices stop mattering, and veterans get bored (inflation).
3. **Soft vs hard currency:**
   - **Soft** (coins) is earned through play.
   - **Hard** (gems) is mostly bought with Robux, sometimes earned in small amounts.
   - Never let soft currency buy hard currency at a rate that makes Robux pointless. Never let hard currency buy *PvP power*.
4. **Avoid shrinking the economy.** Rebirth systems are healthy sinks because they convert spending into permanent progression.
5. **Data-driven config:**
   - Keep prices, drop rates, and rewards in a config ModuleScript or in **Creator Hub Configs** (`ConfigService:GetConfigAsync()` / `GetConfigForPlayerAsync(player)`).
   - That way you can rebalance without a code change and A/B test it (§11).
6. **Instrument it.** Log every source and sink so the Economy dashboard shows flows:

```lua
local AnalyticsService = game:GetService("AnalyticsService")

-- Source: coins from gameplay
AnalyticsService:LogEconomyEvent(player, Enum.AnalyticsEconomyFlowType.Source,
	"Coins", 50, newBalance, Enum.AnalyticsEconomyTransactionType.Gameplay.Name)

-- Source: coins bought with Robux (log inside the receipt grant)
AnalyticsService:LogEconomyEvent(player, Enum.AnalyticsEconomyFlowType.Source,
	"Coins", 1200, newBalance, Enum.AnalyticsEconomyTransactionType.IAP.Name, "Coins1200")

-- Sink: spent in shop
AnalyticsService:LogEconomyEvent(player, Enum.AnalyticsEconomyFlowType.Sink,
	"Coins", 300, newBalance, Enum.AnalyticsEconomyTransactionType.Shop.Name, "DoubleJump")
```

### 5.2 Inflation warning signs

- The median currency balance of players active 14+ days keeps rising week over week.
- The economy dashboard shows sinks below 60–70% of sources for long-term players.
- Prices on player trading markets climb, and "rare" items become common.
- **Fixes:** new aspirational sinks (cosmetics, housing), a rebirth tier, consumable upgrades, trade fees. Seasonal resets for *event* currencies only. Never wipe purchased progress.

### 5.3 Trading security and duplication prevention

Most famous Roblox economy disasters were **dupes**: two servers both believing they own an item, or a crash between "remove from A" and "add to B".

**Hard rules:**
1. **Trades run only on the server, only between players in the same server**, and both players' ProfileStore profiles must be active. Session locking guarantees only one server can write each profile.
2. **Every tradable item instance has a unique ID** (`HttpService:GenerateGUID(false)`), stored in the owner's `Inventory[uid] = {id="Sword", rarity=…}`. A trade moves those uids. Before every move, check that the uid exists in the sender's inventory.
3. **Atomic swap in one step with no yields**:
   - Validate both sides.
   - Remove from both and add to both, in the same function, without yielding in between.
   - Then save both profiles (`profile:Save()`).
   - Log a trade record (both userIds, uids, timestamp) for support and rollback.
4. **Two-phase UI confirmation:** both players accept, then a 3–5 second countdown. **Any change resets both accepts** (this blocks the "swap item at the last second" scam).
5. **Rate limits and cooldowns** on trade requests. A minimum account age or playtime for trading (optional, but it stops alt-farming). Never trust remote args: re-derive everything from server data.
6. **Policy:** if `IsPaidItemTradingAllowed == false` for either player, block trading of items that were bought with Robux or with Robux-bought currency. Tag items with `paid = true` at grant time so you can filter them.
7. **Cross-server trading or marketplaces** (MemoryStore or DataStore escrow) are advanced. They need an escrow record with states (`pending → committed`) and idempotent claim logic. Avoid them in a first game.
8. **No real-money trading.** Selling in-game items for real money or off-platform payment violates the Terms of Use. Don't build systems that encourage it, for example no "trade for Robux via group payouts".

```lua
-- Minimal atomic trade commit (server). Both profiles are active; offers are uid lists.
local function commitTrade(pA, pB, offerA: {string}, offerB: {string}): boolean
	local invA, invB = pA.Data.Inventory, pB.Data.Inventory
	for _, uid in offerA do if invA[uid] == nil then return false end end
	for _, uid in offerB do if invB[uid] == nil then return false end end
	-- no yields from here...
	for _, uid in offerA do invB[uid] = invA[uid]; invA[uid] = nil end
	for _, uid in offerB do invA[uid] = invB[uid]; invB[uid] = nil end
	-- ...to here
	task.spawn(function() pA:Save() end)
	task.spawn(function() pB:Save() end)
	return true
end
```

### 5.4 Regional pricing and gifts (arbitrage protection)

If players can **gift** paid items or currency, a player in a low-price region could buy cheaply and gift to a high-price region. Use `GetUsersPriceLevelsAsync({sender.UserId, recipient.UserId})`. It returns an array of `{UserId, PriceLevel}`, where PriceLevel is 1–1000 and 100 means the default price. Allow the gift only if the sender's level is ≥ the recipient's (official sample in `regional-pricing.md`).

---

## 6. PolicyService: per-player compliance

`PolicyService:GetPolicyInfoForPlayerAsync(player)` (yields, wrap it in pcall) returns:

| Key | Gate this feature when it's the "bad" value |
|---|---|
| `ArePaidRandomItemsRestricted` (true = restricted) | Paid eggs, crates, spins, luck boosts, gacha paid with Robux or Robux-bought currency |
| `IsPaidItemTradingAllowed` (false = blocked) | Trading items bought with Robux or premium currency |
| `AreAdsAllowed` | Immersive ads, independent ad content, sponsored NPC dialog |
| `IsEligibleToPurchaseSubscription` | Showing subscription offers |
| `IsEligibleToPurchaseCommerceProduct` | Commerce (real-world) products |
| `IsContentSharingAllowed` | Player-shared screenshots, videos, posts visible to others |
| `IsEndlessContentLoadAllowed` / `IsEndlessContentAutoplayAllowed` | Infinite-scroll feeds and autoplaying media |
| `IsPhotoToAvatarAllowed` | Photo-to-Avatar APIs |
| `IsSubjectToChinaPolicies` | China-specific compliance |
| `AllowedExternalLinkReferences` | **Legacy**, always returns empty. Don't use it to allow links. |

```lua
-- ServerScriptService/Compliance/Policy.luau (ModuleScript)
local PolicyService = game:GetService("PolicyService")
local Players = game:GetService("Players")

-- Fail-closed defaults used if the call errors.
local RESTRICTIVE = {
	ArePaidRandomItemsRestricted = true,
	IsPaidItemTradingAllowed = false,
	AreAdsAllowed = false,
	IsEligibleToPurchaseSubscription = false,
	IsEligibleToPurchaseCommerceProduct = false,
	IsContentSharingAllowed = false,
	IsEndlessContentLoadAllowed = false,
	IsEndlessContentAutoplayAllowed = false,
}

local cache: {[Player]: any} = {}
local Policy = {}

function Policy.Get(player: Player)
	if cache[player] then return cache[player] end
	local info
	for attempt = 1, 3 do
		local ok, result = pcall(PolicyService.GetPolicyInfoForPlayerAsync, PolicyService, player)
		if ok and result then info = result break end
		task.wait(attempt)
	end
	info = info or RESTRICTIVE
	cache[player] = info
	-- Replicate the bits the client UI needs:
	player:SetAttribute("CanBuyRandom", not info.ArePaidRandomItemsRestricted)
	player:SetAttribute("CanTradePaid", info.IsPaidItemTradingAllowed == true)
	return info
end

Players.PlayerRemoving:Connect(function(p) cache[p] = nil end)
return Policy
```

**Always enforce on the server.** A client attribute only hides UI. The server must refuse the purchase or trade too.

**Treatments for `ArePaidRandomItemsRestricted == true` (from the official list; pick one):**
1. An unpaid, earnable path (free eggs at milestones).
2. A pre-determined, disclosed, non-random sequence ("1st spin = 5 gems, 2nd = 10…").
3. Direct guaranteed purchase priced at expected value (a 10 R$ crate with a 5% sword means the sword sells directly for 200 R$).
4. Remove or hide the paid random item.
5. Block the purchase with a message ("Unavailable in your region").
6. Teleport the player away from areas with paid random items.

Option 3 is usually the best player experience and keeps revenue.

---

## 7. Policy and compliance

### 7.1 The rulebooks you must follow

- **Roblox Terms of Use** (help article 115004647846), updated **April 2026** per DevForum.
- **Roblox Community Standards** (help article 203313410 / about.roblox.com/community-standards), with an Economy section covering paid random items.
- **Advertising Standards** (13722260778260), updated with "New Advertising Policies & Standards" (DevForum 2026).
- **Age-Restricted ("Restricted") Content Policy** (15869919570708).
- **Marketplace Policy, Commerce Standards, DevEx Terms.**
- **[UNCERTAIN]** These pages could not be fetched live from this session (network allowlist). Summaries here come from the docs mirror and secondary coverage. Re-check them before relying on fine details.

### 7.2 Content maturity labels and the Maturity & Compliance Questionnaire (2026 model)

**A game with no maturity information has restricted playability for all players.** Fill out the questionnaire at Creator Hub → your game → **Publish settings → Content rating**.

| Label | Content allowed (summary) | Who can play by default |
|---|---|---|
| **Minimal** | Occasional mild violence, light unrealistic blood | Roblox Kids (5–8), Select (9–15), Roblox (16+) |
| **Mild** | Repeated mild violence, heavy unrealistic blood, mild fear, mild crude humor | Kids, Select, Roblox |
| **Moderate** (9+) | Moderate violence, light realistic blood, moderate fear, moderate crude humor, unplayable gambling depictions | Select (9–15) and Roblox (16+) |
| **Content May Vary** | You answered only the first question ("No" to age-restricted content) | **Age-checked 16+ only** |
| **Restricted** (18+) | Strong violence, heavy realistic blood, romantic themes, alcohol, strong language, unplayable gambling | **Age-verified (ID) 18+ only.** Unplayable in some countries (e.g. Korea, Saudi Arabia, Türkiye). Creator must be ID-verified 18+. A Restricted label can't later be lowered. |

History: "Restricted" was 17+ until 2025. In Aug–Sept 2025 it moved to **18+** for players and creators.

**Questionnaire items that force a higher age, whatever the label:**
- **Social hangout** (the main activity is chatting: hangouts, vibe games, "sad rooms"): 16+. With **private spaces** (bedrooms, bathroom stalls, small tents): ID-verified 18+. Roleplay games are not hangouts *if* the roleplay is central.
- **Free-form user creation** (drawing, spray paint, pixel canvases visible to others): **16+**. Building with 3D assets doesn't count.
- **Sensitive issues as the primary theme**: 16+, and not recommended unless the player is age-verified.
- **Romantic themes, private-space settings, adult venues** (bars, clubs), **alcohol**, **strong language**, **heavy realistic blood**: 18+ (Restricted).
- The questionnaire also asks about paid random items and whether you respect `ArePaidRandomItemsRestricted`, paid item trading and whether you respect `IsPaidItemTradingAllowed`, media sharing and feeds, and **generative AI interactions** (limited vs extended, where extended means cross-session memory or AI as the main purpose).

**Bot defaults for a broad-audience original game:**
- Aim for **Minimal or Mild**: cartoon violence, bodies that vanish at 0 HP, no realistic blood, no romance, no drawing canvases, not a chat-focused hangout.
- Answer **every** question (complete the questionnaire, not just Q1) so the game can reach Kids and Select.
- Implement both policy APIs if you have paid random items or trading.
- Re-submit only when an update changes an answer. Re-submitting temporarily suspends **ads eligibility** while it is reviewed.

### 7.3 Roblox Kids / Select and the publishing evaluation (live globally in 2026)

Since April 2026 (global launch later in spring/summer 2026), accounts fall into three tiers:
- **Roblox Kids** (5–8): Minimal/Mild content. Chat off by default.
- **Roblox Select** (9–15, including all self-declared 9+ accounts that haven't age-checked): up to Moderate. Chat is introduced gradually after an age check.
- **Roblox** (age-checked 16+).

**To reach players under 16, a game must pass evaluation:**

| Requirement | Kids & Select | 16+ only |
|---|---|---|
| Creator account age-checked | Yes | Yes (account at least 2 days old) |
| Verification | Facial age estimation if under 18; **government ID if 18+** | Facial estimation or ID |
| 2-Step Verification | Yes | — |
| Fee or subscription | **1,000 R$ refundable publishing fee** per game, OR an active Plus/Premium subscription held 2+ consecutive months | None |
| Evaluation | Trial phase visible only to 16+. Then **250 unique plays by "highly engaged" age-checked players within 60 days**, plus a safety review. Progress shown on the Audience Reach dashboard. | None |
| Expedited review | **50,000 R$ refundable fee** (mirror, 2026-11). It was 100,000 R$ at announcement, so it has changed. Refundable after 90 days if the game stays in good standing with 25 highly engaged players. | — |

- **The publishing fee** is refunded if the game keeps 25 highly engaged players for 60 days without moderation. It is forfeited if the game is permanently moderated.
- **Ads Manager "Engagement" objective** buys plays from age-checked highly engaged players, as a paid path toward the 250 threshold.
- **Implication for the bot's launch plan:** a new game starts **16+ only**. Plan the first 2–8 weeks around reaching 250 engaged age-checked plays (friends, community, Ads Manager), then the under-16 audience opens up.

### 7.4 Age checks and chat (2025–2026 safety changes)

- **Facial age estimation** (vendor Persona; images deleted after processing) or **ID verification** is **required to use chat**. It started in select markets in Dec 2025 and went **global on January 7, 2026**.
- **Age-based chat:** users can chat only with similar age groups. Under 9s need parental consent.
- **Social media links** on experience pages and profiles are visible only to **age-checked 16+** users. Only 16+ age-checked creators can add them.
- **Game design implications:**
  - Many players, especially under-16s on new accounts, **can't chat**. Don't make core gameplay depend on text or voice chat. Use emotes, pings, quick-chat wheels, and in-game signals.
  - Use `TextChatService` (the default chat). Don't build custom chat that bypasses filtering and age rules.
  - Any custom text displayed to others must be filtered (§7.6).

### 7.5 Paid random items (loot boxes): disclosure requirements

They apply when **Robux, or currency bought with Robux, pays for a random outcome**. This covers capsules (eggs, crates, spins), enhancements (random-duration potions, chance-based upgrades), combinations (fusing), and **probability modifiers** (luck boosts, pity systems, rate-up scrolls).

**Disclosure checklist (from the official policy):**
- [ ] List **all possible outcomes** with **numerical probability percentages**, visible **before purchase**.
- [ ] Percentages sum to **exactly 100%**. If rounded, round to at least 4 decimal places past the first non-zero digit and add the disclaimer "Probabilities are rounded; total of displayed individual probabilities may not equal 100%."
- [ ] If the list doesn't fit, use a clickable popup labeled with a **word** ("Info" or "Details"). An (i) icon alone is **not enough**.
- [ ] Items with identical odds can share one line: "Odds for each item listed below: X%".
- [ ] If an outcome can be obtained only once, **recompute the remaining odds** for that player and show them.
- [ ] Luck boosts and lucky items must **numerically explain** their effect before purchase. While active, the **displayed odds update** to the player's true odds.
- [ ] This also applies to **indirect** purchases (keys, tokens, tickets bought with Robux). Disclose before they spend the in-game currency.
- [ ] Check `ArePaidRandomItemsRestricted` and apply a treatment from §6.
- [ ] Answer the questionnaire item. **Brazil:** under-18s are ineligible for paid random items (Digital ECA). PolicyService handles this if you respect the flag.
- Random rewards earned **without** paying (a key found in the world) don't need disclosure, though disclosing odds anyway builds trust.
- Rewarded-ad rewards may **not** be random.

```lua
-- Shared odds table drives BOTH the server roll and the client disclosure UI,
-- so they can never disagree.
local EggOdds = {
	{ id = "Common",    weight = 6000 },
	{ id = "Uncommon",  weight = 2900 },
	{ id = "Rare",      weight = 900 },
	{ id = "Epic",      weight = 190 },
	{ id = "Legendary", weight = 10 },
}

local function oddsFor(luckMultiplier: number)
	-- Example boost: multiply weights of Epic+Legendary by luckMultiplier
	local list, total = {}, 0
	for _, e in EggOdds do
		local w = e.weight
		if (e.id == "Epic" or e.id == "Legendary") then w *= luckMultiplier end
		table.insert(list, { id = e.id, weight = w })
		total += w
	end
	for _, e in list do e.percent = e.weight / total * 100 end -- show with 2-4 decimals
	return list, total
end

local rng = Random.new()
local function roll(luckMultiplier: number): string -- SERVER ONLY
	local list, total = oddsFor(luckMultiplier)
	local r = rng:NextNumber(0, total)
	for _, e in list do
		r -= e.weight
		if r <= 0 then return e.id end
	end
	return list[#list].id
end
```

### 7.6 Text filtering

Filter anything one player types that others can see: pet names, plot names, sign text, guild names, trade notes, custom titles.
- `TextService:FilterStringAsync(text, fromUserId)` → `TextFilterResult`.
- Then `:GetNonChatStringForBroadcastAsync()` for text everyone sees, or `:GetNonChatStringForUserAsync(toUserId)` for text one user sees.
- Filter on the server, **after** submit (not per keystroke). pcall it. If filtering fails, show nothing (or hashtags), never the raw text.
- **Re-filter stored text when you display it again**, because filter rules change over time.
- Text from external web sources and random word generators must also be filtered.

### 7.7 Off-platform links, advertising, and "free Robux"

- **Inside the game:** no URLs, social handles, Discord invites, or QR codes. Allowed: "Follow us. Links on our game's page."
- Social links go only in the experience page's **Social Links** section.
- Don't create games whose purpose is to send users off Roblox.
- **Never** promise free Robux, use "Robux giveaway" titles, or make fake "claim Robux" UI. This is a scam pattern. It is also demoted by discovery ("Leading with giveaways").
- **Independent ads** inside your game (brand content you place yourself) require clear "Ad" disclosure. They must be gated with `AreAdsAllowed` (hide, replace, or remove ineligible users), and **must not copy Roblox's official ad labels**. Rewarded video ads are shown only to users 13+.
- **Ad fraud** (bots, forced views, incentivized impression inflation) → loss of payouts and suspension.

### 7.8 Gambling

- **Not allowed:** any game of chance wagering real money, Robux, or **items of value**. This includes simulated casinos where Robux-bought chips or currency are bet (slots, roulette, coin flip for items, case battles for tradable items).
- **Allowed with disclosure:** unplayable depictions (a casino backdrop, NPCs playing cards that players can't bet on). Report these in the questionnaire (Moderate or Restricted).
- **Allowed:** paid random items **with odds disclosure and policy gating** (§7.5). The difference: a loot box gives the item; gambling stakes something of value on an outcome.
- Bot rule: **no "bet your coins/pets" mechanics** if those coins or pets can be bought with Robux or traded. Keep chance mechanics to disclosed eggs and crates.

### 7.9 Intellectual property (DMCA)

- Roblox removes infringing content and **suspends or terminates repeat infringers**. Rights holders file copyright (DMCA) and trademark notices. EU users can file under the DSA. Crediting the owner or not monetizing **does not** make infringement OK.
- Never use: other games' names or logos, anime/movie/game characters, brand logos, celebrity likenesses, copyrighted music (use Roblox's licensed audio library or original music), or ripped models and textures.
- Thumbnails and icons must not imitate a popular game's art to steal clicks.
- If your own original game is copied, use the Rights Manager / IP reporting flow (`production/publishing/rights-manager.md`, `ip-guidelines.md`).
- Licensed IP is possible through Roblox's IP licensing program (`ip-licensing/`), but it isn't the bot's default.

### 7.10 Privacy and data

- Don't ask for or display personal information (real names, addresses, phone numbers, schools, ages, photos). Don't build "tell us your age/location" features.
- Store only what gameplay needs. Use `profile:AddUserId(userId)` (ProfileStore) so **Right-to-Be-Forgotten** deletion requests can find player data (`production/publishing/RTBF-and-creators.md`). Process RTBF requests when Roblox sends them.
- Don't send player data to external servers via HttpService unless necessary. If you do, disclose it and follow the ToS. Never collect credentials.

### 7.11 Misleading metadata and thumbnails

- The thumbnail, title, and description **must match the gameplay**. Discovery demotes "mismatched metadata" (a dinosaur thumbnail on a generic obby), and it can be moderated.
- No fake UI promising rewards, no "UPDATE!!" spam titles, no keyword stuffing ("OBBY OBBY OBBY"), no emoji walls, and no frequent renames.
- Thumbnail videos must reflect real gameplay. In-game UI text in them is fine.
- If you use thumbnail personalization (multiple Home thumbnails), every variant must be accurate.

### 7.12 Compliance checklist (before every public release)

- [ ] Maturity & Compliance Questionnaire completed (all questions), and answers match the current build
- [ ] `ProcessReceipt` implemented once, idempotent, covering all products (including the ad reward)
- [ ] No hard-coded prices; all from `GetProductInfoAsync`
- [ ] PolicyService gates: random items, paid trading, ads, subscriptions, sharing
- [ ] Odds disclosed for all paid random items, with boosted odds shown live
- [ ] All player-authored text filtered; no custom chat that bypasses TextChatService
- [ ] No off-platform links, handles, QR codes, or "free Robux"
- [ ] No gambling with Robux-bought or tradable value
- [ ] All assets, names, and music original or properly licensed
- [ ] Thumbnails and description accurate; custom thumbnail uploaded
- [ ] Core gameplay works without chat
- [ ] Ad placements disclosed; no damage during ads; rewards not random

---

## 8. Launch: the experience page

### 8.1 Assets and metadata spec

| Element | Spec / best practice |
|---|---|
| **Title** | Short, memorable, includes the genre word players search for ("Dragon Tycoon", "Lava Escape Obby"). At most one or two emojis. **Keep it stable** (renames lose search memory). No spam or repeated words. Original, not a copy of a hit game's name. |
| **Icon** | **512×512** square (it's shown down to ~150×150). One bold subject, high contrast, readable at small size, minimal text. Original art. |
| **Thumbnails** | Up to **10** images/videos. **16:9, 1920×1080**, <3 MB for personalization uploads. Formats: jpg/png/gif/tga/bmp. The first image is the most important. **A custom thumbnail is required for Home recommendations.** Show real gameplay moments, characters, and bright color, with little text. |
| **Video** | Short, real gameplay, first 3 seconds show the core fun. Moderated. |
| **Description** (≤1,000 characters) | Structure: **Hook** (first ~160 characters: title, genre, unique feature, primary keywords; these become search snippets) → *Recent update* (optional) → **Main content** (core loop, key selling points) → **Additional info** (devices, codes, short FAQ). **No hashtags or tags** (unused by ranking). Don't list controls (teach them in game). All-ages appropriate. |
| **Genre** | Pick accurately (`experience-genres.md`). It affects discovery and benchmarks. |
| **Devices** | Enable Phone/Tablet/Desktop/Console/VR only when the game actually works there. |
| **Social links** | Discord/YouTube/X/Guilded in the Social Links section (visible to 16+ age-checked users). |
| **Maturity label** | Generated by the questionnaire and displayed on the page. |
| **Passes and subscriptions** | Shown on the page. Give each a custom icon and a clear name and description. |
| **Events** | Experience Events (scheduled) appear on the page and in notifications. |

**"SEO" on Roblox:**
- Search is now **semantic**: natural-language queries work in all supported languages.
- Relevance comes from the title, description, genre, and *behavior* (does the searcher play and stay).
- Put the 2–4 most natural search phrases in the title and the first sentence ("tycoon", "simulator", "obby", "horror", "roleplay").
- Don't stuff keywords; spam leads to demotion.
- Localize the title and description (Creator Hub localization) for big markets (Spanish, Portuguese, etc.).

### 8.2 Pre-launch testing

- **Friends preview:** before public release you can invite **up to 10 similar-aged friends** to play a private game.
- **Private/limited release + private servers:** test multiplayer, purchases (mocked in Studio, real on live), and data saving.
- **Team Test / Studio test servers** with 2–8 clients for replication and race conditions (trading, receipts).
- **Paid access closed beta** (25–1000 R$): optional. Tell buyers it's a beta. Remove paid access at public launch (it can't coexist with private servers).
- **Early-access/beta place**: a separate place or universe for risky updates. Only migrate data forward and keep a separate DataStore scope.
- **Soft launch checklist:**
  - [ ] Data saves across rejoin, server hop, and shutdown (`BindToClose`)
  - [ ] Every product buy-tested on live with a cheap price, then repriced
  - [ ] Mobile UI tested on a real phone
  - [ ] Error report dashboard clean
  - [ ] Analytics funnels firing (onboarding steps)

### 8.3 Badges

- **5 free badges per game per 24 hours (GMT).** Extras cost 100 R$ each.
- Use them for onboarding milestones ("Finished tutorial"), mastery goals, secret finds, and events. They give players goals and give you funnel data (badge award rate).
- Award them on the server with `BadgeService:AwardBadgeAsync(userId, badgeId)` in a pcall. Check `UserHasBadgeAsync` first to avoid wasted calls.

### 8.4 Launch-week sequence (bot recommendation)

1. **T-14 days:**
   - Questionnaire done; age-check, ID verify, and 2FA on the publishing account. Decide on the Plus subscription vs the 1,000 R$ fee for Kids/Select reach.
   - Icon, 5+ thumbnails, and description ready.
   - Community group and Discord created.
2. **T-7:** private test with friends and testers. Fix onboarding bounce (target first-session length >10 minutes). Set up Share Links for every external post (Creator Rewards attribution).
3. **Launch (Fri/Sat, when Roblox traffic peaks on weekends):**
   - Make public.
   - Post on socials using Share Links.
   - Start a small **Ads Manager "Plays"** campaign to collect signal. Even a small number of players can trigger "explore" distribution from Recommended for You.
4. **Week 1–2:** watch D1 retention, bounce, and playtime daily. Ship small fixes fast. **Engagement**-objective ads if needed for the 250 highly engaged age-checked plays.
5. **Week 3+:** first content update with an update log. Experience Event. Notifications for opted-in players.

---

## 9. Promotion and community

### 9.1 Roblox ad products (2026)

| Product | Where it shows | Notes |
|---|---|---|
| **Sponsored games** | "Sponsored" sort on Home | Managed in **Ads Manager** (`create.roblox.com/advertise`). Objectives include **Plays/Visits**, **Earnings** (likely spenders), and **Engagement** (age-checked highly engaged players, toward Kids/Select eligibility, higher cost per play). Audiences: new, recent, lapsed. Auto-bidding. |
| **Search ads** | Sponsored tiles in Search results | Bid on keywords relevant to your game. Relevance-adjusted second-price auction. Audience 13+, all regions; targeting can't be changed. |
| **Rewarded video / billboards / portals (as advertiser)** | Inside other games | Drive teleports and awareness. |
| **Sponsored items** | Marketplace | For avatar items, not games. |
| **Ad integrations** | Branded assets inside games | Must disclose: persistent HUD "Ad" label, "Ad" on the thumbnail, `AdService:RegisterDisclosureButton`, eligibility via `GetCampaignEligibilityAsync`. |

- **Ads Manager access:** 13+ with a verified email. Pay by card (18+) or **convert Robux to ad credit** (13+, irreversible, minimum 1 credit; Robux at the 18+ DevEx rate are converted first).
- Ad-acquired players **don't count** toward Recommended-for-You signals. Only organic Home players do. Ads give the algorithm a *chance to explore*, so your game's retention has to do the rest.
- **Case study (official):** Hypershot (a top-100 game) gets up to 10% of plays from Sponsored ads.
- Budget advice for a new game: start small. Optimize the creative (thumbnail A/B), and keep spending only if CPP is low **and** retention of ad cohorts is decent.

### 9.2 Influencers and creators

- Find mid-size Roblox YouTubers and TikTokers in your genre. Send a short pitch: one-sentence hook, a 30-second gameplay clip, a creator code or private server, and a launch date.
- **Video Stars program** members can earn Creator Rewards for driving new users, so your Share Link benefits both sides.
- **Star Codes** were retired (Oct 24, 2025) in favor of Creator Rewards. **[UNCERTAIN: secondary source.]**
- **Never pay with off-platform deals that break rules**, and never ask influencers to promise "free Robux". Sponsored content must be disclosed by the influencer under platform rules (FTC/ASA, etc.).
- Give influencers something to show: a secret area, a custom cosmetic, an early-access server.

### 9.3 Community: Roblox Community (group), Discord, and Talking

- **Roblox Communities (groups):**
  - Own the game with a community-owned group to make team revenue splits easy (group payouts respect the 18+ DevEx rate).
  - Group membership perks (in-game tag, small bonus) grow the community. Check with `player:IsInGroupAsync(groupId)` (`IsInGroup`/`GetRankInGroup(Async)` are marked deprecated in the 2026 API dump).
  - Use group **announcements** for update news.
- **Discord/Guilded server:** link it **only** from the experience page's Social Links. Run channels for update logs, bug reports, suggestions, and trading (with anti-scam rules).
- **Update logs:** keep a short in-game "What's new" panel and post the same text in the description's "Recent updates" line and on Discord. Use version numbers. Name the fun parts ("New: Volcano Island + 12 pets"), not just "bug fixes".
- **Experience Events and notifications:** schedule events (opt-in reminders). Use `ExperienceNotificationService` prompts for opt-in. Send timely, personal notifications (a friend beat your score, your crops are ready) without spamming.
- **Invites and referrals:** `SocialService:PromptGameInvite`, invite prompts, the referral system, and **Share Links**. Co-play is a recommendation signal ("intentional co-play days").
- **Codes:** redeem codes (filtered, server-validated, one per account) posted on socials and in the description drive return visits. Don't gate codes behind off-platform actions inside the game.

---

## 10. How discovery works (what to optimize)

**Recommended for You** (Home) has two stages: **Retrieval** (engagement, retention, monetization signals), then **Ranking**. Signals are **per-user averages from organic Home players** (so small games aren't disadvantaged).

| Priority | Signal |
|---|---|
| **Most important** | **Play-through rate** (impressions → plays); **first-play bounce rate** (negative; measured at 61–180 s); **play days per user** (D1, D2–7, D8–28); **playtime per user** (capped at 60 min/user/day) |
| **Important** | Intentional co-play days per user; qualified play sessions per user; **spend days per user**; **Robux spent per user** |

**Takeaways:**
- **Thumbnail and icon drive play-through rate.**
- **The first 60–180 seconds must hook** (bounce is a negative signal): instant action, no long loading or cutscenes.
- **Players need a reason to return over days** (daily rewards, progression, social goals).
- **Monetization helps ranking when it's healthy.** Spend days count, so many small purchases from many players beat one whale.
- **Things that limit exposure:**
  - Giveaway/Robux metadata.
  - Mismatched metadata.
  - Non-unique games (copies of existing titles or place files).
  - Default thumbnail only.
- A Creator Dashboard banner warns when quality issues reduce exposure.
- **Explore and expand:** after an update you may see a burst of new users (explore). If that cohort retains, you get expanded distribution. Expect play-through rate to dip temporarily as impressions grow.
- **Other surfaces:**
  - Search (semantic).
  - Charts and Discover (top/trending).
  - Curated sorts such as **Standout Games** (hand-curated novel games; R15 and creative direction also matter for the 18+ DevEx rate).
  - Live Events.
  - Friends activity.
  - Notifications.
  - The game details page ("similar games").

---

## 11. Post-launch analytics and iteration

### 11.1 Metrics to watch (Creator Hub → Analytics)

| Metric | Definition | Rough healthy target for a new mid-core game **[heuristic, not official]** |
|---|---|---|
| **D1 retention** | % of new users who return the next day | 20%+ good, 30%+ great |
| **D7 retention** | % who return on day 7 | 5–10%+ |
| **D30 retention** | % who return on day 30 | 2–4%+ |
| **Avg session / playtime per DAU** | Minutes | 15–25+ min (and ≥10 min sessions count for Creator Rewards) |
| **First-play bounce** | Leave within ~1–3 min | As low as possible |
| **Payer conversion** | Paying users ÷ DAU (daily) | 1–5% daily is typical; watch the trend |
| **ARPPU** | Revenue ÷ paying users | Grows with price ladder depth |
| **ARPDAU** | Revenue ÷ DAU (= conversion × ARPPU) | Compare to genre benchmarks in the dashboard |
| **Creator Rewards earned** | Daily Engagement + Audience Expansion | Rises with "first 3 games of the day" habit |

**Official guidance:**
- **Low conversion** → check prices, shop visibility, item appeal, purchase-funnel friction; add welcome or first-purchase offers.
- **Low ARPPU** → add repeatable consumables, more variety, and seasonal items.
- **ARPDAU** → widen the range of price points and improve retention.
- High ARPPU with low ARPDAU means revenue is concentrated in a few players. Broaden it.

**Instrument your game:**
- **Funnel events:** `AnalyticsService:LogOnboardingFunnelStepEvent`, `LogFunnelStepEvent` for the shop funnel (open shop → view item → prompt → purchase).
- **Economy events:** `LogEconomyEvent`, §5.1.
- **Custom events:** `LogCustomEvent`.
- **Custom fields** for segmentation.
- New events can take up to 24 hours to appear.

### 11.2 A/B testing with Experiments and Configs

- **Configs** (`ConfigService`): key/value settings (string, number, boolean, JSON) editable in Creator Hub without republishing. They can be **targeted** by player attributes (new vs returning, language, etc.).
  - Global: `ConfigService:GetConfigAsync():GetValue("key")`.
  - Per player, required for experiments: `ConfigService:GetConfigForPlayerAsync(player):GetValue("key")`.
- **Experiments**: in-game (config variants) or matchmaking. Each runs **14–60 days**, with a % rollout, variants, and an optional audience target. You can't change an experiment after scheduling it, only reschedule. The goal metric can be playtime, ARPU, retention, or up to **3 custom metrics** (from custom, economy, or funnel events).
- **What to test, highest impact first:**
  1. Onboarding steps and length.
  2. When and how the starter pack is offered.
  3. Shop placement and "Best Value" labels.
  4. Daily reward values.
  5. Rewarded-ad placement (roll it out to a % of users first).
  6. Prices (or let Managed Pricing do this automatically when you have the volume).
- **Discipline:**
  - One hypothesis per experiment.
  - Pick the goal metric before starting.
  - Run at least 14 days, so weekly seasonality is covered.
  - Watch guardrails (D1/D7 retention, Like ratio) as well as revenue.
  - Don't ship a revenue win that hurts retention.

```lua
-- Server: read an experiment-controlled value per player
local ConfigService = game:GetService("ConfigService")
local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
	local ok, snapshot = pcall(ConfigService.GetConfigForPlayerAsync, ConfigService, player)
	local offerDelayMinutes = 10 -- safe default
	if ok and snapshot then
		local v = snapshot:GetValue("starter_offer_delay_min")
		if typeof(v) == "number" then offerDelayMinutes = v end
	end
	player:SetAttribute("StarterOfferDelay", offerDelayMinutes)
end)
```

### 11.3 Live-ops cadence

- **Weekly:**
  - Read the dashboards (retention by cohort, Home Recommendation signals vs benchmarks, economy sources/sinks, top products).
  - Respond to bug reports.
- **Every 2–4 weeks:** a content update (new area, pets, cosmetics, event) plus an update log plus new thumbnails. Updates are the main trigger for "explore" distribution.
- **Seasonal:** holiday events with limited cosmetics (seasonal items raise ARPPU) and season passes.
- **Never** remove or nerf things players paid for without compensation. Roblox users remember, and refunds aren't available for most Robux purchases.

---

## 12. Quick reference: numbers (verify before quoting)

| Item | Value (2026-11-05) |
|---|---|
| Creator share of passes/products/Robux subs/private servers | 70% |
| Local-currency subscription share | 70% first month, 100% after (1 R$ per $0.01 base price) |
| In-game avatar item sale: game owner commission | 40% |
| DevEx standard / US 18+ | $0.0038 / $0.0054 per Earned Robux |
| DevEx minimum | 30,000 Earned Robux; age 13+ |
| Creator Rewards daily engagement | 5 R$ per Active Spender (≥$9.99/60 days), first 3 games, 10+ min |
| Creator Rewards audience expansion | 35% of first $100 over 60 days; game needs 100+ avg DAU |
| Roblox Plus signup earnings | 250 R$/month × 3 = 750 R$ per new subscriber |
| Plus discount to buyers (Roblox-subsidized) | 10% (months 1–2), 20% (from month 3) |
| Robux transfer (Plus) | 10–500 R$; game earns 10% |
| Regional price bounds | 30%–100% of default |
| Price optimization volume | ~60k transactions / 30 days |
| Paid access (Robux) | 25–1000 R$ |
| Subscription min (Robux) | 49 R$; price change every 60 days |
| Promoted pass on Buy Robux page | >49 and <801 R$ |
| Rewarded video eligibility | 13+, ID-verified, public, 2k+ unique visitors/month |
| Kids/Select publishing fee | 1,000 R$ refundable, or 2+ months of Plus/Premium |
| Kids/Select evaluation | 250 unique highly engaged age-checked plays in 60 days |
| Expedited review | 50,000 R$ refundable (was 100k at announcement) |
| Free badges | 5 per game per 24 h, then 100 R$ each |
| Icon / thumbnail | 512×512 / 1920×1080 16:9, up to 10 |
| Description hook | First ~160 characters; total ≤1,000 characters |
| Chat age check | Required globally since 2026-01-07 |
| Restricted label | Age-verified 18+ (was 17+ before 2025) |
| Cross-game pass/product sales | Disabled since ~2026-05-29/30 |
| Premium Payouts | Deprecated 2025-07-24 → Creator Rewards |

---

## Sources

**Local official docs mirror** (`/home/user/Roblox/.sources/Roblox_creator-docs/content/en-us`, commit dated 2026-11-05; same content as `reference/creator-docs`):
- `production/monetization/`: `index.md`, `passes.md`, `developer-products.md`, `subscriptions.md`, `private-servers.md`, `paid-access-robux.md`, `paid-access-local-currency.md`, `avatar-items.md`, `avatar-creation-token.md`, `immersive-ads.md`, `commerce-products.md`, `developer-exchange.md`, `18-plus-devex-rate.md`, `engagement-based-payouts.md`, `roblox-plus.md`, `robux-transfers.md`, `shop.md`, `managed-pricing.md`, `price-optimization.md`, `regional-pricing.md`, `paid-random-items.md`
- `creator-rewards.md`, `discovery.md`, `marketplace/marketplace-fees-and-commissions.md`
- `production/promotion/`: `content-maturity.md`, `rewarded-video-ads.md`, `ads-manager.md`, `search-ads.md`, `advertise-on-roblox.md`, `ad-integrations.md`, `comply-with-advertising-standards.md`, `social-media-links.md`
- `production/publishing/`: `kids-and-select.md`, `publish-games-and-places.md`, `descriptions.md`, `thumbnails.md`, `experience-icons.md`, `badges.md`, `ip-guidelines.md`
- `production/analytics/monetization.md`, `production/analytics/economy-events.md`, `production/experiments.md`, `production/configs.md`, `production/game-design/monetization-foundations.md`, `ui/text-filtering.md`
- `reference/engine/classes/MarketplaceService.yaml`, `PolicyService.yaml`; `reference/api/API-Dump.txt` (ReceiptType, ReceiptDecision, ProductPurchaseChannel enums)
- ProfileStore docs: `reference/libraries/MadStudioRoblox_ProfileStore/docs/devproducts/index.md`, `docs/api.md`

**Web (checked 2026-11-05; treated as data):**
- Roblox Plus: [DevForum — Introducing Roblox Plus](https://devforum.roblox.com/t/introducing-roblox-plus/4567894); [BusinessWire press release, Apr 10 2026](https://www.businesswire.com/news/home/20260410099173/en); [Tubefilter, Apr 13 2026](https://www.tubefilter.com/2026/04/13/roblox-plus-creator-payouts/amp/)
- DevEx 18+ rate: [Tubefilter, May 1 2026](https://www.tubefilter.com/2026/05/01/roblox-hikes-developer-earnings-by-42-but-only-if-they-make-games-aimed-at-adults/amp/); [Netinfluencer](https://www.netinfluencer.com/roblox-to-raise-developer-exchange-rate-for-games-aimed-at-18-plus-players-as-adult-cohort-surges/)
- Creator Rewards: [DevForum — Introducing Creator Rewards](https://devforum.roblox.com/t/introducing-creator-rewards-earn-more-by-growing-the-community/3777628); [DevForum — Creator Rewards is Live](https://devforum.roblox.com/t/creator-rewards-is-live/3838257); [Star Codes retirement (secondary)](https://www.gamingamigos.com/post/roblox-retire-star-codes-october-24-creator-rewards)
- Age checks for chat: [Roblox newsroom Nov 2025](https://corp.roblox.com/newsroom/2025/11/roblox-requires-age-checks-limits-minor-and-adult-chat); [Nasdaq/press release Jan 7 2026](https://www.nasdaq.com/press-release/roblox-requires-users-worldwide-age-check-access-chat-2026-01-07); [PC Gamer](https://www.pcgamer.com/gaming-industry/roblox-to-make-facial-age-checks-mandatory-to-access-any-chat-features-and-will-put-common-sense-limits-on-the-age-ranges-users-can-chat-within)
- Kids & Select: [Roblox newsroom Apr 2026](https://about.roblox.com/newsroom/2026/04/introducing-roblox-kids-and-select-accounts); [DevForum — Kids and Select Global Launch](https://devforum.roblox.com/t/roblox-kids-and-select-global-launch-upcoming-updates-to-eligibility-ads-manager-and-expedited-review/4685717); [DevForum — New Publishing Requirements & Evaluation Process](https://devforum.roblox.com/t/new-publishing-requirements-evaluation-process-for-games/4573166)
- Restricted 18+: [DevForum — Updating Age Requirements for 'Restricted'](https://devforum.roblox.com/t/updating-age-requirements-for-experiences-with-%E2%80%98restricted%E2%80%99-content-maturity-label/3905863); [Roblox newsroom Aug 2025 — romantic and sexual content policy](https://about.roblox.com/newsroom/2025/08/extending-roblox-policy-on-romantic-and-sexual-content); [DevForum — Strengthening Our Safety Policies and Tools](https://devforum.roblox.com/t/strengthening-our-safety-policies-and-tools/3882864)
- Cross-game sales / transfers: [PiunikaWeb, May 2026](https://piunikaweb.com/2026/05/05/roblox-disable-gamepasses-sales-players-furious/); [Axeetech Transfers guide](https://axeetech.com/how-to-transfer-robux-after-the-may-29-update/)
- Policy pages (could not be fetched from this session, so the network allowlist blocks them): Terms of Use `en.help.roblox.com/hc/articles/115004647846`, Community Standards `en.help.roblox.com/hc/articles/203313410`, Advertising Standards `.../13722260778260`, Restricted Content Policy `.../15869919570708`; [DevForum — Updates to the Roblox Terms of Use (April 2026)](https://devforum.roblox.com/t/updates-to-the-roblox-terms-of-use-april-2026/4548394); [DevForum — New Advertising Policies & Standards](https://devforum.roblox.com/t/new-advertising-policies-standards/4527365); [Brazil Digital ECA updates](https://en.help.roblox.com/hc/cs/articles/48706630819476-Brazil-Digital-ECA-Updates)
