--!strict
-- Map: lookups for the tagged markers placed by tools/build_map.py (Workspace.Map.House).
-- Server-only. Everything is found by CollectionService tag so the map can be rebuilt or edited
-- in Studio without code changes, as long as tags and attributes stay.

local CollectionService = game:GetService("CollectionService")

local Map = {}

export type Point = { part: BasePart, room: string }

local function parts(tag: string): { BasePart }
	local list = {}
	for _, inst in CollectionService:GetTagged(tag) do
		if inst:IsA("BasePart") then
			table.insert(list, inst)
		end
	end
	return list
end
Map.parts = parts

function Map.one(tag: string): BasePart
	local list = parts(tag)
	assert(#list > 0, `[Map] no part tagged "{tag}" (run tools/build_map.py?)`)
	return list[1]
end

local function points(tag: string): { Point }
	local list = {}
	for _, part in parts(tag) do
		local room = part:GetAttribute("Room")
		table.insert(list, { part = part, room = if typeof(room) == "string" then room else "Hallway" })
	end
	return list
end

function Map.patrolPoints(): { Point }
	return points("PatrolPoint")
end

function Map.fuseSpawns(): { Point }
	return points("FuseSpawn")
end

function Map.playerStarts(): { BasePart }
	local list = parts("PlayerStart")
	table.sort(list, function(a, b)
		return (tonumber(a:GetAttribute("Index")) or 0) < (tonumber(b:GetAttribute("Index")) or 0)
	end)
	return list
end

function Map.closets(): { Model }
	local list = {}
	for _, inst in CollectionService:GetTagged("Closet") do
		if inst:IsA("Model") then
			table.insert(list, inst)
		end
	end
	return list
end

function Map.lobbySpawn(): CFrame
	for _, inst in CollectionService:GetTagged("LobbySpawn") do
		if inst:IsA("BasePart") then
			return inst.CFrame + Vector3.new(0, 3, 0)
		end
	end
	return CFrame.new(0, 4, 72)
end

return Map
