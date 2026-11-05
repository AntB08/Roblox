# 10 — Level Design, World Layout & Narrative

> Chapter scope: how to lay out spaces, pace play, guide players, tell stories, and drive NPCs in **original** Roblox games. Lighting/atmosphere and asset modeling have their own chapters; this one covers where things go and why. Facts checked against the local Creator Docs mirror (`reference/creator-docs/content/en-us`) on 2026-11-05. API names were verified in `reference/engine/classes/*.yaml`.

---

## 0. TL;DR rules for the bot

1. **Measure in studs, design from the character.** Default character is about 5 studs tall. Default `WalkSpeed` = **16 studs/s**, `Workspace.Gravity` = **196.2 studs/s²**, default `JumpHeight` = **7.2 studs** (`JumpPower` 50, which gives about 6.37 studs, when `UseJumpPower` is true). A flat running jump covers about **8.7 studs** of horizontal travel with JumpHeight 7.2, and about 8.15 with JumpPower 50. **Never build a required gap wider than 7 studs edge to edge** unless the stage teaches a speed boost.
2. **Pick one jump mode and write it down.** Set `StarterPlayer.CharacterUseJumpPower` explicitly at startup and design every gap against that value. Changing `JumpHeight`, `WalkSpeed` or `Gravity` later breaks every gap in the game.
3. **Sell the game in 10 seconds of spawn.** Players spawn facing the core loop: the main activity, a giant landmark ("weenie"), and one obvious first action within about 30 studs. Shops and portals go on the path, never behind spawn.
4. **Teach with space, not text.** Use kishōtenketsu for every new mechanic: introduce it safely, develop it, twist it, then conclude with a mastery test. Keep text to 12 words per sign at most.
5. **Pace with intensity curves.** Alternate tension and rest (a sawtooth that rises overall). Put a checkpoint or safe room after every spike. Never place two hard spikes back to back.
6. **Every area has a landmark visible from its entrance.** Light it, colour it uniquely, and make it tall. Lost players quit.
7. **Grey-box first.** Use plain parts for metrics, test with real characters at real speeds, and only then dress the scene. Iterate the layout before polish.
8. **PvP maps: 3 lanes, cover every 8–16 studs, spawns out of every line of sight.** Use spawn protection (a `ForceField` for 3–5 s) and several spawn points chosen away from enemies.
9. **Size maps to player count.** About 1 player per 1,500–4,000 studs² of playable space for action games. A 12-player arena is about 250×250 studs, not 2,000×2,000.
10. **Data-drive quests and dialogue.** Keep definitions in ModuleScripts as tables. The server owns progress and validates every transition. Clients only render.
11. **NPCs: use `PathfindingService:CreatePath` with agent params, `pcall(path.ComputeAsync)`, handle `Path.Blocked`, repath on a timer, and detect when stuck.** Set the NPC's root part network owner to `nil`. Paths fail beyond 3,000 studs or 20,000 nodes.
12. **Turn StreamingEnabled on for any world larger than about 1,000 studs.** Client code must tolerate missing parts (`WaitForChild` with a timeout, `Workspace.PersistentLoaded` for Persistent models). Use `StreamOutBehavior.Opportunistic` on big worlds.
13. **Write for an 8–13 reading level:** short sentences, common words, one idea per line, and verbs first in quest text ("Find 3 crystals").
14. **Originality:** never copy a known game's map, names, or lore. Borrow structures (door rooms, obby stages, tycoon plots), never content.

---

## 1. Core level design principles

### 1.1 Flow and the "golden path"

The **golden path** is the route a first-time player should take. Design it first, then add optional branches. Rules:

- The next goal must be visible or signposted from every decision point.
- Paths are wide enough for traffic. Use **at least 8 studs** for single-player paths and **12–20 studs** for multiplayer corridors (players are about 2–4 studs wide, and pushing into each other at choke points is annoying).
- Corners and doorways frame the next view. Christopher Totten and many GDC speakers call this "framing": an arch or doorway works like a picture frame around the goal.
- **Loops beat dead ends.** A dead end must pay off with a reward, a secret, or a view. Otherwise convert it into a loop back to the main path.

### 1.2 Pacing and intensity curves

Plot a "beat chart" before building: one row per area, with columns for intensity (1–10), new mechanic, reward, and rest point.

```
Intensity
10 |                                   /\
 8 |                    /\            /  \ BOSS
 6 |          /\       /  \   /\     /    \
 4 |   /\    /  \/\   /    \_/  \   /      \__ reward/hub
 2 |__/  \__/      \_/          \_/
   +--------------------------------------------- time
     teach  dev   rest  twist   rest  climax  resolve
```

| Rule | Why |
|---|---|
| Overall trend rises (a sawtooth) | Keeps players progressing while letting them breathe |
| A rest valley after every peak | Lets them recover. Valleys are where you put shops, lore, and saves |
| The climax sits at about 80–90% of the session or level | Then a short resolution and reward screen |
| First 60 seconds stay low intensity but busy | Retention is decided in the first minute on Roblox |
| Average session target is 10–20 min | Chunk content into 2–5 minute arcs with save points |

### 1.3 Teaching through level design: kishōtenketsu

Nintendo's Koichi Hayashida (Super Mario 3D Land/3D World) described his stage design as following **kishōtenketsu**, the four-part structure of Chinese quatrains and Japanese four-panel comics. Game Maker's Toolkit popularised the analysis.

| Phase | In the level | Roblox example: a "disappearing platform" mechanic |
|---|---|---|
| **Ki** (introduce) | Show the mechanic where failing costs nothing | One disappearing platform over the floor, 1 stud below. Falling only costs a step back |
| **Shō** (develop) | Repeat with more demand | A row of 4 platforms over shallow water. Timing matters |
| **Ten** (twist) | Combine it with something else or invert it | Platforms disappear while a conveyor pushes you, or they *appear* only when you step on a button |
| **Ketsu** (conclude) | A mastery test, then a reward | A longer combined sequence over the kill-floor, then a checkpoint, a coin burst, and a new area reveal |

Rules for the bot:
- **One new mechanic per stage or room.** Combine it only with mechanics already taught.
- **The first exposure is always safe** (no kill brick under it, or a checkpoint just before it).
- Retire mechanics after their twist. Don't drag one mechanic through 30 stages.

### 1.4 Gating

Gates control order and pacing. Types:

| Gate | Example | Notes |
|---|---|---|
| Ability gate | Double-jump needed to reach a ledge | Show the ledge *before* the player has the ability: a "lock before key" tease |
| Key or item gate | Red keycard door | Colour the door like the key. Show the door first |
| Currency or level gate | "Requires Level 10" portal, or 5,000 coins to open a zone | The core of simulators. Show the price on a `BillboardGui` |
| Skill gate | A hard parkour section | Offer a skip product only if it's ethical. See the monetization chapter |
| Social gate | Needs 2 players on 2 buttons | Great in co-op. Always have a solo fallback (a timer, or an NPC helper) |
| Soft gate | A tough enemy zone that is passable but dangerous | Lets skilled players sequence-break, which is fun |
| Time gate | Daily door or event zone | Use sparingly |

Always **telegraph a gate**: lock icon, price, requirement text, and a different colour. Server-validate every gate (the `Touched` check must run on the server; never trust the client).

### 1.5 Weenies and landmarks

Walt Disney's "weenie" (from Scott Rogers' GDC 2009 talk *Everything I Learned About Level Design I Learned from Disneyland*) is a tall, distinctive landmark that pulls visitors forward, like the castle at the end of Main Street. Brian Upton's GDC talk borrowed Kevin Lynch's city-planning vocabulary: **paths, edges, districts, nodes, landmarks**.

Landmark rules:
- **Global landmark:** one per world, visible from everywhere (a giant tree, volcano, tower, or beam of light). Players orient by it. Make it at least 3–5× taller than anything around it and give it a unique silhouette and colour.
- **Local landmarks:** one per district or zone (a fountain, statue, or coloured lighthouse). Use them as meeting points ("meet at the fountain").
- Put the **goal of each area on a landmark** (the portal glows at the top of the tower).
- Landmarks need light at night (`PointLight` or `SurfaceLight`, a Neon accent). See the lighting chapter.

### 1.6 Sightlines

- **Reveal shots:** a narrow corridor opening onto a vista shows the whole next area and its landmark. Use these when entering a new zone.
- **Hide then reveal:** block the view with a hill or wall to create curiosity, then reveal.
- **Elevated overlook at spawn** lets new players read the layout.
- **PvP:** long sightlines (over 150 studs) favour snipers. Break them every 60–100 studs with cover or terrain, unless the lane is meant to be a sniper lane.
- **Horror:** short sightlines (8–30 studs), corners, and fog make tension.

### 1.7 Choke points

A choke point is a narrow pass where traffic concentrates.
- **PvP:** they create fights. Give each choke **at least two alternate routes** (flank paths), or it becomes a stalemate. Width 6–10 studs.
- **PvE:** use them for ambushes, gates, or tutorial moments.
- **Hubs:** *avoid* chokes near spawn. 20 players spawning into an 8-stud corridor is a traffic jam.

### 1.8 Risk and reward placement

- Put **valuable pickups near danger**: coins on the edge of a lava pit, or a chest on a dangerous side path.
- **Optional hard route = better reward.** The easy route always exists.
- The reward should be **visible before the risk** so the player chooses deliberately.
- In PvP, put power-ups in the **contested centre**. Put weaker items near spawns.

### 1.9 Verticality

