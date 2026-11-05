# 12 — Testing, QA, Performance and Analytics

> Scope: QA process, Studio test modes, automated tests and CI, performance profiling and budgets, analytics, experiments, KPIs, live ops, error and crash monitoring.
>
> Last verified: 2026-11-05 against the local creator-docs snapshot (`reference/creator-docs/content/en-us`), the Jest Roblox repo (`reference/libraries/Roblox_jest-roblox`) and the Lune repo (`reference/libraries/lune-org_lune`). Facts marked **[heuristic]** are community or studio rules of thumb, not Roblox-published limits. **[verify]** means it could not be confirmed against official docs here.

---

## TL;DR rules for the bot

1. **Test in the right mode.** Use **Test** (F5) for quick solo checks, **Server & Clients** with 2–3 clients (up to 8) for anything that replicates, and real devices for performance numbers. Studio runs server and client in one process, so its memory and FPS figures are *not* representative.
2. **Never point Studio at production DataStores.** Keep a separate **test universe** (a copy of the game) with "Enable Studio Access to API Services" on, and turn it off in the live game. In unit tests, inject a mock DataStore instead of calling `DataStoreService` directly.
3. **Write pure logic as ModuleScripts with dependency injection** so you can unit-test them with **Jest Roblox** (`roblox/jest` + `roblox/jest-globals`, v3.x via Wally). Run them in Studio, or headless in CI through the **Open Cloud Luau Execution API** against a *test place*.
4. **Every release goes through the same checklist:** smoke test, regression list, multi-client test, low-end phone test, DataStore save/load round-trip, purchase test, error-report check one hour after publish. (Checklist in §20.)
5. **Frame budget:** 16.67 ms per frame for 60 FPS, 33.3 ms for 30 FPS. The server heartbeat is capped at 60 Hz; sustained values below ~55 mean the server is overloaded.
6. **Server memory:** the server gets `6.25 GiB + 100 MiB × peak players`. Stay below 50% of that. On the client, design for **2–4 GB Android phones** (about 60% of Android players, and Android is about 65% of a typical game's players).
7. **The top performance killers** are per-frame loops that do real work, unthrottled `Touched` handlers, many server-side Humanoids, unanchored decorative parts, Precise collision fidelity on meshes, server-side tweens, large layered transparent effects, and remotes fired every frame. Fix those first.
8. **Turn on StreamingEnabled** for any map larger than a small arena. Set `StreamOutBehavior = Opportunistic` and `StreamingIntegrityMode = PauseOutsideLoadedArea`, leave `StreamingTargetRadius` at 1024 unless you have measured a reason to change it, and mark only essential models `Persistent`.
9. **Instrument from day one** with a single server-side analytics wrapper: an onboarding funnel (`LogOnboardingFunnelStepEvent`), economy sources and sinks (`LogEconomyEvent`), at most 10 funnels (`LogFunnelStepEvent`), and custom events (`LogCustomEvent`; at most 100 event names, so put variety into the three custom fields). The global rate limit is `120 + 20 × CCU` requests per minute.
10. **Watch D1 retention, D7 retention, session length, payer conversion and ARPDAU** against the dashboard's *similar-games benchmark* (50th–90th percentile), not against absolute numbers from the internet.
11. **Change one thing at a time** and A/B test it with **Experiments** (driven by Configs; 14–60 days; one control and up to 2 variants) or **thumbnail personalization** (needs 2 or more active thumbnails).
12. **Monitor errors.** Read the Creator Hub **Error Report** after every publish. Add a `ScriptContext.Error` and `LogService.MessageOut` reporter that dedupes and rate-limits. Check **Crashes** (server out-of-memory snapshots) and the **Performance** dashboard every week.

---

## 1. The QA process for a Roblox game

Small teams don't need heavyweight QA, but they do need *repeatable* QA. Most bad launches come from regressions, or from features that work solo in Studio and fail with 10 players on phones over cellular data.

### 1.1 Test plan (one per feature)

Write a short test plan in the repo next to the feature (or in the design doc) **before** the feature is built. Template:

```
Feature: Pet hatching v2
Owner: <bot/session id>
Risk: HIGH (touches DataStore + Robux purchase)
Preconditions: test universe, player with 500 coins, empty pet inventory
Cases:
  H1  Hatch with enough coins -> coins -500, 1 pet added, egg anim plays     [server+client]
  H2  Hatch with 499 coins    -> rejected, UI shows "Not enough coins"        [server]
  H3  Spam hatch button 20x in 1s -> at most 1 hatch per cooldown            [exploit]
  H4  Hatch, leave immediately -> pet persists after rejoin                  [DataStore]
  H5  Inventory full (cap 100) -> hatch blocked with message                 [edge]
  H6  Hatch on phone emulator portrait/landscape -> buttons reachable        [UI]
  H7  2 clients: client B sees client A's equipped pet                       [replication]
  H8  300 ms latency -> button gives instant feedback, no double-charge      [network]
Analytics: LogEconomyEvent(Sink, "Coins", 500, ..., "Gameplay", "Egg_Basic")
Exit criteria: all cases pass, no new errors in Output, no frame-time spike > 5 ms
```

Label each case by realm and add exploit, DataStore, edge, UI and network cases. High-risk areas are always DataStores, `ProcessReceipt`, teleports, trading, client-callable remotes and the FTUE.

### 1.2 Smoke test (every build, about 5 minutes)

Is the build playable at all? Run after every meaningful change and before every publish.

1. Start **Test** (F5). The Output window shows **no red errors** during load.
2. The player spawns, moves, jumps and the camera behaves.
3. The core loop completes once (for example: collect, sell, upgrade).
4. The main UI opens and closes, and the shop opens (no purchase).
5. Data loads, a change happens, stop and restart, and the change persisted (in the **test universe** only).
6. Start **Server & Clients** with 2 clients. Each client sees the other, and shared state (leaderboards, doors, NPCs) matches on both.
7. Open the Developer Console (F9) on a client. The Log tab has no new errors or warnings flood.

Any failure means the build doesn't ship.

### 1.3 Regression checklist (per release)

Keep `qa/regression.md` in the repo. Each fixed bug adds one line that would have caught it:

```
[Core]       spawn, respawn after death, reset character, team assignment
[Data]       new player defaults; returning player loads; rejoin within 10 s keeps data;
             server shutdown (BindToClose) saves all; corrupted/legacy schema migrates
[Economy]    every source grants correct amount; every sink deducts; no negative balance;
             cap enforced; offline earnings formula
[Monetize]   each dev product grants exactly once (test receipt replay); each game pass
             perk applies on join AND on in-game purchase; premium payouts unaffected
[Social]     party join, friend follow, private server owner commands
[UI]         every screen on phone (small), tablet, 1080p PC, console 10-ft; safe areas;
             gamepad navigation (selection) on every menu
[Network]    300 ms + 2% loss: no stuck UI, no double actions
[Teleport]   cross-place teleport carries data; failure handling (retry) works
[Perf]       low-end phone 10-minute session: no FPS decay, memory flat
[Analytics]  onboarding funnel steps fire in order once; economy events fire
```

Run the **full** regression list before major updates and the **[Core]+[Data]+[Monetize]** subset before every publish.

### 1.4 Severity

**S0** (data loss, Robux taken without the item, crash on join, game-breaking exploit): hotfix now and restart servers. **S1** (core loop broken for a segment such as all phones): fix within 24 h. **S2** (broken but with a workaround, or error spam): next update. **S3** (cosmetic): backlog.

---

## 2. Studio testing modes

Studio's current toolbar (the "mezzanine") offers these playtest options. Older docs and tutorials call them **Play / Play Here / Run**. Current docs say **Test / Test Here / Run**. They are the same features under new names.

| Mode | Shortcut | What happens | Use for |
|---|---|---|---|
| **Test** (formerly Play) | F5 | Starts a server and a client simulation in one Studio window and spawns your avatar at a `SpawnLocation` (or near `(0,100,0)`) | Most everyday testing |
| **Test Here** (formerly Play Here) | – | Same, but spawns you in front of the camera | Testing a specific area quickly |
| **Run** | F8 | Simulates the server without a player avatar; the camera moves freely | NPC AI, physics, server systems, ambient simulation |
| **Server & Clients** | F7 (Play in this mode) | Launches separate Studio windows: one server plus N clients (choose 1–8; 1–2 is usually enough) | Replication, remotes, leaderboards, multiplayer logic, ownership bugs |
| **Team Test** | – | A cloud-hosted session that collaborators join from their own Studio | Real network latency, playtests with collaborators |
| **Party Simulator** | – | Emulates party assignments for test players (`Player.PartyId`, `SocialService:GetPartyAsync()`) | Games using party APIs |

In solo modes, the **Client/Server toggle** switches between client view (blue border) and server view (green border, free camera) so you can inspect server state. **Pause** freezes physics and animations (not scripts), and **Step Forward** advances 1/60 s.

### 2.1 Device Simulator (phones, tablets, console, VR)

The **Device Simulator** toolbar (beta at the time of writing; enable it under *File → Beta Features*) sits above the viewport and has categories for **Phone** (phones and tablets, with touch and on-screen keyboard), **Desktop**, **Console** (output resolutions, gamepad-first input) and **Headset**. You can switch device mid-playtest.

Use it for aspect ratios, safe areas, touch-button reachability, text readability (below about 14 px is unreadable on phones **[heuristic]**) and gamepad navigation. Do **not** use it for performance or memory, because Studio runs server and client together and the docs call its memory readings inaccurate.

### 2.2 Network simulation (latency, jitter, packet loss)

The newer **Network Simulator** (beta, opened from the Device Simulator toolbar's **Network** pill) adds **inbound** (server→client) and **outbound** (client→server) **latency**, **jitter** and **packet loss** separately, with presets for wired, Wi-Fi and mobile. Added latency is one-way: 10 ms in and 10 ms out adds about 20 ms to ping. The values are added on top of real conditions, so they stack with Team Test's real internet latency. It affects Studio playtests only.

Standard test profiles **[heuristic]**:

| Profile | One-way latency each direction | Jitter | Loss |
|---|---|---|---|
| Good Wi-Fi | 20 ms | 5 ms | 0% |
| Typical mobile | 75 ms | 25 ms | 1% |
| Bad mobile | 150 ms | 50 ms | 3% |

Watch for: no feedback until the server replies, double purchases from repeated taps, rubber-banding, and UI that assumes remote events arrive in order.

### 2.3 Other Studio tools

The **Output** window (filter by client or server), the **script debugger** (breakpoints, watches), the **Command Bar** (grant test currency in the test universe), **Scene Analysis** (script memory, unparented instances, instance, audio, animation and triangle composition), and *Studio Settings → Network → Print Join Size Breakdown* (top 20 instances by join size).

---

## 3. Automated testing

### 3.1 What to automate

Automate deterministic logic where bugs are expensive: economy math (prices, cost curves, rebirth, offline earnings), data schema (defaults, migrations, sanitization), inventory and trade rules, remote-argument validators and rate limiters, pure utilities (number formatting, seeded weighted random), and state machines (rounds, quests).

Architecture rule: **keep Roblox services out of the logic.** Pass them in (dependency injection), so tests can supply fakes:

```lua
-- src/shared/Economy/Wallet.luau  (pure, testable)
local Wallet = {}
Wallet.__index = Wallet

export type Wallet = typeof(setmetatable({} :: { balance: number, cap: number, onChange: ((number, number) -> ())? }, Wallet))

function Wallet.new(balance: number, cap: number, onChange: ((number, number) -> ())?): Wallet
	assert(balance >= 0, "negative starting balance")
	return setmetatable({ balance = balance, cap = cap, onChange = onChange }, Wallet)
end

function Wallet.add(self: Wallet, amount: number): number
	assert(amount > 0 and amount == amount, "amount must be positive and not NaN")
	local before = self.balance
	self.balance = math.min(self.cap, self.balance + amount)
	local granted = self.balance - before
	if self.onChange and granted > 0 then self.onChange(granted, self.balance) end
	return granted
end

function Wallet.trySpend(self: Wallet, amount: number): boolean
	assert(amount > 0 and amount == amount, "amount must be positive and not NaN")
	if self.balance < amount then return false end
	self.balance -= amount
	if self.onChange then self.onChange(-amount, self.balance) end
	return true
end

return Wallet
```

### 3.2 Jest Roblox (Jest-Lua)

**Jest Roblox** (repo `Roblox/jest-roblox`, formerly "jest-lua") is Roblox's official port of JavaScript Jest 27-era APIs: `describe`, `it`/`test`, `expect` matchers, `beforeEach`/`afterEach`, `jest.fn()` mocks, timer mocks, snapshots. It **replaced TestEZ** as the recommended framework. TestEZ (`describe`/`it`/`expect().to.equal()`) still works in older codebases but is unmaintained. New projects should use Jest.

Install with Wally (dev dependencies):

```toml
# wally.toml
[package]
name = "yourname/yourgame"
version = "0.1.0"
realm = "shared"
registry = "https://github.com/UpliftGames/wally-index"

[dev-dependencies]
Jest = "roblox/jest@^3.20.0"
JestGlobals = "roblox/jest-globals@^3.20.0"
```

Key rules from the Jest Roblox docs:
- Tests run **inside a Roblox environment**, either Studio or Open Cloud Luau Execution (the docs call this "OCALE"). They do not run in plain Lune, because the framework relies on the Roblox runtime.
- Every global (`describe`, `it`, `expect`, `jest`, `beforeEach`, and so on) must be **explicitly required** from `JestGlobals`.
- A `jest.config` ModuleScript in the test root sets `testMatch` (for example `{ "**/*.spec" }`). With Rojo, `Wallet.spec.luau` becomes a ModuleScript named `Wallet.spec`.
- The entry point calls `Jest.runCLI(rootInstance, options, { projects })` and `:awaitStatus()`.
- Useful `runCLI` options: `ci`, `verbose`, `testNamePattern`, `testPathPattern`, `testTimeout`, `clearMocks`, `resetMocks`, `passWithNoTests`, `json`.

**Example test file** (`src/shared/Economy/__tests__/Wallet.spec.luau`):

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages -- or ReplicatedStorage.DevPackages with Wally dev realm

local JestGlobals = require(Packages.JestGlobals)
local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect
local beforeEach = JestGlobals.beforeEach
local jest = JestGlobals.jest

local Wallet = require(script.Parent.Parent.Wallet)

describe("Wallet", function()
	local onChange
	local wallet

	beforeEach(function()
		onChange = jest.fn()
		wallet = Wallet.new(100, 1000, onChange)
	end)

	it("adds currency and reports the change", function()
		local granted = wallet:add(50)
		expect(granted).toBe(50)
		expect(wallet.balance).toBe(150)
		expect(onChange).toHaveBeenCalledTimes(1)
		expect(onChange).toHaveBeenCalledWith(50, 150)
	end)

	it("clamps at the cap and only reports what was granted", function()
		local granted = wallet:add(5000)
		expect(granted).toBe(900)
		expect(wallet.balance).toBe(1000)
	end)

	it("refuses to overspend and does not fire onChange", function()
		expect(wallet:trySpend(101)).toBe(false)
		expect(wallet.balance).toBe(100)
		expect(onChange).never.toHaveBeenCalled()
	end)

	it("rejects NaN and negative amounts", function()
		expect(function() wallet:add(0 / 0) end).toThrow()
		expect(function() wallet:trySpend(-5) end).toThrow("positive")
	end)
end)
end)
```

Note the dot-call syntax (`expect(x).toBe(y)`). `.never` replaces JavaScript's `.not`, because `not` is a reserved word in Luau.

**Testing DataStore-dependent code with a mock store.** Write the data layer against a tiny interface, then test with an in-memory fake:

```lua
-- src/server/Data/MockDataStore.luau  (test helper; never shipped to clients)
local MockDataStore = {}
MockDataStore.__index = MockDataStore

function MockDataStore.new(opts: { failRate: number?, seed: number? }?)
	local o = opts or {}
	return setmetatable({
		data = {},
		calls = 0,
		failRate = o.failRate or 0,
		rng = Random.new(o.seed or 1),
	}, MockDataStore)
end

local function maybeFail(self)
	self.calls += 1
	if self.rng:NextNumber() < self.failRate then
		error("502: API Services rejected request (mock)")
	end
end

function MockDataStore:GetAsync(key: string)
	maybeFail(self)
	local v = self.data[key]
	return v and table.clone(v) or nil
end

function MockDataStore:UpdateAsync(key: string, transform: (any) -> any?)
	maybeFail(self)
	local current = self.data[key]
	local nextValue = transform(current and table.clone(current) or nil)
	if nextValue ~= nil then self.data[key] = nextValue end
	return nextValue
end

return MockDataStore
```

Pass `MockDataStore.new({ failRate = 0.3, seed = 42 })` to your `PlayerData` module to test retry, migration and session-lock logic. The seeded RNG keeps the flaky store deterministic.

Jest Roblox also has a benchmark API (`docs/JestBenchmarkAPI.md`). Treat its numbers as relative.

### 3.3 Running tests: Studio, Lune, and Open Cloud Luau Execution

| Runner | What it can run | Use |
|---|---|---|
| **Studio** | Everything, with real engine APIs | Local development |
| **Lune** | Pure Luau plus `@lune/fs`, `net`, `process`, `serde`, `task`, `roblox` (read and write `.rbxl` files offline). **No engine runtime**, so Jest Roblox can't run in it | CI glue, static checks of built places, calling Open Cloud |
| **Open Cloud Luau Execution** | A Luau script on a real headless server loaded with a given place version | Headless Jest in CI |
| `roblox-cli` | Roblox-internal only | Ignore |

**Open Cloud Luau Execution API.** This is the official way to run engine-backed tests in CI. Facts I verified: the operations are `CreateLuauExecutionSessionTask` (with or without a place version), `GetLuauExecutionSessionTask`, `ListLuauExecutionSessionTaskLogs` and `CreateLuauExecutionSessionTaskBinaryInput`, and the API-key scope family is `universe.place.luau-execution-session:*`. Shape from DevForum and SDK sources **[verify against the official reference before relying on exact field names]**:

- `POST https://apis.roblox.com/cloud/v2/universes/{universeId}/places/{placeId}/versions/{versionId}/luau-execution-session-tasks` (or without `/versions/{versionId}` for the latest published version), with header `x-api-key` and JSON body `{ "script": "<luau source>", "timeout": "300s" }`. The timeout accepts 1–300 s.
- The response includes a `path` (`universes/…/places/…/versions/…/luau-execution-sessions/…/tasks/…`) and a `state` (`QUEUED`, `PROCESSING`, `COMPLETE`, `FAILED`, `CANCELLED`).
- Poll with `GET https://apis.roblox.com/cloud/v2/{path}`. When the state is `COMPLETE`, `output.results` holds the script's return values. When it is `FAILED`, `error.message` holds the error.
- Logs: `GET https://apis.roblox.com/cloud/v2/{path}/logs`.
- Each task starts a **fresh server**, so do all your setup inside one script.

The CI pattern (Roblox's own `place-ci-cd-demo` uses it):
1. `rojo build test.project.json -o test.rbxl` (game code plus dev packages plus specs).
2. Upload it to a **dedicated test place** as a *saved*, not published, version: `POST https://apis.roblox.com/universes/v1/{universeId}/places/{placeId}/versions?versionType=Saved` with `Content-Type: application/octet-stream`. The response contains `versionNumber`. Use an API key with **universe-places** write permission, scoped to the test universe only.
3. Create a Luau execution task against that version, running the Jest entry script.
4. Poll, print the logs, and fail the CI job if the task failed or returned `success = false`.

**Jest entry script executed in the cloud** (`scripts/cloud-test-runner.luau`):

```lua
-- Runs inside a headless Roblox server via Open Cloud Luau Execution.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Packages = ReplicatedStorage:WaitForChild("DevPackages")
local Jest = require(Packages.Jest)

local roots = {
	ReplicatedStorage:WaitForChild("Shared"),
	ServerScriptService:WaitForChild("Server"),
}

local status, result = Jest.runCLI(ReplicatedStorage, {
	ci = true,
	verbose = true,
}, roots):awaitStatus()

if status == "Rejected" then
	error("Jest crashed: " .. tostring(result))
end

local r = result.results
local summary = {
	success = r.success,
	numTotalTests = r.numTotalTests,
	numFailedTests = r.numFailedTests,
	numPassedTests = r.numPassedTests,
}
if not r.success then
	-- error() makes the task FAILED so CI goes red even if results are ignored
	error(("Tests failed: %d of %d"):format(r.numFailedTests, r.numTotalTests))
end
return summary
```

**Lune driver that calls Open Cloud** (`scripts/run-cloud-tests.luau`):

```lua
-- lune run scripts/run-cloud-tests.luau <placeVersion>
local fs = require("@lune/fs")
local net = require("@lune/net")
local process = require("@lune/process")
local serde = require("@lune/serde")
local task = require("@lune/task")

local API_KEY = assert(process.env.ROBLOX_API_KEY, "ROBLOX_API_KEY missing")
local UNIVERSE = assert(process.env.TEST_UNIVERSE_ID, "TEST_UNIVERSE_ID missing")
local PLACE = assert(process.env.TEST_PLACE_ID, "TEST_PLACE_ID missing")
local version = assert(process.args[1], "usage: run-cloud-tests <placeVersion>")

local BASE = "https://apis.roblox.com/cloud/v2/"

local function call(method: string, url: string, body: any?)
	local res = net.request({
		url = url,
		method = method,
		headers = { ["x-api-key"] = API_KEY, ["Content-Type"] = "application/json" },
		body = if body then serde.encode("json", body) else nil,
	})
	if not res.ok then
		error(("%s %s -> %d %s"):format(method, url, res.statusCode, res.body))
	end
	return serde.decode("json", res.body)
end

local script = fs.readFile("scripts/cloud-test-runner.luau")
local created = call("POST", ("%suniverses/%s/places/%s/versions/%s/luau-execution-session-tasks")
	:format(BASE, UNIVERSE, PLACE, version), { script = script, timeout = "300s" })

local path = created.path
print("Task:", path)

local taskInfo
local deadline = os.clock() + 360
repeat
	task.wait(3)
	taskInfo = call("GET", BASE .. path)
	print("state:", taskInfo.state)
until taskInfo.state == "COMPLETE" or taskInfo.state == "FAILED"
	or taskInfo.state == "CANCELLED" or os.clock() > deadline

-- Print logs (Jest output) regardless of outcome
local ok, logs = pcall(call, "GET", BASE .. path .. "/logs")
if ok and logs.luauExecutionSessionTaskLogs then
	for _, page in logs.luauExecutionSessionTaskLogs do
		for _, line in page.messages or {} do print(line) end
	end
end

if taskInfo.state ~= "COMPLETE" then
	print("FAILED:", taskInfo.error and taskInfo.error.message or taskInfo.state)
	process.exit(1)
end
print("Results:", serde.encode("json", taskInfo.output and taskInfo.output.results or {}))
process.exit(0)
```

### 3.4 CI with GitHub Actions

Toolchain pinning: put Rojo, Wally, Lune, StyLua and Selene in `rokit.toml` (Rokit is the successor to Aftman and Foreman), so CI and local development use identical versions.

```toml
# rokit.toml
[tools]
rojo = "rojo-rbx/rojo@7.4.4"
wally = "UpliftGames/wally@0.3.2"
lune = "lune-org/lune@0.8.9"
stylua = "JohnnyMorganz/StyLua@2.0.2"
selene = "Kampfkarren/selene@0.28.0"
```

(Pin versions you have checked exist. These are examples.)

```yaml
# .github/workflows/ci.yml
name: CI

on:
  pull_request:
  push:
    branches: [main]

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

jobs:
  test:
    name: Lint, build, Jest via Open Cloud
    runs-on: ubuntu-latest
    environment: test-universe
    steps:
      - uses: actions/checkout@v4

      - name: Install Rokit
        run: |
          curl -sSf https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.sh | bash
          echo "$HOME/.rokit/bin" >> "$GITHUB_PATH"

      - name: Install tools
        run: rokit install --no-trust-check
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Install packages
        run: wally install

      - name: Format check
        run: stylua --check src scripts

      - name: Lint
        run: selene src

      - name: Build game place
        run: rojo build default.project.json -o game.rbxl

      - name: Static place checks (Lune)
        run: lune run scripts/check-place.luau game.rbxl

      # Cloud tests need secrets, which PRs from forks don't get; skip there.
      - name: Build test place (code + specs + dev packages)
        if: github.event_name == 'push' || github.event.pull_request.head.repo.full_name == github.repository
        run: rojo build test.project.json -o test.rbxl

      - name: Upload as saved version of TEST place
        if: github.event_name == 'push' || github.event.pull_request.head.repo.full_name == github.repository
        id: upload
        env:
          ROBLOX_API_KEY: ${{ secrets.ROBLOX_TEST_API_KEY }}
          TEST_UNIVERSE_ID: ${{ vars.TEST_UNIVERSE_ID }}
          TEST_PLACE_ID: ${{ vars.TEST_PLACE_ID }}
        run: |
          resp=$(curl -sS --fail-with-body -X POST \
            "https://apis.roblox.com/universes/v1/${TEST_UNIVERSE_ID}/places/${TEST_PLACE_ID}/versions?versionType=Saved" \
            -H "x-api-key: ${ROBLOX_API_KEY}" \
            -H "Content-Type: application/octet-stream" \
            --data-binary @test.rbxl)
          echo "$resp"
          echo "version=$(echo "$resp" | jq -r .versionNumber)" >> "$GITHUB_OUTPUT"

      - name: Run Jest in Roblox cloud
        if: github.event_name == 'push' || github.event.pull_request.head.repo.full_name == github.repository
        env:
          ROBLOX_API_KEY: ${{ secrets.ROBLOX_TEST_API_KEY }}
          TEST_UNIVERSE_ID: ${{ vars.TEST_UNIVERSE_ID }}
          TEST_PLACE_ID: ${{ vars.TEST_PLACE_ID }}
        run: lune run scripts/run-cloud-tests.luau ${{ steps.upload.outputs.version }}
```

CI rules:
- The API key is scoped to the **test universe only**, with only `universe-places` write and Luau execution permissions. Never use the production universe for CI test runs.
- **Publishing to production is a separate, manual workflow** (`workflow_dispatch` with a required reviewer), never automatic on merge, unless the team explicitly chooses continuous deployment.
- Example `check-place.luau` static checks: fail on any `Script` whose source contains `require(` with a numeric asset ID (a free-model backdoor pattern), on `RemoteEvent`s outside an allowlist, on parts with `CollisionFidelity = PreciseConvexDecomposition` beyond a count, or on unanchored parts in `Workspace.Map`.

---

## 4. Testing DataStores safely

DataStores accessed from Studio are **the same DataStores as the live game**. The docs warn: "do not enable [Studio access] for live games. Instead, enable it for a separate test version of the game."

The recommended setup:

| Environment | Universe | Studio API access | Who plays |
|---|---|---|---|
| **Dev/Test** | Separate universe ("MyGame [TEST]"), private | **ON** | Developer, CI |
| **Staging** (optional) | Separate universe, friends-only or private servers | ON | Internal playtesters |
| **Production** | Main universe | **OFF** | Public |

Practices:
1. **Second safety net:** pick the store name by universe, e.g. `(game.GameId == PROD_UNIVERSE_ID) and "PlayerData_v3" or "PlayerData_v3_TEST"`.
2. **Abstract DataStore access** behind a module, so tests inject `MockDataStore` and Studio sessions without API access fall back to memory (detect this by probing `GetAsync` inside `pcall`).
3. **Test failure paths:** throttling (mock `failRate`), leaving mid-save, `BindToClose` on shutdown (about 30 s), and two servers holding the same player (session lock via `UpdateAsync`).
4. **Migration tests:** keep JSON fixtures of every past schema and assert that `migrate(fixture)` produces valid current data.
5. Seed and inspect test data with **Open Cloud DataStore APIs** using a key scoped to the test universe.
6. Before launch, run a **data soak**: 4–8 testers play for 30 minutes with repeated rejoins, then compare snapshots.

---

## 5. Playtesting with real players

Automated tests prove the game *works*. Playtests show whether it is *understandable and fun*.

### 5.1 Ways to get real players

| Method | Notes |
|---|---|
| **Team Test / collaborators** | Fast, good for multiplayer bugs. Testers need edit access |
| **Invite early testers** (*File → Invite early testers*) | Up to **10** similar-age friends or trusted friends can preview an unreleased game before it has a maturity label. They see a preview watermark and safety tools stay active. Age rules apply |
| **Private servers / friends-only** | Controlled sessions after release |
| **Beta universe** | Gets updates first. Reward participants with a "Beta Tester" badge. Recruit from your group or Discord |
| **Paid access** | Possible, but it shrinks the sample and hurts discovery. Only for an established community |
| **Focus group** | 5–8 target-age players observed live by a facilitator. The best source of FTUE insight |
| **Soft launch** | Public release with no promotion. Watch analytics for 1–2 weeks, iterate, then promote |

### 5.2 Running a moderated playtest

1. Don't explain the game. Say only "play as you normally would and think out loud."
2. Note timestamps for: **time to first fun** (target under 60 s **[heuristic]**); **confusion points** (hesitating more than 5 s, wandering, opening and closing menus, asking "what do I do?"); **missed affordances**; **rage or quit moments**.
3. Afterwards, ask what the game was about, what the best moment was, when they felt lost, and whether they would play again tomorrow. Trust behavior over answers, especially with kids.
4. Count, don't anecdote: "5 of 8 never found Rebirth" is actionable.

### 5.3 In-game feedback form

Add a small, rate-limited feedback UI (for example after 10 minutes of play, or from the settings menu): a 1–5 rating plus an optional category (Bug / Confusing / Suggestion) plus short text. On the server, **filter text** with `TextService:FilterStringAsync` before storing or displaying it, store it in a DataStore or MemoryStore queue in a separate "Feedback" store, and log `LogCustomEvent(player, "FeedbackRating", rating)` for aggregation. Never ask for personal information.

Also check the Creator Hub **Feedback** page after each update.

### 5.4 What to observe in data (FTUE)

The **onboarding funnel** (§14) is the quantitative version of a playtest. Find the **single largest drop** between consecutive steps and fix that first.

---

## 6. Bug reporting

### 6.1 Bug report template

```
Title:  [S1][Shop] Buying Speed Coil twice charges coins twice, grants one
Build:  place version 412 (Studio) / live v412 since 2026-11-04 18:00 UTC
Env:    Test universe | Server & Clients (2) | Network: 150 ms, 3% loss
Device: Device Simulator iPhone SE (also seen on real Android, 3 GB)
Steps:  1. Join with 1000 coins  2. Open Shop  3. Double-tap Buy on Speed Coil quickly
Expect: one purchase, -250 coins, coil in backpack; second tap ignored
Actual: -500 coins, one coil
Freq:   4/5 attempts at 150 ms; 0/5 at 0 ms
Logs:   (Output / F9 excerpts, stack trace)
Data:   UserId 12345 (test account) before/after snapshot
Notes:  Server handler lacks per-player purchase lock; client does not disable button
```

Rules: one bug per report, include the **place version** (shown in the F9 console header and in the Error Report "First seen version" column), reproduction frequency, and network conditions. Every fixed bug gets a regression line (§1.3) and, ideally, a unit test.

### 6.2 Engine bugs

If Roblox itself is at fault (an engine crash, or a spike in **platform crashes**), file a DevForum bug report with a minimal reproduction place.

---

## 7. Performance fundamentals

### 7.1 The budgets

| Quantity | Target |
|---|---|
| Client frame time at 60 FPS | ≤ **16.67 ms** (the default cap is 60 FPS; Windows users can raise it to 240) |
| Client frame time at 30 FPS (minimum acceptable on low-end phones) | ≤ **33.3 ms** |
| Server heartbeat | **60 Hz** cap. Investigate if sustained below ~55; below 40 players feel lag **[heuristic]** |
| Server memory | < **50%** of `6.25 GiB + 100 MiB × peak connected players` (30 players ≈ 9.18 GiB total). Memory does not shrink when players leave |
| Client crash rate | Investigate above **2–3%**, especially a jump right after an update |
| Load (join) time | Under ~10 s on mid-range phones over Wi-Fi; under 20 s on low-end **[heuristic]** |

Why low-end matters: **Android is about 65% of a typical game's players, and about 60% of those have 2–4 GB of RAM.** More than half of players use devices scoring 10k–20k on Passmark. Test throughout development on a **baseline low-end device** (the docs suggest e.g. Infinix Smart 9, Moto G05, Oppo A18, Fire HD 10 2023).

### 7.2 Performance budget per device tier

Values are **[heuristic]** studio targets derived from the docs' baseline-device method (the docs' example baseline: stay below 1,000 draw calls and 1,000,000 triangles) plus common practice. Measure your own baseline device and adjust.

| Budget | Low-end phone (2–3 GB, e.g. Moto G05) | Mid phone / tablet (4–6 GB) | PC (integrated GPU) | Console (Xbox / PS) | Server |
|---|---|---|---|---|---|
| Target FPS | 30 stable (33 ms) | 60 (16.7 ms) | 60+ | 60 | 60 Hz heartbeat |
| Script time per frame (client) | ≤ 4 ms | ≤ 3 ms | ≤ 3 ms | ≤ 3 ms | ≤ 8 ms of the 16.7 ms frame |
| Draw calls (scene) | ≤ 400–600 | ≤ 1,000 | ≤ 1,500 | ≤ 1,500 | n/a |
| Visible triangles | ≤ 300k–500k | ≤ 1M | ≤ 2M | ≤ 2M | n/a |
| Client total memory | ≤ 1.0–1.3 GB | ≤ 1.8 GB | ≤ 2.5 GB | ≤ 2.5 GB | < 50% of allocation |
| Texture memory (GraphicsTexture) | ≤ 200 MB | ≤ 400 MB | ≤ 700 MB | ≤ 700 MB | n/a |
| Streamed-in BaseParts near player | ≤ 10–15k | ≤ 25k | ≤ 50k | ≤ 40k | whole map ≤ 100–200k |
| Animated Humanoids visible | ≤ 15–20 | ≤ 30 | ≤ 50 | ≤ 40 | server Humanoid NPCs ≤ 30–50 |
| Active particle emitters on screen | ≤ 10, low Rate | ≤ 25 | ≤ 50 | ≤ 40 | n/a (keep on client) |
| Network receive (server→client) | ≤ 30 KB/s sustained | ≤ 50 KB/s | ≤ 50 KB/s | ≤ 50 KB/s | sum across players |
| Join time | ≤ 20 s | ≤ 12 s | ≤ 10 s | ≤ 12 s | n/a |

Rule: **If the game meets the low-end column, the others take care of themselves.** Make graphics-heavy extras (dense foliage, many lights, post effects) optional or scale them with the client's quality level (read `UserSettings().GameSettings.SavedQualityLevel` on the client).

---

## 8. Profiling tools

### 8.1 Developer Console (F9)

Available in Studio **and in live games** (on phones from the in-game menu). The **Client** and **Server** dropdown switches perspective. The server view needs edit permission, and it includes a server command bar that runs with normal Script security.

| Tab | What it shows | What to look for |
|---|---|---|
| **Log** | Client or server output with errors, warnings and info (including structured `LogService` context) | Error floods, warnings from your systems |
| **Memory** | Real-time memory by category: **CoreMemory** (engine) and **PlaceMemory** (your content: `GraphicsMeshParts`, `GraphicsTexture`, `Sounds`, `PhysicsParts`, `Instances`, `Script`, `Signals`, …) | Steady growth = leak; large textures and meshes; PhysicsParts from Precise collision |
| **Luau Heap** | Heap snapshots of script memory, viewable by object type, engine class, and so on, with snapshot comparison | Tables or closures growing between snapshots (leaked connections, caches without limits) |
| **Network** | Web calls (HttpService, DataStore, and other services' web requests): counts, failures, time | DataStore request spam, failing HTTP |
| **Script Profiler** | Records CPU time per script and function over a session | The functions that dominate CPU |
| **Server Jobs** (server view) | Task scheduler jobs. **Heartbeat → Steps Per Sec** is server FPS | Heartbeat < 60 |
| **Server Stats** (server view) | Average **data ping** for all players, plus other server health stats | Rising ping = server overloaded or saturating replication |

Other overlays: **Performance Stats** (Ctrl+Alt+F7 or the settings menu) shows memory, CPU, GPU, network and ping. **Debug Stats** (Shift+F1–F5 in the client, Ctrl+Shift+F1–F5 in Studio) include Summary, Render (**Draw (scene)** calls and triangles), Physics and Network. Studio skews FPS, so read it on a client.

### 8.2 MicroProfiler

Open with **Ctrl+Alt+F6** (⌘⌥F6) on the client, or start a **server** capture from the Developer Console. It works on devices, so you can capture a dump on a phone and open it on your PC.

How to read it:
1. **Frame time bar graph** (top): bar height is the frame's milliseconds. A single tall bar is a hitch. Consistently tall bars mean something runs every frame. **Orange** means a worker thread was the bottleneck (scripts, physics, animation). **Blue** means rendering was. **Red** usually comes from object complexity, textures or effects, so optimize it like blue. Focus on frame *time*, not color.
2. **Timeline** (below): tasks per thread, where wider means longer. Hover to see names and durations. Click a bar to jump to that frame.
3. **Label your own code** so it shows up by name:

```lua
RunService.Heartbeat:Connect(function(dt)
	debug.profilebegin("EnemyAI.Update")
	EnemyAI.update(dt)
	debug.profileend()
end)
```

Common scopes to know (from the docs' tag reference):

| Scope | Meaning | Usual fix |
|---|---|---|
| `RunService.Heartbeat` / `Stepped` / `RenderStepped` scripts | Your per-frame code | Do less per frame; spread work over frames; event-driven instead of polling |
| `worldStep` / `Simulation` / physics scopes | Physics simulation | Anchor static parts; reduce assemblies and constraints; Box or Hull collision fidelity |
| `updateInvalidatedFastClusters` (over 4 ms) | Avatar or Humanoid instantiation and modification | Fewer respawns and rescales; pool NPCs; fewer layered clothing changes |
| `ProcessPackets` | Handling incoming network packets (remote calls, property changes) | Fewer and smaller remotes; throttle |
| `Allocate Bandwidth and Run Senders` (server) | Outgoing replication | Replicate less; client-side VFX |
| Render scopes (`Prepare`, `Perform`, shadows, `UI`) | GPU and CPU rendering | Fewer draw calls, transparency, lights and shadows; simpler UI |

4. **Save and compare dumps.** "Dump" saves frames to an HTML file. The web viewer has an **X-Ray** memory-allocation mode and a **diff flame graph** to compare two dumps (before and after a fix).

### 8.3 Live dashboards

- **Performance dashboard** (Creator Hub → Monitoring → Performance): client memory, client frame rate, server heartbeat, server memory, crash rate, **client API calls after join**. Filter by device and OS, and overlay place-version annotations.
- **Crashes** (Monitoring → Crashes): server crashes split into **out-of-memory** (yours to fix) and **platform** (Roblox's). Out-of-memory crashes include an automatic **data-model snapshot** (treemap by service, folder and asset), filterable by place version and uptime. Rising crashes with uptime suggest a **leak**. A spike after one version means that version regressed.

---

## 9. Common performance killers and fixes

### 9.1 Scripts

| Killer | Why | Fix |
|---|---|---|
| `while true do ... wait() end` loops polling state | Runs constantly, and scales badly with copies (one loop per coin) | Event-driven (`.Changed`, `GetPropertyChangedSignal`, attributes, signals); one central loop over a list instead of N loops; `task.wait(interval)` with a real interval |
| Heavy work in `RenderStepped`/`PreRender` | Blocks rendering every frame | Only camera and visual work there; move logic to `Heartbeat` or events |
| `Touched` spam | Fires many times per contact, per part, per frame of contact | Debounce per player (`lastTouch[player] + cooldown`), set `CanTouch = false` on parts that don't need it, use `Workspace:GetPartBoundsInBox`/`GetPartsInPart` with `OverlapParams` on a timer, or ProximityPrompts |
| Creating instances every frame (bullets, VFX) | Allocation plus replication | Pool and reuse; spawn VFX on clients only |
| Connections never disconnected | Memory leak (Signals and Luau Heap grow) | Store connections and disconnect them on cleanup (Trove/Maid pattern); `Destroy()` instances instead of only reparenting them to nil |
| Unbounded caches and tables keyed by Player | Leak after players leave | Clear on `Players.PlayerRemoving` |
| `FindFirstChild` or `GetDescendants` chains every frame | O(n) scans | Cache references; CollectionService tags plus `GetInstanceAddedSignal` |
| Server-side `TweenService` | Replicates the property every frame to every client | Tween on the client; the server sets only the final state |

### 9.2 Physics

- **Unanchored decorative parts** are all simulated. Anchor everything that doesn't need to move.
- **Precise collision fidelity** costs the most CPU and memory (`PhysicsParts`). Use Box for small props, Hull for medium ones, and invisible box colliders for big complex meshes. For non-colliding props, set `CanCollide`, `CanTouch` and `CanQuery` to false **and** use Box, because collision geometry stays in memory otherwise.
- Keep **adaptive timestepping**. Fixed 240 Hz quadruples physics work.
- Minimize constraints, and add `NoCollisionConstraint`s between ragdoll limbs.
- **Physics throttling** (slow-motion physics when the server falls behind): reduce the number of simulated assemblies and watch `worldStep` time.
- Set **network ownership** explicitly (`SetNetworkOwner(player)` for vehicles, `nil` for server-authoritative objects).

### 9.3 Humanoids

Humanoids are expensive. Give static NPCs an `AnimationController` plus `Animator` instead. Disable unused states (`Humanoid:SetStateEnabled`, e.g. Climbing, Swimming). Play NPC animations on the client, and only for nearby NPCs. Pool NPCs instead of respawning them, and avoid rescaling (layered clothing makes `updateInvalidatedFastClusters` expensive). For crowds, see `Workspace.EnableSLIMAvatars` and `Model.LevelOfDetail = SLIM`.

### 9.4 Rendering

- **Draw calls** scale with *unique* mesh, material and texture combinations, so reuse assets.
- **Huge unions** (CSG) have dense geometry and can't be updated by the place publishing API. Prefer MeshParts with Box or Hull collision.
- **Overlapping transparency** (glass, water planes, beams, stacked particles, large transparent GUI) causes overdraw.
- Prefer built-in materials over custom textures, and keep textures at 512–1024 px except for hero assets.
- Limit shadow-casting lights, and set `CastShadow = false` on small props.
- Update UI only when values change. Lower particle `Rate` and `Lifetime`, and disable emitters far away.

### 9.5 Networking

- **Excessive remotes:** don't fire every frame or send whole tables. Send deltas, throttle continuous data to 10–20 Hz, and batch updates. Use `UnreliableRemoteEvent` for loss-tolerant, high-frequency cosmetic data.
- Don't create or destroy big instance trees at runtime. Chunk them, or let streaming handle it.
- Delete leftover Animation Editor data (`AnimSaves`) from rigs before cloning them.
- Server VFX: the server sends "explosion at X" and clients build the visuals.

### 9.6 Content hygiene and part counts [heuristic]

- Free models can hide scripts that spawn thousands of instances, or backdoors (`require(<assetId>)`). Check instance count and load time after inserting one.
- Use Explorer property filters (e.g. `CollisionFidelity=PreciseConvexDecomposition`) to count offending parts.
- Small arena without streaming: ≤ 10–20k BaseParts. Large maps: StreamingEnabled on, so totals can reach 100k+, but keep ≤ 10–25k streamed in near the player on phones.
- Keep templates in ServerStorage, not ReplicatedStorage, which replicates at join. Prefer one system script over one script per object.

---

## 10. StreamingEnabled tuning

Instance streaming improves join time, memory and frame rate, and it is on by default for new places. Key properties (from `workspace/streaming/index.md`):

| Property | Recommended | Notes |
|---|---|---|
| `StreamingEnabled` | true | Clients only receive nearby content |
| `StreamingIntegrityMode` | `PauseOutsideLoadedArea` | Pauses a player who walks into unloaded space instead of letting them fall through. Customize the pause screen using `Player.GameplayPaused` |
| `StreamingTargetRadius` | 1024 (default) | The maximum radius that is streamed in. Lower values reduce server work and client memory but shorten visible detail |
| `StreamingMinRadius` | Smaller than the target (default 64) | Content inside it never streams out. The gap between min and target is the buffer |
| `StreamOutBehavior` | `Opportunistic` | Streams out content beyond the target radius even without memory pressure. Big memory savings and fewer out-of-memory crashes |
| `Model.ModelStreamingMode` | `Default`/`Nonatomic` for scenery; `Atomic` for models whose parts scripts need together; `Persistent` only for essentials (wait for `Workspace.PersistentLoaded`); `PersistentPerPlayer` with `Model:AddPersistentPlayer()` | Don't make large models Persistent, because that defeats streaming |

Streaming coding rules: on the client never assume an instance exists. Use `CollectionService:GetInstanceAddedSignal` and `GetInstanceRemovedSignal` (or `WaitForChild` with a timeout). Client physics only runs in streamed areas. Call `Player:RequestStreamAroundAsync(position)` before teleporting a player across the map.

---

## 11. Server performance and network bandwidth

### 11.1 Server health checklist

- **Heartbeat** at 60 (F9 → Server Jobs → Heartbeat → Steps Per Sec).
- **Memory** under 50% of the allocation and flat over hours. Run a 2–6 hour private-server soak to catch uptime leaks.
- **Data ping** (Server Stats) close to network ping. A growing gap means replication queues are backing up.
- Last resort if the heartbeat stays low after optimizing: **Extended Services for Compute** (paid, reserves extra CPU).

### 11.2 Self-monitoring

Accumulate `RunService.Heartbeat` dt for 60 s on the server and `warn` when the average falls below 50 FPS or the worst frame is over 100 ms. Include `Stats:GetTotalMemoryUsageMb()` and the player count in the message. `Stats:GetMemoryUsageMbForTag(Enum.DeveloperMemoryTag.X)` gives per-category numbers. To stay within analytics rate limits, send a periodic `LogCustomEvent("ServerMemoryMB", mb)` sample from only a fraction of servers.

### 11.3 Network bandwidth budgets [heuristic]

Roblox does not publish a hard per-player cap. These are commonly used studio budgets:

| Direction | Comfortable | Warning |
|---|---|---|
| Server → each client (replication plus remotes) | ≤ 30–50 KB/s sustained | > 80 KB/s sustained, or join bursts that never settle |
| Client → server | ≤ 5–10 KB/s | > 20 KB/s |
| Remote events per client per second | ≤ 20–30 total | > 60 (one per frame) |

Measure with Performance Stats and Debug Stats → Network (Shift+F3). Do the arithmetic: a 2 KB inventory table at 10 Hz to 30 players is 600 KB/s of server egress, and **that is what kills servers**. Rate-limit every remote per player on the server (token bucket), validate every argument, and use `FireClient` for the players concerned instead of `FireAllClients`.

---

## 12. Analytics: the Roblox Analytics dashboard

Creator Hub → your game → **Analytics**. Full KPIs are unlocked once the game has **more than 10 DAU and 10 play hours for 7 consecutive days**. Owners (and group members with analytics permission) must accept the analytics terms. A verified email and 2-step verification are required.

| Dashboard | Key metrics |
|---|---|
| **Overview** | Benchmark scorecard, topline KPIs |
| **Retention** | D1, D7, D30 by new-user cohort (dated by first play, so the newest D7/D30 points stay blank until time passes) |
| **Engagement** | DAU, MAU, average session time, playtime, new-user first-session retention |
| **Monetization** | Revenue, payer conversion, ARPPU, ARPDAU, sales by product, spender segments (Top 15% / Intermediate 35% / Casual 50% / Lapsed, as percentiles within your game) |
| **Acquisition** | Impressions, qualified play-through rate, traffic sources and their conversion |
| **Demographics / Feedback** | Age, gender, country, language, platform; ratings and comments |
| **Monitoring: Performance, Error Report, Crashes** | Client FPS and memory, server heartbeat and memory, crash rate, client API calls after join; Luau errors; out-of-memory and platform crashes |
| **Explore** | Custom charts, formulas, benchmark and prior-period overlays, segment comparisons (unlocked by custom events) |

**Benchmarks.** For behavior KPIs (retention, session time, payer conversion, ARPPU, and so on), the dashboard shows a band from the **50th to the 90th percentile of experiences with similar players**. It falls back to genre or all experiences when needed, using games with at least 100 DAU. For overall-success KPIs it uses the top 1,000 games by 30-day playtime. Example from the docs: a D1 benchmark band of **12.11%–18.73%** means half of similar games are below 12.11% and only 10% are above 18.73%. The same data is available programmatically through the (experimental) **Open Cloud Benchmarks API** (`POST https://apis.roblox.com/analytics-benchmark/v1/universes/{universeId}/benchmarks`, metric for example `ForwardD1Retention`, scope `universe.analytics:read`).

**Filters and breakdowns**: age group, gender, country, language, platform, OS, new vs. returning, spender segment. Always break a KPI change down by **platform** first. Many "retention drops" are really a phone-only performance regression.

---

## 13. AnalyticsService custom events (verified API)

All `AnalyticsService` logging methods are **server-side** calls that take a `Player`. Call them from Scripts, not LocalScripts. If the client needs to report a step (for example "closed tutorial"), it fires a validated remote and the server logs it.

### 13.1 Methods

| Method | Signature (verified in the engine API reference) | Use |
|---|---|---|
| `LogOnboardingFunnelStepEvent` | `(player, step: int, stepName: string?, customFields: Dictionary?)` | The one-time FTUE funnel. Steps run 1–100. Skipped steps count as completed |
| `LogFunnelStepEvent` | `(player, funnelName: string, funnelSessionId: string?, step: int = 1, stepName: string?, customFields?)` | Recurring funnels (shop purchase flow, upgrade flow). At most **10 funnels**. Steps 1–100. Repeated steps in the same session are ignored but still count toward the rate limit. Analytics tracks only the **10 most recent `funnelSessionId`s per user per funnel**. Use `HttpService:GenerateGUID()` for a session ID |
| `LogEconomyEvent` | `(player, flowType: Enum.AnalyticsEconomyFlowType, currencyType: string, amount: float, endingBalance: float, transactionType: string, itemSku: string?, customFields?)` | Sources (`Source`) and sinks (`Sink`) of every soft or hard currency. Amount is always positive. Ending balance ≥ 0. Use `Enum.AnalyticsEconomyTransactionType.X.Name` strings (`IAP`, `ContextualPurchase`, `Shop`, `Gameplay`, `TimedReward`, `Onboarding`, …) |
| `LogCustomEvent` | `(player, eventName: string, value: double = 1, customFields?)` | Counters and values (boss defeated, time to clear a level, K/D). At most **100 event names**. Auto-tracks count and unique users; values support sum, avg, min and max |
| `LogProgressionEvent` | `(player, progressionPathName: string, status: Enum.AnalyticsProgressionType, level: int, levelName: string?, customFields?)` | Level start, complete and fail. Shortcuts: `LogProgressionStartEvent`, `LogProgressionCompleteEvent`, `LogProgressionFailEvent`. The docs say these events **"do not currently display in any Roblox-provided charts"**, so log them for future use and the API, but don't expect a dashboard |
| `LogJourneyEvent` | `(player, journeyName: string, nodeName: string, journeySessionId: string?, customFields?)` | Non-linear paths (hub → zone A → shop → zone B), shown as a Sankey diagram. Names cannot contain `,` `"` `'` or newlines. Node names cannot start with `__` |
| `GetPlayerSegmentsAsync` | `(player)` | Reads the player's analytics segments (for targeting) |

**Deprecated, do not use:** `FireEvent`, `FireCustomEvent`, `FireInGameEconomyEvent`, `FireLogEvent`, `FirePlayerProgressionEvent` (the old PlayFab-era API).

**Custom fields:** at most 3, keyed by `Enum.AnalyticsCustomFieldKeys.CustomField01.Name`, `CustomField02.Name` and `CustomField03.Name`. Other keys are ignored. They work on economy, funnel and custom events (and are accepted by progression and journey events).

### 13.2 Limits (verified, `production/analytics/event-types.md`)

| Limit | Value |
|---|---|
| Global rate limit | **120 + 20 × CCU** `AnalyticsService` requests per minute (per experience) |
| Custom fields | 3 |
| Unique custom-field values | Unlimited, but after **8,000 combined values** across all custom fields, extras are grouped as "Other" |
| Economy resource (currency) types | **10** in the limits table. The API reference for `currencyType` says "5 unique currency types". Treat **5** as the safe maximum |
| Economy transactionTypes | After **20**, grouped as "Other" |
| Economy itemSkus | After **100**, grouped as "Other" |
| Funnels | **10** |
| Steps per funnel | **100** |
| Custom eventNames | **100** |
| Data retention | An event rolls off **90 days** after the last data received. Limits reset daily |

Cardinality rule: **put variety in custom fields, not in names.** Write `PlantSeed` with CustomField01 = `"Plant - Cabbage"`, not three events `PlantCabbage`, `PlantTurnip` and `PlantPepper`. Write currency `XP` with field `Class = Warrior`, not three currencies `WarriorXP`, `MageXP` and `PaladinXP`.

Event names and step names show up in charts. Choose stable, human-readable names on day one, because renaming creates a new series.

### 13.3 Analytics wrapper module

One module owns every analytics call. It enforces the allowlists, the rate budget, pcall safety and once-only onboarding steps.

```lua
-- ServerScriptService/Server/Analytics.luau
--!strict
local AnalyticsService = game:GetService("AnalyticsService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Analytics = {}

local CF1 = Enum.AnalyticsCustomFieldKeys.CustomField01.Name
local CF2 = Enum.AnalyticsCustomFieldKeys.CustomField02.Name
local CF3 = Enum.AnalyticsCustomFieldKeys.CustomField03.Name

-- ===== Allowlists (protect cardinality limits) =====
local CURRENCIES = { Coins = true, Gems = true } -- keep <= 5
local FUNNELS = { Shop = true, Upgrade = true, Trade = true } -- keep <= 10
local CUSTOM_EVENTS = { -- keep well under 100
	BossDefeated = true, LevelCleared = true, FeedbackRating = true,
	ClientError = true, ServerError = true, RebirthDone = true,
}
local ONBOARDING_STEPS = {
	"Joined", "Loaded", "IntroClosed", "FirstCollect", "FirstSell",
	"FirstUpgrade", "SecondLoop", "Played5Min",
}

-- ===== Rate budget: 120 + 20*CCU per minute, keep 25% headroom =====
local windowStart = os.clock()
local sentThisWindow = 0
local function budgetAllows(): boolean
	local now = os.clock()
	if now - windowStart >= 60 then
		windowStart, sentThisWindow = now, 0
	end
	local limit = (120 + 20 * #Players:GetPlayers()) * 0.75
	if sentThisWindow >= limit then return false end
	sentThisWindow += 1
	return true
end

local ENABLED = true -- set false to silence analytics in tests
local function safeCall(fn: (...any) -> (), ...: any)
	if not ENABLED or not budgetAllows() then return end
	local ok, err = pcall(fn, AnalyticsService, ...)
	if not ok and RunService:IsStudio() then
		warn("[Analytics] call failed:", err)
	end
end

local function fields(a: string?, b: string?, c: string?): { [string]: string }?
	if not (a or b or c) then return nil end
	local t = {}
	if a then t[CF1] = a end
	if b then t[CF2] = b end
	if c then t[CF3] = c end
	return t
end

-- ===== Onboarding: each step once per player per server session =====
local onboardingDone: { [Player]: { [number]: boolean } } = {}

function Analytics.onboarding(player: Player, stepName: string)
	local step = table.find(ONBOARDING_STEPS, stepName)
	if not step then
		warn("[Analytics] unknown onboarding step", stepName)
		return
	end
	local done = onboardingDone[player]
	if not done then
		done = {}
		onboardingDone[player] = done
	end
	if done[step] then return end
	done[step] = true
	safeCall(AnalyticsService.LogOnboardingFunnelStepEvent, player, step, stepName)
end

-- ===== Recurring funnels =====
function Analytics.newFunnelSession(): string
	return HttpService:GenerateGUID(false)
end

function Analytics.funnelStep(player: Player, funnel: string, sessionId: string?, step: number, stepName: string, field1: string?)
	if not FUNNELS[funnel] then warn("[Analytics] funnel not allowlisted", funnel) return end
	safeCall(AnalyticsService.LogFunnelStepEvent, player, funnel, sessionId, step, stepName, fields(field1))
end

-- ===== Economy =====
-- transactionType: pass Enum.AnalyticsEconomyTransactionType.X (we convert to .Name)
function Analytics.source(player: Player, currency: string, amount: number, endingBalance: number,
	transactionType: Enum.AnalyticsEconomyTransactionType, sku: string?, field1: string?)
	if not CURRENCIES[currency] or amount <= 0 then return end
	safeCall(AnalyticsService.LogEconomyEvent, player, Enum.AnalyticsEconomyFlowType.Source,
		currency, amount, math.max(0, endingBalance), transactionType.Name, sku, fields(field1))
end

function Analytics.sink(player: Player, currency: string, amount: number, endingBalance: number,
	transactionType: Enum.AnalyticsEconomyTransactionType, sku: string?, field1: string?)
	if not CURRENCIES[currency] or amount <= 0 then return end
	safeCall(AnalyticsService.LogEconomyEvent, player, Enum.AnalyticsEconomyFlowType.Sink,
		currency, amount, math.max(0, endingBalance), transactionType.Name, sku, fields(field1))
end

-- ===== Custom events =====
function Analytics.custom(player: Player, eventName: string, value: number?, f1: string?, f2: string?, f3: string?)
	if not CUSTOM_EVENTS[eventName] then warn("[Analytics] event not allowlisted", eventName) return end
	safeCall(AnalyticsService.LogCustomEvent, player, eventName, value or 1, fields(f1, f2, f3))
end

function Analytics.setEnabled(on: boolean) ENABLED = on end

Players.PlayerRemoving:Connect(function(player)
	onboardingDone[player] = nil
end)

return Analytics
```

Usage:

```lua
Analytics.onboarding(player, "Joined")
Analytics.sink(player, "Coins", 500, wallet.balance, Enum.AnalyticsEconomyTransactionType.Shop, "Egg_Basic", "Zone1")
local sid = Analytics.newFunnelSession()
Analytics.funnelStep(player, "Shop", sid, 1, "OpenedShop")
Analytics.funnelStep(player, "Shop", sid, 2, "ViewedItem", "SpeedCoil")
Analytics.funnelStep(player, "Shop", sid, 3, "Purchased", "SpeedCoil")
Analytics.custom(player, "BossDefeated", fightSeconds, "Boss - Golem", "Party - " .. partySize)
```

Notes: for "once ever" onboarding, also persist completed steps in player data. Call `Analytics.setEnabled(false)` in the test bootstrap. A client-originated step arrives as a remote whose name the server checks against an allowlist and rate-limits before logging.

---

## 14. Funnel design

Good funnels are **short, ordered and decision-focused**.

**Onboarding funnel (8–12 steps)**: each step should be an *action that proves understanding*, not just time passing.

```
1 Joined (server PlayerAdded)
2 Loaded (client: game.Loaded + loading screen closed)
3 IntroClosed / skipped
4 FirstCoreAction (first collect / first hit / first jump pad)
5 FirstReward
6 FirstSpend (first upgrade with soft currency)
7 CompletedTutorial
8 SecondLoop (core loop done twice)
9 Played5Min
10 Played15Min
```

How to read it:
- Step 1 → 2 drop above **10%**: a load-time or crash problem (check the Performance dashboard by platform).
- Step 2 → 4 drop: an unclear first goal. Add a world-space arrow or beacon, shorten the intro, make the first action happen within 10 s.
- Step 5 → 6 drop: the player doesn't understand the shop or the upgrade loop. Add a forced or guided first purchase.
- Step 8 → 10 drop: the core loop is not compelling, or the second goal is unclear.

**Recurring funnels** (use `funnelSessionId`): shop (open → view → buy prompt shown → purchased), upgrades, trading, matchmaking queue (queue → match found → match completed).

Funnel breakdowns use only the custom-field values from the *first* step of a funnel session. Put segmenting info (for example entry point "Button" vs. "NPC") on step 1.

---

## 15. Experiments and A/B testing

### 15.1 In-experience Experiments (Configs-based)

Roblox's **Experiments** (Creator Hub → Experiments) A/B test **Config** values. Configs are remote key-value settings read with `ConfigService`, which is server-only:

```lua
local ConfigService = game:GetService("ConfigService")
-- Per-player value (required for experiments and targeting)
local snapshot = ConfigService:GetConfigForPlayerAsync(player)
local starterPackPrice = snapshot:GetValue("starterPackPrice") -- falls back to control value
```

(`GetConfigAsync()` returns the global config *without* targeting. Use `GetConfigForPlayerAsync(player)` for experiment assignment. Check `production/configs.md` for the snapshot API details, such as refresh signals.)

Experiment facts (verified, `production/experiments.md`):
- Types: **In-game** (config values) and **Matchmaking** (custom matchmaking configurations; only one at a time; 100% rollout recommended).
- **One control plus up to 2 variants** for in-game, and up to 3 variants for matchmaking.
- Duration: **14–60 days**. Choose a goal metric and a percent rollout. After scheduling, the configuration is locked (you can only reschedule).
- Metric sets: **Default** (D1, D7, playtime, ARPU, ARPPU, payer conversion, session time), **Rewarded Video Earnings**, and **Custom** (default plus up to 3 custom metrics built from your custom, economy and funnel events).
- Metrics update every 24 h. In the first 24 h, playtime, payer conversion and ARPU update every 5 minutes as **early-harm** signals.
- Optional audience targeting uses config attributes (platform, country, and so on).
- Mind the **minimum detectable effect**: with small player counts, only big differences are detectable. The docs recommend simple 50/50 tests (one variant plus control) on large rollouts.

What to test in-experience: tutorial variants, starter pack price or contents, reward pacing (`coinsPerCollect`), difficulty (`bossHealth`), shop button placement, daily reward schedule.

Rules: write one hypothesis per experiment ("bossHealth 500→300 raises D1 ≥ 1 pt without lowering ARPU"). Don't stop early on noise unless early-harm shows a clear regression. Don't overlap experiments on the same system.

### 15.2 Thumbnail and icon testing

**Thumbnail personalization** (Creator Hub → Places → Thumbnails → Home Page): activate **2 or more** thumbnails, and Roblox shows each one to random users, learns which converts best per user group (the goal is **qualified play-through rate**), then shifts impressions toward the winners while still exploring. In Roblox's testing, games averaged **+8.5%** qualified play-through rate, and some reached +50%. Keep several thumbnails active rather than picking one "winner", so personalization can adapt. Analyze the results in the personalization performance view.

Loop: make 3–5 *distinct* concepts (subject, color, composition), run them for 1–2 weeks, retire the clear losers, add challengers. Judge thumbnails by qualified play-through rate on the Acquisition dashboard, not by retention.

---

## 16. KPIs and healthy ranges

**Always compare against your dashboard's similar-games benchmark first.** The ranges below are **[heuristic]** cross-genre rules of thumb, collected from public developer talks and DevForum discussions as of 2026, for orientation only. Genres differ a lot (simulators retain differently from horror one-offs, and social hangouts have long sessions but low payer conversion).

| KPI | Definition | Concerning | OK | Strong | Exceptional (front-page) |
|---|---|---|---|---|---|
| **D1 retention** | % of new users who return the next day | < 8% | 10–15% | 15–25% | > 25–30% |
| **D7 retention** | % of new users who return after 7 days | < 2% | 3–6% | 6–10% | > 12% |
| **D30 retention** | | < 1% | 1–2% | 2–4% | > 5% |
| **Average session length** | Playtime / sessions | < 6 min | 8–15 min | 15–25 min | > 30 min |
| **New-user first-session length** | | < 4 min | 5–10 min | 10–20 min | > 20 min |
| **Payer conversion** (daily, % of DAU who pay) | | < 0.3% | 0.5–1.5% | 1.5–3% | > 4% |
| **ARPPU** | Revenue / payers | highly genre-dependent; track the trend | | | |
| **ARPDAU** | Revenue / DAU (Robux) | < 0.5 R$ | 1–3 R$ | 3–6 R$ | > 8 R$ |
| **Qualified play-through rate** (impressions → plays) | | well below benchmark | at benchmark | above | far above |
| **PCU / CCU** | Peak concurrent users | – | depends on stage | | |
| **Client crash rate** | | > 3% | 1–2% | < 1% | |

How the KPIs relate: **Revenue = DAU × ARPDAU**, and **ARPDAU = payer conversion × ARPPU**. DAU comes from acquisition times retention, so D1 and D7 compound everything. Recommendations reward engagement, and the acquisition docs advise getting session time and D1 to at least match similar games **before** scaling ads. Small games should design for small servers (6–12) so servers feel full.

---

## 17. Interpreting data and iterating

1. Define the question ("Why did D1 drop from 14% to 11% on Nov 3?").
2. Segment by platform → country → new vs. returning → acquisition source → place version.
3. Correlate with changes using place-version annotations. Most drops line up with an update or a **traffic-mix** shift. Ad or sponsored bursts and new countries retain worse, and that isn't a game regression.
4. Find the funnel step that changed. Form a hypothesis and change **one** thing. Measure it with an experiment, or over at least 7 days comparing like weekdays.
5. Log the decision in `docs/decisions.md`.

Pitfalls: below about 1,000 new users a day, D1 swings of ±2 points are noise. Holidays and weekends shift DAU. Visits are a vanity metric. Padding session length with forced waits hurts D7.

---

## 18. Live ops calendar

| Cadence | Activity |
|---|---|
| **Daily** | Error Report and Crashes (5 min), Feedback page and community channels, sanity-check the CCU curve |
| **Weekly** | A small update (fixes, balance, one item) on a consistent weekday, often before the weekend. KPI review against the benchmark |
| **Bi-weekly / monthly** | A content update (zone, pet set, mode) or a limited-time event. Thumbnail rotation. Experiment readouts |
| **Seasonal** | Holiday events (Halloween, winter, summer, Lunar New Year). Battle-pass seasons of 4–8 weeks |
| **Quarterly** | A major update. Economy inflation review (sources vs. sinks). Deep performance pass on the baseline device |

Events: gate content behind a **Config flag or a UTC server-time check**, so it switches on and rolls back without a publish. Log participation with custom events. Announce in game and in the description. Publish with **"Migrate to latest update"** (soft shutdown), not a hard restart during peaks.

---

## 19. Error monitoring

### 19.1 Built-in: Error Report dashboard

**Monitoring → Error Report** shows near-real-time Luau errors and warnings for server and client. You can filter by date, place, severity, platform and OS, add version annotations, and filter to **"new errors since" a version**. Each row has count, message, first seen, **first seen version** and a stack trace. After every publish, check "new errors since vNNN" at +15 and +60 minutes.

The **Open Cloud Error Reporting API** (`universe.analytics:read`/`write`, 60 requests/min per key) fetches error details and manages grouping and ignore rules. Use it for a daily job that posts new errors to team chat.

### 19.2 Structured logging (LogService)

`LogService` now supports structured logging: `:Info`, `:Warn`, `:Log` and `:Error(message, context)`. `:Error` always throws a table with `message`, `template`, `context` and `stack`, so wrap it in `pcall`. Named loggers come from `LogService:GetLogger("Shop")`. `{key}` placeholders are filled from the context, and `LogService.MessageOut(message, messageType, context)` receives the context. Example: `LogService:GetLogger("Shop"):Info("Purchase {sku}", { sku = "SpeedCoil" })`. This API is newer than most community examples, so check the `Logger` class page before relying on child loggers.

### 19.3 Error-reporting module

Goals: catch unhandled errors on the server and client, **deduplicate** them, **rate-limit** them, attach the place version and platform, and record counts in analytics without blowing the cardinality limits (one event name, with the message signature in a custom field).

```lua
-- ServerScriptService/Server/ErrorReporter.server.luau
local ScriptContext = game:GetService("ScriptContext")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Analytics = require(script.Parent.Analytics)

local remote = Instance.new("RemoteEvent")
remote.Name = "ClientErrorReport"
remote.Parent = ReplicatedStorage

local PLACE_VERSION = tostring(game.PlaceVersion)
local MAX_PER_SIGNATURE_PER_MIN = 5
local MAX_CLIENT_REPORTS_PER_MIN = 10

local seen: { [string]: { count: number, windowStart: number } } = {}
local clientBudget: { [Player]: { n: number, t: number } } = {}

-- Normalize: strip numbers and quoted strings so "Part123" and "Part456" group together.
local function signature(message: string, stack: string?): string
	local firstFrame = stack and (string.match(stack, "^[^\n]+") or "") or ""
	local s = (message .. " @ " .. firstFrame)
	s = string.gsub(s, "%d+", "#")
	s = string.gsub(s, "\"[^\"]*\"", "\"*\"")
	return string.sub(s, 1, 100) -- keep custom-field values short and low-cardinality
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

local function record(kind: "ServerError" | "ClientError", player: Player?, message: string, stack: string?, platform: string?)
	local sig = signature(message, stack)
	if not shouldReport(sig) then return end
	-- Analytics needs a Player; for server errors use any connected player as the carrier.
	local carrier = player or Players:GetPlayers()[1]
	if carrier then
		Analytics.custom(carrier, kind, 1, sig, "v" .. PLACE_VERSION, platform or "server")
	end
	warn(("[ErrorReporter] %s v%s %s\n%s"):format(kind, PLACE_VERSION, message, stack or ""))
end

-- Server-side unhandled errors (the Error Report dashboard also captures these).
ScriptContext.Error:Connect(function(message: string, stackTrace: string, _script: Instance?)
	record("ServerError", nil, message, stackTrace)
end)

-- Client reports, validated and rate-limited.
remote.OnServerEvent:Connect(function(player: Player, message: any, stack: any, platform: any)
	if typeof(message) ~= "string" or #message > 500 then return end
	if stack ~= nil and (typeof(stack) ~= "string" or #stack > 2000) then return end
	if typeof(platform) ~= "string" or #platform > 20 then platform = "unknown" end
	local now = os.clock()
	local b = clientBudget[player]
	if not b or now - b.t > 60 then
		b = { n = 0, t = now }
		clientBudget[player] = b
	end
	b.n += 1
	if b.n > MAX_CLIENT_REPORTS_PER_MIN then return end
	record("ClientError", player, message, stack, platform)
end)

Players.PlayerRemoving:Connect(function(p) clientBudget[p] = nil end)
```

```lua
-- StarterPlayerScripts/ErrorReporterClient.client.luau
local ScriptContext = game:GetService("ScriptContext")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local remote = ReplicatedStorage:WaitForChild("ClientErrorReport")

local function platform(): string
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then return "touch" end
	if UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled then return "gamepad" end
	return "desktop"
end

local lastSent = 0
ScriptContext.Error:Connect(function(message, stackTrace)
	local now = os.clock()
	if now - lastSent < 2 then return end -- client-side throttle
	lastSent = now
	remote:FireServer(string.sub(message, 1, 500), string.sub(stackTrace or "", 1, 2000), platform())
end)
```

Notes: `ScriptContext.Error` passes `(message, stackTrace, script)` and does **not** fire for watchdog timeouts. Never trust client reports: validate sizes and rate-limit per player. Normalizing and truncating signatures protects the 8,000-value custom-field cap. The Error Report dashboard stays the source of truth, and this module adds platform and version breakdowns. If you forward batched reports to your own endpoint via `HttpService`, send no PII and keep keys in the Secrets Store, never in client code.

### 19.4 Crash analysis

1. **Client crashes** (Performance dashboard, by device): a spike after an update on low-RAM devices is a memory regression. Bisect by version and check F9 → PlaceMemory (GraphicsTexture, GraphicsMeshParts, Sounds) and streaming.
2. **Server out-of-memory crashes** (Crashes page): read the snapshot treemap. Big Workspace folders mean spawned objects that were never destroyed. Big script memory means leaked tables or connections. Crashes that correlate with uptime point to a leak. Reproduce it with a long private-server soak, comparing Luau Heap snapshots taken 30 minutes apart.
3. **Platform crashes** are Roblox's to fix. File a DevForum report if they spike.
4. Turn on analytics **Alerts** (`production/analytics/alerts.md`) for crash rate, errors and CCU drops.

---

## 20. Release checklist

Copy into each release PR or ticket.

```
PRE-RELEASE (test universe)
[ ] All CI green: format, lint, place build, Jest (Open Cloud) pass
[ ] Smoke test (sec 1.2) passed on the exact build to be published
[ ] Regression subset [Core][Data][Monetize] passed; full list if major update
[ ] Server & Clients (3 clients) - replication, leaderboards, trading OK
[ ] Network Simulator "Bad mobile" profile - no stuck UI, no double actions
[ ] Device Simulator: phone (small + large), tablet, console - UI usable, gamepad nav works
[ ] Real low-end Android (baseline device): 10-min session, >= 30 FPS, memory flat, no crash
[ ] DataStore: new player, returning player, rejoin-fast, BindToClose save, migration from last schema
[ ] Purchases: every new dev product / pass tested (receipt granted exactly once, re-join retains)
[ ] Analytics: new events allowlisted; onboarding steps fire in order once; no new event names beyond plan
[ ] No new free-model scripts; no require(<assetId>) backdoors; Output clean of red errors
[ ] Performance: no MicroProfiler spike > 5 ms added in core areas; draw calls within tier budget
[ ] Content maturity questionnaire still accurate for new content
[ ] Update log / patch notes written; thumbnails/icon updated if feature-worthy
[ ] Live-event flags (Configs) set to correct defaults; rollback plan written

PUBLISH
[ ] Publish to production from the reviewed build (Studio or manual CI workflow)
[ ] Note new place version number in changelog
[ ] Use "Migrate to latest update" (soft) unless a hard shutdown is required (S0 exploit/data bug)

POST-RELEASE (first hour, then 24 h)
[ ] Error Report: filter "new errors since vNNN" at +15 min and +60 min
[ ] Performance dashboard: client crash rate, memory, server heartbeat vs previous version
[ ] Crashes page: no OOM uptick
[ ] CCU curve normal; Feedback page / community channels for reports
[ ] +24 h: D0 funnel steps unchanged or better; economy sources/sinks sane
[ ] +7 d: D1/D7 vs previous cohorts and benchmark; decide keep / iterate / revert
```

---

## Sources

Local creator-docs (`reference/creator-docs/content/en-us/`):
- Studio: `studio/testing-modes.md`, `includes/studio/playtest-modes.md`, `studio/device-simulator.md`, `studio/network-simulator.md`, `studio/developer-console.md`.
- Performance: `performance-optimization/identify.md`, `design.md`, `improve.md`, `test-on-hardware.md`, `scene-analysis.md`, `microprofiler/index.md`, `microprofiler/use-microprofiler.md`; `workspace/streaming/index.md`.
- Data and publishing: `cloud-services/data-stores/index.md`, `production/publishing/publish-games-and-places.md` (early testers), `production/publishing/thumbnails.md` (personalization).
- Analytics: `production/analytics/analytics-dashboard.md`, `retention.md`, `engagement.md`, `monetization.md`, `acquisition.md`, `performance.md`, `error-report.md`, `crashes.md`, `alerts.md`, `custom-events.md`, `funnel-events.md`, `economy-events.md`, `custom-fields.md`, `event-types.md` (limits); `production/experiments.md`, `production/configs.md`.
- Engine API: `reference/engine/classes/AnalyticsService.yaml`, `ScriptContext.yaml`, `LogService.yaml`.
- Open Cloud: `cloud/guides/usage-place-publishing.md`, `cloud/guides/error-reporting/index.md`, `cloud/guides/analytics/benchmarks.md`, `cloud-services/http-service.md` (Luau Execution operations), `studio/mcp-open-cloud.md` (scope `universe.place.luau-execution-session:*`).

Libraries: `reference/libraries/Roblox_jest-roblox/docs/docs/` (GettingStarted, CLI, MockFunctions, JestBenchmarkAPI) and `scripts/run-tests.luau`; `reference/libraries/lune-org_lune/crates/*/types.d.luau`.

Web (treated as data): [DevForum, Open Cloud Engine API for Executing Luau](https://devforum.roblox.com/t/beta-open-cloud-engine-api-for-executing-luau/3172185); [rbxcloud luau_execution.rs](https://docs.rs/crate/rbxcloud/latest/source/src/rbx/v2/luau_execution.rs) (search snippet only); [rocale-cli](https://github.com/fitzpr/rocale-cli). The official Luau Execution reference (create.roblox.com) could not be fetched from this environment, so its fields are marked [verify].

KPI ranges, the per-tier budget table, the bandwidth budgets and the part-count guidelines are marked [heuristic]. They are synthesized studio rules of thumb, not Roblox-published figures.
