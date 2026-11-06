# 00 — Master Checklist: How to Make a Roblox Game

This is the bot's starting point. It condenses the detailed guides (01–14 core, 15–20 platform changes, DevForum wisdom, outside tools and video lessons) into one procedure and one
set of rules. Each step names the guide (and section) to read for depth. Snapshot: 2026-11-05.

> How to use: follow the phases in order for a new game. For a feature or fix in an existing
> game, jump to the matching row of the "Task → guide" table in `CLAUDE.md`. Look up exact APIs
> with `scripts/kb_search.sh` before writing code — never guess.

---

## Part A — The 25 rules that matter most

**Design and audience**
1. **Hook in one sentence, fun in 60 seconds, loop complete in 5 minutes.** If you can't say "It's [familiar thing] but [twist], where you [verb] to [goal]", don't build yet. (01 §TL;DR, 14 §TL;DR)
2. **Layer loops:** core (seconds) → session (one sitting) → meta (days: collection, rebirth, rank) → social (trade, co-op, show off). (01, 06)
3. **Design for coming back tomorrow**, not one long session: offline progress, daily rotations, timed events, streaks. The Home algorithm ranks play-days and retention. (01, 13)
4. **Make it social.** Co-play is an explicit ranking signal; shared server moments (weather, bosses, raids) beat solo moments. (01, 06)
5. **Mobile first.** ~80% of players are on phones: big touch targets, little text, low-end performance. (01, 03, 12)
6. **Original work only.** New name, art direction, and a new verb or new combination of loops. Borrow genre conventions, never content. "Non-unique" games are deprioritized. (01, 06, 14)
7. **Scope ruthlessly:** one map, one core loop, 3–5 upgrade lines, one meta loop, one social hook. Ship small, then update every 2–4 weeks. (06, 14)

**Look and feel**
8. **Pick art style + palette before placing a part** (fill the Visual Style Spec). Consistency beats detail. Low-poly + small palette is the most reliable look for a bot. (02 §17, 09)
9. **Never ship default lighting.** Set `LightingStyle`, ClockTime, tinted Ambient/OutdoorAmbient, Atmosphere, ColorCorrection, Bloom. `Lighting.Technology` is deprecated. (02)
10. **Scale everything to the character** (~5–6.5 studs tall, WalkSpeed 16, default jump ≈ 7.2 studs high / ~8.7 studs flat). Grey-box with real characters first. (02, 10)
11. **Every action gets feedback within ~50 ms on at least two channels** (visual, audio, camera, UI). Anticipation → impact → follow-through. (05)
12. **UI is native, editable instances** (not menus flattened into images), Scale for position, safe areas respected, touch targets ≥ 44 px, works with touch + mouse + gamepad. (03)
13. **Audio:** instrumental music that loops seamlessly, non-vocal SFX, no choir/humming/vocal chops by default; only audio you have rights to; new Audio API for new work. (05)

**Engineering**
14. **Server owns all value.** Validate every remote argument (type, range, NaN, length, rate). The client only requests and renders. (04, 11)
15. **`--!strict`, `task.*` only, current API names** (`LoadCharacterAsync`, `Animator:LoadAnimation`, `*Async` variants). Knit is archived — plain ModuleScripts + a tiny loader. (04)
16. **ProfileStore for player data**, versioned with migrations; pcall + retry every web call; never point Studio at production DataStores. (04, 12)
17. **Every connection has an owner that cleans it up** (Trove per player/character/round). Handle players who joined before your script ran. (04)
18. **Design for StreamingEnabled:** `WaitForChild` with timeouts, CollectionService tags, no deep `workspace.A.B.C` paths on the client. (04, 10, 12)
19. **Don't poll; don't do real work every frame.** Event-driven code, pooled effects, budgets per device tier. (04, 05, 12)

