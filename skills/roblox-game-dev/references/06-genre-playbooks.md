# 06 — Genre Playbooks for Roblox

> Knowledge-base chapter for a Claude Code bot that designs **original** Roblox games.
> Written 2026-11-05. Covers 21 genres. Each one uses the same template, then there is a section on hybrid trends and on picking a genre that a solo or small bot-run team can really ship.
> Treat every number from a third-party tracker as **directional**. Third-party CCU and revenue figures disagree with each other. Wherever a figure is used, the source is named in the text, and the full list is at the end.

---

## TL;DR rules for the bot

1. **Pick the loop before the theme.** Every hit on Roblox is a familiar loop with a fresh theme or one new twist. Naavik describes Grow a Garden as a remix of known Roblox loops, not a new concept. Copy *structures* (cost curves, loop shapes). Never copy names, art, characters or exact item lists.
2. **Server owns all value.** Currency, inventory, hatch results, growth timers, hit confirmation and purchases are decided on the server. The client only *requests* and *animates*. Any value the client reports gets checked (range, rate, cooldown) before it is accepted.
3. **Default progression curve:** `cost(n) = base * g^n`, with `g` = 1.07–1.15 for idle/tycoon upgrades, 1.15–1.5 for simulator tool tiers, and 2–3× per rebirth. Income grows by a *multiplier* per prestige, not by adding more of the same.
4. **The first 60 seconds decide retention.** Within one minute the player must take the core action, see a number go up, and see the *next* goal on screen. No text-wall tutorials.
5. **Make offline progress and a reason to return built in.** Growth that ticks while the player is away (computed from `os.time()` deltas), daily rotating shops, timed events and streaks. These worked for idle and garden games because players come back on their own schedule.
6. **Shared server moments beat solo moments.** Server-wide weather, boss spawns, admin events and theft raids make players notice one another. Roblox is a social platform first.
7. **Paid random items must disclose odds** (all outcomes, as percentages that sum to 100%) and must respect `PolicyService:GetPolicyInfoForPlayerAsync().ArePaidRandomItemsRestricted`. Luck boosts and pity systems count as paid random items too.
8. **Rewarded video ads give a predictable second revenue line.** Official Roblox genre playbooks target opt-in rates of 10–15%+ and 2.5–3+ views per user per day. Ad rewards must be deterministic (no random rewards) and preferably consumable and non-tradable.
9. **Build mobile-first.** Big buttons, one-thumb play, under about 20 UI elements on screen, and work on low-end phones. A large share of Roblox players are on phones, trend coverage says players expect games to work on every device, and analyses of the top shooter credit mobile-first, cross-input design.
10. **Scope down ruthlessly.** A bot-built MVP should be one map, one core loop, 3–5 upgrade lines, one meta loop (rebirth or collection) and one social hook. Ship in that state, then add an update every week or two.
11. **Prefer genres with low art demand and high systems demand** (simulator, tycoon, incremental, garden/idle, obby, tower defense, steal/raid). The bot is strongest at code and numbers. Avoid art-heavy (fashion, anime RPG, horror atmosphere) or physics-feel-heavy (racing, fighting, FPS) genres unless the twist depends on them.
12. **Always have a sink for every source.** Inflation kills economies and trading. Rebirth resets, consumables, upgrade fees and cosmetics remove currency.
13. **Never make a pay-to-win PvP item the main thing you sell.** Sell time-savers, cosmetics, convenience, extra slots, private servers and luck, with odds disclosed.
14. **Instrument from day one** with funnel events (first action, first purchase, first rebirth, D1 return) through `AnalyticsService`. You cannot tune what you cannot see.
15. **Originality checklist before building:** a new name, new art direction, a new core *verb* or a new *combination* of two loops, and at least one system no top-10 game in the genre has.

---

## Part A — Universal toolkit (read once, applies to every genre)

### A.1 The loop vocabulary

Roblox's own design docs split a core loop into **minute-to-minute interaction**, the **most repeated set of actions**, and a **progression engine**. This chapter adds a **meta loop**: the slower loop that spans sessions (rebirth, collection book, seasons, trading).

```
CORE (seconds–minutes):   act → earn → spend → act stronger
META (hours–weeks):       reach cap → prestige/reset → permanent multiplier → new zone/content
SOCIAL (any):             show off → compare → trade/raid/cooperate
```

### A.2 Progression math cheat-sheet

| Concept | Formula | Typical parameters | Notes |
|---|---|---|---|
| Exponential cost | `cost(n) = base * g^n` | idle 1.07–1.15; sim tool tiers 1.15–1.5 | Cookie-Clicker-style building cost uses g = 1.15 (well-known reference point) |
| Total cost of levels 0..n-1 | `base * (g^n - 1) / (g - 1)` | — | Use for "buy max" buttons |
| Max affordable levels | `floor(log(cash*(g-1)/(base*g^k) + 1) / log(g))` | k = current level | Avoids looping |
| Linear income per level | `income(n) = r * n` | — | Payback time = cost/income grows like g^n/n, so a natural wall appears |
| Polynomial XP curve | `xp(L) = a * L^p` | p = 1.5–2.5 | Gentler than exponential, used for player levels |
| Rebirth cost | `R(k) = R0 * m^k` | m = 1.5–3 | k = rebirths done |
| Rebirth multiplier | additive `1 + 0.5k`, or multiplicative `1.25^k` | — | Additive is safer early, multiplicative feels great but inflates fast |
| Enemy HP per wave (TD) | `hp(w) = base * 1.1^w` to `1.2^w` | — | Tutorial-level common starting point, then hand-tune |
| Weighted drop chance | `P(i) = w_i / Σw` | — | Show P(i) as % in UI |
| Luck modifier | `w_i' = w_i * luck^{tier_i}` for rare tiers | luck 1.0–3.0 | Re-normalize, re-display odds |
| Pity | guarantee tier ≥ T after N misses | N ≈ 1/P(T) × 1–1.5 | Counts as a probability modifier and must be disclosed |
| Soft cap | `eff = x / (1 + x/c)` or `x^0.5` beyond c | — | Stops runaway multipliers |
| Offline earnings | `min(now - lastSeen, cap) * rate * offlineFactor` | cap 2–12 h, factor 0.25–1.0 | Rewarded-video "double offline earnings" is an officially recommended placement |

**Pacing targets (heuristics, tune with analytics):** the first upgrade comes within 10–20 s, the next visible goal is always under about 2 min away, the first prestige comes in 30–90 min of play, and each later prestige should take about the same time as the last (the bigger multiplier offsets the higher cost).

### A.3 Standard server/client split

| Concern | Server | Client |
|---|---|---|
| Currency, inventory, stats | Authoritative, stored in ProfileStore/DataStore | Displays replicated values (attributes / leaderstats / remote snapshots) |
| RNG (hatches, drops, mutations) | `Random.new()` on the server only | Plays reveal animation after the result arrives |
| Timers (growth, cooldowns) | Store timestamps (`os.time()` or `workspace:GetServerTimeNow()`) | Interpolates progress bars locally |
| Combat hits | Validates range, angle, cooldown, line of sight | Detects hits for responsiveness and plays VFX immediately |
| Purchases | `MarketplaceService.ProcessReceipt` grants idempotently | Prompts purchase only |
| Movement | Trust physics, but sanity-check speed/teleport | Owns its character |

### A.4 Monetization menu (pick what fits, don't use all)

- **Game passes** (one-time and permanent): 2× cash, auto-collect, extra slots, VIP area, faster hatch.
- **Developer products** (consumable): currency packs, boosts, revives, skips, luck potions.
- **Subscriptions** (recurring): daily currency, multiplier, exclusive cosmetic. Roblox's docs describe subscriptions as recurring monthly benefits.
- **Private servers**: big for trading, roleplay and grinding games.
- **Rewarded video** (`AdService`): free-player revenue. Official playbooks give benchmarks per genre (see each genre below).
- **Price optimization / regional pricing**: Roblox runs automated price experiments. Per Roblox's earnings letter, 40 of the top 100 experiences by spend had adopted regional pricing by June 2025.
- **DevEx context:** the standard DevEx rate is $0.0038 per earned Robux (since 2025-09-05). A higher $0.0054 rate applies to qualifying spend by age-verified U.S. 18+ players (official docs). So 1,000,000 Robux of earnings ≈ $3,800 at the standard rate.

---

## Part B — Genre comparison table

Scores are 1 (low) to 5 (high). "Bot fit" = how well a code-strong, art-light solo bot can ship it.

| Genre | Build difficulty | Art demand | Monetization fit | Retention potential | Bot fit | Notes |
|---|---|---|---|---|---|---|
| Simulator (clicker/pets/rebirth) | 2 | 2 | 5 | 4 | **5** | Numbers + eggs. Saturated, needs a twist |
| Tycoon (droppers/plots) | 2 | 3 | 4 | 3 | **5** | Ideal first project |
| Obby / parkour | 1 | 2 | 3 | 2 | **4** | Easy to build, hard to stand out |
| Tower defense | 3 | 3 | 5 | 4 | **4** | Gacha towers + waves, balance-heavy |
| Horror (entity chase) | 3 | 5 | 3 | 3 | 2 | Atmosphere, audio and pacing are everything |
| Survival / crafting | 4 | 4 | 3 | 4 | 3 | Day/night + base building, lots of systems |
| Gardening / idle growth | 2 | 3 | 5 | 5 | **5** | Offline progress + events. Proven 2025 megahit shape |
| Steal / raid base | 3 | 2 | 5 | 4 | **4** | Social tension, needs anti-grief tuning |
| Fighting / battlegrounds | 5 | 4 | 3 | 4 | 2 | Netcode + animation heavy |
| Anime RPG / grinder | 4 | 5 | 5 | 4 | 2 | Content treadmill, IP-adjacent risk |
| Roleplay / hangout | 3 | 5 | 4 | 5 | 2 | World size + props. Network effects |
| Fashion / dress-up voting | 3 | 5 | 4 | 4 | 2 | Needs a large clothing catalog |
| Racing / driving | 4 | 4 | 3 | 3 | 2 | Vehicle feel is hard |
| FPS / shooter | 5 | 4 | 4 | 4 | 2 | Hit-reg, recoil, matchmaking |
| Fishing | 2 | 3 | 4 | 4 | **4** | Minigame + collection + zones |
| Party / minigames | 3 | 3 | 3 | 3 | 3 | Many small games mean wide scope |
| Story / adventure | 4 | 5 | 2 | 2 | 2 | Content consumed once |
| Puzzle | 2 | 2 | 2 | 2 | 3 | Niche on Roblox, good as a hybrid layer |
| Sports | 4 | 3 | 3 | 4 | 2 | Ball physics + netcode |
| Incremental / merge | 2 | 2 | 4 | 4 | **5** | Pure math, very bot-friendly |
| Pet collection / trading | 3 | 4 | 5 | 5 | 3 | Trading needs a secure, dupe-proof economy |

---

## Part C — Genre playbooks

Every genre uses this template: **Audience · Why it works on Roblox · Core loop · Meta loop · Key systems · Progression math · Monetization · Retention · MVP vs full scope · Examples analyzed · Failure modes · Original twists.**

---