- Height adds strategy (high ground) and wayfinding (views). It also adds frustration (falling).
- Give every height gain a **fast way back down**: a slide, a jump pad, or a drop with no fall damage.
- Use **ramps under the slope limit** (default `MaxSlopeAngle` 89°, so humanoids walk up almost anything; set it lower if you want slopes to block players). Keep ramps at 30–40° for comfort.
- `TrussPart` is climbable by default. Ladders are fine for 1–3 floors. Use stairs or ramps for crowds.
- In PvP, **high ground needs a counter**: exposure, a longer route, or no cover on top.

---

## 2. Roblox metrics (computed and verified)

### 2.1 Baseline values (from Creator Docs)

| Property | Default | Source |
|---|---|---|
| `StarterPlayer.CharacterWalkSpeed` / `Humanoid.WalkSpeed` | 16 studs/s | Humanoid.yaml |
| `StarterPlayer.CharacterJumpHeight` | 7.2 studs | StarterPlayer.yaml |
| `StarterPlayer.CharacterJumpPower` | 50 (studs/s initial up-velocity) | Humanoid.yaml |
| `StarterPlayer.CharacterUseJumpPower` | documented default: true (the template or game settings may change it; **set it explicitly**) | StarterPlayer.yaml |
| `Workspace.Gravity` | 196.2 studs/s² | Workspace.yaml |
| `StarterPlayer.CharacterMaxSlopeAngle` | 89° | StarterPlayer.yaml |
| Character height | about 5 studs (R15 default scale; Rthro and other bundles vary) | |
| Pathfinding `AgentRadius` / `AgentHeight` | 2 / 5 | characters/pathfinding.md |
| Pathfinding `WaypointSpacing` | 4 | characters/pathfinding.md |
| `StreamingTargetRadius` (recommended) | 1024 | workspace/streaming |

### 2.2 Jump physics

Projectile maths: initial velocity v₀ = √(2·g·h). Air time on flat ground = 2v₀/g. Horizontal travel = WalkSpeed × time.

- **JumpHeight 7.2:** v₀ = √(2·196.2·7.2) = **53.15 studs/s**. Time to apex 0.271 s, total air time **0.542 s**, flat jump distance at 16 studs/s = **8.67 studs**.
- **JumpPower 50:** apex = 50²/(2·196.2) = **6.37 studs**. Air time 0.510 s, flat distance **8.15 studs**.

Horizontal travel when landing at a different height (root displacement Δh; computed with t = (v₀ + √(v₀² − 2gΔh))/g):

| Landing Δh (studs) | JumpHeight 7.2 travel | JumpPower 50 travel |
|---|---|---|
| +7 | 5.06 (barely) | unreachable |
| +6 | 6.10 | 5.06 |
| +5 | 6.73 | 5.97 |
| +4 | 7.22 | 6.56 |
| +3 | 7.65 | 7.04 |
| +2 | 8.02 | 7.45 |
| +1 | 8.36 | 7.82 |
| 0 | 8.67 | 8.15 |
| −5 | 9.98 | 9.52 |
| −10 | 11.03 | 10.61 |
| −20 | 12.76 | 12.37 |

These are **centre-of-mass travel distances**. The edge-to-edge gap a player can clear is roughly this plus up to about 1–2 studs of footprint (taking off from the very edge and landing on the very lip), minus human error, latency, and mobile thumbs. Verify in a grey-box test, since animation state and the character's collision shape change results slightly.

### 2.3 Design gap table (JumpHeight 7.2, WalkSpeed 16)

| Difficulty | Flat gap (edge to edge) | Up-step | Platform size |
|---|---|---|---|
| Tutorial or trivial | 2–4 studs | ≤ 3 studs | 8×8 or larger |
| Easy | 4–5 | ≤ 4 | 6×6 |
| Medium | 5–6.5 | ≤ 5 | 4×4 |
| Hard | 6.5–8 | ≤ 6 | 2×2 to 3×3 |
| Expert (frame-perfect) | 8–9.5 | 6.5 | 1×1, truss edges |
| **Never required** | > 9.5 flat | > 7 | |

Other metrics:

| Element | Metric |
|---|---|
| Door (walk-through) | ≥ 4 wide × 7 tall. Use 6×9 to feel comfortable |
| Corridor (single player) | ≥ 6 wide, 10–12 tall |
| Corridor (multiplayer) | 12–20 wide |
| Stair step | rise 1, run 1–2 (walkable without jumping) |
| Railing or low wall (blocks walking, not view) | 3–4 tall |
| Wall that blocks jumping | ≥ 8 tall (above the 7.2 apex) |
| Cover in shooters (crouch-less) | 5–6 tall for full cover, 3 for half cover |
| Kill-floor distance below obby | 10–30 studs (fast respawn, readable fall) |
| Crossing time | 16 studs/s means 100 studs ≈ 6 s, 500 ≈ 31 s, 1,000 ≈ 63 s |
| Comfortable walk between hub points | ≤ 10 s (about 160 studs). Add sprint, teleports, or vehicles beyond that |

### 2.4 Verify-in-Studio snippet

Run this in the command bar during Play Solo to print your live jump numbers:

```lua
local hum = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
local g = workspace.Gravity
local v0 = hum.UseJumpPower and hum.JumpPower or math.sqrt(2 * g * hum.JumpHeight)
local air = 2 * v0 / g
print(("UseJumpPower=%s v0=%.2f apex=%.2f air=%.3fs flatDist=%.2f studs"):format(
	tostring(hum.UseJumpPower), v0, v0 * v0 / (2 * g), air, hum.WalkSpeed * air))
```

---

## 3. Obby stage design and difficulty curves

### 3.1 Structure

- **Stage = one checkpoint segment** of 15–60 seconds for a skilled player. Use 20–40 s on average.
- Group stages into **worlds of 10–20 stages** with a theme (colour and material palette), a final "boss" stage, and a hub or reward area.
- Show the stage number on the checkpoint pad and on `leaderstats` (players compare progress, and that is a social driver).

### 3.2 Difficulty curve

Use a sawtooth: each world starts easier than the last world's end, then ramps.

```
Difficulty
 |            /|          /|
 |          /  |        /  |       /
 |   /|   /    |  /|  /    |     /
 | /  | /      |/  |/      |   /
 +--------------------------------- stage
   W1      W2        W3
```

| Stage block | Gap | Element density | Fail cost |
|---|---|---|---|
| 1–5 | 3–4 studs, wide pads | 1 element type | ≤ 10 s replay |
| 6–15 | 4–6 | 2 types combined | ≤ 20 s |
| 16–30 | 5–7, moving parts | 3 types, timing | ≤ 30 s |
| 30+ | 6–8, small pads | twists and inversions | ≤ 45 s |

Rules:
- **Fail cost grows slowly.** No stage should cost more than about 45 s on a death.
- A **"breather" stage** every 5 stages (a short, pretty, easy one, maybe with a reward).
- Vary the **verb**: jump, wall-hop (truss edges), balance (thin beams), timing (spinners, lasers), conveyors, jump pads, swimming, and low-gravity zones.
- **Colour language** stays consistent across the game. **Red/Neon = kills**. Green = checkpoint. Blue = bounce. Yellow = moving or timed. Purple = special or teleport. Never paint decoration in the kill colour.
- **Readable hazards:** kill parts must look dangerous (Neon, lava texture, spikes). Invisible kill bricks are banned.
- Anti-frustration: show a "skip stage" or "stage hint" option only after N deaths on a stage, and keep it optional.

### 3.3 Obby element library (original variants are encouraged)

| Element | Build | Teaching first use |
|---|---|---|
| Static jumps | Parts | Wide pads over the floor |
| Kill floor or lava | Neon part, `Touched` → `Humanoid.Health = 0` | Visible before you need to cross it |
| Moving platform | `PrismaticConstraint` or a `TweenService` on an anchored part (prefer physics constraints so players ride it) | Slow, big platform |
| Spinner bar | `HingeConstraint` motor, or `CFrame` rotation on the server | Low rotation speed |
| Disappearing tiles | Cycle `Transparency` and `CanCollide` | One tile, safe drop |
| Conveyor | `AssemblyLinearVelocity` on an anchored part | Wide conveyor with walls |
| Jump pad | Apply an upward velocity on touch | Single pad to a big ledge |
| Truss climb | `TrussPart` | Short truss |
| Wraparound or wall-hop | Thin edges | Optional bonus first |

---

## 4. Hub and lobby design

### 4.1 The 10-second sell

When a player loads in, within 10 seconds they must see:
1. **What the game is**: the core activity visible from spawn (players fighting in an arena below, a tycoon plot row, the obby tower rising behind, pets following people).
2. **What to do first**: one glowing target (a portal, an NPC with a "!" icon, or a "PLAY" pad) within about 30 studs, ideally in the camera's starting view.
3. **That it's alive**: other players, movement, particles, music.

Spawn checklist:
- [ ] `SpawnLocation`s face the hub's main attraction (rotate the spawn part, since the character faces its front).
- [ ] Spawn area is wide (≥ 40×40 studs for 20+ players) with multiple `SpawnLocation`s to avoid stacking.
- [ ] No hazards, no NPC aggro, no PvP within the spawn bubble.
- [ ] The global landmark is in frame.
- [ ] The first action is reachable in ≤ 5 s of walking (≤ 80 studs).
- [ ] UI is not covering the view (keep the first-run GUI minimal).

### 4.2 Hub layout pattern (the "plaza and spokes")

```
                [ WORLD 2 PORTAL (locked, glowing) ]
                              |
   [SHOP]---[QUESTS NPC]---(PLAZA + LANDMARK)---[LEADERBOARDS]---[TRADING]
                              |
                        [ SPAWN PADS ]  -> facing plaza
                              |
                 [ MAIN ACTIVITY ENTRANCE / PLAY PORTAL ]
```

