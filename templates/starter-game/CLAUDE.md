# <Game Name>: bot instructions

Original Roblox game built from `~/Roblox/templates/starter-game`. The knowledge base is at
`~/Roblox/knowledge`: read `00-master-checklist.md` first, then the guide for the task at hand
(the table is in `~/Roblox/CLAUDE.md`). Look up exact APIs with `~/Roblox/scripts/kb_search.sh`. Never guess.

## Facts (fill in)
- Genre / core loop: <one sentence>
- Target: mobile-first, ages 9+, sessions of 10–20 min
- Universe IDs: prod <id> (place <id>); test <id> (place <id>). Put the test place id in `default.project.json` → `servePlaceIds`
- Owner: user <id> | group <id>. Assets must be owned by this creator
- Data store: `GameConfig.DataStoreName` = `PlayerData_v1`. Never rename it without a migration plan

## Commands
- Setup: `rokit install && wally install` (runtime libraries are vendored; Wally is only for the Jest dev-deps)
- Format: `stylua src tests lune`
- Gate (must pass before every commit): `scripts/check.sh` runs JSON checks, a test-project sync check, StyLua, selene, sourcemap, a strict luau-lsp type-check, both Rojo builds and `lune/scan-place`. The luau-lsp step had not yet been run when the template was written, so fix any strict-mode errors it reports on the first run
- After editing `default.project.json`: `python3 scripts/sync-test-project.py`. Never edit `test.project.json` by hand
- Live sync: `rojo serve`, then Connect in the Studio Rojo plugin (test place only)
- Cloud tests: `lune run tests/run-cloud-tests.luau <savedVersion>` (needs `ROBLOX_API_KEY`, `TEST_UNIVERSE_ID`, `TEST_PLACE_ID`)

## Where things are
| What | Where |
|---|---|
| Server bootstrap (only Script) | `src/server/init.server.luau`: `Net.createAll()`, then `Loader.load(Services)` |
| Client bootstrap (only LocalScript) | `src/client/init.client.luau`: `Loader.load(Controllers)` |
| Module contract | `Priority` (higher runs first), `Init` (sync, no yields, connect things), `Start` (may yield). See `src/shared/Loader.luau` |
| Remotes (single source of truth) | `src/shared/Net/Remotes.luau`. Server: `src/server/Net.luau` (`Net.handle/fire/fireAll/notify`). Client: `src/shared/Net/Client.luau` |
| Arg validation / rate limits | `src/shared/Net/Guard.luau`, `src/shared/Net/RateLimiter.luau` |
| Player data | `src/server/Services/DataService.luau` (only ProfileStore user); schema and migrations in `src/server/Data/Schema.luau` |
| Robux | `src/server/Services/PurchaseService.luau` (the ONLY `ProcessReceipt`); ids in `src/shared/Config/Products.luau` |
| Compliance | `src/server/Services/Policy.luau` (fail-closed) |
| Analytics / errors | `src/server/Services/Analytics.luau`, `ErrorReporter.luau` |
| Live config | `src/server/Services/LiveConfig.luau` (every key needs a DEFAULT) |
| Daily reward / codes | `DailyRewardService.luau` + `Shared/Util/DailyRewardMath.luau`; `CodesService.luau` + `src/server/Config/Codes.luau` |
| Per-player cleanup | `src/server/Services/PlayerLifecycle.luau` (`troveFor(player)`, `onCharacter(fn)`) |
| Tuning | `src/shared/Config/GameConfig.luau`, `DailyRewards.luau` |
| Asset ids | `src/shared/Config/Assets.luau` + `assets/ASSETS.md` (owner + license for each) |
| HUD (authored, editable) | `src/gui/HUD.model.json` → `StarterGui.HUD`; behavior in `src/client/Controllers/*` via `Hud.find(path)` |
| UI kit | `src/shared/UI/Theme.luau`, `src/client/UI/{AnimatedButton,Toast,Hud}.luau` |
| Game feel | `src/client/FX/{CameraShaker,RewardBurst,Sfx,MusicManager}.luau` |
| Lighting | `default.project.json` → `Lighting` (base look); `src/shared/LightingPresets.luau` (runtime moods) |
| Example mechanic | `CollectService.luau` + `CollectController.luau` + `Workspace.Map.CollectNodes` |
| Tests | `tests/specs/*.spec.luau` (Jest-Lua) → `ServerScriptService.Tests` in `test.project.json` |
| Design docs | `docs/DESIGN.md`, `docs/STYLE.md`, `docs/SYSTEMS.md`, `docs/PLAYTEST.md` |

## Rules
- Files are the source of truth. Never leave Rojo-managed scripts edited only in Studio.
- `--!strict` at the top of every file. No globals. Use `task.*` only: never `wait()`, `spawn()` or `delay()`. Use only current APIs, checked against `~/Roblox/reference/api/API-Dump.txt`.
- The server is authoritative. Clients send intent only. Every client→server remote is declared in `Remotes.luau` with `args` (Guard) and `rate`, and its handler re-checks the game rules: range, cooldown, ownership, price. The server never calls `InvokeClient`.
- Data changes go only through `DataService`. Mutate `profile.Data` and never replace it. Don't yield between a check and the write that depends on it. Bump `Schema.VERSION` and add a migration and a test for any rename or retype.
- Purchases: grant only in `PurchaseService.processReceipt`, keep it idempotent through `PurchaseIdCache`, never hard-code prices (read them with `GetProductInfoAsync`), and give no pay-to-win advantage over other players.
- Gate paid random items, paid trading, ads and similar features with `Policy.can` on the server. Show odds for every paid random item.
- Wrap every web call (DataStore, Marketplace, Policy, Config, Http, Teleport, TextService) in pcall, using `Shared/Util/Retry.luau` where a retry makes sense.
- Clean up every connection: use a Trove per player or character (`PlayerLifecycle`) or per controller. Handle the join race by connecting `PlayerAdded` and then looping over `GetPlayers()`.
- UI is native instances authored in `.model.json` or Studio, not whole menus flattened into images. Design mobile-first: touch targets of 44 px or more after scaling, `CoreUISafeInsets`, and honor `ReducedMotionEnabled`. In `.model.json`, write UDim2 as `{"UDim2": [[xs, xo], [ys, yo]]}` and UDim as `{"UDim": [s, o]}`. Rojo 7.7.1 rejects the bare-array forms.
- Filter all player-written text with `TextService` before other players see it.
- Audio: instrumental music only (no vocals, choir or humming) that loops seamlessly, with crossfades. SFX must be non-vocal. Use only assets you own or that are licensed, and record each in `assets/ASSETS.md`.
- Original work only: no other games' names, art, music or levels. Never insert unscanned free models. Never commit secrets.
- `Lighting.LightingStyle` and `PrioritizeLightingQuality` are writable only by plugins or Open Cloud. Set them in `default.project.json`.
- Verify by playing in Studio (Device Emulator: phone first). Passing checks does not mean the game is fun or looks good. Log each playtest in `docs/PLAYTEST.md`.
