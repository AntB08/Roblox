# 04 — Production-Quality Luau Engineering for Roblox

> Audience: a Claude Code bot that builds original Roblox games in Luau (Rojo/Wally toolchain or Studio).
> Accurate as of 2026-11-05. APIs were checked against the local engine reference mirror (Studio `0.746`, `reference/creator-docs/content/en-us/reference/engine`). Library versions checked locally: ProfileStore 1.0.3, sleitnick/trove 1.8.0, sleitnick/signal 2.0.3, evaera/promise 4.0.0, jecs 0.11.0, Blink 0.18.9, StyLua 0.32.0.

---

## TL;DR rules for the bot

1. **Start every script with `--!strict`.** Annotate function parameters, return types, and module exports. Fix type errors; don't paper over them with `any` unless you're at a real dynamic boundary (network input, JSON, a library with incomplete types).
2. **Use the `task` library only.** `task.wait`, `task.spawn`, `task.defer`, `task.delay`, `task.cancel`. Never use the global `wait()`, `spawn()`, `delay()`. `tick()` is fine for wall-clock time but use `os.clock()` for durations and `time()` / `workspace:GetServerTimeNow()` for synced time.
3. **The client is hostile.** Every `OnServerEvent` / `OnServerInvoke` argument is untrusted. Type-check, range-check, NaN-check, length-check, rate-limit, and re-derive anything that matters (prices, damage, positions, cooldowns) on the server.
4. **Never call `RemoteFunction:InvokeClient()` from the server.** A client can yield forever or error. Use RemoteEvents server→client.
5. **One `Script` on the server, one `LocalScript` on the client** (plus `StarterCharacterScripts` if needed). Everything else is a `ModuleScript` that a loader requires in a known order: `Init` everything (sync, no yields), then `Start` everything (may yield).
6. **Handle players who joined before your code ran:** connect `Players.PlayerAdded`, then loop `Players:GetPlayers()` and run the same handler with `task.spawn`. Same idea for `CharacterAdded` (check `player.Character` first) and for `CollectionService` tags (`GetTagged` + `GetInstanceAddedSignal`).
7. **Every connection has an owner that cleans it up.** Use a Trove (or Maid/Janitor) per player, per character, per round, and per object. Disconnect on `PlayerRemoving`, on character removal, and on round end.
8. **Use ProfileStore for player data.** Never call `SetAsync` on player data from several places. Use `UpdateAsync` for anything shared. Version your data and migrate on load. Session locking isn't optional.
9. **Wrap every web call (DataStore, MemoryStore, Messaging, Http, Teleport, MarketplaceService, TextService, `Players:GetUserIdFromNameAsync`, ...) in `pcall`** and retry with exponential backoff where retrying makes sense.
10. **Filter all user-generated text** that another player can see, using `TextService:FilterStringAsync` then `GetNonChatStringForBroadcastAsync` (or `GetNonChatStringForUserAsync`). TextChatService filters chat for you, but not your sign/pet-name/guild-name UIs. Roblox removes games that skip this.
11. **Purchases are server-authoritative.** Prices come from server-side config. Check, deduct, and grant without yielding in between. For Developer Products, use `MarketplaceService:BindReceiptHandler` (or the legacy `ProcessReceipt`), make granting idempotent with a `PurchaseId` cache, and return `Processed` only after the data has been saved.
12. **Design for StreamingEnabled.** On the client, use `WaitForChild` (with a timeout for optional things) and `CollectionService` signals, never deep `workspace.A.B.C` paths. Set `ModelStreamingMode` to `Atomic` / `Persistent` on models the client code relies on.
13. **Don't poll.** React to events (`.Changed`, `GetAttributeChangedSignal`, tag signals, remote events). If you need a loop, use one central `Heartbeat` / `PostSimulation` loop or a coarse `task.wait(n)` loop, not hundreds of `while true do task.wait() end`.
14. **Use `table.freeze`** for constants and config modules, and **`table.clone`** before you mutate shared templates.
15. **Use the current API names.** `Player:LoadCharacterAsync` (not `LoadCharacter`), `Animator:LoadAnimation` (not `Humanoid:LoadAnimation`), `Player:IsInGroupAsync`, `MarketplaceService:GetProductInfoAsync` / `PlayerOwnsAssetAsync`, and `TeleportService:TeleportAsync` with `TeleportOptions.ReservedServerId = HttpService:GenerateGUID(false)` (`ReserveServer` and `ReserveServerAsync` are deprecated).
16. **Knit is archived.** Don't add Knit to new projects. Use plain ModuleScripts with a tiny loader, as shown below.
17. **Use the right remote for the job.** `UnreliableRemoteEvent` for high-frequency cosmetic state (payload ≤ 1000 bytes, may drop or arrive out of order). `RemoteEvent` for reliable, ordered events. Both share a budget of about 500 client→server requests/s per client per remote type.
18. **Lint and format:** selene (`std = "roblox"`), StyLua, and luau-lsp type checking with a Rojo sourcemap. Tests use Jest-Lua (current) or TestEZ (legacy).

---

## 1. Luau language essentials (modern Luau, late 2026)

### 1.1 Type checking modes

```lua
--!strict      -- full inference + errors on type mismatches (USE THIS)
--!nonstrict   -- infers, but unknowns become `any` (the default for files without a directive)
--!nocheck     -- disables type checking for the file (generated code only)
```

The **new type solver** moved out of beta in late 2025, and "non-strict by default" shipped with it. Type checking runs only at edit time, in Studio or luau-lsp. **Types have zero runtime effect.** A function annotated `(amount: number)` will still receive a string from a malicious client, so runtime validation is still required.

### 1.2 Annotations, aliases, unions, optionals, singletons

```lua
--!strict
type ItemId = string
type Rarity = "Common" | "Rare" | "Epic" | "Legendary"   -- singleton (literal) union
type Item = {
	id: ItemId,
	name: string,
	rarity: Rarity,
	price: number,
	stackable: boolean?,          -- optional field: boolean | nil
}

type Inventory = { [ItemId]: number }   -- dictionary
type ItemList = { Item }                -- array

local function priceOf(item: Item, discount: number?): number
	local d = discount or 0
	return math.floor(item.price * (1 - d))
end

-- Refinement narrows types:
local function describe(v: string | number | nil): string
	if v == nil then
		return "nothing"
	elseif typeof(v) == "number" then
		return `number {v}`      -- v: number here
	end
	return `string {v}`          -- v: string here
end
```

Use `export type` to share types from a ModuleScript (`local Types = require(path); local x: Types.Item`).

Read-only and write-only table properties are available: `type Config = { read MaxPlayers: number }`.

### 1.3 Generics and explicit instantiation

```lua
--!strict
local function map<T, U>(list: { T }, fn: (T) -> U): { U }
	local out = table.create(#list)
	for i, v in list do
		out[i] = fn(v)
	end
	return out
end

local names = map({ 1, 2, 3 }, function(n) return `#{n}` end) -- { string }

-- Generic type alias
type Result<T> = { ok: true, value: T } | { ok: false, err: string }

local function parseCount(s: string): Result<number>
	local n = tonumber(s)
	if n == nil or n ~= n then
		return { ok = false, err = "not a number" }
	end
	return { ok = true, value = n }
end
```

### 1.4 Type functions (analysis-time type transforms)

Type functions run at analysis time on types, not values. Use them sparingly, for library-level typing. Built-ins include `keyof<T>`, `index<T, K>`, `rawget<T, K>`, `setmetatable<T, MT>`, and `getmetatable<T>`.

```lua
--!strict
type function Partial(ty)
	-- Makes every property of a table type optional.
	assert(ty:is("table"), "Partial expects a table type")
	local out = types.newtable()
	for key, prop in ty:properties() do
		local read = prop.read
		if read then
			out:setproperty(key, types.unionof(read, types.singleton(nil)))
		end
	end
	return out
end

