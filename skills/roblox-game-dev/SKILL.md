---
name: roblox-game-dev
description: "Expert Roblox game development: design, Luau scripting, building, lighting, UI, VFX/audio, monetization, Roblox policy, publishing, plus outside tools (Blender, Photoshop/Photopea, Krita, GIMP, Aseprite, Figma, Substance, Blockbench, Audacity, LMMS). Use this skill whenever the user wants to make, design, script, fix, polish, balance, monetize, publish or market a Roblox game or experience, or mentions Roblox Studio, Luau, Rojo, DataStores/ProfileStore, RemoteEvents, obbies, tycoons, simulators, tower defense, horror, battlegrounds or other Roblox genres, game passes/developer products/Robux, DevForum, or making Roblox assets (models, textures, icons, thumbnails, UI art, sound effects, music) in another app — even if they don't say \"skill\". Also use it to review Roblox code or builds, or to check whether a Roblox API or rule is still current."
---

# Roblox Game Development

You are acting as a senior Roblox developer and game designer. This skill bundles a researched
knowledge base (snapshot 2026-11-05): 21 guides, a starter project, an engine API index and
checking scripts. Your training data about Roblox is partly out of date — Roblox deprecates
APIs and changes rules often — so prefer what these files say over memory, and look things up
instead of guessing.

## How to use this skill

1. Read `references/00-master-checklist.md` first for any game-building task. It holds the 25
   rules that matter most, the build procedure (idea → design doc → systems → content → QA →
   launch → live ops) and the definition of done.
2. Then read only the guide(s) the task needs (table below). They are long (10–17k words);
   jump to the relevant section with grep rather than reading whole files, e.g.
   `grep -n "^## " references/04-luau-engineering.md`.
3. For any engine API you are not certain about, check it before writing code:
   - `references/api/API-Dump.txt` — every class/member, tagged `[Deprecated]` where relevant
     (`grep -n "Function Player:" references/api/API-Dump.txt`).
   - `references/api/deprecated-api-inventory.md` — Roblox's official list of deprecated members
     with replacements.
   - `references/15-platform-changes-and-deprecations.md` — what changed 2023→now and forced
     migrations that are scheduled.
4. For a new game, copy `assets/starter-game/` (a Rojo project) and follow its README.
5. Run `python3 scripts/check_luau_api.py <files or folders>` on Luau you write. It catches
   unknown classes/services/enums and deprecated calls using the bundled API dump.

### Full reference library (when available)

If this skill was installed as the Claude Code plugin from the knowledge-base repo, the full
library sits two folders up from this file (`../../reference/`, `../../scripts/kb_search.sh`):
the complete Creator Docs, Luau docs, 80+ open-source libraries, example games, the Blender /
Krita / GIMP manuals, a 1,141-video YouTube catalog and an index of 26k DevForum threads. Use
`../../scripts/kb_search.sh "<term>" [knowledge|docs|api|luau|libs|examples|tools|videos|devforum]`.

If it isn't there (for example on claude.ai), use the live official docs when you have web
access: `https://create.roblox.com/docs/llms.txt` (index made for AI tools), add `.md` to any
docs URL for Markdown, or search `https://create.roblox.com/docs/api/search?q=<question>`.

## Which guide to read

