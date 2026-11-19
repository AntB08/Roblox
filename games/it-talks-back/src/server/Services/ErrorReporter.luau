--!strict
-- ErrorReporter: catches unhandled server errors (ScriptContext.Error) and validated client
-- reports (ClientError remote), dedupes them by a normalized signature, rate-limits them, and
-- records one analytics event per signature window. The Creator Hub Error Report dashboard stays
-- the source of truth; this adds version/platform breakdowns. Never forward PII.

local Players = game:GetService("Players")
local ScriptContext = game:GetService("ScriptContext")

local Net = require(script.Parent.Parent.Net)
local Analytics = require(script.Parent.Analytics)

local MAX_PER_SIGNATURE_PER_MIN = 5
local PLACE_VERSION = tostring(game.PlaceVersion)

type Window = { count: number, windowStart: number }

local ErrorReporter = {}
ErrorReporter.Priority = 190 -- right after Analytics, before gameplay services

local seen: { [string]: Window } = {}

-- Strips numbers and quoted strings so "Part123 is nil" and "Part456 is nil" group together.
function ErrorReporter.signature(message: string, stack: string?): string
	local firstFrame = if stack then (string.match(stack, "^[^\n]+") or "") else ""
	local s = message .. " @ " .. firstFrame
	s = string.gsub(s, "%d+", "#")
	s = string.gsub(s, '"[^"]*"', '"*"')
	return string.sub(s, 1, 100) -- short + low-cardinality for the analytics custom field
end

local function shouldReport(sig: string): boolean
	local now = os.clock()
	local entry = seen[sig]
	if not entry or now - entry.windowStart > 60 then
		seen[sig] = { count = 1, windowStart = now }
		return true
	end
	entry.count += 1
	return entry.count <= MAX_PER_SIGNATURE_PER_MIN
end

local function record(
	kind: "ServerError" | "ClientError",
	player: Player?,
	message: string,
	stack: string?,
	platform: string
)
	local sig = ErrorReporter.signature(message, stack)
	if not shouldReport(sig) then
		return
	end
	-- AnalyticsService needs a Player: for server errors use any connected player as carrier.
	local carrier = player or Players:GetPlayers()[1]
	if carrier then
		Analytics.custom(carrier, kind, 1, sig, `v{PLACE_VERSION}`, platform)
	end
	if kind == "ClientError" then
		-- Server errors are already in the output; only echo client ones.
		warn(`[ErrorReporter] {kind} v{PLACE_VERSION} {platform}: {message}`)
	end
end

function ErrorReporter:Init()
	ScriptContext.Error:Connect(function(message: string, stackTrace: string, _script: Instance?)
		record("ServerError", nil, message, stackTrace, "server")
	end)

	-- Args validated + rate-limited by Net (see Remotes.ClientError).
	Net.handle("ClientError", function(player: Player, message: string, stack: string?, platform: string)
		record("ClientError", player, message, stack, platform)
	end)

	-- Bound memory: forget old signatures every few minutes.
	task.spawn(function()
		while true do
			task.wait(300)
			local now = os.clock()
			for sig, entry in seen do
				if now - entry.windowStart > 120 then
					seen[sig] = nil
				end
			end
		end
	end)
end

return ErrorReporter