| Element | Placement rule |
|---|---|
| Main play portal or activity | In the spawn's direct view, closest of all |
| Shop | On the walk from spawn to the activity, never behind spawn. Use a visible NPC or storefront |
| Daily reward, codes, quests NPC | Within the first 20 s of walking. A "!" BillboardGui above |
| Leaderboards (SurfaceGui boards) | On the plaza edge, at eye level, near the waiting area |
| Locked zones and portals | Visible from spawn with the price or requirement shown. They create goals |
| Social space (benches, dance floor, fountain, AFK area) | Off the main traffic line, near the leaderboards |
| Premium or VIP area | Visible but not in the path. Never block the free path |
| Trading plaza | A separate pocket with space for 2-person interaction |
| Settings, info, update board | Near spawn, small |

Hub size: 150–300 studs across for 20–50 players. Everything important should be within 10 s of walking from spawn.

### 4.3 Round-based lobby

Lobbies in round games (murder mystery, survival, minigames) need:
- A clear **countdown display** (SurfaceGui or ScreenGui) and a "players ready" count.
- **Time-killers**: a mini obby, a dance floor, a cosmetic shop, or a spectate screen.
- A **teleport-in moment** (fade to black, then arrive at map spawns) and a teleport back to the lobby at round end.
- **Map vote pads** (stand on a pad to vote, which is physical and social).

---

## 5. Map sizes by player count

Rule of thumb: an encounter should happen every 10–30 s in action games. Time to cross ≈ size/16 seconds at default speed.

| Server size | Genre | Playable area | Notes |
|---|---|---|---|
| 1 (solo or story) | Horror, puzzle, obby | Linear: 200–1,500 studs of path. Rooms 20–60 studs | Density over size. Stream rooms in and out |
| 6 | Co-op horror, small PvP, party game | 150×150 to 300×300 | Everyone meets within 10 s |
| 12 | Arena PvP, round games | 200×200 to 400×400 (tight arena 250×250) | 3 lanes, about 1 fight every 15 s |
| 20–30 | Tycoon, simulator hub | Hub 200–300 across, plus plots | Plot ring around the hub |
| 50 | Battle royale, open world, social | 1,000×1,000 to 3,000×3,000 (shrinking zone for BR) | StreamingEnabled required. Vehicles or sprint for anything over 1,500 |
| 50–100 | Social hangout or roleplay town | 600–1,500 across, dense | Many interiors, so verticality multiplies space |

Calibration: about **1 player per 1,500–4,000 studs²** for action (12 players in 250×250 = 5,200 studs² each, which is on the roomy side). For exploration or roleplay, up to 20,000 studs² per player is fine *if* points of interest are spaced 100–200 studs apart.

---

## 6. Arena / PvP map design

### 6.1 Three-lane structure

```
 [SPAWN A]                                  [SPAWN B]
    |  \_____ flank lane (long, safe) _____/  |
    |---------- mid lane (short, contested) ---|
    |  /‾‾‾‾‾ flank lane (vertical/close) ‾‾\  |
             \__ connectors every 40–60 studs __/
```

- **Mid lane** is shortest, most exposed, and has the power-up.
- **Flanks** are longer but safer. One is close-quarters, the other long-range or vertical.
- **Connectors** between lanes (every 40–60 studs) allow rotations and stop stalemates.
- **Symmetry** (mirror or rotational) for competitive play. Asymmetry is fine for attack/defend if you test balance.

### 6.2 Cover

| Type | Size | Spacing |
|---|---|---|
| Full cover | ≥ 6 tall, ≥ 4 wide | Every 8–16 studs on main routes |
| Half cover (shoot over) | 3 tall | Between full covers |
| Pillar (peek both sides) | 4×4 | In open areas |

- No open stretch longer than about 3 s of running (48 studs) without cover in a shooter.
- Avoid *perfect* cover that can't be flanked.

### 6.3 Spawn safety

- **Spawns sit out of every line of sight** from enemy-accessible areas. Check with test raycasts from common positions.
- **Multiple spawn points per team.** Pick the one with the greatest distance to the nearest enemy (code below).
- **Spawn protection**: `ForceField` for 3–5 s, removed early if the player attacks.
- **One-way exits** or barriers stop enemies entering spawn rooms (team-filtered collision via `CollisionGroup`s, or a damage zone).

```lua
-- Server: choose the safest spawn for a player (furthest from nearest enemy)
local Players = game:GetService("Players")

local function pickSpawn(player: Player, spawns: {BasePart}): BasePart
	local best, bestScore = spawns[1], -math.huge
	for _, spawnPart in spawns do
		local nearest = math.huge
		for _, other in Players:GetPlayers() do
			if other ~= player and other.Team ~= player.Team then
				local root = other.Character and other.Character:FindFirstChild("HumanoidRootPart")
				if root then
					nearest = math.min(nearest, (root.Position - spawnPart.Position).Magnitude)
				end
			end
		end
		-- small random jitter so spawns don't feel predictable
		local score = nearest + math.random() * 10
		if score > bestScore then best, bestScore = spawnPart, score end
	end
	return best
end
```

---

## 7. Tycoon plot layout

- **Plots in a ring or grid around a shared hub.** 6–8 plots for typical 6–8 player servers (match `Players.MaxPlayers`).
- Plot size: **100×100 to 160×160 studs**, with 20–40 stud gaps or walls between plots.
- Every plot is a **copy of one template** (a Model with a `PrimaryPart`) and is claimed by touching a claim pad at its entrance. Store the owner as an attribute (`plot:SetAttribute("OwnerUserId", id)`).
- **Build order radiates outward** from the entrance: the dropper and conveyor first (core loop visible in 30 s), then walls, floors, decor, and upper floors last (verticality for late game).
- **Buy buttons are laid out along a path** so the next affordable button is always near the last one. Use colour states: grey = locked, green = affordable, yellow = soon.
- The collector or cash pad sits near the entrance.
- Show a **neighbour view**: other players' builds are visible (low walls or glass) to create envy and goals.
- Keep part counts per plot within budget (a fully built plot of about 2,000–5,000 parts for 8 plots). Use StreamingEnabled if plots are far apart.

---

## 8. Open world vs zones/worlds

| Approach | Pros | Cons | Use when |
|---|---|---|---|
| Single open world (streamed) | Seamless exploration, social density | Memory, server cost, harder to gate | Roleplay towns, survival, adventure |
| Zoned in one place (walls or portals between areas in the same server) | Easy gating (price doors), players stay together | All zones on one server | Simulators ("Area 2 costs 10K") |
| Separate places (teleports) | Huge content, per-place tuning | Load screens, split players, data handoff | Story chapters, dungeons, PvP queues |
| Instanced/reserved servers | Private runs (dungeons, parties) | Matchmaking work | Co-op dungeons, horror runs |

Zone-gating pattern in one place:
- Each zone has a **gate** (a part with `CanCollide` true) that the client hides once owned. The **server** checks ownership on touch or teleport so players can't bypass it.
- Zones get a **distinct palette and landmark** and a title card on entry ("Frostpeak Caverns").
- Zone N+1 is **visible** from zone N (over a wall or through a glowing portal).

Cross-place travel uses `TeleportService:TeleportAsync(placeId, players, teleportOptions)` on the server. Pass small data through `TeleportOptions:SetTeleportData` (treat it as untrusted, and keep authoritative data in DataStores). Use `TeleportService:ReserveServer` for private instances.

---

## 9. Procedural generation

### 9.1 Door-room generator (linear, "next room" style)

Pattern (a well-known DevForum approach): pre-built **room templates** each have an **Entrance** and an **Exit** attachment. Each new room is aligned so its Entrance meets the previous room's Exit. Keep a window of rooms around the player, and destroy old ones.

Template authoring rules:
- Each room Model in `ServerStorage.Rooms` has a `PrimaryPart` (an invisible floor bounding part), an `Attachment` named `Entrance` and one named `Exit`, both on the PrimaryPart. The attachment's look direction (−Z, the front) points *out of* the room.
- Attributes: `Weight` (spawn chance), `MinIndex` (earliest room number), `Tag` ("Hallway", "Puzzle", "Shop", "Monster").
- Doors are 6×9 studs and sit centred on the attachments.

The full code is in §16.4.

### 9.2 Grid dungeons

For branching dungeons, work on a grid (for example 10×10 cells of 40 studs):
1. Random walk or BSP to choose occupied cells.
2. Pick start, boss (furthest by BFS), and treasure (dead ends).
3. For each cell, choose a template by its open sides (N/E/S/W bitmask: 16 variants, or 4 shapes × rotations).
4. Validate connectivity with BFS. Re-roll if it fails (retry cap!).
5. **Seed everything** with `Random.new(seed)` so runs are reproducible and debuggable.

### 9.3 Perlin terrain

`math.noise(x, y, z)` returns roughly −1..1 (often within ±0.5). Layer octaves for natural shapes:

```lua
-- Server: simple heightmap terrain with octaves. Run once at startup (or in a plugin).
local Terrain = workspace.Terrain
local SIZE, CELL = 128, 4               -- 128x128 columns of 4x4 studs = 512x512 studs
local SEED = 1337
local function height(x, z)
	local h, amp, freq = 0, 1, 1 / 96
	for _ = 1, 4 do                      -- 4 octaves
		h += math.noise(x * freq, z * freq, SEED) * amp
		amp *= 0.5; freq *= 2
	end
	return 20 + h * 40                   -- base 20, about ±30 variation
end
for ix = 0, SIZE - 1 do
	for iz = 0, SIZE - 1 do
		local x, z = (ix - SIZE / 2) * CELL, (iz - SIZE / 2) * CELL
		local h = math.max(4, height(x, z))
		local mat = h > 45 and Enum.Material.Rock or (h < 12 and Enum.Material.Sand or Enum.Material.Grass)
		Terrain:FillBlock(CFrame.new(x, h / 2, z), Vector3.new(CELL, h, CELL), mat)
	end
	if ix % 8 == 0 then task.wait() end  -- yield to avoid script timeout
end
Terrain:FillBlock(CFrame.new(0, 6, 0), Vector3.new(SIZE * CELL, 4, SIZE * CELL), Enum.Material.Water) -- sea level
```

