# 11 — Multiplayer, Physics & Combat Systems

> Chapter scope: **gameplay systems** for original Roblox multiplayer games: netcode, hit detection, melee, projectiles, guns, abilities, status effects, damage, NPC waves, vehicles, physics movers, character controllers, rounds/lobbies/matchmaking, inventory, trading, leaderboards, cross-server events, anti-exploit, and cross-device input.
> General Luau architecture, DataStore basics and remote basics live in other chapters. This one assumes you know `RemoteEvent`, `ModuleScript`, and `pcall`.
> APIs checked against the local engine API dump (`reference/api/API-Dump.txt`) and creator-docs snapshot, as of 2026-11-05.

---

## TL;DR rules for the bot

1. **The server is the only source of truth for damage, health, currency, inventory, cooldowns, and round state.** Clients send *intent* ("I pressed attack, aiming here"). They never send results ("I hit X for 50").
2. **Pick a netcode model first.** For most games, use the **classic model** (`Workspace.AuthorityMode = Automatic`): the client owns its character physics, and the server validates combat. For competitive FPS, racing or sports, consider **Server Authority** (`AuthorityMode = Server`, opt-in, fully released in 2026). It gives prediction and rollback through `RunService:BindToSimulation()`. Read §2 before you mix the two.
3. **Hit detection: use spatial queries, not `Touched`.** Use `workspace:Raycast` for hitscan, `Blockcast`/`Spherecast`/`Shapecast` for swept melee and thick projectiles, and `GetPartBoundsInBox`/`GetPartBoundsInRadius`/`GetPartsInPart` with `OverlapParams` for instant hitboxes. Use `Touched` only for slow triggers such as pickups, lava and zones.
4. **Every combat remote handler must:** type-check every argument (`typeof`), reject NaN and infinity, rate-limit per player, check that the player is alive and not stunned, check the cooldown with a *server* clock, and check distance and line of sight against *server* positions plus a ping-based tolerance.
5. **Damage goes through ONE function** (`DamageService.Apply`). It handles i-frames, block, parry, armor, attribution (who hit whom, for kill credit and assists), and the death event. Never write `humanoid.Health -= x` anywhere else.
6. **Combat state lives in attributes** on the character (`Stunned`, `Blocking`, `IFrameUntil`, …). Attributes replicate to the client for UI, and they work as synced state under Server Authority. Only the server writes them in the classic model.
7. **Knockback on a player character must run where the physics runs.** The client owns its character, so a server-side `ApplyImpulse` on a client-owned assembly is overridden. Either fire the victim's client to apply it, or briefly `SetNetworkOwner(nil)`. NPCs are server-owned, so apply knockback on the server.
8. **Use the modern mover constraints:** `LinearVelocity`, `AngularVelocity`, `AlignPosition`, `AlignOrientation`, `VectorForce`, and `BasePart:ApplyImpulse`. Never use the deprecated `BodyVelocity`, `BodyGyro`, `BodyPosition` or `BodyForce` in new code.
9. **Projectiles: the server simulates or verifies.** The client renders the projectile right away. The server checks origin, rate and ammo, then simulates the same ballistic path with raycasts per step and decides hits. Other clients only get a cosmetic replication event (`UnreliableRemoteEvent` is fine for this).
10. **For lag compensation, keep about 1 s of server-side position history** per character. Rewind targets by roughly `ping/2 + interpolation delay` (cap it at about 250 ms) when you validate a hitscan shot.
11. **NPCs:** call `SetNetworkOwner(nil)` on their root part, tick the AI at 4–10 Hz rather than every frame, cap concurrent NPCs, pool or `Destroy` corpses, and route NPC attacks through the same `DamageService`.
12. **Vehicles:** give network ownership to the driver (`seat:SetNetworkOwner(player)` when `Occupant` changes, `SetNetworkOwnershipAuto()` when they leave). Drive wheels with `HingeConstraint` motors and `SpringConstraint`/`CylindricalConstraint` suspension.
13. **Reserved servers: `TeleportService:ReserveServer`/`ReserveServerAsync` and `TeleportOptions.ShouldReserveServer`/`ReservedServerAccessCode` are DEPRECATED.** Set `TeleportOptions.ReservedServerId = HttpService:GenerateGUID(false)` and call `TeleportService:TeleportAsync`. Wrap every teleport in `pcall` with retries, and handle `TeleportInitFailed`.
14. **Matchmaking across lobby servers:** put entries in a `MemoryStoreQueue` (party = one entry), let one reader pop a match, announce it with `MessagingService`, then teleport with a shared `ReservedServerId`. Do not call `RemoveAsync` on entries you didn't use; they become visible again after the invisibility timeout.
15. **Trades are server-side state machines:** offer, lock (both "ready"), countdown, both confirm, then re-verify ownership, swap items in one non-yielding block, and journal it. Any change to the offer resets both confirmations. Items carry unique IDs so dupes are detectable.
16. **Global leaderboards: `OrderedDataStore`** with integer values. Write on a throttled interval and on leave. Read with `GetSortedAsync(false, ≤100)` every 60 s or more and cache the result. Don't read per player.
17. **MessagingService:** 1 kB per message, and best-effort delivery, so it is *not* guaranteed. Use it for announcements and match notifications only, never as the single record of anything valuable.
18. **Input:** the **Input Action System** (`InputContext` → `InputAction` → `InputBinding`) is the modern cross-device path and is *required* under Server Authority. Give every action a keyboard/mouse, gamepad, and touch (`InputBinding.UIButton`) binding. `ContextActionService` and `UserInputService` still work. Use `UserInputService.PreferredInput` to adapt the UI.
19. **Prefer `Player:LoadCharacterAsync()`** (`LoadCharacter` is deprecated). Use `Humanoid:ApplyDescriptionAsync` (`ApplyDescription` is deprecated).
20. **Under Server Authority, `Tool`s are not fully supported.** Build equippables as welded models plus an attribute. In the classic model, `Tool` is fine for simple weapons, but run all logic on the server.
21. **Anti-exploit is server math,** not client detection. Compare server-observed position deltas to the maximum legal speed, check the floor raycast for fly, rate-limit every remote, and log anomalies before you kick (false positives from lag are common).
22. **Use `workspace:GetServerTimeNow()` for a shared clock** in UI countdowns and cooldown displays. Use `os.clock()` for server-only elapsed-time checks. Under Server Authority, use `time()` inside bound simulation functions.

---

## 1. Networking model and latency

### 1.1 What replicates and who simulates

| Thing | Authority (classic model) | Replicates? |
|---|---|---|
| Instances/properties changed by the server | Server | Server → all clients (subject to streaming) |
| Instances/properties changed by a client | That client | **No** (FilteringEnabled). Exceptions: physics of parts the client *owns*, and some character/Humanoid/Animator state. |
| Physics of the player's own character | Client (network owner) | Client → server → other clients. **The client can lie** (speed, fly, teleport). |
| Unanchored parts near a player | Auto-assigned owner (often that client) | Owner → others |
| Anchored parts | Always server | — |
| Attributes set on the server | Server | Yes |
| `RemoteEvent` | Explicit | Reliable, ordered *per remote* |
| `UnreliableRemoteEvent` | Explicit | Unordered, may drop, payload ~1000 bytes. Good for cosmetic, high-frequency data. |

Remote rate limit is roughly **500 requests per second per client, shared across all remotes of the same type**. Your own per-feature limits should be much stricter.

### 1.2 The latency facts you design around

- **Ping** (`Player:GetNetworkPing()`, round-trip, in seconds) is typically 50–200 ms, and higher on mobile or in other regions. One-way delay is about ping/2.
- **Other players are rendered in the past.** Roblox buffers replicated physics and interpolates between snapshots. Community measurements put the extra buffer at roughly 50–100 ms on top of one-way latency. It isn't documented precisely, so treat it as a tunable constant.
- So when player A shoots at B on A's screen, B was actually about `ping_A/2 + interp + ping_B/2` further along on the server. Without lag compensation, fair shots miss. With unbounded compensation, players get hit "behind walls". **Cap compensation** at 200–300 ms.

### 1.3 The four techniques

