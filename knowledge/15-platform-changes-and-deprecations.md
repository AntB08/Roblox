# 15 — Platform Changes and Deprecations (2023 → November 2026)

> **Why this chapter exists.** Your training data is older than this repo and partly stale. Between 2023
> and November 2026 Roblox changed a lot: the input system, avatar joints, lighting settings, chat rules,
> publishing requirements, payouts, discovery signals, and dozens of API names. This chapter is the
> "what changed" layer. When it conflicts with your memory, **trust this chapter, then confirm the exact API in
> `reference/`** (`scripts/kb_search.sh "<name>" api`).
>
> **Sources.** Everything here comes from the local mirror of DevForum *Announcements* threads
> (`.sources/devforum/announcements/`, 2,368 threads, staff posts plus top replies), checked against
> `reference/api/API-Dump.txt` (`[Deprecated]` tags) and the Creator Docs YAML mirror. The mirrored
> *release notes* (`.sources/devforum/release-notes/`) are mostly empty stubs, so small engine changes that
> appeared only in release notes may be missing. Links use the short form `https://devforum.roblox.com/t/<id>`,
> which redirects to the thread. Snapshot date: **2026-11-05**. Items marked **(uncertain)** have unclear
> status in the sources. Check the live thread before relying on them.

---

## TL;DR rules for the bot

