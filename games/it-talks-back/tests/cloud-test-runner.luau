-- Executed INSIDE a headless Roblox server by Open Cloud Luau Execution against a saved version
-- of the TEST place (built from test.project.json). Also runnable in Studio's command bar after
-- building test.project.json. NOT part of the Rojo tree, so it never ships.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DevPackages = ReplicatedStorage:WaitForChild("DevPackages", 30)
assert(DevPackages, "ReplicatedStorage.DevPackages missing: run `wally install` before building test.project.json")
local Jest = require(DevPackages:WaitForChild("Jest"))

local root = ServerScriptService:WaitForChild("Tests", 30)
assert(root, "ServerScriptService.Tests missing: build test.project.json, not default.project.json")

local status, result = Jest.runCLI(root, { ci = true, verbose = true }, { root }):awaitStatus()

if status == "Rejected" then
	error("Jest crashed: " .. tostring(result))
end

local r = result.results
-- Zero tests found is a SETUP FAILURE, not a pass.
assert(r.numTotalTests > 0, "No tests were discovered: check jest.config testMatch and the Tests root")
if not r.success then
	error(string.format("Tests failed: %d of %d", r.numFailedTests, r.numTotalTests))
end
return {
	success = r.success,
	numTotalTests = r.numTotalTests,
	numPassedTests = r.numPassedTests,
	numFailedTests = r.numFailedTests,
}