Procedural rules:
- **Hand-author the important spaces** (spawn, boss arenas, hubs) and generate the filler.
- Place landmarks procedurally but **guarantee** at least one visible per area.
- Clamp the playable area with walls or water. Generated terrain must not trap players (flood-fill or pathfind test from spawn).

---

## 10. Wayfinding

| Tool | How | Notes |
|---|---|---|
| Landmarks | §1.5 | Primary |
| Colour coding | One accent colour = "interactable or the path" (for example yellow trims on climbable ledges, orange on doors) | Keep it consistent for the whole game |
| Lighting cues | Brighter and warmer = go here. Dark = optional or danger | Players move toward light |
| Signage | Short words plus an icon (arrow, zone name) on `SurfaceGui` | ≤ 5 words |
| Breadcrumbs | Coins or collectibles laid along the path | Doubles as reward |
| Beam guide | `Beam` from the player to the objective, with `TextureSpeed` for flow | Quests and tutorials. Toggleable |
| Compass or waypoint UI | `BillboardGui` with `AlwaysOnTop` over the objective, showing distance | Big worlds |
| Geometry | Paths worn into terrain, fences as edges, arches as framing | Invisible guidance |
| Sound | Music or ambience from the objective (`Sound` in a part) | Horror and exploration |
| NPC behaviour | NPCs walking toward the event | Organic |

### 10.1 Beam guide (client)

```lua
-- LocalScript (StarterPlayerScripts): draw an animated beam from the character to a target part.
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local GuideBeam = {}
local beam, a0, a1

function GuideBeam.show(target: BasePart)
	GuideBeam.hide()
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart", 5)
	if not root then return end
	a0 = Instance.new("Attachment"); a0.Position = Vector3.new(0, -2.5, 0); a0.Parent = root
	a1 = Instance.new("Attachment"); a1.Parent = target
	beam = Instance.new("Beam")
	beam.Attachment0, beam.Attachment1 = a0, a1
	beam.Width0, beam.Width1 = 1, 1
	beam.FaceCamera = true
	beam.Color = ColorSequence.new(Color3.fromRGB(255, 220, 80))
	beam.LightEmission = 1
	beam.Texture = "rbxassetid://0" -- replace with your own arrow/chevron texture id
	beam.TextureMode = Enum.TextureMode.Static
	beam.TextureLength = 4
	beam.TextureSpeed = 2           -- arrows flow toward the target
	beam.Segments = 20
	beam.Parent = root
end

function GuideBeam.hide()
	if beam then beam:Destroy() end
	if a0 then a0:Destroy() end
	if a1 then a1:Destroy() end
	beam, a0, a1 = nil, nil, nil
end

return GuideBeam -- put this in a ModuleScript if you require it from other client code
```

With StreamingEnabled, the target may not exist on the client. Point the beam at a target in a Persistent model, or fall back to a `BillboardGui` at a known `Vector3` position.

---

## 11. Greyboxing / blockout workflow

1. **Paper or text map**: bubble diagram of areas, golden path, gates, and the beat chart (§1.2).
2. **Metrics test room**: a gallery of gaps (2–10 studs), heights (1–8), corridor widths, and cover heights. Play it once to confirm the numbers in §2.
3. **Blockout** with plain anchored parts, using colour codes:

| Colour | Meaning |
|---|---|
| Grey | Walkable floor or walls |
| Red | Hazard |
| Green | Checkpoint or spawn |
| Blue | Interactable |
| Yellow | Gate or door |
| Orange | Enemy spawn |
| Transparent purple | Trigger volume |

4. **Playtest** using Studio's **Team Test** or local server with 2–8 players. Record: time per area, deaths per spot, where players look and get lost, and where they stop.
5. **Iterate the layout** (cheap now). Cut anything not fun.
6. **Art pass**: replace blocks with assets. Keep the collision of the blockout (use invisible collision parts plus `CanCollide=false` detail meshes when meshes have messy collision).
7. **Polish and lighting** (see the lighting chapter), then re-test (art changes readability).
8. **Performance pass**: part count, StreamingEnabled, `CollisionFidelity`, and anchoring.

---

## 12. Environmental storytelling

Tell story through objects placed in the world. Players read scenes faster than text.

| Technique | Example (original) |
|---|---|
| Aftermath scene | Broken cart, scattered crates, claw marks: something attacked here |
| Contrast | A cosy lit cabin in a dead grey forest: safety, hope |
| Progression of decay | A town gets more overgrown the deeper you go: time or corruption spreading |
| Personal objects | A child's drawing on a lab wall tells you who lived here |
| Signs and notes | A short note: "Don't open the blue door. —M." |
| Architecture | Barricaded windows mean the people were afraid of outside |
| Light and colour | A safe zone is warm. A corrupted zone is purple and green |
| Before/after | Restoring a zone (a quest reward) visibly changes it: flowers, lights back on |

Rules: every room should answer "what happened here?" without text. Put a **story prop near every rest point** (players stop and look there).

---

## 13. Quests, NPCs and dialogue

### 13.1 Quest design rules

- **Verb + count + target**: "Collect 5 Glowberries", "Talk to Ranger Pim", "Defeat 3 Slimes".
- Quest chains of 3–6 steps. Each step happens **within about 60 s of travel** of the previous one.
- Rewards are shown up front (coins, XP, and a cosmetic or pet item for chain finales).
- Variety: talk, collect, defeat, reach, deliver, escort (sparingly), and puzzle.
- Show **tracker UI** (top-right list), a world marker (Beam or Billboard), and "!" or "?" over quest NPCs.
- Daily or repeatable quests feed retention. Story quests feed onboarding.

### 13.2 Data-driven architecture

```
ReplicatedStorage/
  QuestDefs (ModuleScript)    -- pure data, readable by client for UI
  DialogueDefs (ModuleScript) -- pure data
  Remotes/ QuestUpdated (RemoteEvent), DialogueEvent (RemoteEvent)
ServerScriptService/
  QuestService (ModuleScript) -- owns progress, validates, rewards
  DialogueServer (Script)     -- ProximityPrompts + node transitions
StarterPlayerScripts/
  DialogueClient (LocalScript) -- renders UI only
```

Full code is in §16.1 and §16.2.

### 13.3 Dialogue writing rules

- **≤ 2 short sentences per node** (≤ 25 words). Use 2–4 choices.
- Every NPC has a **name, one personality trait, and one want** ("Pim, a nervous ranger who wants his lantern back").
- Choices must be **meaningfully different** in tone or outcome, and always include a "Bye" exit.
- Use the player's name sparingly (`player.DisplayName`).
- **All player-visible text from users must be filtered** (`TextService:FilterStringAsync`). Authored dialogue doesn't need filtering, but localise it with `LocalizationService` and translation tables when going global.
- `ProximityPrompt` settings for NPCs: `ActionText = "Talk"`, `ObjectText = npcName`, `MaxActivationDistance = 8–10`, `HoldDuration = 0`, `RequiresLineOfSight = false` for NPCs whose prompt sits in their head (prevents flicker), and `KeyboardKeyCode = E` (the default).

---

## 14. Lore & writing for kids and teens

Roblox's core audience skews young (a large share under 13, and a growing 13–17 and 17+ segment). Write for a **reading age of about 8–12** unless the game is clearly for older teens.

| Rule | Bad | Good |
|---|---|---|
| Short sentences (≤ 12 words) | "The ancient guardians, long forgotten by the villagers, have reawakened to protect the sacred grove." | "The stone guards woke up. They protect the grove." |
| Verbs first in objectives | "The crystals must be collected" | "Find 3 crystals" |
| Common words | "Commence", "acquire" | "Start", "get" |
| One idea per text box | Lore dump | Drip-feed across 5 NPCs |
| Numbers over words | "a few" | "3" |
| Humour and personality | Generic quest-giver | A goofy frog mayor who hates puddles |
| Show, don't tell | "The castle is scary" | Torches flicker out as you walk in |
| Optional deep lore | Forced reading | Collectible notes or a codex for fans |

Lore structure: a **one-sentence premise** ("Islands fell from the sky, and you're the last sky-mechanic"), **3–5 factions or places**, **one mystery** that unfolds through updates (great for community theories and returning players), and a **mascot** character.

Content safety: keep within Roblox Community Standards and set the **Maturity & Compliance questionnaire** honestly. Avoid realistic gore or romance in all-ages games. Horror can be suspenseful and still fit lower age ratings if gore is absent. Check the current content maturity labels in the docs before publishing.

---

## 15. Cutscenes and onboarding through the world

### 15.1 Cutscenes

- **Keep them short** (≤ 10 s on first join, ≤ 20 s for story beats) and **always skippable** (a button, plus auto-skip on replays; store a "seen" flag in DataStore).
- Implement them on the client: `Camera.CameraType = Enum.CameraType.Scriptable`, tween `Camera.CFrame` between named camera parts with `TweenService`, then restore `Enum.CameraType.Custom`.
- Don't freeze players in multiplayer for a cutscene others aren't watching. Use in-world events (an NPC walks by, a bridge collapses) that everyone sees in real time where possible.


### 15.2 Onboarding through the world (no wall of text)

