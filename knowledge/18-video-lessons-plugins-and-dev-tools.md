# 18 — Video Lessons, Studio Plugins and Dev Tools (as of 2026-11-05)

This chapter has two parts.

- **Part A: the best video lessons, summarized.** For each Roblox development topic it picks the 3–8 most useful videos from the local catalog (`reference/video-library/catalog.json`, 1,141 YouTube results). Each entry gives what the video teaches, what the bot should take from it, and any caveats (especially deprecated APIs).
- **Part B: Studio plugins and external dev tools.** It covers what each one does, its price, when to use it, its risks and current status, and the best thread or video for learning it.

> **How the summaries were made (read this first).** YouTube watch pages and caption endpoints can't be reached from the bot's environment because of the bot check, so **no transcript was read**. Each summary comes from the catalog metadata (title, channel, views, length, age, description snippet), the chapter lists in descriptions, companion DevForum threads, the local DevForum mirror (`.sources/devforum/`), and web searches. Where a summary goes beyond what the metadata shows, it is marked *(inferred)*. Before relying on a specific claim about a video, the owner can run `scripts/fetch_youtube_transcripts.py` on a home connection to get transcripts and then check this chapter against them. Ages ("1y ago") are relative to when the catalog was collected (autumn 2026). View counts measure popularity, not quality.

Related chapters: toolchain setup is in [08](08-bot-toolchain-and-workflow.md) (not repeated here); API deprecations are in [15](15-platform-changes-and-deprecations.md); topic depth is in 01 (design), 02 (visuals/lighting), 03 (UI), 04 (Luau), 05 (feel/VFX/audio/animation), 06 (genres), 10 (level design), 11 (multiplayer/combat), and 12 (testing). Blender, 2D art and audio-tool videos are out of scope here; see chapter 17 if present, and chapter 09.

---

## TL;DR rules for the bot

1. **Treat videos as idea sources, not code sources.** Never paste tutorial code. Rewrite it with current APIs, `--!strict` types, server authority and the project's own architecture (chapters 04, 11).
2. **Put every tutorial older than about 18 months through the deprecation filter** (§A0) before borrowing anything. The usual offenders are `wait()`/`spawn()`/`delay()`, `Humanoid:LoadAnimation`, `BodyVelocity`/`BodyGyro`/`BodyPosition`, `FindPartOnRay`, `SetPrimaryPartCFrame`, `TweenPosition`, `Lighting.Technology`, `Mouse`, ProfileService (ProfileStore replaced it), and legacy `Chat`.
3. **For player data, follow the ProfileStore videos** (Rileybytes, MonzterDEV), not the raw-DataStore or ProfileService ones. Also follow the rule from chapter 15: read values before the first yield in `PlayerRemoving`.
4. **For security, take the principle from GnomeCode and ByteBlox: the server validates everything, and client anti-cheats are speed bumps.** Ignore "free anti-cheat" shorts and any video that shows an executor.
5. **For combat, guns and NPCs, borrow the structure** (state machine, server hitbox validation, cooldowns, knockback via constraints) and leave the code. The highest-view combat tutorials are beginner-level and client-trusting.
6. **For lighting, use the modern properties**: `Lighting.LightingStyle` + `PrioritizeLightingQuality`, `Atmosphere`, `ColorGradingEffect`. Treat "set Technology to Future" as stale wording.
7. **For UI, use Scale + `UIAspectRatioConstraint` + `UIStroke` + `UICorner`, plus TweenService or springs.** Kek, Develuper and ByteBlox teach the visual craft. Leif's React-Luau video teaches the architecture.
8. **For game feel, the canon is old and still correct**: *Juice it or lose it*, *The Art of Screenshake*, GMTK's *Secrets of Game Feel*. Apply them through chapter 05's Roblox recipes.
9. **For design and economy, prefer GDC, GMTK and Extra Credits fundamentals over "go viral" Roblox YouTube.** Use the Roblox-specific creators (AlvinBlox, Zyonic, waveshine, rasdev, Roblox Creators) for platform facts, and check those facts against chapter 15 §1 (discovery changed again in October 2026).
10. **Plugins are code that runs with your Studio permissions.** Install only from the Creator Store, from the original, identifiable creator (check the creator name and the DevForum thread link), and never from "free download" sites (many *pages.dev* SEO pages offer backdoored "free Moon Animator / F3X" copies). Deny script-injection permission unless the plugin needs it.
11. **Use what Studio now has built in before reaching for a plugin.** Studio has a Tag Editor, Align Tool, Pivot Editor, Next-Gen Draggers (beta), **Studio Script Sync (full release 2026-06-17)**, the Universal Importer, Material Generator, Assistant and the built-in **Studio MCP server** (with the Playtest Agent beta and Open Cloud access since 2026-11-04).
12. **The bot's own pipeline stays file-based** (Rojo + luau-lsp + selene + StyLua + Lune + Open Cloud; chapter 08). Script Sync, Argon and Azul are for human collaborators who live in Studio; don't mix two sync tools on one place.
13. **Use Asphalt (2.x, maintained) for assets, not Tarmac** (last release 0.7.0 in 2020). Use **Lune, not Remodel** (deprecated). Treat **Mantle** as unmaintained: script deploys with Open Cloud yourself.
14. **Use the built-in Studio MCP.** `Roblox/studio-rust-mcp-server` is no longer developed, and `boshyxd/robloxstudio-mcp` was archived on 2026-06-06 (its maintained fork is `Chrrxs/robloxstudio-mcp`).
15. **Never hand an owner a plugin or tool recommendation without its current status.** Many famous plugins are archived, deprecated or superseded: Kronos, Hidden Infection Script Detector, Roundify, Beautiful Roads, the RTGI plugin, Reclass classic.

---

## A0. The deprecation filter for old tutorials

Most Roblox tutorials with high view counts are 2–6 years old. They still teach good *ideas* with *stale code*. When a video shows the left column, write the right column (full table in chapter 15 §2.2).

