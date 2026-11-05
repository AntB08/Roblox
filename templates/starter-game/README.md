# Starter Game (template)

A Rojo project that is the base for every new **original** Roblox game. It builds without
Wally (ProfileStore, Trove and Signal are vendored). It includes the production systems almost
every game needs, plus one complete example mechanic, **Collect**, that runs from input through
the server and back to client feedback. Copy that mechanic's shape when you add new ones.

> Bot: read `CLAUDE.md` in this folder first. It holds the rules and says where things live.

## What's included

| Area | Where | Notes |
|---|---|---|
| Bootstraps | `src/server/init.server.luau`, `src/client/init.client.luau` | The only Script and the only LocalScript. `Shared/Loader` runs `Init` on every module, then `Start` |
| Remotes | `src/shared/Net/Remotes.luau` (definitions), `src/server/Net.luau`, `src/shared/Net/Client.luau` | One source of truth. Each client→server remote has `Guard` argument checks and a per-player token-bucket rate limit. Malformed traffic is counted, and repeat offenders are kicked |
| Validation | `src/shared/Net/Guard.luau`, `src/shared/Net/RateLimiter.luau` | Pure modules with unit tests |
| Player data | `src/server/Services/DataService.luau`, `src/server/Data/Schema.luau` | ProfileStore with session locking, a versioned template and migrations, a guard against data from a newer version, GDPR `AddUserId`, and the join race handled |
| Leaderstats | `src/server/Services/LeaderstatsService.luau` | Display only, mirrored from the profile |
| Purchases | `src/server/Services/PurchaseService.luau`, `src/shared/Config/Products.luau` | The only `ProcessReceipt` in the game. It is idempotent through a `PurchaseIdCache` in the profile and acknowledges only after the save. It also keeps the game pass cache. Prices are read live on the client |
| Policy | `src/server/Services/Policy.luau` | Fail-closed `PolicyService` wrapper. It also writes `Policy_<Feature>` attributes for the UI |
| Analytics | `src/server/Services/Analytics.luau` | Allowlists, rate budget, pcall, and the onboarding funnel |
| Errors | `src/server/Services/ErrorReporter.luau`, `src/client/Controllers/ErrorReporterClient.luau` | Deduplicated and rate-limited, with validated client reports |
| Live config | `src/server/Services/LiveConfig.luau` | `ConfigService` wrapper with defaults that retries and refreshes |
| Daily reward | `src/server/Services/DailyRewardService.luau`, `src/shared/Util/DailyRewardMath.luau` | 7-day streak with a one-day freeze. Uses UTC days and lives in the profile |
| Codes | `src/server/Services/CodesService.luau`, `src/server/Config/Codes.luau`, `src/shared/Util/CodeFormat.luau` | Server-only list, once per player, optional global `maxUses` |
| Settings | `src/server/Services/SettingsService.luau`, `src/client/Controllers/SettingsController.luau` | Music volume and camera shake, saved in the profile |
| Cleanup | `src/server/Services/PlayerLifecycle.luau` | One Trove per player and one per character |
| UI | `src/gui/HUD.model.json` (authored instances), `src/client/UI/*`, `src/shared/UI/Theme.luau` | Native editable GUI (not images). AnimatedButton, Toast, responsive UIScale, safe areas |
| Game feel | `src/client/FX/*` | CameraShaker, RewardBurst, Sfx (new Audio API), MusicManager (seamless loops, crossfades) |
| Lighting | `default.project.json` → `Lighting`, `src/shared/LightingPresets.luau` | Neutral daylight preset (not the default look) plus runtime mood presets |
| Example mechanic | `src/server/Services/CollectService.luau`, `src/client/Controllers/CollectController.luau`, `Workspace.Map.CollectNodes` | Collect, end to end |
| Tests | `tests/specs/*.spec.luau` | Jest-Lua specs for Guard, RateLimiter, migrations, daily reward date math, code normalization, Format |
| Tooling | `rokit.toml`, `wally.toml`, `selene.toml`, `stylua.toml`, `.luaurc`, `scripts/check.sh`, `.github/workflows/ci.yml`, `lune/scan-place.luau` | Quality gate and CI |

