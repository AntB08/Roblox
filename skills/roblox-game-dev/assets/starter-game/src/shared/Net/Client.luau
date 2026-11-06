--!strict
-- NetClient: client-side lookup of remotes declared in Remotes.luau.
-- Yields (with a timeout) until the server has created the remote. Call from Start(), not Init().
--
--   local NetClient = require(ReplicatedStorage.Shared.Net.Client)
--   NetClient.event("Collect"):FireServer(node)
--   local ok, status = NetClient.func("ClaimDaily"):InvokeServer()

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(script.Parent.Remotes)

local TIMEOUT = 30

local NetClient = {}

local folder: Instance? = nil

local function getFolder(): Instance
	if folder and folder.Parent then
		return folder
	end
	local found = ReplicatedStorage:WaitForChild("Remotes", TIMEOUT)
	assert(found, "[NetClient] ReplicatedStorage.Remotes never appeared (server Net.createAll not run?)")
	folder = found
	return found
end

local function get(name: string, expectedKind: Remotes.Kind): Instance
	local def = Remotes[name]
	assert(def, `[NetClient] unknown remote "{name}" (add it to Shared/Net/Remotes.luau)`)
	assert(def.kind == expectedKind, `[NetClient] remote "{name}" is a {def.kind}, not a {expectedKind}`)
	local remote = getFolder():WaitForChild(name, TIMEOUT)
	assert(remote, `[NetClient] remote "{name}" not found after {TIMEOUT}s`)
	return remote
end

function NetClient.event(name: string): RemoteEvent
	return get(name, "Event") :: RemoteEvent
end

function NetClient.func(name: string): RemoteFunction
	return get(name, "Function") :: RemoteFunction
end

function NetClient.unreliable(name: string): UnreliableRemoteEvent
	return get(name, "Unreliable") :: UnreliableRemoteEvent
end

-- InvokeServer wrapped in pcall (it errors if the server handler errors or the remote is gone).
-- Returns (true, ...results) or (false, errorMessage).
function NetClient.invoke(name: string, ...: any): (boolean, ...any)
	local remote = NetClient.func(name)
	return pcall(remote.InvokeServer, remote, ...)
end

return table.freeze(NetClient)