### C.1 Simulator (clicker / collect / pets / eggs / rebirth)

**Audience.** Younger players (roughly 8–14) and AFK grinders. Players who like watching numbers grow and showing off rare pets.

**Why it works on Roblox.** Click-to-earn is instantly understandable on any device. Pets follow you, so your progress is visible to every other player on the server. Eggs give a gacha-like thrill. Rebirth lets the same map be replayed for hours. Third-party guides consistently call simulators one of the most reliably profitable genres. They cite no hard data, but the monetization levers (multipliers, auto-click, premium eggs, storage) are proven.

**Core loop.**
```
click/swing tool ──► earn "strength/coins" ──► sell at pad (if capacity-limited)
      ▲                                              │
      └──── buy better tool / bigger backpack ◄──────┘
                     │
                     └─► buy eggs ──► hatch pets (multipliers) ──► equip best N
```

**Meta loop.** Fill zones → unlock the next zone (gated by currency) → hit the cost wall → **rebirth** (reset currency/tools, keep pets, gain a permanent multiplier and rebirth tokens) → buy rebirth upgrades → repeat faster. Collection index ("pet book") and limited-time eggs sit on top.

**Key systems.**
- *Data model (per player):* `coins`, `gems`, `rebirths`, `toolTier`, `backpackTier`, `pets = { [uuid] = {id, level, shiny, locked} }`, `equipped = {uuid...}`, `index = {[petId]=true}`, `eggPity = {[eggId]=n}`.
- *Server:* click rate limiting (cap about 10–15 actions/s per player and ignore extras), all hatch rolls, multiplier stacking, zone gating.
- *Client:* click VFX, pet follow animation (CFrame lerp around the character, done client-side for each player's pets to save server bandwidth), hatch cinematic.
- *Multiplier stack:* `income = base * toolMult * (1 + Σ petMults) * rebirthMult * passMult * boostMult`. Keep pets additive among themselves and the other categories multiplicative. Otherwise pets dominate everything.

**Weighted egg hatch with luck and pity (server):**
```lua
--!strict
-- ServerScriptService/EggService (excerpt)
local EGGS = {
	Starter = {
		cost = 100,
		pity = { tier = 4, after = 300 }, -- guarantee tier>=4 after 300 misses
		entries = {
			{ pet = "Pebble", tier = 1, weight = 6000 },
			{ pet = "Sprout", tier = 2, weight = 3000 },
			{ pet = "Glimmer", tier = 3, weight = 900 },
			{ pet = "Comet", tier = 4, weight = 95 },
			{ pet = "Nova", tier = 5, weight = 5 },
		},
	},
}

local rng = Random.new()

local function effectiveWeights(entries, luck: number)
	local out, total = {}, 0
	for i, e in entries do
		-- luck only boosts tier 3+; exponent makes rarer tiers benefit more
		local w = if e.tier >= 3 then e.weight * luck ^ (e.tier - 2) else e.weight
		out[i] = w
		total += w
	end
	return out, total
end

-- Returns odds table for UI disclosure (must sum to 100%).
local function getOdds(eggId: string, luck: number)
	local egg = EGGS[eggId]
	local w, total = effectiveWeights(egg.entries, luck)
	local odds = {}
	for i, e in egg.entries do
		odds[e.pet] = w[i] / total * 100
	end
	return odds
end

local function roll(eggId: string, luck: number, pityCount: number): (string, number)
	local egg = EGGS[eggId]
	local w, total = effectiveWeights(egg.entries, luck)
	local forced = pityCount >= egg.pity.after
	while true do
		local r = rng:NextNumber() * total
		for i, e in egg.entries do
			r -= w[i]
			if r <= 0 then
				if forced and e.tier < egg.pity.tier then break end -- reroll
				local newPity = if e.tier >= egg.pity.tier then 0 else pityCount + 1
				return e.pet, newPity
			end
		end
	end
end
```
Validate the purchase before rolling (enough coins, egg unlocked, player near the egg), deduct, roll, save, *then* fire the reveal to the client.

**Progression math.**
- Tool tiers: `cost(t) = 50 * 3^t` with power `p(t) = 2^t`. The power-per-coin ratio slowly worsens, which pushes players toward pets and rebirth.
- Zone gates: each zone costs about 5–10× the previous one, and its pets/eggs give about 2–3× the multiplier.
- Rebirth: `R(k) = 10,000 * 2.5^k` coins, reward `rebirthMult = 1 + 0.25k` (additive). Grant tokens for a rebirth shop with its own `g = 1.4` costs.
- Egg odds design: the top tier is 0.01–0.1% for bragging rights. The "useful upgrade" tier is around 1% so most players get one in a session.

**Monetization that fits.** 2×/3× coins pass, auto-click/auto-hatch pass, triple-hatch and faster-hatch passes, extra equip slots, pet storage, luck potions (devproduct, disclosed), premium eggs (odds disclosed, not available where `ArePaidRandomItemsRestricted`), and a VIP zone. Rewarded video: official incremental-sim playbook recommends "velocity reward" boosts, doubled "welcome back" earnings, resource refill and timed automation trials. Benchmarks: 13%+ opt-in, about 2.8 views/day.

**Retention.** Daily login chest, timed eggs, a weekly event zone, the pet index with completion rewards, playtime gifts (a reward every 5/10/15 min in session), friend boost (+10% per friend on the server), and leaderboards.

**MVP vs full.** *MVP:* one map with 3 zones, 1 click action, 5 tool tiers, 2 eggs × 5 pets, rebirth, 2 passes, save/load. About 1–2 weeks of bot work. *Full:* 8–15 worlds, 100+ pets with shiny/golden fusion, trading, enchants, events every 1–2 weeks, quests, and clans.

**Examples analyzed.** The Pet Simulator series (BIG Games) pairs collection with progression and trading. The parent-oriented Screenwise guide notes that the latest entry monetizes more aggressively than its predecessor (large bundles, trading plazas). Lesson: trading and rarity scarcity drive long-term value, but over-monetization draws criticism. Strength-training simulators show the "one stat goes up" variant.

**Failure modes.** Nothing to do except click (no decisions). An inflation spiral where multipliers stack multiplicatively. Map too big for mobile. Hatch animation too long and not skippable. Undisclosed odds (a policy violation). Copycat theme lost in a saturated market.

**Original twists.** The click action *is* the theme (e.g., tuning radio signals: each pet is a frequency you pick up). Pets that combine into *formations* with positional synergy. Rebirth that changes the *map* (seasons), not just numbers. A cooperative server goal (fill a shared meter to open a world for everyone). Pets that have jobs in a base while you are offline (simulator × idle).

---

### C.2 Tycoon (droppers, conveyors, plot claiming)

**Audience.** Broad (8–16), with a strong appeal to "builder" personalities. Players love watching a base grow from empty to huge.

**Why it works on Roblox.** Each player claims a visible plot on a shared server, so progress shows in the world and in comparison with neighbors. Buttons that spawn new parts feel tangible. The structure is easy to theme (restaurant, theme park, factory, raft, mansion). Official rewarded-video tycoon examples include Mansion Tycoon, Raft Tycoon and Grow a Garden.

**Core loop.**
```
claim plot ─► dropper spawns ore ─► conveyor carries it ─► collector converts to cash
                    ▲                                              │
                    └──── step on buy-button: new dropper/upgrader ◄┘
```

**Meta loop.** Finish all buttons → rebirth (reset the plot, ×N cash multiplier, unlock cosmetic or new tier) → a second "floor" or a new biome plot → collection of rare decorations.

**Key systems.**
- *Plot claiming:* a fixed set of plot `Model`s in the workspace with an `Owner` attribute. On join, assign the first free plot. On leave, save and clear it.
- *Button graph:* each purchasable is a model with attributes `Cost`, `Requires` (ids of prerequisite buttons) and `Unlocks`. The server stores `purchased = {[id]=true}` and rebuilds the plot from it on join. Saving *ids*, not geometry, keeps data tiny.
- *Droppers and conveyors:* the physical version below works for an MVP, but spawning thousands of unanchored parts is expensive. Scale with **virtual drops**: the server computes cash = Σ(dropper value × upgrader mults / interval), and clients render cosmetic drops locally.
- *Server:* cash, purchases, drop value. *Client:* drop visuals (in the scaled version), button hover UI, build-in animation (tween parts from below).

**Dropper → conveyor → collector (server, MVP physics version):**
```lua
--!strict
-- One script per plot; Plot has attributes Owner (UserId) and parts Dropper, Conveyor, Collector
local Players = game:GetService("Players")
local plot = script.Parent
local dropper = plot.Dropper
local conveyor = plot.Conveyor :: BasePart
local collector = plot.Collector :: BasePart

-- Anchored part with velocity acts as a belt: it moves things touching it
conveyor.Anchored = true
conveyor.AssemblyLinearVelocity = conveyor.CFrame.LookVector * 8

local DROP_VALUE = 5
local INTERVAL = 2
local MAX_LIVE = 25 -- hard cap per plot for performance
local live = 0

task.spawn(function()
	while plot.Parent do
		task.wait(INTERVAL)
		if plot:GetAttribute("Owner") and live < MAX_LIVE then
			local ore = Instance.new("Part")
			ore.Size = Vector3.new(1, 1, 1)
			ore.CFrame = dropper.Spout.CFrame
			ore:SetAttribute("Value", DROP_VALUE * (plot:GetAttribute("DropMult") or 1))
			ore.Parent = workspace.Drops
			ore:SetNetworkOwner(nil) -- server-simulated: clients cannot fling/duplicate
			live += 1
			task.delay(30, function() -- despawn safety
				if ore.Parent then ore:Destroy(); live -= 1 end
			end)
		end
	end
end)

collector.Touched:Connect(function(hit)
	local value = hit:GetAttribute("Value")
	if not value or hit:GetAttribute("Collected") then return end
	hit:SetAttribute("Collected", true)
	local owner = Players:GetPlayerByUserId(plot:GetAttribute("Owner") or 0)
	if owner then
		owner:SetAttribute("Cash", (owner:GetAttribute("Cash") or 0) + value)
	end
	hit:Destroy()
	live -= 1
end)
```
(Use a profile/data module in production instead of raw attributes. Shown simply here.)

**Progression math.**
- Button cost for the *i*-th purchase in plot order: `cost(i) = 25 * 1.35^i`. Each new dropper adds roughly constant income, so the payback time rises from about 10 s to about 3 min across 40 buttons.
- Upgraders multiply ore value by 1.5–3× and cost 3–5× a dropper at that stage.
- Rebirth: `R(k) = totalPlotCost * 1.0 * 2^k`, with reward ×1.5 cash per rebirth (multiplicative, but each rebirth costs 2× more, so it stays bounded).
- Target: full-plot completion in 45–120 min for the first run.

**Monetization.** 2× cash pass, auto-collect pass, a faster-dropper pass, a "golden dropper" premium button costing Robux (on the plot itself, so it is contextual), cash packs, VIP decorations, and a private server. Rewarded video (official tycoon playbook): time-skip / double offline earnings, progressive ad rewards (each consecutive view pays more), progression accelerators. Benchmarks: 15%+ opt-in, 3+ views/day.

**Retention.** Offline earnings (with a cap), rebirth cosmetics visible on the plot, daily rewards, plot visitors with "like" counts, timed events (holiday decorations).

**MVP vs full.** *MVP:* 6 plots, 1 dropper type with 3 upgrades, 25–40 buttons, rebirth, save. About 1 week. *Full:* multiple floors/biomes, worker NPCs, minigames on the plot, raids between tycoons, decorating mode, seasonal content.

**Examples analyzed.** Classic "factory" tycoons established the dropper/conveyor grammar. Newer themed ones (rafts, mansions) wrap it in a theme with movement (the raft sails), which adds exploration. Grow a Garden is arguably a tycoon whose "droppers" are plants, with time in place of conveyors.

**Failure modes.** A linear button walk with zero decisions. Too many physics parts, causing server lag. No reason to stay once the plot is complete. Plot theft or griefing when there are no walls.

**Original twists.** A tycoon you *wear* or *ride* (a moving base). Neighbors' plots link together, so conveyors can feed across plots (co-op supply chains). Customers are other *players' NPCs*. Disasters hit the shared server and you insure your plot. A tycoon whose layout you design (free placement on a grid) instead of fixed buttons.

---

### C.3 Obby / parkour

**Audience.** Very broad, skewing young. Content creators (rage-reaction videos). Players who want quick, readable challenges.

**Why it works on Roblox.** Avatar movement is built in and every device can run and jump, so an obby needs only geometry. It is the platform's native genre. Difficulty-chart and "escape X" obbies dominate the cheap-to-make tier. Official rewarded-video obby benchmarks: opt-in 15–25% genre average, 30%+ best in class, 3–4 views/day per user. These are the highest opt-in rates among the official genre playbooks.

**Core loop.**
```
attempt stage ─► fail (respawn at checkpoint) ─► retry ─► pass ─► checkpoint ─► next stage
```

**Meta loop.** Stage count / % complete leaderboard → badges per section → cosmetics (trails, titles) → a "hard mode" or a new tower → speedrun timers.

**Key systems.**
- *Checkpoint system:* tagged parts with a `Stage` number. The server stores `stage` per player and only accepts `stage == current + 1` (prevents skips), or `<=` for revisits.
- *Kill bricks:* tagged `Kill` parts; on touch set `Humanoid.Health = 0`, server-side.
- *Moving platforms:* `PrismaticConstraint`/`AlignPosition`, or tween an anchored CFrame (a tweened anchored part does not carry players, so use constraints or update the velocity).
- *Skip stage:* devproduct → server increments stage → teleport.
- *Difficulty-chart structure:* sections by difficulty color, each 10–20 stages.

**Checkpoint system (server):**
```lua
--!strict
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local checkpoints: { [number]: BasePart } = {}
for _, cp in CollectionService:GetTagged("Checkpoint") do
	checkpoints[cp:GetAttribute("Stage")] = cp
end

local function getStage(p: Player): number
	return p:GetAttribute("Stage") or 0
end

for stage, cp in checkpoints do
	cp.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player then return end
		local hum = hit.Parent:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then return end
		if stage == getStage(player) + 1 then -- no skipping
			player:SetAttribute("Stage", stage) -- also persist via data module
		end
	end)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		local cp = checkpoints[getStage(player)]
		if cp then
			task.defer(function()
				char:PivotTo(cp.CFrame + Vector3.new(0, 4, 0))
			end)
		end
	end)
end)
```

**Progression math (difficulty curve).** Guides agree: stages 1–5 nearly everyone passes, 6–15 moderate, 16+ steep, with breather stages and never the hardest jump first. Model difficulty as `d(s) = d0 + k*s` with a sawtooth: every 8–10 stages drop d by 20–30% for a breather. Checkpoint density: one per stage early, and in harder sections one every 2–3 "jumps" of challenge. Teach each mechanic alone before combining it (introduce → test → combine → twist).

**Monetization.** Skip-stage devproduct (the top earner in the genre), gravity coil / speed coil passes (keep them out of leaderboards or label them), trails/cosmetics, "save me" revive. Rewarded video: placements at first spawn (timed buff), mid-session (free currency/trial), and **post-failure second chance**. Official examples: an obby where a failed attempt offers an ad to respawn at a previous checkpoint (47% opt-in), and one granting a single-life item on failure.

**Retention.** Hard. Obbies are finite. Use daily rotating "daily tower", weekly new sections, time-trial leaderboards, a stage editor (UGC), and multiplayer co-op obbies (one player holds a button for another).

**MVP vs full.** *MVP:* 30–50 stages, checkpoints, a skip product, a timer, 3 badges. 2–4 days. *Full:* 200–500 stages across themed worlds, unique mechanics per world, cosmetics shop, weekly updates.

**Examples analyzed.** "Escape the [themed villain]" obbies wrap stages in a light story and a chasing threat. Difficulty-chart towers lean into prestige and stream-ability. Both earn from skip and revive moments, the peaks of frustration.

**Failure modes.** Unfair invisible kill-bricks. Inconsistent jump distances (always measure against default WalkSpeed 16 / JumpPower 50, or JumpHeight 7.2). Lag-dependent moving parts. Nothing after the end.

**Original twists.** Obby where the course is generated from the *other players'* ghost runs. Rhythm obby (platforms pulse to music). An obby where you build the next stage for the following player. Physics toys (grapple, wall-run) as the core verb. Asymmetric obby (one player is the course controller).

---

### C.4 Tower defense

**Audience.** 10–18, strategy-minded players and gacha collectors. Strong co-op appeal (play with friends).

**Why it works on Roblox.** Co-op lobbies of 2–4 friends, collectible units (gacha summons) and theme flexibility (anime, memes, toys). Fixed paths are cheap to author. Waves give clear session lengths of 10–30 min.

**Core loop.**
```
lobby ─► queue map ─► place towers with in-match cash ─► waves kill enemies ─► earn cash
                ▲                           │upgrade/sell towers
                └── match reward (gems/xp) ◄┘ win/lose
```

**Meta loop.** Gems → summon banner (gacha) → new towers/units → level and evolve → harder maps / endless mode / raids → limited banners.

**Key systems.**
- *Path:* a sequence of waypoints (Parts in a folder named 1..N). Enemies move by **server-side CFrame interpolation along waypoints**, not Humanoid physics. Distance traveled along the path doubles as the targeting key ("first", "last", "strongest").
- *Enemy replication at scale:* the server keeps enemy state (id, pathDistance, hp, speed) in tables. Clients render models from snapshots (e.g., a `RemoteEvent` every 0.1–0.2 s with compact arrays) and interpolate. Hundreds of Humanoids would kill the server.
- *Tower targeting:* each tower ticks every `1/attackRate` s, queries enemies within range (math against the table, not physics), picks the target by mode, and applies damage on the server. The client plays projectile VFX.
- *Placement:* the client previews, the server validates (on a placeable surface, not on the path, no overlap, enough cash, under the tower limit).
- *Data:* `units = {[uuid]={id, level, xp, trait}}`, `loadout = {uuid×6}`, `gems`, `summonPity`.

**Progression math.**
- Enemy HP: `hp(w) = base * 1.12^w` (1.1–1.2 is the common starting band), plus boss waves at w%10 == 0 with ×8–15 HP.
- In-match income: `cash(w) = 100 + 25w`, plus kill bounties. Compare cumulative cash to the DPS needed: `DPS_req(w) ≈ Σhp(w)/time_on_path`. Tune so a "good" loadout clears about 70–80% of waves of a normal-difficulty map on the first try.
- Tower upgrade costs per level: `c(l) = c0 * 1.6^l`, DPS gain per level: ×1.35–1.5.
- Summon odds e.g. 60/30/8.5/1.4/0.1 with pity at 50–100 pulls for the top-but-one tier.

**Monetization.** Summon currency packs (odds disclosed), unit storage, 2× speed in match, extra loadout slot, VIP, battle pass, limited banners. Rewarded video fits pre-match boosts and "double match rewards."

**Retention.** Daily quests (clear X waves), limited-time banners with expiry, story-map progression, raids, endless leaderboards, trading (if secure).

**MVP vs full.** *MVP:* 1 map, 20 waves + boss, 6 towers with 3 upgrades each, 1 summon banner, co-op of 4. 2–3 weeks. *Full:* 10+ maps, 50+ units with evolutions, modes (endless, challenge, raid), trading, seasons.

**Examples analyzed.** Long-running TD games on Roblox show the gacha unit model plus co-op lobbies. Meme-themed TDs grew fast by attaching a viral theme to a proven loop. Fan-wiki and calculator sites for TD games show how much players care about exact DPS numbers. Expose stats.

**Failure modes.** Humanoid enemies (lag). Wave walls that force paying. Only one viable tower meta. Placement exploits (towers on the path). Unreadable visuals with 50 effects.

**Original twists.** Enemies are other players' armies (async PvP TD). Path drawing (player shapes the path). Towers that move or are your pets. Day/night TD where a garden or tycoon economy feeds the defense. TD × obby: a player runs the path collecting powerups while friends defend.

---

### C.5 Horror (Doors-style rooms / entity chase / atmosphere)

**Audience.** 10–17. Friend groups (screaming together is the product). Streamers.

**Why it works on Roblox.** Horror is shareable and funny with friends, and simple blocky visuals with lighting and audio can still be scary. Doors (LSPLASH, released August 2022 per fan wikis) popularized procedural rooms plus sound-cued entities, and fan sources stress audio cues as a core mechanic (one entity is detected by its screech, and players must hide). Survival-horror hybrids (99 Nights in the Forest) use lighting and sound for tension per games.gg.

**Core loop.**
```
enter room ─► scan (light, loot, key) ─► entity cue (sound/flicker) ─► react (hide/run/look away)
     ▲                                                                      │
     └────────── open next door (room N+1) ◄── survive ◄────────────────────┘
```

**Meta loop.** Run currency (knobs/coins) → shop for pre-run items or revives → unlock floors/modes → achievements/badges for encountering each entity → lore collection.

**Key systems.**
- *Procedural room generator:* a library of room prefabs with `Entrance`/`Exit` attachment parts. The next room's Entrance is pivoted onto the previous Exit, with an overlap check (`GetPartBoundsInBox`). Keep the last 3–5 rooms and delete older ones. Fire a `RoomSpawned` signal that entity spawners listen to.
- *Entity director:* a server state machine with weighted entity picks by room index and cooldowns (no repeat within N rooms). Each entity has `cue → delay → attack → check` phases. The server decides who dies (e.g., not hidden in a closet when the entity passes their room). The client plays sounds, lights and camera shake.
- *Hiding:* closets/beds as ProximityPrompts. The server records `hidden=true`.
- *Atmosphere:* `Lighting` (low Brightness, Atmosphere density, ColorCorrection), point lights that flicker (tween), 3D positional audio with Roblox's audio API. See the official flickering-lights and 3D audio tutorials.
- *Party lobby:* elevator/queue → `TeleportService:ReserveServer` for a private run.

**Progression math.** Light. Run currency per room `c(r) = 1 + floor(r/10)`. Shop item prices are flat. Difficulty: entity spawn probability per room `p(r) = min(0.6, 0.05 + 0.01r)`, plus guaranteed set-pieces at fixed rooms (50, 100).

**Monetization.** Revives (a devproduct, strong because of loss aversion; the official survival playbook calls death the peak moment), cosmetic lobby items, pre-run boosts, private servers. Rewarded video: second chance and streak saver (official survival playbook, 13%+ opt-in, 2.5+ views/day; rewards must be deterministic and consumable).

**Retention.** New floors as major updates, rare entities and achievements, hard modes/modifiers, daily challenges, and content updates hyped on social media.

**MVP vs full.** *MVP:* 15 room prefabs, 3 entities, 50 rooms, hiding, revive. 3–4 weeks (atmosphere tuning takes time). *Full:* several floors, 15+ entities, modifiers, lore, shop. Doors-level polish is a big art/audio job.

**Failure modes.** Unfair deaths with no cue. Every entity is just "run." Too dark on mobile (players turn brightness up and the scare is gone). A long empty walk. Copying a famous entity design.

**Original twists.** Horror where the entity learns from the group's habits (hides where you hid last time). Horror running on sound *you* make (voice chat as a stealth mechanic where available). Daylight horror (wrongness, not darkness). Co-op roles (one sees, one hears). Horror × tycoon: run a haunted shop at night.

---

### C.6 Survival / crafting (day-night, e.g. 99 Nights style)

**Audience.** 11–18, friend squads, players who like planning and base defense.

**Why it works on Roblox.** Co-op runs with clear goals (survive N nights). Day/night creates natural tension cycles. Per games.gg, 99 Nights in the Forest has players build camps, gather resources and defend against threats that escalate each night. Days last only a few minutes, and rescuing missing children shortens the run. The Roblox take on survival is *session-based runs*, not persistent Rust-style worlds.

**Core loop.**
```
day: explore ─► gather (wood, food, scrap) ─► return to camp ─► craft/upgrade campfire & tools
night: defend camp / stay in light ─► survive ─► day N+1 (harder)
```

**Meta loop.** Per-run classes/kits unlocked with persistent currency → badges for nights reached → cosmetic camps → harder modes.

**Key systems.**
- *Day/night clock:* the server owns `dayIndex` and `phase`, and sets `Lighting.ClockTime` from them (tween). Night length grows slightly with dayIndex.
- *Resource nodes:* trees/rocks as models with `HP` attributes. Hitting them is server-validated (distance and tool cooldown). They drop items as physical pickups or straight into inventory. Respawn by timer, or never within a run (scarcity).
- *Crafting:* recipe table `{output, inputs={[item]=n}, station}`. The server checks the inventory atomically, consumes, then grants.
- *Base safety zone:* campfire radius `r = r0 + level*k`. Enemies avoid it or take damage in it. Fuel drains `f(t)` and must be fed, which is the central tension resource.
- *Enemies:* `PathfindingService` for a few smart enemies plus simple steering for swarms. Cap active counts per player.
- *Shared inventory:* chests on the server. Avoid per-item Instances. Use tables.

**Progression math.** Threat budget per night: `B(n) = 10 * 1.15^n` points, spent on enemies with costs (wolf 1, brute 5, boss 25). Resource yield per node is flat, but distance to rich nodes grows, so time cost rises. Campfire fuel burn `= 1 + 0.05n` per second.

**Monetization.** Class/kit unlocks (persistent), cosmetics, revives, pre-run items (keep them modest), private servers. Rewarded video (official survival playbook): second chance, pre-round power-up, streak saver, daily survival kit. Deterministic, consumable, capped daily.

**Retention.** Night milestones as badges, class mastery, seasonal maps, challenge modifiers, rescue/lore side goals (99 Nights' missing children add a secondary objective).

**MVP vs full.** *MVP:* 1 forest map, 5 resources, 10 recipes, 1 campfire with 4 upgrade levels, 3 enemy types, 15 nights. 3–5 weeks. *Full:* classes, bosses, biomes, 99-night arcs, events.

**Failure modes.** Inventory UI hell on mobile. Too many physics items. Dull days (nothing to do but chop). Nights that one-shot weaker friends. No reason for a second run.

**Original twists.** Survival where the *weather* is the enemy (floods rise, retreat upward). Survival on a moving platform (a train, a whale). A player-voted modifier each night. Survival where the camp is a creature you feed. Survival × garden: grow food that matures across nights.

---

### C.7 Gardening / idle growth (Grow a Garden style)

**Audience.** Extremely broad: young kids, casual teens, adults, idle players. Low skill floor.

**Why it works on Roblox.** Grow a Garden (released 2025) is reported to have reached 1 billion visits in about 33 days, the fastest on record per trend sites. Its concurrency peak is reported at roughly 21–22M in mid-2025 (single third-party source). Analyses credit: plants **grow while you are offline** (breaking the "stop playing = stop progressing" norm), a **rotating seed shop** with rarity-weighted stock that makes players check back, **server-wide weather events** that apply crop mutations, rare pets, and social tension from players stealing at night. The developer later talked about shifting toward depth over quantity ("Method Era", Aug 2025, per guide sites). Roblox's own docs list Grow a Garden as a rewarded-video example: a progressive HUD reward that gives growth-accelerating utility items.

**Core loop.**
```
buy seed (rotating shop) ─► plant on plot ─► wait (real-time, also offline) ─► harvest
        ▲                                                                        │
        └───────── sell produce (value × size × mutations) ◄─────────────────────┘
```

**Meta loop.** Rare seeds → multi-harvest plants → pets that buff growth → mutations from weather/events → gear (sprinklers) → limited event currencies and seeds → trading and showing off.

**Key systems.**
- *Real-time growth from timestamps* (no ticking per plant on the server): store `plantedAt`, `growSeconds`. Stage is derived on read. Offline progress comes free.
- *Stock rotation:* a deterministic seed from the time window, so **every server shows the same stock** without cross-server messaging: `seed = floor(os.time()/ROTATION_SECONDS)`, `Random.new(seed)` rolls each item's appearance and quantity by rarity.
- *Weather/events:* scheduled by time windows (deterministic like stock) or triggered globally via `MessagingService` (admin events). While active, each growing plant has a per-minute chance to gain a mutation. Mutation multipliers multiply together for sell value.
- *Crop value:* `value = baseValue * sizeMult * Π(mutationMults)`. Size is rolled at harvest from a skewed distribution (e.g., `1 + 4*rng^6` for rare giants).
- *Stealing/visiting:* other players walking into your plot. Rules like "night only" plus a cooldown and a cap per visitor create tension without a total loss.

**Plant growth with offline progress (server module):**
```lua
--!strict
local Plants = {}

local SEEDS = {
	Carrot = { grow = 60, value = 10, regrow = false },
	Berry = { grow = 300, value = 8, regrow = true, regrowTime = 120 },
	Moonmelon = { grow = 3600, value = 900, regrow = false },
}
local MUTATION_MULT = { Watered = 1.2, Frosted = 2, Starlit = 10 }
local STOCK_CHANCE = { Carrot = 1.0, Berry = 0.6, Moonmelon = 0.03 }
local STOCK_MAX = { Carrot = 20, Berry = 8, Moonmelon = 1 }
local STOCK_ORDER = { "Carrot", "Berry", "Moonmelon" }

export type Plant = {
	seed: string,
	plantedAt: number, -- os.time() when planted (or last harvested for regrowers)
	mutations: { string },
}

function Plants.progress(p: Plant, now: number): number
	local cfg = SEEDS[p.seed]
	local need = if p.mutations and table.find(p.mutations, "Watered") then cfg.grow * 0.9 else cfg.grow
	return math.clamp((now - p.plantedAt) / need, 0, 1)
end

function Plants.harvest(p: Plant, now: number, rng: Random): (number?, Plant?)
	if Plants.progress(p, now) < 1 then return nil, p end -- server rejects early harvest
	local cfg = SEEDS[p.seed]
	local size = 1 + 4 * rng:NextNumber() ^ 6 -- mostly ~1, rare giants up to 5x
	local mult = 1
	for _, m in p.mutations do
		mult *= (MUTATION_MULT[m] or 1)
	end
	local value = math.floor(cfg.value * size * mult)
	if cfg.regrow then
		return value, { seed = p.seed, plantedAt = now - (cfg.grow - cfg.regrowTime), mutations = {} }
	end
	return value, nil
end

-- Deterministic shop: identical across all servers for the same window.
function Plants.currentStock(rotationSeconds: number)
	local window = math.floor(os.time() / rotationSeconds)
	local r = Random.new(window)
	local stock = {}
	-- Iterate a FIXED-ORDER array: dictionary iteration order is not guaranteed,
	-- and a different order would consume RNG differently on each server.
	for _, name in STOCK_ORDER do -- e.g. { "Carrot", "Berry", "Moonmelon" }
		local chance = STOCK_CHANCE[name]
		if r:NextNumber() < chance then
			stock[name] = r:NextInteger(1, STOCK_MAX[name])
		end
	end
	return stock, (window + 1) * rotationSeconds -- next restock time for UI countdown
end

return Plants
```
Note: `os.time()` on different servers can differ slightly. That is fine for 5-minute windows. For exact sync use `workspace:GetServerTimeNow()` on the client to show countdowns.

**Progression math.**
- Seed price vs. return: early seeds pay back in about 1–2 harvests (ROI 2–3×). Rare seeds cost about 50–200× more, take 10–60× longer, and are multi-harvest, so their lifetime ROI is 5–20× but locked behind time. That steers players toward patience, and pays.
- Plot size cap forces *choosing* what to plant (value per tile per hour = `value / growTime`).
- Mutation multipliers range from ×2 (common weather) to ×50–100+ (rare stacked event). Stacking multiplicatively creates the viral "giant mutated crop worth billions" moments.
- Stock appearance chances: common 100%, uncommon 50–70%, rare 10–25%, mythic 1–5% per window.

**Monetization.** Robux-buy any seed from the shop instantly (when out of stock), growth skip (devproduct per plant), sprinklers/gear, pets (eggs, odds disclosed), extra plot space, event passes. Progressive rewarded-video ad rewards in the HUD.

**Retention.** Offline growth (the core), shop restock countdown (every few minutes), weather schedule, weekly event themes with their own currencies, pet leveling, trading and showing off giant crops.

**MVP vs full.** *MVP:* 8 plots per server, 10 seeds (3 regrow), shop rotation, 2 weather events, 3 mutations, selling, save. 1–2 weeks. *Full:* 100+ seeds, pets, gear, event cycles every week, trading, stealing rules, cooking/crafting from produce.

**Failure modes.** No offline progress (it then becomes just a slow tycoon). A static shop. Mutations too rare to ever be seen. Stealing that wipes progress (rage-quits). Economy inflation from stacked multipliers with no sinks. Server-side per-plant loops (performance). Compute from timestamps instead.

**Original twists.** Grow *creatures* or *crystals* (same loop, new verb). An ecosystem where plants affect neighbors (pollination between player plots). A garden that grows on a moving planet with real seasons. Cooperative server-wide giant plant. Cross-breeding genetics (traits as genes, Mendelian odds shown).

---

### C.8 "Steal" / raid base games (Steal a Brainrot style)

**Audience.** 8–15, highly social, meme-driven. Players who enjoy mischief and rivalry.

**Why it works on Roblox.** Steal a Brainrot reportedly passed 25M CCU (PocketGamer.biz reported about 25.4M in October 2025), and together with Grow a Garden it helped push Roblox's platform peak to about 47.4M in August 2025. Its design per reports: players spawn at one of 8 bases on a server, each base produces cash from the characters stored in it, players buy units from a central conveyor or **steal them from other bases**, and later updates added rebirth. Theft creates instant stories and rivalry between strangers. It mixes a tycoon's passive income with tag-like action.

**Core loop.**
```
buy unit from conveyor ─► place in base slot ─► unit generates cash/sec
        ▲                                                │
        │   steal: run into rival base, grab unit, carry it home (slow, vulnerable)
        └──── defend: lock base, hit thieves, chase ◄────┘
```

**Meta loop.** Rarer units (higher income) → more base slots/floors → rebirth (reset for multiplier, keep some slots) → limited-event units → collection and trading.

**Key systems.**
- *Base:* fixed base models (8 per server) with slots. Unit state = `{unitId, rarity, mutation, slot, ownerId}`. Units in slots generate `income/s` server-side (accumulate per second or compute on collection).
- *Conveyor shop:* the server spawns a stream of units with random rarity on a belt. A purchase prompt (cash or Robux) is available while the unit passes. This creates scarcity and racing.
- *Stealing:* a ProximityPrompt on a slot (rival base only). On complete, the thief "carries" the unit (attach to the character, set WalkSpeed lower). Reaching their own base transfers ownership. Being hit/tagged before then returns the unit. All state on the server.
- *Defense:* a base lock (timed shield, e.g. 60 s with cooldown), slap/hit tools with knockback, traps.
- *Anti-grief:* new-player protection, minimum time a unit stays put after purchase, a cap on steals per minute, and players with protection cannot steal.

**Progression math.**
- Unit price ≈ income × payback seconds: `price = income * T`, with T rising from 30 s (common) to 300–600 s (legendary). Rarity weights on the conveyor e.g. 70/22/6/1.8/0.2%.
- Income per rarity: ×4–6 per tier. Slots cost `s(n) = 1000 * 2.2^n`.
- Rebirth requires owning specific rarity units plus cash, giving `+50%` income per rebirth.
- Steal time balance: prompt hold 1–3 s, carry speed −30–50%, distance from rival base to home about 8–15 s of walking, so defenders have a chance.

**Monetization.** Robux-buy conveyor units (direct purchase, not random, so no odds needed), lock/shield extensions, speed or carry passes (PvP-sensitive, so keep modest), extra slots, cosmetic bases, server luck boosts (disclosed odds affect the conveyor), private servers (popular in steal games so players can farm safely).

**Retention.** Revenge (you know who stole from you), events with special conveyor units (Steal a Brainrot's records came during an event, per reports), rebirth tiers, leaderboards of base value, and offline income (if bases persist).

**MVP vs full.** *MVP:* 8 bases, 1 conveyor, 15 units across 5 rarities, steal/carry/return, lock, 2 passes. 2 weeks. *Full:* mutations, rebirth, traits, event units, trading, multiple floors, admin events.

**Failure modes.** Endless theft of everything a new player owns (churn). Server hoppers. Exploits on carry (teleport home). Too-strong paid PvP tools (backlash). Meme theme that fades: RoWatcher already asks whether the brainrot trend is dying, based on CCU data.

**Original twists.** Steal *time* or *energy* rather than objects. Heist planning with roles (lookout, carrier). A shared vault everyone defends against an NPC raid boss. Steal-and-return bounty system (police vs. thieves). Bases that move (ships raiding ships). Cozy-steal: you "borrow" a neighbor's pet and it returns with a gift.

---

### C.9 Fighting / battlegrounds

**Audience.** 11–18, competitive, often anime fans. Players who like learning tech and making combo videos.

**Why it works on Roblox.** Drop-in free-for-all servers with no matchmaking wait. Player guides describe the leading battlegrounds game (released August 2022) as easy to learn but hard to master. Its kit is M1 basic strings, 4 equipped skills, movement tech like dashes and ragdoll cancels, and an "awakening" ultimate. Community-discovered tech extends the skill ceiling. Characters themed on anime archetypes sell on fandom. (Do **not** use real anime IP.)

**Core loop.**
```
find target ─► M1 string (4 hits) ─► stun ─► skill confirm ─► knockback/ragdoll ─► reset/escape
      ▲                                                                              │
      └────────────── fill ultimate meter from damage dealt ◄────────────────────────┘
```

**Meta loop.** Kills → unlock characters/movesets → emotes and kill effects → ranked or kill-streak leaderboards → new character releases as updates.

**Key systems.**
- *Frame data in seconds:* define every move as `{startup, active, recovery, damage, stun, knockback, hitbox={size, offset}}`. Typical M1: startup 0.10 s, active 0.10 s, recovery 0.25 s, stun 0.35–0.5 s. The 4th M1 knocks back. Stun > attacker recovery = combo window.
- *Hit detection (hybrid, the community consensus):* the client runs the hitbox (`workspace:GetPartBoundsInBox` / `Blockcast` at the active frame) for instant feedback, then sends `{moveId, targets, attackerCFrame, t}`. The server validates: the move is off cooldown, the attacker is not stunned, each target is within `range + tolerance` (latency-based tolerance, e.g. +4–6 studs), and the angle is plausible. Then it applies damage/stun. DevForum threads warn that tight server checks (e.g., 3 studs) cause missed hits from replication delay.
- *Blocking:* a `Blocking` state reduces damage 80–100% from the front (dot product of the attacker direction against the defender LookVector > 0.3). Block meter/guard-break after N hits. A "perfect block" window of 0.15–0.25 s stuns the attacker.
- *Stun and states:* the server keeps `state ∈ {Idle, Attacking, Stunned, Blocking, Ragdoll, Dashing}` per character, plus timers. Inputs are rejected in an invalid state. Replicate state via attributes so all clients animate it.
- *Knockback:* `LinearVelocity`/`ApplyImpulse` on the server-owned target, or on the client of the network owner. Network ownership of characters is the victim's client, so knockback typically sends a remote to the victim's client or sets velocity on the server (both have trade-offs, so test with latency).
- *Animation-driven timings:* use `AnimationTrack:GetMarkerReachedSignal("Hit")` on the client to time hitboxes. The server uses its own timers from frame data, never trusting client timings.

**Client-detect, server-validate (server excerpt):**
```lua
--!strict
local MOVES = { M1 = { cooldown = 0.35, range = 6, maxTargets = 3, damage = 5, stun = 0.4 } }
local TOLERANCE = 5 -- studs for latency
local lastUse: { [Player]: { [string]: number } } = {}

AttackRemote.OnServerEvent:Connect(function(player: Player, moveId: string, targets: { Model })
	local move = MOVES[moveId]
	local char = player.Character
	if not move or not char or typeof(targets) ~= "table" then return end
	if char:GetAttribute("State") == "Stunned" then return end

	local now = os.clock()
	lastUse[player] = lastUse[player] or {}
	if now - (lastUse[player][moveId] or 0) < move.cooldown * 0.9 then return end -- small leniency
	lastUse[player][moveId] = now

	local root = char:FindFirstChild("HumanoidRootPart") :: BasePart
	local count = 0
	for _, target in targets do
		if count >= move.maxTargets then break end
		if typeof(target) ~= "Instance" or not target:IsA("Model") or target == char then continue end
		local hum = target:FindFirstChildOfClass("Humanoid")
		local troot = target:FindFirstChild("HumanoidRootPart") :: BasePart?
		if not hum or not troot or hum.Health <= 0 then continue end
		local offset = troot.Position - root.Position
		if offset.Magnitude > move.range + TOLERANCE then continue end
		if root.CFrame.LookVector:Dot(offset.Unit) < -0.2 then continue end -- behind attacker
		count += 1
		local blocking = target:GetAttribute("State") == "Blocking"
			and troot.CFrame.LookVector:Dot(-offset.Unit) > 0.3
		hum:TakeDamage(if blocking then move.damage * 0.1 else move.damage)
		if not blocking then
			target:SetAttribute("State", "Stunned")
			target:SetAttribute("StunUntil", workspace:GetServerTimeNow() + move.stun)
		end
	end
end)
```
(Clean `lastUse` on PlayerRemoving. A state-machine heartbeat clears the stun when `StunUntil` passes.)

**Progression math.** Mostly horizontal. Character unlock via kills: `k(c) = 50 * 2^c` kills, or a currency price. Ultimate meter: fills from damage dealt `+dmg*1.0` and taken `+dmg*0.5`, needs about 100–150 damage dealt.

**Monetization.** Character/moveset unlocks (Robux shortcut), cosmetic kill effects/emotes/auras, private servers (practice), VIP. Avoid selling raw damage.

**Retention.** New characters every few weeks (the main lever), kill streak titles, rank seasons, community tech discovery (leave interactions emergent), training dummies.

**MVP vs full.** *MVP:* 1 arena, 2 characters × (M1 + 3 skills + ultimate), block/dash/ragdoll, kill leaderboard. 3–5 weeks, heavy on animation. *Full:* 10+ characters, ranked, modes, map hazards, cosmetics.

**Failure modes.** Server-only hitboxes (feel laggy), client-trusted damage (exploits), stun-lock infinites with no escape, unreadable VFX spam, animations that don't match hitboxes, mobile controls with no auto-target.

**Original twists.** A fighter where the *environment* is your moveset (grab props). Elemental combos between teammates. Rhythm-timed blocks. A battleground where you fight as a pet you raised (sim × fighter). Weight-class physics sumo (simpler animation demands).

---

### C.10 Anime RPG / grinder

**Audience.** 11–20, anime fans, long-session grinders, players who like stat optimization.

**Why it works on Roblox.** Long grind loops sustain huge playtime. Gacha-style "fruit/power/race rerolls" monetize strongly. Open-world quests give sessions a direction. Official RPG rewarded-video guidance: reward *time saved*, not power ("convenience" placement), loss-aversion revives, luck potions, 2× XP. Opt-in 15%+, 3+ views/day. Rewards deterministic, and account-bound so alt farming can't break trading.

**Core loop.**
```
take quest ─► kill mobs in zone ─► XP + money + drops ─► level ─► allocate stats
     ▲                                                              │
     └──── stronger: next zone / boss / sea ◄── buy/reroll power ◄──┘
```

**Meta loop.** Level cap per area → new island/world → rare power reroll (gacha) → raids/bosses for unique drops → PvP bounty → prestige/race evolution.

**Key systems.**
- *Mobs:* NPC Humanoids are expensive. Pool them, cap per zone (e.g. 8–12), simple chase AI on the server, and stream out distant zones (`StreamingEnabled`).
- *Combat:* reuse the fighting hit-validation pattern, PvE-lenient.
- *Stats:* `{level, xp, statPoints, melee, defense, power, sword}`. Damage = `base * (1 + stat/100)` with soft caps.
- *Quests:* data tables `{npc, killTarget, count, reward}` and server-tracked counters.
- *Powers/abilities:* a rarity-weighted roll (paid ⇒ disclose odds), stored by id. Ability scripts live in modules keyed by id.

**Progression math.** XP to next level `xp(L) = 50 * L^1.8`. Mob XP `≈ 8 * L_mob^1.5` so about 15–30 kills/level early and 60–100 later. Zone level bands every 25–50 levels. Gear upgrade `c(u) = c0 * 1.5^u`. Max level 1,000–3,000 is common for long grinds. Use soft caps to avoid stat inflation.

**Monetization.** Power/fruit rerolls (odds disclosed), 2× XP/money passes, inventory storage, fast travel, private servers (grinding), cosmetic auras.

**Retention.** Bosses on timers (server announcements), raids with friends, rare spawns, updates adding a new sea/island, codes for boosts (common Roblox practice).

**MVP vs full.** *MVP:* 2 islands, 3 mob types, 1 boss, 30 levels, 5 abilities, quests. 4–6 weeks. *Full:* multiple worlds, hundreds of levels, raids, PvP, factions. The content treadmill is very heavy.

**Failure modes.** Content drought (players hit the cap in a week). Copying anime IP (takedown risk). Laggy mob combat. Stat inflation. Dead starter zone with nobody to group with.

**Original twists.** An original mythos (folklore, not anime). Abilities crafted from combinable runes instead of gacha. Class swaps tied to time of day. A cooperative world boss that persists across servers via MemoryStore health.

---

### C.11 Roleplay / social hangout (Brookhaven style)

**Audience.** The broadest audience on the platform: kids, families of friends, teens. Players who make their own fun.

**Why it works on Roblox.** Roblox is a social network. RoWatcher reports Brookhaven RP (released April 2020) passed about 80B visits, making it the most-visited experience. Analyses credit its simplicity: houses, vehicles and a city to explore, with no grind currency, and game passes for premium houses, vehicles and property (it was acquired by Voldex in February 2025). Roblox's own docs show Brookhaven's rewarded-video placement as a timed VIP trial ("try before you buy").

**Core loop.**
```
spawn ─► pick house/job/outfit ─► act out scenarios with friends (school, family, cops)
   ▲                                                       │
   └────── unlock more props/vehicles/houses ◄─────────────┘
```

**Meta loop.** Basically social: new map areas, seasonal events, premium houses. No grind is a feature.

**Key systems.**
- *Houses:* claimable plots with a lock, customization (colors, furniture), and per-player persistence if you go deeper.
- *Props/tools:* a catalog of tools given via a menu. Server-validated spawns with per-player limits.
- *Vehicles:* a spawn menu with a cap per player and despawn on leave. Simple chassis (see Racing).
- *Roles/teams:* jobs as cosmetic teams with uniforms and tools. Name tags and bios with TextService filtering (**always filter user text**).
- *Avatar editing:* `HumanoidDescription` application for outfits (server-side `ApplyDescription`).

**Progression math.** None, or cosmetic. If you add currency, keep it soft (pay for furniture). Prices flat by tier.

**Monetization.** Premium houses, vehicles and pets as passes, VIP chat color and areas, music/radio pass, private servers (huge for roleplay groups), timed VIP trials via rewarded video.

**Retention.** Friends (network effects), frequent small updates (new buildings), holiday decorations, houses that remember customization.

**MVP vs full.** *MVP:* small town of 8 buildings, 10 houses, 5 vehicles, 10 props, jobs, house lock. 3–4 weeks (mostly building/art). *Full:* a large city, interiors, hundreds of props, custom houses, events.

**Failure modes.** An empty-feeling world with low player counts (roleplay needs people). Moderation and safety issues (filter text, no private-messaging bypasses). Clutter and prop spam lag. Copying a famous map layout.

**Original twists.** Roleplay with light systemic hooks (a town economy, elections that change laws, weather). A non-city setting (space station, medieval village, underwater). Roleplay with a "story director" that triggers scenarios (fires, alien landing). Pets or creatures as roleplay companions.

---

### C.12 Fashion / dress-up voting

**Audience.** Mostly 9–16, creative and social. TikTok-driven.

**Why it works on Roblox.** Dress to Impress launched November 2023 and is described as one of the fastest experiences to 1B visits. The loop: a theme, a short timer to dress up, then a runway where every player rates every other outfit. It spread through short-form video. Guides stress reading the theme over owning rare items. The persistent complaint is spite-voting (giving every competitor the minimum).

**Core loop.**
```
theme announced ─► dress-up timer (catalog, colors, makeup) ─► runway walk ─► everyone votes
       ▲                                                                        │
       └─────── currency/xp from placement ─► unlock items/levels ◄─────────────┘
```

**Meta loop.** Level up → unlock catalog items → VIP items → seasonal themes → titles/rank.

**Key systems.**
- *Outfit system:* layered clothing/accessories applied on a custom rig or via `HumanoidDescription`. Color/pattern pickers. The item catalog is data-driven `{id, slot, assetId, unlockLevel, vip}`.
- *Round manager:* server state machine Lobby → Theme → Dressing (timer) → Runway (sequence each player) → Voting → Results.
- *Voting fairness:* drop the top and bottom vote per outfit, weight voters by agreement with consensus (penalize consistent outlier voters), and do not let players vote on themselves. Show anonymized results.
- *Text:* any custom theme or name text goes through TextService filtering.

**Progression math.** Placement reward `r(p) = base * (N - p + 1)/N`. Level curve `xp(L) = 100 * L^1.5`. Unlock about 3–5 items per level early.

**Monetization.** VIP pass (exclusive items), item bundles, makeup/pose packs, private servers (friends' runway shows), extra customization slots (saved outfits).

**Retention.** Daily themes, events with exclusive items, saved outfit slots, social sharing moments.

**MVP vs full.** *MVP:* 1 stage, 60–100 items, 20 themes, voting, levels. Art is the bottleneck. *Full:* hundreds of items, patterns, makeup, poses, events.

**Failure modes.** A thin catalog (the genre lives on items). Toxic voting. Long dead time between rounds. A UI that is unusable on phones.

**Original twists.** Design-the-garment (pattern/shape editor). Team styling (pairs). Judge NPC with a taste profile instead of peer votes for part of the score. Fashion × tycoon (run a boutique, players buy your designs). Non-human dress-up (dress creatures, robots, houses).

---

### C.13 Racing / driving

**Audience.** 8–18, car lovers, players who like driving with friends without a strict goal.

**Why it works on Roblox.** Cars are aspirational collectibles, driving with friends is social, and open-world driving doubles as a hangout. Competitive racing is smaller than "car ownership" games.

**Core loop.**
```
drive ─► race / deliver / explore ─► earn cash ─► buy/upgrade cars ─► drive faster
```

**Meta loop.** Car collection, tuning trees, liveries, leaderboards per track, seasonal cars.

**Key systems.**
- *Chassis:* three families per DevForum discussions: the simple VehicleSeat ("tank") chassis that is easy and stable, constraint chassis (HingeConstraints with motors on wheels, SpringConstraints for suspension) with better steering but sometimes unstable, and open-source community chassis (A-Chassis is widely used). Raycast suspension (custom, using `VectorForce`/`LinearVelocity` per wheel from raycasts) gives arcade feel and is stable at speed. That makes it a strong choice for a bot that can tune numbers.
- *Network ownership:* set the vehicle's network owner to the driver (`SetNetworkOwner(player)`) for responsive control. The server sanity-checks speed.
- *Checkpoints for races:* ordered gates, lap counts, position = laps*N + lastGate + progress to the next gate.
- *Upgrades:* data `{carId, engine, tires, nitro, livery}` mapped to chassis parameters (torque, max speed, grip).

**Progression math.** Car price tiers ×2–3 per class. Upgrade levels `c(l) = c0 * 1.4^l`, +4–6% speed per level. Race payouts scale with class: `pay = base * classMult * (1 + 0.5*(placement==1))`.

**Monetization.** Premium cars (passes), cash packs, liveries, garage slots, private servers.

**Retention.** Daily races, time-trial ghosts, car meets, new cars in updates.

**MVP vs full.** *MVP:* 1 map, 4 cars, 1 race track + free roam, upgrades. 3–4 weeks (handling tuning). *Full:* open world, 50+ cars, tuning, police chases, jobs.

**Failure modes.** Floaty, flippy cars, physics jank at high speed, mobile steering that is unplayable, server lag with many cars.

**Original twists.** Driving non-cars (shopping carts, snails, hovercraft). Delivery games where the cargo is physics-fragile. Racing on procedurally built tracks players vote on. Co-op vehicle with a driver plus a gunner/navigator.

---

### C.14 FPS / shooters

**Audience.** 12–20+, competitive, the older Roblox cohort. The official shooter playbook frames players as driven by competition, mastery and weapon upgrades.

**Why it works on Roblox.** RIVALS, a round-based 1v1 to 5v5 duel shooter, reportedly peaked at about 964K CCU (RoWatcher). Analyses credit mobile-first, cross-input design, clear hit feedback (tracers, hit markers), ranked seasons and cosmetic skins as the revenue driver.

**Core loop.**
```
queue ─► round (spawn, fight, die/kill) ─► round end ─► match result
  ▲                                                       │
  └── XP/keys ─► unlock weapons/skins/cases ◄─────────────┘
```

**Meta loop.** Weapon unlocks, skin collection (cases with disclosed odds), ranked ELO seasons, battle pass.

**Key systems.**
- *Hit detection:* Roblox's official laser-tag sample is the reference. The **client** computes rays from the camera (instant feel) and sends results. The **server validates** the data types, the angle against the expected direction (tolerance), shooter-to-origin distance, target-near-destination distance, and line of sight (re-raycast for obstruction). Then it applies `Humanoid:TakeDamage` (respects ForceFields).
- *Projectile weapons:* the community module **FastCast** simulates bullets with velocity and drop using segment raycasts per frame. The client renders cosmetic bullets, and the server or a validator decides hits.
- *Recoil:* camera recoil applied on the client: per shot add `pitch += r_v * pattern[i]`, `yaw += r_h * random(-1,1)`, recover with a spring (`x += (0 - x) * (1 - exp(-k*dt))`). Spread grows with shots fired, `spread = s0 + s1 * heat` and decays over time.
- *Lag compensation:* basic server rewind (store character positions for the last ~1 s, validate the hit against the position at `shotTime - latency`) is advanced. Many Roblox shooters use generous tolerances instead.
- *Matchmaking:* lobby place → `TeleportService` to reserved servers for matches, with per-input pools if aim assist exists.

**Progression math.** Account XP `xp(L) = 200 * L^1.4`. Weapon unlock per level band. ELO `R' = R + K*(S - E)`, `E = 1/(1+10^((Rb-Ra)/400))`, K = 24–40.

**Monetization.** Skins/wraps, cases (odds disclosed), battle pass, emotes and finishers. Never sell stats. Rewarded video (official shooter playbook): pre-match XP boost, armory currency, **weapon trial for one match** (example: RIVALS), post-match payout double. Only at natural breaks. 10%+ opt-in, 3+ views/day.

**Retention.** Ranked seasons, daily challenges, new weapons/maps per update, friends parties.

**MVP vs full.** *MVP:* 1 small map, 1v1/2v2 rounds, 3 weapons, validation, simple skins. 4–6 weeks. *Full:* 20+ weapons, ranked, modes, cosmetics economy, anti-cheat.

**Failure modes.** Client-trusted damage (aimbots and teleport kills), no mobile aim assist, poor hit feedback, too many modes splitting a small player base.

**Original twists.** Paint/territory shooter (non-violent, younger audience). Shooter where ammo is your currency. Gravity-shifting maps. Asymmetric 1-vs-many boss shooter. Shooter × tower defense hybrid.

---

### C.15 Fishing (minigame)

**Audience.** Broad, chill and collector-minded. Idle-friendly.

**Why it works on Roblox.** A relaxing core with gacha-like rarity at every cast. Fisch's developer said in Roblox's Creator Spotlight that he took inspiration from a beloved farming sim's fishing that none of the roughly 20 Roblox fishing games he tried had. He designed it to be open-ended with more than one end goal, and argued retention depends on being able to play in multiple ways. Per that spotlight, CCU peaked around 470K after a Halloween event, and the Roblox wiki says it passed 1M CCU on 2025-10-04.

**Core loop.**
```
cast ─► wait for bite ─► reel minigame (keep bar on fish) ─► catch ─► sell / log in bestiary
  ▲                                                                     │
  └──── buy better rod/bait, travel to new waters ◄─────────────────────┘
```

**Meta loop.** Bestiary completion, location-gated rare fish, weather/time-of-day spawns, rods with unique abilities, events and mythic hunts.

**Key systems.**
- *Server picks the fish at bite time:* `pickFish(zone, timeOfDay, weather, luck)` from weighted tables. The client only plays the minigame.
- *Reel minigame (client):* a fish marker moves (noise/random walk) at a speed set by a per-fish "resilience" stat. The player holds/releases to keep the catch bar overlapping. Progress fills while overlapping and drains otherwise. Rod stats widen the bar or slow the fish (one rod freezes the fish bar).
- *Validation:* the server expects the result no sooner than a minimum plausible duration `t_min = progressNeeded / maxFillRate`, and rejects a claimed catch faster than that. Cap catches per minute.
- *Data:* `bestiary = {[fishId]={count, maxWeight, mutations}}`, rods owned, bait.

**Progression math.** Rarity weights (e.g., 55/28/12/4/0.9/0.1%) with luck `w' = w * luck^tier` on rare tiers. Weight per catch is log-normal, and sell value `= base * (weight/avgWeight)^1.2 * mutationMult`. Rod price `c(r) = 200 * 3^r`, luck +15–25% per tier.

**Monetization.** Rods/bait (soft currency plus Robux shortcuts), luck boosts (Fisch's luck boost is cited officially as a rewarded-video "velocity reward"), boats, extra storage, private servers.

**Retention.** Bestiary, rotating weather, events with limited fish, multiple paths (fishing, treasure, exploration, quests).

**MVP vs full.** *MVP:* 2 zones, 25 fish, 4 rods, minigame, bestiary, selling. 2 weeks. *Full:* 10+ zones, 300+ fish, boats, events, quests.

**Failure modes.** A minigame that is too hard on mobile, too easy (no skill), or identical for every fish. A single linear goal. Fish art fatigue (vary silhouettes).

**Original twists.** Fishing in odd media (clouds, lava, dreams, data streams). Co-op net fishing. Fish that you then raise in an aquarium tycoon. Fishing where the catch is a creature you can battle.

---

### C.16 Party / minigame collection

**Audience.** 7–15, friend groups, short-session players.

**Why it works on Roblox.** Varied 1–3 minute rounds keep groups together. Easy to understand, with no long commitment.

**Core loop.** `lobby → random minigame → play 60–180 s → points/elimination → next minigame → winner gets coins`.

**Meta loop.** Coins → cosmetics/effects → level/titles → map votes.

**Key systems.** A round manager loads minigame modules from a registry (`{name, minPlayers, setup(), run(), cleanup()}`). Map models are cloned from ServerStorage and destroyed after. Each minigame is self-contained: score API, teams, timers. Always clean up connections (use a "trove"/maid pattern).

**Progression math.** Flat coin payouts by placement. Level `xp(L) = 100 * L^1.3`.

**Monetization.** Cosmetics, double-coins pass, extra votes, VIP lobby, private servers. Rewarded video: post-round coin double, rematch.

**Retention.** New minigame weekly, daily challenges, rare "chaos" rounds.

**MVP vs full.** *MVP:* 5 minigames, lobby, coins, a shop of 10 cosmetics. 2–3 weeks. *Full:* 30+ minigames, modes, events.

**Failure modes.** A few great minigames buried among bad ones, long load/dead time, games that need 6+ players on empty servers.

**Original twists.** Minigames that change based on the previous winner. A board-game meta layer that connects rounds. A shared theme/story where minigames are chapters.

---

### C.17 Story / adventure

**Audience.** 8–16, players who like narrative, friend groups (chaptered "escape" stories).

**Why it works on Roblox.** Chaptered stories with NPC dialog, simple puzzles and a chase finale are memorable and streamable. Roblox "story games" are usually 15–30 minute linear runs with choices.

**Core loop.** `chapter scene → dialog → task/puzzle → threat/chase → choice → next chapter`.

**Meta loop.** Endings collection, badges, alternate paths, new chapters as updates.

**Key systems.** A server-driven cutscene/dialog sequencer (data tables of `{speaker, line, camera, wait}`), group voting on choices, triggers and set-pieces, checkpoints per chapter. Use `TeleportService` between chapter places if they are large.

**Progression math.** Minimal. Story currency for cosmetics or revives.

**Monetization.** Revives/skips, perks (extra life), cosmetic roles, private servers. Low lifetime value because content is consumed once.

**Retention.** Weak. Rely on new chapters and multiple endings.

**MVP vs full.** *MVP:* 1 chapter (15 min), 3 set-pieces, 2 endings. 3 weeks. *Full:* 5+ chapters, voiced lines (official text-to-speech tutorial exists), cinematic camera.

**Failure modes.** Unskippable dialog, a broken sequence when a player leaves, content gone in a day.

**Original twists.** A story whose cast is generated from the players. A procedural "campfire tale" (AI-free, template-driven). A story layered on another genre (a tycoon with a narrative campaign).

---

### C.18 Puzzle

**Audience.** Niche on Roblox, 10+ and older players. Escape-room fans with friends.

**Why it works on Roblox.** Co-op escape rooms and physics puzzles thrive with friends talking. Solo logic puzzles are weaker on the platform.

**Core loop.** `observe → hypothesize → manipulate (levers, codes, objects) → solve → unlock next room`.

**Meta loop.** Room/level packs, speed rankings, star ratings.

**Key systems.** A server-authoritative puzzle state (`{puzzleId, stateTable}`), ProximityPrompts and ClickDetectors, a hint system with timers, procedural variants (randomize codes per server so walkthroughs don't spoil).

**Progression math.** Difficulty by step count and red herrings. Hints cost soft currency.

**Monetization.** Hint packs, room packs, cosmetics. Low.

**Retention.** Weekly rooms, randomized solutions, leaderboards.

**MVP vs full.** *MVP:* 3 rooms, 9 puzzles, hints. 1–2 weeks. *Full:* 30 rooms, co-op-only puzzles.

**Failure modes.** Pixel hunting, solutions spoiled online, no co-op role split.

**Original twists.** Asymmetric co-op (only one player sees the code). Puzzle as a layer inside other genres (puzzle doors in a horror run, merge puzzles in an incremental).

---

### C.19 Sports

**Audience.** 9–18, sports fans, competitive teams. Official examples are football and soccer games.

**Why it works on Roblox.** Team play and anime-sports stylization (special moves) make sports flashy. The official sports playbook says players are driven by competition, progression and the desire to win.

**Core loop.** `queue → team match (3–6 min) → score → result → XP/coins → abilities/styles`.

**Meta loop.** Style/ability gacha (anime-sports pattern), ranked, cosmetics, clubs.

**Key systems.** Ball physics: network ownership hands off to the nearest controlling player for responsiveness, with the server arbitrating possession (a `possessor` attribute) and capping kick velocity. Abilities as moves with cooldowns. Positions/teams. Goal detection on the server.

**Progression math.** Ability rarity weights, upgrade costs `c0 * 1.5^l`, and ELO for ranked.

**Monetization.** Abilities/styles (odds disclosed if random), cosmetics, passes. Rewarded video (official): post-match earnings boost, store currency reward, rematch rescue, pre-game edge lasting one match. 15%+ opt-in, 3+ views/day.

**Retention.** Ranked seasons, new abilities, clubs, tournaments.

**MVP vs full.** *MVP:* 1 field, 3v3, ball logic, 4 abilities. 4 weeks. *Full:* modes, ranked, many abilities.

**Failure modes.** Ball desync/teleporting, stacked teams, empty queues.

**Original twists.** Invented sports (zero-gravity ball, mount-back polo). Sports × pets (your pet is the player).

---

### C.20 Incremental / merge

**Audience.** Idle players, players who love optimizing, all ages.

**Why it works on Roblox.** Pure number growth, playable AFK. RNG "aura/roll" incrementals (Sol's RNG is officially cited for its rewarded-video quick-roll trial) are a big Roblox sub-genre.

**Core loop (merge).**
```
buy tier-1 item ─► place on grid ─► merge 2 equal ─► tier+1 ─► produces more income
     ▲                                                              │
     └────────────────────── income ◄───────────────────────────────┘
```
**Core loop (roll):** `roll (luck-weighted) → keep best aura → luck upgrades → roll faster`.

**Meta loop.** Prestige layers (2–3 nested resets, each with its own currency and upgrade tree), achievements, offline earnings.

**Key systems.** Pure server math on a grid of item ids, offline calc from timestamps, large-number handling (doubles go to about 1.8e308; past that, use a mantissa/exponent "BigNum" or log values). Number formatting (K, M, B, T, aa…).

**Progression math.** Merge value: tier k worth `2^k` (or `2.2^k` to reward merging). Buy cost of tier 1 rises per purchase `c(n) = c0 * 1.07^n`. Auto-merge unlock. Prestige currency `P = floor((lifetimeEarnings / 1e6)^0.5)`, multiplier `1 + 0.02*P` (classic idle square-root scaling). Rolls: chance of a 1-in-N aura with luck L is `L/N`, so expected rolls ≈ N/L.

**Monetization.** Auto-merge/auto-roll pass, offline cap extension, 2× income, luck potions (disclosed), skins. Rewarded video: doubled welcome-back, timed automation.

**Retention.** Offline earnings, prestige milestones, rare roll announcements across the server (social brag), events.

**MVP vs full.** *MVP:* 1 grid, 15 tiers, 1 prestige layer, offline earnings. 1 week. *Full:* 3 prestige layers, collections, events.

**Failure modes.** Dead periods where nothing is affordable, number overflow, no visible world for others to see (add a world representation).

**Original twists.** Merge in 3D space where merged objects physically combine. Incremental where *other players* are a resource (co-op merges). Rolls that produce usable items in another loop.

---

### C.21 Pet collection / trading

**Audience.** 8–15 collectors and traders. Players who value rarity and status.

**Why it works on Roblox.** Pets are visible status. Trading creates a player economy (values tracked by fan sites) and a reason to return long after the core content runs out. Long-running pet roleplay/raising games and pet simulators show trading can keep a game alive for years.

**Core loop.** `earn currency (care tasks/minigames) → hatch/buy pets → raise/age/level → trade up → show off`.

**Meta loop.** Limited/retired pets (scarcity), "neon/mega" fusion tiers (combine 4 → 1 better), seasonal eggs, value lists.

**Key systems.**
- *Pet identity:* each pet is a uuid with immutable origin data (`{uuid, species, hatchedAt, edition, traits}`).
- *Trading:* a two-sided server trade session, both confirm, a short countdown, then **atomic transfer**. Use a single DataStore `UpdateAsync` per player plus a trade journal, or a session-locked ProfileStore and transfer only when both profiles are loaded on the same server. Log every trade. Add anti-scam UI (show values, a change-reset countdown).
- *Dupe prevention:* never grant before saving, uuids are unique, and a server lock during trade. Re-validate both inventories at commit.
- *Pet follow:* rendered client-side for performance.

**Progression math.** Egg tiers ×3–5 price. Fusion: 4 of tier t → 1 of t+1, so the value implied is ≥4×. Retirement removes the supply of limited pets.

**Monetization.** Premium eggs (odds disclosed), potions (ride, fly), pet storage, cosmetic accessories, trading license (unlock trading after X minutes or a small purchase to deter alt farms; careful with fairness).

**Retention.** Limited-time eggs, retirements, trading community, pet care tasks (light daily needs).

**MVP vs full.** *MVP:* 2 eggs, 12 pets, leveling, fusion, secure trading. 3 weeks (trading safety is the hard part). *Full:* 100s of pets, events, homes, minigames.

**Failure modes.** Dupe bugs (they destroy the economy instantly), scams, inflation from free pets, unclear value.

**Original twists.** Pets with genetics and breeding (traits inherit). Pets that age into jobs. A "lend" system (temporary trades). Trading via an auction house with sinks (listing fees).

---

## Part D — Hybrid trends and picking a genre

### D.1 Hybrid patterns that worked (2024–2026)

Trend coverage for 2025–2026 keeps pointing at **hybrids**: familiar loops combined so each covers the other's weakness.

| Hybrid | Loop A gives | Loop B gives | Example pattern |
|---|---|---|---|
| Idle growth × tycoon × social theft | offline progress, return visits | visible base, rivalry | garden games with night stealing |
| Tycoon × tag/raid | passive income | action, stories | steal-base games (8 bases + central conveyor) |
| Survival × horror × co-op | systems, planning | tension, shareability | forest night-survival runs |
| Simulator × RNG roll | number growth | gacha thrill each roll | aura/roll games |
| Fishing × collection × exploration | relaxing minigame | bestiary, many paths | fishing games with "more than one end goal" |
| Fighting × anime collection | mastery | character unlocks | battlegrounds |
| TD × gacha × meme theme | strategy | collection, virality | meme tower defense |
| Obby × escape story | easy content | narrative hook | "escape the X" obbies |

**Rule of thumb:** combine a **retention loop** (offline growth, collection, prestige) with an **excitement loop** (theft, chase, gacha reveal, event), and make both **visible to other players**.

### D.2 Choosing a genre for a solo/small bot-made game

Score each candidate (1–5) and multiply: `Fit = BotFit × MonetizationFit × RetentionPotential / (ArtDemand × NetcodeRisk)`. Then sanity-check scope.

**Strong candidates for a bot:** incremental/merge, simulator, garden/idle, tycoon, steal/raid, fishing, tower defense, obby. All are systems- and math-heavy, tolerate simple low-poly or primitive art, and need little latency-sensitive netcode.

**Avoid as a first project** unless the twist depends on it: fighting, FPS, racing (feel and netcode), fashion, roleplay, anime RPG (art and content volume), story (consumed once).

**Scope realism checklist (MVP must satisfy all):**
1. A single place, at most one lobby-to-match teleport.
2. The core loop is playable in under 60 s from join.
3. At most about 25 unique art assets (primitives + recolors + a few meshes).
4. At most 1 meta loop (rebirth OR collection OR ranked).
5. Data model fits in one ProfileStore profile under about 100 KB.
6. 2–4 game passes + 2–4 devproducts + 1 rewarded-video placement.
7. 1 recurring content mechanism that needs no new art (rotating shop, weekly event modifier, weather).
8. Mobile UI tested at phone resolution.

**Weekly update cadence after launch:** new zone/tier (numbers), event (modifier + 3 recolored items), quality-of-life fix. Top live games refresh constantly, and the official liveops docs emphasize planned content updates.

### D.3 Twist generator (to stay original)

Take a proven loop and change **exactly one or two** of: the *verb* (click → tune, grow → brew, steal → borrow), the *setting* (garden → reef → asteroid), the *social rule* (compete → co-op meter), the *time model* (session → real-time offline), or the *ownership model* (personal → shared server asset). Then check the result against the originality list in TL;DR rule 15.

---

## Sources

Official Roblox docs (local mirror `reference/creator-docs/content/en-us`):
- `production/game-design/core-loops.md`, `balance-virtual-economies.md`, `monetization-foundations.md`, `liveops-essentials.md`, `subscription-design.md`
- `production/monetization/paid-random-items.md` (odds disclosure), `developer-exchange.md` (DevEx $0.0038 / $0.0054), `price-optimization.md`, `regional-pricing.md`, `subscriptions.md`
- `production/rewarded-video-guides.md` and `production/promotion/rewarded-video-playbooks/{incremental-sim,tycoon,obby,survival,shooter,rpg,sports}.md` (opt-in/frequency benchmarks, placement strategies)
- `production/ad-placements/{growagarden,brookhaven,sols}.md`
- `production/roblox-user-base.md`
- `tutorials/curriculums/gameplay-scripting/detect-hits.md`, `implement-blasters.md` (laser-tag hit validation)
- `tutorials/use-case-tutorials/lighting/create-flickering-lights.md`, `audio/add-3D-audio.md`, `data-storage/save-player-data.md`
- `reference/engine/classes/PolicyService.yaml`, `AdService.yaml`, `WorldRoot.yaml`

Web (accessed 2026-11-05; third-party figures are directional):
- Naavik, "Predicting the next big hits on Roblox": https://naavik.co/digest/predicting-the-next-big-hits-on-roblox/ (search summary only; fetch blocked)
- RoLearn, Grow a Garden CCU analysis / case study: https://rolearn.dev/insights/grow-a-garden-ccu-record-analysis, https://rolearn.dev/case-studies/idle-garden-zero-to-20m-ccu
- GamesBeat interview with Grow a Garden's creator: https://gamesbeat.com/?p=305182
- gam3s.gg, "Grow A Garden Hits Over 8 Million CCUs": https://gam3s.gg/news/grow-a-garden-hits-over-8m-users
- Pocket Tactics, Grow a Garden mutations: https://www.pockettactics.com/grow-a-garden-mutations
- PocketGamer.biz, Steal a Brainrot first to 25M CCU: https://www.pocketgamer.biz/robloxs-steal-a-brainrot-becomes-first-game-to-surpass-25m-concurrent-players
- PocketGamer.biz, Roblox peak 47.4M: https://www.pocketgamer.biz/robloxs-peak-concurrent-user-count-hits-record-474m-as-steal-a-brainrot-and-grow-a-garden-compete
- Steal a Brainrot (Wikipedia, via search summary): https://en.wikipedia.org/wiki/Steal_a_Brainrot
- RoWatcher, brainrot trend CCU: https://rowatcher.com/news/is-the-brainrot-trend-dying-what-ccu-data-from-three-top-games-reveals
- games.gg, 99 Nights in the Forest overview: https://games.gg/pt-BR/99-nights-in-the-forest/
- shapes.inc fan wiki on Doors: https://shapes.inc/fandom/doors
- Roblox DevForum, Creator Spotlight on Fisch: https://devforum.roblox.com/t/creator-spotlight-woozynate-makes-a-splash-with-fisch/3269481
- Roblox Wiki (Fandom), Fisch: https://roblox.fandom.com/wiki/Fisching/Fisch
- Varsity, Dress to Impress review: https://varsity.co.uk/fashion/28397
- RoWatcher, Dress to Impress: https://rowatcher.com/news/dress-to-impress-how-a-teen-developer-s-fashion-game-hit-9-7-billion-visits
- RoWatcher, Brookhaven 80B visits: https://rowatcher.com/news/brookhaven-rp-at-80-billion-visits-inside-roblox-s-unstoppable-digital-dollhouse
- mapshot.gg, Voldex acquires Brookhaven: https://mapshot.gg/news/voldex-acquires-brookhaven-how-robloxs-most-visited-game-could-see-a-monetization-overhaul
- RoWatcher, RIVALS: https://rowatcher.com/news/rivals-how-roblox-s-top-shooter-built-a-nearly-million-player-empire
- RoLearn, RIVALS case study: https://rolearn.dev/case-studies/fps-rivals-competitive-shooter-growth
- noping.com / games.gg, Strongest Battlegrounds combat guides: https://noping.com/blog/the-strongest-battlegrounds-tsb-in-roblox
- Roblox DevForum hitbox threads: https://devforum.roblox.com/t/client-side-or-server-side-hitboxes/3089136, https://devforum.roblox.com/t/what-system-do-big-battlegrounds-games-use-for-hitboxes/3972418, https://devforum.roblox.com/t/securing-client-side-hit-detection-in-sword-combat/2961187
- Roblox DevForum, FastCast: https://devforum.roblox.com/t/making-a-combat-game-with-ranged-weapons-fastcast-may-be-the-module-for-you/133474
- Roblox DevForum, chassis types: https://devforum.roblox.com/t/tank-chassis-constraint-chassis/59923
- Roblox DevForum, difficulty chart guide: https://devforum.roblox.com/t/the-guide-to-making-a-difficulty-chartpart-1/1135152
- creation.dev obby design guide: https://www.creation.dev/blog/roblox-obby-design-guide
- TD wave scaling examples: https://roblox-tower-defense-wave-script.pages.dev, https://west-games.com/tower-defense-wave-hp-scaling-calculator/, https://devforum.roblox.com/t/organizing-tower-defense-wave-data/3266290
- Screenwise, Pet Simulator 99 parent guide: https://screenwiseapp.com/guides/parent-s-guide-to-roblox-pet-simulator-99
- creation.dev simulator guide: https://www.creation.dev/blog/roblox-simulator-game-guide
- DevForum, rewarded video expansion: https://devforum.roblox.com/t/more-creators-can-now-use-rewarded-video-ads/3838678
- Trend roundups (low confidence): https://kitsblox.com/blog/popular-roblox-game-genres-2026, https://rolearn.dev/trend-reports/emerging-roblox-game-genres-q2-2026

Note: in this session, direct fetches of naavik.co, wikipedia.org and devforum.roblox.com were blocked by the network allowlist, so claims from those sites rely on search-result summaries. Deconstructor of Fun, RoMonitor and Rolimons pages were not retrieved, and no figures from them are used.
