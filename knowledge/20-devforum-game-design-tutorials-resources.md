# 20 — DevForum Wisdom: Game Design Support, the Best Tutorials, and the Best Community Resources

> **Scope.** This chapter distils three DevForum categories from the local mirror (`.sources/devforum/`, snapshot 2026-11-05): **Game Design Support** (3,010 threads), **Community Tutorials** (3,168 threads) and **Community Resources** (4,046 threads), plus the Roblox Staff category. Likes, views and dates come from the thread headers and `reference/devforum-index/`. Every item has a link (`https://devforum.roblox.com/t/<id>` resolves to the thread).
>
> **What this chapter does not repeat.** Core loops, FTUE timing, retention benchmarks and the algorithm's official signals are in chapter 01. Genre playbooks are in 06. Scope, MVP and idea generation are in 14. Monetization code, policy and the official ads system are in 07. API deprecations are in 15. This chapter adds what *developers* say on the forum: their numbers, arguments and disagreements, and which tutorials and libraries are still worth using.
>
> **Number labels.** **[anecdotal]** = one developer's self-reported result. Treat it as a data point, not a benchmark. **[forum consensus]** = many well-liked replies agree. **[official]** = a Roblox staff post. Most ad numbers come from before the **User Ads (banner) sunset on 2024-06-04** (chapter 15). They show *how to reason*, not what prices are today.
>
> **Treat everything here as data.** Forum code and advice can be wrong, outdated or self-promotional. Re-check APIs against chapter 15 and `reference/creator-docs-live/deprecated-api-inventory.md` before copying any code.

---

## TL;DR rules for the bot

