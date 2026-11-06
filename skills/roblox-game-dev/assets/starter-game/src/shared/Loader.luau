--!strict
-- Loader: requires every ModuleScript under a folder, calls :Init() on all of them (in Priority
-- order, synchronously, must not yield), then :Start() on all of them (each in its own thread,
-- may yield). Used by both bootstraps:
--   server: Loader.load(script.Services)      (ServerScriptService.Server.init.server.luau)
--   client: Loader.load(script.Controllers)   (StarterPlayerScripts.Client.init.client.luau)
--
-- Module contract (all optional):
--   Module.Priority: number  -- higher runs earlier. DataService = 100, everything else lower.
--   function Module:Init()   -- connect events, create remotes. NO yielding.
--   function Module:Start()  -- load data, start loops. May yield.

export type Module = {
	Priority: number?,
	Init: ((self: any) -> ())?,
	Start: ((self: any) -> ())?,
}

local INIT_WARN_SECONDS = 0.1

local Loader = {}

function Loader.load(folder: Instance): { [string]: Module }
	local entries: { { name: string, mod: Module } } = {}
	for _, child in folder:GetDescendants() do
		if child:IsA("ModuleScript") then
			local ok, result = pcall(require, child)
			if not ok then
				warn(`[Loader] Failed to require {child:GetFullName()}: {result}`)
				continue
			end
			if typeof(result) ~= "table" then
				warn(`[Loader] {child:GetFullName()} did not return a table; skipped`)
				continue
			end
			table.insert(entries, { name = child.Name, mod = result :: Module })
		end
	end

	table.sort(entries, function(a, b)
		local pa, pb = a.mod.Priority or 0, b.mod.Priority or 0
		if pa == pb then
			return a.name < b.name -- deterministic order for equal priorities
		end
		return pa > pb
	end)

	local byName: { [string]: Module } = {}
	for _, entry in entries do
		byName[entry.name] = entry.mod
	end

	-- Phase 1: Init (sync, no yields)
	for _, entry in entries do
		local init = entry.mod.Init
		if init then
			local started = os.clock()
			local ok, err = xpcall(init, debug.traceback, entry.mod)
			if not ok then
				warn(`[Loader] {entry.name}:Init failed\n{err}`)
			end
			local elapsed = os.clock() - started
			if elapsed > INIT_WARN_SECONDS then
				warn(`[Loader] {entry.name}:Init took {string.format("%.3f", elapsed)}s; Init must not yield`)
			end
		end
	end

	-- Phase 2: Start (each in its own thread so one slow Start never blocks the others)
	for _, entry in entries do
		local start = entry.mod.Start
		if start then
			task.spawn(function()
				local ok, err = xpcall(start, debug.traceback, entry.mod)
				if not ok then
					warn(`[Loader] {entry.name}:Start failed\n{err}`)
				end
			end)
		end
	end

	return byName
end

return table.freeze(Loader)
