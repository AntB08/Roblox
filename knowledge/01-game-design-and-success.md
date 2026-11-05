# 01 — Game Design and Success on Roblox

*What makes Roblox games fun, sticky and discoverable: core loops, onboarding, retention, social hooks, progression, live ops, the discovery algorithm, analytics, audience, and the checklists the bot must fill in before building anything.*

Written 2026-11-05. Claim tags:
- **[official]**: Roblox Creator Docs (local mirror at `reference/creator-docs/content/en-us`, synced 2026-11-05), the Roblox newsroom, or Roblox shareholder letters.
- **[developer-reported]**: developers, DevForum posts, or press reporting of developer and Roblox statements.
- **[analysis/opinion]**: third-party trackers and analysts, or this chapter's own design reasoning.

> Method note: in this session, WebFetch could not reach devforum.roblox.com, about.roblox.com or gameanalytics.com because of DNS/allowlist limits. Web claims were collected through search-result summaries and cross-checked against each other. Anything not in the local official docs mirror should be treated as second-hand unless it is tagged [official]. The docs mirror is the most authoritative source available here, so it wins when sources conflict.

---

## TL;DR rules for the bot

1. **The fun has to show in the first 60 seconds, and the core loop has to complete at least once within 5 minutes.** Roblox's own guidance is to get users "into the fun... ideally in 5 minutes or less" [official]. First-play bounce in the 61–180 second window is a **negative ranking signal** [official].
2. **Design for return visits, not one long session.** The Home algorithm ranks on *play days per user* (D1, D2–7, D8–28) and *playtime per user* (capped at 60 min/user/day) [official]. Since April 2026, Roblox has deliberately weighted long-term retention above near-term spend [official/developer-reported]. Every game needs a reason to come back tomorrow.
3. **Make it multiplayer and friend-friendly.** *Intentional co-play days* (joining friends, invites, private servers) is an explicit ranking signal [official]. Single-player games "often find it harder to build and retain an audience on Roblox" [official]. Never make private servers expensive.
4. **The thumbnail and icon must match the gameplay exactly.** Play-through rate is the #1 signal [official]. A mismatch between metadata and content gets your exposure *reduced*, and misleading thumbnails cause bounces that hurt you twice [official].
5. **Be original in title, art, and place file.** "Non-unique games" whose metadata or place files resemble existing games are deprioritized [official]. Follow trends only with a real twist.
6. **Never lead with giveaways or "free Robux".** It is explicitly penalized [official].
7. **Mobile first.** About 80% of DAU play on mobile [official, 2024 10-K, via press]. Use big touch targets, little text, icon-driven UI, and test performance on low-end phones.
8. **Treat the audience as teens and young adults, with kids kept in mind.** Roughly two-thirds of DAU were 13+ by late 2025, and 18+ users reached 29% of age-checked DAU in Q3 2026 [official, via press]. Kids still matter, so keep it readable and visual.
9. **A new game first reaches only age-checked 16+ users.** Kids/Select (under-16) eligibility requires 250 unique plays from "highly engaged" age-checked 16+ players within 60 days, plus a Minimal/Mild/Moderate rating and creator verification [official]. Plan the launch funnel around this.
10. **Layer loops.** Use a core loop (seconds to minutes), a session loop (one sitting, with a goal), a meta loop (days and weeks: collection, rebirth, rank) and a social loop (trade, show off, co-op). Simple to start, deep to master.
11. **Ship small and on a schedule, then keep updating.** Roblox recommends small content updates every 2–4 weeks and larger feature updates every 2–3 months [official]. The top hits ran weekly updates and live events [developer-reported].
12. **Instrument everything from day one.** Add funnel events for the FTUE, progression events for level distribution, and economy events for sources and sinks. Use Configs and Experiments (A/B, 14–60 days) and thumbnail personalization (2–5 active thumbnails) [official].
13. **Avoid the generic look.** Default baseplate lighting, free-model clutter, unthemed UI, text-wall tutorials and placeholder names make a game read as AI-generated or low effort. Every game needs one memorable hook, a coherent art direction, and juicy feedback on every action.
14. **The algorithm keeps testing.** There is no permanent penalty for a weak start. Signals use a moving window, and an improved game can be re-tested and grow [official]. Fix the funnel, push an update, and refresh thumbnails.
15. **Fill in the Design Doc template and the Pre-Launch Checklist (end of this chapter) for every game, before writing code.**

---

## 1. How Roblox is different from other game platforms

**[official]** Roblox describes its users as valuing three strengths: **content variety**, **low friction** ("launch a new game and start playing in seconds"), and **social connection**. A Roblox session "typically means playing a handful of different games", and the platform is "closer in many ways to YouTube than the App Store" (`production/roblox-user-base.md`).

Consequences for design [analysis/opinion, derived from the official framing]:

| Platform property | Design consequence |
|---|---|
| Joining and leaving costs nothing | The first minute decides everything. There is no sunk cost (purchase price, install) to keep a bored player. |
| Players hop between games in a session | Your game competes with the game they will open next, so short loops and quick wins matter more than slow burns. |
| Friends follow friends into games | One player who invites three friends is worth more than four solo players: co-play is a ranking signal, and friends retain each other. |
| Shared avatar identity | Players want their avatar *seen*. Don't override avatars without a strong reason [official]. Cosmetics and showing off are powerful. |
| Platform-wide conventions | Copy UI conventions (hotbar at the bottom, shop button on the left, settings icon) so nothing needs explaining. Be original in theme and hook, not in where the buttons go. |
| YouTube/TikTok-driven culture | Design moments that make good clips: big reveals, rare drops, chaos, betrayal, jump scares. |

**[official]** Roblox's "tourists vs locals" model (`production/game-design/design-for-roblox.md`): *tourists* hop for variety, while *locals* go deep on a few games and "form almost all a game's engaged user base". "Many locals start out as tourists and convert", so the FTUE converts tourists and the meta loop keeps locals.

---

## 2. Case studies: why the top games worked (mechanics, not copies)

The bot must **not** clone these games. That is penalized as "non-unique" and is also a creative dead end. Extract the *underlying principle* from each one and apply it to a new theme and mechanic.

### 2.1 Scale context

| Game | Notable reported peak | Source quality |
|---|---|---|
| Steal a Brainrot | ~25.4M CCU (Oct 2025), the first single Roblox game above 25M | press [developer-reported], via PocketGamer.biz |
| Grow a Garden | ~21.9M CCU (reported June/July 2025); broke Blox Fruits' record | press, figures supplied by Roblox [developer-reported] |
| 99 Nights in the Forest | ~14.2M CCU peak (2025); film rights optioned by 20th Century Studios | PC Gamer [developer-reported] |
| Roblox platform | 47.4M platform CCU record (Aug 2025) | PocketGamer.biz [developer-reported] |
| Roblox platform (Oct 2026) | ~9.7M CCU snapshot across ~14K live experiences | RoWatcher [analysis/opinion] |

**[analysis/opinion]** Viral peaks decay fast. Steal a Brainrot sat around ~215K CCU in a 2026 RoWatcher snapshot, roughly 1% of its peak, and RoWatcher describes the brainrot genre as a "viral, high-churn layer" where loyalty attaches to the genre more than to any one game. Grow a Garden 2 launched 12 June 2026 and passed 400K CCU within 20 minutes [developer-reported via StudioKrew], which shows that a sequel can re-harvest an audience. By September–October 2026, new trend games ("Steal An Egg", "Sell Lemons", "Kick a Lucky Block", "Fish It") topped charts [analysis/opinion, trackers disagree]. **Lesson:** trend-surfing gives spikes. The Home algorithm, and therefore long-term traffic, now rewards D8–28 retention.

### 2.2 Principles extracted per game