**Money, rules, launch**
20. **Grant developer products only in one idempotent receipt handler** that saves the `PurchaseId` with the reward before acknowledging. Read prices live with `GetProductInfoAsync`. (07)
21. **Paid random items show every outcome's odds** (sum 100%) before purchase and respect `PolicyService`. Gate features by policy; if the call fails, treat the player as restricted. (07, 13)
22. **No pay-to-win PvP as the main product.** Sell cosmetics, convenience, time-savers, VIP, extra slots. Every currency source needs a sink. (06, 07)
23. **Filter all player-written text** shown to others. No off-platform links in game. No gambling. Fill out the maturity questionnaire honestly. (04, 07, 13)
24. **Thumbnail and icon must show the real gameplay.** Play-through rate is the top discovery signal; mismatches get exposure reduced. (01, 07)
25. **Verify by playing.** Syntax checks, lint passes, and self-written tests do not prove a game is fun, looks good, or sounds good. Test on a phone-class device at low graphics. (08, 12)

---

## Part B — The build procedure (concept → live)

Each phase ends with a gate. Don't move on until the gate passes. Record decisions in the game
project's own `docs/` so a later session can continue.

### Phase 0 — Intake (with the human owner)
- [ ] Ask: target audience/age, genre preferences, scope/timeline, budget (Robux for ads, commissions), any assets the owner provides. (14 §intake)
- [ ] Note the owner's standing preferences (see `CLAUDE.md` → Non-negotiables).

### Phase 1 — Idea → one-page pitch
- [ ] Generate ≥ 10 ideas with at least three methods (mechanic-first, fantasy-first, trend remix, "X but Y", constraint). (14)
- [ ] Score them (hook clarity, thumbnail-ability, social potential, monetization fit, build cost for a bot, competition). (14 rubric; 06 genre comparison table)
- [ ] Originality / IP gate passes. (14)
- [ ] Write the one-page pitch. **Gate:** owner approves the hook.

### Phase 2 — Design doc + style spec
- [ ] Fill in the Design Doc template. (01, end of chapter)
- [ ] Read the genre playbook section; pick progression formulas (`cost = base * g^n`, etc.). (06)
- [ ] Fill in the Visual Style Spec: palette, materials, lighting preset, UI style, audio palette. (02 §17, 03, 05)
- [ ] Define MVP with MoSCoW + a cut list + kill criteria. (14)
- [ ] Plan analytics events (onboarding funnel, economy, progression). (12)

### Phase 3 — Project setup
- [ ] Copy `templates/starter-game/` and follow its README (rename, set IDs).
- [ ] Check `knowledge/15` for any forced migration due soon, and `reference/creator-docs-live/deprecated-api-inventory.md` before using unfamiliar APIs.
- [ ] Otherwise create the repo from the guide-08 template: Rojo project, `rokit.toml`, `wally.toml`, selene, StyLua, `.luaurc`, per-game `CLAUDE.md`, CI. (08 templates)
- [ ] `rokit install`, `wally install`, `rojo build` succeeds on an empty place.
- [ ] Separate test universe for DataStores. (12)

### Phase 4 — Prototype (1–3 days, grey-box)
- [ ] Core loop only, plain parts, real character metrics. (10 §greybox, 14 §prototype)
- [ ] **Gate:** someone wants to keep playing. If not after honest iteration, pivot or kill. (14)

### Phase 5 — Systems (vertical slice → alpha)
Build in this order, testing each in multi-client Studio play as you go:
1. [ ] Loader + Net/Guard remote wrapper + Trove cleanup. (04)
2. [ ] Player data (ProfileStore, versioned) + leaderstats. (04)
3. [ ] Core loop systems for the genre (e.g. hatching, droppers, growth, combat). (06, 11)
4. [ ] Progression + economy with sinks; balance sheet. (06, 07)
5. [ ] Monetization: passes, products, idempotent receipts, policy gating, odds display. (07)
6. [ ] Social hooks: invites, trading (atomic), shared events. (11, 13)
7. [ ] Retention: daily reward, codes, timed rotations, `ConfigService` flags. (13)
8. [ ] Analytics wrapper + error reporter. (12)

