--!strict
-- StoreController: binds HUD buttons that carry a "Product" attribute (a key of
-- Products.DevProducts) to a Robux purchase prompt.
--   * Prices are read LIVE with GetProductInfoAsync (regional pricing / price tests / discounts),
--     never hard-coded. If the price can't be read, the label stays empty and the button still
--     works (the prompt shows the real price).
--   * Products with id 0 (not created yet) hide their button.
--   * Prompt only in response to a tap. The grant happens on the server in PurchaseService's
--     ProcessReceipt; PromptProductPurchaseFinished is NOT proof of purchase.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Products = require(Shared.Config.Products)
local Retry = require(Shared.Util.Retry)

local Client = script.Parent.Parent
local Hud = require(Client.UI.Hud)
local AnimatedButton = require(Client.UI.AnimatedButton)

local StoreController = {}

local priceCache: { [string]: number } = {}

-- Live, per-player price in Robux (nil if unavailable). Yields.
function StoreController.getPrice(id: number, infoType: Enum.InfoType): number?
	local key = `{infoType.Name}:{id}`
	local cached = priceCache[key]
	if cached then
		return cached
	end
	local ok, info = Retry.call(function()
		return MarketplaceService:GetProductInfoAsync(id, infoType)
	end, 3)
	if ok and typeof(info) == "table" and typeof(info.PriceInRobux) == "number" then
		priceCache[key] = info.PriceInRobux
		return info.PriceInRobux
	end
	return nil
end

local function bindProductButton(button: GuiButton, productKey: string)
	local product = (Products.DevProducts :: any)[productKey] :: Products.DevProduct?
	if not product or not Products.isConfigured(product.id) then
		button.Visible = false -- no product id yet: hide instead of showing a broken offer
		return
	end
	local priceLabel = button:FindFirstChild("PriceLabel")
	task.spawn(function()
		local price = StoreController.getPrice(product.id, Enum.InfoType.Product)
		if price and priceLabel and priceLabel:IsA("TextLabel") then
			priceLabel.Text = `R$ {price}`
		end
	end)
	AnimatedButton.wrap(button, {
		onActivated = function()
			MarketplaceService:PromptProductPurchase(Players.LocalPlayer, product.id)
		end,
	})
end

function StoreController:Start()
	local hud = Hud.get()
	for _, d in hud:GetDescendants() do
		local productKey = d:GetAttribute("Product")
		if d:IsA("GuiButton") and typeof(productKey) == "string" then
			bindProductButton(d, productKey)
		end
	end
end

return StoreController