| Game | Core loop (seconds to minutes) | Why it hooked players (the transferable principle) |
|---|---|---|
| **Grow a Garden** (2025) | Buy seeds from a restocking shop → plant → wait (crops grow in real time, **including offline**) → harvest → sell → buy better seeds | **Offline progress plus appointment mechanics.** The shop restocks on a timer and admin weather events apply rare mutations, so there is always a reason to check back. **Weekly Saturday updates with a pre-update "admin abuse" live event** made return visits a ritual [developer-reported]. A cosy, readable theme suits all ages. Trading and pets add a social and collection layer. 3/4 of its DAU also played other games [official, CFO, Q3 2025 call], so it was a "daily check-in" game rather than an exclusive one. |
| **Steal a Brainrot** (2025) | Buy characters off a conveyor → place them in your base → they generate cash per second → upgrade → **sneak into other bases to steal their characters, or defend yours** | **Idle tycoon plus PvP theft.** Passive income (tycoon) is combined with *loss* and *revenge*, which are strong emotional drivers. Other players become content. Meme-culture collectibles (Italian brainrot) gave instant cultural recognition and shareability. Weekend admin events and crossover events drove the peaks [developer-reported]. Critics point to pay-to-win pressure on kids [analysis/opinion], which is a risk to avoid. |
| **99 Nights in the Forest** (2025) | Explore the forest by day → gather wood and food → **keep the campfire alive** → survive the night monster → advance the day counter | **Cooperative survival with a clear, countable goal ("survive 99 nights").** Every session has a visible progress number, roles and classes give each friend a job, the monster gives tension, and rescue missions give purpose. It is co-op rather than competitive, so it is friendly to mixed-skill friend groups [analysis/opinion]. |
| **Dead Rails** (2025) | Ride a train across a procedurally generated frontier → stop to loot fuel, weapons and valuables → defend the train from undead at night → reach the end | **Familiar survival mechanics plus a novel setting (Wild West, zombies, a train as mobile base)**, per GameAnalytics' "MAYA: most advanced yet acceptable" framing [analysis/opinion]. Run-based structure with a destination, a team of up to 4, class unlocks instead of levels, and monetization added after retention was proven [analysis/opinion]. |
| **Blox Fruits** | Grind NPC quests → level → find or buy fruits (powers) → explore seas → boss raids and PvP | **Very long progression runway** (many levels and seas), anime power fantasy, rare-fruit spawns as a lottery, and fruit trading. Former CCU record holder [developer-reported]. |
| **Adopt Me!** | Care for pets (needs/tasks) → earn money → hatch eggs → age pets → **trade** | **Trading economy and collection.** Scarcity of limited pets, "neon/mega" fusion as a sink, and themed pet-variant drops as cheap, regular content [official: Roblox cites Adopt Me pet variants as the model content cadence]. |
| **Brookhaven RP** | Free-form roleplay: houses, cars, jobs, props | **The players are the content.** No goals needed: it is "playing house" [official]. A tool-rich sandbox for social pretend play, with a "Creator Cam" for YouTubers [official]. |
| **Doors** | Move through procedurally generated rooms → solve small puzzles → react to entities (sound and light cues) → reach room 100 | **Procedural horror with learnable rules.** Each entity has a tell (sound or flicker) and a counter, so death feels fair and fear becomes skill. Friend-group runs produce screams and clips, which made it a YouTuber favourite [developer-reported, PCGamesN]. QoL updates were cited by Roblox as examples [official]. |
| **Pet Simulator 99** | Break coins/breakables → earn currency → hatch eggs → unlock zones → rarer pets → repeat | **Collection plus numbers-go-up plus scarcity.** Huge/Titanic pets as status, a trading plaza, clans, and weekly Saturday updates [developer-reported]. Criticized for aggressive monetization and power creep [analysis/opinion], which is a warning, not a template. |
| **The Strongest Battlegrounds** | Spawn into an arena → combo-fight others with character movesets → respawn | **Skill-based PvP with no grind before fun.** Characters are immediately available and matches are short. Anime-inspired move sets (One Punch Man) made it widely credited with popularizing the "battlegrounds" sub-genre [analysis/opinion]. Revenue comes mostly from cosmetics and kill-effects, not power [analysis/opinion]. |
| **Fisch** | Cast → timing minigame to reel → catch → sell / log in bestiary → upgrade rod → new island | **One satisfying skill micro-interaction (the reel bar) at the centre of a collection meta (bestiary, rare and mutated fish).** Weather and events change what is catchable. (No rigorous published analysis was found, so this is [analysis/opinion].) |
| **Dress to Impress** | Theme announced → limited time to dress your avatar → runway walk → **players vote stars** → rank up | **Social judgement as the game.** Short timed rounds give urgency, avatar self-expression drives sharing, voting gives other players a role, and the format makes "content" for TikTok and YouTube. Boosted by influencers and a Charli XCX moment [developer-reported]. |
| **Tower Defense Simulator** | Queue with friends → place and upgrade towers → survive waves → earn coins → unlock towers | **Co-op strategy with build variety.** Tower unlocks as long-term meta, difficulty modes for mastery, and events with exclusive towers [analysis/opinion]. |
| **Jailbreak** | Prisoner escapes and robs locations ↔ police arrest | **Cops and robbers** (a childhood game [official]). Asymmetric roles create endless emergent chases. Vehicles are the collection and status layer. Season pass [official example]. Hidden visual hints in the prison escape teach without text [official]. |
| **Arsenal** | Kill → weapon advances (gun game) → first to final weapon wins | **Ultra-short matches with constant novelty** (weapon rotation per kill). Cosmetics as monetization. Appeals to older users [official]. |
| **Natural Disaster Survival** | Spawn on a map → random disaster → survive → next round | **Short rounds with random spectacle.** No learning curve, and every round is a different story. It shows how far a simple premise plus physics chaos can go [analysis/opinion]. |
| **Tower of Hell** | Climb a randomly assembled tower of obby sections with **no checkpoints**, before the timer resets the tower | **High-stakes skill obby.** Randomization keeps it fresh, the shared timer builds communal tension, and falling is funny to watch. Coins buy mutators and cosmetics [analysis/opinion]. |

### 2.3 Cross-cutting patterns from the hits [analysis/opinion]

1. **A one-sentence hook a 10-year-old can repeat.** "Grow plants, they grow even when you're offline." "Steal other people's brainrots." "Survive 99 nights with friends."
2. **Familiar plus one novel twist.** Each hit is a known genre (tycoon, survival, gacha-collection, obby) with *one* new idea (theft, a train base, offline growth, a fixed night count).
3. **Other players are central.** They are thieves, teammates, judges, trading partners or audiences.
4. **Visible, countable progress.** Money per second, day counter, room number, level, bestiary completion.
5. **Randomness with rare highs.** Mutations, rare spawns, lucky eggs and random disasters create moments worth screaming about and clipping.
6. **Appointment and event rhythm.** Restock timers, weekly update days, admin events and limited-time items.
7. **Low skill floor, real skill or knowledge ceiling.**
8. **Cheap content cadence.** New seeds, pets, brainrots, fish or towers are mostly art on top of existing systems [official: content cadence guidance].

---

## 3. Core loop and meta loop design

### 3.1 Roblox's official three-part definition [official]

From `production/game-design/core-loops.md`, a core loop has:
1. **Minute-to-minute interaction**: what the player is doing constantly (exploring, clicking, driving).
2. **Most repeated set of actions**: the defining mechanic (fighting, planting, stealing).
3. **Progression engine**: how actions turn into lasting change (upgrades, levels, unlocks). "Without a progression system, a game becomes repetitive, boring, and shallow."

### 3.2 The loop stack the bot should design

| Layer | Time scale | Question it answers | Examples |
|---|---|---|---|
| **Micro / interaction** | 1–10 s | "Does this feel good to do?" | A swing hits with VFX, sound and numbers. The reel bar snaps. Coins burst and fly to the counter. |
| **Core loop** | 30 s–3 min | "What do I do over and over?" | Gather → sell → upgrade. Round start → survive → reward. |
| **Session loop** | 10–30 min | "What am I trying to finish today?" | Unlock the next zone, finish a run, complete daily quests, hatch the event egg. |
| **Meta loop** | days–weeks | "Why come back tomorrow?" | Collection index, rebirth or prestige, ranks, season pass, offline growth, streaks. |
| **Social loop** | any | "Why bring friends / why do others matter?" | Co-op goals, trading, stealing, voting, leaderboards, showing off rare items. |
| **Live-ops loop** | weekly–monthly | "What's new?" | Weekly drops, events, limited items, new zones. |

### 3.3 Core-loop quality checklist [analysis/opinion, with official backing where noted]

- [ ] Every player action has **immediate feedback**: VFX, SFX, number pop and UI tick. "Anytime a player takes an action... it's imperative to provide clear feedback" [official, onboarding-techniques].
- [ ] The loop completes once in **under 2 minutes** for a new player.
- [ ] The **reward is visible before it is earned**: show the next upgrade, its cost, and a progress bar.
- [ ] There is a **choice**: at least two meaningful options per loop (which upgrade, which zone, which risk).
- [ ] There is **variance**: occasional rare or crit outcomes (5–10% "nice!" moments, under 1% "WOW" moments).
- [ ] It **scales**: numbers, zones or enemies that grow, so the loop doesn't feel identical at minute 30.
- [ ] There is a **sink**: currency has things to buy, upgrades, rebirths or consumables, or inflation kills goals (see `production/game-design/balance-virtual-economies.md`).
- [ ] It works **with 1 player and is better with 4**.
- [ ] It is **mobile-playable**, with one thumb ideally for the most-repeated action.