### Phase 6 — Content and presentation
- [ ] World layout: spawn sells the game in 10 s, landmark per area, wayfinding, map sized to player count. (10)
- [ ] Lighting preset applied and tuned by eye; materials/palette per spec; terrain/foliage. (02)
- [ ] Run the build/UI/icon critique checklist on screenshots. (16)
- [ ] Assets generated by re-runnable scripts (bpy / Luau / Lune); every third-party model audited with the backdoor scanner. (09)
- [ ] UI: HUD, shop, toasts, onboarding — native instances, responsive, gamepad-navigable. (03)
- [ ] Juice: particles, camera shake, hit feedback, damage numbers, sounds, music manager. (05)
- [ ] Quests/dialogue/NPCs if the genre needs them. (10)
- [ ] Localization keys + accessibility settings respected. (13)

### Phase 7 — QA and performance
- [ ] Release checklist: smoke test, regression list, 2–3 client server test, low-end phone emulator test, DataStore round-trip, purchase test (Studio test purchases), error report clean. (12)
- [ ] Performance budgets per device tier: frame time, memory, draw calls, particles, network. (12, 02, 05)
- [ ] Security self-review: every remote validated and rate-limited; no client-trusted values. (04, 11)
- [ ] Scan new code against the symptom→fix catalog for known pitfalls. (19)
- [ ] Policy self-review: text filtering, odds, no links, no gambling, questionnaire answered. (07, 13)
- [ ] Playtest with real players; watch the first 5 minutes; fix the biggest drop-off. (12, 14)

### Phase 8 — Launch
- [ ] Experience page: 512×512 icon, 1920×1080 thumbnails showing real gameplay, description hook, age guidelines. (07)
- [ ] Publish to a test place first, run cloud tests, then publish production. (08)
- [ ] Soft launch with small ad spend to buy data, not success. (07, 14)
- [ ] Remember: new games first reach only age-checked 16+ users; under-16 reach needs 250 engaged plays in 60 days plus requirements. (01, 07, 13)

### Phase 9 — Live
- [ ] Read D1/D7, session length, FTUE funnel, conversion vs. the similar-games benchmark. (12)
- [ ] Change one thing at a time; A/B test with Experiments/Configs; refresh thumbnails. (12, 13)
- [ ] Update cadence the owner can sustain; ship content dark behind config flags; use built-in Restart Servers. (13)
- [ ] Kill/pivot/persevere against the criteria set before launch. Write a postmortem. (14)

---

## Part C — Definition of done (any feature)

A feature is done only when all of these are true:
- [ ] Works in a multi-client local server test, including join-late and leave-mid-action.
- [ ] Server validates every input; no exploit path grants value.
- [ ] Data survives leave/rejoin and server shutdown (BindToClose) where relevant.
- [ ] Has visual + audio feedback and reads clearly on a phone-sized screen.
- [ ] Works with touch, mouse/keyboard and gamepad.
- [ ] Inside the performance budget on the low-end emulator.
- [ ] Lint, format, type check, and `rojo build` pass; code blocks/tests pass.
- [ ] Logged analytics where the feature affects the funnel/economy.
- [ ] Project docs updated (state, decisions, open issues).
- [ ] Looked at (screenshots/emulator) and, where possible, listened to — not just compiled.

---

## Part D — Where facts came from and how much to trust them

- **[official]** claims come from the Roblox Creator Docs mirror in `reference/creator-docs` (snapshot 2026-11-05) and the engine API reference. Most authoritative.
- **[developer-reported] / [community]** claims came mostly from web search summaries: in the research session, devforum.roblox.com and several policy pages could not be fetched directly. Treat these as leads to verify.
- **[analysis/opinion]** and benchmark ranges are rules of thumb, not Roblox numbers.
- Player counts and chart positions change weekly; re-check before using them in a decision.
- Code in the guides was syntax-checked with the Luau compiler (`scripts/check_guide_code.py`) and API names were checked against the local reference, but it was **not run in Studio**. Test before shipping.
- Asset IDs in examples are placeholders (`rbxassetid://0`). Replace with assets you own or have rights to.
