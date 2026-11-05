# 13 — Live Ops, Community, Localization, Accessibility and Young-Audience Design

> Scope: what happens **after** a Roblox game ships. That means running updates and events, the config and feature-flag systems, codes, admin and moderation tooling, server restarts, data migration, community channels, player support, in-game social features, localization, accessibility, and designing for kids under Roblox's 2026 age-based account system. Monetization, launch marketing and analytics are covered in other chapters and are only cross-referenced here.
>
> Verified against the local creator-docs snapshot (`reference/creator-docs/content/en-us`) and Roblox newsroom/DevForum posts as of **2026-11-05**. Where something comes from community practice rather than official docs, this chapter says so.

---

## TL;DR rules for the bot

1. **Build every live-tunable value behind `ConfigService`** (Roblox's official remote-config and feature-flag service, also used for A/B experiments). Call it on the **server only**, keep hard-coded fallback defaults, wrap the first `GetConfigAsync()` in `pcall`, and refresh snapshots between rounds rather than mid-match.
2. **Ship content dark, then flip it on.** Publish event code days early behind a boolean config (`event_halloween_enabled`) plus start/end timestamps. Do not publish a new place version at the moment an event goes live.
3. **Use the built-in server restart for updates.** Creator Hub → Server management → **Restart Servers**, with "Restart only servers with outdated versions" and a delay of 1–60 minutes. Roblox now teleports players to updated servers on its own. Listen to `game.ServerRestartScheduled` to show a countdown and flush saves. A custom reserved-server "soft shutdown" is only a fallback.
4. **Never trust the client** for codes, daily rewards, admin commands or event claims. Do all validation, time checks (`os.time()` on the server, in UTC) and writes on the server, with atomic `UpdateAsync`.
5. **Version your player data** (`data.version = N`) and migrate it in one place when it loads. Take an Open Cloud **data store snapshot** before any update that changes the save format. Old versions are kept for 30 days.
6. **Admin commands go through `TextChatCommand`.** Parsing `Player.Chatted` or `TextChatMessage.Text` stops working under platform-integrated chat, which becomes mandatory in **May 2027**. Check permissions on the server for every command, never let a moderator target someone of equal or higher rank, filter every broadcast string, and log every action.
7. **No external links or handles inside the game.** Social links (Discord, X, YouTube…) may only appear on the game's details page, and only age-checked users aged 16+ can see them. In-game text may say "links on our game page" and nothing more specific.
8. **Codes:** normalize the input (trim, uppercase), rate-limit attempts, record redemptions atomically per user, and keep the code list server-side. Never put the list in ReplicatedStorage.
9. **Daily rewards:** use UTC day indexes, make claims idempotent per day, show the "next reward in" timer, and be forgiving: offer a streak freeze or a one-day grace period, and use no shame or false-urgency copy.
10. **Social prompts:** check `SocialService:CanSendGameInviteAsync()` before `PromptGameInvite()`. Send Experience Notifications only for personalized, actionable moments (13+, opt-in, at least 100 visits). Update announcements are capped at 60 characters, once every three days.
11. **Localize from day one.** Keep `AutoLocalize` on, turn on Automatic Text Capture and "Use Translated Content", and send **keys and arguments** from server to client rather than finished English sentences. Never concatenate translated fragments; use `{param}` placeholders. Turn `AutoLocalize` off for names and player-made text.
12. **Accessibility is a checklist, not an add-on.** Respect `GuiService.PreferredTextSize` (avoid `TextScaled` on body text), `PreferredTransparency` and `ReducedMotionEnabled`. Never rely on color or sound alone, add captions for important audio, support remapping, and keep touch targets at least 44 px.
13. **Design for Roblox Kids (5–8) and Select (9–15) first.** Only Minimal/Mild-rated games reach Kids, and Moderate reaches Select. To reach under-16s you need a verified creator, 2FA, a completed questionnaire, a fee or Plus/Premium subscription, and 250 engaged-player plays in 60 days. Write for a second-grade reading level with icons, and add no open-ended social features for young players.
14. **Gate features by policy** with `PolicyService:GetPolicyInfoForPlayerAsync()`: paid random items, paid trading, content sharing, ads, endless feeds. Gate voice-dependent mechanics with `VoiceChatService:IsVoiceEnabledForUserIdAsync()`, and always provide a non-voice path.
15. **Do not use Roblox Connect or call-invite APIs.** Connect was shut down on 2026-07-15, and `CanSendCallInviteAsync` returns false. Players use Party / Party Voice instead; read party membership with `Player.PartyId` and `SocialService:GetPartyAsync()`.

---

## 1. Live operations

### 1.1 Why live ops matters on Roblox

Roblox discovery strongly rewards **retention and session engagement**, and players expect a game they love to keep changing. Top games run on a predictable rhythm. Players learn when updates drop, often a fixed weekday and time, and creators and YouTubers plan videos around that schedule. "Update day" spikes in concurrent players feed the recommendation system, which in turn feeds more update-day spikes.

### 1.2 Update cadence: weekly vs biweekly vs monthly

| Cadence | Who it suits | Pros | Cons |
|---|---|---|---|
| **Weekly** (same weekday and hour, often Friday or Saturday afternoon US time) | Simulators, tycoons, "brainrot"/trend games, games with a small team that has templated content | Constant reasons to return; strong algorithm signal; creators make weekly videos | Burnout; QA debt; content dilution; every update risks data bugs |
| **Biweekly** | Most small studios, including a solo dev assisted by Claude | Room for one real feature plus polish; sustainable | Needs filler in off weeks (a mini event, a code, a leaderboard reset) |
| **Monthly, or "seasons" of 4–8 weeks** | Story, RPG, competitive and horror games | Large hype moments; trailers are worth making | Players churn in the gaps without live events |

Recommended default for bot-built games: a **biweekly content update plus a weekly "pulse"**. The pulse is something that needs no new place version: a rotating config-driven event, a new code, a featured quest set, or a leaderboard season reset. Announce the schedule on the game page ("Updates every other Saturday 10 AM ET") and keep to it.

Rules for update timing:
- Update when players are **online but not at peak**. Restart servers with a delay so nobody loses a round. Weekend afternoons in US Eastern time match the largest overlap of US, EU and LATAM players. APAC is a growing share of DAU, so rotate event start times or keep events running long enough (at least 48 hours) to span time zones.
- **Avoid Friday-night deploys with nobody on call.** If a data bug ships, you need someone to roll back within minutes.
- For Roblox Kids and Select audiences (section 7), check the publishing requirements. Updating an all-ages game requires the creator to meet the fee or subscription requirement *at the time of the update*.

### 1.3 Content pipeline

A repeatable pipeline is what makes a cadence sustainable:

1. **Backlog**, tagged by type: content (maps, items, pets), systems, events, QoL, bugs.
2. **Templates.** Every new item, pet or zone is data (a ModuleScript row or a config JSON entry) plus assets. The core code should never need to change to add the 41st pet.
3. **Staging place.** Keep a separate "-Dev" or "-Staging" game. Test there with Studio Team Test and private servers. Configs can be published from Studio to another game ("Publish As"), which lets you sync staging configs to live.
4. **Feature flags.** New systems ship with `feature_x_enabled = false` and are turned on through config after deploy.
5. **Release checklist:** bump the game version string; write the update log; take a data store snapshot if the save format changed; run a smoke test in a private server; publish; restart outdated servers with a 5–15 minute delay; watch error and analytics dashboards for 30 minutes; post the announcement.
6. **Post-release:** hotfix window, feedback triage (section 3), and patch notes for fixes.

### 1.4 Remote config and feature flags: `ConfigService` (official, 2025–26)

Roblox **does** have an official remote-config service: **Experience Configs**, exposed as `ConfigService` and `ConfigSnapshot`. It also powers **Experiments** (A/B tests). Key facts from the docs:

- Key/value pairs whose value is a **string, number, boolean or JSON object**. Strings and JSON can be up to 100,000 characters, and a game can have up to **1,000 active configs**.
- Configs are managed on Creator Hub → **Configs**, or in Studio via **File → Open Configs**. Changes are **staged** first (visible in Studio play sessions), then you either **Publish now** (live in about 15 s to 1 min) or **Publish over 15 min** for a gradual rollout. A **History** page supports diffs and restore.
- **Server-only.** Calling it from the client throws an error.
- `ConfigService:GetConfigAsync()` returns a global snapshot. `ConfigService:GetConfigForPlayerAsync(player)` applies **targeting**: country, language, new vs returning players, traffic source, tenure, payer status, activity, engagement, and platform spender or activity status. You can define up to 100 conditions per game and 20 per key, and rules are evaluated top-down globally.
- Snapshots do **not** update on their own. Listen to `snapshot.UpdateAvailable`, call `snapshot:Refresh()` when it is safe (between rounds), then react with `snapshot:GetValueChangedSignal(key)`.
- `GetValue(key)` returns `nil` for a missing key. If configs have *never* loaded, `GetConfigAsync()` throws. If the connection drops later, you get the last known values.
- Testing: `ConfigService:SetTestingValue(key, value)` and `ClearTestingValue(key)` affect only the current server, which is useful for admin "try this on this server" commands.

**Pattern: a typed config wrapper with defaults**

```lua
--!strict
-- ServerScriptService/LiveConfig.lua (ModuleScript)
local ConfigService = game:GetService("ConfigService")

local DEFAULTS = {
	event_halloween_enabled = false,
	event_halloween_start = 0,      -- unix seconds (UTC)
	event_halloween_end = 0,
	coin_multiplier = 1,
	shop_rotation_seed = 1,
	motd = "",                      -- localization KEY, not raw text
	codes = {},                     -- JSON: { CODE = {reward=..., expires=...} }
}

local LiveConfig = {}
local snapshot: ConfigSnapshot? = nil

local function load()
	local ok, result = pcall(function()
		return ConfigService:GetConfigAsync()
	end)
	if ok then
		snapshot = result
		result.UpdateAvailable:Connect(function()
			-- Refreshing here applies changes immediately. For competitive
			-- games, set a flag instead and call Refresh() between rounds.
			result:Refresh()
		end)
	else
		warn("[LiveConfig] using defaults:", result)
		task.delay(30, load) -- retry later
	end
end
load()

function LiveConfig.get(key: string): any
	if snapshot then
		local v = snapshot:GetValue(key)
		if v ~= nil then
			return v
		end
	end
	return (DEFAULTS :: any)[key]
end

function LiveConfig.onChanged(key: string, fn: (any) -> ())
	task.spawn(function()
		while not snapshot do task.wait(1) end
		(snapshot :: ConfigSnapshot):GetValueChangedSignal(key):Connect(fn)
	end)
end

function LiveConfig.isEventLive(prefix: string): boolean
	local now = os.time()
	return LiveConfig.get(prefix .. "_enabled") == true
		and now >= (LiveConfig.get(prefix .. "_start") or 0)
		and now < (LiveConfig.get(prefix .. "_end") or 0)
end

return LiveConfig
```

Fallbacks if configs are unavailable, or for data that is not "config":
- **DataStore** suits durable values you also want to write from code, such as a global code-use counter or ban notes. Avoid polling it on every server at high frequency. Read it on start plus every few minutes, or broadcast changes with `MessagingService`.
- **MemoryStore** (`GetHashMap`, `GetSortedMap`, `GetQueue`) suits fast, **ephemeral** cross-server state: live event phase, server browser, matchmaking queues, global boss HP. Data expires after its TTL (at most 45 days), so never use it as the source of truth for anything players own.
- **MessagingService** pushes "refresh now" signals or announcements across servers.

Replicate to clients only the values they need, through attributes on `ReplicatedStorage` or a RemoteEvent. Never send the whole config, because it may contain unreleased codes.

### 1.5 Seasonal and limited-time events

The event calendar that works on Roblox: **Halloween** (all of October), **Winter/Christmas** (December into early January), **Lunar New Year**, **Easter/Spring**, **Summer** (late June to August, school holidays in the US and EU), **Back-to-School** and **anniversaries**. Platform-wide events such as The Hunt are opt-in programs run by Roblox, so watch the DevForum for applications.

Event design checklist:
- **Event currency** that expires or converts when the event ends, plus a time-limited shop. Keep event items cosmetic or side-grade so returning players are not walled off.
- **Event quests**, daily and total, that work for a 15-minute session.
- **A visible end date in UTC, shown as a countdown.** Show a "Returning next year?" style tease only if it is true. Do not use fake scarcity.
- **Experience Events listing.** Creator Hub → Engagement → **Events & Updates** creates an event page that players can RSVP to (`SocialService:PromptRsvpToEventAsync`, `GetUpcomingExperienceEventsAsync`) and that appears on the game page. Use a unique event thumbnail.
- **Data hygiene.** Store event progress under a season key (`events.halloween2026 = {...}`) so next year starts clean. Retire old data stores after the event; deletion has a 30-day restore buffer.
- **Admin-friendly toggles**: start, end and multipliers live in config.

### 1.6 Battle pass / season pass

A season pass is a progression track (usually 30–50 tiers over 4–8 weeks) with a **free track** and a **premium track**, unlocked by a game pass for that season or by a developer product. Pricing and Robux design belong to the monetization chapter; the operational rules are:

- **Season ID in data** (`pass.season = 7`). When the season changes, archive or convert the old progress and grant any unclaimed free rewards automatically. Never silently delete them.
- **XP sources** come from normal play, plus daily and weekly quests (1.8). Tune XP per tier through config so you can rescue a season that is too grindy without publishing.
- **Catch-up mechanics.** XP boosts in the last two weeks, or quests that bank. This makes late joiners feel the purchase is still worth it.
- **Premium track:** a developer product per season is cleaner than a game pass, because game passes are permanent. If you use a game pass, name it per season and do not reuse it.
- **Respect young players.** Show exactly what the premium track contains before purchase, and add no "buy tiers" pressure popups after every match. See 7.4.

### 1.7 Daily rewards, streaks and login calendars

Two common shapes:
- **Streak ladder:** day 1→7 with escalating rewards that loop. Missing a day resets the streak, unless a freeze is available.
- **Login calendar:** a monthly grid of 28–31 cells where each login claims the next cell. Missed days do not reset it; the player simply ends the month with fewer cells. This is kinder for kids and easier to understand.

Rules:
- Use **UTC day boundaries** (`os.time() // 86400`), and show "next reward in hh:mm" on the client using a server-provided `nextResetUnix`.
- Make claims **idempotent** with `UpdateAsync`, which works across servers and protects against double-click races.
- **Grace:** one free "streak freeze" per week, or let a missed day be recovered by playing longer the next day. Avoid FOMO messages ("You'll LOSE EVERYTHING!"). Experience Notification guidelines explicitly ban false time pressure, and the same spirit applies in-game.
- Roblox's open DevForum guidance is that you should not reward likes or favorites. Rewarding **community membership** is common practice: an extra daily bonus for members of your Roblox community (group), checked with `player:IsInGroupAsync(groupId)`.

**Luau: daily reward streak system (server)**

```lua
--!strict
-- ServerScriptService/DailyRewards.server.lua
-- Requires ReplicatedStorage.Remotes.DailyGetStatus (RemoteFunction)
-- and ReplicatedStorage.Remotes.DailyClaim (RemoteFunction).
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local STORE = DataStoreService:GetDataStore("DailyRewards_v1")
local DAY = 86400
local MAX_FREEZES = 2

-- 7-day ladder that loops. Values are data, so they can move to ConfigService JSON.
local LADDER = {
	{ coins = 100 }, { coins = 150 }, { coins = 200 }, { coins = 250 },
	{ coins = 300 }, { coins = 400 }, { coins = 500, crate = "WeeklyCrate" },
}

type State = { lastDay: number?, streak: number, best: number, freezes: number, version: number }

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local getStatusRF = remotes:WaitForChild("DailyGetStatus") :: RemoteFunction
local claimRF = remotes:WaitForChild("DailyClaim") :: RemoteFunction

local cache: { [number]: State } = {}
local busy: { [number]: boolean } = {}

local function today(): number
	return os.time() // DAY
end

local function fresh(): State
	return { lastDay = nil, streak = 0, best = 0, freezes = 1, version = 1 }
end

-- Pure function: what would claiming today do?
local function evaluate(s: State, day: number): (boolean, number, boolean)
	-- returns canClaim, nextStreak, usesFreeze
	if s.lastDay == day then
		return false, s.streak, false
	elseif s.lastDay == day - 1 then
		return true, s.streak + 1, false
	elseif s.lastDay ~= nil and day - s.lastDay == 2 and s.freezes > 0 then
		return true, s.streak + 1, true
	else
		return true, 1, false
	end
end

local function rewardFor(streak: number)
	return LADDER[((streak - 1) % #LADDER) + 1]
end

-- Hook into your real economy/profile system here.
local function grantReward(player: Player, reward: { [string]: any })
	local leaderstats = player:FindFirstChild("leaderstats")
	local coins = leaderstats and leaderstats:FindFirstChild("Coins")
	if coins and reward.coins then
		(coins :: IntValue).Value += reward.coins
	end
	-- reward.crate -> inventory system, etc.
end

local function load(player: Player)
	local ok, data = pcall(function()
		return STORE:GetAsync("u_" .. player.UserId)
	end)
	cache[player.UserId] = if ok and type(data) == "table" then data :: any else fresh()
end

local function status(player: Player)
	local s = cache[player.UserId]
	if not s then return nil end
	local day = today()
	local canClaim, nextStreak = evaluate(s, day)
	return {
		canClaim = canClaim,
		streak = s.streak,
		nextStreak = nextStreak,
		nextReward = rewardFor(nextStreak),
		freezes = s.freezes,
		nextResetUnix = (day + 1) * DAY, -- client renders the countdown
	}
end

getStatusRF.OnServerInvoke = function(player)
	return status(player)
end

claimRF.OnServerInvoke = function(player)
	local uid = player.UserId
	if busy[uid] or not cache[uid] then
		return { ok = false, reason = "BUSY" }
	end
	busy[uid] = true

	local day = today()
	local granted: { [string]: any }? = nil
	local newState: State? = nil

	local ok, err = pcall(function()
		STORE:UpdateAsync("u_" .. uid, function(old)
			local s: State = if type(old) == "table" then old else fresh()
			local canClaim, nextStreak, usesFreeze = evaluate(s, day)
			if not canClaim then
				granted = nil
				return nil -- abort write; already claimed (maybe on another server)
			end
			-- Weekly freeze refill on streak milestones
			if usesFreeze then s.freezes -= 1 end
			if nextStreak % 7 == 0 then s.freezes = math.min(MAX_FREEZES, s.freezes + 1) end
			s.streak = nextStreak
			s.best = math.max(s.best, nextStreak)
			s.lastDay = day
			granted = rewardFor(nextStreak)
			newState = s
			return s
		end)
	end)

	busy[uid] = nil
	if not ok then
		warn("[Daily] claim failed", uid, err)
		return { ok = false, reason = "ERROR" }
	end
	if not granted then
		return { ok = false, reason = "ALREADY_CLAIMED", status = status(player) }
	end
	cache[uid] = newState :: State
	-- NOTE: in production, record the claim *and* grant the reward inside the
	-- same session-locked profile save so they can never diverge.
	grantReward(player, granted :: any)
	return { ok = true, reward = granted, status = status(player) }
end

Players.PlayerAdded:Connect(load)
for _, p in Players:GetPlayers() do task.spawn(load, p) end
Players.PlayerRemoving:Connect(function(p)
	cache[p.UserId] = nil
	busy[p.UserId] = nil
end)
```

Client notes: render the 7 cells, highlight `nextStreak`, show `nextResetUnix - os.time()` as a countdown that refreshes every second (the client clock is fine for *display*), and call `DailyClaim` from a big, obvious button. Auto-open the panel once per day on join, and only after the loading screen.

### 1.8 Quest rotation

- Use **daily** quests (3, rerolling at UTC midnight), **weekly** quests (5–7, Monday 00:00 UTC) and **event** quests.
- Make rotation **deterministic** so every server agrees without storage. Seed with the day index: `Random.new(dayIndex * 7919 + configSeed)` picks from a quest pool, and players can be offset by `UserId` for variety.
- Store progress as `{questId, dayIndex, progress, claimed}`. When `dayIndex` changes, discard it.
- Give each player one free reroll per day. Write quests for a single short session, and include social ones ("Play with a friend", which you can verify with `player:IsFriendsWith`, or check that party members share a server).

### 1.9 Codes system (X/Twitter, Discord and YouTube codes)

Codes are a cheap weekly pulse: post a code with each update, at like or follower milestones on social media, or in creator videos. Operational rules:
- Codes live **only on the server**: in config JSON (so they can be added live without publishing) and/or in a server-side ModuleScript in `ServerScriptService` or `ServerStorage`.
- Every code has `reward`, optional `startsAt` and `expiresAt`, an optional global `maxUses` (for limited codes), and optionally `minAccountAgeDays` to deter alt farming for valuable codes.
- Redemption is **once per user**, recorded atomically. Normalize input to uppercase with whitespace stripped. Rate-limit attempts so codes cannot be brute-forced.
- In-game copy may say: "Codes are posted on our community. Links on our game page." Do **not** write a Discord invite or X handle in the game (section 2.3).
- Keep a **public list of active codes** on the game description or an in-game "Codes" panel with hints, and remove expired codes promptly. Third-party "codes" websites will scrape them anyway, and that is free marketing.

**Luau: secure codes redemption (server)**

```lua
--!strict
-- ServerScriptService/Codes.server.lua
-- Remote: ReplicatedStorage.Remotes.RedeemCode (RemoteFunction) -> returns result key
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local LiveConfig = require(ServerScriptService.LiveConfig)
-- Server-only fallback list (never in ReplicatedStorage):
local STATIC_CODES: { [string]: any } = {
	RELEASE = { reward = { coins = 250 } },
	SPOOKY2026 = {
		reward = { coins = 500, item = "PumpkinHat" },
		expiresAt = DateTime.fromIsoDate("2026-11-10T00:00:00Z").UnixTimestamp,
	},
	FIRST1000 = { reward = { gems = 50 }, maxUses = 1000, minAccountAgeDays = 7 },
}

local RedeemStore = DataStoreService:GetDataStore("CodeRedemptions_v1") -- per user
local UsesStore = DataStoreService:GetDataStore("CodeGlobalUses_v1")     -- per code

local RATE_WINDOW, RATE_MAX = 60, 6
local attempts: { [number]: { number } } = {}
local inFlight: { [number]: boolean } = {}

local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RedeemCode") :: RemoteFunction

local function normalize(raw: any): string?
	if type(raw) ~= "string" or #raw > 40 then return nil end
	local s = string.upper((string.gsub(raw, "%s+", "")))
	if #s < 3 or #s > 32 or not string.match(s, "^[%w_%-]+$") then return nil end
	return s
end

local function rateLimited(uid: number): boolean
	local now = os.clock()
	local list = attempts[uid] or {}
	local kept = {}
	for _, t in list do
		if now - t < RATE_WINDOW then table.insert(kept, t) end
	end
	attempts[uid] = kept
	if #kept >= RATE_MAX then return true end
	table.insert(kept, now)
	return false
end

local function lookup(code: string): any
	local live = LiveConfig.get("codes")
	if type(live) == "table" and live[code] then return live[code] end
	return STATIC_CODES[code]
end

local function grant(player: Player, reward: { [string]: any })
	-- Connect to your profile/economy module. Must run on the server.
	print(("[Codes] grant %s -> %s"):format(player.Name, game:GetService("HttpService"):JSONEncode(reward)))
end

local function reserveGlobal(code: string, maxUses: number, delta: number): boolean
	local reserved = false
	local ok = pcall(function()
		UsesStore:UpdateAsync(code, function(n)
			n = tonumber(n) or 0
			if delta > 0 and n >= maxUses then
				reserved = false
				return nil -- sold out; abort write
			end
			reserved = true
			return math.max(0, n + delta)
		end)
	end)
	return ok and reserved
end

remote.OnServerInvoke = function(player: Player, raw: any): string
	local uid = player.UserId
	if inFlight[uid] then return "BUSY" end
	if rateLimited(uid) then return "RATE_LIMITED" end

	local code = normalize(raw)
	if not code then return "INVALID" end
	local def = lookup(code)
	if not def then return "INVALID" end

	local now = os.time()
	if def.startsAt and now < def.startsAt then return "INVALID" end
	if def.expiresAt and now >= def.expiresAt then return "EXPIRED" end
	if def.minAccountAgeDays and player.AccountAge < def.minAccountAgeDays then
		return "ACCOUNT_TOO_NEW"
	end

	inFlight[uid] = true
	local result = "ERROR"

	local usedGlobal = false
	if def.maxUses then
		if not reserveGlobal(code, def.maxUses, 1) then
			inFlight[uid] = nil
			return "SOLD_OUT"
		end
		usedGlobal = true
	end

	local newlyRedeemed = false
	local ok, err = pcall(function()
		RedeemStore:UpdateAsync("u_" .. uid, function(old)
			local rec = if type(old) == "table" then old else { codes = {} }
			if rec.codes[code] then
				newlyRedeemed = false
				return nil -- already redeemed (possibly on another server)
			end
			rec.codes[code] = now
			newlyRedeemed = true
			return rec
		end)
	end)

	if ok and newlyRedeemed then
		grant(player, def.reward)
		result = "OK"
	elseif ok then
		result = "ALREADY_REDEEMED"
	else
		warn("[Codes] datastore error", err)
		result = "ERROR"
	end

	-- Refund the global slot if this user didn't actually consume it.
	if usedGlobal and result ~= "OK" then
		reserveGlobal(code, def.maxUses, -1)
	end

	inFlight[uid] = nil
	return result -- client maps the key to a localized message
end

Players.PlayerRemoving:Connect(function(p)
	attempts[p.UserId] = nil
	inFlight[p.UserId] = nil
end)
```

Hardening notes: in production, store `codes` inside the same session-locked profile as the currency so recording and granting happen in one save. Log redemptions to analytics with custom events, which also tells you which channel a code came from. Never echo the typed string to other players.

### 1.10 Admin tools and moderation commands

Every live game needs: kick, timed ban, unban, server announcement, teleport to a player (to investigate), a "spectate" or invisible mode, a server-local config override for testing, and an audit log. Also use the **Creator Hub Bans dashboard** (Moderation → Bans), which supports alt-account bans and public versus private reasons. In code, `Players:BanAsync()`, `UnbanAsync()` and `GetBanHistoryAsync()` do the same.

Design rules:
- **Permission levels** come from your Roblox community (group) rank and/or a UserId allowlist, are resolved on the server when the player joins, and are cached. Levels are 0 Player, 1 Moderator, 2 Admin, 3 Owner.
- **Re-check the permission at execution time**, not just in the UI. Clients only ever *request*.
- **No acting on equal or higher rank** (a mod cannot ban an admin).
- **Filter all text** an admin broadcasts, using `TextService:FilterStringAsync` then `GetNonChatStringForBroadcastAsync`. Admin messages are not exempt from filtering.
- **Audit log** every command (who, what, target, when) to a DataStore and/or analytics.
- **Use `TextChatCommand` for chat commands.** With **platform-integrated chat** (opt-in now, required for all games from May 2027), code can no longer read message text, and `Player.Chatted` and `OnIncomingMessage` no longer work for commands. `TextChatCommand.Triggered(textSource, unfilteredText)` still delivers the command text to the server. Set `AutocompleteVisible = false` so normal players do not see admin commands in the autocomplete list.
- Do not fully trust free third-party admin models. Many are backdoored. Write your own small module (below), or audit any you use.

**Luau: admin command module with permission checks**

```lua
--!strict
-- ServerScriptService/Admin/AdminCommands.lua (ModuleScript)
-- Bootstrap: require(script.AdminCommands).init() from a Script.
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local TextService = game:GetService("TextService")
local DataStoreService = game:GetService("DataStoreService")
local ConfigService = game:GetService("ConfigService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LEVEL = { Player = 0, Mod = 1, Admin = 2, Owner = 3 }

local SETTINGS = {
	groupId = 0, -- your Roblox community (group) id; 0 = disabled
	rankToLevel = { { minRank = 255, level = 3 }, { minRank = 200, level = 2 }, { minRank = 100, level = 1 } },
	userOverrides = {} :: { [number]: number }, -- [UserId] = level
}

local AuditStore = DataStoreService:GetDataStore("AdminAudit_v1")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local feedbackRE = remotes:WaitForChild("AdminFeedback") :: RemoteEvent   -- private toast to executor
local announceRE = remotes:WaitForChild("Announcement") :: RemoteEvent    -- banner to everyone

local levels: { [number]: number } = {}
local lastUse: { [number]: number } = {}

local function resolveLevel(player: Player): number
	if RunService:IsStudio() then return LEVEL.Owner end
	if game.CreatorType == Enum.CreatorType.User and game.CreatorId == player.UserId then
		return LEVEL.Owner
	end
	local lvl = SETTINGS.userOverrides[player.UserId] or LEVEL.Player
	if SETTINGS.groupId ~= 0 then
		local ok, rank = pcall(function()
			return player:GetRankInGroupAsync(SETTINGS.groupId)
		end)
		if ok then
			for _, row in SETTINGS.rankToLevel do
				if rank >= row.minRank then lvl = math.max(lvl, row.level) break end
			end
		end
	end
	return lvl
end

local function levelOf(player: Player): number
	return levels[player.UserId] or LEVEL.Player
end

local function reply(player: Player, msg: string)
	feedbackRE:FireClient(player, msg)
end

local function audit(executor: Player, cmd: string, detail: string)
	local entry = { t = os.time(), by = executor.UserId, cmd = cmd, detail = string.sub(detail, 1, 200) }
	print("[AdminAudit]", executor.Name, cmd, detail)
	task.spawn(function()
		pcall(function()
			AuditStore:UpdateAsync(os.date("!%Y-%m-%d"), function(log)
				log = if type(log) == "table" then log else {}
				table.insert(log, entry)
				while #log > 1000 do table.remove(log, 1) end
				return log
			end)
		end)
	end)
end

-- Find exactly one player by name/display-name prefix.
local function findTarget(query: string?): (Player?, string?)
	if not query or query == "" then return nil, "Missing player name." end
	query = string.lower(query)
	local matches = {}
	for _, p in Players:GetPlayers() do
		if string.sub(string.lower(p.Name), 1, #query) == query
			or string.sub(string.lower(p.DisplayName), 1, #query) == query then
			table.insert(matches, p)
		end
	end
	if #matches == 1 then return matches[1], nil end
	return nil, if #matches == 0 then "No player matches." else "Ambiguous name; type more letters."
end

local function canTarget(executor: Player, target: Player): boolean
	return executor == target or levelOf(executor) > levelOf(target)
end

local function filterBroadcast(text: string, fromUserId: number): string?
	local ok, result = pcall(function()
		local filtered = TextService:FilterStringAsync(text, fromUserId)
		return filtered:GetNonChatStringForBroadcastAsync()
	end)
	return if ok then result else nil
end

type Command = {
	alias: string, level: number, usage: string,
	run: (executor: Player, args: { string }, rest: string) -> string,
}

local COMMANDS: { Command } = {
	{
		alias = "/kick", level = LEVEL.Mod, usage = "/kick <player> [reason]",
		run = function(ex, args, rest)
			local target, err = findTarget(args[1])
			if not target then return err :: string end
			if not canTarget(ex, target) then return "You can't target that player." end
			local reason = string.sub(rest, #args[1] + 2)
			target:Kick(if reason ~= "" then "Kicked by a moderator: " .. reason else "Kicked by a moderator.")
			audit(ex, "kick", target.UserId .. " " .. reason)
			return "Kicked " .. target.Name
		end,
	},
	{
		alias = "/ban", level = LEVEL.Mod, usage = "/ban <player> <hours|perm> <reason>",
		run = function(ex, args, rest)
			local target, err = findTarget(args[1])
			if not target then return err :: string end
			if not canTarget(ex, target) then return "You can't target that player." end
			local hours = if args[2] == "perm" then -1 else tonumber(args[2])
			if not hours then return "Usage: /ban <player> <hours|perm> <reason>" end
			if hours == -1 and levelOf(ex) < LEVEL.Admin then return "Only admins can perm-ban." end
			local reason = table.concat(args, " ", 3)
			local ok, e = pcall(function()
				Players:BanAsync({
					UserIds = { target.UserId },
					ApplyToUniverse = true,
					Duration = if hours == -1 then -1 else math.floor(hours * 3600),
					DisplayReason = "You were banned for breaking the game rules.",
					PrivateReason = ("by %d: %s"):format(ex.UserId, reason),
					ExcludeAltAccounts = false,
				})
			end)
			audit(ex, "ban", ("%d %s %s"):format(target.UserId, tostring(args[2]), reason))
			return if ok then "Banned " .. target.Name else "Ban failed: " .. tostring(e)
		end,
	},
	{
		alias = "/unban", level = LEVEL.Admin, usage = "/unban <userId>",
		run = function(ex, args)
			local id = tonumber(args[1])
			if not id then return "Usage: /unban <userId>" end
			local ok, e = pcall(function()
				Players:UnbanAsync({ UserIds = { id }, ApplyToUniverse = true })
			end)
			audit(ex, "unban", tostring(id))
			return if ok then "Unbanned " .. id else "Unban failed: " .. tostring(e)
		end,
	},
	{
		alias = "/announce", level = LEVEL.Admin, usage = "/announce <message>",
		run = function(ex, _args, rest)
			if rest == "" then return "Usage: /announce <message>" end
			local safe = filterBroadcast(string.sub(rest, 1, 200), ex.UserId)
			if not safe then return "Filtering failed; not sent." end
			announceRE:FireAllClients(safe)
			audit(ex, "announce", safe)
			return "Announcement sent."
		end,
	},
	{
		alias = "/goto", level = LEVEL.Mod, usage = "/goto <player>",
		run = function(ex, args)
			local target, err = findTarget(args[1])
			if not target then return err :: string end
			local a, b = ex.Character, target.Character
			if not (a and b and b.PrimaryPart) then return "Characters not loaded." end
			a:PivotTo(b:GetPivot() * CFrame.new(0, 0, 4))
			audit(ex, "goto", tostring(target.UserId))
			return "Teleported to " .. target.Name
		end,
	},
	{
		alias = "/testflag", level = LEVEL.Owner, usage = "/testflag <key> <true|false|number|clear>",
		run = function(ex, args)
			local key, raw = args[1], args[2]
			if not key or not raw then return "Usage: /testflag <key> <value|clear>" end
			if raw == "clear" then
				ConfigService:ClearTestingValue(key)
			else
				local v: any = if raw == "true" then true elseif raw == "false" then false else (tonumber(raw) or raw)
				ConfigService:SetTestingValue(key, v) -- affects THIS server only
			end
			audit(ex, "testflag", key .. "=" .. raw)
			return "Test value set on this server."
		end,
	},
}

local AdminCommands = {}

function AdminCommands.init()
	Players.PlayerAdded:Connect(function(p)
		levels[p.UserId] = resolveLevel(p)
		p:SetAttribute("AdminLevel", levels[p.UserId]) -- UI hint only; never trusted
	end)
	for _, p in Players:GetPlayers() do
		levels[p.UserId] = resolveLevel(p)
	end
	Players.PlayerRemoving:Connect(function(p)
		levels[p.UserId] = nil
		lastUse[p.UserId] = nil
	end)

	local folder = Instance.new("Folder")
	folder.Name = "AdminCommands"
	folder.Parent = TextChatService

	for _, cmd in COMMANDS do
		local tcc = Instance.new("TextChatCommand")
		tcc.Name = "Admin_" .. string.sub(cmd.alias, 2)
		tcc.PrimaryAlias = cmd.alias
		tcc.AutocompleteVisible = false
		tcc.Parent = folder
		tcc.Triggered:Connect(function(source: TextSource, text: string)
			local ex = Players:GetPlayerByUserId(source.UserId)
			if not ex then return end
			if levelOf(ex) < cmd.level then return end -- silent for non-staff
			local now = os.clock()
			if lastUse[ex.UserId] and now - lastUse[ex.UserId] < 0.5 then return end
			lastUse[ex.UserId] = now
			local rest = string.gsub(string.sub(text, #cmd.alias + 1), "^%s+", "")
			local args = string.split(rest, " ")
			if args[1] == "" then args = {} end
			local ok, msg = pcall(cmd.run, ex, args, rest)
			reply(ex, if ok then msg else ("Error: " .. tostring(msg)))
		end)
	end
end

return AdminCommands
```

An admin *panel* (GUI) should call one RemoteFunction, `AdminRequest(cmdAlias, args)`, which runs the **same** `COMMANDS` table through the same `levelOf` check. That way there is one permission path to audit.

### 1.11 Releasing updates: server restarts, "soft shutdown" and migration

Current Roblox behavior (docs, 2026):
- Publishing does **not** move players. Old servers keep running old code until they empty, unless you **Restart Servers** (Creator Hub → Configurations → Server management, or the Open Cloud restarts API).
- The restart options are **"Restart only servers with outdated versions"** (recommended) and **"Delay server restart"** of 1–60 minutes (server bleed-off).
- During a restart, matchmaking to old servers stops, the delay elapses, and then **Roblox teleports everyone on an old server together to a replacement server on the new version**. This is the built-in version of the old community "soft shutdown" script.
- `game.ServerRestartScheduled(restartTime: DateTime, source: Enum.CloseReason, attributes)` fires on affected servers. `source` is `DeveloperUpdate` for your restarts and `RobloxMaintenance` for platform maintenance. Use it for a countdown banner, an early save, or to end a round cleanly.
- `game:BindToClose(fn)` handlers receive an `Enum.CloseReason` (`DeveloperShutdown`, `DeveloperUpdate`, `RobloxMaintenance`, `ServerEmpty`, `OutOfMemory`, `Moderation`, `Unknown`). There is a 30-second limit, and teleports are disabled during moderation shutdowns.
- For time-sensitive releases, **deploy early with the content hidden behind a config, then flip the config**. No restart is needed.

**Luau: soft shutdown / restart handler**

```lua
--!strict
-- ServerScriptService/SoftShutdown.server.lua
-- 1) Announces scheduled restarts with a countdown and saves early.
-- 2) OPTIONAL legacy path: when a developer uses "Shut down all servers" (not a
--    versioned restart), park players in a reserved server and bring them back,
--    so they rejoin fresh servers instead of being disconnected.
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ENABLE_LEGACY_SOFT_SHUTDOWN = false -- turn on only if you use full shutdowns for updates
local FLAG = "softShutdownHolding"

local restartRE = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ServerRestart") :: RemoteEvent

-- Hook: your data module's "save everyone now" function.
local function saveAll()
	-- e.g. require(ServerScriptService.PlayerData).saveAll()
end

-- (1) Scheduled restart notice
game.ServerRestartScheduled:Connect(function(restartTime: DateTime, source: Enum.CloseReason, attributes: { [string]: any }?)
	local unix = restartTime.UnixTimestamp
	local reasonKey = if source == Enum.CloseReason.RobloxMaintenance then "RESTART_MAINTENANCE" else "RESTART_UPDATE"
	restartRE:FireAllClients(unix, reasonKey, attributes and attributes.note)
	task.spawn(saveAll)
	-- Optional: stop starting new rounds if restart is < 2 minutes away.
	workspace:SetAttribute("NoNewRounds", unix - os.time() < 120)
end)

-- (2a) Holding-server behaviour: send players back to public servers
local isReservedServer = game.PrivateServerId ~= "" and game.PrivateServerOwnerId == 0
if isReservedServer then
	local function isHoldingArrival(p: Player): boolean
		local data = p:GetJoinData().TeleportData
		return type(data) == "table" and data[FLAG] == true
	end
	local holding = false
	for _, p in Players:GetPlayers() do holding = holding or isHoldingArrival(p) end
	Players.PlayerAdded:Connect(function(p)
		if not isHoldingArrival(p) then return end
		holding = true
		task.wait(8) -- let old servers finish closing so matchmaking picks new ones
		local ok, err = pcall(function()
			TeleportService:TeleportAsync(game.PlaceId, { p })
		end)
		if not ok then
			warn("[SoftShutdown] return teleport failed:", err)
			task.wait(5)
			pcall(function() TeleportService:TeleportAsync(game.PlaceId, { p }) end)
		end
	end)
end

-- (2b) On close
game:BindToClose(function(reason: Enum.CloseReason)
	if RunService:IsStudio() then return end
	saveAll()

	if not ENABLE_LEGACY_SOFT_SHUTDOWN or isReservedServer then return end
	if reason ~= Enum.CloseReason.DeveloperShutdown then return end -- DeveloperUpdate: Roblox migrates for us
	local players = Players:GetPlayers()
	if #players == 0 then return end

	restartRE:FireAllClients(os.time(), "RESTART_UPDATE", nil)
	local options = Instance.new("TeleportOptions")
	options.ShouldReserveServer = true
	options:SetTeleportData({ [FLAG] = true })
	local ok, err = pcall(function()
		TeleportService:TeleportAsync(game.PlaceId, players, options)
	end)
	if not ok then
		warn("[SoftShutdown] park teleport failed:", err)
		return
	end
	-- Keep the server alive (max ~30s) until players have left.
	local deadline = os.clock() + 25
	while #Players:GetPlayers() > 0 and os.clock() < deadline do
		task.wait(1)
	end
end)
```

Client: on `ServerRestart`, show a non-blocking banner such as "Update in 4:59 — your progress is saved", using the localized `reasonKey`. Do not freeze gameplay.

### 1.12 Update log UI ("What's new")

- Keep a `GameVersion` string (for example `"1.14.0"`) in a ReplicatedStorage ModuleScript, along with a list of entries `{version, date, headlineKey, bulletsKeys, image}`. Store the strings as localization keys.
- Save `lastSeenVersion` in player data. On join, if it is older than the current version, open the "What's New" panel once after the loading screen, with a single **Got it** button and an optional "Take me there" teleport. Then update `lastSeenVersion`.
- Show a small version label in the settings menu (`v1.14.0 • server v1.13.2`). Read the server's version from an attribute so players and support can spot old servers.
- Mirror the headline in the game description's top line and in a Creator Hub **update announcement**: 60 characters maximum, once every three days, delivered to opted-in followers. Be specific ("New volcano world + 12 pets"), not "bug fixes".

### 1.13 Data versioning and migration

```lua
-- Inside your profile load, before anything else touches the data
local CURRENT = 4
local MIGRATIONS = {
	[1] = function(d) d.settings = d.settings or { music = true } end,
	[2] = function(d) d.inventory = d.items or {}; d.items = nil end,      -- rename
	[3] = function(d) d.gems = (d.gems or 0) + math.floor((d.coins or 0) / 1000) end, -- currency rework
	[4] = function(d) d.pass = { season = 1, xp = 0, claimed = {} } end,
}
local function migrate(d)
	d.version = d.version or 0
	while d.version < CURRENT do
		local step = MIGRATIONS[d.version + 1]
		if step then step(d) end
		d.version += 1
	end
	return d
end
```

Rules:
- Migrations are **append-only and idempotent**. Never edit an old step once it has shipped.
- **Never save data that has a newer version than the server understands.** If `d.version > CURRENT` (an old server that missed the restart), load it read-only and do not save. Otherwise an old server will overwrite new fields. This is the main reason to restart outdated servers after any save-format change.
- Take an Open Cloud **data store snapshot** right before publishing a save-format change. Snapshots can be taken once per day and preserve the pre-update state. Previous versions of each key are kept for **30 days** after being overwritten (`ListVersionsAsync`, `GetVersionAsync`), which is what makes per-player rollbacks possible.
- Respect right-to-be-forgotten (RTBF) requests. Delete the user's keys within 30 days when Roblox notifies you.

---

## 2. Community management

### 2.1 The off-platform stack

| Channel | Use | Notes |
|---|---|---|
| **Roblox Community** (formerly "Groups"; renamed in late 2024; still "Groups" in Creator Hub and APIs) | Primary on-platform home: membership perks, group-owned game, roles that drive admin levels, **Forums** (launched for all community owners in 2025; Walls are read-only/retired) | Members can be rewarded in-game. Announcements reach members. |
| **Discord server** | Core fans, bug reports, suggestions, leaks/teasers, code drops, testers | Off-platform: only linkable from the game page social links. Discord requires users to be 13+. |
| **X / Twitter** | Codes, update teasers, like-goal codes | Traditional channel for Roblox codes. |
| **YouTube (long + Shorts), TikTok** | Discovery via clips, trailers, devlogs | Biggest off-platform acquisition channel for Roblox games. |
| **Roblox Moments** (announced RDC Sept 2025; beta for 13+) | In-Roblox short-form gameplay clip feed; viewers can jump into the game | Use `CaptureService` to let players record and share highlight moments. |

Discord structure template:
- **INFO:** #rules, #announcements (read-only), #update-log, #codes, #faq, #roles (self-assign ping roles: updates, events, codes)
- **COMMUNITY:** #general, #media (clips and fan art), #trading (only if the game has trading; heavy moderation), #off-topic, language channels (#español, #português…)
- **FEEDBACK:** #suggestions (a forum channel with tags and upvotes), #bug-reports (a forum channel with a template), #known-issues (read-only)
- **SUPPORT:** a ticket bot for data loss and purchase issues
- **STAFF:** #mod-log, #mod-chat, #dev
- Use AutoMod with slur and scam filters, require phone or email verification, set slow mode in #general, and post a clear minimum-age rule (Discord's ToS requires users to be 13+).

### 2.2 Social links rules (critical for the bot)

From the official docs:
- Up to **three social links** per game, community or Creator Store asset can be added by creators who have **verified their age as 16+** (facial age estimation or government ID). Group-owned games need at least one age-verified 16+ collaborator. If all such collaborators leave, the links are deleted after 90 days.
- **Only users who have verified as 16+ can see social links.** Most of your young audience never sees your Discord link. Plan community features that work **on Roblox**: Community membership, in-game announcements, events, update notifications.
- Links may appear **only on the game's details page**, never inside the game.
  - Allowed in-game: "Check out our social media links on our game's page", "Join us in our Community Server. Links on our game's page."
  - Not allowed: "Join our Discord discord.gg/abc", "Follow for merch on X.com/abc", "Send bug reports to abc@xyz.com".

### 2.3 Handling feedback and toxicity

- **Collect feedback** in three places: the in-game prompt (`SocialService:PromptFeedbackSubmissionAsync`; results appear in Creator Dashboard → Audience → **Feedback**; each player can submit once per day per game), Discord forum channels, and analytics. Weight the analytics most heavily, because loud Discord users are not your median player.
- **Close the loop.** Post "You asked, we did" in patch notes, credit community ideas by username in the update log (with permission), and keep a public known-issues list.
- **Toxicity and moderation:** use Roblox's chat (filtered, with built-in report and mute), `TextChatService` default commands, and Quick Words for coordination. Set community rules that mirror Roblox Community Standards. Moderators need written guidelines (warning → kick → 1-day ban → 7-day ban → permanent) and must log actions. Never publicly shame players. Ban reasons shown to users must be neutral.
- **Developer conduct:** never reveal personal information, never ask players for personal information, never promise refunds outside policy, and never engage in flame wars. Stay calm and factual, and lock threads when needed.
- **Leaks and exploiters:** do not publicize exploit methods. Patch the issue quietly, ban based on server-side detection, and post "fixed an exploit" with no details.

### 2.4 Content creators and influencers

- Keep a creator program: a #creator role in Discord, early-access private servers or a staging place, exclusive codes per creator (track which code was redeemed, as in 1.9), and a press kit (logo, key art, a B-roll capture place, a fact sheet).
- Approach small and medium creators (10k–500k subscribers) in your genre. They respond more often and their audiences convert. Give them something new to show: an unreleased update a day early, or a creator-only code.
- Any paid promotion must be disclosed by the creator under platform and FTC rules. Roblox's advertising standards apply to ads that target Roblox users. Do not ask creators to say false things ("free Robux").
- Creator-tagged in-game items (a pet named after a creator) are a common, cheap reward. Get written consent.

### 2.5 Trailers, clips and short-form video (TikTok, YouTube Shorts, Moments)

- **Vertical 9:16, 15–30 s, hook in the first 1.5 s.** Open on the most absurd, satisfying or funny moment (a giant explosion, a rare pet hatch, a fail), not a logo. Put text on screen because most viewers watch muted. End with the game name **as it appears in Roblox search**.
- Record in Studio or a private server with a **cinematic camera script** (hide the UI with `StarterGui:SetCoreGuiEnabled`, use a free camera, tween along CFrame splines). Capture at 60 fps and edit in CapCut or DaVinci Resolve.
- Formats that work on Roblox TikTok and Shorts: "POV: you…", rare-drop reactions, "rating every pet", before/after progression, speed-runs, "I built X in my game", a dev reacting to a bug, and players' reactions to an update.
- Post consistently (3–5 Shorts per week around updates), reuse the same clip across TikTok, Shorts, Moments and X, and pin the comment "Search ___ on Roblox". Do not use copyrighted music outside each platform's licensed library.
- **Moments / CaptureService:** let players capture their own highlights. `CaptureService:TakeScreenshotCaptureAsync`, `StartVideoCaptureAsync`/`StopVideoCapture` and `PromptShareCapture` exist. Trigger a capture prompt at peak moments (a boss kill, a rare hatch). Check `IsContentSharingAllowed` from PolicyService before showing sharing features.

---

## 3. Player support

### 3.1 Bug reports

- Add an in-game **Report a bug** button. Either use `SocialService:PromptFeedbackSubmissionAsync()` (Feedback type; the **PlayerSupport** type is alpha, for select games only), or build your own form that sends **only structured fields**: category dropdown, auto-attached server JobId, place version, platform, the player's recent error codes, and position. Avoid free text, or filter it and store it privately; never show it to other players.
- Auto-attach diagnostics: `game.JobId`, `game.PlaceVersion`, `UserInputService` platform hints, and the last 20 client errors from `ScriptContext.Error`. Send these through rate-limited RemoteEvents (one report per player per minute).
- Triage: label each report (crash, data, purchase, exploit, UI, translation), reproduce it in staging, link it to the known-issues list, and close the loop in the update log.

### 3.2 Refund and rollback policy

- **Robux purchases:** you cannot issue Robux refunds directly. Roblox handles payment disputes. Your obligations are to **deliver what was bought**: use `ProcessReceipt` correctly, make it idempotent, and record a purchase history in player data. When an item was not delivered, **re-grant** it after verifying the receipt in your stored purchase log. Support can cross-check purchase history in Creator Hub (sales reports) where available.
- **Data loss:** you can restore a player's key to an earlier version with `ListVersionsAsync` and `GetVersionAsync`. Versions are kept for 30 days after being overwritten. Build an **admin-only restore tool** that previews a version and writes it back while the player is **offline** (or kicks them first so the session lock is released). Log every restore.
- **Write a public policy** (Discord #faq and game description): "We restore lost progress from automatic backups within 30 days; we re-grant missing purchases with proof; we do not compensate for items lost through trading/scams." This prevents endless arguments.
- **Global rollbacks** after a duplication exploit: prefer targeted fixes (remove the duplicated items from the identified accounts) over rolling everyone back. If you must roll back, compensate everyone with a public, generous gift.

---

## 4. Social features in-game

Roblox is a social platform, and games that make playing with friends easy retain far better.

### 4.1 Friend invites

```lua
-- LocalScript: invite button
local SocialService = game:GetService("SocialService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local options = Instance.new("ExperienceInviteOptions")
options.PromptMessage = "Invite friends to raid the castle with you!"
-- options.InviteMessageId = "<Notification asset id>"  -- custom localized notification text
-- options.LaunchData = "squad=castle"                 -- ≤200 chars, read via Player:GetJoinData()

local function tryInvite()
	local ok, canSend = pcall(function()
		return SocialService:CanSendGameInviteAsync(player)
	end)
	if ok and canSend then
		SocialService:PromptGameInvite(player, options)
	end
end
```

- Show the invite button **in context**: in the lobby, after a win ("Invite a friend to beat this together"), and in party-required modes. Don't nag.
- The **Friend referral system** tracks and rewards inviters and invitees through referral links, with custom reward banners.
- **Share links:** `SocialService:PromptLinkSharingAsync(player, {ExpirationSeconds, PreviewTitle, PreviewDescription, PreviewAssetId, LaunchData})` (server-side) generates an expiring deep link and opens the platform share sheet. Use it for "join my base" and "check out my build".
- `LaunchData` and `Player:GetJoinData().LaunchData` let you route an invited friend straight to the inviter's team, plot or lobby.

### 4.2 Friend join, following and parties

- Players can join friends from profiles and the Roblox app. When `player.FollowUserId ~= 0`, the player followed someone in. Spawn them near that friend and put them on the same team.
- **Parties:** Roblox's Party feature, with Party Voice, lets friends travel together. `Player.PartyId`, `SocialService:GetPlayersByPartyId(partyId)` (same server) and `SocialService:GetPartyAsync(partyId)` (across servers, with PlaceId and JobId) let you **keep parties together**: put them on the same team, and use `TeleportService:TeleportPartyAsync` or `TeleportAsync` with all party members into the same reserved match. Test with Studio's **Party Simulator**.
- **Roblox Connect** (avatar video calls) **was discontinued 2026-07-15**, including the developer call APIs (`CanSendCallInviteAsync` now returns false). Do not build on it.

### 4.3 Experience Notifications (out-of-game re-engagement)

- Delivered to **opted-in users 13+** in their Roblox notification stream, with a **Join** button. `launchData` in the payload is readable through `GetJoinData()`.
- Sent server-side with the **Open Cloud** Luau package (`OpenCloud.V2.UserNotification.createUserNotification(userId, {payload = {messageId, type = "MOMENT", parameters, joinExperience = {launchData}, analyticsData = {category}}})`), or through the Open Cloud REST API from your backend.
- Eligibility: the game has at least **100 visits**, is not under moderation, and you have manage permission.
- Prompt opt-in **in context**, on the client: `ExperienceNotificationService:CanPromptOptInAsync()` then `PromptOptIn()`. The prompt text is fixed. It won't show to under-13s, to users already opted in, or to anyone prompted in the last 30 days, so pick the moment carefully ("Want to know when your egg hatches?").
- Content rules: **personalized and actionable** ("Your gold goose egg has hatched!", "Allie beat your record — time for revenge?"). Not allowed: generic ads, disguised ads, false time pressure, bait-and-switch freebies, tricking players into purchases. Notifications are filtered and held to platform-wide standards regardless of your game's rating.
- **Update announcements** (Creator Hub → Events & Updates): 60 characters maximum, once per three days, to opted-in followers.

### 4.4 Voice chat and spatial voice

- Voice is available to **age-checked 13+** users in supported countries, in places with **at most 100 max players**. It is on by default for new games and toggled in Experience Settings → Communication.
- It is proximity-based by default. With `VoiceChatService.UseAudioApi = Enabled`, you get `AudioDeviceInput`, `AudioEmitter`, `AudioListener` and wires for custom routing: team-only voice, radios, megaphones, and muffling through walls. `VoiceChatService:IsVoiceEnabledForUserIdAsync(userId)` tells you whether a player has voice.
- **Design rules:** never *require* voice to progress, and offer a text or Quick Words alternative for every voice mechanic. Default to proximity voice (strangers far away aren't heard). Show a speaking indicator. Respect the in-game volume and mute controls (`EnableVoiceVolumeControls`). Avoid "lobby voice to everyone" layouts in games aimed at younger teens.
- Speech-to-text APIs require voice to be enabled.

### 4.5 TextChatService customization and safe chat

- Use `TextChatService` (legacy chat is gone). You can customize the look with `ChatWindowConfiguration`, `ChatInputBarConfiguration` and `BubbleChatConfiguration`, plus channels (`TextChannel`) for team or guild chat and `TextChatCommand` for commands.
- **Platform-integrated chat** (`TextChatService.PlatformIntegratedChat`, set in Studio only) is opt-in today and **required for all games from May 2027**. When it is enabled, Roblox renders the chat, `TextChatMessage.Text`, `Translation` and `PrefixText` return `""`, `OnIncomingMessage` callbacks are not invoked, custom chat UIs must use `TextChannelWindow` (one per channel; the Global channel can't be targeted), custom chat-wheel presets must move to **Quick Words**, and commands must use `TextChatCommand`. **Build new games to be compatible now.** Don't depend on chat tags/prefixes or on reading message text.
- **Quick Words:** Creator Hub → Configure → Chat → Quick Words. Up to 3 custom categories with 3–10 phrases each, each under 25 characters, written in English and automatically translated. They are reviewed against the preset guidelines and must be gameplay coordination ("Follow me", "Need healing"), not social or open-ended questions. This is the right communication tool for young and cross-age audiences.
- **Chat is age-checked.** Since January 2026, Roblox requires an age check (facial age estimation or ID) to use chat worldwide. Users are placed in age bands (under 9, 9–12, 13–15, 16–17, 18–20, 21+) and generally chat only with the same or adjacent bands, while under-9s need parental consent. Assume **many players cannot chat with each other**. Game coordination must work through UI (pings, emotes, Quick Words, ready buttons), not chat. `TextChatService:CanUsersChatAsync(a, b)` tells you whether two users can chat.
- **Any player-written text** you display (pet names, signs, guild names) must go through `TextService:FilterStringAsync` with the right Get… method, must not be a two-way communication channel, and needs at least a 1-minute rate limit on in-world writable surfaces.
- `TextChatService.ChatTranslationEnabled` lets Roblox translate chat between languages. Leave it on.

---

## 5. Localization

### 5.1 Why and which languages

Most Roblox growth is now **outside the US and Canada**, with APAC, Europe and "rest of world" (LATAM, MENA) together making up the large majority of DAU in 2025 earnings. Roblox does not publish per-language player shares, but developer reports and the auto-translation language list point to these priorities:

1. **Spanish** (LATAM and Spain; locales `es-es`/`es-mx` are supported) and **Portuguese (Brazil)**. These are the classic top two non-English markets, and Brazil is huge on Roblox.
2. **Indonesian, Filipino-English markets, Thai, Vietnamese.** APAC growth is fast.
3. **German, French, Russian, Turkish, Polish, Italian.**
4. **Japanese, Korean, Chinese (Simplified and Traditional), Arabic, Hindi.**

Roblox's automatic translation supports Arabic, Chinese (Simplified and Traditional), English, French, German, Hindi, Indonesian, Italian, Japanese, Korean, Polish, Portuguese, Russian, Spanish, Thai, Turkish and Vietnamese. Players who turn on "Automatic Translations" in their account settings see translated game content **even if you did nothing**. Manual translations always win over automatic ones.

Check your game's own Analytics breakdown by language and country, and use config targeting by **language** or **country** for region-specific events or messages.

### 5.2 The pipeline

1. **Settings** (Creator Hub → game → Audience → **Localization**): set the source language and add supported languages.
2. Turn on **Automatic Text Capture (ATC)**, "Capture text from experience UI while users play". It only captures GUI text with `AutoLocalize = true`. For a `TextBox`, only `PlaceholderText` is captured. New strings can take days to appear, while Studio's Localization Tools → Automatic Text Capture adds them within 1–2 minutes of playtesting. ATC does **not** capture the default leaderboard and chat, player-owned tools, text inside images, or badge and pass names and descriptions pulled from the platform. Translate those on the platform side or by script.
3. Turn on **Use Translated Content**, then per language enable "Experience Information" (name and description) and "Experience Strings & Products".
4. **Quotas:** the initial and monthly automatic-translation quotas are counted **per character per language**.
5. **Review:** add trusted community translators in the **Translator Portal** (see "Work with translators"). Lock good entries; locking turns an automatic translation into a manual one that won't be auto-updated, and you remain responsible for its content.
6. **CSV round-trip:** download and upload the localization table as `.csv` (Studio or Creator Hub). This is the only way to edit the **Key**, **Context** and **Example** columns in bulk. Limits are 2 MB per file and 1,000 modified or added entries per upload. Uploading never deletes entries; to delete, use Delete Table and then re-upload.
7. **Cleanup:** ATC removes stale auto-captured strings unless you disable that option.

CSV shape (keys make scripted lookups stable):

```csv
Key,Context,Example,Source,es,pt,fr,de,id
UI_PLAY,,,Play,Jugar,Jogar,Jouer,Spielen,Main
DAILY_STREAK,,"{streak}=5",Day {streak} streak!,¡Racha de {streak} días!,Sequência de {streak} dias!,Série de {streak} jours !,{streak}-Tage-Serie!,Beruntun {streak} hari!
CODE_OK,,,Code redeemed!,¡Código canjeado!,Código resgatado!,Code utilisé !,Code eingelöst!,Kode berhasil ditukar!
CODE_EXPIRED,,,That code has expired.,Ese código ha caducado.,Esse código expirou.,Ce code a expiré.,Dieser Code ist abgelaufen.,Kode itu sudah kedaluwarsa.
RESTART_UPDATE,,"{time}=4:59",Update in {time} — your progress is saved,Actualización en {time}: tu progreso está guardado,Atualização em {time} — seu progresso está salvo,Mise à jour dans {time} — ta progression est sauvegardée,Update in {time} – dein Fortschritt ist gespeichert,Pembaruan dalam {time} — progresmu tersimpan
```

### 5.3 Translating UI and dynamic strings

- **Static GUI text** is handled automatically by ATC and the table. Turn `AutoLocalize` off for player names, NPC proper names, numbers you format yourself, and anything player-written.
- **Dynamic strings** should use **parameters** in the table (`Day {streak} streak!`) plus `Translator:FormatByKey(key, {streak = 5})`. Format specifiers such as `{1:int}`, `{1:fixed}`, `{1:num}` and `{1:datetime}` give locale-correct separators. **Never concatenate** ("You have " .. n .. " coins"), because word order differs by language.
- **Server → client:** the server sends `{key = "CODE_OK"}` or `{key = "DAILY_STREAK", args = {streak = 5}}`, and each client formats it in its own language. Never build final display text on the server, since a server holds players with many locales.
- **Localized images and sounds:** put asset IDs in the table under a key (`Key_JewelsImage`) and fetch them with `FormatByKey`.
- **Context overrides:** the same source string can have different translations depending on the Context column (an instance path).
- **Player-generated or rare text:** the **real-time translation Open Cloud API** (`TranslateText`, early development) translates arbitrary text into `player.LocaleId` through the Open Cloud package. It only supports RCC auth, so test it in a Team Test server. Use it sparingly, with caching.
- **React to language changes:** listen to `translator:GetPropertyChangedSignal("LocaleId")` and re-render scripted text.
- **Layout:** German and Russian run about 30% longer than English, while Thai, Arabic and CJK scripts need taller lines. Use `AutomaticSize`, `TextWrapped` and `UIListLayout` rather than fixed-width labels. Arabic is right-to-left, so test mirrored layouts if you support it. Prefer icons and numbers over words in core HUD elements.

**Luau: localization helper (client ModuleScript)**

```lua
--!strict
-- ReplicatedStorage/Shared/Loc.lua
-- Usage (client):
--   local Loc = require(ReplicatedStorage.Shared.Loc)
--   label.Text = Loc.t("DAILY_STREAK", { streak = 5 })
--   Loc.bind(label, "UI_PLAY")              -- auto-updates on language change
--   Loc.fromPayload({ key = "CODE_OK" })     -- server sends keys, never English
local LocalizationService = game:GetService("LocalizationService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

assert(RunService:IsClient(), "Loc is a client module")

local player = Players.LocalPlayer
local translator: Translator? = nil
local sourceTranslator: Translator? = nil -- source-language fallback
local bound: { [Instance]: { key: string, args: { [string]: any }? } } = {}
local changed = Instance.new("BindableEvent")

local Loc = {}
Loc.Changed = changed.Event

local function getTranslator(fn: () -> Translator, tries: number): Translator?
	for i = 1, tries do
		local ok, t = pcall(fn)
		if ok then return t end
		task.wait(2 ^ i * 0.5)
	end
	return nil
end

local function formatWith(t: Translator?, key: string, args: { [string]: any }?): string?
	if not t then return nil end
	local ok, result = pcall(function()
		return t:FormatByKey(key, args)
	end)
	return if ok then result else nil
end

-- Translate a key with named args; falls back to source language, then the key.
function Loc.t(key: string, args: { [string]: any }?): string
	return formatWith(translator, key, args)
		or formatWith(sourceTranslator, key, args)
		or key
end

-- Translate a literal source string (for text that has no key).
function Loc.s(source: string, context: Instance?): string
	if not translator then return source end
	local ok, result = pcall(function()
		return (translator :: Translator):Translate(context or game, source)
	end)
	return if ok then result else source
end

function Loc.fromPayload(payload: { key: string, args: { [string]: any }? }): string
	return Loc.t(payload.key, payload.args)
end

-- Bind a TextLabel/TextButton so it re-renders when language changes.
function Loc.bind(label: TextLabel | TextButton, key: string, args: { [string]: any }?)
	label.AutoLocalize = false -- we handle it; avoid double translation
	bound[label] = { key = key, args = args }
	label.Text = Loc.t(key, args)
	label.Destroying:Once(function() bound[label] = nil end)
end

-- Locale-aware compact numbers for HUD (1.2K, 3.4M). Keep suffixes universal.
function Loc.compact(n: number): string
	local abs = math.abs(n)
	if abs >= 1e9 then return string.format("%.1fB", n / 1e9) end
	if abs >= 1e6 then return string.format("%.1fM", n / 1e6) end
	if abs >= 1e3 then return string.format("%.1fK", n / 1e3) end
	return tostring(math.floor(n))
end

function Loc.localeId(): string
	return if translator then translator.LocaleId else LocalizationService.RobloxLocaleId
end

local function rerenderAll()
	for label, b in bound do
		(label :: any).Text = Loc.t(b.key, b.args)
	end
	changed:Fire(Loc.localeId())
end

task.spawn(function()
	sourceTranslator = getTranslator(function()
		return LocalizationService:GetTranslatorForLocaleAsync("en-us") -- your source locale
	end, 3)
	translator = getTranslator(function()
		return LocalizationService:GetTranslatorForPlayerAsync(player)
	end, 4)
	if translator then
		translator:GetPropertyChangedSignal("LocaleId"):Connect(rerenderAll)
	end
	rerenderAll()
end)

return Loc
```

### 5.4 Regional considerations

- **Policy differences:** `PolicyService:GetPolicyInfoForPlayerAsync(player)` returns `ArePaidRandomItemsRestricted` (loot boxes; e.g. restricted in some countries), `IsPaidItemTradingAllowed`, `IsContentSharingAllowed`, `AreAdsAllowed`, `IsEligibleToPurchaseSubscription`, `IsEndlessContentLoadAllowed`, `IsEndlessContentAutoplayAllowed`, `IsSubjectToChinaPolicies`, and more. Call it on the server with `pcall`, cache the result, and gate features with it. **Show an alternative** (direct-purchase cosmetics instead of crates). `AllowedExternalLinkReferences` is legacy and always empty.
- **Regional content availability:** Roblox may make a game unavailable in specific countries for local legal reasons. Avoid real-world flags, maps, politics and religious symbols in core content.
- **Culture:** avoid hand gestures, number superstitions (4 in East Asia), and holiday-specific events presented as universal. Pair "Christmas" with a neutral "Winter Festival" framing. Run regional events (Carnaval for Brazil, Ramadan or Eid-friendly evening events, Lunar New Year) targeted with config by country.
- **Time zones:** use UTC everywhere in data. Show **relative** times ("ends in 2d 4h") rather than clock times.
- **Low-end devices:** many players in growth markets use low-end Android phones. Keep live-event content cheap to render, and keep text large (section 6).

---

## 6. Accessibility

About 26% of people have some disability and over 5% have some color blindness. On Roblox, add young children who read slowly, mobile players with small screens, and players with no sound.

### 6.1 Respect Roblox's built-in player preferences

| Setting (Roblox menu) | API | What to do |
|---|---|---|
| Text Size | `GuiService.PreferredTextSize` (`Medium` default, then `Large`, `Larger`, `Largest`) | Engine scales text automatically **unless** you use `TextScaled` (not scaled) or `UITextSizeConstraint` caps. Use fixed `TextSize` + `AutomaticSize`/`TextWrapped`. `TextService:GetTextSize`/`GetTextBoundsAsync` honor the setting. |
| Background Transparency | `GuiService.PreferredTransparency` (0–1) | Multiply panel `BackgroundTransparency` by it (tag-based script in docs). |
| Reduce Motion | `GuiService.ReducedMotionEnabled` | Tween time → 0 or fade instead of slide; disable camera shake, screen flashes, bobbing, parallax. |

```lua
-- Client helper: motion-safe tween + camera shake guard
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")

local A11y = {}
function A11y.tween(obj: Instance, time: number, goal: { [string]: any })
	local t = if GuiService.ReducedMotionEnabled then 0 else time
	local tw = TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
	tw:Play()
	return tw
end
function A11y.shakeAllowed(): boolean
	return not GuiService.ReducedMotionEnabled
end
return A11y
```

### 6.2 Your own settings menu (minimum set)

- **Colorblind mode / palette:** protanopia, deuteranopia and tritanopia presets for team colors, rarity colors and damage indicators. More important still, **never use color alone**. Add shapes, icons, patterns and labels (rarity stars plus a word, team icons, a ✓/✗).
- **Subtitles and captions:** a `subtitles` toggle (on by default for dialogue). Add captions for important sound cues ("[Footsteps behind you]", "[Alarm]") and **visual indicators for directional audio** (an edge-of-screen arrow). This is essential in horror games.
- **Separate volume sliders** for music, SFX and voice/dialogue.
- **Flashing and screen-effects toggle:** turn off camera shake and flashes. Avoid more than 3 flashes per second at all times.
- **Input remapping:** let players rebind actions. With the **Input Action System** (`InputContext`, `InputAction`, `InputBinding`), you define actions once and expose binding changes. With `ContextActionService`, store the binding per action in player settings and rebind on change. Support keyboard, gamepad and touch for every action, and offer **toggle vs hold** for sprint, aim and crouch.
- **Camera sensitivity and invert-Y**, and an FOV option (motion sickness).
- **UI scale** slider (0.8–1.4) through a `UIScale` on the root ScreenGui.
- **Auto-aim, aim assist and difficulty options** in action games. Add an **assist mode** (slower timers, extra hints) for kids.
- Save settings in player data (or in local storage settings if you keep them client-only) and apply them on join.

### 6.3 Simple controls for young kids, and reading level

- **One-thumb play on mobile:** the core loop should need at most 2 buttons, with large hit areas (at least 44×44 px; 56+ for primary buttons) placed in the natural thumb zones, away from Roblox's top-bar and system buttons.
- **Reading level:** write for about **age 7–8** (US grades 2–3). Use short words and 3–6-word sentences, plus **icons + numbers** ("🪙 50"). Teach through demonstration (arrows, glowing paths, an NPC pointing) rather than paragraphs. Do not put essential information in text alone. Localized text helps, but pre-readers need visuals.
- **Forgiving design:** no permanent fail states, quick respawns, checkpoint-based obbies, and an undo option on purchases with in-game currency ("Are you sure?" for anything above a threshold).
- **Consistent conventions:** a big green "Play" button, a red X to close, a shop icon top-left or right as in other top Roblox games. Kids learn these across games.
- **Onboarding:** the first 60 seconds should be playable without reading.

### 6.4 Contrast and readability

- Text contrast should be at least 4.5:1 (WCAG AA). Put a dark outline or `UIStroke` on text over 3D scenes, and use a semi-opaque backing panel.
- Use fonts such as Builder Sans or Gotham-style sans serifs. Avoid decorative fonts for body text and all-caps paragraphs.
- Keep 14 pt or larger the minimum effective text size on mobile at default settings, and test on a phone-sized emulator.

---

## 7. Age-appropriate design and parental controls

### 7.1 The 2026 account framework (affects reach)

Roblox assigns three account types:

| | **Roblox Kids** | **Roblox Select** | **Roblox** |
|---|---|---|---|
| Who | Age 5–8 (self-declared or age-checked) | Self-declared 9+ until age-checked, or age-checked 9–15 | Age-checked 16+ |
| Content ratings | Minimal, Mild | Minimal, Mild, Moderate (9+) | All rated content except Restricted (18+) |
| Chat | Off by default; enable through a linked parent once age-checked | Off for self-declared accounts; gradually introduced after an age check | On by default where available |
| Parental controls | Full suite incl. **Approved Experience** controls | Full suite through age 12; some through 15 | Visibility into friends, screen time, spending through 18 |

Content labels: Minimal or Mild games reach Kids and Select. Moderate reaches Select and 16+. "Content May Vary" (questionnaire skipped) reaches **only age-checked 16+**. Restricted is for **age-verified 18+**. Games with no maturity information are restricted.

**To reach anyone under 16 (Kids and Select)** the creator, or the group owner for group games, needs:
1. An account in good standing.
2. Account verification: facial age estimation if under 18, government ID if 18+.
3. 2-step verification.
4. The full **Maturity & Compliance Questionnaire**, with a Minimal, Mild or Moderate result.
5. Either an active Roblox Plus or Premium subscription for 2+ months, or a one-time refundable per-game fee. This is checked when you publish **or update** for all-ages audiences.
6. **Evaluation:** the game first goes to age-checked 16+ users only. It needs **250 unique plays from highly engaged age-checked users within 60 days** plus a safety review, tracked on the **Audience Reach** dashboard. An optional **expedited review** costs a 50,000-Robux refundable fee per game.

Implications for the bot:
- **Answer the questionnaire fully and honestly**, based on the most extreme content a player can encounter. Misrepresentation leads to moderation.
- If the game is meant for kids, keep it **Minimal/Mild**: cartoon violence only, no blood, no realistic weapons focus, no romance, no crude humor beyond mild, and no paid random items for restricted regions.
- Plan the **launch for the 16+ trial phase**. Early marketing should attract teen and adult players so the game clears the 250-engaged-play threshold.
- Free-form **user-generated content** features (drawing boards, custom text, image sharing) increase moderation risk. Gate them with `IsContentSharingAllowed`, filter them, and consider leaving them out of a kids' game entirely.

### 7.2 Chat and social for young players

- Assume younger players **cannot chat**. Under-9s chat only with parental consent, and chat is age-banded for everyone. Build communication through **pings, emotes, Quick Words, stickers and ready-check buttons**.
- Do not build features that encourage players to move to off-platform apps. That is against the rules, and off-platform links are invisible to under-16s anyway.
- Avoid "dating", "boyfriend/girlfriend" or romance-roleplay mechanics, and design hangout spaces with **moderation affordances**: the default report and mute tools, and the ability to leave or teleport away from harassment.
- **Trading** between players attracts scams. Use a two-step confirmation screen showing both sides clearly, a cooldown, value warnings ("This trade looks unfair!"), and check `IsPaidItemTradingAllowed`.

### 7.3 Parental controls: what they change for your game

Parents can link accounts and control **chat**, **content maturity level**, **Approved Experiences** for Kids accounts (they may need to approve your game explicitly), **spending limits and notifications**, **screen time** limits, and friend visibility. Design consequences:
- **Spending may be blocked or capped.** Purchases can fail, and the game must handle it gracefully (no soft-lock, no shaming). Always have a free path.
- **Screen-time limits end sessions abruptly.** Autosave often (every 60–120 s and at milestones), make sessions resumable, and design 10–15-minute session arcs.
- The **content level** filters discovery, which is why an accurate maturity label matters.

### 7.4 Ethical monetization and engagement for kids (operational view)

Details are in the monetization chapter. The live-ops rules:
- No **false urgency** ("Only 2 minutes left to buy!" when that is untrue), no disguised ads, no bait-and-switch "FREE" claims, and no pre-loaded purchase prompts. These are explicitly banned in notifications, and Roblox's guidelines extend the same spirit to in-game design.
- **Clear prices and contents** before purchase, and **paid random items** shown with odds and gated by `ArePaidRandomItemsRestricted`.
- Daily rewards and streaks must be forgiving (1.7). Don't punish a child for a weekend away.
- Paid boosts must not be required to complete an event on time.

---

## 8. Putting it together: a minimal live-ops starter kit for a new game

| Component | Implementation | Section |
|---|---|---|
| `LiveConfig` module | ConfigService + defaults + refresh | 1.4 |
| Event framework | config flags + UTC windows + season-keyed data | 1.5 |
| Daily streak | UpdateAsync idempotent claim | 1.7 |
| Quest rotation | deterministic day-seeded selection | 1.8 |
| Codes | server-only list, rate limit, per-user atomic record | 1.9 |
| Admin | TextChatCommand + rank levels + audit + BanAsync | 1.10 |
| Restart handling | ServerRestartScheduled banner + BindToClose save | 1.11 |
| What's New | versioned log, lastSeenVersion | 1.12 |
| Data migrations | `version` field + append-only steps + snapshot before deploy | 1.13 |
| Feedback | PromptFeedbackSubmissionAsync + bug button | 3.1 |
| Invites/parties | CanSendGameInviteAsync → PromptGameInvite; PartyId grouping | 4.1–4.2 |
| Notifications | in-context PromptOptIn + personalized MOMENT notifications | 4.3 |
| Chat-safe comms | Quick Words, pings; platform-integrated-chat compatible | 4.5 |
| Localization | ATC on, keys + Loc helper, CSV for review | 5 |
| Accessibility | PreferredTextSize/Transparency/ReducedMotion + settings menu | 6 |
| Audience reach | full questionnaire, Kids/Select requirements | 7.1 |

**Weekly live-ops routine** (to turn into a checklist):
1. Monday: review analytics (D1/D7 retention, session length, event participation), feedback, and bug reports. Pick the fixes.
2. Tuesday to Thursday: build the update in staging, put new content behind flags, prepare localization keys and upload the CSV.
3. Thursday: write the update log, record clips and Shorts, and schedule the update announcement and code.
4. Friday or Saturday: take a snapshot if the save format changed, publish, restart outdated servers with a delay, flip the flags, post the code on Discord and X, and set the game description headline.
5. During the following hour: monitor errors and the economy, and be ready to toggle flags off.
6. Off-week: run a config-only event (double XP, a rotating quest theme, a leaderboard season) and post a new code.

---

## Sources

Local creator-docs snapshot (`/home/user/Roblox/reference/creator-docs/content/en-us`):
- `production/configs.md`, `production/experiments.md`; `reference/engine/classes/ConfigService.yaml`, `ConfigSnapshot.yaml`
- `projects/update-games.md` (Restart servers, `ServerRestartScheduled`); `reference/engine/classes/DataModel.yaml`; `reference/engine/enums/CloseReason.yaml`; `reference/engine/classes/TeleportOptions.yaml`
- `cloud-services/data-stores/versioning-listing-and-caching.md` (versions, snapshots), `cloud-services/data-stores/best-practices.md`, `cloud-services/data-stores/right-to-be-forgotten.md`, `cloud-services/memory-stores/*`, `cloud-services/data-stores-vs-memory-stores.md`
- `production/bans.md`; `reference/engine/classes/Players.yaml` (BanAsync/UnbanAsync); `Player.yaml` (GetRankInGroupAsync, IsInGroupAsync, PartyId)
- `chat/platform-integrated-chat.md`, `chat/quick-words.md`, `chat/examples/custom-text-chat-commands.md`, `chat/voice-chat.md`, `chat/in-experience-text-chat.md`; `reference/engine/classes/TextChatService.yaml`, `TextChatCommand.yaml`, `VoiceChatService.yaml`, `TextFilterResult.yaml`
- `production/promotion/experience-notifications.md` (+ `includes/experience-notifications/*`), `invite-prompts.md`, `referral-system.md`, `share-links.md`, `social-media-links.md`, `experience-events.md`, `content-maturity.md`, `regional-content-availability.md`
- `production/publishing/kids-and-select.md`, `production/publishing/accessibility.md`, `production/roblox-user-base.md`
- `reference/engine/classes/SocialService.yaml` (PromptFeedbackSubmissionAsync, GetPartyAsync, GetPlayersByPartyId, PromptLinkSharingAsync, CanSendCallInviteAsync), `ExperienceNotificationService.yaml`, `PolicyService.yaml`, `CaptureService.yaml`, `GuiService.yaml`, `enums/PreferredTextSize.yaml`
- `production/localization/index.md`, `automatic-translations.md`, `localize-with-scripting.md`, `translate-dynamic-content.md`, `auto-translate-dynamic-content.md`, `add-translations.md`, `manual-translations.md`, `work-with-translators.md`, `language-codes.md`; `reference/engine/classes/LocalizationService.yaml`, `Translator.yaml`

Web (accessed 2026-11-05; treated as data):
- Roblox Newsroom, "Roblox Requires Users Worldwide to Age Check to Access Chat" (Jan 2026): https://about.roblox.com/newsroom/2026/01/roblox-age-checks-required-to-chat
- Roblox Newsroom, "Roblox requires age checks, limits minor and adult chat" (Nov 2025): https://about.roblox.com/newsroom/2025/11/roblox-requires-age-checks-limits-minor-and-adult-chat
- PC Gamer coverage of age bands: https://www.pcgamer.com/gaming-industry/roblox-to-make-facial-age-checks-mandatory-to-access-any-chat-features-and-will-put-common-sense-limits-on-the-age-ranges-users-can-chat-within
- DevForum, "Introducing Roblox Communities": https://devforum.roblox.com/t/introducing-roblox-communities/3268307
- Community walls retired (2026): https://piunikaweb.com/2026/04/01/roblox-community-walls-retired-end-of-march/
- Roblox Moments announcement (Sept 2025): https://devforum.roblox.com/t/roblox-moments-a-new-era-of-user-generated-discovery-for-experiences-and-gameplay-is-here/3919813 ; https://about.roblox.com/newsroom/2025/09/roblox-moments-user-generated-discovery ; https://techcrunch.com/2025/09/05/roblox-announces-short-form-video-feed-for-gameplay-clips-new-ai-tools-for-creators-and-more
- Roblox Connect shutdown (July 2026): https://www.gadgetpilipinas.net/2026/07/roblox-ends-connect-avatar/ ; https://www.prismnews.com/news/roblox-to-shut-down-avatar-video-calling-service-connect
- Real-time translation API announcement: https://devforum.roblox.com/t/introducing-the-real-time-translation-api/3550206
- Regional DAU growth (Q3 2025): https://gamesbeat.com/roblox-had-151m-daily-active-users-in-q3-2025/
- Language priority (community data, anecdotal): https://devforum.roblox.com/t/psa-which-languages-should-you-translate-to/1419183 ; https://devforum.roblox.com/t/what-are-the-top-languages-to-translate-my-game-to/380906
- Rewarding likes/favorites (community guidance): https://devforum.roblox.com/t/is-rewarding-players-for-liking-favoriting-a-game-allowed/2926286
