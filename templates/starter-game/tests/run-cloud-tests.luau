-- Lune driver: runs tests/cloud-test-runner.luau in a real Roblox server via the Open Cloud
-- Luau Execution API against a SAVED version of the TEST place.
--   lune run tests/run-cloud-tests.luau <placeVersion>
-- Env: ROBLOX_API_KEY (test universe only: universe-places write + luau-execution-session),
--      TEST_UNIVERSE_ID, TEST_PLACE_ID.
-- [VERIFY] Endpoint paths and field names come from knowledge/12 section 3.3 (DevForum/SDK
-- sources); check the official Open Cloud reference before relying on them.
local fs = require("@lune/fs")
local net = require("@lune/net")
local process = require("@lune/process")
local serde = require("@lune/serde")
local task = require("@lune/task")

local API_KEY = assert(process.env.ROBLOX_API_KEY, "ROBLOX_API_KEY missing")
local UNIVERSE = assert(process.env.TEST_UNIVERSE_ID, "TEST_UNIVERSE_ID missing")
local PLACE = assert(process.env.TEST_PLACE_ID, "TEST_PLACE_ID missing")
local version = assert(process.args[1], "usage: lune run tests/run-cloud-tests.luau <placeVersion>")

local BASE = "https://apis.roblox.com/cloud/v2/"

local function call(method: string, url: string, body: any?): any
	local res = net.request({
		url = url,
		method = method :: any,
		headers = { ["x-api-key"] = API_KEY, ["Content-Type"] = "application/json" },
		body = if body then serde.encode("json", body) else nil,
	})
	if not res.ok then
		error(string.format("%s %s -> %d %s", method, url, res.statusCode, res.body))
	end
	return serde.decode("json", res.body)
end

local source = fs.readFile("tests/cloud-test-runner.luau")
local created = call(
	"POST",
	string.format("%suniverses/%s/places/%s/versions/%s/luau-execution-session-tasks", BASE, UNIVERSE, PLACE, version),
	{ script = source, timeout = "300s" }
)
local path = created.path
print("Task:", path)

local info
local deadline = os.clock() + 360
repeat
	task.wait(3)
	info = call("GET", BASE .. path)
	print("state:", info.state)
until info.state == "COMPLETE" or info.state == "FAILED" or info.state == "CANCELLED" or os.clock() > deadline

local ok, logs = pcall(call, "GET", BASE .. path .. "/logs")
if ok and logs.luauExecutionSessionTaskLogs then
	for _, page in logs.luauExecutionSessionTaskLogs do
		for _, line in page.messages or {} do
			print(line)
		end
	end
end

if info.state ~= "COMPLETE" then
	print("FAILED:", if info.error then info.error.message else info.state)
	process.exit(1)
end
print("Results:", serde.encode("json", if info.output then info.output.results else {}))
process.exit(0)
