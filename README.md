# Roblox Game-Making Knowledge Base

A reference library for an AI coding agent (Claude Code) that designs and builds original Roblox
games. Start with [`CLAUDE.md`](CLAUDE.md), then [`knowledge/00-master-checklist.md`](knowledge/00-master-checklist.md).

## Install as a Claude skill

**Claude Code (recommended, includes the full reference library):**
```
/plugin marketplace add AntB08/Roblox
/plugin install roblox-game-dev@antb08-roblox
```
Claude then uses the `roblox-game-dev` skill automatically whenever you work on a Roblox game.

**claude.ai / Claude desktop app:** upload `dist/roblox-game-dev.skill` (or a zip of
`skills/roblox-game-dev/`) under Settings → Capabilities → Skills. That version carries the 21
guides, the starter project and the API index; for the full docs it uses Roblox's live docs.

Rebuild the skill after editing guides: `scripts/build_skill.sh`.

## Contents

| Folder | What it is |
|---|---|
| `knowledge/` | 20 guides + master checklist (~245k words): design, visuals, UI, Luau, feel/VFX/audio, genres, monetization/policy, toolchain, 3D art, level design, gameplay systems, QA/performance/analytics, live ops, production, platform changes & deprecations, DevForum critique/scripting fixes/game design, outside tools (Blender, 2D, audio), video lessons & plugins. |
| `templates/starter-game/` | Rojo starter project every new game copies (data, purchases, remotes, UI/FX, one complete vertical slice). |
| `reference/creator-docs/` | Text mirror of the official Roblox Creator Docs incl. the full engine API reference (CC-BY-4.0, © Roblox). |
| `reference/luau/` | Luau language docs and RFCs. |
| `reference/api/` | Engine API dump and Luau type definitions (from Roblox-Client-Tracker). |
| `reference/libraries/` | Source + docs of open-source libraries and tools: ProfileStore, RbxUtil (Trove, Signal…), Promise, Fusion, Vide, React-lua, jecs, Blink, Nevermore, Rojo, Rokit, Wally, selene, StyLua, luau-lsp, Lune, Jest-Roblox, TestEZ. Each keeps its own license. |
| `reference/example-games/` | Open-source (licensed) example game codebases (incl. Vesteria MMORPG, Slither, Chickynoid). |
| `reference/creator-docs-live/` | Live-only doc pages, Roblox's official deprecated-API inventory, weekly release notes. |
| `reference/tools/blender-manual/` | Official Blender manual source (CC-BY-SA 4.0). |
| `reference/video-library/` | Catalog of 1,141 YouTube videos across ~100 Roblox/tool topics (metadata + links). |
| `reference/devforum-index/` | Titles, likes and links for ~26k most-liked DevForum threads. |
| `scripts/kb_search.sh` | Search guides and references. |
| `scripts/fetch_sources.sh` | Download the full upstream repos (~2 GB) into `.sources/` (gitignored). |
| `scripts/check_guide_code.py` | Syntax-check every Luau code block in the guides with `luau-compile`. |
| `scripts/check_guide_api.py` | Check classes, services, enums and deprecated members in guide code against the API dump. |
| `scripts/fetch_devforum.py` | Build the local DevForum mirror (~26k threads, kept local/gitignored). |
| `scripts/youtube_catalog.py` / `fetch_youtube_transcripts.py` | Rebuild the video catalog; download transcripts (run at home). |

Snapshot date: 2026-11-05. Two example Slack webhook URLs in the docs mirror were replaced with
`REDACTED_EXAMPLE` to satisfy GitHub secret scanning.
