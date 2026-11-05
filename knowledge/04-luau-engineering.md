# 04 — Production-Quality Luau Engineering for Roblox

> Audience: a Claude Code bot that builds original Roblox games in Luau (Rojo/Wally toolchain or Studio).
> Accurate as of 2026-11-05. APIs were checked against the local engine reference mirror (Studio `0.746`, `/home/user/Roblox/.sources/Roblox_creator-docs/content/en-us/reference/engine`). Library versions checked locally: ProfileStore 1.0.3, sleitnick/trove 1.8.0, sleitnick/signal 2.0.3, evaera/promise 4.0.0, jecs 0.11.0, Blink 0.18.9, StyLua 0.32.0.

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

### 2.4 Script capabilities and security

`scripting/capabilities.md` describes sandboxing scripts with **capabilities** (for example, running untrusted or UGC code in a container with limited permissions). It's rarely needed in normal games. Note that the reference YAML lists `capabilities` on each API (e.g. `DataStore`, `Monetization`).

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

-- Array of `check`, at most maxCount items, no holes, no extra keys.
function Guard.array(check: Check, maxCount: number): Check
	return function(v)
		if typeof(v) ~= "table" or getmetatable(v :: any) ~= nil then return false end
		local n = #v
		if n > maxCount then return false end
		local count = 0
		for k, item in v do
			count += 1
			if typeof(k) ~= "number" or k < 1 or k > n or k % 1 ~= 0 or not check(item) then
				return false
			end
		end
		return count == n
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
