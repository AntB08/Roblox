--!strict
-- Products: Robux developer products and game passes. IDs come from Creator Hub
-- (Monetization > Developer Products / Passes). An id of 0 means "not created yet": the server
-- ignores it and the client hides the buy button.
--
-- PRICES ARE NOT STORED HERE. They are read live with MarketplaceService:GetProductInfoAsync,
-- because regional pricing, price tests and subscriber discounts change what each player pays.
-- `coins` is the grant amount, enforced on the server by PurchaseService.

export type DevProduct = { id: number, coins: number? }
export type Pass = { id: number }

local Products = {
	DevProducts = {
		Coins100 = { id = 0, coins = 100 } :: DevProduct, -- SET ID before publishing
	},
	Passes = {
		VIP = { id = 0 } :: Pass, -- SET ID before publishing; perk applied in PurchaseService
	},
}

function Products.isConfigured(id: number): boolean
	return id > 0
end

return table.freeze(Products)