**Code (engine/API)**
1. **Use the `…Async` names.** On 2026-01-14 about 45 yielding methods were renamed with an `Async` suffix. Examples: `LoadCharacterAsync`, `IsInGroupAsync`, `GetProductInfoAsync`, `PlayerOwnsAssetAsync`, `AwardBadgeAsync`, `ApplyDescriptionAsync`, `GetFriendsOnlineAsync`. The old names still work but are deprecated. Wrap these calls in `pcall`, and use `task.spawn` when you need several at once. [4257585](https://devforum.roblox.com/t/4257585)
2. **For group rank and role, use `GroupService:GetRolesInGroupAsync(userId, groupId)`.** `Player:GetRankInGroup(Async)` and `GetRoleInGroup(Async)` are now both tagged `[Deprecated]` in the API dump.
3. **Use the `task` library.** Write `task.wait`, `task.spawn`, `task.delay`, never `wait`, `spawn`, `delay` (all three globals are tagged Deprecated in the docs). Also write `Animator:LoadAnimation`, not `Humanoid:LoadAnimation`; `WorldRoot:Raycast`, `GetPartBoundsInBox` and `GetPartsInPart`, not `FindPartOnRay*` or the `Region3` finders; and `PivotTo`/`GetPivot`, not `SetPrimaryPartCFrame`. See the table in §2.
4. **For new code, use the `RaycastParams` / `OverlapParams` fields `ExcludeInstances` and `IncludeInstances`** (added 2026-04). They supersede `FilterDescendantsInstances` + `FilterType`. [4563575](https://devforum.roblox.com/t/4563575)
5. **Teleports go through `TeleportService:TeleportAsync` + `TeleportOptions`.** For a new reserved server, set `ReservedServerId = HttpService:GenerateGUID()`; for a VIP server, set `VipServerId`. `ReserveServer(Async)`, `TeleportToPrivateServer`, `TeleportPartyAsync`, `TeleportToPlaceInstance`, `ShouldReserveServer` and `ReservedServerAccessCode` are deprecated. [4963250](https://devforum.roblox.com/t/4963250)
6. **Write saving code that survives `PlayerCharacterDestroyBehavior = Enabled`.** From 2026-11-11 it is the default, and the property is removed at the end of February 2027. In `PlayerRemoving`, read every value from the Player *before* the first yield. [4975616](https://devforum.roblox.com/t/4975616)
7. **Never hard-index an avatar's joints or attachments.** With the Avatar Joint Upgrade, body parts are joined by `AnimationConstraint`s instead of `Motor6D`s, rigid accessories by `RigidConstraint`s instead of Welds, and attachments may sit under optional `Bone`s. Use `FindFirstChild(name, true)` or `QueryDescendants`. Phase 3 (forced for every game) is targeted for the end of 2026. [4541689](https://devforum.roblox.com/t/4541689), [4656414](https://devforum.roblox.com/t/4656414)
8. **Input: new games should use the Input Action System** (`InputContext` / `InputAction` / `InputBinding`, fully released 2026-06-11) instead of `ContextActionService`, raw `UserInputService` branching or `Mouse`. Use `UserInputService.PreferredInput` for the device mode and `InputActionLabel` for on-screen key hints. Server Authority needs IAS. [4678416](https://devforum.roblox.com/t/4678416)
9. **Lighting: set `Lighting.LightingStyle` (`Realistic` / `Soft`) and `Lighting.PrioritizeLightingQuality`.** `Lighting.Technology` is deprecated. Compatibility lighting is gone (it became Voxel + Retro tone mapping). [3401512](https://devforum.roblox.com/t/3401512), [3128560](https://devforum.roblox.com/t/3128560)
10. **Audio: the "new" Audio API (`AudioPlayer` → `AudioEmitter`/`AudioListener`/`AudioDeviceOutput`, connected with `Wire`s) is the modern path.** `Sound` still works and is not removed. Since Oct 2025 `AudioPlayer` plays at full volume (the opt-out flag is gone). Acoustic Simulation (occlusion/reverb) works only with the Audio API, not with `Sound`. [3153454](https://devforum.roblox.com/t/3153454), [3907391](https://devforum.roblox.com/t/3907391), [4307121](https://devforum.roblox.com/t/4307121)
11. **Asset properties are `Content` now.** From 2026-11-11 Studio serializes `*Content` properties (`TextureContent`, `MeshContent`, `ImageContent`, `AudioContent` and so on). In new scripts, prefer `x.TextureContent = Content.fromAssetId(id)` (or `Content.fromUri("rbxassetid://…")`). The old string properties still work. **Rojo must be ≥ 7.7.1.** [4975546](https://devforum.roblox.com/t/4975546)
12. **Chat goes through `TextChatService` only.** Legacy `Chat` was retired on 2025-04-30. Any player-to-player free text outside TCS (signs, pet names, trade notes, admin "message" commands) must be routed through a `TextChannel` or rate-limited to one update per minute. Custom chat UIs must move to `TextChannelWindow` by **May 2027**, and after that scripts can no longer read message content. [4948433](https://devforum.roblox.com/t/4948433)
13. **No social-media links inside the game.** Since 2026-02-23 links live only on the game page, and `PolicyService` `GetExternalLinkReference` returns an empty list. In-game text may only say "links on our game's page". [4226101](https://devforum.roblox.com/t/4226101)
14. **Only call `PlayerOwnsAssetAsync` for *other* players from the server.** Client calls now respect inventory privacy and throw. Cross-experience badge checks (`UserHasBadgeAsync` / `CheckUserBadgesAsync`) only work for players who are in, or were recently in, the server. [4226591](https://devforum.roblox.com/t/4226591), [4438920](https://devforum.roblox.com/t/4438920)
15. **Plan for scoped User IDs.** A new player may get a per-game ID; the `User` datatype is now accepted by engine APIs. Never use a UserId as a cross-game key, and never fingerprint players across games (that violates the ToS). The rollout is delayed **(uncertain timing)**. [4677155](https://devforum.roblox.com/t/4677155)

**Monetization and policy**
16. **Never hard-code displayed prices.** Plus subscribers get 10–20% off (Roblox-funded), and regional pricing / Managed Pricing is on by default for passes. Display `MarketplaceService:GetProductInfoAsync` prices. [4567894](https://devforum.roblox.com/t/4567894), [4684738](https://devforum.roblox.com/t/4684738)
17. **Don't sell another game's passes or dev products.** Cross-game sales were disabled on 2026-05-29. For donations or tips, use the Transfers API. [4618396](https://devforum.roblox.com/t/4618396)
18. **Handle refunds.** Subscribe to the Open Cloud *Transaction Refunded* webhook and revoke what was granted. [4890339](https://devforum.roblox.com/t/4890339)
19. **Paid random items** (eggs, crates, spins, luck boosts, pity systems) need: numerical odds that sum to 100% shown before purchase, `PolicyService:GetPolicyInfoForPlayerAsync().ArePaidRandomItemsRestricted` with a compliant alternative for restricted users, `IsPaidItemTradingAllowed` gating any trading, and no "lose everything" outcome. [4654622](https://devforum.roblox.com/t/4654622)
20. **Publishing is gated by age band.** Personal-use publishing is open to everyone. Reaching 16+ needs an age check, an account in good standing, and an account at least 2 days old. Reaching all ages (Roblox Kids <9, Select 9–15) needs ID verification (or Facial Age Estimation for under-18 creators), 2FA, Plus/Premium *or* a refundable 1,000-Robux fee per game, **plus** an evaluation driven by "Highly Engaged Players". Tell the user about these requirements up front; don't promise a launch to kids. [4573166](https://devforum.roblox.com/t/4573166), [4865780](https://devforum.roblox.com/t/4865780)
21. **Answer the Maturity & Compliance Questionnaire honestly.** Unrated games are unplayable (since 2025-09-30). Social hangouts, free-form user creation and "sensitive issues" games are 16+ (since 2026-05-19). "Restricted" games are 18+ (since 2025-11-06). [3899317](https://devforum.roblox.com/t/3899317), [3882864](https://devforum.roblox.com/t/3882864)
22. **Discovery:** without a **custom thumbnail** a game gets no homepage recommendations (since 2026-10-19). Upload a gameplay **video** in Creator Hub (YouTube embeds were removed on 2026-09-30). Recommended For You now rewards Day 1 / Day 2–7 / Day 8–28 retention and sustainable monetization. Copycat titles, thumbnails and placefiles are deprioritized. [4945086](https://devforum.roblox.com/t/4945086), [4684575](https://devforum.roblox.com/t/4684575)
23. **In-game ads and brand integrations** must be registered as Advertising Integrations and labeled (since 2026-05-04). No rewarded ad formats for players under 13. A revenue share applies from January 2027. [4527365](https://devforum.roblox.com/t/4527365)

**Workflow**
24. **Studio MCP:** every tool call now takes `studio_id`, and `set_active_studio` was removed (2026-08). `open_cloud_invoke` reaches Open Cloud (2026-11). In an *unsaved* place, `execute_luau` cannot make HTTP requests. [4820583](https://devforum.roblox.com/t/4820583), [4975849](https://devforum.roblox.com/t/4975849)
25. **Don't trust Creator Store inserts.** Since 2026-05 they are sandboxed by script capabilities, which can block hidden code, but it is still free-model code: read it. [4634642](https://devforum.roblox.com/t/4634642)

---

## How to use this chapter

- **Building a new game:** read the TL;DR, §2 (deprecated → replacement) and §3 (upcoming). Make sure templates and code don't use anything in the left column of §2.
- **Touching a specific system** (chat, avatars, teleports, monetization): search this file for the system name, open the cited thread in `.sources/devforum/announcements/<id>-*.md`, and read the staff post *and* the update blocks at its top (staff edit dates and phases into the head of the post).
- **Rollout properties.** Many behavior changes ship as a `Workspace`/`StarterPlayer`/`StarterGui` property of type `Enum.RolloutState` (`Default` / `Enabled` / `Disabled`). They follow three phases: opt-in (Default = old behavior), then opt-out (Default = new behavior), then the property is removed and the new behavior is forced. **Always set these to `Enabled` in new places and test that way.** A list is in §2.3.

---

## 1. Timeline (reverse chronological)

Format: **date — change.** What and why. **Bot:** what to do differently. Link.

### 2026 Q4 (October 1 – November 5)

**2026-11-05 — Minimum draw distance raised from 200 to 500 studs on low-end devices.** Auto-quality now keeps at least 500 studs visible at the lowest quality level and ramps up faster. Water keeps its transparency and beams scale better. Test it with Studio Settings > Rendering > Editor Quality Level. **Bot:** low-end phones now see further. Don't rely on short draw distance to hide unfinished map edges; dress the horizon or use fog. [4977292](https://devforum.roblox.com/t/4977292)

**2026-11-04 — Content property serialization switch (effective 2026-11-11).** Studio will save asset references as `Content` (e.g. `MeshContent`, `TextureContent`, `ImageContent`, `AudioContent`, `VideoContent`, `Sky.SkyboxBackContent`). Legacy `*Id` properties disappear from the Properties widget. Scripts that use the old names keep working, and they are not read-only. Rojo users must update to **v7.7.1+** before 2026-11-11. Custom parsers must handle `<Content name="…"><uri>…</uri></Content>` and `<null />`. If a file contains both the legacy and the new property with different values, it fails to open ("Content property conflict"). **Bot:** pin Rojo ≥ 7.7.1 in the toolchain (see `08-bot-toolchain-and-workflow.md`), and use `*Content` + `Content.fromAssetId()` in new code. [4975546](https://devforum.roblox.com/t/4975546)

**2026-11-04 — `PlayerCharacterDestroyBehavior` becomes effectively Enabled on 2026-11-11.** The server now destroys the Player instance 5 seconds after the `PlayerRemoving` handlers run, and the Character right after `CharacterRemoving`. Reading `player.leaderstats` after a `task.wait` in `PlayerRemoving` will fail. Phase 3 (end of February 2027) removes the property, so there is no more opt-out. **Bot:** in leave handlers, copy `UserId` and values first, then yield or save. ProfileStore-style session code is fine as long as it doesn't re-read Player children after yielding. [4975616](https://devforum.roblox.com/t/4975616)

**2026-11-04 — Studio MCP: Open Cloud access + asset import Skills.** The `open_cloud_invoke` tool lets an MCP client call any Open Cloud API (game passes, dev products, settings, analytics, asset upload), with per-game permissions. Known issue: in an unsaved place, `execute_luau` can't make HTTP requests, because you can't add domains to the allow list until the place is saved. **Bot:** save or publish the place before testing HTTP. Ask the user before enabling Open Cloud permissions for an agent. [4975849](https://devforum.roblox.com/t/4975849)

**2026-11-03 — `Color3:GetContrastingColor`, `GetContrastRatio`, `GetLuminance`.** These are native helpers for picking readable text colors. **Bot:** use them for accessible text over dynamic backgrounds. [4974212](https://devforum.roblox.com/t/4974212)

**2026-11-03 — Promotional Text (beta).** A short secondary line on the game tile (for example "Limited-time mode") so the game name can stay short. **Bot:** keep game names short and put event text here instead of stuffing it into titles. [4973915](https://devforum.roblox.com/t/4973915)

**2026-11-02 — `DataModel.ServerLowMemoryWarning`.** Fires on live servers when memory goes from normal to high, so scripts can drop debris and effects, pause spawning and log before an out-of-memory crash. **Bot:** connect a cleanup handler in server bootstrap code for large games. [4972486](https://devforum.roblox.com/t/4972486)

**2026-11-02 — Account bans, alt detection, appeals.** A new Game Issues & Appeals page (Creator Hub > Creations > [Game] > Safety > Issues and appeals). Roblox says bans are for severe or repeated violations and use multiple signals; "high-confidence alts" are moderated together with the main account. **Bot:** if the user's game gets a notice, point them to that page. [4972565](https://devforum.roblox.com/t/4972565)

**2026-10-30 — Orthographic Camera (Studio beta).** `Camera.ProjectionType = Enum.ProjectionType.Orthographic` gives true 2D, isometric and top-down views. It defaults to `Perspective`. It is still a Studio beta, so **don't ship it in a published game yet** (uncertain when it will be publishable). [4966772](https://devforum.roblox.com/t/4966772)

**2026-10-30 — Scene Generation** (prototype a scene layout from a prompt) and **Inspect live server during Team Test** (beta). [4966611](https://devforum.roblox.com/t/4966611), [4966700](https://devforum.roblox.com/t/4966700)

**2026-10-29 — Input Action Manager fully released** (Windows > Input > Actions), a table editor for IAS contexts, actions and bindings. **Bot:** create IAS setups as instances; this editor is a good way for the user to audit them. [4965021](https://devforum.roblox.com/t/4965021)

**2026-10-29 — Web Play (creator-only early access).** Creators can test their own games in Chrome (macOS, Windows, Android) via "Play in Browser" in Creator Hub, before Web Play opens to all players. **Bot:** browsers are a new client target to test, especially input and performance. [4964592](https://devforum.roblox.com/t/4964592)

**2026-10-29 — Prompt-to-Avatar (Studio beta)**, which generates game characters. [4964945](https://devforum.roblox.com/t/4964945)

**2026-10-28 — Shapecast upgrade.** Every `Blockcast` / `Spherecast` / `Shapecast` call is more precise and up to 4.1× faster with no code changes. New: `RaycastParams.Margin`, size gradients, CFrame/size overrides, and a Studio visualization mode. **Bot:** for character controllers and melee sweeps, shapecasts with `Margin` are now the recommended tool. [4963119](https://devforum.roblox.com/t/4963119)

**2026-10-28 — Teleports to reserved/VIP servers by ID.** `TeleportOptions.ReservedServerId` and `.VipServerId` (GUID strings) work with `TeleportAsync`. VIP servers can now exist in any place of the universe. Access-code paths still work but print deprecation messages. Setting more than one targeting field raises an error. **Bot:** see TL;DR #5. [4963250](https://devforum.roblox.com/t/4963250)

**2026-10-27 — `AnimatedImage` / `AnimationPlayer` 2D animation (Early Access, Studio-only).** Import Aseprite (`.ase`) files as flipbook animations. Places with these features cannot be published yet. **Bot:** for a 2D game shipping now, still use sprite-sheet `ImageRectOffset` animation. [4960734](https://devforum.roblox.com/t/4960734)

**2026-10-27 — Device Trust API (Android and Web).** Reports a device trust level (Unknown/None/…) based on hardware attestation, so you can gate trading, chat or ranked queues. **Bot:** gate *optional* competitive features, not entry: "Unknown" is common (unsupported platforms, de-Googled phones). [4961129](https://devforum.roblox.com/t/4961129)

**2026-10-22 — Custom Terrain Materials (full launch).** Turn on `Workspace.ExpandedTerrain` for up to 62 custom terrain materials, plus file size and load time improvements. As of 2026-10-27, the client-side performance improvements were rolled back pending a crash fix; custom materials themselves are unaffected. [4950620](https://devforum.roblox.com/t/4950620)

**2026-10-21 — TextChatService "platform-integrated chat": the biggest pending chat migration.** Roblox will make chat native.
- Phase 0 (now): all player-to-player chat must use TCS. Signs, boards, pet names, trade notes and admin-module messaging must go through a `TextChannel` or be rate-limited to one update per minute, or the game may be suspended.
- Phase 1 (until Feb 2027): opt in to test with `TextChatService.PlatformIntegratedChat = Enabled`.
- Phase 2 (Feb 2027): all games are auto-opted in, with an opt-out.
- Phase 3 (May 2027): the updated TCS is the only way to do custom chat.

Replacements: custom chat UI → `TextChannelWindow` (also works in SurfaceGuis, e.g. in-world phones and radios); custom moderation → read-only moderation (18+ moderators); custom commands → `TextChatCommand`; custom presets → Quick Words; custom prefixes → native "role badges" (February 2027). **Message content will no longer be accessible in code.** `ChatWindowConfiguration.TextChannelDisplayMode` filters custom channels out of the default window. `DisplaySystemMessage` (client-side, rich text) remains for announcements. **Bot:** never build a custom chat UI that reads message text. Use the default window or `TextChannelWindow`, use `BubbleChatConfiguration` / `OnBubbleAdded` for overhead styling, and use `TextChatCommand` for commands. [4948433](https://devforum.roblox.com/t/4948433)

**2026-10-19 — In-game EditableImage publishing.** `AssetService:PromptCreateAssetAsync(Instance)` was renamed/replaced by `PromptCreatePlatformContentAsync(Object)`, which can publish an `EditableImage` to the player's inventory. [4944421](https://devforum.roblox.com/t/4944421)

**2026-10-19 — Homepage recommendations require a custom thumbnail.** Games that only have the default placeholder get no Home recommendation impressions. **Bot:** every release checklist must include at least one custom, accurate thumbnail. [4945086](https://devforum.roblox.com/t/4945086)

**2026-10-14 — Upgraded UIShadow (Studio beta)**: text, inset, knockout and gradient shadows. [4934553](https://devforum.roblox.com/t/4934553)

**2026-10-13 — Custom Quick Words.** Creator Hub > game > Configure > Chat > Quick Words: up to 3 custom categories with 3–10 phrases each (English only). They are reviewed before going live and work across age groups without an age check. **Bot:** for games aimed at young or mixed-age players, define gameplay Quick Words ("Follow me", "Trade?") instead of preset-chat GUIs. [4932108](https://devforum.roblox.com/t/4932108)

**2026-10-12 — Simpler publishing.** A single question replaces the full questionnaire to reach 16+ (if there is no restricted content). Early tester access lets you invite up to 10 friends before public launch. Highly Engaged Player counts update hourly. [4930524](https://devforum.roblox.com/t/4930524)

**2026-10-12 — In-game Age Check API + Paid Access gets the 18+ rate.** `Player:PromptAgeCheck()` (non-yielding; one prompt per player per 15 minutes per session, extra calls silently dropped; not supported on console or VR) and the read-only replicated `Player.AgeChecked` (`Enum.AgeCheckStatus.Unchecked/Checked`). **Bot:** prompt only on a deliberate player action, and only gate optional rewards behind `Checked`, never core gameplay. [4607091](https://devforum.roblox.com/t/4607091)

**2026-10-08 — Animation Graphs get State Machines and Luau expressions (Studio beta).** [4921939](https://devforum.roblox.com/t/4921939)

**2026-10-06 — `if local` / `if const` Luau syntax (Studio beta).** `if local hum = char:FindFirstChildWhichIsA("Humanoid") then … end`. **Bot:** this is a beta; don't use it in shipped code until it is released. [4918297](https://devforum.roblox.com/t/4918297)

**2026-10-06 — Collision Summaries.** `BasePart:BindToCollisionSummaries(callback)` gives contact points, normals and relative velocities, which `Touched` never provided. Good for impact VFX and SFX. [4918568](https://devforum.roblox.com/t/4918568)

**2026-10-01 to 09-29 — Frustum Streaming.** `Player.FrustumStreaming` streams what the camera is looking at (scopes, racing roads) without raising the radius in every direction. Web API cookie and IP rate limits were lowered after 2026-10-19; Open Cloud limits are unchanged. [4904553](https://devforum.roblox.com/t/4904553), [4906160](https://devforum.roblox.com/t/4906160)

### 2026 Q3 (July – September)

**2026-09-23 — Transaction Refunded webhook (Open Cloud).** Fires when a Robux purchase in your game is refunded or charged back. It reports the original price. **Bot:** for currency packs, keep a purchase ledger keyed by receipt/transaction so a refund can be revoked. [4890339](https://devforum.roblox.com/t/4890339)

**2026-09-23 — Quad support for EditableMesh (beta).** [4890142](https://devforum.roblox.com/t/4890142)

**2026-09-18 — YouTube videos removed from game pages (from 2026-09-30).** Upload videos in Creator Hub > Configure > Places > Videos. [4879633](https://devforum.roblox.com/t/4879633)

**2026-09-18 — Creator Roadmap Fall update (72 items from RDC26).** Upcoming items include compute functions (serverless Luau), built-in player-data management with session locking and schemas, place branching/merging, adaptive streaming radius, new primitives (Capsule/Cone/Disc/rounded), UI blur, `QueueService`, push notifications, offline play, free trials for passes, and a Safety Callback API. These are *roadmap* items with no dates in the source. **Bot:** don't use them until a release thread exists. [4880208](https://devforum.roblox.com/t/4880208)

**2026-09-11 — RDC26 summary.** 123M daily users, game visits up 55%, about $1.7B DevEx in a year. Highly Engaged Player threshold drops 250 → 100 in November. ~40% fewer bans for "well-intentioned" creators. Early testing. [4865880](https://devforum.roblox.com/t/4865880)

**2026-09-11 — Publishing made easier.** Under-18 creators can use Facial Age Estimation instead of ID. The Kids & Select expedited review fee drops from 100,000 to 50,000 Robux. "Asset Iteration" reduces moderation while a game is still in development. [4865780](https://devforum.roblox.com/t/4865780)

**2026-09-11 — Roblox Wallet and Card.** From December 2026, US 18+ independent creators can opt in to daily USD payouts and repurchase Robux at the DevEx rate ($0.0038). DevEx remains available in the US through mid-2027; groups, 13+ and international follow in 2027. [4865505](https://devforum.roblox.com/t/4865505)

**2026-09-11 — Terrain: scattering, path splines, projected decals, SDF, virtual texturing** (Early Access program). [4865617](https://devforum.roblox.com/t/4865617)

**2026-09-10 — Character Controller Library: new default abilities and custom ability API (Studio beta).** The 2026-11-05 update renamed static functions to camelCase (`ExtendAbility` → `extendAbility`). **Bot:** this library is still changing; pin versions and re-check the API. [4863739](https://devforum.roblox.com/t/4863739)

**2026-09-09 — Roblox-provided discounts on passes and dev products (test).** Roblox funds the discount and the creator is paid on the undiscounted price. Turn on the in-game Shop button. [4861443](https://devforum.roblox.com/t/4861443)

**2026-09-09 — Device Simulator toolbar + Network Simulator (full).** Test latency and packet loss in Studio. [4861695](https://devforum.roblox.com/t/4861695)

**2026-09-02 — Upgraded UIGradient (full release 2026-10-29):** radial, conic and elliptical types, tile modes, scale. [4846594](https://devforum.roblox.com/t/4846594)

**2026-09-03 — WorldModel supports collision groups.** Freecam upgrades. [4848541](https://devforum.roblox.com/t/4848541), [4848482](https://devforum.roblox.com/t/4848482)

**2026-08-31 — Gameplay videos on Home.** Videos autoplay on Recommended For You (hover on desktop, scroll-stop on mobile). Roblox reports up to +39% playtime from RFY for games with video. [4842601](https://devforum.roblox.com/t/4842601), [4502571](https://devforum.roblox.com/t/4502571)

**2026-08-26 — Roblox-native Friends and Global Leaderboards (full release 2026-09-16).** Connect an existing `OrderedDataStore` in Creator Hub; there's no UI to build. `BatchGetAsync` (multiple ordered data store keys per call) arrived 2026-08-10. `Player:GetFriendsWhoPlayedAsync()` (May 2026) returns only friends who played your game. **Bot:** prefer these over hand-rolled friend leaderboards. [4832224](https://devforum.roblox.com/t/4832224), [4644214](https://devforum.roblox.com/t/4644214)

**2026-08-19 — Creator Store publishing requires an age-checked account ≥ 2 days old in good standing.** [4820095](https://devforum.roblox.com/t/4820095)

**2026-08-19 — Highly Engaged Player entry threshold 500 → 250** (the maintenance bar is 25). It goes to 100 in November 2026. [4820164](https://devforum.roblox.com/t/4820164)

**2026-08-19 — Studio MCP multi-agent.** Every tool takes `studio_id`, `set_active_studio` is **removed**, and `list_roblox_studios` returns the Place ID. **Bot:** call `list_roblox_studios` first and pass `studio_id` on every call. [4820583](https://devforum.roblox.com/t/4820583)

**2026-08-19 — `IsVerified` supports verification levels.** [4820514](https://devforum.roblox.com/t/4820514)

**2026-08-06 — Home recommendations value long-term retention and monetization (live for all on 2026-08-20).** Roblox's guidance: if retention is low, fix core gameplay first; if retention is high, add fair, value-adding monetization. **Bot:** this fits `01-game-design-and-success.md`. Retention comes first; monetization never interrupts the core loop. [4779042](https://devforum.roblox.com/t/4779042)

**2026-08-06 — EditableMesh batching and parallel queries (published 2026-09-15).** [4779401](https://devforum.roblox.com/t/4779401)

**2026-08-06 — `InputActionLabel` (Studio beta).** A UI instance that automatically shows the current binding of an `InputAction` (`PreferredBinding`). [4779420](https://devforum.roblox.com/t/4779420)

**2026-07-29 — Predictive Streaming.** Set `Workspace.PredictiveStreamingMode = Enabled` (opt-in) to pre-stream areas the player is likely to need, such as respawn points and teleport targets. [4764052](https://devforum.roblox.com/t/4764052)

**2026-07-23 — Instance attributes (`InstanceHandle`) are live.** An attribute can now reference an Instance directly, so you no longer need `ObjectValue` children. [4753441](https://devforum.roblox.com/t/4753441)

**2026-07-22 — Studio camera navigation update (beta).** [4751512](https://devforum.roblox.com/t/4751512)

**2026-07-15 — Data Stores limits unified and storage raised (live 2026-07-29).** In-game and Open Cloud requests share one per-experience budget per request type (base 300 + CCU multiplier). Storage is **500 MB + 1 MB × lifetime users**. Overages can be paid via Robux deductions or Extended Services (from 2026-04-09). **Bot:** watch the Data Stores Observability dashboard. Large per-player blobs count against the experience total. [4739240](https://devforum.roblox.com/t/4739240), [4504347](https://devforum.roblox.com/t/4504347)

**2026-07-15 — Animation Graphs fully released.** A visual blend tree / state editor for character motion (Avatar tab). [4739840](https://devforum.roblox.com/t/4739840)

**2026-07-15 — Roblox Connect calling APIs shut down.** `SocialService:PromptPhoneBook`, `CanSendCallInviteAsync`, `OnCallInviteInvoked`, `CallInviteStateChanged` and `PhoneBookPromptClosed` no longer function. Use Party Voice. [4684409](https://devforum.roblox.com/t/4684409)

**2026-07-14 — Clipping for rotated GUI elements and Path2D.** `StarterGui.ClipsDescendantsSupportsRotation`: Phase 2 (default Enabled) on 2026-09-24; **Phase 3 (property removed) planned for November 2026**. **Bot:** design UI assuming rotated children are clipped. [4737864](https://devforum.roblox.com/t/4737864)

**2026-07-14 — 2D and 3D avatar item publishing unified.** Upload costs 80 Robux for both; publishing 2D items costs 10 Robux. Uploading needs ID verification or a linked parent; publishing for sale needs ID + 2SV + Plus/Premium. **Bot:** relevant only if the user sells avatar items (see `09-…`). [4722717](https://devforum.roblox.com/t/4722717)

**2026-07-09 — Server Authority fully released.** `Workspace.AuthorityMode = Server` makes the server authoritative for physics and character movement, with client prediction and rollback, so speed hacks are rejected at engine level. It requires **StreamingEnabled**, `SignalBehavior = Deferred` (when in Automatic mode) and IAS for inputs. Tools and backpacks are supported. Breaking change: the camera `InputAction` replication was removed, so use `Player:GetCameraState()` (CFrame, FieldOfView, ViewportSize). It stays opt-in; staff say it "isn't the right decision for all games". **Bot:** consider it for competitive or physics games. Server-side validation of remotes is still required. [4727993](https://devforum.roblox.com/t/4727993), [4606949](https://devforum.roblox.com/t/4606949)

**2026-07-07 — 2D clothing creators lose a large revenue share** (see reactions in §4). [4722717](https://devforum.roblox.com/t/4722717)

**2026-07-06 — `GuiButton.SecondaryActivated`.** One event for right-click, long press (>1 s), controller R3 and Alt+Enter. **Bot:** use it for context menus instead of per-device branches. [4720108](https://devforum.roblox.com/t/4720108)

**2026-07-06 — `GetProductInfo(Async)` creator `Id` returns 0 for group creators.** Use `Creator.CreatorType` + `Creator.CreatorTargetId`. [4666671](https://devforum.roblox.com/t/4666671)

### 2026 Q2 (April – June)

**2026-06-25 — Next-Gen Draggers (beta), LibMP MicroProfiler API (beta), individual game server logs, terrain with up to 64 custom materials (EAP).** [4703155](https://devforum.roblox.com/t/4703155), [4703136](https://devforum.roblox.com/t/4703136), [4703360](https://devforum.roblox.com/t/4703360), [4703282](https://devforum.roblox.com/t/4703282)

**2026-06-24 — Shop: personalized in-game storefront.** Roblox surfaces your passes and dev products to players (Creator Hub > Monetization > Shop). From 2026-09-22 it also has a Robux tab for bonus items. **Bot:** give every product a clear name, icon and description, because the platform UI shows them. [4701505](https://devforum.roblox.com/t/4701505)

**2026-06-22 — Convert-to-Streaming AI Skill (early preview).** Automates making a non-streaming game streaming-compatible. [4697943](https://devforum.roblox.com/t/4697943)

**2026-06-17 — Studio Script Sync fully released.** Edit scripts as files in an external editor, synced with Studio, with conflict resolution and Team Create indicators. An official alternative to Rojo for scripts. [4688454](https://devforum.roblox.com/t/4688454)

**2026-06-17 — Community ownership is managed at the community level.** Community (group) ownership settings moved. [4687884](https://devforum.roblox.com/t/4687884)

**2026-06-16 — Roblox Kids and Select launched globally.** On 2026-06-17 classic games whose owners hadn't done Facial Age Estimation became unavailable (direct links returned 404). The Highly Engaged Player definition was relaxed on 07-06, the maintenance bar lowered 100 → 25 on 07-16, and the entry bar lowered 500 → 250 on 08-19. A refundable Expedited Review option and an Ads Manager "Engagement objective" exist for reaching younger audiences faster. [4685717](https://devforum.roblox.com/t/4685717)

**2026-06-15 — Recommended For You algorithm: 7-day signals become 28-day.** It measures Day 1, Day 2–7 and Day 8–28 playtime, play days, qualified sessions, intentional co-play days and spend. QPTR was removed and play-through rate plus first-play bounce rate were added. Signal importance is shown in Creator Analytics > Acquisition > Home Recommendations. **Bot:** design D1/D7/D28 hooks (daily goals, social co-play, progression) instead of chasing the click-through rate alone. [4684575](https://devforum.roblox.com/t/4684575)

**2026-06-15 — Managed Pricing** unifies Regional Pricing and Price Optimization. New items are auto-enrolled, and you can opt out per item. [4684738](https://devforum.roblox.com/t/4684738)

**2026-06-11 — Input Action System fully released + IAS player scripts.** `Workspace.PlayerScriptsUseInputActionSystem` switches the default PlayerScripts (camera and controls) to IAS. Reported bug at launch: shift-lock combined with ProximityPrompts. **Bot:** default to IAS for new games and turn this property on. [4678416](https://devforum.roblox.com/t/4678416)

**2026-06-10 — Scoped User IDs announced (delayed).** Each new player of a game would get a per-game ID; returning players keep their global ID. The `Player.User` property and `User` datatype are accepted by `UserOwnsGamePassAsync`, `UserHasBadgeAsync` and others. An account-linking API and Ban API cross-game ban lists are promised. The broad rollout was planned for October 2026, but on 2026-09-01 staff said details would come "in October"; **no October thread is in the mirror (uncertain status).** **Bot:** store data keyed by `player.UserId` within your own game only. Don't build cross-game ID-sharing features. [4677155](https://devforum.roblox.com/t/4677155)

**2026-06-09 — `Workspace.ImprovedPhysicsReplication`** (eventual consistency under packet loss) was rolled out 06-15. A temporary `Disabled` option exists while bugs are fixed. [4675512](https://devforum.roblox.com/t/4675512)

**2026-06-04 — Ban API device blocking.** `Players:BanAsync({…, ApplyDeviceBlock = true})`. Structured logging: `LogService:Output/Info/Warn/Error/Log("{name} …", {name = …})` with context tables. [4668265](https://devforum.roblox.com/t/4668265), [4668415](https://devforum.roblox.com/t/4668415)

**2026-06-02 — Extended Services for compute** and expanded Network Simulation. [4665165](https://devforum.roblox.com/t/4665165), [4665487](https://devforum.roblox.com/t/4665487)

**2026-05-27 — Avatar Joint Upgrade Phase 2.** For games with `StarterPlayer.AvatarJointUpgrade = Default`, Motor6D joints are replaced with `AnimationConstraint` + `BallSocketConstraint`. Temporary opt-out: `Disabled`. **Phase 3 (forced) is targeted for the end of 2026.** Templates now ship with AJU on and `CharacterBreakJointsOnDeath = false` (ragdoll-like death). [4656414](https://devforum.roblox.com/t/4656414), [4541689](https://devforum.roblox.com/t/4541689)

**2026-05-26 — Paid Random Items requirements clarified.** See TL;DR #19. A random item bundled into a paid pack makes the whole pack a paid random item. Luck boosts and pity systems count. Test with the Player Emulator in a regulated region. [4654622](https://devforum.roblox.com/t/4654622)

**2026-05-26 — Multi-touch simulation in Studio (full).** [4654721](https://devforum.roblox.com/t/4654721)

**2026-05-21 — Styling Transitions** (no-code tweens in the UI Styling system), fully released 2026-07-27. [4646870](https://devforum.roblox.com/t/4646870)

**2026-05-18 — Procedural Models (full).** Parametric models driven by attributes, which can be generated by code, Assistant or MCP. `AssetService:CreateDataModelContent` (bake editable mesh/image data to session-lifetime Content) is published. [4642542](https://devforum.roblox.com/t/4642542), [4541898](https://devforum.roblox.com/t/4541898)

**2026-05-15 — Transfers: 10,000 Robux/month with 2SV; 16+ transfers no longer need parental approval in most regions.** [4637912](https://devforum.roblox.com/t/4637912)

**2026-05-14 — `UIShadow` and per-corner `UICorner` rounding** (fully released 2026-06-23). **Bot:** native shadows and corners replace 9-slice shadow images; this fits the "native editable GUI" preference. [4636263](https://devforum.roblox.com/t/4636263)

**2026-05-13 — Script Capabilities sandboxing for Creator Store inserts.** Assets inserted from the Store are placed in a sandbox container that blocks "banned capabilities" often used by hidden backdoors. [4634642](https://devforum.roblox.com/t/4634642)

**2026-05-12 — Cross-Server Chat and Chat Summaries live.** Quick Words launched 2026-07-01 with 30 Roblox phrases, auto-enabled, usable across age groups. [4632665](https://devforum.roblox.com/t/4632665)

**2026-05-11 — Alternate publishing path: a refundable 1,000-Robux fee per game** instead of Plus/Premium for all-ages publishing. It is refunded 90 days after eligibility, or 90 days after payment if the game never qualifies. A "highly engaged player" is a user who met a minimum platform purchase in the last 60 days; they don't have to spend in your game. [4630944](https://devforum.roblox.com/t/4630944)

**2026-05-06 — Reimport (full).** One-click updates for imported 3D content. [4622567](https://devforum.roblox.com/t/4622567)

**2026-05-05 — Asset privacy on by default for new accounts and groups.** New Image/Mesh/Decal assets are "Restricted" (permission-checked at load). Audio, video, models, packages and MeshParts are always restricted. **Bot:** if an uploaded image doesn't load in a group game, check sharing permissions. [4620416](https://devforum.roblox.com/t/4620416)

**2026-05-05 — Scene Analysis tool (full).** [4620678](https://devforum.roblox.com/t/4620678)

**2026-05-04 — Cross-game sales of passes and dev products disabled (2026-05-29) + Transfers API.** Transfers carry a 0% platform fee, and the integrating game earns a 10% commission. Senders need Plus, and under-18 users need parental approval. Initial limits were 500/day and 1,000/month (later raised, see 05-15). Robux received via transfer cannot be DevEx'd. **Bot:** "donation" games must use Transfers, not other games' passes. [4618396](https://devforum.roblox.com/t/4618396)

**2026-04-30 — US 18+ DevEx rate.** $0.54 per 100 earned Robux instead of $0.38, from 2026-06-08, for spend by age-checked 18+ US players in eligible games. Eligibility: Avatar Settings = **R15 only**, or a custom ≥15-joint humanoid rig, a non-human rig, or no visible characters. R6 games do not qualify. **Bot:** if the user targets older players, default to R15. [4607091](https://devforum.roblox.com/t/4607091)

**2026-04-30 — Server Authority client beta** (publishable; requires deferred signals and streaming). [4606949](https://devforum.roblox.com/t/4606949)

**2026-04-29 — `RunService:BindToSimulation(callback, frequency, priority)`** runs fixed-rate logic (default `Enum.StepFrequency.Hz30`; a parallel variant exists). `Workspace.UseFixedSimulation` (opt-in) moves engine systems such as animation to a fixed rate. No date has been set for the opt-out phase. **Bot:** put gameplay-critical simulation (vehicles, custom movement) in `BindToSimulation`, not `Heartbeat`/`PreSimulation`. [4605516](https://devforum.roblox.com/t/4605516)

**2026-04-29 — Adaptive Animation (GA)** retargets one animation to any rig. ClientAnimatorThrottling became always-on (no toggle). [4605672](https://devforum.roblox.com/t/4605672), [4568218](https://devforum.roblox.com/t/4568218)

**2026-04-27 — Mesh Streaming and improved cloud LoDs (opt-in).** `Workspace.MeshStreamingAndImprovedLods = Enabled`. The default was planned for "~July 2026", and Phase 3 will remove the property and `MeshPart.RenderFidelity`. **(Uncertain whether Phase 2 has happened; the property is still in the API dump.)** Texture Streaming launched 2025-12-12, and 4K textures are available through it from 2026-01-30. [4601232](https://devforum.roblox.com/t/4601232), [4144855](https://devforum.roblox.com/t/4144855), [4316229](https://devforum.roblox.com/t/4316229)

**2026-04-22 — Private servers.** From 2026-04-30 prices can change every 60 days without cancelling subscriptions, regional pricing is automatic, and group split changes apply immediately. [4590482](https://devforum.roblox.com/t/4590482)

**2026-04-17 — Roblox on smart TVs.** Another 10-foot UI and gamepad target. [4582709](https://devforum.roblox.com/t/4582709)

**2026-04-15 — EditableMesh/EditableImage can load assets *shared* with you**, not only owned ones. [4578818](https://devforum.roblox.com/t/4578818)

**2026-04-13 — New publishing requirements (effective 2026-05-19)** with three tiers: personal / 16+ and Trusted Friends / all ages, plus an evaluation in which games are trialed with age-checked 16+ users and reviewed by real-time multimodal moderation. A move to the IARC rating framework is mentioned as coming "soon". This is the most-liked thread in the mirror (40.9k likes, overwhelmingly negative replies). [4573166](https://devforum.roblox.com/t/4573166)

**2026-04-10 — Roblox Plus** ($4.99/month, rolled out 04-30): 10% discount on Robux purchases of in-game and avatar items (20% from month 3), funded by Roblox; free unlimited paid private servers (creators are paid for Plus time in them); free transfers. Creators get up to 750 Robux per Plus sign-up driven via `MarketplaceService:PromptRobloxSubscriptionPurchase`. Roblox said Premium "will soon no longer be available" **(no sunset date in the sources)**. [4567894](https://devforum.roblox.com/t/4567894)

**2026-04-10 — Automated RTBF processing for Data Stores (beta).** Define deletion templates once to handle Right-to-be-Forgotten requests. [4568086](https://devforum.roblox.com/t/4568086)

**2026-04-09 — StyleQuery** (responsive UI styling, full 2026-05-11). UI Styling (`StyleSheet`/`StyleRule`) has been fully released since 2026-01-20. [4566519](https://devforum.roblox.com/t/4566519), [4275082](https://devforum.roblox.com/t/4275082)

**2026-04-09 — Studio Assistant & MCP Playtest Agent (beta).** [4566767](https://devforum.roblox.com/t/4566767)

**2026-04-08 — Character Controller Library (full).** A Luau-based character controller (`AvatarAbilities`) as an alternative to Humanoid locomotion. On 2026-04-30 default touch thumbstick and jump button positions moved; check that custom mobile UI doesn't overlap them. [4565267](https://devforum.roblox.com/t/4565267)

**2026-04-07 — `ExcludeInstances` / `IncludeInstances` on RaycastParams and OverlapParams**, which can be used together. [4563575](https://devforum.roblox.com/t/4563575)

**2026-04-03 — `AnalyticsService:GetPlayerSegmentsAsync`** returns spender status, active-payer status and tenure. [4556228](https://devforum.roblox.com/t/4556228)

**2026-04-02 — "Connections" renamed back to "Friends"; Trusted Connections → Trusted Friends.** No API change, but update in-game UI text to say "Friends". [4554217](https://devforum.roblox.com/t/4554217)

**2026-04-02 — Animation Graph system (beta, full in July), Universal Importer (full), CSG delta replication.** [4554788](https://devforum.roblox.com/t/4554788), [4554615](https://devforum.roblox.com/t/4554615), [4554628](https://devforum.roblox.com/t/4554628)

**2026-04-01 — Subscriptions can be paid in Robux.** [4552995](https://devforum.roblox.com/t/4552995)

### 2026 Q1 (January – March)

**2026-03-27 — "Advancing Avatars": optional detail bones (clavicle, spine, fingers, toes), RigidConstraints for rigid accessories, attachments under Bones.** Avatars with more than 15 articulations carry a Humanoid Rig Description. The importer has a "Joint Upgrade" vs "Legacy" constraint type. Existing NPC models saved in places are not changed. [4541689](https://devforum.roblox.com/t/4541689)

**2026-03-26 — Team Create requires an age check** (and collaborating across age groups needs Trusted Friends or parental permission, from 2026-06-25). Read-only chat for 18+ moderators. Preset-chat guidelines were tightened ahead of the native Quick Words. [4539725](https://devforum.roblox.com/t/4539725), [4539685](https://devforum.roblox.com/t/4539685)

**2026-03-25 — Server Management.** Targeted server restarts and a server browser in Creator Hub. [4537709](https://devforum.roblox.com/t/4537709)

**2026-03-24 — Voice chat in servers of up to 100.** [4534031](https://devforum.roblox.com/t/4534031)

**2026-03-20 — Advertising Integrations policy (effective 2026-05-04).** Independent in-game brand deals must be registered in Ads Manager and labeled in Studio. All U13 ad formats are COPPA-compliant, with no rewarded formats for under-13s. A revenue share starts in January 2027: around $4–5 CPTV globally for the first 28 days, then $0.10. [4527365](https://devforum.roblox.com/t/4527365)

**2026-03-17 — Communities: multiple roles per member; the 25-Robux role fee was removed.** [4525605](https://devforum.roblox.com/t/4525605)

**2026-03-16 — Search shows 16:9 thumbnails.** **Bot:** make 16:9 thumbnails. [4525356](https://devforum.roblox.com/t/4525356)

**2026-03-12 — Multi-line Command Bar (full); Solid Modeling on meshes (beta).** [4514144](https://devforum.roblox.com/t/4514144), [4515374](https://devforum.roblox.com/t/4515374)

**2026-03-09 — Home changes:** Today's Picks became "Standout Games" (novel games) and RFY added a "deep play-through rate" signal. [4502571](https://devforum.roblox.com/t/4502571)

**2026-03-05 — Regional pricing default for all passes (from 03-30)**; dev products remain opt-in because of gifting and trading arbitrage. [4471199](https://devforum.roblox.com/t/4471199)

**2026-03-05 — Text filter improvements + AI chat rephrasing** (profanity between age-checked similar-age users or Trusted Friends is rephrased instead of hashed). [4474526](https://devforum.roblox.com/t/4474526)

**2026-03-05 — Built-in Studio MCP server** (recommended over the open-source one), with playtest automation, virtual input and streamlined script approval. Screenshot tool `screen_capture` added on 2026-03-19. **Bot:** prefer the built-in server and its playtest tools (`start_stop_play`, `run_script_in_play_mode`, `get_console_output`, `get_studio_mode`). [4474643](https://devforum.roblox.com/t/4474643), [4415631](https://devforum.roblox.com/t/4415631), [4527258](https://devforum.roblox.com/t/4527258)

**2026-03-05 — 2D clothing: publishing needs Premium 1000/2200 (later Plus/Premium); upload fees; delisting from 2026-08-01.** [4474667](https://devforum.roblox.com/t/4474667)

**2026-02-27 — Redesigned Place Version History.** [4451086](https://devforum.roblox.com/t/4451086)

**2026-02-25 — Breaking: `UserHasBadgeAsync` / `CheckUserBadgesAsync` (from 2026-03-23)** no longer report badges from *other* experiences for users not in, or recently in, the server. Your own game's badges are unaffected. [4438920](https://devforum.roblox.com/t/4438920)

**2026-02-24 — Logged-out users can't fetch 3D thumbnails;** use Open Cloud auth. [4435303](https://devforum.roblox.com/t/4435303)

**2026-02-18 — AvatarAbilities library (beta), MaterialVariant Alpha Mode (beta).** [4403904](https://devforum.roblox.com/t/4403904), [4406303](https://devforum.roblox.com/t/4406303)

**2026-02-17 — `HttpService:JSONEncode` encodes `inf`/`-inf`/`NaN` as `{"m":null,"t":"numeric","v":"inf"}`** (rollout from 2026-03-10; the opt-out ended 2026-04-10). Round-trips inside Roblox are unchanged. External servers will see the new objects. [4400205](https://devforum.roblox.com/t/4400205)

**2026-02-12 — Speech-to-Text API (full), emissive masks live, higher texture resolutions for avatars.** [4357786](https://devforum.roblox.com/t/4357786), [4357705](https://devforum.roblox.com/t/4357705)

**2026-02-09 — Server-side teleport control.** You can require that teleports originate from the server, so players can't skip progression-locked places. **Bot:** turn this on and initiate teleports from the server. [4349211](https://devforum.roblox.com/t/4349211)

**2026-02-05 — `TextChatService:GetChatGroupsAsync` / `VoiceChatService:GetChatGroupsAsync`.** These group players who can chat together (used for party/teleport matchmaking). You must opt in under Experience Settings > Communication and agree to the terms. Ages are never exposed, and trying to infer them violates policy. [4337233](https://devforum.roblox.com/t/4337233)

**2026-02-04 — 4D generation (`GenerateModelAsync`); `GenerateMeshAsync` deprecated (migrate by 2026-03-18).** [4331818](https://devforum.roblox.com/t/4331818)

**2026-02-03 — `.ROBLOSECURITY` cookie format changes.** Tools must not parse cookies; use Open Cloud keys or OAuth. [4328913](https://devforum.roblox.com/t/4328913)

**2026-01-28 — Acoustic Simulation (client beta, out of beta 2026-09-22).** Real-time occlusion, reflection and diffraction for **Audio API** emitters only. [4307121](https://devforum.roblox.com/t/4307121)

**2026-01-28 — DevForum and Community Forums age rules (from 2026-03-18).** Posting needs an age check as 13+; DMs and the Collaboration category need 18+. [4306298](https://devforum.roblox.com/t/4306298)

**2026-01-27 — Dynamic Head migration completed (2026-03-23).** All classic heads and faces became Dynamic Heads (head shape + animation toggle). This is the second most-liked thread in the mirror (75k likes on the thread, top replies hostile). **Bot:** don't script against classic `face` Decals on avatar heads; avatars may have animated faces. [4301387](https://devforum.roblox.com/t/4301387)

**2026-01-26 — Avatar Joint Upgrade live (opt-in).** [4298561](https://devforum.roblox.com/t/4298561)

**2026-01-20 — UI Styling fully released.** `StyleSheet`, `StyleRule`, `StyleLink`, and the Style Editor. [4275082](https://devforum.roblox.com/t/4275082)

**2026-01-14 — PSA: yielding methods renamed to `…Async`.** Full list in §2.1. `WaitForChild`, `InvokeServer`/`InvokeClient` and `BindableFunction:Invoke` are *not* renamed. All new yielding methods will end in `Async`. [4257585](https://devforum.roblox.com/t/4257585)

**2026-01-07 — Age Check to Chat live globally.** Users are sorted into age bands, and only similar ages or Trusted Friends can chat. **Bot:** never assume all players in a server can chat with each other. Design cooperation that works without chat (pings, emotes, Quick Words). [4226101](https://devforum.roblox.com/t/4226101), [4238626](https://devforum.roblox.com/t/4238626)

**2026-01-07 — Breaking: `PlayerOwnsAsset(Async)` from a LocalScript about *another* player throws if their inventory is private (from 2026-01-27).** Inventory web APIs follow the same rule. [4226591](https://devforum.roblox.com/t/4226591)

**2026-01-05 — New flexible Studio UI made permanent** (ribbon, custom tabs, density settings). Docs or tutorials showing the old toolbar are outdated. [4085392](https://devforum.roblox.com/t/4085392)

### 2025 H2 (July – December)

**2025-12-16 — 2025 roadmap recap.** [4156739](https://devforum.roblox.com/t/4156739)

**2025-12-12 — Texture Streaming;** "Making Avatar Rendering More Performant". [4144855](https://devforum.roblox.com/t/4144855), [4147160](https://devforum.roblox.com/t/4147160)

**2025-12-11 — Publishing requirements v1 (2025-12-17):** publishing or updating a public experience needed ID verification, a real-money purchase since 2025-01-01, or a recent DevEx. This was replaced by the 2026-05-19 rules (the "Robux spent" option was dropped because it was being circumvented). Experience Betas were added. [4143953](https://devforum.roblox.com/t/4143953), [4144485](https://devforum.roblox.com/t/4144485)

**2025-12-09 — Server Authority Studio beta; System Badges removed from profiles; new Engine API reference site.** [4139157](https://devforum.roblox.com/t/4139157), [4138869](https://devforum.roblox.com/t/4138869), [4116300](https://devforum.roblox.com/t/4116300)

**2025-12-08 — Prompt players to join Communities in-game** (`GroupService:PromptJoinAsync`). [4135599](https://devforum.roblox.com/t/4135599)

**2025-12-04 — Matchmaking "Text Chat signal".** Roblox matchmaking prefers grouping players who can chat; Custom Matchmaking can adjust this. `StudioTestService` lets plugins automate playtests. Open Cloud can configure dev products and passes. [4116099](https://devforum.roblox.com/t/4116099), [4116257](https://devforum.roblox.com/t/4116257), [4114297](https://devforum.roblox.com/t/4114297)

**2025-12-01 — Groups API changes** (members-list privacy setting from January 2026 means a 403 is possible; rate limits). [4109666](https://devforum.roblox.com/t/4109666)

**2025-11-20 — Luau new type solver in general release** (default in nocheck/nonstrict; strict is opt-in); redesigned nonstrict mode. [4084991](https://devforum.roblox.com/t/4084991)

**2025-11-18 — Age checks for chat, Team Create and links announced; ReflectionService** (Luau access to API metadata). [4079702](https://devforum.roblox.com/t/4079702), [4078522](https://devforum.roblox.com/t/4078522)

**2025-11-14 — Verified-badge requirements for experiences updated.** [4070915](https://devforum.roblox.com/t/4070915)

**2025-11-13 — Video previews on game pages; group-owned API keys deprecation deferred.** [4068103](https://devforum.roblox.com/t/4068103), [4068530](https://devforum.roblox.com/t/4068530)

**2025-11-12 — Studio Script Sync beta; improved CSG APIs.** Passes can opt in to the Buy Robux page. [4065468](https://devforum.roblox.com/t/4065468), [4065505](https://devforum.roblox.com/t/4065505), [4065622](https://devforum.roblox.com/t/4065622)

**2025-11-11 — Rewarded Video ads available to all ads-eligible creators.** [4063278](https://devforum.roblox.com/t/4063278)

**2025-11-06 — Custom Matchmaking for all; Configs and Experiments live; "Restricted" label blocked for under-18s.** [4051419](https://devforum.roblox.com/t/4051419), [4051385](https://devforum.roblox.com/t/4051385), [3905863](https://devforum.roblox.com/t/3905863)

**2025-11-03 — Dynamic server CPU (from 2025-11-10)** scales with player count; dynamic server memory has existed since 2024. [4044040](https://devforum.roblox.com/t/4044040), [3293192](https://devforum.roblox.com/t/3293192)

**2025-10-30 — SLIM (lightweight streamed-out avatar models, client beta), emissive masks (beta), PlayerFeedback API.** [4034709](https://devforum.roblox.com/t/4034709), [4034414](https://devforum.roblox.com/t/4034414), [4034161](https://devforum.roblox.com/t/4034161)

**2025-10-28 — `Players.PlayerRemoving(player, exitReason)`** with `Enum.PlayerExitReason` (server only: Unknown / PlatformKick / CreatorKick). [4029827](https://devforum.roblox.com/t/4029827)

**2025-10-23 — WebSockets in Studio** (plugins only); User Provided Default Instances (customize Insert Object defaults). [4021932](https://devforum.roblox.com/t/4021932), [4022156](https://devforum.roblox.com/t/4022156)

**2025-10-09 — Text-to-Speech API (full; 10 more languages added 2026-08-11).** Memory tracking disabled on Android for performance. [3986607](https://devforum.roblox.com/t/3986607), [3986299](https://devforum.roblox.com/t/3986299)

**2025-10-07 — `ApplyDescription` / `CreateHumanoidModelFromDescription` validate asset types server-side by default (from 2025-10-27).** For non-avatar-asset use cases, pass `Enum.AssetTypeVerification.ClientOnly`. Server Authority early access opened. [3982903](https://devforum.roblox.com/t/3982903), [3983188](https://devforum.roblox.com/t/3983188)

**2025-10-03 — ProximityPrompt indicators** (full 2026-04-03). [3976368](https://devforum.roblox.com/t/3976368)

**2025-10-01 — Regional pricing for developer products (opt-in); Creator Store model monetization.** [3971235](https://devforum.roblox.com/t/3971235), [3971041](https://devforum.roblox.com/t/3971041)

**2025-09-29 — Fast Flag allowlist.** Local `ClientAppSettings.json` overrides only work for allowlisted flags. **Bot:** never tell users to tweak FFlags to fix a game. [3966569](https://devforum.roblox.com/t/3966569)

**2025-09-25 — UIStroke improvements** (scaling, offsets; full 2025-12-04). Local light range doubled from 60 to 120. [3958036](https://devforum.roblox.com/t/3958036), [3954367](https://devforum.roblox.com/t/3954367)

**2025-09-18 — Server Management page; 2025-09-17 Data Store deletion** (30-day cooldown). [3941907](https://devforum.roblox.com/t/3941907), [3940169](https://devforum.roblox.com/t/3940169)

**2025-09-16 — Loading third-party model assets in-experience** (InsertService extended to shared assets). [3939065](https://devforum.roblox.com/t/3939065), [3891135](https://devforum.roblox.com/t/3891135)

**2025-09-05 — DevEx +8.5%: $0.0038 per earned Robux** for Robux earned after 2025-09-05 10:00 PT (older balance stays at $0.0035). Early Access Programs launched. [3920159](https://devforum.roblox.com/t/3920159), [3920133](https://devforum.roblox.com/t/3920133)

**2025-08-29 — `AudioPlayer` volume doubled to match `Sound`** (Default = fixed from 2025-09-29; `SoundService.AudioPlayerVolumeFix` removed 2025-10-29). **Bot:** volumes tuned for `AudioPlayer` before October 2025 are now twice as loud. [3907391](https://devforum.roblox.com/t/3907391)

**2025-08-28 — HTTP streaming / Server-Sent Events in Studio; glTF export beta.** [3905367](https://devforum.roblox.com/t/3905367), [3905928](https://devforum.roblox.com/t/3905928)

**2025-08-25 — Unrated experiences unplayable after 2025-09-30**; the questionnaire must be completed per experience. [3899317](https://devforum.roblox.com/t/3899317)

**2025-08-21 — In-experience Avatar Switcher** (disable API live 2026-03-04). [3892696](https://devforum.roblox.com/t/3892696)

**2025-08-20 — Input Action System client beta (publishable).** [3890979](https://devforum.roblox.com/t/3890979)

**2025-08-19 — New Studio UI beta.** [3889612](https://devforum.roblox.com/t/3889612)

**2025-08-15 — HTTP/2 in HttpService; safety policy update** (16+ for social hangouts etc., see 2026-05-12 update). [3882356](https://devforum.roblox.com/t/3882356), [3882864](https://devforum.roblox.com/t/3882864)

**2025-08-14 — `ViewportDisplaySize` API (full 2025-10-21)** gives a device screen-size class for responsive UI. [3880384](https://devforum.roblox.com/t/3880384)

**2025-08-07 — Emulators restricted for players** (an exception lets editors test their own games); avatar creators can sell emotes. [3867040](https://devforum.roblox.com/t/3867040), [3866987](https://devforum.roblox.com/t/3866987)

**2025-08-04 — "Sensitive issues" content descriptor in the Maturity questionnaire** (retake by 2025-09-29). [3860056](https://devforum.roblox.com/t/3860056)

**2025-08-01 — Minimum age and region access settings** (Creator Hub > Audience > Access Settings). [3854020](https://devforum.roblox.com/t/3854020)

**2025-07-31 — "OOF" is the default death sound again; child order now replicates consistently** (`GetChildren` order is the same on client and server). [3852055](https://devforum.roblox.com/t/3852055), [3852381](https://devforum.roblox.com/t/3852381)

**2025-07-29 — Multiple Replication Foci:** `Player:AddReplicationFocus(part)` streams extra areas such as home bases and remote cameras. [3848736](https://devforum.roblox.com/t/3848736)

**2025-07-24 — Creator Rewards live, replacing Engagement-Based Payouts and Creator Affiliate.** The Daily Engagement Reward pays 5 Robux when an *Active Spender* (≥ $9.99 spent in 60 days) spends ≥ 10 minutes in your game, if it's one of the first three experiences they launch that day. The Audience Expansion Reward pays a 35% share of the first $100 spent by new or returning users you bring (requires ≥ 100 average DAU). Both have a 60-day hold. **Bot:** Premium-only payout tricks are obsolete. A satisfying 10-minute+ session and off-platform share links matter. [3777628](https://devforum.roblox.com/t/3777628), [3838257](https://devforum.roblox.com/t/3838257)

**2025-07-21 — Avatar Settings** (Game Settings > Avatar: R6/R15/both, body scale, clothing limits, animation packs). Cube 3D updates. [3828640](https://devforum.roblox.com/t/3828640)

**2025-07-17 — Trusted Connections, age estimation.** [3820020](https://devforum.roblox.com/t/3820020)

**2025-07-16 — EditableMesh/EditableImage improvements** (Content inspector, `Content.fromObject`, vertex/face getters). [3818624](https://devforum.roblox.com/t/3818624)

**2025-07-15 — PBR for avatar accessories; Licenses catalog (IP partnerships).** [3816937](https://devforum.roblox.com/t/3816937), [3816457](https://devforum.roblox.com/t/3816457)

**2025-07-08 — `SavePlaceAsync` works for all places.** [3805169](https://devforum.roblox.com/t/3805169)

### 2025 H1 (January – June)

**2025-06-30 — Text-to-Speech beta.** [3792085](https://devforum.roblox.com/t/3792085)

**2025-06-23 — Next Gen Explorer rolled out to everyone.** [3774759](https://devforum.roblox.com/t/3774759)

**2025-06-18 — New Experience Event APIs.** [3754058](https://devforum.roblox.com/t/3754058)

**2025-06-17 — Detached Attachments:** `Attachment`s can be parented to anything (live 2025-09-02). **`UserInputService.PreferredInput`** (full 2025-10-14). [3750286](https://devforum.roblox.com/t/3750286), [3750890](https://devforum.roblox.com/t/3750890)

**2025-06-12 — Content maturity moderation process clarified.** [3709028](https://devforum.roblox.com/t/3709028)

**2025-06-03 — Party API; regional pricing for avatar items.** `SkyboxOrientation` beta (06-02). [3676068](https://devforum.roblox.com/t/3676068), [3674945](https://devforum.roblox.com/t/3674945)

**2025-05-30 — Open Cloud usage policy changes.** [3671058](https://devforum.roblox.com/t/3671058)

**2025-05-22 — UI Styling Studio beta; Haptic Effects publishable.** [3660722](https://devforum.roblox.com/t/3660722), [3660577](https://devforum.roblox.com/t/3660577)

**2025-05-19 — Input Action System Studio beta; HttpService can call Open Cloud (`apis.roblox.com`) without proxies (beta).** [3656214](https://devforum.roblox.com/t/3656214), [3656373](https://devforum.roblox.com/t/3656373)

**2025-05-13 — Open-source Studio MCP server** (proof of concept, now superseded by the built-in server). [3649365](https://devforum.roblox.com/t/3649365)

**2025-05-06 — Automated action against modified clients rolled out to all users** (since 2025-05-30, editors are exempt in their own places). [3640609](https://devforum.roblox.com/t/3640609)

**2025-05-01 — Next Gen Studio beta, Acoustic Simulation Studio beta, Comments in Studio.** [3634123](https://devforum.roblox.com/t/3634123), [3634265](https://devforum.roblox.com/t/3634265)

**2025-04-29 — DataStore migration packages for Berezaa method / DataStore2.** [3631514](https://devforum.roblox.com/t/3631514)

**2025-04-21 — Roblox Extended Services; regional pricing for passes.** [3621439](https://devforum.roblox.com/t/3621439), [3621382](https://devforum.roblox.com/t/3621382)

**2025-04-07 — DataStores access limits per experience; storage limits announced; Data Stores Manager.** [3597255](https://devforum.roblox.com/t/3597255), [3597219](https://devforum.roblox.com/t/3597219)

**2025-04-08 — Custom Matchmaking beta; reorder badges.** [3598471](https://devforum.roblox.com/t/3598471)

**2025-03-31 — Recommended For You improvements and analytics; improved sleep system.** [3587441](https://devforum.roblox.com/t/3587441), [3587885](https://devforum.roblox.com/t/3587885)

**2025-03-20 — Cube 3D (text-to-mesh `GenerateMeshAsync`, later deprecated in favour of `GenerateModelAsync`).** [3558947](https://devforum.roblox.com/t/3558947)

**2025-03-18 — Text Generation API beta.** [3556520](https://devforum.roblox.com/t/3556520)

**2025-03-10 — `PathfindingUseImprovedSearch` restored (opt-in); TextChatService on console.** [3258657](https://devforum.roblox.com/t/3258657), [3545185](https://devforum.roblox.com/t/3545185)

**2025-02-24 — Scroll/trackpad delta behavior changed** (now on all platforms). [3505033](https://devforum.roblox.com/t/3505033)

**2025-02-21 — Sell developer products on the experience details page.** [3494897](https://devforum.roblox.com/t/3494897)

**2025-01-22 — Require-by-string:** `require("./Child")`, `require("@game/ReplicatedStorage/Module")` (the `@game` alias was added 2026-01-08). [3405078](https://devforum.roblox.com/t/3405078)

**2025-01-21 — Unified Lighting (fully live 2025-07-23):** `Lighting.Technology` is auto-mapped (Future → Realistic + PrioritizeLightingQuality; ShadowMap → Soft + Prioritize; Voxel → Soft without Prioritize). [3401512](https://devforum.roblox.com/t/3401512)

**2025-01-13 — Legacy chat retirement date 2025-04-30; auto-migration from May 2025.** [3376880](https://devforum.roblox.com/t/3376880)

**2025-01-08 — Plan against account farming and exploits.** [3360580](https://devforum.roblox.com/t/3360580)

### 2024 (highlights)

- **2024-12-20 — Studio requires Windows 10+ and macOS 10.14+ (from 2025-03-20).** [3312418](https://devforum.roblox.com/t/3312418)
- **2024-12-10 — Occlusion culling live in the client** (terrain support 2025-06-23). Don't build your own culling for interiors. [3300953](https://devforum.roblox.com/t/3300953)
- **2024-12-09 — Low-quality and copycat experiences deprioritized in recommendations** (thumbnails, titles, descriptions or placefiles that resemble existing games). [3299107](https://devforum.roblox.com/t/3299107)
- **2024-12-06 — WrapDeformer.** 2024-12-05 — Assistant full release; `CreateAssetAsync` for tooling (beta). [3294953](https://devforum.roblox.com/t/3294953)
- **2024-12-03 — Under-13s can't play experiences without a maturity label.** [3249079](https://devforum.roblox.com/t/3249079)
- **2024-12-02 — Audio API: directional audio, AudioLimiter. Data Stores "version at time".** [3282100](https://devforum.roblox.com/t/3282100), [3283017](https://devforum.roblox.com/t/3283017)
- **2024-11-21 — Groups renamed to Communities.** [3268307](https://devforum.roblox.com/t/3268307)
- **2024-11-20 — EditableMesh/EditableImage publishable (client beta).** Requires 13+, an ID-verified owner and the Game Settings > Security "Allow Mesh / Image APIs" toggle; creation is subject to a memory budget and may return nil; call `:Destroy()`. Since 2026-04 assets shared with you also work. TouchSwipe updated and TouchDrag added. [3267293](https://devforum.roblox.com/t/3267293), [3266901](https://devforum.roblox.com/t/3266901)
- **2024-11-14 — Improved pathfinding algorithm** (`PathfindingUseImprovedSearch`). [3258657](https://devforum.roblox.com/t/3258657)
- **2024-11-11 — Integrate `TextChatService:CanUsersDirectChatAsync` / `TextChannel:SetDirectChatRequester`** for custom direct chat. [3255672](https://devforum.roblox.com/t/3255672)
- **2024-10-30 — Migrate to TextChatService: legacy and custom chat systems lose support.** [3237100](https://devforum.roblox.com/t/3237100)
- **2024-10-29 — Future lighting fully rolled out on Android.** [3235808](https://devforum.roblox.com/t/3235808)
- **2024-10-25 — Script Capabilities preview (sandboxing).** [3228100](https://devforum.roblox.com/t/3228100)
- **2024-10-15 — New in-experience controls (top bar) live.** Keep the top corners clear (see `03-ui-ux-design.md`). [3215981](https://devforum.roblox.com/t/3215981)
- **2024-10-08 — User-to-user inbox messaging sunset (2024-10-29).** [3187502](https://devforum.roblox.com/t/3187502)
- **2024-09-26 — Improved genres and subgenres.** [3173148](https://devforum.roblox.com/t/3173148)
- **2024-09-24 — `IsOnline` removed from `GetFriendsAsync`; friend limit 1,000.** [3171177](https://devforum.roblox.com/t/3171177)
- **2024-09-17 — All places migrated to Shorelines water** (old water sunset). [3162811](https://devforum.roblox.com/t/3162811), [3007235](https://devforum.roblox.com/t/3007235)
- **2024-09-16 — PlayerCharacterDestroyBehavior default flip attempted, then suspended** (it finally lands 2026-11-11). [3161577](https://devforum.roblox.com/t/3161577)
- **2024-09-12 — New type solver beta.** 2024-09-10 — **Audio API exits beta.** Paid random items blocked for Australian users from 2024-09-20 (UK under-18s from August 2024). [3153454](https://devforum.roblox.com/t/3153454), [3153602](https://devforum.roblox.com/t/3153602), [3072183](https://devforum.roblox.com/t/3072183)
- **2024-08-29 — `BindToClose(function(closeReason))`** receives `Enum.CloseReason`. [3139159](https://devforum.roblox.com/t/3139159)
- **2024-08-21 — Compatibility lighting removed → Voxel + `ColorGradingEffect.TonemapperPreset = Retro`; `ColorGradingEffect`.** [3128560](https://devforum.roblox.com/t/3128560)
- **2024-08-19 — `BadgeService:CheckUserBadgesAsync`** (batch). [3125886](https://devforum.roblox.com/t/3125886)
- **2024-08-14 — 8 new base materials released; Studio visualization modes.** [3118321](https://devforum.roblox.com/t/3118321), [3118441](https://devforum.roblox.com/t/3118441)
- **2024-08-08 — UIDragDetector released.** [3109263](https://devforum.roblox.com/t/3109263)
- **2024-07-31 — UIListLayout flex features (`UIFlexItem`) released.** [3096190](https://devforum.roblox.com/t/3096190)
- **2024-07-22 — Non-sequential asset IDs** (the decal-ID-minus-one trick is dead; load the Decal and read its texture). [3082004](https://devforum.roblox.com/t/3082004)
- **2024-07-12 — `OpenTypeFeatures`.** 2024-07-11 — `GrassLength` released. 2024-07-08 — Highlights outlines on mobile. [3065736](https://devforum.roblox.com/t/3065736), [3064300](https://devforum.roblox.com/t/3064300), [3059061](https://devforum.roblox.com/t/3059061)
- **2024-07-02 — Improved mover constraints** (stability, network ownership). [3050174](https://devforum.roblox.com/t/3050174)
- **2024-06-25 — Ban API (`Players:BanAsync`) and alt detection.** [3039740](https://devforum.roblox.com/t/3039740)
- **2024-06-17 — Path2D released.** [3027288](https://devforum.roblox.com/t/3027288)
- **2024-06-04 — User Ads sunset** (Sponsored Experiences / Ads Manager instead). [3004673](https://devforum.roblox.com/t/3004673)
- **2024-05-30 — Max framerate setting** (players can run above 60 FPS, so use delta time everywhere). [2995965](https://devforum.roblox.com/t/2995965)
- **2024-05-29 — Avatar Importer plugin deprecated** (use the 3D Importer). [2994923](https://devforum.roblox.com/t/2994923)
- **2024-05-23 — Public sound effect uploads.** [2980704](https://devforum.roblox.com/t/2980704)
- **2024-04-24 — In-experience CSG APIs (`UnionAsync` etc.) publishable.** [2944380](https://devforum.roblox.com/t/2944380)
- **2024-04-17 — LinkedSource scripts sunset** (use Packages). [2934824](https://devforum.roblox.com/t/2934824)
- **2024-04-05 — Player counts on tiles changed.** [2914339](https://devforum.roblox.com/t/2914339)
- **2024-03-27 — Secrets Store GA** (`HttpService:GetSecret`). [2892154](https://devforum.roblox.com/t/2892154)
- **2024-03-13 — 16:9 thumbnails on Home.** [2875237](https://devforum.roblox.com/t/2875237)
- **2024-03-07 — Builder font; Gotham and Arial removed 2024-05-28** (mapped to Montserrat and Arimo). [2868222](https://devforum.roblox.com/t/2868222)
- **2024-02-22 — New Audio API beta.** [2848873](https://devforum.roblox.com/t/2848873)
- **2024-02-12 — MessagingService limits raised.** [2835576](https://devforum.roblox.com/t/2835576)
- **2024-02-06 — Experience Notifications.** [2826474](https://devforum.roblox.com/t/2826474)
- **2024-01-22 — Generalized shapecasts (`WorldRoot:Shapecast`).** [2805975](https://devforum.roblox.com/t/2805975)

### 2023 (highlights)

- **2023-12-01 — EditableMesh/EditableImage Studio beta; Assistant beta.** [2725284](https://devforum.roblox.com/t/2725284)
- **2023-11-30 — Luau `buffer` type.** 2023-11-29 — **`UnreliableRemoteEvent`** (payload up to 1,000 bytes since 2025-03). [2724894](https://devforum.roblox.com/t/2724894), [2724155](https://devforum.roblox.com/t/2724155)
- **2023-11-28 — Deferred events:** templates default to `SignalBehavior = Deferred`. Staff said Immediate mode would remain "for the foreseeable future". **Bot:** use Deferred in new places (Server Authority requires it). [2723113](https://devforum.roblox.com/t/2723113)
- **2023-11-21 — `PlayerCharacterDestroyBehavior` introduced (opt-in).** [2711317](https://devforum.roblox.com/t/2711317)
- **2023-11-09 — UIListLayout flex beta; physics usability.** [2694081](https://devforum.roblox.com/t/2694081)
- **2023-10-11 — DragDetectors released.** [2641956](https://devforum.roblox.com/t/2641956)
- **2023-09-29 — Character physics controllers** (`ControllerManager`, `GroundController`, `AirController`…). [2623426](https://devforum.roblox.com/t/2623426)
- **2023-09-01 — `SurfaceGui.MaxDistance`.** [2574715](https://devforum.roblox.com/t/2574715)
- **2023-08-24 — R6→R15 adapter.** [2557840](https://devforum.roblox.com/t/2557840)
- **2023-08-16 — Legacy CSG engines (v1/v2) sunset 2023-09-18.** [2531375](https://devforum.roblox.com/t/2531375)
- **2023-07-10 — StreamingEnabled is on by default in all new templates.** [2462204](https://devforum.roblox.com/t/2462204)
- **2023-07-06 — `PhysicsSteppingMethod` default Adaptive.** [2455212](https://devforum.roblox.com/t/2455212)
- **2023-06-23 — Data Stores 6-second write cooldown removed.** [2436230](https://devforum.roblox.com/t/2436230)
- **2023-06-20 — 17+ experiences** (later "Restricted", now 18+). [2432184](https://devforum.roblox.com/t/2432184)
- **2023-05-31 — Wind (`Workspace.GlobalWind`) released; Parallel Luau v2.** [2400083](https://devforum.roblox.com/t/2400083), [2399970](https://devforum.roblox.com/t/2399970)
- **2023-05-08 — api.roblox.com sunset 2023-05-22.** [2324429](https://devforum.roblox.com/t/2324429)
- **2023-05-05 — Shapecasts (`Blockcast`, `Spherecast`).** [2320655](https://devforum.roblox.com/t/2320655)
- **2023-05-03 — PointsService retired 2023-06-30** (calls return 0). [2318767](https://devforum.roblox.com/t/2318767)
- **2023-03-16 — TextChatService default for new experiences.** [2220324](https://devforum.roblox.com/t/2220324)
- **2023-03-31 — `Workspace.RejectCharacterDeletions` default Enabled.** [2269179](https://devforum.roblox.com/t/2269179)
- **2023-03-02 — Model scale API (`Model:ScaleTo`).** [2205722](https://devforum.roblox.com/t/2205722)
- **2023-02-23 — Tool inherits from Model.** [2196081](https://devforum.roblox.com/t/2196081)
- **2023-01-06 — StreamingIntegrityMode.** [2129797](https://devforum.roblox.com/t/2129797)
- **2023-01-04 — String interpolation (`` `Hello {name}` ``) available.** [2127058](https://devforum.roblox.com/t/2127058)

---

## 2. Deprecated → use instead

Sources: the `[Deprecated]` tags in `reference/api/API-Dump.txt`, the Creator Docs YAML, and the announcements above. "Still works" means the old member functions but must not appear in new code. **Removed** means it no longer functions.

### 2.1 The 2026 `…Async` renames ([4257585](https://devforum.roblox.com/t/4257585))

Old names are deprecated but will *not* be removed. Use the right column.

| Deprecated | Use instead |
|---|---|
| `Player:LoadCharacter()` | `Player:LoadCharacterAsync()` |
| `Player:LoadCharacterWithHumanoidDescription()` | `Player:LoadCharacterWithHumanoidDescriptionAsync()` |
| `Player:IsInGroup()` | `Player:IsInGroupAsync()` |
| `Player:GetRankInGroup()` / `GetRoleInGroup()` | `GroupService:GetRolesInGroupAsync(userId, groupId)`. Note that `GetRankInGroupAsync`/`GetRoleInGroupAsync` are **also** tagged Deprecated in the dump; the docs say `GetRolesInGroupAsync` supersedes them (it returns all public roles, highest first, with a stable role `Id`). |
| `Player:IsFriendsWith()` | `Player:IsFriendsWithAsync()` |
| `Player:GetFriendsOnline()` | `Player:GetFriendsOnlineAsync()` |
| `MarketplaceService:GetProductInfo()` | `MarketplaceService:GetProductInfoAsync()` |
| `MarketplaceService:PlayerOwnsAsset()` | `PlayerOwnsAssetAsync()` (server-side for other players) |
| `MarketplaceService:PlayerOwnsBundle()` | `PlayerOwnsBundleAsync()` |
| `BadgeService:AwardBadge()` | `BadgeService:AwardBadgeAsync()` |
| `BadgeService:UserHasBadge()` | `BadgeService:UserHasBadgeAsync()` / `CheckUserBadgesAsync()` |
| `Humanoid:ApplyDescription()` / `ApplyDescriptionReset()` | `ApplyDescriptionAsync()` / `ApplyDescriptionResetAsync()` |
| `Humanoid:PlayEmote()` | `Humanoid:PlayEmoteAsync()` |
| `Players:CreateHumanoidModelFromDescription()` / `FromUserId()` | `…Async()` |
| `Players:GetHumanoidDescriptionFromUserId()` / `FromOutfitId()` | `…Async()` |
| `TeleportService:ReserveServer()` | Docs: **don't use `ReserveServerAsync` either** (also deprecated). Use `TeleportOptions.ReservedServerId = HttpService:GenerateGUID()` + `TeleportAsync`. |
| `InsertService:GetFreeModels()` / `GetFreeDecals()` | `…Async()` |
| `AvatarEditorService:*` (GetInventory, GetItemDetails, SearchCatalog, GetOutfits, PromptSave…, etc.) | the `…Async` variants |
| `AssetService:SearchAudio()` / `GetAssetIdsForPackage()` | `…Async()` |
| `SocialService:PromptLinkSharing()` | `PromptLinkSharingAsync()` |
| `Plugin:CreateDockWidgetPluginGui()`, `PromptSaveSelection()`, `ImportFbx*()` | `…Async()` |
| `TestService:Run()` | `TestService:RunAsync()` |

### 2.2 Common game-script deprecations (API-dump verified)

| Deprecated / removed | Use instead | Notes |
|---|---|---|
| `wait()`, `spawn()`, `delay()` (globals) | `task.wait()`, `task.spawn()`, `task.delay()`, `task.defer()` | Tagged Deprecated in the docs globals. `tick()` isn't deprecated but has issues: use `os.clock()` / `workspace:GetServerTimeNow()`. |
| `Humanoid:LoadAnimation()` | `Animator:LoadAnimation()` (Animator under Humanoid or AnimationController) | Also lowercase `loadAnimation`. `AnimationController:LoadAnimation` is deprecated too; `AnimationController` itself is tagged Deprecated in the dump, but docs still describe it as the Humanoid-less animation host **(uncertain; prefer Animator)**. |
| `Humanoid:GetPlayingAnimationTracks()` | `Animator:GetPlayingAnimationTracks()` | |
| `Humanoid` status API (`AddStatus`, `HasCustomStatus`, …), `takeDamage` | Attributes / your own state; `TakeDamage` | |
| `WorldRoot:FindPartOnRay*` | `WorldRoot:Raycast(origin, direction, RaycastParams)` | |
| `FindPartsInRegion3*`, `IsRegion3Empty*` | `GetPartBoundsInBox`, `GetPartBoundsInRadius`, `GetPartsInPart` + `OverlapParams` | |
| `RaycastParams.FilterDescendantsInstances` + `FilterType` | `ExcludeInstances` / `IncludeInstances` (2026-04) | The old fields still work. [4563575](https://devforum.roblox.com/t/4563575) |
| `Model:SetPrimaryPartCFrame()` / `GetPrimaryPartCFrame()` / `GetModelCFrame()` / `GetModelSize()` | `Model:PivotTo()`, `GetPivot()`, `GetBoundingBox()`, `GetExtentsSize()` | |
| `Model:move()` / `moveTo()` (lowercase) | `Model:MoveTo()` (not deprecated) or `PivotTo()` | |
| `BasePart:BreakJoints()` / `MakeJoints()`, `Model:BreakJoints()` | Destroy specific `WeldConstraint`s / joints | Surface-based auto-joining is gone. |
| `BasePart.Velocity` / `RotVelocity` | `AssemblyLinearVelocity` / `AssemblyAngularVelocity` | |
| `BasePart:GetRootPart()`, `getMass()` | `BasePart.AssemblyRootPart`, `AssemblyMass` / `GetMass()` | |
| `BasePart.CollisionGroupId`, `PhysicsService:SetPartCollisionGroup()`, `CreateCollisionGroup()`, `GetCollisionGroups()` … | `BasePart.CollisionGroup = "Name"`, `PhysicsService:RegisterCollisionGroup()`, `GetRegisteredCollisionGroups()`, `CollisionGroupSetCollidable()` | WorldModel collision groups since 2026-09. |
| `BodyVelocity`, `BodyPosition`, `BodyGyro`, `BodyForce`, `BodyThrust`, `BodyAngularVelocity`, `RocketPropulsion` (all `BodyMover`s) | `LinearVelocity`, `AlignPosition`, `AlignOrientation`, `VectorForce`, `AngularVelocity`, `Torque` | The whole class family is Deprecated. |
| `Hint`, `Message` | ScreenGui + TextLabel | |
| `Hat` | `Accessory` | |
| `HopperBin` | `Tool` (or IAS-driven abilities) | |
| `GamePassService` | `MarketplaceService:UserOwnsGamePassAsync()` | |
| `PointsService` | Data Stores | **Removed** 2023-06-30. |
| `Player:SaveNumber/LoadNumber/SaveData/…` (Data Persistence) | `DataStoreService` (via ProfileStore) | |
| `GlobalDataStore:OnUpdate()` | `MessagingService` | |
| `DataStore:RemoveVersionAsync()` | Version APIs (`ListVersionsAsync`, `GetVersionAtTimeAsync`) | |
| `GuiObject:TweenPosition/TweenSize/TweenSizeAndPosition` | `TweenService:Create()` or Styling Transitions | |
| `GuiObject.Draggable`, `DragBegin/DragStopped` | `UIDragDetector` | |
| `TextLabel/TextButton/TextBox.FontSize`, `TextWrap`, `TextColor` | `TextSize`, `TextWrapped`, `TextColor3` (+ `FontFace`) | |
| `GuiObject.Transparency`, `BackgroundColor`, `BorderColor` | `BackgroundTransparency`, `BackgroundColor3`, `BorderColor3` (better: `UIStroke`) | |
| `Lighting.Technology` | `Lighting.LightingStyle` + `PrioritizeLightingQuality` | [3401512](https://devforum.roblox.com/t/3401512) |
| `Lighting.Outlines`, `ShadowColor` | none (removed visuals) | |
| Compatibility lighting | Voxel + `ColorGradingEffect.TonemapperPreset = Retro` | Removed 2024. |
| `Sound.Pitch`, `MinDistance`/`MaxDistance`/`EmitterSize`, `isPlaying`, `play()/stop()/pause()` lowercase | `PlaybackSpeed`, `RollOffMinDistance`/`RollOffMaxDistance`, `IsPlaying`, `Play()/Stop()/Pause()`, or the Audio API | |
| `AudioPlayer.AssetId` | `AudioPlayer.Asset` → `AudioContent` (Nov 2026) | |
| `Decal.Texture`, `MeshPart.MeshId/TextureID`, `ImageLabel.Image`, `Sound.SoundId`, `Sky.Skybox*`, `Shirt.ShirtTemplate`… | the `*Content` properties (`TextureContent`, `MeshContent`, `ImageContent`, `AudioContent`, `SkyboxBackContent`, `ShirtTemplateContent` …) with `Content.fromAssetId()` | **Not deprecated-tagged.** The old names stay readable and writable, but Studio serializes Content from 2026-11-11. [4975546](https://devforum.roblox.com/t/4975546) |
| `Mouse` (`Player:GetMouse()`), `Mouse.KeyDown/KeyUp`, `Mouse.hit/target` (lowercase) | IAS (`InputAction`), `UserInputService`, `Camera:ViewportPointToRay` + `Raycast` | `Mouse.Hit/Target` (capitalized) aren't tagged, but avoid them in new code. |
| `ContextActionService:BindActionToInputTypes()` | IAS, or `BindAction` | CAS isn't deprecated, but IAS is the recommended system and Server Authority needs it. |
| `UserInputService.ModalEnabled`, `UserHeadCFrame`, `GetUserCFrame` (UIS) | `VRService:GetUserCFrame()` / IAS | |
| `UserInputService` touch/keyboard heuristics to guess the device | `UserInputService.PreferredInput` | [3750890](https://devforum.roblox.com/t/3750890) |
| `Chat` service, `Chat:FilterStringForPlayerAsync`, Lua Chat System, custom chat | `TextChatService` (`TextChannel`, `TextChatCommand`, `TextChannelWindow`, `BubbleChatConfiguration`); `TextService:FilterStringAsync` for non-chat text | Legacy chat **removed** 2025-04-30. |
| Custom chat UIs that read message text | `TextChannelWindow` (by May 2027) | [4948433](https://devforum.roblox.com/t/4948433) |
| `PolicyService` external link reference (`GetExternalLinkReference`) | none (returns empty); link from the game page | [4226101](https://devforum.roblox.com/t/4226101) |
| `TeleportService:TeleportToPrivateServer()`, `TeleportPartyAsync()`, `TeleportToPlaceInstance()`, `TeleportToSpawnByName()` | `TeleportService:TeleportAsync(placeId, players, TeleportOptions)` with `ServerInstanceId` / `ReservedServerId` / `VipServerId` | |
| `TeleportOptions.ShouldReserveServer`, `ReservedServerAccessCode` | `TeleportOptions.ReservedServerId` | [4963250](https://devforum.roblox.com/t/4963250) |
| `DataModel.VIPServerId` / `VIPServerOwnerId` | `game.PrivateServerId` / `game.PrivateServerOwnerId` | |
| `Players.NumPlayers`, `Players:getPlayers()`, `playerFromCharacter` (lowercase), `Player.userId` | `#Players:GetPlayers()`, `GetPlayers()`, `GetPlayerFromCharacter()`, `Player.UserId` (and `Player.User` for scoped IDs) | |
| `Instance:Remove()`, `remove()`, `clone()`, `destroy()`, `findFirstChild()`, `children()`, `getChildren()`, `isDescendantOf()` | `Destroy()`, `Clone()`, `FindFirstChild()`, `GetChildren()`, `IsDescendantOf()` | |
| `CollectionService:GetCollection()`, `ItemAdded/ItemRemoved` | `GetTagged()`, `GetInstanceAddedSignal()`/`GetInstanceRemovedSignal()` | |
| `Debris:addItem()`, `Debris.MaxItems` | `Debris:AddItem()` or `task.delay(t, inst.Destroy, inst)` | |
| `Camera.CoordinateFrame`, `Camera.focus`, `Camera:Interpolate()` | `Camera.CFrame`, `Camera.Focus`, `TweenService` | |
| `Attachment.Rotation/WorldRotation`, `SetAxis/GetAxis` | `Attachment.CFrame`/`Orientation`, `Axis`/`SecondaryAxis` | |
| `BillboardGui.DistanceLowerLimit/UpperLimit` | `MaxDistance`, `DistanceStep` | |
| `StarterGui.ResetPlayerGuiOnSpawn` | `ScreenGui.ResetOnSpawn` | |
| `Workspace.FilteringEnabled` | always on; meaningless | |
| `DataModel.OnClose` | `game:BindToClose(function(closeReason) … end)` | |
| `PathfindingService:ComputeRawPathAsync/ComputeSmoothPathAsync` | `PathfindingService:CreatePath()` + `Path:ComputeAsync()` | |
| `Terrain:SetCell/GetCell/…` | `Terrain:FillBlock/FillBall/WriteVoxels/ReadVoxels` | |
| `BaseScript.LinkedSource` | Packages | LinkedSource sunset 2024. |
| `SocialService` Roblox Connect calling (`PromptPhoneBook`, `CanSendCallInviteAsync`, …) | Party Voice | **Removed** 2026-07-15. [4684409](https://devforum.roblox.com/t/4684409) |
| `GenerateMeshAsync` (Cube text-to-mesh) | `GenerateModelAsync` (4D generation) | Deprecated, migrate by 2026-03-18. [4331818](https://devforum.roblox.com/t/4331818) |
| `AssetService:PromptCreateAssetAsync(Instance)` | `AssetService:PromptCreatePlatformContentAsync(Object)` | [4944421](https://devforum.roblox.com/t/4944421) |
| `GetFriendsAsync` item field `IsOnline` | `Player:GetFriendsOnlineAsync()` | [3171177](https://devforum.roblox.com/t/3171177) |
| `GetProductInfo` creator field `Id` (now 0 for groups) | `Creator.CreatorType` + `Creator.CreatorTargetId` | [4666671](https://devforum.roblox.com/t/4666671) |
| `Player.InputContexts.CameraContext.CameraAction` (camera replication under Server Authority) | `Player:GetCameraState()` | [4727993](https://devforum.roblox.com/t/4727993) |
| Fonts Gotham / Arial | Builder, Montserrat, Arimo (`Font.new(...)` / `FontFace`) | Removed 2024-05-28. |
| Classic heads / faces (avatar) | Dynamic Heads | Migrated 2026-03-23. |
| `Motor6D`-based R15 joints on player avatars | `AnimationConstraint` / `BallSocketConstraint` (AJU) | Forced by end of 2026. |
| Welds for rigid accessories | `RigidConstraint` to Attachments (maybe under Bones) | |
| Engagement-Based Payouts, Creator Affiliate | Creator Rewards | Ended 2025-07-24. |
| Cross-game pass / dev product sales | Transfers API | Disabled 2026-05-29. |
| YouTube video on game page | Creator Hub video upload | Removed 2026-09-30. |
| User Ads (banner ads) | Ads Manager (Sponsored, Search ads, Rewarded video) | Sunset 2024. |
| Open-source Studio MCP server, `set_active_studio` | Built-in Studio MCP, `studio_id` per call | |
| Old Studio toolbar, old Explorer | Next-gen Studio UI (default 2026-01-05), Next Gen Explorer | |
| Avatar Importer plugin | 3D Importer / Universal Importer | |
| Legacy CSG v1/v2 | CSGv3 (`UnionAsync`/`SubtractAsync`/`IntersectAsync`, GeometryService) | |
| Old water | Shorelines | 2024-09. |
| Decal-ID-minus-one image ID trick | Load the Decal asset and read `Texture`/`TextureContent` | Non-sequential IDs since 2024. |
| Web endpoints with cookie auth (badges, inventory, groups, thumbnails, `api.roblox.com`) | Open Cloud with API keys / OAuth; HttpService can call `apis.roblox.com` directly | |

### 2.3 Rollout properties: set these explicitly in new places

| Property | Set to | Status (2026-11-05) | Thread |
|---|---|---|---|
| `Workspace.PlayerCharacterDestroyBehavior` | `Enabled` | Default = Enabled from 2026-11-11; property removed end of February 2027 | [4975616](https://devforum.roblox.com/t/4975616) |
| `StarterPlayer.AvatarJointUpgrade` | `Enabled` (test) | Phase 2 since 2026-05-27; Phase 3 forced ~end of 2026 | [4656414](https://devforum.roblox.com/t/4656414) |
| `StarterGui.ClipsDescendantsSupportsRotation` | `Enabled` | Phase 2 since 2026-09-24; removal planned November 2026 | [4737864](https://devforum.roblox.com/t/4737864) |
| `Workspace.PlayerScriptsUseInputActionSystem` | `Enabled` | Opt-in since 2026-06-11 | [4678416](https://devforum.roblox.com/t/4678416) |
| `Workspace.UseFixedSimulation` | `Enabled` (test) | Opt-in; no opt-out date yet | [4605516](https://devforum.roblox.com/t/4605516) |
| `Workspace.ImprovedPhysicsReplication` | leave Default/Enabled | Rolled out 2026-06-15; `Disabled` is temporary | [4675512](https://devforum.roblox.com/t/4675512) |
| `Workspace.MeshStreamingAndImprovedLods` | `Enabled` | Opt-in from 2026-04; planned default ~July 2026 (uncertain) | [4601232](https://devforum.roblox.com/t/4601232) |
| `Workspace.PredictiveStreamingMode` | `Enabled` for streamed games | Opt-in | [4764052](https://devforum.roblox.com/t/4764052) |
| `Workspace.SignalBehavior` | `Deferred` | Template default since 2023; required by Server Authority | [2723113](https://devforum.roblox.com/t/2723113) |
| `Workspace.StreamingEnabled` | `true` (most games) | Template default since 2023; required by Server Authority | [2462204](https://devforum.roblox.com/t/2462204) |
| `Workspace.ExpandedTerrain` | `Enabled` if you use custom terrain materials | Full launch 2026-10-22 | [4950620](https://devforum.roblox.com/t/4950620) |
| `Workspace.AuthorityMode` | `Server` for competitive/physics games | Opt-in, full release 2026-07-09 | [4727993](https://devforum.roblox.com/t/4727993) |
| `TextChatService.PlatformIntegratedChat` | `Enabled` (to test) | Opt-in until Feb 2027 | [4948433](https://devforum.roblox.com/t/4948433) |
| `Workspace.RejectCharacterDeletions` | Enabled (default) | Default since 2023 | [2196175](https://devforum.roblox.com/t/2196175) |
| `StarterPlayer.CharacterBreakJointsOnDeath` | `false` in new templates (ragdoll death) | Template default 2026 | [4541689](https://devforum.roblox.com/t/4541689) |
| `SoundService.AudioPlayerVolumeFix` | — | **Removed** 2025-10-29 (fixed behavior) | [3907391](https://devforum.roblox.com/t/3907391) |
| `Workspace.ClientAnimatorThrottling` | — | Always on since 2026-04-29 | [4568218](https://devforum.roblox.com/t/4568218) |

---

## 3. Upcoming / scheduled changes (after 2026-11-05)

Ordered by date. Re-check each thread before acting, because dates slip often (see §4).

| When | What | Action for the bot | Thread |
|---|---|---|---|
| **2026-11-11** | `PlayerCharacterDestroyBehavior` Default → Enabled | Read Player data before yielding in `PlayerRemoving`; test leaderboards and saving | [4975616](https://devforum.roblox.com/t/4975616) |
| **2026-11-11** | Studio saves `*Content` properties; legacy `*Id` hidden in Properties | Rojo ≥ 7.7.1; update custom rbxlx tooling | [4975546](https://devforum.roblox.com/t/4975546) |
| **November 2026** | Highly Engaged Player entry threshold 250 → 100 (Kids & Select) | Tell users the Kids/Select bar is lower | [4865780](https://devforum.roblox.com/t/4865780), [4930524](https://devforum.roblox.com/t/4930524) |
| **November 2026** | `StarterGui.ClipsDescendantsSupportsRotation` removed (rotated clipping forced) | Check rotated UI inside clipping frames | [4737864](https://devforum.roblox.com/t/4737864) |
| **November 2026** | Chat: emojis, voice typing, translations/AI-rephrases in `TextChannelWindow`; display-name color customization | — | [4948433](https://devforum.roblox.com/t/4948433) |
| **2026-11-19** | Free 6-month Roblox Plus grants end | — | [4567894](https://devforum.roblox.com/t/4567894) |
| **December 2026** | Roblox Wallet: daily USD payouts for US 18+ independent creators (opt-in) | — | [4865505](https://devforum.roblox.com/t/4865505) |
| **2026-12-19** | Publishing-fee waiver (for Plus-grant creators) ends; new Kids & Select games need Plus, the 1,000-Robux refundable fee, or another eligible requirement. Existing games stay live | Budget the fee or Plus when planning a launch to under-16s | [4567894](https://devforum.roblox.com/t/4567894) |
| **End of 2026** | Avatar Joint Upgrade Phase 3: forced for all games | Remove Motor6D assumptions now | [4656414](https://devforum.roblox.com/t/4656414) |
| **End of 2026** | Chat message history for moderators; avatars, bubbles and Quick Words in `TextChannelWindow` | — | [4948433](https://devforum.roblox.com/t/4948433) |
| **January 2027** | Advertising Integrations revenue share (campaigns starting after 2027-01-01) | Price brand deals accordingly | [4527365](https://devforum.roblox.com/t/4527365) |
| **February 2027** | TCS Phase 2: all games auto-opted into platform-integrated chat (opt-out available); native role badges (prefixes) replace custom prefixes; `TextChatCommand` keyword-anywhere detection | Migrate custom chat UI and prefixes | [4948433](https://devforum.roblox.com/t/4948433) |
| **End of February 2027** | `PlayerCharacterDestroyBehavior` property removed (no opt-out) | — | [4975616](https://devforum.roblox.com/t/4975616) |
| **April 2027** | Native click-on-message / Quick Action Menu | — | [4948433](https://devforum.roblox.com/t/4948433) |
| **May 2027** | TCS Phase 3: updated TextChatService is the only custom chat; message content not readable by code; creator blocked-words list | All custom chat must be migrated | [4948433](https://devforum.roblox.com/t/4948433) |
| **Mid-2027** | DevEx remains available in the US "through mid-2027" (Wallet transition) | — | [4865505](https://devforum.roblox.com/t/4865505) |
| **2027** | Wallet expands to groups, 13+, international; Roblox Card; typing indicators in chat | — | [4865505](https://devforum.roblox.com/t/4865505) |
| **No date** | `UseFixedSimulation` opt-out phase | Test now | [4605516](https://devforum.roblox.com/t/4605516) |
| **No date (uncertain)** | Scoped User IDs broad rollout (was "October 2026", delayed) | Avoid cross-game UserId features | [4677155](https://devforum.roblox.com/t/4677155) |
| **No date** | Premium retirement ("will soon no longer be available") | Use Plus-aware APIs (`PromptRobloxSubscriptionPurchase`) | [4573166](https://devforum.roblox.com/t/4573166) |
| **No date** | IARC age-rating framework transition | Keep the questionnaire accurate | [4573166](https://devforum.roblox.com/t/4573166) |
| **No date** | Web Play for all players; publishable Orthographic Camera and AnimatedImages | Don't ship betas | [4964592](https://devforum.roblox.com/t/4964592) |
| **No date** | Roadmap: compute functions, built-in data management with session locking, place branching, new primitives, UI blur, QueueService, push notifications, offline play, pass free trials, Safety Callback API, adaptive streaming radius | Treat as unavailable until a release thread exists | [4880208](https://devforum.roblox.com/t/4880208) |
| **No date** | Mesh Streaming default + removal of `MeshPart.RenderFidelity` (Phase 3) | Don't rely on `RenderFidelity` | [4601232](https://devforum.roblox.com/t/4601232) |

---

## 4. Lessons from developer reactions (top replies)

These come from the highest-liked replies under the staff posts. They show where migrations hurt, and what to watch for when building or advising.

1. **Short notice is the norm, so build defensively.** "Less than 3 weeks is pretty short notice" (on the PlayerOwnsAsset client change, [4226591](https://devforum.roblox.com/t/4226591)). "Wow, it seems like you have a lot of breaking changes coming out recently" (badges, [4438920](https://devforum.roblox.com/t/4438920)). **Lesson:** don't rely on undocumented or privacy-sensitive behavior (other players' inventories, cross-game badges, user IDs as global keys). Make server-side checks and `pcall` every web-backed call.

2. **Phased rollouts slip, in both directions.** PlayerCharacterDestroyBehavior was meant to be forced in mid-2024; the rollout was suspended ([3161577](https://devforum.roblox.com/t/3161577)) and it lands in November 2026. Pathfinding's improved search was disabled for a crash, then restored ([3258657](https://devforum.roblox.com/t/3258657)). Custom-terrain performance gains were rolled back after client crashes ([4950620](https://devforum.roblox.com/t/4950620)). Scoped IDs missed their October date ([4677155](https://devforum.roblox.com/t/4677155)). **Lesson:** write code that works under *both* the old and new behavior of a rollout property, and re-check thread headers for "[Update]" blocks.

3. **"Temporary opt-out" means it will be forced.** AJU replies: "Why is this a 'temporary' opt-out? Why can't there be both…" ([4656414](https://devforum.roblox.com/t/4656414)). Staff kept the forced Phase 3. **Lesson:** migrate rather than opt out. The concrete break is scripts that index `character.UpperTorso.Waist` (Motor6D) or assume accessory Welds exist; use recursive `FindFirstChild` or `QueryDescendants`, and attach effects to Attachments, not joints.

4. **The TextChatService migration threatens roleplay mechanics.** The top replies (431 and 410 likes) say radios, walkie-talkies, broadcasts and criminal/police roleplay systems will break ([4948433](https://devforum.roblox.com/t/4948433)). Staff answered with `TextChannelWindow` in SurfaceGuis, one window per channel, read-only channels via `TextSource.CanSend = false`, and server-to-client `DisplaySystemMessage` for announcements. **Lesson:** design radio and phone features as separate `TextChannel`s rendered with `TextChannelWindow`, never as custom UIs that read and relay message text.

5. **What counts as "chat" is broad.** Staff list signs, bulletin boards, pet names, license plates, trading notes, announcement systems, admin tools and comment systems as possible chat bypasses ([4948433](https://devforum.roblox.com/t/4948433)). Developers were frustrated that even preset "Hello" messages are restricted ([4539685](https://devforum.roblox.com/t/4539685)). **Lesson:** any free-text field visible to others must be filtered (`TextService:FilterStringAsync` + `GetNonChatStringForBroadcastAsync`) *and* rate-limited to ≥ 1 minute per submission, or routed through TCS. Prefer picking from preset options.

6. **Age gating fragments small servers.** "Many games are far too small to support matchmaking of this type; splitting servers could cause many small…" (on the Text Chat signal, [4116099](https://devforum.roblox.com/t/4116099)). **Lesson:** small games shouldn't depend on chat for core coordination. Add pings, emotes, Quick Words and clear UI so mixed-age servers still work.

7. **Publishing requirements are the biggest friction for new creators.** The April 2026 thread has 40.9k likes, and the top replies (3.5k, 1.6k, 1.5k likes) object to paying a subscription to reach under-16s ([4573166](https://devforum.roblox.com/t/4573166)). Under the fee thread: "1000 robux is very expensive for little Timmy" ([4630944](https://devforum.roblox.com/t/4630944)). After the threshold cut, users asked to "reduce the expedited review fee" (later halved, [4820164](https://devforum.roblox.com/t/4820164)). **Lesson:** when a user asks the bot to "publish to everyone", explain the tiers, check eligibility (create.roblox.com/settings/eligibility/publishing-permissions) and plan to launch to 16+ first.

8. **Classic games disappeared when owners didn't verify.** On 2026-06-17 beloved games whose owners hadn't done Facial Age Estimation became unavailable, and direct links returned 404 ([4685717](https://devforum.roblox.com/t/4685717)). **Lesson:** account-level verification now affects whether a game is *visible*. Group-owned games depend on the group owner's status.

9. **Privacy changes break moderation tooling.** Scoped IDs: "*extremely* destructive for moderation tooling to the point where we can't moderate our communities anymore" (819 likes, [4677155](https://devforum.roblox.com/t/4677155)). Another reply: "You're hiding player userids in the name of privacy, meanwhile demanding all of us show our face…" (654). **Lesson:** use the engine Ban API (`BanAsync` with `ApplyToUniverse`, `ApplyDeviceBlock`) rather than external ban databases keyed by global IDs.

10. **The Transfers API caps killed high-end donation games at launch.** "Is this API seriously capped at 1k robux a month? This would completely kill the higher end of donation games" ([4618396](https://devforum.roblox.com/t/4618396)). The limit was raised to 10k/month with 2SV ([4637912](https://devforum.roblox.com/t/4637912)). **Lesson:** don't design a game whose core loop is Robux moving between players.

11. **Even "free money" has eligibility traps.** The US 18+ DevEx rate top reply: "noticed this little caveat which makes every single game I work on ineligible" (the R15-only rule, [4607091](https://devforum.roblox.com/t/4607091)). Creator Rewards: low-session-length games feared becoming "unDevExable" ([3777628](https://devforum.roblox.com/t/3777628)). **Lesson:** check the eligibility rule (R15, 10-minute sessions, first-3-experiences-of-the-day) *before* recommending a design for revenue reasons.

12. **Regional pricing defaults aren't wanted by everyone.** "Can we disable regional prices please?" (private servers, [4590482](https://devforum.roblox.com/t/4590482)). Dev products stay opt-in because of gifting and trading arbitrage ([4471199](https://devforum.roblox.com/t/4471199)). **Lesson:** if the game has trading or gifting of dev-product goods, think about regional arbitrage before opting in.

13. **Asset moderation can ban innocent creators.** RDC26 replies came from creators banned by "the recent wave" of AI asset moderation ([4865780](https://devforum.roblox.com/t/4865780)). HumanoidDescription server validation was partly driven by bans tied to avatar assets worn in games ([3982903](https://devforum.roblox.com/t/3982903)). **Lesson:** keep uploads clean, use original assets only (`09-…`), and enable server-side asset-type verification. "Asset Iteration" is meant to reduce development-time moderation.

14. **Default UI changes overlap custom HUDs.** The touch thumbstick and jump button moved (2026-04-30, [4565267](https://devforum.roblox.com/t/4565267)), and new top-bar experience controls arrived (2024, [3215981](https://devforum.roblox.com/t/3215981)). **Lesson:** test mobile layouts in the Device Simulator after each platform update. Keep the bottom-left and bottom-right thumb zones and the top bar clear.

15. **New system defaults can surprise existing setups.** "Many developers build their experiences with their roblox volume set to the lowest setting", so AudioPlayer's 2× volume fix caused loud surprises ([3907391](https://devforum.roblox.com/t/3907391)). The Gotham/Arial removal broke carefully tuned UI ("Well screw me and almost all the UI I've ever made", [2868222](https://devforum.roblox.com/t/2868222)). **Lesson:** use `FontFace` with Builder/Montserrat-family fonts, avoid pixel-perfect text fits (`TextScaled` + `UITextSizeConstraint`), and normalize audio levels against a reference.

16. **IAS is required for the future stack.** A reply explains: "Instances are required for server authority so they can be predicted… If you had binded inputs with a service like ContextActionService, only the client…" ([4678416](https://devforum.roblox.com/t/4678416)). **Lesson:** new games should start on IAS instances, so Server Authority, InputActionLabel and the Input Action Manager all work.

17. **Explorer and Studio UI rollouts disrupted workflows.** "There's currently no way to disable these subcategories" ([3774759](https://devforum.roblox.com/t/3774759)). Studio UI became non-optional on 2026-01-05 ([4085392](https://devforum.roblox.com/t/4085392)). **Lesson:** when writing instructions for a human, describe Studio actions by command name (e.g. "Beta Features", "Game Settings > Security") rather than toolbar positions.

18. **AI features divide the community.** Replies to 4D generation, the MCP server and Assistant were strongly negative ("ALERT! New TERRIBLE update", [4331818](https://devforum.roblox.com/t/4331818); [4415631](https://devforum.roblox.com/t/4415631)). **Lesson:** keep AI-generated content original and policy-compliant. Don't rely on AI-generated thumbnails being acceptable ("Same for AI thumbnails. Are those excluded?" was asked and not clearly answered, [4945086](https://devforum.roblox.com/t/4945086), uncertain). Make sure the game's quality holds up by play-testing it.

---

## 5. Gaps and uncertainty

- **Release notes are missing.** The mirrored release-notes files (676–746) are mostly empty stubs. Small API additions or deprecations announced only there are not covered; check `reference/api/API-Dump.txt` for current tags.
- **Some staff posts lost their body text** in the mirror (tables and code blocks rendered as empty markup; e.g. UIShadow, Orthographic Camera, Character Controller Library, Instance attributes). Their key takeaways are reliable, but details (exact property names) must be confirmed in `reference/creator-docs/…/classes/<Class>.yaml`.
- **Status unknown as of 2026-11-05:** Mesh Streaming Phase 2/3; Scoped User IDs rollout; Premium retirement date; UseFixedSimulation opt-out date; whether `SignalBehavior = Default` now means Deferred for old places (2023 staff said Immediate would remain "for the foreseeable future").
- **Policy pages change without DevForum posts.** For Community Standards, chat guidelines, the paid random items policy and the advertising policy, the live Creator Hub pages are authoritative.
- **`AnimationController` and `Player:GetRankInGroupAsync`** are tagged `[Deprecated]` in the API dump without a matching announcement thread in the mirror. The docs point to `Animator` and `GroupService:GetRolesInGroupAsync` respectively.