1. **Spawn view** shows the goal (§4.1).
2. **First interaction is guaranteed success**: a big glowing button, an NPC with "!", or the first coin pile 10 studs away.
3. **Teach controls diegetically**: a short wall to jump over right after spawn. Contextual prompt ("Press Space / tap ↑") appears only if they haven't jumped in 5 s.
4. **First reward within 30 s** (currency, a pet, an upgrade).
5. **Second goal revealed by the first reward** ("You can afford the Speed Boots! Shop →", with the Beam guide on).
6. **Social hook within 2–3 min**: show other players' progress (leaderboard, visible bigger builds).
7. **Session ender**: a reason to return (daily reward timer, locked zone price).

---

## 16. Code: core systems

All code is Luau, server-authoritative, and uses typed annotations lightly. Replace placeholder asset IDs with your own.

### 16.1 Data-driven quest system

```lua
-- ReplicatedStorage/QuestDefs (ModuleScript) — pure data; safe for client UI to read.
-- Objective types: "talk", "collect", "defeat", "reach"
return {
	lost_lantern = {
		title = "The Lost Lantern",
		giver = "RangerPim",
		requires = {},                         -- quest ids that must be complete first
		steps = {
			{ type = "talk",    target = "RangerPim",   count = 1, text = "Talk to Ranger Pim" },
			{ type = "collect", target = "Glowberry",   count = 5, text = "Find 5 Glowberries" },
			{ type = "reach",   target = "OldMill",     count = 1, text = "Go to the Old Mill" },
			{ type = "defeat",  target = "MossSlime",   count = 3, text = "Beat 3 Moss Slimes" },
			{ type = "talk",    target = "RangerPim",   count = 1, text = "Bring the lantern to Pim" },
		},
		rewards = { coins = 250, xp = 100 },
	},
	mill_repairs = {
		title = "Fix the Mill",
		giver = "Miller",
		requires = { "lost_lantern" },
		steps = {
			{ type = "collect", target = "Gear", count = 3, text = "Find 3 old gears" },
			{ type = "talk",    target = "Miller", count = 1, text = "Give the gears to the Miller" },
		},
		rewards = { coins = 400, xp = 150 },
	},
}
```

```lua
-- ServerScriptService/QuestService (ModuleScript)
-- Owns all quest progress. Other server code calls QuestService.report(player, type, target, amount).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local QuestDefs = require(ReplicatedStorage:WaitForChild("QuestDefs"))
local QuestUpdated = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("QuestUpdated") :: RemoteEvent

export type QuestState = { step: number, progress: number }
export type PlayerQuests = { active: { [string]: QuestState }, completed: { [string]: boolean } }

local QuestService = {}
local data: { [Player]: PlayerQuests } = {}

-- Hook these to your save system (DataStore/ProfileStore) — see the data chapter.
function QuestService.load(player: Player, saved: PlayerQuests?)
	data[player] = saved or { active = {}, completed = {} }
	QuestUpdated:FireClient(player, data[player])
end

function QuestService.get(player: Player): PlayerQuests?
	return data[player]
end

local function grantRewards(player: Player, rewards)
	local stats = player:FindFirstChild("leaderstats")
	local coins = stats and stats:FindFirstChild("Coins")
	if coins and rewards.coins then coins.Value += rewards.coins end
	-- xp, items, etc.: call your economy module here
end

function QuestService.canStart(player: Player, questId: string): boolean
	local pq, def = data[player], QuestDefs[questId]
	if not pq or not def then return false end
	if pq.active[questId] or pq.completed[questId] then return false end
	for _, req in def.requires do
		if not pq.completed[req] then return false end
	end
	return true
end

function QuestService.start(player: Player, questId: string): boolean
	if not QuestService.canStart(player, questId) then return false end
	data[player].active[questId] = { step = 1, progress = 0 }
	QuestUpdated:FireClient(player, data[player])
	return true
end

local function advance(player: Player, questId: string)
	local pq = data[player]
	local state, def = pq.active[questId], QuestDefs[questId]
	state.step += 1
	state.progress = 0
	if state.step > #def.steps then
		pq.active[questId] = nil
		pq.completed[questId] = true
		grantRewards(player, def.rewards)
	end
end

-- The single entry point for all gameplay events.
function QuestService.report(player: Player, objType: string, target: string, amount: number?)
	local pq = data[player]
	if not pq then return end
	local changed = false
	for questId, state in pq.active do
		local step = QuestDefs[questId].steps[state.step]
		if step and step.type == objType and step.target == target then
			state.progress = math.min(step.count, state.progress + (amount or 1))
			changed = true
			if state.progress >= step.count then
				advance(player, questId)
			end
		end
	end
	if changed then QuestUpdated:FireClient(player, pq) end
end

Players.PlayerRemoving:Connect(function(player)
	-- save data[player] here first
	data[player] = nil
end)

return QuestService
```

Hooking events (server):

```lua
-- "reach" objective: tagged trigger parts with a QuestTarget attribute
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local QuestService = require(game.ServerScriptService.QuestService)

local function hookReach(part: BasePart)
	local debounce = {}
	part.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if player and not debounce[player] then
			debounce[player] = true
			QuestService.report(player, "reach", part:GetAttribute("QuestTarget"))
			task.delay(2, function() debounce[player] = nil end)
		end
	end)
end
for _, p in CollectionService:GetTagged("QuestReach") do hookReach(p) end
CollectionService:GetInstanceAddedSignal("QuestReach"):Connect(hookReach)

-- "collect": in your pickup handler → QuestService.report(player, "collect", "Glowberry")
-- "defeat":  when an NPC humanoid dies, read its creator tag → QuestService.report(killer, "defeat", npc.Name)
```

### 16.2 Dialogue system with ProximityPrompt

```lua
-- ReplicatedStorage/DialogueDefs (ModuleScript)
-- Node: { text, choices = { {text, next?, action?, condition?} } }. next=nil ends the conversation.
return {
	RangerPim = {
		displayName = "Ranger Pim",
		start = function(ctx) -- pick an entry node based on quest state
			if ctx.completed("lost_lantern") then return "thanks" end
			if ctx.active("lost_lantern") then return "waiting" end
			return "hello"
		end,
		nodes = {
			hello = {
				text = "Oh! Hi. Have you seen my lantern? The woods get so dark...",
				choices = {
					{ text = "I'll find it!", next = "accept", action = "startQuest:lost_lantern" },
					{ text = "What's in the woods?", next = "lore" },
					{ text = "Bye.", next = nil },
				},
			},
			lore = {
				text = "Moss Slimes. They love shiny things. Like my lantern.",
				choices = {
					{ text = "I'll get it back.", next = "accept", action = "startQuest:lost_lantern" },
					{ text = "Yikes. Bye.", next = nil },
				},
			},
			accept = {
				text = "Thank you! Grab some Glowberries first. They light the way.",
				choices = { { text = "On it!", next = nil } },
			},
			waiting = {
				text = "Any luck? Follow the glowing path.",
				choices = { { text = "Still looking.", next = nil } },
			},
			thanks = {
				text = "My lantern! The woods feel safer already.",
				choices = { { text = "Happy to help.", next = nil } },
			},
		},
	},
}
```

```lua
-- ServerScriptService/DialogueServer (Script)
-- NPC models are tagged "DialogueNPC" and have attribute DialogueId = "RangerPim".
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local DialogueDefs = require(ReplicatedStorage:WaitForChild("DialogueDefs"))
local QuestService = require(script.Parent:WaitForChild("QuestService"))
local DialogueEvent = ReplicatedStorage.Remotes:WaitForChild("DialogueEvent") :: RemoteEvent

-- Server-side conversation state: which NPC/node each player is on.
local sessions: { [Player]: { npcId: string, node: string, npc: Model } } = {}
local MAX_TALK_DISTANCE = 15

local function makeCtx(player)
	local pq = QuestService.get(player) or { active = {}, completed = {} }
	return {
		active = function(id) return pq.active[id] ~= nil end,
		completed = function(id) return pq.completed[id] == true end,
	}
end

local function runAction(player: Player, action: string?)
	if not action then return end
	local kind, arg = string.match(action, "^(%w+):(.+)$")
	if kind == "startQuest" then
		QuestService.start(player, arg)
	end
	-- add more: "giveItem:...", "openShop:...", "teleport:..."
end

local function sendNode(player: Player, npcId: string, nodeId: string?)
	local def = DialogueDefs[npcId]
	if not nodeId then
		sessions[player] = nil
		DialogueEvent:FireClient(player, "close")
		return
	end
	local node = def.nodes[nodeId]
	sessions[player].node = nodeId
	local choiceTexts = {}
	for i, c in node.choices do choiceTexts[i] = c.text end
	DialogueEvent:FireClient(player, "show", def.displayName, node.text, choiceTexts)
end

local function setupNPC(npc: Model)
	local npcId = npc:GetAttribute("DialogueId")
	local def = npcId and DialogueDefs[npcId]
	local head = npc:FindFirstChild("Head") or npc.PrimaryPart
	if not def or not head then return end

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Talk"
	prompt.ObjectText = def.displayName
	prompt.MaxActivationDistance = 10
	prompt.HoldDuration = 0
	prompt.RequiresLineOfSight = false
	prompt.Parent = head

	prompt.Triggered:Connect(function(player)
		if sessions[player] then return end
		-- Talking also counts as a quest "talk" objective
		QuestService.report(player, "talk", npcId)
		sessions[player] = { npcId = npcId, node = "", npc = npc }
		sendNode(player, npcId, def.start(makeCtx(player)))
	end)
end

DialogueEvent.OnServerEvent:Connect(function(player, choiceIndex)
	local s = sessions[player]
	if not s or typeof(choiceIndex) ~= "number" then return end
	-- Validate distance so exploiters can't talk across the map
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root or (root.Position - s.npc:GetPivot().Position).Magnitude > MAX_TALK_DISTANCE then
		sendNode(player, s.npcId, nil); return
	end
	local node = DialogueDefs[s.npcId].nodes[s.node]
	local choice = node and node.choices[math.floor(choiceIndex)]
	if not choice then return end
	runAction(player, choice.action)
	sendNode(player, s.npcId, choice.next)
end)

Players.PlayerRemoving:Connect(function(p) sessions[p] = nil end)
for _, npc in CollectionService:GetTagged("DialogueNPC") do setupNPC(npc) end
CollectionService:GetInstanceAddedSignal("DialogueNPC"):Connect(setupNPC)
```

