# Roblox Game-Making Knowledge Base — instructions for the bot

You are building ORIGINAL Roblox games. This repo is your reference library. Do not
load everything into context — read the guide for the task at hand, then search the
raw reference for exact APIs.

## Read first, every new game
1. `knowledge/00-master-checklist.md` — the short rules and the build procedure.
2. `knowledge/01-game-design-and-success.md` — what makes games succeed; fill in its design-doc template.
3. `knowledge/06-genre-playbooks.md` — the section for the chosen genre.

## Read when the task touches it
| Task | Guide |
|---|---|
| Lighting, building, terrain, art style, "make it look good" | `knowledge/02-visual-design-lighting-building.md` |
| Menus, HUD, shop, mobile layout | `knowledge/03-ui-ux-design.md` |
| Any Luau code, data saving, remotes, security, performance | `knowledge/04-luau-engineering.md` |
| Effects, sound, music, animation, camera, "make it feel good" | `knowledge/05-game-feel-vfx-audio-animation.md` |
| Robux products, economy, policy/age rating, publishing, marketing | `knowledge/07-monetization-policy-launch.md` |
| Rojo/Lune/Wally/Open Cloud setup, project template, testing | `knowledge/08-bot-toolchain-and-workflow.md` |
| Meshes, Blender, textures, characters/rigs, free-model safety | `knowledge/09-3d-art-assets-and-characters.md` |
| Map layout, obby stages, hubs, quests, dialogue, NPC AI/pathfinding | `knowledge/10-level-design-world-narrative.md` |
| Combat, hitboxes, projectiles, vehicles, physics, rounds/matchmaking, input | `knowledge/11-multiplayer-physics-combat-systems.md` |
| Testing, CI, playtests, MicroProfiler, performance budgets, analytics events | `knowledge/12-testing-qa-performance-analytics.md` |
| Updates, events, daily rewards, codes, admin tools, community, translation, accessibility | `knowledge/13-liveops-community-localization-accessibility.md` |
| Coming up with ideas, scoping an MVP, milestones, docs templates, postmortems | `knowledge/14-production-scope-and-idea-generation.md` |

## Look up exact facts (never guess an API)
```bash
scripts/kb_search.sh "TweenInfo" api        # class/property/enum reference (official YAML + API dump)
scripts/kb_search.sh "session lock" docs    # official Creator Docs (CC-BY-4.0 mirror)
scripts/kb_search.sh "type function" luau   # Luau language docs + RFCs
scripts/kb_search.sh "Trove" libs           # open-source library source code
scripts/kb_search.sh "ProfileStore" examples
```
- Engine reference: `reference/creator-docs/content/en-us/reference/engine/classes/<Class>.yaml`
- Full API dump (every member, tags like Deprecated): `reference/api/API-Dump.txt`
- Luau type definitions for the engine: `reference/api/LuauTypes.d.luau`
- Docs snapshot date: 2026-11-05. If something may have changed since, check the live docs.

## Non-negotiables
- Server is authoritative. Validate every RemoteEvent argument on the server; never trust the client.
- Save data with session locking (ProfileStore), and make `ProcessReceipt` idempotent.
- Design for phones first (most players are on mobile): touch targets, safe areas, low-end performance.
- Filter all user-written text shown to other players. Follow Roblox Community Standards; fill out the maturity questionnaire honestly; show odds for paid random items.
- Original work only: no copied names, art, music, or levels from existing games.
- User preferences: native editable GUI instances (not whole menus flattened into images);
  instrumental music that loops seamlessly; no vocal/choir/humming by default; non-vocal SFX.
- Verify by playing: syntax checks and self-written tests don't prove a game is fun or looks good.
