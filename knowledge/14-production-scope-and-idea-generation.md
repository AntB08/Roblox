# 14 — Production, Scope, and Idea Generation: From Nothing to a Shipped Roblox Game

> Chapter purpose: give a Claude Code agent a repeatable procedure for taking an ORIGINAL Roblox game from a blank page to a live, iterating product, working alongside a human owner. Covers ideation, validation, scoping, prototyping, milestones, team roles, documentation, version control, collaboration, commissioning, budgets, kill/pivot decisions, and data-driven iteration. Templates are in Part 9; a full worked example is in Part 10.
>
> Written 2026-11-05. Platform facts were checked against the local official docs (`/home/user/Roblox/reference/creator-docs/content/en-us/`). Community anecdotes come from DevForum, press and podcasts. Several of those pages could not be fetched directly from this environment, so the anecdotes here are summarized from search-result excerpts and attributed. Treat any number from them as a single developer's report, not a platform statistic.

---

## TL;DR rules for the bot

1. **Never start building before you have a one-sentence hook the owner agrees with.** If you can't say "It's [familiar thing] but [twist], where you [core verb] to [goal]" in one breath, the idea isn't ready.
2. **Generate at least 10 ideas, score them, and prototype the top 2–3.** One idea is a guess. Several ideas plus a scoring rubric is a decision.
3. **Find the fun in 1–3 days of greybox.** A prototype tests one question ("Is grabbing and throwing other players fun for 5 minutes?"). If nobody, owner included, wants to keep playing after three days of honest iteration, kill it or pivot it.
4. **Scope the MVP to the core loop plus the minimum retention hook plus the minimum monetization.** Everything else goes on the cut list. On Roblox, a small polished loop shipped in weeks beats a big unpolished one shipped in months.
5. **Originality is non-negotiable.** No other games' names, characters, art, UI layouts, audio, or "X Simulator but it's literally X" knockoffs. Borrowing a *genre convention* is fine. Copying *expression* (art, UI, text, characters, specific level design) is not. Brand IP (anime, films, other games, real people) is off limits unless the owner holds a licence.
6. **Use the milestone ladder:** Prototype → Vertical Slice → Alpha → Beta (private/friends) → Soft Launch (small ad spend, real players) → Launch → Live. Each gate has written exit criteria. Don't skip gates; do shrink them.
7. **Put all code in Git with Rojo. Back up place files at every milestone.** Use Studio Version History notes on every publish. Never let the only copy of anything live in one Studio session.
8. **Write things down, but keep it short:** a one-page GDD, one feature spec per system, a balance spreadsheet, a style guide, a changelog. Docs exist so the next session (yours or a human's) can pick up the work.
9. **Cover each discipline honestly.** You can script, do UI layout, write data/balance, write docs, and do procedural or primitive building well. Ask for human help, or commission it, for character models, high-end props, animation polish, original music, and marketing art (icon and thumbnails), unless the owner accepts simpler placeholders.
10. **Measure before you decide.** After soft launch, look at D1/D7 retention, session length, the FTUE funnel, conversion, and qualified play-through. Fix the biggest leak first. Use Roblox Experiments for A/B tests where you can.
11. **Kill or pivot on evidence, not mood.** Set the kill criteria *before* soft launch (e.g., "if D1 stays under the threshold we agreed after two rounds of FTUE fixes, we pivot"). Record why in a postmortem.
12. **Protect the human's sustainability.** Propose a cadence the owner can keep up for months (e.g., one meaningful update every 1–2 weeks, not daily crunch). Even top studios have stepped back from weekly content when it hurt quality.
13. **Spend money last and small.** Ads in soft launch are for buying *data* (does the game retain?), not for buying success. Commission assets only with a written brief, milestones, and clear ownership terms.
14. **Never invent stats, quotes, or "industry benchmarks" in docs you produce.** If you cite a number, say where it came from.

---

## Part 1 — The Whole Procedure on One Page

```
PHASE 0  Owner intake (30 min)        -> constraints, audience, budget, time, skills
PHASE 1  Ideation (1 session)         -> 10-20 ideas via 5 methods
PHASE 2  Evaluation (1 session)       -> scored shortlist of 3, competition check, IP check
PHASE 3  Pitch (1 doc)                -> one-page pitch for top 1-3, owner picks
PHASE 4  Prototype (1-3 days each)    -> greybox answering ONE question per prototype
PHASE 5  Decide                       -> greenlight / pivot / kill (written)
PHASE 6  Scope (1 session)            -> GDD one-pager, MoSCoW list, cut list, milestone plan, risk register
PHASE 7  Vertical slice (1-2 weeks)   -> one complete loop at near-final quality
PHASE 8  Alpha (feature complete MVP) -> all Musts in, rough
PHASE 9  Beta (content + polish)      -> private testers, bug bash, FTUE tuning
PHASE 10 Soft launch                  -> public, small ad spend, analytics review
PHASE 11 Launch                       -> marketing push, update #1 ready
PHASE 12 Live                         -> cadence of updates/events, data-driven iteration
PHASE 13 Postmortem                   -> at every kill, pivot, or major milestone
```

At every phase boundary the agent writes a short status note (what was done, what was learned, what's next, what needs the owner) and asks the owner for a go/no-go. The owner holds final authority on creative direction, money, publishing, and anything posted publicly.

### Phase 0 — Owner intake questions

Ask these before generating ideas. Record the answers at the top of the project's `docs/` folder.

- **Who is it for?** Age band (younger kids, tweens, teens, 17+ with a matching content maturity label), and whether it's for players who come alone or in friend groups. Roblox's own guidance notes the user base now has more users aged 13+ than under 13, and stresses three platform strengths: content variety, low friction, and social connection (`production/roblox-user-base.md`).
- **What do you love playing on Roblox right now?** Name three games. This shows the owner's taste and the conventions they already know.
- **Time budget:** hours per week from the human, and the target date for a first public version.
- **Money budget:** Robux or USD for ads, commissions, and audio/asset licences. Zero is a valid answer.
- **Skills on the human side:** can they build, model, animate, draw icons, make music, run a Discord?
- **Goal:** learning project, portfolio piece, side income, or full business? This changes how much risk is acceptable.
- **Hard constraints:** platforms (mobile-first? console?), genres to avoid, content limits.

---

## Part 2 — Idea Generation Methods

Run at least three of these methods in one ideation session and aim for 10–20 raw ideas. Write each as a one-liner. Don't evaluate while generating.

### 2.1 Mechanic-first
Start from a verb that's fun on its own, then build a context around it.
- Procedure: list 20 verbs that feel good with Roblox physics and inputs (grab, fling, swing, grapple, slide, stack, paint, dig, bounce, magnetize, shrink, glue, ride, tow, launch, balance, herd, fish, sculpt, trade). For each, ask "what game would make me do this 1,000 times?"
- Strength: the fun can be tested on day one. Weakness: it can produce toys without goals. Roblox players generally need clear goals and visible progression, a point made repeatedly in DevForum "why games fail" threads.

### 2.2 Fantasy-first
Start from a role or wish the player wants to live out: run a bakery, be a storm chaser, be the monster, own a zoo, be a celebrity designer.
- Procedure: complete "I want to feel like a ___ who ___." Then find the smallest repeated action that delivers that feeling.
- Strength: easy to pitch, thumbnail, and theme. Weakness: the fantasy can hide a weak loop. Pair it with 2.1 to find the verb.

### 2.3 Trend remix
Roblox moves in waves (tycoons, simulators, obbies, tower defense, "grow/steal/collect" loops, survival-horror co-op, social hangouts, fashion competitions). Trends show what the audience's recommendation feeds are rewarding *right now*.
- Procedure: study the current top charts and the "trending/up-and-coming" sorts on the Roblox Discover page. For each trending game, write down its **core loop**, its **social hook**, and its **session shape** (how long a session is and why players come back). Then combine *one* of those structural elements with a fresh theme and a fresh mechanic.
- Hard rule: remix *structures*, never *expression*. The brainrot wave of 2025–26 shows the risk. Bloomberg and The Star reported that the developers of *Steal a Brainrot* had filed several lawsuits against alleged copycats, including on Fortnite, alleging copying of UI elements, objects, artwork, level design, animations, and overall aesthetic. Hundreds of derivative "for Brainrots" titles flooded Roblox. Being the 300th clone means no discovery and some legal risk.
- Timing risk: trends peak fast. By the time a solo developer ships a clone, the wave may be over. Roblox's own Q3 2026 earnings commentary noted that a large share of top games by hours had launched within the previous 90 days. The platform rewards new things, and that cuts both ways.

### 2.4 "X but Y"
Take a known genre or game shape (X) and change one major axis (Y): theme, perspective, who you play, the win condition, co-op vs. competitive, scale, or time pressure.
- Examples: "Tower defense, but the towers are your friends' avatars." "An obby, but the course is built live by the losing team." "A fishing game, but you fish in the sky for weather."
- Rule: change one or two axes, not five. Players need enough familiarity to understand the game in seconds, because Roblox sessions often hop between several games (see `production/roblox-user-base.md`, "User behavior on the platform").

### 2.5 Constraint-based
Constraints produce originality. Pick 1–3 at random:
- Only one button. Only one room. Every round lasts 90 seconds. No combat. Everyone shares one body or vehicle. The map changes every 5 minutes. You can only see what your teammate describes. The game must work for 2 players or 20. Mobile portrait only. Max 10 parts per player creation.
- Game jam themes (Roblox's own jams, Ludum Dare, GMTK) work as constraint generators too.

### 2.7 Output format for the ideation session
A table with columns: `#`, `One-liner`, `Method`, `Core verb`, `Fantasy`, `Social hook`. Hand it to Phase 2.

---

## Part 3 — Evaluating Ideas

### 3.1 The scoring rubric

Score each idea 1–5 on each criterion. Multiply by the weight. Shortlist the top 3. The weights are the agent's defaults, and the owner may change them.

| Criterion | Weight | What a 5 looks like |
|---|---|---|
| **Hook clarity** | 3 | One sentence; a 10-year-old can repeat it back. |
| **Core-loop fun (gut + quick paper test)** | 3 | The core verb is satisfying on its own; obvious 30-second loop. |
| **Target-audience fit** | 2 | Clear audience; matches what that audience already plays. |
| **Thumbnail-ability** | 2 | One image shows the fantasy and the action; readable at small size. |
| **Social/viral potential** | 2 | Better with friends; produces clip-worthy moments; natural reason to invite. |
| **Monetization fit** | 2 | Purchases that feel fair grow naturally from the loop (cosmetics, convenience, extra content) without pay-to-win. See the monetization chapter. |
| **Build cost (inverted)** | 3 | MVP doable by this team in ≤ 6–8 weeks with available skills. |
| **Competition gap** | 2 | Few strong games doing exactly this; or a clearly better/different take. |
| **Originality / IP safety** | Gate | Pass/fail. A fail removes the idea regardless of score. |
| **Live-ops extensibility** | 1 | Easy to add content (new zones, items, events) without new systems. |

### 3.2 Hook test (one sentence)
Template: **"[Genre/familiar shape] where you [core verb] to [goal], but [twist]."**
Bad: "An open-world adventure RPG with crafting, pets, quests, and PvP." (no hook, enormous scope)
Good: "A co-op heist game where you and your friends are tiny mice stealing cheese from a sleeping giant cat, and the cat wakes up whenever anyone squeaks on voice or chat." (clear verb, goal, twist, social hook, thumbnail)

### 3.3 Thumbnail test
Sketch or describe the icon and the first thumbnail in one sentence each. If the image needs text to make sense, the hook is weak. The official docs specify 16:9, ideally 1920×1080 thumbnails for the home page and detail page, and describe *thumbnail personalization*: Roblox reported that games using it saw an average +8.5% in qualified play-through rate during testing (`production/publishing/thumbnails.md`). Thumbnails matter enough that Roblox built a feature around them. Community threads also report player-count changes after icon changes, though that evidence is anecdotal.

### 3.4 Social/viral test
Ask:
- Is it *more* fun with a friend? Does the game give a reason to send an invite (co-op goals, a party bonus, shared bases)? See `production/promotion/invite-prompts.md` and `referral-system.md`.
- Does a 15-second clip of it make sense with the sound off?
- Is there a moment players will want to show others (a rare drop, a funny failure, a creation)?

### 3.5 Monetization fit test
Write three example purchases that would feel fair to a player. If you can only think of pay-to-win items, or nothing at all, mark it down. The Liftoff case study author on DevForum reported that profit was maximized by including "only just enough" game passes, not by piling them on. Again, that's one developer's report.

### 3.6 Build-cost estimate
List the systems the MVP needs (Part 5). Size each one S/M/L (S ≈ ≤1 day agent time, M ≈ 2–4 days, L ≈ 1–2 weeks, including testing), then add art needs. If the total is beyond the owner's time budget by more than 1.5×, cut scope or drop the idea.

### 3.7 Competition check on Roblox charts (procedure)
1. Search the Roblox Discover page for 5–10 keywords that describe the idea (genre, theme, verb).
2. Record the top 10 results: name, active players (CCU), visits, like ratio, last-updated date, creator (solo/group/big studio).
3. Open the top 3 and play each for 15 minutes. Write down their core loop, FTUE length, monetization, and what's weak.
4. Classify the market:
   - **Empty** (no results): either an untapped niche or no demand. Validate with the prototype.
   - **Fragmented** (many small games, no leader): opportunity if you execute better.
   - **Dominated** (1–2 giants with huge CCU from big studios): avoid head-on competition. Change an axis (audience, session length, co-op vs. PvP).
5. Write a "why ours is different" line. If you can't write one, the idea is a clone. Drop it or rework it.

The DevForum thread "So your game died…" makes the same argument: find a niche, ask "what makes my game unique," and accept that not everyone will like your game. Your job is to find the players who do.

### 3.8 Originality and IP risk check (gate)
Fail the idea if any of these are true:
- It uses another franchise's name, characters, creatures, logos, music, or distinctive art (anime, movies, TV, other video games, toys, sports leagues, brands, celebrities, YouTubers) without a licence.
- The plan is to reproduce a specific existing Roblox game's UI layout, map, item set, names, or progression tables.
- The title or icon is designed to be confused with a popular game.

Pass but flag it if the idea uses a common genre convention (a rebirth system, a pet egg hatch, a tycoon dropper conveyor). Those are not owned. Just give them original names, art, numbers, and presentation.

Platform facts (`production/publishing/ip-guidelines.md`): Roblox prohibits unauthorized use of IP and removes infringing content. Repeat infringers can be suspended or terminated. Copyright protects *expression*, not ideas. Crediting the original creator, not monetizing, or "seeing others do it" does **not** make infringement okay. Real cautionary tale: developer mattqdev's write-up "3.2 Million Visits on a Roblox Game in 6 Months" covers a game built on another company's franchise name (*Brawl Stars Pet Simulator*) "from launch to DMCA takedown". Six months of traction were lost to a takedown. The agent should never propose using a franchise's IP, however tempting the search volume.

Copyright isn't the only problem. **Platform discovery punishes clones in practice**: they compete with the original for the same recommendation slots, and players spot them.

---

## Part 4 — Prototyping: Find the Fun in 1–3 Days

Roblox's own prototyping guide (`production/game-design/prototyping.md`) frames prototyping as fast, cheap exploration whose goals are **time efficiency** and **finding the fun**. It contrasts *paper* prototyping (minutes to start, great for UI/UX and system interactions, but prone to false positives) with *Studio* prototyping (reusable work, early technical-risk detection, but slower iteration). It says the difference between building a feature and prototyping is **scope**: a prototype hits certain aspects of a feature, not the whole thing. It recommends testing the core loop, UI/UX, game rules, and edge cases, plus several playtests with others.

### 4.1 Prototype procedure for the agent
1. **Write the question.** One sentence: "Is it fun to ___ for 5 minutes?" or "Can players understand ___ without a tutorial?" or "Can the server handle ___ with 20 players?"
2. **Greybox only.** Parts, default materials, no custom art, placeholder UI (TextLabels), placeholder SFX from the free library (check licensing), no monetization, no saving unless saving *is* the question.
3. **Build the core verb first, with "juice"** (screen shake, sound, particles, camera feedback). Fun often hides in feel. Cheap juice is allowed in a prototype.
4. **Day 1:** core verb working and playable in a test server. **Day 2:** a goal and a fail state, so there's a loop. **Day 3:** playtest with the owner and 2–5 others; iterate on the most-complained-about thing.
5. **Observe, don't ask.** Track: did they keep playing without being asked? Did they laugh? Did they invent their own goals? Did they want to invite someone? Self-reported "it's fun" is weak evidence. Behavior is strong evidence.
6. **Write a prototype report** (template in Part 9.8) with a decision: Greenlight / Iterate one more round (max 1) / Pivot / Kill.

### 4.2 Run prototypes in parallel when possible
Jamie Fristrom (*Dungeon Life*) described applying "new product science" to Roblox in a Game Developer retrospective: start with several prototypes and narrow them to the one with the best odds. He noted Dungeon Life was still a financial failure. A movement-speed fix noticeably improved engagement but not enough. He argued the testing was still worth it, because the alternative ideas were just as likely to flop. Lesson for the bot: parallel prototyping improves your odds; it doesn't guarantee a hit. Make prototypes cheap enough that killing them doesn't hurt.

### 4.3 Vertical slice
After greenlight, build **one complete slice** of the game at close to final quality: one zone/level, the full core loop, the first progression step, real UI style, real audio direction, first-pass FTUE, and saving. Purpose: prove the *production pipeline* (art style is achievable, code architecture holds) and give the owner something to show testers or collaborators. Typical size: 1–2 weeks for a small team with an agent.

### 4.4 Remember the "a few days" outliers, but don't plan around them
Press coverage of *Grow a Garden* reports that its original teenage creator built a simple version in a matter of days. Splitting Point Studios (Janzen "Jandel" Madsen) partnered after launch and scaled it with a rapid update cadence. Likewise, the *Fantasy Forest* launch post-mortem on DevForum (FriendlyStoneGolem, 2022) reports a prototype built in about two weeks: one week on features like flying and customization, one on polish and more animals. Lesson: on Roblox, small and fast is a valid strategy, *because the market tells you quickly whether the loop works*. Plan for small MVPs and fast feedback. Don't plan for virality.

---

## Part 5 — Defining the MVP

### 5.1 The MVP formula
**MVP = Core loop (polished) + FTUE (first 60–120 seconds) + one retention hook + saving + minimum monetization + mobile controls + basic moderation-safe social features.**

Not in the MVP: multiple modes, deep crafting trees, trading, clans, leaderboards beyond one, seasonal passes, many zones, cinematic intros, localization (beyond auto-translation), console-specific polish (unless console is the target).

### 5.2 MVP by genre (starting points; adapt per idea)

| Genre | MVP must include | Defer |
|---|---|---|
| **Obby / platformer** | 30–60 stages with a difficulty curve, checkpoints and saved progress, skip-stage product, a reason to return (daily or new stages), mobile-tuned jumps | Level editor, many worlds, trails shop beyond a few |
| **Tycoon** | Plot claiming, 1 dropper→conveyor→collector chain, 20–40 purchasable buttons, rebirth v1, saving, one gamepass (e.g., 2× cash) | Multiple themes, PvP raids, pets |
| **Simulator (collect/upgrade)** | Collect action, sell/convert, 3 upgrade tiers, 2–3 zones gated by currency, one pet/egg or equivalent, rebirth, saving | Trading, 10+ zones, events, guilds |
| **Tower defense** | 1 map, 5–8 towers with upgrade paths, 20–30 waves, 3–5 enemy types, 1 boss, co-op of up to 4, loadout unlocks | Multiple maps, endless mode, gacha towers |
| **Round-based PvP / party** | Lobby, 1 mode with 1–2 maps, matchmaking via teleport or round system, win/lose, XP, cosmetics shop | Ranked, many modes, custom servers |
| **Survival-horror co-op** | 1 map, 1 monster AI with a clear threat pattern, objective chain, revive, 15–25 min run, run-end rewards | Multiple monsters/maps, lore systems |
| **Roleplay / hangout** | One detailed, readable map, 5–10 interactive props/jobs, avatar or outfit tools, chat-friendly spaces, house/plot v1 | Economy depth, vehicles galore |
| **Fashion/creation competition** | Dress/create stage with a curated item set, timed rounds, voting, rewards that unlock items | Huge catalogs, custom textures |
| **Fishing / gathering / collection** | Catch minigame, 20–40 collectibles with rarities, index/collection book, 2 locations, upgrades, sell | Weather, boats, events |

### 5.3 Feature prioritization: MoSCoW + cut list

- **Must** — without it the game is not the game (core loop, FTUE, saving, mobile controls).
- **Should** — strongly improves retention or monetization; ship in MVP if time allows, else in update #1.
- **Could** — nice; goes on the post-launch roadmap.
- **Won't (this version)** — explicitly out. Writing these down stops scope creep.

**Cut list protocol:**
- Keep a ranked **cut list**: features ordered from "cut first" to "cut last." When the schedule slips, cut from the top, and don't argue each one fresh.
- Keep a **"cannot cut" list** (core loop, saving, FTUE, performance on mobile, the hook).
- For every cut, write one line on *why* and *what we expect to lose*. This becomes postmortem data.
- Tom Francis's GDC 2018 talk on scope change in *Heat Signature* vs. *Gunpoint* is the classic reference here. He offered rules for telling useful scope creep from damaging scope creep, including choosing ideas that are quick to prototype and prototyping the important parts first.

**Feature scoring for tie-breaks:** `Priority = (Impact on retention or monetization × Confidence) / Cost`. Score 1–5 each. Impact is about the *core metrics* (D1, D7, session length, conversion), not "coolness."

### 5.4 Scope creep warning signs
Flag these to the owner: new systems added after Alpha; "while we're at it" features with no target metric; the milestone date has slipped twice; the vertical slice took more than 2x its estimate (re-estimate everything by that factor); polishing zones that aren't in the MVP. Liftoff's DevForum case study names "cramming" during development as a cause of rushed design and execution, which made the game hard to maintain.

---

## Part 6 — Milestones, Estimates, and Cadence

### 6.1 Milestone ladder with exit criteria

| Milestone | Goal | Exit criteria (all must be true) |
|---|---|---|
| **Prototype** | Answer the fun question | Prototype report written; owner says greenlight; core verb feels good in a 5-minute test with ≥3 non-team players |
| **Vertical slice** | Prove pipeline and quality bar | One full loop at target quality; style guide v1; architecture doc; saving works; runs acceptably on a mid-range phone |
| **Alpha** | Feature complete (all Musts) | Every Must implemented; no blocker bugs in the core loop; analytics events wired (funnel, economy, custom); placeholder art allowed in non-core areas |
| **Beta** | Content complete + polish | All MVP content in; FTUE tested with ≥10 fresh players; mobile/console input pass; performance pass; monetization products configured; icon + thumbnails done; moderation/text filtering verified |
| **Soft launch** | Real-player data | Public; small ad budget; ≥ several hundred new users to read early retention; dashboards reviewed; kill/pivot thresholds written in advance |
| **Launch** | Growth push | Top issues from soft launch fixed; update #1 ready or near-ready; community channels set up; social links set; marketing assets ready |
| **Live** | Retain and grow | Update cadence agreed; event calendar; weekly metrics review; changelog discipline |

### 6.2 Time estimates (heuristics, not promises)
These are the agent's planning defaults for a *first original game* with an agent writing most code and a human owner reviewing, building some art, and playtesting. They aren't platform statistics. Re-estimate after the vertical slice using actual velocity.

| Scope | Solo human + agent | Small team (2–4) + agent |
|---|---|---|
| Prototype | 1–3 days each | 1–2 days each |
| Vertical slice | 1–3 weeks | 1–2 weeks |
| Small MVP (obby, simple sim, party game) | 3–6 weeks total | 2–4 weeks |
| Medium MVP (tycoon w/ rebirth, TD, horror co-op) | 6–12 weeks | 4–8 weeks |
| Large (RPG, open-world, deep economy) | Not recommended as a first project | 3–6+ months |

Rules: (a) add 30–50% buffer to any estimate; (b) art and audio usually take longer than code once a quality bar is set; (c) FTUE and mobile controls always take longer than expected; budget them explicitly; (d) the last 10% (bugs, polish, store page) takes a lot of the time.

### 6.3 Sustainable cadence and burnout
- The live phase is a marathon. Grow a Garden's team was known for weekly updates. In August 2025 Jandel publicly announced a shift away from weekly events toward deeper farming content. Press coverage reported the team felt that weekly events had become hard to keep fresh and had crowded out bug fixes and long-term depth. If a top studio finds weekly cadence costly, a solo human shouldn't promise it.
- DevForum burnout threads repeat the same advice: take regular breaks, set goals that are meaningful but not overwhelming, and use a task tracker. Several developers have publicly left projects because constant updates and promotion were beyond their capacity.
- Agent behaviors:
  - Propose an update cadence based on the owner's stated hours (e.g., 6 hrs/week → a content drop every 2–3 weeks, small fixes in between).
  - Batch work into *themed updates* with a changelog, rather than a stream of tiny pushes the owner has to review daily.
  - Use Roblox's configs/experiments and data-driven content (item tables in ModuleScripts) so you can run events by changing data, not rewriting code. See `production/configs.md`.
  - Flag scope creep and late-night "just one more feature" requests. Point back to the milestone plan.
  - Never schedule launches right before the owner's known busy periods (exams, holidays) unless they choose to.
- Studio-scale cautionary tale: Player Driven's podcast with Wonder Works' Zach Letter describes the studio scaling from six people to ninety after early hits, burning roughly $600K a month while drifting into work-for-hire, then cutting back to twelve before a later licensed hit. Growth commitments (headcount, cadence) can outrun the product. Size commitments to proven revenue.

---

## Part 7 — Team Roles and How the Agent Covers Them

Roblox's collaboration doc puts it plainly: a high-quality game needs modeling, scripting, UI, audio and more, and one person rarely has all of these skills (`projects/collaboration.md`). Typical Roblox studio roles and the agent's stance on each:

| Role | What they do | Agent can do well | Hand off / commission when |
|---|---|---|---|
| **Game designer / producer** | Vision, loops, economy, priorities, schedule | Ideation, specs, balance spreadsheets, milestone plans, risk registers, analytics plans | Owner keeps final creative say |
| **Scripter (Luau)** | Gameplay, server authority, data saving, UI logic, tools | Most of it: architecture, systems, DataStores, anti-exploit validation, tests, Rojo project setup | Highly specialized needs (custom physics rigs, advanced shaders-like effects) may need a specialist review |
| **Builder / level designer** | Maps, layout, greybox→final, lighting | Greybox layouts, procedural placement, modular kits from primitives, lighting presets, readable navigation | Stylized hero environments, organic terrain art, "showcase" quality maps |
| **3D modeler** | Meshes, props, characters, UGC-style assets | Simple low-poly geometry via parts/unions, procedural meshes, specs and reference sheets | Character models, creatures, detailed props, rigged meshes. Commission, or use owner-approved licensed packs |
| **UI/UX designer** | HUD, menus, shops, onboarding visuals | Layout, responsive scaling, UI state code, accessibility, a consistent component system | Polished icon art, illustrated buttons, branded logo |
| **VFX artist** | Particles, beams, trails, impact effects | Functional particles and tweens, "juice" passes | Signature high-polish effects, custom textures/flipbooks |
| **Animator** | Character and object animations | Procedural tweens, simple Motor6D/CFrame animation via code, animation-loading code | Keyframed character animations (emotes, attacks, idle personality) |
| **Sound designer / composer** | SFX, music, mix | Choosing from licensed/free library audio (with licence checks), mixing via SoundGroups, audio code | Original music and a signature SFX set |
| **Marketing artist** | Icon, thumbnails, ad creatives, trailers | Briefs, composition specs, in-game screenshot staging, A/B plan for thumbnails | Final illustrated icon and thumbnails (high impact on CTR) |
| **Community manager** | Discord, socials, feedback triage, updates | Drafting changelogs, update posts, FAQ, feedback triage summaries | Owner posts publicly. Agent never posts as the owner without approval |
| **QA / playtester** | Bug finding, balance feedback | Automated tests, test plans, multi-client Studio tests, bug triage | Real-player testing needs humans |
| **Analyst** | Dashboards, funnels, experiments | Event instrumentation, dashboard reading guides, experiment design | — |

**Agent rule:** At project start, produce a "discipline coverage" table for this specific game, marking each row *Agent*, *Owner*, *Commission*, or *Placeholder accepted*. Re-check it at the vertical slice.

---

## Part 8 — Documentation, Version Control, Collaboration, Commissioning, Budgets

### 8.1 Documentation set (keep it lean)
Store in the repo under `docs/`:
- `pitch.md` — one-page pitch (template 9.1).
- `gdd.md` — GDD skeleton, one page with links (template 9.2).
- `specs/<feature>.md` — one per system (template 9.3).
- `balance/` — CSV or spreadsheet exports of economy tables (prices, rewards, XP curves, drop rates). Generate Luau data modules *from* these, or keep the Luau module as the source of truth and export CSV for review. Pick one and say which. See `production/game-design/balance-virtual-economies.md`.
- `style-guide.md` — palette (hex), fonts, UI corner radius/stroke rules, material list, scale reference (avatar height vs. door height), lighting preset, audio mood, naming conventions for instances and assets.
- `milestones.md` (template 9.4) and `risks.md` (template 9.5).
- `CHANGELOG.md` — every publish, written for players and devs both. Mirror the player-facing lines into Studio's publish version notes. The docs note that **version notes are required when publishing** (`projects/version-history.md`).
- `postmortems/` (template 9.7).

### 8.2 Git + Rojo workflow
- **Rojo** syncs files on disk into Studio, so code lives in Git. Two modes (Rojo docs): **fully managed** (Rojo owns every instance and `rojo build` can rebuild the whole place, which gives reproducible builds and full version control, but models must be saved to files and some instance types are hard to manage), and **partially managed** (Rojo owns scripts and some folders, the rest, usually Workspace/terrain/builds, lives in the place file or Team Create). The Rojo v7 docs say best practice for partial management is still evolving and generally recommend a separate place per programmer.
- **Agent default:** partially managed. Rojo owns `ServerScriptService`, `ReplicatedStorage` (shared modules, data tables), `StarterPlayer` scripts, and `StarterGui` code-built UI. Builders work in Studio on the map.
- **Branching:** `main` = what's live (or ready to publish). `dev` = integration. `feature/<name>` branches for each spec. Merge to `dev` after test, `dev` → `main` at milestone/publish. Tag releases (`v0.3.0-beta`). Small teams can skip `dev` and use short-lived feature branches off `main`.
- **Commits:** reference the spec or bug ("feat(shop): add daily rotation per specs/shop.md").
- **Place-file backups:** at every milestone and before every risky change, (1) "Save to Roblox with Notes" in Studio (Version History lets you restore earlier versions and filter by collaborator and notes), and (2) export a local `.rbxl` copy to a backups folder or a Git LFS store, named `game_vX.Y_YYYY-MM-DD.rbxl`. Some teams commit the place file alongside Rojo code. Others avoid it because it can go stale. If you commit it, use Git LFS and treat it as a snapshot, not a merge target.
- Studio also writes **auto-recovery files** when saving to Roblox fails (`projects/place-files.md`). Don't rely on them as backups.
- **Separate places for dev and live:** keep a "Dev" place (or a separate dev game) and the "Live" place. Publish to live only from a tagged commit, after a test pass.

### 8.3 Working with collaborators in Studio
- **Team Create / collaboration:** official docs (`projects/collaboration.md`) say that collaborating with other creators requires the owner (and collaborators) to complete an **age check**, and that collaboration between age groups is limited by default (with parental and trusted-friend exceptions). Permission levels are Owner, Edit, Play, No Access. For **user-owned** games, Edit can only be granted to Roblox friends. For **group-owned** games, Edit is managed through group roles (all group games, or per game).
- **Agent recommendations:** put any serious project in a **Roblox group** from day one (cleaner permissions, revenue handling, and later ownership transfer; see `projects/groups.md`, `projects/game-ownership-transfer.md`). Create group roles per discipline (Scripter, Builder, Tester). Grant per-game Edit only for as long as needed.
- **Packages** (`projects/assets/packages.md`): convert reusable assets (doors, lamps, UI components, NPC rigs) into packages so updates propagate. Packages can auto-update and keep a full version history. The docs suggest packaging placeholders early so greybox copies upgrade automatically as detailed versions get published. Use this for builder/modeler handoffs.
- **Safety:** the docs warn that assets you didn't create can contain malicious scripts. Save first, inspect scripts in any third-party asset, and keep the ability to revert.

### 8.4 Commissioning assets from humans
- **Where:** Roblox's Talent Hub (official hiring board on the Creator Hub), the DevForum's collaboration and hiring categories, and artist portfolios linked there.
- **Pricing reality:** there is no official price guide. DevForum discussions show wide ranges: experienced scripters quoting roughly tens to low hundreds of USD per commission, and percentage-of-revenue offers to builders and scripters on hobby projects. Several developers advise caution with revenue-share-only deals. One freelancer describes combining a smaller fixed fee with a percentage. Treat all of these as anecdotes, ask the artist for their rate, and compare portfolios.
- **Agent's commissioning procedure:**
  1. Write a **brief**: asset list, style guide excerpt, reference images (owned or licensed), poly/texture limits, file format, rig requirements, deadline, revision count.
  2. Agree on **payment structure**: fixed fee (preferred for defined assets), milestone payments (e.g., sketch / blockout / final), or fee + percentage for long-term roles. Avoid percentage-only arrangements for critical-path work.
  3. **Ownership and licence in writing:** who owns the asset, whether the artist can show it in a portfolio, whether it's exclusive, and whether a model's uploaded asset ID will be transferred to the group.
  4. **Delivery path:** the artist uploads to the group, or sends files that the owner uploads. Avoid depending on assets owned by an individual's account.
  5. **Review against the brief**, then pay. Keep records.
- The agent drafts briefs and contracts-as-checklists. **The human owner negotiates, signs, and pays.** Recommend a lawyer for significant deals; the agent isn't one.

### 8.5 Budgets: ads, sponsorships, and spend discipline
- **Ads Manager** (official docs: `production/promotion/ads-manager.md`, `search-ads.md`, `advertise-on-roblox.md`) supports daily or lifetime budgets. A DevForum announcement on Ads Manager upgrades describes a minimum campaign setup of 10 ad credits (5/day over at least 2 days), and Roblox's RDC 2025 ads recap claimed cost-per-play had dropped significantly, with players acquired for under one US cent each. These are company claims. Check the current UI for real minimums and prices.
- **What ads are for in soft launch:** buying *a sample of real new players* to read FTUE completion, D1, and session length. The Fantasy Forest post-mortem reported a first-week spend of tens of thousands of Robux that produced under 100 concurrents, and argued the value of those first players was telling you whether the game has potential. Organic recommendation, not ads, then grew the game once engagement was proven. The author's advice: focus on engagement metrics and let the algorithm supply players.
- **Budget rule of thumb (agent default):** split any available promo budget into (a) ~20–30% for a soft-launch data read, (b) the remainder held back for a launch push *only if* soft-launch metrics clear the agreed thresholds. Never spend the whole budget before you know retention.
- **Influencers:** studios like Wonder Works built strategies around YouTube creators. For small teams, the cheap version is designing clip-worthy moments, then reaching out (politely, via the owner) to small and mid-size creators in the genre.
- **Other promotion tools to wire in:** share links, invite prompts, referral systems, experience notifications, social media links, experience events (see `production/promotion/`).

---

## Part 9 — Templates

Copy these into `docs/`. Fill every bracket. Delete sections that don't apply instead of leaving them blank.

### 9.1 One-page pitch

```markdown
# [Working Title] — One-Page Pitch
**Hook (one sentence):** [Familiar shape] where you [core verb] to [goal], but [twist].
**Target audience:** [age band, solo/friends, what they already play (3 games)]
**Fantasy:** "I feel like a ___ who ___."
**Core loop (30s):** [action] -> [reward] -> [upgrade/choice] -> repeat
**Session loop (10-20 min):** [what a session achieves]
**Long-term loop (days/weeks):** [why they come back tomorrow / next week]
**Social hook:** [why play with friends; why invite]
**Thumbnail in one sentence:** [the image]
**Monetization (3 fair purchases):** 1. ___ 2. ___ 3. ___
**Why it's different (competition check summary):** [top 3 comparable games + our difference]
**Originality/IP check:** PASS — [notes]
**MVP scope (Musts only):** [5-8 bullets]
**Estimate:** prototype [days], MVP [weeks], team [who]
**Biggest risk + how prototype tests it:** [one line]
**Rubric score:** [x / max]
```

### 9.2 GDD skeleton (one page + links)

```markdown
# [Title] — Game Design Document (v[0.x], [date])
## 1. Vision
Hook, fantasy, pillars (3 words/phrases that every feature must support, e.g., "Chaotic co-op", "Readable at a glance", "Every run feels different").
## 2. Audience & platform
Ages, devices (mobile-first?), content maturity target, session length target.
## 3. Loops
Core / session / long-term (diagram or bullet chain).
## 4. Systems (link each to specs/)
- [System] — [one line] — [specs/system.md] — [MoSCoW]
## 5. Content plan
MVP content counts (levels, items, enemies) + first 3 post-launch updates.
## 6. Economy & monetization
Currencies, sources/sinks, products — link balance/ sheet.
## 7. FTUE
Second-by-second first 2 minutes.
## 8. Art & audio direction
Link style-guide.md; 3 reference mood descriptions (no copyrighted images in repo).
## 9. Tech
Architecture summary, data model (DataStore keys/schema), networking/remote list, Rojo layout.
## 10. Analytics plan
Funnels, custom events, economy events, KPIs + target thresholds.
## 11. Milestones & risks
Link milestones.md and risks.md.
## 12. Open questions
```

### 9.3 Feature spec

```markdown
# Spec: [Feature] (owner: [name/agent], status: Draft/Approved/Built/Shipped)
**Goal / metric it moves:** [e.g., D1 retention via early goal clarity]
**Player story:** As a [player type], I want to [action] so that [benefit].
**Description:** [how it works in 3-6 sentences]
**Rules & numbers:** [table; link balance sheet]
**UI:** [screens/states; wireframe description]
**Server/client split:** [what server validates; remotes + payloads; rate limits]
**Data:** [saved fields, defaults, migration]
**Edge cases:** [disconnect mid-action, full inventory, exploit attempts, mobile]
**Analytics events:** [names + fields]
**Acceptance criteria:** [ ] ... [ ] ... (testable statements)
**Out of scope:** [explicit]
**Estimate:** S/M/L  **Dependencies:** [...]
```

### 9.4 Milestone plan

```markdown
# Milestone Plan — [Title]
| Milestone | Target date | Scope (link) | Exit criteria | Status |
|---|---|---|---|---|
| Prototype A | | Q: "..." | report + owner go | |
| Vertical slice | | zone 1 full loop | see criteria | |
| Alpha | | all Musts | | |
| Beta | | content + polish | | |
| Soft launch | | public + ads [budget] | metrics read | |
| Launch | | fixes + update #1 | | |
**Weekly capacity:** owner [h/wk], others [h/wk]
**Buffer:** [30-50%] included? Y/N
**Kill/pivot thresholds (set now):** [metric + value + after how many fix cycles]
```

### 9.5 Risk register

```markdown
| ID | Risk | Likelihood (1-5) | Impact (1-5) | Score | Early warning sign | Mitigation | Owner | Status |
|---|---|---|---|---|---|---|---|---|
| R1 | Core loop not fun beyond 10 min | 3 | 5 | 15 | testers stop at ~5 min | add mid-term goal; prototype 2nd loop | agent | open |
| R2 | Art quality bar unreachable | | | | slice art time > 2x | simplify style; commission key assets | owner | |
| R3 | Mobile controls clunky | | | | mobile testers fail FTUE | dedicated mobile pass in Beta | agent | |
| R4 | Data loss / DataStore bugs | | | | errors in logs | session locking, retries, backups | agent | |
| R5 | IP/clone complaint | | | | lookalike titles/art | originality gate; original names/art | agent | |
```

### 9.7 Post-mortem template

```markdown
# Post-mortem: [Title] — [milestone/kill/pivot/launch], [date]
## Summary (3 lines): what we set out to do, what happened, decision
## Timeline: planned vs actual per milestone
## Metrics: visits, peak CCU, D1/D7/D30, avg session, payer conversion, revenue, ad spend (with sources)
## What went right (3-5)
## What went wrong (3-5) — root cause for each (5 whys)
## Scope: what was cut, what should have been cut earlier
## Process: estimates accuracy (estimate vs actual ratio), docs usefulness, tooling
## Team & sustainability: hours, stress points
## Lessons -> concrete rule changes for next project (max 5)
## Assets to reuse (code modules, packages, art)
```

### 9.8 Prototype report

```markdown
# Prototype report: [name] — question: "[...]"
Build time: [h] | Testers: [n, who] | Session lengths observed: [...]
Observed behavior: [kept playing? laughed? invented goals? asked to invite?]
Top 3 positives / Top 3 problems
Decision: Greenlight / Iterate once / Pivot to [...] / Kill   Reason: [...]
```

---

## Part 10 — Worked Example: Original Concept to Scoped MVP

This example is invented and original. It does not reference any existing game's IP.

### 10.1 Intake (summarized)
Owner: solo, ~10 hrs/week, can do basic building, no modeling or animation. Budget: a modest Robux amount for ads, nothing for commissions at first. Audience: ages 9–14, friend groups. Mobile-first. Target: public soft launch in ~8 weeks.

### 10.2 Ideation (excerpt of 12 ideas)

| # | One-liner | Method |
|---|---|---|
| 1 | Sky fishing: cast lines into clouds to catch weather creatures | X but Y / fantasy |
| 2 | Lighthouse keepers: co-op keep the light on through a stormy night while ships approach | Fantasy + constraint (one room) |
| 3 | Balloon courier: deliver packages across a floating archipelago by inflating/deflating | Mechanic-first (inflate) |
| 6 | Night market cook-off: cook dishes for a picky dragon in 90-second rounds | Constraint + fantasy |
| ... | ... | ... |

### 10.3 Evaluation (top 3 after scoring)
- **#3 Balloon Courier** — strong core verb (inflate/deflate for lift is physical and readable), clear goal, very thumbnail-able (a kid hanging from a cluster of balloons over sky islands), co-op potential (shared heavy deliveries), fair monetization (balloon skins, a delivery-route pass, a cosmetic basket). Build cost medium-low (parts-based islands, primitive balloons). Competition check (agent procedure): keyword searches for "balloon," "delivery," "courier," and "sky islands" turned up only small games with different loops in this hypothetical. Market classified as *fragmented*. IP check: PASS (generic concepts, original names).
- **#1 Sky Fishing** — great fantasy and collection appeal, but fishing/collection is a crowded genre with strong incumbents. Higher competition risk.
- **#2 Lighthouse Keepers** — great social hook, but horror-adjacent tuning for 9–14 is risky, and it needs AI ships. Medium-high build cost.

Owner picks **Balloon Courier**, with Lighthouse Keepers as a backup prototype.

### 10.4 Pitch (filled)
**Hook:** "A delivery game where you float across sky islands by inflating and popping balloons, and heavy packages need friends to carry together."
**Fantasy:** "I feel like a daring sky courier who can go anywhere."
**Core loop (30s):** grab package → manage lift (inflate/pop) and wind → land on target pad → coins and stars.
**Session loop:** complete 5–10 deliveries, upgrade balloon capacity/basket, unlock the next island ring.
**Long-term:** collect courier stamps (a collection book) for every island, daily "rush order," rarer fragile/huge packages.
**Social:** "heavy" packages require 2–4 players tethered together. Party bonus for deliveries with friends.
**Thumbnail:** a kid dangling from a rainbow balloon cluster, holding a giant parcel, over bright floating islands with a gust swirl.
**Monetization:** balloon/basket cosmetics; "Express Route" game pass (one extra active delivery slot, convenience not power); private server.
**Biggest risk:** is balloon flight *fun* and controllable on mobile? The prototype tests exactly this.

### 10.5 Prototype (3 days)
Question: "Is managing lift with inflate/pop fun and controllable on mobile for 10 minutes?"
- Day 1: a BodyForce/VectorForce-based lift tied to balloon count (server authoritative count, client prediction for feel). Two buttons: Inflate (+1 balloon, max 6) and Pop (−1). Simple wind zones.
- Day 2: three greybox islands, package pickup/drop pads, timer, coins.
- Day 3: playtest with the owner + 4 kids (owner's family/friends). Observations: everyone kept playing past 10 minutes; landings were frustrating without a shadow indicator; tethered co-op made people laugh. Iteration: added a landing shadow and a slow-descent "parachute" when you pop your last balloon.
Decision: **Greenlight.** Lighthouse Keepers stays parked.

### 10.6 MoSCoW for MVP

**Must**
1. Balloon flight (inflate/pop, wind zones, landing shadow, parachute fallback), mobile + PC + gamepad input.
2. Delivery loop: pickup, target pad, timer bonus, rewards.
3. 3 island rings (12 islands) gated by courier level.
4. Upgrades: max balloons, basket weight, inflate speed (3 tiers each).
5. Co-op heavy packages with tethering (2–4 players).
6. FTUE: 90-second guided first delivery, no text walls.
7. Saving (coins, level, upgrades, stamps) with session locking.
8. Stamp book (collection: one stamp per island + per package type).
9. Shop: balloon colour cosmetics (6), one game pass (Express Route), private servers enabled.
10. Analytics: FTUE funnel, delivery completion, economy sources/sinks, purchases.

**Should**
11. Daily rush order with bonus reward.
12. Party bonus (+% rewards when delivering with friends) + invite prompt after the first co-op delivery.
13. Fragile packages (penalty for hard landings).
14. Basic leaderboard (deliveries this week).

**Could**
15. Weather events (thunderstorm ring, rainbow gusts).
16. Pets that float along (cosmetic).
17. Player-named courier companies (groups of friends).
18. Seasonal stamp sets.

**Won't (MVP)**
- Trading, PvP sabotage, custom balloon designer, island building, story cutscenes, multiple worlds.

**Cut list (cut from top first if behind):** 14 → 13 → 11 → stamp book reduced to islands only → ring 3 reduced to 2 islands → cosmetics reduced to 3.
**Cannot cut:** 1, 2, 5, 6, 7.

### 10.7 Discipline coverage

| Discipline | Coverage |
|---|---|
| Scripting, UI, data, analytics | Agent |
| Islands/greybox → final build | Owner builds with agent-generated modular kit (parts), agent does lighting presets |
| Balloons, basket, packages | Agent from primitives + meshes from owner-approved free/licensed sources (licence logged) |
| Character animation | Default avatar animations + procedural sway (agent) |
| Icon & thumbnails | Placeholder by agent (staged screenshots); commission final icon after soft-launch data justifies spend |
| Audio | Licensed library SFX + one calm loop (agent selects, owner approves) |

### 10.8 Milestone plan (8 weeks at ~10 hrs/week owner + agent)

| Week | Milestone | Exit criteria |
|---|---|---|
| 1 | Prototype done (above) | Greenlight report |
| 2–3 | Vertical slice: ring 1 (4 islands) final-ish, flight polished, saving, FTUE v1 | 5 fresh testers complete FTUE unaided |
| 4–5 | Alpha: all Musts, rings 2–3 greybox, co-op tethering, shop | No blockers; analytics events firing |
| 6 | Beta: rings 2–3 built, mobile pass, performance pass, icon/thumbnail placeholders | 10+ testers; FTUE completion high in private test |
| 7 | Soft launch: public, ~25% of ad budget | Read FTUE funnel, D1, session length after enough new users |
| 8 | Fix top 3 issues; decide launch push vs. iterate vs. pivot | Thresholds agreed in week 1 |

### 10.9 Kill/pivot thresholds (written in week 1, numbers chosen by owner + agent)
- If FTUE completion is poor → fix FTUE (up to 2 cycles) before any other work.
- If D1 stays below the agreed threshold after 2 FTUE/loop fix cycles → pivot test: swap to the "co-op heavy deliveries only" mode, which testers enjoyed most.
- If still below after the pivot test → kill, write the postmortem, reuse the flight and saving modules, and prototype Lighthouse Keepers.

---

## Part 11 — Iterating With Data

### 11.1 What to read, in order
Official analytics docs (`production/analytics/`) cover acquisition, engagement, retention, monetization, funnels, economy events, custom events, performance, and error reports. Read in this order, because each step depends on the previous one:
1. **Performance and errors** — crashes, server errors, client FPS/memory on mobile. A broken game can't retain. DevForum threads report games dropping off after bugs drove players away early.
2. **FTUE funnel** (funnel events, `production/analytics/funnel-events.md`) — where in the first minutes do players drop?
3. **D1 retention** — the docs advise improving it through the **core loop**, **first-time user experience**, and **performance** (`production/analytics/retention.md`).
4. **D7 retention** — the docs tie it to the **progression system**.
5. **Session length and sessions per user** (engagement).
6. **Monetization** — conversion, ARPPU, product mix (only once retention is acceptable).
7. **Acquisition** — where players come from, and how thumbnails and icons perform.

Note from the docs: retention dips after a large influx of new users are typical and temporary. Don't panic over one cohort.

### 11.2 Small-sample caution
A DevForum thread titled "My game is in the top 10% engagement, but no one will ever play it" got replies pointing out that tiny samples distort averages (a single long session can skew the mean). Before acting on metrics, check the number of users in the cohort. With small numbers, use qualitative playtests instead.

### 11.3 Experiments
Roblox's Experiments feature (`production/experiments.md`) supports A/B tests with built-in and custom metrics (custom events, economy, funnel), early-harm detection, targeting, and a sample-ratio-mismatch check. Agent procedure:
1. Hypothesis ("Showing the target pad arrow for the first 3 deliveries raises FTUE completion").
2. One variable per experiment, wired through configs.
3. Primary metric plus guardrail metrics (D1, revenue).
4. Run until the tool reports a decision. Don't stop early because a number looks good.
5. Log the result in `docs/experiments.md`.

### 11.4 The iteration loop
`Measure → Find the biggest leak → Hypothesis → Smallest change → Ship (or experiment) → Measure`. One major change per update, so you can tell what worked. Write a changelog line for each.

### 11.5 Signals from discovery
Roblox's RDC 2025 announcements describe discovery ranking that optimizes for different audience segments and for both quick-hit and long-return games. Third-party commentary claims early retention is a heavy ranking signal, but Roblox hasn't published exact weights. The practical conclusion is the same either way: **engagement and retention earn traffic; launch spend alone does not.** The Fantasy Forest and Liftoff post-mortems both point to engagement/retention as the deciding factor, in opposite directions.

---

## Part 12 — When to Kill, Pivot, or Persevere

### 12.1 Decision table

| Situation | Evidence | Action |
|---|---|---|
| Prototype not fun after 3 days + 1 iteration | Testers stop early; nobody asks to keep playing | **Kill.** Park the idea; harvest reusable code. |
| Fun loop, poor FTUE | Good session length for those who get past minute 2; big early funnel drop | **Persevere:** FTUE work only. |
| Good FTUE, poor D1 | Players finish onboarding but don't return | **Iterate:** loop depth, early goals, reasons to return (dailies, unfinished goals). |
| Good D1, poor D7 | Return next day but fade within a week | **Iterate:** progression, content cadence, social ties. |
| One mode/feature far outperforms the rest | Analytics show most playtime in one sub-mode | **Pivot** toward that mode. |
| Metrics fine, but no traffic | Small cohorts; good retention | Fix the **store page** (icon, thumbnails, title, description), invite/referral hooks; modest ad test; creator outreach. |
| Metrics poor after 2–3 fix cycles at soft launch | Thresholds missed repeatedly | **Kill or major pivot**, per thresholds written in advance. Write the postmortem. |
| Owner exhausted / lost interest | Missed reviews, no time | **Pause or shrink** the cadence; consider a final "complete" update and move on. |

### 12.2 Kill well
- A Game Developer blog post-mortem about cancelling a project after roughly six months put it plainly: it's better to cancel once you realize it won't work than to keep investing in a project you already know won't succeed.
- Wooga's GDC Europe 2014 talk "The Art of Killing Games" made killing games a deliberate studio process for deciding whether a game is good enough to launch. Treat kills as normal portfolio management, not failure.
- When killing: write the postmortem, extract reusable modules into a shared library (or Roblox Packages), archive the place file and repo with a tag, and tell the owner exactly what transfers to the next project.

### 12.3 Lessons from real developers, in one line each
- *Fantasy Forest*: ads buy data, not success. Engagement unlocked organic growth.
- *Liftoff*: poor retention plus "crammed" development sank it. Instrument retention early.
- *Dungeon Life*: parallel prototypes improve your odds; they don't guarantee anything.
- *Grow a Garden*: small loops can win, but cadence has to be sustainable and can't replace depth.
- *Brawl Stars Pet Simulator* (mattqdev): borrowed IP means a takedown can erase all traction.
- *Steal a Brainrot* imitators: copying expression invites lawsuits, and clones go unseen.
- Wonder Works: design for creators and clips, and scale headcount only to proven revenue.
- Molegul (Roblox Developer Medium): think about the whole game. Animation, sound, and music create atmosphere.
- *99 Nights in the Forest* spotlight: tune intensity to the audience early (scary without alienating younger players).

---

## Sources

**Official Roblox documentation (local copy: `/home/user/Roblox/reference/creator-docs/content/en-us/`)**
- `production/game-design/prototyping.md` — paper vs. Studio prototyping, finding the fun, best practices.
- `production/roblox-user-base.md` — platform strengths, demographics (13+ majority), session behavior, social factors.
- `production/publishing/ip-guidelines.md` — IP policy, copyright/trademark basics, enforcement.
- `production/publishing/thumbnails.md` — 16:9 / 1920×1080 spec, thumbnail personalization (+8.5% average qualified play-through in testing).
- `production/analytics/retention.md` — D1/D7/D30 definitions; improving D1 (core loop, FTUE, performance) and D7 (progression).
- `production/experiments.md` — A/B experiments, custom metrics, early harm, decision-making.
- `production/game-design/liveops-planning.md`, `liveops-essentials.md`, `content-updates.md`, `core-loops.md`, `balance-virtual-economies.md`, `analytics-essentials.md`.
- `production/promotion/` — `ads-manager.md`, `invite-prompts.md`, `referral-system.md`, `share-links.md`, etc.
- `production/configs.md` — remote configuration.
- `projects/collaboration.md` — age-check requirements, permission levels, group roles.
- `projects/version-history.md` — version notes (required on publish), restore.
- `projects/place-files.md` — auto-recovery files, 100 MB place limit.
- `projects/assets/packages.md` — packages, auto-update, version history, third-party asset safety.
- `projects/groups.md`, `projects/game-ownership-transfer.md`.

**Roblox DevForum / Roblox-published (summarized from search excerpts; devforum.roblox.com was not directly fetchable from this environment)**
- FriendlyStoneGolem, "From 0 to 2000 players in 4 weeks: 'Fantasy Forest' launch post-mortem" — https://devforum.roblox.com/t/from-0-to-2000-players-in-4-weeks-fantasy-forest-launch-post-mortem/2044257
- Whimzer, "Liftoff - A Case Study" — https://devforum.roblox.com/t/liftoff-a-case-study/468266
- "So your game died... (A thread on game design and the market)" — https://devforum.roblox.com/t/so-your-game-died-a-thread-on-game-design-and-the-market/2644450
- "Why Games Fail, and How To Fix It - A Comprehensive Tutorial" — https://devforum.roblox.com/t/why-games-fail-and-how-to-fix-it-a-comprehensive-tutorial/1588819
- "My game is in the top 10% engagement, but no one will ever play it" — https://devforum.roblox.com/t/my-game-is-in-the-top-10-engagement-but-no-one-will-ever-play-it/2785010
- "Creator Spotlight: The Story Behind 99 Nights in the Forest" — https://devforum.roblox.com/t/creator-spotlight-the-story-behind-99-nights-in-the-forest/4036940
- "Ads for Creators: RDC Recap and What's Next" — https://devforum.roblox.com/t/ads-for-creators-rdc-recap-and-what%E2%80%99s-next/3929106
- "More Ads Manager Upgrades" — https://devforum.roblox.com/t/more-ads-manager-upgrades/3659656
- "Partially managed Rojo/Git workflow in teams" — https://devforum.roblox.com/t/partially-managed-rojo-git-workflow-in-teams/1381762 ; "What is your Rojo workflow?" — https://devforum.roblox.com/t/what-is-your-rojo-workflow/254604
- "What is a fair price to pay game builders and scripters in Robux or USD?" — https://devforum.roblox.com/t/what-is-a-fair-price-to-pay-game-builders-and-scripters-in-robux-or-usd/3027798 ; "Commission price guide for new developers" — https://devforum.roblox.com/t/commission-price-guide-for-new-developers/1356888
- Burnout threads: "Overcoming Burnout" — https://devforum.roblox.com/t/overcoming-burnout/413411 ; "How to stay persistent with completing a project (mental health tips)" — https://devforum.roblox.com/t/how-to-stay-persistent-with-completing-a-project-mental-health-tips/1090776
- Molegul, "Why Some Games Work and Others Don't" (Roblox Developer, Medium) — https://medium.com/roblox-developer/why-some-games-work-and-others-dont-9cc17b7ab499
- Roblox Developer Medium, "Player Retention: A First Look…" — https://medium.com/roblox-developer/player-retention-a-first-look-at-how-to-get-players-coming-back-to-your-game-9ae68826f466
- Jamie Fristrom, "From the Devs: If It Wasn't For Roblox…" — https://medium.com/roblox-developer/from-the-devs-if-it-wasnt-for-roblox-i-might-have-stopped-making-games-by-jamie-fristrom-e397fa41a595

**Developer interviews, retrospectives, press**
- Jamie Fristrom, "My Roblox Years: Dungeon Life and New Product Science" (Game Developer) — https://www.gamedeveloper.com/business/my-roblox-years-dungeon-life-and-new-product-science ; open-source repo — https://github.com/JamieFristrom/dungeonlife
- GamesBeat, "How Grow a Garden took off on Roblox | Janzen 'Jandel' Madsen interview" — https://gamesbeat.com/janzen-madsen-interview/
- PC Gamer on Grow a Garden's "new era" shift from weekly updates — https://www.pcgamer.com/games/survival-crafting/robloxs-top-experience-grow-a-garden-is-shifting-into-a-new-era-and-promises-deeper-farming-after-a-series-of-disappointing-updates-i-hope-the-community-can-see-this-change-as-a-positive-attempt-to-keep-the-game-fresh-and-enjoyable-for-everyone/ ; Game Rant — https://gamerant.com/roblox-grow-a-garden-weekly-events-changes/
- Roblox Tech Talks Episode 29 (with Jandel) — https://about.roblox.com/newsroom/2025/09/roblox-tech-talks-episode-29-creator
- mattqdev, "How I got 3M visits" (Brawl Stars Pet Simulator, launch to DMCA takedown) — https://mattqdev.github.io/blog/how-i-got-3m-visits
- Bloomberg, "Roblox's Hit Game 'Steal A Brainrot' Battles Its Many Imitators" (2026-03-24) — https://www.bloomberg.com/news/articles/2026-03-24/roblox-s-hit-game-steal-a-brainrot-battles-its-many-imitators ; The Star reprint — https://www.thestar.com.my/tech/tech-news/2026/03/25/robloxs-hit-game-steal-a-brainrot-battles-its-many-imitators ; PC Gamer on the Fortnite lawsuit — https://www.pcgamer.com/games/a-brainrot-themed-roblox-game-is-taking-a-brainrot-themed-fortnite-game-to-court-for-being-a-copy/
- HackerNoon, "Finding Success on Roblox, Launching Games with Zach Letter of Wonder Works" — https://hackernoon.com/finding-success-on-roblox-launching-games-with-zach-letter-of-wonder-works
- Player Driven podcast, "Betting the Studio: Zach Letter on Surviving the Cut…" — https://playerdriven.io/podcast/betting-the-studio-zach-letter-on-surviving-the-cut-and-building-roblox-s-1-licensed-game
- Forbes, "Wonder Works Studio Reveals The Creator Advantage On Roblox" (2026-08-21) — https://www.forbes.com/sites/ianshepherd/2026/08/21/wonder-works-studio-reveals-the-creator-advantage-on-roblox/
- Roblox Q3 2026 earnings call coverage (launch recency, retention commentary) — https://www.benzinga.com/news/26/10/62722787/roblox-q3-2026-earnings-call-transcript
- Roblox RDC announcements (discovery ranking) — https://finance.yahoo.com/technology/articles/roblox-unveils-ways-play-build-190000538.html

**GDC / production talks**
- Tom Francis, "Dealing with Scope Change in 'Heat Signature' and 'Gunpoint'" (GDC 2018) — https://gdcvault.com/play/1024932/ ; write-up — https://gamedeveloper.com/production/video-how-tom-francis-dealt-with-scope-change-while-making-i-heat-signature-i-
- Wooga, "The Art of Killing Games" (GDC Europe 2014) — summary at https://mobilefreetoplay.com/?p=149
- "Learning from failure: post mortem of an unborn" (Game Developer blog) — https://www.gamedeveloper.com/business/learning-from-failure-post-mortem-of-an-unborn
- Washburn et al., "What Went Right and What Went Wrong: An Analysis of 155 Postmortems from Game Development" (ICSE 2016) — https://swag.uwaterloo.ca/publications/what-went-right-and-what-went-wrong-an-analysis-of-155-postmortems-from-game-development.html

**Tools**
- Rojo docs, "Full vs. Partial" (v0.5) — https://rojo.space/docs/v0.5/reference/full-vs-partial/ ; "Recommended Workflows" (v7) — https://rojo.space/docs/v7/workflows/