| Technique | What it does | How on Roblox |
|---|---|---|
| **Client prediction** | Show the local result of input immediately | Classic: play the animation/VFX locally on input and move the character locally (it's client-owned anyway). Server Authority: built in, via `BindToSimulation`. |
| **Server reconciliation** | Server corrects a wrong client guess | Classic: the server rejects the action and fires a "denied" event; the client rolls back UI/VFX (refund ammo display, cancel the animation). Server Authority: automatic rollback and resimulation. |
| **Lag compensation** | Server judges hits against where targets *were* on the shooter's screen | Position history buffer plus rewind (§1.5). |
| **Interpolation / smoothing** | Hide jitter for remote objects | Engine-interpolated for physics. For custom state, lerp in `RenderStepped`, or use `TweenService:SmoothDamp` (used in the official server-authority smoothing sample). |

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
| Destroying instances | Anywhere | Not inside bound functions. Flag with an attribute, destroy in `RunService.PostSimulation` on the server. |
| Cost | Normal | Higher server utilization |
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

### 3.2 Turning parts into unique characters

```lua
-- Collect unique Humanoids from a list of parts (one hit per character per swing)
local function humanoidsFromParts(parts: { Instance }, ignore: Model?): { Humanoid }
	local seen: { [Humanoid]: boolean } = {}
	local out = {}
	for _, part in parts do
		local model = part:FindFirstAncestorOfClass("Model")
		while model and not model:FindFirstChildOfClass("Humanoid") do
			model = model:FindFirstAncestorOfClass("Model") -- accessories/tools nest deeper
		end
		if model and model ~= ignore then
			local hum = model:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 and not seen[hum] then
				seen[hum] = true
				table.insert(out, hum)
			end
		end
	end
	return out
end
```

### 3.3 Why not `Touched`

- It fires only on **physics contact**, and is unreliable for fast or thin parts (tunnelling), anchored-vs-anchored parts, and `CanTouch = false` parts.
- It fires on the **network owner's** simulation. For client-owned characters, touches against your server hitbox are reported late or spoofable.
- It fires many times per contact (each limb) and needs debouncing. `TouchEnded` is flaky.
- Welding a hitbox part to a swinging sword animates it only on the client that plays the animation. The server's copy of `Motor6D` transforms isn't the client's.

**Use `Touched` for:** pickups, kill bricks, zone entry on slow-moving players (debounced per character). For zones, prefer periodic `GetPartBoundsInBox` checks or the ZonePlus pattern.

### 3.4 Visualizing hitboxes in Studio

```lua
local DEBUG_HITBOX = game:GetService("RunService"):IsStudio()
local function debugBox(cf: CFrame, size: Vector3, color: Color3)
	if not DEBUG_HITBOX then return end
	local p = Instance.new("Part")
	p.Anchored, p.CanCollide, p.CanQuery, p.CanTouch = true, false, false, false
	p.Transparency, p.Color, p.Material = 0.7, color, Enum.Material.ForceField
	p.CFrame, p.Size = cf, size
	p.Parent = workspace
	game:GetService("Debris"):AddItem(p, 0.25)
end
```

---

## 4. Health and damage pipeline (with attribution)

One module owns all health changes. Melee, projectiles, abilities, NPCs and hazards all call it.

```lua
--!strict
-- ServerScriptService/Combat/DamageService.luau
local Players = game:GetService("Players")

export type DamageInfo = {
	Amount: number,
	Source: Player? | Model?, -- attacker player, or NPC model
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

Data-driven effects with stacking rules. They modify *derived* stats, never base stats, so removing an effect always restores the right value.

```lua
--!strict
-- ServerScriptService/Combat/StatusEffects.luau
local RunService = game:GetService("RunService")
local DamageService = require(script.Parent.DamageService)

type EffectDef = {
	Duration: number,
	Stacking: "Refresh" | "Stack" | "Ignore",
	MaxStacks: number?,
	TickInterval: number?,
	OnTick: ((char: Model, stacks: number, source: any) -> ())?,
	Modifiers: { WalkSpeedMult: number?, DamageTakenMult: number?, DamageDealtMult: number? }?,
	Tag: string?, -- written as a boolean attribute while active (e.g. "Stunned", "Burning")
}

local DEFS: { [string]: EffectDef } = {
	Burn = {
		Duration = 4, Stacking = "Stack", MaxStacks = 5, TickInterval = 0.5, Tag = "Burning",
		OnTick = function(char, stacks, source)
			DamageService.Apply(char, { Amount = 2 * stacks, Source = source, Kind = "DoT", Unblockable = true, Parryable = false })
		end,
	},
	Slow = { Duration = 3, Stacking = "Refresh", Modifiers = { WalkSpeedMult = 0.6 } },
	Haste = { Duration = 5, Stacking = "Refresh", Modifiers = { WalkSpeedMult = 1.35 } },
	Fortify = { Duration = 6, Stacking = "Ignore", Modifiers = { DamageTakenMult = 0.7 } },
	Root = { Duration = 1.5, Stacking = "Refresh", Modifiers = { WalkSpeedMult = 0 }, Tag = "Rooted" },
}

type Active = { def: EffectDef, expires: number, stacks: number, nextTick: number, source: any }
local active: { [Model]: { [string]: Active } } = {}

local BASE_WALKSPEED = 16

local StatusEffects = {}

local function recompute(char: Model)
	local effects = active[char] or {}
	local ws, taken, dealt = 1, 1, 1
	local tags: { [string]: boolean } = {}
	for _, a in effects do
		local m = a.def.Modifiers
		if m then
			ws *= m.WalkSpeedMult or 1
			taken *= m.DamageTakenMult or 1
			dealt *= m.DamageDealtMult or 1
		end
		if a.def.Tag then tags[a.def.Tag] = true end
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local stunned = (char:GetAttribute("StunnedUntil") or 0) > os.clock()
	if hum then
		hum.WalkSpeed = if stunned then 0 else BASE_WALKSPEED * ws
	end
	char:SetAttribute("DamageTakenMult", taken)
	char:SetAttribute("DamageDealtMult", dealt)
	for name, def in DEFS do
		if def.Tag then char:SetAttribute(def.Tag, tags[def.Tag] == true) end
	end
end

function StatusEffects.Apply(char: Model, effectId: string, source: any?, durationOverride: number?)
	local def = DEFS[effectId]
	if not def then return end
	local list = active[char]
	if not list then
		list = {}
		active[char] = list
		char.Destroying:Connect(function() active[char] = nil end)
	end
	local t = os.clock()
	local dur = durationOverride or def.Duration
	local a = list[effectId]
	if a then
		if def.Stacking == "Ignore" then return end
		if def.Stacking == "Stack" then a.stacks = math.min(a.stacks + 1, def.MaxStacks or 99) end
		a.expires = t + dur
		a.source = source
	else
		list[effectId] = { def = def, expires = t + dur, stacks = 1, nextTick = t + (def.TickInterval or math.huge), source = source }
	end
	recompute(char)
end

function StatusEffects.Remove(char: Model, effectId: string)
	local list = active[char]
	if list and list[effectId] then
		list[effectId] = nil
		recompute(char)
	end
end

function StatusEffects.Cleanse(char: Model)
	active[char] = {}
	recompute(char)
end

-- One loop for all effects (cheaper than a thread per effect)
local accum = 0
RunService.Heartbeat:Connect(function(dt)
	accum += dt
	if accum < 0.1 then return end -- 10 Hz is plenty
	accum = 0
	local t = os.clock()
	for char, list in active do
		local changed = false
		for id, a in list do
			if a.def.OnTick and t >= a.nextTick then
				a.nextTick += a.def.TickInterval :: number
				task.spawn(a.def.OnTick, char, a.stacks, a.source)
			end
			if t >= a.expires then
				list[id] = nil
				changed = true
			end
		end
		-- also re-evaluate when stun expires
		if changed or char:GetAttribute("StunnedUntil") then recompute(char) end
	end
end)

return StatusEffects
```

Effects that also need to show on the client, such as icons, use the boolean tag attributes. For timers, write `effect_<id>_end = workspace:GetServerTimeNow() + dur` as an attribute.

---

## 6. Data-driven abilities and cooldowns

### 6.1 Design

- **Definitions are data** (a ModuleScript in `ReplicatedStorage` so the client can read names, icons and cooldowns for UI). The **server-only executor** maps `Id → function`.
- The server stores the authoritative cooldown (`os.clock()`) and mirrors it to a `workspace:GetServerTimeNow()` attribute for UI.
- **Charges** (for example, two dashes) and **global cooldown** (GCD) are built in.
- Each request is validated for type, ownership (the player has the ability equipped or unlocked), alive and not stunned, cooldown, rate, and argument sanity.

```lua
--!strict
-- ReplicatedStorage/Shared/AbilityDefs.luau  (readable by client for UI)
export type AbilityDef = {
	Id: string,
	DisplayName: string,
	Cooldown: number,       -- seconds per charge
	Charges: number?,       -- default 1
	CastTime: number?,      -- wind-up before effect (server waits)
	GCD: number?,           -- global cooldown triggered
	Range: number?,
	Icon: string?,
	RequiresAim: boolean?,
}

local Defs: { [string]: AbilityDef } = {
	Dash = { Id = "Dash", DisplayName = "Dash", Cooldown = 3, Charges = 2, GCD = 0.2 },
	Fireball = { Id = "Fireball", DisplayName = "Fireball", Cooldown = 6, CastTime = 0.35, GCD = 0.5, Range = 120, RequiresAim = true },
	Shockwave = { Id = "Shockwave", DisplayName = "Shockwave", Cooldown = 10, CastTime = 0.5, GCD = 0.5, Range = 14 },
	Heal = { Id = "Heal", DisplayName = "Mend", Cooldown = 15, CastTime = 1.0, GCD = 1.0 },
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
local AbilityFeedback = Remotes:WaitForChild("AbilityFeedback") :: RemoteEvent -- server -> client: accepted/denied
local Knockback = Remotes:WaitForChild("Knockback") :: RemoteEvent
DamageService.SetKnockbackRemote(Knockback)

type PlayerState = {
	charges: { [string]: number },
	nextChargeAt: { [string]: number },
	gcdUntil: number,
	casting: boolean,
	requestTimes: { number },
}
local states: { [Player]: PlayerState } = {}

local MAX_REQUESTS_PER_SEC = 8

local function getState(p: Player): PlayerState
	local s = states[p]
	if not s then
		s = { charges = {}, nextChargeAt = {}, gcdUntil = 0, casting = false, requestTimes = {} }
		states[p] = s
	end
	return s
end
Players.PlayerRemoving:Connect(function(p) states[p] = nil end)

local function rateLimited(s: PlayerState): boolean
	local t = os.clock()
	local times = s.requestTimes
	while #times > 0 and t - times[1] > 1 do table.remove(times, 1) end
	if #times >= MAX_REQUESTS_PER_SEC then return true end
	table.insert(times, t)
	return false
end

local function ownsAbility(p: Player, id: string): boolean
	-- Replace with your loadout/profile check. Example: attribute list "Dash,Fireball"
	local loadout = p:GetAttribute("Loadout")
	if type(loadout) ~= "string" then return false end
	for item in string.gmatch(loadout, "[^,]+") do
		if item == id then return true end
	end
	return false
end

local function canAct(char: Model?): boolean
	if not char then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return false end
	if (char:GetAttribute("StunnedUntil") or 0) > os.clock() then return false end
	return true
end

-- Refill charges lazily based on time
local function refreshCharges(s: PlayerState, def: AbilityDefs.AbilityDef)
	local max = def.Charges or 1
	local c = s.charges[def.Id]
	if c == nil then
		s.charges[def.Id] = max
		return
	end
	local t = os.clock()
	while c < max and s.nextChargeAt[def.Id] and t >= s.nextChargeAt[def.Id] do
		c += 1
		s.nextChargeAt[def.Id] = if c < max then s.nextChargeAt[def.Id] + def.Cooldown else nil :: any
	end
	s.charges[def.Id] = c
end

local function publishCooldown(p: Player, s: PlayerState, def: AbilityDefs.AbilityDef)
	-- UI mirror on the shared clock
	local offset = workspace:GetServerTimeNow() - os.clock()
	local nextAt = s.nextChargeAt[def.Id]
	p:SetAttribute("Cd_" .. def.Id, if nextAt then nextAt + offset else 0)
	p:SetAttribute("Ch_" .. def.Id, s.charges[def.Id])
end

-- Executors: server-only effects. aim is a validated unit Vector3 or nil.
local Executors: { [string]: (p: Player, char: Model, def: AbilityDefs.AbilityDef, aim: Vector3?) -> () } = {
	Dash = function(p, char, def, aim)
		local root = char:FindFirstChild("HumanoidRootPart") :: BasePart
		local dir = root.CFrame.LookVector * Vector3.new(1, 0, 1)
		-- Client-owned character: ask the owner to apply velocity (validated magnitude)
		Knockback:FireClient(p, dir.Unit * 70)
		char:SetAttribute("IFrameUntil", os.clock() + 0.25) -- dash i-frames
	end,
	Fireball = function(p, char, def, aim)
		local head = char:FindFirstChild("Head") :: BasePart
		Projectiles.FireServerProjectile({
			Shooter = p, Origin = head.Position, Direction = aim :: Vector3,
			Speed = 90, Gravity = 0, MaxDistance = def.Range or 120, Damage = 30,
			OnHit = function(hitChar: Model)
				StatusEffects.Apply(hitChar, "Burn", p)
			end,
		})
	end,
	Shockwave = function(p, char, def, aim)
		local root = char:FindFirstChild("HumanoidRootPart") :: BasePart
		local params = OverlapParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { char }
		local parts = workspace:GetPartBoundsInRadius(root.Position, def.Range or 14, params)
		local hit: { [Model]: boolean } = {}
		for _, part in parts do
			local m = part:FindFirstAncestorOfClass("Model")
			if m and not hit[m] and m:FindFirstChildOfClass("Humanoid") then
				hit[m] = true
				local mRoot = m:FindFirstChild("HumanoidRootPart") :: BasePart?
				if mRoot then
					local away = (mRoot.Position - root.Position) * Vector3.new(1, 0, 1)
					local kb = (if away.Magnitude > 0 then away.Unit else root.CFrame.LookVector) * 50 + Vector3.new(0, 30, 0)
					DamageService.Apply(m, { Amount = 20, Source = p, Kind = "Ability", WeaponId = "Shockwave",
						Knockback = kb, StunTime = 0.6, Origin = root.Position })
				end
			end
		end
	end,
	Heal = function(p, char)
		local hum = char:FindFirstChildOfClass("Humanoid") :: Humanoid
		hum.Health = math.min(hum.MaxHealth, hum.Health + 40)
	end,
}

UseAbility.OnServerEvent:Connect(function(player: Player, abilityId: unknown, aim: unknown)
	-- 1. Type checks (never trust argument types)
	if type(abilityId) ~= "string" or #abilityId > 32 then return end
	local def = AbilityDefs[abilityId]
	if not def then return end
	local s = getState(player)
	if rateLimited(s) then return end

	local aimVec: Vector3? = nil
	if def.RequiresAim then
		if typeof(aim) ~= "Vector3" then return end
		local v = aim :: Vector3
		if v.X ~= v.X or v.Y ~= v.Y or v.Z ~= v.Z then return end -- NaN
		if v.Magnitude < 0.5 or v.Magnitude > 1.5 then return end -- must be ~unit
		aimVec = v.Unit
	end

	-- 2. Ownership, state
	if not ownsAbility(player, def.Id) then return end
	local char = player.Character
	if not canAct(char) or s.casting then
		AbilityFeedback:FireClient(player, def.Id, false, "busy")
		return
	end
	local t = os.clock()
	if t < s.gcdUntil then
		AbilityFeedback:FireClient(player, def.Id, false, "gcd")
		return
	end

	-- 3. Cooldown / charges
	refreshCharges(s, def)
	if (s.charges[def.Id] or 0) <= 0 then
		AbilityFeedback:FireClient(player, def.Id, false, "cooldown")
		return
	end

	-- 4. Commit cost BEFORE yielding (prevents double-cast during cast time)
	s.charges[def.Id] -= 1
	if not s.nextChargeAt[def.Id] then s.nextChargeAt[def.Id] = t + def.Cooldown end
	s.gcdUntil = t + (def.GCD or 0)
	publishCooldown(player, s, def)
	AbilityFeedback:FireClient(player, def.Id, true)

	-- 5. Cast time (interruptible by stun/death)
	if def.CastTime and def.CastTime > 0 then
		s.casting = true
		char:SetAttribute("Casting", def.Id)
		task.wait(def.CastTime)
		s.casting = false
		if char.Parent then char:SetAttribute("Casting", nil) end
		if not canAct(char) or player.Character ~= char then return end -- interrupted: cooldown still spent
	end

	Executors[def.Id](player, char :: Model, def, aimVec)
end)
```

Client side, for responsiveness: play the cast animation and VFX immediately on input, gray the button using `Cd_<Id>` minus `workspace:GetServerTimeNow()`, and cancel the VFX if `AbilityFeedback` returns `false`.

Client knockback receiver. Validate even here, since a server bug shouldn't be able to fling a player into orbit:

```lua
-- StarterPlayerScripts/KnockbackClient.client.luau
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knockback = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Knockback")

Knockback.OnClientEvent:Connect(function(velocity: Vector3)
	local char = Players.LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root or velocity.Magnitude > 300 then return end
	-- Set velocity directly for a crisp, mass-independent hit
	root.AssemblyLinearVelocity = velocity
	-- Optional: briefly stop the Humanoid from fighting the velocity
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum and velocity.Y > 20 then
		hum:ChangeState(Enum.HumanoidStateType.Freefall)
	end
end)
```

---

## 7. Melee combat system

### 7.1 Architecture

```
Client                                   Server
------                                   ------
Input (IAS/CAS) ──► local anim + swing   
  sends Attack(comboHint) ───────────►  validate: alive, not stunned, not blocking,
                                         rate, per-step cooldown, combo window
                                         compute comboIndex (server-owned)
                                         wait windup (from weapon data)
                                         hitbox from SERVER root CFrame (+lag padding)
                                         GetPartBoundsInBox / Blockcast
                                         per-target: range & facing checks
                                         DamageService.Apply (block/parry/iframes)
                                         stun, knockback, hit-stop event
  ◄────────── HitConfirm (VFX, sound, damage numbers) to attacker & nearby
```

**Why server-side hitboxes and not client-reported hits?** Client hit lists are easy to forge, for example "I hit everyone within 200 studs". A server box from the attacker's *server* position, padded by a few studs for lag, is fair enough for melee ranges of 5–8 studs. If your game needs pixel-perfect melee, accept client-reported targets but validate each one against `PositionHistory` (rewound distance ≤ range + tolerance, facing, one hit per swing).

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

local Defs: { [string]: MeleeDef } = {
	Fists = {
		Id = "Fists",
		ComboResetTime = 0.9,
		Steps = {
			{ Damage = 6, Windup = 0.12, Active = 0.10, Recovery = 0.18, HitboxSize = Vector3.new(4, 5, 4.5),
			  HitboxOffset = CFrame.new(0, 0, -3), Stun = 0.35, Knockback = 4, Anim = "rbxassetid://0" },
			{ Damage = 6, Windup = 0.12, Active = 0.10, Recovery = 0.18, HitboxSize = Vector3.new(4, 5, 4.5),
			  HitboxOffset = CFrame.new(0, 0, -3), Stun = 0.35, Knockback = 4, Anim = "rbxassetid://0" },
			{ Damage = 8, Windup = 0.15, Active = 0.12, Recovery = 0.22, HitboxSize = Vector3.new(4.5, 5, 5),
			  HitboxOffset = CFrame.new(0, 0, -3.2), Stun = 0.45, Knockback = 6, Anim = "rbxassetid://0" },
			{ Damage = 12, Windup = 0.25, Active = 0.15, Recovery = 0.5, HitboxSize = Vector3.new(5, 6, 6),
			  HitboxOffset = CFrame.new(0, 0, -3.5), Stun = 0.8, Knockback = 45, Launch = 25, Anim = "rbxassetid://0" },
		},
	},
}
return Defs
```

Replace `rbxassetid://0` with your own uploaded animations.

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

local LAG_PAD = 1.5          -- studs added to hitbox depth/width for latency
local ACTIVE_SAMPLES = 3     -- hitbox checks during the active window
local PARRY_WINDOW = 0.18
local BLOCK_WALKSPEED = 8

type Swing = { busyUntil: number, comboIndex: number, lastStepEnd: number, swingId: number }
local swings: { [Player]: Swing } = {}
Players.PlayerRemoving:Connect(function(p) swings[p] = nil end)

local function now() return os.clock() end

local function getWeapon(player: Player): MeleeDefs.MeleeDef
	local id = player:GetAttribute("EquippedMelee")
	return MeleeDefs[if type(id) == "string" then id else "Fists"] or MeleeDefs.Fists
end

local function alive(char: Model?): (Humanoid?, BasePart?)
	if not char then return nil, nil end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if hum and root and hum.Health > 0 then return hum, root end
	return nil, nil
end

local function playStepAnim(hum: Humanoid, animId: string)
	-- Server-played animations replicate to all clients via the Animator
	local animator = hum:FindFirstChildOfClass("Animator")
	if not animator or animId == "rbxassetid://0" then return end
	local anim = Instance.new("Animation")
	anim.AnimationId = animId
	local track = animator:LoadAnimation(anim)
	track.Priority = Enum.AnimationPriority.Action
	track:Play(0.05)
end

local function doHitbox(player: Player, char: Model, root: BasePart, step: MeleeDefs.ComboStep,
	alreadyHit: { [Model]: boolean })
	local size = step.HitboxSize + Vector3.new(LAG_PAD, 0, LAG_PAD)
	local cf = root.CFrame * step.HitboxOffset * CFrame.new(0, 0, -LAG_PAD / 2)

	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { char }
	params.MaxParts = 64

	for _, part in workspace:GetPartBoundsInBox(cf, size, params) do
		local model = part:FindFirstAncestorOfClass("Model")
		if model and not alreadyHit[model] then
			local hum = model:FindFirstChildOfClass("Humanoid")
			local tRoot = model:FindFirstChild("HumanoidRootPart") :: BasePart?
			if hum and tRoot and hum.Health > 0 then
				alreadyHit[model] = true
				-- Line-of-sight: don't hit through walls
				local rp = RaycastParams.new()
				rp.FilterType = Enum.RaycastFilterType.Exclude
				rp.FilterDescendantsInstances = { char, model }
				local blocked = workspace:Raycast(root.Position, tRoot.Position - root.Position, rp)
				if not blocked then
					local horiz = (tRoot.Position - root.Position) * Vector3.new(1, 0, 1)
					local dir = if horiz.Magnitude > 0.01 then horiz.Unit else root.CFrame.LookVector
					local dealtMult = char:GetAttribute("DamageDealtMult") or 1
					local result = DamageService.Apply(model, {
						Amount = step.Damage * dealtMult,
						Source = player,
						Kind = "Melee",
						WeaponId = getWeapon(player).Id,
						Knockback = dir * step.Knockback + Vector3.new(0, step.Launch or 0, 0),
						StunTime = step.Stun,
						Origin = root.Position,
					})
					if result ~= "Invalid" and result ~= "Immune" then
						HitConfirm:FireAllClients(model, result, tRoot.Position)
					end
				end
			end
		end
	end
end

AttackRemote.OnServerEvent:Connect(function(player: Player)
	local char = player.Character
	local hum, root = alive(char)
	if not hum or not root or not char then return end
	if (char:GetAttribute("StunnedUntil") or 0) > now() then return end
	if char:GetAttribute("Blocking") == true then return end
	if char:GetAttribute("Casting") then return end

	local s = swings[player]
	if not s then
		s = { busyUntil = 0, comboIndex = 0, lastStepEnd = 0, swingId = 0 }
		swings[player] = s
	end
	local t = now()
	if t < s.busyUntil then return end -- still in previous step: drop (client may buffer)

	local weapon = getWeapon(player)
	-- Server owns the combo counter; the client cannot skip to the finisher
	if t - s.lastStepEnd > weapon.ComboResetTime or s.comboIndex >= #weapon.Steps then
		s.comboIndex = 0
	end
	s.comboIndex += 1
	local step = weapon.Steps[s.comboIndex]
	s.busyUntil = t + step.Windup + step.Active + step.Recovery
	s.swingId += 1
	local mySwing = s.swingId
	char:SetAttribute("Attacking", true)
	char:SetAttribute("ComboIndex", s.comboIndex)

	playStepAnim(hum, step.Anim)

	task.wait(step.Windup)
	-- Interrupted? (stunned during windup = trade lost)
	if (char:GetAttribute("StunnedUntil") or 0) > now() or hum.Health <= 0 or s.swingId ~= mySwing then
		char:SetAttribute("Attacking", false)
		return
	end

	local alreadyHit: { [Model]: boolean } = {}
	for i = 1, ACTIVE_SAMPLES do
		if hum.Health <= 0 then break end
		doHitbox(player, char, root, step, alreadyHit)
		if i < ACTIVE_SAMPLES then task.wait(step.Active / (ACTIVE_SAMPLES - 1)) end
	end

	s.lastStepEnd = now()
	task.wait(step.Recovery)
	if s.swingId == mySwing and char.Parent then char:SetAttribute("Attacking", false) end
end)

-- Block / parry: hold to block; the first PARRY_WINDOW seconds of a block are a parry.
local lastBlockStart: { [Player]: number } = {}
BlockRemote.OnServerEvent:Connect(function(player: Player, holding: unknown)
	if type(holding) ~= "boolean" then return end
	local char = player.Character
	local hum = alive(char)
	if not hum or not char then return end
	if holding then
		if (char:GetAttribute("StunnedUntil") or 0) > now() or char:GetAttribute("Attacking") then return end
		-- Anti-spam: parry only if the last block started > 0.6s ago (no parry-mashing)
		local last = lastBlockStart[player] or 0
		if now() - last > 0.6 then
			char:SetAttribute("ParryUntil", now() + PARRY_WINDOW)
		end
		lastBlockStart[player] = now()
		char:SetAttribute("Blocking", true)
		hum.WalkSpeed = BLOCK_WALKSPEED
	else
		char:SetAttribute("Blocking", false)
		char:SetAttribute("ParryUntil", 0)
		hum.WalkSpeed = 16 -- or let StatusEffects recompute
	end
end)

-- Guard regen
task.spawn(function()
	while true do
		task.wait(0.5)
		for _, p in Players:GetPlayers() do
			local c = p.Character
			if c and c:GetAttribute("Blocking") ~= true then
				c:SetAttribute("Guard", math.min(100, (c:GetAttribute("Guard") or 100) + 5))
			end
		end
	end
end)
```

### 7.4 Melee client (input buffering, local feel)

```lua
-- StarterPlayerScripts/MeleeClient.client.luau
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local AttackRemote = Remotes:WaitForChild("MeleeAttack")
local BlockRemote = Remotes:WaitForChild("MeleeBlock")
local HitConfirm = Remotes:WaitForChild("MeleeHitConfirm")

local player = Players.LocalPlayer
local BUFFER_WINDOW = 0.25
local bufferedAt = 0
local nextAllowed = 0

local function tryAttack()
	local char = player.Character
	if not char or char:GetAttribute("StunnedUntil") then
		-- StunnedUntil is a server os.clock; only presence is meaningful client-side.
	end
	local t = os.clock()
	if t < nextAllowed then
		bufferedAt = t -- remember the press; fire when the current step ends
		return
	end
	nextAllowed = t + 0.3 -- rough local gate; the server has the real one
	AttackRemote:FireServer()
end

ContextActionService:BindAction("Attack", function(_, state)
	if state == Enum.UserInputState.Begin then tryAttack() end
	return Enum.ContextActionResult.Pass
end, true, Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2)

ContextActionService:BindAction("Block", function(_, state)
	if state == Enum.UserInputState.Begin then BlockRemote:FireServer(true)
	elseif state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then BlockRemote:FireServer(false) end
	return Enum.ContextActionResult.Sink
end, true, Enum.KeyCode.F, Enum.KeyCode.ButtonL2)
ContextActionService:SetTitle("Attack", "Hit")
ContextActionService:SetTitle("Block", "Block")

-- Drain the buffer
game:GetService("RunService").Heartbeat:Connect(function()
	if bufferedAt > 0 and os.clock() >= nextAllowed then
		if os.clock() - bufferedAt <= BUFFER_WINDOW + 0.3 then tryAttack() end
		bufferedAt = 0
	end
end)

-- Hit feedback (VFX/sound/camera shake) - purely cosmetic
HitConfirm.OnClientEvent:Connect(function(model: Model, result: string, pos: Vector3)
	-- spawn a hit spark at pos, play sound, show damage number, small hitstop on own attacks
end)
```

### 7.5 Melee design checklist

- **Combos:** the server owns the step index. Reset after `ComboResetTime`. The finisher has more recovery, which gives counterplay.
- **Stun:** `StunnedUntil` blocks attack, block and abilities, and sets WalkSpeed to 0 through StatusEffects. Add **stun decay or immunity** after N consecutive hits (`ComboImmuneUntil`) to stop infinite combos.
- **I-frames:** set `IFrameUntil` on dash, on rising from knockdown, and on respawn (2–3 s).
- **Hit-stop:** pause the attacker's and victim's animation tracks for 50–80 ms *on clients* (`track:AdjustSpeed(0)` then restore). Never do this on the server.
- **Knockback:** the victim's client sets `AssemblyLinearVelocity`. For NPCs, the server calls `ApplyImpulse(mass * deltaV)`. For long, controlled launches, use a `LinearVelocity` with `MaxForce` for 0.2 s, then destroy it (§11).
- **Facing for block/parry:** use a dot product against the victim's `LookVector`. Back attacks ignore block.

---

## 8. Projectile systems (FastCast-style, server verified)

### 8.1 Concept

A "FastCast-style" projectile isn't a physics part. It's a **math path stepped with raycasts**: each frame, compute `p(t) = origin + v0·t + ½·g·t²` and raycast from the last position to the new one. That makes it immune to tunnelling, cheap, and deterministic, so client and server agree. FastCast (community module) and SecureCast (community, server-authoritative with lag compensation) implement this. Below is a self-contained version.

**Flow:**
1. The client presses fire. It immediately simulates a **cosmetic** projectile locally (no damage) and sends `Fire(origin, direction, clientTime)`.
2. The server validates: rate (fire-rate gate), ammo, origin within N studs of the server head position, direction is a unit vector, the weapon is equipped.
3. The server simulates the **authoritative** projectile, optionally *fast-forwarded* by the shooter's one-way latency so it lines up with what the shooter saw.
4. The server broadcasts `Replicate(shooter, origin, direction, speed)` to the other clients, who render cosmetic copies (skip the shooter).
5. On a server hit, call `DamageService.Apply`, then broadcast the impact.

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

export type FireArgs = {
	Shooter: Player, Origin: Vector3, Direction: Vector3,
	Speed: number, Gravity: number, MaxDistance: number, Damage: number,
	FastForward: number?, -- seconds to pre-simulate (lag compensation)
	OnHit: ((Model) -> ())?,
}

type Live = { state: Ballistics.CastState, args: FireArgs }
local live: { Live } = {}

local ProjectileService = {}

local function findCharacter(inst: Instance): Model?
	local m = inst:FindFirstAncestorOfClass("Model")
	while m do
		if m:FindFirstChildOfClass("Humanoid") then return m end
		m = m:FindFirstAncestorOfClass("Model")
	end
	return nil
end

local function onHit(p: Live, result: RaycastResult)
	local char = findCharacter(result.Instance)
	if char then
		local shooterChar = p.args.Shooter.Character
		local dealtMult = shooterChar and shooterChar:GetAttribute("DamageDealtMult") or 1
		local isHead = result.Instance.Name == "Head"
		local r = DamageService.Apply(char, {
			Amount = p.args.Damage * dealtMult * (if isHead then 1.5 else 1),
			Source = p.args.Shooter, Kind = "Projectile", Origin = p.state.origin,
			Knockback = p.state.velocity.Unit * 5,
		})
		if r ~= "Invalid" and p.args.OnHit then p.args.OnHit(char) end
	end
	ImpactRemote:FireAllClients(result.Position, result.Normal, result.Material)
end

function ProjectileService.FireServerProjectile(args: FireArgs)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local exclude: { Instance } = { workspace:FindFirstChild("Projectiles") or workspace.Terrain:FindFirstChild("__none") or nil :: any }
	if args.Shooter.Character then table.insert(exclude, args.Shooter.Character) end
	params.FilterDescendantsInstances = exclude

	local state = Ballistics.New(args.Origin, args.Direction, args.Speed, args.Gravity, args.MaxDistance, params)
	local p: Live = { state = state, args = args }

	-- Others render cosmetic copies
	for _, other in Players:GetPlayers() do
		if other ~= args.Shooter then
			ReplicateRemote:FireClient(other, args.Origin, args.Direction, args.Speed, args.Gravity, args.MaxDistance)
		end
	end

	-- Lag compensation: pre-simulate the time the shot spent in transit
	local ff = math.clamp(args.FastForward or 0, 0, 0.2)
	if ff > 0 then
		local hit, done = Ballistics.Step(state, ff)
		if hit then onHit(p, hit) return end
		if done then return end
	end
	table.insert(live, p)
end

RunService.Heartbeat:Connect(function(dt)
	for i = #live, 1, -1 do
		local p = live[i]
		local hit, done = Ballistics.Step(p.state, dt)
		if hit then onHit(p, hit) end
		if hit or done then
			live[i] = live[#live]
			live[#live] = nil
		end
	end
end)

return ProjectileService
```

> The `exclude` line keeps a "Projectiles" cosmetic folder out of hits if one exists. Simplify it for your project, for example `{ workspace.Effects, char }`.

### 8.4 Fire remote with full validation

```lua
--!strict
-- ServerScriptService/Combat/GunService.server.luau  (projectile weapons)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProjectileService = require(script.Parent.ProjectileService)

local FireRemote = ReplicatedStorage.Remotes:WaitForChild("ProjectileFire") :: RemoteEvent

local WEAPONS = {
	Crossbow = { RPM = 90, Speed = 220, Gravity = 40, Range = 600, Damage = 45, Mag = 1, Reload = 1.2 },
	Rifle = { RPM = 600, Speed = 900, Gravity = 10, Range = 1000, Damage = 18, Mag = 30, Reload = 2.0 },
}

local MAX_ORIGIN_OFFSET = 6 -- studs from server head (covers lag + muzzle offset)

type Ammo = { mag: number, reloadingUntil: number, nextShot: number }
local ammo: { [Player]: { [string]: Ammo } } = {}
Players.PlayerRemoving:Connect(function(p) ammo[p] = nil end)

local function isUnitVector(v: any): boolean
	if typeof(v) ~= "Vector3" then return false end
	if v.X ~= v.X or v.Y ~= v.Y or v.Z ~= v.Z then return false end
	return math.abs(v.Magnitude - 1) < 0.01
end

FireRemote.OnServerEvent:Connect(function(player: Player, weaponId: unknown, origin: unknown, direction: unknown)
	if type(weaponId) ~= "string" then return end
	local w = WEAPONS[weaponId]
	if not w then return end
	if player:GetAttribute("EquippedGun") ~= weaponId then return end
	if typeof(origin) ~= "Vector3" or not isUnitVector(direction) then return end

	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local head = char and char:FindFirstChild("Head") :: BasePart?
	if not hum or hum.Health <= 0 or not head then return end
	if ((origin :: Vector3) - head.Position).Magnitude > MAX_ORIGIN_OFFSET then return end
	-- Don't allow firing from inside walls: ray from head to claimed origin
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Exclude
	rp.FilterDescendantsInstances = { char :: Model }
	if workspace:Raycast(head.Position, (origin :: Vector3) - head.Position, rp) then return end

	local per = ammo[player] or {}
	ammo[player] = per
	local a = per[weaponId] or { mag = w.Mag, reloadingUntil = 0, nextShot = 0 }
	per[weaponId] = a
	local t = os.clock()
	if t < a.reloadingUntil then return end
	-- Fire-rate gate with a small tolerance for network jitter bunching
	if t < a.nextShot - 0.02 then return end
	if a.mag <= 0 then
		a.reloadingUntil = t + w.Reload
		a.mag = w.Mag
		return
	end
	a.mag -= 1
	a.nextShot = math.max(a.nextShot, t - 0.05) + 60 / w.RPM
	player:SetAttribute("Ammo_" .. weaponId, a.mag)

	ProjectileService.FireServerProjectile({
		Shooter = player, Origin = origin :: Vector3, Direction = direction :: Vector3,
		Speed = w.Speed, Gravity = w.Gravity, MaxDistance = w.Range, Damage = w.Damage,
		FastForward = player:GetNetworkPing() / 2,
	})
end)
```

`a.nextShot = max(nextShot, t - 0.05) + interval` is a "token bucket lite". It tolerates packets arriving bunched by jitter, but over time it can't exceed the RPM.

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
-- StarterPlayerScripts/GunClient.client.luau (excerpt)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FireRemote = ReplicatedStorage.Remotes:WaitForChild("ProjectileFire")

local camera = workspace.CurrentCamera
local player = Players.LocalPlayer

local GUN = {
	Id = "Rifle", RPM = 600,
	HipSpread = math.rad(3.0), AdsSpread = math.rad(0.6), MoveSpreadAdd = math.rad(2.0),
	RecoilPitch = math.rad(1.2), RecoilYawJitter = math.rad(0.4), RecoilRecover = 8, -- per second
	HipFov = 70, AdsFov = 50, AdsTime = 0.15,
}

local aiming = false
local recoilPitch = 0 -- accumulated camera kick to recover
local fovAlpha = 0
local nextShot = 0
local rng = Random.new()

-- Random direction inside a cone (uniform on the cap)
local function spreadDirection(dir: Vector3, angle: number): Vector3
	local cf = CFrame.lookAt(Vector3.zero, dir)
	local z = 1 - rng:NextNumber() * (1 - math.cos(angle))
	local theta = rng:NextNumber() * 2 * math.pi
	local r = math.sqrt(1 - z * z)
	return cf:VectorToWorldSpace(Vector3.new(r * math.cos(theta), r * math.sin(theta), -z)).Unit
end

local function currentSpread(): number
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local moving = hum and hum.MoveDirection.Magnitude > 0.1
	local base = if aiming then GUN.AdsSpread else GUN.HipSpread
	return base + (if moving then GUN.MoveSpreadAdd else 0)
end

local function fire()
	local t = os.clock()
	if t < nextShot then return end
	nextShot = t + 60 / GUN.RPM
	local head = player.Character and player.Character:FindFirstChild("Head")
	if not head then return end

	local dir = spreadDirection(camera.CFrame.LookVector, currentSpread())
	local origin = head.Position
	FireRemote:FireServer(GUN.Id, origin, dir) -- server re-validates everything
	-- local cosmetic tracer/muzzle flash here

	-- Recoil: kick camera up, random yaw
	local kick = GUN.RecoilPitch * (if aiming then 0.6 else 1)
	recoilPitch += kick
	camera.CFrame *= CFrame.Angles(kick, rng:NextNumber(-1, 1) * GUN.RecoilYawJitter, 0)
end

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton2 or input.KeyCode == Enum.KeyCode.ButtonL2 then
		aiming = true
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 or input.KeyCode == Enum.KeyCode.ButtonL2 then
		aiming = false
	end
end)

RunService.RenderStepped:Connect(function(dt)
	-- Full-auto while held
	if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then fire() end
	-- Recoil recovery (pull camera back down partially)
	if recoilPitch > 0 then
		local back = math.min(recoilPitch, GUN.RecoilRecover * dt * recoilPitch + 0.0005)
		recoilPitch -= back
		camera.CFrame *= CFrame.Angles(-back * 0.7, 0, 0)
	end
	-- ADS FOV lerp
	local target = if aiming then 1 else 0
	fovAlpha += (target - fovAlpha) * math.clamp(dt / GUN.AdsTime, 0, 1)
	camera.FieldOfView = GUN.HipFov + (GUN.AdsFov - GUN.HipFov) * fovAlpha
	UserInputService.MouseDeltaSensitivity = 1 - 0.4 * fovAlpha -- slower look when aiming
end)
```

Notes:
- Spread is **client-side** for feel. A cheater can send zero spread, so if spread matters competitively, have the server choose the spread: send the aim direction plus a shot index, and let the server apply deterministic spread from a seeded `Random.new(seed + shotIndex)` known to both sides.
- For first person, set `player.CameraMode = Enum.CameraMode.LockFirstPerson` and render a viewmodel parented to the camera, client-only.
- Gamepad: bind fire to `ButtonR2` and ADS to `ButtonL2`. Use aim assist (light rotational slowdown near targets) for gamepad and touch.

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

Folder setup: `ServerStorage/Enemies/<Name>` (a Model with Humanoid, HumanoidRootPart, PrimaryPart set), `workspace/EnemySpawns` with spawn parts.

```lua
--!strict
-- ServerScriptService/Waves/WaveService.luau
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local PhysicsService = game:GetService("PhysicsService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DamageService = require(game.ServerScriptService.Combat.DamageService)

local EnemyTemplates = ServerStorage:WaitForChild("Enemies")
local SpawnPoints = workspace:WaitForChild("EnemySpawns")
local EnemyFolder = Instance.new("Folder")
EnemyFolder.Name = "Enemies"
EnemyFolder.Parent = workspace

pcall(function() PhysicsService:RegisterCollisionGroup("NPC") end)
PhysicsService:CollisionGroupSetCollidable("NPC", "NPC", false)

type EnemyStats = { Health: number, Speed: number, Damage: number, AttackRange: number, AttackCooldown: number, Reward: number }
local ENEMY_STATS: { [string]: EnemyStats } = {
	Grunt = { Health = 60, Speed = 12, Damage = 8, AttackRange = 4.5, AttackCooldown = 1.0, Reward = 5 },
	Runner = { Health = 30, Speed = 20, Damage = 5, AttackRange = 4, AttackCooldown = 0.7, Reward = 4 },
	Brute = { Health = 400, Speed = 8, Damage = 25, AttackRange = 6, AttackCooldown = 2.0, Reward = 40 },
}

type WaveDef = { Groups: { { Enemy: string, Count: number, Interval: number } }, TimeLimit: number }
local WAVES: { WaveDef } = {
	{ Groups = { { Enemy = "Grunt", Count = 6, Interval = 0.8 } }, TimeLimit = 90 },
	{ Groups = { { Enemy = "Grunt", Count = 8, Interval = 0.6 }, { Enemy = "Runner", Count = 4, Interval = 1.0 } }, TimeLimit = 120 },
	{ Groups = { { Enemy = "Runner", Count = 10, Interval = 0.4 }, { Enemy = "Brute", Count = 1, Interval = 0 } }, TimeLimit = 150 },
}
local MAX_ALIVE = 40
local AI_HZ = 6

type Npc = { model: Model, hum: Humanoid, root: BasePart, stats: EnemyStats, nextAttack: number }
local alive: { [Model]: Npc } = {}

local WaveState = ReplicatedStorage:FindFirstChild("WaveState") or Instance.new("Configuration")
WaveState.Name = "WaveState"
WaveState.Parent = ReplicatedStorage

local WaveService = {}
local onEnemyKilled: ((killer: Player?, reward: number) -> ())? = nil
function WaveService.SetRewardHandler(fn) onEnemyKilled = fn end

-- Difficulty scaling by player count
local function scaledHealth(base: number): number
	local n = math.max(1, #Players:GetPlayers())
	return math.floor(base * (1 + 0.35 * (n - 1)))
end

local function pickSpawn(): BasePart
	local spawns = SpawnPoints:GetChildren()
	return spawns[math.random(1, #spawns)] :: BasePart
end

local function spawnEnemy(name: string): Npc?
	local template = EnemyTemplates:FindFirstChild(name) :: Model?
	local stats = ENEMY_STATS[name]
	if not template or not stats then
		warn("Unknown enemy", name)
		return nil
	end
	local model = template:Clone()
	local hum = model:FindFirstChildOfClass("Humanoid") :: Humanoid
	local root = model:FindFirstChild("HumanoidRootPart") :: BasePart
	hum.MaxHealth = scaledHealth(stats.Health)
	hum.Health = hum.MaxHealth
	hum.WalkSpeed = stats.Speed
	hum.BreakJointsOnDeath = false
	for _, s in { Enum.HumanoidStateType.Climbing, Enum.HumanoidStateType.Swimming, Enum.HumanoidStateType.Seated } do
		hum:SetStateEnabled(s, false)
	end
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") then d.CollisionGroup = "NPC" end
	end
	model:SetAttribute("Enemy", true)
	model:PivotTo(pickSpawn().CFrame * CFrame.new(0, 3, 0))
	model.Parent = EnemyFolder
	root:SetNetworkOwner(nil) -- server simulates; clients can't hijack

	local npc: Npc = { model = model, hum = hum, root = root, stats = stats, nextAttack = 0 }
	alive[model] = npc
	hum.Died:Connect(function()
		alive[model] = nil
		Debris:AddItem(model, 3)
	end)
	return npc
end

-- Kill credit: DamageService tells us who killed what
DamageService.OnKilled(function(victim, killer)
	if victim:GetAttribute("Enemy") ~= true then return end
	local name = victim.Name
	local reward = ENEMY_STATS[name] and ENEMY_STATS[name].Reward or 0
	if onEnemyKilled then
		onEnemyKilled(if typeof(killer) == "Instance" and killer:IsA("Player") then killer else nil, reward)
	end
end)

local function nearestPlayerRoot(pos: Vector3): (Model?, BasePart?, number)
	local bestChar, bestRoot, bestDist = nil, nil, math.huge
	for _, p in Players:GetPlayers() do
		local c = p.Character
		local h = c and c:FindFirstChildOfClass("Humanoid")
		local r = c and c:FindFirstChild("HumanoidRootPart") :: BasePart?
		if c and h and r and h.Health > 0 then
			local d = (r.Position - pos).Magnitude
			if d < bestDist then bestChar, bestRoot, bestDist = c, r, d end
		end
	end
	return bestChar, bestRoot, bestDist
end

-- One brain loop for all NPCs
task.spawn(function()
	while true do
		task.wait(1 / AI_HZ)
		local t = os.clock()
		for model, npc in alive do
			if npc.hum.Health <= 0 or not model.Parent then
				alive[model] = nil
				continue
			end
			if (model:GetAttribute("StunnedUntil") or 0) > t then
				npc.hum:MoveTo(npc.root.Position)
				continue
			end
			local targetChar, targetRoot, dist = nearestPlayerRoot(npc.root.Position)
			if targetChar and targetRoot then
				if dist > npc.stats.AttackRange then
					npc.hum:MoveTo(targetRoot.Position)
				elseif t >= npc.nextAttack then
					npc.nextAttack = t + npc.stats.AttackCooldown
					npc.hum:MoveTo(npc.root.Position)
					DamageService.Apply(targetChar, {
						Amount = npc.stats.Damage, Source = model, Kind = "Melee",
						Origin = npc.root.Position, StunTime = 0.2,
					})
				end
			end
		end
	end
end)

local function aliveCount(): number
	local n = 0
	for _ in alive do n += 1 end
	return n
end

-- Runs one wave; returns true if cleared, false on timeout/all players dead
function WaveService.RunWave(index: number): boolean
	local def = WAVES[math.min(index, #WAVES)]
	local extraScale = math.max(0, index - #WAVES) -- endless mode: keep scaling counts
	WaveState:SetAttribute("Wave", index)
	local deadline = os.clock() + def.TimeLimit
	WaveState:SetAttribute("WaveEndsAt", workspace:GetServerTimeNow() + def.TimeLimit)

	local spawning = 0
	for _, group in def.Groups do
		spawning += 1
		task.spawn(function()
			local count = group.Count + extraScale * 2
			for _ = 1, count do
				while aliveCount() >= MAX_ALIVE do task.wait(0.5) end
				spawnEnemy(group.Enemy)
				if group.Interval > 0 then task.wait(group.Interval) end
			end
			spawning -= 1
		end)
	end

	while os.clock() < deadline do
		task.wait(0.5)
		WaveState:SetAttribute("EnemiesLeft", aliveCount())
		if spawning == 0 and aliveCount() == 0 then return true end
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
end

return WaveService
```

Usage, inside a round (§16): `for wave = 1, math.huge do if not WaveService.RunWave(wave) then break end task.wait(8) end`.

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
- Visualize ownership: Studio Settings → Physics → "Are Owners Shown". The outline colors show ownership.

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
--!strict
-- Script inside the car model (server). Driver gets ownership; driver's client could also run this logic.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local car = script.Parent
local seat = car:WaitForChild("VehicleSeat") :: VehicleSeat
local motors = { car.Wheels.RL.Motor, car.Wheels.RR.Motor, car.Wheels.FL.Motor, car.Wheels.FR.Motor } :: { HingeConstraint }
local steers = { car.Wheels.FL.Steer, car.Wheels.FR.Steer } :: { HingeConstraint }

local MAX_SPEED = 80     -- studs/s at wheel rim
local WHEEL_RADIUS = 1.5
local MAX_STEER = 30     -- degrees
local TORQUE = 20000

for _, m in motors do
	m.ActuatorType = Enum.ActuatorType.Motor
	m.MotorMaxTorque = TORQUE
end
for _, s in steers do
	s.ActuatorType = Enum.ActuatorType.Servo
	s.ServoMaxTorque = 50000
	s.AngularSpeed = 6
end

seat:GetPropertyChangedSignal("Occupant"):Connect(function()
	local hum = seat.Occupant
	local player = hum and Players:GetPlayerFromCharacter(hum.Parent)
	if player then
		seat:SetNetworkOwner(player) -- whole mechanism follows
	else
		seat:SetNetworkOwnershipAuto()
		for _, m in motors do m.AngularVelocity = 0 end
	end
end)

RunService.Heartbeat:Connect(function()
	-- Hinge sign depends on your attachment orientation; flip for one side if needed
	local w = seat.ThrottleFloat * MAX_SPEED / WHEEL_RADIUS
	for i, m in motors do
		m.AngularVelocity = if i % 2 == 0 then -w else w
	end
	for _, s in steers do
		s.TargetAngle = seat.SteerFloat * MAX_STEER
	end
end)
```

> When the driver owns the car, the property writes the server makes (`AngularVelocity`, `TargetAngle`) replicate to them, which adds latency. For the best feel, run the drive loop in a **client** script handed to the driver (for example, cloned into `PlayerScripts` on sit, or `RunContext = Client` with a check for `seat.Occupant == local humanoid`). Keep the server validating speed: if `chassis.AssemblyLinearVelocity.Magnitude > MAX_SPEED * 1.5` repeatedly, take ownership back.

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

```lua
--!strict
-- Server: convert Motor6Ds to BallSocketConstraints. For player characters, the CLIENT must also
-- switch its Humanoid to Physics/Ragdoll state (fire a remote), because it owns the physics.
local function ragdoll(char: Model)
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	hum.BreakJointsOnDeath = false
	hum.RequiresNeck = false
	for _, motor in char:GetDescendants() do
		if motor:IsA("Motor6D") and motor.Part0 and motor.Part1 and motor.Name ~= "RootJoint" and motor.Name ~= "Root" then
			local a0 = Instance.new("Attachment")
			a0.CFrame = motor.C0
			a0.Parent = motor.Part0
			local a1 = Instance.new("Attachment")
			a1.CFrame = motor.C1
			a1.Parent = motor.Part1
			local bs = Instance.new("BallSocketConstraint")
			bs.Attachment0, bs.Attachment1 = a0, a1
			bs.LimitsEnabled = true
			bs.UpperAngle = 60
			bs.TwistLimitsEnabled = true
			bs.Parent = motor.Parent
			motor.Enabled = false -- keep the Motor6D so you can un-ragdoll later
		end
	end
	-- limbs need collisions while ragdolled
	for _, p in char:GetDescendants() do
		if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.CanCollide = true end
	end
end
```

To recover: re-enable the motors, destroy the BallSockets, and `ChangeState(GettingUp)` on the owner. For R15 on death, set `BreakJointsOnDeath = false` *before* death, and call `ragdoll` in `Died`.

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

```lua
local UserInputService = game:GetService("UserInputService")
local function applyLayout()
	local pref = UserInputService.PreferredInput -- KeyboardAndMouse | Gamepad | Touch | MicroGamepad
	-- show on-screen buttons for Touch; show button glyphs for Gamepad; hide hints for KBM
end
UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(applyLayout)
applyLayout()
```

### 15.4 Device rules for combat games

- **Mobile:** put on-screen buttons (IAS `UIButton` bindings or CAS touch buttons) in the bottom-right thumb zone, at least 60–80 px. Add **auto-aim or target lock** (aim at the nearest enemy in the camera cone), larger hitboxes or `Margin` on casts, and tap-to-attack with a combo buffer. Avoid hold-and-drag-while-attacking unless you have a dedicated aim stick.
- **Gamepad:** R2 attack/fire, L2 block/ADS, R1/L1 abilities, A jump, B dodge. Add aim assist (friction and magnetism near targets) and a radial menu for inventory. Test with Studio's Controller Emulator.
- **Keyboard/mouse:** M1 attack, M2 block/ADS, Q/E/R/F abilities, Shift dash, 1–9 hotbar. Lock the mouse in shooters (`UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter` with a custom crosshair).
- **VR:** `VRService:GetUserCFrame(Enum.UserCFrame.RightHand)` relative to the camera's head scale. Melee from hand velocity, with the server validating swing speed and reach. Default to comfort options (snap turn, vignette).
- **Never** gate combat input on `gameProcessedEvent == false` alone when using on-screen buttons; buttons set `processed = true`. Use IAS or CAS for mobile combat actions.

---

## 16. Round systems, teams, spectating

### 16.1 Round state machine (single-place or round-server)

States: `Waiting` (not enough players) → `Intermission` → `Playing` → `Ended` → back to `Intermission`. The state lives on a replicated object (`ReplicatedStorage.RoundState` attributes), so every client's UI just reads attributes.

```lua
--!strict
-- ServerScriptService/Rounds/RoundService.server.luau
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DamageService = require(game.ServerScriptService.Combat.DamageService)

local MIN_PLAYERS = 2
local INTERMISSION = 15
local ROUND_TIME = 180
local RESULTS_TIME = 8
local KILLS_TO_WIN = 25

local State = Instance.new("Configuration")
State.Name = "RoundState"
State.Parent = ReplicatedStorage

local function setState(name: string, duration: number?)
	State:SetAttribute("Phase", name)
	State:SetAttribute("EndsAt", if duration then workspace:GetServerTimeNow() + duration else 0)
end

-- Teams (Team objects replicate; Player.Team assignment drives spawn selection via SpawnLocation.TeamColor)
local function makeTeam(name: string, color: BrickColor): Team
	local t = Teams:FindFirstChild(name) :: Team?
	if not t then
		t = Instance.new("Team")
		t.Name = name
		t.TeamColor = color
		t.AutoAssignable = false
		t.Parent = Teams
	end
	return t :: Team
end
local Red = makeTeam("Red", BrickColor.new("Bright red"))
local Blue = makeTeam("Blue", BrickColor.new("Bright blue"))
local Lobby = makeTeam("Lobby", BrickColor.new("Medium stone grey"))

local inRound: { [Player]: boolean } = {}
local score = { Red = 0, Blue = 0 }

local function balanceTeams(players: { Player })
	-- shuffle, then alternate. Replace with party-aware / skill-aware balancing as needed.
	for i = #players, 2, -1 do
		local j = math.random(i)
		players[i], players[j] = players[j], players[i]
	end
	for i, p in players do
		p.Team = if i % 2 == 0 then Red else Blue
		p.Neutral = false
	end
end

local function spawnAll(players: { Player })
	for _, p in players do
		task.spawn(function()
			p:LoadCharacterAsync()
			local char = p.Character
			if char then char:SetAttribute("IFrameUntil", os.clock() + 2) end -- spawn protection
		end)
	end
end

local function returnToLobby()
	for p in inRound do
		if p.Parent then
			p.Team = Lobby
			task.spawn(function() p:LoadCharacterAsync() end)
		end
	end
	table.clear(inRound)
end

-- Kill scoring during Playing; respawn handled per mode
DamageService.OnKilled(function(victim, killer)
	if State:GetAttribute("Phase") ~= "Playing" then return end
	if typeof(killer) == "Instance" and killer:IsA("Player") and inRound[killer] and killer.Team then
		local teamName = killer.Team.Name
		if score[teamName] then
			score[teamName] += 1
			State:SetAttribute("Score" .. teamName, score[teamName])
		end
	end
	local victimPlayer = Players:GetPlayerFromCharacter(victim)
	if victimPlayer and inRound[victimPlayer] then
		task.delay(Players.RespawnTime, function()
			if inRound[victimPlayer] and State:GetAttribute("Phase") == "Playing" then
				victimPlayer:LoadCharacterAsync()
			end
		end)
	end
end)

Players.CharacterAutoLoads = false -- we control spawns
Players.PlayerAdded:Connect(function(p)
	p.Team = Lobby
	p:LoadCharacterAsync()
end)
Players.PlayerRemoving:Connect(function(p) inRound[p] = nil end)

local function waitPhase(duration: number, earlyExit: (() -> boolean)?)
	local deadline = os.clock() + duration
	while os.clock() < deadline do
		task.wait(0.25)
		if earlyExit and earlyExit() then return end
	end
end

local function countInRound(): number
	local n = 0
	for p in inRound do if p.Parent then n += 1 end end
	return n
end

while true do
	-- WAITING
	setState("Waiting")
	while #Players:GetPlayers() < MIN_PLAYERS do task.wait(1) end

	-- INTERMISSION
	setState("Intermission", INTERMISSION)
	waitPhase(INTERMISSION)
	local participants = Players:GetPlayers()
	if #participants < MIN_PLAYERS then continue end

	-- PLAYING
	score.Red, score.Blue = 0, 0
	State:SetAttribute("ScoreRed", 0)
	State:SetAttribute("ScoreBlue", 0)
	for _, p in participants do inRound[p] = true end
	balanceTeams(participants)
	spawnAll(participants)
	setState("Playing", ROUND_TIME)
	waitPhase(ROUND_TIME, function()
		return score.Red >= KILLS_TO_WIN or score.Blue >= KILLS_TO_WIN or countInRound() < MIN_PLAYERS
	end)

	-- ENDED
	local winner = if score.Red > score.Blue then "Red" elseif score.Blue > score.Red then "Blue" else "Draw"
	State:SetAttribute("Winner", winner)
	setState("Ended", RESULTS_TIME)
	-- award rewards here (server-side, via your data layer)
	waitPhase(RESULTS_TIME)
	returnToLobby()
end
```

Notes:
- `Player:LoadCharacterAsync()` is the current API. `LoadCharacter()` is deprecated.
- Spawn by team: put `SpawnLocation`s with `TeamColor` matching the team and `Neutral = false`. Or set `player.RespawnLocation`.
- Handle mid-round joiners by spectating, or by joining the smaller team.
- For free-for-all, skip teams and keep `Player.Neutral = true` (DamageService's friendly-fire check skips neutral players).

### 16.2 Spectating (client)

```lua
-- StarterPlayerScripts/Spectate.client.luau
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer

local targets: { Player } = {}
local index = 1
local spectating = false

local function refreshTargets()
	targets = {}
	for _, p in Players:GetPlayers() do
		local h = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
		if p ~= localPlayer and h and h.Health > 0 then table.insert(targets, p) end
	end
	index = math.clamp(index, 1, math.max(#targets, 1))
end

local function focus()
	local t = targets[index]
	local hum = t and t.Character and t.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		camera.CameraType = Enum.CameraType.Custom
		camera.CameraSubject = hum
	end
end

local function setSpectating(on: boolean)
	spectating = on
	if on then refreshTargets() focus()
	else
		local myHum = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
		if myHum then camera.CameraSubject = myHum end
	end
end

local function cycle(dir: number)
	refreshTargets()
	if #targets == 0 then return end
	index = (index - 1 + dir) % #targets + 1
	focus()
end
-- Hook cycle(1)/cycle(-1) to UI buttons or IAS actions; setSpectating(true) when the RoundState
-- says you're not in the round, false when you respawn into it.
```

Under `StreamingEnabled`, a far-away spectate target may not be streamed in. Set `player.ReplicationFocus = targetRoot` on the **server** for spectators, and reset it to `nil` afterwards.

---

## 17. Matchmaking: lobby place → round servers

### 17.1 Architecture

```
Lobby place (public servers)                      Round place (reserved servers only)
  Queue pad / Play button
  → party leader joins queue
  → MemoryStoreQueue "MM_<mode>" AddAsync({party})
  Matchmaker loop (every lobby server):
     ReadAsync(N) → pack parties into a match
     id = GenerateGUID → ReservedServerId
     MessagingService "MM_Match" {userIds, rsid}
     RemoveAsync(readId) for used entries
  On "MM_Match": teleport local members ───────►  Player:GetJoinData().TeleportData
     TeleportAsync(roundPlaceId, players, opts)      → mode, teams, matchId
                                                    run round; on end:
                                    ◄───────────── TeleportAsync(lobbyPlaceId, players)
```

Why this shape:
- **MemoryStore queues** give cross-server queueing with an invisibility timeout. If a matchmaker server crashes mid-match, unremoved entries reappear after the timeout.
- **`ReservedServerId` is a GUID you generate.** The first teleport with that ID creates the server, and later teleports with the same ID join it. That lets several lobby servers send their players to the *same* match. (`ReserveServerAsync` and `ReservedServerAccessCode` are deprecated.)
- **MessagingService** is best-effort. If a lobby server misses the message, its players stay queued. Handle that with a queue timeout plus re-queue on the client.

Simpler alternatives:
- Single-server party teleport, where everyone queuing is in the same lobby server: skip MemoryStore and call `TeleportAsync` with a new `ReservedServerId` for the pad's players.
- **Built-in matchmaking customization** (Creator Hub → Matchmaking: attributes, signals, scoring) tunes which *public* server a joining player lands in, for example by skill or language. It doesn't create matches between parties. Use it for public-server quality, and the pattern below for queued matches.

### 17.2 Complete lobby matchmaker (server, lobby place)

```lua
--!strict
-- ServerScriptService/Matchmaking/Matchmaker.server.luau  (LOBBY place)
local Players = game:GetService("Players")
local MemoryStoreService = game:GetService("MemoryStoreService")
local MessagingService = game:GetService("MessagingService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ROUND_PLACE_ID = 0000000000 -- TODO: your round place id (same universe)
local MODE = "Duos"
local MATCH_SIZE = 4          -- players per match
local QUEUE_ENTRY_TTL = 120   -- seconds an entry may sit in the queue
local INVISIBILITY = 20       -- seconds an item is hidden after ReadAsync
local MATCH_TOPIC = "MM_Match_" .. MODE

local queue = MemoryStoreService:GetQueue("MM_" .. MODE, INVISIBILITY)

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local QueueRemote = Remotes:WaitForChild("Queue") :: RemoteEvent   -- client -> server: true/false
local QueueStatus = Remotes:WaitForChild("QueueStatus") :: RemoteEvent -- server -> client

-- Parties: leaderUserId -> {userIds}. Replace with your party system.
local function getPartyUserIds(player: Player): { number }
	local raw = player:GetAttribute("PartyMembers") -- e.g. "123,456"
	local ids = { player.UserId }
	if type(raw) == "string" then
		for s in string.gmatch(raw, "%d+") do
			local id = tonumber(s)
			if id and id ~= player.UserId and Players:GetPlayerByUserId(id) then table.insert(ids, id) end
		end
	end
	return ids
end

local queuedHere: { [number]: boolean } = {} -- userIds queued from this server
local lastQueueAt: { [Player]: number } = {}

local function retry<T...>(attempts: number, fn: () -> T...): (boolean, T...)
	local result
	for i = 1, attempts do
		result = table.pack(pcall(fn))
		if result[1] then return table.unpack(result, 1, result.n) end
		task.wait(0.5 * 2 ^ (i - 1))
	end
	return table.unpack(result, 1, result.n)
end

QueueRemote.OnServerEvent:Connect(function(player: Player, join: unknown)
	if type(join) ~= "boolean" then return end
	local t = os.clock()
	if t - (lastQueueAt[player] or 0) < 2 then return end -- spam guard
	lastQueueAt[player] = t

	if join then
		if queuedHere[player.UserId] then return end
		local ids = getPartyUserIds(player)
		if #ids > MATCH_SIZE then return end
		local entry = {
			partyId = HttpService:GenerateGUID(false),
			userIds = ids,
			queuedAt = os.time(),
			-- skill = averageElo, region = ..., etc.
		}
		local ok, err = retry(3, function()
			return queue:AddAsync(entry, QUEUE_ENTRY_TTL, 0)
		end)
		if ok then
			for _, id in ids do queuedHere[id] = true end
			QueueStatus:FireClient(player, "Queued")
		else
			warn("Queue add failed:", err)
			QueueStatus:FireClient(player, "Error")
		end
	else
		-- Leaving: we can't remove a specific un-read item from a MemoryStoreQueue.
		-- Mark locally; the match teleport will skip absent/unqueued players and the
		-- entry expires by TTL. (Use a SortedMap-based queue if you need hard cancels.)
		for _, id in getPartyUserIds(player) do queuedHere[id] = nil end
		QueueStatus:FireClient(player, "Left")
	end
end)

Players.PlayerRemoving:Connect(function(p)
	queuedHere[p.UserId] = nil
	lastQueueAt[p] = nil
end)

-- Receive match announcements (from any lobby server, including this one)
local function teleportMatch(data: { userIds: { number }, rsid: string, matchId: string })
	local mine: { Player } = {}
	for _, id in data.userIds do
		local p = Players:GetPlayerByUserId(id)
		if p and queuedHere[id] then
			table.insert(mine, p)
			queuedHere[id] = nil
		end
	end
	if #mine == 0 then return end

	local options = Instance.new("TeleportOptions")
	options.ReservedServerId = data.rsid -- same GUID on every lobby server => same match server
	options:SetTeleportData({ matchId = data.matchId, mode = MODE, expected = data.userIds })

	local ok, err = retry(3, function()
		return TeleportService:TeleportAsync(ROUND_PLACE_ID, mine, options)
	end)
	if not ok then
		warn("Match teleport failed:", err)
		for _, p in mine do QueueStatus:FireClient(p, "Error") end
	end
end

task.spawn(function()
	local ok, err = pcall(function()
		MessagingService:SubscribeAsync(MATCH_TOPIC, function(message)
			local data = message.Data
			if type(data) == "table" and type(data.rsid) == "string" and type(data.userIds) == "table" then
				teleportMatch(data)
			end
		end)
	end)
	if not ok then warn("Subscribe failed:", err) end
end)

-- Matchmaker loop: every lobby server tries; invisibility timeout prevents double-processing.
task.spawn(function()
	while true do
		task.wait(3)
		local ok, items, readId = pcall(function()
			-- Read up to 10 parties, wait up to 2s for items
			return queue:ReadAsync(10, false, 2)
		end)
		if not ok or not items or #items == 0 then continue end

		-- Greedy packing: oldest first, fill exactly MATCH_SIZE
		table.sort(items, function(a, b) return (a.queuedAt or 0) < (b.queuedAt or 0) end)
		local match: { number } = {}
		for _, entry in items do
			if #match + #entry.userIds <= MATCH_SIZE then
				for _, id in entry.userIds do table.insert(match, id) end
			end
			if #match == MATCH_SIZE then break end
		end

		if #match == MATCH_SIZE then
			local payload = {
				userIds = match,
				rsid = HttpService:GenerateGUID(false),
				matchId = HttpService:GenerateGUID(false),
			}
			local pubOk = pcall(function()
				MessagingService:PublishAsync(MATCH_TOPIC, payload)
			end)
			if pubOk then
				-- ReadAsync returns ONE id for the whole batch, so RemoveAsync drops all items read.
				-- Re-add the parties that were read but NOT used, so they keep their place.
				local used: { [number]: boolean } = {}
				for _, id in match do used[id] = true end
				pcall(function() queue:RemoveAsync(readId) end)
				for _, entry in items do
					if not used[entry.userIds[1]] then
						pcall(function() queue:AddAsync(entry, QUEUE_ENTRY_TTL, 0) end)
					end
				end
			end
			-- If publish failed: don't remove; items reappear after INVISIBILITY seconds.
		end
		-- Not enough players: don't remove; items become visible again after INVISIBILITY.
	end
end)
```

Important behaviors:
- `MemoryStoreQueue:ReadAsync(count, allOrNothing, waitTimeout)` returns `(items, id)`. **One id covers the whole batch**, and `RemoveAsync(id)` removes every item in that read. That's why the code re-adds unused parties after a successful match. (The re-added entries lose their queue position, but since priority is 0 and the sort uses `queuedAt`, the oldest still win at the next read.)
- **MessagingService size limit is 1 kB.** Fine for about 16 userIds. For big matches, write the roster to a MemoryStore hash map keyed by `matchId` and publish only the id.
- Keep a client-side queue timer. If nothing happens within about 90 s, re-queue (the TTL expires stale entries).
- Skill matching: add `skill` to entries and only pack parties within a window that widens with wait time.

### 17.3 Round place: receiving the match and returning players

```lua
--!strict
-- ServerScriptService/RoundServer.server.luau  (ROUND place)
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local LOBBY_PLACE_ID = 0000000000 -- TODO
local isReserved = game.PrivateServerId ~= "" and game.PrivateServerOwnerId == 0

local expected: { [number]: boolean } = {}
local matchId: string? = nil

Players.PlayerAdded:Connect(function(player)
	local joinData = player:GetJoinData()
	local td = joinData.TeleportData
	-- TeleportData is client-carried: treat as UNTRUSTED hints (fine for mode/matchId, never for rewards)
	if type(td) == "table" and type(td.matchId) == "string" then
		matchId = matchId or td.matchId
		if type(td.expected) == "table" then
			for _, id in td.expected do if type(id) == "number" then expected[id] = true end end
		end
	end
	if not isReserved then
		-- Someone joined the round place directly (e.g. from the website): send them to the lobby
		task.defer(function()
			pcall(function() TeleportService:TeleportAsync(LOBBY_PLACE_ID, { player }) end)
		end)
	end
end)

-- Wait for the roster (or timeout) before starting
local function waitForRoster(timeout: number)
	local deadline = os.clock() + timeout
	while os.clock() < deadline do
		local present = 0
		local total = 0
		for id in expected do
			total += 1
			if Players:GetPlayerByUserId(id) then present += 1 end
		end
		if total > 0 and present == total then return end
		task.wait(0.5)
	end
end

TeleportService.TeleportInitFailed:Connect(function(player, result, message)
	warn("Teleport failed for", player.Name, result, message)
	task.wait(2)
	pcall(function() TeleportService:TeleportAsync(LOBBY_PLACE_ID, { player }) end)
end)

local function sendAllToLobby(results: any?)
	local players = Players:GetPlayers()
	if #players == 0 then return end
	local opts = Instance.new("TeleportOptions")
	opts:SetTeleportData({ fromMatch = matchId })
	local ok, err = pcall(function()
		return TeleportService:TeleportAsync(LOBBY_PLACE_ID, players, opts)
	end)
	if not ok then warn("Return teleport failed:", err) end
end

-- Flow: waitForRoster(30) → run RoundService/WaveService once → save results via data layer → sendAllToLobby()
-- Also: game:BindToClose(function() sendAllToLobby() end) so a shutdown returns players.
```

- Save match results **on the round server, before teleporting** (session-locked profiles release on leave, so the lobby can load fresh data).
- `TeleportAsync` returns a `TeleportAsyncResult`. Retry on failure with exponential backoff, and listen to `TeleportInitFailed` for per-player failures.
- Teleports only work in published games, not Studio playtests. Guard with `RunService:IsStudio()`.

---

## 18. Inventory and equipment

### 18.1 Tools vs custom

| | `Tool` (Backpack) | Custom (data + welded models) |
|---|---|---|
| Effort | Low: built-in hotbar, equip/unequip, `Activated` | You build the UI and equip logic |
| Control | Limited (one equipped tool, default hotbar) | Full: multiple slots, offhand, armor, cosmetics |
| Server Authority | **Not fully supported** | Supported (weld inside the simulation, track with an attribute) |
| Security | Tools in the Backpack are client-visible, and client `Activated` is a hint | Same rule: the server owns the data |

`Tool` properties worth knowing: `RequiresHandle`, `CanBeDropped` (set **false** for weapons, or players can drop them for others), `ManualActivationOnly`, and the `Activated`/`Equipped`/`Unequipped` events. Weapon logic goes in server scripts, with the client only firing a remote.

### 18.2 Data model

```lua
-- Profile data (persisted via your data layer, see the data chapter)
Data.Inventory = {
	-- every non-stackable item has a unique id => dupes are detectable
	["f3a1...guid"] = { ItemId = "IronSword", Level = 3, Locked = false },
	["9b20...guid"] = { ItemId = "HealthPotion", Count = 12 }, -- stackables may use one entry
}
Data.Equipped = { Weapon = "f3a1...guid", Armor = nil, Hotbar = { "9b20...guid" } }
```

- Item *definitions* (`ItemDefs`: damage, rarity, tradable, max stack) live in ReplicatedStorage. *Ownership* lives only in the server profile.
- Equip remote: `Equip(slot, uid)`. The server checks that the uid exists in the profile, the item fits the slot, and the player isn't in combat (optional). It then updates `Equipped`, sets `player:SetAttribute("EquippedMelee", ItemId)`, and welds the model to the character with a `WeldConstraint` or `RigidConstraint` (`CanCollide=false`, `Massless=true`, `CanQuery=false`).
- The client UI mirrors the inventory through a replicated snapshot (a remote push on change). Never let the client edit it.

---

## 19. Secure trading (two-phase commit)

### 19.1 Rules

1. Both players must be **in the same server**, with **session-locked profiles loaded** (ProfileStore/ProfileService style). Cross-server trades need far more machinery, so avoid them.
2. A trade is a **server-side session object**. Clients only send intents: add, remove, ready, confirm, cancel.
3. **Any change to either offer clears both `ready` and `confirmed` flags** and restarts the countdown. This defeats bait-and-switch.
4. **Phase 1 (prepare):** both confirm, then the server re-verifies every offered uid is still owned, not locked, tradable, and not equipped. It writes a journal record (`pending`).
5. **Phase 2 (commit):** move items between the in-memory profiles **in one block with no yields**, so it's atomic with respect to other Luau code on this server. Mark the journal `committed` and request a save for both profiles.
6. Recovery: on profile load, any `pending` journal entry referencing this user is either rolled forward or ignored. Since items carry unique ids, the check "does exactly one of the two profiles own uid X?" resolves it.
7. Rate-limit trade requests, cap items per offer, and block trades for brand-new accounts or during combat if you like.

### 19.2 Complete trade service

```lua
--!strict
-- ServerScriptService/Trading/TradeService.server.luau
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(game.ServerScriptService.Data.DataService) -- must expose:
--   Data.GetProfileData(player): table? (live, session-locked data table; nil if not loaded)
--   Data.RequestSave(player): ()
local ItemDefs = require(ReplicatedStorage.Shared.ItemDefs) -- [ItemId] = { Tradable: boolean, ... }

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local TradeRequest = Remotes:WaitForChild("TradeRequest") :: RemoteEvent -- (targetPlayer)
local TradeAction = Remotes:WaitForChild("TradeAction") :: RemoteEvent   -- (action, arg)
local TradeUpdate = Remotes:WaitForChild("TradeUpdate") :: RemoteEvent   -- server -> clients snapshot

local Journal = DataStoreService:GetDataStore("TradeJournal_v1")

local MAX_ITEMS_PER_SIDE = 8
local CONFIRM_COUNTDOWN = 5
local REQUEST_EXPIRY = 30

type Side = { player: Player, items: { [string]: boolean }, ready: boolean, confirmed: boolean }
type Trade = { id: string, a: Side, b: Side, state: "Open" | "Countdown" | "Committing" | "Done" | "Cancelled",
	countdownToken: number }

local tradesByPlayer: { [Player]: Trade } = {}
local pendingRequests: { [Player]: { [Player]: number } } = {} -- target -> requester -> expiry
local lastAction: { [Player]: number } = {}

local function throttle(p: Player, gap: number): boolean
	local t = os.clock()
	if t - (lastAction[p] or 0) < gap then return true end
	lastAction[p] = t
	return false
end

local function sideOf(trade: Trade, p: Player): (Side, Side)
	if trade.a.player == p then return trade.a, trade.b end
	return trade.b, trade.a
end

local function snapshot(trade: Trade)
	local function view(s: Side)
		local list = {}
		local data = Data.GetProfileData(s.player)
		for uid in s.items do
			local item = data and data.Inventory[uid]
			if item then table.insert(list, { uid = uid, ItemId = item.ItemId, Level = item.Level }) end
		end
		return { userId = s.player.UserId, items = list, ready = s.ready, confirmed = s.confirmed }
	end
	local payload = { id = trade.id, state = trade.state, a = view(trade.a), b = view(trade.b) }
	TradeUpdate:FireClient(trade.a.player, payload)
	TradeUpdate:FireClient(trade.b.player, payload)
end

local function resetFlags(trade: Trade)
	trade.a.ready, trade.b.ready = false, false
	trade.a.confirmed, trade.b.confirmed = false, false
	trade.countdownToken += 1 -- invalidates any running countdown
	if trade.state == "Countdown" then trade.state = "Open" end
end

local function endTrade(trade: Trade, state: "Done" | "Cancelled")
	trade.state = state
	trade.countdownToken += 1
	snapshot(trade)
	if tradesByPlayer[trade.a.player] == trade then tradesByPlayer[trade.a.player] = nil end
	if tradesByPlayer[trade.b.player] == trade then tradesByPlayer[trade.b.player] = nil end
end

local function isEquipped(data: any, uid: string): boolean
	local eq = data.Equipped
	if not eq then return false end
	for _, v in eq do
		if v == uid then return true end
		if type(v) == "table" then for _, h in v do if h == uid then return true end end end
	end
	return false
end

local function itemTradable(data: any, uid: string): boolean
	local item = data.Inventory[uid]
	if not item or item.Locked then return false end
	local def = ItemDefs[item.ItemId]
	if not def or def.Tradable ~= true then return false end
	if isEquipped(data, uid) then return false end
	return true
end

-- PHASE 1 + PHASE 2
local function commit(trade: Trade)
	trade.state = "Committing"
	local pa, pb = trade.a.player, trade.b.player
	local da, db = Data.GetProfileData(pa), Data.GetProfileData(pb)
	if not da or not db or not pa.Parent or not pb.Parent then
		endTrade(trade, "Cancelled")
		return
	end
	-- Phase 1: verify everything still valid (no yields between here and the swap)
	for uid in trade.a.items do if not itemTradable(da, uid) then endTrade(trade, "Cancelled") return end end
	for uid in trade.b.items do if not itemTradable(db, uid) then endTrade(trade, "Cancelled") return end end
	-- Guard: uid must not exist on the receiving side already (dupe detection)
	for uid in trade.a.items do if db.Inventory[uid] then warn("DUPE?", uid) endTrade(trade, "Cancelled") return end end
	for uid in trade.b.items do if da.Inventory[uid] then warn("DUPE?", uid) endTrade(trade, "Cancelled") return end end

	-- Phase 2: atomic in-memory swap (no yields)
	local moved = { aToB = {}, bToA = {} }
	for uid in trade.a.items do
		db.Inventory[uid] = da.Inventory[uid]
		da.Inventory[uid] = nil
		table.insert(moved.aToB, uid)
	end
	for uid in trade.b.items do
		da.Inventory[uid] = db.Inventory[uid]
		db.Inventory[uid] = nil
		table.insert(moved.bToA, uid)
	end
	endTrade(trade, "Done")

	-- Persist: save both profiles, then write an audit/recovery journal entry (yields are fine now)
	Data.RequestSave(pa)
	Data.RequestSave(pb)
	task.spawn(function()
		pcall(function()
			Journal:SetAsync(trade.id, {
				a = pa.UserId, b = pb.UserId, moved = moved, at = os.time(), status = "committed",
			}, { pa.UserId, pb.UserId })
		end)
	end)
end

local function startCountdown(trade: Trade)
	trade.state = "Countdown"
	trade.countdownToken += 1
	local token = trade.countdownToken
	snapshot(trade)
	task.delay(CONFIRM_COUNTDOWN, function()
		-- Only proceed if nothing changed during the countdown
		if trade.countdownToken == token and trade.state == "Countdown" then
			trade.state = "Open" -- now waiting for final confirms
			snapshot(trade)
		end
	end)
end

TradeRequest.OnServerEvent:Connect(function(requester: Player, target: unknown)
	if throttle(requester, 1) then return end
	if typeof(target) ~= "Instance" or not (target :: Instance):IsA("Player") then return end
	local tp = target :: Player
	if tp == requester or tp.Parent ~= Players then return end
	if tradesByPlayer[requester] or tradesByPlayer[tp] then return end
	if not Data.GetProfileData(requester) or not Data.GetProfileData(tp) then return end

	-- If target already requested us: accept => open trade
	local mine = pendingRequests[requester]
	if mine and mine[tp] and mine[tp] > os.clock() then
		mine[tp] = nil
		local trade: Trade = {
			id = HttpService:GenerateGUID(false),
			a = { player = requester, items = {}, ready = false, confirmed = false },
			b = { player = tp, items = {}, ready = false, confirmed = false },
			state = "Open", countdownToken = 0,
		}
		tradesByPlayer[requester] = trade
		tradesByPlayer[tp] = trade
		snapshot(trade)
		return
	end
	pendingRequests[tp] = pendingRequests[tp] or {}
	pendingRequests[tp][requester] = os.clock() + REQUEST_EXPIRY
	TradeUpdate:FireClient(tp, { incomingFrom = requester.UserId })
end)

TradeAction.OnServerEvent:Connect(function(player: Player, action: unknown, arg: unknown)
	if throttle(player, 0.15) then return end
	if type(action) ~= "string" then return end
	local trade = tradesByPlayer[player]
	if not trade or trade.state == "Committing" or trade.state == "Done" or trade.state == "Cancelled" then return end
	local me, other = sideOf(trade, player)
	local data = Data.GetProfileData(player)
	if not data then return end

	if action == "Add" then
		if type(arg) ~= "string" or #arg > 64 then return end
		local count = 0
		for _ in me.items do count += 1 end
		if count >= MAX_ITEMS_PER_SIDE or me.items[arg] then return end
		if not itemTradable(data, arg) then return end
		me.items[arg] = true
		resetFlags(trade)
	elseif action == "Remove" then
		if type(arg) ~= "string" or not me.items[arg] then return end
		me.items[arg] = nil
		resetFlags(trade)
	elseif action == "Ready" then
		if type(arg) ~= "boolean" then return end
		me.ready = arg
		me.confirmed = false
		other.confirmed = false
		if trade.a.ready and trade.b.ready then
			startCountdown(trade)
			return
		elseif trade.state == "Countdown" then
			resetFlags(trade)
		end
	elseif action == "Confirm" then
		-- Only valid after both ready AND countdown finished (state back to "Open" with ready flags)
		if not (trade.a.ready and trade.b.ready) or trade.state ~= "Open" then return end
		me.confirmed = true
		if trade.a.confirmed and trade.b.confirmed then
			commit(trade)
			return
		end
	elseif action == "Cancel" then
		endTrade(trade, "Cancelled")
		return
	else
		return
	end
	snapshot(trade)
end)

Players.PlayerRemoving:Connect(function(p)
	local trade = tradesByPlayer[p]
	if trade and trade.state ~= "Committing" then endTrade(trade, "Cancelled") end
	pendingRequests[p] = nil
	lastAction[p] = nil
	for _, reqs in pendingRequests do reqs[p] = nil end
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
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local board = DataStoreService:GetOrderedDataStore("Wins_AllTime_v1")
local TOP_N = 50
local REFRESH = 90 -- seconds; reads are budgeted, so never refresh per player

-- In-session leaderstats (the built-in player list leaderboard)
Players.PlayerAdded:Connect(function(p)
	local ls = Instance.new("Folder")
	ls.Name = "leaderstats"
	local wins = Instance.new("IntValue")
	wins.Name = "Wins"
	wins.Value = 0 -- load from your profile
	wins.Parent = ls
	ls.Parent = p
end)

-- Write: on a throttle and on leave. Values must be integers.
local dirty: { [number]: number } = {}
local function markWins(player: Player, wins: number)
	dirty[player.UserId] = math.floor(wins)
end
Players.PlayerRemoving:Connect(function(p)
	local ls = p:FindFirstChild("leaderstats")
	local w = ls and ls:FindFirstChild("Wins") :: IntValue?
	if w then markWins(p, w.Value) end
end)

task.spawn(function()
	while true do
		task.wait(60)
		for _, p in Players:GetPlayers() do
			local w = p:FindFirstChild("leaderstats") and p.leaderstats:FindFirstChild("Wins") :: IntValue?
			if w then markWins(p, w.Value) end
		end
		for userId, value in dirty do
			pcall(function() board:SetAsync(tostring(userId), value) end)
			dirty[userId] = nil
			task.wait(0.2)
		end
	end
end)

-- Read: cache top N in a replicated value for SurfaceGui/ScreenGui clients
local Cache = Instance.new("StringValue")
Cache.Name = "GlobalWinsTop"
Cache.Parent = ReplicatedStorage

task.spawn(function()
	while true do
		local ok, pages = pcall(function()
			return board:GetSortedAsync(false, TOP_N) -- descending, pagesize ≤ 100
		end)
		if ok and pages then
			local rows = {}
			for rank, entry in pages:GetCurrentPage() do
				table.insert(rows, { rank = rank, userId = tonumber(entry.key), value = entry.value })
			end
			Cache.Value = game:GetService("HttpService"):JSONEncode(rows)
		end
		task.wait(REFRESH)
	end
end)
```

- For "weekly" boards, version the key name by week (`"Wins_W" .. os.date("!%Y%W")`).
- Resolve names on the client with `Players:GetNameFromUserIdAsync` (cached, with `pcall`), or on the server once per refresh.
- For leaderboards that update in real time across servers, mirror into a `MemoryStoreSortedMap` (`SetAsync(key, value, expiration, sortKey)` and `GetRangeAsync(Enum.SortDirection.Descending, n)`), and persist to an OrderedDataStore periodically.

---

## 21. Cross-server events (MessagingService)

Limits (subject to change): message ≤ **1 kB**. Per server, `600 + 240 × players` messages sent per minute. Per topic, `40 + 80 × servers` messages received per minute. Per server, `20 + 8 × players` subscriptions. Delivery is **best-effort**.

```lua
--!strict
-- Global event: "Double XP for 15 minutes" triggered by an admin in any server
local MessagingService = game:GetService("MessagingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TOPIC = "GlobalEvents"
local Events = ReplicatedStorage:FindFirstChild("GlobalEvents") or Instance.new("Configuration")
Events.Name = "GlobalEvents"
Events.Parent = ReplicatedStorage

local function applyEvent(data: any)
	if type(data) ~= "table" or type(data.kind) ~= "string" then return end
	if data.kind == "DoubleXP" and type(data.endsAt) == "number" then
		Events:SetAttribute("DoubleXPEndsAt", data.endsAt) -- clients compare to GetServerTimeNow()
	elseif data.kind == "BossSpawn" then
		-- spawn a world boss in every server
	end
end

task.spawn(function()
	local ok, err = pcall(function()
		MessagingService:SubscribeAsync(TOPIC, function(message)
			applyEvent(message.Data) -- message.Sent is the publish timestamp
		end)
	end)
	if not ok then warn("GlobalEvents subscribe failed:", err) end
end)

local GlobalEvents = {}
function GlobalEvents.Broadcast(kind: string, durationSec: number)
	local data = { kind = kind, endsAt = workspace:GetServerTimeNow() + durationSec }
	local ok = pcall(function() MessagingService:PublishAsync(TOPIC, data) end)
	if not ok then applyEvent(data) end -- at least apply locally
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

local CHECK_INTERVAL = 0.5
local SPEED_TOLERANCE = 1.4   -- allow 40% over legal speed (lag bursts)
local MAX_STRIKES = 6
local FLY_TIME_LIMIT = 4      -- seconds airborne without a legit reason

type Track = { lastPos: Vector3, lastT: number, strikes: number, airborneSince: number?, lastSafe: CFrame }
local tracks: { [Player]: Track } = {}

local function legalSpeed(char: Model, hum: Humanoid): number
	local s = hum.WalkSpeed
	if char:GetAttribute("DashingUntil") and (char:GetAttribute("DashingUntil") :: number) > os.clock() then s = math.max(s, 80) end
	if hum.SeatPart then s = math.max(s, 150) end -- vehicle; validate vehicle separately
	return s
end

local downParams = RaycastParams.new()
downParams.FilterType = Enum.RaycastFilterType.Exclude

task.spawn(function()
	while true do
		task.wait(CHECK_INTERVAL)
		for _, p in Players:GetPlayers() do
			local char = p.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
			if not (char and hum and root) or hum.Health <= 0 then tracks[p] = nil continue end
			local t = os.clock()
			local tr = tracks[p]
			if not tr or char:GetAttribute("ServerTeleported") then
				char:SetAttribute("ServerTeleported", nil) -- your own teleports set this flag
				tracks[p] = { lastPos = root.Position, lastT = t, strikes = 0, airborneSince = nil, lastSafe = root.CFrame }
				continue
			end
			local dt = t - tr.lastT
			local horiz = (root.Position - tr.lastPos) * Vector3.new(1, 0, 1)
			local speed = horiz.Magnitude / math.max(dt, 1e-3)
			local suspicious = speed > legalSpeed(char, hum) * SPEED_TOLERANCE + 4

			-- Fly: airborne too long with no downward progress
			downParams.FilterDescendantsInstances = { char }
			local ground = workspace:Raycast(root.Position, Vector3.new(0, -(hum.HipHeight + 6), 0), downParams)
			if ground or hum.SeatPart or hum:GetState() == Enum.HumanoidStateType.Swimming then
				tr.airborneSince = nil
				if not suspicious then tr.lastSafe = root.CFrame end
			else
				tr.airborneSince = tr.airborneSince or t
				local falling = root.AssemblyLinearVelocity.Y < -5
				if t - tr.airborneSince > FLY_TIME_LIMIT and not falling then suspicious = true end
			end

			if suspicious then
				tr.strikes += 1
				-- Rubber-band rather than kick: cheap, and harmless for lagging legit players
				root.CFrame = tr.lastSafe
				char:SetAttribute("ServerTeleported", true)
				if tr.strikes >= MAX_STRIKES then
					warn(("[AC] %s movement strikes=%d speed=%.1f"):format(p.Name, tr.strikes, speed))
					-- log to analytics/datastore; kick only on repeated, extreme violations
				end
			else
				tr.strikes = math.max(0, tr.strikes - 0.25)
			end
			tr.lastPos, tr.lastT = root.Position, t
		end
	end
end)
Players.PlayerRemoving:Connect(function(p) tracks[p] = nil end)
```

Caveats: setting a client-owned root's `CFrame` from the server does replicate, but the client can ignore it, which is why strikes are logged. Allowlist launch pads, knockback (`KnockbackUntil` attribute), vehicles, and server teleports. Under Server Authority, movement is server-simulated and this whole class of cheat disappears.

### 22.2 The combat checklist

| Threat | Server defense |
|---|---|
| Remote spam / macro | Per-player sliding-window rate limit per remote (§6). Drop excess silently. Log extreme rates. |
| Cooldown bypass | Cooldowns only on the server (`os.clock()`). Commit the cost *before* any yield. |
| Infinite range / kill aura | Server hitboxes from server positions. Distance ≤ range + lag pad. LOS raycast. One hit per target per swing. |
| Damage edits | The client never sends damage. Damage comes from server weapon data plus validated modifiers. `DamageService` rejects NaN, inf, and absurd values. |
| Fire-rate hacks | Token-bucket fire gate (§8.4). Server-side ammo and reload. |
| Silent aim / magic bullets | Origin within N studs of the server head. No wall between head and origin. Rewound-target validation with tolerance. Track headshot ratio statistics. |
| Teleport / speed / fly | §22.1 movement check. Server Authority for competitive games. |
| Spoofed arguments | `typeof` every argument. Check NaN (`x ~= x`). Length-limit strings. Check Instances are the expected class *and* in an expected location (`target:IsDescendantOf(workspace.Enemies)`). |
| Godmode via Humanoid deletion | Health lives on the server Humanoid (or an attribute). If the character is missing parts server-side, respawn it. |
| Trade or inventory dupes | Unique item ids, session locking, the two-phase trade (§19), and audit logs. |
| Teleport-data tampering | `TeleportData` is client-carried. Never derive rewards or permissions from it. Use MemoryStore or DataStore keyed by `matchId`. |
| Exploiting `Touched` on client-owned parts | Don't use client-owned parts as damage sources. |

**Logging over banning:** keep per-player anomaly counters (speed strikes, rejected remotes, impossible hits) and send them to your analytics or a DataStore. Ban only on overwhelming evidence. Lag produces many false positives.

---

## 23. Putting it together: recommended file layout

```
ReplicatedStorage/
  Remotes/  (MeleeAttack, MeleeBlock, MeleeHitConfirm[U], UseAbility, AbilityFeedback, Knockback,
             ProjectileFire, ProjectileReplicate[U], ProjectileImpact[U], Queue, QueueStatus,
             TradeRequest, TradeAction, TradeUpdate)
  Shared/   (AbilityDefs, MeleeDefs, ItemDefs, Ballistics)
  Inputs/   (PlayContext, MenuContext — IAS)
ServerScriptService/
  Combat/   (DamageService, StatusEffects, PositionHistory, ProjectileService, AbilityService, MeleeService, GunService)
  Waves/    (WaveService)
  Rounds/   (RoundService)
  Matchmaking/ (Matchmaker — lobby place only)
  Trading/  (TradeService)
  Leaderboards/ (GlobalBoard)
  AntiCheat/ (MovementCheck)
ServerStorage/
  Enemies/  (NPC templates)
StarterPlayerScripts/
  MeleeClient, GunClient, KnockbackClient, Spectate, InputSetup
```

`[U]` = `UnreliableRemoteEvent`. Create remotes in Studio, or with a server bootstrap script *before* other scripts `WaitForChild` them.

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
