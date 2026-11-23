--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local describe, it, expect = JestGlobals.describe, JestGlobals.it, JestGlobals.expect

local RateLimiter = require(ReplicatedStorage.Shared.Net.RateLimiter)

describe("RateLimiter", function()
	it("allows a burst, then refills at the configured rate", function()
		local now = 0
		local limiter = RateLimiter.new({ rate = 2, burst = 3 }, function()
			return now
		end)
		expect(limiter:take("p")).toBe(true)
		expect(limiter:take("p")).toBe(true)
		expect(limiter:take("p")).toBe(true)
		expect(limiter:take("p")).toBe(false) -- bucket empty
		now = 0.5 -- +1 token at 2/s
		expect(limiter:take("p")).toBe(true)
		expect(limiter:take("p")).toBe(false)
		now = 100 -- refill is capped at burst
		for _ = 1, 3 do
			expect(limiter:take("p")).toBe(true)
		end
		expect(limiter:take("p")).toBe(false)
	end)

	it("keeps separate buckets per key and forgets keys", function()
		local now = 0
		local limiter = RateLimiter.new({ rate = 1, burst = 1 }, function()
			return now
		end)
		expect(limiter:take("a")).toBe(true)
		expect(limiter:take("a")).toBe(false)
		expect(limiter:take("b")).toBe(true)
		limiter:forget("a")
		expect(limiter:take("a")).toBe(true) -- fresh bucket after forget
	end)

	it("ignores a clock that goes backwards", function()
		local now = 10
		local limiter = RateLimiter.new({ rate = 1, burst = 1 }, function()
			return now
		end)
		expect(limiter:take("p")).toBe(true)
		now = 5
		expect(limiter:take("p")).toBe(false)
	end)

	it("rejects invalid configs", function()
		expect(function()
			RateLimiter.new({ rate = 0, burst = 1 })
		end).toThrow()
	end)
end)