```lua
-- StarterPlayerScripts/DialogueClient (LocalScript) — renders only; expects a ScreenGui "DialogueGui"
-- with Frame > NameLabel, BodyLabel, Choices (UIListLayout) and a template TextButton "ChoiceTemplate".
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DialogueEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("DialogueEvent")

local gui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("DialogueGui")
local frame = gui.Frame
local template = frame.Choices.ChoiceTemplate
template.Visible = false

local function typewrite(label: TextLabel, text: string)
	label.Text = text
	label.MaxVisibleGraphemes = 0
	for i = 1, utf8.len(text) or #text do
		label.MaxVisibleGraphemes = i
		task.wait(0.015)
	end
	label.MaxVisibleGraphemes = -1
end

DialogueEvent.OnClientEvent:Connect(function(cmd, name, body, choices)
	for _, c in frame.Choices:GetChildren() do
		if c:IsA("TextButton") and c ~= template then c:Destroy() end
	end
	if cmd == "close" then frame.Visible = false; return end
	frame.Visible = true
	frame.NameLabel.Text = name
	task.spawn(typewrite, frame.BodyLabel, body)
	for i, text in choices do
		local b = template:Clone()
		b.Text = text; b.LayoutOrder = i; b.Visible = true
		b.Parent = frame.Choices
		b.Activated:Connect(function() DialogueEvent:FireServer(i) end)
	end
end)
```

### 16.3 Pathfinding chase NPC (perception, patrol, chase, search, repath, stuck detection)

```lua
-- Script inside an NPC Model (R15/R6 rig with Humanoid + HumanoidRootPart).
-- States: Patrol -> Chase (sees player) -> Search (lost player) -> Patrol
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")

local npc = script.Parent
local humanoid: Humanoid = npc:WaitForChild("Humanoid")
local root: BasePart = npc:WaitForChild("HumanoidRootPart")
root:SetNetworkOwner(nil) -- server simulates; prevents stutter/exploits

local CONFIG = {
	PatrolSpeed = 10, ChaseSpeed = 18,       -- ChaseSpeed slightly > player 16 = tense; == 16 = fair
	SightRange = 80, FOVDegrees = 110, HearRange = 18, -- hear = 360° close-range detection
	RepathInterval = 0.4, RepathMoveThreshold = 6,
	LoseSightTime = 3, SearchTime = 6,
	StuckCheckInterval = 1, StuckDistance = 1.0,
	AttackRange = 4, AttackDamage = 20, AttackCooldown = 1,
}
local patrolPoints = {} -- Parts in a folder "PatrolPoints" next to the NPC
local folder = npc.Parent:FindFirstChild("PatrolPoints")
if folder then patrolPoints = folder:GetChildren() end

local path = PathfindingService:CreatePath({
	AgentRadius = 2, AgentHeight = 5,
	AgentCanJump = true, AgentCanClimb = false,
	WaypointSpacing = 4,
	Costs = { Water = 20, DangerZone = math.huge, Door = 1 }, -- DangerZone/Door = PathfindingModifier Labels
})

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.FilterDescendantsInstances = { npc }

---------------------------------------------------------------- perception
local function canSee(targetRoot: BasePart): boolean
	local offset = targetRoot.Position - root.Position
	local dist = offset.Magnitude
	if dist <= CONFIG.HearRange then return true end
	if dist > CONFIG.SightRange then return false end
	local dot = root.CFrame.LookVector:Dot(offset.Unit)
	if dot < math.cos(math.rad(CONFIG.FOVDegrees / 2)) then return false end
	local hit = workspace:Raycast(root.Position + Vector3.new(0, 1.5, 0), offset, rayParams)
	return hit ~= nil and hit.Instance:IsDescendantOf(targetRoot.Parent)
end

local function findTarget(): (Model?, BasePart?)
	local best, bestRoot, bestDist = nil, nil, math.huge
	for _, player in Players:GetPlayers() do
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local tRoot = char and char:FindFirstChild("HumanoidRootPart")
		if hum and hum.Health > 0 and tRoot and canSee(tRoot) then
			local d = (tRoot.Position - root.Position).Magnitude
			if d < bestDist then best, bestRoot, bestDist = char, tRoot, d end
		end
	end
	return best, bestRoot
end

---------------------------------------------------------------- movement
local waypoints: { PathWaypoint } = {}
local wpIndex = 0
local currentGoal: Vector3? = nil
local lastPathTime = 0

local function computePath(goal: Vector3): boolean
	local ok = pcall(function() path:ComputeAsync(root.Position, goal) end)
	lastPathTime = os.clock()
	currentGoal = goal
	if ok and path.Status == Enum.PathStatus.Success then
		waypoints = path:GetWaypoints()
		wpIndex = 2 -- index 1 is the start position
		return true
	end
	waypoints, wpIndex = {}, 0
	return false
end

path.Blocked:Connect(function(blockedIndex)
	if blockedIndex >= wpIndex and currentGoal then
		computePath(currentGoal) -- obstacle appeared ahead (door closed, part streamed, etc.)
	end
end)

-- Step along the path; call each heartbeat-ish tick.
local function stepPath()
	local wp = waypoints[wpIndex]
	if not wp then return end
	if wp.Action == Enum.PathWaypointAction.Jump then
		humanoid.Jump = true
	end
	-- Custom PathfindingLink labels arrive as wp.Label (e.g. "UseZipline") — handle here.
	humanoid:MoveTo(wp.Position)
	local flat = Vector3.new(wp.Position.X - root.Position.X, 0, wp.Position.Z - root.Position.Z)
	if flat.Magnitude < 2.5 then wpIndex += 1 end
end

-- Stuck detection: not moving while it should be -> jump, then force repath.
local lastPos, lastStuckCheck, stuckCount = root.Position, os.clock(), 0
local function checkStuck()
	if os.clock() - lastStuckCheck < CONFIG.StuckCheckInterval then return end
	lastStuckCheck = os.clock()
	local moved = (root.Position - lastPos).Magnitude
	lastPos = root.Position
	if wpIndex > 0 and wpIndex <= #waypoints and moved < CONFIG.StuckDistance then
		stuckCount += 1
		humanoid.Jump = true
		if currentGoal then computePath(currentGoal) end
		if stuckCount >= 4 then
			-- Last resort: nudge to the next waypoint so it never freezes forever
			local wp = waypoints[math.min(wpIndex, #waypoints)]
			if wp then npc:PivotTo(CFrame.new(wp.Position + Vector3.new(0, 3, 0))) end
			stuckCount = 0
		end
	else
		stuckCount = 0
	end
end

---------------------------------------------------------------- state machine
local state = "Patrol"
local target: Model?, targetRoot: BasePart? = nil, nil
local lastSeenPos: Vector3? = nil
local lastSeenTime, searchStart, lastAttack = 0, 0, 0
local patrolIndex = 1

local function setState(s: string)
	state = s
	humanoid.WalkSpeed = (s == "Chase") and CONFIG.ChaseSpeed or CONFIG.PatrolSpeed
	waypoints, wpIndex = {}, 0
end

local function tryAttack()
	if not (target and targetRoot) then return end
	if (targetRoot.Position - root.Position).Magnitude <= CONFIG.AttackRange
		and os.clock() - lastAttack >= CONFIG.AttackCooldown then
		lastAttack = os.clock()
		local hum = target:FindFirstChildOfClass("Humanoid")
		if hum then hum:TakeDamage(CONFIG.AttackDamage) end
	end
end

humanoid.Died:Connect(function() script.Enabled = false end)

while humanoid.Health > 0 do
	local seenChar, seenRoot = findTarget()
	if seenChar then
		target, targetRoot = seenChar, seenRoot
		lastSeenPos, lastSeenTime = seenRoot.Position, os.clock()
		if state ~= "Chase" then setState("Chase") end
	end

	if state == "Patrol" then
		if #patrolPoints > 0 then
			if wpIndex == 0 or wpIndex > #waypoints then
				patrolIndex = patrolIndex % #patrolPoints + 1
				computePath(patrolPoints[patrolIndex].Position)
			end
		end
	elseif state == "Chase" then
		if not seenChar and os.clock() - lastSeenTime > CONFIG.LoseSightTime then
			setState("Search"); searchStart = os.clock()
			if lastSeenPos then computePath(lastSeenPos) end
		elseif targetRoot then
			local goalMoved = currentGoal == nil
				or (targetRoot.Position - currentGoal).Magnitude > CONFIG.RepathMoveThreshold
			local close = (targetRoot.Position - root.Position).Magnitude < 10
			if close and seenChar then
				-- direct line: skip pathfinding for snappy close chase
				humanoid:MoveTo(targetRoot.Position); waypoints, wpIndex = {}, 0
			elseif goalMoved and os.clock() - lastPathTime > CONFIG.RepathInterval then
				if not computePath(targetRoot.Position) then humanoid:MoveTo(targetRoot.Position) end
			end
			tryAttack()
		end
	elseif state == "Search" then
		if os.clock() - searchStart > CONFIG.SearchTime then
			target, targetRoot = nil, nil
			setState("Patrol")
		elseif wpIndex == 0 or wpIndex > #waypoints then
			-- look around: wander near last seen position
			local base = lastSeenPos or root.Position
			computePath(base + Vector3.new(math.random(-20, 20), 0, math.random(-20, 20)))
		end
	end

	stepPath()
	checkStuck()
	task.wait(0.1)
end
```

