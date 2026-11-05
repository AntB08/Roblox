# Roblox Game-Making Knowledge Base

A reference library for an AI coding agent (Claude Code) that designs and builds original Roblox
games. Start with [`CLAUDE.md`](CLAUDE.md), then [`knowledge/00-master-checklist.md`](knowledge/00-master-checklist.md).

## Contents

| Folder | What it is |
|---|---|
| `knowledge/` | 14 guides (~150k words) written for the bot: design, visuals, UI, Luau, feel/VFX/audio, genres, monetization/policy, toolchain, 3D art, level design, gameplay systems, QA/performance/analytics, live ops, production. |
| `reference/creator-docs/` | Text mirror of the official Roblox Creator Docs incl. the full engine API reference (CC-BY-4.0, © Roblox). |
| `reference/luau/` | Luau language docs and RFCs. |
| `reference/api/` | Engine API dump and Luau type definitions (from Roblox-Client-Tracker). |
| `reference/libraries/` | Source + docs of open-source libraries and tools: ProfileStore, RbxUtil (Trove, Signal…), Promise, Fusion, Vide, React-lua, jecs, Blink, Nevermore, Rojo, Rokit, Wally, selene, StyLua, luau-lsp, Lune, Jest-Roblox, TestEZ. Each keeps its own license. |
| `reference/example-games/` | Open-source (licensed) example game codebases. |
| `scripts/kb_search.sh` | Search guides and references. |
| `scripts/fetch_sources.sh` | Download the full upstream repos (~2 GB) into `.sources/` (gitignored). |
| `scripts/check_guide_code.py` | Syntax-check every Luau code block in the guides with `luau-compile`. |

Snapshot date: 2026-11-05. Two example Slack webhook URLs in the docs mirror were replaced with
`REDACTED_EXAMPLE` to satisfy GitHub secret scanning.