| If the video uses… | Write instead | Typical videos affected |
|---|---|---|
| `wait()`, `spawn()`, `delay()` | `task.wait()`, `task.spawn()`, `task.delay()` | almost everything before 2022; round systems, tycoons, obbies |
| `Humanoid:LoadAnimation()` | `Animator:LoadAnimation()` (Animator under the Humanoid) | older combat and ability tutorials |
| `BodyVelocity`, `BodyPosition`, `BodyGyro`, `BodyForce` | `LinearVelocity`, `AlignPosition`, `AlignOrientation`, `VectorForce` | knockback, dashes, pet-follow, hover cars |
| `workspace:FindPartOnRay(Ray.new(...))` | `workspace:Raycast(origin, dir, params)` with `ExcludeInstances`/`IncludeInstances` (2026-04) | guns, placement, NPC sight |
| `Region3` + `FindPartsInRegion3` | `GetPartBoundsInBox` / `GetPartsInPart` + `OverlapParams` | hitboxes |
| `Model:SetPrimaryPartCFrame()` | `Model:PivotTo()` / `GetPivot()` | placement systems, tycoon droppers |
| `GuiObject:TweenPosition/TweenSize` | `TweenService:Create()` or UI Styling | UI animation |
| `Player:GetMouse()`, `Mouse.KeyDown` | Input Action System (IAS) or `UserInputService`, `Camera:ViewportPointToRay` | guns, placement, building |
| `ContextActionService` for new controls | **IAS** (`InputContext`/`InputAction`/`InputBinding`, full release 2026-06-11) | combat, vehicles |
| `Lighting.Technology = Future` | `Lighting.LightingStyle` + `PrioritizeLightingQuality` | lighting tutorials before 2025 |
| `Sound` with `Pitch`/`MaxDistance` | `PlaybackSpeed`/`RollOffMaxDistance`, or the Audio API (`AudioPlayer` → `AudioEmitter`, `Wire`) | audio |
| `AudioPlayer.AssetId` | `AudioPlayer.Asset` / `AudioContent` | 2024 Audio API videos |
| ProfileService | ProfileStore (DevForum [3190543](https://devforum.roblox.com/t/3190543), 2024-10) | data tutorials from 2021–2024 |
| Legacy `Chat`, custom chat that reads messages | `TextChatService` | admin and chat tutorials |
| `game.Players.PlayerAdded` without handling players already in the server | loop `Players:GetPlayers()` too | most beginner scripts |
| `PlayerRemoving` save that yields before reading the Player | read every value first (`PlayerCharacterDestroyBehavior` default from 2026-11-11) | all data tutorials |
| Hard-coded `Motor6D` names / `Character.Torso.Neck` | `FindFirstChild(name, true)`; the Avatar Joint Upgrade swaps Motor6Ds for `AnimationConstraint`s | camera sway, look-at, ragdoll |

Other red flags in a tutorial:
- `RemoteEvent` handlers that trust a client-sent damage, price or position.
- "Put this LocalScript in StarterPlayerScripts and it's secure".
- `require(assetId)` of a third-party module (the Creator Store sandbox blocks this).
- Free models from the Toolbox "to save time".

---

## A1. Game design and success on Roblox

### Top picks

**1. [Here's Why Roblox Games Blow Up](https://www.youtube.com/watch?v=Y93DRfB-Deo)** — AlvinBlox · 11:01 · 1y · 287k views
- **What it teaches:** AlvinBlox is a long-running Roblox educator. The video breaks down the shared traits of games that break out. *(Inferred from the title, description and his related videos:)* a simple, readable hook; a fast early reward loop; social and shareable moments; thumbnails and icons that state the fantasy; and timing on trends.
- **Bot takeaway:** use it as a checklist when you write a game's one-sentence pitch and its first-five-minutes plan (chapter 01).
- **Caveat:** "trend-chasing" advice conflicts with this KB's rule to make *original* games. Take the structural lessons (hook, loop, social), not "copy the current meme genre". Since 2026, copycat titles, thumbnails and placefiles are deprioritized by discovery (chapter 15, rule 22).

**2. [How To Make A Popular Roblox Game](https://www.youtube.com/watch?v=Le4QhC3dDGk)** — AlvinBlox · 11:16 · 1y · 501k views
- **What it teaches:** a broad tips video on scoping small, polishing the core loop, testing with real players, iterating on stats, and marketing.
- **Bot takeaway:** it reinforces chapter 14 (scope) and chapter 12 (analytics).
- **Pair with:** [Avoid These 5 Roblox Dev Mistakes (They Cost Me Thousands)](https://www.youtube.com/watch?v=f63stwpsaXw) (8:32, 181k), which covers costly mistakes. *(Inferred:)* overscoping, spending ad money before retention is good, ignoring mobile, weak onboarding, and building without testing.

**3. [I Made a Successful Roblox Game to Prove It's Not Luck](https://www.youtube.com/watch?v=RIWPfMJyVhQ)** — Zyonic · 8:01 · 1mo · 399k views
- **What it teaches:** a recent, first-person case study covering the development process, advertising, and what the stats did. The companion video is [How I made a FRONT PAGE game in 30 Days!](https://www.youtube.com/watch?v=4-ge-E9WvM4) (8:38, 10mo).
- **Bot takeaway:** these are the most *current* of the success stories (late 2026), so they reflect the 2026 algorithm. Note the order: prototype quickly, test with ads or small promotion, look at retention, then scale. Treat the specific numbers as anecdotes.

**4. [Watch this before making ROBLOX Games](https://www.youtube.com/watch?v=xnlaYLnCtFc)** — waveshine · 10:03 · 1y · 557k views
- **What it teaches:** a realistic account of the developer journey: most games fail, you need many attempts, and you should keep motivation through small projects.
- **Bot takeaway:** set honest expectations with the owner (chapter 14). Plan a portfolio of small, fast-to-ship games rather than one giant project.
- **Related from the same creator:** [There's so much money to be made from Roblox](https://www.youtube.com/watch?v=hQ1lrFLEF1c) (12:51, 3mo), about misconceptions and the advice he wishes he'd learned sooner.

**5. [RDC 22: Creating an Intriguing First Time User Experience](https://www.youtube.com/watch?v=TZ14iO23Bpk)** — Onett (Bee Swarm Simulator) · 27:37 · 4y · 407k views
- **What it teaches:** Onett (Piercen Harbut), solo creator of Bee Swarm Simulator, explains how the opening builds *intrigue* rather than front-loading tutorials. New players see mysterious, higher-tier things early (locked areas, big bees, NPCs with quests), which creates questions that pull them forward. Teaching is spread out through quests.
- **Bot takeaway:** design the first five minutes so players *see* aspirational content within 30 seconds, get a reward within the first minute, and receive one clear next goal at all times. Never open with a wall of text.
- **Caveat:** none on APIs. It is the best design talk in this section and has aged well.

**6. Roblox Creators official shorts**
- [What are onboarding techniques on Roblox?](https://www.youtube.com/watch?v=dXqZC4x2Vn8) (2:49, 2y)
- [Onboarding Essentials](https://www.youtube.com/watch?v=XfxbdKtSbOI) (12:12, 3y)
- [What are retention metrics on Roblox?](https://www.youtube.com/watch?v=LpAU6TheAZ4) (2:54, 3y)
- [How the "Recommended for You" algorithm works on Roblox](https://www.youtube.com/watch?v=K7jsk3bzmvE) (1:37, 4mo)

These are short, official explanations. The FTUE video stresses that on Roblox "a big part of the fun is playing with others", so onboarding should get players into social play quickly. The recommendation short is the newest official word.
- **Bot takeaway:** use the official framing of D1/D7/D30 retention, session length, and an onboarding funnel. Instrument it with `AnalyticsService` funnel events (chapter 12).

**7. Algorithm deep dives (community)**
- [The New Rules of the Algorithm (2026)](https://www.youtube.com/watch?v=RC19PKdRt1Y) — rasdev · 8:16 · 13d · 83k
- [The Most Valuable Roblox Algorithm Video You'll Ever Watch](https://www.youtube.com/watch?v=e4o-ECkzDoI) — rasdev · 12:14 · 3w · 116k
- [The Roblox Algorithm Explained Like You're 5](https://www.youtube.com/watch?v=inWzxY26NXo) — Tizzy RBLX · 18:18 · 5mo

rasdev posts frequently about discovery and runs a developer-analytics site (rebloxed). These are the freshest community takes and almost certainly discuss the 2026 Recommended-For-You changes.
- **Bot takeaway:** treat community algorithm claims as hypotheses. The verified facts are in chapter 15 rule 22: a custom thumbnail is required for homepage recommendations since 2026-10-19; D1, D2–7 and D8–28 retention and sustainable monetization are rewarded; gameplay video now uploads in Creator Hub.
- **Caveat:** videos titled "how to trick the algorithm" (rasdev [7VhmLFkhwPU](https://www.youtube.com/watch?v=7VhmLFkhwPU)) may suggest tactics that break policy. Never use fake engagement or misleading thumbnails.

**8. Marketing basics**
- [How to ACTUALLY Advertise Your Roblox Game](https://www.youtube.com/watch?v=7QfaQe4rsq8) — CallMeDogey · 9:38 · 7mo · 97k
- [How to ACTUALLY Make High CTR Roblox Thumbnails](https://www.youtube.com/watch?v=SjjPGduApZU) — CallMeDogey · 6:24 · 6mo
- [Roblox Game Monetization Explained Like You're 5](https://www.youtube.com/watch?v=zoz3PSMqets) — Tizzy RBLX · 15:08 · 4mo

These cover recent practice for Ads Manager campaigns, CTR-focused thumbnails, and developer products versus passes.
- **Bot takeaway:** test two or three thumbnails (chapter 07); price with `GetProductInfoAsync`, never hard-coded; and follow the paid-random-item rules for any egg or crate.
- **Caveat:** many thumbnail videos promote paid AI thumbnail tools (ForgeGUI, Rovisuals). Roblox rules on misleading thumbnails still apply.

### Also useful
- [How to Organize your Roblox Game](https://www.youtube.com/watch?v=CtqlgCwXT6o) — MikoLikesHat · 10:48 · 1y. Explorer hygiene, folder conventions and naming. It matches the Rojo tree in chapter 08.
- **AI-built games, for awareness only:** [Building a Viral Roblox Game with AI](https://www.youtube.com/watch?v=OfObWnrucRY) (tef, 13d, 231k) and [Can Claude AI Build a Viral +1 Roblox Game in Just 3 Prompts?](https://www.youtube.com/watch?v=epEK5TWOZfc) (Yxii, 3d). These show what owners will compare the bot against. The lesson is that fast prototypes are easy now and differentiation comes from originality, polish and retention design.

**Well-known channels (design and success):** AlvinBlox, Zyonic, waveshine, rasdev, Tizzy RBLX, CallMeDogey, SmartyRBX (older, beginner-motivational), Roblox Creators (official), Onett's RDC talk.

---

## A2. Building and environment

### Top picks

**1. BONES — Building Tutorial series** (2y; avoid scripting APIs, so age matters less)
- [Basics](https://www.youtube.com/watch?v=EAtKeffHRRI) (13:51, 446k)
- [Environmental Art](https://www.youtube.com/watch?v=-DoOf32pkPo) (35:00, 409k)
- [Advanced](https://www.youtube.com/watch?v=B9nvNMNUiBE) (15:15)
- [Basic Layouts](https://www.youtube.com/watch?v=ozwIWIbMu-0) (9:55)
- [PBR textures](https://www.youtube.com/watch?v=5DxfMG-kDfw) (9:50, 121k)
- [5 Tips to get better at building instantly](https://www.youtube.com/watch?v=XEXeFYNTrBA)

This is the most complete free building course in the catalog. It moves from part manipulation and snapping, to layouts and composition, to environment art (terrain plus props, foliage clusters, framing), to PBR. The PBR episode explains that a `MaterialVariant` attached to a base material overrides that material across the place.
- **Bot takeaway:** start each map with a *layout pass* (blockout of paths and landmarks) before detail. Use MaterialVariants through `MaterialService` for consistent surfaces. Cluster props in odd numbers with varied scale and rotation.
- **Caveat:** since 2026 Studio has 64-material terrain early access and new base materials. Check chapter 02 for current material names.

**2. [the ULTIMATE stylized tutorial for ROBLOX studio](https://www.youtube.com/watch?v=YG-IZoKAaQI)** — DatBoiEle · 12:27 · 10mo · 79k
- **What it teaches:** DatBoiEle is the catalog's most prolific environment builder (realistic showcases, build studies, lighting). This video covers the stylized (non-realistic) look: simplified shapes, bold colors, soft lighting. The companion is [How to Make Stylized Trees & Assets](https://www.youtube.com/watch?v=0_lkryX-CgM) (19:24, 152k), which builds Blender trees and imports them.
- **Also from him:** [I just figured out how ALL ROBLOX games make their MAPS...](https://www.youtube.com/watch?v=wmB8BW4y5EA) (6mo), about kit-bashing from asset packs. The description is sponsored by an asset marketplace, so watch for licensing.
- **Bot takeaway:** commit to one art style per game. A stylized style is cheaper, reads better on mobile, and ages better than "realistic".
- **Caveat:** for any marketplace assets, record the license in `assets/ASSETS.md` (chapter 08).

**3. [Building The 3 Best Roblox Art Styles](https://www.youtube.com/watch?v=3KBgLxPV-8E)** — VainOath · 19:05 · 2y · 40k
- **What it teaches:** builds the same idea in the three dominant Roblox styles. *(Inferred:)* low-poly or stylized, "stud"/classic, and realistic, with the trade-offs of each.
- **Bot takeaway:** use it to choose a style in the design doc (chapter 02).

**4. [How to Build PRO Roblox Maps!](https://www.youtube.com/watch?v=I-AB6pJ-y5g)** — DeHapy · 5:35 · 2y · 239k
- **What it teaches:** a devlog-style hour of building a test map, showing a quick blockout, then landmarks, then dressing.
- **Bot takeaway:** time-box map passes.

**5. [Why You SHOULDN'T Use Roblox Terrain](https://www.youtube.com/watch?v=YhQ_ERl4w7g)** — HollyHollers · 12:07 · 9mo · 41k
- **What it teaches:** argues against overusing smooth terrain: performance, a blobby look, and difficulty getting a stylized result. It suggests mesh or part-based ground and hand-placed cliffs instead.
- **Contrast with:** [The EASIEST Guide to Making Amazing Terrain](https://www.youtube.com/watch?v=CippiATeZ54) (SmartyRBX, 3y, 518k), which shows the terrain tools.
- **Bot takeaway:** use terrain for large natural ground and water (Shorelines). Use parts or meshes for gameplay surfaces that need crisp collision and readable edges. Chapter 08 §8.3 covers scripting terrain (`FillBlock`, `WriteVoxels`).
- **Caveat:** the 2024 Terrain Editor update and the 2026 64-material early access changed the tools. Older terrain videos show the legacy editor UI.

**6. [Everything about MaterialVariants](https://www.youtube.com/watch?v=MWAIZuV70EQ)** — Roblox Studio in a Minute · 5:04 · 4y
- **What it teaches:** MaterialService, MaterialVariant properties, tiling, and overriding base materials. It is still conceptually correct.
- **Caveat:** it says to "enable the beta feature", which is no longer needed. Texture-map properties are PluginSecurity (chapter 09).

**7. [Creating Custom Skyboxes on Roblox](https://www.youtube.com/watch?v=ds9FjZUc2tg)** — Roblox Creators · 7:22 · 2y
- **What it teaches:** the official method for making and importing six-face skyboxes.
- **Caveat:** use the `Sky.*Content` properties in scripts (chapter 15). `SkyboxOrientation` arrived in 2025.

### Obby and lobby
- [Every Obby Style Explained](https://www.youtube.com/watch?v=_tcjS1nsFoE) — AmusingThing · 7:22 · 2y. A taxonomy of obby formats (tower, stage, tiered, troll, and so on). Useful for genre selection (chapter 06).
- [How to Make TIERED OBBIES (Design & Gameplay)](https://www.youtube.com/watch?v=BbupfrVpcQ4) — addison · 7:16 · 3y. Difficulty tiers and pacing.
- [🔥 How to Make an Obby on Roblox Studio](https://www.youtube.com/watch?v=9v3GvfX_qr8) — AlvinBlox · 16:21 · 608k. Beginner checkpoint and kill-brick scripting. ⚠ Old-style code (likely `wait`, `.Touched` without debounce patterns). Rewrite it.

**Well-known channels (building):** BONES, DatBoiEle, Ice Guy, Kingkade 3D, HollyHollers (build reviews), Gamer M8 (low-poly), RoBuilder, Hibstheribs (sci-fi), VainOath.

---

## A3. Lighting and atmosphere

Lighting videos age fast. Before 2025 they say "set `Technology` to Future". Now `Lighting.Technology` is deprecated in favor of **`Lighting.LightingStyle` (Realistic/Soft) + `PrioritizeLightingQuality`**, and Compatibility lighting was removed (chapter 15 rule 9). The *art* advice (contrast, color temperature, atmosphere density, light placement) transfers unchanged.

**1. [MASTER Roblox Lighting With This Video](https://www.youtube.com/watch?v=j2ZhZv_L38M)** — Ice Guy · 34:41 · 2mo · 22k
- **What it teaches:** the newest complete guide, covering interior, exterior, horror and cartoon setups. Its description calls it "the complete guide to Roblox Studio Lighting".
- **Siblings from the same creator:** [Realistic Lighting](https://www.youtube.com/watch?v=adgCWET34rU) (5:18, 4mo) and [Realistic INTERIOR Lighting](https://www.youtube.com/watch?v=rewH2lXBYAk) (3:59, 3mo).
- **Bot takeaway:** this is the most current lighting reference. Mirror its per-mood presets as Lune or command-bar scripts that set `Lighting`, `Atmosphere`, `Sky`, `ColorCorrection`/`ColorGradingEffect`, `Bloom` and `SunRays` (chapter 02 has the property tables).

**2. [Make Your Roblox Game Look 10x Better With Lighting](https://www.youtube.com/watch?v=vkEXLmRAQgs)** — Develuper · 4:37 · 6mo · 243k
- **What it teaches:** quick wins with lighting tricks and post effects.
- **Bot takeaway:** a five-minute "baseline lighting" pass for every prototype: Atmosphere on, `ColorCorrection` with slight saturation and contrast, subtle Bloom, `SunRays`, and EnvironmentDiffuse/SpecularScale tuned.

**3. [THE Ultimate Lighting Tutorial [ADVANCED]](https://www.youtube.com/watch?v=aq0Fi0R2FAY)** — DatBoiEle · 21:17 · 1y · 131k
- **What it teaches:** advanced realistic lighting, including volumetric looks via Atmosphere, local lights, and shadow-casting choices.
- **Caveat:** check whether it sets `Technology`. Translate that to `LightingStyle`.

**4. [How I Do Lighting & Atmosphere in Roblox](https://www.youtube.com/watch?v=UlvSrWHESwA)** — RingWorld Studio (Fives) · 12:15 · 8mo · 54k
- **What it teaches:** a working studio developer's real process for atmosphere and lighting.
- **Bot takeaway:** treat lighting as part of art direction. Pick a time of day and a palette per zone.

**5. Stylized and cartoon**
- [How to make CARTOON LIGHTING](https://www.youtube.com/watch?v=YIyir52FiYo) — Gamer M8 · 3:06 · 3y · 287k
- [How to Light a Low Poly Map](https://www.youtube.com/watch?v=kJ4Kel0j04g) — barjNET · 8:10 · 2y

These use flatter, brighter, saturated setups: high Ambient/OutdoorAmbient, soft or no shadows, strong color correction.
- **Caveat:** older videos may rely on Compatibility/Voxel tech. Recreate the look with `LightingStyle = Soft` + `ColorGradingEffect` (chapter 02).

**6. [Give me 2 minutes and I'll fix your lighting FOREVER](https://www.youtube.com/watch?v=06KmD8aNJ5o)** — Rileybytes · 1:52 · 1y · 60k
- **What it teaches:** a minimal preset. Good for a quick sanity check, not a style guide.

**Zones:** [How to Change Lighting Depending where you are!](https://www.youtube.com/watch?v=41ODscGm28E) (RoBuilder, 5y, 102k) and [How To Make Weather Zones](https://www.youtube.com/watch?v=-82iN9JTbUg) (RKGAM3ZS, 1y). These cover client-side lighting swaps per region.
- **Bot takeaway:** do zone lighting on the client with TweenService on Lighting properties, triggered by zone detection (ZonePlus or `GetPartBoundsInBox` polling).
- **Caveat:** the 5-year-old video likely uses `.Touched` and `wait()`.

**Well-known channels (lighting):** Ice Guy, DatBoiEle, Develuper, RingWorld Studio, Gamer M8, Paul1Rb (engine-feature explainers).

---

## A4. Scripting systems

General warning: this is where tutorial age hurts most. Every pick below was checked against the deprecation filter (§A0). Where a high-view video is older or client-trusting, a newer or more rigorous alternative is named.

### A4.1 Architecture and project setup

**1. [How Big Studios Develop on Roblox](https://www.youtube.com/watch?v=IJDg6tRJmHo)** — Leif · 16:06 · 1y · 748k
- **What it teaches:** the professional external toolchain. A web digest of the video lists Git, VS Code, Rojo, and the Wally package manager (garbled as "Wall-E" in the digest), with GitHub for backup and collaboration ([recapio digest](https://recapio.com/digest/how-big-studios-develop-on-roblox-by-leif)).
- **Bot takeaway:** it matches chapter 08 exactly. Send the owner to this video when they ask "why files instead of Studio scripts?"
- **Companions:**
  - [How PRO Devs Set Up Roblox Games](https://www.youtube.com/watch?v=F3ASTJuO82A) (11:08, 1y, 273k): "the exact structure and code setup professionals use" (single entry-point scripts plus ModuleScripts, services and controllers).
  - [I Built a Better Data System for Roblox](https://www.youtube.com/watch?v=YSNAFlRF96o) (7:11, 8mo): combines ProfileService-style saving with Replica-style replication into one system.

**2. [Roblox Devs, Stop Rewriting Code (Do THIS Instead)](https://www.youtube.com/watch?v=6Q_p2ObUXSo)** — Crusherfire · 27:49 · 10mo · 64k
- **What it teaches:** reusable modules and composition. *(Inferred:)* writing generic ModuleScripts and utilities (signals, cleanup or Trove, components via CollectionService tags) instead of copy-pasting.
- **Bot takeaway:** keep a `shared/` utilities layer and tag-driven components (chapter 04).

**3. [How to use OOP with Luau on Roblox](https://www.youtube.com/watch?v=fByFKZarNiI)** — Roblox Creators · 11:25 · 1y · 87k
- **What it teaches:** the official explainer of metatables, `__index`, `.new` constructors and colon methods.
- **Bot takeaway:** use OOP for entities with state (NPCs, projectiles, placed objects). Type the class with `export type` (chapter 04).
- **Alternative:** [All Of Roblox Lua (Luau) in 21 Minutes](https://www.youtube.com/watch?v=LWL5QUdSQiA) (KatanaBladeHD, 10mo, 539k) is a fast refresher for humans.

**4. Types and parallelism**
- [Luau Type Checking](https://www.youtube.com/watch?v=eRVDL7xlN8g) — Suphi Kaner · 23:36 · 3y
- [MULTI-THREADING on ROBLOX?! - Parallel Luau](https://www.youtube.com/watch?v=MyM3JkHEPmA) — Crusherfire · 33:13 · 2y
- [How Roblox Uses Multiple CPU Threads](https://www.youtube.com/watch?v=_99zdTIqXFc) — Stewiepfing · 20:59 · 9mo
- [Multi Thread, Parallel Scripts, MicroProfiler](https://www.youtube.com/watch?v=BbIPalpAfaI) — Suphi Kaner · 4y

Suphi Kaner is one of the most technically rigorous Roblox educators. The type-checking video still applies conceptually, but Luau's **new type solver** has since changed inference details, so check against luau-lsp output. The Parallel Luau videos explain Actors, `task.desynchronize`/`synchronize`, and SharedTable.
- **Bot takeaway:** only parallelize measured hot paths, such as many NPC raycasts or terrain generation (chapter 12). Use the MicroProfiler before and after.

### A4.2 Player data (DataStores, ProfileStore)

**1. [Stop Using Default DataStores! Use ProfileStore Instead](https://www.youtube.com/watch?v=m2SP_TLeWHI)** — Rileybytes · 27:13 · 1y · 131k
- **What it teaches:** why ProfileStore beats hand-written DataStore code, and how to set it up. DevForum users link it as a go-to ProfileStore tutorial; the key selling point they cite is **session locking**, which stops a player's data loading in two servers at once ([ProfileStore thread](https://devforum.roblox.com/t/profilestore-save-your-player-data-easy-datastore-module/3190543)).
- **Bot takeaway:** use ProfileStore as the default. Reconcile templates, `Profile:AddUserId` for GDPR, and end the session on leave.
- **Caveat:** follow chapter 15 rule 6. From 2026-11-11, `PlayerCharacterDestroyBehavior = Enabled`, so read Player values before the first yield in `PlayerRemoving`.

**2. [How to Save Player Data using Profile Store!](https://www.youtube.com/watch?v=evBhoqeYegQ)** — MonzterDEV · 20:27 · 2y · 34k
- **What it teaches:** an early ProfileStore walkthrough ("created by the same developer" as ProfileService: loleris / MadStudio).
- **Bot takeaway:** a second explanation of the same API. Check method names against the current module in `reference/libraries/MadStudioRoblox_ProfileStore`.

**3. [DataStore (Saving Player Data, pcall(), Scopes) - Roblox Advanced Scripting](https://www.youtube.com/watch?v=TIZ3qsCX5S0)** — BrawlDev · 46:59 · 2y · 237k
- **What it teaches:** the raw DataStoreService underneath: `GetAsync`/`SetAsync`/`UpdateAsync`, pcall, retries and scopes. BrawlDev's "Advanced Scripting" series is the catalog's best structured course.
- **Bot takeaway:** understand the primitives for leaderboards (OrderedDataStore) and global data. Use `UpdateAsync` over `SetAsync` for read-modify-write.
- **Caveat:** prefer ProfileStore for player profiles.

**Skip:** [ProfileService tutorials](https://www.youtube.com/watch?v=zpw7Kg8S14k) (Dot Product, 3y). ProfileService is superseded by ProfileStore.

### A4.3 Remotes, security and anti-exploit

**1. [How to Secure your Game Against Exploiters](https://www.youtube.com/watch?v=2jvahdJnQRI)** — GnomeCode · 28:30 · 3y · 138k
- **What it teaches:** "There's no such thing as the perfect anti-cheat." Exploiters control their client, so the server must validate every remote: type checks, ownership, distance and rate checks, and cooldowns. It demonstrates attacks failing against a validated remote.
- **Bot takeaway:** the core rule set of chapter 11. Validate argument types (`typeof`), clamp numbers, check `NaN`, check that the player owns or is near the target, and rate-limit per player.

**2. [Exploits Are EASY to Fix, People Are Just Lazy](https://www.youtube.com/watch?v=vKPZGVtIHy4)** — ByteBlox · 11:42 · 2y · 385k
- **What it teaches:** most exploit damage comes from developer mistakes (trusting the client with damage, currency or positions) rather than unstoppable hacks. It matches one side of the long DevForum debate ([Developers are not equipped to deal with exploiters](https://devforum.roblox.com/t/developers-are-not-equipped-to-deal-with-exploiters/1770356)).
- **Bot takeaway:** design so a fully compromised client can't award itself anything.

**3. [Remote Events (One-Way Communication)](https://www.youtube.com/watch?v=rxBldFKWaTc)** — BrawlDev · 32:09 · 2y · 258k
- **What it teaches:** the fundamentals: FireServer, FireClient, FireAllClients, and the implicit `player` argument.
- **Pair with:** [Reliable vs Unreliable RemoteEvents](https://www.youtube.com/watch?v=n5uOVlCIUjI) (Roblox Creators, 9:16, 1y), the official guide to `UnreliableRemoteEvent` for high-frequency, loss-tolerant data such as cosmetic positions and VFX triggers.
- **Bot takeaway:** use unreliable remotes for cosmetic streams only, never for state changes. Consider a networking library for batching (ByteNet, Blink, Packet; chapter 04).

**4. [How To Make Remotes Like A Pro](https://www.youtube.com/watch?v=MJ-BuEvwaqs)** — Ludius · 21:20 · 1y
- **What it teaches:** a structured remotes module (central definitions, wrappers).
- **Companion:** [Let's Talk About Exploit Protection](https://www.youtube.com/watch?v=vu-ZOoTjR-E) (7:08, 2y), on how LocalScripts can be read and modified.

**Skip:** shorts titled "SIMPLE ANTI CHEAT", "Best FREE anti-cheat" and "Anti-Dex", and anything showing an executor. Client-side detection is easy to bypass ([Why Hackers Easily Bypass Roblox Anti-Cheat](https://www.youtube.com/watch?v=nPxzyAeEh5Q), xoace, 10mo, explains this).
- **Modern option:** the **Server Authority** beta (2025-12, needs IAS) is Roblox's engine-level answer for movement and physics trust. See chapter 15.

### A4.4 Combat

**1. [Every Popular Roblox Combat System Explained](https://www.youtube.com/watch?v=QPNniezfQVA)** — Ludius · 11:09 · 11mo
- **What it teaches:** a taxonomy of the three dominant Roblox combat types. *(Inferred:)* battlegrounds-style M1 combos, tool or weapon swings with hitboxes, and ability or skill systems.
- **Bot takeaway:** pick the model first, then design hit detection to match (chapter 11).

**2. [Don't Build Your Combat System Until You Watch This](https://www.youtube.com/watch?v=Aoc9HkGHu_8)** — ArTheDev · 6:02 · 1y
- **What it teaches:** the chapters list "Common Combat System Issues" and "Must Get…" (latency, hit registration, replication).
- **Then:** [The Combat System Tutorial Everyone's Been Waiting For](https://www.youtube.com/watch?v=Pi8rQ9gGTKE) (48:45, 1y, 55k). Its description lists replication, **server hitboxes**, knockback, blocking and perfect blocks.
- **Bot takeaway:** this is the most architecture-aware combat tutorial in the catalog. Copy the feature list (combo, block, parry, stun, knockback) and the server-validated hitbox approach.

**3. [How To Make A Combat System In Roblox Studio](https://www.youtube.com/watch?v=AX3rWUj5gRo)** — VuukStudios · 19:05 · 2y · 890k
- **Also:** [BEGINNER TUTORIAL](https://www.youtube.com/watch?v=Ht6ZfibXpDs) (32:50, 913k) and [ADVANCED](https://www.youtube.com/watch?v=r-c1aCp5RNg) (34:06, 1y).
- **What it teaches:** the most-viewed combat tutorials. They are beginner-friendly: M1 combos, animations, simple hitboxes.
- **Caveats:**
  - ⚠ Check for `Humanoid:LoadAnimation`. Use `Animator:LoadAnimation`.
  - ⚠ Check for `BodyVelocity` knockback. Use `LinearVelocity` or `ApplyImpulse` on the server-owned assembly.
  - ⚠ Check whether the client decides hits.
- **Bot takeaway:** use these for the *feel*: combo timing, animation events, VFX on hit.
- **Supporting modules:** Raycast Hitbox 4 ([DevForum 374482](https://devforum.roblox.com/t/374482), 3.3k likes) is the classic melee hitbox module. It is old, so check that it uses `WorldRoot:Raycast`.

### A4.5 Pets and eggs

The catalog is weak here. Most results are 10–30-second showcase shorts or "free system" ads.

**1. [The ONLY Pet Display System You'll Ever Need](https://www.youtube.com/watch?v=ErTOTGmAjNA)** — Stewiepfing · 21:13 · 8mo
- **What it teaches:** a pet inventory and display GUI with viewports, plus pets following the player. Stewiepfing's videos are technically solid and recent.
- **Bot takeaway:** use `ViewportFrame`s or `UIGridLayout` for the inventory. Run pet-follow movement **client-side** for smoothness, with positions computed relative to the character (`AlignPosition`/`AlignOrientation` or CFrame lerp in `RenderStepped`). The server stores only equipped IDs.

**2. [EGG OPENING SYSTEM For Your Roblox Game - Full Tutorial](https://www.youtube.com/watch?v=SG93rPGKQf0)** — AnonymousDev · 9:01 · 6mo
- **What it teaches:** an egg-hatching flow with configurable hatch amounts and pet unlocks.
- **Bot takeaway:** roll on the **server** with weighted tables. Show **odds that sum to 100% before purchase**. Check `PolicyService` `ArePaidRandomItemsRestricted` for paid eggs and provide a compliant path (chapter 15 rule 19, chapter 07). The hatch animation is client-side theatre after the server result.
- **Caveat:** ⚠ older pet tutorials, such as Exodia's 4-year-old [Egg Hatching System PART 1](https://www.youtube.com/watch?v=FMzr6vlRFpU), use `BodyPosition`/`BodyGyro` for pet following. Those are deprecated; replace them.

### A4.6 Tycoon

**1. [🔥 How to Make a Tycoon On Roblox Studio](https://www.youtube.com/watch?v=XY6Ig48tAnk)** — AlvinBlox · 21:30 · 3y · 564k
- **Also:** [Roblox Tycoon Scripting Tutorial](https://www.youtube.com/watch?v=m-fN3ww_PzU) (10:36, 2y).
- **What it teaches:** classic tycoon structure: plot claiming, droppers, a conveyor, a collector, and buy buttons that unlock the next items.
- **Bot takeaway:** the data model is the lesson. Store buttons with a `Price` attribute and a `Dependency` attribute, and keep a purchased list in the profile so the plot rebuilds on join.
- **Caveat:** ⚠ 3 years old. Expect `wait()` loops in droppers (use one central `Heartbeat` or `task.wait` scheduler), `.Touched` collectors (fine with debounce), and `SetPrimaryPartCFrame` (use `PivotTo`).

**2. Design case studies**
- [Making a Viral Roblox Tycoon in 14 Days](https://www.youtube.com/watch?v=JYvGdKRzwEo) — janisjanis01 · 17:47 · 10mo · 374k
- [Can I Make a VIRAL TYCOON in 24 HOURS?](https://www.youtube.com/watch?v=F9sfnpkzcPw) — Duckable · 20:28 · 11mo · 828k

These devlogs cover what makes a 2025–26 tycoon work: a unique theme ("My Duck Farm"), fast early unlocks, rebirths, and social plots.
- **Bot takeaway:** spend the effort on an original theme and a fast first 3 minutes of unlocks. The droppers are commodity code.

### A4.7 Simulator

The catalog query "roblox simulator tutorial scripting" returned only generic "learn to script" videos (DeHapy's [I Tried Learning Roblox Scripting In 7 Days](https://www.youtube.com/watch?v=UE_4mNwcXco), SmartyRBX's [EASIEST Beginner Guide to Scripting](https://www.youtube.com/watch?v=P2ECl-mLmvY), which is 4 years old with 4.7M views and teaches beginner idioms like `wait()`).
- **Gap:** there is no good dedicated simulator-architecture video in the catalog. Use chapter 06's simulator playbook. Watch Onett's FTUE talk (§A1) for design, Rileybytes' [How To Make PET SIM 99 Shop](https://www.youtube.com/watch?v=4ki3i4JnMNk) (25:14, 2y) for shop UI, and the pets section above.

### A4.8 Round systems

**1. [How to make a Round Based Game](https://www.youtube.com/watch?v=oEWoyT-GBZY)** — GnomeCode · 20:42 · 2y · 83k
- **What it teaches:** intermission, then map selection, then teleport into the arena, then the round timer, then win conditions, then cleanup. Full scripts are on gnomecode.com.
- **Bot takeaway:** implement it as an explicit state machine (`Intermission`, `Loading`, `InRound`, `PostRound`) on the server, with state replicated through an attribute or remote. Handle players leaving mid-round and late joiners.

**2. [How to Make A Round System (Countdown & Teleport Players)](https://www.youtube.com/watch?v=ESzmiC_AzLw)** — TheDevKing · 16:46 · **6y** · 393k
- **Caveat:** ⚠ too old to copy: expect `wait()`, `game.Workspace` string paths, and `Players.NumPlayers` patterns. It is listed only because of its view count; prefer GnomeCode.
- **Related:** [How to make a LOBBY QUEUE system](https://www.youtube.com/watch?v=E2nFsr22A1M) (PineappleDev, 1y, 265k) covers queue pads that teleport to a reserved server. ⚠ Use `TeleportAsync` + `TeleportOptions.ReservedServerId` (chapter 15 rule 5), not `ReserveServer` + `TeleportToPrivateServer`.

### A4.9 NPC AI and pathfinding

**1. [Pathfinding (AI, Dynamic Paths, Modifiers)](https://www.youtube.com/watch?v=ckA4fVkAjIA)** — BrawlDev · 34:29 · 1y · 165k
- **What it teaches:** `PathfindingService:CreatePath` with agent parameters, `Path:ComputeAsync`, waypoints, `Blocked` re-pathing, and `PathfindingModifier`s / costs for preferred and avoided materials.
- **Bot takeaway:** recompute paths on `Blocked` and at most every 0.5–1 s. Use direct `MoveTo` when there is line of sight (raycast) and pathfinding only when needed. Use modifiers for "avoid water".
- **Modules:** SimplePath ([DevForum 1196762](https://devforum.roblox.com/t/1196762), 900 likes) wraps this.

**2. [Advanced Enemy NPC](https://www.youtube.com/watch?v=WIhm49putiA)** — Built2Last · 5:25 · 1y · 130k
- **Also:** [How to Make a Pathfinding Enemy NPC](https://www.youtube.com/watch?v=mKIUsz81JLE) (DevMelon, 16:22, 9mo).
- **What it teaches:** chase, attack and idle behavior. DevMelon's is "fully customisable".
- **Bot takeaway:** structure NPCs as a finite state machine (Idle, Patrol, Chase, Attack, Return), use one server loop for all NPCs (not one script per NPC), and set network ownership to the server for enemies.
- **Caveat:** ⚠ check animation loading and `wait()` usage.

### A4.10 Inventory

**1. [Build a Modular Inventory System (Datastore + GUI + …)](https://www.youtube.com/watch?v=RDjsR4iIRlg)** — ArTheDev · 26:57 · 6mo
- **What it teaches:** an inventory with datastore support, GUI updating and a modular design. It is the most architecture-minded inventory tutorial in the catalog.
- **Bot takeaway:** the server owns the item list (in the profile). The client renders it from replicated state. Item definitions live in a shared ModuleScript keyed by item ID.

**2. [How to make a Custom Hotbar Inventory - RPG #12](https://www.youtube.com/watch?v=FZXnUYbGvxo)** — GnomeCode · 22:28 · 7mo
- **What it teaches:** replaces the default backpack with a custom hotbar. Part of a full RPG series.
- **Bot takeaway:** disable `CoreGui` Backpack only if you replace every function, including mobile and gamepad selection (IAS bindings). Consider **Satchel** ([DevForum 2451549](https://devforum.roblox.com/t/2451549); open-source, local copy in `reference/libraries/ryanlua_satchel`) as a drop-in modern backpack.

**3. [How To Script An Inventory System [BEGINNER]](https://www.youtube.com/watch?v=3UC3ZYGB5Bw)** — Im Stuff Games · 16:12 · 1y · 99k
- **What it teaches:** simpler and beginner-oriented. Fine for concepts.

### A4.11 Guns and projectiles

**1. [How to make a REALISTIC Gun with FastCast](https://www.youtube.com/watch?v=mJZWY3G7wa4)** — B Ricey · 26:06 · **5y** · 115k
- **What it teaches:** FastCast simulates bullets with travel time, drop and pierce ([FastCast thread 133474](https://devforum.roblox.com/t/133474), 3.2k likes). Part 2 is [Make your guns less laggy (and make it Full Auto)](https://www.youtube.com/watch?v=YyQi82TzYL4).
- **Caveat:** ⚠ 5 years old. Expect `Mouse.Hit`, older raycast filters and client-authoritative damage. FastCast itself is aging; its maintenance status is uncertain, so check the thread before adopting it.
- **Bot takeaway:** take the *pattern*. The client renders the cosmetic projectile immediately. The server re-simulates or validates the shot (origin near the character's head, rate of fire, line of sight).

**2. [SecureCast DESTROYS FastCast](https://www.youtube.com/watch?v=aBQQa94sN5A)** — ShadowClaw · 17:02 · 2y
- **What it teaches:** SecureCast, a multithreaded, **server-authoritative** projectile system with server-synced bullets.
- **Bot takeaway:** closer to what chapter 11 recommends for competitive shooters. Evaluate the module's maintenance before adopting it.

**3. [How To Create A Gun](https://www.youtube.com/watch?v=nmlY6wA0eq4)** — Built2Last · 6:35 · 1y · 106k
- **What it teaches:** short and modern-ish. A quick look at tool, animation and raycast basics.
- **Skip:** "FREE realistic gun system" showcase shorts and leaks (YNTLeaks etc.). These carry licensing and backdoor risk.

### A4.12 Vehicles

**1. [How to Make a Car in Roblox Studio | Simple Chassis Tutorial](https://www.youtube.com/watch?v=3a_ZVhyKSHI)** — H2M Blox · 46:57 · 2y · 276k
- **What it teaches:** a simple rear-wheel-drive chassis built from constraints: `CylindricalConstraint` or `HingeConstraint` motors for wheels, `SpringConstraint` suspension, and a `VehicleSeat` for input.
- **Bot takeaway:** use the constraint-based approach (no BodyMovers). Read throttle and steer from `VehicleSeat` or IAS. Give the driver network ownership for responsiveness, and sanity-check speed on the server.

**2. A-Chassis**
- [How to setup A-Chassis 1.7 for a slot car!](https://www.youtube.com/watch?v=37JzD7ljDHo) — rdvarney22 · 42:41 · 1y
- [Making A Roblox Slot Car in 15 Minutes](https://www.youtube.com/watch?v=xuHKFOv4g8I) — rdvarney22 · 15:26 · 10mo

A-Chassis is the community-standard realistic car kit (source in `reference/libraries/lisphm_A-Chassis`).
- **Caveat:** A-Chassis is a large legacy codebase. Inspect it for deprecated BodyMovers or `wait()`, and its plugins for free-model risk. Use it only for driving-centric games.
- **Skip:** Build a Boat "car chassis" videos. They are game-specific.

### A4.13 Grid placement and building

**1. B Ricey placement series**
- [How to create a Plot Placement System #1 - Plots & Players](https://www.youtube.com/watch?v=FaEMgVDlaNQ) — 25:52 · 2y · 56k
- [MINECRAFT/VOXEL GRID Placement System](https://www.youtube.com/watch?v=92acKqS_Jo0) — 26:11 · 2y

The series covers plot assignment (Bloxburg and Build a Boat style), then snapping to a grid with mouse raycasts, rotation, collision checks, and server confirmation.
- **Bot takeaway:**
  - The client previews: a ghost model with `PivotTo`, snapped `math.floor(pos/grid+0.5)*grid`, and red or green validity.
  - The server re-validates: inside your plot, no overlap via `GetPartBoundsInBox`, and the player owns the item and can afford it.
  - The server then places and saves the item as `{id, cframeComponents}` relative to the plot origin.
- **Caveat:** ⚠ replace `Mouse.Hit` with `Camera:ViewportPointToRay` + `Raycast`, and add touch and gamepad placement via IAS.

**2. [GRID PLACEMENT System (Piggy Build Mode)](https://www.youtube.com/watch?v=pUt9pYo4O28)** — Curly Fri · 9:25 · 2y
- **What it teaches:** a shorter alternative.
- **Design reference:** [I'm Creating A Sandbox Tycoon on Roblox](https://www.youtube.com/watch?v=6g8ZYtDKPBw) (Duckable, 1y, 239k).

### A4.14 External tooling videos (for the owner)
- [How to use Rojo to easily create Roblox games!](https://www.youtube.com/watch?v=18-cGOjfrKw) — MonzterDEV · 26:28 · 2y · 116k. A full Rojo walkthrough.
- [How to setup Rojo, VSCode, and Git](https://www.youtube.com/watch?v=ulBM7UdHk_4) — B Ricey · 15:57 · 5y. ⚠ Uses Foreman-era installs and Rojo 6; the concepts still apply. Use Rokit + Rojo ≥ 7.7.1 (chapter 08).
- Leif's *How Big Studios Develop* (above) is the best "why".

**Well-known channels (scripting):** BrawlDev (structured beginner→advanced series), GnomeCode (complete systems, security), Suphi Kaner (rigorous internals), Crusherfire, Stewiepfing (modern techniques), Ludius, ArTheDev (combat and inventory architecture), B Ricey (placement, FastCast; older), Leif (pro workflow, React-Luau), Rileybytes, MonzterDEV, AlvinBlox and TheDevKing (beginner; often old), Roblox Creators (official).

---

## A5. UI

**1. [The Ultimate Beginner's Guide to Roblox GUI](https://www.youtube.com/watch?v=lmNWskz9cEI)** — Kek · 18:16 · 10mo · 144k
- **What it teaches:** ScreenGui, Frames, Scale vs Offset, and layout objects.
- **Follow-ups from Kek:**
  - [The Greatest Cartoony UI Tutorial (w/ Figma)](https://www.youtube.com/watch?v=z16zs2v-FNI) (41:54, 8mo, 92k): "front-page cartoony UI"
  - [The Greatest Stud UI Tutorial (w/ Figma)](https://www.youtube.com/watch?v=gnIKtS3nUqo) (1:01:51, 4mo)
  - [The Greatest Anime UI Tutorial](https://www.youtube.com/watch?v=BeNTYzzQVcA) (31:13)
- Kek is the strongest current UI-art channel in the catalog.
- **Bot takeaway:** design in Figma (or have the owner do it), export image slices, and rebuild in Studio with Scale sizing, `UIAspectRatioConstraint`, `UIStroke`, `UICorner`, `UIGradient` and `UIPadding`. Pick one style (cartoony, stud or anime) to match the game's art style.

**2. [Make Your Roblox UI Look 10x Better](https://www.youtube.com/watch?v=F6AtQKo3uIY)** — Develuper · 7:03 · 2mo · 155k
- **What it teaches:** recent, quick polish rules: consistent palette, strokes, gradients, spacing, icon quality, and hierarchy.
- **Bot takeaway:** apply it as a UI review checklist (chapter 03).

**3. [Making Good UI is EASY, People Are Just Lazy](https://www.youtube.com/watch?v=ZTzUHfMeYKA)** — ByteBlox · 17:29 · 2y · 175k
- **Companion:** [Your GUI is Boring, Lets Animate It](https://www.youtube.com/watch?v=ZLLVmY3D444) (18:21, 98k).
- **What it teaches:** practical UI craft (alignment, readable text, contrast) and animation (hover, click and open/close transitions).
- **Bot takeaway:** every button gets hover and press feedback: a scale tween of about 1.05 / 0.95, a sound, and the `Selectable` setup for gamepad.

**4. [How Modern Roblox UI Actually Works](https://www.youtube.com/watch?v=Ezk3vEOvv8o)** — Leif · 14:56 · 10mo · 181k
- **What it teaches:** "everything you need to build a game using **React Luau**": declarative UI with components, state, and props.
- **Bot takeaway:** for UI-heavy games (shops, inventories, settings), a declarative library (React-Luau, Fusion, Vide; local copies in `reference/libraries/`) scales better than hand-wired GUIs. Preview components with UI Labs or Flipbook (Part B). For small games, plain Instances plus a few modules are fine.

**5. Scaling across devices**
- [How To Scale UI Across Devices](https://www.youtube.com/watch?v=1B46XsUvi2E) — Kingkade 3D · 4:36 · 4mo
- [How to SCALE GUI like a PRO | Buttons + Frames + ScrollingFrames](https://www.youtube.com/watch?v=BLZl-0cl2DM) — Itz_FloppyFish · 40:16 · 2y · 194k

These cover Scale vs Offset, `UIAspectRatioConstraint`, ScrollingFrame `AutomaticCanvasSize`, and the "UI looks fine on PC, broken on phone" problem.
- **Bot takeaway:** test in the Studio device emulator at phone, tablet and 4K sizes. Use the [AutoScale Lite plugin](https://devforum.roblox.com/t/217704) (Part B) to convert. Respect `GuiService:GetGuiInset()` and the top bar.
- **Plugin walkthrough:** [How To Scale Your Roblox UI.. (Roblox Studio Plugin)](https://www.youtube.com/watch?v=Hei8pOej_T0) (TwinPlayz, 5:23, 6mo).

**6. Animation**
- [Tweening Is Holding You Back..](https://www.youtube.com/watch?v=h-POiqC120Y) — Stewiepfing · 16:12 · 1y · 76k
- [Make Your Roblox UI Buttons SUPER Smooth in 8 Minutes!](https://www.youtube.com/watch?v=2z4rebjBnQA) — PineappleDev · 8:35 · 1y · 136k

Stewiepfing's description says "Tweening is a simple way to make cool animations, but what if you wanted to do more?". *(Inferred:)* it introduces spring- or physics-based UI motion, which reacts to interruptions mid-motion. PineappleDev covers grow-on-hover and shrink-on-leave buttons.
- **Bot takeaway:** use `TweenService` for one-shot transitions and springs (`spr`, local `reference/libraries/fraktality_spr`) for interruptible, juicy motion.
- **Caveat:** never `GuiObject:TweenPosition` (deprecated).

**7. Figma workflow**
- [How to create Roblox Guis using Figma!](https://www.youtube.com/watch?v=_UfFmap5cow) — MonzterDEV · 22:08 · 2y · 158k
- [Should I Use Figma For Roblox UI Design?](https://www.youtube.com/watch?v=YNCTZwIkpGg) — gfxcomet · 8:30 · 1y

These cover designing in Figma, exporting slices, and rebuilding in Studio, plus the trade-offs.
- **Bot takeaway:** Figma is for the human designer. The bot builds the Studio side from exported assets uploaded with Asphalt (Part B).

**Shops:** [How To Make PET SIM 99 Shop](https://www.youtube.com/watch?v=4ki3i4JnMNk) and [How to make Animated Opening Shop Gui](https://www.youtube.com/watch?v=u404sKevMPU) (Rileybytes, 2y, 131k).
- **Caveat:** prices come from `GetProductInfoAsync`; never hard-code them.

**Well-known channels (UI):** Kek, Develuper, ByteBlox, Kingkade 3D, PineappleDev, Stewiepfing, gfxcomet, Leif (React-Luau), MonzterDEV.

---

## A6. VFX, animation, camera and audio

### VFX

**1. TrendyV2 — ROBLOX VFX Guide**
- [#1 Particles](https://www.youtube.com/watch?v=xzZeP65SSlA) — 7:14 · 1y · 376k
- [#2 Trails & Beams](https://www.youtube.com/watch?v=rIXyQ4RAwws) — 8:29 · 11mo

A compact modern primer on ParticleEmitter properties (Size/Transparency NumberSequences, Lifetime, Speed, Drag, `LightEmission`, flipbooks, `ZOffset`) and on Beams and Trails (Attachments, `TextureSpeed`, `FaceCamera`, width curves).
- **Bot takeaway:** build VFX as prefab Attachments holding emitters, kept in `ReplicatedStorage`, and trigger them on the **client** with `:Emit(n)`. Use the `EmitCount`/`EmitDelay` attribute convention from chapter 05.

**2. [How to ACTUALLY Use VFX in Roblox](https://www.youtube.com/watch?v=TkNZETIu0CM)** — Develuper · 9:24 · 7mo · 229k
- **What it teaches:** "from the basics to real examples like shooting effects, impacts…", meaning how to *integrate* VFX into gameplay code, not just make pretty emitters.
- **Bot takeaway:** the server sends one remote ("hit at position X, type Y") and each client spawns VFX locally. Never replicate emitters from the server every frame.

**3. Twist VFX**
- [How to Start Learning Roblox VFX](https://www.youtube.com/watch?v=GJOTJiUiYr4) — 19:11 · 6mo
- [How to Learn Roblox Aura VFX in 1 Hour](https://www.youtube.com/watch?v=u2o-wHKDlpw) — 41:47 · 8mo · 96k
- [How to Make Slash VFX](https://www.youtube.com/watch?v=zlKdwujvP2A) — 58:10 · 7mo · 263k
- [Stylized Explosion VFX](https://www.youtube.com/watch?v=J8uIGox3xfU) — 16:35

This is the deepest current VFX course in the catalog. The slash video uses beams and meshes with "a tiny bit of scripting". The learning video points to VFX communities (VFX Society, RoVFX).
- **Bot takeaway:** good ability VFX layers several elements: anticipation, then a flash, then the main shape (mesh plus beam), then particles, then lingering smoke or sparks, then camera shake, then sound. Keep the total under about 1 s for frequent attacks.

**4. [2025 Roblox VFX Setup Tutorial | Plugins and Tips](https://www.youtube.com/watch?v=9dQR7FySSLg)** — MoldySugar · 6:36 · 1y · 80k
- **What it teaches:** the plugins VFX artists use in Studio.
- **Caveat:** apply Part B's vetting rules to each plugin it shows.

**Anime abilities:** [Advanced Roblox Skill System Tutorial Part 2 (VFX)](https://www.youtube.com/watch?v=omiWGG6Wjwo) (Ampro, 4y, 117k) and [Roblox VFX Tutorial Part 2](https://www.youtube.com/watch?v=JXoGT2PoOhs) (Ampro, 2y).
- **Caveat:** ⚠ 2–4 years old. Check for `BodyVelocity`, `Humanoid:LoadAnimation` and `wait`.

### Animation

**1. [Moon Animator 2 Basics - Official Tutorial](https://www.youtube.com/watch?v=q8tGNMo_jHg)** — six (the Moon Animator author) · 4:41 · 4y · 1.9M
- **What it teaches:** the official intro: installing, inserting a rig, keyframing, and exporting.
- **Deeper:**
  - [Roblox ANIMATION Guide #1 - Moon Animator](https://www.youtube.com/watch?v=267aFypaeWU) (Nisky, 12:07, 1y, 281k)
  - [How I Animate: An Unofficial Moon Animator 2 Tutorial](https://www.youtube.com/watch?v=Yzf3iGZis7A) (Tycoon, 45:46, 1y), a working animator's process
  - [These Moon Animator 2 Shortcuts Will Save You HOURS!](https://www.youtube.com/watch?v=d2Tgk7Japp4) (AhdexDev)
- **DevForum guide:** [Getting Started with Moon Animator 2 [Unofficial]](https://devforum.roblox.com/t/476330) (590 likes, 239k views).
- **Bot takeaway:** the bot can't animate by hand. It can specify animations (key poses, timing, events) for the owner, load exported IDs with `Animator:LoadAnimation`, and use `AnimationTrack:GetMarkerReachedSignal` for hit frames.

**2. [The ULTIMATE Beginner's Guide to Animating in Roblox Studio](https://www.youtube.com/watch?v=y7_9d-BcgWY)** — Rustysillyband · 20:56 · 3y · 1.6M
- **Also:** [How to Animate in ROBLOX the RIGHT way](https://www.youtube.com/watch?v=dqAAa9aubM8) (DatBoiEle, 1y, 269k).
- **What it teaches:** animation using the **built-in Animation Editor**, which is free, plus easing, posing and priorities.
- **Bot takeaway:** set `AnimationPriority` correctly (Action for attacks) and loop only idle and walk.
- **Caveat:** the **Animation Graph System** (Studio beta 2026-04) may change how blending and state are authored. Check chapter 15.

**3. [Roblox Animation in Blender: Full Beginner Guide [2026]](https://www.youtube.com/watch?v=eg6COxaPCyo)** — Nisky · 7:46 · 11mo · 521k
- **What it teaches:** animating Roblox rigs in Blender and importing them.
- **Bot takeaway:** for complex or long animations, Blender plus a Roblox rig plus the 3D Importer is the pro path. Chapter 09 has the export settings.
- **Caveat:** the Avatar Joint Upgrade changes player-avatar joints. Test imported animations on current R15.

### Camera shake

**1. The canon** (§A7): Vlambeer's *Art of Screenshake* and [Screenshake that doesn't suck](https://www.youtube.com/watch?v=fn3hIPLbSn8) (Jump Trajectory, 8:37, 6y, Unity but engine-agnostic). The latter explains noise-based (Perlin) trauma shake instead of random jitter.
- **Bot takeaway:** implement trauma-based shake. `trauma ∈ [0,1]` decays over time; offset = `trauma² × maxOffset × noise(t)`. Apply it on the client in a `BindToRenderStep` after the camera update, and expose a **reduce-motion setting** (chapter 13).

**2. Roblox-specific**
- [How to make CAMERA SHAKE/SWAY](https://www.youtube.com/watch?v=nd9tzpjONNA) — MonkeyDev · 4:03 · 3y · 141k
- [How to make a REALLY SIMPLE Camera Shake Module](https://www.youtube.com/watch?v=Ch2PrfAJujU) — EmitTheLuz · 11:18 · 2mo

The community module is **EZ Camera Shake** ([DevForum 98482](https://devforum.roblox.com/t/98482), 1.5k likes, 2018), a port of the Unity asset.
- **Caveat:** ⚠ older sway code indexes `Humanoid.CameraOffset` or Motor6Ds directly. Avoid hard-indexing joints (Avatar Joint Upgrade).

### Audio

**1. [The Capabilities of Roblox's NEW Audio API](https://www.youtube.com/watch?v=b0hawic22jg)** — BrawlDev · 24:44 · 2y
- **What it teaches:** voice filters, analyzers, and the `AudioPlayer` → effects → `AudioEmitter`/`AudioListener` → `AudioDeviceOutput` graph wired with `Wire`s.
- **Bot takeaway:** use the Audio API for new games, especially if you want acoustic simulation (occlusion and reverb only work with it).
- **Caveats:** ⚠ `AudioPlayer.AssetId` became `Asset`/`AudioContent`, and `AudioPlayer` now plays at full volume (since 2025-10). Paul1Rb's own "(Outdated)" titles show how fast this area moves.

**2. [New Roblox Audio Features Are Massive!](https://www.youtube.com/watch?v=Ie_woKhjj3E)** — Paul1Rb · 12:01 · 1y
- **What it teaches:** `AngleAttenuation`, `AudioLimiter` and later additions. Paul1Rb has a series of short explainers on each engine audio update.
- **Bot takeaway:** check the property names in chapter 15 before use.

**3. [the COOLEST game feature YOU'RE NOT USING! - Roblox Volumetric Audio](https://www.youtube.com/watch?v=2VZ7DQHYPn8)** — Crusherfire · 7:41 · 2y · 62k
- **What it teaches:** volumetric sound emitters, where sound comes from a part's volume rather than a point. Good for rivers and crowds.
- **Gap:** "roblox sound design tutorial" returned only shorts. For sound design craft, see chapter 05 and the audio-tool videos summarized in chapter 17.

**Well-known channels (VFX, animation, audio):** TrendyV2, Twist VFX, Develuper, MoldySugar, Ampro (older), six / xSIXx (Moon Animator), Nisky, Rustysillyband, DatBoiEle, Paul1Rb (engine features), BrawlDev, Crusherfire.

---

## A7. General game design (engine-agnostic canon)

These are mostly 5–14 years old, but they teach principles, not APIs, so age doesn't matter. They are the highest-signal videos in the whole catalog.

### Juice and game feel

**1. [Juice it or lose it](https://www.youtube.com/watch?v=Fy0aCDmgnxg)** — Martin Jonasson & Petri Purho · 15:38 · 14y · 617k
- **What it teaches:** the classic demo. A plain Breakout clone becomes delightful by adding tweens, squash and stretch, particles, screenshake, sound, color and "personality" (eyes on blocks), without changing the rules. The playable build is linked from the description.
- **Bot takeaway:** after the core loop works, run a dedicated **juice pass**. Every player action gets at least three feedback channels (visual motion, particle or flash, sound), and every reward gets a bigger version. Chapter 05 has the Roblox implementations.

**2. [Secrets of Game Feel and Juice](https://www.youtube.com/watch?v=216_5nu4aVQ)** — Game Maker's Toolkit · 5:19 · 11y · 1.1M
- **What it teaches:** a short synthesis of feel: responsive controls, animation anticipation and follow-through, hit-pause, screenshake, sound, and particles. Plus the caution that juice can't save bad mechanics.
- **Bot takeaway:** use it as a checklist for combat and collection moments.

**3. [10 Ways to Improve Game Feel](https://www.youtube.com/watch?v=qCj9CZoAvFY)** — Design Diary · 10:37 · 2y · 84k
- **Also:** [5 Tips for Making Your Game Feel Good](https://www.youtube.com/watch?v=dMxSbS1uWDE) (O. and Co., 2y, 97k).
- **What it teaches:** modern enumerations: input buffering, coyote time, hit-stop, easing, camera follow lag, impact frames, and audio variation.
- **Bot takeaway:** on Roblox, implement input buffering (queue the next attack within about 150 ms), hit-stop (pause the attacker's and victim's animation tracks for 50–80 ms by setting `AdjustSpeed(0)`), and pitch-randomized sounds (±5%).

**4. [Instant "Game Feel" Tutorial - Secrets of Springs Explained](https://www.youtube.com/watch?v=bFOAipGJGA0)** — Toyful Games · 12:17 · 4y
- **What it teaches:** damped springs as the universal feel tool for cameras, UI and squash.
- **Bot takeaway:** use a spring module (`spr`) for camera offsets, UI pops and bobbing pickups.

**5. [A Guide to Good Combat Feel](https://www.youtube.com/watch?v=FpGgpUWEb_k)** — IndividualKex · 5:33 · 3y · 95k
- **What it teaches:** anticipation, active frames, recovery, knockback, hit flash and hit-stop in a small prototype.
- **Bot takeaway:** pairs with §A4.4.

**6. [How To Fail At Game Feel](https://www.youtube.com/watch?v=6kPLx_qGbDY)** — Artindi · 3:48 · 3y · 121k
- **What it teaches:** the anti-patterns: over-juicing, unreadable effects, and feedback that hides information.
- **Bot takeaway:** keep VFX from obscuring hitboxes and UI. Provide a reduce-effects option.

### Screenshake

**[The art of screenshake](https://www.youtube.com/watch?v=AJdEqssNZ-U)** — Jan Willem Nijman (Vlambeer) · 44:10 · 12y · 386k
- **What it teaches:** a live demo turning a dull shooter into a punchy one, step by step: bigger bullets, muzzle flash, faster projectiles, impact effects, hit animation, enemy knockback, screenshake, permanence (shells and corpses stay), camera lerp and kick, sleep (hit-pause), sound, and recoil pushing the player back.
- **Bot takeaway:** order matters. Clear feedback and permanence first, shake last and sparingly. On Roblox mobile, keep shake small; it can cause discomfort.
- **Pair with:** [Screenshake that doesn't suck](https://www.youtube.com/watch?v=fn3hIPLbSn8) for the noise and trauma implementation.

### Level design

**1. [Ten Principles for Good Level Design](https://www.youtube.com/watch?v=iNEe3KhMvXM)** — GDC, Dan Taylor (Square Enix Montreal) · 1:00:47 · 8y · 549k
- **What it teaches:** a Rams-style list. *(From the talk's well-known content:)* good level design is fun to navigate, doesn't rely on words, tells what but not how, constantly teaches, surprises, empowers the player, is easy and medium and hard at once, is efficient, creates emotion, and is driven by mechanics.
- **Bot takeaway:** use it as a review rubric for every map (chapter 10).

**2. [Level Design Workshop: Blockmesh and Lighting Tips](https://www.youtube.com/watch?v=09r1B9cVEQY)** — GDC, David Shaver (Naughty Dog) and Robert Yang · 56:35 · 8y
- **What it teaches:** blockmesh first, with scale and metrics, then use lighting to guide players (light as a path marker, contrast toward goals).
- **Bot takeaway:** block out with plain parts and a grid. Lock the player metrics first (jump height, walk speed). Use light and color to lead the eye to objectives.

**3. [8 Common Problems with Level Layouts / Blockouts](https://www.youtube.com/watch?v=wJEaWQz4180)** — Steve Lee · 6:03 · 3y · 63k
- **What it teaches:** a quick list of blockout mistakes. *(Inferred:)* spaces that are too big or empty, no landmarks, dead ends with no reward, confusing sightlines, and flat elevation.
- **Bot takeaway:** use it as a self-review checklist.

**4. [Level Design Workshop: Designing Celeste](https://www.youtube.com/watch?v=4RlpMhBKNr0)** — GDC, Maddy Thorson · 31:34 · 8y · 274k
- **What it teaches:** introduce a mechanic safely, develop it, then twist it. Rooms as small teaching units, plus assist-friendly difficulty.
- **Bot takeaway:** the right model for obby stage sequencing (chapter 06).

**5. [Level Design Approaches for Solo Devs](https://www.youtube.com/watch?v=OLXn6YYAk7M)** — Indie Game Clinic · 20:45 · 1y · 279k
- **What it teaches:** practical, small-team approaches such as modular kits, reuse and hub layouts.
- **Bot takeaway:** fits the bot-plus-owner production scale (chapter 14).

### Economy and progression

**1. [How Video Game Economies are Designed](https://www.youtube.com/watch?v=Zrf1cou_yVo)** — Game Maker's Toolkit · 16:12 · 4y · 1.3M
- **What it teaches:** faucets and sinks, resource flows, inflation, and machinations-style diagrams.
- **Bot takeaway:** before coding a simulator or tycoon, write the economy as a flow table (sources per minute, sinks, prices per tier) and simulate it in a Lune script. Check time-to-next-upgrade at minutes 1, 5, 30 and 120 (chapter 06).
- **Pair with:** [MMO Economies - Hyperinflation, Reserve Currencies & You!](https://www.youtube.com/watch?v=sumZLwFXJqE) (Extra Credits, 9y, 1.5M) for trading economies.

**2. [How to Keep Players Engaged (Without Being Evil)](https://www.youtube.com/watch?v=hbzGO_Qonu0)** — Game Maker's Toolkit · 10:46 · 8y · 2.8M
- **What it teaches:** ethical engagement: intrinsic motivation and meaningful goals over compulsion loops, plus where daily rewards and streaks become manipulative.
- **Bot takeaway:** align with Roblox's 2026 emphasis on "sustainable monetization" and its policies for younger audiences. No dark patterns, FOMO timers aimed at kids, or punitive streak loss (chapter 07).

**3. [Progression Systems - How Good Games Avoid Skinner Boxes](https://www.youtube.com/watch?v=S5camMoNw-o)** — Extra Credits · 6:19 · 11y · 1.3M
- **What it teaches:** progression should unlock new *ways to play*, not only bigger numbers.
- **Bot takeaway:** every tier in a simulator or tycoon adds a mechanic, area or ability, not just a multiplier.

**4. Leveling systems**
- [What Makes a Good Level Up System?](https://www.youtube.com/watch?v=Ae_zvm0-CQU) — Design Doc · 17:56 · 6y · 578k
- [Leveling Up Progression Systems](https://www.youtube.com/watch?v=gDQX3jk5xxc) — Adam Millard · 15:12 · 7y · 675k

These cover XP curves, horizontal vs vertical progression, and player-skill vs character-power progression.
- **Bot takeaway:** use a gentle exponential XP curve (for example `base × level^1.5`). Give frequent small rewards early and milestone rewards every 5–10 levels.

**5. [How To Design a Gameplay Loop](https://www.youtube.com/watch?v=wTbSrOexWZU)** — Apox Fox · 7:35 · 3y
- **What it teaches:** core, mid and long loops.
- **Bot takeaway:** write all three loops in the design doc (chapter 01).

**6. [The Two Types of Random in Game Design](https://www.youtube.com/watch?v=dwI5b-wRLic)** — Game Maker's Toolkit · 19:18 · 6y · 3.6M
- **What it teaches:** input randomness (shapes decisions) vs output randomness (decides outcomes).
- **Bot takeaway:** for eggs, crits and drops, prefer input randomness or pity systems so players feel in control. Paid randomness must follow the disclosure rules (chapter 15 rule 19).

### Prototyping and finding the fun

**1. [What's the Point of Prototyping?](https://www.youtube.com/watch?v=8tHJgtbj6rs)** — Game Maker's Toolkit · 17:02 · 1y · 361k
- **What it teaches:** prototypes answer specific questions ("is this mechanic fun?") with the least work. Grey boxes, throwaway code, and testing early with others.
- **Bot takeaway:** for each new game, build a 1–2 day grey-box prototype of the core verb before any art, then playtest with the owner. Use Studio's Playtest Agent (beta) for automated smoke tests (chapter 12).

**2. [How to find amazing game ideas](https://www.youtube.com/watch?v=0m60QbT85Tc)** — Game Maker's Toolkit · 27:09 · 1y · 1.0M
- **What it teaches:** idea generation through constraints, mashups, and starting from a verb or feeling.
- **Bot takeaway:** feeds chapter 14's idea-generation method.

**3. [10 Game Design Lessons from 10 Years of GMTK](https://www.youtube.com/watch?v=Cm2_drGLGbc)** — Game Maker's Toolkit · 15:38 · 1y
- **What it teaches:** a distilled summary.
- **Also:** [How To Think Like A Game Designer](https://www.youtube.com/watch?v=iIOIT3dCy5w) (3y, 981k) and [Can we Improve Tutorials for Complex Games?](https://www.youtube.com/watch?v=-GV814cWiAw) (5y, 1.6M), which pairs with Onett's FTUE talk: teach by doing, just-in-time.

**Well-known channels (general design):** Game Maker's Toolkit, GDC (Festival of Gaming), Extra Credits, Design Doc, Adam Millard (Architect of Games), Indie Game Clinic, Jonas Tyroller, Steve Lee, Toyful Games, Vlambeer talks.

---

## A8. Catalog gaps and what to do

| Topic | Gap | Fallback |
|---|---|---|
| Simulator architecture | no dedicated, rigorous tutorial | chapter 06 playbook; Onett FTUE talk; pets and tycoon sections |
| Pets and eggs | mostly shorts and "free system" ads | Stewiepfing display video plus server-rolled odds rules |
| Anti-exploit | dominated by client "anti-cheat" shorts | GnomeCode and ByteBlox principles; Server Authority beta (chapter 15) |
| Sound design | only shorts | chapter 05; audio-tool videos (chapter 17) |
| Input Action System | not in catalog | chapter 15 rule 8 and Roblox docs |
| Server Authority, Animation Graph, Procedural Models (2025–26 features) | too new for tutorials | DevForum announcements (chapter 15) |
| Postmortems | the query returned the horror game *POSTMORTEM* | DevForum `game-design` category; chapter 01 |

To extend the catalog, run `scripts/youtube_catalog.py` at home with new queries. Suggested: "roblox input action system", "roblox server authority", "roblox animation graph", "roblox ui styling", "roblox studio script sync".

---

# Part B — Studio plugins and external dev tools

## B0. Plugin safety rules (read before installing anything)

Studio plugins run Luau with **PluginSecurity**. They can read and modify every script and instance in any place you open, make HTTP requests (with permission), and inject scripts. The two most common outcomes of a malicious plugin are:
- a **backdoor**: a hidden `require(id)` or loadstring-style loader injected into your place, which gives an attacker server-side control in the live game;
- **infection spread**: the injected script copies itself into other places and models you publish.

The [Hidden Backdoor/Infection Script Detector thread](https://devforum.roblox.com/t/216692) (681 likes) and [How to remove backdoors from your game](https://devforum.roblox.com/t/511548) document the classic patterns.

**Rules:**
1. **Install only from the Creator Store** (Studio's Toolbox → Plugins, or create.roblox.com/store), and only the listing that the *original* creator's DevForum thread or GitHub links to. Check the creator name exactly; impostor copies use near-identical names and icons.
2. **Never install a "free" copy of a paid plugin.** Search results for "Moon Animator free" or "F3X download" are full of SEO sites (`*.pages.dev`) offering modified copies that are often backdoored. If it's paid, buy it or use a free alternative.
3. **Read the permission prompts.**
   - **Script injection** ([Plugin Script Modification Permissions](https://devforum.roblox.com/t/877312)) should be granted only to plugins whose job is editing scripts: Rojo, Argon, Azul, Reclass, Codify.
   - **HTTP domains** ([Plugin HTTP Permissions](https://devforum.roblox.com/t/493269)) should go only to the domains the plugin documents (for example `localhost` for sync tools).
   - A building or UI plugin asking for script injection or unknown domains is a red flag.
4. **Prefer open-source plugins** (GitHub link, readable source) and plugins with long, active DevForum threads. Likes and views are in the local mirror headers.
5. **Audit after installing anything new.** Search the place (`Ctrl+Shift+F`) for `require(` with a numeric argument, `getfenv`, `setfenv`, `loadstring`, `MarketplaceService:PromptPurchase` in unexpected scripts, and long obfuscated strings. Check `ServerScriptService`, `Workspace`, and inside models.
6. **Creator Store inserts are now sandboxed** ([Script Capabilities Sandboxing, 2026-05-13](https://devforum.roblox.com/t/4634642)). Assets inserted from the Store run in a sandbox that blocks "banned capabilities", including `LoadUnownedAsset` (`require(id)`, `LoadAssetAsync`). This applies to **assets (models)**, not plugins. Read free-model code anyway (chapter 15 rule 25).
7. **The bot itself should not depend on plugins.** It runs headless with Rojo, Lune and Open Cloud (chapter 08). Plugins are for the human owner and for Studio-attached sessions.

---

## B1. Features now built into Studio (they replaced plugins)

| Built-in feature | Status (2026-11) | What it replaced / notes | Source |
|---|---|---|---|
| **Tag Editor** | built in since late 2022; button under **View** | the community Tag Editor plugin (Sweetheartichoke, 2018). Tags also show in the Properties panel. Use for CollectionService-driven components. | [2055202](https://devforum.roblox.com/t/2055202) |
| **Align Tool** | built in (full release 2021-02) | most "align parts" plugins (Alignment+, etc.) | [1069328](https://devforum.roblox.com/t/1069328) |
| **Pivot Editor** | built in (2021) | pivot-hacking plugins; F3X/SBS had to update for the Pivot API | [1403027](https://devforum.roblox.com/t/1403027), [1235661](https://devforum.roblox.com/t/1235661) |
| **Next-Gen Draggers** | **beta** (2026-06-25): multi-axis planar drag, view-space transforms, trackball rotate | some advanced move/rotate plugins. Users report scale-from-pivot behavior changes, so set a sensible pivot first. | [4703155](https://devforum.roblox.com/t/4703155), [4760031](https://devforum.roblox.com/t/4760031) |
| **Studio Script Sync** | **full release 2026-06-17**: right-click a folder → "Sync to…"; two-way; conflict dialog; Team Create status | lightweight file-sync use of Rojo/Argon/Azul, for scripts and folders only | [4688454](https://devforum.roblox.com/t/4688454), [docs](https://create.roblox.com/docs/scripting/sync) |
| **Assistant** (AI in Studio) | full release 2024-12; can modify place content; **external LLM support** via API key (2026-02) | AI code plugins | [3294217](https://devforum.roblox.com/t/3294217), [4415631](https://devforum.roblox.com/t/4415631) |
| **Studio MCP server** (built in) | enable via Assistant → Manage MCP Servers; `studio_id` on every call (2026-08); **Playtest Agent** beta (2026-04); **Open Cloud access, permissions and asset-import Skills** (2026-11-04) | the open-source `studio-rust-mcp-server` (no longer developed) and community MCP plugins | [4566767](https://devforum.roblox.com/t/4566767), [4820583](https://devforum.roblox.com/t/4820583), [4975849](https://devforum.roblox.com/t/4975849); setup in chapter 08 §8.1 |
| **Universal Importer** | full release 2026-04 (images, audio, video, 3D in one place) | Avatar Importer plugin (deprecated 2024), bulk-upload plugins | [4554615](https://devforum.roblox.com/t/4554615) |
| **Material Generator** | available to everyone since 2024-09 | AI-texture plugins for MaterialVariants | [3145555](https://devforum.roblox.com/t/3145555) |
| **UIStroke, UICorner, UI Styling** | released; UI Styling beta 2025-05 | **Roundify** (rounded-corner plugin; obsolete since `UICorner`) | [3660722](https://devforum.roblox.com/t/3660722) |
| **Multi-line Command Bar** | beta 2025-10 | "run snippet" plugins | [4032717](https://devforum.roblox.com/t/4032717) |
| **Plugin window screenshots** (`Ctrl+Shift+2`) | 2026-10-27; MCP support planned | screenshot plugins | [4960927](https://devforum.roblox.com/t/4960927) |
| **Script Editor** with Luau autocomplete and type checking | built in | some autocomplete plugins (SimpleComplete still adds snippets) | [1406701](https://devforum.roblox.com/t/1406701) |

---

## B2. Building plugins

| Plugin | What it does | Price | Status (2026-11) | When to use | Learn it |
|---|---|---|---|---|---|
| **Building Tools by F3X** (GigsD4X / F3X Team) | all-in-one move, resize, rotate, paint, material, surface, weld, lighting and mesh tools; also usable as an **in-game** build tool | free | long-lived; the original thread's last activity was 2021, and the source is on [GitHub F3XTeam/RBX-Building-Tools](https://github.com/F3XTeam/RBX-Building-Tools). Community maintenance continues in **Fork3X** (open source, 2025; its author moved support to GitHub). | in-game building games (sandbox and "build" genres) more than Studio work; Studio's native tools now cover most needs | [Building Tools by F3X](https://devforum.roblox.com/t/1273), [Fork3X](https://devforum.roblox.com/t/3622698) |
| **Archimedes 3** (Scriptos) | builds smooth arcs and circles by repeatedly duplicating and rotating parts around an edge | free *(verify the listing)* | Archimedes 3 is live; the author says a better rewrite is in progress (thread activity 2026-03) | curved walls, rails, roads, rings | [Introducing Archimedes 3](https://devforum.roblox.com/t/1610366), [Everything About Archimedes' New Version](https://devforum.roblox.com/t/1877504) |
| **ResizeAlign** (stravant) | resizes parts so faces meet exactly; rounded-join mode; Ctrl dragger mode; respects Join Surfaces | free | v1.3 (2022); thread active to 2025 | closing seams between angled parts and roads | [ResizeAlign v1.3](https://devforum.roblox.com/t/1815331) |
| **GapFill & Extrude** (stravant) | fills the gap between two edges with wedges; works on Unions and MeshParts via collision geometry | free, [open source](https://github.com/stravant/roblox-gapfill) | v1.3 (2022) | filling gaps after Archimedes curves, terrain-like part surfaces | [GapFill v1.3](https://devforum.roblox.com/t/1817053) |
| **Model Reflect** (stravant) | mirrors models across a plane (symmetry) | free | old but working; a community fork adds Union support | symmetric builds (vehicles, buildings) | [Modified Model Reflect](https://devforum.roblox.com/t/66791) |
| **Brushtool 2.0** (XAXA) | paints, stamps or erases model instances onto surfaces with scale, rotation and wobble randomization | free | 2019 rewrite; thread active to 2026-08 | scattering trees, rocks and grass props | [Brushtool 2.0](https://devforum.roblox.com/t/255053) |
| **Power Selectors** | advanced selection (by class, material, color, and so on) | free | 2021 | bulk edits on big maps | [Power Selectors](https://devforum.roblox.com/t/1503783) |
| **Mesh Optimization Tools / MaximumADHD plugins** | collision-fidelity batch tools and others (TerrainImporter, ToolGripEditor, DecalProjector, StreamingDebugger) | free, open source | source in `reference/libraries/MaximumADHD_Roblox-Plugins` | setting `CollisionFidelity` in bulk (stravant recommends `PreciseConvexDecomposition`/`Hull` for meshes you collide with) | the GapFill thread links them |
| **Edge Bevel / IntersectAsync bevel plugins** | bevel part edges | free | 2024–25 | chamfered, stylized parts | chapter 02 lists them |

**Building summary:** for the bot's builds, prefer code-generated geometry (Lune or command-bar scripts using `PivotTo`, CSGv3 `GeometryService`, and Procedural Models since 2026-05) over plugin work. For the owner, the essential free kit is ResizeAlign, GapFill, Archimedes, Brushtool and Model Reflect, plus Studio's Align Tool and Pivot Editor.

---

## B3. UI plugins and Figma bridges

| Plugin | What it does | Price | Status | When to use | Learn it |
|---|---|---|---|---|---|
| **AutoScale Lite** (ZacBytes) | converts Offset↔Scale and adds `UIAspectRatioConstraint` with the correct ratio; Plus/Nightly add SmartScale | Lite free; Plus paid | 1.2k likes, 233k views; thread active to 2026-06 | the classic fix for "UI broken on mobile". Select the ScreenGui's *children*, then click Add Constraint. | [AutoScale Lite thread](https://devforum.roblox.com/t/217704), [TwinPlayz plugin video](https://www.youtube.com/watch?v=Hei8pOej_T0) |
| **Interface Tools** (fivefactor) | 900+ Material icons, patterns, gradients, button styles, a Kenney game-icon pack, a color generator and a contrast checker | free on the Creator Store *(check current tiers)* | relaunched; thread active to 2026-04 | fast icons and accessibility contrast checks | [Interface Tools](https://devforum.roblox.com/t/404423) |
| **Sketch** | Figma-like visual UI canvas inside Studio (zoom, pan, measurements), exports real ScreenGuis | free | new (2026-04, v1.77) and actively updated | the owner designing UI visually without Figma | [Sketch](https://devforum.roblox.com/t/4570888) |
| **Figma → Roblox converters** | import Figma frames as Roblox instances (Frames, TextLabels, layouts) or as images | mostly free; Bloxporter paid | *Figma to Roblox (Beta)* (2023; stale since 2023-12); **Figma Importer Assistant v2** (2024, active 2026-07; "opportunistic" mode maps strokes, colors and auto-layout); **FigBloxUI** (2026-02, active; also handles image upload); **Bloxporter** (paid, 2025) | owner designs in Figma. **Risk:** these need HTTP permission and sometimes Open Cloud keys, so give keys the narrowest scope. | [Figma Importer Assistant](https://devforum.roblox.com/t/2961561), [FigBloxUI](https://devforum.roblox.com/t/4446977), [Figma to Roblox](https://devforum.roblox.com/t/2272099), [Bloxporter](https://devforum.roblox.com/t/3501193); video: [MonzterDEV Figma workflow](https://www.youtube.com/watch?v=_UfFmap5cow) |
| **Codify** | converts instances (UI or models) into Luau, React, Fusion, Vide, Rojo or TypeScript code | free tier; paid features | maintained (621 likes) | turning a Studio-designed UI into code for a file-based project | [Codify](https://devforum.roblox.com/t/473076) |
| **UI Labs** | storybook: preview React, Fusion, Vide or Iris components with hot reload, without playing | free, open source | active (2026-08) | developing declarative UI components | [UI Labs](https://devforum.roblox.com/t/3109174) |
| **Flipbook** | storybook plugin (Roact, Fusion, React) | free, open source | maintained on GitHub (thread quiet since 2024) | as above; source in `reference/libraries/flipbook-labs_flipbook` | [Flipbook](https://devforum.roblox.com/t/2184387) |
| **Roundify** | rounded-corner images | free | **obsolete**: use `UICorner` | never for new work | [168608](https://devforum.roblox.com/t/168608) |

---

## B4. Animation and VFX plugins

| Plugin | What it does | Price | Status | Notes and risks | Learn it |
|---|---|---|---|---|---|
| **Moon Animator 2** (xSIXx) | film-style timeline: animates rigs, cameras, lights and any property; IK; easing; camera cutscenes | **paid** (Robux on the Creator Store; check the current price) | the standard for Roblox animators and cutscenes | most "free Moon Animator" downloads are modified copies, so buy from xSIXx's official listing ([rblx.co/MoonAnimator](https://rblx.co/MoonAnimator) per the official video). Exported KeyframeSequences become normal Animation assets. | [Official basics video](https://www.youtube.com/watch?v=q8tGNMo_jHg), [Nisky guide](https://www.youtube.com/watch?v=267aFypaeWU), [DevForum getting-started](https://devforum.roblox.com/t/476330), [Is Moon Animator worth it?](https://devforum.roblox.com/t/2477738) |
| **Moon2Cutscene / Moon Animator 2 to In-Game** | play Moon Animator 2 files (camera and property tracks) at runtime | free modules | 2024 | needed because property and camera tracks don't export as normal animations | [Moon2Cutscene](https://devforum.roblox.com/t/3001411), [Moon Animator 2 to In-Game](https://devforum.roblox.com/t/3178584) |
| **Built-in Animation Editor** | keyframes, easing, IK, curve editor, events | free | built in; the **Animation Graph System** is in beta (2026-04) | the default for simple animations | [Rustysillyband guide](https://www.youtube.com/watch?v=y7_9d-BcgWY) |
| **Blender + Roblox rigs** | full animation and modeling pipeline | free | current | R6 IK/FK Blender Rig V2.5 ([3586405](https://devforum.roblox.com/t/3586405), 770 likes) | [Nisky Blender guide](https://www.youtube.com/watch?v=eg6COxaPCyo); chapter 09 |
| **VFX helper plugins** (emitter editors, "emit" previewers, mesh-flipbook tools) | preview `:Emit()` bursts, edit NumberSequences, organize effect prefabs | mixed | many small community plugins | vet each one (B0). Prefer the convention of `EmitCount`/`EmitDelay` attributes plus a tiny previewer you control. | [MoldySugar VFX setup](https://www.youtube.com/watch?v=9dQR7FySSLg) |

---

## B5. Scripting and utility plugins

| Plugin | What it does | Price | Status | Learn it |
|---|---|---|---|---|
| **Reclass** (Elttob / dphfox) | changes an instance's class (Part→MeshPart, Frame→ImageLabel) while preserving properties and children | **Reclass classic: free, unmaintained**; **Elttob Reclass: paid**, maintained (2024, active 2026-07) | [Reclass classic](https://devforum.roblox.com/t/402382), [Elttob Reclass](https://devforum.roblox.com/t/3119767) |
| **DataStore Editor** (cheap alternative, open source) | browse and edit DataStore entries in Studio | cheap on the Creator Store; free on GitHub | [894063](https://devforum.roblox.com/t/894063). For the bot, use Open Cloud DataStores v2 (chapter 08 §9.4) instead. |
| **Benchmarker** (boatbomber) | compares function timings with percentiles | paid (cheap) | [829912](https://devforum.roblox.com/t/829912) |
| **Jexplorer** | a performance-focused Explorer replacement (JECS) | free | [3788801](https://devforum.roblox.com/t/3788801); Studio's Next Gen Explorer is now default, so mostly optional |
| **Script Editor Themes / Code Minimap** | editor comfort | free | older |
| **Cmdr** (evaera; module, not plugin) | in-game typed command console for admin and debug | free, open source | [182815](https://devforum.roblox.com/t/182815); local `reference/libraries/evaera_Cmdr` |
| **Iris** (module) | Dear ImGui-style debug UI in game | free, open source | [2302802](https://devforum.roblox.com/t/2302802); great for tuning panels during development |

---

## B6. Free-model and backdoor scanners

| Tool | Status | Verdict |
|---|---|---|
| **Hidden Infection Script Detector** (Christbru01) | the author says the original exploit was patched and the plugin is **no longer updated** (last 2021) | historical; may still flag known patterns ([216692](https://devforum.roblox.com/t/216692)) |
| **Kronos** | **discontinued** and "outdated" by its author; a reply found it whitelisting a (deleted) backdoor ID | don't rely on it ([224779](https://devforum.roblox.com/t/224779)) |
| **Ro-Defender** | DevForum users report mixed results; one says it deleted a legitimate server script | use, if at all, as a hint generator, never auto-delete ([discussion](https://devforum.roblox.com/t/what-are-some-useful-trusted-plugins-to-identify-backdoor-scripts/1838327)) |
| **Sniper's Anti-Virus v12** | 2026-04, small, signature plus heuristic list | low adoption (9 likes); treat as an extra check ([4582077](https://devforum.roblox.com/t/4582077)) |
| **Fake "security" plugins** | a known scam pattern | only use scanners with long, public DevForum histories |

**Best practice (bot and owner):** don't insert free models into shipping games. If you must, insert into an empty place first. The sandbox (B0 rule 6) now blocks the most dangerous capabilities. Then grep every script for the patterns in B0 rule 5, delete everything you don't understand, and record the asset in `assets/ASSETS.md`. A scanner is a supplement to reading code, not a replacement.

---

## B7. External dev tools

Setup commands live in chapter 08. This section covers **what to choose and why**, plus status.

### B7.1 Editors and language tooling

| Tool | What it does | Status | Notes |
|---|---|---|---|
| **VS Code** (or Cursor, Zed, Neovim) | the editor | current | the de facto standard for external Roblox development |
| **luau-lsp** (JohnnyMorganz) | language server: autocomplete, type checking, go-to-definition, Roblox API types; also a CLI (`luau-lsp analyze`) | **v1.70.1 (2026-09-27)**, actively maintained | needs a `sourcemap.json` (from Rojo, Argon or Azul). Replaces the abandoned "Roblox LSP" (2020). [Marketplace](https://marketplace.visualstudio.com/items?itemName=JohnnyMorganz.luau-lsp) |
| **Rojo VS Code extension** (evaera) | starts and stops `rojo serve` from VS Code | current | convenience only |
| **selene / StyLua** | linter / formatter | current | [Selene, StyLua, and Roblox LSP explained](https://devforum.roblox.com/t/1977666) (2022; swap "Roblox LSP" for luau-lsp) |

### B7.2 Sync tools compared

| | **Rojo** | **Argon** | **Azul** | **Studio Script Sync** |
|---|---|---|---|---|
| Source of truth | filesystem | either (two-way) | **Studio** | either (two-way, scripts and folders only) |
| Syncs non-script instances | yes (`.model.json`, `.rbxm`, meta files); `syncback` in 7.x | yes, with properties | mirrors the whole DataModel 1:1 | no |
| Build place from files (CI) | **yes** (`rojo build`), the industry standard | yes (binary or XML) | `azul build/push/pack` (not its main goal) | no |
| Setup | `default.project.json` | CLI + VS Code extension + plugin | `npm i -g azul-sync` + plugin, zero config | right-click → "Sync to…" |
| Maturity | most mature; required by roblox-ts and most OSS | mature (2022–, 1.1k likes, active 2026-09) | new (2025-12, one maintainer, active) | official, full release 2026-06 |
| Best for | **the bot's file-first pipeline**, teams, CI, packages | small teams wanting two-way sync with properties | Studio-first developers adding VS Code and Git to an existing place | quick external editing of scripts in any place |
| Learn | [rojo.space](https://rojo.space/docs); [MonzterDEV video](https://www.youtube.com/watch?v=18-cGOjfrKw) | [argon.wiki](https://argon.wiki/); [thread 2021776](https://devforum.roblox.com/t/2021776) | [GitHub](https://github.com/Ransomwave/azul); [thread 4159808](https://devforum.roblox.com/t/4159808); [guide: Azul, Rokit, Wally & Git](https://devforum.roblox.com/t/4617424) | [announcement 4688454](https://devforum.roblox.com/t/4688454) |

**Choosing:**
- **The bot uses Rojo** (≥ 7.7.1 for the November 2026 Content serialization; chapter 15 rule 11).
- If the owner insists on building in Studio and the project is mostly Studio-authored, Azul or Script Sync lets them keep that habit. The bot then edits only the synced script files.
- **Never run two sync tools against the same place at the same time.** Rojo will overwrite edits made through another channel, and two-way tools can fight each other.
- Azul's author notes it doesn't fit roblox-ts or arbitrary folder layouts.
- Treat any sync plugin's script-injection permission as required but powerful. Install only the official plugin build (`rojo plugin install`, or the Creator Store listing linked from the official repo or thread).

### B7.3 Toolchain and packages
- **Rokit** (preferred toolchain manager; Foreman and Aftman are legacy-compatible), **Wally** (default package manager) and **pesde** (alternative). Details are in chapter 08 §2 and §4. The DevForum guides [How to install Wally](https://devforum.roblox.com/t/1757494) and [Why you should use Wally](https://devforum.roblox.com/t/1977617) are from 2022 but still accurate.
- **Loom** (2026-06): imports Wally packages or Rojo files natively inside Studio, for Studio-first owners ([4711006](https://devforum.roblox.com/t/4711006); new, so vet it).

### B7.4 Asset pipelines

| Tool | Status | Use |
|---|---|---|
| **Asphalt** (jackTabsCode) | **v2.0.2, maintained**. Uploads images, sounds, videos, animations and models; generates Luau or TS asset tables; alpha-bleeds images; converts SVG→PNG; targets users or groups. | **Default.** Run in CI with an Open Cloud key scoped to Assets read+write for one creator. Source in `reference/libraries/jackTabsCode_asphalt`. |
| **Tarmac** (Roblox, ex-rojo-rbx) | last release **0.7.0 (2020-07)**; dormant | legacy projects only; migrate to Asphalt |
| **Open Cloud Assets API directly** | current | small one-off uploads from scripts (chapter 08 §9.5) |
| **Universal Importer / Studio MCP asset-import Skill** | current (2026) | human or agent imports inside Studio |

### B7.5 Scripting outside Roblox
- **Lune** (**v0.11.1, 2026-10-21**): a standalone Luau runtime with `@lune/roblox` for reading and writing place files. Use it for generating places and models, data migrations, economy simulations and build scripts. It **replaces Remodel**, which is officially deprecated ([migration guide](https://lune-org.github.io/docs/roblox/3-remodel-migration)).
- **Lute** (luau-lang): Roblox's own general-purpose Luau runtime (`reference/libraries/luau-lang_lute`). It is promising but younger; prefer Lune for Roblox file manipulation.

### B7.6 Deployment
- **Mantle** (blake-mealey): infrastructure-as-code for places, passes, products and thumbnails. Its README says **"no longer maintained"**. Don't adopt it for new projects.
- **Instead:** use Rojo build plus the Open Cloud Place Publishing API (`versionType=Saved` for staging, `Published` to go live), plus Open Cloud for developer products and passes (configurable since 2025-12) via `rbxcloud` (Sleitnick) or `curl` (chapter 08 §9). Since 2026-11-04, the Studio MCP can also call Open Cloud with per-game permissions.
- **Keep separate dev and prod places** in one universe. Set Rojo `servePlaceIds` to prevent syncing into production (chapter 08 §3.2).

### B7.7 Git workflow (summary)
- One repo per game. Commit `src/`, `default.project.json`, `rokit.toml`, `wally.toml` + `wally.lock`, `selene.toml`, `stylua.toml`, and asset manifests.
- Ignore `Packages/`, `sourcemap.json`, `*.rbxl(x)` build outputs, and `.env`/API keys.
- Use feature branches. CI runs `stylua --check`, `selene`, `luau-lsp analyze`, then `rojo build`, then an Open Cloud Luau Execution test run.
- Studio-authored maps that can't live as text: keep them in a separate "map" place, or as `.rbxm` files with Git LFS, or sync them back with `rojo syncback`, Argon or Azul.
- **Learn it:** Leif's [How Big Studios Develop on Roblox](https://www.youtube.com/watch?v=IJDg6tRJmHo); the [Azul + Rokit + Wally + Git guide](https://devforum.roblox.com/t/4617424) (gentlest for beginners); [Setup Rojo Fast… with Git support](https://devforum.roblox.com/t/838182) (2020, dated).

### B7.8 AI and agent integration

| Tool | Status | Use |
|---|---|---|
| **Built-in Studio MCP server** | current; Playtest Agent beta; Open Cloud access (2026-11-04) | the bot's Studio-attached mode (chapter 08 §8.1). In an unsaved place, `execute_luau` can't make HTTP requests, so save to Roblox first ([4975849](https://devforum.roblox.com/t/4975849)). |
| `Roblox/studio-rust-mcp-server` | **no longer actively developed** (README) | reference only |
| `boshyxd/robloxstudio-mcp` | **archived 2026-06-06**; points to `Chrrxs/robloxstudio-mcp` | use only if the built-in server lacks a specific feature; vet the fork |
| **Assistant with external LLM** | 2026-02 | the owner may connect their own model key. Treat the key like any API key. |

Community reaction to the AI features is divided (chapter 15 §4). Don't push AI tooling onto an owner who prefers not to use it.

---

## B8. DevForum resources worth bookmarking

Likes and views are from the local mirror headers (`.sources/devforum/index.tsv`). These are modules and resources rather than plugins, but owners ask about them alongside plugins.

| Resource | Likes | What it is | Note |
|---|---|---|---|
| [TopbarPlus v3](https://devforum.roblox.com/t/1017485) | 4.5k | top-bar icons and menus | check compatibility with the current top bar |
| [ProfileService](https://devforum.roblox.com/t/667805) → [ProfileStore](https://devforum.roblox.com/t/3190543) | 3.6k / 1.5k | player data | use ProfileStore |
| [Raycast Hitbox 4](https://devforum.roblox.com/t/374482) | 3.3k | melee hitboxes | older; verify the APIs |
| [FastCast](https://devforum.roblox.com/t/133474) | 3.3k | projectile simulation | aging; consider alternatives |
| [Exploiting Explained](https://devforum.roblox.com/t/170977) | 2.9k | how exploits work | required reading for security |
| [ZonePlus v3](https://devforum.roblox.com/t/1017701) | 2.2k | zone detection | |
| [Wind Shake](https://devforum.roblox.com/t/1039806) | 1.6k | foliage wind | |
| [Chickynoid](https://devforum.roblox.com/t/1660558) | 1.6k | server-authoritative character | compare with the Server Authority beta |
| [Cmdr](https://devforum.roblox.com/t/182815) | 1.5k | admin console | |
| [EZ Camera Shake](https://devforum.roblox.com/t/98482) | 1.5k | camera shake | |
| [Iris](https://devforum.roblox.com/t/2302802) | 1.1k | debug UI | |
| [SimplePath](https://devforum.roblox.com/t/1196762) | 900 | pathfinding wrapper | |
| [Satchel](https://devforum.roblox.com/t/2451549) | 1.0k | modern backpack | |
| [SmartBone 2](https://devforum.roblox.com/t/2728928) | 817 | bone physics | |
| [Vanilla 3 icons](https://devforum.roblox.com/t/935745) | 3.1k | Studio-style icon set | good for plugin and dev UI |

**Category pages:** [Community Resources](https://devforum.roblox.com/c/resources/community-resources/), [Community Tutorials](https://devforum.roblox.com/c/resources/community-tutorials/), [Announcements](https://devforum.roblox.com/c/updates/announcements/), and the [Creator Store Plugins](https://create.roblox.com/store/plugins) listing (featured plugins are curated by Roblox: [3225629](https://devforum.roblox.com/t/3225629)). Note the 2026 DevForum age-gating (some open-source authors, such as Fork3X, moved support to GitHub), so check GitHub issues for current status.

---

## Sources

**Local:**
- `reference/video-library/catalog.json` and `README.md`
- `.sources/devforum/` (`index.tsv`; tutorials/, resources/, announcements/)
- `reference/libraries/` READMEs and CHANGELOGs: Rojo, Lune (0.11.1), luau-lsp (1.70.1), Asphalt (2.0.2), Tarmac (0.7.0), Mantle (unmaintained notice), Remodel (deprecated notice), `studio-rust-mcp-server` (no-longer-developed notice), `boshyxd_robloxstudio-mcp` (archived notice), Flipbook, MaximumADHD plugins
- `knowledge/08-bot-toolchain-and-workflow.md`, `knowledge/15-platform-changes-and-deprecations.md`

**DevForum (fetched or mirrored):** 4688454, 3257548, 4065468 (Script Sync); 4703155, 4760031 (draggers); 2055202 (Tag Editor); 4415631, 4566767, 4820583, 4975849 (MCP and Assistant); 4634642 (sandboxing); 4960927 (screenshots); 1273, 3622698 (F3X / Fork3X); 1610366 (Archimedes); 1815331, 1817053 (stravant); 255053 (Brushtool); 404423 (Interface Tools); 217704 (AutoScale); 402382, 3119767 (Reclass); 2021776 (Argon); 4159808, 4617424 (Azul); 2272099, 2961561, 4446977, 3501193, 4570888 (Figma and Sketch); 3109174, 2184387 (UI Labs, Flipbook); 216692, 224779, 4582077, 1838327 (scanners); 476330, 3001411 (Moon Animator); 3190543 (ProfileStore).

**Web:**
- [recapio digest of Leif's "How Big Studios Develop on Roblox"](https://recapio.com/digest/how-big-studios-develop-on-roblox-by-leif)
- [F3X wiki](https://github.com/F3XTeam/ROBLOX-Building-Tools/wiki)
- [Moon2Module thread (xsixx permission note)](https://devforum.roblox.com/t/moon2module-plugin-that-converts-your-moon-animator-projects-into-modulescripts/2975574)
- [Ro-Defender / Kronos discussion](https://devforum.roblox.com/t/what-are-some-useful-trusted-plugins-to-identify-backdoor-scripts/1838327)
- [Developers are not equipped to deal with exploiters](https://devforum.roblox.com/t/developers-are-not-equipped-to-deal-with-exploiters/1770356)

Web searches for individual video content mostly returned SEO spam. Most video summaries therefore rest on catalog metadata and are marked *(inferred)* where they go beyond it.
