--!strict
-- Retry: exponential backoff with jitter for web calls (DataStore, MarketplaceService, Policy,
-- Config, Http, Teleport...). Do not retry validation errors, and never retry inside
-- BindToClose past its ~30 s budget.
--
--   local ok, info = Retry.call(function()
--       return MarketplaceService:GetProductInfoAsync(id, Enum.InfoType.Product)
--   end, 3)

local Retry = {}

function Retry.call(fn: () -> ...any, attempts: number?, baseDelay: number?): (boolean, ...any)
	local maxAttempts = attempts or 5
	local delay = baseDelay or 1
	local lastErr: any = nil
	for attempt = 1, maxAttempts do
		local result = table.pack(pcall(fn))
		if result[1] then
			return table.unpack(result, 1, result.n)
		end
		lastErr = result[2]
		if attempt < maxAttempts then
			local waitTime = delay * 2 ^ (attempt - 1)
			task.wait(waitTime + math.random() * waitTime * 0.25) -- jitter avoids thundering herds
		end
	end
	return false, lastErr
end

return table.freeze(Retry)
