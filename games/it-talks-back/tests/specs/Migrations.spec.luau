--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local describe, it, expect = JestGlobals.describe, JestGlobals.it, JestGlobals.expect

local DataSchema = require(ServerScriptService.Server.Data.Schema)

local function deepCopy(t: any): any
	if typeof(t) ~= "table" then
		return t
	end
	local c = {}
	for k, v in t do
		c[k] = deepCopy(v)
	end
	return c
end

describe("DataSchema", function()
	it("template is at the current version", function()
		expect(DataSchema.TEMPLATE.Version).toBe(DataSchema.VERSION)
	end)

	it("has a migration step for every version below current", function()
		for v = 1, DataSchema.VERSION - 1 do
			expect(DataSchema.MIGRATIONS[v]).toBeDefined()
		end
	end)

	it("leaves up-to-date data untouched", function()
		local data = deepCopy(DataSchema.TEMPLATE)
		data.Coins = 42
		local result, from = DataSchema.migrate(data)
		expect(result).toBe("UpToDate")
		expect(from).toBe(DataSchema.VERSION)
		expect(data.Coins).toBe(42)
	end)

	it("migrates v1 data (Cash + boolean Music) to the current version", function()
		local v1 = { Version = 1, Cash = 120, Coins = 5, Settings = { Music = false } }
		local result, from = DataSchema.migrate(v1)
		expect(result).toBe("Migrated")
		expect(from).toBe(1)
		expect(v1.Version).toBe(DataSchema.VERSION)
		expect(v1.Coins).toBe(125)
		expect(v1.Cash).toBeNil()
		expect(v1.Settings.MusicVolume).toBe(0)
		expect(v1.Settings.Music).toBeNil()
	end)

	it("treats data without a Version as v1", function()
		local legacy = { Cash = 10, Settings = { Music = true } }
		local result = DataSchema.migrate(legacy)
		expect(result).toBe("Migrated")
		expect(legacy.Coins).toBe(10)
		expect(legacy.Settings.MusicVolume).toBe(0.6)
	end)

	it("survives missing optional tables in old data", function()
		local v1 = { Version = 1 }
		expect(function()
			DataSchema.migrate(v1)
		end).never.toThrow()
		expect(v1.Coins).toBe(0)
	end)

	it("refuses to touch data saved by a newer version", function()
		local future = { Version = DataSchema.VERSION + 1, Coins = 99, NewField = true }
		local result, from = DataSchema.migrate(future)
		expect(result).toBe("FromFuture")
		expect(from).toBe(DataSchema.VERSION + 1)
		expect(future.Version).toBe(DataSchema.VERSION + 1)
		expect(future.NewField).toBe(true)
	end)

	it("template contains only JSON-safe values", function()
		local function check(t: any, path: string)
			for k, v in t do
				expect(typeof(k)).toBe("string")
				local kind = typeof(v)
				if kind == "table" then
					check(v, path .. "." .. k)
				else
					expect(kind == "number" or kind == "string" or kind == "boolean").toBe(true)
				end
			end
		end
		check(DataSchema.TEMPLATE, "Data")
	end)
end)