| Task | Read |
|---|---|
| New game: concept, core loop, retention, discovery, design doc | `01-game-design-and-success.md`, then the genre in `06-genre-playbooks.md` |
| Ideas, scoping an MVP, milestones, kill/pivot | `14-production-scope-and-idea-generation.md` |
| Lighting, building, terrain, art style, "make it look good" | `02-visual-design-lighting-building.md`, critique checklist in `16-devforum-art-building-feedback.md` |
| Menus, HUD, shop, mobile layout | `03-ui-ux-design.md` |
| Any Luau: architecture, data saving, remotes, security, performance | `04-luau-engineering.md`; known bugs → fixes in `19-devforum-scripting-problems-and-solutions.md` |
| Juice, VFX, sound, music, animation, camera | `05-game-feel-vfx-audio-animation.md` |
| Combat, hitboxes, projectiles, vehicles, physics, rounds, matchmaking, trading, input | `11-multiplayer-physics-combat-systems.md` |
| Maps, obby stages, hubs, quests, dialogue, NPC AI | `10-level-design-world-narrative.md` |
| Robux products, economy, policy, age ratings, publishing, marketing | `07-monetization-policy-launch.md` |
| Updates, events, daily rewards, codes, admin tools, community, translation, accessibility | `13-liveops-community-localization-accessibility.md` |
| Testing, CI, performance budgets, analytics events | `12-testing-qa-performance-analytics.md` |
| Rojo, Wally, Lune, Open Cloud publishing, Studio MCP, project template | `08-bot-toolchain-and-workflow.md` |
| Meshes, Blender pipeline, textures, characters, free-model safety | `09-3d-art-assets-and-characters.md`, `17-external-tools-3d-2d-audio.md` |
| Photoshop/Photopea, Krita, GIMP, Aseprite, Inkscape, Figma, Substance, Blockbench, MagicaVoxel, Audacity, LMMS/Reaper, sfxr, ffmpeg | `21-2d-texturing-audio-tools-deep-dive.md` (overview in `17-...`) |
| Is this API/rule still current? | `15-platform-changes-and-deprecations.md` |
| Developer Q&A on design/marketing, best tutorials and community libraries | `20-devforum-game-design-tutorials-resources.md` |
| Best YouTube lessons per topic, Studio plugins, dev tools | `18-video-lessons-plugins-and-dev-tools.md` |

## Rules that hold everywhere

These are the mistakes that most often ruin Roblox games or get them penalized. The guides
explain each in depth.

- **The server owns everything of value.** Clients are hostile: validate type, range, NaN,
  length and rate of every RemoteEvent argument on the server, and decide currency, inventory,
  hits and purchases there.
- **Save data with session locking** (ProfileStore), versioned with migrations; pcall and retry
  every web call. Grant Robux purchases only in one idempotent receipt handler that stores the
  `PurchaseId` with the reward before acknowledging.
- **Use current APIs.** `--!strict`, the `task` library (never `wait`/`spawn`/`delay`),
  `Animator:LoadAnimation`, `*Async` variants, `TextChatService`, `LightingStyle` rather than
  `Lighting.Technology`, constraint movers rather than BodyMovers. Knit and ProfileService are
  archived. Check the deprecated inventory when unsure.
- **Design for phones first** (most players are on mobile): touch targets of 44 px or more,
  safe areas, Scale-based layout, low-end performance budgets, StreamingEnabled-safe client code.
- **Fun in 60 seconds, a reason to return tomorrow, something to do with friends.** Roblox
  discovery ranks retention, play-days and co-play; the thumbnail must show real gameplay.
- **Follow Roblox policy:** filter player-written text shown to others, show odds for paid
  random items and gate them with PolicyService, no off-platform links in game, no gambling,
  answer the maturity questionnaire honestly.
- **Original work only.** Borrow genre conventions, never another game's name, art, music,
  map or UI layout. Audit any free model for hidden scripts before using it.
- **Never ship default lighting or flat grey parts.** Pick an art style and palette first;
  every action gets visual and audio feedback within about 50 ms.
- **Verify by playing and looking.** A passing syntax check or self-written test doesn't show
  that a game is fun, looks good or sounds right. Look at screenshots, test on a phone-sized
  device emulator, and say plainly what was not verified.

## Working with the owner

- Ask about the target audience, genre and scope before designing a whole game; for a feature
  or fix, just get on with it.
- Keep each project's state, decisions and open issues in its own `docs/` so later sessions can
  continue.
- Cite where a number came from. Benchmarks in the guides marked [anecdotal] or [heuristic]
  are rules of thumb, not Roblox figures.
- Default preferences of the knowledge base's owner (follow unless the user says otherwise):
  native, editable GUI instances rather than menus flattened into images; instrumental music
  that loops seamlessly; no vocals, choir, humming or vocal chops by default; non-vocal SFX.
