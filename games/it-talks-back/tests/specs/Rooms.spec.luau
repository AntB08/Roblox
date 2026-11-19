--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local describe, it, expect = JestGlobals.describe, JestGlobals.it, JestGlobals.expect

local Rooms = require(ReplicatedStorage.Shared.Rooms)

-- Same numbers as tools/build_map.py
local function box(name: string, x1: number, x2: number, y1: number, y2: number, z1: number, z2: number): Rooms.Volume
	return {
		name = name,
		cframe = CFrame.new((x1 + x2) / 2, (y1 + y2) / 2, (z1 + z2) / 2),
		size = Vector3.new(x2 - x1, y2 - y1, z2 - z1),
	}
end

local volumes = {
	box("Hallway", -8, 8, 0, 12, -40, 20),
	box("Kitchen", -40, -8, 0, 12, -40, -10),
	box("Stairs", -40, -8, -1, 12, -10, 20),
	box("Study", 8, 40, 0, 12, -40, 20),
	box("Basement", -40, -8, -14, -1, -40, 20),
}
Rooms.sortBySize(volumes)

describe("Rooms", function()
	it("finds the room on each floor", function()
		expect(Rooms.find(volumes, Vector3.new(0, 3, 0))).toBe("Hallway")
		expect(Rooms.find(volumes, Vector3.new(-24, 3, -25))).toBe("Kitchen")
		expect(Rooms.find(volumes, Vector3.new(24, 3, 0))).toBe("Study")
		expect(Rooms.find(volumes, Vector3.new(-24, 3, 5))).toBe("Stairs")
	end)
	it("puts the basement under the kitchen, not in it", function()
		expect(Rooms.find(volumes, Vector3.new(-24, -10, -25))).toBe("Basement")
	end)
	it("returns nil outside the house", function()
		expect(Rooms.find(volumes, Vector3.new(0, 3, 70))).toBeNil()
	end)
	it("respects rotation", function()
		local rotated: Rooms.Volume = {
			name = "Turned",
			cframe = CFrame.Angles(0, math.rad(90), 0),
			size = Vector3.new(10, 4, 2),
		}
		expect(Rooms.contains(rotated, Vector3.new(0, 0, 4))).toBe(true)
		expect(Rooms.contains(rotated, Vector3.new(4, 0, 0))).toBe(false)
	end)
end)