type Settings = { music: number, sfx: number, shadows: boolean }
type SettingsPatch = Partial<Settings>   -- { music: number?, sfx: number?, shadows: boolean? }
type SettingKey = keyof<Settings>        -- "music" | "sfx" | "shadows"
```

### 1.5 Syntax features you should use

```lua
--!strict
-- String interpolation (backticks). Use \{ for a literal brace.
local msg = `Player {player.Name} has {coins} coins`

-- Compound assignment: += -= *= /= //= %= ^= ..=
coins += 10
label ..= "!"

-- Floor division
local rows = total // perRow

-- if-expressions (not the `a and b or c` idiom, which breaks when b is falsy)
local color = if hp > 50 then Color3.new(0, 1, 0) else Color3.new(1, 0, 0)

-- continue
for _, part in workspace:GetDescendants() do
	if not part:IsA("BasePart") then
		continue
	end
	part.CastShadow = false
end

-- Generalized iteration: no pairs/ipairs needed (both still work)
for key, value in someTable do end

-- const bindings: the name can't be reassigned (the value can still be mutated)
const MAX_PLAYERS = 12
```

> `const` is part of the shipped Luau grammar (RFC "Implemented"). If a build tool or an older selene/StyLua rejects it, use `local` with an UPPER_CASE name. Never rely on `const` for safety. Use `table.freeze` for immutability.

### 1.6 Standard library additions to know

```lua
-- table
local defaults = table.freeze({ WalkSpeed = 16, JumpPower = 50 })   -- writes now error
local copy = table.clone(defaults)                                    -- shallow, unfrozen copy
table.isfrozen(defaults)  --> true
table.clear(t)            -- empties t but keeps capacity (good for reuse)
table.create(100, 0)      -- preallocated array
table.find(list, value)   -- linear search

-- deep clone helper (table.clone is shallow!)
local function deepClone<T>(t: T): T
	if typeof(t) ~= "table" then return t end
	local out = {}
	for k, v in t :: any do
		out[k] = deepClone(v)
	end
	return (out :: any) :: T
end

-- math
math.clamp(x, 0, 1); math.round(x); math.sign(x); math.noise(x, y, z)
math.lerp(a, b, t); math.map(x, inMin, inMax, outMin, outMax)

-- buffer: fixed-size mutable byte array (compact serialization, networking, bitpacking)
local b = buffer.create(8)
buffer.writeu16(b, 0, 513)
buffer.writef32(b, 2, 3.5)
buffer.writeu8(b, 6, 255)
print(buffer.readu16(b, 0), buffer.readf32(b, 2), buffer.len(b))
local s = buffer.tostring(b)          -- binary string
local b2 = buffer.fromstring(s)
-- buffer.readbits / writebits exist for sub-byte packing.
-- Buffers can be sent over remotes and stored in DataStores (ProfileStore accepts buffer).

-- string
string.split("a,b,c", ","); string.format("%.2f", x); utf8.len(s)  -- utf8.len returns nil for invalid UTF-8
```

`vector` is a native Luau type with a `vector` library (`vector.create`, `vector.magnitude`, `vector.dot`, ...). In Roblox, `Vector3` is the engine type that most APIs take.

### 1.7 The task library (and what's deprecated)

| Use | Instead of | Notes |
|---|---|---|
| `task.wait(n)` | `wait(n)` | Returns the actual elapsed time and resumes on the next Heartbeat. Throttle-free. |
| `task.spawn(fn, ...)` | `spawn(fn)`, `coroutine.wrap(fn)()` | Runs immediately until it yields. Errors keep their traceback. |
| `task.defer(fn, ...)` | `spawn` | Runs at the end of the current resumption cycle. |
| `task.delay(t, fn, ...)` | `delay(t, fn)` | Returns a thread you can pass to `task.cancel`. |
| `task.cancel(thread)` | — | Cancels a delayed or suspended thread. |
| `task.desynchronize()` / `task.synchronize()` | — | Parallel Luau (inside Actors only). |

```lua
local thread = task.delay(5, function()
	print("5 seconds later")
end)
-- changed our mind:
task.cancel(thread)
```

**Deferred events:** `Workspace.SignalBehavior = Deferred` (already the default in new template places, and required for Server Authority) means handlers run at the next resumption point, not synchronously inside `:Fire()` or a property set. Don't write code that expects a handler to have run on the line after you set a property.

### 1.8 Native code generation

Put `--!native` at the top of a script, or add `@native` to a function, to compile it to machine code on the server (and on the client where supported). Use it for hot numeric code (pathfinding, procedural generation, ECS systems). Annotated types help the native compiler. Don't sprinkle it everywhere. Profile first.

```lua
--!strict
@native
local function sumSquares(arr: { number }): number
	local s = 0
	for i = 1, #arr do
		local v = arr[i]
		s += v * v
	end
	return s
end
```

---

## 2. Client/server model, FilteringEnabled, and where scripts live

### 2.1 The model

- **The server** owns the authoritative DataModel. Changes it makes replicate to clients (subject to streaming).
- **Clients** run LocalScripts, own their UI, input, camera, and local effects. Most client changes **do not replicate** to the server. This is FilteringEnabled, which is always on. The `Workspace.FilteringEnabled` property is deprecated and has no effect.
- **What does replicate from the client:** physics of parts the client has **network ownership** of (its own character by default), character `Humanoid` state and animations played through the character's `Animator`, plus anything sent through remotes. That's why exploiters can teleport or fly their own character, and why movement needs server-side sanity checks (§6.6).
- **Server-only** services and data: `ServerScriptService` and `ServerStorage` never replicate. DataStores, MessagingService, MemoryStore, HttpService, `TextService:FilterStringAsync`, TeleportService teleports, and MarketplaceService receipts are server-only.

### 2.2 Containers

| Container | Runs | Replicates to client? | Put here |
|---|---|---|---|
| `ServerScriptService` | Server `Script`s | No | Server bootstrap `Script` and server-only modules (`Services/`) |
| `ServerStorage` | Nothing runs | No | Server-only assets: maps, NPC templates, tool templates |
| `ReplicatedStorage` | Nothing runs by itself | Yes | Shared modules (config, types, utilities, network definitions), `Packages/` (Wally), remotes, shared assets |
| `ReplicatedFirst` | LocalScripts run first | Yes | Loading screen only |
| `StarterPlayer.StarterPlayerScripts` | LocalScripts, copied once per player to `PlayerScripts` | — | Client bootstrap `LocalScript` + client controllers |
| `StarterPlayer.StarterCharacterScripts` | Copied into each new character | — | Per-character client or server scripts (e.g. custom animate, footsteps) |
| `StarterGui` | Copied into `PlayerGui` (on every respawn if `ResetOnSpawn`) | — | ScreenGuis. Set `ResetOnSpawn = false` for persistent UI. |
| `Workspace` | Scripts run (legacy) | Yes (streamed) | World geometry. Avoid putting scripts here. |

### 2.3 RunContext

`Script.RunContext` (`Enum.RunContext.Legacy | Server | Client | Plugin`) lets a `Script` run anywhere, regardless of its container:

- `Legacy`: old behavior. Runs only in server containers such as Workspace and ServerScriptService.
- `Server`: runs on the server wherever it is, even in ReplicatedStorage. Avoid this for secrets: the source of a script in a replicated container is sent to clients.
- `Client`: a `Script` that runs on the client wherever it is, including Workspace and ReplicatedStorage. Handy for client code that belongs to a streamed model. Remember that it runs once per client, and it runs again every time the model streams back in.

Default to the classic layout (Script in ServerScriptService, LocalScript in StarterPlayerScripts). Use `RunContext = Client` for self-contained client behavior inside packages or streamed models.

---

## 3. Architecture: single-script + ModuleScripts

### 3.1 Why

A single entry point per realm gives you **deterministic load order**, one place to handle errors, easy dependency injection, and no race conditions between scripts that each assume another script has already set something up.

### 3.2 The service/controller pattern without a framework

**Knit is archived** (`Sleitnick_Knit/ARCHIVAL.md`). Its author notes that ModuleScripts already provide service-like structure, and that typed networking needs runtime checks anyway. Use this minimal pattern:

```lua
--!strict
-- ReplicatedStorage/Shared/Loader.luau
-- Requires every ModuleScript under `folder`, calls :Init() on all (sync), then :Start() on all (spawned).
export type Module = {
	Name: string?,
	Priority: number?,         -- higher runs earlier
	Init: ((self: any) -> ())?,
	Start: ((self: any) -> ())?,
}

local Loader = {}

function Loader.load(folder: Instance): { [string]: Module }
	local modules: { { name: string, mod: Module } } = {}
	for _, child in folder:GetDescendants() do
		if child:IsA("ModuleScript") then
			local ok, result = pcall(require, child)
			if not ok then
				warn(`[Loader] Failed to require {child:GetFullName()}: {result}`)
				continue
			end
			table.insert(modules, { name = child.Name, mod = result :: Module })
		end
	end

	table.sort(modules, function(a, b)
		return (a.mod.Priority or 0) > (b.mod.Priority or 0)
	end)

	local byName: { [string]: Module } = {}
	for _, entry in modules do
		byName[entry.name] = entry.mod
	end

	-- Phase 1: Init (must not yield; wire up state and references)
	for _, entry in modules do
		local init = entry.mod.Init
		if init then
			local t = os.clock()
			local ok, err = xpcall(init, debug.traceback, entry.mod)
			if not ok then
				warn(`[Loader] {entry.name}:Init failed\n{err}`)
			end
			if os.clock() - t > 0.1 then
				warn(`[Loader] {entry.name}:Init took {os.clock() - t}s; Init should not yield`)
			end
		end
	end

	-- Phase 2: Start (may yield; each in its own thread)
	for _, entry in modules do
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

return Loader
```

```lua
--!strict
-- ServerScriptService/Server/init.server.luau  (the ONLY server Script)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Loader = require(ReplicatedStorage.Shared.Loader)

Loader.load(script.Services)
print("[Server] booted")
```

```lua
--!strict
-- StarterPlayer/StarterPlayerScripts/Client/init.client.luau  (the ONLY LocalScript)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Loader = require(ReplicatedStorage.Shared.Loader)

Loader.load(script.Controllers)
```

A service is a plain module. Other services `require` it **directly** (typed, with autocomplete) instead of looking it up by string:

```lua
--!strict
-- ServerScriptService/Server/Services/EconomyService.luau
local PlayerData = require(script.Parent.PlayerData)

local EconomyService = {}
EconomyService.Priority = 50

function EconomyService:Init() end
function EconomyService:Start() end

function EconomyService.reward(player: Player, coins: number, reason: string)
	PlayerData.addCoins(player, coins, reason)
end

return EconomyService
```

**Rules for dependencies:**
- `require` at the top of the file. Luau caches modules, so requires are cheap after the first call.
- Avoid circular requires. If A needs B and B needs A, move the shared piece into C, or have one side require the other lazily inside a function.
- Never yield at module top level, for example with `WaitForChild` on something created later or a DataStore call. That stalls the require chain. Do yielding work in `Start`.
- Modules return a table. Don't run side effects such as connecting events or creating instances at require time, except for constants.

### 3.3 When a framework is fine

If the project already uses Knit, keep using it consistently. For new projects, the loader above plus a typed networking layer (§4) covers everything Knit offered.

---

## 4. Networking: remotes, validation, rate limits, anti-exploit

### 4.1 The remote types

| Type | Delivery | Order | Use for | Limits |
|---|---|---|---|---|
| `RemoteEvent` | reliable | ordered (even across different RemoteEvents, per direction and per client) | discrete actions: "buy", "equip", "round ended" | ~500 req/s per client shared by all RemoteEvents (client→server). Excess is delayed, not dropped. |
| `UnreliableRemoteEvent` | may drop | unordered | high-frequency cosmetic state: aim direction, VFX, look-at | payloads > **1000 bytes are dropped**. Excess beyond the rate limit is dropped. Unhandled messages are discarded immediately. |
| `RemoteFunction` | reliable | not ordered relative to RemoteEvents | client→server request/response ("can I afford X?") | **Never `InvokeClient`.** Only the last-assigned `OnServerInvoke` runs. |
| `BindableEvent` / `BindableFunction` | same-realm | — | rarely needed. Prefer a Signal module. | — |

Facts from `scripting/events/remote.md`:
- If no handler is connected yet, RemoteEvent messages queue (with a limited queue) and are delivered when one connects. That's why you should connect handlers early, in `Init`.
- Ordering is about when handlers **start**. If a handler yields, the next message can start before it finishes.
- **Argument limits:** tables with mixed keys or non-string keys get mangled. `nil` holes truncate arrays. Instances arrive as `nil` if the receiver can't see them (not replicated or streamed out). Functions and metatables don't cross. Send plain data: strings, numbers, booleans, arrays, string-keyed dictionaries, Vector3, CFrame, Color3, EnumItems, buffers.

### 4.2 The validation wrapper with rate limiting (complete)

```lua
--!strict
-- ReplicatedStorage/Shared/Guard.luau
-- Runtime validators. Each returns (value: any) -> boolean. Types don't exist at runtime: check everything.
export type Check = (value: any) -> boolean

local Guard = {}

local function isFinite(n: number): boolean
	return n == n and n ~= math.huge and n ~= -math.huge
end

function Guard.number(min: number?, max: number?): Check
	return function(v)
		if typeof(v) ~= "number" or not isFinite(v) then return false end
		if min ~= nil and v < min then return false end
		if max ~= nil and v > max then return false end
		return true
	end
end

function Guard.integer(min: number?, max: number?): Check
	local num = Guard.number(min, max)
	return function(v)
		return num(v) and v % 1 == 0
	end
end

function Guard.string(maxLength: number, minLength: number?): Check
	return function(v)
		if typeof(v) ~= "string" then return false end
		local len = utf8.len(v)                 -- nil for invalid UTF-8
		if len == nil then return false end
		return len <= maxLength and len >= (minLength or 0)
	end
end

function Guard.boolean(): Check
	return function(v)
		return typeof(v) == "boolean"
	end
end

-- Value must be a key of `set` (e.g. an item catalog). Prevents arbitrary strings.
function Guard.oneOf(set: { [any]: any }): Check
	return function(v)
		return (typeof(v) == "string" or typeof(v) == "number") and set[v] ~= nil
	end
end

function Guard.vector3(maxMagnitude: number?): Check
	return function(v)
		if typeof(v) ~= "Vector3" then return false end
		if not (isFinite(v.X) and isFinite(v.Y) and isFinite(v.Z)) then return false end
		return maxMagnitude == nil or v.Magnitude <= maxMagnitude
	end
end

function Guard.instanceOf(className: string, ancestor: Instance?): Check
	return function(v)
		if typeof(v) ~= "Instance" or not v:IsA(className) then return false end
		return ancestor == nil or v:IsDescendantOf(ancestor)
	end
end

function Guard.optional(check: Check): Check
	return function(v)
		return v == nil or check(v)
	end
end

return table.freeze(Guard)
```

```lua
--!strict
-- ServerScriptService/Server/Net.luau
-- Server side of all remotes: creates them, validates arguments, rate-limits per player, logs abuse.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Guard = require(ReplicatedStorage.Shared.Guard)

type Check = Guard.Check
type RateConfig = { rate: number, burst: number }   -- tokens per second, bucket size
type Bucket = { tokens: number, last: number }

local DEFAULT_RATE: RateConfig = { rate = 10, burst = 20 }
local VIOLATION_KICK_THRESHOLD = 50   -- malformed payloads before a kick (rate drops are not counted)

local remotesFolder = Instance.new("Folder")
remotesFolder.Name = "Remotes"
remotesFolder.Parent = ReplicatedStorage

local buckets: { [Player]: { [string]: Bucket } } = {}
local violations: { [Player]: number } = {}

local function takeToken(player: Player, key: string, cfg: RateConfig): boolean
	local perPlayer = buckets[player]
	if perPlayer == nil then
		if player.Parent ~= Players then return false end   -- player left; ignore
		perPlayer = {}
		buckets[player] = perPlayer
	end
	local now = os.clock()
	local b = perPlayer[key]
	if b == nil then
		b = { tokens = cfg.burst, last = now }
		perPlayer[key] = b
	end
	b.tokens = math.min(cfg.burst, b.tokens + (now - b.last) * cfg.rate)
	b.last = now
	if b.tokens < 1 then
		return false
	end
	b.tokens -= 1
	return true
end

local function flag(player: Player, remoteName: string, reason: string)
	local n = (violations[player] or 0) + 1
	violations[player] = n
	warn(`[Net] {player.Name} ({player.UserId}) {remoteName}: {reason} (#{n})`)
	if n >= VIOLATION_KICK_THRESHOLD then
		player:Kick("Unexpected network activity")
	end
end

local function validate(player: Player, name: string, checks: { Check }, ...: any): boolean
	local argc = select("#", ...)
	if argc > #checks then
		flag(player, name, `too many args ({argc})`)
		return false
	end
	for i, check in checks do
		local v = select(i, ...)
		if not check(v) then
			flag(player, name, `arg #{i} failed validation ({typeof(v)})`)
			return false
		end
	end
	return true
end

local function getOrCreate(className: string, name: string): Instance
	local existing = remotesFolder:FindFirstChild(name)
	if existing then
		assert(existing.ClassName == className, `Remote {name} exists with different class`)
		return existing
	end
	local r = Instance.new(className)
	r.Name = name
	r.Parent = remotesFolder
	return r
end

local Net = {}

-- Client -> server event.
function Net.onEvent(name: string, checks: { Check }, rate: RateConfig?, handler: (Player, ...any) -> ())
	local remote = getOrCreate("RemoteEvent", name) :: RemoteEvent
	local cfg = rate or DEFAULT_RATE
	remote.OnServerEvent:Connect(function(player: Player, ...: any)
		if not takeToken(player, name, cfg) then return end   -- silently drop spam
		if not validate(player, name, checks, ...) then return end
		local ok, err = xpcall(handler, debug.traceback, player, ...)
		if not ok then
			warn(`[Net] handler {name} errored for {player.Name}\n{err}`)
		end
	end)
	return remote
end

-- Client -> server unreliable event (cosmetic, high frequency).
function Net.onUnreliable(name: string, checks: { Check }, rate: RateConfig?, handler: (Player, ...any) -> ())
	local remote = getOrCreate("UnreliableRemoteEvent", name) :: UnreliableRemoteEvent
	local cfg = rate or { rate = 30, burst = 30 }
	remote.OnServerEvent:Connect(function(player: Player, ...: any)
		if not takeToken(player, name, cfg) then return end
		if not validate(player, name, checks, ...) then return end
		handler(player, ...)
	end)
	return remote
end

-- Client -> server request/response. Handler returns the response values.
function Net.onInvoke(name: string, checks: { Check }, rate: RateConfig?, handler: (Player, ...any) -> ...any)
	local remote = getOrCreate("RemoteFunction", name) :: RemoteFunction
	local cfg = rate or DEFAULT_RATE
	remote.OnServerInvoke = function(player: Player, ...: any)
		if not takeToken(player, name, cfg) then
			return false, "RateLimited"
		end
		if not validate(player, name, checks, ...) then
			return false, "BadRequest"
		end
		local results = table.pack(xpcall(handler, debug.traceback, player, ...))
		if not results[1] then
			warn(`[Net] invoke {name} errored for {player.Name}\n{results[2]}`)
			return false, "ServerError"
		end
		return table.unpack(results, 2, results.n)
	end
	return remote
end

-- Server -> client events (create upfront so clients can WaitForChild them).
function Net.event(name: string): RemoteEvent
	return getOrCreate("RemoteEvent", name) :: RemoteEvent
end

function Net.unreliable(name: string): UnreliableRemoteEvent
	return getOrCreate("UnreliableRemoteEvent", name) :: UnreliableRemoteEvent
end

Players.PlayerRemoving:Connect(function(player)
	buckets[player] = nil
	violations[player] = nil
end)

return Net
```

Usage (server):

```lua
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Guard = require(ReplicatedStorage.Shared.Guard)
local ShopCatalog = require(ReplicatedStorage.Shared.Config.ShopCatalog)
local Net = require(script.Parent.Parent.Net)

Net.onInvoke("RequestPurchase", { Guard.oneOf(ShopCatalog) }, { rate = 2, burst = 5 }, function(player, itemId: string)
	return ShopService.purchase(player, itemId)   -- returns (ok: boolean, reason: string?)
end)

Net.onEvent("SetSetting", { Guard.oneOf({ Music = true, Sfx = true }), Guard.number(0, 1) }, nil,
	function(player, key: string, value: number)
		PlayerData.setSetting(player, key, value)
	end)
```

Client side:

```lua
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RequestPurchase = Remotes:WaitForChild("RequestPurchase") :: RemoteFunction

local function buy(itemId: string)
	local ok, reason = RequestPurchase:InvokeServer(itemId)
	if not ok then
		warn("Purchase failed:", reason)
	end
end
```

### 4.3 Never trust the client: the checklist

For every client→server message, ask:

1. **Who?** Use the `player` argument the engine supplies, never a player or userId sent in the payload.
2. **Is the shape right?** Types, argument count, NaN/inf, string length, UTF-8, table depth and size.
3. **Is it allowed now?** Is the player alive? In the round? Is the tool equipped? Is the cooldown over (tracked **server-side** with `os.clock()`)? Is the target in range (`(target.Position - root.Position).Magnitude <= MAX_RANGE + latency slack`)? Is there line of sight (server raycast)?
4. **Is the value server-derived?** The client sends *intent* ("I want to buy `sword_iron`", "I swung at this target"), never *outcomes* ("give me 500 coins", "deal 9999 damage", "the price is 0").
5. **Is the rate sane?** Use token buckets per remote, plus a server-side cooldown per action.
6. **Can it be replayed or duplicated?** Make operations idempotent where possible (purchase IDs, sequence numbers).

### 4.4 Server-side hit validation example

```lua
--!strict
local Players = game:GetService("Players")
local MAX_RANGE = 12          -- studs (melee)
local SWING_COOLDOWN = 0.45   -- seconds
local DAMAGE = 20             -- server constant; the client never sends damage

local lastSwing: { [Player]: number } = {}

local function onSwing(player: Player, target: Model)
	local now = os.clock()
	if now - (lastSwing[player] or 0) < SWING_COOLDOWN then return end
	lastSwing[player] = now

	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not (root and hum and hum.Health > 0) then return end

	local targetHum = target:FindFirstChildOfClass("Humanoid")
	local targetRoot = target:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not (targetHum and targetRoot and targetHum.Health > 0) then return end
	if target == char then return end

	-- Range check with a small allowance for latency
	if (targetRoot.Position - root.Position).Magnitude > MAX_RANGE + 3 then return end

	-- Optional line of sight check
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { char, target }
	local hit = workspace:Raycast(root.Position, targetRoot.Position - root.Position, params)
	if hit then return end   -- something is in the way

	targetHum:TakeDamage(DAMAGE)
end

Players.PlayerRemoving:Connect(function(p) lastSwing[p] = nil end)
-- Wire: Net.onEvent("Swing", { Guard.instanceOf("Model", workspace) }, { rate = 4, burst = 4 }, onSwing)
```

### 4.5 Anti-exploit basics: speed and teleport checks

Clients own their character's physics, so they can set their own `CFrame` or velocity. Keep a server-side record of the last valid position and rubber-band anyone who moves impossibly far. Allow server-initiated teleports by updating the record.

```lua
--!strict
-- ServerScriptService/Server/Services/MovementGuard.luau
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local CHECK_INTERVAL = 0.5
local HORIZONTAL_TOLERANCE = 1.6     -- multiplier over WalkSpeed
local FLAT_ALLOWANCE = 6             -- studs per check (knockback, latency jitter)
local MAX_STRIKES = 5

type Track = { pos: Vector3, strikes: number }
local tracks: { [Player]: Track } = {}

local MovementGuard = {}

-- Call this whenever the SERVER moves a character on purpose.
function MovementGuard.serverTeleport(player: Player, cf: CFrame)
	local char = player.Character
	if not char then return end
	char:PivotTo(cf)
	tracks[player] = { pos = cf.Position, strikes = 0 }
end

function MovementGuard:Start()
	local acc = 0
	RunService.Heartbeat:Connect(function(dt)
		acc += dt
		if acc < CHECK_INTERVAL then return end
		local elapsed = acc
		acc = 0

		for _, player in Players:GetPlayers() do
			local char = player.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
			if not (hum and root) or hum.Health <= 0 then
				tracks[player] = nil
				continue
			end
			local track = tracks[player]
			if track == nil then
				tracks[player] = { pos = root.Position, strikes = 0 }
				continue
			end
			local delta = root.Position - track.pos
			local horizontal = Vector3.new(delta.X, 0, delta.Z).Magnitude
			local allowed = hum.WalkSpeed * elapsed * HORIZONTAL_TOLERANCE + FLAT_ALLOWANCE
			-- Upward movement check (falling is fine; flying up is not)
			local maxRise = (hum.JumpHeight + 4) + 2
			if horizontal > allowed or delta.Y > maxRise then
				track.strikes += 1
				char:PivotTo(CFrame.new(track.pos))   -- rubber-band back
				if track.strikes >= MAX_STRIKES then
					warn(`[MovementGuard] {player.Name} exceeded movement limits repeatedly`)
					-- Escalate: log to analytics, kick, or flag; avoid instant bans (false positives from lag)
				end
			else
				track.pos = root.Position
				track.strikes = math.max(0, track.strikes - 1)
			end
		end
	end)

	Players.PlayerRemoving:Connect(function(p) tracks[p] = nil end)
end

return MovementGuard
```

More anti-exploit basics:
- **Server authority over state:** health, currency, inventory, cooldowns, and round state live on the server. The client only displays them.
- **Don't put secrets in ReplicatedStorage**: API keys, admin lists, or server logic. Exploiters can read every replicated script and instance.
- **Don't trust client-side `Touched`**. Handle touch-to-collect on the server and validate distance.
- **Admin commands:** check `player.UserId` against a server-side list or `player:IsInGroupAsync()` / group rank, never a client flag.
- Use `Players:BanAsync` for persistent bans (it supports alt detection settings) instead of rolling your own DataStore ban list.

### 4.6 Roblox Server Authority (2025–2026)

Roblox now ships a native **server authority model** with client prediction, rollback, and resimulation (`projects/server-authority`). It went from Studio beta in late 2025 to client beta to a full release in 2026. Setup: set `Workspace.AuthorityMode = Enum.AuthorityMode.Server`. That auto-enables `NextGenerationReplication`, `PlayerScriptsUseInputActionSystem`, Deferred `SignalBehavior`, `UseFixedSimulation`, and `StreamingEnabled`. Core rules:

- Put core simulation in `RunService:BindToSimulation(fn)` inside a ModuleScript initialized on **both** server and client. Only APIs labeled "Simulation Access" may be used inside it.
- Use `time()` inside simulation, not `tick()` / `os.clock()`. It's synced and rewinds during resimulation.
- Read input through the **Input Action System** (`InputAction` / `InputContext` parented under the Player), not `UserInputService.InputBegan`, for anything that affects simulation.
- Sync custom state with **attributes** on predicted instances (first 64 attributes, names ≤ 50 characters, string values ≤ 50 characters).
- Don't `Destroy()` or reparent inside simulation. Set an attribute and destroy in `PostSimulation` on the server.
- Effects and sounds go in `RenderStepped`. They must tolerate mispredictions.
- Server CPU usage goes up. Use it for competitive FPS, racing, sports, and combat. Keep the classic model for casual or social games.

```lua
--!strict
-- ReplicatedStorage/Shared/Simulation.luau  (required by both server and client bootstraps)
local RunService = game:GetService("RunService")
local Simulation = {}

function Simulation.init()
	RunService:BindToSimulation(function(deltaTime: number)
		-- read InputActions for each player, update predicted state (attributes, CFrames)
	end)
end

return Simulation
```

### 4.7 Networking libraries

Every library wraps RemoteEvents, UnreliableRemoteEvents, and RemoteFunctions. Use one when bandwidth or CPU matters, for example with many entities or 20+ Hz updates.

- **Blink** (IDL compiler, `1Axen/blink`, v0.18.x): you write a `.blink` schema and it generates typed server and client modules. It packs data into buffers, batches per frame, and **validates incoming data against the schema** (ranges, string lengths). Community benchmarks in 2025 put it at or near the top for speed.
- **Zap**: a similar IDL generator, comparable in speed.
- **ByteNet**: a runtime, strictly typed buffer library (no codegen). Slower than Blink and Zap in benchmarks.
- Others (Packet, Warp, ...) come and go. Pick one, and keep game logic behind your own small `Net` facade so you can swap it out.

```blink
-- net.blink
option ClientOutput = "src/shared/Net/Client.luau"
option ServerOutput = "src/shared/Net/Server.luau"

type ItemId = string(1..32)

event PurchaseRequest {
    from: Client,
    type: Reliable,
    call: SingleSync,
    data: ItemId
}

event CoinsChanged {
    from: Server,
    type: Reliable,
    call: SingleSync,
    data: u32
}

event AimDirection {
    from: Client,
    type: Unreliable,
    call: SingleSync,
    data: vector
}
```

```lua
-- server
local Net = require(ReplicatedStorage.Shared.Net.Server)
Net.PurchaseRequest.On(function(player, itemId)
	-- itemId is guaranteed a 1..32 length string; STILL check it exists in the catalog
end)
Net.CoinsChanged.Fire(player, 150)
```

Schema validation is **not** game-logic validation. Ownership, price, cooldowns, and range checks are still on you.

---
## 5. Data persistence

### 5.1 DataStoreService limits (current values from the docs)

| Limit | Value |
|---|---|
| Key name / store name / scope | 50 characters each |
| Value size | 4,194,304 characters per key (JSON-encoded) |
| Per-key throughput | 25 MB/min read, 4 MB/min write (rounded up to the nearest KB per request) |
| **Per-server default** (standard) | Read `60 + 40×players`/min, Write `60 + 40×players`/min, List `5 + 2×players`, Remove `60 + 40×players` |
| **Per-server default** (ordered) | Read `60 + 40×players`, Write `30 + 5×players`, List (`GetSortedAsync`) `5 + 2×players` |
| **Experience-wide** (shared with Open Cloud) | Standard read `300 + 40×CCU`, write `300 + 20×CCU`, list `300 + 2×CCU`, remove `300 + 40×CCU` |
| Storage | `500 MB + 1 MB × lifetime users` (latest versions) |
| Throttle queues | 30 requests per queue. Beyond that, requests fail with errors 301–306. |

- `UpdateAsync` consumes **both** read and write budget.
- `DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.X)` returns the remaining budget. `SetRateLimitForRequestType` configures per-server limits; call it once at startup.
- `GlobalDataStore:OnUpdate` is **deprecated**. Use MessagingService for change notifications.
- `OrderedDataStore` supports `BatchGetAsync(keys)` (up to 100 keys). It throws on standard stores.
- Studio uses separate static limits and needs "Enable Studio Access to API Services" turned on. Use a separate place or store name for testing.

### 5.2 UpdateAsync is the only safe read-modify-write

`SetAsync` blindly overwrites, so two servers writing the same key will lose data. `UpdateAsync` retries your transform against the latest value. The transform **must not yield** and **may be called multiple times**. Return `nil` to cancel the write.

```lua
--!strict
local DataStoreService = game:GetService("DataStoreService")
local guildStore = DataStoreService:GetDataStore("Guilds_v1")