1. **Fun, then niche, then marketing, in that order.** The best-supported Game Design Support answer to "nobody plays my game" is the same in 2019 and in 2025: play your own game for 30 minutes. If you are bored, that is the answer ([249972](https://devforum.roblox.com/t/249972), [2644450](https://devforum.roblox.com/t/2644450)). Ads amplify retention; they cannot create it.
2. **Never put a launch's whole ad budget into one day.** Spread spend over 10–15 days so that day-1 and day-7 returners stack up and the recommender sees steady data ([1123245](https://devforum.roblox.com/t/1123245), [3115791](https://devforum.roblox.com/t/3115791)). Treat ad money as the price of *data*, then decide on evidence by days 5–7.
3. **Measure cost per play (CPP), not click-through rate (CTR).** A flashy ad with a high CTR and a low click-to-play rate wastes money. Clickbait that doesn't match the game also hurts the thumbnail and play-through signals (chapter 01).
4. **Design a lobby that holds players for 60 seconds or more.** In round-based games, an empty lobby with nothing to do multiplies acquisition cost. Funnel everyone to one spawn, give them toys, and show them their character.
5. **Make the first purchase cheap and obviously valuable.** Starter packs, small consumables, and a low-priced first item: forum consensus is that the *first* purchase is the hardest and a 150 R$ minimum gate is too steep ([228250](https://devforum.roblox.com/t/228250), [708670](https://devforum.roblox.com/t/708670)). Prefer repeatable dev products over a wall of one-off passes.
6. **Don't lock a core social feature behind Premium or a pass.** Gate *extras*, not the feature itself (customization, private servers, trading) ([1201008](https://devforum.roblox.com/t/1201008)).
7. **Never ship a "99% nothing" loot box, even with odds shown.** The forum calls it immoral, and policy (chapter 07/15) requires real outcomes and PolicyService gating ([3457220](https://devforum.roblox.com/t/3457220)).
8. **Watch players; don't poll them.** Players report pain points, not solutions. Work out the fix yourself and confirm it with funnel data and A/B tests ([75900](https://devforum.roblox.com/t/75900), [3064458](https://devforum.roblox.com/t/3064458), [4549276](https://devforum.roblox.com/t/4549276)).
9. **Copy structures, never "slop".** Low-effort trend clones are the subject of the bluntest replies on the forum ([4107600](https://devforum.roblox.com/t/4107600)). A distinct hook beats a saturated clone ([2644450](https://devforum.roblox.com/t/2644450), [2772921](https://devforum.roblox.com/t/2772921)).
10. **Treat tutorial code as a draft.** Most of the top-liked tutorials are from 2017–2021. Before reusing any of it, replace `wait/spawn/delay`, `Humanoid:LoadAnimation`, `FindPartOnRay`, `SetPrimaryPartCFrame`, `BodyMover`s, `:TweenPosition`, legacy `Chat` and `Lighting.Technology` (see the per-entry status notes in Part B).
11. **Data: use ProfileStore (vendored), not DataStore2 or ProfileService, for new games.** The most-liked tutorial on the whole forum (DataStore2, 5,574 likes) is for a deprecated library.
12. **Use community libraries only from known authors, pinned to a version, read before use, and preferably the vendored copy in `reference/libraries/`.** Never `require(assetId)` a module at runtime. Never insert closed-source or obfuscated "anti-cheat" free models.
13. **Don't build on server-side anti-cheat kits as your security.** Security means server-authoritative design: validate every remote by type, range, rate and ownership (chapter 11). A client anti-cheat is at best a speed bump; this is an open forum debate.
14. **Respect licenses and credit requirements.** TopbarPlus requires credit (or an unchanged attribute). DataPredict has a commercial revenue licence. MPL-2.0 (Satchel, CullThrottle) requires sharing modifications to those files.
15. **Protect the owner's accounts and group.** Front-page games have been stolen through fake verification bots ([3913726](https://devforum.roblox.com/t/3913726)). Never tell the owner to "verify" with a third-party bot a stranger links to.

---

## How to read the status tags in Parts B and C

| Tag | Meaning |
|---|---|
| **[Current]** | Code and APIs are fine as of 2026-11. Still check rollout properties (chapter 15 §2.3). |
| **[Update: X→Y]** | The ideas are good, but swap the named deprecated API for its replacement before reuse. |
| **[Concept]** | No code, or the code is incidental. The design or math is timeless. |
| **[Outdated]** | Superseded or broken. Read for history only, or skip. |
| **[Caution]** | Works, but carries policy, privacy, security or fragility risk. Read the note. |

The deprecation checks in Part B come from scanning each tutorial's text for deprecated calls (counts of `wait(`, `spawn(`, `FindPartOnRay`, `Body*`, `Humanoid:LoadAnimation`, `SetPrimaryPartCFrame`, `:TweenPosition`, legacy chat, `Technology`), cross-checked against chapter 15 §2.2 and the deprecated-API inventory.

---

# PART A — Game design wisdom from Game Design Support

## A.1 What the category actually asks

The most-liked Game Design Support threads fall into roughly five groups:

1. **Policy questions** ("Is X allowed?": suicide references, slavery, smoking signs, drawing games, dating sims, gore, flags, casinos, rank-selling). These are the top-liked threads by far ([265010](https://devforum.roblox.com/t/265010) 579 likes, [2813124](https://devforum.roblox.com/t/2813124) 480 likes, [745280](https://devforum.roblox.com/t/745280) 321 likes). The answers are dated; use chapter 07 §7 and the current Community Standards instead.
2. **Getting players and spending on ads** (the largest *design* cluster).
3. **Monetization and fairness** (pricing, Premium-only features, loot boxes, refunds).
4. **Genre viability and mechanics** (RPGs, permadeath, horror, realism vs cartoon, education).
5. **People** (hiring, payment, solo development, player toxicity, motivation).

The sections below cover groups 2–5.

## A.2 Getting players without money

**Best-supported answer: make the game worth sharing, then seed it socially** ([401593](https://devforum.roblox.com/t/401593), [470064](https://devforum.roblox.com/t/470064), [965994](https://devforum.roblox.com/t/965994)).

- **Have a "Thing"**, one property the game is known for: Rogue Lineage's difficulty and permadeath, Bee Swarm's personality, Wild West's freedom (Kotojo, 45 likes, [401593](https://devforum.roblox.com/t/401593)). The bot should be able to name its game's Thing in a few words. This is the same hook test as chapter 14 §3.2.
- **The game must work with one player.** Kotojo calls this the "snowball": if a lone joiner leaves because the game needs four players, you never reach four. Design a solo-viable state, such as bots, solo rounds, or a server as "Simon". The OP of that thread rebuilt their round start to allow single-player and reported the change was small.
- **Bring 5+ friends to seed a server.** A populated server shows up in sorts and lets newcomers see activity (stef0206, [965994](https://devforum.roblox.com/t/965994)). Several developers report reaching their first 100 CCU by bringing friends, then small streamers with 1k–20k subscribers (Cyrphex, *Vibe NYC*, ~1 week to 100 CCU **[anecdotal, 2021]**).
- **Small YouTubers and TikTokers who cover your genre**, contacted professionally. Give them codes and unlocked access, and match the creator to the genre: a horror-lore channel won't play a pet sim ([2521861](https://devforum.roblox.com/t/2521861), [2535279](https://devforum.roblox.com/t/2535279)).
- **Social media is a supplement, not a launch engine.** AtreyuDev argues that "social media almost never picks up" unless the game reads well in a 30-second clip, and that a one-day influencer spike gives the recommender one good day and many bad ones ([3115791](https://devforum.roblox.com/t/3115791)). TheAmazeman (2019) calls social media "negligible in the grand scheme". **Disagreement:** dantheprogram (41 likes, [303933](https://devforum.roblox.com/t/303933)) and the Sensei_Developer/Vikinglaw interview ([2535279](https://devforum.roblox.com/t/2535279)) rate social media and networking highly.
- **Don't use keyword tags in the description.** They look desperate and are a spam signal. Write a natural sentence that contains the keywords instead ([1155140](https://devforum.roblox.com/t/1155140)).
- **Note on platform rules:** in-game social links are banned since 2026-02-23 (chapter 15 rule 13). Put community links on the game page only.

## A.3 Paid acquisition: what developers report

> All numbers are **[anecdotal]** and most come from the pre-2024 Sponsored/User-Ads system. Today's system is Ads Manager (Sponsored, Search, Rewarded; objectives Plays/Earnings/Engagement; see chapter 07 §11).

### A.3.1 The reasoning that still applies

**Don't advertise a game that doesn't retain.** Sharksie (27 likes, [110692](https://devforum.roblox.com/t/110692)): "You have no business running ads until your game is making money." paul2448 adds the arithmetic. Buying Robux to advertise is a bad trade because you buy Robux at retail and earn them back at the DevEx rate, so you must earn back far more Robux than you spent. A launch with a heavy ad push also tells you nothing about organic appeal.

**Disagreement.** Kampfkarren (31 likes, same thread) calls that "a completely awful way of thinking about advertising if you're not already a name". Ads are "hands down the easiest way to get players" if the game and the ad are good. The 2024 view (AtreyuDev, [3115791](https://devforum.roblox.com/t/3115791)) sides with Kampfkarren for launches: "advertising is better for the release". The forum has converged on this compromise:

- **Small test campaigns first.** Spend about 1k R$ per creative to learn its CTR before scaling (CJ_Oyer, [1123245](https://devforum.roblox.com/t/1123245); TheodoreBalfour, [303933](https://devforum.roblox.com/t/303933)).
- **Then a sustained run, never one big day** (§A.3.3).
- **Augustus_Alderidge** ([1922578](https://devforum.roblox.com/t/1922578)) argues that earned Robux are worth less than bought Robux, so reinvest earnings into ads rather than DevExing early, and avoid buying Robux at retail.

### A.3.2 Think in cost per play (CPP)

CJ_Oyer's reply (47 likes) to a developer who spent ~200k R$ for ~4k visits is the clearest piece of ad analysis on the category ([1123245](https://devforum.roblox.com/t/1123245)):

- **CPP = spend ÷ plays.** At 200k R$ for 4k visits, CPP ≈ 50 R$, which is awful.
- At the time, weekends gave ~50% of weekday impressions per Robux because more developers bid on weekends.
- The sponsorship screen showed an attributed CPP (~4 R$) that hid a direct-click CPP of ~20–25 R$.
- A worked example: ~100 impressions per R$ × 0.75% CTR × 25% click-to-play gives ~5.3 R$ per play. On that basis, banner ads beat sponsorships 4–5× and skewed to PC players, who spend more **[anecdotal, 2021; banner ads no longer exist]**.

TheAmazeman's **Economic Guide** ([122318](https://devforum.roblox.com/t/122318), 594 likes) gives the same method as a spreadsheet: estimated clicks = spend × impressions/R$ × CTR, multiplied by an assumed play-through rate and an organic "popularity boost". It also warns about **diminishing returns**: CTR falls as spend rises because the same audience gets tired of the ad.

**CTR thresholds people quote:** ≥1.0% is the minimum and ~3% is the aim ([574695](https://devforum.roblox.com/t/574695), [2535279](https://devforum.roblox.com/t/2535279)) **[anecdotal]**. Several developers note that deliberately "ugly" or simple ads get 2–3% CTR while polished ones underperform (reply in [574695](https://devforum.roblox.com/t/574695)). Clickbait raises CTR but lowers click-to-play and hurts rating and retention. Today it also violates the metadata-match rule (chapter 01 rule 4).

### A.3.3 Spread spend to stack retention

CJ_Oyer's model ([1123245](https://devforum.roblox.com/t/1123245)) assumes a top-250 game typically has **D1 ≈ 25%, D7 ≈ 10%** **[anecdotal, 2021; see chapter 01 §5.2 for official benchmarks]**. Put 100k R$ into one day at 5 R$ CPP and you get 20k new players; a week later ~2k are returning, enough to fill about one server. Split the same budget over a week and the returners from each day stack on top of each other, which keeps DAU up and gives the recommender a reason to pick the game up.

AtreyuDev (2024, [3115791](https://devforum.roblox.com/t/3115791)) gives a modern version:

- Spend **≥10,000 R$ spread over 10–15 days**.
- Run sponsorship in **2–4 day intervals**.
- Over-advertise in the first three days to learn which device and age group retains, then target them.
- **Low max bid** (0.02 at the time) because unspent budget is refunded.
- "If by the 5th–7th day you're still getting bad metrics, it might be time to abandon the project."
- His claim that Roblox "decides how much a game will get promoted" within the first 10–25 days is **unverified** and conflicts with the official statement that there's no permanent penalty and signals use a moving window (chapter 01 rule 14).

### A.3.4 Reported outcomes (all [anecdotal])

| Report | Spend | Result | Lesson drawn by repliers |
|---|---|---|---|
| Cheedaman, *BEAR*, 2019 ([303933](https://devforum.roblox.com/t/303933)) | ~2,000 R$ phone sponsors | Went viral, later grew without ads | Luck plus a strong concept and thumbnail. Stay in close contact with players; big updates drove growth spikes. |
| Rawblocky, 2019 ([303933](https://devforum.roblox.com/t/303933)) | 5k–7.5k R$ Friday phone sponsors | ~3M estimated impressions | Phone inventory was far larger than PC or tablet. **Add an in-game shop:** sales "skyrocketed" once passes were sold in-game rather than only on the store page. |
| GuerillaMayhem's friend, 2019 ([303933](https://devforum.roblox.com/t/303933)) | 20k R$ | 10k visits, ~50 CCU, collapsed after 2 days | One-shot spend doesn't stick. |
| *Watch Slamos* dev, 2020 ([659454](https://devforum.roblox.com/t/659454)) | ~10k R$ ads+sponsors | Max 20 CCU | The ad didn't say what the game is. A click only reaches the game page, which must then sell the game. |
| *Dungeon Royale*, 2021 ([1123245](https://devforum.roblox.com/t/1123245)) | ~200k R$ | ≤25 CCU, ~4k visits, near-zero spend | CPP ≈ 50, empty lobby, text-wall tutorial, split spawn pads. |
| *Mushroom Simulator*, 2022 ([1757112](https://devforum.roblox.com/t/1757112)) | 260k R$ (110k sponsor) | ~5k visits, 80 CCU | "Clickbait" ads. Others reported **ad inflation**: the same 2k R$ that bought 2.3k clicks dropped to 600–700 clicks within 5 months. Another dev got 29.6k attributed visits from 15k R$, roughly 119× better. Results vary wildly. |
| *The Part Game*, 2023 ([2521861](https://devforum.roblox.com/t/2521861)) | 30k R$ (2k/weekday × 3 weeks) | ~2.3k visits | Ad efficiency had worsened. Players now find games through Recommended, not Discord. |
| Portal ads test, 2024 ([2872724](https://devforum.roblox.com/t/2872724)) | 2-day portal campaign | 200 → 1,000 CCU for ~15 minutes, then gone; stats later changed (900 plays became 7) | Suspected bot traffic or a broken system. Several devs reported the same spike. **Treat brand-new ad formats with suspicion** and judge them on retained players. |
| SheriffTaco, 2020 ([610313](https://devforum.roblox.com/t/610313)) | 5k R$ at launch | Grew rapidly in week 1 (hangout/RP) | Works if players come back daily. iGottic's reply on the same question: 10k R$ is "huge and risky"; start with 1k. |
| Sensei_Developer interview, 2023 ([2535279](https://devforum.roblox.com/t/2535279)) | n/a | "In today's age you most certainly need Robux to grow." Grinding Group Recruitment Plaza still works but is weak | Capital matters more than in 2018. |

**Bot rule:** budget soft-launch ads only to learn D1, session length and conversion (chapter 14 rule 13). Report CPP and retained players to the owner, not impressions.

## A.4 Retention, onboarding and pacing

**Playtime bands** quoted by AtreyuDev ([3115791](https://devforum.roblox.com/t/3115791)) **[anecdotal, 2024]**: under 5 min is bad, 5–7 average, 7–9 good, 9–15 excellent, over 15 "crazy good". He adds that reliable metrics need a few thousand daily visits. Don't over-read a 50-visit day.

**Three goal horizons** ([2772921](https://devforum.roblox.com/t/2772921)):

- **Short:** the next round, kill or level. This is the backbone.
- **Mid:** a new weapon or skin, a challenge. These must be created deliberately through quests.
- **Long:** a season pass or the best weapon. These must feel worth the journey and must not imply the game is "finished".

This matches chapter 01 §3's loop stack.

**Onboarding techniques, ranked by the forum** (CJ_Oyer, [1123245](https://devforum.roblox.com/t/1123245)):

1. **Intuitive design**, such as Jailbreak's floor arrows: environmental cues, contrast, signage, room shape.
2. **Situational prompts:** a small hint the first time a player meets each mechanic.
3. **Not teaching at all** for familiar genres. A battle royale needs little explanation, and some discovery is fun.
4. **Never a wall of text.**

In **Improving Onboarding through Funnel Events** ([3064458](https://devforum.roblox.com/t/3064458), staff **[official]**), Roblox's own sample game *Plant* lost **70.48% of players between spawning and planting their first seed**, and fewer than 3% finished the 9-step funnel. The suggested diagnosis order: bug or performance → goal unclear → mechanic unclear → genuine disinterest. Disinterest is the least likely if the icon and title match the game. **Bot rule:** instrument every FTUE step with `AnalyticsService:LogOnboardingFunnelStepEvent` and fix the largest single drop first.

**Social stickiness:** players who join with friends stay longer and leave less, because friends "hold them accountable" ([2772921](https://devforum.roblox.com/t/2772921)). Make inviting and party-joining easy (chapter 01 rule 3).

**Experiments work** ([4549276](https://devforum.roblox.com/t/4549276), staff, 2026 **[official]**). In Q1 2026 about 1 in 4 of over a thousand experiments produced a statistically significant playtime lift, averaging ~5%. The creator case studies:

- *Build a Crazy Tower*: tuning difficulty (block pools) gave **+50% payer conversion** and +10% session time.
- *Trolls cannot break this tower*: a free reward at the end of a level gave **+12.5% playtime** and +5.3% D1 "without negatively impacting monetization".
- *Weird Gun Game*: replacing the shop with level-based progression gave +10% D1.

The lesson the developers drew: "developer intuition and actual player behavior can vary dramatically."

**Loading screens** ([348161](https://devforum.roblox.com/t/348161)): "The best loading screen is no loading screen at all" (Intended_Pun, 23 likes). If you need one, make it entertaining, or say *what* is loading (sleitnick). Keep it short and skippable. Chapter 03 covers the UI side.

**Permadeath** ([272066](https://devforum.roblox.com/t/272066)): it suits mature, skill-based niches like Rogue Lineage. It works only if a fresh character can, with skill, beat a geared one; otherwise there are no stakes. Most repliers suggest softer penalties (lives, timeouts) for Roblox's broad audience.

## A.5 Monetization: fairness and what converts

**Player spending stages** ([246902](https://devforum.roblox.com/t/246902), Monetisation 101, 478 likes): first purchase → repeat purchase → heavy spender. The first purchase is the hardest and is usually small and self-congratulatory. The post cites an RDC 2018 figure that "95% of people who purchase Robux purchase it more than once" **[cited third-hand; unverified]**. It recommends:

- **Pay to join only as a soft launch or early-access step.** It raises like ratio but limits reach.
- **Battle passes** that pay back enough currency to almost buy the next pass.
- **Slowly accrued hard currency** that teases bigger purchases.
- **Exclusivity**: keep premium currency scarce or it loses value.

**Concrete conversion advice that recurs:**

- **Starter pack / first-purchase deal** with very high value at low price, plus a reward for buying several times (Thezi, [228250](https://devforum.roblox.com/t/228250)).
- **Lower the entry price.** A 150 R$ cheapest pass is "an expensive first time investment". Add repeatable dev products in the 30–60 R$ range (02Alien, [708670](https://devforum.roblox.com/t/708670)).
- **Sell inside the game, at the moment of need**, not only on the store page (Rawblocky, [303933](https://devforum.roblox.com/t/303933)).
- **Audience age matters.** Overly complex games don't get kids asking parents for Robux ([708670](https://devforum.roblox.com/t/708670)).
- **Genre isn't destiny.** "You can design any genre of game to make you money... the more players enjoy your game, the more they will be willing to spend" (Fm_Trick, 22 likes, [350494](https://devforum.roblox.com/t/350494)). **Disagreement:** Lawnmovver replies that pure cash grabs "worked" for people he knows. In 2025 an admitted cash-grab simulator earned **0.18 R$ ARPDAU vs 1–2 for the dev's earlier ones** and drew the reply "Stop creating slop" ([4107600](https://devforum.roblox.com/t/4107600)) **[anecdotal]**.

**Revenue-per-visit benchmarks people shared (all [anecdotal], 2018):** "a properly monetized game makes somewhere between 0.5 and 2 R$ per visit" (paul2448, [110692](https://devforum.roblox.com/t/110692)). One simulator reported 2.2 R$/visit and 55 R$ per unique visitor. A #2 top-earner reported ~1 R$/visit. Front-page traffic lowers R$/visit because casual players flood in ([97380](https://devforum.roblox.com/t/97380)). These figures predate Creator Rewards, rewarded ads and regional pricing. Use ARPDAU and payer conversion from Creator Analytics instead (chapter 07).

**Fairness rulings from the forum:**

- **Premium-only character customization: unfair.** Give Premium players *extra* options, not the whole feature ([1201008](https://devforum.roblox.com/t/1201008)).
- **"99% nothing" loot box: don't.** Even if odds are shown, repliers say it is unethical and probably against the spirit of the paid-random-item rules ([3457220](https://devforum.roblox.com/t/3457220)). Chapter 15 rule 19 adds "no lose-everything outcome".
- **Refund requests:** Roblox has no developer refund button, and all sales are final. The forum advice is to stay calm, verify the purchase, point players to Roblox support, and not be guilted into group payouts ([100414](https://devforum.roblox.com/t/100414)). **Update (2026):** Roblox now does refund some purchases. Subscribe to the *Transaction Refunded* webhook and revoke what was granted (chapter 15 rule 18).
- **Subscriptions** ([2710072](https://devforum.roblox.com/t/2710072), staff case study, Livetopia **[official]**). Livetopia bundled ten ~99 R$ premium houses plus one new house a month into a $2.99/month subscription (price at the time), shown next to the single-item price at the point of browsing. It was built in four days. Design rules: real monthly value, trust, and synergy with the core loop.
- **Rewarded and immersive ads** are covered in chapter 07. A 2024 thread reported badly broken portal-ad stats, so verify new ad products independently.

## A.6 Economy balance

Economy threads are few and thin on the forum; chapters 06 and 07 §5 hold the real treatment. Useful forum points:

- **Price items in Robux first, then derive the soft-currency price and earn rate**, so a fixed exchange rate prevents hyperinflation and keeps premium currency "premium" (SolelySoul, [238862](https://devforum.roblox.com/t/238862)).
- **Two currencies is the norm:** soft currency from tasks, hard currency from levelling or purchase ([238862](https://devforum.roblox.com/t/238862)).
- **Don't raise pass prices for "Robux inflation".** Developer-to-developer Robux prices inflate, but player spending power doesn't ([1922578](https://devforum.roblox.com/t/1922578)).
- A 2025 developer cut the rebirth requirement from 100Qd to 1B "for free-to-play players" and saw revenue collapse ([4107600](https://devforum.roblox.com/t/4107600)). Repliers blamed the thumbnail and quality more than the rebirth change. Use an A/B test for changes like this, not a guess.

## A.7 Genre and style questions

- **RPGs** ([92927](https://devforum.roblox.com/t/92927)): Sharksie's answer (16 likes) is that traditional RPGs are **solitary, long and hard to make**, "any one of these aspects will kill a roblox game", so a successful Roblox RPG must solve all three. Counterpoints: Swordburst 2, Pokémon Brick Bronze and Fantastic Frontier succeeded with strong teams and frequent updates, and "if your goal is to make a popular game, avoid RPGs" (coolbulls). This agrees with chapter 06 rule 11 (prefer systems-heavy, low-art genres).
- **Cartoon vs realistic** ([236721](https://devforum.roblox.com/t/236721)): bright, cartoony, low-poly games dominate front pages because they read at thumbnail size and run on phones. Detailed realism mostly impresses other developers. Choose based on the goal: reach, or a showcase.
- **Story and horror games:** Camping and Piggy clones repeat one plot template ("Bobby goes on a trip... MONSTER... survive"). Write a real plot, cut the clichés (find a seat, sacrificial side characters, "find wood for the fire"), and give every character, the antagonist included, a goal ([674550](https://devforum.roblox.com/t/674550)). Horror depends on atmosphere, sound and pacing, not jump-scare spam ([889158](https://devforum.roblox.com/t/889158), [1583917](https://devforum.roblox.com/t/1583917), [2212571](https://devforum.roblox.com/t/2212571)).
- **Educational games** ([324675](https://devforum.roblox.com/t/324675)): viable only if fun comes first; players come to play, not to study.
- **Find a gap in the market.** AtreyuDev made a surgery game because none existed; it earned ~70k R$ as paid access after a few weeks of work **[anecdotal]** ([2772921](https://devforum.roblox.com/t/2772921)). He also cites an arachnophobia game that kept growing after the Piggy trend it launched into had faded.

## A.8 When a game flops

Jagriel_1, **"So your game died..."** ([2644450](https://devforum.roblox.com/t/2644450)):

1. **Ask why people play games.** The answer is "because they're fun", so evaluate the concept for fun before anything else.
2. **Find your niche.** You only see the three front-page simulators, not the tens of thousands of identical ones that failed. "Cloning popular games may have worked 10 years ago."
3. **Share the vision.** Be selective when hiring, market aggressively to the niche, and avoid being "[Generic Dev Studio #2000]".

He closes: "**trends die fast, but communities last a lot longer**."

**A practical post-mortem order** compiled from [249972](https://devforum.roblox.com/t/249972), [1123245](https://devforum.roblox.com/t/1123245) and [3064458](https://devforum.roblox.com/t/3064458):

1. Does the icon and title tell people what the game is? Check CTR, and whether players bounce in 10 seconds.
2. Does a new player know what to do in 30 seconds? Check the funnel step 1→2 drop.
3. Is there something to do while alone? Check the lobby.
4. Is there a reason to return tomorrow? Check D1.
5. Only then look at ads.

The kill or pivot decision should be pre-agreed (chapter 14 rule 11). The forum's rough heuristic is about 5–7 days of bad metrics after a properly spread campaign ([3115791](https://devforum.roblox.com/t/3115791)).

**Botting and sabotage:** one game was dislike-botted (79% → 30% rating, 5,000 joins in 10 minutes, each staying under 10 seconds) ([751532](https://devforum.roblox.com/t/751532)). There's no fast fix; report it to Roblox and wait. Ratings matter less to discovery now than retention (chapter 01).

## A.9 Players and community

- **Players state pain points, not designs.** Stickmasterluke (17 likes, [75900](https://devforum.roblox.com/t/75900)): it is the developer's job to find solutions. Watch people play over their shoulder, on YouTube, or in remote sessions. Look at *when* players leave: before, during or after rounds. buildthomas says, "Players are not game designers."
- **Toxic messages** ([417801](https://devforum.roblox.com/t/417801)): respond objectively, use templates for common bug reports and refund demands, and moderate rather than argue. Don't publicly humiliate exploiters ([988736](https://devforum.roblox.com/t/988736)).
- **Idea theft** ([461549](https://devforum.roblox.com/t/461549)): ideas aren't protected; expression is. "Maybe avoid telling everyone your game" (20 likes). Being the best version wins, as Murder Mystery 2 outlived its copies. DMCA covers copied *assets* ([1463008](https://devforum.roblox.com/t/1463008)).

## A.10 Teams, payment and scope

- **Solo is possible, more so for scripting-heavy games.** Hyperant (Rise of Nations) suggests a scale from building-heavy to scripting-heavy: the closer a game is to one extreme, the easier it is to make solo ([525143](https://devforum.roblox.com/t/525143)). BullfrogBait reached 750K+ visits solo at ~1 hour/day. Chapter 14 covers which disciplines the bot should outsource.
- **Percentage-only pay** works mostly with people who already trust you or who want portfolio pieces. Many developers refuse "work for free under someone's name" ([333955](https://devforum.roblox.com/t/333955)). Keep teams small so the pay split is meaningful and fewer people hold your assets ([468794](https://devforum.roblox.com/t/468794)).
- **Unrealistic timelines:** one scripter was fired for not recreating Adopt Me in two months. Repliers estimated at least 4–6 months for a much smaller approximation, against a 30+ person team for the real game ([837974](https://devforum.roblox.com/t/837974)) **[anecdotal]**. Use this when talking an owner down from "make Game X".
- **Budget** ([313531](https://devforum.roblox.com/t/313531)): it ranges from $0 (all self-made) to thousands (commissions, audio, GFX, ads). The unbudgeted costs are licensed audio, icon and thumbnail art, and ads.
- **Payout delays:** group payouts to new members are blocked for a period ("User is new to group", [1058250](https://devforum.roblox.com/t/1058250), 952 likes, the most-liked GDS thread). Plan contractor payments around it.
- **Free models:** using them is fine and nothing to be ashamed of, but read any scripts, avoid script-laden "fire" models, and never ship a 100% free-model game ([1811602](https://devforum.roblox.com/t/1811602)). Creator Store inserts are now capability-sandboxed but still need reading (chapter 15 rule 25).
- **Revenue math reality check** ([3913473](https://devforum.roblox.com/t/3913473), 2025): FriendlyEvo estimates that after the ~30% marketplace fee and the DevEx conversion, roughly **25% of player spend reaches the developer in cash**, so ~$12k/month of player spending yields ~$3k before income tax **[anecdotal arithmetic; check the current DevEx rate in chapter 07 §2]**. Use this to set owner expectations.

## A.11 Where the forum disagrees

| Question | Side A | Side B | Bot default |
|---|---|---|---|
| Advertise before the game earns? | No: only reinvest earnings; test fun first (Sharksie, paul2448 [110692](https://devforum.roblox.com/t/110692)) | Yes: ads are the easiest growth if done right (Kampfkarren, AtreyuDev [3115791](https://devforum.roblox.com/t/3115791)) | Small spread-out test after friends/playtest validation |
| Sponsors vs banners/other formats | Banners had 4–5× better CPP (CJ_Oyer, 2021) | Sponsors had larger phone reach (Rawblocky, 2019) | Moot (banners are gone). Compare Ads Manager objectives by CPP and retained plays. |
| Social media and YouTubers | Key free channel ([303933](https://devforum.roblox.com/t/303933), [2535279](https://devforum.roblox.com/t/2535279)) | Rarely moves the needle; spikes give bad data ([3115791](https://devforum.roblox.com/t/3115791)) | Use as a supplement; prefer steady channels |
| Polished vs "ugly" ad creatives | Quality creatives matter ([303933](https://devforum.roblox.com/t/303933)) | Simple or ugly ads get 2–3% CTR ([574695](https://devforum.roblox.com/t/574695)) | A/B test creatives. Never mislead. |
| Cash-grab simulators | "They worked" ([350494](https://devforum.roblox.com/t/350494)) | Saturated slop earns nothing now ([4107600](https://devforum.roblox.com/t/4107600)) | Original hook plus fair monetization |
| Client-side anti-cheat | Worthless: never trust the client ([1643298](https://devforum.roblox.com/t/1643298)) | Useful second layer, "not as bad as you think" ([2471974](https://devforum.roblox.com/t/2471974)) | Server authority first; client checks only as cheap telemetry |
| Frameworks (Knit etc.) | Speeds up structure ([1592333](https://devforum.roblox.com/t/1592333)) | Hides understanding; prefer your own light structure ([3630438](https://devforum.roblox.com/t/3630438)) | Plain modules plus small vendored utilities (chapter 04) |
| Permadeath | Raises stakes ([272066](https://devforum.roblox.com/t/272066)) | Alienates young players | Only for mature skill niches, with lives |

---

# PART B — "Best tutorials" catalog (Community Tutorials)

Selection: the top ~230 Community Tutorials by likes, plus every well-liked tutorial from 2023–2026, filtered for usefulness to an AI building original games. Not included: Studio UI reverts, Linux, DevForum how-to-post, account and voice-chat topics, clothing/UGC selling and off-topic posts. Sorted by topic, then likes. *Likes* and *year* are from the thread header (year = created). Every link is `https://devforum.roblox.com/t/<id>`.

## B.1 Data and persistence

| Tutorial | Likes | Year | What it teaches | Status |
|---|---:|---:|---|---|
| [How to use DataStore2](https://devforum.roblox.com/t/136317) | 5574 | 2018 | Kampfkarren's DataStore2: caching, "berezaa method" ordered backups, combined keys. | **[Outdated]** Library unmaintained. Roblox shipped migration packages for DataStore2/Berezaa data (2025-04-29, chapter 15). Use ProfileStore. |
| [Datastore Tutorial for Beginners](https://devforum.roblox.com/t/733973) | 932 | 2020 | GetAsync/SetAsync basics, pcall, retries, leaderstats. | **[Update]** `wait`→`task.wait`. Prefer `UpdateAsync` or ProfileStore. Read Player values before the first yield in `PlayerRemoving` (chapter 15 rule 6). |
| [How to make a simple global leaderboard](https://devforum.roblox.com/t/256754) | 960 | 2019 | OrderedDataStore `GetSortedAsync` plus SurfaceGui board refresh. | **[Update]** Logic is current; `wait`→`task.wait`. Respect request budgets (refresh every 60 s or more). |
| [DataStores - Beginners to Advanced](https://devforum.roblox.com/t/1275421) | 657 | 2021 | Full arc: Get/Set/UpdateAsync, session locking, budgets, comparison of DataStore2/ProfileService. | **[Update]** Best conceptual primer. Swap ProfileService→ProfileStore. |
| [Pcalls - When and how to use them](https://devforum.roblox.com/t/393687) | 659 | 2019 | What to wrap, retry patterns, returning errors. | **[Current]** apart from `wait`. |
| [How to save parts, and the idea of Serialization](https://devforum.roblox.com/t/524311) | 590 | 2020 | Serializing builds (position, size, colour) to tables and JSON for base or plot saving. | **[Current concept]** Consider `buffer` for compact saves and the 4 MB key limit. |
| [How to save your players' inventory items](https://devforum.roblox.com/t/467961) | 336 | 2020 | Saving item IDs, not instances. UpdateAsync. | **[Update]** `wait`; otherwise fine. |
| [How to properly save player data upon server close](https://devforum.roblox.com/t/313218) | 295 | 2019 | `BindToClose`, waiting for pending saves, Studio caveats. | **[Update]** Concepts still apply. Combine with ProfileStore's own shutdown handling. |
| [The Best and Easiest Way To Save and Load Data](https://devforum.roblox.com/t/2494650) | 107 | 2023 | ProfileService walkthrough with templates. | **[Update]** Same pattern in ProfileStore. |
| [How To Make A Membership System](https://devforum.roblox.com/t/714977) | 258 | 2020 | Timed VIP via saved expiry timestamps. | **[Outdated]** Use native **Subscriptions** ([2710072](https://devforum.roblox.com/t/2710072)). |
| [Right to Erasure / Deleting Player Data](https://devforum.roblox.com/t/2392456) | 70 | 2023 | Handling GDPR erasure requests: find and remove every key for a UserId. | **[Current]** Required compliance. Design key schemas so all keys for a player can be found. |

## B.2 Luau fundamentals, architecture and code quality

| Tutorial | Likes | Year | What it teaches | Status |
|---|---:|---:|---|---|
| [All about Object Oriented Programming](https://devforum.roblox.com/t/8585) | 2665 | 2014 | magnalite's classic metatable class pattern (`__index`, constructors, inheritance). | **[Update]** Pattern is canonical. Replace `spawn/delay` and `SetPrimaryPartCFrame`. |
| [Avoiding wait() and why](https://devforum.roblox.com/t/244015) | 1241 | 2019 | Why polling `wait()` is bad. Use events and Heartbeat. | **[Concept]** Its argument won; the `task` library is now standard. |
| [All you need to know about Metatables and Metamethods](https://devforum.roblox.com/t/503259) | 720 | 2020 | Every metamethod with examples. | **[Current]** |
| [Full Beginner Guide To Metatables](https://devforum.roblox.com/t/2505946) | 317 | 2023 | Gentler version of the above. | **[Current]** |
| [Concepts: OOP in Roblox](https://devforum.roblox.com/t/761267) | 587 | 2020 | OOP rationale, encapsulation, inheritance vs composition. | **[Current]** |
| [Roblox OOP](https://devforum.roblox.com/t/1639499) | 431 | 2022 | Compact class template. | **[Current]** |
| [Efficient OOP Tutorial](https://devforum.roblox.com/t/1061153) | 228 | 2021 | Memory and performance-aware classes (shared methods, avoiding closures per instance). | **[Current]** |
| [Guide to Type-Checking with OOP](https://devforum.roblox.com/t/1997394) | 196 | 2022 | Typing classes with `typeof(setmetatable(...))`. | **[Update]** The new type solver changes some idioms; see 3637378. |
| [Type checking for beginners](https://devforum.roblox.com/t/1027242) | 514 | 2021 | `--!strict`, annotations, generics. | **[Current]** |
| [Type Annotations! ... Actually Good](https://devforum.roblox.com/t/2843221) | 341 | 2024 | Practical typing style and why it prevents bugs. | **[Current]** |
| [Luau's New Type Solver: type functions](https://devforum.roblox.com/t/3637378) | 173 | 2025 | User-defined type functions in the new solver. | **[Current]** Advanced. |
| [Coroutines - When and how](https://devforum.roblox.com/t/541683) | 294 | 2020 | coroutine.create/wrap/yield. | **[Update]** Prefer `task.spawn/defer`. |
| [Garbage Collection and Memory Leaks](https://devforum.roblox.com/t/374954) | 492 | 2019 | References, connections and leaked tables. | **[Current concept]** `wait` in the examples. |
| [PSA: Connections can memory leak Instances](https://devforum.roblox.com/t/90082) | 623 | 2018 | Connections keep instances alive; disconnect or Destroy. | **[Current]** Still the #1 leak source. Players and characters are now destroyed on leave by default (chapter 15 rule 6). |
| [A Beginner's Guide to Lua GC](https://devforum.roblox.com/t/1756677) | 227 | 2022 | Weak tables, GC cycles. | **[Current]** |
| [How to use a Maid class](https://devforum.roblox.com/t/340061) | 227 | 2019 | Quenty's Maid: one object owns all cleanup. | **[Concept]** Use vendored Janitor or Trove (RbxUtil). |
| [How To Use Module Scripts](https://devforum.roblox.com/t/572047) | 262 | 2020 | require, caching, shared state. | **[Current]** |
| [CollectionService in a nutshell](https://devforum.roblox.com/t/668984) | 242 | 2020 | Tags to drive behaviour for many parts. | **[Current]** See also staff "Collections: query patterns" ([4809143](https://devforum.roblox.com/t/4809143), 2026). |
| [Attributes Vs Values](https://devforum.roblox.com/t/2613261) | 101 | 2023 | Why attributes replace ValueObjects for most state. | **[Current]** |
| [Algorithm efficiency and alternatives to table.find](https://devforum.roblox.com/t/764774) | 291 | 2020 | Big-O, sets and dictionaries vs linear scans. | **[Current]** |
| [Be careful when using assert()](https://devforum.roblox.com/t/1289175) | 266 | 2021 | Message strings are evaluated eagerly, a hidden cost. | **[Current]** |
| [Best Practices Handbook](https://devforum.roblox.com/t/2593598) | 176 | 2023 | Naming, early returns, guard clauses, module structure. | **[Current]** |
| [How to Write Professional Code](https://devforum.roblox.com/t/3475830) | 134 | 2025 | Readability, separation of concerns, typing. | **[Current]** |
| [Writing clean code - A complete guide](https://devforum.roblox.com/t/662447) | 189 | 2020 | Same theme, older. | **[Update]** `SetPrimaryPartCFrame`, `SetAsync`. |
| [MVC: A Practical Approach](https://devforum.roblox.com/t/3026159) | 87 | 2024 | Model-View-Controller split for Roblox; ends the ECS-vs-OOP confusion. | **[Current]** |
| [All about Entity Component System](https://devforum.roblox.com/t/1664447) | 193 | 2022 | ECS concepts. | **[Concept]** For production use vendored jecs. |
| [DOD - Data Oriented Design](https://devforum.roblox.com/t/2615978) | 76 | 2023 | Structure-of-arrays thinking for many entities. | **[Current]** |
| [Luau Bytecode EXPLAINED](https://devforum.roblox.com/t/3941941) | 367 | 2025 | Reading bytecode to understand and optimize hot paths. | **[Current]** Advanced; rarely needed. |
| [Illegal Luau Optimizations](https://devforum.roblox.com/t/4128934) | 155 | 2025 | Extreme micro-optimizations (anti-OOP school). | **[Caution]** Hurts readability. Use only in profiled hot loops. |
| [Useful Luau shorthands](https://devforum.roblox.com/t/4054206) | 96 | 2025 | `if-then-else` expressions, compound ops, string interpolation. | **[Current]** |
| [My biggest mistake as a scripter](https://devforum.roblox.com/t/3993562) | 148 | 2025 | Stop restarting "dream games"; finish small projects. | **[Concept]** Matches chapter 14. |

## B.3 Gameplay systems

| Tutorial | Likes | Year | What it teaches | Status |
|---|---:|---:|---|---|
| [Creating A Furniture Placement System](https://devforum.roblox.com/t/205509) | 2000 | 2018 | EgoMoose: grid snapping on a surface, rotation, client preview, server validation, saving. | **[Update]** `SetPrimaryPartCFrame`→`PivotTo`; `GetMouse`→IAS/`UserInputService`; `SetAsync`→ProfileStore. The math is still the reference for tycoon and housing plots. |
| [How to use Placement Service](https://devforum.roblox.com/t/698753) | 282 | 2020 | Using a community placement module. | **[Update]** `GetMouse`. Prefer writing your own from 205509. |
| [Writing an FPS framework (2020)](https://devforum.roblox.com/t/503318) / [part 2](https://devforum.roblox.com/t/581791) | 1289 / 441 | 2020 | Viewmodels, springs, sway, ADS, server hit validation. | **[Update]** `wait/spawn`, `Humanoid:LoadAnimation`→`Animator`. Use `BindToRenderStep` for camera-bound code. |
| [The First Person Element Of A First Person Shooter](https://devforum.roblox.com/t/160434) | 1116 | 2018 | EgoMoose: arm/camera math, replicating look direction. | **[Update]** `Body*`→constraints, `Animator:LoadAnimation`. The math holds. |
| [Designing an FPS Framework: Beginner's guide](https://devforum.roblox.com/t/1198208) / [Part 2](https://devforum.roblox.com/t/1203507) | 773 / 616 | 2021 | Modular viewmodel framework with springs. | **[Update]** `GetMouse`→IAS. Otherwise good. |
| [Modeling a projectile's motion](https://devforum.roblox.com/t/176677) | 1193 | 2018 | EgoMoose: kinematics, launch angles, drawing a trajectory with Beams. | **[Update]** `FindPartOnRay`→`Raycast`; `BodyForce`→`VectorForce`; `.Velocity`→`AssemblyLinearVelocity`. |
| [How to make a raycasting gun](https://devforum.roblox.com/t/723716) | 541 | 2020 | Client input → remote → server `Raycast` → damage. | **[Update]** Add rate, range and line-of-sight validation (chapter 11). Use IAS. |
| [Network Efficient and Safe Practices with Projectiles](https://devforum.roblox.com/t/2608367) | 114 | 2023 | Replicate projectile *parameters*, simulate on clients, validate on server; cuts 150+ KB/s. | **[Current]** |
| [The Basics of Combat Games: Hitboxes](https://devforum.roblox.com/t/3002930) / [Health and Damage](https://devforum.roblox.com/t/2994963) | 130 / 70 | 2024 | Spatial queries vs raycast hitboxes, server authority, damage pipeline. | **[Current]** |
| [Weighted Chance System](https://devforum.roblox.com/t/1373953) | 700 | 2021 | Weighted random selection for drops and eggs. | **[Current]** If paid, show odds summing to 100% and gate with PolicyService (chapter 15 rule 19). |
| [Creating a Crate/Spin System](https://devforum.roblox.com/t/260895) | 590 | 2019 | Spinner UI plus server-side roll. | **[Update]** Same compliance as above; `wait`. |
| [How to Make Server-Synced Daily Shops](https://devforum.roblox.com/t/632401) | 548 | 2020 | Seed `Random` from a date so every server shows the same daily rotation. | **[Current]** Great retention feature. |
| [Dungeon Generation: A Procedural Generation Guide](https://devforum.roblox.com/t/342413) | 417 | 2019 | Room placement, corridors, spanning trees. | **[Current concept]** |
| [Ultimate Perlin Noise and Procedural Terrain](https://devforum.roblox.com/t/3109400) | 116 | 2024 | `math.noise` octaves to build terrain. | **[Current]** |
| [Consume everything - how greedy meshing works](https://devforum.roblox.com/t/452717) | 399 | 2020 | Merging voxels into fewer parts. | **[Current]** For voxel or building games. |
| [How 2 make A* Pathfinding](https://devforum.roblox.com/t/2714504) | 91 | 2023 | Grid A* in Luau. | **[Current]** Use `PathfindingService` unless you need a custom grid. |
| [How to Create a Realistic NPC Eyesight System](https://devforum.roblox.com/t/2456522) | 147 | 2023 | View cone (dot product) plus line-of-sight raycast. | **[Current]** For stealth and horror. |
| [Simulating thousands of moving NPCs performantly](https://devforum.roblox.com/t/4603494) | 137 | 2026 | Server-side simulation without real humanoids, bit-packed snapshots, client-rendered models. | **[Current]** For tower defense and RTS. Pairs with [1202300](https://devforum.roblox.com/t/1202300). |
| [How to Actually Use Roblox's Physics Character Controllers](https://devforum.roblox.com/t/3092097) | 358 | 2024 | `ControllerManager`, `GroundController`/`AirController` setup and tuning. | **[Current]** Relevant to Server Authority. |
| [Movement System](https://devforum.roblox.com/t/2135683) / [Sliding System](https://devforum.roblox.com/t/2598383) | 173 / 118 | 2023 | Sprint, dash and slide mechanics. | **[Current]** Route input through IAS. |
| [How to Rig a Car](https://devforum.roblox.com/t/523855) | 723 | 2020 | Constraint-based car (hinges, springs, cylindrical constraints). | **[Current]** Or use vendored A-Chassis. |
| [In Depth Scripted Car Physics](https://devforum.roblox.com/t/3915628) | 207 | 2025 | Raycast suspension, tyre forces, drivetrain. | **[Current]** Very long. |
| [How to make a basic train](https://devforum.roblox.com/t/1582741) | 280 | 2021 | Track following with CFrame lerps. | **[Current]** |
| [Coding a Murder Mystery Game](https://devforum.roblox.com/t/890082) | 211 | 2020 | Round loop, role assignment, win conditions. | **[Update]** 29 `wait()` calls; rewrite with `task` and state machines. |
| [How To Make A Round-Based System](https://devforum.roblox.com/t/487712) | 197 | 2020 | Intermission → round → cleanup loop. | **[Update]** `wait`. Funnel players to one lobby (§A.4). |
| [Custom Inventory System](https://devforum.roblox.com/t/2955578) | 88 | 2024 | Server-owned inventory with UI. | **[Current]** |
| [How to make basic admin commands](https://devforum.roblox.com/t/59691) | 346 | 2017 | Command parsing on `Chatted`. | **[Update]** Use `TextChatCommand` (TextChatService) or vendored Cmdr. |
| [How to use the new Ban API](https://devforum.roblox.com/t/3045051) | 97 | 2024 | `Players:BanAsync` with alt detection and durations. | **[Current]** |
| [How to make a "PLS DONATE!" Game](https://devforum.roblox.com/t/1686310) | 480 | 2022 | Booths that sell other players' passes. | **[Outdated]** Cross-game pass sales disabled 2026-05-29; use the Transfers API (chapter 15 rule 17). Also uses DataStore2. |
| [How to Make a Spectate!](https://devforum.roblox.com/t/606352) | 183 | 2020 | Cycle `CurrentCamera.CameraSubject` through players. | **[Current]** |
| [How to Create a LIVE Countdown](https://devforum.roblox.com/t/908114) | 188 | 2020 | Event countdown from a UTC timestamp. | **[Update]** `wait`; use `workspace:GetServerTimeNow()`. |
| [Level Systems (part 2)](https://devforum.roblox.com/t/297486) | 190 | 2019 | XP curves and level-ups. | **[Concept]** See chapter 06 §A.2 for curves. |

## B.4 Math, CFrames and physics

| Tutorial | Likes | Year | What it teaches | Status |
|---|---:|---:|---|---|
| [Ultimate Guide to Vector3:Cross() and :Dot()](https://devforum.roblox.com/t/953984) | 900 | 2020 | Facing checks, normals, angle between vectors. | **[Current]** |
| [How to think about CFrames](https://devforum.roblox.com/t/11743) | 372 | 2015 | Object vs world space and composition order. | **[Current]** |
| [A Couple of Advanced CFrame Tricks](https://devforum.roblox.com/t/337682) | 498 | 2019 | EgoMoose: `fromMatrix`, surface alignment, rotation between vectors. | **[Current]** |
| [Aligning Object to Surface using CFrame.fromMatrix](https://devforum.roblox.com/t/2440345) | 86 | 2023 | Aligning placed objects to a raycast normal. | **[Current]** |
| [How to reflect rays on hit](https://devforum.roblox.com/t/18143) | 524 | 2015 | Reflection formula `r = d - 2(d·n)n`. | **[Current]** The thread has been updated to `Raycast`. |
| [Basic Trigonometry](https://devforum.roblox.com/t/554329) / [Vector Mathematics 101](https://devforum.roblox.com/t/157718) / [Math for Roblox Developers #1](https://devforum.roblox.com/t/3659072) | 273 / 257 / 76 | 2018–25 | Foundations. | **[Current]** |
| [How to think about Quaternions](https://devforum.roblox.com/t/143295) | 235 | 2018 | Rotation interpolation without gimbal lock. | **[Concept]** |
| [2 Joint 2 Limb Inverse Kinematics](https://devforum.roblox.com/t/252399) | 263 | 2019 | Law-of-cosines IK. | **[Concept]** Built-in `IKControl` now covers most cases. |
| [Procedural Animation](https://devforum.roblox.com/t/564782) | 321 | 2020 | Legs and creatures driven by IK and math. | **[Update]** `wait` |
| [Using DeltaTime](https://devforum.roblox.com/t/417353) | 215 | 2019 | Frame-rate-independent motion. | **[Update]** Concept is essential; examples use `wait/spawn/delay`. |
| [Understanding Roblox Physics and Conversions to Real Units](https://devforum.roblox.com/t/1847678) | 227 | 2022 | Studs, mass and gravity in real units. | **[Current]** See also staff "Units on Roblox" ([2418615](https://devforum.roblox.com/t/2418615)). |
| [HowTo: Physics-Based TweenService](https://devforum.roblox.com/t/2873727) | 189 | 2024 | Moving platforms that carry players: tween a target, drive with constraints. | **[Current]** Solves the "player slides off a tweened platform" bug. |
| [Introduction to Tweening Models](https://devforum.roblox.com/t/315253) | 876 | 2019 | Tweening multi-part models. | **[Update]** `SetPrimaryPartCFrame`→tween a CFrameValue and `PivotTo`, or weld to a tweened root. |
| [Understanding Easing Styles](https://devforum.roblox.com/t/937281) | 235 | 2020 | Visual guide to Enum.EasingStyle. | **[Current]** |
| [Dragging objects with the mouse](https://devforum.roblox.com/t/403766) | 831 | 2019 | Physics drag using BodyPosition/Gyro. | **[Outdated]** Use **DragDetector** (staff [2839937](https://devforum.roblox.com/t/2839937)) or AlignPosition/AlignOrientation. |
| [Network ownership for beginners](https://devforum.roblox.com/t/947029) | 189 | 2020 | `SetNetworkOwner`, client physics. | **[Update]** Check Server Authority and the improved physics replication rollout ([4618365](https://devforum.roblox.com/t/4618365)). |

## B.5 Networking, security and anti-exploit

| Tutorial | Likes | Year | What it teaches | Status |
|---|---:|---:|---|---|
| [How you should secure your game](https://devforum.roblox.com/t/351775) | 734 | 2019 | Never trust the client: validate remotes, keep server authority over values. | **[Current concept]** |
| [Why Your Anti-Exploit Sucks](https://devforum.roblox.com/t/1643298) | 313 | 2022 | Client-side checks, false positives (lag, ping) and bad UX make anti-exploits fail. | **[Concept]** |
| [Client Anti Cheats: Aren't as bad as you think!](https://devforum.roblox.com/t/2471974) | 599 | 2023 | Counterpoint: client checks raise exploit effort as a second layer. | **[Caution]** Debate (§A.11). |
| [A Guide to Making Proper Anti-Exploits](https://devforum.roblox.com/t/1606949) / [Creating Proper Anti-Exploits](https://devforum.roblox.com/t/2172882) | 263 / 72 | 2021–23 | Server-side movement and teleport sanity checks. | **[Update]** `SetPrimaryPartCFrame`. |
| [Securing your anticheat: bad practices + handshakes](https://devforum.roblox.com/t/2519952) | 111 | 2023 | How powerful exploiters are; why handshakes are bypassable. | **[Concept]** |
| [How to Prevent Speed Hacking](https://devforum.roblox.com/t/210733) | 225 | 2018 | Server distance-over-time checks. | **[Update]** `SetPrimaryPartCFrame`, `wait`. |
| [Exploiters and how they spoof stuff](https://devforum.roblox.com/t/695958) / [Tired of remote-spoofers?](https://devforum.roblox.com/t/2577431) | 203 / 134 | 2020–23 | Spoofed properties and remote arguments. | **[Concept]** Validate type, range, rate, ownership. |
| [Common Client-Server mistakes](https://devforum.roblox.com/t/3100804) | 95 | 2024 | Client-owned currency, trusting client hit claims. | **[Current]** |
| [Server Authority: How to Begin?](https://devforum.roblox.com/t/4139185) | 152 | 2025 | Enabling Server Authority, rollback netcode concepts, prediction. | **[Current]** Read with staff deep dive [4624565](https://devforum.roblox.com/t/4624565) and chapter 15 (needs IAS and Deferred signals). |
| [Network Optimization best practices](https://devforum.roblox.com/t/1913475) / [Network Optimization (2021)](https://devforum.roblox.com/t/1046078) | 275 / 227 | 2021–22 | Fewer, smaller remotes; batching; avoid replicating physics spam. | **[Current]** Today, add `buffer` serialization (Blink/ByteNet). |
| [How to remove backdoors from your game](https://devforum.roblox.com/t/511548) | 225 | 2020 | Finding `require(id)`, `getfenv` and obfuscated insertions from free models. | **[Current]** Combine with the Creator Store capability sandbox (chapter 15 rule 25). |
| [Best ways to stop people leaking your game client side](https://devforum.roblox.com/t/915372) | 255 | 2020 | Keep server logic and assets in ServerStorage/ServerScriptService. | **[Concept]** |
| [Understanding method hooking](https://devforum.roblox.com/t/31442) | 377 | 2016 | How exploiters hook client functions. | **[Concept]** |
| [PromptProductPurchaseFinished Vulnerability Fix](https://devforum.roblox.com/t/2943231) | 115 | 2024 | Never grant purchases from the client-side "finished" event. | **[Current]** Grant only in `ProcessReceipt` (chapter 07 §3). |

## B.6 Optimization and performance

| Tutorial | Likes | Year | What it teaches | Status |
|---|---:|---:|---|---|
| [[Improved] How to Actually Improve Performance](https://devforum.roblox.com/t/1221842) | 628 | 2021 | Part count, anchoring, CastShadow, streaming, script costs. | **[Update]** Drop the `Technology` advice and `wait/spawn`. |
| [Building Optimisation](https://devforum.roblox.com/t/235059) | 565 | 2019 | Unions vs meshes, collision fidelity, texture reuse. | **[Concept]** |
| [MeshPart Usage, Performance & Optimizations](https://devforum.roblox.com/t/1319217) | 337 | 2021 | RenderFidelity, CollisionFidelity, instancing identical meshes. | **[Current]** |
| [How to Optimize Humanoids](https://devforum.roblox.com/t/389801) | 344 | 2019 | Disabling unused HumanoidStateTypes, NPC costs. | **[Current]** |
| [Creating the most optimized Roblox game - 6000+ FPS](https://devforum.roblox.com/t/1736424) | 415 | 2022 | boatbomber's extreme case study (culling, minimal instances). | **[Concept]** |
| [Improving Game Performance: Benchmarking, MicroProfiler...](https://devforum.roblox.com/t/1002074) | 214 | 2021 | Reading the MicroProfiler and Developer Console stats. | **[Current]** See staff update [3226801](https://devforum.roblox.com/t/3226801) (memory profiling, flame graphs). |
| [All about optimization](https://devforum.roblox.com/t/2586333) / [Hitchhiker's Guide To Optimization](https://devforum.roblox.com/t/3358345) / [Definitive tutorial to game optimization](https://devforum.roblox.com/t/4629258) | 178 / 136 / 71 | 2023–26 | Modern roundups: streaming, LOD, object pooling, network budgets, Parallel Luau. | **[Current]** 4629258 (2026) is the most up to date. |
| [Actors - make your game run faster](https://devforum.roblox.com/t/2536196) | 72 | 2023 | Parallel Luau with Actors and `task.desynchronize`. | **[Update]** `spawn` |
| [Performance tips for custom characters](https://devforum.roblox.com/t/4202236) | 70 | 2025 | Bandwidth and framerate costs of replicated rigs. | **[Current]** |
| [How to make a FPS Counter](https://devforum.roblox.com/t/1531019) | 234 | 2021 | Frame-time measurement on RenderStepped. | **[Current]** |

Also read staff posts **Real world building and scripting optimization** ([3127146](https://devforum.roblox.com/t/3127146), 1,405 likes) and **Instance streaming best practices** ([4563685](https://devforum.roblox.com/t/4563685), 2026).

## B.7 UI and UX

| Tutorial | Likes | Year | What it teaches | Status |
|---|---:|---:|---|---|
| [UI Design Starter Guide](https://devforum.roblox.com/t/53461) | 1112 | 2017 | Hierarchy, colour, consistency, simplicity. | **[Concept]** |
| [ViewportFrame Masking](https://devforum.roblox.com/t/2964839) | 1047 | 2024 | Masking UI using meshes with erased vertex alpha inside ViewportFrames. | **[Current]** Clever, but relies on engine behaviour; test on mobile. |
| [The Ultimate UI Design Guide](https://devforum.roblox.com/t/1236916) | 426 | 2021 | Layout, scale vs offset, constraints. | **[Concept]** |
| [The Correct Way to Design Mobile Buttons](https://devforum.roblox.com/t/2494558) | 407 | 2023 | Positioning custom buttons relative to the jump button so they scale across screens. | **[Current]** Today, bind via IAS (`InputBinding` with UI buttons). |
| [[Advanced UI] Introduction to 2D Animations](https://devforum.roblox.com/t/459849) | 622 | 2020 | Sprite-sheet and tween animations in UI. | **[Update]** `:TweenPosition/:TweenSize`→`TweenService`. |
| [4 UIGradient Animations](https://devforum.roblox.com/t/557922) | 453 | 2020 | Shine and rainbow effects via gradient Offset/Rotation. | **[Current]** |
| [Keeping the Aspect Ratio of your GUIs](https://devforum.roblox.com/t/17171) | 382 | 2015 | Scale-based sizing. | **[Current]** Use `UIAspectRatioConstraint`. |
| [Complete, Comprehensive Roblox UI Scaling Guide](https://devforum.roblox.com/t/2232510) / [UI Positioning For Dummies](https://devforum.roblox.com/t/2312197) | 88 / 88 | 2023 | AnchorPoint, Scale/Offset, constraints, safe areas. | **[Current]** |
| [Fixing images in Roblox UI (black outlines)](https://devforum.roblox.com/t/75817) | 363 | 2018 | Transparent-pixel bleed on scaled images; run Pixelfix before upload. | **[Current]** |
| [How to use SliceCenter (9-slice)](https://devforum.roblox.com/t/18313) | 257 | 2015 | Scalable rounded panels and frames. | **[Current]** |
| [How to Plan, Design and Build Quality User Interfaces](https://devforum.roblox.com/t/281785) | 279 | 2019 | Wireframe, then mock-up, then implement. | **[Concept]** |
| [Here's How to Create a Modern Sleek UI Design](https://devforum.roblox.com/t/2528850) | 223 | 2023 | Modern flat style with UIStroke, UICorner, gradients. | **[Current]** |
| [How to make extremely Clean UI while keeping good UX](https://devforum.roblox.com/t/2438099) / [clean, appealing UI](https://devforum.roblox.com/t/1770083) | 108 / 187 | 2022–23 | Whitespace, contrast, fewer elements. | **[Concept]** |
| [How To Create A Custom Loading Screen](https://devforum.roblox.com/t/737094) / [fade-in logo](https://devforum.roblox.com/t/406287) | 330 / 354 | 2019–20 | ReplicatedFirst, `RemoveDefaultLoadingScreen`, `ContentProvider:PreloadAsync`. | **[Update]** `wait`. Keep it short (§A.4). |
| [The Ultimate Guide to Custom Loading/Health Bars](https://devforum.roblox.com/t/1323459) / [Circular HP Bar](https://devforum.roblox.com/t/420996) | 216 / 191 | 2019–21 | Bars via ClipDescendants/UIGradient. | **[Current]** |
| [Gaussian blur filter for UI](https://devforum.roblox.com/t/1238701) | 299 | 2021 | Fake UI blur. | **[Caution]** Costly. `DepthOfField` or BlurEffect are simpler. |
| [ClipDescendants with UICorners](https://devforum.roblox.com/t/2492826) | 88 | 2023 | Rounded clipping workaround. | **[Current]** |
| [Roblox guide: 3d GUI](https://devforum.roblox.com/t/2930494) | 115 | 2024 | Tilted, parallax 3D-feeling UI. | **[Current]** Or use Screen3D (Part C). |
| [Customize your GUIs with builder icons](https://devforum.roblox.com/t/3968755) | 104 | 2025 | Using Roblox's official icon set in UI. | **[Current]** |
| [How to Implement a Damage Indication System](https://devforum.roblox.com/t/483161) | 263 | 2020 | Directional hit indicators and damage numbers. | **[Update]** `:TweenPosition`→`TweenService`. |
| [Making Accessible Games](https://devforum.roblox.com/t/1375919) | 396 | 2021 | Colour-blind palettes, text size, reduced motion, subtitles, input remapping. Updated 2026-11. | **[Current]** Pair with chapter 13. |
| [Roact UI Framework Crash Course (Deprecated)](https://devforum.roblox.com/t/796618) | 339 | 2020 | Roact. | **[Outdated]** Use react-lua (vendored) via staff [How To: React + Roblox](https://devforum.roblox.com/t/2964543), or Fusion/Vide. |

Also read the staff post **Designing UI - Tips and Best Practices** ([3074034](https://devforum.roblox.com/t/3074034)).

## B.8 Building, terrain and level design

| Tutorial | Likes | Year | What it teaches | Status |
|---|---:|---:|---|---|
| [Ruski's Tutorial #1 - How to design a map layout](https://devforum.roblox.com/t/277853) | 795 | 2019 | Flow, landmarks, sightlines and choke points, sketched before building. | **[Concept]** Series: [#2 house](https://devforum.roblox.com/t/330237), [#3 PvP map](https://devforum.roblox.com/t/2746055), [#5 open world](https://devforum.roblox.com/t/3554962). |
| [Large-Scale Roblox Terrain: The ultimate guide](https://devforum.roblox.com/t/405672) | 774 | 2019 | Heightmaps, external tools, painting materials at scale. | **[Current]** |
| [Creating Large-Scale Terrain with World Machine](https://devforum.roblox.com/t/2271535) / [Realistic Terrain](https://devforum.roblox.com/t/560473) / [immersive smooth terrain](https://devforum.roblox.com/t/252172) | 101 / 206 / 181 | 2019–23 | Terrain workflows and dressing. | **[Current]** Add MaterialVariants and TerrainDetail (staff [2840180](https://devforum.roblox.com/t/2840180)). |
| [Map Design and Scene Building: Fantasy, Medieval and Nature](https://devforum.roblox.com/t/709866) | 248 | 2020 | Composition and prop dressing by theme. | **[Concept]** |
| [A general guide on how to build](https://devforum.roblox.com/t/221681) / [Building Tutorial For All](https://devforum.roblox.com/t/23919) | 252 / 236 | 2016–19 | Grids, proportion, detail passes. | **[Concept]** |
| [Unique Techniques For Advanced Builders](https://devforum.roblox.com/t/3160906) / [Advanced Guide to Efficient Building](https://devforum.roblox.com/t/2198562) | 102 / 75 | 2023–24 | Workflow speed, modular kits, trims. | **[Current]** |
| [Creating a realistic city](https://devforum.roblox.com/t/3053768) | 83 | 2024 | Blocking, modular facades, street dressing. | **[Current]** |
| [Faster Road Creation](https://devforum.roblox.com/t/329327) | 314 | 2019 | Road-building workflow with plugins. | **[Current]** |
| [Efficiently building good looking trees (with CSG)](https://devforum.roblox.com/t/23976) | 457 | 2016 | CSG trees. | **[Outdated]** Use meshes or packs; unions cost more. |
| [How to recover invisible / corrupt unions](https://devforum.roblox.com/t/398711) | 272 | 2019 | Recovering broken unions. | **[Current]** Still useful. |
| [Roblox - Classic Building Guide](https://devforum.roblox.com/t/3297677) / [The Old Roblox Ultimate Guide](https://devforum.roblox.com/t/3962532) | 237 / 87 | 2024–25 | Retro/classic style (studs, old colours, lighting). | **[Current]** For retro-styled games. |
| [How to make a rounded block](https://devforum.roblox.com/t/2387408) | 83 | 2023 | Rounded parts. | **[Current]** |

## B.9 Lighting, rendering and graphics tricks

| Tutorial | Likes | Year | What it teaches | Status |
|---|---:|---:|---|---|
| [How to make your lighting more realistic in shadowmap](https://devforum.roblox.com/t/367805) | 942 | 2019 | ColorCorrection, Bloom, SunRays and Atmosphere values. | **[Update]** `Technology`→`LightingStyle` + `PrioritizeLightingQuality` (chapter 15 rule 9). The effect values are still useful. |
| [A Guide to a Better Looking Day/Night Cycle](https://devforum.roblox.com/t/392643) | 397 | 2019 | Tweening ClockTime with matching colour and fog changes. | **[Update]** `wait` |
| [Hidden Glass Distortion Effect](https://devforum.roblox.com/t/2338789) | 817 | 2023 | A Glass-material engine quirk that gives distortion and reflections. | **[Caution]** It's a quirk; it may break after lighting updates. Check on mobile. |
| [Simple Volumetric Lighting Solutions](https://devforum.roblox.com/t/3048831) | 154 | 2024 | Fake volumetrics with particle grids and beams. | **[Current]** |
| [Planetary atmospheres on Roblox](https://devforum.roblox.com/t/3114609) | 152 | 2024 | Layered atmosphere shells for space scenes. | **[Current]** |
| [How to make surfaces appear wet](https://devforum.roblox.com/t/2476461) | 157 | 2023 | MaterialVariant wet look (pack included). | **[Current]** |
| [An outline technique with variable thickness](https://devforum.roblox.com/t/3950556) | 204 | 2025 | EgoMoose: inverted-hull outlines with controllable thickness. | **[Current]** Use `Highlight` for simple cases. |
| [How To: Cel Shading Effect](https://devforum.roblox.com/t/1472627) | 197 | 2021 | Toon look via materials and lighting. | **[Current]** |
| [How To Have Functioning Emissive Textures](https://devforum.roblox.com/t/319192) | 341 | 2019 | Emissive workaround (layered Neon or transparency). | **[Caution]** Check newer SurfaceAppearance options before using the hack. |
| [How to get a reflective surface](https://devforum.roblox.com/t/491868) / [Viewport frames make good reflections](https://devforum.roblox.com/t/3256930) | 284 / 73 | 2020–24 | Fake reflections. | **[Current]** Costly; use sparingly. |
| [Creating new and fresh Skyboxes](https://devforum.roblox.com/t/133796) | 258 | 2018 | Making skybox images. | **[Current]** See staff [Custom Skyboxes 101](https://devforum.roblox.com/t/2849003). |
| [Making a black hole with real time lensing](https://devforum.roblox.com/t/2696918) / [Chromatic Aberration](https://devforum.roblox.com/t/3119178) / [sub-pixel effect](https://devforum.roblox.com/t/2633312) | 96 / 69 / 88 | 2023–24 | ViewportFrame and UI post-effects. | **[Current]** Showcase-tier tricks. |
| [Realistic Oceans Using Mesh Deformation](https://devforum.roblox.com/t/1159345) / [Mesh Deformation Ocean](https://devforum.roblox.com/t/1122587) | 589 / 428 | 2021 | Gerstner waves on a skinned plane's bones. | **[Current]** EditableMesh is an alternative. Mind client cost. |
| [A complete guide to EditableImages](https://devforum.roblox.com/t/3858566) | 108 | 2025 | Runtime pixel editing (drawing, minimaps). | **[Current]** |
| [How to make a roblox game 2D Pixelated](https://devforum.roblox.com/t/2630038) | 130 | 2023 | 2D pixel platformer in Roblox. | **[Update]** `wait` |

## B.10 Animation and rigging

| Tutorial | Likes | Year | What it teaches | Status |
|---|---:|---:|---|---|
| [Blender rig exporter/animation importer](https://devforum.roblox.com/t/34729) | 5000 | 2017 | Blender ↔ Roblox animation plugin. | **[Outdated]** Use FBX animation import or the official Roblox Blender add-on. Rig *concepts* still apply. |
| [How to animate Tool Parts (Guns, Knifes etc.)](https://devforum.roblox.com/t/359484) | 3067 | 2019 | Replace RightGrip with a Motor6D so tool parts can be animated. | **[Caution]** Still the common method. With the Avatar Joint Upgrade, find joints by name (`FindFirstChild(name, true)`), never by fixed path (chapter 15 rule 7). |
| [How to animate a tool/object with a Dummy](https://devforum.roblox.com/t/232317) / [animate tools (melees)](https://devforum.roblox.com/t/1654589) / [Tool Handles](https://devforum.roblox.com/t/921518) | 777 / 345 / 234 | 2019–22 | Same pipeline, variations. | **[Caution]** Same note as above. |
| [Jespone's guide to animations](https://devforum.roblox.com/t/225752) | 847 | 2019 | Principles: anticipation, follow-through, arcs, timing. | **[Concept]** Excellent. |
| [Getting Started with Moon Animator 2](https://devforum.roblox.com/t/476330) | 590 | 2020 | Moon Animator workflow. | **[Current]** Third-party plugin. |
| [Camera Animations for cutscenes and gameplay](https://devforum.roblox.com/t/1181691) | 481 | 2021 | Animating a camera part, then playing it on CurrentCamera. | **[Current]** |
| [How to animate 2 characters like a takedown](https://devforum.roblox.com/t/1625809) | 314 | 2022 | Paired animations with aligned roots. | **[Update]** `Humanoid:LoadAnimation`→`Animator`. |
| [Complete guide to rigging and animating models](https://devforum.roblox.com/t/315258) / [rigging a custom character](https://devforum.roblox.com/t/1104770) | 189 / 197 | 2019–21 | Motor6D rigs for custom models. | **[Caution]** The joint upgrade affects avatars, not custom NPC rigs; still verify. |
| [How to make Low FPS / Blocky Style Animation](https://devforum.roblox.com/t/2800541) | 87 | 2024 | Stepped, stylized animation. | **[Current]** |
| [How To Achieve Active Ragdoll](https://devforum.roblox.com/t/3146642) | 74 | 2024 | Constraint-driven ragdoll that tries to stand. | **[Current]** |

## B.11 VFX

| Tutorial | Likes | Year | What it teaches | Status |
|---|---:|---:|---|---|
| [Full Beginner's Guide on scripting Anime/Fighting VFX](https://devforum.roblox.com/t/1610853) | 586 | 2022 | Spawning, tweening and cleaning up effect parts, ParticleEmitter:Emit, client-side replication. | **[Current]** |
| [VFX Tutorial](https://devforum.roblox.com/t/872437) | 538 | 2020 | Particle and beam fundamentals. | **[Current concept]** |
| [Crecent Sword Slash Effect](https://devforum.roblox.com/t/1113871) | 217 | 2021 | Mesh slash with texture scroll. | **[Current]** |
| [How to make aurora borealis using ONE particle emitter](https://devforum.roblox.com/t/3929731) | 95 | 2025 | Flipbook and stretched particle tricks. | **[Current]** |
| [Creating a Simple, Realistic Camera (bobbing, blur, sprint)](https://devforum.roblox.com/t/646943) / [Add "Weight" to the Camera](https://devforum.roblox.com/t/1331996) | 243 / 196 | 2020–21 | Game feel through camera motion. | **[Current]** Respect a reduced-motion setting (chapter 13). |
| [Easy Camera Distortion and Manipulation](https://devforum.roblox.com/t/1896438) | 407 | 2022 | Camera FOV and roll effects, custom shiftlock. | **[Current]** Gimmicky title; sound techniques. |

## B.12 Audio

| Tutorial | Likes | Year | What it teaches | Status |
|---|---:|---:|---|---|
| [How to store sounds and music in your game correctly](https://devforum.roblox.com/t/2336991) | 76 | 2023 | SoundGroups, preloading, organisation. | **[Update]** Valid for `Sound`. New work should use the Audio API (`AudioPlayer` → `AudioEmitter`/`Wire`, chapter 15 rule 10). |
| [Making a Music Playlist](https://devforum.roblox.com/t/878997) | 189 | 2020 | Shuffled playlist loop. | **[Update]** `wait`. Use licensed or own audio only. |
| Staff: [Creating Perfect Audio Loops](https://devforum.roblox.com/t/2849057) | 162 | 2024 | Seamless loop editing. | **[Current]** |

Audio is the weakest-covered area in Community Tutorials. Rely on chapter 05 and the Creator Docs Audio API pages.

## B.13 3D art and Blender (for briefing human artists)

| Tutorial | Likes | Year | What it teaches | Status |
|---|---:|---:|---|---|
| [Low-Polying Tutorial for Beginners](https://devforum.roblox.com/t/235354) | 337 | 2019 | Low-poly modelling basics. | **[Concept]** |
| [Blender 2.8 View Model Tutorial (FPS ARMS)](https://devforum.roblox.com/t/584568) | 339 | 2020 | Modelling and exporting viewmodel arms. | **[Concept]** Old Blender UI. |
| [Some tips and tricks to uploading meshes properly](https://devforum.roblox.com/t/45800) | 220 | 2017 | Scale, normals, collision fidelity on import. | **[Current]** |
| [An Introductory Guide to Splitting Meshes](https://devforum.roblox.com/t/2429536) | 89 | 2023 | Splitting meshes for culling and triangle limits. | **[Current]** |
| [{OUTDATED!} high quality PBR textures](https://devforum.roblox.com/t/409419) | 211 | 2019 | PBR texture authoring. | **[Outdated]** Use staff Substance and PBR posts ([2884182](https://devforum.roblox.com/t/2884182), [2723999](https://devforum.roblox.com/t/2723999)). |

## B.14 Tools, workflow and external integrations

| Tutorial | Likes | Year | What it teaches | Status |
|---|---:|---:|---|---|
| [How to create your own plugin](https://devforum.roblox.com/t/1711475) / [comprehensive guide on making Plugins](https://devforum.roblox.com/t/2449141) | 287 / 72 | 2022–23 | Toolbars, widgets, ChangeHistoryService. | **[Current]** |
| [How to setup and use Rojo](https://devforum.roblox.com/t/2322815) / [Automate Place Publishing with Partially Managed Rojo](https://devforum.roblox.com/t/2443196) | 68 / 78 | 2023 | Rojo project setup and CI publishing. | **[Update]** Rojo ≥ 7.7.1 for `Content` properties (chapter 15 rule 11). See chapter 08. |
| [Guide: Effectively QA Testing Your Roblox Experience](https://devforum.roblox.com/t/2199838) | 142 | 2023 | Test plans, device matrix, bug triage. | **[Current]** Pair with chapter 12. |
| [Error tracking with Sentry on Roblox](https://devforum.roblox.com/t/49751) | 292 | 2017 | Sending script errors to an external tracker. | **[Caution]** Works over HttpService; don't send PII. Native error reports in Creator Hub cover most needs. |
| [Using GameAnalytics (Retention and Monetisation)](https://devforum.roblox.com/t/41083) | 357 | 2017 | Third-party analytics SDK. | **[Outdated]** Use native Creator Analytics, funnel/economy/custom events (`AnalyticsService`). |
| [Discord Integration](https://devforum.roblox.com/t/47090) / [Discord Webhooks](https://devforum.roblox.com/t/458366) | 892 / 270 | 2017–20 | Posting to Discord via webhooks. | **[Caution]** Needs a proxy. Never log chat or PII. Uses legacy chat. In-game links are banned (chapter 15 rule 13). |
| [Using Google Spreadsheets as a Database](https://devforum.roblox.com/t/12658) / [Roblox to Trello](https://devforum.roblox.com/t/151887) / [RobloxGmail](https://devforum.roblox.com/t/705169) | 451 / 413 / 222 | 2015–20 | External data stores via HttpService. | **[Outdated]** Use DataStores, MemoryStore, Configs, or Open Cloud. |
| [Rank Management System using Glitch](https://devforum.roblox.com/t/442725) | 499 | 2020 | Group ranking via a cookie bot on a Glitch server. | **[Outdated]** Cookie bots are unsafe and Glitch hosting is gone. Use [Group ranking with Open Cloud](https://devforum.roblox.com/t/3763957) (2025, **[Current]**). |
| [How to get a Server Location/Region](https://devforum.roblox.com/t/1518509) | 396 | 2021 | External IP geolocation of the server. | **[Caution]** Server IP only; never geolocate players. |
| [How to make a free self-hosted Roblox proxy (Cloudflare)](https://devforum.roblox.com/t/3175532) | 85 | 2024 | Proxying roblox.com web APIs. | **[Caution]** HttpService can now call `apis.roblox.com` (Open Cloud) directly. Prefer that. |
| [Custom Chat Tag (2023, TextChatService)](https://devforum.roblox.com/t/2302562) | 129 | 2023 | `OnIncomingMessage` with PrefixText chat tags. | **[Current]** The 2020 version ([735593](https://devforum.roblox.com/t/735593)) and [bubble chat](https://devforum.roblox.com/t/623798) / [chat settings](https://devforum.roblox.com/t/313614) tutorials are **[Outdated]** (legacy Chat retired 2025-04-30). |
| [[REFURBISHED] Adonis Guide V2.0](https://devforum.roblox.com/t/1085802) / [Basic Admin Essentials](https://devforum.roblox.com/t/3019051) | 253 / 294 | 2021–24 | Configuring admin systems. | **[Current]** Adonis is vendored. |

## B.15 Design, marketing and career (opinion pieces)

| Tutorial | Likes | Year | What it teaches | Status |
|---|---:|---:|---|---|
| [The Economic Guide to Profitable Game Advertising](https://devforum.roblox.com/t/122318) | 594 | 2018 | Clicks per Robux, estimated plays, profit spreadsheet (§A.3). | **[Concept]** Banner ads are gone; the method still applies. |
| [Using the Roblox Advertising System](https://devforum.roblox.com/t/64733) | 334 | 2017 | Old user-ads UI. | **[Outdated]** |
| [Monetisation 101](https://devforum.roblox.com/t/246902) | 478 | 2019 | Spending stages, battle passes, hard currency, scarcity (§A.5). | **[Concept]** |
| [Creating Unique Game Ideas](https://devforum.roblox.com/t/53482) | 468 | 2017 | Combining mechanics and themes, observing everyday life. | **[Concept]** |
| [Game Design Theory: Planning a Game](https://devforum.roblox.com/t/62838) / [Psychology of Feedback Loops](https://devforum.roblox.com/t/63140) / [Game Development Theory 101](https://devforum.roblox.com/t/457156) | 269 / 71 / 259 | 2017–20 | Planning docs, positive and negative feedback loops. | **[Concept]** |
| [Achieving Infinite Replayability](https://devforum.roblox.com/t/51179) | 195 | 2017 | Procedural variety, emergent play, social loops. | **[Concept]** |
| [So your game died...](https://devforum.roblox.com/t/2644450) / [Understand the Roblox algorithm](https://devforum.roblox.com/t/2772921) / [How to (actually) make a popular game](https://devforum.roblox.com/t/3115791) / [How to Successfully Grow Your Game](https://devforum.roblox.com/t/2535279) | 152 / 127 / 105 / 264 | 2023–24 | Fun, niche, packaging, retention, ad pacing (§A.2–A.8). | **[Concept]** Verify algorithm claims against chapter 01. |
| [How to Make a Terrifying Horror Game](https://devforum.roblox.com/t/1583917) / [Better Horror Experiences](https://devforum.roblox.com/t/2212571) | 257 / 120 | 2021–23 | Pacing, sound, darkness, entity design. | **[Concept]** |
| [Developers, it's storytime](https://devforum.roblox.com/t/674550) | 266 | 2020 | Story-game clichés and how to write real plots. | **[Concept]** |
| [How to Cooperate with a Development Team](https://devforum.roblox.com/t/122601) / [How to Approach a Developer](https://devforum.roblox.com/t/598071) / [2021 Commission Price Guide](https://devforum.roblox.com/t/1356888) | 511 / 226 / 181 | 2018–21 | Communication, briefs, payment etiquette. | **[Concept]** Prices are dated. |
| [The Art of Robux Getting](https://devforum.roblox.com/t/1922578) / [How to Make $3K per Month](https://devforum.roblox.com/t/3913473) | 255 / 163 | 2022–25 | Robux economics, DevEx math. | **[Concept]** Check the current DevEx rate in chapter 07. |
| [First Time Developing? Things I wish I knew](https://devforum.roblox.com/t/598070) / [Beginners Guide To All Things Game Development](https://devforum.roblox.com/t/1121665) | 218 / 201 | 2020–21 | Start small, finish projects, learn fundamentals. | **[Concept]** |
| [How to Make the Worst Looking Code Possible](https://devforum.roblox.com/t/2319578) | 758 | 2023 | Satire listing anti-patterns. | **[Concept]** Use as a "don't" list. |

**Skip entirely:** Studio UI revert hacks ([3636365](https://devforum.roblox.com/t/3636365), [4258769](https://devforum.roblox.com/t/4258769)), disabling the Roblox desktop app, FPS unlockers, "bring back chat", audio downloading ([3050869](https://devforum.roblox.com/t/3050869): copyright risk), Discord bots, OpenAI-in-Roblox posts from 2023 (API keys belong in Secrets Store and behind policy review), and "AI assistant" promos.

---

# PART C — "Best community resources" catalog (Community Resources)

## C.0 Safety rules for using any community resource

1. **Prefer the vendored copy** in `reference/libraries/<owner>_<repo>` (marked **V** below). It is pinned and inspectable. Otherwise take the GitHub release, not a Toolbox model.
2. **Read every line before it runs in the owner's game.** Look for `require(<number>)`, `getfenv`/`setfenv`, `loadstring`, string-built `require`, `HttpService` calls to unknown hosts, `MarketplaceService` prompts you didn't ask for, and obfuscated blobs. The forum has a whole genre of backdoor-removal guides ([511548](https://devforum.roblox.com/t/511548), [216692](https://devforum.roblox.com/t/216692)).
3. **Never load code by asset ID at runtime.** Suphi's DataStore Module, for example, documents `require(11671168253)`; vendor the source instead so an author update or account takeover can't change your game.
4. **Trust signals:** a long-lived author (loleris, sleitnick, evaera, EgoMoose, boatbomber, ForeverHD, ffrostfall, Quenty, stravant, MaximumADHD, Elttob/dphfox), a public GitHub repo with a licence and issues, many likes *and* recent activity. Likes alone are not trust: a closed free-model anti-cheat has 1,203 likes.
5. **Check maintenance.** Many top-liked resources say "deprecated", "unmaintained" or "superseded" in their own OP. The table records this.
6. **Respect licences.** MIT/Apache: keep the notice. MPL-2.0: modified files stay MPL. TopbarPlus: credit required. No licence stated: treat as "all rights reserved, use as published", and vendor only with permission.
7. **Account security:** a 2025 PSA ([3913726](https://devforum.roblox.com/t/3913726), 704 likes) describes a group that stole front-page games by luring owners into "verifying" with a fake RoVer bot. Never authenticate the owner's account through a link from a stranger.

**Legend:** **V** = vendored in `reference/libraries/`. Licence is from the OP or the vendored LICENSE ("n/s" = not stated). Maintenance is from the OP plus the last-activity date in the mirror.

## C.1 Player data

| Resource | Likes | What it solves | Licence | Maintenance / notes |
|---|---:|---|---|---|
| [ProfileStore](https://devforum.roblox.com/t/3190543) (loleris) **V** | 1531 | Session-locked profiles, auto-save, `MessageAsync`, template reconcile. The successor to ProfileService. | Apache-2.0 | **Active** (2026-09). **Default choice** (chapter 04/07). |
| [ProfileService](https://devforum.roblox.com/t/667805) (loleris) | 3633 | Same, older API. | Apache-2.0 | OP: "STABLE, BUT NO LONGER SUPPORTED — use ProfileStore". |
| [Suphi's DataStore Module](https://devforum.roblox.com/t/2425597) | 749 | Session locking plus MemoryStore-backed state. | n/s | Active. **[Caution]** distributed via `require(id)`; vendor the source. |
| [DataKeep](https://devforum.roblox.com/t/2656200) | 101 | Promise-based ProfileService-style module. | n/s | Last activity 2025-02. |
| [PlayerState](https://devforum.roblox.com/t/3766568) / [Scribe](https://devforum.roblox.com/t/4738905) | 243 / 125 | ProfileStore + Replica wrappers: typed, auto-replicated player data. | n/s / MIT | Active (2026). Optional convenience; ProfileStore + Replica directly is just as easy. |
| Lapis (nezuo) **V**, Lyra (paradoxum) **V** | — | Alternative DataStore libraries (vendored, not in the top forum list). | MIT | See their READMEs. |
| [DataDelve](https://devforum.roblox.com/t/3067950) / [Datastore Editor](https://devforum.roblox.com/t/894063) | 448 / 550 | Studio plugins to inspect and edit DataStore keys. | n/s | Active. Use for support and refunds; never edit live data without a backup. |

## C.2 Networking and replication

| Resource | Likes | What it solves | Licence | Maintenance / notes |
|---|---:|---|---|---|
| [Replica](https://devforum.roblox.com/t/3216980) (loleris) **V** | 568 | Server→client state replication with per-player subscriptions. Successor to [ReplicaService](https://devforum.roblox.com/t/894736) (748). | Apache-2.0 | Active (2026-09). |
| [Blink](https://devforum.roblox.com/t/2959671) **V** | 267 | IDL compiler that generates typed, buffer-packed remotes and validates incoming data. | MIT | Active. **Best fit for bot-generated code:** a schema file gives one source of truth. |
| [ByteNet](https://devforum.roblox.com/t/2733365) (ffrostfall) **V** | 481 | Buffer-serialized packets defined in Luau. | MIT | Active (2026-07). Fork [ByteNet Max](https://devforum.roblox.com/t/3268469) (222). |
| [BridgeNet2](https://devforum.roblox.com/t/2189165) (ffrostfall) **V** | 616 | Batched remotes with simple API. | MIT-style | Still works; the same author's ByteNet is the newer buffer-based design. |
| [Packet](https://devforum.roblox.com/t/3573907) (5uphi) | 780 | Buffer networking library. | n/s | Active (2026-10). |
| [Warp](https://devforum.roblox.com/t/2779813) / [Red](https://devforum.roblox.com/t/2302865) | 407 / 171 | Alternative networking libraries. | n/s | Warp active; Red quieter. |
| rbx-net (roblox-aurora) **V** | — | Definitions-based remotes (TS-friendly). | MIT | Older. |
| [Chrono](https://devforum.roblox.com/t/3873294) (Parihsz) **V** | 667 | Drop-in custom character/physics replication with interpolation; lower bandwidth than default. | MIT | Active (2026-10). Check against Roblox's improved physics replication ([4618365](https://devforum.roblox.com/t/4618365)) and Server Authority before adopting. |
| [Chickynoid](https://devforum.roblox.com/t/1660558) (MrChickenRocket) | 1572 | Server-authoritative character with client prediction and rollback, years before Server Authority. | n/s (GitHub easy-games/chickynoid) | Active-ish (2026-08). Heavy; for competitive games. Roblox's native Server Authority (2025–26) is the forward path. |
| [BetterReplication](https://devforum.roblox.com/t/3260027) | 337 | Lower-latency character replication for combat. | n/s | OP notes superseded parts; evaluate against Chrono and native options. |
| [How we reduced bandwidth 60× in Astro Force](https://devforum.roblox.com/t/1202300) | 946 | Case study: server simulates units as data, clients render; quantize and delta-encode. Under 40–50 KB/s is "exceptional"; Phantom Forces/Arsenal use ~50–80 KB/s **[anecdotal, 2021]**. | — | **[Concept]** The pattern for RTS and tower defense. |
| [Packet Profiler](https://devforum.roblox.com/t/1890924) | 367 | Plugin measuring bytes per remote. | n/s | Active. Use during optimization passes. |
| [MatchmakingService](https://devforum.roblox.com/t/1483736) | 690 | Cross-server matchmaking with MemoryStore. | n/s | **On hold.** Prefer Roblox **Custom Matchmaking** (staff [4164379](https://devforum.roblox.com/t/4164379)). |

## C.3 Code utilities and frameworks

| Resource | Likes | What it solves | Licence | Maintenance / notes |
|---|---:|---|---|---|
| [Promise](https://devforum.roblox.com/t/350825) (evaera) **V** | 727 | Promises for async flows: chaining, cancellation, `Promise.retry`. | MIT | Stable. |
| [GoodSignal](https://devforum.roblox.com/t/1387063) (stravant) | 482 | Fast pure-Luau signal; the thread benchmarks signal implementations. | n/s (gist) | Stable. RbxUtil **Signal V** is the maintained equivalent. |
| Janitor (howmanysmall) **V** / RbxUtil Trove **V** | — | Cleanup ownership (Maid successors). | MIT | Active. |
| [Knit](https://devforum.roblox.com/t/1592333) (sleitnick) **V** | 299 | Services/controllers framework with networking. | MIT | **Archived, no longer maintained** (vendored README). **Disagreement:** [3630438](https://devforum.roblox.com/t/3630438) argues against frameworks. Chapter 04 prefers plain modules. |
| [spr](https://devforum.roblox.com/t/714728) (Fraktality) **V** | 364 | Critically damped springs for UI and object motion in one call. | MIT | Stable. Great for game-feel UI. |
| [BoatTween](https://devforum.roblox.com/t/540277) (boatbomber) | 668 | Extra easing styles, runs on any update event. | n/s | Stable, quiet since 2024. |
| [Cmdr](https://devforum.roblox.com/t/182815) (evaera) **V** | 1515 | Typed, extensible admin/dev command console. | MIT | Active. Good for debug commands in test builds. Gate by `GetRolesInGroupAsync`/UserId allow-list. |
| [Iris](https://devforum.roblox.com/t/2302802) **V** | 1145 | Dear ImGui-style immediate-mode debug UI. | MIT | Active. **Use for dev tools and balance panels, not player UI.** |
| Fusion (dphfox) **V**, Vide **V**, react-lua **V**, charm/reflex/ripple **V** | — | Declarative UI and state libraries. Forum showcases: [Player List with Fusion](https://devforum.roblox.com/t/1763780). | MIT | See chapter 03/04. |
| [Codify](https://devforum.roblox.com/t/473076) (Elttob) | 621 | Converts Studio UI into Luau, Fusion, React or Vide code. | commercial plugin | Active. Handy for turning hand-built UI into code. |
| jecs (Ukendio) **V** | 322 ([3263203](https://devforum.roblox.com/t/3263203)) | Fast ECS. | MIT (vendored) / Apache (OP mention) | Active. For thousands of entities. |

## C.4 UI and topbar

| Resource | Likes | What it solves | Licence | Maintenance / notes |
|---|---:|---|---|---|
| [TopbarPlus v3](https://devforum.roblox.com/t/1017485) (ForeverHD) **V** | 4497 | Topbar icons, dropdowns and menus matching Roblox's topbar. | Custom: **credit required** (keep attribute, or credit in description) | Active (2026-10). The most-liked resource. Re-check after topbar redesigns. |
| [Satchel](https://devforum.roblox.com/t/2451549) **V** (ryanlua) | 1016 | Modern replacement for the default backpack/hotbar. | MPL-2.0 | OP: "v1 is unmaintained to focus on v2"; Creator Store distribution disabled. Use the vendored source. |
| [UI Labs](https://devforum.roblox.com/t/3109174) / [Flipbook](https://devforum.roblox.com/t/2184387) **V** | 238 / 45 | Storybook plugins: preview UI components in isolation. | n/s / MIT | Active. Useful with Fusion/React workflows. |
| [AutoScale Lite](https://devforum.roblox.com/t/217704) / [Interface Tools](https://devforum.roblox.com/t/404423) | 1239 / 877 | Plugins: convert Offset→Scale, add constraints, align and distribute. | n/s | Active. |
| [Vanilla 3 icons](https://devforum.roblox.com/t/935745) (Elttob) | 3083 | Studio icon set (a Studio theme, not game UI). | n/s | Studio-only. For in-game icons see [builder icons](https://devforum.roblox.com/t/3968755) and [Fluency Icon Library](https://devforum.roblox.com/t/2038503). |
| [Pixelfix](https://devforum.roblox.com/t/201802) | 717 | Fixes black fringes on transparent images before upload. | n/s (GitHub Corecii) | Stable. Run on every UI PNG. |
| [Screen3D](https://devforum.roblox.com/t/3273671) | 668 | Turns ScreenGuis into 3D-tilted UI. | n/s | 2026-01 activity. |
| [CanvasDraw](https://devforum.roblox.com/t/1624633) | 1528 | Pixel drawing library on EditableImage. | n/s | Active (2026-10). Drawing games, minimaps. |
| [Nature2D](https://devforum.roblox.com/t/1510935) **V** | 1046 | 2D physics engine for UI elements. | MIT | Quiet since 2026-02. For 2D minigames. |
| [Proximity Prompt Customizer](https://devforum.roblox.com/t/1663458) / [NumberSpinner](https://devforum.roblox.com/t/1105961) / [SliderService](https://devforum.roblox.com/t/1597785) / [GridPack](https://devforum.roblox.com/t/2891897) | 788 / 502 / 499 / 441 | Styled prompts, animated counters, sliders, Tetris-grid inventories. | n/s | Mostly active. |
| [Advanced Dialogue System + Node Editor](https://devforum.roblox.com/t/1526346) / [Dialogue Kit V2.5](https://devforum.roblox.com/t/3548230) | 911 / 140 | Branching NPC dialogue. | n/s | Check maintenance. Dialogue Kit is newer. |

## C.5 Camera

| Resource | Likes | What it solves | Licence | Maintenance / notes |
|---|---:|---|---|---|
| [EZ Camera Shake](https://devforum.roblox.com/t/98482) (sleitnick port) | 1499 | Preset and custom camera shakes. | n/s (port of MIT Unity lib) | Stable; a [v2 refresh](https://devforum.roblox.com/t/4671745) exists. Add a reduced-motion toggle. |
| [CameraService](https://devforum.roblox.com/t/1988655) | 449 | Preset camera modes (OTS, top-down, side-scroller) with smoothing. | n/s | 2026-01 activity. |
| [Over-The-Shoulder Camera](https://devforum.roblox.com/t/728481) / [SmoothShiftLock](https://devforum.roblox.com/t/2180708) | 542 / 487 | Third-person and shift-lock variants. | n/s | Okay. Check against PlayerModule updates. |
| [Cutscenify](https://devforum.roblox.com/t/518030) / [CutsceneService](https://devforum.roblox.com/t/718571) | 703 / 489 | Cutscene authoring (Bézier camera paths). | n/s | Older. Camera-part animation ([1181691](https://devforum.roblox.com/t/1181691)) needs no dependency. |

## C.6 Characters, movement and physics

| Resource | Likes | What it solves | Licence | Maintenance / notes |
|---|---:|---|---|---|
| [Wall stick / Gravity Controller](https://devforum.roblox.com/t/432598) (EgoMoose) **V** | 2543 | Walk on walls and spheres with arbitrary gravity. | MIT | Active thread (2026-11). Test with the Avatar Joint Upgrade and new character controllers. |
| [Realism](https://devforum.roblox.com/t/898642) (MaximumADHD) | 1758 | First-person body visibility, head and look-direction replication. | n/s (GitHub Character-Realism) | 2026-06 activity. Check joint lookups after the joint upgrade. |
| [SmartBone 2](https://devforum.roblox.com/t/2728928) **V** | 817 | Dynamic bone physics for hair, tails, cloth, with collisions. | MIT | Active (2026-09). The old [SmartBone](https://devforum.roblox.com/t/2087131) (1461) is superseded. |
| [RagdollService](https://devforum.roblox.com/t/4255978) | 704 | R6/R15 ragdoll with replication and recovery. | MIT | New (2026), active. Older options: [R15/Rthro Ragdolls](https://devforum.roblox.com/t/338580) (769), [Smooth R6 Ragdoll](https://devforum.roblox.com/t/1580486) (262), [Emilio's ragdoll](https://devforum.roblox.com/t/2865426). |
| [Leg Controller (IK)](https://devforum.roblox.com/t/2617356) / [R6 IK](https://devforum.roblox.com/t/2278937) / [CCDIKController](https://devforum.roblox.com/t/968275) | 405 / 370 / 397 | Procedural foot placement and limb IK. | n/s / n/s / MIT | Mixed. Built-in `IKControl` first. |
| [Nexus VR Character Model](https://devforum.roblox.com/t/109055) **V** | 500 | Full-body VR characters. | MIT | OP: "Needs Maintainer". |
| [Custom character controller](https://devforum.roblox.com/t/172696) / [Platformer controller](https://devforum.roblox.com/t/195215) (EgoMoose) | 1267 / 730 | Reference controllers. | n/s | 2018 era. **[Concept]**; use ControllerManager now ([3092097](https://devforum.roblox.com/t/3092097)). |
| A-Chassis **V** | — | Standard community car chassis. | MPL-2.0 | Vendored. |

## C.7 Combat: projectiles and hitboxes

| Resource | Likes | What it solves | Licence | Maintenance / notes |
|---|---:|---|---|---|
| [FastCast](https://devforum.roblox.com/t/133474) (EtiTheSpirit) | 3254 | Raycast-segmented bullets with drop and velocity, no physics parts. | n/s (MIT on GitHub) | Last version 13.2.0 (2020); support for current version only. Still widely used. |
| [FastCast2](https://devforum.roblox.com/t/4093890) | 558 | Typed FastCast with Parallel Luau and extensions. | MIT | **Active (2026-11).** Prefer for new code. |
| [Raycast Hitbox 4.01](https://devforum.roblox.com/t/374482) | 3317 | Melee hitboxes from attachment raycasts. | n/s | OP: "no longer supported... superseded by **ShapecastHitbox**". |
| [ShapecastHitbox](https://devforum.roblox.com/t/3624241) | 391 | Successor using shapecasts (blockcast/spherecast). | n/s | Active (2026-07). |
| [ClientCast](https://devforum.roblox.com/t/895217) | 717 | Client-side hitbox detection reported to server. | n/s | Active. **Server must validate** (distance, timing). |
| [WCS combat framework](https://devforum.roblox.com/t/2843521) | 356 | Skills, status effects, movesets (battlegrounds-style). | n/s | Active (2026-06). |
| [PartCache](https://devforum.roblox.com/t/246641) | 836 | Object pool for bullets and debris. | n/s | Old; simple to re-implement. |

## C.8 Zones, AI and pathfinding

| Resource | Likes | What it solves | Licence | Maintenance / notes |
|---|---:|---|---|---|
| [ZonePlus v3](https://devforum.roblox.com/t/1017701) (ForeverHD) | 2182 | Enter/exit events for areas (music zones, safe zones, shops). | n/s | Active thread. Faster newcomers: [QuickZone](https://devforum.roblox.com/t/4369336), [ZoneService](https://devforum.roblox.com/t/4901073). For a few zones, `GetPartBoundsInBox` polling is enough. |
| [SimplePath](https://devforum.roblox.com/t/1196762) | 900 | PathfindingService wrapper with blocked-path recompute and events. | n/s | Active (2026-08). |
| [BehaviorTrees3 + Visual Editor](https://devforum.roblox.com/t/836158) | 655 | Behaviour trees for NPC AI. | n/s | Quiet since 2025. |
| [DataPredict](https://devforum.roblox.com/t/2196446) | 1542 | ML/RL library. | **Commercial tiered licence** (free under $5K/yr) | **[Caution]** Licence obligations; rarely needed. |

## C.9 VFX and environment

| Resource | Likes | What it solves | Licence | Maintenance / notes |
|---|---:|---|---|---|
| [Wind Shake](https://devforum.roblox.com/t/1039806) (boatbomber) | 1591 | Cheap foliage sway via tags and attributes. | n/s (GitHub) | Active (2026-10); some API deprecated in favour of attributes. |
| [SkinnedGrass](https://devforum.roblox.com/t/3364812) / [DistanceFade](https://devforum.roblox.com/t/3136828) | 517 / 1000 | Interactive grass; transparency falloff (e.g. reveal-near-player walls). | n/s | Active. |
| [Lightning Beams](https://devforum.roblox.com/t/843534) / [Electric Arcs](https://devforum.roblox.com/t/228413) | 1444 / 695 | Procedural lightning. | n/s | Lightning Beams marked deprecated in places; check the GitHub fork. |
| [Rain Module + Plugin](https://devforum.roblox.com/t/157190) (buildthomas) | 1257 | Rain with splashes, occlusion and audio. | n/s | Active thread. |
| [Lumina particle system](https://devforum.roblox.com/t/2963557) / [Blood Engine](https://devforum.roblox.com/t/2545682) / [Collideable Particles](https://devforum.roblox.com/t/2279402) | 610 / 746 / 513 | Custom particles, droplets and decals, colliding particles. | n/s | Active. Blood/gore affects the maturity rating (chapter 07). |
| [Lens flare system](https://devforum.roblox.com/t/4021857) | 805 | Builder-friendly lens flares. | n/s | New (2025). |
| [LampLight GI](https://devforum.roblox.com/t/1837877) | 536 | Fake global illumination. | n/s | Quiet. Future/Realistic lighting usually suffices. |
| Highlighter **V**, CullThrottle **V** (boatbomber) | — | Syntax highlighting for in-game code UIs; distance-based update throttling. | MIT / MPL-2.0 | Vendored. |
| [Advanced Modular Dynamic Culling](https://devforum.roblox.com/t/4322958) | 503 | Client culling for large maps. | n/s | New (2026). Try StreamingEnabled first. |

## C.10 Operations, admin and workflow

| Resource | Likes | What it solves | Licence | Maintenance / notes |
|---|---:|---|---|---|
| [Soft Shutdown](https://devforum.roblox.com/t/47588) / [SoftShutdown2](https://devforum.roblox.com/t/1156844) | 953 / 530 | On update, teleport players to a temp server and back so nobody is kicked. | n/s | Use **TeleportAsync + TeleportOptions** (old scripts use deprecated `ReserveServer`, chapter 15 rule 5). |
| [Kohl's Admin](https://devforum.roblox.com/t/3163723) / Adonis **V** / [Cmdr](https://devforum.roblox.com/t/182815) **V** | 453 / — / 1515 | Admin commands. | n/s / MIT / MIT | Active. Admin commands that broadcast text must go through TextChatService filtering (chapter 15 rule 12). |
| [Argon](https://devforum.roblox.com/t/2021776) / [Azul](https://devforum.roblox.com/t/4159808) / Rojo **V** | 1131 / 401 / — | File-system ↔ Studio sync. | n/s / n/s / MPL-2.0 | Bot standard is Rojo ≥ 7.7.1 (chapter 08). |
| [Runtime Explorer](https://devforum.roblox.com/t/2693615) | 624 | Explorer for live servers. | n/s | Debug only; admin-gate it. |
| [Hidden Backdoor Detector plugin](https://devforum.roblox.com/t/216692) | 681 | Scans for malicious inserted scripts. | n/s | Last activity 2021; supplement with manual grep (C.0 rule 2). |

## C.11 Open-source games and kits (learn from them, don't ship them)

| Resource | Likes | Notes |
|---|---:|---|
| [Miner's Haven open-sourced](https://devforum.roblox.com/t/350767) (berezaa) | 682 | Full factory/tycoon game; Apache/public-domain mentions in OP. Good for studying droppers and economy. Old APIs and old data patterns. |
| [Ruddev's Battle Royale](https://devforum.roblox.com/t/340548) | 1046 | Complete BR (2019). Study architecture; don't reuse netcode. |
| [Vesteria Open-Source](https://devforum.roblox.com/t/842436) | 597 | Full RPG codebase (2020). Big, dated. |
| [Lots of free & open-sourced games](https://devforum.roblox.com/t/525670) | 559 | Index thread. |
| [Chrythm's RPG Kit](https://devforum.roblox.com/t/436287) / [Evercyan's RPG Kit V2](https://devforum.roblox.com/t/2253417) / [Techy's Obby System](https://devforum.roblox.com/t/785271) / [Sensei's Gun Kit](https://devforum.roblox.com/t/1714719) | 382 / 373 / 481 / 154 | Kits. Using them as-is gives a non-unique place file, which is deprioritized (chapter 01 rule 5). Read them for patterns only. |
| [Exploiting Explained](https://devforum.roblox.com/t/170977) / [How exploits work](https://devforum.roblox.com/t/767594) | 2897 / 613 | Essential threat-model reading. |

## C.12 Avoid or treat with suspicion

- **Closed or free-model "drop-in" anti-cheats** ([CheatBlocker](https://devforum.roblox.com/t/2451762) 1203, [CheatBlocker PRO](https://devforum.roblox.com/t/2626118), [Knightmare](https://devforum.roblox.com/t/2223732), [Anti-Exploit Framework](https://devforum.roblox.com/t/721362)). Distributed as Toolbox models, they offer generic walkspeed and fly checks prone to false positives (see [1643298](https://devforum.roblox.com/t/1643298)), and you can't easily audit updates. Write game-specific server validation instead.
- **Deprecated by their own authors:** [StreamX](https://devforum.roblox.com/t/1992484) (use StreamingEnabled), [RoRender minimap](https://devforum.roblox.com/t/965827), [Topbar+ v1](https://devforum.roblox.com/t/573313), [Zone+ v1](https://devforum.roblox.com/t/397465), [Better Chat V2](https://devforum.roblox.com/t/1093749) and other legacy-chat replacements (Chat retired), [Neural Network Library (Obsolete)](https://devforum.roblox.com/t/400885), [Ray-Traced GI plugin](https://devforum.roblox.com/t/1359785), [Beautiful Roads plugin](https://devforum.roblox.com/t/511940).
- **Web proxies for roblox.com APIs** ([RoProxy](https://devforum.roblox.com/t/1508367), [RoTunnel](https://devforum.roblox.com/t/3809046)): third parties see your traffic. Use Open Cloud from HttpService instead.
- **"AI game builder" promos** ([SuperbulletAI](https://devforum.roblox.com/t/3856417), [RBLX/ai](https://devforum.roblox.com/t/2974290)): high likes, commercial, unrelated to this bot's pipeline.
- **Mass-uncopylocked game dumps** ([953 likes](https://devforum.roblox.com/t/2880269)): IP and backdoor risk; never base an original game on one.

## C.13 Vendored ↔ forum mapping (quick reference)

| Vendored folder | Forum thread | Use for |
|---|---|---|
| `MadStudioRoblox_ProfileStore` | [3190543](https://devforum.roblox.com/t/3190543) | Player data (default) |
| `MadStudioRoblox_Replica` | [3216980](https://devforum.roblox.com/t/3216980) | State replication |
| `1Axen_blink`, `ffrostfall_ByteNet`, `ffrostfall_BridgeNet2` | [2959671](https://devforum.roblox.com/t/2959671), [2733365](https://devforum.roblox.com/t/2733365), [2189165](https://devforum.roblox.com/t/2189165) | Remotes / buffer networking |
| `Parihsz_Chrono` | [3873294](https://devforum.roblox.com/t/3873294) | Custom character replication |
| `1ForeverHD_TopbarPlus` | [1017485](https://devforum.roblox.com/t/1017485) | Topbar icons (credit required) |
| `ryanlua_satchel` | [2451549](https://devforum.roblox.com/t/2451549) | Custom backpack (MPL) |
| `SirMallard_Iris` | [2302802](https://devforum.roblox.com/t/2302802) | Debug UI |
| `evaera_Cmdr`, `Epix-Incorporated_Adonis` | [182815](https://devforum.roblox.com/t/182815), [1085802](https://devforum.roblox.com/t/1085802) | Admin / dev console |
| `evaera_roblox-lua-promise` | [350825](https://devforum.roblox.com/t/350825) | Async |
| `Sleitnick_Knit`, `Sleitnick_RbxUtil` | [1592333](https://devforum.roblox.com/t/1592333), — | Framework (optional); Signal/Trove/etc. |
| `fraktality_spr` | [714728](https://devforum.roblox.com/t/714728) | Springs |
| `EgoMoose_Rbx-Gravity-Controller` | [432598](https://devforum.roblox.com/t/432598) | Wall-walking / custom gravity |
| `smartbone-org_SmartBone-2` | [2728928](https://devforum.roblox.com/t/2728928) | Bone physics |
| `jaipack17_Nature2D` | [1510935](https://devforum.roblox.com/t/1510935) | 2D UI physics |
| `Ukendio_jecs` | [3263203](https://devforum.roblox.com/t/3263203) | ECS |
| `TheNexusAvenger_Nexus-VR-Character-Model` | [109055](https://devforum.roblox.com/t/109055) | VR |
| `flipbook-labs_flipbook` | [2184387](https://devforum.roblox.com/t/2184387) | UI stories |
| `lisphm_A-Chassis` | — | Vehicles |

Not vendored but frequently worth it, after audit: FastCast2, ShapecastHitbox, ZonePlus (or `GetPartBoundsInBox`), SimplePath, Wind Shake, EZ Camera Shake, RagdollService, Pixelfix (offline tool).

---

## Gaps and caveats

- **Ad numbers are historical.** Nearly every spend/CTR figure predates Ads Manager and the 2024 User Ads sunset. Use them to learn the CPP/retention reasoning, then measure live.
- **Survivorship and selection.** Success stories on the forum over-represent lucky launches ("I only spent 2,000 Robux"). Failure threads under-report game quality issues.
- **Algorithm claims from developers** (e.g. "Roblox decides within 10–25 days") are unverified; chapter 01's official signals take precedence.
- **Maintenance status** is from the mirror's OPs and last-activity dates as of 2026-11-05. Re-check a library's GitHub before adopting.
- **Licences** were taken from OPs and vendored LICENSE files. Where "n/s", ask the owner before vendoring.
