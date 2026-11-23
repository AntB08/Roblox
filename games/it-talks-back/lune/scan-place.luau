-- Static checks on a BUILT place file (no Studio needed):
--   lune run lune/scan-place build/game.rbxl
-- Fails (exit 1) on: more than one server Script / client LocalScript bootstrap, numeric
-- require(<assetId>) (free-model backdoor pattern), getfenv/setfenv/loadstring in game code,
-- missing HUD, missing Remotes definitions module, or spec files shipped in production.
local fs = require("@lune/fs")
local process = require("@lune/process")
local roblox = require("@lune/roblox")

local path = assert(process.args[1], "usage: lune run lune/scan-place <place.rbxl>")
local game = roblox.deserializePlace(fs.readFile(path))

local problems = {}
local function problem(msg: string)
	table.insert(problems, msg)
end

local serverScripts, clientScripts = 0, 0
for _, inst in game:GetDescendants() do
	if inst:IsA("LuaSourceContainer") then
		local source: string = (inst :: any).Source or ""
		local full = inst:GetFullName()
		local vendored = string.find(full, "%.Packages%.") ~= nil
		if inst.ClassName == "Script" then
			serverScripts += 1
		elseif inst.ClassName == "LocalScript" then
			clientScripts += 1
		end
		if string.find(source, "require%s*%(%s*%d+%s*%)") then
			problem(`numeric require (asset id) in {full}`)
		end
		if
			not vendored
			and (string.find(source, "getfenv") or string.find(source, "setfenv") or string.find(source, "loadstring"))
		then
			problem(`getfenv/setfenv/loadstring in {full}`)
		end
		if string.find(inst.Name, "%.spec$") then
			problem(`test file shipped in production build: {full}`)
		end
	end
end

if serverScripts ~= 1 then
	problem(`expected exactly 1 server Script, found {serverScripts}`)
end
if clientScripts ~= 1 then
	problem(`expected exactly 1 LocalScript, found {clientScripts}`)
end

local starterGui = game:GetService("StarterGui")
if not starterGui:FindFirstChild("HUD") then
	problem("StarterGui.HUD missing")
end
local shared = game:GetService("ReplicatedStorage"):FindFirstChild("Shared")
local net = shared and shared:FindFirstChild("Net")
if not (net and net:FindFirstChild("Remotes")) then
	problem("ReplicatedStorage.Shared.Net.Remotes missing")
end

if #problems > 0 then
	for _, msg in problems do
		print("PLACE CHECK FAILED: " .. msg)
	end
	process.exit(1)
end
print(`place checks passed ({serverScripts} Script, {clientScripts} LocalScript)`)