-- Atomically add a member if there's room. Returns true on success.
local function addGuildMember(guildId: string, userId: number): boolean
	local added = false
	local ok, err = pcall(function()
		guildStore:UpdateAsync(guildId, function(current: any, keyInfo: DataStoreKeyInfo?)
			added = false
			local guild = current or { members = {}, createdAt = os.time() }
			if #guild.members >= 50 or table.find(guild.members, userId) then
				return nil              -- cancel: no write
			end
			table.insert(guild.members, userId)
			added = true
			-- Return value, plus optional userIds (GDPR) and metadata:
			return guild, { userId }
		end)
	end)
	if not ok then
		warn("addGuildMember failed:", err)
		return false
	end
	return added
end
```

### 5.3 Session locking (why ProfileStore)

Without a lock, a player who hops servers quickly can have server A save stale data after server B has loaded and modified it. That's the classic item-duplication and rollback bug. **Session locking** stores "owned by JobId X" in the record. Other servers wait, ask the owner to release, or steal the lock after a timeout. ProfileStore does this for you:

- `AUTO_SAVE_PERIOD = 300 s` autosave, plus a save on `EndSession`
- Session conflict: the new server sends a release request and steals after `SESSION_STEAL = 40 s`. A session that hasn't updated for `ASSUME_DEAD = 630 s` is treated as crashed.
- It binds `game:BindToClose` internally and saves all active profiles on shutdown (`ProfileStore.IsClosing`).
- Each save is one `UpdateAsync`. `ProfileStore.IsCriticalState` / `OnCriticalToggle` report DataStore outages, and `OnError` reports errors.

### 5.4 Complete ProfileStore data module

Install: Wally `lm-loleris/profilestore@1.0.3` (realm `server`, so it lands in `ServerPackages`), or put the `ProfileStore` ModuleScript in ServerScriptService.

```lua
--!strict
-- ServerScriptService/Server/Services/PlayerData.luau
-- Owns all persistent player data. The ONLY module that touches ProfileStore for players.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local ProfileStore = require(ServerScriptService.ServerPackages.ProfileStore)
local Signal = require(ReplicatedStorage.Packages.Signal)