## Start a new game from this template

1. **Copy:**
   ```bash
   cp -r ~/Roblox/templates/starter-game ~/games/<game-name>
   cd ~/games/<game-name> && git init
   ```
2. **Rename:**
   - `"name"` in `default.project.json`, then run `python3 scripts/sync-test-project.py`.
   - `name` in `wally.toml`.
   - The title in `CLAUDE.md` and in this README.
3. **Set IDs** (search for `SET ID` and `PLACEHOLDER`):
   - `default.project.json` → `servePlaceIds`: your TEST place id, so `rojo serve` can never sync into production.
   - `src/shared/Config/Products.luau`: developer product and pass ids from Creator Hub. An id of `0` hides the offer.
   - `src/shared/Config/Assets.luau`: sound, music and icon ids. Record each one in `assets/ASSETS.md`. Use only assets you own or that are licensed. Music must be **instrumental** and loop seamlessly.
   - `src/server/Config/Codes.luau`: your launch code(s).
   - `CLAUDE.md` → Facts: universe and place ids for production and test, and the owner.
4. **Design first:** fill in `docs/DESIGN.md` and `docs/STYLE.md`. Pick a lighting preset and copy its values into `default.project.json` → `Lighting`, including `LightingStyle`, which scripts cannot set.
5. **Toolchain and gate:**
   ```bash
   rokit install          # pinned tools
   wally install          # Jest dev-deps (runtime libs are vendored)
   stylua src tests lune  # normalise formatting with the pinned StyLua
   scripts/check.sh       # format, lint, typecheck, build, place checks
   ```
6. **Play it:** run `rojo serve`, connect from Studio, and turn on *Game Settings → Security → Enable Studio Access to API Services* so data saves. Alternatively, set the Workspace attribute `UseMockData = true` to use an in-memory store. Walk to a glowing crystal and press **Collect** (or E / gamepad X).
7. **Replace the example.** Keep the Collect files as a reference until your first real mechanic works, then delete them (`CollectService`, `CollectController`, `Remotes.Collect/CollectResult`, `Workspace.Map.CollectNodes`, `HUD/BottomCenter`).

## How the Collect vertical slice works

```
Client  CollectController   nearest ready "CollectNode" in range -> show HUD CollectButton
        press (tap / E / X)  -> Remotes.Collect:FireServer(node)            (intent only)
Server  Net                  rate limit (3/s, burst 5) + Guard.instanceOf("BasePart", Workspace)
        CollectService       tag? alive? distance <= 12 + 4 slack? per-node cooldown (server clock)?
                             -> DataService.addCoins (profile is saved by ProfileStore; updates the
                                leaderstat and the "Coins" attribute; logs an analytics economy event)
                             -> Remotes.CollectResult:FireClient(player, { ok, amount, position, cooldown })
Client  CollectController    RewardBurst (particles + light + sound) + toast + camera shake
        UIController         coin counter pops (bound to the "Coins" attribute)
```

## Everyday recipes

- **New remote:** add an entry to `src/shared/Net/Remotes.luau` with `args` (Guard checks) and `rate`. Use `Net.handle(name, fn)` on the server and `NetClient.event(name)` or `NetClient.invoke(name, ...)` on the client.
- **New server system:** add `src/server/Services/<Name>Service.luau`. It returns a table with optional `Priority`, `Init` (must not yield) and `Start` (may yield). The loader finds it automatically.
- **New client system:** add `src/client/Controllers/<Name>Controller.luau`. It uses the same contract.
- **New saved field:** add it to `TEMPLATE` in `src/server/Data/Schema.luau`. Reconcile fills it in for existing players. To rename or retype a field, bump `VERSION`, add `MIGRATIONS[old]` and add a test.
- **New UI:** author it in `src/gui/*.model.json`, or in Studio and then sync it back to the file. Controllers only find instances by name with `Hud.find("Path/To/Thing")` and bind behavior to them. Tag buttons `AnimatedButton`.
- **Live tuning:** add a key with a default to `LiveConfig`'s `DEFAULTS`, read it with `LiveConfig.number(key, fallback)`, and edit it in Creator Hub → Configs.