### 3.4 Avoid these loop anti-patterns [analysis/opinion]

- **Click-and-wait without decisions**: pure idle with nothing to choose churns after novelty fades.
- **Progress that doesn't change play**: numbers go up but nothing new happens. Every 5–15 minutes in the early game something should *unlock* (a new area, tool, enemy or mechanic).
- **Dead time**: long walks, long loading, long round intermissions with nothing to do. Give lobbies a mini-activity.
- **Gated fun**: the best mechanic only arrives after an hour, or behind a paywall. "Balance the progression system to not gate off the fun" [official, engagement doc].

---

## 4. First-time user experience (FTUE)

### 4.1 What Roblox says [official]

- The FTUE is measured by **D1 retention** and **onboarding goals** (`production/game-design/onboarding.md`).
- Three goals: **teach the essentials**, **get to the fun quickly**, **leave players wanting more** (short, mid and long-term goals plus an end-of-onboarding "moment of joy").
- "Ensure users have fun within the first five minutes", and "avoid long tutorials" (`production/analytics/engagement.md`).
- Make tutorials **visual** rather than text: arrows, glowing trails, highlights and in-world signs. "Players generally don't like to read instructions." Younger players may still be learning to read, and visuals don't need translation (`onboarding-techniques.md`).
- Use **contextual (just-in-time) tutorials**: teach a feature the first time a player meets it (Squishmallows' combine station example).
- Use **timed hints**: show a hint only to players who haven't acted after N seconds, where N comes from playtest data (Plant example: most players press within 10 s, so highlight at 11 s).
- **First-play bounce rate** is measured on a 61–180 s average window, and it is a negative RFY signal [official, discovery.md].
- The **New User First Session Retention** chart shows the percentage of new users still playing after X minutes, which makes it the FTUE diagnostic.

### 4.2 The first 60 seconds: second-by-second target [analysis/opinion]

| Time | What must happen |
|---|---|
| 0–5 s | Spawn into a **beautiful, readable, on-theme** space that matches the thumbnail. No menus, no "Play" screen unless the game needs it (and if it does, one big button). |
| 5–15 s | The player's first input does something satisfying: walk to a glowing objective, click the first plant, swing the first tool. One arrow or trail, no text walls. |
| 15–30 s | **First reward**: currency pops, a sound plays, a counter increments. The player understands the verb. |
| 30–60 s | **First upgrade or purchase**, which makes the next loop visibly faster or better. The player has now seen the whole core loop. |
| 1–3 min | Second and third loops, a first "rare" moment (a forced lucky drop is fine), and a hint of the bigger goal (locked zone, leaderboard, rare item on display). |
| 3–5 min | A **joy moment**: level up or unlock with fanfare. Introduce the session goal ("Unlock the Volcano: 0/1000"). Prompt to invite or play with friends *after* the player is having fun, not before. |
| 5–15 min | Introduce the meta loop (collection book, rebirth teaser, daily reward). Show other players' rare stuff. Set up a reason to return ("Your crops will be ready in 2 h", "Daily chest tomorrow"). |

### 4.3 FTUE rules [analysis/opinion unless tagged]

- **Spawn location matches the thumbnail**, or players feel tricked and bounce.
- **Never block movement with a modal** in the first 10 seconds. Ask for settings or names later.
- **Pre-load and stream**: show something playable while assets stream in. Long loads on mobile kill PTR and bounce rate.
- **Give starter currency or items** to let players touch the systems [official: test the starting amounts with Experiments].
- **Low early XP thresholds** so players level up in the first minutes [official: tune with Configs].
- **Track funnel steps** with Funnel Events, one per FTUE step (spawned, first action, first reward, first purchase, first upgrade, first zone unlock, minute 5, minute 10). Find the biggest drop and fix that first [official: retention.md describes this process].
- **The tutorial is skippable or invisible for returning players.**
- **Don't sell in the first minute.** A shop popup before the first fun moment is a classic bounce trigger. Starter packs come after the first loop at the earliest.

---

## 5. Retention: benchmarks and how to move them

### 5.1 Definitions [official]

- **D1/D7/D30 retention** = the percentage of new users who return on day 1, day 7 or day 30 after first play, cohorted by first-play date (`production/analytics/retention.md`).
- The **RFY signals** use different windows: play days per user and playtime per user over **D1, D2–7 and D8–28**, measured only on users acquired organically from Recommended For You (`discovery.md`, `discovery-faq.md`).

### 5.2 Benchmarks

There is **no official universal "good" number**. Roblox benchmarks are percentile bands (50th–90th) among "games with similar players", which requires 100+ DAU [official]. The docs' illustrative example shows a D1 benchmark band of **12.11%–18.73%** (50th–90th percentile) [official, illustrative only].

Community and third-party rules of thumb [analysis/opinion, unverified and genre-dependent]:

| Metric | Weak | OK | Good | Excellent / hit-level |
|---|---|---|---|---|
| D1 retention | <10% | 10–15% | 15–25% | 25–35%+ (simulators/tycoons tend higher, obbies lower) |
| D7 retention | <3% | 3–6% | 6–12% | 12–18%+ |
| D30 retention | <1% | 1–2% | 2–5% | 5%+ |
| D7/D1 ratio | <0.3 | 0.3–0.5 | >0.5 | — |
| Avg session length | <5 min | 8–15 min | 15–25 min | 25 min+ (hangout/RP higher) |

(Sources: RoWatcher genre tables and widely repeated DevForum guidance of "aim for 20–25% D1"; RoWatcher itself argues against a genre-agnostic figure. Session-length bands are this chapter's opinion. Always compare against the dashboard's similar-game benchmark instead.)

### 5.3 Which system fixes which metric [official mapping, from retention.md]

| Metric is low | Look at | Fix |
|---|---|---|
| First-session minutes / bounce | FTUE, load time, thumbnail match | Shorter, visual tutorial. Faster first reward. Match spawn to thumbnail. Check errors and performance. |
| **D1** | **Core loop, FTUE, performance** | Clear and fun core steps, balanced challenge, rewards. A joy moment. Preview future progress. |
| **D7** | **Progression system** | Short, mid and long goals. Content variety. Measure player distribution per level (grant a marker per level) and fix stalls. |
| **D30** | **"Ending system" / endgame** | Regular updates (small every 2–4 weeks, big every 2–3 months). Social mechanics: trading, parties, guilds, PvP, tournaments, leaderboards. |

### 5.4 Return-visit mechanics (pick 2–4 per game) [analysis/opinion]

| Mechanic | Strength | Caution |
|---|---|---|
| **Offline progress** (crops grow, idle income accrues, eggs incubate) | Very strong D1/D7 driver. Grow a Garden is the poster child. | Cap accumulation (e.g., 8–12 h) so it pulls players back rather than letting them skip days. |
| **Timers / restocks** (shop rotates every 5–15 min, daily stock) | Creates "check now" urgency inside the session and across days. | Too punishing feels like a chore. |
| **Daily rewards and streaks** | Simple D1–D7 lift. | Streak loss feels bad. Offer forgiveness (one missed day). |
| **Daily/weekly quests** | Gives session goals and variety. | Keep them achievable in 10–20 min. |
| **Collection index** (bestiary, pet index, badges) | Long meta, completionists. | Show silhouettes of what's missing. |
| **Rebirth / prestige** | Resets the loop with a permanent multiplier, doubling content life. | Each rebirth must feel faster and unlock something new. |
| **Scheduled live events** (weekly update day, weekend events) | Builds ritual and spikes CCU. | Must be sustainable for the team. |
| **Experience notifications** | Re-engage lapsed players ("Your garden is ready") [official]. | Use the in-game opt-in prompt [official]. Don't spam. |
| **Social obligations** (team base, clan, friend co-op progress) | Friends pull each other back. | Don't punish players whose friends are offline. |

---

## 6. Session length and pacing

- **[official]** RFY playtime per user is capped at **60 minutes per user per game per day**, so marathon sessions add nothing to ranking beyond an hour. Frequent returns (play days) matter more than very long sessions.
- **[official]** Creator Rewards: an **Active Spender** (someone who spent ≥ $9.99 on Roblox in the past 60 days) who plays your game **10+ minutes** in a day earns you **5 Robux**, when your game is among the first three experiences they launch that day (`creator-rewards.md`). The **Audience Expansion** reward pays **35%** of new or returning users' first $100 of purchases in their first two months [developer-reported via press; check the doc for current terms]. This is a direct incentive to design for a **10+ minute** first session and for being a "first stop of the day" game.
- **[analysis/opinion]** Target new-player first sessions of **10–20 min** and returning-player sessions of **15–30 min**. Round-based games should have rounds of **2–8 min** with **under 20 s** of intermission, and give lobby activities.
- **[analysis/opinion]** End sessions on a **cliffhanger**: "Next unlock at 92%", "Crops ready in 1 h", "Event starts Saturday".

---

## 7. Social and multiplayer hooks

**[official]** "Many users treat Roblox as a place to hang out with their friends... single-player games often find it harder to build and retain an audience." Social systems include parties, trading, guilds and competition. "Avoid making private servers prohibitively expensive" (`design-for-roblox.md`). *Intentional co-play days per user* (join-friend, invites, private servers) is an "Important" RFY signal [official]. Roblox reportedly also counts reserved-server sessions as intentional co-play [developer-reported].

### 7.1 Social hook menu [analysis/opinion]

| Hook | Mechanic | Example principle |
|---|---|---|
| **Co-op goal** | A shared objective only reachable together | Survive nights together, defend the train, finish the tower run as a team. |
| **Role differentiation** | Classes or roles that complement each other | A healer, a builder and a scout make each friend matter. |
| **Trading** | A player-to-player exchange with a safe trade UI | Scarcity creates economy and conversation. Needs anti-scam UI (both confirm, countdown). |
| **Showing off** | Visible rare items, titles, auras, pets that follow you, leaderboards in the lobby | Status is a major motivation, especially for teens. |
| **Competition** | PvP, races, leaderboards, voting | Short matches and a rematch button. |
| **Antagonism** | Stealing, raiding, sabotage, with defence options | Loss creates strong emotion. Always give counterplay and protection timers. |
| **Judgement / audience** | Voting, spectating, emotes | Turns other players into the reward system (Dress to Impress). |
| **Hangout space** | Social hub, emotes, music, photo spots | Players stay longer when friends are there. |
| **Invites and referrals** | `SocialService` invite prompts, rewards for playing with friends, **share links**, referral system [official: promotion docs] | Prompt invites after a fun moment and reward both sides. |
| **Private servers** | Free or cheap VIP servers | Supports friend groups and creators. Counted as co-play. |

### 7.2 Social design rules [analysis/opinion]

- **Matchmake friends into the same server and team by default.**
- **Group progress shouldn't punish solo play.** Use solo-friendly scaling (fewer enemies with fewer players).
- **Bring-a-friend bonuses** such as "+10% coins while playing with a friend" are common, cheap and effective.
- **Make other players visible doing cool things**, like rare pet hatches announced server-wide or a top-player statue.
- **Chat is restricted by age-check status and age band since January 2026** [official, via newsroom]. Users are grouped U9, 9–12, 13–15, 16–17, 18–20 and 21+, and by default chat only with adjacent groups unless they are Trusted Connections. Many players can't chat freely. **Design non-verbal communication**: emotes, pings, quick-chat wheels, gestures, and trade UIs that work without chat.

---

## 8. Progression systems

| System | What it gives | Design notes [analysis/opinion] |
|---|---|---|
| **Levels / XP** | Steady feedback | Fast early levels (level 2 within 1 min, level 5 within 10 min), then a smooth curve. Tune with Configs [official]. |
| **Gear / tool tiers** | Visible power growth | Each tier should *look* different (colour, VFX), not just have bigger numbers. |
| **Zones / worlds** | New scenery plus new mechanics | Gate them with a clear price or progress bar. A locked zone visible from the spawn is a powerful goal. |
| **Collection** (pets, fish, brainrots, cards) | Long meta, status, trading | Rarity tiers (Common → Secret). Show the odds (required for paid random items; see the Monetization chapter). Use an index with silhouettes. |
| **Rebirth / prestige** | Content multiplier | Reset currency and early upgrades for a permanent multiplier and a new unlock (pet slot, zone, cosmetic). The first rebirth should be achievable in session 2–3. |
| **Offline progress** | Return pull | Cap it and show a "while you were away" summary popup. |
| **Skill progression** | Mastery | Ranked modes, timed obby stages, harder difficulties (Hardcore modes). |
| **Season / battle pass** | A time-boxed goal ladder | Roblox calls it a straightforward framework for cadence releases [official, `season-pass-design.md`]. |
| **Quests** | Direction and variety | Introductory → daily → weekly → story. See `introduction-to-quest-design.md` [official]. |
| **Cosmetics** | Self-expression and status | No power. Best for older audiences and PvP fairness. |

**[official]** Measure progression: "track the number of users for each progression level... adjust tasks so users spend the proper amount of time on each level" (retention.md). Too fast and players run out of content. Too slow and they get bored.

**[analysis/opinion]** A sample pacing target for a simulator or tycoon:

| Milestone | Target time for an average new player |
|---|---|
| First upgrade | < 1 min |
| First new tool/pet tier | 3–5 min |
| First new zone | 10–20 min |
| First rebirth | 45–90 min of total playtime (session 2–4) |
| "Endgame" of launch content | 10–20 h for a committed player, so the cadence must refill before that |

---

## 9. Live ops, update cadence and events

### 9.1 Official guidance [official]

- **LiveOps** = content cadence + major updates + QoL + bug fixes (`liveops-essentials.md`).
- **Content cadence** builds on *existing systems* (new pets, vehicles, weapons, maps, quests, color variants), so artists can ship it quickly. Spend **fewer than three weeks of effort** per cadence drop. "Many games release content cadence updates every two weeks to one month" (`content-updates.md`).
- **Major updates** add new systems (social, competitive, collections, live events) and may take months.
- Retention doc: small updates every **2–4 weeks**, and big feature updates every **2–3 months**.
- Cadence content should **not be consumed immediately**. Gate it behind progression, limited-time events or season passes.
- A **routine release day** makes players check back and speculate. That is free marketing.
- **Experience Events** on the game details page let players opt in to be notified, with up to 5 event thumbnails. The Home page has a **Live Events** sort for limited-time events with quests and rewards [official, discovery.md].
- **Monitor events** with hourly data and compare the week before and after the event for lasting KPI impact (`liveops-planning.md`).

### 9.2 What the hits did [developer-reported]

- Grow a Garden: weekly updates on Saturdays, with an "admin abuse" session about 1 h before each drop where developers trigger rare weather and mutations across servers.
- Steal a Brainrot: weekend admin events and crossover events (an "Admin War" with Grow a Garden, an "Extinct" event, a "Yin Yang" event); a Bruno Mars in-game concert in January 2026 reportedly drew 12.8M concurrent users.
- Pet Simulator 99: weekly Saturday updates and dense seasonal events.

### 9.3 Live-ops plan template for the bot [analysis/opinion]

| Cadence | Content type | Effort | Purpose |
|---|---|---|---|
| Weekly (fixed day/time) | 1–3 new collectibles or items, a shop rotation, balance fixes, a mini-event (e.g., a double-coins hour) | Low | Ritual and return trigger |
| Every 2–4 weeks | Themed content drop (new zone fragment, a quest line, new enemies), limited-time event currency and items | Medium | D7/D30 and spending spike |
| Every 2–3 months | Major system (trading, clans, a new mode, a new world, a season pass) | High | Re-acquisition and re-test by the algorithm |
| Seasonal | Halloween, winter holidays, summer, back-to-school, Lunar New Year (pick themes that fit the audience) | Medium | Platform traffic peaks |

**[official]** Seasonality: Home traffic peaks on Saturdays, with summer/back-to-school and holiday cycles (discovery.md). **Ship updates late in the week (Thu–Sat)** to ride the weekend peak [analysis/opinion].

### 9.4 Limited-time event design checklist [analysis/opinion]

- [ ] Announce it in advance (in-game banner, Experience Event, group/Discord).
- [ ] Have a **memorable start moment** (map transformation, sky change, boss arrival) [official: liveops-planning].
- [ ] Use event currency earned through the *core loop* (not a separate minigame only).
- [ ] Have a reward ladder: something achievable in 1 session, something in 1 week, and a prestige item at the end.
- [ ] Limited items that remain tradable or visible afterwards create status.
- [ ] Make it **friend-amplified** (bonus for team play).
- [ ] Post-event: compare D1/D7, playtime and revenue against the prior week.

---

## 10. How discovery works (2026)

### 10.1 Recommended For You (Home) [official, discovery.md / discovery-faq.md]

Two stages:
1. **Retrieval**: choose candidate games per user based on engagement, retention and monetization. It requires "only a very low minimum number of plays from any source".
2. **Ranking**: a personalized ranking that narrows to **~100 games** shown on a user's Home.

**Signals** (all measured only on users who joined *organically from RFY*; all are **per-user averages**, so small games aren't disadvantaged):

| Priority | Signal | Notes |
|---|---|---|
| **Most important** | **Play-through rate (PTR)** | Plays ÷ RFY impressions, i.e. thumbnail, icon and title effectiveness. A temporary PTR drop during impression growth is normal. |
| **Most important** | **First-play bounce rate** (negative) | Leaves after a short session, 61–180 s window. |
| **Most important** | **Play days per user** | D1, D2–7 (out of 6 days), D8–28 |
| **Most important** | **Playtime per user** | Capped at 60 min/user/game/day |
| Important | **Intentional co-play days per user** | Joins, invites, private servers |
| Important | **Qualified play sessions per user** | Filters accidental clicks and quick bounces |
| Important | **Spend days per user** | Unique days with Robux spend |
| Important | **Robux spent per user** | |

Key official facts:
- **Explore and expand**: after an update, Roblox may show the game to new cohorts (explore). If they engage, it widens distribution (expand).
- Four things change your impressions: **your changes**, **algorithm changes**, **total Home traffic / seasonality**, and **competitors improving more than you**.
- **No permanent penalty.** Signals use a moving window and the algorithm "tests your game daily". Old games can grow again.
- **New games don't wait 28 days.** PTR and bounce count immediately, then D1, then D2–7, then D8–28.
- Strength in only retention *or* only monetization still gets impressions. Strength in both gets broader distribution. "If retention is low, focus on core gameplay first."
- Genre is **not** an explicit ranking factor. The algorithm learns from behavior. Accurate genre tags still matter because they set expectations and reduce bounces.
- Story-driven or finite games are **not penalized** for genre-typical low D8–28.
- **Ads do not hurt RFY.** Ad-acquired users are excluded from RFY signals and are considered "already acquired", so RFY impressions can dip while total acquisition rises.
- A **custom thumbnail is required** to receive Home recommendation impressions at all.

### 10.2 The 2026 shift toward long-term retention [official + developer-reported]

- A June 2026 Roblox newsroom post, "Optimizing Discovery: How Great Games Reach Millions of Players", says overvaluing short-term engagement "could favor games that win attention with exciting thumbnails but lack long-term value". RFY now weights long-term behavior (returning over time, bringing friends, spending) more heavily. Testing reportedly lifted platform DAU and engagement [official, via search summaries].
- Press and the Q2 2026 shareholder letter: the April 2026 change "intentionally provides more impressions for highly retentive games at the expense of near term monetization". Reporting says the retention lookback moved from 7 to 28 days. Roblox guided to its first bookings decline in four years, and the stock fell ~27–30% on 31 July 2026 [developer-reported via Motley Fool/Nasdaq/godisageek; the 7→28 day detail is unverified]. Q3 2026: DAU ~138M (-9% YoY), bookings ~$1.7B (-12% YoY), but "seasonally adjusted retention reached the highest level since 2021" [developer-reported via press].
- **Implication for the bot:** a thumbnail-bait, shallow game is now actively disadvantaged. **Build for D8–28 play days.**

### 10.3 Reduced exposure (quality filters) [official]

These reduce visibility in Home, Search and Charts:
- **Leading with giveaways** (e.g., a title like "Robux! Play now!").
- **Mismatched metadata and content** (dinosaur thumbnail, generic obby gameplay).
- **Non-unique games**: metadata *and/or place files* closely resembling existing games. Among indistinguishable games, Roblox highlights "the game that first added the unique metadata and/or placefile".
- Safety, moderation or Community Standards violations.

A banner appears on the Creator Dashboard if a game is affected. It updates daily, and appeals go through Support → Bug Report. Content quality is reclassified with every update.

**[developer-reported]** Developers complain enforcement is imperfect: AI-thumbnail shovelware still slips through, and some flags persist after fixes. In April 2026 the Roblox CEO reportedly said Roblox is testing filters against low-quality "brain rot" games [weakly sourced].

### 10.4 Other surfaces [official]

| Surface | How to win it |
|---|---|
| **Continue Playing** | Returning users. Driven by your retention. |
| **Friends activity / join** | Social design and invites. |
| **Sponsored (Ads Manager)** | Paid. Doesn't help or hurt RFY. Useful for seeding a new game's first plays and the 16+ evaluation threshold. |
| **Search** (now semantic, e.g., "food games") | An accurate title and description with natural-language keywords. No keyword stuffing. |
| **Discover / Charts** (Top Trending, Top Revisited, Fun with Friends, Up-and-Coming, CCU-based sorts; filterable by genre, country and device [developer-reported]) | Velocity of growth, revisits and co-play. |
| **Standout Games** (hand-curated) | Novel mechanics, distinctive visual style, under-represented genre. |
| **Live Events sort** | Run limited-time events with quests and rewards. |
| **Game details page** | Gameplay video (authentic, no voice-over, no promo text), events, group, passes. Shows "similar games". |
| **Notifications** | Experience notifications and in-game opt-in prompts to resurrect lapsed users. |
| **External** | Share links, deeplinks, social links, YouTube/TikTok creators. Design for streamability (e.g., a "creator cam" that hides UI) [official]. |

Scale: discovery served **>10.5B impressions/day** in early 2025, up from 7.5B a year earlier [official, 2025 Discovery Roadmap via search].

### 10.5 Thumbnails and icons [official, thumbnails.md / experience-icons.md]

- **Icon**: square, 512×512, readable at 150×150. Unique, relevant imagery, with colour and contrast that signal the genre (bright and saturated for fantasy, muted for moody, heavy contrast for horror).
- **Thumbnails**: 16:9, 1920×1080, up to 10 on the details page. Keep essential elements away from the **bottom**, which is covered by metadata like player count.
- **Thumbnail personalization (Home)**: activate **2–5** thumbnails. A multi-armed bandit shows each to random users, then favours the winner per user group while still exploring. It optimizes **qualified play-through rate**. In testing it gave **+8.5% average qPTR, up to +50%**. Keep multiple thumbnails active. Test new thumbnails with each major update, then leave them until the next update (the forum guidance says at least 7 days between changes [developer-reported]).
- **Video**: authentic gameplay only. No voice-over, no lyrics, no real-life footage, no "50% off / Free UGC" claims. Rejected videos count against a 3/month quota.
- **Experiments tool** (A/B in-game configs and matchmaking): 14–60 day runs, up to 2 variants plus control. It tracks D1/D7, playtime, ARPU, ARPPU and conversion, with early-harm alerts in the first 24 h. Prefer simple 50/50 tests on large rollouts [official, experiments.md]. (Thumbnail testing uses thumbnail personalization, not Experiments.)

**Thumbnail craft rules [analysis/opinion]:**
- One clear focal subject, a big readable silhouette, and 1–3 words maximum (or none).
- Show the **hook verb** (stealing, surviving, growing), not just scenery.
- Characters with expressive faces and action poses beat empty landscapes.
- High contrast against Roblox's light and dark UI, and it must read at phone size.
- It must be **honest**: everything shown exists in the first 5 minutes of play.
- Make 3–5 variants that differ meaningfully (character vs. action vs. rare item), not colour tweaks.

---

## 11. The Analytics dashboard: metrics to watch

**[official]** Creator Hub → your game → Analytics. Sections: Overview (benchmark scorecards, insights, realtime), **Acquisition** (sources, PTR, **Home Recommendations** tab with the RFY signal charts), **Engagement** (average session time, new user first-session retention), **Retention** (D1/D7/D30 cohorts, daily and weekly cohort tables with 7D playtime, conversion and revenue per user), **Monetization** (ARPDAU, ARPPU, conversion), **Demographics** (age, gender, country, language of MAU), Performance, Errors, Crashes, Custom/Economy/Funnel events, and Explore (custom charts and formulas).

Benchmarks: "experiences with similar players" (50th–90th percentile band, needs 100+ DAU). For overall-success KPIs, the pool is the top 1,000 games by 30-day playtime, with Top 200/500/1000 tiers [official].

Segments include active payer status, platform spender status ("Active" = spent ≥ $9.99 on Roblox in 60 days), and lifecycle (Early, Active, Lapsed, Reactivated) [official].

### 11.1 The bot's weekly metrics review

| Order | Metric | Healthy direction | If bad, look at |
|---|---|---|---|
| 1 | RFY **PTR** vs benchmark | ≥ 50th percentile | Icon/thumbnail/title. Run thumbnail personalization. |
| 2 | **First-play bounce** / first-session retention at 1, 3, 5, 10 min | Fewer drops | Spawn, load time, first reward, tutorial. |
| 3 | **D1 retention** and RFY D1 play days | ≥ benchmark P50 | Core loop, FTUE, performance. |
| 4 | **D2–7 / D7** | D7/D1 > 0.4 | Progression stalls (level distribution), daily goals. |
| 5 | **D8–28 / D30** | Rising | Endgame, social systems, cadence. |
| 6 | **Playtime per user**, average session time | 15–30 min | Pacing, dead time, session goals. |
| 7 | **Co-play days** | Rising | Invites, friend bonuses, private servers. |
| 8 | Conversion, ARPDAU, ARPPU | ≥ benchmark | (Monetization chapter.) Only after retention is solid [official guidance]. |
| 9 | Errors, crash rate, client FPS/memory by device | Flat or improving after updates | Mobile performance. |
| 10 | Funnel events | Find the biggest step drop | Fix one step per update. |

---

## 12. Audience demographics (2025–2026)

| Fact | Value | Tag / source |
|---|---|---|
| DAU | 151.5M (Q3 2025), 132M (Q1 2026), ~138M (Q3 2026, -9% YoY) | [official, shareholder letters via press] |
| 13+ share | "More users that are at least 13 years old than under 13" [official docs]. 13+ DAU grew 89% YoY in Q3 2025, about two-thirds of DAU, and **68% of hours** from 13+ | [official via press] |
| 18+ | 29% of global *age-checked* DAU (Q3 2026) | [official via press] |
| Under 13 | ~40% of users "last year" (2024), per Roblox in 2025 press | [developer-reported] |
| Platforms | ~80% of DAU on mobile, 17% PC, 3% console (2024 annual report). Mobile share of *spend* is lower (~46% per one analysis). | [official via PocketGamer.biz; spend figure analysis] |
| Regions | US/UK/Canada largest. Europe, APAC and rest of world growing fastest. | [official docs] |
| Engagement | 39.6B hours in Q3 2025, ~34B in Q3 2026 | [official via press] |
| Payers | ~30M monthly unique payers (Q3 2026, -16% YoY) | [official via press] |

### 12.1 Age systems that affect design [official]

- **Account tiers** (`production/publishing/kids-and-select.md`): **Roblox Kids** (5–8, Minimal/Mild content, chat off by default), **Roblox Select** (9–15, up to Moderate 9+, chat gradually introduced once age-checked), **Roblox** (age-checked 16+, all rated content except Restricted 18+).
- **Publishing to under-16s requires**: an age-checked and verified creator (facial age estimation under 18, government ID 18+), 2FA, a completed Maturity & Compliance Questionnaire with a Minimal/Mild/Moderate rating, a refundable fee *or* a 2+ month Roblox Plus/Premium subscription, and **evaluation**: the game first goes to age-checked 16+ only and must reach **250 unique plays from highly engaged age-checked users within 60 days** (account tenure, playtime, platform spend) plus a safety review. An optional **50,000 Robux refundable expedited review** exists.
- **16+ only path**: an age-checked creator; answering "No" to the age-restricted question gives "Content May Vary", available to age-checked 16+ users.
- **Restricted (18+)** content is limited to ID-verified 18+ users. (The older "17+" label has been superseded by these tiers. Check `production/promotion/content-maturity.md` before publishing.)
- **Chat** requires an age check (since Jan 2026 globally) and is limited to adjacent age bands [official newsroom via search].
- **Roblox Plus** (launched 30 April 2026, replaces Premium for new subscribers, $4.99/mo): creators can embed a subscription prompt and earn **250 Robux/month for each of a subscriber's first three months** [developer-reported via PC Gamer/DevForum].

**Design implications [analysis/opinion]:**
- **Launch content must work for 16+ age-checked players first.** They are your evaluation cohort and RFY seed. Teen and young-adult-friendly humour, competitive and social systems, and good feel matter.
- Keep content **Minimal/Mild** unless the concept needs more, so the game can graduate to all ages and its larger audience.
- Readability for kids is still critical (icons over text, simple goals). Older players value depth, fairness, cosmetics and skill expression.
- **Older users monetize and convert from tourist to local more** [official, design-for-roblox].

---

## 13. "AI-generated / generic" vs intentional

Roblox explicitly deprioritizes near-duplicates and mismatched metadata, and developers note a flood of low-effort shovelware with AI thumbnails [official + developer-reported]. Players also recognize "slop" instantly. The bot builds with AI, so it must actively avoid these tells.

| Generic / AI-tell | Intentional alternative |
|---|---|
| Default sky, flat Baseplate, default lighting, no atmosphere | Custom `Lighting` (Future/ShadowMap tech, colour correction, atmosphere, bloom matched to mood), a skybox that fits the theme, fog for depth. |
| Random free-model clutter in mismatched styles | One coherent art direction (palette of 5–7 colours, consistent material set, consistent scale and proportions). Build or generate assets *to the style guide*. |
| Generic names ("Simulator Game", "Epic Obby", "Mega Tycoon 2") | A distinctive title with a hook and personality. Check that it isn't already taken by a popular game. |
| Text-wall tutorials, many popups | Visual onboarding: trails, arrows, in-world signs, contextual tips. |
| UI from default `TextButton`s with Arial/Legacy fonts and no hierarchy | A styled UI kit: one display font plus one body font, rounded corners (`UICorner`), strokes, consistent icon set, hover and press animations, mobile-scaled. |
| Actions with no feedback | "Juice": tweened scale pops, particles, screen shake (sparing), satisfying SFX, number popups, coin fly-to-counter animations. |
| Mechanics bolted together with no theme logic | Every system justified by the fantasy (why does a farmer have pets? make it fit). |
| Lifeless world: no NPCs, ambient sound or motion | Ambient audio loops, animated props (swaying trees, flowing water), NPCs with idle animations and one-line personalities. |
| Identical rooms and repeated assets | Hand-placed landmarks and variation. Procedural generation *with* authored set pieces. |
| An AI-art thumbnail that doesn't resemble the game | A thumbnail rendered *in-engine* from the real game (free camera, posed characters, lighting), with optional post-processing that stays faithful. |
| Balance not tested (numbers explode or crawl) | Spreadsheet the economy, simulate progression, playtest, and track progression events. |
| No reason to exist beyond a trend | A one-sentence "why this is different" in the design doc, and the twist must be in the first 5 minutes. |
| Lore-free item names like "Sword 1, Sword 2" | Named items with rarity colour, a short flavour text, and a recognizable silhouette. |

**[analysis/opinion]** Ask: *"Would a player screenshot this?"* and *"Could a player describe what's special in one sentence?"* If not, the game isn't ready.

---

## 14. Common mistakes of new developers

| Mistake | Why it hurts | Fix |
|---|---|---|
| Building systems for months before testing whether the core loop is fun | Most ideas aren't fun, so effort is wasted | Graybox prototype in days, playtest, kill or continue (`production/game-design/prototyping.md` [official]). |
| A long or text-heavy tutorial | Bounce in 61–180 s is a negative signal [official] | Visual, contextual, under 60 s to the first reward. |
| Misleading or clickbait thumbnail | High bounce and possible reduced exposure [official] | Honest, in-engine, hook-focused. |
| Cloning a hit (same title or visuals) | "Non-unique" deprioritization [official]. You can't out-update the original. | Borrow principles, change theme and mechanic, add a real twist. |
| "Free Robux / giveaway" titles | Explicitly deprioritized [official] | Lead with gameplay. |
| A single-player design | Weak retention and no co-play signal [official] | Add co-op, trading, showing off and invites. |
| PC-only UI and controls | ~80% of players are on mobile | Mobile-first UI, test on a phone and on low-end devices. |
| Too much text / English-only | Young and international audience | Icons, visual language, localization (auto-translation plus key strings). |
| No progression past 30 min | D7 collapses | Plan the meta loop and 10+ hours of content runway, or rebirth. |
| Monetizing before retention | Ranking needs retention first. Pay-to-win drives churn [official guidance: fix retention first]. | Prove D1/D7, then add fair monetization. |
| Paywalling the fun / expensive private servers | Blocks social play [official] | Cosmetic and convenience monetization, cheap private servers. |
| No analytics events | Can't find the leak | Funnel, progression and economy events from day one. |
| Launch and abandon | RFY tests daily, and updates trigger "explore" | Plan 8–12 weeks of cadence before launch. |
| Ignoring performance | Mobile crashes and load times cause bounce | Streaming enabled, part and mesh budgets, test on low-end devices. |
| Buggy launch | First impressions and reviews (like ratio) | A pre-launch checklist and soft launch to the 16+ cohort. |
| Changing thumbnails daily | Personalization needs data | Batch changes per update, keep 2–5 active. |
| Building content only for kids, or only for adults | Audience is mixed, and the evaluation cohort is 16+ | A broad, readable theme with depth for teens and adults. |
| Inflation and an unbalanced economy | Goals become meaningless | Sources and sinks plan, Configs for live tuning. |

---

## 15. Design-doc template (the bot fills this in for every new game)

```markdown
# <Game Title> — Design Doc v0.1  (date)

## 1. Pitch
- One-sentence hook (a 10-year-old could repeat it):
- Genre (familiar base) + Twist (the one novel idea):
- Fantasy / emotion the player should feel (e.g. "clever thief", "cosy gardener", "brave survivor"):
- Why it is NOT a clone of <closest existing game>: (3 concrete differences)
- Target audience: age band(s), solo vs friends, casual vs mastery
- Content maturity target: Minimal / Mild / Moderate (justify)

## 2. Loops
- Micro interaction (1–10 s) + feedback (VFX/SFX/UI):
- Core loop (30 s–3 min) as a cycle: A → B → C → A
- Session loop (10–30 min) goal:
- Meta loop (days/weeks): collection / rebirth / ranks / offline progress / pass
- Social loop: co-op / trading / PvP / showing off / voting
- Live-ops loop: weekly drop day + event types

## 3. First-Time User Experience (timed script)
| Time | Player sees | Player does | Reward/feedback | Funnel event name |
| 0–5 s | | | | FTUE_Spawn |
| 5–15 s | | | | FTUE_FirstAction |
| 15–30 s | | | | FTUE_FirstReward |
| 30–60 s | | | | FTUE_FirstUpgrade |
| 1–3 min | | | | FTUE_Loop3 |
| 3–5 min | joy moment + session goal | | | FTUE_Goal |
| 5–15 min | meta loop intro + return hook | | | FTUE_Meta |

## 4. Progression & economy
- Currencies (soft / premium / event): sources & sinks table
- Level/zone/tier table with target time-to-reach
- Rebirth/prestige formula
- Rarity tiers and drop rates (with odds display)
- Offline progress cap
- Content runway at launch (hours for an engaged player):

## 5. Social design
- Max server size; friend matchmaking; team rules
- Co-op objective(s); role differentiation
- Trading? (safety UI) / PvP? (protection & counterplay)
- Show-off surfaces (leaderboards, auras, titles, announcements)
- Non-chat communication (emotes, pings, quick-chat)
- Invite & referral rewards; private server price

## 6. Retention hooks (pick 2–4)
- [ ] Offline progress  [ ] Timed restock  [ ] Daily reward/streak  [ ] Daily/weekly quests
- [ ] Collection index  [ ] Rebirth  [ ] Scheduled events  [ ] Notifications (opt-in prompt)

## 7. Monetization (summary; see Monetization chapter)
- Passes / dev products / subscriptions / Plus prompt / rewarded video — all fair, none block core fun
- First offer timing (never before first fun moment)

## 8. Art direction & feel
- Palette (hex), materials, lighting preset, sky, fog, music/ambience
- UI kit (fonts, corner radius, icon style), mobile layout sketch
- 3 "screenshot moments" the game will produce
- Juice list per action

## 9. Discovery assets
- Title (checked unique), description first line, genre tags
- Icon concept (512×512, readable at 150 px)
- 3–5 thumbnail concepts (distinct angles on the hook)
- 30-s gameplay video shot list

## 10. Tech & performance
- Server authority / anti-exploit for currency & trading
- DataStore schema + session locking; versioned migrations
- Streaming, part/mesh budgets, target 60 FPS mid phone / 30 FPS low-end
- Analytics events: funnel, progression, economy, custom

## 11. Live-ops plan (first 12 weeks)
| Week | Drop | Event | Experiment |

## 12. Success metrics & kill criteria
- Targets: PTR ≥ benchmark P50; 5-min first-session retention ≥ 60%; D1 ≥ 15%; D7 ≥ 5%; avg session ≥ 12 min
- Kill/pivot if after 2 iterations: D1 < 8% and 5-min retention < 40%
```

(The numeric targets in section 12 are this chapter's starting heuristics [analysis/opinion]. Replace them with the dashboard's similar-game benchmarks once the game has 100+ DAU.)

---

## 16. Pre-launch checklist (must be all ✅ or consciously waived)

### Concept and originality
- [ ] One-sentence hook written. Twist identified. Three concrete differences from the closest existing game.
- [ ] Title searched on Roblox: no popular game with the same or a confusingly similar name.
- [ ] No copied place files, models, thumbnails or UI from other games. All assets original or properly licensed.

### Fun and FTUE
- [ ] A new player reaches the first reward in **under 30 s** and completes the core loop in **under 2 min** (playtested with someone who has never seen the game).
- [ ] No mandatory text-reading to start. Visual guidance (arrows, trails, highlights) in place. Timed hints for stuck players.
- [ ] A joy moment within 5 min. Session goal and return hook visible by 10 min.
- [ ] Tutorial state saved, so returning players skip it.
- [ ] No shop or purchase popup before the first fun moment.

### Retention and progression
- [ ] At least 2 return hooks (offline progress, timers, dailies, events, notifications).
- [ ] Progression table simulated. At least 5 h of content for an engaged player, plus rebirth or endgame.
- [ ] Economy sources and sinks balanced. Key values in **Configs** for live tuning.

### Social
- [ ] Friends join the same server and team. Invite prompt after a fun moment. Bring-a-friend bonus.
- [ ] Works solo, better with friends. Non-chat communication (emotes and pings).
- [ ] Trading (if any) has a two-step confirm and server validation. PvP or theft (if any) has protection timers and counterplay.
- [ ] Private servers free or cheap.

### Mobile and performance
- [ ] Tested on a phone-sized viewport and with touch. Buttons ≥ 44 px equivalent. Nothing hidden under Roblox core UI (chat, leaderboard, top bar).
- [ ] Gamepad and keyboard bindings for core actions.
- [ ] Streaming enabled where appropriate. Load to playable in under ~10 s on mid devices. No server memory leaks over a 1 h soak test.
- [ ] Error log clean in a test server with multiple players.

### Data and security
- [ ] DataStore save/load with retries, session locking and autosave. Tested on rejoin and server shutdown (`BindToClose`).
- [ ] All currency, purchases and rewards are server-authoritative. Remotes validated and rate-limited.
- [ ] `ProcessReceipt` idempotent (see the Monetization chapter).

### Analytics
- [ ] Funnel events for each FTUE step. Progression events per level or zone. Economy events for every currency source and sink.
- [ ] At least one Experiment planned for after launch (e.g., starter currency or tutorial variant).

### Discovery assets
- [ ] Icon 512×512, unique, readable at 150 px, genre-appropriate colour.
- [ ] 3–5 thumbnails at 1920×1080, rendered in-engine, honest, no key info at the bottom. 2–5 activated for personalization.
- [ ] An authentic gameplay video (no voice-over or promo text).
- [ ] Description: the first line states the hook. Accurate genre. No keyword stuffing, no "free Robux".
- [ ] Social links, group and Discord set up (age-check rules apply).

### Compliance and audience
- [ ] Maturity & Compliance Questionnaire completed. Target rating achieved (Minimal/Mild preferred).
- [ ] Creator account age-checked and verified, 2FA on. Plan to reach the 250 highly-engaged-play threshold for Kids/Select (organic, friends, or sponsored ads), or budget the expedited review.
- [ ] Paid random items show odds. No gambling-like mechanics with real-money value. Community Standards reviewed.

### Live ops readiness
- [ ] Weekly update day chosen. The first 4 weekly drops prepared, plus 1 event designed.
- [ ] An Experience Event created for launch or the first event.
- [ ] Bug-report and feedback channel ready (in-game feedback or group).

### Launch plan
- [ ] Soft launch → watch PTR, bounce and 5-min retention for 48–72 h → fix the biggest funnel drop → update (triggers re-exploration) → refresh thumbnails.
- [ ] Launch timed for Thursday–Saturday to catch the weekend peak.

---

## 17. Quick reference: numbers worth remembering

| Number | Meaning | Tag |
|---|---|---|
| 5 min | Target for "fun reached / FTUE done" | [official] |
| 61–180 s | First-play bounce measurement window | [official] |
| 60 min/day | RFY playtime cap per user per game | [official] |
| D1, D2–7, D8–28 | RFY play-day and playtime windows | [official] |
| ~100 | Games shown on a user's Home after ranking | [official] |
| 2–5 | Active thumbnails for personalization; +8.5% avg qPTR in tests | [official] |
| 14–60 days | Experiment duration; ≤ 2 variants plus control | [official] |
| 2–4 weeks / 2–3 months | Small / big update cadence | [official] |
| < 3 weeks | Effort per content-cadence drop | [official] |
| 250 plays / 60 days | Highly engaged age-checked plays needed for Kids/Select | [official] |
| 50,000 Robux | Refundable expedited review fee | [official] |
| 5 Robux | Per Active Spender playing 10+ min (Daily Engagement Reward) | [official] |
| 512×512 / 1920×1080 | Icon / thumbnail sizes | [official] |
| ~80% | DAU on mobile (2024) | [official via press] |
| ~2/3 | DAU aged 13+ (late 2025) | [official via press] |
| 29% | 18+ share of age-checked DAU (Q3 2026) | [official via press] |
| 15–25% D1 | Community "good" rule of thumb (genre-dependent) | [analysis/opinion] |

---

## Sources

All accessed 2026-11-05. Local paths refer to the official docs mirror `reference/creator-docs/content/en-us/` (mirrors create.roblox.com/docs).

**Official Roblox documentation (local mirror)**
- Discovery: `discovery.md` (https://create.roblox.com/docs/discovery)
- Discovery FAQ: `discovery-faq.md` (https://create.roblox.com/docs/discovery-faq)
- The Roblox user base: `production/roblox-user-base.md`
- Design for Roblox: `production/game-design/design-for-roblox.md`
- Core loops: `production/game-design/core-loops.md`
- Onboarding: `production/game-design/onboarding.md`; Onboarding techniques: `production/game-design/onboarding-techniques.md`
- LiveOps essentials / planning / content updates: `production/game-design/liveops-essentials.md`, `liveops-planning.md`, `content-updates.md`
- Analytics: `production/analytics/retention.md`, `engagement.md`, `acquisition.md`, `analytics-dashboard.md`, `demographics.md`; `production/game-design/analytics-essentials.md`
- Experiments: `production/experiments.md`
- Thumbnails: `production/publishing/thumbnails.md`; Icons: `production/publishing/experience-icons.md`
- Roblox Kids and Select: `production/publishing/kids-and-select.md`
- Creator Rewards: `creator-rewards.md` (https://create.roblox.com/docs/creator-rewards)

**Roblox newsroom / corporate (via search summaries; direct fetch blocked)**
- Optimizing Discovery: How Great Games Reach Millions of Players (June 2026): https://about.roblox.com/newsroom/2026/06/optimizing-discovery-great-games-reach-millions-players-roblox
- Facial Age Checks Now Required to Chat (Jan 2026): https://about.roblox.com/newsroom/2026/01/roblox-age-checks-required-to-chat
- Introducing Roblox Plus (Apr 2026): https://about.roblox.com/newsroom/2026/04/introducing-roblox-plus-subscription ; https://devforum.roblox.com/t/introducing-roblox-plus/4567894
- RDC 2025: https://about.roblox.com/newsroom/2025/09/roblox-rdc-2025
- Q3 2025 Shareholder Letter: https://s27.q4cdn.com/984876518/files/doc_financials/2025/q3/Q3-2025-Shareholder-Letter.pdf
- Roblox 2025 Discovery Roadmap (DevForum): https://devforum.roblox.com/t/roblox’s-2025-discovery-roadmap-and-ways-to-reach-and-engage-your-audience/3557533
- Reducing exposure of low quality content (DevForum): https://devforum.roblox.com/t/improving-user-experience-by-reducing-exposure-of-low-quality-content/3299107
- Testing an Enhanced Discover Page: https://devforum.roblox.com/t/testing-an-enhanced-discover-page-top-charts-and-new-sorts/2954676
- Testing Improvements to RFY: https://devforum.roblox.com/t/testing-improvements-to-the-%E2%80%9Crecommended-for-you%E2%80%9D-algorithms/3275201
- How we are improving Home this year: https://devforum.roblox.com/t/how-we-are-improving-home-this-year/4502571

**Press and analysis**
- GamesBeat, Roblox 151M DAU Q3 2025: https://gamesbeat.com/roblox-had-151m-daily-active-users-in-q3-2025/
- Gaming.net / Securities.io, Roblox Q3 2026 results: https://gaming.net/roblox-q3-revenue-rises-16-as-bookings-fall-12-to-1-7-billion
- Motley Fool, Roblox guided bookings down / algorithm change (Jul 2026): https://www.fool.com/investing/2026/07/31/roblox-guided-bookings-down-as-much-as-18-and-with/
- Nasdaq, same: https://nasdaq.com/articles/roblox-guided-bookings-down-much-18-and-withdrew-its-full-year-outlook-algorithm-change
- God is a Geek, algorithm change and stock drop: https://godisageek.com/2026/08/roblox-9-billion-algorithm-change/
- PocketGamer.biz, 80% of Roblox users on mobile: https://www.pocketgamer.biz/80-of-roblox-users-are-on-mobile-contributing-46-of-robux-revenue
- PocketGamer.biz, Steal a Brainrot passes 25M CCU: https://www.pocketgamer.biz/robloxs-steal-a-brainrot-becomes-first-game-to-surpass-25m-concurrent-players
- PocketGamer.biz, platform CCU record 47.4M: https://www.pocketgamer.biz/robloxs-peak-concurrent-user-count-hits-record-474m-as-steal-a-brainrot-and-grow-a-garden-compete
- Wikipedia, Steal a Brainrot: https://en.wikipedia.org/wiki/Steal_a_Brainrot
- esports.gg, Grow a Garden breaks Blox Fruits record: https://esports.gg/news/roblox/grow-a-garden-breaks-blox-fruits-record-for-most-concurrent-users-on-roblox/
- ClickOrlando/AP, viral Grow a Garden: https://www.clickorlando.com/business/2025/07/30/millions-are-flocking-to-grow-virtual-gardens-in-viral-roblox-game-created-by-teenager/
- Sportskeeda / DigitalCitizen, Grow a Garden admin abuse schedule: https://www.sportskeeda.com/roblox-news/when-admin-abuse-start-grow-garden ; https://www.digitalcitizen.life/grow-a-garden-admin-abuse-schedule/
- PC Gamer, 99 Nights in the Forest 14.2M peak: https://www.pcgamer.com/games/survival-crafting/with-a-peak-player-count-of-14-2-million-99-nights-in-the-forest-has-an-audience-other-multiplayer-games-would-kill-for-to-find-these-behemoth-playerbases-you-need-to-be-on-a-platform-like-roblox/
- GameAnalytics, Dead Rails and the hit-maker's formula: https://gameanalytics.com/blog/dead-rails-and-the-hit-makers-formula
- PCGamesN, Doors and YouTubers: https://www.pcgamesn.com/roblox/doors-horror-game
- RoWatcher: Is the Brainrot Trend Dying?: https://rowatcher.com/news/is-the-brainrot-trend-dying-what-ccu-data-from-three-top-games-reveals
- RoWatcher: Retention benchmarks by genre: https://rowatcher.com/news/retention-benchmarks-by-roblox-genre-what-good-actually-looks-like
- RoWatcher: Inside BIG Games / Pet Simulator: https://rowatcher.com/news/inside-big-games-how-pet-simulator-became-a-100m-roblox-empire
- RoWatcher: The Strongest Battlegrounds: https://rowatcher.com/news/the-strongest-battlegrounds-how-one-punch-man-sparked-roblox-s-anime-fighter-revolution
- RoWatcher: Dress To Impress: https://rowatcher.com/news/dress-to-impress-how-a-teen-developer-s-fashion-game-hit-9-7-billion-visits
- StudioKrew top Roblox games (Jul–Sep 2026): https://studiokrew.com/blog/top-roblox-games-september-2026/
- Tubefilter, Creator Rewards: https://www.tubefilter.com/2025/06/24/roblox-creator-rewards-program-robux-for-engagement-retention/amp/
- Tubefilter, 2025 discovery roadmap: https://www.tubefilter.com/2025/03/20/roblox-discovery-roadmap-2025/
- GamesBeat, thumbnail personalization: https://gamesbeat.com/roblox-will-let-game-devs-personalize-thumbnails-to-attract-more-players/
- PC Gamer, facial age checks for chat: https://www.pcgamer.com/gaming-industry/roblox-to-make-facial-age-checks-mandatory-to-access-any-chat-features-and-will-put-common-sense-limits-on-the-age-ranges-users-can-chat-within
- PC Gamer, Roblox Plus: https://www.pcgamer.com/software/platforms/roblox-unveils-new-roblox-plus-monthly-subscription-that-pays-creators-who-get-players-to-sign-up-for-the-new-roblox-plus-monthly-subscription
- Endsights, Optimizing Discovery explainer: https://endsights.com/roblox-optimizing-discovery-how-great-games-reach-millions-of-players-on-roblox