-- ===== Schema =====
local CURRENT_VERSION = 3

local TEMPLATE = {
	Version = CURRENT_VERSION,
	Coins = 0,
	Gems = 0,
	Wins = 0,
	OwnedItems = {} :: { [string]: boolean },
	Equipped = "" :: string,
	Settings = { Music = 0.5, Sfx = 0.8 },
	PurchaseIdCache = {} :: { string },
	Stats = { PlayTimeSeconds = 0, FirstJoin = 0, LastJoin = 0 },
}
export type Data = typeof(TEMPLATE)
type Profile = ProfileStore.Profile<Data>

-- Migrations: MIGRATIONS[v] upgrades data from version v to v + 1. Never edit an old step; add new ones.
local MIGRATIONS: { [number]: (data: any) -> () } = {
	[1] = function(data)
		-- v1 stored "Cash"; v2 renamed it to "Coins"
		data.Coins = (data.Coins or 0) + (data.Cash or 0)
		data.Cash = nil
	end,
	[2] = function(data)
		-- v2 stored Inventory as an array of ids; v3 uses a set
		local owned = {}
		for _, id in data.Inventory or {} do
			owned[id] = true
		end
		data.OwnedItems = owned
		data.Inventory = nil
	end,
}

local function migrate(data: any)
	local version = data.Version or 1
	while version < CURRENT_VERSION do
		local step = MIGRATIONS[version]
		assert(step, `Missing migration for version {version}`)
		step(data)
		version += 1
		data.Version = version
	end
end

-- ===== Store =====
local STORE_NAME = "PlayerData_v1"   -- change ONLY with a migration plan; a new name = wiped data
local PlayerStore = ProfileStore.New(STORE_NAME, TEMPLATE)
-- In Studio without API access, use the mock store (in-memory, never saved):
local USE_MOCK = RunService:IsStudio() and workspace:GetAttribute("MockData") == true
local Store = if USE_MOCK then PlayerStore.Mock else PlayerStore

local profiles: { [Player]: Profile } = {}
local waiters: { [Player]: { thread } } = {}
local joinClock: { [Player]: number } = {}

local PlayerData = {}
PlayerData.Priority = 100   -- load before services that depend on data

-- Fired as (player, data) once a profile is ready.
PlayerData.Loaded = Signal.new()
-- Fired as (player, key, newValue) whenever a top-level field changes through this API.
PlayerData.Changed = Signal.new()

local function resumeWaiters(player: Player, data: Data?)
	local list = waiters[player]
	waiters[player] = nil
	if list then
		for _, thread in list do
			task.spawn(thread, data)
		end
	end
end

local function onPlayerAdded(player: Player)
	local profile = Store:StartSessionAsync(`Player_{player.UserId}`, {
		Cancel = function()
			return player.Parent ~= Players   -- stop retrying if they leave mid-load
		end,
	} :: any)   -- `Cancel` is documented but missing from the exported param type

	if profile == nil then
		-- Only happens when the server is shutting down or the player left
		if player.Parent == Players then
			player:Kick("Data failed to load. Please rejoin.")
		end
		resumeWaiters(player, nil)
		return
	end

	profile:AddUserId(player.UserId)   -- GDPR / right-to-erasure association
	migrate(profile.Data)              -- migrate BEFORE Reconcile
	profile:Reconcile()                -- fill fields added to TEMPLATE since this profile was created

	profile.OnSessionEnd:Connect(function()
		profiles[player] = nil
		if player.Parent == Players then
			player:Kick("Your data was loaded on another server. Please rejoin.")
		end
	end)

	profile.OnLastSave:Connect(function()
		-- Final chance to write session-derived data (no yielding here)
		local started = joinClock[player]
		if started then
			profile.Data.Stats.PlayTimeSeconds += math.floor(os.clock() - started)
			joinClock[player] = nil
		end
	end)

	if player.Parent ~= Players then
		profile:EndSession()   -- left while loading
		resumeWaiters(player, nil)
		return
	end

	local now = os.time()
	if profile.Data.Stats.FirstJoin == 0 then
		profile.Data.Stats.FirstJoin = now
	end
	profile.Data.Stats.LastJoin = now
	joinClock[player] = os.clock()

	profiles[player] = profile
	PlayerData.Loaded:Fire(player, profile.Data)
	resumeWaiters(player, profile.Data)
end

local function onPlayerRemoving(player: Player)
	local profile = profiles[player]
	if profile then
		profile:EndSession()   -- OnLastSave fires, final save, lock released
	end
	resumeWaiters(player, nil)
end

-- ===== Public API =====
function PlayerData.get(player: Player): Data?
	local p = profiles[player]
	return if p then p.Data else nil
end

function PlayerData.getProfile(player: Player): Profile?
	return profiles[player]
end

-- Yields until the player's data loads. Returns nil if they leave or loading fails.
function PlayerData.waitFor(player: Player): Data?
	local p = profiles[player]
	if p then return p.Data end
	if player.Parent ~= Players then return nil end
	local list = waiters[player]
	if list == nil then
		list = {}
		waiters[player] = list
	end
	table.insert(list, coroutine.running())
	return coroutine.yield()
end

function PlayerData.addCoins(player: Player, amount: number, reason: string): boolean
	assert(amount == amount and amount >= 0 and amount % 1 == 0, "amount must be a non-negative integer")
	local p = profiles[player]
	if not p then return false end
	p.Data.Coins += amount
	PlayerData.Changed:Fire(player, "Coins", p.Data.Coins)
	return true
end

-- Atomic check-and-deduct. No yields, so nothing can interleave.
function PlayerData.trySpendCoins(player: Player, amount: number): boolean
	assert(amount == amount and amount >= 0 and amount % 1 == 0, "amount must be a non-negative integer")
	local p = profiles[player]
	if not p or p.Data.Coins < amount then return false end
	p.Data.Coins -= amount
	PlayerData.Changed:Fire(player, "Coins", p.Data.Coins)
	return true
end

function PlayerData.incrementWins(player: Player)
	local p = profiles[player]
	if not p then return end
	p.Data.Wins += 1
	PlayerData.Changed:Fire(player, "Wins", p.Data.Wins)
end

function PlayerData.setSetting(player: Player, key: string, value: number)
	local p = profiles[player]
	if not p then return end
	local settings = p.Data.Settings :: any
	if settings[key] == nil then return end    -- only known keys
	settings[key] = math.clamp(value, 0, 1)
end

-- ===== Lifecycle =====
function PlayerData:Init()
	ProfileStore.OnError:Connect(function(message, storeName, key)
		warn(`[PlayerData] DataStore error {storeName}/{key}: {message}`)
	end)
	ProfileStore.OnCriticalToggle:Connect(function(isCritical)
		warn(`[PlayerData] critical state: {isCritical}`)   -- e.g. show a "saving paused" banner
	end)
end

function PlayerData:Start()
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
	for _, player in Players:GetPlayers() do   -- players who joined before Start
		task.spawn(onPlayerAdded, player)
	end
end

return PlayerData
```

Notes:
- **Never replace `profile.Data`** with a new table. Mutate fields. Store only JSON-safe values: no Instances, Vector3, CFrame, or Color3. Serialize them as numbers or arrays (or use buffers).
- Don't use mixed tables or numeric-string ambiguity. A dictionary keyed by `tostring(userId)` is fine. A sparse array is not.
- `Reconcile` only fills **missing** keys. It never deletes old keys or changes types. That's what migrations are for.
- ProfileStore's `MessageAsync` / `MessageHandler` let you send data to an offline player's profile (gifts, admin grants). It's processed when they next load.
- `Profile:Save()` costs one UpdateAsync. Reserve it for critical moments like purchases.
- **GDPR:** `AddUserId` associates the key with the user. Handle right-to-erasure requests by removing that key (`PlayerStore:RemoveAsync(key)` or Open Cloud).

### 5.5 Leaderstats

`leaderstats` is a Folder under the Player containing `IntValue` / `NumberValue` / `StringValue` children. The default player list displays it. It's display only. The source of truth is PlayerData.

```lua
--!strict
-- ServerScriptService/Server/Services/Leaderstats.luau
local PlayerData = require(script.Parent.PlayerData)

local SHOWN = { "Coins", "Wins" }   -- order = column order

local Leaderstats = {}

function Leaderstats:Init()
	PlayerData.Loaded:Connect(function(player: Player, data: PlayerData.Data)
		local folder = Instance.new("Folder")
		folder.Name = "leaderstats"
		for _, key in SHOWN do
			local value = Instance.new("IntValue")
			value.Name = key
			value.Value = (data :: any)[key]
			value.Parent = folder
		end
		folder.Parent = player   -- parent last: one replication packet, no partial state
	end)

	PlayerData.Changed:Connect(function(player: Player, key: string, newValue: any)
		local folder = player:FindFirstChild("leaderstats")
		local stat = folder and folder:FindFirstChild(key)
		if stat and stat:IsA("IntValue") then
			stat.Value = newValue
		end
	end)
end

return Leaderstats
```

Because PlayerData has `Priority = 100`, it inits first. Leaderstats connects to `Loaded` during `Init`, before PlayerData's `Start` begins loading profiles, so no `Loaded` event is missed.

### 5.6 Raw DataStore + BindToClose (when not using ProfileStore)

For non-player global data (e.g. a world-state key written by one server), or if you must avoid ProfileStore:

```lua
--!strict
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local store = DataStoreService:GetDataStore("WorldState_v1")

local dirty: { [string]: any } = {}

local function flush()
	for key, value in dirty do
		local ok, err = pcall(function()
			store:UpdateAsync(key, function()
				return value
			end)
		end)
		if ok then
			dirty[key] = nil
		else
			warn("flush failed", key, err)
		end
	end
end

task.spawn(function()
	while true do
		task.wait(120)
		flush()
	end
end)

game:BindToClose(function()
	if RunService:IsStudio() then return end   -- avoid 30 s hangs when stopping playtests
	flush()   -- BindToClose gives at most ~30 seconds total
end)
```

### 5.7 OrderedDataStore leaderboards

- Values must be **integers**. Write sparingly: the ordered write budget is only `30 + 5×players`/min per server. Write on leave, or every few minutes for active players, never on every change.
- Read with `GetSortedAsync(ascending, pageSize)` at most once a minute or so, and cache the result (list budget is `5 + 2×players`).

```lua
--!strict
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local winsBoard = DataStoreService:GetOrderedDataStore("GlobalWins_v1")

local Leaderboard = {}
local cached: { { userId: number, name: string, wins: number } } = {}

function Leaderboard.submit(player: Player, wins: number)
	local ok, err = pcall(function()
		winsBoard:SetAsync(tostring(player.UserId), math.floor(wins))
	end)
	if not ok then warn("Leaderboard submit failed:", err) end
end

local nameCache: { [number]: string } = {}
local function nameOf(userId: number): string
	local cachedName = nameCache[userId]
	if cachedName then return cachedName end
	local ok, name = pcall(Players.GetNameFromUserIdAsync, Players, userId)
	local result = if ok then name else `User{userId}`
	nameCache[userId] = result
	return result
end

function Leaderboard.refresh()
	local ok, pages = pcall(function()
		return winsBoard:GetSortedAsync(false, 50)
	end)
	if not ok then
		warn("Leaderboard read failed:", pages)
		return
	end
	local entries = {}
	for _, entry in (pages :: DataStorePages):GetCurrentPage() do
		local userId = tonumber(entry.key)
		if userId then
			table.insert(entries, { userId = userId, name = nameOf(userId), wins = entry.value })
		end
	end
	cached = entries
end

function Leaderboard.top() return cached end

task.spawn(function()
	while true do
		Leaderboard.refresh()
		task.wait(90)
	end
end)

return Leaderboard
```

### 5.8 MemoryStoreService: queues, sorted maps, hash maps

MemoryStore is fast, ephemeral, cross-server memory: matchmaking, server browsers, global rate limits, live events, and short-lived leaderboards. Everything has an **expiration** (max 45 days). Limits:
- Memory quota: `64 KB + 1.2 KB × users` per experience.
- Requests: `1000 + 120 × CCU` request units per minute (range reads cost one unit per returned item).
- Max 1,000,000 items and 100 MB per sorted map or queue.
- Each sorted map or queue lives on a **single partition** (throttling at roughly 30k units/min). Hash maps spread across partitions, with a per-key limit of about 5k writes and 15k reads per minute. Shard hot structures.

```lua
--!strict
local MemoryStoreService = game:GetService("MemoryStoreService")
local HttpService = game:GetService("HttpService")

-- ===== Queue: matchmaking =====
local queue = MemoryStoreService:GetQueue("Matchmaking_Ranked", 30)  -- 30 s invisibility timeout

local function enqueue(player: Player, rating: number)
	local ok, err = pcall(function()
		-- value, expiration (s), priority (higher = read first)
		queue:AddAsync({ userId = player.UserId, rating = rating, jobId = game.JobId }, 120, 0)
	end)
	if not ok then warn("enqueue failed", err) end
end