Notes:
- `ComputeAsync` yields and can error. Always `pcall` it and check `path.Status`.
- Paths fail if the straight-line distance is over **3,000 studs** or the search exceeds **20,000 nodes**. Use waypoint graphs (zone-to-zone) for huge maps.
- For doors NPCs should path *through*, put a part with a `PathfindingModifier` (`PassThrough = true`) around the door. To mark expensive or forbidden areas, set a modifier `Label` (for example `DangerZone`) and give that label a cost in `Costs` (`math.huge` means never).
- Use `PathfindingLink` (`Attachment0`, `Attachment1`, `Label`, `IsBidirectional`) for zip-lines, teleporters, and boats. The waypoint's `Label` tells your script to run the custom action.
- Many NPCs: stagger updates (each NPC ticks at a random offset), reduce perception checks to 5–10 Hz, and cap simultaneous `ComputeAsync` calls.
- **Fairness:** for horror chasers, ChaseSpeed ≈ player speed ± 2. Give players hiding spots (closets that break line of sight) and audio warnings before the monster arrives.

### 16.4 Procedural room generator (door-room style)

```lua
-- ServerScriptService/RoomGenerator (Script)
-- Templates: ServerStorage.Rooms.<Model> with PrimaryPart, Attachments "Entrance" and "Exit"
-- on the PrimaryPart, attributes Weight (number), MinIndex (number, optional).
-- Workspace.StartRoom has an attachment "Exit". Each room has a trigger part "EnterTrigger".
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local TEMPLATES = ServerStorage:WaitForChild("Rooms"):GetChildren()
local KEEP_BEHIND, BUILD_AHEAD, MAX_TRIES = 2, 2, 8
local rng = Random.new(os.time()) -- store the seed if you want replays/debugging

local roomsFolder = Instance.new("Folder"); roomsFolder.Name = "GeneratedRooms"; roomsFolder.Parent = workspace
local rooms: { Model } = {}
local nextIndex = 1
local lastExit: Attachment = workspace:WaitForChild("StartRoom"):FindFirstChild("Exit", true)
local furthestEntered = 0

local function pickTemplate(index: number): Model
	local pool, total = {}, 0
	for _, t in TEMPLATES do
		if index >= (t:GetAttribute("MinIndex") or 0) then
			local w = t:GetAttribute("Weight") or 1
			total += w
			table.insert(pool, { t = t, w = w })
		end
	end
	local roll = rng:NextNumber() * total
	for _, e in pool do
		roll -= e.w
		if roll <= 0 then return e.t end
	end
	return pool[#pool].t
end

-- Align: new room's Entrance must sit on lastExit, facing the opposite way.
local function placeRoom(room: Model, exitAtt: Attachment)
	local entrance = room.PrimaryPart:FindFirstChild("Entrance") :: Attachment
	local target = exitAtt.WorldCFrame * CFrame.Angles(0, math.pi, 0) -- face back into new room
	-- pivot offset from entrance to model pivot
	local entranceToPivot = entrance.WorldCFrame:ToObjectSpace(room:GetPivot())
	room:PivotTo(target * entranceToPivot)
end

local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include

local function overlapsExisting(room: Model): boolean
	overlapParams.FilterDescendantsInstances = { roomsFolder }
	local cf, size = room:GetBoundingBox()
	local hits = workspace:GetPartBoundsInBox(cf, size - Vector3.new(1, 1, 1), overlapParams) -- shrink to ignore shared walls
	for _, part in hits do
		if not part:IsDescendantOf(room) then return true end
	end
	return false
end

local function onEnter(index: number)
	if index <= furthestEntered then return end
	furthestEntered = index
	-- build ahead
	while nextIndex <= furthestEntered + BUILD_AHEAD do
		local built = false
		for _ = 1, MAX_TRIES do
			local room = pickTemplate(nextIndex):Clone()
			placeRoom(room, lastExit)
			room.Parent = roomsFolder
			if overlapsExisting(room) then
				room:Destroy() -- e.g. a turn would loop into an older room; try another template
			else
				room.Name = "Room" .. nextIndex
				room:SetAttribute("Index", nextIndex)
				-- door number sign
				local sign = room:FindFirstChild("DoorSign", true)
				if sign and sign:FindFirstChildOfClass("SurfaceGui") then
					local label = sign:FindFirstChildOfClass("SurfaceGui"):FindFirstChildOfClass("TextLabel")
					if label then label.Text = string.format("%03d", nextIndex) end
				end
				local trigger = room:FindFirstChild("EnterTrigger", true) :: BasePart?
				if trigger then
					local idx = nextIndex
					trigger.Touched:Connect(function(hit)
						if Players:GetPlayerFromCharacter(hit.Parent) then onEnter(idx) end
					end)
				end
				lastExit = room.PrimaryPart:FindFirstChild("Exit") :: Attachment
				table.insert(rooms, room)
				nextIndex += 1
				built = true
				break
			end
		end
		if not built then
			warn("RoomGenerator: no template fits at", nextIndex, "- add a straight 'fallback' room")
			break
		end
	end
	-- clean up behind (only rooms no player is in)
	while #rooms > 0 and rooms[1]:GetAttribute("Index") < furthestEntered - KEEP_BEHIND do
		table.remove(rooms, 1):Destroy()
	end
end

onEnter(0) -- prebuild first rooms
```

Design notes for door-room games:
- Mix room tags so the rhythm alternates: hallway (rest) → puzzle → hallway → encounter → reward room every ~10. Enforce with rules ("no two encounter rooms in a row", "a shop room every 25 rooms ±3").
- Keep a straight **fallback template** with weight 0 that is always used when nothing fits.
- In multiplayer, clean up based on the *slowest* player's room, or teleport stragglers forward (a common "the door closes behind you" mechanic).

### 16.5 Obby checkpoint / stage system

```lua
-- ServerScriptService/ObbyStages (Script)
-- Workspace.Checkpoints contains Parts named "1", "2", ... (pad tops, Anchored, CanCollide).
-- Kill parts are tagged "Kill" with CollectionService.
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local DataStoreService = game:GetService("DataStoreService")

local store = DataStoreService:GetDataStore("ObbyProgress_v1")
local checkpoints = workspace:WaitForChild("Checkpoints")
local MAX_STAGE = #checkpoints:GetChildren()

local function getCheckpoint(stage: number): BasePart?
	return checkpoints:FindFirstChild(tostring(stage)) :: BasePart?
end

local function spawnAt(player: Player, character: Model)
	local stage = player.leaderstats.Stage.Value
	local cp = getCheckpoint(stage) or getCheckpoint(1)
	if not cp then return end
	local root = character:WaitForChild("HumanoidRootPart", 5)
	if root then
		task.defer(function() -- after default spawn positioning
			character:PivotTo(cp.CFrame * CFrame.new(0, cp.Size.Y / 2 + 3, 0))
		end)
	end
end

Players.PlayerAdded:Connect(function(player)
	local ls = Instance.new("Folder"); ls.Name = "leaderstats"; ls.Parent = player
	local stage = Instance.new("IntValue"); stage.Name = "Stage"; stage.Value = 1; stage.Parent = ls

	local ok, saved = pcall(store.GetAsync, store, tostring(player.UserId))
	if ok and typeof(saved) == "number" then stage.Value = math.clamp(saved, 1, MAX_STAGE) end

	player.CharacterAdded:Connect(function(char) spawnAt(player, char) end)
	if player.Character then spawnAt(player, player.Character) end
end)

Players.PlayerRemoving:Connect(function(player)
	local ls = player:FindFirstChild("leaderstats")
	if ls then
		pcall(store.SetAsync, store, tostring(player.UserId), ls.Stage.Value)
	end
end)

game:BindToClose(function()
	for _, p in Players:GetPlayers() do
		pcall(store.SetAsync, store, tostring(p.UserId), p.leaderstats.Stage.Value)
	end
end)

-- Checkpoints: only advance by exactly +1 (no skipping by flinging to later pads)
for _, cp in checkpoints:GetChildren() do
	local n = tonumber(cp.Name)
	if cp:IsA("BasePart") and n then
		cp.Touched:Connect(function(hit)
			local char = hit.Parent
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local player = Players:GetPlayerFromCharacter(char)
			if not (player and hum and hum.Health > 0) then return end
			local stage = player.leaderstats.Stage
			if n == stage.Value + 1 then
				stage.Value = n
				-- feedback: sound/particles on the pad (client-side via RemoteEvent is nicer)
			end
		end)
	end
end

-- Kill bricks
local function hookKill(part: BasePart)
	part.Touched:Connect(function(hit)
		local hum = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health > 0 then hum.Health = 0 end
	end)
end
for _, p in CollectionService:GetTagged("Kill") do hookKill(p) end
CollectionService:GetInstanceAddedSignal("Kill"):Connect(hookKill)

Players.RespawnTime = 1.5 -- fast retries
```

---

## 17. Spawning systems

| Spawn type | Pattern |
|---|---|
| Player spawn | `SpawnLocation`s (`Neutral`/`TeamColor`). For custom logic, set `Players.CharacterAutoLoads` normally and `PivotTo` on `CharacterAdded` (see §6.3, §16.5) |
| Enemy spawners | Spawner parts tagged `EnemySpawner` with attributes `EnemyType`, `MaxAlive`, `RespawnDelay`, `ActivationRadius` |
| Pickups or resources | Fixed nodes with respawn timers, keeping density about constant |
| Wave spawns | Data table of waves `{ {type="Slime", count=5, delay=1}, ... }` |
| Event spawns | Server-wide timed events (boss every 30 min) announced 1 min ahead |

