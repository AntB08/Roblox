--!strict
-- PurchaseService: ALL Robux purchase handling.
--
-- Developer products: the ONE AND ONLY MarketplaceService.ProcessReceipt assignment in the game.
--   * Idempotent: each PurchaseId is stored in profile.Data.PurchaseIdCache IN THE SAME SAVE as
--     the reward. A redelivered receipt (rejoin, server hop, crash) finds it and grants nothing.
--   * PurchaseGranted is returned only after profile.LastSavedData contains the PurchaseId.
--   * Two servers at once: ProfileStore's session lock means only one has an active profile; the
--     other returns NotProcessedYet. Unknown products return NotProcessedYet (never auto-lost).
--   * Grants come from Shared/Config/Products.luau (server's copy), never from the client.
-- Game passes: ownership checked on the server at join (pcall + retry), cached per session,
--   mirrored to player attribute Pass_<Name> for UI, updated from the SERVER-side
--   PromptGamePassPurchaseFinished.
-- Prices: never stored. The client reads them live (StoreController -> GetProductInfoAsync).

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(script.Parent.Parent.Net)
local DataService = require(script.Parent.DataService)
local Analytics = require(script.Parent.Analytics)

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Products = require(Shared.Config.Products)
local GameConfig = require(Shared.Config.GameConfig)
local Retry = require(Shared.Util.Retry)

type Grant = (data: DataService.Data) -> ()

local PurchaseService = {}

-- ===== Developer products ==============================================================
-- productId -> { sku, grant }. Grants mutate profile Data ONLY (no yields, no instances).
local grants: { [number]: { sku: string, grant: Grant } } = {}

local function buildGrants()
	for sku, product in Products.DevProducts do
		if Products.isConfigured(product.id) then
			local coins = product.coins
			if coins then
				grants[product.id] = {
					sku = sku,
					grant = function(data: DataService.Data)
						data.Coins += coins
					end,
				}
			else
				warn(`[PurchaseService] product {sku} has no grant defined`)
			end
		end
	end
end

local function isSaved(profile: any, purchaseId: string): boolean
	local saved = profile.LastSavedData and profile.LastSavedData.PurchaseIdCache
	return saved ~= nil and table.find(saved, purchaseId) ~= nil
end

local function processReceipt(receipt: { [string]: any }): Enum.ProductPurchaseDecision
	local player = Players:GetPlayerByUserId(receipt.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet -- redelivered when they next join
	end

	local entry = grants[receipt.ProductId]
	if not entry then
		warn(`[PurchaseService] unknown product {receipt.ProductId}; leaving receipt open`)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	if DataService.waitFor(player) == nil then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local profile = DataService.getProfile(player)
	if not profile or not profile:IsActive() then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local purchaseId = tostring(receipt.PurchaseId)
	local data = profile.Data
	local cache = data.PurchaseIdCache
	local newlyGranted = false

	if table.find(cache, purchaseId) == nil then
		local ok, err = pcall(entry.grant, data)
		if not ok then
			warn(`[PurchaseService] grant failed {purchaseId}:`, err)
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		while #cache >= GameConfig.PurchaseIdCacheSize do
			table.remove(cache, 1)
		end
		table.insert(cache, purchaseId)
		local spent = tonumber(receipt.CurrencySpent) or 0
		data.Stats.RobuxSpent += spent
		newlyGranted = true

		DataService.refreshCoins(player)
		local product = (Products.DevProducts :: any)[entry.sku]
		if product and product.coins then
			Analytics.source(
				player,
				GameConfig.Currency,
				product.coins,
				data.Coins,
				Enum.AnalyticsEconomyTransactionType.IAP,
				entry.sku
			)
		end
	end

	-- Wait until the purchase is durably saved, then acknowledge.
	while profile:IsActive() do
		if isSaved(profile, purchaseId) then
			if newlyGranted and player.Parent == Players then
				Net.notify(player, "Purchase complete. Thank you!", "success")
			end
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
		local before = profile.LastSavedData
		profile:Save()
		if profile.LastSavedData == before then
			(profile.OnAfterSave :: any):Wait()
		end
		if not isSaved(profile, purchaseId) and profile:IsActive() then
			task.wait(10) -- DataStore trouble: keep trying while the session lives
		end
	end
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

-- ===== Game passes =====================================================================
local ownedPasses: { [Player]: { [number]: boolean } } = {}

local function applyPass(player: Player, name: string, passId: number)
	local owned = ownedPasses[player]
	if not owned or owned[passId] then
		return
	end
	owned[passId] = true
	player:SetAttribute(`Pass_{name}`, true)
	Analytics.custom(player, "PassOwned", 1, name)
	-- Server-side perks go here (e.g. VIP: extra daily coins). Keep perks cosmetic/convenience,
	-- never pay-to-win against other players.
end

local function checkPasses(player: Player)
	if ownedPasses[player] then
		return
	end
	ownedPasses[player] = {}
	for name, pass in Products.Passes do
		if Products.isConfigured(pass.id) then
			task.spawn(function()
				local ok, owns = Retry.call(function()
					return MarketplaceService:UserOwnsGamePassAsync(player.UserId, pass.id)
				end, 3)
				if ok and owns == true and player.Parent == Players then
					applyPass(player, name, pass.id)
				end
				-- On failure: fail closed for now; ownership is re-checked next join.
			end)
		end
	end
end

local function passNameFor(passId: number): string?
	for name, pass in Products.Passes do
		if pass.id == passId then
			return name
		end
	end
	return nil
end

-- Server-side truth for gameplay code.
function PurchaseService.ownsPass(player: Player, name: string): boolean
	local pass = (Products.Passes :: any)[name]
	local owned = ownedPasses[player]
	return pass ~= nil and owned ~= nil and owned[pass.id] == true
end

-- ===== Lifecycle =======================================================================
function PurchaseService:Init()
	buildGrants()
	-- THE ONLY ProcessReceipt assignment in the game. Do not add another anywhere.
	MarketplaceService.ProcessReceipt = processReceipt

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(
		function(player: Instance, passId: number, wasPurchased: boolean)
			if not wasPurchased or not player:IsA("Player") then
				return
			end
			local name = passNameFor(passId)
			if name then
				applyPass(player, name, passId)
				Net.notify(player, "Pass unlocked. Thank you!", "success")
			end
		end
	)
end

function PurchaseService:Start()
	Players.PlayerAdded:Connect(checkPasses)
	Players.PlayerRemoving:Connect(function(player)
		ownedPasses[player] = nil
	end)
	for _, player in Players:GetPlayers() do
		task.spawn(checkPasses, player)
	end
end

return PurchaseService