-- One "matchmaker" loop per server (or only on a designated server)
local function matchmakerTick(placeId: number)
	local ok, items, readId = pcall(function()
		-- count, allOrNothing, waitTimeout
		return queue:ReadAsync(8, true, 5)
	end)
	if not ok or items == nil or #items == 0 then return end
	-- Reserve a server for the match and notify the owning servers (MessagingService), then:
	local matchId = HttpService:GenerateGUID(false)
	-- ... publish {matchId, userIds} so each origin server teleports its players ...
	pcall(function()
		queue:RemoveAsync(readId)   -- acknowledge; otherwise items reappear after the invisibility timeout
	end)
end

-- ===== Sorted map: server browser / live leaderboard =====
local servers = MemoryStoreService:GetSortedMap("ServerBrowser")

local function heartbeatServer(playerCount: number, mapName: string)
	pcall(function()
		-- key, value, expiration (s), sortKey (optional; number or string)
		servers:SetAsync(game.JobId, { players = playerCount, map = mapName }, 60, playerCount)
	end)
end

local function listServers(): { any }
	local ok, result = pcall(function()
		-- direction, count, exclusiveLowerBound?, exclusiveUpperBound?
		return servers:GetRangeAsync(Enum.SortDirection.Descending, 50)
	end)
	return if ok then result else {}
end

-- Atomic update (transform may run multiple times; return nil to cancel)
local eventScores = MemoryStoreService:GetSortedMap("EventScores")
local function bumpEventScore(teamId: string, delta: number)
	pcall(function()
		eventScores:UpdateAsync(`team_{teamId}`, function(old: any, sortKey: any)
			local new = (old or 0) + delta
			return new, new
		end, 3600)
	end)
end

-- ===== Hash map: per-key fast state (no ordering, scales well) =====
local partyMap = MemoryStoreService:GetHashMap("Parties")

local function setParty(partyId: string, members: { number })
	pcall(function()
		partyMap:SetAsync(partyId, members, 600)
	end)
end

local function getParty(partyId: string): { number }?
	local ok, v = pcall(function()
		return partyMap:GetAsync(partyId)
	end)
	return if ok then v else nil
end
```

### 5.9 MessagingService: cross-server pub/sub

Limits: message ≤ **1 KB**. Send `600 + 240 × players`/min per server. Receive per topic `40 + 80 × servers`/min. Subscriptions `20 + 8 × players` per server. Delivery is best-effort: no guarantee and no ordering. Use it for notifications, and store the truth in DataStore or MemoryStore.

```lua
--!strict
local MessagingService = game:GetService("MessagingService")
local HttpService = game:GetService("HttpService")

local TOPIC = "GlobalAnnouncement"

local function subscribe(onMessage: (text: string, sentAt: number) -> ())
	for attempt = 1, 5 do
		local ok, conn = pcall(function()
			return MessagingService:SubscribeAsync(TOPIC, function(message)
				-- message.Data = payload, message.Sent = unix time sent
				local data = message.Data
				if typeof(data) == "string" then
					local decoded = HttpService:JSONDecode(data)
					onMessage(decoded.text, message.Sent)
				end
			end)
		end)
		if ok then return conn end
		task.wait(2 ^ attempt)
	end
	warn("SubscribeAsync failed permanently")
	return nil
end

local function announce(text: string)
	local payload = HttpService:JSONEncode({ text = text, from = game.JobId })
	assert(#payload <= 1000, "message too large")
	local ok, err = pcall(MessagingService.PublishAsync, MessagingService, TOPIC, payload)
	if not ok then warn("PublishAsync failed:", err) end
end
```

**Which to use:** DataStore = durable truth. MemoryStore = shared, fast, expiring state with atomic updates. MessagingService = "something happened" notifications. Global leaderboard = OrderedDataStore, or a MemoryStore sorted map for time-boxed events.

---

## 6. Player lifecycle, cleanup, and Signals

### 6.1 The lifecycle

```
Server starts → Script runs (players may ALREADY be in game in Studio / fast joins)
Players.PlayerAdded(player)
  → load data (yields!)
  → player.CharacterAdded(character)    (every respawn; first one may fire before you connect)
       → character.Humanoid.Died
       → player.CharacterRemoving(character)
Players.PlayerRemoving(player)          (player still accessible; save + clean up here)
game:BindToClose                         (server shutdown; ≤30 s)
```

### 6.2 Correct join handling + per-player/per-character cleanup with Trove

```lua
--!strict
-- ServerScriptService/Server/Services/PlayerLifecycle.luau
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.Packages.Trove)

type Trove = typeof(Trove.new())

local playerTroves: { [Player]: Trove } = {}

local PlayerLifecycle = {}

local function onCharacterAdded(player: Player, character: Model, playerTrove: Trove)
	-- A sub-trove: cleaned when THIS character goes away, or when the player trove is cleaned
	local charTrove = playerTrove:Extend()

	local humanoid = character:WaitForChild("Humanoid", 10) :: Humanoid?
	if not humanoid or character.Parent == nil then
		playerTrove:Remove(charTrove)
		return
	end

	charTrove:Connect(humanoid.Died, function()
		print(`{player.Name} died`)
	end)

	-- Example: a server-created part that must die with the character
	local marker = charTrove:Add(Instance.new("Part"))
	marker.Anchored = true
	marker.CanCollide = false
	marker.Transparency = 1
	marker.Parent = character

	-- Clean everything when the character is removed (respawn/leave/destroy)
	charTrove:Connect(character.AncestryChanged, function(_, parent)
		if parent == nil then
			playerTrove:Remove(charTrove)   -- Remove() also cleans it
		end
	end)
end

local function onPlayerAdded(player: Player)
	if playerTroves[player] then return end   -- guard double-call (loop + event race)
	local trove = Trove.new()
	playerTroves[player] = trove

	trove:Connect(player.CharacterAdded, function(character)
		onCharacterAdded(player, character, trove)
	end)
	if player.Character then   -- character spawned before we connected
		task.spawn(onCharacterAdded, player, player.Character, trove)
	end
end

local function onPlayerRemoving(player: Player)
	local trove = playerTroves[player]
	if trove then
		playerTroves[player] = nil
		trove:Destroy()
	end
end

function PlayerLifecycle:Start()
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
	for _, player in Players:GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end
end

-- Let other modules attach per-player resources that auto-clean on leave
function PlayerLifecycle.troveFor(player: Player): Trove?
	return playerTroves[player]
end

return PlayerLifecycle
```

Trove API (v1.8): `Trove.new()`, `:Add(obj, cleanupMethod?)` (Instances → `Destroy`, connections → `Disconnect`, functions → called, threads → `task.cancel`, tables with `Destroy`/`Disconnect`, Promises via `AddPromise`), `:Connect(signal, fn)`, `:Once(signal, fn)`, `:Clone(instance)`, `:Construct(Class, ...)`, `:BindToRenderStep(name, priority, fn)`, `:Extend()` (child trove), `:Remove(obj)` (removes **and cleans**), `:Pop(obj)`, `:Clean()`, `:WrapClean()`, `:AttachToInstance(inst)` (cleans when the instance is destroyed), `:Destroy()`. Maid and Janitor are equivalent alternatives (Janitor has `:LinkToInstance`). Pick one per project.

### 6.3 Memory leak sources the bot must avoid

- **Tables keyed by Player/Instance that are never cleared.** Clear them in `PlayerRemoving` or use a per-player Trove.
- **Connections to long-lived signals** (`RunService.Heartbeat`, `Players.PlayerAdded`, a module Signal) made per object or per round and never disconnected.
- **Connections on Instances are cleaned by `:Destroy()`**, but not if you just set `Parent = nil`. Destroy what you create.
- **Player and character instances**: set `Workspace.PlayerCharacterDestroyBehavior = Enabled` so the engine calls `Destroy()` on old characters when they respawn and on the `Player` when they leave. That disconnects their connections. Don't keep references to old characters either way.
- **Closures capturing big tables** inside connections that outlive their purpose.
- **Threads waiting forever**: `WaitForChild` without a timeout, or `Signal:Wait()` on something that never fires.
- **Unbounded caches**: cap them, or use weak tables (`setmetatable({}, { __mode = "k" })`) for Instance-keyed caches. Note that weak-keyed Instance tables only release after the Instance has been destroyed and collected.

### 6.4 Signals

Use `sleitnick/signal` (pure Luau, typed, fast, no BindableEvent overhead):

```lua
--!strict
local Signal = require(ReplicatedStorage.Packages.Signal)

