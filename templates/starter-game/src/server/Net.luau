--!strict
-- Net (server): creates every remote declared in Shared/Net/Remotes.luau, and wraps every
-- client->server handler with: per-player token-bucket rate limit -> argument validation (Guard)
-- -> xpcall'd handler. Malformed payloads are counted; repeated abuse kicks the player.
--
--   Net.handle("Collect", function(player, node) ... end)        -- ToServer Event
--   Net.handle("ClaimDaily", function(player) return result end) -- ToServer Function
--   Net.fire("Notify", player, "Saved!", "success")              -- ToClient
--   Net.fireAll("Notify", "Event starting", "info")
--
-- The server NEVER calls InvokeClient. Server->client messages are RemoteEvents.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Guard = require(Shared.Net.Guard)
local RateLimiter = require(Shared.Net.RateLimiter)
local Remotes = require(Shared.Net.Remotes)

local VIOLATION_KICK_THRESHOLD = 30 -- malformed payloads per session before a kick
local DEFAULT_RATE: RateLimiter.Config = { rate = 10, burst = 20 }

local Net = {}

local folder: Folder? = nil
local instances: { [string]: Instance } = {}
local limiters: { [string]: RateLimiter.RateLimiter } = {}
local handled: { [string]: boolean } = {}
local violations: { [Player]: number } = {}

local function flag(player: Player, name: string, reason: string)
	local n = (violations[player] or 0) + 1
	violations[player] = n
	warn(`[Net] {player.Name} ({player.UserId}) {name}: {reason} (#{n})`)
	if n >= VIOLATION_KICK_THRESHOLD then
		player:Kick("Unexpected network activity. Please rejoin.")
	end
end

-- Creates ReplicatedStorage.Remotes and every remote in Remotes.luau. Idempotent.
-- Called by the server bootstrap BEFORE services load, so clients can WaitForChild them.
function Net.createAll()
	if folder then
		return
	end
	local f = Instance.new("Folder")
	f.Name = "Remotes"
	for name, def in Remotes do
		local className = if def.kind == "Event"
			then "RemoteEvent"
			elseif def.kind == "Unreliable" then "UnreliableRemoteEvent"
			else "RemoteFunction"
		local remote = Instance.new(className)
		remote.Name = name
		remote.Parent = f
		instances[name] = remote
		if def.direction == "ToServer" then
			assert(def.args ~= nil, `[Net] ToServer remote "{name}" must declare args`)
			limiters[name] = RateLimiter.new(def.rate or DEFAULT_RATE)
		end
	end
	f.Parent = ReplicatedStorage -- parent last: clients see a complete folder
	folder = f

	Players.PlayerRemoving:Connect(function(player)
		violations[player] = nil
		for _, limiter in limiters do
			limiter:forget(player)
		end
	end)
end

local function getDef(name: string): Remotes.Def
	local def = Remotes[name]
	assert(def, `[Net] unknown remote "{name}" (declare it in Shared/Net/Remotes.luau)`)
	assert(folder, "[Net] Net.createAll() has not run")
	return def
end

-- Registers the ONE handler for a ToServer remote. For Functions, the handler's return values
-- are sent back. Returns nothing to the client when rate-limited or invalid (Functions return
-- nil, which client code must treat as failure).
function Net.handle(name: string, handler: (Player, ...any) -> ...any)
	local def = getDef(name)
	assert(def.direction == "ToServer", `[Net] "{name}" is not a ToServer remote`)
	assert(not handled[name], `[Net] "{name}" already has a handler`)
	handled[name] = true

	local checks = def.args :: { Guard.Check }
	local limiter = limiters[name]
	local remote = instances[name]

	local function admit(player: Player, ...: any): boolean
		if not limiter:take(player) then
			return false -- silently drop spam (not counted as a violation)
		end
		local ok, reason = Guard.args(checks, ...)
		if not ok then
			flag(player, name, reason or "invalid")
			return false
		end
		return true
	end

	if def.kind == "Function" then
		(remote :: RemoteFunction).OnServerInvoke = function(player: Player, ...: any): ...any
			if not admit(player, ...) then
				return nil
			end
			local results = table.pack(xpcall(handler, debug.traceback, player, ...))
			if not results[1] then
				warn(`[Net] {name} handler errored for {player.Name}\n{results[2]}`)
				return nil
			end
			return table.unpack(results, 2, results.n)
		end
	else
		local signal = if def.kind == "Event"
			then (remote :: RemoteEvent).OnServerEvent
			else (remote :: UnreliableRemoteEvent).OnServerEvent
		signal:Connect(function(player: Player, ...: any)
			if not admit(player, ...) then
				return
			end
			local ok, err = xpcall(handler, debug.traceback, player, ...)
			if not ok then
				warn(`[Net] {name} handler errored for {player.Name}\n{err}`)
			end
		end)
	end
end

function Net.fire(name: string, player: Player, ...: any)
	local def = getDef(name)
	assert(def.direction == "ToClient", `[Net] "{name}" is not a ToClient remote`)
	local remote = instances[name]
	if def.kind == "Unreliable" then
		(remote :: UnreliableRemoteEvent):FireClient(player, ...)
	else
		(remote :: RemoteEvent):FireClient(player, ...)
	end
end

function Net.fireAll(name: string, ...: any)
	local def = getDef(name)
	assert(def.direction == "ToClient", `[Net] "{name}" is not a ToClient remote`)
	local remote = instances[name]
	if def.kind == "Unreliable" then
		(remote :: UnreliableRemoteEvent):FireAllClients(...)
	else
		(remote :: RemoteEvent):FireAllClients(...)
	end
end

-- Convenience: server -> client toast.
function Net.notify(player: Player, text: string, kind: ("info" | "success" | "warning" | "error")?)
	Net.fire("Notify", player, text, kind or "info")
end

return Net
