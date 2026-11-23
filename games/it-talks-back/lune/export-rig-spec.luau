--!nocheck
-- Writes build/rig_spec.json: the monster rig (parts, joints, decor) from MonsterRig.SPEC, for the
-- Python mesh generator (tools/build_monster_mesh.py) and preview renders.
--   lune run lune/export-rig-spec
local fs = require("@lune/fs")
local luau = require("@lune/luau")
local roblox = require("@lune/roblox")
local serde = require("@lune/serde")

local env = {
	Instance = roblox.Instance,
	CFrame = roblox.CFrame,
	Vector3 = roblox.Vector3,
	Color3 = roblox.Color3,
	Enum = roblox.Enum,
	table = table,
	math = math,
	string = string,
}
local Rig = luau.load(fs.readFile("src/server/Game/MonsterRig.luau"), { environment = env })()
local function cf(c)
	return { c:GetComponents() }
end
local function v(x)
	return { x.X, x.Y, x.Z }
end
local function col(c)
	return { c.R, c.G, c.B }
end
local out = { parts = {}, joints = {}, decor = {}, hipHeight = Rig.SPEC.hipHeight }
for _, p in Rig.SPEC.parts do
	table.insert(out.parts, { name = p.name, size = v(p.size), color = col(p.color), shape = p.shape })
end
for _, j in Rig.SPEC.joints do
	table.insert(out.joints, { name = j.name, part0 = j.part0, part1 = j.part1, c0 = cf(j.c0), c1 = cf(j.c1) })
end
for _, d in Rig.SPEC.decor do
	table.insert(out.decor, {
		name = d.name,
		attach = d.attach,
		offset = cf(d.offset),
		size = v(d.size),
		color = col(d.color),
		shape = d.shape,
		neon = d.material == roblox.Enum.Material.Neon,
	})
end
fs.writeDir("build")
fs.writeFile("build/rig_spec.json", serde.encode("json", out, true))
print(`wrote build/rig_spec.json ({#out.parts} parts, {#out.joints} joints)`)