local roundEnded = Signal.new() :: Signal.Signal<string, { Player }>  -- (reason, winners)
local conn = roundEnded:Connect(function(reason, winners) print(reason, #winners) end)
roundEnded:Once(function(reason) print("first end:", reason) end)
roundEnded:Fire("TimeUp", {})
local reason = roundEnded:Wait()   -- yields until next Fire
conn:Disconnect()
roundEnded:DisconnectAll()
roundEnded:Destroy()
-- Signal.Wrap(rbxScriptSignal) adapts an engine signal; :FireDeferred uses task.defer.
```

Don't use `BindableEvent` for module-to-module events. It deep-copies tables and strips metatables.

### 6.5 Promises (optional)

`evaera/promise` v4 (`Promise.new`, `:andThen`, `:catch`, `Promise.all`, `:timeout`, `Promise.retryWithDelay`, cancellation) is useful for complex async flows. Plain `pcall` with retries (§15) covers most server code.

---

## 7. OOP, typed classes, state machines, ECS

### 7.1 A typed class (metatables + Luau types)

The documented pattern: define the data type, derive the class type with `typeof(setmetatable({} :: Data, Class))`, and annotate `self` explicitly.

```lua
--!strict
-- ReplicatedStorage/Shared/Classes/Inventory.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)

local Inventory = {}
Inventory.__index = Inventory

type InventoryData = {
	_slots: { [string]: number },
	_capacity: number,
	Changed: Signal.Signal<string, number>,   -- (itemId, newCount)
}

export type Inventory = typeof(setmetatable({} :: InventoryData, Inventory))

function Inventory.new(capacity: number): Inventory
	local self = setmetatable({
		_slots = {},
		_capacity = capacity,
		Changed = Signal.new(),
	} :: InventoryData, Inventory)
	return self
end

function Inventory.count(self: Inventory, itemId: string): number
	return self._slots[itemId] or 0
end

function Inventory.usedSlots(self: Inventory): number
	local n = 0
	for _ in self._slots do
		n += 1
	end
	return n
end

function Inventory.add(self: Inventory, itemId: string, amount: number): boolean
	assert(amount > 0 and amount % 1 == 0, "amount must be a positive integer")
	local current = self._slots[itemId]
	if current == nil and self:usedSlots() >= self._capacity then
		return false
	end
	local new = (current or 0) + amount
	self._slots[itemId] = new
	self.Changed:Fire(itemId, new)
	return true
end

function Inventory.remove(self: Inventory, itemId: string, amount: number): boolean
	local current = self._slots[itemId] or 0
	if current < amount then
		return false
	end
	local new = current - amount
	self._slots[itemId] = if new > 0 then new else nil
	self.Changed:Fire(itemId, new)
	return true
end

function Inventory.serialize(self: Inventory): { [string]: number }
	return table.clone(self._slots)
end

function Inventory.destroy(self: Inventory)
	self.Changed:Destroy()
	table.clear(self._slots)
end

return Inventory
```

```lua
local Inventory = require(ReplicatedStorage.Shared.Classes.Inventory)
local inv = Inventory.new(20)
inv.Changed:Connect(function(id, n) print(id, n) end)
inv:add("apple", 3)        -- method call works; autocomplete knows `inv: Inventory`
```

Prefer **composition** over metatable inheritance chains.

### 7.2 State machines

Most game objects (round, NPC AI, weapon, door) are state machines. Make them explicit.

```lua
--!strict
-- ReplicatedStorage/Shared/StateMachine.luau
export type StateDef<S, C> = {
	enter: ((ctx: C, from: S?) -> ())?,
	exit: ((ctx: C, to: S) -> ())?,
	update: ((ctx: C, dt: number) -> S?)?,   -- return a state to transition
	allowed: { S }?,                         -- legal next states (nil = any)
}

local StateMachine = {}
StateMachine.__index = StateMachine

type Data<S, C> = {
	_states: { [S]: StateDef<S, C> },
	_ctx: C,
	current: S?,
}
export type StateMachine<S, C> = typeof(setmetatable({} :: Data<S, C>, StateMachine))

function StateMachine.new<S, C>(states: { [S]: StateDef<S, C> }, ctx: C): StateMachine<S, C>
	return setmetatable({ _states = states, _ctx = ctx, current = nil } :: Data<S, C>, StateMachine) :: any
end

function StateMachine.transition<S, C>(self: StateMachine<S, C>, to: S): boolean
	local from = self.current
	if from == to then return false end
	if from ~= nil then
		local fromDef = self._states[from]
		if fromDef.allowed and not table.find(fromDef.allowed, to) then
			warn(`Illegal transition {tostring(from)} -> {tostring(to)}`)
			return false
		end
		if fromDef.exit then fromDef.exit(self._ctx, to) end
	end
	self.current = to
	local toDef = self._states[to]
	assert(toDef, `Unknown state {tostring(to)}`)
	if toDef.enter then toDef.enter(self._ctx, from) end
	return true
end

function StateMachine.update<S, C>(self: StateMachine<S, C>, dt: number)
	local cur = self.current
	if cur == nil then return end
	local def = self._states[cur]
	if def.update then
		local nextState = def.update(self._ctx, dt)
		if nextState ~= nil then
			self:transition(nextState)
		end
	end
end

return StateMachine
```

Example: a simple NPC with `"Idle" | "Chase" | "Attack"` states, where `update` returns the next state based on the distance to the nearest player. Drive all NPCs from **one** Heartbeat loop, not one loop per NPC.

### 7.3 ECS with jecs (when it pays off)

Use an ECS when you have **hundreds or thousands of similar entities** with data-oriented behavior (projectiles, crowds, resource nodes, tower defense units), or when composing behavior from components beats deep class trees. Skip it for small games, UI, or a few unique objects. Plain modules plus tags are simpler.

```lua
--!strict
-- jecs 0.11 (wally: ukendio/jecs)
local jecs = require(ReplicatedStorage.Packages.jecs)
local RunService = game:GetService("RunService")

local world = jecs.world()

local Position = world:component() :: jecs.Id<Vector3>
local Velocity = world:component() :: jecs.Id<Vector3>
local Lifetime = world:component() :: jecs.Id<number>
local Model = world:component() :: jecs.Id<BasePart>
local Projectile = world:entity()   -- a tag (component without data)

local function spawnProjectile(origin: Vector3, dir: Vector3, part: BasePart)
	local e = world:entity()
	world:set(e, Position, origin)
	world:set(e, Velocity, dir.Unit * 120)
	world:set(e, Lifetime, 3)
	world:set(e, Model, part)
	world:add(e, Projectile)
	return e
end

-- Cleanup hook: destroy the part when the Model component is removed / entity deleted
world:set(Model, jecs.OnRemove, function(entity)
	local part = world:get(entity, Model)
	if part then part:Destroy() end
end)

local toDelete: { jecs.Entity } = {}
RunService.Heartbeat:Connect(function(dt)
	for e, pos, vel, life in world:query(Position, Velocity, Lifetime):with(Projectile) do
		local newPos = pos + vel * dt
		world:set(e, Position, newPos)
		local remaining = life - dt
		if remaining <= 0 then
			table.insert(toDelete, e)
		else
			world:set(e, Lifetime, remaining)
		end
	end
	for _, e in toDelete do
		world:delete(e)   -- don't structurally change the archetype mid-iteration
	end
	table.clear(toDelete)

	-- Render/sync step (batch CFrame writes)
	local parts, cframes = {}, {}
	for _, part, pos in world:query(Model, Position) do
		table.insert(parts, part)
		table.insert(cframes, CFrame.new(pos))
	end
	workspace:BulkMoveTo(parts, cframes, Enum.BulkMoveMode.FireCFrameChanged)
end)
```

jecs features: relationships (`jecs.pair(ChildOf, parent)`), wildcards, hooks (`OnAdd` / `OnChange` / `OnRemove`), cached queries (`:cached()`), and query filters (`:with`, `:without`). See `reference/libraries/Ukendio_jecs/how_to/`.

---
## 8. Generic round-based game loop

The server owns the round state. It replicates the state through **attributes** on `ReplicatedStorage` (cheap, no remotes needed), and clients listen with `GetAttributeChangedSignal`. Each round has its own Trove.

```lua
--!strict
-- ServerScriptService/Server/Services/RoundService.luau
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Trove = require(ReplicatedStorage.Packages.Trove)
local Signal = require(ReplicatedStorage.Packages.Signal)
local PlayerData = require(script.Parent.PlayerData)

type RoundState = "Waiting" | "Intermission" | "InRound" | "Results"

local CONFIG = table.freeze({
	MIN_PLAYERS = 2,
	INTERMISSION = 15,
	ROUND_LENGTH = 120,
	RESULTS = 6,
	WIN_COINS = 50,
	PARTICIPATION_COINS = 10,
})

local RoundService = {}
RoundService.RoundEnded = Signal.new() -- (winners: {Player})

local alive: { [Player]: boolean } = {}

local function setState(state: RoundState, endsAt: number?)
	ReplicatedStorage:SetAttribute("RoundState", state)
	-- Clients compute "time left" locally from a synced clock: no per-second network traffic.
	ReplicatedStorage:SetAttribute("StateEndsAt", endsAt or 0)
end

local function countAlive(): number
	local n = 0
	for player, isAlive in alive do
		if isAlive and player.Parent == Players then
			n += 1
		end
	end
	return n
end

-- Waits until `seconds` pass or `predicate()` becomes true. Checks 4x per second (cheap, bounded).
local function waitUntil(seconds: number, predicate: (() -> boolean)?)
	local deadline = os.clock() + seconds
	while os.clock() < deadline do
		if predicate and predicate() then return end
		task.wait(0.25)
	end
end

local function runRound()
	local roundTrove = Trove.new()
	local map = roundTrove:Clone(ServerStorage.Maps:GetChildren()[math.random(#ServerStorage.Maps:GetChildren())])
	map.Parent = workspace
	local spawns = map:WaitForChild("Spawns"):GetChildren()

	table.clear(alive)
	for i, player in Players:GetPlayers() do
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if char and hum and hum.Health > 0 then
			alive[player] = true
			local spawnPart = spawns[(i - 1) % #spawns + 1] :: BasePart
			char:PivotTo(spawnPart.CFrame + Vector3.new(0, 3, 0))
			-- if using MovementGuard: MovementGuard.serverTeleport(player, ...)
			roundTrove:Connect(hum.Died, function()
				alive[player] = false
			end)
		end
	end
	roundTrove:Connect(Players.PlayerRemoving, function(player)
		alive[player] = nil
	end)

	setState("InRound", workspace:GetServerTimeNow() + CONFIG.ROUND_LENGTH)
	waitUntil(CONFIG.ROUND_LENGTH, function()
		return countAlive() <= 1
	end)

	-- Determine winners and reward (server-side)
	local winners: { Player } = {}
	for player, isAlive in alive do
		if player.Parent == Players then
			if isAlive then
				table.insert(winners, player)
				PlayerData.addCoins(player, CONFIG.WIN_COINS, "RoundWin")
				PlayerData.incrementWins(player)
			else
				PlayerData.addCoins(player, CONFIG.PARTICIPATION_COINS, "RoundParticipation")
			end
		end
	end

	setState("Results", workspace:GetServerTimeNow() + CONFIG.RESULTS)
	RoundService.RoundEnded:Fire(winners)
	task.wait(CONFIG.RESULTS)

	-- Respawn everyone in the lobby and destroy round resources
	roundTrove:Destroy()   -- destroys the map clone and disconnects every round connection
	table.clear(alive)
	for _, player in Players:GetPlayers() do
		task.spawn(function()
			pcall(player.LoadCharacterAsync, player)
		end)
	end
end

function RoundService:Start()
	task.spawn(function()
		while true do
			if #Players:GetPlayers() < CONFIG.MIN_PLAYERS then
				setState("Waiting")
				waitUntil(math.huge, function()
					return #Players:GetPlayers() >= CONFIG.MIN_PLAYERS
				end)
			end
			setState("Intermission", workspace:GetServerTimeNow() + CONFIG.INTERMISSION)
			task.wait(CONFIG.INTERMISSION)
			if #Players:GetPlayers() >= CONFIG.MIN_PLAYERS then
				local ok, err = xpcall(runRound, debug.traceback)
				if not ok then
					warn("[RoundService] round crashed:\n" .. err)   -- the loop survives a bad round
					task.wait(3)
				end
			end
		end
	end)
end

return RoundService
```

Client timer (no polling of the server, just a local render):

```lua
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local label: TextLabel = script.Parent

RunService.RenderStepped:Connect(function()
	local state = ReplicatedStorage:GetAttribute("RoundState") or "Waiting"
	local endsAt = ReplicatedStorage:GetAttribute("StateEndsAt") or 0
	local left = math.max(0, math.ceil(endsAt - workspace:GetServerTimeNow()))
	label.Text = if endsAt > 0 then `{state} - {left}s` else state
end)
```

(Setting `Text` to the same string every frame is cheap. If you want to avoid even that, only assign when the value changes.)

---

## 9. Server-authoritative currency and purchase flows

### 9.1 In-game currency shop

```lua
--!strict
-- ReplicatedStorage/Shared/Config/ShopCatalog.luau  (shared so the client can DISPLAY prices)
export type CatalogItem = { name: string, price: number, category: "Skin" | "Tool" }
local ShopCatalog: { [string]: CatalogItem } = {
	sword_iron = { name = "Iron Sword", price = 250, category = "Tool" },
	skin_neon = { name = "Neon Skin", price = 1000, category = "Skin" },
}
return table.freeze(ShopCatalog)
```

```lua
--!strict
-- ServerScriptService/Server/Services/ShopService.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Guard = require(ReplicatedStorage.Shared.Guard)
local ShopCatalog = require(ReplicatedStorage.Shared.Config.ShopCatalog)
local PlayerData = require(script.Parent.PlayerData)
local Net = require(script.Parent.Parent.Net)

export type PurchaseResult = "Ok" | "UnknownItem" | "AlreadyOwned" | "InsufficientFunds" | "NotLoaded"

local ShopService = {}

-- Pure server logic: check + deduct + grant with NO yields in between (atomic in Luau's scheduler).
function ShopService.purchase(player: Player, itemId: string): (boolean, PurchaseResult)
	local item = ShopCatalog[itemId]                       -- the price comes from SERVER config
	if not item then return false, "UnknownItem" end

	local data = PlayerData.get(player)
	if not data then return false, "NotLoaded" end
	if data.OwnedItems[itemId] then return false, "AlreadyOwned" end

	if not PlayerData.trySpendCoins(player, item.price) then
		return false, "InsufficientFunds"
	end
	data.OwnedItems[itemId] = true
	return true, "Ok"
end

function ShopService:Init()
	Net.onInvoke("RequestPurchase", { Guard.oneOf(ShopCatalog) }, { rate = 2, burst = 4 },
		function(player: Player, itemId: string)
			return ShopService.purchase(player, itemId)
		end)
end

return ShopService
```

If you add a `task.wait`, a DataStore call, or any yield between the balance check and the deduction, two concurrent requests can both pass the check, and the player spends money they don't have. Keep that critical section yield-free.

### 9.2 Developer Products (Robux) with BindReceiptHandler + ProfileStore

`MarketplaceService:BindReceiptHandler(Enum.ReceiptType.DeveloperProduct, handler, filter?)` is the modern API. It returns an `RBXScriptConnection`. Handlers return `Enum.ReceiptDecision.Processed` or `NotProcessedYet`. A matching bound handler takes precedence over the legacy `MarketplaceService.ProcessReceipt` callback, which still works (returning `Enum.ProductPurchaseDecision`). Unresolved receipts are redelivered later, or when the player next joins. Grant **idempotently** by caching `PurchaseId`, and return `Processed` only after the grant is **saved**.

```lua
--!strict
-- ServerScriptService/Server/Services/ReceiptService.luau
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local PlayerData = require(script.Parent.PlayerData)

local PURCHASE_ID_CACHE_SIZE = 100

-- productId -> grant function (must not yield; mutate profile.Data only)
local PRODUCTS: { [number]: (data: PlayerData.Data) -> () } = {
	[123456789] = function(data) data.Coins += 1000 end,    -- replace with real product ids
	[987654321] = function(data) data.Gems += 50 end,
}

local function waitForSave(profile: any, purchaseId: string): boolean
	local function saved(): boolean
		local cache = profile.LastSavedData.PurchaseIdCache
		return cache ~= nil and table.find(cache, purchaseId) ~= nil
	end
	while profile:IsActive() do
		if saved() then return true end
		local before = profile.LastSavedData
		profile:Save()
		if profile.LastSavedData == before then
			profile.OnAfterSave:Wait()
		end
		if saved() then return true end
		task.wait(10)   -- DataStore trouble; keep trying while the session lives
	end
	return false
end

local function handleReceipt(receipt: { [string]: any }): Enum.ReceiptDecision
	local player = Players:GetPlayerByUserId(receipt.PlayerId)
	if not player then
		return Enum.ReceiptDecision.NotProcessedYet
	end
	local grant = PRODUCTS[receipt.ProductId]
	if not grant then
		warn(`[Receipt] unknown product {receipt.ProductId}`)
		return Enum.ReceiptDecision.NotProcessedYet
	end

	if PlayerData.waitFor(player) == nil then
		return Enum.ReceiptDecision.NotProcessedYet
	end
	local profile = PlayerData.getProfile(player)
	if not profile or not profile:IsActive() then
		return Enum.ReceiptDecision.NotProcessedYet
	end

	local data = profile.Data
	if table.find(data.PurchaseIdCache, receipt.PurchaseId) == nil then
		local ok, err = pcall(grant, data)
		if not ok then
			warn("[Receipt] grant failed:", err)
			return Enum.ReceiptDecision.NotProcessedYet
		end
		while #data.PurchaseIdCache >= PURCHASE_ID_CACHE_SIZE do
			table.remove(data.PurchaseIdCache, 1)
		end
		table.insert(data.PurchaseIdCache, receipt.PurchaseId)
		PlayerData.Changed:Fire(player, "Coins", data.Coins)
	end

	return if waitForSave(profile, receipt.PurchaseId)
		then Enum.ReceiptDecision.Processed
		else Enum.ReceiptDecision.NotProcessedYet
end

local ReceiptService = {}
function ReceiptService:Init()
	MarketplaceService:BindReceiptHandler(Enum.ReceiptType.DeveloperProduct, handleReceipt)
end
return ReceiptService
```

Client prompt: `MarketplaceService:PromptProductPurchase(Players.LocalPlayer, productId)`. **Game passes**: check `MarketplaceService:UserOwnsGamePassAsync(userId, passId)` on the server (pcall it, cache per session), and listen to `PromptGamePassPurchaseFinished` on the server to grant immediately. Never trust a client "I bought it" message.

---

## 10. Physics and network ownership

- Unanchored parts are simulated by the server or by a client (the **network owner**). Players own their characters, and by default parts near a player are automatically given to that player.
- `part:SetNetworkOwner(nil)` = server owns it (authoritative, but laggy for the player interacting with it). `part:SetNetworkOwner(player)` = smooth for that player, but **that client can move it however it likes**. `part:SetNetworkOwnershipAuto()` reverts to automatic. Call these on the **assembly root**, and only on the server. Anchored parts can't have owners (they error).
- Vehicles: give ownership to the driver when they sit (`VehicleSeat.Occupant` changed), and take it back on exit. Validate speed server-side if it matters.
- Projectiles that decide hits: simulate on the server (raycasts, or a cast library), and let clients render a cosmetic copy.
- Exploiters can fling or teleport anything they own, including their character. Validate gameplay outcomes server-side (§4.4–4.5). For competitive games, consider Server Authority (§4.6).
- Use `CollisionGroups` (`PhysicsService:RegisterCollisionGroup`, `BasePart.CollisionGroup`) instead of lots of `Touched` filtering.

---

## 11. CollectionService tags and Attributes (data-driven design)

Tag instances in Studio (or at runtime), and write **one** system per tag instead of copying scripts into every part.

```lua
--!strict
-- ServerScriptService/Server/Services/KillBricks.luau
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.Packages.Trove)

local TAG = "KillBrick"
local troves: { [Instance]: any } = {}

local function setup(part: Instance)
	if not part:IsA("BasePart") or troves[part] then return end
	local trove = Trove.new()
	troves[part] = trove
	trove:Connect(part.Touched, function(hit: BasePart)
		local char = hit.Parent
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum and Players:GetPlayerFromCharacter(char) then
			local damage = part:GetAttribute("Damage") or 100   -- per-instance config via attributes
			hum:TakeDamage(damage)
		end
	end)
end

local function teardown(part: Instance)
	local trove = troves[part]
	if trove then
		troves[part] = nil
		trove:Destroy()
	end
end

local KillBricks = {}
function KillBricks:Start()
	CollectionService:GetInstanceAddedSignal(TAG):Connect(setup)
	CollectionService:GetInstanceRemovedSignal(TAG):Connect(teardown)
	for _, inst in CollectionService:GetTagged(TAG) do
		task.spawn(setup, inst)
	end
end
return KillBricks
```

- Tag APIs: `inst:AddTag`, `inst:RemoveTag`, `inst:HasTag`, `CollectionService:GetTagged`, plus the added/removed signals. Tags replicate.
- **On the client, with streaming on**, the added and removed signals fire as instances stream in and out. That's exactly what you want for client visuals. Always implement teardown.
- **Attributes** (`SetAttribute` / `GetAttribute` / `GetAttributeChangedSignal` / `GetAttributes`) hold small per-instance config and state. They replicate server→client. Supported types are primitives, Vector3, CFrame, Color3, UDim2, NumberRange, etc. Tables aren't supported. Prefer attributes over `IntValue`/`StringValue` children.
- Attributes set by a client don't replicate to the server. Never read client-writable attributes as truth.

---

## 12. RunService events

Frame order (per frame): **`PreRender`** (client only; was `RenderStepped`) → `PreAnimation` → **`PreSimulation`** (was `Stepped`) → physics → **`PostSimulation`** (was `Heartbeat`) → replication.

| Event | Realm | Use |
|---|---|---|
| `PreRender` / `RenderStepped` / `BindToRenderStep(name, priority, fn)` | client | camera, local visual interpolation, input-to-visual. Keep it tiny: it blocks the frame. `BindToRenderStep` lets you order work relative to `Enum.RenderPriority.Camera` / `Input` / `Character`. Unbind with `UnbindFromRenderStep`. |
| `PreSimulation` / `Stepped` | both | set forces or velocities before physics |
| `PostSimulation` / `Heartbeat` | both | game logic ticks, after physics |
| `BindToSimulation` | both | Server Authority simulation (§4.6) |

`RenderStepped`, `Stepped`, and `Heartbeat` aren't deprecated, but the new names are preferred in new code. Use the `dt` argument. Never assume 60 FPS. Clients can run at 30, 60, 120, or 240 Hz.

---

## 13. Parallel Luau (Actors)

Scripts under an `Actor` instance can run **in parallel** after `task.desynchronize()` or inside `:ConnectParallel()`. Parallel code can **read** most of the DataModel but **can't write** to it. Call `task.synchronize()` before writing. Each Actor has its own Luau VM, so modules are required separately per Actor and module state isn't shared. Share data with `SharedTable` (via `SharedTableRegistry`) or with Actor messages (`actor:SendMessage(topic, ...)` / `BindToMessageParallel`).

```lua
--!strict
-- Script parented under an Actor (one of N worker actors cloned at startup)
local actor = script:GetActor()
assert(actor, "must be under an Actor")

actor:BindToMessageParallel("ComputeChunk", function(chunkX: number, chunkZ: number)
	-- Parallel phase: heavy pure computation (noise, pathfinding prep, raycasts are allowed)
	local heights = table.create(16 * 16)
	for x = 0, 15 do
		for z = 0, 15 do
			heights[x * 16 + z + 1] = math.noise((chunkX * 16 + x) / 64, (chunkZ * 16 + z) / 64) * 20
		end
	end
	task.synchronize()   -- Serial phase: safe to touch the DataModel
	-- build parts / write terrain from `heights` here
end)
```

Use it for procedural generation, many-NPC sensing (raycasts), and heavy math. Don't use it for small tasks. The scheduling overhead outweighs the gain. Run the MicroProfiler to confirm the work actually spreads across cores.

---

## 14. Performance

**Measure first:** MicroProfiler (Ctrl+F6, or `debug.profilebegin("Label")` / `debug.profileend()` around hot code), the **Script Profiler** (Developer Console → Scripts tab), Script Performance (activity %), and Developer Console memory/network stats.

**Rules:**
- **Avoid polling.** One central loop per system, event-driven UI, and attributes plus changed signals.
- **Cache lookups.** `game:GetService` once at the top. Cache `FindFirstChild` results and the character's parts (re-cache on `CharacterAdded`).
- **Batch property writes.** Use `workspace:BulkMoveTo(parts, cframes, mode)` for many CFrames. Set properties before parenting a new instance (parent last).
- **Object pooling** for frequently spawned objects (bullets, VFX, damage numbers):

```lua
--!strict
local Pool = {}
Pool.__index = Pool
export type Pool = typeof(setmetatable({} :: { _template: Instance, _free: { Instance } }, Pool))

function Pool.new(template: Instance, prewarm: number): Pool
	local self = setmetatable({ _template = template, _free = {} }, Pool)
	for _ = 1, prewarm do
		table.insert(self._free, template:Clone())
	end
	return self
end

function Pool.get(self: Pool, parent: Instance): Instance
	local obj = table.remove(self._free) or self._template:Clone()
	obj.Parent = parent
	return obj
end

function Pool.release(self: Pool, obj: Instance)
	obj.Parent = nil   -- parking outside the DataModel; or move far away (cheaper for parts: CFrame offscreen)
	table.insert(self._free, obj)
end
return Pool
```

- **Network:** send deltas, not full state. Throttle to 10–20 Hz. Use UnreliableRemoteEvent for cosmetic streams and buffers for compact payloads. Don't replicate what the client can compute (timers via `GetServerTimeNow`).
- **Server CPU:** NPC AI on a staggered schedule (update 1/N of the NPCs per frame). Use `@native` for hot math. Use spatial queries (`GetPartBoundsInRadius` with `OverlapParams`) instead of looping over every part.
- **Memory:** destroy what you create. Avoid huge numbers of unique meshes and textures. Watch `LuaHeap` in the Developer Console.

### 14.1 StreamingEnabled implications for client code

With `Workspace.StreamingEnabled = true` (the default for new places, and required by Server Authority), clients only have nearby parts of the Workspace.
- **Never assume an instance in Workspace exists on the client.** Use `WaitForChild(name, timeout)` for things that should arrive, and handle `nil`. Better yet, react to `CollectionService` tag signals (stream in = added, stream out = removed).
- Models are streamed according to `Model.ModelStreamingMode`: `Default`/`Nonatomic` (parts arrive piecemeal), **`Atomic`** (the whole model arrives at once, all descendants present), **`Persistent`** (always present for all clients, never streamed out), `PersistentPerPlayer` (persistent for specific players via `Model:AddPersistentPlayer`). Mark models your client scripts index into (for example, a shop NPC with UI anchors) `Atomic` or `Persistent`. Use `Persistent` sparingly because it costs memory.
- `Player:RequestStreamAroundAsync(position, timeout?)` on the server pre-streams an area before you teleport a player there.
- Instances passed through remotes arrive as `nil` if they aren't streamed in on that client. Send IDs or positions instead, or check for `nil`.
- `ReplicatedStorage` contents and `Persistent` models are always available.

---

## 15. Error handling and retries

- `pcall(fn, ...)` returns `(ok, resultOrErr)`. `xpcall(fn, debug.traceback, ...)` keeps the stack trace. Use it at system boundaries (loader, handlers, round loop).
- `error("msg", 2)` blames the caller. `error({ code = "X" })` lets you throw a structured error.
- Don't pcall everything. Let programmer bugs surface. pcall **web calls** and **untrusted callbacks**.

```lua
--!strict
-- ReplicatedStorage/Shared/Retry.luau
-- Exponential backoff with jitter for web calls (DataStore, Http, Teleport, Marketplace...).
local Retry = {}

function Retry.call<T...>(fn: () -> T..., attempts: number?, baseDelay: number?): (boolean, ...any)
	local maxAttempts = attempts or 5
	local delay = baseDelay or 1
	local lastErr: any
	for attempt = 1, maxAttempts do
		local result = table.pack(pcall(fn))
		if result[1] then
			return table.unpack(result, 1, result.n)
		end
		lastErr = result[2]
		if attempt < maxAttempts then
			local wait = delay * 2 ^ (attempt - 1)
			task.wait(wait + math.random() * wait * 0.25)   -- jitter avoids thundering herds
		end
	end
	return false, lastErr
end

return Retry
```

```lua
local ok, info = Retry.call(function()
	return MarketplaceService:GetProductInfoAsync(productId, Enum.InfoType.Product)
end)
```

Don't retry inside `BindToClose` past the ~30 s budget. Don't retry validation failures (4xx-style errors). Respect DataStore budgets (`GetRequestBudgetForRequestType`).

---

## 16. TeleportService and reserved servers

- Teleports are **server-side**: `TeleportService:TeleportAsync(placeId, players, teleportOptions?)`. The legacy `Teleport`, `TeleportToPlaceInstance`, `TeleportToPrivateServer`, `TeleportPartyAsync`, and `ReserveServer` / `ReserveServerAsync` are deprecated.
- **Reserved server:** set `TeleportOptions.ReservedServerId` to any GUID. The first teleport with a new ID creates the server, and reusing the ID routes players to the same server.
- Teleports can fail (`TeleportService.TeleportInitFailed(player, teleportResult, errorMessage, placeId, teleportOptions)`). Retry.
- Teleport data is **client-visible and client-forgeable**. Use it for non-sensitive context only (map choice, party ID). Keep authoritative data in DataStore/MemoryStore keyed by the reserved server ID.

```lua
--!strict
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Retry = require(game:GetService("ReplicatedStorage").Shared.Retry)

local ARENA_PLACE_ID = 0   -- set your place id

local function sendToNewArena(players: { Player }, mapName: string): boolean
	local options = Instance.new("TeleportOptions")
	options.ReservedServerId = HttpService:GenerateGUID(false)
	options:SetTeleportData({ map = mapName })    -- non-sensitive only
	local ok, err = Retry.call(function()
		return TeleportService:TeleportAsync(ARENA_PLACE_ID, players, options)
	end, 3, 2)
	if not ok then warn("Teleport failed:", err) end
	return ok
end

TeleportService.TeleportInitFailed:Connect(function(player, result, message, placeId, options)
	warn(`Teleport failed for {player.Name}: {result.Name} {message}`)
	-- retry once after a delay for transient failures (Flooded, Failure)
	if result == Enum.TeleportResult.Flooded or result == Enum.TeleportResult.Failure then
		task.delay(3, function()
			pcall(TeleportService.TeleportAsync, TeleportService, placeId, { player }, options)
		end)
	end
end)
```

In the destination server, `player:GetJoinData().TeleportData` gives the data. `game.PrivateServerId ~= "" and game.PrivateServerOwnerId == 0` means this is a reserved server (owner ≠ 0 means a VIP/private server).

---

## 17. Chat and text filtering

- **TextChatService** is the only chat system. Legacy chat is retired. Customize it with `TextChatService.OnIncomingMessage` (client, formatting via `TextChatMessageProperties`), `TextChannel:SendAsync`, `TextChatCommand` (with `PrimaryAlias` like `"/spectate"` and a `Triggered(originTextSource, unfilteredText)` event), and `TextChatService:DisplayBubble`. Chat messages sent through TextChatService are filtered automatically.
- **Your own user text** (pet names, signs, guild names, custom message boards, text pulled from DataStores or external HTTP) must be filtered on the server before others see it. **Filter again when you display stored text**, because filter rules change.

```lua
--!strict
local TextService = game:GetService("TextService")

-- Returns filtered text safe for everyone in the server, or nil on failure (show nothing / placeholder).
local function filterForBroadcast(text: string, fromUserId: number): string?
	if #text == 0 or #text > 100 then return nil end
	local ok, result = pcall(function()
		return TextService:FilterStringAsync(text, fromUserId, Enum.TextFilterContext.PublicChat)
	end)
	if not ok then
		warn("FilterStringAsync failed:", result)
		return nil      -- never fall back to the raw text
	end
	local ok2, filtered = pcall(function()
		return (result :: TextFilterResult):GetNonChatStringForBroadcastAsync()
	end)
	return if ok2 then filtered else nil
end

-- Usage: Net.onEvent("NamePet", { Guard.string(20, 1) }, { rate = 0.5, burst = 2 }, function(player, name)
--   local safe = filterForBroadcast(name, player.UserId)
--   if safe then pet:SetAttribute("DisplayName", safe) end
-- end)
```

For text shown only to one specific user, use `GetNonChatStringForUserAsync(toUserId)`. Don't filter per keystroke. Filter on submit. Check `TextChatService:CanUsersChatAsync` before enabling player-to-player text features in custom UIs.

---

## 18. HttpService

- Enable it in Game Settings → Security (`HttpService.HttpEnabled`). Server-only. Limit is **500 requests/min per server** to external hosts. Open Cloud endpoints called from in-game have a separate 2500/min budget.
- `HttpService:RequestAsync({ Url, Method, Headers, Body })` returns `{ Success, StatusCode, StatusMessage, Headers, Body }`. Check `Success`, then decode with `JSONDecode` inside a pcall.
- **Secrets:** store API keys in the experience's Secrets (Creator Dashboard) and read them with `HttpService:GetSecret("name")`, which returns a `Secret` you can use in headers/URLs (`secret:AddPrefix("Bearer ")`). Never hardcode keys in scripts.
- `JSONEncode` / `JSONDecode` are also used for size checks and for serializing data. `GenerateGUID(false)` gives an ID without braces.
- Filter any external text before displaying it (§17).

```lua
--!strict
local HttpService = game:GetService("HttpService")
local Retry = require(game:GetService("ReplicatedStorage").Shared.Retry)

local function getJson(url: string): any?
	local ok, response = Retry.call(function()
		local res = HttpService:RequestAsync({ Url = url, Method = "GET" })
		if not res.Success then
			error(`HTTP {res.StatusCode} {res.StatusMessage}`)
		end
		return res
	end, 4, 1)
	if not ok then return nil end
	local decodeOk, data = pcall(HttpService.JSONDecode, HttpService, response.Body)
	return if decodeOk then data else nil
end
```

---

## 19. Tooling: testing, linting, formatting, type checking

| Tool | Purpose | Config |
|---|---|---|
| **Rojo** | sync files ↔ Studio | `default.project.json` |
| **Wally** (or pesde) | packages | `wally.toml` → `Packages/`, `ServerPackages/` |
| **Rokit** (or Aftman) | pin tool versions | `rokit.toml` |
| **luau-lsp** | type checking, autocomplete in VS Code / CLI (`luau-lsp analyze`) | `.luaurc` + Rojo `sourcemap.json` (`rojo sourcemap --watch default.project.json -o sourcemap.json`) |
| **selene** | linter | `selene.toml`: `std = "roblox"` (`"roblox+testez"` with TestEZ) |
| **StyLua** | formatter | `stylua.toml` |
| **Jest-Lua** (`jsdotlua/jest`) | tests (current Roblox standard) | `jest.config.luau`, run via `run-in-roblox` or Open Cloud Luau execution |
| **TestEZ** | tests (legacy; still common) | `describe` / `it` / `expect(x).to.equal(y)` |

```toml
# selene.toml
std = "roblox"
[lints]
unused_variable = "warn"
shadowing = "warn"
```

```toml
# stylua.toml
column_width = 120
line_endings = "Unix"
indent_type = "Tabs"
indent_width = 4
quote_style = "AutoPreferDouble"
call_parentheses = "Always"
```

```json
// .luaurc
{ "languageMode": "strict", "lint": { "*": true }, "aliases": { "Shared": "src/shared" } }
```

Jest-Lua test example:

```lua
-- src/shared/__tests__/Guard.spec.luau
local JestGlobals = require("@DevPackages/JestGlobals")
local describe, it, expect = JestGlobals.describe, JestGlobals.it, JestGlobals.expect
local Guard = require("../Guard")

describe("Guard.number", function()
	it("rejects NaN and infinity", function()
		local check = Guard.number(0, 100)
		expect(check(0 / 0)).toBe(false)
		expect(check(math.huge)).toBe(false)
		expect(check(50)).toBe(true)
	end)
end)
```

Test pure modules (Guard, StateMachine, Inventory, migrations, economy math) and keep Roblox-service code thin. **Always test migrations** against sample old-version data.

---

## 20. Recommended project structure (Rojo)

```
my-game/
├─ default.project.json
├─ wally.toml  rokit.toml  selene.toml  stylua.toml  .luaurc
├─ src/
│  ├─ server/                         → ServerScriptService.Server
│  │  ├─ init.server.luau             (bootstrap: Loader.load(script.Services))
│  │  ├─ Net.luau                     (remote creation + validation + rate limits)
│  │  └─ Services/
│  │     ├─ PlayerData.luau           (ProfileStore)
│  │     ├─ Leaderstats.luau
│  │     ├─ PlayerLifecycle.luau
│  │     ├─ RoundService.luau
│  │     ├─ ShopService.luau
│  │     ├─ ReceiptService.luau
│  │     └─ MovementGuard.luau
│  ├─ client/                         → StarterPlayer.StarterPlayerScripts.Client
│  │  ├─ init.client.luau             (bootstrap: Loader.load(script.Controllers))
│  │  ├─ Controllers/  (UIController, InputController, CameraController, EffectsController)
│  │  └─ UI/           (components: Fusion / Vide / React-Lua, or plain Instances)
│  ├─ shared/                         → ReplicatedStorage.Shared
│  │  ├─ Loader.luau  Guard.luau  Retry.luau  StateMachine.luau  Types.luau
│  │  ├─ Config/      (ShopCatalog, GameConfig — frozen tables)
│  │  ├─ Classes/     (Inventory, ...)
│  │  └─ Net/         (generated Blink output, if used)
│  └─ assets/  (or keep models in a .rbxl and map via Rojo)
├─ Packages/                          → ReplicatedStorage.Packages (Trove, Signal, Promise, jecs)
├─ ServerPackages/                    → ServerScriptService.ServerPackages (ProfileStore)
└─ tests/
```

```json
{
  "name": "my-game",
  "tree": {
    "$className": "DataModel",
    "ReplicatedStorage": {
      "Shared": { "$path": "src/shared" },
      "Packages": { "$path": "Packages" }
    },
    "ServerScriptService": {
      "Server": { "$path": "src/server" },
      "ServerPackages": { "$path": "ServerPackages" }
    },
    "StarterPlayer": {
      "StarterPlayerScripts": { "Client": { "$path": "src/client" } }
    },
    "Workspace": { "$properties": { "StreamingEnabled": true, "SignalBehavior": "Deferred" } }
  }
}
```


---

## 21. Common bugs the bot must avoid

| # | Bug | Symptom | Fix |
|---|---|---|---|
| 1 | Only connecting `PlayerAdded` | First player (Studio) never gets data or leaderstats | Also loop `Players:GetPlayers()` with `task.spawn` |
| 2 | Only connecting `CharacterAdded` | First spawn missed | Check `player.Character` first |
| 3 | Trusting remote arguments (price, damage, amount, target player) | Infinite money, one-shot kills | Server-side config and validation (`Guard`), send intent only |
| 4 | Not checking NaN/inf | `NaN` coins corrupts data forever | `v == v` and finite checks |
| 5 | `RemoteFunction:InvokeClient` | Server thread hangs forever | RemoteEvents for server→client |
| 6 | `SetAsync` for player data / no session lock | Rollbacks, item duplication | ProfileStore or `UpdateAsync` with session locking |
| 7 | Replacing `profile.Data = {...}` | Data not saved | Mutate fields |
| 8 | Saving Instances/Vector3 in DataStore | Silent nil or errors | Serialize to numbers/strings/buffers |
| 9 | Yield between balance check and deduct | Double-spend | Atomic, yield-free critical section |
| 10 | `ProcessReceipt`/handler returns granted before saving, or grants twice | Lost or duplicated purchases | PurchaseId cache + wait for save |
| 11 | Using `wait()`, `spawn()`, `delay()` | Throttled, hidden errors | `task.*` |
| 12 | Connections never disconnected | Memory grows, duplicate effects every round | Trove per player/character/round |
| 13 | Tables keyed by Player never cleared | Memory leak | Clear on `PlayerRemoving` |
| 14 | Indexing `workspace.Map.Door` on the client | Errors with StreamingEnabled | `WaitForChild` with timeout, tags, `ModelStreamingMode` |
| 15 | `WaitForChild` without timeout on optional items | Infinite yield warnings, stuck threads | Pass a timeout and handle nil |
| 16 | Displaying unfiltered user text | Game moderated or removed | `TextService:FilterStringAsync` + `GetNonChatStringForBroadcastAsync` |
| 17 | Hundreds of `while true do task.wait() end` loops | High script activity | Central loop, events |
| 18 | DataStore calls in loops or on every change | Throttling, errors 301–306 | Cache in memory, autosave, budget checks |
| 19 | Writing OrderedDataStore on every stat change | Ordered write budget exhausted | Write on leave / every few minutes |
| 20 | Using deprecated `ReserveServer`, `LoadCharacter`, `Humanoid:LoadAnimation`, `IsInGroup`, `GetProductInfo`, `PlayerOwnsAsset` | Deprecation warnings, future breakage | `TeleportOptions.ReservedServerId`, `LoadCharacterAsync`, `Animator:LoadAnimation`, `*Async` variants |
| 21 | Secrets/admin lists in ReplicatedStorage | Exploiters read them | ServerStorage/ServerScriptService + `HttpService:GetSecret` |
| 22 | `a and b or c` with falsy `b` | Wrong branch | `if a then b else c` |
| 23 | Module yields at require time | Whole boot stalls | Do yields in `Start` |
| 24 | Circular requires | `require` errors or nil module | Extract shared module, lazy require |
| 25 | `table.clone` assumed deep | Shared nested tables mutated (template corruption) | Deep clone; freeze templates |
| 26 | Unreliable remote payload > 1000 bytes | Messages silently vanish | Keep small; use buffers; RemoteEvent for large |
| 27 | Assuming handler ran synchronously after `:Fire()` / property set (Deferred signals) | Order bugs | Don't depend on immediate handler execution |
| 28 | Giving network ownership of important parts to clients | Teleported/flung objects | `SetNetworkOwner(nil)` for critical parts, validate |
| 29 | Using `tick()`/`os.time()` for durations | Drift, coarse resolution | `os.clock()` for durations, `GetServerTimeNow()` for shared timers |
| 30 | Changing DataStore name to "reset data" | All players lose progress | Migrations / explicit wipe flags |

---

## Sources

Local (verified):
- Engine API reference YAML (Studio 0.746): `reference/creator-docs/content/en-us/reference/engine/` — classes `RemoteEvent`, `UnreliableRemoteEvent`, `DataStoreService`, `GlobalDataStore`, `OrderedDataStore`, `MemoryStore*`, `MessagingService`, `MarketplaceService` (BindReceiptHandler), `TeleportService`, `TeleportOptions`, `TextService`, `TextChatService`, `HttpService`, `Players`, `Player`, `Workspace` (AuthorityMode, SignalBehavior, PlayerCharacterDestroyBehavior), `RunService`, `Actor`, `Model`; enums `RunContext`, `ModelStreamingMode`, `AuthorityMode`; libraries `task`, `buffer`, `table`.
- Creator docs: `cloud-services/data-stores/error-codes-and-limits.md`, `cloud-services/memory-stores/index.md`, `cloud-services/cross-server-messaging.md`, `cloud-services/http-service.md`, `scripting/events/remote.md`, `scripting/events/deferred.md`, `scripting/security/*`, `projects/server-authority/index.md`, `ui/text-filtering.md`, `chat/in-experience-text-chat.md`.
- Luau: `reference/luau/src/content/docs/` (syntax incl. `const`, type functions, OOP typing), `news/2025-12-19-luau-recap-runtime-2025.md`; RFCs `reference/luau/docs/`.
- Libraries: `MadStudioRoblox_ProfileStore` (ProfileStore.luau, docs/tutorial, docs/devproducts, docs/api), `Sleitnick_RbxUtil` (trove 1.8.0, signal 2.0.3), `Sleitnick_Knit/ARCHIVAL.md`, `evaera_roblox-lua-promise`, `1Axen_blink/docs`, `Ukendio_jecs/how_to`, `Kampfkarren_selene/docs`, `JohnnyMorganz_StyLua`, `JohnnyMorganz_luau-lsp`, `rojo-rbx_rojo`, `UpliftGames_wally`.

Web (2025–2026):
- [General Release: Luau's New Type Solver (DevForum)](https://devforum.roblox.com/t/general-release-luau%E2%80%99s-new-type-solver/4084991)
- [Studio Beta: Build Fair, Responsive Games with Server Authority](https://devforum.roblox.com/t/studio-beta-build-fair-responsive-games-with-server-authority/4139157)
- [Full Release: Ship Fair and Competitive Games with Server Authority](https://devforum.roblox.com/t/full-release-ship-fair-and-competitive-games-with-server-authority/4727993)
- [Roblox Newsroom: Creating responsive, cheat-resistant games with server authority (2026-07)](https://about.roblox.com/newsroom/2026/07/creating-responsive-cheat-resistant-games-roblox-server-authority)
- [Zap or ByteNet: Performance & Security (DevForum)](https://devforum.roblox.com/t/zap-or-bytenet-performance-security/2888968)
- [BlinkBlox benchmark thread (DevForum)](https://devforum.roblox.com/t/blinkblox-buffer-networking-that-checks-everything-a-client-sends/4898948)
- [Packet networking library thread (DevForum)](https://devforum.roblox.com/t/3573907)