## Using Wally instead of the vendored packages

The vendored copies are in `src/shared/Packages/{Trove,Signal}` and `src/server/Packages/ProfileStore`, each with its LICENSE file. To switch to Wally:

1. Run `wally install`. This creates `Packages/` and `ServerPackages/`.
2. Add `"Packages": { "$path": "Packages" }` under `ReplicatedStorage` and `"ServerPackages": { "$path": "ServerPackages" }` under `ServerScriptService` in `default.project.json`, then re-run `scripts/sync-test-project.py`.
3. Replace each vendored `init.luau` with a one-line re-export, for example `return require(game:GetService("ReplicatedStorage").Packages.Trove)`. No other code changes are needed.

## Testing

- **Unit specs** (`tests/specs`) run inside Roblox with Jest-Lua. `test.project.json` is the production tree plus `ReplicatedStorage.DevPackages` (from `wally install`) plus `ServerScriptService.Tests`. It is regenerated from `default.project.json` by `scripts/sync-test-project.py`, so don't edit it by hand.
- **Cloud (CI):** build `test.project.json`, upload it as a *Saved* version of the TEST place, then run `lune run tests/run-cloud-tests.luau <version>`. This needs the `ROBLOX_TEST_API_KEY` secret and the `TEST_UNIVERSE_ID` and `TEST_PLACE_ID` variables. CI skips this step until they are set.
- **Studio:** build `test.project.json`, open it, and paste `tests/cloud-test-runner.luau` into the command bar.
- **Play-testing is still required.** Syntax checks and unit tests don't prove a game is fun, readable on a phone, or good-looking.

## Verification status

### Verified when this template was written (2026-11-05)

- Every `.luau` file (61, including vendored) passes `luau-compile --null`, so there are no syntax errors.
- Every class, enum item, service and the ~230 members used were checked against `reference/api/API-Dump.txt`. None are missing or deprecated, and none are restricted from scripts. `Lighting.LightingStyle` and `PrioritizeLightingQuality` can be written only by plugins or Open Cloud, so they are set in `default.project.json` and never from scripts.
- **Rojo 7.7.1 (built from crates.io) builds `default.project.json` and `test.project.json`**, and `rojo sourcemap` succeeds. The built place has exactly 1 Script and 1 LocalScript, Lighting is applied (LightingStyle = Soft), CollectionService tags are written, and LICENSE files are not turned into instances.
- `lune run lune/scan-place` (Lune 0.11.1) passes on the production place, and it correctly fails on the test place, which contains specs.
- `stylua --check src tests lune` passes with StyLua 2.3.1. `rokit.toml` pins 2.6.0, so re-run `stylua` once after `rokit install`.
- `selene` 0.31.0 reports 0 errors and 0 warnings, but only against a minimal substitute std (Luau plus Roblox globals as `any`). The real `std = "roblox"` could not be downloaded here.
- The pure-module specs pass (51 cases) when run with the plain `luau` CLI and a small Jest/Roblox shim. `luau-analyze --mode=strict` is clean on the pure modules.
- All JSON files parse, `test.project.json` is in sync, and every version in `rokit.toml` exists as an upstream git tag.

### Not yet verified in Studio

Studio does not run on Linux, so none of the following has been run in a real Roblox client or server:

- Gameplay at runtime: data load and save through ProfileStore, receipts (use Studio test purchases), passes, the Policy and Config services, and analytics calls.
- The HUD's look and layout on phone, tablet, PC and console (Device Emulator), gamepad navigation, and the feel of the Collect feedback.
- Jest-Lua running the specs inside Roblox (the Open Cloud Luau Execution flow in CI). The API fields in `tests/run-cloud-tests.luau` are marked VERIFY.
- `luau-lsp analyze` (the strict whole-project type-check with Roblox definitions) has **not** been run. Expect to fix a few strict-mode type errors on the first `scripts/check.sh`.
- `selene` with the real Roblox std.
- That each pinned tool in `rokit.toml` has a release binary for your platform.
