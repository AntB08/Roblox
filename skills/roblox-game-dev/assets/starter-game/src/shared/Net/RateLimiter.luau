--!strict
-- RateLimiter: token bucket per key (normally per Player). Pure module; the clock is injectable
-- so tests can drive time. Used by the server Net module for every client->server remote.
--
--   local limiter = RateLimiter.new({ rate = 4, burst = 6 })  -- 4 tokens/s, bucket of 6
--   if not limiter:take(player) then return end              -- drop spam
--   limiter:forget(player)                                    -- on PlayerRemoving

export type Config = { rate: number, burst: number }

type Bucket = { tokens: number, last: number }

local RateLimiter = {}
RateLimiter.__index = RateLimiter

export type RateLimiter = typeof(setmetatable(
	{} :: { config: Config, clock: () -> number, buckets: { [any]: Bucket } },
	RateLimiter
))

function RateLimiter.new(config: Config, clock: (() -> number)?): RateLimiter
	assert(config.rate > 0 and config.burst >= 1, "RateLimiter: rate must be > 0 and burst >= 1")
	return setmetatable({
		config = config,
		clock = clock or os.clock,
		buckets = {},
	}, RateLimiter)
end

function RateLimiter.take(self: RateLimiter, key: any): boolean
	local now = self.clock()
	local cfg = self.config
	local bucket = self.buckets[key]
	if bucket == nil then
		bucket = { tokens = cfg.burst, last = now }
		self.buckets[key] = bucket
	end
	local elapsed = math.max(0, now - bucket.last)
	bucket.tokens = math.min(cfg.burst, bucket.tokens + elapsed * cfg.rate)
	bucket.last = now
	if bucket.tokens < 1 then
		return false
	end
	bucket.tokens -= 1
	return true
end

function RateLimiter.forget(self: RateLimiter, key: any)
	self.buckets[key] = nil
end

return RateLimiter