Rules:
- **Never spawn enemies in view of players** (raycast or distance check ≥ 40 studs, or behind them) or on top of them.
- **Activate spawners only near players** (distance check). Despawn far-away idle NPCs to save server CPU.
- **Cap totals** (global and per spawner). Use object pooling (reparent to `ServerStorage` instead of Destroy/Clone churn) for high-frequency spawns.
- Scale difficulty with player count (enemies × 1 + 0.5 × (players − 1)).

Spawner loop sketch: every `RespawnDelay` seconds, prune dead entries from the spawner's `alive` list; if `#alive < MaxAlive`, a player is within `ActivationRadius` and **no** player is within 30 studs, clone the template from `ServerStorage.Enemies`, `PivotTo` a jittered offset of the spawner, parent it to `workspace`, and `Destroy` it 3 s after `Humanoid.Died`.

---

## 18. Day/night and weather as level design

The lighting chapter covers the visual setup. Here is the **gameplay** role:
- **Day/night changes the level**: nocturnal enemies, glowing collectibles visible only at night, shops closed at night, and safe lit roads versus dark woods.
- A cycle of **10–20 real minutes** per in-game day works well. Players should see a full cycle in one session.
- **Weather as pacing**: a storm event raises intensity (lightning hazard, reduced visibility, rare drops), then clears (rest).
- **Announce changes** ("Night falls... the Glowmoths are out!") so players can plan.

Implementation: a server `Heartbeat` loop advances `Lighting.ClockTime` by `dt * 24 / DAY_LENGTH_SECONDS` and sets `workspace:SetAttribute("IsNight", ClockTime < 6 or ClockTime >= 18)` only when the phase flips.

Systems read `workspace:GetAttribute("IsNight")` or connect `workspace:GetAttributeChangedSignal("IsNight")`. Setting `ClockTime` on the server replicates to clients. For smoother visuals, some games set it client-side from a shared server timestamp (`workspace:GetServerTimeNow()`).

---

## 19. Zone streaming with StreamingEnabled

From the Creator Docs (`workspace/streaming`):

| Property | Meaning | Recommendation |
|---|---|---|
| `Workspace.StreamingEnabled` | Instance streaming on or off | **On** for anything big or mobile-heavy |
| `Workspace.StreamingTargetRadius` | Max distance content streams in | Default **1024** recommended |
| `Workspace.StreamingMinRadius` | Never streamed out inside this radius. Content near the player is prioritised | Less than the target radius (leave a buffer) |
| `Workspace.StreamOutBehavior` | `LowMemory` (default) or `Opportunistic` | **Opportunistic** to reduce memory and crashes |
| `Workspace.ModelStreamingBehavior` | `Legacy` / `Improved` | Improved for new games (models stream with their parts more sensibly) |
| `Model.ModelStreamingMode` | `Nonatomic` (default), `Atomic`, `Persistent`, `PersistentPerPlayer` | `Atomic` for things client scripts read whole. `Persistent` *rarely* |
| `Workspace.PersistentLoaded` | Fires once persistent models have arrived | Wait on it in client code that needs persistent models |
| `Player:RequestStreamAroundAsync(pos)` | Ask the server to stream an area before teleporting a player there | Call before `PivotTo`-teleporting into far zones |

Level design implications:
- **Design zones as bubbles about 1,000 studs apart** with transition corridors or portals, so the far zone streams in during the walk. For long teleports, call `RequestStreamAroundAsync` first and show a short fade.
- **Landmarks must survive streaming**: either keep them in range, or use low-detail stand-ins. Models can stream as low-detail imposters with `Model.LevelOfDetail` (`StreamingMesh`) for far views. Check the current docs for availability.
- **Client scripts must not assume parts exist**: use `WaitForChild(name, timeout)`, `CollectionService:GetInstanceAddedSignal`, and handle `GetInstanceRemovedSignal` for parts that stream out.
- **Server-side NPC pathfinding** sees the full world (fine). Client-side pathfinding or Beams to unloaded targets fail, so point them at Persistent anchors or positions.
- Keep the **spawn zone's essentials** (shops, the first quest NPC, portals) close together so they load immediately on join.
- Interiors behind doors and teleports reduce how much is in streaming range at once (classic "pocket interiors" below or above the map).

---

## 20. Pre-ship level checklist

**Flow and teaching**
- [ ] Golden path playable start to finish with no dead ends (or every dead end rewards)
- [ ] Each new mechanic follows introduce → develop → twist → conclude
- [ ] The first exposure to every hazard is safe
- [ ] Beat chart has rest valleys after every peak

**Metrics**
- [ ] `UseJumpPower`, `JumpHeight`/`JumpPower`, `WalkSpeed`, `Gravity` set explicitly and documented
- [ ] No required gap over 8 studs (JumpHeight 7.2), no required climb over 6.5
- [ ] Doors ≥ 4×7 (preferably 6×9), multiplayer corridors ≥ 12 wide

**Wayfinding**
- [ ] A global landmark visible from spawn; a local landmark per zone
- [ ] Consistent colour language (kill = red/neon, checkpoint = green, interact = one accent)
- [ ] Objective markers or Beam guides for quests; signs ≤ 5 words

**Hub**
- [ ] Spawn faces the core activity; first action within 5 s of walking
- [ ] Shop and quests on the main path; locked zones visible with price
- [ ] No hazards or PvP at spawn

**Multiplayer**
- [ ] Map size matches player count (§5)
- [ ] PvP spawns out of sight with protection; at least 2 routes at every choke
- [ ] Server validates gates, checkpoints, dialogue choices, quest progress

**NPCs and systems**
- [ ] Pathfinding uses pcall, handles Blocked, repaths, and recovers from stuck
- [ ] NPC root network owner set to nil
- [ ] Spawners respect caps and activation radius and never spawn in view

**Narrative**
- [ ] Every area answers "what happened here?" visually
- [ ] Dialogue ≤ 25 words per node with a "Bye" option; quest text verb-first
- [ ] Cutscenes ≤ 10 s on first join and skippable

**Performance**
- [ ] StreamingEnabled on for big worlds; client scripts tolerate missing parts
- [ ] Playtested with 2+ players on a mobile emulator and on a low-end device

---

## Sources

Local official docs (Roblox Creator Docs mirror, `/home/user/Roblox/reference/creator-docs/content/en-us`):
- `characters/pathfinding.md`: agent parameters (AgentRadius 2, AgentHeight 5, AgentCanJump, AgentCanClimb, WaypointSpacing 4, Costs), PathfindingModifier (Label, PassThrough), PathfindingLink, Path.Blocked, streaming compatibility, limits (3,000 studs, 20,000 nodes)
- `workspace/streaming/index.md`, `techniques.md`: StreamingTargetRadius (1024 recommended), StreamingMinRadius, StreamOutBehavior (Opportunistic recommended), ModelStreamingMode (Atomic/Persistent/PersistentPerPlayer), PersistentLoaded
- `reference/engine/classes/Humanoid.yaml`: WalkSpeed 16, JumpHeight, JumpPower, UseJumpPower, MaxSlopeAngle, MoveTo
- `reference/engine/classes/StarterPlayer.yaml`: CharacterJumpHeight 7.2, CharacterJumpPower 50, CharacterMaxSlopeAngle 89, CharacterUseJumpPower
- `reference/engine/classes/Workspace.yaml`: Gravity 196.2 studs/s²
- `reference/engine/classes/ProximityPrompt.yaml`, `Beam.yaml`, `Path.yaml`, `PathfindingModifier.yaml`, `PathfindingLink.yaml`

Web (treated as data):
- Kishōtenketsu / Koichi Hayashida: [Koichi Hayashida (Wikipedia)](https://en.wikipedia.org/wiki/Koichi_Hayashida); [MCV/Develop: Nintendo's level design secrets in four steps (Game Maker's Toolkit)](https://www.mcvuk.com/development/video-nintendos-level-design-secrets-in-four-steps); [Engadget: Why Mario levels are brilliant](https://www.engadget.com/2015/03/17/super-mario-3d-world-design/)
- Weenies and theme-park design: [Boing Boing: Scott Rogers' GDC 2009 Disneyland level design slides](https://boingboing.net/2009/03/27/gamedesign-lessons-f.html/amp); [Venus Patrol: What Disneyland can teach you about game design](https://venuspatrol.com/2009/08/gdc-slides-what-disneyland-can); [craphound.com talk notes](https://craphound.com/disneylandleveldesign.txt)
- Brian Upton (Lynch's paths/edges/districts/nodes/landmarks): [Game Developer: Post-GDC — Rainbow Six's Upton talks landscaping game worlds](https://gamedeveloper.com/game-platforms/post-gdc-i-rainbow-six-i-s-upton-talks-landscaping-game-worlds)
- Wayfinding: [GDC Vault: Level Design in a Day — Wayfinding & Storytelling Techniques (Brendon Chung)](https://gdcvault.com/play/1022117/Level-Design-in-a-Day); [Various Uses of Landmarks in Level Design](https://tancoque.design.blog/)
- Procedural rooms: [DevForum: Dungeon Generation — A Procedural Generation Guide](https://devforum.roblox.com/t/dungeon-generation-a-procedural-generation-guide/342413); [DevForum: Problem with room generation](https://devforum.roblox.com/t/problem-with-room-generation/3971134); [DevForum: Feedback on random room generation](https://devforum.roblox.com/t/feedback-on-random-room-generation/2025377); [DevForum: Infinite room generator](https://devforum.roblox.com/t/2002626)
Computed values: jump distances derived from v₀ = √(2gh) with g = 196.2, WalkSpeed = 16 (Python check, 2026-11-05). Edge-to-edge gaps include a footprint estimate, so verify in Studio with the §2.4 snippet.
