# 08 — Bot Toolchain and Workflow: Building Roblox Games from Files

> Audience: a Claude Code agent working mostly from a Linux terminal, building **original** Roblox games.
> Versions checked on 2026-11-05 against local source repos and official docs (see Sources).
> Tool versions at time of writing: Rojo 7.7.1, Rokit 1.2.0, Wally 0.3.2 (stable; 0.4.0 is alpha), luau-lsp 1.70.1, selene 0.32.0, StyLua 2.6.0, Lune 0.11.1, darklua 0.19.0, wally-package-types 1.7.0, pesde 0.7.4, Jest Roblox 3.20.0.

---

## TL;DR rules for the bot

1. **Files are the source of truth.** Every script, every config, and every buildable instance lives in git as text (`.luau`, `.project.json`, `.model.json`, `.meta.json`), or as a generated binary (`.rbxm`) that a checked-in Lune script can regenerate. Never leave anything important only inside a Studio session.
2. **Rojo builds the place.** `rojo build default.project.json -o build/game.rbxl` is the build step. It needs no Studio and runs on Linux. Treat a failed build as a broken commit.
3. **Pin every tool in `rokit.toml`** and run `rokit install` first in every fresh environment. Do not rely on globally installed binaries.
4. **Run the quality gate before every commit**: `stylua --check src`, `selene src`, `rojo sourcemap … && luau-lsp analyze …`, then `rojo build`. All four must pass with zero errors.
5. **Studio does not run on Linux.** Plan for two modes. **Headless mode**: Rojo + Lune + Open Cloud (publish a test place, run tests with the Luau Execution API). **Studio-attached mode**: a human's Studio with the Rojo plugin and/or the built-in **Roblox Studio MCP server**, which Claude Code connects to over stdio. Default to headless mode. Use Studio only for what genuinely needs it.
6. **Generate geometry in code.** Use Lune scripts that write `.rbxm` files, project.json `$properties`, or runtime builders. Studio-only things are CSG unions (`PartOperation`), MeshPart import, SurfaceAppearance and hand-sculpted terrain. Keep them in `assets/studio/*.rbxm` and document how each was made.
7. **Lighting is file-authorable.** Set `Lighting` properties and children (Atmosphere, Sky, ColorCorrection, Bloom) in `default.project.json`. Terrain is not file-friendly, so generate it at runtime from a seed, or with a command-bar or `--task RunScript` script, and save the result.
8. **Secrets never touch git.** Open Cloud API keys come from environment variables (`ROBLOX_API_KEY`). Give each key the narrowest scope and restrict it to specific games and, where possible, to an IP range.
9. **Publish to a TEST place first** (`versionType=Saved`), run the cloud test suite against that version, and only then publish to production (`versionType=Published`). The publish API ignores some instance types (unions, SurfaceAppearance, EditableImage/Mesh, BaseWrap), so publish those from Studio.
10. **Only use assets you own or have rights to.** Do not insert free models blindly, because they are a malware and backdoor vector. Use no IP from other games, brands or franchises. Record every asset ID in `assets/ASSETS.md` with its owner and license.
11. **Follow the end-to-end procedure** (§14): concept → design doc → style spec → systems → content → playtest → polish → publish. A game is "done" only when it meets the Definition of Done (§15) and passes the self-review checklist (§16).
12. **Never guess an API or a CLI flag.** Search the local references (`scripts/kb_search.sh`) or run the tool's `--help`. The flags below were verified against source. Note the odd ones, such as `rojo upload --api_key/--universe_id/--asset_id`, which use underscores.

---

## 1. The big picture: what runs where

