# 11 — Multiplayer, Physics & Combat Systems

> Chapter scope: **gameplay systems** for original Roblox multiplayer games: netcode, hit detection, melee, projectiles, guns, abilities, status effects, damage, NPC waves, vehicles, physics movers, character controllers, rounds/lobbies/matchmaking, inventory, trading, leaderboards, cross-server events, anti-exploit, and cross-device input.
> General Luau architecture, DataStore basics and remote basics live in other chapters. This one assumes you know `RemoteEvent`, `ModuleScript`, and `pcall`.
> APIs checked against the local engine API dump (`reference/api/API-Dump.txt`) and creator-docs snapshot, as of 2026-11-05.

---

## TL;DR rules for the bot

1. **The server owns damage, health, currency, inventory, cooldowns and round state.** Clients send *intent* ("attack, aiming here"), never results ("I hit X for 50").
2. **Pick the netcode model first.** Default: **classic** (`Workspace.AuthorityMode = Automatic`). The client owns its character, and the server validates combat. For competitive FPS, fighting, racing or sports, consider **Server Authority** (`AuthorityMode = Server`, opt-in, fully released in 2026), which gives prediction and rollback via `RunService:BindToSimulation()` (§2).
3. **Hit detection: use spatial queries, not `Touched`.** `Raycast` for hitscan, `Blockcast`/`Spherecast`/`Shapecast` for sweeps, and `GetPartBoundsInBox`/`GetPartBoundsInRadius`/`GetPartsInPart` with `OverlapParams` for instant hitboxes. `Touched` is only for slow triggers (pickups, zones).
4. **Every combat remote handler:** `typeof`-check every argument, reject NaN and infinity, rate-limit per player, check alive and not stunned, check the cooldown on a *server* clock, and check range and line of sight against *server* positions plus a ping tolerance.
5. **All damage goes through one function** (`DamageService.Apply`): i-frames, block, parry, armor, kill and assist attribution, death event. Nothing else writes `Humanoid.Health`.
6. **Combat state lives in server-written attributes** on the character (`StunnedUntil`, `Blocking`, `IFrameUntil`). They replicate for UI, and they act as synced state under Server Authority.
7. **Knockback runs where the physics runs.** A player character is client-owned, so fire their client (or briefly `SetNetworkOwner(nil)`). NPCs are server-owned, so `ApplyImpulse` on the server.
8. **Use modern movers:** `LinearVelocity`, `AngularVelocity`, `AlignPosition`, `AlignOrientation`, `VectorForce`, `ApplyImpulse`. Never use the deprecated `BodyVelocity`/`BodyGyro`/`BodyPosition`/`BodyForce`.
9. **Projectiles:** the client renders instantly. The server validates origin, rate and ammo, simulates the same raycast-stepped ballistic path, and decides hits. Other clients get cosmetic copies (an `UnreliableRemoteEvent` is fine).
10. **Lag compensation:** keep about 1 s of server position history and rewind targets by about `ping/2 + interp`, **capped at about 250 ms**.
11. **NPCs:** `SetNetworkOwner(nil)`, one shared AI loop at 4–10 Hz, a cap on the number alive, collision groups, `Debris` for corpses.
12. **Vehicles:** the driver gets network ownership on `Occupant` change, and `SetNetworkOwnershipAuto()` on exit. Use `HingeConstraint` motor and servo plus spring suspension.
13. **`TeleportService:ReserveServer(Async)`, `TeleportOptions.ShouldReserveServer` and `ReservedServerAccessCode` are DEPRECATED.** Set `TeleportOptions.ReservedServerId = HttpService:GenerateGUID(false)` and call `TeleportAsync`. Wrap it in `pcall` with retries, and handle `TeleportInitFailed`.
14. **Cross-server matchmaking:** a `MemoryStoreQueue` (one entry per party), a reader packs a match, `MessagingService` announces it, and every lobby server teleports its players with the same `ReservedServerId`.
15. **Trades:** a server-side state machine with offer, both ready, countdown, both confirm, re-verify, swap in one non-yielding block, journal. Any offer change resets both. Items have unique ids.
16. **Global leaderboards:** `OrderedDataStore` with integer values. Write on a throttle and on leave. Read with `GetSortedAsync(false, ≤100)` every 60 s or more, and cache it.
17. **MessagingService** is limited to 1 kB and is best-effort. Use it for announcements and match notices, never as the only record of anything valuable.
18. **Input:** the **Input Action System** (`InputContext`/`InputAction`/`InputBinding`) is released and required under Server Authority. Give every action keyboard/mouse, gamepad and touch (`UIButton`) bindings. Use `UserInputService.PreferredInput` for adaptive UI.
19. Use `Player:LoadCharacterAsync()` (`LoadCharacter` is deprecated) and `Humanoid:ApplyDescriptionAsync()` (`ApplyDescription` is deprecated).
20. Under Server Authority, **`Tool`s are not fully supported**, so use welded models plus an attribute.
21. **Anti-exploit is server math:** position-delta speed checks, floor raycasts for fly, rate limits, damage validation. Log first, kick only on extreme repeated violations.
22. **Clocks:** `workspace:GetServerTimeNow()` for shared UI timers, `os.clock()` for server-only checks, `time()` inside `BindToSimulation`.

---

## 1. Networking model and latency

### 1.1 What replicates and who simulates

- Server changes replicate to clients (subject to streaming). Client changes **don't** replicate, except the physics of parts the client **owns** (its own character, nearby unanchored parts), plus some Humanoid and Animator state. **An owning client can lie** about position, which is how speed, fly and teleport hacks work.
- Anchored parts are always server-owned. Server-set attributes replicate.
- `RemoteEvent`: reliable, ordered per remote. `UnreliableRemoteEvent`: unordered, may drop, about 1000-byte payload. Good for cosmetic, high-frequency data.
- Remote rate limit: about **500 requests per second per client, shared across all remotes of the same type**. Your per-feature limits should be far stricter.

### 1.2 Latency facts

- `Player:GetNetworkPing()` returns **round-trip** seconds (typically 0.05–0.2). One-way delay is about ping/2.
- Other players are rendered **in the past**: one-way latency plus an interpolation buffer (community estimates are 50–100 ms; undocumented, so make it a constant).
- A shot that hits on A's screen lands about `pingA/2 + interp + pingB/2` behind B's server position. Without lag compensation, fair shots miss. Uncapped, players get hit behind walls. **Cap the rewind at 200–300 ms.**

### 1.3 Techniques

| Technique | On Roblox |
|---|---|
| **Client prediction** (show the result of input now) | Classic: play the anim/VFX locally on input. The character moves locally anyway. Server Authority: built in. |
| **Server reconciliation** (server corrects a wrong guess) | Classic: the server rejects the action, and the client undoes the UI/VFX on a "denied" reply. Server Authority: automatic rollback and resimulation. |
| **Lag compensation** (judge hits where targets *were*) | Position history plus rewind (§1.5) |
| **Interpolation/smoothing** | The engine interpolates physics. For custom state, lerp in `RenderStepped` or use `TweenService:SmoothDamp`. |

### 1.4 Shared clock

```lua
-- Anywhere (client or server): a clock synchronized to the server
local now = workspace:GetServerTimeNow()

-- Server: publish a cooldown end time for UI
player:SetAttribute("Cd_Dash", workspace:GetServerTimeNow() + 4)

-- Client UI: remaining = math.max(0, player:GetAttribute("Cd_Dash") - workspace:GetServerTimeNow())
```

Never trust a client-sent timestamp for authority. You may use it, clamped, as a *hint* for how far to rewind: `rewind = math.clamp(serverNow - clientTime, 0, MAX_REWIND)`.

### 1.5 Lag-compensation position history (server)

```lua
--!strict
-- ServerScriptService/Combat/PositionHistory.luau
-- Records each character's HumanoidRootPart CFrame every Heartbeat for HISTORY_SECONDS.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local HISTORY_SECONDS = 1.0
local MAX_REWIND = 0.25 -- never rewind more than this (fairness vs "shot behind wall")

type Sample = { t: number, cf: CFrame }
local history: { [Model]: { Sample } } = {}

local PositionHistory = {}

RunService.Heartbeat:Connect(function()
	local now = os.clock()
	for _, player in Players:GetPlayers() do
		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
		if char and root then
			local buf = history[char]
			if not buf then
				buf = {}
				history[char] = buf
				char.Destroying:Connect(function() history[char] = nil end)
			end
			table.insert(buf, { t = now, cf = root.CFrame })
			while #buf > 0 and now - buf[1].t > HISTORY_SECONDS do
				table.remove(buf, 1)
			end
		end
	end
end)

-- Returns the root CFrame `secondsAgo` in the past (interpolated), or nil.
function PositionHistory.GetRootCFrameAt(char: Model, secondsAgo: number): CFrame?
	local buf = history[char]
	if not buf or #buf == 0 then return nil end
	local target = os.clock() - math.clamp(secondsAgo, 0, MAX_REWIND)
	for i = #buf, 2, -1 do
		local a, b = buf[i - 1], buf[i]
		if a.t <= target and target <= b.t then
			local alpha = (target - a.t) / math.max(b.t - a.t, 1e-6)
			return a.cf:Lerp(b.cf, alpha)
		end
	end
	return buf[1].cf
end

-- Typical rewind for a shot from `shooter`: their one-way delay plus an interpolation estimate.
function PositionHistory.RewindFor(shooter: Player): number
	local INTERP_ESTIMATE = 0.08
	return math.clamp(shooter:GetNetworkPing() / 2 + INTERP_ESTIMATE, 0, MAX_REWIND)
end

return PositionHistory
```

> `table.remove(buf, 1)` is O(n), which is fine at about 60 entries per character. For 50+ players, use a ring buffer.

---

## 2. Choosing a netcode model: classic vs Server Authority

| | **Classic (`AuthorityMode.Automatic`)** | **Server Authority (`AuthorityMode.Server`)** |
|---|---|---|
| Character physics | Client-owned, exploitable (speed/fly) | Server-owned, predicted on the client with rollback |
| Your combat code | Remotes plus server validation (this chapter's main samples) | Logic in a shared ModuleScript bound with `RunService:BindToSimulation(fn, frequency?, priority?)` on **both** client and server |
| Input | Any (UIS / CAS / IAS / remotes) | `InputAction`s for all simulation-affecting input. `InputContext`s must be **descendants of the Player**. |
| State sync | Attributes and remotes, server-written | Attributes on predicted instances. A mismatch triggers rollback. Write them **only inside bound functions**. |
| Time | `os.clock()` server side | `time()` (fixed-step, synced, rewinds). **Not** `tick`/`os.clock`/`os.time` inside the simulation. |
| Tools | Supported | Not fully supported. Use welded models plus an attribute. |
| Instance removal / cost | Anywhere / normal | Not inside bound functions (flag it, then destroy in `RunService.PostSimulation`) / higher server utilization |
| Best for | Simulators, tycoons, obbies, RPGs, casual PvE/PvP | Competitive FPS, fighting games, racing, sports |

Setting `Workspace.AuthorityMode = Server` in Studio automatically sets `NextGenerationReplication`, `PlayerScriptsUseInputActionSystem`, `SignalBehavior = Deferred`, `UseFixedSimulation`, and `StreamingEnabled`. Prediction controls: `RunService:SetPredictionMode(instance, Enum.PredictionMode.Automatic|On|Off)` and `RunService:GetPredictionStatus(instance)` (client). Debug with Studio's server authority visualizer (Ctrl+Shift+F6).

Minimal server-authority skeleton (pattern from the official docs):

```lua
-- ReplicatedStorage/Simulation (ModuleScript), required by BOTH a server Script and a client LocalScript
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Simulation = {}

local DASH_COOLDOWN = 2

function Simulation.Initialize()
	RunService:BindToSimulation(function(dt: number)
		for _, player in Players:GetPlayers() do
			local char = player.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local inputs = player:FindFirstChild("Inputs") -- cloned per player by the server
			local dash = inputs and inputs:FindFirstChild("PlayContext")
				and inputs.PlayContext:FindFirstChild("Dash")
			if root and dash then
				local now = time() -- synced, rewinds on resimulation
				local ready = (root:GetAttribute("DashReadyAt") or 0) <= now
				if dash:GetState() == true and ready then
					root:ApplyImpulse(root.CFrame.LookVector * root.AssemblyMass * 60)
					root:SetAttribute("DashReadyAt", now + DASH_COOLDOWN)
				end
			end
		end
	end)
end

return Simulation
```

Effects (sounds, particles) go in `RenderStepped`. Read the synced attributes there, and be prepared to *undo* mispredicted effects. Design mechanics with wind-ups (fuses, cast times), because a delayed effect hides corrections better than an instant one.

**The rest of this chapter shows classic-model code**, since that's what most games ship. The validation logic (cooldowns, ranges, damage pipeline) carries over directly into bound simulation functions under Server Authority.

---

## 3. Hit detection approaches

### 3.1 The toolbox (all on `WorldRoot`, so `workspace` or a `WorldModel`)

| API | Shape | Use for | Notes |
|---|---|---|---|
| `Raycast(origin, direction, RaycastParams?)` | Line | Hitscan guns, LOS checks, ground checks, projectile steps | Direction magnitude ≤ 15,000 studs |
| `Blockcast(cframe, size, direction, params?)` | Swept box | Sword swings, wide beams | Size ≤ 512, distance ≤ 1024. **Misses parts that initially overlap the shape.** |
| `Spherecast(position, radius, direction, params?)` | Swept sphere | Thick projectiles, fists, "forgiving" bullets | Same initial-overlap caveat |
| `Shapecast(part, direction, params?, cframeOverride?, sizeOverride?)` | Swept arbitrary part | Weapon-shaped sweeps | |
| `GetPartBoundsInBox(cframe, size, OverlapParams?)` | Box AABB-ish | Instant melee hitbox, AoE | Cheap, uses bounding boxes |
| `GetPartBoundsInRadius(position, radius, OverlapParams?)` | Sphere | Explosions, auras | Bounding-box test |
| `GetPartsInPart(part, OverlapParams?)` | Exact geometry | Precise hitbox parts | More expensive |
| `ArePartsTouchingOthers(parts, overlapIgnored?)` | — | Placement validation | |

`RaycastParams` fields: `FilterDescendantsInstances` + `FilterType` (`Enum.RaycastFilterType.Exclude`/`Include`), the newer **`ExcludeInstances` / `IncludeInstances`** (you can use both together, and exclusion wins; `IncludeInstances = nil` means everything, `{}` means nothing), `IgnoreWater`, `CollisionGroup`, `RespectCanCollide`, `BruteForceAllSlow`, **`Margin`** (inflates the cast; a non-zero Margin on `Raycast` behaves as a sphere cast), **`SizeGradient`** (tapers or expands the swept shape), and `:AddToFilter(...)`.

`OverlapParams` fields: the same filter fields, `MaxParts`, `CollisionGroup`, `RespectCanCollide`, `Tolerance` (0–0.05), and `BruteForceAllSlow`.

Parts with `CanQuery = false` are invisible to all queries. Set this on VFX, hitbox visualizers and accessories to save cost and avoid false hits.

**`Touched` pitfalls:** it only fires on physics contact, so fast or thin parts tunnel through. It's reported by the **network owner's** simulation, so for client-owned characters it's late or spoofable. It fires once per limb and needs a debounce. A hitbox welded to an animated sword only moves on the client playing the animation. Use `Touched` only for pickups, kill bricks and zones on slow movers. For damage, use queries. To map query results to characters, walk up with `FindFirstAncestorOfClass("Model")` until you find a model with a `Humanoid`, and keep a `hit[model]` set so each target is hit once per swing. To debug, spawn an anchored, `CanQuery=false` `ForceField` box at the query CFrame and `Debris:AddItem` it after 0.25 s (Studio only).

---

## 4. Health and damage pipeline (with attribution)

One module owns all health changes. Melee, projectiles, abilities, NPCs and hazards all call it.

```lua
--!strict
-- ServerScriptService/Combat/DamageService.luau
local Players = game:GetService("Players")

export type DamageInfo = {
	Amount: number,
	Source: (Player | Model)?, -- attacker player, or NPC model
	Kind: string?,            -- "Melee" | "Projectile" | "Ability" | "Hazard" ...
	WeaponId: string?,
	Knockback: Vector3?,      -- world-space velocity change
	StunTime: number?,
	Unblockable: boolean?,
	Parryable: boolean?,
	Origin: Vector3?,         -- for block-direction checks
}

export type DamageResult = "Hit" | "Blocked" | "Parried" | "Immune" | "Invalid" | "Killed"

local ASSIST_WINDOW = 10 -- seconds
local BLOCK_DAMAGE_MULT = 0.2
local BLOCK_ARC_DOT = 0.2 -- the attacker must be roughly in front of the blocker

local DamageService = {}

-- Bindable-style callbacks (simple signal)
local killedListeners: { (victim: Model, killer: (Player | Model)?, assists: { Player }, info: DamageInfo) -> () } = {}
local damagedListeners: { (victim: Model, dealt: number, info: DamageInfo) -> () } = {}
function DamageService.OnKilled(fn) table.insert(killedListeners, fn) end
function DamageService.OnDamaged(fn) table.insert(damagedListeners, fn) end

-- Per-victim attribution log: attacker -> {damage, lastTime}
local attribution: { [Humanoid]: { [any]: { dmg: number, t: number } } } = {}

local function now() return os.clock() end

local function isFiniteNumber(x: any): boolean
	return type(x) == "number" and x == x and x ~= math.huge and x ~= -math.huge
end

function DamageService.IsImmune(char: Model): boolean
	return (char:GetAttribute("IFrameUntil") or 0) > now() or char:GetAttribute("Invulnerable") == true
end

local function facing(victimRoot: BasePart, origin: Vector3): boolean
	local toAttacker = (origin - victimRoot.Position) * Vector3.new(1, 0, 1)
	if toAttacker.Magnitude < 1e-3 then return true end
	return victimRoot.CFrame.LookVector:Dot(toAttacker.Unit) >= BLOCK_ARC_DOT
end

-- Applies knockback where the physics actually runs.
local KnockbackRemote: RemoteEvent? = nil
function DamageService.SetKnockbackRemote(r: RemoteEvent) KnockbackRemote = r end

function DamageService.ApplyKnockback(char: Model, velocity: Vector3)
	local root = char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then return end
	local owner = Players:GetPlayerFromCharacter(char)
	if owner and KnockbackRemote then
		-- Client-owned assembly: the victim's client must apply it.
		KnockbackRemote:FireClient(owner, velocity)
	else
		-- Server-owned (NPC): apply directly. Impulse = mass * deltaV
		root:ApplyImpulse(velocity * root.AssemblyMass)
	end
end

function DamageService.Apply(victimChar: Model, info: DamageInfo): DamageResult
	local hum = victimChar:FindFirstChildOfClass("Humanoid")
	local root = victimChar:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not hum or not root or hum.Health <= 0 then return "Invalid" end
	if not isFiniteNumber(info.Amount) or info.Amount <= 0 or info.Amount > 10_000 then return "Invalid" end

	-- Friendly fire / same team
	local attackerPlayer = if typeof(info.Source) == "Instance" and (info.Source :: Instance):IsA("Player")
		then info.Source :: Player else nil
	local victimPlayer = Players:GetPlayerFromCharacter(victimChar)
	if attackerPlayer and victimPlayer and attackerPlayer ~= victimPlayer
		and attackerPlayer.Team and attackerPlayer.Team == victimPlayer.Team
		and not victimPlayer.Neutral then
		return "Invalid"
	end

	if DamageService.IsImmune(victimChar) then return "Immune" end

	local amount = info.Amount
	-- Parry: a short window, reflects stun to the attacker
	if info.Parryable ~= false and (victimChar:GetAttribute("ParryUntil") or 0) > now()
		and info.Origin and facing(root, info.Origin) then
		local attackerChar = if attackerPlayer then attackerPlayer.Character
			elseif typeof(info.Source) == "Instance" and (info.Source :: Instance):IsA("Model") then info.Source :: Model
			else nil
		if attackerChar then
			attackerChar:SetAttribute("StunnedUntil", now() + 1.0)
		end
		return "Parried"
	end
	-- Block
	if not info.Unblockable and victimChar:GetAttribute("Blocking") == true
		and info.Origin and facing(root, info.Origin) then
		amount *= BLOCK_DAMAGE_MULT
		local guard = (victimChar:GetAttribute("Guard") or 100) - info.Amount
		victimChar:SetAttribute("Guard", math.max(guard, 0))
		if guard <= 0 then -- guard break
			victimChar:SetAttribute("Blocking", false)
			victimChar:SetAttribute("StunnedUntil", now() + 1.5)
		end
		if amount <= 0 then return "Blocked" end
	end

	-- Armor / resist multiplier from status effects (written by StatusEffects)
	local resist = victimChar:GetAttribute("DamageTakenMult") or 1
	amount = math.max(0, amount * resist)

	-- Attribution
	local log = attribution[hum]
	if not log then
		log = {}
		attribution[hum] = log
		hum.Destroying:Connect(function() attribution[hum] = nil end)
	end
	if info.Source then
		local entry = log[info.Source] or { dmg = 0, t = 0 }
		entry.dmg += math.min(amount, hum.Health)
		entry.t = now()
		log[info.Source] = entry
	end

	hum.Health = math.max(0, hum.Health - amount)

	if info.StunTime and info.StunTime > 0 then
		local current = victimChar:GetAttribute("StunnedUntil") or 0
		victimChar:SetAttribute("StunnedUntil", math.max(current, now() + info.StunTime))
	end
	if info.Knockback then
		DamageService.ApplyKnockback(victimChar, info.Knockback)
	end

	for _, fn in damagedListeners do task.spawn(fn, victimChar, amount, info) end

	if hum.Health <= 0 then
		local assists = {}
		for src, e in log do
			if src ~= info.Source and typeof(src) == "Instance" and src:IsA("Player")
				and now() - e.t <= ASSIST_WINDOW then
				table.insert(assists, src)
			end
		end
		for _, fn in killedListeners do task.spawn(fn, victimChar, info.Source, assists, info) end
		attribution[hum] = nil
		return "Killed"
	end
	return "Hit"
end

return DamageService
```

Notes:
- Using `os.clock()` for `StunnedUntil`/`IFrameUntil` works for *server-only checks*. If clients need to display these, also write a `workspace:GetServerTimeNow()`-based attribute, or just a boolean `Stunned` attribute the server toggles.
- Hook kill credit, for example: `DamageService.OnKilled(function(victim, killer, assists) if typeof(killer)=="Instance" and killer:IsA("Player") then addStat(killer,"Kills",1) end ... end)`.
- Turn off `Humanoid.BreakJointsOnDeath` if you want ragdolls (§13.4).

---

## 5. Status effects and buffs

```lua
--!strict
-- ServerScriptService/Combat/StatusEffects.luau
local RunService = game:GetService("RunService")
local DamageService = require(script.Parent.DamageService)

type EffectDef = {
	Duration: number, Stacking: "Refresh" | "Stack" | "Ignore", MaxStacks: number?,
	TickInterval: number?, OnTick: ((char: Model, stacks: number, source: any) -> ())?,
	WalkSpeedMult: number?, DamageTakenMult: number?, DamageDealtMult: number?,
}
local DEFS: { [string]: EffectDef } = {
	Burn = { Duration = 4, Stacking = "Stack", MaxStacks = 5, TickInterval = 0.5,
		OnTick = function(char, stacks, source)
			DamageService.Apply(char, { Amount = 2 * stacks, Source = source, Kind = "DoT", Unblockable = true, Parryable = false })
		end },
	Slow = { Duration = 3, Stacking = "Refresh", WalkSpeedMult = 0.6 },
	Haste = { Duration = 5, Stacking = "Refresh", WalkSpeedMult = 1.35 },
	Fortify = { Duration = 6, Stacking = "Ignore", DamageTakenMult = 0.7 },
}
local BASE_WALKSPEED = 16

type Active = { def: EffectDef, expires: number, stacks: number, nextTick: number, source: any }
local active: { [Model]: { [string]: Active } } = {}
local StatusEffects = {}

local function recompute(char: Model)
	local ws, taken, dealt = 1, 1, 1
	for id, a in active[char] or {} do
		ws *= a.def.WalkSpeedMult or 1
		taken *= a.def.DamageTakenMult or 1
		dealt *= a.def.DamageDealtMult or 1
		char:SetAttribute("Effect_" .. id, true) -- UI icon flag
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local stunned = (char:GetAttribute("StunnedUntil") or 0) > os.clock()
	if hum then hum.WalkSpeed = if stunned then 0 else BASE_WALKSPEED * ws end
	char:SetAttribute("DamageTakenMult", taken)
	char:SetAttribute("DamageDealtMult", dealt)
end

function StatusEffects.Apply(char: Model, id: string, source: any?)
	local def = DEFS[id]
	if not def then return end
	local list = active[char]
	if not list then
		list = {}
		active[char] = list
		char.Destroying:Connect(function() active[char] = nil end)
	end
	local t, a = os.clock(), list[id]
	if a then
		if def.Stacking == "Ignore" then return end
		if def.Stacking == "Stack" then a.stacks = math.min(a.stacks + 1, def.MaxStacks or 99) end
		a.expires, a.source = t + def.Duration, source
	else
		list[id] = { def = def, expires = t + def.Duration, stacks = 1,
			nextTick = t + (def.TickInterval or math.huge), source = source }
	end
	recompute(char)
end

-- One 10 Hz loop for every effect (not a thread per effect)
local accum = 0
RunService.Heartbeat:Connect(function(dt)
	accum += dt
	if accum < 0.1 then return end
	accum = 0
	local t = os.clock()
	for char, list in active do
		for id, a in list do
			if a.def.OnTick and t >= a.nextTick then
				a.nextTick += a.def.TickInterval :: number
				task.spawn(a.def.OnTick, char, a.stacks, a.source)
			end
			if t >= a.expires then
				list[id] = nil
				char:SetAttribute("Effect_" .. id, nil)
			end
		end
		recompute(char) -- also restores WalkSpeed when a stun ends
	end
end)

return StatusEffects
```

Effects modify *derived* stats, so removal always restores the right value. For client timers, also write `Effect_<id>_End = workspace:GetServerTimeNow() + duration`.

---

## 6. Data-driven abilities and cooldowns

### 6.1 Design

Definitions are data, in `ReplicatedStorage` so the UI can read them. A **server-only** executor table maps `Id → function`. The server keeps authoritative charges, cooldowns and GCD on `os.clock()`, and mirrors them to `GetServerTimeNow()`-based attributes for UI. Every request is checked for type, ownership, alive and not stunned, cooldown, rate, and argument sanity.

```lua
--!strict
-- ReplicatedStorage/Shared/AbilityDefs.luau
export type AbilityDef = { Id: string, DisplayName: string, Cooldown: number, Charges: number?,
	CastTime: number?, GCD: number?, Range: number?, Icon: string?, RequiresAim: boolean? }

local Defs: { [string]: AbilityDef } = {
	Dash = { Id = "Dash", DisplayName = "Dash", Cooldown = 3, Charges = 2, GCD = 0.2 },
	Fireball = { Id = "Fireball", DisplayName = "Fireball", Cooldown = 6, CastTime = 0.35, GCD = 0.5, Range = 120, RequiresAim = true },
	Shockwave = { Id = "Shockwave", DisplayName = "Shockwave", Cooldown = 10, CastTime = 0.5, GCD = 0.5, Range = 14 },
}
return Defs
```

```lua
--!strict
-- ServerScriptService/Combat/AbilityService.server.luau
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AbilityDefs = require(ReplicatedStorage.Shared.AbilityDefs)
local DamageService = require(script.Parent.DamageService)
local StatusEffects = require(script.Parent.StatusEffects)
local Projectiles = require(script.Parent.ProjectileService) -- §8

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local UseAbility = Remotes:WaitForChild("UseAbility") :: RemoteEvent
local AbilityFeedback = Remotes:WaitForChild("AbilityFeedback") :: RemoteEvent -- (id, accepted, reason?)
local Knockback = Remotes:WaitForChild("Knockback") :: RemoteEvent
DamageService.SetKnockbackRemote(Knockback)

type PlayerState = { charges: { [string]: number }, nextChargeAt: { [string]: number },
	gcdUntil: number, casting: boolean, requestTimes: { number } }
local states: { [Player]: PlayerState } = {}
Players.PlayerRemoving:Connect(function(p) states[p] = nil end)

local MAX_REQUESTS_PER_SEC = 8

local function rateLimited(s: PlayerState): boolean
	local t, times = os.clock(), s.requestTimes
	while #times > 0 and t - times[1] > 1 do table.remove(times, 1) end
	if #times >= MAX_REQUESTS_PER_SEC then return true end
	table.insert(times, t)
	return false
end

local function ownsAbility(p: Player, id: string): boolean
	-- Replace with your profile/loadout check. Example: attribute "Dash,Fireball" set by the server.
	local loadout = p:GetAttribute("Loadout")
	return type(loadout) == "string" and table.find(string.split(loadout, ","), id) ~= nil
end

local function canAct(char: Model?): boolean
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	return hum ~= nil and hum.Health > 0 and ((char :: Model):GetAttribute("StunnedUntil") or 0) <= os.clock()
end

-- Lazily refill charges: each charge regenerates Cooldown seconds after the previous one
local function refreshCharges(s: PlayerState, def: AbilityDefs.AbilityDef)
	local max, t = def.Charges or 1, os.clock()
	local c = s.charges[def.Id] or max
	local nextAt = s.nextChargeAt[def.Id]
	while c < max and nextAt and t >= nextAt do
		c += 1
		nextAt = if c < max then nextAt + def.Cooldown else nil
	end
	s.charges[def.Id], s.nextChargeAt[def.Id] = c, nextAt :: any
end

local Executors: { [string]: (p: Player, char: Model, def: AbilityDefs.AbilityDef, aim: Vector3?) -> () } = {
	Dash = function(p, char)
		local root = char:FindFirstChild("HumanoidRootPart") :: BasePart
		Knockback:FireClient(p, (root.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit * 70) -- owner applies
		char:SetAttribute("IFrameUntil", os.clock() + 0.25)
		char:SetAttribute("DashingUntil", os.clock() + 0.4) -- whitelists the movement anti-cheat (§22)
	end,
	Fireball = function(p, char, def, aim)
		Projectiles.FireServerProjectile({
			Shooter = p, Origin = (char:FindFirstChild("Head") :: BasePart).Position, Direction = aim :: Vector3,
			Speed = 90, Gravity = 0, MaxDistance = def.Range or 120, Damage = 30,
			OnHit = function(hitChar: Model) StatusEffects.Apply(hitChar, "Burn", p) end,
		})
	end,
	Shockwave = function(p, char, def)
		local root = char:FindFirstChild("HumanoidRootPart") :: BasePart
		local params = OverlapParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { char }
		local hit: { [Model]: boolean } = {}
		for _, part in workspace:GetPartBoundsInRadius(root.Position, def.Range or 14, params) do
			local m = part:FindFirstAncestorOfClass("Model")
			local mRoot = m and m:FindFirstChild("HumanoidRootPart") :: BasePart?
			if m and mRoot and not hit[m] and m:FindFirstChildOfClass("Humanoid") then
				hit[m] = true
				local away = (mRoot.Position - root.Position) * Vector3.new(1, 0, 1)
				local dir = if away.Magnitude > 0 then away.Unit else root.CFrame.LookVector
				DamageService.Apply(m, { Amount = 20, Source = p, Kind = "Ability", WeaponId = "Shockwave",
					Knockback = dir * 50 + Vector3.new(0, 30, 0), StunTime = 0.6, Origin = root.Position })
			end
		end
	end,
}

UseAbility.OnServerEvent:Connect(function(player: Player, abilityId: unknown, aim: unknown)
	-- 1. Types and existence
	if type(abilityId) ~= "string" then return end
	local def = AbilityDefs[abilityId]
	if not def or not Executors[def.Id] then return end
	local s = states[player]
	if not s then
		s = { charges = {}, nextChargeAt = {}, gcdUntil = 0, casting = false, requestTimes = {} }
		states[player] = s
	end
	if rateLimited(s) then return end

	local aimVec: Vector3? = nil
	if def.RequiresAim then
		if typeof(aim) ~= "Vector3" then return end
		local v = aim :: Vector3
		if v ~= v or v.Magnitude < 0.5 or v.Magnitude > 1.5 then return end -- NaN / not ~unit
		aimVec = v.Unit
	end

	-- 2. Ownership and state
	local char = player.Character
	if not ownsAbility(player, def.Id) or not canAct(char) or s.casting then
		AbilityFeedback:FireClient(player, def.Id, false, "busy")
		return
	end
	local t = os.clock()
	refreshCharges(s, def)
	if t < s.gcdUntil or s.charges[def.Id] <= 0 then
		AbilityFeedback:FireClient(player, def.Id, false, "cooldown")
		return
	end

	-- 3. Commit the cost BEFORE yielding (prevents double casts during cast time)
	s.charges[def.Id] -= 1
	s.nextChargeAt[def.Id] = s.nextChargeAt[def.Id] or t + def.Cooldown
	s.gcdUntil = t + (def.GCD or 0)
	local offset = workspace:GetServerTimeNow() - t -- mirror on the shared clock for UI
	player:SetAttribute("Cd_" .. def.Id, (s.nextChargeAt[def.Id] or t) + offset)
	player:SetAttribute("Ch_" .. def.Id, s.charges[def.Id])
	AbilityFeedback:FireClient(player, def.Id, true)

	-- 4. Interruptible cast time
	if def.CastTime and def.CastTime > 0 then
		s.casting = true
		char:SetAttribute("Casting", def.Id)
		task.wait(def.CastTime)
		s.casting = false
		char:SetAttribute("Casting", nil)
		if not canAct(char) or player.Character ~= char then return end -- interrupted; cost stays spent
	end
	Executors[def.Id](player, char :: Model, def, aimVec)
end)
```

Client side, for responsiveness: play the cast animation and VFX immediately on input, gray out the button using `Cd_<Id> - workspace:GetServerTimeNow()`, and cancel the VFX if `AbilityFeedback` says `false`.

Client knockback receiver. The victim's client applies velocity to its own character, and clamps it, because even server bugs shouldn't fling players into orbit:

```lua
-- StarterPlayerScripts/KnockbackClient.client.luau
local Players = game:GetService("Players")
local Knockback = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Knockback")

Knockback.OnClientEvent:Connect(function(velocity: Vector3)
	local char = Players.LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root or velocity.Magnitude > 300 then return end
	root.AssemblyLinearVelocity = velocity -- crisp and mass-independent
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum and velocity.Y > 20 then hum:ChangeState(Enum.HumanoidStateType.Freefall) end
end)
```

---

## 7. Melee combat system

### 7.1 Architecture

The client sends `Attack()` (no arguments) and plays the swing locally. The server validates alive, not stunned, not blocking, not casting, and not mid-step. It advances the **server-owned** combo index, waits the wind-up, sweeps `GetPartBoundsInBox` from the attacker's **server** root CFrame (padded for lag) over the active window, checks LOS, calls `DamageService.Apply` (block, parry, i-frames, stun, knockback), and broadcasts a cosmetic `HitConfirm`.

Client-reported hit lists are trivial to forge ("I hit everyone within 200 studs"). A padded server box is fair at melee ranges of 5–8 studs. If you need pixel-perfect melee, accept client-reported targets, but validate each one against `PositionHistory` (rewound distance ≤ range + tolerance, facing, one hit per swing).

### 7.2 Weapon data

```lua
--!strict
-- ReplicatedStorage/Shared/MeleeDefs.luau
export type ComboStep = {
	Damage: number,
	Windup: number,      -- seconds from input to active frames
	Active: number,      -- seconds the hitbox is "live" (sampled a few times)
	Recovery: number,    -- seconds after active before next input accepted
	HitboxSize: Vector3,
	HitboxOffset: CFrame, -- relative to root
	Stun: number,
	Knockback: number,   -- horizontal speed
	Launch: number?,     -- vertical speed
	Anim: string,        -- rbxassetid://...
}
export type MeleeDef = { Id: string, ComboResetTime: number, Steps: { ComboStep } }

local function step(dmg, windup, active, recovery, depth, stun, kb, launch): ComboStep
	return { Damage = dmg, Windup = windup, Active = active, Recovery = recovery,
		HitboxSize = Vector3.new(4.5, 5, depth), HitboxOffset = CFrame.new(0, 0, -depth / 2 - 1),
		Stun = stun, Knockback = kb, Launch = launch, Anim = "rbxassetid://0" } -- use your own anims
end

local Defs: { [string]: MeleeDef } = {
	Fists = { Id = "Fists", ComboResetTime = 0.9, Steps = {
		step(6, 0.12, 0.10, 0.18, 4.5, 0.35, 4),
		step(6, 0.12, 0.10, 0.18, 4.5, 0.35, 4),
		step(8, 0.15, 0.12, 0.22, 5, 0.45, 6),
		step(12, 0.25, 0.15, 0.50, 6, 0.8, 45, 25), -- finisher: launches, long recovery = counterplay
	} },
}
return Defs
```


### 7.3 Complete server-validated melee (server)

```lua
--!strict
-- ServerScriptService/Combat/MeleeService.server.luau
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MeleeDefs = require(ReplicatedStorage.Shared.MeleeDefs)
local DamageService = require(script.Parent.DamageService)

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local AttackRemote = Remotes:WaitForChild("MeleeAttack") :: RemoteEvent
local BlockRemote = Remotes:WaitForChild("MeleeBlock") :: RemoteEvent
local HitConfirm = Remotes:WaitForChild("MeleeHitConfirm") :: UnreliableRemoteEvent -- cosmetic

local LAG_PAD = 1.5        -- studs of hitbox padding for latency
local ACTIVE_SAMPLES = 3   -- hitbox checks across the active window
local PARRY_WINDOW = 0.18

type Swing = { busyUntil: number, combo: number, lastStepEnd: number, id: number }
local swings: { [Player]: Swing } = {}
local lastBlockStart: { [Player]: number } = {}
Players.PlayerRemoving:Connect(function(p) swings[p] = nil lastBlockStart[p] = nil end)

local function now() return os.clock() end
local function stunned(char: Model) return (char:GetAttribute("StunnedUntil") or 0) > now() end

local function getWeapon(player: Player): MeleeDefs.MeleeDef
	local id = player:GetAttribute("EquippedMelee") -- set by the server's equip logic only
	return (type(id) == "string" and MeleeDefs[id]) or MeleeDefs.Fists
end

local function playAnim(hum: Humanoid, animId: string)
	local animator = hum:FindFirstChildOfClass("Animator")
	if not animator or animId == "rbxassetid://0" then return end
	local anim = Instance.new("Animation")
	anim.AnimationId = animId
	local track = animator:LoadAnimation(anim) -- cache per animId in production
	track.Priority = Enum.AnimationPriority.Action
	track:Play(0.05)
end

local function sweep(player: Player, char: Model, root: BasePart, step: MeleeDefs.ComboStep, hit: { [Model]: boolean })
	-- Hitbox from the SERVER's view of the attacker, padded for lag
	local cf = root.CFrame * step.HitboxOffset * CFrame.new(0, 0, -LAG_PAD / 2)
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { char }
	params.MaxParts = 64
	local los = RaycastParams.new()
	los.FilterType = Enum.RaycastFilterType.Exclude

	for _, part in workspace:GetPartBoundsInBox(cf, step.HitboxSize + Vector3.new(LAG_PAD, 0, LAG_PAD), params) do
		local model = part:FindFirstAncestorOfClass("Model")
		local hum = model and model:FindFirstChildOfClass("Humanoid")
		local tRoot = model and model:FindFirstChild("HumanoidRootPart") :: BasePart?
		if model and hum and tRoot and hum.Health > 0 and not hit[model] then
			hit[model] = true -- one hit per target per swing
			los.FilterDescendantsInstances = { char, model }
			if not workspace:Raycast(root.Position, tRoot.Position - root.Position, los) then -- no hits through walls
				local flat = (tRoot.Position - root.Position) * Vector3.new(1, 0, 1)
				local dir = if flat.Magnitude > 0.01 then flat.Unit else root.CFrame.LookVector
				local result = DamageService.Apply(model, {
					Amount = step.Damage * (char:GetAttribute("DamageDealtMult") or 1),
					Source = player, Kind = "Melee", WeaponId = getWeapon(player).Id,
					Knockback = dir * step.Knockback + Vector3.new(0, step.Launch or 0, 0),
					StunTime = step.Stun, Origin = root.Position,
				})
				if result ~= "Invalid" and result ~= "Immune" then
					HitConfirm:FireAllClients(model, result, tRoot.Position)
				end
			end
		end
	end
end

AttackRemote.OnServerEvent:Connect(function(player: Player)
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not char or not hum or not root or hum.Health <= 0 then return end
	if stunned(char) or char:GetAttribute("Blocking") or char:GetAttribute("Casting") then return end

	local s = swings[player] or { busyUntil = 0, combo = 0, lastStepEnd = 0, id = 0 }
	swings[player] = s
	local t = now()
	if t < s.busyUntil then return end -- mid-step: drop (the client buffers)

	-- The server owns the combo counter: clients can't skip to the finisher
	local weapon = getWeapon(player)
	if t - s.lastStepEnd > weapon.ComboResetTime or s.combo >= #weapon.Steps then s.combo = 0 end
	s.combo += 1
	local step = weapon.Steps[s.combo]
	s.busyUntil = t + step.Windup + step.Active + step.Recovery
	s.id += 1
	local myId = s.id
	char:SetAttribute("Attacking", true)
	playAnim(hum, step.Anim)

	task.wait(step.Windup)
	if not stunned(char) and hum.Health > 0 and s.id == myId then -- stunned during windup = trade lost
		local hit: { [Model]: boolean } = {}
		for i = 1, ACTIVE_SAMPLES do
			sweep(player, char, root, step, hit)
			if i < ACTIVE_SAMPLES then task.wait(step.Active / (ACTIVE_SAMPLES - 1)) end
		end
		s.lastStepEnd = now()
		task.wait(step.Recovery)
	end
	if s.id == myId and char.Parent then char:SetAttribute("Attacking", false) end
end)

-- Hold to block; the first PARRY_WINDOW seconds of a block are a parry (no parry-mashing).
BlockRemote.OnServerEvent:Connect(function(player: Player, holding: unknown)
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if type(holding) ~= "boolean" or not char or not hum or hum.Health <= 0 then return end
	if holding then
		if stunned(char) or char:GetAttribute("Attacking") then return end
		if now() - (lastBlockStart[player] or 0) > 0.6 then char:SetAttribute("ParryUntil", now() + PARRY_WINDOW) end
		lastBlockStart[player] = now()
		char:SetAttribute("Blocking", true)
		hum.WalkSpeed = 8
	else
		char:SetAttribute("Blocking", false)
		char:SetAttribute("ParryUntil", 0)
		hum.WalkSpeed = 16 -- or let StatusEffects recompute
	end
end)
-- Guard regen: a 0.5 s loop adding +5 "Guard" while not blocking (omitted).
```

### 7.4 Melee client

On input, play the swing animation and whoosh locally for instant feel, then `MeleeAttack:FireServer()` with no arguments (the server owns the combo). Keep a local pacing gate (about 0.3 s), and **buffer** presses that arrive up to 0.25 s early, firing them when the gate opens. Send `MeleeBlock:FireServer(true/false)` on press/release (`UserInputState.End` *or* `Cancel`). Use `MeleeHitConfirm` only for sparks, sounds, damage numbers and a 60 ms hit-stop.

### 7.5 Melee design checklist

- **Stun:** `StunnedUntil` blocks actions and zeroes WalkSpeed (via StatusEffects). Add stun immunity after N consecutive hits to stop infinite combos.
- **I-frames** on dash, on getting up, and on spawn (2–3 s). **Hit-stop:** `track:AdjustSpeed(0)` for 50–80 ms on clients only.
- **Knockback:** the victim's client sets `AssemblyLinearVelocity`. NPCs get server `ApplyImpulse(mass * Δv)`. Long launches use a timed `LinearVelocity` (§11).
- **Block/parry facing:** dot product against the victim's `LookVector`. Back attacks ignore block.

---

## 8. Projectile systems (FastCast-style, server verified)

### 8.1 Concept

A FastCast-style projectile is a **math path stepped with raycasts**, not a physics part. Each frame, compute `p(t) = origin + v0·t + ½·g·t²` and raycast from the previous point to the new one. It can't tunnel, it's cheap, and it's deterministic, so client and server agree. FastCast and SecureCast (community modules) do this. The version below is self-contained. **Flow:** the client renders a cosmetic projectile immediately and sends `(weaponId, origin, direction)`. The server validates equip, fire rate, ammo, origin near the server head, and a unit direction. It then simulates the authoritative projectile, fast-forwarded by about ping/2, replicates cosmetic copies to everyone else, and applies damage on a server hit.

### 8.2 Shared ballistic stepper

```lua
--!strict
-- ReplicatedStorage/Shared/Ballistics.luau
local Ballistics = {}

export type CastState = {
	origin: Vector3, velocity: Vector3, gravity: Vector3,
	t: number, pos: Vector3, traveled: number, maxDistance: number,
	params: RaycastParams,
}

function Ballistics.New(origin: Vector3, direction: Vector3, speed: number, gravity: number,
	maxDistance: number, params: RaycastParams): CastState
	return {
		origin = origin, velocity = direction.Unit * speed, gravity = Vector3.new(0, -gravity, 0),
		t = 0, pos = origin, traveled = 0, maxDistance = maxDistance, params = params,
	}
end

function Ballistics.PositionAt(s: CastState, t: number): Vector3
	return s.origin + s.velocity * t + 0.5 * s.gravity * t * t
end

-- Advance by dt. Returns (hitResult?, finished)
function Ballistics.Step(s: CastState, dt: number): (RaycastResult?, boolean)
	local newT = s.t + dt
	local newPos = Ballistics.PositionAt(s, newT)
	local seg = newPos - s.pos
	local result = workspace:Raycast(s.pos, seg, s.params)
	if result then
		s.traveled += (result.Position - s.pos).Magnitude
		s.pos = result.Position
		s.t = newT
		return result, true
	end
	s.traveled += seg.Magnitude
	s.pos = newPos
	s.t = newT
	return nil, s.traveled >= s.maxDistance
end

return Ballistics
```

Bullet drop is just `gravity > 0` (`workspace.Gravity` is 196.2 studs/s² by default; use a fraction of it for game feel). To *aim* with drop, the client can offset aim upward. The server doesn't care, since it simulates whatever direction it was given.

### 8.3 Server projectile service

```lua
--!strict
-- ServerScriptService/Combat/ProjectileService.luau
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Ballistics = require(ReplicatedStorage.Shared.Ballistics)
local DamageService = require(script.Parent.DamageService)

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ReplicateRemote = Remotes:WaitForChild("ProjectileReplicate") :: UnreliableRemoteEvent
local ImpactRemote = Remotes:WaitForChild("ProjectileImpact") :: UnreliableRemoteEvent

export type FireArgs = { Shooter: Player, Origin: Vector3, Direction: Vector3, Speed: number, Gravity: number,
	MaxDistance: number, Damage: number, FastForward: number?, OnHit: ((Model) -> ())? }
type Live = { state: Ballistics.CastState, args: FireArgs }
local live: { Live } = {}
local ProjectileService = {}

local function onHit(p: Live, result: RaycastResult)
	local m = result.Instance:FindFirstAncestorOfClass("Model")
	while m and not m:FindFirstChildOfClass("Humanoid") do m = m:FindFirstAncestorOfClass("Model") end
	if m then
		local sc = p.args.Shooter.Character
		local mult = (sc and sc:GetAttribute("DamageDealtMult") or 1) * (if result.Instance.Name == "Head" then 1.5 else 1)
		local r = DamageService.Apply(m, { Amount = p.args.Damage * mult, Source = p.args.Shooter,
			Kind = "Projectile", Origin = p.state.origin, Knockback = p.state.velocity.Unit * 5 })
		if r ~= "Invalid" and p.args.OnHit then p.args.OnHit(m) end
	end
	ImpactRemote:FireAllClients(result.Position, result.Normal)
end

function ProjectileService.FireServerProjectile(args: FireArgs)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local ignore: { Instance } = {}
	if args.Shooter.Character then table.insert(ignore, args.Shooter.Character) end
	local fx = workspace:FindFirstChild("Effects") -- cosmetic folder
	if fx then table.insert(ignore, fx) end
	params.FilterDescendantsInstances = ignore
	local p: Live = { state = Ballistics.New(args.Origin, args.Direction, args.Speed, args.Gravity, args.MaxDistance, params), args = args }

	for _, other in Players:GetPlayers() do -- cosmetic copies for everyone else
		if other ~= args.Shooter then
			ReplicateRemote:FireClient(other, args.Origin, args.Direction, args.Speed, args.Gravity, args.MaxDistance)
		end
	end
	-- Lag compensation: pre-simulate the time the shot spent in transit (capped)
	local ff = math.clamp(args.FastForward or 0, 0, 0.2)
	if ff > 0 then
		local hit, done = Ballistics.Step(p.state, ff)
		if hit then return onHit(p, hit) end
		if done then return end
	end
	table.insert(live, p)
end

RunService.Heartbeat:Connect(function(dt)
	for i = #live, 1, -1 do
		local p = live[i]
		local hit, done = Ballistics.Step(p.state, dt)
		if hit then onHit(p, hit) end
		if hit or done then live[i] = live[#live]; live[#live] = nil end -- swap-remove
	end
end)

return ProjectileService
```

### 8.4 Fire remote with full validation

```lua
--!strict
-- ServerScriptService/Combat/GunService.server.luau
local Players = game:GetService("Players")
local ProjectileService = require(script.Parent.ProjectileService)
local FireRemote = game:GetService("ReplicatedStorage").Remotes:WaitForChild("ProjectileFire") :: RemoteEvent

local WEAPONS = {
	Crossbow = { RPM = 90, Speed = 220, Gravity = 40, Range = 600, Damage = 45, Mag = 1, Reload = 1.2 },
	Rifle = { RPM = 600, Speed = 900, Gravity = 10, Range = 1000, Damage = 18, Mag = 30, Reload = 2.0 },
}
local MAX_ORIGIN_OFFSET = 6 -- studs from the server head (lag + muzzle offset)

type Ammo = { mag: number, reloadingUntil: number, nextShot: number }
local ammo: { [Player]: { [string]: Ammo } } = {}
Players.PlayerRemoving:Connect(function(p) ammo[p] = nil end)

FireRemote.OnServerEvent:Connect(function(player: Player, weaponId: unknown, origin: unknown, direction: unknown)
	local w = type(weaponId) == "string" and WEAPONS[weaponId]
	if not w or player:GetAttribute("EquippedGun") ~= weaponId then return end
	if typeof(origin) ~= "Vector3" or typeof(direction) ~= "Vector3" then return end
	local o, d = origin :: Vector3, direction :: Vector3
	if o ~= o or d ~= d or math.abs(d.Magnitude - 1) > 0.01 then return end -- NaN / not unit

	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local head = char and char:FindFirstChild("Head") :: BasePart?
	if not hum or hum.Health <= 0 or not head or (o - head.Position).Magnitude > MAX_ORIGIN_OFFSET then return end
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Exclude
	rp.FilterDescendantsInstances = { char :: Model }
	if workspace:Raycast(head.Position, o - head.Position, rp) then return end -- origin behind a wall

	local per = ammo[player] or {}
	ammo[player] = per
	local a = per[weaponId :: string] or { mag = w.Mag, reloadingUntil = 0, nextShot = 0 }
	per[weaponId :: string] = a
	local t = os.clock()
	if t < a.reloadingUntil or t < a.nextShot - 0.02 then return end
	if a.mag <= 0 then a.reloadingUntil, a.mag = t + w.Reload, w.Mag return end
	a.mag -= 1
	-- "token bucket lite": tolerates jitter-bunched packets but can't exceed RPM over time
	a.nextShot = math.max(a.nextShot, t - 0.05) + 60 / w.RPM
	player:SetAttribute("Ammo_" .. (weaponId :: string), a.mag)

	ProjectileService.FireServerProjectile({ Shooter = player, Origin = o, Direction = d, Speed = w.Speed,
		Gravity = w.Gravity, MaxDistance = w.Range, Damage = w.Damage, FastForward = player:GetNetworkPing() / 2 })
end)
```

---

## 9. Guns: hitscan, recoil, spread, ADS

### 9.1 Hitscan with server rewind validation

For hitscan, the client raycasts locally for instant feedback and sends `(origin, direction, claimedTarget?)`. The server re-casts with **targets rewound** to the shooter's view.

```lua
--!strict
-- Server: validate a hitscan shot (call from your fire handler after rate/ammo checks)
local PositionHistory = require(script.Parent.PositionHistory)
local DamageService = require(script.Parent.DamageService)
local Players = game:GetService("Players")

local HIT_TOLERANCE = 3.5 -- studs between ray and rewound target root

local function closestDistanceRayToPoint(origin: Vector3, dir: Vector3, point: Vector3, maxLen: number): number
	local t = math.clamp((point - origin):Dot(dir), 0, maxLen)
	return ((origin + dir * t) - point).Magnitude
end

local function validateHitscan(shooter: Player, origin: Vector3, dir: Vector3, range: number, damage: number)
	local shooterChar = shooter.Character
	if not shooterChar then return end
	-- 1. World geometry: where does the ray stop (walls)?
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Exclude
	local chars = {}
	for _, p in Players:GetPlayers() do if p.Character then table.insert(chars, p.Character) end end
	rp.FilterDescendantsInstances = chars -- world only
	local wall = workspace:Raycast(origin, dir * range, rp)
	local maxLen = if wall then wall.Distance else range

	-- 2. Test rewound character positions
	local rewind = PositionHistory.RewindFor(shooter)
	local best: Model?, bestT = nil, math.huge
	for _, p in Players:GetPlayers() do
		local c = p.Character
		if c and c ~= shooterChar then
			local pastCF = PositionHistory.GetRootCFrameAt(c, rewind)
			if pastCF then
				local along = (pastCF.Position - origin):Dot(dir)
				if along > 0 and along <= maxLen
					and closestDistanceRayToPoint(origin, dir, pastCF.Position, maxLen) <= HIT_TOLERANCE
					and along < bestT then
					best, bestT = c, along
				end
			end
		end
	end
	if best then
		DamageService.Apply(best, { Amount = damage, Source = shooter, Kind = "Hitscan", Origin = origin })
	end
end
```

For headshots under rewind, store per-limb CFrames, or approximate the head as `pastCF * CFrame.new(0, 1.5, 0)` with a smaller tolerance. The tolerance-around-root approach is coarse but robust. Tighten it for competitive games.

### 9.2 Client: recoil, spread, ADS

```lua
-- Uniform random direction inside a cone of half-angle `angle` (spread)
local rng = Random.new()
local function spreadDirection(dir: Vector3, angle: number): Vector3
	local z = 1 - rng:NextNumber() * (1 - math.cos(angle))
	local theta = rng:NextNumber() * 2 * math.pi
	local r = math.sqrt(1 - z * z)
	return CFrame.lookAt(Vector3.zero, dir):VectorToWorldSpace(Vector3.new(r * math.cos(theta), r * math.sin(theta), -z))
end
-- per shot:  dir = spreadDirection(camera.CFrame.LookVector, (aiming and ADS or HIP) + (moving and MOVE_ADD or 0))
--            recoil += kick; camera.CFrame *= CFrame.Angles(kick, rng:NextNumber(-1, 1) * yawJitter, 0)
-- RenderStepped: back = recoil * math.min(1, RECOVER * dt); recoil -= back; camera.CFrame *= CFrame.Angles(-back * 0.7, 0, 0)
-- ADS: lerp camera.FieldOfView 70 -> 50 over ~0.15 s; UserInputService.MouseDeltaSensitivity = 1 - 0.4 * adsAlpha
```

- Spread is client-side for feel, and cheaters can send zero spread. For competitive games, use **deterministic spread**: the client sends aim plus a shot index, and both sides use `Random.new(seed + shotIndex)`.
- First person: `player.CameraMode = Enum.CameraMode.LockFirstPerson` plus a client-only viewmodel under the camera. Gamepad: R2 fires, L2 aims, add aim assist. Touch: auto-fire or a fire button, plus aim assist.

---

## 10. NPC enemies and wave spawners

### 10.1 NPC rules

- **Server-owned:** `root:SetNetworkOwner(nil)` after parenting. Otherwise a nearby client can take ownership and teleport or fling your NPCs.
- **Low-frequency brains:** one manager loop ticks all NPCs at 5–10 Hz and staggers expensive pathfinding. Don't put a script inside every NPC.
- **Movement:** `Humanoid:MoveTo(pos)` for open arenas. For mazes, use `PathfindingService:CreatePath({AgentRadius=..., AgentHeight=..., AgentCanJump=...})` + `path:ComputeAsync(from, to)` + `path:GetWaypoints()`, recomputed at most every ~1 s per NPC.
- **Collision groups:** put NPCs in an "NPC" group that doesn't collide with itself, so crowds don't jam (`PhysicsService:RegisterCollisionGroup`, `CollisionGroupSetCollidable`, `part.CollisionGroup = "NPC"`).
- **Cleanup:** `Debris:AddItem(model, 3)` after death, and cap alive NPCs (`MAX_ALIVE`).
- **Optimization:** disable unused Humanoid states (`SetStateEnabled` for `Climbing`, `Swimming`, `Seated`…). For big hordes, use anchored, CFrame-animated "dumb" enemies or AnimationController rigs with no Humanoid.

### 10.2 Complete wave spawner

Setup: `ServerStorage/Enemies/<Name>` (a Model with Humanoid and HumanoidRootPart), and `workspace/EnemySpawns` holding spawn parts.

```lua
--!strict
-- ServerScriptService/Waves/WaveService.luau
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local PhysicsService = game:GetService("PhysicsService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DamageService = require(game.ServerScriptService.Combat.DamageService)

local Templates = ServerStorage:WaitForChild("Enemies")
local SpawnPoints = workspace:WaitForChild("EnemySpawns")
local EnemyFolder = Instance.new("Folder")
EnemyFolder.Name = "Enemies"
EnemyFolder.Parent = workspace
pcall(PhysicsService.RegisterCollisionGroup, PhysicsService, "NPC")
PhysicsService:CollisionGroupSetCollidable("NPC", "NPC", false) -- crowds don't jam

type Stats = { Health: number, Speed: number, Damage: number, Range: number, Cooldown: number, Reward: number }
local STATS: { [string]: Stats } = {
	Grunt = { Health = 60, Speed = 12, Damage = 8, Range = 4.5, Cooldown = 1.0, Reward = 5 },
	Runner = { Health = 30, Speed = 20, Damage = 5, Range = 4, Cooldown = 0.7, Reward = 4 },
	Brute = { Health = 400, Speed = 8, Damage = 25, Range = 6, Cooldown = 2.0, Reward = 40 },
}
type Group = { Enemy: string, Count: number, Interval: number }
local WAVES: { { Groups: { Group }, TimeLimit: number } } = {
	{ Groups = { { Enemy = "Grunt", Count = 6, Interval = 0.8 } }, TimeLimit = 90 },
	{ Groups = { { Enemy = "Grunt", Count = 8, Interval = 0.6 }, { Enemy = "Runner", Count = 4, Interval = 1 } }, TimeLimit = 120 },
	{ Groups = { { Enemy = "Runner", Count = 10, Interval = 0.4 }, { Enemy = "Brute", Count = 1, Interval = 0 } }, TimeLimit = 150 },
}
local MAX_ALIVE, AI_HZ = 40, 6

type Npc = { hum: Humanoid, root: BasePart, stats: Stats, nextAttack: number }
local alive: { [Model]: Npc } = {}
local aliveCount = 0

local WaveState = Instance.new("Configuration") -- clients read attributes for UI
WaveState.Name = "WaveState"
WaveState.Parent = ReplicatedStorage

local WaveService = { OnReward = nil :: ((killer: Player?, reward: number) -> ())? }

local function spawnEnemy(name: string)
	local template, stats = Templates:FindFirstChild(name) :: Model?, STATS[name]
	if not template or not stats then return warn("Unknown enemy", name) end
	local model = template:Clone()
	local hum = model:FindFirstChildOfClass("Humanoid") :: Humanoid
	local root = model:FindFirstChild("HumanoidRootPart") :: BasePart
	hum.MaxHealth = math.floor(stats.Health * (1 + 0.35 * (#Players:GetPlayers() - 1))) -- scale by players
	hum.Health = hum.MaxHealth
	hum.WalkSpeed = stats.Speed
	for _, st in { Enum.HumanoidStateType.Climbing, Enum.HumanoidStateType.Swimming, Enum.HumanoidStateType.Seated } do
		hum:SetStateEnabled(st, false)
	end
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") then d.CollisionGroup = "NPC" end
	end
	model:SetAttribute("Enemy", true)
	local spawns = SpawnPoints:GetChildren()
	model:PivotTo((spawns[math.random(#spawns)] :: BasePart).CFrame + Vector3.new(0, 3, 0))
	model.Parent = EnemyFolder
	root:SetNetworkOwner(nil) -- server simulates; clients can't hijack
	alive[model] = { hum = hum, root = root, stats = stats, nextAttack = 0 }
	aliveCount += 1
	hum.Died:Once(function()
		if alive[model] then alive[model] = nil aliveCount -= 1 end
		Debris:AddItem(model, 3)
	end)
end

DamageService.OnKilled(function(victim, killer) -- kill credit
	local stats = victim:GetAttribute("Enemy") and STATS[victim.Name]
	if stats and WaveService.OnReward then
		WaveService.OnReward(if typeof(killer) == "Instance" and killer:IsA("Player") then killer else nil, stats.Reward)
	end
end)

local function nearestTarget(pos: Vector3): (Model?, BasePart?, number)
	local bestC, bestR, bestD = nil, nil, math.huge
	for _, p in Players:GetPlayers() do
		local c = p.Character
		local h = c and c:FindFirstChildOfClass("Humanoid")
		local r = c and c:FindFirstChild("HumanoidRootPart") :: BasePart?
		if h and r and h.Health > 0 and (r.Position - pos).Magnitude < bestD then
			bestC, bestR, bestD = c, r, (r.Position - pos).Magnitude
		end
	end
	return bestC, bestR, bestD
end

task.spawn(function() -- ONE brain loop for all NPCs
	while true do
		task.wait(1 / AI_HZ)
		local t = os.clock()
		for model, npc in alive do
			if (model:GetAttribute("StunnedUntil") or 0) > t then npc.hum:MoveTo(npc.root.Position) continue end
			local char, root, dist = nearestTarget(npc.root.Position)
			if not char or not root then continue end
			if dist > npc.stats.Range then
				npc.hum:MoveTo(root.Position) -- swap for PathfindingService in mazes (recompute ≤ 1/s)
			elseif t >= npc.nextAttack then
				npc.nextAttack = t + npc.stats.Cooldown
				DamageService.Apply(char, { Amount = npc.stats.Damage, Source = model, Kind = "Melee",
					Origin = npc.root.Position, StunTime = 0.2 })
			end
		end
	end
end)

-- Runs one wave. Returns true if cleared, false on timeout or party wipe.
function WaveService.RunWave(index: number): boolean
	local def = WAVES[math.min(index, #WAVES)]
	local extra = math.max(0, index - #WAVES) * 2 -- endless scaling past the last authored wave
	local deadline = os.clock() + def.TimeLimit
	WaveState:SetAttribute("Wave", index)
	WaveState:SetAttribute("WaveEndsAt", workspace:GetServerTimeNow() + def.TimeLimit)

	local spawning = #def.Groups
	for _, g in def.Groups do
		task.spawn(function()
			for _ = 1, g.Count + extra do
				while aliveCount >= MAX_ALIVE do task.wait(0.5) end
				spawnEnemy(g.Enemy)
				task.wait(g.Interval)
			end
			spawning -= 1
		end)
	end

	while os.clock() < deadline do
		task.wait(0.5)
		WaveState:SetAttribute("EnemiesLeft", aliveCount)
		if spawning == 0 and aliveCount == 0 then return true end
		local anyAlive = false
		for _, p in Players:GetPlayers() do
			local h = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
			if h and h.Health > 0 then anyAlive = true break end
		end
		if not anyAlive then return false end
	end
	return false
end

function WaveService.ClearAll()
	for model in alive do model:Destroy() end
	table.clear(alive)
	aliveCount = 0
end

return WaveService
```

Usage inside a round (§16): `local wave = 1 while WaveService.RunWave(wave) do wave += 1 task.wait(8) end WaveService.ClearAll()`.

---

## 11. Physics constraints and movers

All of these are `Constraint`s attached through `Attachment0` (and `Attachment1` for two-body constraints). They have `Enabled`, and most have `RelativeTo` (`Enum.ActuatorRelativeTo.World | Attachment0 | Attachment1`).

| Constraint | Key properties (verified) | Use |
|---|---|---|
| `LinearVelocity` | `VelocityConstraintMode` (Vector/Line/Plane), `VectorVelocity`, `LineDirection`+`LineVelocity`, `PlaneVelocity`+`PrimaryTangentAxis`/`SecondaryTangentAxis`, `MaxForce`, `ForceLimitMode`, `MaxAxesForce`, `MaxPlanarAxesForce`, `ForceLimitsEnabled`, `RelativeTo` | Dashes, knockback, conveyor, hover drift. Replaces BodyVelocity. |
| `AngularVelocity` | `AngularVelocity` (Vector3 rad/s), `MaxTorque`, `RelativeTo`, `ReactionTorqueEnabled` | Spinners, turret yaw, wheel spin without hinges |
| `AlignPosition` | `Mode` (OneAttachment/TwoAttachment), `Position`, `MaxForce`, `MaxVelocity`, `Responsiveness`, `RigidityEnabled`, `ForceLimitMode`, `MaxAxesForce`, `ApplyAtCenterOfMass` | Carry/grab objects, hover, pets following, "pull to" grapple |
| `AlignOrientation` | `Mode`, `CFrame`, `AlignType`, `PrimaryAxisOnly`, `LookAtPosition`, `MaxTorque`, `MaxAngularVelocity`, `Responsiveness`, `RigidityEnabled` | Keep upright, face target, custom controller rotation |
| `VectorForce` | `Force`, `RelativeTo`, `ApplyAtCenterOfMass` | Thrusters, anti-gravity (`Force = mass * workspace.Gravity` up), wind |
| `Torque` | `Torque`, `RelativeTo` | Constant twist |
| `HingeConstraint` | `ActuatorType` (None/Motor/Servo), `AngularVelocity`+`MotorMaxTorque`, `TargetAngle`+`AngularSpeed`+`ServoMaxTorque`, `LimitsEnabled` | Doors, wheels (Motor), steering (Servo) |
| `PrismaticConstraint` / `CylindricalConstraint` | Linear actuator (`ActuatorType`, `Velocity`, `TargetPosition`…), Cylindrical also `AngularActuatorType` | Elevators, pistons, suspension + wheel axis |
| `SpringConstraint` | `Stiffness`, `Damping`, `FreeLength`, `LimitsEnabled`, `MinLength`/`MaxLength` | Suspension, bouncy links |
| `TorsionSpringConstraint` | `Stiffness`, `Damping` | Spring-back doors, flippers |
| `BallSocketConstraint` | `LimitsEnabled`, `UpperAngle`, `TwistLimitsEnabled` | Ragdoll joints, chains |
| `RopeConstraint`, `RodConstraint` | `Length`, Rope has `WinchEnabled` | Grapples, wrecking balls |
| `WeldConstraint`, `RigidConstraint` | — | Attach gear/weapons. Rigid uses attachments and supports breaking. |
| `NoCollisionConstraint` | `Part0`, `Part1` | Stop specific pairs colliding |

**Dash/knockback with LinearVelocity (client for own character, server for NPC):**

```lua
local function burst(root: BasePart, velocity: Vector3, duration: number)
	local att = Instance.new("Attachment")
	att.Parent = root
	local lv = Instance.new("LinearVelocity")
	lv.Attachment0 = att
	lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	lv.RelativeTo = Enum.ActuatorRelativeTo.World
	lv.VectorVelocity = velocity
	lv.MaxForce = root.AssemblyMass * 2000 -- strong but finite
	lv.Parent = root
	task.delay(duration, function()
		lv:Destroy()
		att:Destroy()
	end)
end
```

Use **Plane mode** for a horizontal dash that keeps gravity working: set `VelocityConstraintMode = Plane`, set `PrimaryTangentAxis = (1,0,0)` and `SecondaryTangentAxis = (0,0,1)`, and set `PlaneVelocity = Vector2.new(v.X, v.Z)`.

**`ApplyImpulse` vs `AssemblyLinearVelocity` vs `LinearVelocity`:**
- `ApplyImpulse(mass * Δv)` is instantaneous and adds to the current velocity. Good for hits and explosions on server-owned bodies.
- Setting `AssemblyLinearVelocity` replaces the velocity outright. Crisp, but the Humanoid's own movement fights it within a few frames on the ground.
- `LinearVelocity` for N seconds holds the velocity against friction and the Humanoid. Best for dashes.
- All three must run on the **network owner**, or the next physics update from the owner overwrites them.

---

## 12. Network ownership

- The server owns anchored parts (always) and any unanchored part by default. The engine **auto-assigns** ownership of unanchored parts near a player to that player's client.
- Ownership is per **assembly**, and for mechanisms with no anchored parts it spreads to the whole mechanism.
- `part:SetNetworkOwner(player | nil)` is server-only. `part:SetNetworkOwnershipAuto()` reverts to automatic. `GetNetworkOwner()` and `CanSetNetworkOwnership()` (returns `ok, reason`) are also available.
- **The owner's simulation is trusted.** A client that owns a part can move it anywhere. Rules:
  - **Gameplay-critical physics (balls in sports games, NPCs, moving platforms carrying many players): `SetNetworkOwner(nil)`.** This costs responsiveness for players touching them. Under Server Authority, prediction removes that cost.
  - **Things a single player controls (their vehicle, their thrown object): give them ownership** for responsiveness, and validate outcomes on the server (speed caps, position sanity).
  - Projectiles that are real parts and that a client owns can be teleported onto targets. Never trust their `Touched`.
- Visualize ownership: viewport **Visualization Options** → **Network owners** (green = you own it, white/grey = server or another client).

```lua
-- Server-owned ball (sports game) with throw/kick validated on the server
local ball = workspace.Ball
ball:SetNetworkOwner(nil)
-- When a player "kicks", validate distance to the ball on the server, then:
-- ball:ApplyImpulse(direction * power * ball.AssemblyMass)
```

---

## 13. Characters: vehicles, controllers, Humanoid states, ragdolls

### 13.1 Vehicles

**Quick path: `VehicleSeat`.** It exposes `ThrottleFloat`/`SteerFloat` (−1..1) from the driver's WASD/thumbstick, plus `Occupant`, `MaxSpeed` and `Torque`. Read the floats and drive constraints yourself (the legacy built-in hinge drive is limited).

**Constraint chassis layout:**
- Chassis base (unanchored, the heavy part).
- For each wheel: a `CylindricalConstraint` (axis = vertical, gives suspension travel) with a `SpringConstraint` beside it, and a `HingeConstraint` with `ActuatorType = Motor` at the wheel axle for drive.
- Front wheels: a steering knuckle part, with a `HingeConstraint` `ActuatorType = Servo` controlling `TargetAngle`.
- `CustomPhysicalProperties` on the wheels for friction. Keep the chassis density high and the wheels light, for stability.

```lua
-- Car script (server). Wheels: HingeConstraint Motor (drive) and Servo (front steer).
local Players = game:GetService("Players")
local car = script.Parent
local seat = car.VehicleSeat :: VehicleSeat
local motors = { car.Wheels.RL.Motor, car.Wheels.RR.Motor } :: { HingeConstraint }
local steers = { car.Wheels.FL.Steer, car.Wheels.FR.Steer } :: { HingeConstraint }
local MAX_SPEED, WHEEL_RADIUS, MAX_STEER = 80, 1.5, 30

seat:GetPropertyChangedSignal("Occupant"):Connect(function()
	local player = seat.Occupant and Players:GetPlayerFromCharacter(seat.Occupant.Parent)
	if player then seat:SetNetworkOwner(player) else seat:SetNetworkOwnershipAuto() end -- whole mechanism follows
end)

game:GetService("RunService").Heartbeat:Connect(function()
	local w = seat.ThrottleFloat * MAX_SPEED / WHEEL_RADIUS
	motors[1].AngularVelocity, motors[2].AngularVelocity = w, -w -- sign depends on attachment orientation
	for _, s in steers do s.TargetAngle = seat.SteerFloat * MAX_STEER end
end)
```

Property writes from the server reach the owning driver with latency. For the best feel, run the drive loop on the **driver's client** (for example, a `RunContext = Client` script that checks `seat.Occupant` is the local Humanoid), and keep the server validating: if `chassis.AssemblyLinearVelocity.Magnitude > MAX_SPEED * 1.5` repeatedly, take ownership back.

### 13.2 Humanoid states

- `Humanoid:GetState()`, `ChangeState(state)`, `SetStateEnabled(state, bool)`, `GetStateEnabled`, and the `StateChanged(old, new)` event.
- State changes must run on the **owner** (the client for player characters) to stick. The server calling `ChangeState` on a player character generally doesn't work. Fire the client instead.
- Useful states: `Physics` (Humanoid stops controlling, so you can use your own movers or a ragdoll), `Ragdoll`/`FallingDown`, `GettingUp`, `Freefall`, `Dead`.
- `Humanoid.PlatformStand = true` makes the Humanoid stop balancing (used for flinging). `AutoRotate = false` lets you drive facing yourself (lock-on combat).
- `Humanoid.EvaluateStateMachine = false` turns the state machine off entirely. Use it when a `ControllerManager` drives the character.

### 13.3 ControllerManager (physics-based custom controllers)

`ControllerManager` + controllers (`GroundController`, `AirController`, `ClimbController`, `SwimController`) + sensors (`ControllerPartSensor` with `SensorMode = Floor|Ladder`, `BuoyancySensor`) form the engine's physics character controller. It's the base layer of the beta **Character Controller Library (CCL, `@rbx/AvatarAbilities`)**. It works without CCL too.

```lua
--!strict
-- Build a ControllerManager on a character (runs on the owner: client for players, server for NPCs).
local function setupController(char: Model): ControllerManager
	local hum = char:FindFirstChildOfClass("Humanoid") :: Humanoid
	local root = char:FindFirstChild("HumanoidRootPart") :: BasePart
	hum.EvaluateStateMachine = false -- the CM drives physics now

	local cm = Instance.new("ControllerManager")
	cm.RootPart = root
	cm.BaseMoveSpeed = 16
	cm.BaseTurnSpeed = 8

	local ground = Instance.new("GroundController")
	ground.GroundOffset = hum.HipHeight
	ground.Friction = 2
	ground.AccelerationTime = 0.15
	ground.Parent = cm

	local air = Instance.new("AirController")
	air.MoveMaxForce = 2000
	air.Parent = cm

	local floor = Instance.new("ControllerPartSensor")
	floor.SensorMode = Enum.SensorMode.Floor
	floor.SearchDistance = hum.HipHeight + 1.5
	floor.Name = "GroundSensor"
	floor.Parent = root
	cm.GroundSensor = floor

	cm.ActiveController = ground
	cm.Parent = char
	return cm
end

-- Each frame (client, for the local character):
-- cm.MovingDirection = moveVectorWorld          -- from input (Vector3, magnitude ≤ 1)
-- cm.FacingDirection = camera look, flattened
-- cm.ActiveController = if floorSensor.SensedPart then ground else air
-- Jump: when grounded, root:ApplyImpulse(Vector3.yAxis * root.AssemblyMass * 50); cm.ActiveController = air
```

Wall-run, double-jump, glide and similar mechanics then become small state switches: change `ActiveController`, `UpDirection`, `MoveSpeedFactor`, or add a temporary `VectorForce`.

### 13.4 Ragdolls

Set `Humanoid.BreakJointsOnDeath = false` (and `RequiresNeck = false`) *before* death. To ragdoll, for each `Motor6D` except the root joint: create `Attachment`s at `motor.C0` on `Part0` and `motor.C1` on `Part1`, link them with a `BallSocketConstraint` (`LimitsEnabled = true`, `UpperAngle ≈ 60`, `TwistLimitsEnabled = true`), set `motor.Enabled = false` (keep the motor so you can recover), and make the limbs `CanCollide = true`. The **owner** must also switch the Humanoid to `Physics`/`Ragdoll` state, so for players, fire their client. To recover, re-enable the motors, destroy the sockets, and `ChangeState(GettingUp)` on the owner.

---

## 14. Physics performance

- **Anchor everything static.** Unanchored decoration costs simulation and network ownership churn.
- **`CanQuery=false`, `CanTouch=false`, `CanCollide=false`** on VFX, hitbox debug parts, and accessories you never query.
- Prefer `Box`/`Hull` `CollisionFidelity` for MeshParts. `PreciseConvexDecomposition` is expensive. For tiny details, also set `CanCollide = false`.
- **The sleep system:** resting assemblies sleep. Avoid tiny constant forces (`VectorForce` with jitter, `AlignPosition` that never settles), because they keep everything awake.
- **Adaptive timestepping** (`Workspace.PhysicsSteppingMethod = Adaptive`) lets simple assemblies step at lower rates. Use `Fixed` for precise mechanisms such as vehicles and ragdoll-heavy games.
- **Projectiles:** raycast-stepped math (§8), not hundreds of physics parts. Pool cosmetic parts on clients.
- **NPCs:** a shared brain loop, collision groups, a `MAX_ALIVE` cap, and `Debris` for corpses. Consider `Workspace.StreamingEnabled` so far-away NPCs aren't replicated.
- **Spatial queries:** use `MaxParts` on `OverlapParams` and narrow `IncludeInstances` (for example, only the Characters folder) instead of querying the whole world.
- Watch Studio's **MicroProfiler** (Ctrl+F6) and the Developer Console's Physics tab ("Physics Step time", contacts).

---

## 15. Input across devices

### 15.1 Which API to use

| API | Status (Nov 2026) | Best for |
|---|---|---|
| **Input Action System**: `InputContext` → `InputAction` (`Type`: Bool, Direction1D/2D/3D, ViewportPosition) → `InputBinding` (`KeyCode`, `Up`/`Down`/`Left`/`Right`/`Forward`/`Backward` composites, `UIButton` for touch, `PrimaryModifier`/`SecondaryModifier`, `Scale`, `Deadzone`, `PressedThreshold`/`ReleasedThreshold`, `ResponseCurve`) | Released. Required under Server Authority (`Workspace.PlayerScriptsUseInputActionSystem`). `InputActionLabel` and the Input Action Manager Studio tool are still **beta**. | New games, remappable cross-device controls, combat hotkeys |
| `ContextActionService:BindAction(name, fn, createTouchButton, ...inputs)` | Supported | Quick contextual binds with auto mobile buttons (`SetTitle`, `SetImage`, `SetPosition`, `GetButton`) |
| `UserInputService` (`InputBegan`/`InputEnded`/`InputChanged`, `IsKeyDown`, `GetLastInputType`, `PreferredInput`, `TouchEnabled`, `GamepadEnabled`, `VREnabled`, `MouseBehavior`) | Supported | Raw input, camera, device detection |
| `VRService` (`VREnabled`, `GetUserCFrame(Enum.UserCFrame.Head/LeftHand/RightHand)`, `UserCFrameChanged`) | Supported | VR hands and head |

### 15.2 IAS events and polling

- `InputAction.Pressed` / `Released` (Bool type only), and `StateChanged(value)` for all types.
- **For analog input, poll `GetState()` every frame.** `StateChanged` fires once when a thumbstick moves, not while it's held.
- `InputBinding:Fire(state)` injects input programmatically (tests, custom UI).
- `InputContext.Priority` + `Sink` lets a higher-priority context (inventory open) swallow keys from gameplay. `Enabled` toggles a whole context.
- `InputAction.PreferredBinding` gives the binding for the current device. Use it for prompts ("Press [X]").

```lua
-- Client: wire combat actions defined in ReplicatedStorage/Inputs/PlayContext
-- Hierarchy: PlayContext(InputContext) > Attack(InputAction, Bool) > {KB: MouseLeftButton, GP: ButtonR2, Touch: UIButton=AttackButton}
--                                      > Move(InputAction, Direction2D) > {KB: WASD composites, GP: Thumbstick1}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ctx = ReplicatedStorage:WaitForChild("Inputs"):WaitForChild("PlayContext") :: InputContext
local attack = ctx:WaitForChild("Attack") :: InputAction
local block = ctx:WaitForChild("Block") :: InputAction
local move = ctx:WaitForChild("Move") :: InputAction
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

attack.Pressed:Connect(function()
	Remotes.MeleeAttack:FireServer()
end)
block.StateChanged:Connect(function(down: boolean)
	Remotes.MeleeBlock:FireServer(down)
end)
RunService.RenderStepped:Connect(function()
	local v: Vector2 = move:GetState() -- poll analog every frame
	-- feed into ControllerManager.MovingDirection / custom movement
end)

-- Opening the inventory: disable gameplay context
local function setInventoryOpen(open: boolean)
	ctx.Enabled = not open
end
```

Under Server Authority, InputContexts must be **cloned under each Player** by a server script (see §2), and your simulation reads `action:GetState()` inside `BindToSimulation` on both sides.

### 15.3 Device-adaptive UI

Read `UserInputService.PreferredInput` (`KeyboardAndMouse | Gamepad | Touch | MicroGamepad`) and listen to `GetPropertyChangedSignal("PreferredInput")`. Show touch buttons for Touch, glyphs for Gamepad, and key hints for keyboard/mouse.

### 15.4 Device rules for combat games

- **Mobile:** put on-screen buttons (IAS `UIButton` bindings or CAS touch buttons) in the bottom-right thumb zone, at least 60–80 px. Add **auto-aim or target lock** (aim at the nearest enemy in the camera cone), larger hitboxes or `Margin` on casts, and tap-to-attack with a combo buffer. Avoid hold-and-drag-while-attacking unless you have a dedicated aim stick.
- **Gamepad:** R2 attack/fire, L2 block/ADS, R1/L1 abilities, A jump, B dodge. Add aim assist (friction and magnetism near targets) and a radial menu for inventory. Test with Studio's Controller Emulator.
- **Keyboard/mouse:** M1 attack, M2 block/ADS, Q/E/R/F abilities, Shift dash, 1–9 hotbar. Lock the mouse in shooters (`UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter` with a custom crosshair).
- **VR:** `VRService:GetUserCFrame(Enum.UserCFrame.RightHand)` relative to the camera's head scale. Melee from hand velocity, with the server validating swing speed and reach. Default to comfort options (snap turn, vignette).
- **Never** gate combat input on `gameProcessedEvent == false` alone when using on-screen buttons; buttons set `processed = true`. Use IAS or CAS for mobile combat actions.

---

## 16. Round systems, teams, spectating

### 16.1 Round state machine

`Waiting` → `Intermission` → `Playing` → `Ended` → repeat. State lives in attributes on a replicated object, so client UI just reads them.

```lua
--!strict
-- ServerScriptService/Rounds/RoundService.server.luau
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local DamageService = require(game.ServerScriptService.Combat.DamageService)

local MIN_PLAYERS, INTERMISSION, ROUND_TIME, RESULTS_TIME, KILLS_TO_WIN = 2, 15, 180, 8, 25

local State = Instance.new("Configuration")
State.Name = "RoundState"
State.Parent = game:GetService("ReplicatedStorage")
local function setPhase(name: string, duration: number?)
	State:SetAttribute("Phase", name)
	State:SetAttribute("EndsAt", workspace:GetServerTimeNow() + (duration or 0)) -- clients count down
end

local function team(name: string, color: string): Team
	local t = Instance.new("Team")
	t.Name, t.TeamColor, t.AutoAssignable = name, BrickColor.new(color), false
	t.Parent = Teams
	return t
end
-- SpawnLocations with matching TeamColor (Neutral=false) pick spawns per team
local Red, Blue, Lobby = team("Red", "Bright red"), team("Blue", "Bright blue"), team("Lobby", "Medium stone grey")

local inRound: { [Player]: boolean } = {}
local score = { Red = 0, Blue = 0 }

DamageService.OnKilled(function(victim, killer)
	if State:GetAttribute("Phase") ~= "Playing" then return end
	if typeof(killer) == "Instance" and killer:IsA("Player") and inRound[killer] and killer.Team then
		local name = killer.Team.Name
		if score[name] then
			score[name] += 1
			State:SetAttribute("Score" .. name, score[name])
		end
	end
	local vp = Players:GetPlayerFromCharacter(victim)
	if vp and inRound[vp] then
		task.delay(Players.RespawnTime, function()
			if inRound[vp] and State:GetAttribute("Phase") == "Playing" then vp:LoadCharacterAsync() end
		end)
	end
end)

Players.CharacterAutoLoads = false -- the round controls spawning
Players.PlayerAdded:Connect(function(p) p.Team = Lobby p:LoadCharacterAsync() end)
Players.PlayerRemoving:Connect(function(p) inRound[p] = nil end)

local function countIn(): number
	local n = 0
	for p in inRound do if p.Parent then n += 1 end end
	return n
end

while true do
	setPhase("Waiting")
	while #Players:GetPlayers() < MIN_PLAYERS do task.wait(1) end
	setPhase("Intermission", INTERMISSION)
	task.wait(INTERMISSION)
	local list = Players:GetPlayers()
	if #list < MIN_PLAYERS then continue end

	score.Red, score.Blue = 0, 0
	State:SetAttribute("ScoreRed", 0)
	State:SetAttribute("ScoreBlue", 0)
	for i = #list, 2, -1 do local j = math.random(i) list[i], list[j] = list[j], list[i] end -- shuffle
	for i, p in list do
		inRound[p] = true
		p.Team = if i % 2 == 0 then Red else Blue -- swap in party/skill balancing here
		task.spawn(function()
			p:LoadCharacterAsync()
			if p.Character then p.Character:SetAttribute("IFrameUntil", os.clock() + 2) end -- spawn protection
		end)
	end
	setPhase("Playing", ROUND_TIME)
	local deadline = os.clock() + ROUND_TIME
	repeat task.wait(0.25)
	until os.clock() > deadline or score.Red >= KILLS_TO_WIN or score.Blue >= KILLS_TO_WIN or countIn() < MIN_PLAYERS

	State:SetAttribute("Winner", if score.Red > score.Blue then "Red" elseif score.Blue > score.Red then "Blue" else "Draw")
	setPhase("Ended", RESULTS_TIME)
	-- award rewards server-side via your data layer
	task.wait(RESULTS_TIME)
	for p in inRound do
		if p.Parent then p.Team = Lobby task.spawn(p.LoadCharacterAsync, p) end
	end
	table.clear(inRound)
end
```

- `LoadCharacterAsync()` is current, and `LoadCharacter()` is deprecated. Mid-round joiners spectate, or join the smaller team.
- Free-for-all: skip teams and keep `Player.Neutral = true` (DamageService's friendly-fire check ignores neutral players).

### 16.2 Spectating

On the client, keep a list of living players, and set `camera.CameraSubject = target.Character:FindFirstChildOfClass("Humanoid")` with `CameraType = Custom`. Cycle with next/prev buttons or IAS actions, and restore your own Humanoid on respawn. Turn spectating on when `RoundState` says you're not in the round. Under `StreamingEnabled`, a far-away target may not be streamed in, so the **server** sets `spectator.ReplicationFocus = targetRoot` (and resets it to `nil` afterwards).

---

## 17. Matchmaking: lobby place → round servers

### 17.1 Architecture

Lobby place (public servers): a party joins the queue, which adds one entry to `MemoryStoreQueue "MM_<mode>"`. Every lobby server runs a matchmaker loop: `ReadAsync` → pack parties into a match → generate a GUID as the `ReservedServerId` → `MessagingService:PublishAsync` with `{userIds, rsid}`. Each lobby server teleports **its own** members with `TeleportAsync(roundPlaceId, players, options)`. Since all use the same `ReservedServerId`, they land in one server. The round place reads `Player:GetJoinData().TeleportData`, runs a single round, and teleports everyone back to the lobby.

- Queue entries are protected by the invisibility timeout: if a matchmaker crashes, unremoved entries reappear.
- If everyone queuing is in one lobby server, skip MemoryStore: just `TeleportAsync` the pad's players with a fresh `ReservedServerId`.
- **Built-in matchmaking customization** (Creator Hub → Matchmaking: attributes, signals, scoring) only tunes which *public* server a joiner lands in, by skill, language and so on. It doesn't form party matches.

### 17.2 Complete lobby matchmaker (server, lobby place)

```lua
--!strict
-- ServerScriptService/Matchmaking/Matchmaker.server.luau  (LOBBY place)
local Players = game:GetService("Players")
local MemoryStoreService = game:GetService("MemoryStoreService")
local MessagingService = game:GetService("MessagingService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")

local ROUND_PLACE_ID = 0 -- TODO: round place id (same universe)
local MODE, MATCH_SIZE = "Duos", 4
local ENTRY_TTL, INVISIBILITY = 120, 20
local TOPIC = "MM_Match_" .. MODE
local queue = MemoryStoreService:GetQueue("MM_" .. MODE, INVISIBILITY)
local QueueRemote = Remotes:WaitForChild("Queue") :: RemoteEvent         -- client -> server: true/false
local QueueStatus = Remotes:WaitForChild("QueueStatus") :: RemoteEvent   -- server -> client

local queuedHere: { [number]: boolean } = {} -- userIds queued from THIS server
local lastQueueAt: { [Player]: number } = {}

local function retry(attempts: number, fn: () -> any): (boolean, any)
	local ok, res
	for i = 1, attempts do
		ok, res = pcall(fn)
		if ok then return true, res end
		task.wait(0.5 * 2 ^ (i - 1))
	end
	return false, res
end

local function partyOf(player: Player): { number }
	-- Replace with your party system. Example: server-set attribute "123,456"
	local ids = { player.UserId }
	for s in string.gmatch(tostring(player:GetAttribute("PartyMembers") or ""), "%d+") do
		local id = tonumber(s)
		if id and id ~= player.UserId and Players:GetPlayerByUserId(id) then table.insert(ids, id) end
	end
	return ids
end

QueueRemote.OnServerEvent:Connect(function(player: Player, join: unknown)
	if type(join) ~= "boolean" or os.clock() - (lastQueueAt[player] or 0) < 2 then return end
	lastQueueAt[player] = os.clock()
	local ids = partyOf(player)
	if not join then
		-- A MemoryStoreQueue can't delete an unread item: forget locally; the match skips
		-- players not in queuedHere and the entry expires via TTL.
		for _, id in ids do queuedHere[id] = nil end
		QueueStatus:FireClient(player, "Left")
		return
	end
	if queuedHere[player.UserId] or #ids > MATCH_SIZE then return end
	local entry = { userIds = ids, queuedAt = os.time() } -- add skill/region for better matching
	local ok = retry(3, function() return queue:AddAsync(entry, ENTRY_TTL, 0) end)
	if ok then for _, id in ids do queuedHere[id] = true end end
	QueueStatus:FireClient(player, if ok then "Queued" else "Error")
end)
Players.PlayerRemoving:Connect(function(p) queuedHere[p.UserId] = nil lastQueueAt[p] = nil end)

-- Every lobby server receives every match and teleports the members it has
local function teleportMatch(data: { userIds: { number }, rsid: string, matchId: string })
	local mine: { Player } = {}
	for _, id in data.userIds do
		local p = Players:GetPlayerByUserId(id)
		if p and queuedHere[id] then table.insert(mine, p) queuedHere[id] = nil end
	end
	if #mine == 0 then return end
	local options = Instance.new("TeleportOptions")
	options.ReservedServerId = data.rsid -- same GUID everywhere => same match server
	options:SetTeleportData({ matchId = data.matchId, mode = MODE, expected = data.userIds })
	local ok, err = retry(3, function() return TeleportService:TeleportAsync(ROUND_PLACE_ID, mine, options) end)
	if not ok then
		warn("Match teleport failed:", err)
		for _, p in mine do QueueStatus:FireClient(p, "Error") end
	end
end

task.spawn(function()
	local ok, err = pcall(MessagingService.SubscribeAsync, MessagingService, TOPIC, function(message)
		local d = message.Data
		if type(d) == "table" and type(d.rsid) == "string" and type(d.userIds) == "table" then teleportMatch(d) end
	end)
	if not ok then warn("Subscribe failed:", err) end
end)

-- Matchmaker loop on every lobby server; the invisibility timeout prevents double-processing
while true do
	task.wait(3)
	local ok, items, readId = pcall(function() return queue:ReadAsync(10, false, 2) end)
	if not ok or not items or #items == 0 then continue end

	table.sort(items, function(a, b) return a.queuedAt < b.queuedAt end) -- oldest first
	local match, used = {}, {}
	for i, entry in items do
		if #match + #entry.userIds <= MATCH_SIZE then
			for _, id in entry.userIds do table.insert(match, id) end
			used[i] = true
		end
		if #match == MATCH_SIZE then break end
	end
	-- Not enough players or publish fails: do nothing; items reappear after INVISIBILITY seconds.
	if #match == MATCH_SIZE then
		local payload = { userIds = match, rsid = HttpService:GenerateGUID(false), matchId = HttpService:GenerateGUID(false) }
		if pcall(MessagingService.PublishAsync, MessagingService, TOPIC, payload) then
			-- ONE readId covers the whole batch: remove it, then re-add parties we didn't use
			pcall(function() queue:RemoveAsync(readId) end)
			for i, entry in items do
				if not used[i] then pcall(function() queue:AddAsync(entry, ENTRY_TTL, 0) end) end
			end
		end
	end
end
```

Key behaviors:
- `MemoryStoreQueue:ReadAsync(count, allOrNothing, waitTimeout)` returns `(items, id)`, and `RemoveAsync(id)` removes **the whole batch**. That's why unused parties are re-added. Their `queuedAt` survives, so they still sort first.
- MessagingService messages are limited to **1 kB**, which fits about 16 userIds. For larger matches, store the roster in a `MemoryStoreHashMap` keyed by `matchId` and publish only the id.
- Delivery is best-effort. Give the client a queue timer that re-queues after about 90 s. Stale entries expire via the TTL.
- Skill matching: add `skill` to entries and only pack parties within a window that widens with wait time.

### 17.3 Round place: receiving the match and returning players

```lua
--!strict
-- ServerScriptService/RoundServer.server.luau  (ROUND place)
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local LOBBY_PLACE_ID = 0 -- TODO
local isReserved = game.PrivateServerId ~= "" and game.PrivateServerOwnerId == 0
local expected: { [number]: boolean } = {}

Players.PlayerAdded:Connect(function(player)
	-- TeleportData is client-carried: an UNTRUSTED hint (fine for mode/roster, never for rewards)
	local td = player:GetJoinData().TeleportData
	if type(td) == "table" and type(td.expected) == "table" then
		for _, id in td.expected do if type(id) == "number" then expected[id] = true end end
	end
	if not isReserved then -- joined the round place directly: bounce to lobby
		task.defer(pcall, TeleportService.TeleportAsync, TeleportService, LOBBY_PLACE_ID, { player })
	end
end)

local function waitForRoster(timeout: number)
	local deadline = os.clock() + timeout
	repeat
		task.wait(0.5)
		local missing = false
		for id in expected do if not Players:GetPlayerByUserId(id) then missing = true break end end
	until (next(expected) and not missing) or os.clock() > deadline
end

local function sendAllToLobby()
	local players = Players:GetPlayers()
	if #players == 0 then return end
	local ok, err = pcall(TeleportService.TeleportAsync, TeleportService, LOBBY_PLACE_ID, players)
	if not ok then warn("Return teleport failed:", err) end
end

TeleportService.TeleportInitFailed:Connect(function(player, result, message)
	warn("Teleport failed:", player.Name, result, message)
	task.wait(2)
	pcall(TeleportService.TeleportAsync, TeleportService, LOBBY_PLACE_ID, { player })
end)
game:BindToClose(sendAllToLobby)

waitForRoster(30)
-- run ONE round (RoundService loop body / WaveService), save results via your data layer, then:
sendAllToLobby()
```

- Save match results **on the round server before teleporting**. Session-locked profiles release on leave, so the lobby loads fresh data.
- Teleports don't work in Studio playtests. Guard them with `RunService:IsStudio()`.

---

## 18. Inventory and equipment

**Tools vs custom.** `Tool` (Backpack) is low effort: built-in hotbar, `Activated`/`Equipped`/`Unequipped`, `RequiresHandle`, `ManualActivationOnly`, and `CanBeDropped` (set it **false** for weapons). But you only get one equipped tool, the default UI, and **no full Server Authority support**. A custom system (profile data plus welded models) gives multiple slots, offhand and armor, and works under Server Authority. In both cases the client only fires intents.

```lua
-- Profile data: every non-stackable item has a unique id, so dupes are detectable
Data.Inventory = {
	["f3a1...guid"] = { ItemId = "IronSword", Level = 3, Locked = false },
	["9b20...guid"] = { ItemId = "HealthPotion", Count = 12 },
}
Data.Equipped = { Weapon = "f3a1...guid", Hotbar = { "9b20...guid" } }
```

`ItemDefs` (stats, rarity, `Tradable`) live in ReplicatedStorage. Ownership lives only in the server profile. On `Equip(slot, uid)`, the server checks that the uid is owned and fits the slot, updates `Equipped`, sets `player:SetAttribute("EquippedMelee", ItemId)`, and welds the model on (`WeldConstraint`, `Massless`, `CanCollide=false`, `CanQuery=false`). The UI mirrors a server-pushed snapshot.

---

## 19. Secure trading (two-phase commit)

### 19.1 Rules

1. Both players are **in the same server** with **session-locked profiles** loaded (ProfileStore style). Avoid cross-server trades.
2. The trade is a **server-side session**. Clients only send intents: add, remove, ready, confirm, cancel.
3. **Any offer change clears both `ready` and `confirmed`** and invalidates the countdown. This defeats bait-and-switch.
4. **Phase 1 (prepare):** re-verify every uid is owned, unlocked, tradable, unequipped, and not already present on the receiving side.
5. **Phase 2 (commit):** swap in memory **with no yields in between**, which is atomic with respect to other Luau on this server. Then save both profiles and journal the trade for audit. For extra durability, write a `pending` journal entry before phase 2 and resolve it on load ("exactly one profile owns uid X").
6. Rate-limit requests, cap items per side, and optionally block new accounts or players in combat.

### 19.2 Complete trade service

```lua
--!strict
-- ServerScriptService/Trading/TradeService.server.luau
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Data.GetProfileData(player) -> live session-locked table or nil; Data.RequestSave(player)
local Data = require(game.ServerScriptService.Data.DataService)
local ItemDefs = require(ReplicatedStorage.Shared.ItemDefs) -- [ItemId] = { Tradable = true, ... }
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local TradeRequest = Remotes:WaitForChild("TradeRequest") :: RemoteEvent -- (targetPlayer)
local TradeAction = Remotes:WaitForChild("TradeAction") :: RemoteEvent   -- (action, arg)
local TradeUpdate = Remotes:WaitForChild("TradeUpdate") :: RemoteEvent   -- server -> clients
local Journal = DataStoreService:GetDataStore("TradeJournal_v1")

local MAX_ITEMS, COUNTDOWN, REQUEST_TTL = 8, 5, 30

type Side = { player: Player, items: { [string]: boolean }, ready: boolean, confirmed: boolean }
type Trade = { id: string, a: Side, b: Side, state: string, token: number, countdownDone: boolean }
local trades: { [Player]: Trade } = {}
local requests: { [Player]: { [Player]: number } } = {} -- target -> requester -> expiry
local lastAction: { [Player]: number } = {}

local function throttled(p: Player, gap: number): boolean
	if os.clock() - (lastAction[p] or 0) < gap then return true end
	lastAction[p] = os.clock()
	return false
end

local function push(trade: Trade)
	local function view(s: Side)
		local list, data = {}, Data.GetProfileData(s.player)
		for uid in s.items do
			local item = data and data.Inventory[uid]
			if item then table.insert(list, { uid = uid, ItemId = item.ItemId }) end
		end
		return { userId = s.player.UserId, items = list, ready = s.ready, confirmed = s.confirmed }
	end
	local payload = { id = trade.id, state = trade.state, countdownDone = trade.countdownDone, a = view(trade.a), b = view(trade.b) }
	TradeUpdate:FireClient(trade.a.player, payload)
	TradeUpdate:FireClient(trade.b.player, payload)
end

local function resetFlags(trade: Trade) -- ANY change => both must re-ready and re-confirm
	trade.a.ready, trade.b.ready, trade.a.confirmed, trade.b.confirmed = false, false, false, false
	trade.countdownDone = false
	trade.token += 1 -- invalidates a running countdown
end

local function finish(trade: Trade, state: string)
	trade.state = state
	trade.token += 1
	push(trade)
	trades[trade.a.player], trades[trade.b.player] = nil, nil
end

local function tradable(data: any, uid: string): boolean
	local item = data.Inventory[uid]
	if not item or item.Locked then return false end
	local def = ItemDefs[item.ItemId]
	if not def or def.Tradable ~= true then return false end
	for _, v in data.Equipped or {} do
		if v == uid or (type(v) == "table" and table.find(v, uid)) then return false end
	end
	return true
end

local function commit(trade: Trade)
	trade.state = "Committing"
	local pa, pb = trade.a.player, trade.b.player
	local da, db = Data.GetProfileData(pa), Data.GetProfileData(pb)
	if not da or not db or pa.Parent ~= Players or pb.Parent ~= Players then return finish(trade, "Cancelled") end
	-- PHASE 1 (prepare): re-verify everything. No yields from here until the swap is done.
	for uid in trade.a.items do
		if not tradable(da, uid) or db.Inventory[uid] then return finish(trade, "Cancelled") end -- 2nd check = dupe guard
	end
	for uid in trade.b.items do
		if not tradable(db, uid) or da.Inventory[uid] then return finish(trade, "Cancelled") end
	end
	-- PHASE 2 (commit): atomic in-memory swap
	local moved = { aToB = {}, bToA = {} }
	for uid in trade.a.items do
		db.Inventory[uid], da.Inventory[uid] = da.Inventory[uid], nil
		table.insert(moved.aToB, uid)
	end
	for uid in trade.b.items do
		da.Inventory[uid], db.Inventory[uid] = db.Inventory[uid], nil
		table.insert(moved.bToA, uid)
	end
	finish(trade, "Done")
	-- Durability + audit (yielding is fine now)
	Data.RequestSave(pa)
	Data.RequestSave(pb)
	task.spawn(pcall, Journal.SetAsync, Journal, trade.id,
		{ a = pa.UserId, b = pb.UserId, moved = moved, at = os.time() }, { pa.UserId, pb.UserId })
end

TradeRequest.OnServerEvent:Connect(function(requester: Player, target: unknown)
	if throttled(requester, 1) or typeof(target) ~= "Instance" or not (target :: Instance):IsA("Player") then return end
	local tp = target :: Player
	if tp == requester or tp.Parent ~= Players or trades[requester] or trades[tp] then return end
	if not Data.GetProfileData(requester) or not Data.GetProfileData(tp) then return end
	local incoming = requests[requester]
	if incoming and (incoming[tp] or 0) > os.clock() then -- tp asked us first: accept => open
		incoming[tp] = nil
		local trade: Trade = { id = HttpService:GenerateGUID(false), state = "Open", token = 0, countdownDone = false,
			a = { player = requester, items = {}, ready = false, confirmed = false },
			b = { player = tp, items = {}, ready = false, confirmed = false } }
		trades[requester], trades[tp] = trade, trade
		return push(trade)
	end
	requests[tp] = requests[tp] or {}
	requests[tp][requester] = os.clock() + REQUEST_TTL
	TradeUpdate:FireClient(tp, { incomingFrom = requester.UserId })
end)

TradeAction.OnServerEvent:Connect(function(player: Player, action: unknown, arg: unknown)
	local trade = trades[player]
	if throttled(player, 0.15) or type(action) ~= "string" or not trade or trade.state ~= "Open" then return end
	local me = if trade.a.player == player then trade.a else trade.b
	local data = Data.GetProfileData(player)
	if not data then return end

	if action == "Add" and type(arg) == "string" and not me.items[arg] then
		local n = 0
		for _ in me.items do n += 1 end
		if n >= MAX_ITEMS or not tradable(data, arg) then return end
		me.items[arg] = true
		resetFlags(trade)
	elseif action == "Remove" and type(arg) == "string" and me.items[arg] then
		me.items[arg] = nil
		resetFlags(trade)
	elseif action == "Ready" and type(arg) == "boolean" then
		if not arg then resetFlags(trade) else me.ready = true end
		if trade.a.ready and trade.b.ready and not trade.countdownDone then
			trade.token += 1
			local token = trade.token
			task.delay(COUNTDOWN, function() -- confirm unlocks only if nothing changed meanwhile
				if trade.token == token and trade.state == "Open" then
					trade.countdownDone = true
					push(trade)
				end
			end)
		end
	elseif action == "Confirm" then
		if not (trade.a.ready and trade.b.ready and trade.countdownDone) then return end
		me.confirmed = true
		if trade.a.confirmed and trade.b.confirmed then return commit(trade) end
	elseif action == "Cancel" then
		return finish(trade, "Cancelled")
	else
		return
	end
	push(trade)
end)

Players.PlayerRemoving:Connect(function(p)
	local trade = trades[p]
	if trade and trade.state == "Open" then finish(trade, "Cancelled") end
	requests[p], lastAction[p] = nil, nil
	for _, r in requests do r[p] = nil end
end)
```

Why it's safe:
- **Server-owned offers**, with validation on add *and* on commit, mean an item can't be sold, equipped or traded twice in between.
- `countdownToken` invalidates stale countdowns. Any edit resets both players' flags.
- The swap has no yields, so no other remote handler can run in the middle of it.
- The uid collision check catches duplication bugs. Combined with session locking (one server owns each profile), this prevents the classic "trade then rejoin" dupe.
- For currency in trades, add `me.coins`, validate `data.Coins >= offer` at commit, and move it in the same block.

---

## 20. Global leaderboards (OrderedDataStore)

```lua
--!strict
-- ServerScriptService/Leaderboards/GlobalBoard.server.luau
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local board = game:GetService("DataStoreService"):GetOrderedDataStore("Wins_AllTime_v1")

local function winsOf(p: Player): number?
	local ls = p:FindFirstChild("leaderstats") -- the in-session player-list board (IntValue "Wins")
	local v = ls and ls:FindFirstChild("Wins") :: IntValue?
	return v and v.Value
end

local function write(p: Player) -- values must be integers
	local w = winsOf(p)
	if w then pcall(board.SetAsync, board, tostring(p.UserId), math.floor(w)) end
end
Players.PlayerRemoving:Connect(write)

local Cache = Instance.new("StringValue") -- clients render this JSON on a SurfaceGui
Cache.Name = "GlobalWinsTop"
Cache.Parent = game:GetService("ReplicatedStorage")

while true do
	for _, p in Players:GetPlayers() do write(p) task.wait(0.2) end -- throttled writes
	local ok, pages = pcall(board.GetSortedAsync, board, false, 50) -- descending, pagesize ≤ 100
	if ok and pages then
		local rows = {}
		for rank, e in pages:GetCurrentPage() do
			table.insert(rows, { rank = rank, userId = tonumber(e.key), value = e.value })
		end
		Cache.Value = HttpService:JSONEncode(rows)
	end
	task.wait(90) -- reads are budgeted: refresh rarely, never per player
end
```

- Weekly boards: version the key per week (`"Wins_W" .. os.date("!%Y%W")`). Resolve names with `Players:GetNameFromUserIdAsync` (`pcall`, cached).
- For real-time cross-server boards, mirror into a `MemoryStoreSortedMap` (`SetAsync(key, value, expiration, sortKey)` / `GetRangeAsync(Enum.SortDirection.Descending, n)`), and persist to the OrderedDataStore periodically.

---

## 21. Cross-server events (MessagingService)

Limits (subject to change): message ≤ **1 kB**. Per server, `600 + 240 × players` messages sent per minute. Per topic, `40 + 80 × servers` messages received per minute. Per server, `20 + 8 × players` subscriptions. Delivery is **best-effort**.

```lua
--!strict
-- Global event (e.g. "Double XP for 15 min"), triggered from any server
local MessagingService = game:GetService("MessagingService")
local Events = Instance.new("Configuration") -- clients read attributes
Events.Name = "GlobalEvents"
Events.Parent = game:GetService("ReplicatedStorage")
local TOPIC = "GlobalEvents"

local function applyEvent(data: any)
	if type(data) == "table" and data.kind == "DoubleXP" and type(data.endsAt) == "number" then
		Events:SetAttribute("DoubleXPEndsAt", data.endsAt) -- compare to GetServerTimeNow()
	end
end

task.spawn(function()
	local ok, err = pcall(MessagingService.SubscribeAsync, MessagingService, TOPIC, function(message)
		applyEvent(message.Data) -- message.Sent = publish timestamp; the publishing server receives it too
	end)
	if not ok then warn("Subscribe failed:", err) end
end)

local GlobalEvents = {}
function GlobalEvents.Broadcast(kind: string, durationSec: number)
	local data = { kind = kind, endsAt = workspace:GetServerTimeNow() + durationSec }
	if not pcall(MessagingService.PublishAsync, MessagingService, TOPIC, data) then applyEvent(data) end
end
return GlobalEvents
```

For events that *must* reach every server, including ones that start later, also write the event to a DataStore or MemoryStore hash map, and have servers read it on startup.

---

## 22. Anti-exploit for gameplay systems

Exploiters control their client completely: they can fire any remote with any arguments, read all replicated data, and move their own character anywhere (in the classic model). Defend on the server.

### 22.1 Movement sanity (classic model)

```lua
--!strict
-- ServerScriptService/AntiCheat/MovementCheck.server.luau
local Players = game:GetService("Players")
local INTERVAL, TOLERANCE, FLY_LIMIT, MAX_STRIKES = 0.5, 1.4, 4, 6

type Track = { pos: Vector3, t: number, strikes: number, airSince: number?, safe: CFrame }
local tracks: { [Player]: Track } = {}
local down = RaycastParams.new()
down.FilterType = Enum.RaycastFilterType.Exclude

local function legalSpeed(char: Model, hum: Humanoid): number
	if (char:GetAttribute("DashingUntil") or 0) > os.clock() or (char:GetAttribute("KnockbackUntil") or 0) > os.clock() then
		return 90
	end
	return if hum.SeatPart then 150 else hum.WalkSpeed -- validate vehicles separately
end

Players.PlayerRemoving:Connect(function(p) tracks[p] = nil end)
while true do
	task.wait(INTERVAL)
	for _, p in Players:GetPlayers() do
		local char = p.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
		if not char or not hum or not root or hum.Health <= 0 then tracks[p] = nil continue end
		local t, tr = os.clock(), tracks[p]
		if not tr or char:GetAttribute("ServerTeleported") then -- your own teleports set this flag
			char:SetAttribute("ServerTeleported", nil)
			tracks[p] = { pos = root.Position, t = t, strikes = 0, airSince = nil, safe = root.CFrame }
			continue
		end
		local speed = ((root.Position - tr.pos) * Vector3.new(1, 0, 1)).Magnitude / math.max(t - tr.t, 1e-3)
		local bad = speed > legalSpeed(char, hum) * TOLERANCE + 4

		down.FilterDescendantsInstances = { char }
		if workspace:Raycast(root.Position, Vector3.new(0, -(hum.HipHeight + 6), 0), down) or hum.SeatPart
			or hum:GetState() == Enum.HumanoidStateType.Swimming then
			tr.airSince = nil
			if not bad then tr.safe = root.CFrame end
		else
			tr.airSince = tr.airSince or t
			if t - (tr.airSince :: number) > FLY_LIMIT and root.AssemblyLinearVelocity.Y > -5 then bad = true end
		end

		if bad then
			tr.strikes += 1
			root.CFrame = tr.safe -- rubber-band: harmless for laggy legit players
			char:SetAttribute("ServerTeleported", true)
			if tr.strikes >= MAX_STRIKES then
				warn(("[AC] %s strikes=%d speed=%.1f"):format(p.Name, tr.strikes, speed)) -- log; kick only if extreme
			end
		else
			tr.strikes = math.max(0, tr.strikes - 0.25)
		end
		tr.pos, tr.t = root.Position, t
	end
end
```

The server can set a client-owned root's `CFrame`, but a cheating client can ignore it, which is why strikes get logged. Allowlist launch pads, knockback (`KnockbackUntil`), vehicles and server teleports. Under Server Authority, movement is server-simulated and this whole class of cheat goes away.

### 22.2 The combat checklist

| Threat | Server defense |
|---|---|
| Remote spam / macros | Sliding-window rate limit per remote per player. Drop silently and log extremes. |
| Cooldown bypass | Server-clock cooldowns. Commit the cost before any yield. |
| Kill aura / reach | Server hitboxes from server positions, range + lag pad, LOS raycast, one hit per target per swing. |
| Damage or fire-rate edits | The client never sends damage. Token-bucket fire gate, server ammo and reload. `DamageService` rejects NaN and absurd values. |
| Silent aim | Origin near the server head, no wall between head and origin, rewound-target validation, headshot-ratio stats. |
| Spoofed arguments | `typeof` everything, NaN checks (`x ~= x`), string length caps, Instances checked for class *and* location (`IsDescendantOf(workspace.Enemies)`). |
| Dupes | Unique item ids, session locking, the two-phase trade, audit logs. |
| Teleport-data tampering | `TeleportData` is client-carried. Never base rewards or permissions on it. Key server data by `matchId` in MemoryStore or DataStore. |
| Client-owned damage parts | Never use `Touched` on client-owned parts as a damage source. |

**Log, don't ban rashly:** keep per-player anomaly counters and send them to analytics. Lag causes false positives.

---

## 23. File layout

`ReplicatedStorage`: `Remotes/` (create before anything calls `WaitForChild`; mark cosmetic ones as `UnreliableRemoteEvent`), `Shared/` (AbilityDefs, MeleeDefs, ItemDefs, Ballistics), `Inputs/` (IAS contexts). `ServerScriptService`: `Combat/` (DamageService, StatusEffects, PositionHistory, ProjectileService, AbilityService, MeleeService, GunService), `Waves/`, `Rounds/`, `Matchmaking/` (lobby place only), `Trading/`, `Leaderboards/`, `AntiCheat/`. `ServerStorage/Enemies/`. `StarterPlayerScripts`: melee, gun, knockback and spectate clients.

---

## Sources

Local (creator-docs snapshot and API dump, verified 2026-11-05):
- `reference/api/API-Dump.txt`: WorldRoot spatial queries, RunService `BindToSimulation`/`SetPredictionMode`/`GetPredictionStatus`, BasePart network ownership and impulses, mover constraint properties, ControllerManager and controllers, InputAction/InputBinding/InputContext, TeleportService (deprecations of `ReserveServer*`, `TeleportPartyAsync`), TeleportOptions, MemoryStoreQueue/SortedMap, MessagingService, OrderedDataStore, Humanoid, `Player:LoadCharacterAsync` (`LoadCharacter` deprecated), `UserInputService.PreferredInput`.
- `content/en-us/projects/server-authority/index.md`, `techniques.md`: Server Authority model, setup, simulation sync, attributes, input actions, tools limitation, instance stitching, smoothing, animation.
- `content/en-us/input/input-action-system.md`, `input/mobile.md`, `input/gamepad.md`: IAS contexts, actions, bindings, events, beta status of InputActionLabel and Input Action Manager.
- `content/en-us/physics/network-ownership.md`, `physics/mover-constraints.md`, `physics/constraints/*`, `physics/adaptive-timestepping.md`, `physics/sleep-system.md`.
- `content/en-us/projects/teleport.md`, `projects/teleport-private-servers.md`: `ReservedServerId` GUID flow and migration from access codes.
- `content/en-us/cloud-services/memory-stores/queue.md`, `cross-server-messaging.md`. `reference/engine/classes/MessagingService.yaml` (limits), `UnreliableRemoteEvent.yaml` (rate and payload limits), `Player.yaml` (`GetNetworkPing` is round-trip).
- `content/en-us/reference/engine/datatypes/RaycastParams.yaml`, `OverlapParams.yaml`: `ExcludeInstances`/`IncludeInstances`, `Margin`, `SizeGradient`, `Tolerance`.
- `content/en-us/characters/character-controller-library/*`: CCL (beta) and ControllerManager usage.
- `content/en-us/matchmaking/index.md`: built-in server-selection matchmaking.
- `reference/libraries/MadStudioRoblox_ProfileStore`: session-locked profiles (the basis for safe trades).

Web (treated as data):
- Roblox DevForum, "[Full Release] Ship Fair And Competitive Games with Server Authority": https://devforum.roblox.com/t/full-release-ship-fair-and-competitive-games-with-server-authority/4727993 (opt-in; increased server utilization)
- Roblox DevForum, "[Studio Beta] Build Fair, Responsive Games with Server Authority": https://devforum.roblox.com/t/studio-beta-build-fair-responsive-games-with-server-authority/4139157
- Roblox Newsroom, server authority (2026): https://about.roblox.com/newsroom/2026/07/creating-responsive-cheat-resistant-games-roblox-server-authority
- DevForum, FastCast thread: https://devforum.roblox.com/t/making-a-combat-game-with-ranged-weapons-fastcast-may-be-the-module-for-you/133474
- DevForum, SecureCast (server-authoritative projectiles with lag compensation): https://devforum.roblox.com/t/server-authoritative-projectiles-with-lag-compensation-multi-threading-and-more/2546164
- DevForum, projectile replication delay compensation: https://devforum.roblox.com/t/projectile-replication-delay-compensation-with-fastcast/486679 (interpolation buffer and latency anecdotes, roughly 80–100 ms)

> DevForum pages couldn't be fetched directly from this environment (host not allowed). The claims above come from search-result summaries and are cross-checked against the local official docs wherever possible.