| Step | Tool | Runs on Linux? | Needs Studio? | Needs network/API key? |
|---|---|---|---|---|
| Write code/config | editor + luau-lsp | yes | no | no |
| Format / lint / typecheck | StyLua, selene, luau-lsp analyze | yes | no | selene `std=roblox` downloads its std once (or pin it) |
| Install packages | Wally / pesde | yes | no | yes (package registries) |
| Generate models/places | Lune `@lune/roblox` | yes | no | no |
| Build place file | `rojo build` | yes | no | no |
| Live-sync into Studio | `rojo serve` + Rojo plugin | server yes | yes (human's machine) | local network |
| Pure-logic unit tests | Lune (non-engine modules) | yes | no | no |
| Engine tests (real DataModel) | Open Cloud Luau Execution + Jest Roblox | yes (HTTP client) | no | API key |
| Interactive playtest / screenshots | Studio MCP server (`start_stop_play`, `screen_capture`, input simulation) | no | yes | no (local stdio) |
| Publish place | Open Cloud Place Publishing API or `rojo upload` | yes | no | API key |
| Upload images/audio/meshes | Open Cloud Assets API | yes | no | API key |
| Edit DataStores / send live messages | Open Cloud DataStore v2 / Messaging | yes | no | API key |
| Unions, MeshPart import, terrain sculpting | Studio | no | yes | — |

The rule that falls out of this table: **everything except the last row, and interactive playtesting, can be done by the bot alone.** Where a human with Studio is in the loop, use them for the visual pass and the feel pass, plus the few Studio-only operations.

---

## 2. Toolchain managers: Rokit (preferred), Aftman, Foreman

All three download pinned CLI binaries from GitHub releases and put a shim on your `PATH`, so that `rojo`, `selene` and the rest resolve to the version pinned by the project.

- **Rokit** (`rojo-rbx/rokit`) is the current recommendation. It is fast and reads `rokit.toml`. It also reads the legacy `aftman.toml` and `foreman.toml`, so old repos keep working.
- **Aftman** (`aftman.toml`) is the predecessor. It is still common in older repos, and luau-lsp's own repo still ships an `aftman.toml`.
- **Foreman** (`foreman.toml`) is the oldest. Avoid it in new projects.

Install Rokit on Linux or macOS (from its README):

```bash
curl -sSf https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.sh | bash
# then restart the shell or source the profile it edited
rokit --version
```

Subcommands (verified in `src/cli/`) are `init`, `add`, `install`, `list`, `update`, `trust`, `authenticate`, `self-install`, `self-update` and `system-info`.

```bash
rokit init                              # creates rokit.toml in cwd
rokit add rojo-rbx/rojo                 # adds latest + installs; alias defaults to repo name
rokit add rojo-rbx/rojo@7.7.1 rojo      # explicit version + alias
rokit add --global lune-org/lune        # global tool, not in project manifest
rokit install                           # install everything in rokit.toml
rokit install --no-trust-check          # CI only: skip interactive trust prompts
rokit authenticate github --token "$GITHUB_TOKEN"  # avoid GitHub API rate limits in CI
```

**Template: `rokit.toml`**

```toml
# rokit.toml: pinned toolchain. Run `rokit install` after cloning.
[tools]
rojo = "rojo-rbx/rojo@7.7.1"
wally = "UpliftGames/wally@0.3.2"
wally-package-types = "JohnnyMorganz/wally-package-types@1.7.0"
selene = "Kampfkarren/selene@0.32.0"
stylua = "JohnnyMorganz/StyLua@2.6.0"
luau-lsp = "JohnnyMorganz/luau-lsp@1.70.1"
lune = "lune-org/lune@0.11.1"
darklua = "seaofvoices/darklua@0.19.0"
```

If a pinned version is not available as a release asset for linux-x86_64, run `rokit add <repo>` without a version to get the latest one, and record what it chose.

Some environments block GitHub release downloads. In that case `cargo install rojo --locked` (likewise `selene`, `stylua`, `lune`) is a slower fallback. luau-lsp is C++, so get it from its release zip.

---

## 3. Rojo: the build system

Rojo maps a filesystem tree onto the Roblox instance tree. It provides `rojo build` (files → `.rbxl`/`.rbxm`), `rojo serve` (live sync into Studio via the plugin), `rojo sourcemap` (for luau-lsp), `rojo syncback` (place → files, new in 7.x), `rojo upload`, `rojo init`, `rojo plugin`, `rojo fmt-project` and `rojo doc`.

### 3.1 CLI reference (verified against `src/cli/*.rs`, Rojo 7.7.1)

```bash
rojo init [PATH] --kind place|model|plugin [--skip-git]   # scaffold (default kind: place)

rojo build [PROJECT] -o build/game.rbxl          # --output/-o; extension picks format:
                                                 # .rbxl/.rbxlx = place, .rbxm/.rbxmx = model
rojo build [PROJECT] -p MyPlugin.rbxm            # --plugin/-p: build straight into Studio plugins folder
rojo build [PROJECT] -o build/game.rbxl --watch  # rebuild on change

rojo serve [PROJECT] [--address 0.0.0.0] [--port 34872] [--allowed-hosts host1,host2]

rojo sourcemap [PROJECT] -o sourcemap.json [--include-non-scripts] [--watch] [--absolute]

rojo syncback [PROJECT] --input place.rbxl [--list] [--dry-run] [-y|--non-interactive]

rojo upload [PROJECT] --asset_id <PLACE_ID> --universe_id <UNIVERSE_ID> --api_key "$ROBLOX_API_KEY"
#   NOTE: these three flags use underscores. With --api_key, Rojo uses Open Cloud (places only).

rojo fmt-project [PROJECT]     # normalizes project.json formatting
rojo plugin install            # installs the matching Studio plugin (human's machine)
```

`[PROJECT]` defaults to the current directory, which means `default.project.json` there. Pass a different file (for example `test.project.json`) to build variants.

### 3.2 `*.project.json` format

Top-level fields (from `src/project.rs`; unknown fields are rejected):

| Field | Meaning |
|---|---|
| `name` | Project name (root instance name for model builds). |
| `tree` | The root **instance node** (required). For a place, `"$className": "DataModel"`. |
| `servePort`, `serveAddress`, `serveAllowedHosts` | Defaults for `rojo serve`. |
| `servePlaceIds` / `blockedPlaceIds` | Whitelist or blacklist of place IDs the plugin may sync into (safety against syncing into prod). |
| `placeId`, `gameId` | Sets the place/game ID on connect (useful for testing). |
| `emitLegacyScripts` | Default **true** until Rojo 8. When true, `*.server.luau` becomes `Script` and `*.client.luau` becomes `LocalScript`. When false, both become `Script` with `RunContext` Server/Client. |
| `globIgnorePaths` | Globs (relative to the project file) to skip, for example `["**/*.spec.luau"]` in prod builds. |
| `syncRules` | Custom file-pattern → middleware rules. |
| `syncbackRules` | Controls what `rojo syncback` writes. |

Instance-node keys:

| Key | Meaning |
|---|---|
| `$className` | Class to create. Optional when `$path` provides one, or when the key is a service name (`Workspace`, `ReplicatedStorage`, …). |
| `$path` | File or folder to turn into this instance. `{"optional": "DevPackages"}` means "skip if missing". |
| `$properties` | Property values (see value syntax below). |
| `$attributes` | Attributes (unambiguous values, or explicitly typed). |
| `$ignoreUnknownInstances` | If true, `rojo serve` won't delete instances that exist in Studio but not in files. It defaults to true for nodes with no `$path`. |
| `$id` | A referent ID so that other instances can point at this one (see Ref properties). |
| any other key | A child instance with that name. |

**Property value syntax.** Rojo infers the type from the class's reflection data, so most values can be written implicitly:

```jsonc
"$properties": {
  "Anchored": true,                         // bool
  "Transparency": 0.5,                      // number
  "Size": [4, 1, 2],                        // Vector3
  "Color": [0.2, 0.6, 1.0],                 // Color3 (0..1 floats)
  "CFrame": [0, 10, 0,  1,0,0, 0,1,0, 0,0,1], // CFrame: position + 9 rotation terms
  "Material": "SmoothPlastic",              // Enum by name
  "Tags": ["Lava", "Hazard"],               // CollectionService tags
  "Attributes": { "Damage": 25 },           // attributes via property
  "TextureID": "rbxassetid://1234567890"    // Content/ContentId from string
}
```

Use the explicit form when the type is ambiguous, for example `{"Vector3": [1,2,3]}`, `{"Color3uint8": [255,128,0]}` or `{"Enum": 256}`.

**Ref properties** (`ObjectValue.Value`, `Model.PrimaryPart`) use `$id` on the target. On the pointer, use an attribute named `Rojo_Target_<PropertyName>` whose value is the target's ID:

```json
{ "className": "ObjectValue", "attributes": { "Rojo_Target_Value": "spawnPad" } }
```

### 3.3 File → instance rules (default `syncRules`, verified in `snapshot_middleware/mod.rs`)

| File | Becomes |
|---|---|
| `foo.server.luau` / `.server.lua` | `Script` (server) named `foo` |
| `foo.client.luau` / `.client.lua` | `LocalScript` (or `Script` with RunContext=Client if `emitLegacyScripts:false`) |
| `foo.plugin.luau` | plugin script |
| `foo.luau` / `foo.lua` | `ModuleScript` |
| `foo.project.json` | nested project (its tree is inlined) |
| `foo.model.json` | instance(s) described in JSON |
| `foo.meta.json` | **metadata for the sibling `foo.*`** (not an instance) |
| `foo.json` | `ModuleScript` that returns the JSON as a table |
| `foo.toml`, `foo.yaml` | `ModuleScript` returning the data |
| `foo.txt` | `StringValue` |
| `foo.csv` | `LocalizationTable` |
| `foo.rbxm` / `foo.rbxmx` | instances from a binary/XML model file |
| a folder | `Folder` unless it contains an `init.*` file |

**`init` conventions.** If a folder contains `init.luau`, the folder becomes a `ModuleScript` with the folder's name, and its other files become children of that module. `init.server.luau` makes the folder a server `Script`, and `init.client.luau` makes it a `LocalScript`. `init.meta.json` sets properties or the class on the folder itself, for example turning a folder into a `Model` or `ScreenGui`:

```json
// src/client/UI/init.meta.json: makes the "UI" folder a ScreenGui
{ "className": "ScreenGui", "properties": { "ResetOnSpawn": false, "IgnoreGuiInset": true } }
```

**`.meta.json` next to a script** (`Spawner.server.luau` + `Spawner.meta.json`) can set `properties`, `attributes`, `ignoreUnknownInstances` and `id`. For a folder, use `init.meta.json`, which also accepts `className`.

**`.model.json`** (keys: `name`, `className`, `properties`, `attributes`, `children`, `id`):

```json
{
  "className": "Model",
  "properties": { "Tags": ["Checkpoint"] },
  "attributes": { "Stage": 3 },
  "children": [
    {
      "name": "Pad",
      "className": "Part",
      "properties": {
        "Anchored": true,
        "Size": [8, 1, 8],
        "CFrame": [0, 20, 40, 1, 0, 0, 0, 1, 0, 0, 0, 1],
        "Material": "Neon",
        "Color": [0.1, 0.9, 0.4]
      }
    }
  ]
}
```

### 3.4 `.rbxm` vs `.rbxmx`

- `.rbxm` is binary, compact, and handles every property type well, including unions, meshes and terrain data. It is the preferred format for **generated** content and for Studio-made assets.
- `.rbxmx` is XML. It diffs in git but is verbose, and some binary-only data (such as SharedStrings for CSG/mesh data) is awkward to review in it.
- Rule: hand-authored instances go in `.model.json`. Generated or bulk instances go in `.rbxm`, produced by a Lune script that lives in the repo. Studio-made assets go in `.rbxm` under `assets/studio/` with a README line explaining how each was made.

### 3.5 Two-way sync: limitations

- `rojo serve` is **one-way: files → Studio.** Edits made in Studio to Rojo-managed instances are overwritten on the next sync, or lost.
- **`rojo syncback`** (Rojo 7.6+, actively developed in 7.7) converts a place file back into the file tree. It writes `.luau`, `.meta.json` and `.model.json` (including JSON for RemoteEvents, Actors and similar), and `.rbxm` for complex instances. Always run it with `--dry-run --list` first, read the plan, then run it with `-y`. Review the git diff afterwards. It is a migration and import tool, not a continuous sync.
- Instances outside the project tree, or under nodes with `$ignoreUnknownInstances: true` (the default for path-less service nodes), are left alone in Studio. That is how hand-built Workspace content and Rojo-managed code coexist.
- The script editor in Studio is not where the bot works. If a human edits a script in Studio during `rojo serve`, the change must be copied back to the file, or it will be lost.

### 3.6 Live sync (Studio-attached mode)

```bash
rojo serve                         # default port 34872; human clicks "Connect" in the Rojo plugin
rojo serve --address 0.0.0.0 --allowed-hosts my-dev-box.local   # if Studio is on another machine
```

Add `"servePlaceIds": [<test place id>]` so that a misclick can't sync dev code into the live place.

---

## 4. Packages: Wally (default) and pesde

### 4.1 Wally

`wally.toml` declares dependencies by realm, and `wally install` writes them into folders that Rojo maps:

| Section | Install folder | Map in project.json to |
|---|---|---|
| `[dependencies]` (shared) | `Packages/` | `ReplicatedStorage.Packages` |
| `[server-dependencies]` | `ServerPackages/` | `ServerScriptService.ServerPackages` (or `ServerStorage`) |
| `[dev-dependencies]` | `DevPackages/` | `ReplicatedStorage.DevPackages`, **test project only** |

Commands: `wally init`, `wally install`, `wally update`, `wally search <q>`, `wally package --list`, `wally publish`, `wally login`/`logout`, `wally manifest-to-json`. Commit `wally.lock`.

Version strings follow Cargo semantics: `"scope/name@1.2.3"` means `^1.2.3`. Use `"=1.2.3"` for an exact pin.

**Template: `wally.toml`**

```toml
[package]
name = "yourname/my-game"          # scope/name, lowercase
version = "0.1.0"
registry = "https://github.com/UpliftGames/wally-index"
realm = "shared"
private = true                     # never publish a game as a package
license = "UNLICENSED"

[dependencies]
# Pick only what the design needs. Verify current versions with `wally search`.
# Promise = "evaera/promise@4.0.0"
# Trove   = "sleitnick/trove@1.5.0"
# Signal  = "sleitnick/signal@2.0.0"

[server-dependencies]
# ProfileStore: check the current package name/version (or vendor the single module file)

[dev-dependencies]
Jest = "roblox/jest@=3.20.0"
JestGlobals = "roblox/jest-globals@=3.20.0"
```

Wally packages are thunks (re-export modules), so luau-lsp loses their types. After every `wally install`, regenerate the sourcemap and run `wally-package-types`:

```bash
wally install
rojo sourcemap default.project.json -o sourcemap.json
wally-package-types --sourcemap sourcemap.json Packages/
wally-package-types --sourcemap sourcemap.json ServerPackages/
```

### 4.2 pesde (alternative)

pesde is a newer Luau package manager. It uses `pesde.toml` and `pesde.lock`, supports Roblox and Lune targets, and can pull from its own registry, from Wally and from git. Use it if a project already does. For new bot projects, Wally remains the default because it has the widest documentation coverage and the simplest Rojo mapping. Run `pesde --help` before relying on any flags, because pesde is still pre-1.0 and its interface changes.

### 4.3 Vendoring

Small single-file libraries (or ones whose package names are uncertain) can be copied into `src/shared/Vendor/<Lib>/` with their LICENSE file. That is acceptable, and it removes a network dependency. Record the source URL and commit in a header comment.

---

## 5. Static analysis: luau-lsp, selene, StyLua

### 5.1 luau-lsp (type checking, also usable headless)

luau-lsp understands the DataModel through a Rojo **sourcemap**, and understands the Roblox API through a **definitions file**.

```bash
# 1) sourcemap: maps instance paths <-> files
rojo sourcemap default.project.json -o sourcemap.json --include-non-scripts

# 2) Roblox API type definitions (analyze does NOT download them for you)
mkdir -p .luau-lsp
curl -fsSL -o .luau-lsp/globalTypes.d.luau \
  https://luau-lsp.pages.dev/type-definitions/globalTypes.None.d.luau
#   (security levels: None, PluginSecurity, LocalUserSecurity, RobloxScriptSecurity;
#    use None for game code)

# 3) analyze
luau-lsp analyze \
  --platform=roblox \
  --sourcemap=sourcemap.json \
  --definitions=@roblox=.luau-lsp/globalTypes.d.luau \
  --base-luaurc=.luaurc \
  --formatter=plain \
  --ignore="**/Packages/**" --ignore="**/DevPackages/**" --ignore="**/ServerPackages/**" \
  src/
```

These flags were verified in `src/main.cpp`. Two of them are repeatable: `--definitions` takes `@NAME=PATH`, and `--ignore` takes a GLOB. The other flags are `--settings`, `--no-strict-dm-types` and `--formatter default|plain|gnu`. If you pass `--platform=roblox` with no definitions, you get a warning and missing types.

**Template: `.luaurc`**

```json
{
  "languageMode": "strict",
  "lint": { "*": true, "LocalShadow": false },
  "lintErrors": false,
  "typeErrors": true
}
```

Put `--!strict` at the top of every new module anyway. It is explicit and survives copy-paste.

### 5.2 selene (linter)

**Template: `selene.toml`**

```toml
std = "roblox"          # Roblox globals + Roblox-specific lints; std auto-generated & cached
# std = "roblox+testez" # only if using TestEZ globals (not needed for Jest: it uses explicit requires)
# roblox-std-source = "pinned"   # writes roblox.yml locally; use for offline CI

exclude = ["Packages/*", "ServerPackages/*", "DevPackages/*", "build/*"]

[lints]
shadowing = "allow"
unused_variable = "warn"
global_usage = "deny"
deprecated = "warn"
incorrect_standard_library_use = "deny"
```

Run it with `selene src`. Refresh the generated Roblox std with `selene update-roblox-std`. If selene chokes on brand-new Luau syntax that luau-lsp accepts, prefer the conservative syntax, or exclude that file and note why.

### 5.3 StyLua (formatter)

**Template: `stylua.toml`**

```toml
syntax = "Luau"
column_width = 120
line_endings = "Unix"
indent_type = "Tabs"
indent_width = 4
quote_style = "AutoPreferDouble"
call_parentheses = "Always"
collapse_simple_statement = "Never"

[sort_requires]
enabled = false
```

Use `stylua src` to format, `stylua --check src` as the CI gate, and `--verify` as a paranoid safety check that the output parses identically.

### 5.4 darklua (optional transpile step)

darklua rewrites Luau code. Its common uses are converting string requires (`require("./Foo")`) into Roblox instance requires using a Rojo sourcemap (rule `convert_require` with `roblox` mode and `rojo_sourcemap`), stripping type annotations, and bundling. It adds a build stage (`darklua process src out` → Rojo builds from `out/`). Only adopt it if you need it. For most games, write instance-path requires directly (`require(ReplicatedStorage.Shared.Config)`), which Rojo, luau-lsp and Studio all understand with no transform.

---

## 6. Lune: run Luau outside Roblox (and generate places)

Lune is a standalone Luau runtime with `@lune/fs`, `@lune/process`, `@lune/net`, `@lune/serde`, `@lune/stdio`, `@lune/task`, `@lune/datetime`, `@lune/regex`, `@lune/luau` and, most importantly, **`@lune/roblox`**, which reads and writes `.rbxl`/`.rbxm` files and provides a real Instance tree with Roblox datatypes.

```bash
lune run build-map            # finds ./build-map.luau, or ./lune/build-map.luau, or ./.lune/build-map.luau
lune run scripts/foo.luau arg1 arg2   # args in process.args
lune list                     # list scripts in lune/ and .lune/
lune setup                    # generate type definitions for editor support
lune repl
```

**What `@lune/roblox` gives you** (verified in `crates/lune-std-roblox`):

- `deserializePlace(contents) -> DataModel`, `deserializeModel(contents) -> {Instance}`
- `serializePlace(game, xml?) -> string`, `serializeModel({Instance}, xml?) -> string`
- `Instance.new`, and Instance methods: `FindFirstChild*`, `GetChildren`, `GetDescendants`, `QueryDescendants`, `Clone`, `Destroy`, `IsA`, `Get/SetAttribute`, `AddTag/HasTag/GetTags`, `GetFullName`.
- Datatypes: `Vector3`, `Vector2`, `CFrame`, `Color3`, `BrickColor`, `UDim`, `UDim2`, `NumberSequence`, `ColorSequence`, `NumberRange`, `Rect`, `Region3`, `Font`, `PhysicalProperties`, `Content`, `Faces`, `Axes`, `Ray`, `Enum`.
- `getReflectionDatabase()`, which tells you which classes and properties exist.
- `implementMethod` / `implementProperty` let you polyfill engine behavior. **There is no physics, rendering, terrain voxel engine or running scripts.** Lune only manipulates data.

**Template: `lune/build-obby.luau`** (deterministic content generation → `.rbxm` that Rojo includes):

```luau
--!strict
-- Generates assets/generated/ObbyCourse.rbxm from a seed. Run: lune run build-obby [seed]
local fs = require("@lune/fs")
local process = require("@lune/process")
local roblox = require("@lune/roblox")

local Instance = roblox.Instance
local Vector3, CFrame, Color3, Enum = roblox.Vector3, roblox.CFrame, roblox.Color3, roblox.Enum

local seed = tonumber(process.args[1]) or 1337
math.randomseed(seed)

-- Palette from the game's style spec (docs/STYLE.md); keep in sync
local PALETTE = {
	Color3.fromRGB(255, 196, 87),
	Color3.fromRGB(94, 207, 255),
	Color3.fromRGB(255, 120, 160),
}

local course = Instance.new("Model")
course.Name = "ObbyCourse"

local pos = Vector3.new(0, 10, 0)
for stage = 1, 40 do
	local step = Instance.new("Part")
	step.Name = string.format("Step_%02d", stage)
	step.Anchored = true
	step.TopSurface = Enum.SurfaceType.Smooth
	step.BottomSurface = Enum.SurfaceType.Smooth
	step.Material = Enum.Material.SmoothPlastic
	step.Size = Vector3.new(math.random(5, 9), 1, math.random(5, 9))
	-- difficulty ramps: larger gaps and height later
	local gap = 6 + stage * 0.15 + math.random() * 2
	pos += Vector3.new(gap, math.random(-1, 3) * 0.75, (math.random() - 0.5) * 8)
	step.CFrame = CFrame.new(pos)
	step.Color = PALETTE[(stage % #PALETTE) + 1]
	step:SetAttribute("Stage", stage)
	if stage % 10 == 0 then
		step:AddTag("Checkpoint")
		step.Material = Enum.Material.Neon
	end
	step.Parent = course
end

fs.writeDir("assets/generated")
fs.writeFile("assets/generated/ObbyCourse.rbxm", roblox.serializeModel({ course }))
print(`Wrote ObbyCourse.rbxm with {#course:GetChildren()} parts (seed {seed})`)
```

Map it in `default.project.json` as `"Workspace": { "ObbyCourse": { "$path": "assets/generated/ObbyCourse.rbxm" } }`. Commit both the script and the output so that the build has no hidden step, and regenerate the output whenever the script changes.

Other good Lune jobs:

- **Place inspection/linting**: load `build/game.rbxl`, and assert counts (parts < budget, no unanchored parts in static map folders, every `Checkpoint` tag has a `Stage` attribute, no `Script` under `Workspace` from free models).
- **Importing a Studio-made place**: `deserializePlace` it and extract the `Workspace.Map` folder to `assets/studio/Map.rbxm`.
- **Open Cloud client**: `@lune/net` + `@lune/serde` make a dependency-free HTTP client (see §9.7).
- **Unit tests for pure modules**: Lune can `require` shared modules that don't touch engine services (math, economy formulas, inventory logic). Keep game logic in pure modules so this works.

---

## 7. Testing

### 7.1 Layers

1. **Static**: StyLua, selene, luau-lsp analyze. Free and fast. Run them always.
2. **Pure unit tests in Lune**: run them locally on every change. Design modules as `(state, input) -> state` where possible.
3. **Engine tests with Jest Roblox, run in the cloud** via the Open Cloud Luau Execution API: real DataModel, real `Instance`, `CollectionService` and so on. No players connect, so treat it as a headless server.
4. **Interactive playtests**: through the Studio MCP server (when a human's Studio is attached), or by a human. They cover client UI, input, camera, feel, mobile emulation.

### 7.2 Jest Roblox (current standard) and legacy options

- **Jest Roblox** (`Roblox/jest-roblox`, port of Jest 27; Wally `roblox/jest` + `roblox/jest-globals`, 3.20.0 at time of writing). The older `jsdotlua/jest` package name stops at 3.10. Test files are named `*.spec.luau` inside `__tests__` folders.
- **TestEZ** is legacy (`describe/it/expect` globals, `std = "roblox+testez"` in selene). Don't start new projects with it.
- **run-in-roblox** (`rojo-rbx/run-in-roblox`) launches local Studio to run a place and pipe output. It needs Studio (Windows/macOS), so it is unusable on Linux. It has been superseded by the Luau Execution API and Studio's own `--task RunScript --runScriptFile … --outputFile … --quitAfterExecution`.

**Template: `src/shared/__tests__/Economy.spec.luau`**

```luau
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local describe, it, expect = JestGlobals.describe, JestGlobals.it, JestGlobals.expect

local Economy = require(ReplicatedStorage.Shared.Economy)

describe("Economy.priceForLevel", function()
	it("is monotonic", function()
		for level = 1, 99 do
			expect(Economy.priceForLevel(level + 1) >= Economy.priceForLevel(level)).toBe(true)
		end
	end)
	it("rejects non-positive levels", function()
		expect(function() Economy.priceForLevel(0) end).toThrow()
	end)
end)
```

**Template: `tests/run.server.luau`** (the script sent to Luau Execution; it returns a JSON-able summary):

```luau
-- Executed by Open Cloud Luau Execution against the TEST place build.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local runCLI = require(ReplicatedStorage.DevPackages.Jest).runCLI

local roots = { ReplicatedStorage.Shared, game:GetService("ServerScriptService").Server }
local status, result = runCLI(ReplicatedStorage, { verbose = false, ci = true }, roots):awaitStatus()

if status == "Rejected" then
	error(tostring(result))
end
local r = result.results
-- Zero tests found is a SETUP FAILURE, not a pass.
assert(r.numTotalTests > 0, "No tests were discovered: check test roots / jest.config")
assert(r.numFailedTests == 0, `{r.numFailedTests} test(s) failed`)
return { passed = r.numPassedTests, failed = r.numFailedTests, total = r.numTotalTests }
```

Jest Roblox also expects a `jest.config.luau` ModuleScript in each test root, for example `return { testMatch = { "**/*.spec" } }`. Check the Jest Roblox docs for the current config keys before relying on them.

**Template: `test.project.json`** (prod tree + dev packages + tests; never published to the live place):

```json
{
  "name": "my-game-test",
  "tree": {
    "$path": "default.project.json",
    "ReplicatedStorage": {
      "DevPackages": { "$path": { "optional": "DevPackages" } }
    }
  }
}
```

If Rojo rejects merging a nested project at the root like this, duplicate the tree from `default.project.json` and add the `DevPackages` node. Production builds use `globIgnorePaths: ["**/__tests__/**", "**/*.spec.luau"]`, so test files never ship.

---

## 8. Studio integration for an external agent

### 8.1 Roblox Studio MCP server (built into Studio)

Studio ships a built-in **MCP server**. An open-source standalone version came first in 2025 (`Roblox/studio-rust-mcp-server`). Studio's version is enabled from **Assistant → … → Manage MCP Servers → "Enable Studio as MCP server"**. It talks to clients over **stdio** and supports quick-connect for Claude Code, Claude Desktop, Cursor, Codex CLI, Gemini CLI, VS Code and Antigravity.

Connect Claude Code (on the same machine as Studio):

```bash
# macOS
claude mcp add Roblox_Studio -- /Applications/RobloxStudio.app/Contents/MacOS/StudioMCP
# Windows (from cmd/PowerShell where `claude` runs)
claude mcp add Roblox_Studio -- cmd.exe /c "%LOCALAPPDATA%\Roblox\mcp.bat"
```

Or use JSON config (`.mcp.json` / `mcpServers`):

```json
{ "mcpServers": { "Roblox_Studio": { "command": "/Applications/RobloxStudio.app/Contents/MacOS/StudioMCP" } } }
```

**Tools exposed** (official docs). Every call takes a `studio_id`. Get it from `list_roblox_studios`.

| Group | Tools |
|---|---|
| Scripts | `script_read`, `multi_edit` (creates if missing; `datamodel_type: Edit`), `script_search`, `script_grep` |
| Data model | `search_game_tree`, `inspect_instance`, `subagent` (`explore`, `playtest`) |
| Luau | `execute_luau` (`datamodel_type`: Edit, Client or Server) |
| Playtest | `get_studio_state`, `start_stop_play`, `get_console_output`, `screen_capture` (optional camera pose) |
| Input sim | `character_navigation`, `user_keyboard_input`, `user_mouse_input` |
| Assets | `generate_mesh`, `generate_material`, `generate_procedural_model`, `wait_job_finished`, `search_asset`, `insert_asset`, `upload_image`, `store_image` |
| Docs | `http_get` (Roblox docs only), `skill` |
| Open Cloud | `open_cloud_invoke` (no API key; the human grants per-game scopes in **MCP Permissions**; game must be published) |

**How the bot should use it with Rojo:**

- Keep code in files. Run `rojo serve` and let the human connect the plugin. **Do not** use `multi_edit` on Rojo-managed scripts, because Rojo will overwrite the edit. Edit the files instead.
- Use `execute_luau` (Edit datamodel) for one-off **world-building operations**: terrain, lighting experiments, bulk placement, and creating unions with `BasePart:UnionAsync` (unions must be created in Studio). Then save the results as `.rbxm`, or ask the human to export them (right-click → Save to File) into `assets/studio/`.
- Use `start_stop_play` + `character_navigation` + `get_console_output` + `screen_capture` for **smoke playtests**: spawn, walk to the first objective, check the output for errors, capture screenshots for the visual review. Always stop play afterwards.
- `insert_asset`/`search_asset` reach the public Creator Store. Inserted assets are **untrusted** (see §11). Prefer `generate_procedural_model` or your own Lune builders for original content.
- **Cloud sessions can't reach a local Studio.** If Claude Code runs in a remote container, the Studio MCP server is unavailable unless the human runs Claude Code locally. Plan headless.

### 8.2 Command-bar / RunScript scripts

For one-shot edits on a human's machine, write a `.luau` file under `studio-scripts/` and either:

- ask the human to paste it into **View → Command Bar**, or
- give them a ready command: `RobloxStudio --task RunScript --localPlaceFile "/abs/path/build/game.rbxl" --runScriptFile "/abs/path/studio-scripts/gen-terrain.luau" --outputFile out.log --quitAfterExecution` (runs at command-bar permission level).

Command-bar scripts must be **idempotent**: delete or clear what they previously made before rebuilding (for example `workspace.Terrain:Clear()`, or destroy `workspace:FindFirstChild("Generated")`). Each should print a summary line.

**Template: `studio-scripts/gen-terrain.luau`** (also usable at runtime from a server script):

```luau
--!strict
-- Seeded rolling-hills terrain with water. Idempotent. ~512x512 studs.
local Terrain = workspace.Terrain
local SEED, SIZE, CELL = 4242, 512, 8
local BASE_Y, AMP, WATER_Y = 0, 40, 6

Terrain:Clear()
-- Water first: FillBlock overwrites voxels, so the land columns below replace water where they rise above it.
Terrain:FillBlock(CFrame.new(0, WATER_Y / 2, 0), Vector3.new(SIZE, WATER_Y, SIZE), Enum.Material.Water)

local rng = Random.new(SEED)
local ox, oz = rng:NextNumber(0, 1000), rng:NextNumber(0, 1000)

local function height(x: number, z: number): number
	local n = math.noise((x + ox) / 180, (z + oz) / 180) * 0.7
		+ math.noise((x + ox) / 60, (z + oz) / 60) * 0.3
	return BASE_Y + (n + 0.5) * AMP
end

for x = -SIZE / 2, SIZE / 2 - CELL, CELL do
	for z = -SIZE / 2, SIZE / 2 - CELL, CELL do
		local h = math.max(height(x + CELL / 2, z + CELL / 2), 1)
		local material = if h < WATER_Y + 2 then Enum.Material.Sand
			elseif h > AMP * 0.8 then Enum.Material.Rock
			else Enum.Material.Grass
		Terrain:FillBlock(CFrame.new(x + CELL / 2, h / 2 - 8, z + CELL / 2), Vector3.new(CELL, h + 16, CELL), material)
	end
	task.wait() -- yield so Studio/server stays responsive
end
print("Terrain generated, seed", SEED)
```

(For finer control, such as caves, overhangs or smooth shorelines, use `Terrain:WriteVoxels` with explicit material and occupancy arrays per 4-stud voxel, in chunks of ≤ 64³ voxels.)

### 8.3 Terrain strategy

| Option | When | How |
|---|---|---|
| **Runtime generation from seed** (server script at start) | stylized, procedural maps; headless workflow | Put the generator in `ServerScriptService`. Make it deterministic. Budget the startup time (chunk + `task.wait()`), and spawn players only after a `MapReady` attribute is set. |
| **Command bar / MCP `execute_luau` once, then save** | hand-tuned maps | Generate, have the human sculpt, then save `Terrain` into the place. Pull the result into files with `rojo syncback` or Lune (Terrain as `.rbxm`, mapped via `"Terrain": {"$path": "assets/studio/Terrain.rbxm"}`, as in Rojo's `test-projects/terrain`). |
| **No terrain; parts + MeshParts** | obbies, tycoons, simulators, interiors | Often simplest and cheapest. Parts can also be generated by Lune. |

---

## 9. Roblox Open Cloud from the terminal

Base URL: `https://apis.roblox.com`. Auth: header `x-api-key: $ROBLOX_API_KEY`. OAuth 2.0 is for third-party apps; API keys are right for the bot.

### 9.1 API key hygiene

- Create keys at **create.roblox.com → Credentials**, owned by the user or by a group (group-owned games need group-owned keys with the right role permissions).
- Add only the APIs you need. For each API, restrict the key to specific games and operations, set an IP allowlist when possible (`0.0.0.0/0` only for throwaway testing), and set an expiration.
- Suggested keys per project: **deploy key** (universe-places write + luau-execution read/write on the test and prod universes) and **assets key** (asset read/write). Create a **data key** (datastores) only when an admin tool needs it.
- Store keys in env vars or a CI secret. **Never** put them in the repo, logs, place files or `HttpService` code.
- Handle `429` (respect `x-ratelimit-*` headers, back off exponentially) and `5xx` (retry with jitter). `401/403` means a wrong scope, an IP restriction or a key/game mismatch.

### 9.2 Place publishing

```bash
# Publish (goes live): versionType=Published. Save without going live: versionType=Saved.
curl -sS --fail-with-body -X POST \
  "https://apis.roblox.com/universes/v1/${UNIVERSE_ID}/places/${PLACE_ID}/versions?versionType=Saved" \
  -H "x-api-key: ${ROBLOX_API_KEY}" \
  -H "Content-Type: application/octet-stream" \
  --data-binary @build/game.rbxl
# -> {"versionNumber": 42}
# For .rbxlx use Content-Type: application/xml
```

Or use Rojo directly (Open Cloud mode, places only):

```bash
rojo upload default.project.json --api_key "$ROBLOX_API_KEY" --universe_id "$UNIVERSE_ID" --asset_id "$PLACE_ID"
```

Note what `rojo upload` does with a whole-DataModel project. It publishes the full tree, which replaces any hand-built Studio content not in files. That is why **all** content must be in the project (§3.5).

**Limitations (official):** the publish API does not update `EditableImage`, `EditableMesh`, `PartOperation` (unions), `SurfaceAppearance` or `BaseWrap`. If the game uses these, the final publish must be done from Studio.

**First publish:** the API updates existing places. The universe and its start place must be created once, by a human or in Studio (File → Publish to Roblox). Get the Universe ID from the Creator Dashboard (… → Copy Universe ID). The Place ID is in the place's configure URL.

### 9.3 Luau Execution API (run code / tests in the cloud)

Scope: `universe.place.luau-execution-session:write` (create) and `:read` (poll and logs). The task runs your `script` in a headless server of a specific place version and returns its return values as JSON. The default timeout is 5 minutes, and it is set per task with `"timeout": "120s"`.

```bash
# 1) Create task against the version you just saved
TASK=$(curl -sS --fail-with-body -X POST \
  "https://apis.roblox.com/cloud/v2/universes/${UNIVERSE_ID}/places/${PLACE_ID}/versions/${VERSION}/luau-execution-session-tasks" \
  -H "x-api-key: ${ROBLOX_API_KEY}" -H "Content-Type: application/json" \
  --data "$(jq -n --rawfile s tests/run.server.luau '{script: $s, timeout: "300s"}')")
TASK_PATH=$(echo "$TASK" | jq -r .path)

# 2) Poll until state is COMPLETE / FAILED / CANCELLED
while :; do
  R=$(curl -sS "https://apis.roblox.com/cloud/v2/${TASK_PATH}" -H "x-api-key: ${ROBLOX_API_KEY}")
  STATE=$(echo "$R" | jq -r .state); echo "state=$STATE"
  case "$STATE" in COMPLETE|FAILED|CANCELLED) break;; esac
  sleep 3
done
echo "$R" | jq '.output.results, .error'

# 3) Logs (print/warn output)
curl -sS "https://apis.roblox.com/cloud/v2/${TASK_PATH}/logs" -H "x-api-key: ${ROBLOX_API_KEY}" | jq .
```

Notes:

- Instance return values come back as `null`. Return plain tables, strings and numbers.
- You can omit `/versions/${VERSION}` to target the latest version, but pin the version to avoid races.
- For large inputs and outputs there are `luau-execution-session-task-binary-inputs` (≤100 MiB upload via presigned URL) and `enableBinaryOutput` (return `{BinaryOutput = buffer, ReturnValues = {...}}`, ≤256 MiB).
- Use a dedicated **test universe/place**, so that test runs never touch the production DataStores. If tests need data, use a test-only DataStore name prefix.

### 9.4 DataStores (v2)

```bash
# Read one entry
curl -sS "https://apis.roblox.com/cloud/v2/universes/${UNIVERSE_ID}/data-stores/PlayerData/entries/Player_12345" \
  -H "x-api-key: ${ROBLOX_API_KEY}"

# List entries (paginate with pageToken)
curl -sS "https://apis.roblox.com/cloud/v2/universes/${UNIVERSE_ID}/data-stores/PlayerData/entries?maxPageSize=50" \
  -H "x-api-key: ${ROBLOX_API_KEY}"

# Increment a numeric entry
curl -sS -X POST "https://apis.roblox.com/cloud/v2/universes/${UNIVERSE_ID}/data-stores/Stats/entries/GlobalVisits:increment" \
  -H "x-api-key: ${ROBLOX_API_KEY}" -H "Content-Type: application/json" --data '{"amount": 1}'
```

Other endpoints: `PATCH`/`DELETE` on an entry, `:listRevisions`, scoped variants `/scopes/{scope}/entries/...`, ordered data stores under `/ordered-data-stores/...`, and `data-stores:snapshot`. **Rule:** the bot never writes to production player data, except for a documented, reviewed migration or a GDPR/"right to erasure" deletion request. Session-locked data (ProfileStore and similar) must not be edited externally while the player may be online.

### 9.5 Assets API (images, audio, models)

```bash
curl -sS --fail-with-body -X POST "https://apis.roblox.com/assets/v1/assets" \
  -H "x-api-key: ${ROBLOX_API_KEY}" \
  -F 'request={"assetType":"Image","displayName":"CoinIcon","description":"HUD coin icon","creationContext":{"creator":{"userId":"'"${CREATOR_USER_ID}"'"}}}' \
  -F "fileContent=@assets/images/coin.png;type=image/png"
# -> {"path":"operations/abc123", ...}
curl -sS "https://apis.roblox.com/assets/v1/operations/abc123" -H "x-api-key: ${ROBLOX_API_KEY}"
# -> when done: {"done":true,"response":{"assetId":"...","path":"assets/<id>",...}}
```

- Asset types and formats: **Image/Decal** png/jpeg/bmp/tga; **Audio** mp3/ogg/wav/flac (≤7 min, monthly upload caps: 100 if ID-verified, 10 otherwise; can't be updated); **Model** fbx/gltf/glb/rbxm/rbxmx (fbx/gltf import as MeshParts; rbxm uploads as packages); **Video** mp4/mov; **Animation** rbxm/rbxmx. Max 20 MB per call for most types.
- Use `"groupId"` instead of `"userId"` for group games, because assets must be owned by the same creator as the game, or shared with it.
- Uploaded assets go through **moderation**. The operation can be done before the asset is usable in-game, and a rejected asset renders as blank. Re-check before release.
- Images display through `rbxassetid://<id>`. A Decal ID is not the same as its Image ID, so upload as `Image` for UI textures.
- `PATCH /assets/v1/assets/{id}` updates content or metadata. `/versions` and `:rollback` exist too.

### 9.6 Messaging API (talk to live servers)

```bash
curl -sS -X POST "https://apis.roblox.com/cloud/v2/universes/${UNIVERSE_ID}:publishMessage" \
  -H "x-api-key: ${ROBLOX_API_KEY}" -H "Content-Type: application/json" \
  --data '{"topic":"Announcements","message":"{\"kind\":\"shutdown_soon\",\"minutes\":5}"}'
```

In game: `MessagingService:SubscribeAsync("Announcements", fn)`. Use it for live-ops (announcements, event start, soft shutdown). Messages are small (≈1 KB) and are not guaranteed delivery. The legacy endpoint is `/messaging-service/v1/universes/{id}/topics/{topic}`.

### 9.7 Lune Open Cloud client (no curl/jq dependency)

**Template: `lune/cloud-test.luau`**

```luau
--!strict
-- Usage: ROBLOX_API_KEY=... TEST_UNIVERSE_ID=... TEST_PLACE_ID=... lune run cloud-test
local fs = require("@lune/fs")
local net = require("@lune/net")
local process = require("@lune/process")
local serde = require("@lune/serde")
local task = require("@lune/task")

local KEY = assert(process.env.ROBLOX_API_KEY, "ROBLOX_API_KEY not set")
local U = assert(process.env.TEST_UNIVERSE_ID, "TEST_UNIVERSE_ID not set")
local P = assert(process.env.TEST_PLACE_ID, "TEST_PLACE_ID not set")
local BASE = "https://apis.roblox.com"

local function call(method: string, url: string, body: (string | buffer)?, contentType: string?)
	local headers = { ["x-api-key"] = KEY }
	if contentType then headers["Content-Type"] = contentType end
	for attempt = 1, 5 do
		local res = net.request({ url = url, method = method :: any, headers = headers, body = body })
		if res.ok then return serde.decode("json", res.body) end
		if res.statusCode == 429 or res.statusCode >= 500 then
			task.wait(2 ^ attempt)
		else
			error(`{method} {url} -> {res.statusCode}: {res.body}`)
		end
	end
	error("retries exhausted: " .. url)
end

-- 1) build happens before this script: rojo build test.project.json -o build/test.rbxl
local place = fs.readFile("build/test.rbxl")
local v = call("POST", `{BASE}/universes/v1/{U}/places/{P}/versions?versionType=Saved`, place, "application/octet-stream")
print("saved version", v.versionNumber)

-- 2) run tests
local script = fs.readFile("tests/run.server.luau")
local t = call("POST", `{BASE}/cloud/v2/universes/{U}/places/{P}/versions/{v.versionNumber}/luau-execution-session-tasks`,
	serde.encode("json", { script = script, timeout = "300s" }), "application/json")

local r
repeat
	task.wait(3)
	r = call("GET", `{BASE}/cloud/v2/{t.path}`)
	print("state", r.state)
until r.state == "COMPLETE" or r.state == "FAILED" or r.state == "CANCELLED"

local logs = call("GET", `{BASE}/cloud/v2/{t.path}/logs`)
print(serde.encode("json", logs, true))
if r.state ~= "COMPLETE" then
	error("Cloud tests failed: " .. serde.encode("json", r.error or {}, true))
end
print("RESULT", serde.encode("json", r.output.results, true))
```

---

## 10. Representing builds: code-generated vs Studio-built

| Content | Best representation | Why |
|---|---|---|
| Scripts, configs, tuning tables | `.luau` modules | diffable, testable |
| Lighting, Atmosphere, Sky, post-FX, SoundService, StarterPlayer settings | `$properties` + children in `default.project.json` | fully declarative |
| Small hand-placed props (spawn, pads, triggers) | `.model.json` | readable, diffable |
| Procedural/bulk geometry (obby courses, tycoon plots, city blocks, trees) | Lune script → `.rbxm` (committed) | deterministic, regenerable |
| Runtime-variable geometry (per-player plots, rounds, random maps) | server-side builder module from data | changes per session |
| UI | code-built (Fusion/Vide/React-lua or plain Instance builders) on the client, or `.model.json` ScreenGuis | responsive layouts in code, easy to test on mobile |
| Unions/CSG, imported meshes, SurfaceAppearance, sculpted terrain | Studio → `.rbxm` in `assets/studio/` (+ README entry) | needs Studio/engine processing |
| Animations | Studio Animation Editor → upload → ID in `Config/Assets.luau` | needs editor |

**Rules for generated geometry**

- Anchor static geometry. Set `CanCollide`, `CanTouch` and `CanQuery` false on decorative parts. Use `CollisionFidelity = Box` for decorative MeshParts.
- Tag things instead of naming them: `CollectionService` tags (`"Checkpoint"`, `"KillBrick"`, `"Collectible"`) plus attributes (`Stage = 3`). Systems bind to tags, so content stays dumb data.
- Put generated content under a dedicated folder (`Workspace.Map.Generated`), so that it can be rebuilt wholesale.
- **MeshParts can't be created from files by setting `MeshId`.** Their collision and render data come from the engine, so a file-made MeshPart has the wrong size and physics. Either import the meshes in Studio and save them as `.rbxm`, or at runtime use `AssetService:CreateMeshPartAsync(Content.fromAssetId(id))` (server), then clone the result.
- Budgets (see chapter 04/02): aim for < ~10k parts in a typical map, stream large worlds (`Workspace.StreamingEnabled = true`, set in project.json), and reuse models via `Clone()`.

**Template: `src/server/Builders/PlotBuilder.luau`** (runtime builder pattern):

```luau
--!strict
local CollectionService = game:GetService("CollectionService")
local PlotBuilder = {}

export type PadSpec = { name: string, offset: Vector3, size: Vector3, color: Color3, tag: string? }

function PlotBuilder.build(origin: CFrame, pads: { PadSpec }, parent: Instance): Model
	local model = Instance.new("Model")
	model.Name = "Plot"
	for _, spec in pads do
		local p = Instance.new("Part")
		p.Name = spec.name
		p.Anchored = true
		p.Size = spec.size
		p.Color = spec.color
		p.Material = Enum.Material.SmoothPlastic
		p.CFrame = origin * CFrame.new(spec.offset)
		if spec.tag then CollectionService:AddTag(p, spec.tag) end
		p.Parent = model
	end
	model.PrimaryPart = model:FindFirstChild(pads[1].name) :: BasePart
	model.Parent = parent
	return model
end

return PlotBuilder
```

---

## 11. Asset IDs, ownership and permissions

- **Ownership must match.** A place can only load images, audio, meshes and animations that are owned by the game's creator (the user or the group), that are public (Creator Store, where allowed), or that have been explicitly granted to the universe. Animations are the strictest: they must be owned by the game owner. A user-owned animation will not play in a group game.
- **Granting access:** the Asset Permissions API (`PATCH /asset-permissions-api/v1/assets/permissions`) and the Creator Dashboard share assets with specific universes. Audio and images uploaded by the game owner just work.
- **Centralize IDs** in `src/shared/Config/Assets.luau`:

```luau
--!strict
-- Every asset used by the game. Owner + source recorded in assets/ASSETS.md.
return table.freeze({
	Images = table.freeze({ Coin = "rbxassetid://0", Gem = "rbxassetid://0" }),
	Sounds = table.freeze({ Pickup = "rbxassetid://0", Music_Lobby = "rbxassetid://0" }),
	Animations = table.freeze({ Swing = "rbxassetid://0" }),
})
```

  A Lune check script fails the build if any value is still `rbxassetid://0` at release time.
- **Free models / Creator Store inserts are untrusted.** Before keeping one, scan it: no `Script`/`ModuleScript` you didn't write, no `require(<number>)`, no `getfenv`, no `loadstring`, no obfuscated strings, no `HttpService` calls. A Lune scan script (`lune run scan-place build/game.rbxl`) can enforce this on every build.
- **Originality and IP:** no trademarked names, logos, characters or music from other franchises or games. Everything is generated by the bot, uploaded by the owner, or clearly licensed for Roblox use. Keep `assets/ASSETS.md` as the ledger: ID, type, owner, source (generated / own upload / store with link), license, date.
- Roblox's default sky, the built-in `rbxasset://` content and the standard materials are always safe to use.

---

## 12. Recommended repo template

```
my-game/
├── CLAUDE.md                    # per-game bot instructions (template below)
├── README.md                    # how to build/run (short)
├── rokit.toml
├── wally.toml   wally.lock
├── default.project.json         # production tree
├── test.project.json            # + DevPackages, tests
├── selene.toml  stylua.toml  .luaurc
├── .gitignore
├── docs/
│   ├── DESIGN.md                # design doc (from chapter 01 template)
│   ├── STYLE.md                 # palette, materials, lighting, UI style, fonts, sound
│   ├── SYSTEMS.md               # module map, remotes list, data schema + version
│   └── PLAYTEST.md              # playtest log: date, build, findings, fixes
├── src/
│   ├── shared/                  # -> ReplicatedStorage.Shared
│   │   ├── Config/              # tuning tables, Assets.luau, Products.luau
│   │   ├── Net/                 # remote definitions (single source of truth)
│   │   ├── Util/
│   │   └── __tests__/
│   ├── server/                  # -> ServerScriptService.Server
│   │   ├── init.server.luau     # bootstrap: requires services in order
│   │   ├── Services/            # DataService, EconomyService, RoundService...
│   │   ├── Builders/
│   │   └── __tests__/
│   ├── client/                  # -> StarterPlayer.StarterPlayerScripts.Client
│   │   ├── init.client.luau
│   │   ├── Controllers/
│   │   └── UI/
│   └── storage/                 # -> ServerStorage.Assets (server-only templates)
├── assets/
│   ├── ASSETS.md                # asset ledger
│   ├── images/ audio/           # source files for upload
│   ├── generated/               # *.rbxm produced by lune scripts (committed)
│   └── studio/                  # *.rbxm made in Studio (committed) + README
├── lune/                        # build-*.luau generators, cloud-test.luau, scan-place.luau, check-assets.luau
├── studio-scripts/              # command-bar / RunScript scripts (idempotent)
├── tests/run.server.luau
├── scripts/check.sh             # the quality gate
├── Packages/ ServerPackages/ DevPackages/   # (gitignored, from wally)
└── build/                       # (gitignored)
```

**Template: `default.project.json`**

```json
{
  "name": "my-game",
  "emitLegacyScripts": false,
  "globIgnorePaths": ["**/__tests__/**", "**/*.spec.luau"],
  "servePlaceIds": [],
  "tree": {
    "$className": "DataModel",

    "ReplicatedStorage": {
      "Shared": { "$path": "src/shared" },
      "Packages": { "$path": { "optional": "Packages" } }
    },

    "ServerScriptService": {
      "Server": { "$path": "src/server" },
      "ServerPackages": { "$path": { "optional": "ServerPackages" } }
    },

    "ServerStorage": {
      "Assets": { "$path": "src/storage" }
    },

    "StarterPlayer": {
      "$properties": {
        "CharacterWalkSpeed": 16,
        "CharacterJumpHeight": 7.2,
        "CameraMaxZoomDistance": 64
      },
      "StarterPlayerScripts": {
        "Client": { "$path": "src/client" }
      }
    },

    "Workspace": {
      "$properties": {
        "StreamingEnabled": true,
        "Gravity": 196.2
      },
      "Map": {
        "$className": "Folder",
        "SpawnLocation": {
          "$className": "SpawnLocation",
          "$properties": {
            "Anchored": true,
            "Size": [12, 1, 12],
            "CFrame": [0, 0.5, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1],
            "Material": "SmoothPlastic",
            "Duration": 0
          }
        },
        "Ground": {
          "$className": "Part",
          "$properties": {
            "Anchored": true,
            "Locked": true,
            "Size": [512, 4, 512],
            "CFrame": [0, -2, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1],
            "Material": "Grass",
            "Color": [0.36, 0.6, 0.3]
          }
        }
      }
    },

    "Lighting": {
      "$properties": {
        "Technology": "Future",
        "Brightness": 2.5,
        "ClockTime": 14.5,
        "GlobalShadows": true,
        "EnvironmentDiffuseScale": 1,
        "EnvironmentSpecularScale": 1,
        "Ambient": [0.27, 0.27, 0.3],
        "OutdoorAmbient": [0.5, 0.5, 0.55]
      },
      "Atmosphere": {
        "$className": "Atmosphere",
        "$properties": { "Density": 0.3, "Offset": 0.25, "Color": [0.78, 0.84, 0.94], "Decay": [0.42, 0.45, 0.55], "Glare": 0.2, "Haze": 1.2 }
      },
      "Sky": { "$className": "Sky" },
      "ColorCorrection": {
        "$className": "ColorCorrectionEffect",
        "$properties": { "Saturation": 0.1, "Contrast": 0.05 }
      },
      "Bloom": {
        "$className": "BloomEffect",
        "$properties": { "Intensity": 0.6, "Size": 24, "Threshold": 1.4 }
      }
    },

    "SoundService": {
      "$properties": { "RespectFilteringEnabled": true }
    }
  }
}
```

Adjust the lighting to `docs/STYLE.md`; chapter 02 has the presets. If a property name is rejected at build time, check it in `reference/creator-docs/.../classes/<Class>.yaml`. A wrong name fails the build loudly, which is what you want.

**Template: `.gitignore`**

```gitignore
# build output
/build/
*.rbxl.lock
*.rbxlx.lock
# packages (restored by wally install)
/Packages/
/ServerPackages/
/DevPackages/
# generated tooling files
sourcemap.json
/.luau-lsp/
roblox.yml
# secrets
.env
*.key
# OS/editor
.DS_Store
Thumbs.db
.vscode/*
!.vscode/settings.json
```

Do **not** ignore `assets/generated/*.rbxm` or `assets/studio/*.rbxm`. They are the content.

**Template: `scripts/check.sh`** (the quality gate)

```bash
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

rokit install --no-trust-check >/dev/null
[ -f wally.toml ] && wally install >/dev/null

echo "== format";  stylua --check src lune tests
echo "== lint";    selene src
echo "== sourcemap"; rojo sourcemap default.project.json -o sourcemap.json --include-non-scripts
[ -d Packages ] && wally-package-types --sourcemap sourcemap.json Packages/ >/dev/null || true
[ -d ServerPackages ] && wally-package-types --sourcemap sourcemap.json ServerPackages/ >/dev/null || true
mkdir -p .luau-lsp
[ -f .luau-lsp/globalTypes.d.luau ] || curl -fsSL -o .luau-lsp/globalTypes.d.luau \
  https://luau-lsp.pages.dev/type-definitions/globalTypes.None.d.luau
echo "== typecheck"
luau-lsp analyze --platform=roblox --sourcemap=sourcemap.json \
  --definitions=@roblox=.luau-lsp/globalTypes.d.luau --base-luaurc=.luaurc --formatter=plain \
  --ignore="**/Packages/**" --ignore="**/ServerPackages/**" --ignore="**/DevPackages/**" src
echo "== build"
mkdir -p build
rojo build default.project.json -o build/game.rbxl
rojo build test.project.json -o build/test.rbxl
echo "== place checks"
lune run scan-place build/game.rbxl
echo "ALL CHECKS PASSED"
```

**Template: `CLAUDE.md`** (per game project)

```markdown
# <Game Name>: bot instructions

Original Roblox game. Knowledge base: ~/Roblox/knowledge (read 00 checklist first).

## Facts
- Genre / core loop: <one sentence>
- Target: mobile-first, ages 9+, session 10–20 min
- Universe IDs: prod <id> (place <id>); test <id> (place <id>)
- Owner: user <id> | group <id>   (assets must be owned by this creator)

## Commands
- Setup: `rokit install && wally install`
- Gate (must pass before commit): `scripts/check.sh`
- Regenerate content: `lune run build-<thing>`, which writes assets/generated/*.rbxm (commit outputs)
- Cloud tests: `lune run cloud-test` (needs ROBLOX_API_KEY, TEST_UNIVERSE_ID, TEST_PLACE_ID)
- Publish prod: only after cloud tests pass on the same commit; see docs/RELEASE in README

## Architecture
- Server bootstrap: src/server/init.server.luau loads Services/* in order
- Client bootstrap: src/client/init.client.luau loads Controllers/*
- Remotes: defined ONLY in src/shared/Net; server validates every argument
- Data: DataService (ProfileStore or equivalent, session-locked); schema + version in docs/SYSTEMS.md
- Config/tuning: src/shared/Config/*; assets in Config/Assets.luau + assets/ASSETS.md

## Rules
- Files are truth; never edit Rojo-managed scripts in Studio
- --!strict everywhere; no globals; no `wait()`/`spawn()` (use task.*)
- Never trust the client; rate-limit remotes; never write prod DataStores from tools
- No third-party IP; no unscanned free models; no secrets in repo
- Keep docs/DESIGN.md, docs/STYLE.md and docs/PLAYTEST.md current
```

**Template: `.vscode/settings.json`** (for humans using VS Code with luau-lsp)

```json
{
  "luau-lsp.platform.type": "roblox",
  "luau-lsp.sourcemap.enabled": true,
  "luau-lsp.sourcemap.autogenerate": true,
  "luau-lsp.sourcemap.rojoProjectFile": "default.project.json",
  "luau-lsp.completion.imports.enabled": true,
  "stylua.targetReleaseVersion": "latest"
}
```

**Template: CI (`.github/workflows/ci.yml`)**

```yaml
name: ci
on: [push, pull_request]
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install Rokit
        run: |
          curl -sSf https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.sh | bash
          echo "$HOME/.rokit/bin" >> "$GITHUB_PATH"
      - name: Toolchain
        env: { GITHUB_TOKEN: "${{ secrets.GITHUB_TOKEN }}" }
        run: |
          rokit authenticate github --token "$GITHUB_TOKEN" || true
          rokit install --no-trust-check
      - run: bash scripts/check.sh
      - name: Cloud tests
        if: github.ref == 'refs/heads/main'
        env:
          ROBLOX_API_KEY: ${{ secrets.ROBLOX_TEST_API_KEY }}
          TEST_UNIVERSE_ID: ${{ vars.TEST_UNIVERSE_ID }}
          TEST_PLACE_ID: ${{ vars.TEST_PLACE_ID }}
        run: lune run cloud-test
```

(Verify the Rokit install path. Check `rokit system-info` output on the runner and adjust the `GITHUB_PATH` line if needed.)

---

## 13. Bootstrapping a new game repo (exact commands)

```bash
mkdir my-game && cd my-game && git init
rokit init
rokit add rojo-rbx/rojo@7.7.1 && rokit add UpliftGames/wally@0.3.2 \
 && rokit add JohnnyMorganz/wally-package-types && rokit add Kampfkarren/selene \
 && rokit add JohnnyMorganz/StyLua stylua && rokit add JohnnyMorganz/luau-lsp \
 && rokit add lune-org/lune
rojo init --kind place --skip-git .   # gives src/{shared,server,client} + default.project.json
# replace default.project.json, add selene.toml, stylua.toml, .luaurc, wally.toml, .gitignore,
# CLAUDE.md, docs/*, lune/*, scripts/check.sh from the templates above
wally install
chmod +x scripts/check.sh && scripts/check.sh
git add -A && git commit -m "Scaffold"
```

---

## 14. End-to-end "build a new game" procedure

Each phase has an **exit artifact**. Don't move on without it.

### Phase 0: Concept (exit: 1-paragraph pitch in `docs/DESIGN.md`)
- Pick a genre with chapter 06. Write the **core loop in one sentence**, the **hook** (what's new), the **target player** and the **session length**.
- Originality check: name, theme and mechanics are not copies of a specific existing game or IP.

### Phase 1: Design doc (exit: `docs/DESIGN.md` complete)
- Fill in chapter 01's template: core loop, progression (first 5 minutes / first hour / day 7), economy sinks and sources, social hooks, monetization plan (chapter 07), content list with counts, and the success metrics (D1 retention, session length).
- List **systems** with responsibilities. List **remotes** with payloads, and who can call them.

### Phase 2: Style spec (exit: `docs/STYLE.md`)
- Palette (5–7 colors with RGB), materials, lighting preset (exact Lighting/Atmosphere values), UI style (corner radius, stroke, font, sizes, scale rules), SFX and music mood, and VFX language. Chapters 02, 03 and 05 cover these.
- Encode the style in the code: lighting in project.json, palette in `Config/Style.luau`, and the same palette in the Lune generators.

### Phase 3: Systems (exit: gate green, systems unit-tested)
- Order: **Data** (load/save/session lock, schema version, migration stub) → **Net** (remotes + validation + rate limits) → **core loop service** → **economy** → **progression** → **UI controllers** → **monetization** (ProcessReceipt idempotent) → **analytics hooks**.
- Write tests alongside: pure logic in Lune, engine-touching code in Jest specs.
- Run `scripts/check.sh` after each system and commit.

### Phase 4: Content (exit: full content list from the design doc exists in the build)
- Generate the map, levels and props with Lune → `.rbxm`. Generate per-session content with runtime builders. Generate terrain from a seed.
- Upload images and audio with the Assets API. Record the IDs in `Config/Assets.luau` and `ASSETS.md`. Wait for moderation to finish.
- Tag and attribute everything; systems should bind to tags.

### Phase 5: Playtest (exit: `docs/PLAYTEST.md` entries, no P0/P1 bugs)
- **Headless**: `lune run cloud-test` (Jest suite + smoke script: data round-trip on a test store, economy invariants, every remote rejects bad input, map integrity).
- **Studio-attached** (if available): via MCP, start play → `character_navigation` through the first-5-minute path → `get_console_output` (no errors or warnings from our code) → `screen_capture` at key spots → device-emulate phone and tablet (ask the human or use the `skill` docs) → stop play.
- **Human**: ask for a 10-minute session, and record their confusion points.
- Log every finding with a severity. Fix all P0 (crash, data loss, exploit, blocked progress) and P1 (major confusion, broken UI on mobile).

### Phase 6: Polish (exit: chapter 05 feel checklist done)
- Juice: SFX on every action, tween feedback, particles on rewards, camera shake (subtle), and music with ducking.
- Onboarding: first 30 seconds teach the loop without text walls; arrows and highlights.
- Performance pass: part counts, streaming, no per-frame allocations in hot loops, MicroProfiler review if Studio is available.
- Lighting and composition review against the screenshots.

### Phase 7: Publish (exit: live version number recorded)
1. `scripts/check.sh` green on the release commit, and the asset check finds no placeholder IDs.
2. Publish to the **test place** (`versionType=Saved`) → cloud tests pass on that version number.
3. Publish to **prod**: `versionType=Published` (or `rojo upload`). If the game contains unions or SurfaceAppearance, the human publishes from Studio.
4. A human completes the Creator Dashboard items the bot can't: the **experience questionnaire / content maturity**, the icon and thumbnails, the description, genre, devices (enable phone/tablet/console as designed), developer products and passes (or create them via Open Cloud with the right scopes), and privacy → public.
5. Tag the git commit with the place version (`git tag v1.0.0-place42`), and post live-ops notes.
6. Post-launch: watch error reports and analytics. Use `publishMessage` for announcements and soft shutdowns.

---

## 15. Definition of Done (a release is done when ALL are true)

- [ ] `scripts/check.sh` passes: format, lint, typecheck (0 errors), both builds, place scan.
- [ ] Cloud test suite passes on the exact place version being released, with > 0 tests discovered.
- [ ] Every system in `docs/SYSTEMS.md` exists, and every remote listed there validates its inputs server-side.
- [ ] Player data: loads, saves on leave and on `BindToClose`, uses session locking, has a schema version, and a new-player default is tested. A test-store round-trip was verified.
- [ ] First 5 minutes playable start→first reward→first upgrade with no errors in the output (client and server).
- [ ] UI works at phone resolution (touch targets ≥ 44 px equivalent, no overlap with the Roblox top bar or thumbstick, readable text) and on desktop.
- [ ] All assets are owned by the game creator, moderated and listed in `ASSETS.md`. No placeholder IDs, no third-party IP, no unscanned free-model scripts.
- [ ] Monetization (if any): ProcessReceipt is idempotent and grants exactly once; products and passes are configured; nothing pay-to-win that violates policy; no paid random items without disclosed odds (chapter 07).
- [ ] Performance: server heartbeat stable at 60 with the target max players (when testable), part and instance counts within budget, StreamingEnabled decided deliberately.
- [ ] `docs/DESIGN.md`, `STYLE.md`, `SYSTEMS.md` and `PLAYTEST.md` match what shipped.
- [ ] Release commit tagged with the place version number.

---

## 16. Self-review checklist (run before every publish)

**Security**
- [ ] Server-authoritative state: the client never sends amounts, prices, damage, positions-as-truth or "I won".
- [ ] Every RemoteEvent/RemoteFunction handler type-checks arguments (`typeof`), clamps numbers, checks NaN/inf, checks string length, and rate-limits per player.
- [ ] No server→client `RemoteFunction:InvokeClient` without a timeout path. No client-trusted cooldowns.
- [ ] No `loadstring`, no `require(<assetId>)`, no `getfenv/setfenv`. `HttpService` is only used for intended endpoints, and no secrets are in place files.
- [ ] Server-only modules live in `ServerScriptService`/`ServerStorage`, not in `ReplicatedStorage`.
- [ ] Admin or debug commands are gated by user ID / group rank on the server, and are disabled in prod builds.

**Data safety**
- [ ] Session locking (ProfileStore or equivalent). There is no case where two servers can write the same key.
- [ ] Saves are retried with backoff and respect DataStore budgets. `BindToClose` waits for pending saves.
- [ ] A schema version and migration function exist. Unknown future fields are preserved, not wiped.
- [ ] No tool, test or Open Cloud script writes production data stores. Tests use a separate universe or store names.
- [ ] Currency changes go through one service with logged sources and sinks. There are no negative balances.

**Mobile and accessibility**
- [ ] UI uses Scale + `UIAspectRatioConstraint`/`UISizeConstraint`, and respects `GuiService:GetGuiInset()` and safe areas.
- [ ] Every action is reachable by touch (ContextActionService buttons or on-screen UI), not only by key binds.
- [ ] Text is ≥ 14 px at phone size, contrast is adequate, and the game doesn't rely on color alone.
- [ ] Gamepad navigation works where the console is enabled.

**Performance**
- [ ] No per-frame `Instance.new` in hot paths, and no unbounded tables (per-player tables are cleaned on `PlayerRemoving`).
- [ ] Connections are disconnected (Trove/Maid), and no `while true do wait()` loops.
- [ ] Static parts are anchored. Decorative parts have collision and query disabled. Instance counts are within budget.
- [ ] Remote traffic is bounded (no per-frame `FireAllClients` with big payloads).
- [ ] Sounds and particles are pooled or limited, with no runaway emitters.

**Policy and community standards**
- [ ] Content fits the declared maturity questionnaire answers. No real-world gambling mechanics. Paid random items disclose their odds.
- [ ] No external links or off-platform contact prompts. All user-generated text displayed to others is filtered (`TextService:FilterStringAsync`).
- [ ] No impersonation of Roblox or other brands. No misleading thumbnails or descriptions. No forced social pressure for Robux.
- [ ] No third-party IP in names, art, audio or mechanics marketed as another game.
- [ ] Ads and rewarded features follow the current Roblox policies (chapter 07).

---

## 17. Troubleshooting quick reference

| Symptom | Likely cause / fix |
|---|---|
| `rojo build` error "property X not found / wrong type" | Misspelled property, or an ambiguous value. Use the explicit form `{"Vector3":[...]}`. Check the class YAML. |
| Script runs on the wrong side | Check the suffix (`.server`/`.client`) and `emitLegacyScripts`. With `false`, client scripts are `Script` + `RunContext=Client` and run wherever they're parented. Keep them under StarterPlayerScripts. |
| luau-lsp: "unknown require" | Stale sourcemap. Rerun `rojo sourcemap`. For packages, rerun `wally-package-types`. |
| luau-lsp: `game`/`Instance` unknown | Missing `--definitions=@roblox=...` or `--platform=roblox`. |
| selene: "`game` is not defined" | `std = "roblox"` missing from `selene.toml`. |
| Publish API 403 | Key lacks `universe-places` write on that universe, or an IP restriction applies. |
| Publish OK but unions/meshes missing | API limitation (§9.2). Publish from Studio. |
| Luau Execution FAILED "timeout" | Raise `timeout`, or split the suite. Make sure nothing yields forever (e.g. `WaitForChild` on a player-only instance). |
| Image renders blank | Still in moderation, rejected, a Decal ID used instead of an Image ID, or the asset is not owned by or shared with the game. |
| Animation won't play | Animation not owned by the game's creator (user vs group mismatch). |
| `rojo serve` overwrote Studio work | Expected. Files are the truth. Recover via Studio's File → version history, then `syncback` to files. |

---

## Sources

Local (verified):
- Rojo 7.7.1 source: `.sources/rojo-rbx_rojo/src/cli/{build,serve,sourcemap,syncback,upload,init}.rs`, `src/project.rs`, `src/snapshot_middleware/{mod,dir,json_model,meta_file,lua,util}.rs`, `src/rojo_ref.rs`, `assets/project-templates/place/default.project.json`, `test-projects/{tags,attributes,terrain}`, `CHANGELOG.md`
- Wally: `.sources/UpliftGames_wally/README.md`, `src/commands/`
- luau-lsp 1.70.1: `.sources/JohnnyMorganz_luau-lsp/README.md`, `src/main.cpp`, `src/AnalyzeCli.cpp`, `editors/code/src/roblox.ts`, `CHANGELOG.md`
- selene 0.32.0: `.sources/Kampfkarren_selene/docs/src/roblox.md`, `CHANGELOG.md`
- StyLua 2.6.0: `.sources/JohnnyMorganz_StyLua/README.md`
- Lune 0.11.1: `.sources/lune-org_lune/crates/lune-std-roblox/{src/lib.rs,types.d.luau}`, `crates/lune-roblox/src/lib.rs`, `crates/lune-std-{fs,net,serde,process}/types.d.luau`, `crates/lune/src/cli/`, `CHANGELOG.md`
- Rokit 1.2.0: `.sources/rojo-rbx_rokit/README.md`, `src/cli/`
- Roblox Creator Docs (`.sources/Roblox_creator-docs/content/en-us/`): `studio/mcp.md`, `studio/mcp-open-cloud.md`, `studio/cli.md`, `cloud/guides/usage-place-publishing.md`, `cloud/guides/usage-assets.md`, `cloud/guides/usage-messaging.md`, `cloud/reference/rate-limits.md`, `cloud/auth/api-keys.md`, `reference/cloud/openapi.json` (Luau Execution, DataStores v2, Assets, Messaging paths and schemas)
- Release tags via `git ls-remote`: wally v0.3.2, darklua v0.19.0, wally-package-types v1.7.0, pesde v0.7.4

Web (treated as data):
- Jest Roblox: https://github.com/Roblox/jest-roblox
- darklua docs: https://darklua.com/docs/rules/convert_require and https://darklua.com/docs/roblox-require-mode/
- pesde: https://docs.rs/crate/pesde/latest , https://github.com/pesde-pkg/pesde
- Luau Execution beta thread (Jest via Open Cloud context): https://devforum.roblox.com/t/beta-open-cloud-engine-api-for-executing-luau/3172185
- Open Cloud test-runner CLIs (community): https://socket.dev/npm/package/%40isentinel%2Fjest-roblox
