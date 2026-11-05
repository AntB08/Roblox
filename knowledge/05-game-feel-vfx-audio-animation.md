# 05: Game feel, VFX, audio, animation and camera

What this chapter covers: making a Roblox game feel good to touch. That means juice principles, particle and lighting effects, tweens and springs, camera work, character animation, the new Audio API, music, haptics and performance budgets. It ends with six complete Luau modules you can paste in.

Docs snapshot: 2026-11-05. Every class, property, enum and method name in this file was checked against `reference/creator-docs/content/en-us/reference/engine/classes/*.yaml` and `enums/*.yaml`. Where a fact comes from the community and not the official docs, the text says so. Before you use an API this chapter does not show, look it up: `scripts/kb_search.sh "<name>" api`.

---

## TL;DR rules for the bot

1. **Every player action gets feedback within 1 frame (up to about 50 ms).** Each one needs at least 2 of these channels: visual (particle, tween, flash), audio, camera, haptic, UI number. If a click, hit, pickup or purchase has no feedback, it is a bug.
2. **Cosmetics run on the client.** The server decides that something happened and tells clients, using `UnreliableRemoteEvent` for pure cosmetics and `RemoteEvent` when the message must arrive. Each client then renders particles, shakes, sounds and numbers. Never run screen shake, hitstop or UI tweens on the server.
3. **Structure each effect as anticipation, impact, follow-through.** Wind-up is 80–200 ms. The impact frame gets hitstop (30–120 ms), a white flash, shake, a sound transient and a particle burst. Follow-through is 300–800 ms of smoke, embers, popups and recovery animation.
4. **Shake with Perlin noise driven by a decaying "trauma" value, rotation first.** Never use `math.random` every frame. Scale shake by distance. Respect `GuiService.ReducedMotionEnabled` and give players a shake slider.
5. **Use bursts, not floods.** For one-shot effects, set `ParticleEmitter.Enabled = false` and call `:Emit(n)`. Keep `Rate` low. The engine caps an emitter at 400 particles/s, or 100/s on mobile. Wait one frame after parenting a new emitter before you call `:Emit`.
6. **Layer every effect.** A good hit is flash + sparks + smoke + light + sound + shake. Three cheap layers beat one expensive layer.
7. **Use the new Audio API for new work.** That means `AudioPlayer`, then `Wire`, then `AudioFader`/effects, then `AudioEmitter`/`AudioDeviceOutput`. The docs now discourage `Sound`, `SoundGroup` and `SoundEffect`. Legacy `Sound` still works and is fine for quick one-shots.
8. **Music rules (user preference):** instrumental only, with no vocals, choir, humming or vocal chops unless the user asks. Music loops seamlessly via `AudioPlayer.Looping = true` plus `LoopRegion`. Songs change by crossfade, never by hard cut. Music sits well under SFX, at a bus volume around 0.3–0.5. SFX are non-vocal as well: no grunts or voice barks by default.
9. **Only use audio you have rights to.** That means the Creator Store audio library (Roblox-licensed tracks from partners and Roblox) or audio the user made or owns. Never upload commercial songs. Asset privacy means an uploaded audio ID only plays in experiences that have been granted permission.
10. **Use AnimationTrack priorities correctly.** Idle → `Idle`, locomotion → `Movement`, attacks and emotes → `Action`, layered overrides → `Action2..4`. Use `GetMarkerReachedSignal` to sync hit frames, footsteps and VFX to animation. `KeyframeReached` is deprecated.
11. **Tween UI and props with `TweenService`. Use springs for anything that gets interrupted** (camera offsets, recoil, hover bob, UI that follows the cursor).
12. **Budgets for phones (see §11):** about 6 or fewer shadow-casting dynamic lights near the camera, a few hundred particles on screen, small textures, few flipbooks. Reuse `Highlight` instances; don't create and destroy them.
13. **Pool and clean up.** Every spawned FX instance gets `Debris:AddItem` or goes back to a pool. Leaked attachments and emitters are a common late-game lag source.
14. **Verify by playing** in Studio on the Phone/Tablet device emulator with a low graphics level. Effects that look fine at quality 10 can be invisible or overwhelming at quality 1.

---

## 1. Juice principles, translated to Roblox

"Juice" means a lot of feedback for a small input. Two talks set the canon. In *Juice It or Lose It* (Martin Jonasson and Petri Purho, 2012), a dull Breakout clone becomes delightful through tweens, squash, particles, sound and screen shake, with no rule changes at all. In *The Art of Screenshake* (Jan Willem Nijman, Vlambeer, 2013), a bland top-down shooter is improved one tweak at a time: bigger bullets, muzzle flash, faster bullets, less accuracy, impact effects, hit pause, screen shake, knockback, permanence (corpses and shells that stay), camera lerp toward the aim direction, and sound. Squirrel Eiserloh's GDC 2016 talk *Juicing Your Cameras With Math* added the "trauma" model for shake (shake = trauma² with Perlin noise) used in §6.

### 1.1 Feedback table: what each action needs

| Player action | Visual | Audio | Camera / haptic | UI |
|---|---|---|---|---|
| Button press (UI) | Scale 1 → 0.92 on press, 1.06 → 1 on release (Back, 0.12 s) | Soft click, pitch ±5% | `HapticEffect` `UIClick` (mobile) | none |
| Collect coin | Coin burst + sparkle, item pops (scale up, then shrink into player) | Bright "ding", pitch rises with combo | none | "+5" popup; counter bumps (scale 1.15 → 1) |
| Hit enemy | White flash 0.08 s, sparks, hit-direction knockback | Layered impact: transient + body + tail | Hitstop 40–90 ms, trauma +0.15–0.3, `GameplayCollision` | Damage number |
| Take damage | Red vignette pulse, character flash | Low thud, muffled lowpass 0.3 s | Trauma +0.3, haptic rumble | Health bar shakes, delayed "ghost" bar |
| Kill / break | Explosion layers, debris that stays a few seconds (permanence) | Big layered boom with tail | Trauma +0.5, `GameplayExplosion` | Combo / kill feed |
| Jump / land | Squash on land (camera dip 0.3 studs), dust ring | Footstep "land" variant | Small shake only on high falls | none |
| Sprint | FOV 70 → 80, speed lines, dust trail | Faster footsteps, wind loop fades in | none | Stamina bar |
| Level up | Pillar of light + rising sparkles + ring + Highlight pulse | Instrumental fanfare stinger; music ducks | Mild shake, haptic `UINotification` | Big banner with overshoot tween |
| Purchase | Confetti burst on the UI, item spins in | Cash register / chime | `UINotification` | Shop button pulse |

### 1.2 Timing cheat sheet (60 fps: 1 frame ≈ 16.7 ms)

| Element | Light | Medium | Heavy |
|---|---|---|---|
| Anticipation (wind-up) | 60–100 ms | 120–200 ms | 250–400 ms (telegraphed boss attack) |
| Hitstop | 2–3 frames (35–50 ms) | 4–5 frames (70–85 ms) | 6–8 frames (100–130 ms) |
| Flash | 50 ms | 80 ms | 120 ms |
| Shake trauma added | 0.1–0.2 | 0.3–0.4 | 0.6–1.0 |
| Shake decay | 1.5/s | 1.2/s | 0.8/s |
| Popup life | 0.5 s | 0.7 s | 1.0 s (crit) |
| UI pop scale | 1.08 | 1.15 | 1.3 |

Rules of thumb:
- **Don't hitstop every bullet.** For rapid-fire weapons, hitstop only on kills or crits, or cap it at one per 150 ms.
- **Vary the feedback.** Randomize pitch (±5–10%), volume (±10%), particle rotation, and number positions (±0.5 studs). The same sample played identically 20 times sounds like a machine gun of clicks.
- **Scale feedback with importance.** If a coin pickup is louder than a boss kill, the hierarchy is broken.
- **Permanence:** let shells, scorch decals and debris stay 5–20 s, using a pool with a cap. It makes the world remember the player.
- **Squash and stretch:** squash a model on landing by tweening a scale. For models, use `Model:ScaleTo()` carefully, or better, animate a visual-only mesh. For UI, use a `UIScale`. Preserve volume: when Y goes to 0.8, X/Z go to 1.12.
- **Easing:** almost nothing in juice is `Linear`. Use `Quad`/`Cubic` `Out` for things arriving, `In` for things leaving, `Back` `Out` for UI pops, and `Elastic` sparingly (only for cartoony bounces).

### 1.3 The cosmetic replication pattern

```lua
-- ServerScriptService/Combat.server.luau (excerpt)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FxEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("FxEvent") :: UnreliableRemoteEvent

local function applyHit(attacker: Player, victimModel: Model, damage: number, isCrit: boolean)
	-- authoritative damage happens here first (validated!)
	local root = victimModel:FindFirstChild("HumanoidRootPart") :: BasePart?
	if root then
		-- fire to everyone; each client decides how much FX to show (distance, quality)
		FxEvent:FireAllClients("Hit", victimModel, root.Position, damage, isCrit, attacker.UserId)
	end
end
```

```lua
-- StarterPlayerScripts/FxClient.client.luau (excerpt)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FxEvent = ReplicatedStorage.Remotes.FxEvent :: UnreliableRemoteEvent
local DamageNumbers = require(ReplicatedStorage.Shared.DamageNumbers)
local HitFeedback = require(ReplicatedStorage.Shared.HitFeedback)

FxEvent.OnClientEvent:Connect(function(kind: string, model: Model, pos: Vector3, amount: number, crit: boolean, attackerId: number)
	if kind == "Hit" then
		local mine = attackerId == Players.LocalPlayer.UserId
		DamageNumbers.Show(pos, amount, crit)
		HitFeedback.Hit(model, if mine then Players.LocalPlayer.Character else nil, if crit then 1.5 else 1)
	end
end)
```

`UnreliableRemoteEvent` messages can be dropped or arrive out of order, and payloads are size-limited. Use it for things that don't matter if missed, like VFX. Use `RemoteEvent` for things that must arrive, like "you leveled up".

---

## 2. VFX building blocks: property reference

### 2.1 ParticleEmitter

An emitter must be parented to a `BasePart`, where particles spawn within the part's volume or surface according to `Shape`, or to an `Attachment` inside a part or `Terrain`, where they spawn at the attachment's point.

| Property | Type | What it does / good values |
|---|---|---|
| `Enabled` | bool | Continuous emission at `Rate`. Set to `false` for burst-only emitters. |
| `Rate` | number | Particles/second. Cap: 400/s (100/s on mobile). Keep ambient effects under 20. |
| `Lifetime` | NumberRange | Seconds. Bursts 0.3–1.0, smoke 1.5–4. |
| `Speed` | NumberRange | Studs/s at spawn. |
| `SpreadAngle` | Vector2 | Cone around the emission direction in degrees; (180,180) = all directions. |
| `EmissionDirection` | NormalId | Face that particles leave from (`Top` for upward). |
| `Shape` | ParticleEmitterShape | `Box`, `Sphere`, `Cylinder`, `Disc`. Applies only when parented to a part. |
| `ShapeStyle` | ParticleEmitterShapeStyle | `Volume` or `Surface`. |
| `ShapeInOut` | ParticleEmitterShapeInOut | Outward / inward / both from the shape. |
| `ShapePartial` | number 0–1 | Fraction of the shape used (e.g. a ring = Disc + partial). |
| `Acceleration` | Vector3 | Studs/s², e.g. gravity `(0,-30,0)`, smoke rise `(0,3,0)`. |
| `Drag` | number | Exponential slowdown; 2–6 makes bursts "pop then hang". |
| `VelocityInheritance` | number | Fraction of the parent's velocity inherited (0.2–0.5 for trails off moving things). |
| `LockedToPart` | bool | Particles move rigidly with the parent (auras, shields). |
| `Size` | NumberSequence | Size over life in studs. Fill-rate cost grows with screen area. |
| `Squash` | NumberSequence | Non-uniform scale: >0 tall/thin, <0 wide/flat. Use for streaks and rain. |
| `Transparency` | NumberSequence | 0 visible → 1 invisible. Fade in briefly and fade out at the end. |
| `Color` | ColorSequence | Colour over life. |
| `LightEmission` | number 0–1 | Additive blending. 1 = glowy (fire, magic), 0 = normal alpha (smoke, dust). |
| `LightInfluence` | number 0–1 | How much world lighting affects particles. 0 for glows, 1 for smoke and dust. |
| `Brightness` | number | Scales emitted light when `LightInfluence` is 0. 1–5 for bright magic. |
| `Orientation` | ParticleOrientation | `FacingCamera`, `FacingCameraWorldUp`, `VelocityParallel` (sparks, streaks), `VelocityPerpendicular` (ground rings and shockwaves; needs some speed). |
| `Rotation` / `RotSpeed` | NumberRange | Initial angle and spin in degrees and degrees/s. Randomize so particles don't look stamped. |
| `ZOffset` | number | Render sort offset toward the camera. Use 0.5–2 so a flash draws over smoke. |
| `TimeScale` | number 0–1 | Slows the whole simulation. 0 freezes it; useful for hitstop. |
| `WindAffectsDrag` | bool | Particles follow `Workspace.GlobalWind` (scaled by drag). |
| `Texture` / `TextureContent` | ContentId / Content | The image. `TextureContent` is the newer Content-typed version. |
| `FlipbookLayout` | ParticleFlipbookLayout | `None`, `Grid2x2`, `Grid4x4`, `Grid8x8`, `Custom` (+ `FlipbookSizeX/Y`). |
| `FlipbookMode` | ParticleFlipbookMode | `Loop`, `OneShot` (plays once over lifetime: explosions), `PingPong`, `Random`. |
| `FlipbookFramerate` | NumberRange | Frames/s for Loop/PingPong. |
| `FlipbookStartRandom` | bool | Random starting frame. |
| `FlipbookBlendFrames` | bool | Cross-blend frames (smoother, slightly blurrier). |
| `VelocitySpread` | — | **Deprecated**, use `SpreadAngle`. |

Methods: `:Emit(count)` spawns `count` particles immediately. `:Clear()` removes all live particles.

Flipbook notes: textures are 2×2, 4×4, 8×8 or custom grids, for example a 1024×1024 sheet with 8×8 frames of 128 px. Leave transparent padding around each frame or mip filtering will bleed between frames. Flipbooks use memory, and low-memory clients (older phones) disable them automatically, so the effect must still read with a static first frame. Reuse the same few sheets.

Built-in textures: a new emitter defaults to the engine sparkle texture. For smoke, fire, coins and so on, make original textures: a soft radial gradient, a 4-point star, a coin icon, a ring, a spark streak. Upload them as Decals/Images, or generate them with the asset tools described in `08-bot-toolchain-and-workflow.md`. A 64–256 px white-on-transparent texture tinted through `Color` covers most needs.

### 2.2 Beam, Trail, Attachment

**Attachment** is a point-and-orientation in a part (`Position`, `Orientation`, `CFrame`, `WorldPosition`, `WorldCFrame`, `Axis`, `SecondaryAxis`, `Visible`). Every Beam and Trail needs two of them. Attachments can be parented to `Workspace.Terrain` for world-space FX anchors, which is the standard trick for spawning an effect at a raw `Vector3`.

**Beam** draws a textured ribbon between `Attachment0` and `Attachment1`, optionally curved by a Bézier.

| Property | Notes |
|---|---|
| `Attachment0`, `Attachment1` | Endpoints. |
| `Width0`, `Width1` | Width at each end (studs). Lasers 0.2–0.6. |
| `CurveSize0`, `CurveSize1` | Bézier handle lengths along each attachment's axis. Use for arcs and lightning wobble. |
| `Segments` | Default 10. Raise only for curved beams; keep straight beams low. |
| `Texture`, `TextureLength`, `TextureMode` | `TextureMode` `Wrap` (repeat every `TextureLength` studs), `Stretch`, `Static`. |
| `TextureSpeed` | Scroll speed. Energy flowing 1–4. |
| `Color`, `Transparency` | Sequences along the length. |
| `LightEmission`, `LightInfluence`, `Brightness` | Same meaning as particles. |
| `FaceCamera` | Always face the camera (good for lasers seen from all sides). |
| `ZOffset`, `Enabled` | none |
| `:SetTextureOffset(offset)` | Manually shift the texture. |

Uses: lasers, tractor beams, grappling ropes, lightning (several beams with random `CurveSize` refreshed every 0.05 s), god-rays, quest waypoints (a beam from the player to the objective with a scrolling arrow texture).

**Trail** leaves a ribbon behind two moving attachments.

| Property | Notes |
|---|---|
| `Attachment0`, `Attachment1` | Their separation sets trail width (e.g. two attachments 2 studs apart on a sword). |
| `Lifetime` | Seconds a segment lives: swords 0.15–0.3, dash 0.3–0.5, projectile 0.2. |
| `MinLength`, `MaxLength` | Minimum segment length before a new segment is added; MaxLength caps total length (0 = unlimited). |
| `WidthScale` | NumberSequence over the trail's length (taper 1 → 0). |
| `Color`, `Transparency` | Sequences over the trail's length (from newest to oldest). |
| `FaceCamera`, `LightEmission`, `LightInfluence`, `Brightness`, `Texture`, `TextureLength`, `TextureMode` | none |
| `:Clear()` | Wipe the trail, e.g. after a teleport so it doesn't streak across the map. |

Enable a sword trail only during the swing (`Enabled = true` at the "SwingStart" marker, `false` at "SwingEnd") so it doesn't smear during idle.

### 2.3 Highlight

| Property | Notes |
|---|---|
| `Adornee` | Model or part to highlight (defaults to its parent). |
| `FillColor`, `FillTransparency` | Inner tint. Hit flash: white, transparency 0 → 1. |
| `OutlineColor`, `OutlineTransparency` | Outline. Selection/interact prompt: white outline, fill 1. |
| `DepthMode` | `AlwaysOnTop` (through walls: teammates, objectives) or `Occluded`. |
| `Enabled` | Toggle this instead of creating and destroying the instance. |

Performance (official): at most **255** highlights display on a client at once; extras are silently ignored. Adding or removing a Highlight rebuilds geometry and can spike. **Change properties instead** (cheap). The first visible highlight costs the most (up to about 1 ms GPU on mobile), and on mobile cost scales with screen coverage. Disabled or fully transparent highlights cost nothing. Don't nest highlighted objects inside other highlighted objects.

### 2.4 Lights

All lights inherit `Light`: `Brightness`, `Color`, `Enabled`, `Shadows`.

| Class | Extra properties | Use |
|---|---|---|
| `PointLight` | `Range` (studs, engine max 60) | Torches, pickups, explosion flash. Parent to an Attachment for a precise origin. |
| `SpotLight` | `Range`, `Angle` (0–180), `Face` | Flashlights, stage lights. |
| `SurfaceLight` | `Range`, `Angle`, `Face` | Screens, signs, glowing panels. |

Brightness is still limited to `Range`: raising Brightness makes the lit area hotter, not bigger. `Shadows = true` is the expensive part. Keep shadows on a few hero lights only and **never** on short-lived FX flashes. Explosion flash recipe: `PointLight` with Brightness 8, Range 16, Color (255,170,80), tween Brightness to 0 over 0.25 s (Quad Out), then destroy.

For glow without a light, use `Material = Neon` parts, or particles with `LightEmission = 1`, combined with a `BloomEffect` in Lighting (see chapter 02).

### 2.5 Legacy Fire, Smoke, Sparkles

`Fire` (`Color`, `SecondaryColor`, `Heat`, `Size`, `TimeScale`, `Enabled`) and `Smoke` (`Color`, `Opacity`, `RiseVelocity`, `Size`, `TimeScale`, `Enabled`) are one-instance effects from the old engine. They are fine for a quick prototype or a background torch, but you can't tune shape, texture or bursts. For anything the player looks at, build ParticleEmitter recipes (§3). Don't use `Explosion` instances for visuals in new games. Build layered explosions and apply knockback yourself on the server.

---

## 3. Particle recipes (exact values)

These are plain property tables you can apply with a helper. Values assume a 1-stud ≈ 0.28 m human scale (character ~5 studs tall). Scale `Size`, `Speed` and `Acceleration` together to resize an effect. `TEX.*` are placeholders for your own uploaded textures; the default sparkle texture works for anything marked "(default ok)".

```lua
-- ReplicatedStorage/Shared/FxRecipes.luau
--!strict
local NS, NSK = NumberSequence.new, NumberSequenceKeypoint.new
local CS, CSK = ColorSequence.new, ColorSequenceKeypoint.new
local NR = NumberRange.new

local TEX = {
	Sparkle = "", -- "" keeps the engine default sparkle texture
	Soft = "rbxassetid://0",   -- REPLACE: soft round radial gradient (white)
	Smoke = "rbxassetid://0",  -- REPLACE: wispy smoke puff (white)
	Flame = "rbxassetid://0",  -- REPLACE: flame tongue, optional 4x4 flipbook
	Coin = "rbxassetid://0",   -- REPLACE: your original coin/gem icon
	Spark = "rbxassetid://0",  -- REPLACE: thin horizontal streak
	Ring = "rbxassetid://0",   -- REPLACE: thin white ring
	Star = "rbxassetid://0",   -- REPLACE: 4-point star
}

local R = {}

-- 1) Ambient sparkles on a collectible (continuous, cheap)
R.Sparkles = {
	Texture = TEX.Sparkle, Enabled = true, Rate = 8,
	Lifetime = NR(0.6, 1.2), Speed = NR(0.5, 1.5), SpreadAngle = Vector2.new(180, 180),
	Size = NS({ NSK(0, 0), NSK(0.2, 0.35), NSK(1, 0) }),
	Transparency = NS({ NSK(0, 0.2), NSK(1, 1) }),
	Color = CS(Color3.fromRGB(255, 240, 170)),
	LightEmission = 1, LightInfluence = 0, Brightness = 2,
	Rotation = NR(0, 360), RotSpeed = NR(-90, 90), ZOffset = 0.5,
}

-- 2) Coin burst on pickup (Emit 20-30)
R.CoinBurst = {
	Texture = TEX.Coin, Enabled = false, Rate = 0,
	EmissionDirection = Enum.NormalId.Top,
	Lifetime = NR(0.6, 0.9), Speed = NR(18, 28), SpreadAngle = Vector2.new(35, 35),
	Acceleration = Vector3.new(0, -60, 0), Drag = 2,
	Size = NS({ NSK(0, 0.6), NSK(0.8, 0.6), NSK(1, 0) }),
	Transparency = NS(0),
	Rotation = NR(0, 360), RotSpeed = NR(-360, 360),
	LightEmission = 0.3, LightInfluence = 0.2,
}

-- 3) Smoke puff (Emit 6-10, or Rate 4-6 for a chimney)
R.Smoke = {
	Texture = TEX.Smoke, Enabled = false,
	Lifetime = NR(1.5, 2.5), Speed = NR(1, 3), SpreadAngle = Vector2.new(25, 25),
	EmissionDirection = Enum.NormalId.Top,
	Acceleration = Vector3.new(0, 2, 0), Drag = 1,
	Size = NS({ NSK(0, 1), NSK(1, 4) }),
	Transparency = NS({ NSK(0, 1), NSK(0.1, 0.45), NSK(1, 1) }),
	Color = CS(Color3.fromRGB(110, 110, 115)),
	LightEmission = 0, LightInfluence = 1,
	Rotation = NR(0, 360), RotSpeed = NR(-30, 30),
}

-- 4a) Fire core (continuous) - pair with 4b and a flickering PointLight
R.FireCore = {
	Texture = TEX.Flame, Enabled = true, Rate = 30,
	Lifetime = NR(0.4, 0.8), Speed = NR(2, 4), SpreadAngle = Vector2.new(10, 10),
	EmissionDirection = Enum.NormalId.Top, Acceleration = Vector3.new(0, 6, 0),
	Size = NS({ NSK(0, 1.2), NSK(1, 0.2) }),
	Transparency = NS({ NSK(0, 1), NSK(0.15, 0.2), NSK(1, 1) }),
	Color = CS({ CSK(0, Color3.fromRGB(255, 225, 130)), CSK(0.5, Color3.fromRGB(255, 120, 30)), CSK(1, Color3.fromRGB(120, 30, 10)) }),
	LightEmission = 1, LightInfluence = 0, Brightness = 2,
	Rotation = NR(-20, 20), RotSpeed = NR(-60, 60),
	-- if TEX.Flame is a 4x4 sheet: FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4, FlipbookMode = Enum.ParticleFlipbookMode.OneShot
}
-- 4b) Embers
R.Embers = {
	Texture = TEX.Soft, Enabled = true, Rate = 6,
	Lifetime = NR(1, 2), Speed = NR(3, 6), SpreadAngle = Vector2.new(30, 30),
	EmissionDirection = Enum.NormalId.Top, Acceleration = Vector3.new(0, 3, 0), Drag = 0.5,
	Size = NS({ NSK(0, 0.12), NSK(1, 0) }),
	Color = CS(Color3.fromRGB(255, 150, 50)), LightEmission = 1, LightInfluence = 0,
}

-- 5) Magic hit: three layers, all Emit-driven
R.MagicFlash = { -- Emit 1
	Texture = TEX.Soft, Enabled = false, Lifetime = NR(0.12), Speed = NR(0),
	Size = NS({ NSK(0, 0), NSK(0.3, 5), NSK(1, 6) }),
	Transparency = NS({ NSK(0, 0), NSK(1, 1) }),
	Color = CS(Color3.fromRGB(170, 140, 255)), LightEmission = 1, LightInfluence = 0,
	Brightness = 3, ZOffset = 1.5,
}
R.MagicSparks = { -- Emit 16
	Texture = TEX.Spark, Enabled = false, Lifetime = NR(0.25, 0.45), Speed = NR(25, 40),
	SpreadAngle = Vector2.new(180, 180), Drag = 6,
	Orientation = Enum.ParticleOrientation.VelocityParallel,
	Size = NS({ NSK(0, 0.35), NSK(1, 0) }), Squash = NS(-1.5),
	Color = CS(Color3.fromRGB(210, 190, 255)), LightEmission = 1, LightInfluence = 0, ZOffset = 1,
}
R.MagicRing = { -- Emit 1; flat on the ground because of VelocityPerpendicular + Top
	Texture = TEX.Ring, Enabled = false, Lifetime = NR(0.35), Speed = NR(0.01),
	EmissionDirection = Enum.NormalId.Top,
	Orientation = Enum.ParticleOrientation.VelocityPerpendicular,
	Size = NS({ NSK(0, 0.5), NSK(1, 8) }), Transparency = NS({ NSK(0, 0.2), NSK(1, 1) }),
	Color = CS(Color3.fromRGB(180, 150, 255)), LightEmission = 1, LightInfluence = 0,
}

-- 6) Dust trail (Rate driven by speed in script) / landing puff (Emit 10)
R.Dust = {
	Texture = TEX.Smoke, Enabled = false, Rate = 0,
	Lifetime = NR(0.5, 0.9), Speed = NR(1, 2), SpreadAngle = Vector2.new(60, 60),
	EmissionDirection = Enum.NormalId.Top, Acceleration = Vector3.new(0, 1, 0), Drag = 3,
	Size = NS({ NSK(0, 0.5), NSK(1, 2) }), Transparency = NS({ NSK(0, 0.5), NSK(1, 1) }),
	Color = CS(Color3.fromRGB(200, 180, 150)), -- re-tint from the floor colour at runtime
	LightEmission = 0, LightInfluence = 1, Rotation = NR(0, 360), RotSpeed = NR(-40, 40),
}

-- 7) Explosion: fireball + smoke + sparks + shockwave (+ PointLight flash, shake, sound)
R.ExplosionFire = { -- Emit 12
	Texture = TEX.Soft, Enabled = false, Lifetime = NR(0.35, 0.6), Speed = NR(6, 12),
	SpreadAngle = Vector2.new(180, 180), Drag = 4,
	Size = NS({ NSK(0, 2), NSK(1, 6) }),
	Transparency = NS({ NSK(0, 0), NSK(0.6, 0.3), NSK(1, 1) }),
	Color = CS({ CSK(0, Color3.fromRGB(255, 240, 180)), CSK(0.4, Color3.fromRGB(255, 140, 40)), CSK(1, Color3.fromRGB(90, 20, 10)) }),
	LightEmission = 1, LightInfluence = 0, Brightness = 2, ZOffset = 1, RotSpeed = NR(-90, 90), Rotation = NR(0, 360),
}
R.ExplosionSmoke = { -- Emit 10
	Texture = TEX.Smoke, Enabled = false, Lifetime = NR(1.5, 3), Speed = NR(4, 8),
	SpreadAngle = Vector2.new(180, 180), Drag = 2, Acceleration = Vector3.new(0, 3, 0),
	Size = NS({ NSK(0, 3), NSK(1, 9) }), Transparency = NS({ NSK(0, 0.3), NSK(1, 1) }),
	Color = CS(Color3.fromRGB(60, 60, 60)), LightEmission = 0, LightInfluence = 1,
	Rotation = NR(0, 360), RotSpeed = NR(-20, 20),
}
R.ExplosionSparks = { -- Emit 30
	Texture = TEX.Spark, Enabled = false, Lifetime = NR(0.5, 1.2), Speed = NR(40, 70),
	SpreadAngle = Vector2.new(180, 180), Drag = 3, Acceleration = Vector3.new(0, -40, 0),
	Orientation = Enum.ParticleOrientation.VelocityParallel,
	Size = NS({ NSK(0, 0.25), NSK(1, 0) }), Squash = NS(-2),
	Color = CS(Color3.fromRGB(255, 200, 120)), LightEmission = 1, LightInfluence = 0,
}
R.Shockwave = { -- Emit 1
	Texture = TEX.Ring, Enabled = false, Lifetime = NR(0.3), Speed = NR(0.01),
	EmissionDirection = Enum.NormalId.Top, Orientation = Enum.ParticleOrientation.VelocityPerpendicular,
	Size = NS({ NSK(0, 1), NSK(1, 18) }), Transparency = NS({ NSK(0, 0.3), NSK(1, 1) }),
	LightEmission = 1, LightInfluence = 0,
}

-- 8) Level-up column (emitter in an invisible 4x0.2x4 cylinder part at the feet; Enabled for 1.5 s)
R.LevelUpColumn = {
	Texture = TEX.Star, Enabled = false, Rate = 40,
	Shape = Enum.ParticleEmitterShape.Cylinder, ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface,
	EmissionDirection = Enum.NormalId.Top, Lifetime = NR(1, 1.5), Speed = NR(4, 8),
	Acceleration = Vector3.new(0, 4, 0),
	Size = NS({ NSK(0, 0.4), NSK(1, 0) }),
	Color = CS({ CSK(0, Color3.fromRGB(255, 215, 90)), CSK(1, Color3.fromRGB(255, 255, 255)) }),
	LightEmission = 1, LightInfluence = 0, Brightness = 2, Rotation = NR(0, 360), RotSpeed = NR(-180, 180),
}

return R
```

Helper used throughout this chapter:

```lua
-- ReplicatedStorage/Shared/Fx.luau (part 1)
--!strict
local Fx = {}

function Fx.MakeEmitter(props: { [string]: any }, parent: Instance?): ParticleEmitter
	local e = Instance.new("ParticleEmitter")
	for key, value in props do
		if key == "Texture" and value == "" then continue end -- keep the default sparkle
		(e :: any)[key] = value
	end
	e.Parent = parent
	return e
end

-- A world-space anchor: an Attachment on Terrain at a position
function Fx.Anchor(position: Vector3, lifetime: number?): Attachment
	local a = Instance.new("Attachment")
	a.WorldPosition = position
	a.Parent = workspace.Terrain
	if lifetime then game:GetService("Debris"):AddItem(a, lifetime) end
	return a
end

return Fx
```

Recipe tuning tips:
- **Reads at a glance** means silhouette and contrast first. A dark smoke behind a bright flash reads better than two bright layers.
- **Fast in, slow out:** high `Speed` plus high `Drag` gives the "pop then hang" look of professional bursts.
- **Size curves** should start at 0 or small and peak early (0.1–0.3 of life). A particle that is full size on frame 1 looks pasted on.
- **Colour sequences** should go from hot (white-yellow) to cool (orange to dark red to grey) for fire and from bright to saturated for magic.
- **Use `ZOffset`** to keep flashes in front of smoke without moving the attachment.

---

## 4. VFX community workflows

### 4.1 Emit versus continuous

| Use | Mode |
|---|---|
| Ambient (torch, aura, waterfall mist, sparkles on a pickup) | `Enabled = true`, low `Rate` |
| One-shot (hit, pickup, explosion, level-up) | `Enabled = false`, `:Emit(n)` |
| Timed (dash dust 0.4 s, level-up column 1.5 s) | `Enabled = true` → `task.delay(d, ...)` → `false` |
| Speed-dependent (footstep dust, tire smoke) | Set `Rate` each frame from velocity (0 when idle) |

Pros author effects in Studio as a **template Model/Attachment in ReplicatedStorage**, with many emitters, a light, sounds, and a few attributes. A generic emitter function then plays any template. This keeps art data out of code.

### 4.2 Attribute convention: EmitCount / EmitDelay / EmitDuration

These are **not engine features**. They are a widespread community convention used by VFX plugins and effect packs, and the meanings differ slightly between tools. Define them yourself and keep them consistent:

| Attribute (on a ParticleEmitter) | Meaning in this KB |
|---|---|
| `EmitCount` (number) | Particles for `:Emit()`. Default 10. |
| `EmitDelay` (number, s) | Wait before emitting. Default 0. Use it to sequence flash, then sparks, then smoke. |
| `EmitDuration` (number, s) | If set, enable continuous emission for this long instead of `:Emit`. |
| `EmitRepeat` (number) | Optional: repeat N bursts spaced by `EmitDelay`. |

```lua
-- ReplicatedStorage/Shared/Fx.luau (part 2) - add above `return Fx`
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

local function maxLifetime(root: Instance): number
	local m = 0
	for _, d in root:GetDescendants() do
		if d:IsA("ParticleEmitter") then
			local delay = (d:GetAttribute("EmitDelay") :: number?) or 0
			local dur = (d:GetAttribute("EmitDuration") :: number?) or 0
			m = math.max(m, delay + dur + d.Lifetime.Max)
		end
	end
	return m
end

-- Plays every emitter under `root` using the attribute convention.
function Fx.EmitAll(root: Instance)
	for _, d in root:GetDescendants() do
		if d:IsA("ParticleEmitter") then
			local count = (d:GetAttribute("EmitCount") :: number?) or 10
			local delay = (d:GetAttribute("EmitDelay") :: number?) or 0
			local duration = d:GetAttribute("EmitDuration") :: number?
			local repeats = (d:GetAttribute("EmitRepeat") :: number?) or 1
			task.delay(delay, function()
				if not d.Parent then return end
				if duration then
					d.Enabled = true
					task.delay(duration, function() d.Enabled = false end)
				else
					for i = 1, repeats do
						d:Emit(count)
						if i < repeats then task.wait(math.max(delay, 0.05)) end
					end
				end
			end)
		end
	end
end

-- Clones a template (Attachment or Model containing attachments) to a position and plays it.
function Fx.Play(template: Instance, cf: CFrame): Instance
	local fx = template:Clone()
	if fx:IsA("Attachment") then
		fx.WorldCFrame = cf
		fx.Parent = workspace.Terrain
	elseif fx:IsA("Model") then
		fx:PivotTo(cf)
		fx.Parent = workspace
	elseif fx:IsA("BasePart") then
		fx.CFrame = cf
		fx.Parent = workspace
	end
	-- Emitting on the same frame an emitter is parented is unreliable; wait one frame.
	RunService.Heartbeat:Once(function()
		Fx.EmitAll(fx)
	end)
	Debris:AddItem(fx, maxLifetime(fx) + 0.5)
	return fx
end
```

Why the one-frame wait: DevForum threads repeatedly report `:Emit()` doing nothing right after cloning or parenting, and fixed by a tiny `task.wait`/`task.defer`. This is community-observed behaviour, not documented, but the frame of latency is invisible, so always add it.

### 4.3 VFX module checklist

- [ ] Templates live in `ReplicatedStorage/Fx/<Name>`, with emitters disabled and attributes set.
- [ ] One `Fx.Play(name, cframe)` entry point, client-side, called from remote handlers.
- [ ] Distance culling: skip or reduce effects more than 150 studs from the camera.
- [ ] Quality scaling: read `UserSettings():GetService("UserGameSettings").SavedQualityLevel` (Automatic = 0) and halve `EmitCount` at low levels.
- [ ] Hard cap on concurrent effects (e.g. 40 live templates); drop the oldest.
- [ ] Everything cleaned with `Debris` or a pool.
- [ ] Paired sound and light belong to the template, so artists tune them together.

---

## 5. Tweens and springs

### 5.1 TweenService

```lua
local TweenService = game:GetService("TweenService")
local info = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) -- time, style, dir, repeatCount, reverses, delayTime
local t = TweenService:Create(frame, info, { Size = UDim2.fromScale(0.3, 0.1), BackgroundTransparency = 0 })
t:Play()
t.Completed:Wait() -- or :Connect
```

- Tweenable: number, bool (snaps), CFrame, Color3, NumberRange, Rect, UDim, UDim2, Vector2, Vector3 (not NumberSequence/ColorSequence).
- Two tweens on the **same property** of the same instance: the newer cancels the older. Tweens on different properties combine.
- `TweenService:GetValue(alpha, style, direction)` gives an eased alpha for your own loops, e.g. a custom camera path.
- Tween **models** by tweening a `CFrameValue` and calling `model:PivotTo()` in `.Changed`, or by tweening the anchored PrimaryPart with welded unanchored children.
- Server tweens replicate as property updates (choppy at distance). Run cosmetic tweens on the client.

| EasingStyle | Feel | Typical use |
|---|---|---|
| `Linear` | Mechanical | Progress bars, constant spins |
| `Sine` | Gentle | Hover bob, breathing, crossfades |
| `Quad`/`Cubic` | Natural | Most UI and camera moves |
| `Quart`/`Quint`/`Exponential` | Snappy | Dash, menu slam-in |
| `Back` | Overshoot | Button pops, popups, banners |
| `Elastic` | Wobbly | Cartoony "boing" (sparingly) |
| `Bounce` | Ball bounce | Dropped items landing |
| `Circular` | Sharp ease | Swooshes |

UI pop helper:

```lua
local function pop(guiObject: GuiObject, peak: number?)
	local scale = guiObject:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	scale.Parent = guiObject
	scale.Scale = 1
	local up = TweenService:Create(scale, TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = peak or 1.15 })
	local down = TweenService:Create(scale, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
	up.Completed:Once(function() down:Play() end)
	up:Play()
end
```

### 5.2 Springs

Tweens have a fixed duration and restart abruptly when interrupted. Springs carry velocity, so retargeting them mid-motion stays smooth. Use them for camera offsets, recoil, sway, hover/follow UI, and vehicle body roll.

Libraries already in `reference/libraries`: **RbxUtil `Spring`** (`Spring.new(initial, smoothTime, maxSpeed?)`, `:Update(dt)`, `:Impulse(v)`, `:Reset(v)`), **RbxUtil `Shake`**, and **Nevermore `spring`**. Popular on the DevForum: **spr** by Fraktality (`spr.target(instance, dampingRatio, frequency, {Prop = goal})`). Damping 1 = no overshoot; under 1 = bouncy.

A minimal critically damped / underdamped spring you can paste (works for numbers and Vector3):

```lua
-- ReplicatedStorage/Shared/Spring.luau
--!strict
local Spring = {}
Spring.__index = Spring

export type Spring<T> = typeof(setmetatable({} :: {
	Position: T, Velocity: T, Target: T, Damping: number, Speed: number,
}, Spring))

-- damping: 1 = critical (no overshoot), 0.4-0.7 = bouncy. speed: angular frequency (higher = faster), 8-20 typical.
function Spring.new<T>(initial: T, damping: number?, speed: number?): Spring<T>
	local zero = (initial :: any) * 0
	return setmetatable({
		Position = initial, Velocity = zero, Target = initial,
		Damping = damping or 1, Speed = speed or 12,
	}, Spring) :: any
end

function Spring.Update<T>(self: Spring<T>, dt: number): T
	-- semi-implicit Euler with substeps for stability
	local steps = math.max(1, math.ceil(dt / (1 / 120)))
	local h = dt / steps
	local p: any, v: any, t: any = self.Position, self.Velocity, self.Target
	local w, z = self.Speed, self.Damping
	for _ = 1, steps do
		local accel = (t - p) * (w * w) - v * (2 * z * w)
		v += accel * h
		p += v * h
	end
	self.Position, self.Velocity = p, v
	return p
end

function Spring.Impulse<T>(self: Spring<T>, velocity: T)
	self.Velocity = (self.Velocity :: any) + velocity
end

return Spring
```

Recoil example: `recoil:Impulse(Vector3.new(0.6, 0, 0))` on fire. Each render step, apply `CFrame.Angles(recoil.Position.X, 0, 0)` to the camera after the camera update (same technique as the shaker in §12.1).

---

## 6. Camera work

### 6.1 Camera essentials

| Property | Notes |
|---|---|
| `Workspace.CurrentCamera` | The local camera (client only). |
| `CameraType` | `Custom` (default player camera), `Scriptable` (you set CFrame every frame: cutscenes, custom cams), `Follow`, `Track`, `Watch`, `Attach`, `Fixed`, `Orbital`. |
| `CameraSubject` | Humanoid (default) or a BasePart (vehicle, spectate). |
| `CFrame`, `Focus` | Camera transform and the point the engine treats as "looked at" (used for LOD and audio). Set `Focus` in cutscenes. |
| `FieldOfView` | Vertical degrees, default 70. Valid range 1–120. |
| `FieldOfViewMode`, `DiagonalFieldOfView`, `MaxAxisFieldOfView` | Alternatives for consistent framing across aspect ratios. |
| `ViewportSize` | Screen size in pixels. |
| `NearPlaneZ` | Read-only. |
| `:WorldToViewportPoint`, `:ViewportPointToRay`, `:ScreenPointToRay`, `:GetPartsObscuringTarget`, `:ZoomToExtents` | none |
| `Camera:Interpolate`, `SetRoll`, `PanUnits`, etc. | **Deprecated**; use tweens and CFrame math instead. |

Player-level settings live on `StarterPlayer`/`Player`: `CameraMaxZoomDistance`, `CameraMinZoomDistance`, `CameraMode` (`Classic`/`LockFirstPerson`), `DevCameraOcclusionMode` (`Zoom`/`Invisicam`), `DevComputerCameraMovementMode`, `DevTouchCameraMovementMode`. `Humanoid.CameraOffset` (Vector3) shifts the default camera relative to the character without replacing the camera scripts, which is the cheapest over-the-shoulder setup.

**Order of operations:** the default `PlayerModule` camera updates at `Enum.RenderPriority.Camera` (value 200). To modify the result (shake, recoil, FOV), `RunService:BindToRenderStep(name, Enum.RenderPriority.Camera.Value + 1, fn)`. Undo your previous offset *before* the camera module runs (priority `Camera.Value - 1`) so the module never sees your shake and drifts.

### 6.2 FOV kick on sprint and dash

```lua
-- StarterPlayerScripts/SprintFov.client.luau
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local BASE_FOV, SPRINT_FOV = 70, 80
local current = BASE_FOV
local kick = 0 -- extra FOV from dashes, decays

local function onDash()
	kick = 12 -- call from your dash code
end

RunService:BindToRenderStep("SprintFov", Enum.RenderPriority.Camera.Value + 2, function(dt)
	local char = Players.LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	local speed = if root then (root.AssemblyLinearVelocity * Vector3.new(1, 0, 1)).Magnitude else 0
	local sprinting = hum ~= nil and hum.WalkSpeed > 18 and speed > 17
	local target = if sprinting then SPRINT_FOV else BASE_FOV
	current += (target - current) * (1 - math.exp(-8 * dt)) -- frame-rate independent lerp
	kick *= math.exp(-10 * dt)
	camera.FieldOfView = current + kick
end)
```

Keep FOV changes under 15° for comfort. Don't change FOV while the camera is `Scriptable` in a cutscene unless it's intended.

### 6.3 Custom offsets and over-the-shoulder

- **Cheap:** `humanoid.CameraOffset = Vector3.new(1.75, 0.5, 0)` plus `UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter` (shift-lock-like). Spring the offset when switching shoulders.
- **Full custom:** set `CameraType = Scriptable` and compute `CFrame.new(rootPos) * CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0) * CFrame.new(offset)` each render step. Raycast from the head to the desired camera position (excluding the character) and pull the camera in on hit, so it never clips through walls. Mobile needs touch-drag input for yaw/pitch, so prefer the default camera unless the genre needs a custom one.

### 6.4 Shake with Perlin noise (trauma model)

- `trauma` ∈ [0,1]; events add to it; it decays linearly (≈1/s).
- `shake = trauma²` (or ³), so small hits are subtle and big ones are violent.
- Offsets = `maxAngle * shake * noise(seed_i, t * frequency)` per axis, using `math.noise` (smooth, coherent), never `math.random` per frame (jittery, nauseating).
- In 3D, **rotation shake reads best**. Add only small positional shake, and very little roll.
- Attenuate by distance: `trauma * clamp(1 - dist/radius, 0, 1)`.
- Accessibility: multiply by a player setting and by `0.25` when `GuiService.ReducedMotionEnabled` is true.

The full module is in §12.1.

### 6.5 Cutscenes

```lua
-- Client: simple keyframed cutscene using Parts named "Shot1", "Shot2"... in a folder
local TweenService = game:GetService("TweenService")
local camera = workspace.CurrentCamera

local function playCutscene(folder: Folder, shotTime: number)
	local shots = folder:GetChildren()
	table.sort(shots, function(a, b) return a.Name < b.Name end)
	local prevType, prevSubject = camera.CameraType, camera.CameraSubject
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = (shots[1] :: BasePart).CFrame
	for i = 2, #shots do
		local goal = (shots[i] :: BasePart).CFrame
		local tw = TweenService:Create(camera, TweenInfo.new(shotTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { CFrame = goal })
		tw:Play()
		tw.Completed:Wait()
	end
	camera.CameraType = prevType
	camera.CameraSubject = prevSubject
end
```

Cutscene rules: let players skip after 1 s ("Tap to skip"). Hide the HUD (`ScreenGui.Enabled = false`), use letterbox bars, and freeze input by sinking actions with `ContextActionService`. Never trap the camera when the character dies; restore on `CharacterAdded`. Keep them under 10 s for a mobile audience. For moving shots, chain tweens or sample a Bézier with `TweenService:GetValue`. For dialogue, cut between two over-the-shoulder shots and avoid long pans.

---

## 7. Animation

### 7.1 Core objects

- **`Animation`**: holds `AnimationId = "rbxassetid://..."`.
- **`Animator`**: lives under `Humanoid` (characters) or `AnimationController` (non-humanoid rigs). `:LoadAnimation(anim)` returns an `AnimationTrack`. Other members: `:GetPlayingAnimationTracks()`, `:GetTrackByAnimationId()`, `AnimationPlayed`, `:ApplyJointVelocities()`, `:StepAnimations(dt)` (Studio/preview stepping), `PreferLodEnabled`, `EvaluationThrottled` (LOD throttling of distant rigs). `Humanoid:LoadAnimation` is the old path; use the Animator.
- **`AnimationTrack`**: `:Play(fadeTime=0.1, weight=1, speed=1)`, `:Stop(fadeTime=0.1)`, `:AdjustSpeed(speed)`, `:AdjustWeight(weight, fadeTime=0.1)`, `:GetMarkerReachedSignal(name)`, `:GetTimeOfKeyframe(name)`, `:SetParameter`/`:GetParameter` (animation graphs). Properties: `Priority`, `Looped`, `Speed`, `TimePosition`, `Length`, `IsPlaying`, `WeightCurrent`, `WeightTarget`. Events: `Ended`, `Stopped`, `DidLoop`. `KeyframeReached` is **deprecated**; use markers.

**Replication:** animations a client plays on **its own character** through the Humanoid's Animator replicate to the server and to other players. Animations on NPCs should be played by the server (or by each client, if purely cosmetic and you accept the desync). Load each track **once** per character and reuse it; loading on every click leaks tracks (there is a per-Animator limit of loaded tracks).

`Length` is 0 until the animation asset has loaded. Wait for `track.Length > 0` if you need it, or preload with `ContentProvider:PreloadAsync({anim})`.

### 7.2 Priorities and weights

| Priority (high → low) | Use |
|---|---|
| `Action4` | Overrides everything (stun, ragdoll-blend, cinematic) |
| `Action3` | Layered overrides (e.g. aiming arms over an attack) |
| `Action2` | Upper-body actions over `Action` |
| `Action` | Attacks, tool use, emotes |
| `Movement` | Walk, run, swim, climb |
| `Idle` | Idle loops |
| `Core` | Lowest; Roblox default animations and catalog bundles |

(Enum integer values are not in priority order: `Core` = 1000. Compare by the list above, not by `.Value`.)

Blending (official rule): per joint, tracks are evaluated from high to low priority while the summed weight is under 1. Once a joint's weights reach 1, lower priorities are ignored for that joint. Tracks at equal priority blend in proportion to weight. Practical consequences:
- An upper-body attack animated only on arm/torso joints at `Action` leaves the legs to the `Movement` walk cycle, giving free "attack while running". Don't key the legs in that animation, or the legs will freeze.
- Blend walk and run by playing both at `Movement` and adjusting weights by speed: `walk:AdjustWeight(1 - a)`, `run:AdjustWeight(a)`. Also set `AdjustSpeed` to match ground speed and avoid foot sliding.

### 7.3 Markers (animation events)

In the Animation Editor, add **Animation Events** on the timeline, each with a name and an optional parameter string. In code:

```lua
local swing = animator:LoadAnimation(swingAnim)
swing.Priority = Enum.AnimationPriority.Action
swing:GetMarkerReachedSignal("Hit"):Connect(function(param: string?)
	-- client: play whoosh/trail/vfx; ask server to resolve the hit (server re-validates range & cooldown)
end)
swing:GetMarkerReachedSignal("Footstep"):Connect(function(foot: string?)
	-- foot == "L" or "R": play footstep, emit dust at that foot
end)
swing:Play(0.05)
```

Use markers for hit frames, footsteps, VFX spawn, trail on/off, sound cues and camera kicks. That way timing lives in the animation and stays correct when the animator retimes it.

### 7.4 R15 vs R6

| | R15 | R6 |
|---|---|---|
| Parts | 15 (upper/lower limbs, hands, feet) | 6 |
| Animation quality | Elbows/knees, smooth, supports IK, layered clothing, dynamic heads | Blocky, retro, simple |
| Tools/emotes from catalog | Yes | Limited |
| Use when | Default for almost everything | Deliberate retro style, classic sword-fighting, obbies chasing an "old Roblox" feel |

Set this in Game Settings → Avatar. Animations are rig-specific: an R15 animation won't play on R6.

### 7.5 Authoring tools

- **Animation Editor** (built-in): keyframes, easing per keyframe (Linear, Constant, Cubic, Elastic, Bounce, plus direction), curve editor, events, priority, looping, IK posing. Publishing gives an asset ID owned by you or your group. **Animations only play in experiences owned by the same user/group** (or with permission), so publish under the group that owns the game.
- **Moon Animator 2** (paid community plugin): film-style timeline, animates cameras, lights and properties as well as rigs. Popular for cutscenes.
- **Blender**: animate with a Roblox-compatible rig (export the R15 rig with an exporter plugin, or use community rig add-ons), export FBX, import via the 3D Importer / Animation Editor "Import from FBX". Good for complex creature rigs.
- **Animation Capture**: video-to-animation and face capture, built into Studio (`animation/capture.md`).
- **Animation Graph Editor** (new): a node-based state machine asset (`AnimationGraphDefinition`). You load it like an animation and drive it with `track:SetParameter("humanoidSpeed", v)`. It is useful for complex locomotion, but newer and less battle-tested. Prefer the classic Animate script plus your own tracks unless the user wants it.

Animation feel rules: strong silhouettes on key poses, anticipation before every attack (pull back), overshoot then settle (follow-through), and arcs instead of straight lines. Hold the impact pose 2–4 frames; this is "animation hitstop", built into the clip. Idle needs breathing and a slight weight shift. Never leave a T-pose or a perfectly still idle.

### 7.6 Replacing default animations

Characters get an `Animate` LocalScript containing `StringValue` folders (`idle`, `walk`, `run`, `jump`, `fall`, `climb`, `swim`, `swimidle`) with `Animation` children. The official approach (server script on `CharacterAppearanceLoaded`): stop playing tracks, then set the IDs:

```lua
local animate = character:WaitForChild("Animate")
animate.run.RunAnim.AnimationId = "rbxassetid://<yours>"
animate.walk.WalkAnim.AnimationId = "rbxassetid://<yours>"
animate.jump.JumpAnim.AnimationId = "rbxassetid://<yours>"
animate.idle.Animation1.AnimationId = "rbxassetid://<yours>"
animate.idle.Animation2.AnimationId = "rbxassetid://<yours>"
animate.idle.Animation1.Weight.Value = 9   -- relative chance of each idle variant
animate.idle.Animation2.Weight.Value = 1
animate.fall.FallAnim.AnimationId = "rbxassetid://<yours>"
animate.climb.ClimbAnim.AnimationId = "rbxassetid://<yours>"
animate.swim.Swim.AnimationId = "rbxassetid://<yours>"
animate.swimidle.SwimIdle.AnimationId = "rbxassetid://<yours>"
```

For a fully custom controller, copy the `Animate` script from a play-test into `StarterCharacterScripts` and edit it there. Game Settings → Avatar can also force "Standard" animations (ignoring players' bundles) for a consistent look.

### 7.7 Emotes

The default `/e dance` and the emote wheel use `HumanoidDescription:SetEmotes()` / `:SetEquippedEmotes()` and `Humanoid:PlayEmote(name)`. In your own game, emotes are just `Action`-priority looped tracks bound to UI buttons. Stop them when the character moves (`Humanoid.MoveDirection.Magnitude > 0`). Use original emote animations, or catalog emotes the player owns via their description.

### 7.8 Procedural animation

- **`IKControl`** (child of the Humanoid/AnimationController): `Type` (`Transform`, `Position`, `Rotation`, `LookAt`), `ChainRoot` (e.g. UpperTorso), `EndEffector` (e.g. RightHand or an Attachment), `Target` (Attachment/part), `Pole` (elbow/knee hint), `Weight` 0–1, `SmoothTime`, `Priority`, `Offset`, `EndEffectorOffset`, `Enabled`. Uses: head/eyes look at the nearest NPC (`LookAt`, Weight 0.6), hand on a door handle, feet planted on slopes (raycast down per foot, Position IK), aiming a held weapon. IK runs on top of animation, client-side for smoothness.
- **`AnimationConstraint`**: a physics-friendly replacement for Motor6D. Its `Transform` is animated, and with `IsKinematic = false` it drives the joint with forces (`MaxForce`, `MaxTorque`, `LinearStrength`, `AngularStrength`, damping). It enables "active ragdolls" and physical hit reactions where the body reacts to impacts while still trying to follow the animation.
- **Code-driven joints**: write `Motor6D.Transform` in `RunService.PreSimulation`/`Stepped` (after animation, before physics) for things like a tail wag, a turret aim, or leaning into turns (roll the root by `-turnRate * 0.05`).
- **Procedural bob and sway** for first-person viewmodels: sin/cos of walk distance with springs, rather than authoring separate walk clips.

---

## 8. Audio

### 8.1 New Audio API vs legacy

| | **New (modular) API** | **Legacy** |
|---|---|---|
| Source | `AudioPlayer` (`Asset`, `Volume` 0–10, `PlaybackSpeed`, `Looping`, `LoopRegion`, `PlaybackRegion`, `TimePosition`, `TimeLength`, `IsPlaying`, `IsReady`, `AutoLoad`, `AutoPlay`; `:Play()`, `:Stop()`; `Ended`, `Looped`) | `Sound` (`SoundId`, `Volume` 0–10, default 0.5, `Looped`, `PlaybackSpeed`, `RollOffMode`, `RollOffMinDistance`, `RollOffMaxDistance`, `PlayOnRemove`, `SoundGroup`, `PlaybackLoudness`) |
| Routing | `Wire` (`SourceInstance`, `TargetInstance`, optional `SourceName`/`TargetName` pins) | Implicit (parent position) + `SoundGroup` |
| Effects | `AudioFader`, `AudioEqualizer`, `AudioCompressor`, `AudioReverb`, `AudioEcho`, `AudioChorus`, `AudioFlanger`, `AudioDistortion`, `AudioPitchShifter`, `AudioTremolo`, `AudioFilter`, `AudioLimiter`, `AudioGate`, `AudioAnalyzer`, `AudioChannelMixer/Splitter` | `SoundEffect` subclasses (`EqualizerSoundEffect`, `ReverbSoundEffect`...) under Sound/SoundGroup |
| 3D | `AudioEmitter` (positioned by parent) + `AudioListener` (camera/character) | Sound parented to a part/attachment |
| Output | `AudioDeviceOutput` (speakers; `Player` property limits it to one player) | Automatic |
| Voice/mic | `AudioDeviceInput`, `AudioTextToSpeech`, `AudioSpeechToText`, `AudioRecorder` | none |
| Status | **Recommended** | Docs: "now discouraged". Still works. |

Notes verified in the API reference:
- `AudioPlayer.AssetId` is **deprecated**: set `AudioPlayer.Asset = "rbxassetid://123"` (or `AudioContent`). Studio's property panel may still label it AssetID.
- `Sound.Pitch`, `Sound.MinDistance`, `Sound.MaxDistance` and `Sound.EmitterSize` are deprecated. Use `PlaybackSpeed` and `RollOffMinDistance/MaxDistance`.
- `AudioEmitter.DistanceAttenuationMode`: `Custom` (default; curve from `:SetDistanceAttenuation({[distance]=volume})`), `InverseTapered`, `Linear`, `LinearSquared`, `Inverse`. Non-custom modes use `DistanceAttenuationBounds` (NumberRange min/max distance).
- `AudioEmitter:SetAngleAttenuation({[angle0to180]=volume})` makes directional sources (a speaker cone, a monster facing you).
- `AudioEmitter.AudioInteractionGroup` / `AudioListener.AudioInteractionGroup`: a listener only hears emitters in the same group (e.g. a "radio" channel, an underwater mix).
- `SoundService.DefaultListenerLocation` (`Default`, `None`, `Character`, `Camera`). With `Character` or `Camera`, the engine creates the listener and an `AudioDeviceOutput` automatically. **Set it to `Camera` (third person) or `Character` in Studio** when you use AudioEmitters, or nothing 3D will be heard.
- `SoundService.CharacterSoundsUseNewApi` switches default character sounds to the new API (plugin-security write, so set it in Studio).

**2D (UI, music):** `AudioPlayer → Wire → AudioDeviceOutput` (optionally `→ AudioFader` bus in between).
**3D (world):** `AudioPlayer → Wire → AudioEmitter` (in a part/attachment), and the listener → `AudioDeviceOutput` (auto-created by `DefaultListenerLocation`).

Wire helper used below:

```lua
local function wire(source: Instance, target: Instance): Wire
	local w = Instance.new("Wire")
	w.SourceInstance = source
	w.TargetInstance = target
	w.Parent = target
	return w
end
```

Quick 3D one-shot with the new API:

```lua
local function play3D(assetId: string, parent: BasePart | Attachment, volume: number?, speed: number?)
	local player = Instance.new("AudioPlayer")
	player.Asset = assetId
	player.Volume = volume or 1
	player.PlaybackSpeed = speed or (0.95 + math.random() * 0.1)
	local emitter = Instance.new("AudioEmitter")
	emitter.DistanceAttenuationMode = Enum.DistanceAttenuationMode.InverseTapered
	emitter.DistanceAttenuationBounds = NumberRange.new(10, 120)
	emitter.Parent = parent
	player.Parent = emitter
	wire(player, emitter)
	player.Ended:Once(function() emitter:Destroy() end)
	if not player.IsReady then player:GetPropertyChangedSignal("IsReady"):Wait() end
	player:Play()
end
```

For very frequent one-shots (gunfire, footsteps), **pool** AudioPlayers rather than creating new ones every time (see §12.6).

### 8.2 Legacy Sound / SoundService reference (still common in existing games)

| Item | Notes |
|---|---|
| `SoundService.RolloffScale` | Global multiplier for legacy rolloff (1 = default; 0.5 = sounds carry further). |
| `SoundService.DistanceFactor` | Studs per meter for Doppler (default 3.33). |
| `SoundService.DopplerScale` | Doppler intensity (0 to disable for arcade games). |
| `SoundService.AmbientReverb` | Global reverb preset (`ReverbType`): `Cave`, `Hallway`, etc. Swap by zone. |
| `SoundService.RespectFilteringEnabled` | When true, client-played sounds don't replicate. Keep it true. |
| `SoundService:PlayLocalSound(sound)` | Plays a Sound locally (UI clicks). |
| `SoundService:SetListener(...)` | Change the legacy listener (camera / part / CFrame). |
| `Sound.RollOffMode` | `Inverse` (realistic, long tail), `Linear`, `LinearSquare`, `InverseTapered` (recommended: realistic near, reaches 0 at max). |
| `RollOffMinDistance` / `RollOffMaxDistance` | Full volume within min; silent past max (tapered/linear modes). |
| `SoundGroup.Volume` | Bus volume (multiplies member Sounds). |

### 8.3 3D sound guidelines

| Source | Attenuation bounds (min–max studs) |
|---|---|
| Footsteps (others) | 5–60 |
| Gunshot / explosion | 20–300 / 30–500 |
| Ambient emitters (waterfall, machine) | 10–80, looped, low volume |
| Coin pickup (others) | 5–40 |
| NPC idle chatter SFX (non-vocal) | 5–40 |

- The local player's own action sounds (their footsteps, their weapon) can be 2D or very close-range 3D so they're always crisp.
- Use `AudioReverb` / `AudioEqualizer` per zone (caves: `DecayTime` 2–3 s, `WetLevel` around −6 dB; underwater: `AudioFilter` `Lowpass24dB` at ~800 Hz on the listener chain).

### 8.4 Mixing guidelines

Volumes are linear amplitude: 1 = unity, 0.5 ≈ −6 dB, 0.25 ≈ −12 dB. A sane starting mix:

| Bus | Volume | Notes |
|---|---|---|
| Music | 0.3–0.5 | Under everything. Duck to ~0.2 during stingers and cutscene SFX. |
| Ambience | 0.2–0.4 | Wind, birds, room tone; crossfade per zone. |
| SFX (gameplay) | 0.6–1.0 | Hits, pickups, abilities. Most important feedback should be loudest. |
| UI | 0.4–0.6 | Short, soft, never harsh. |
| Stingers (level-up, win) | 0.8–1.0 | Duck music around them. |

- Add a **settings menu with separate Music and SFX sliders** (save them in DataStore or player attributes) and a music mute button. Many players listen to their own music.
- Put an `AudioLimiter` (`MaxLevel` around −1 dB) or `AudioCompressor` at the end of the SFX bus so 20 simultaneous explosions don't clip.
- **Normalize your assets.** Peak about −1 dBFS, perceived loudness consistent across SFX, so code volumes mean the same thing for every file.
- Limit voices: cap concurrent instances of the same sound (e.g. 4 coin dings), and drop extras or steal the oldest.
- **Pitch variation is free juice:** ±5–8% `PlaybackSpeed` on every repeated SFX. For combos, raise the pitch by a semitone per step (×1.0595), capped at +1 octave.
- **Sound layering for impacts:** a *transient* (click/crack, 0–30 ms) for snap, a *body* (thump/whoosh, 50–300 ms) for weight, and a *tail* (debris, rumble, reverb, 0.3–2 s) for scale. Make 2–4 variants per layer and randomize combinations.
- User preference: SFX must be **non-vocal**. No grunts, shouts, "yeah!" barks or laughing; use synthetic or foley sounds instead.

### 8.5 Music system rules

- **Instrumental only** by default (no lyrics, choir, humming, vocal chops or vocal pads).
- **Seamless loops.** Choose tracks authored to loop, or find loop points. Set `AudioPlayer.Looping = true`, and if the track has an intro/outro, set `LoopRegion = NumberRange.new(loopStart, loopEnd)` (seconds) so the loop skips the intro and ending. Test the loop seam in Studio by setting `TimePosition` to `loopEnd - 3` and listening.
- **Upload in WAV/OGG/FLAC rather than MP3** when you control the file. MP3 encoders add padding silence at the start and end, which causes an audible gap at the loop point. Allowed formats: mp3, ogg, wav, flac; under 20 MB, 7 min, 48 kHz; mono/stereo/3.0/5.1.
- **Crossfade** 1.5–3 s between areas or states with equal-power-ish curves (Sine Out for fade-in, Sine In for fade-out). Never hard-cut except for dramatic stingers.
- **Adaptive music:** keep 2–3 stems or intensity tracks of the same song in sync (start them together, all `Looping`, same length) and fade stem volumes by game state (explore → combat). Since they share `TimePosition`, transitions are musical.
- **Avoid fatigue:** in a menu or lobby, rotate 2–4 tracks. In long sessions, add 10–30 s of silence or ambience between songs.

### 8.6 Licensing, privacy and where to get audio

- **Creator Store (Toolbox → Creator Store → Audio)**: Roblox's free-to-use library, with more than 100,000 professionally produced SFX and music tracks from Roblox and audio/music partners. Over the years these have included APM Music's library (announced as royalty-free for use on Roblox), Monstercat's catalogue (via Monstercat's official Roblox account) and DistroKid-distributed music. Creator Store music is licensed **for use on Roblox only**. Filter by "Creator: Roblox" or a verified partner account for licensed tracks; community uploads carry whatever rights the uploader had.
- **Prefer instrumental tracks.** When searching, use genre and mood keywords plus "instrumental", and preview every candidate to confirm there are no vocals or choir.
- Right-click → **Copy Asset ID** and paste it into `AudioPlayer.Asset`. Clicking an asset in the Toolbox inserts a legacy `Sound`; copy the ID instead if you use the new API.
- **Uploading your own:** you must own the rights. ID-verified accounts can upload 2,000 audio files per 30 days, unverified accounts 100. Uploads are moderated.
- **Asset privacy:** uploaded audio is private to the uploader (or group). It only plays in experiences owned by the same creator, or that you grant permission in the asset's Permissions settings. **Upload under the group that owns the game**, or grant the universe access, or the sound will be silent in live servers. Animations follow the same rule.
- **Never** rip commercial music, use "bypassed" audio, or reuse IDs from other games without permission. Copyright strikes can remove assets and moderate accounts.
- Original audio sources: compose in a DAW, use CC0 sound libraries (check the licence of every file), or synthesize SFX (sfxr-style tools) and polish them in Audacity. Keep a `CREDITS.md` with source and licence for each asset.

---

## 9. Haptics

Two APIs:

1. **`HapticEffect`** (new, recommended): `Type` (`Enum.HapticEffectType`: `UIHover`, `UIClick`, `UINotification`, `GameplayExplosion`, `GameplayCollision`, `Custom`), `Looped`, `Position` + `Radius` (where on the device the impact feels centred), `:Play()`, `:Stop()`, `:SetWaveformKeys({FloatCurveKey...})` for `Custom`, `Ended`. Supported on most haptic iPhone/Pixel/Galaxy phones, PlayStation and Xbox gamepads, and Quest Touch controllers.

```lua
local Workspace = game:GetService("Workspace")
local hapticCache: { [Enum.HapticEffectType]: HapticEffect } = {}
local function haptic(kind: Enum.HapticEffectType)
	local e = hapticCache[kind]
	if not e then
		e = Instance.new("HapticEffect")
		e.Type = kind
		e.Parent = Workspace
		hapticCache[kind] = e
	end
	e:Play()
end
-- haptic(Enum.HapticEffectType.UIClick); haptic(Enum.HapticEffectType.GameplayExplosion)
```

2. **`HapticService`** (legacy motor API, gamepads): `:IsVibrationSupported(Enum.UserInputType.Gamepad1)`, `:IsMotorSupported(input, Enum.VibrationMotor.Large)`, `:SetMotor(input, motor, intensity0to1)`, `:GetMotor(...)`. You must set intensity back to 0 yourself.

Haptic rules: short (under 100 ms) and only for meaningful events (hit landed, damage taken, purchase, level-up). Never use continuous buzz. Include a settings toggle. Run haptics from the client in the same handler as the VFX.

---

## 10. Character controllers (feel)

- The default Humanoid controller is fine for most games. Tune `Humanoid.WalkSpeed` (16 default; 20–24 feels snappier for action games), `JumpPower`/`JumpHeight` (with `UseJumpPower`), and `Workspace.Gravity` (196.2 default; 150–170 floatier, 230+ snappier).
- The feel comes from **acceleration**: default humanoids snap to full speed. For weight, consider a custom controller (a `ControllerManager` with `GroundController`/`AirController`, or a fully physics-based controller). This is costly; only do it when the genre is movement-centric.
- Coyote time (allow a jump 0.1 s after leaving a ledge) and jump buffering (remember a jump press 0.1 s before landing) make platformers feel fair. Implement both with timestamps in a LocalScript and `Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)`.
- Landing feedback: on `Humanoid.StateChanged` → `Landed`, scale the effect by fall speed. Apply a camera dip (spring Y offset −0.3 to −0.8), dust `Emit(6–14)`, a land sound with volume by speed, and fall damage only past a threshold.
- Dash: `LinearVelocity` or `ApplyImpulse` on the root for 0.15–0.25 s, plus FOV kick, trail on, a dust burst, and a whoosh.

---

## 11. Performance budgets (mobile first)

| Resource | Budget on a low-end phone | Notes |
|---|---|---|
| Particle rate per emitter | ≤ 100/s (engine cap on mobile) | Lower is better; widen size before raising rate. |
| Live particles on screen | ~300–500 total | Overdraw (layered transparency) is the real cost. |
| Particle screen area | Avoid full-screen particles | Fill rate: big soft smoke close to the camera is expensive. |
| Continuous emitters visible | ~10–20 | Disable emitters out of range (distance check every 0.5 s). |
| Unique particle textures | Few, ≤ 256 px | Reuse textures; flipbooks get dropped on low memory. |
| Dynamic lights near camera | ~10–15; ≤ 2–4 with `Shadows` | FX flashes: Shadows = false, short-lived. |
| Beams | Segments 1–10; straight beams use few | Curved lightning: refresh ≤ 20 Hz. |
| Trails | `MaxLength` set; `Lifetime` ≤ 0.5 s | Disable when not moving. |
| Highlights | Few; ≤ 255 hard cap | First one ~1 ms GPU on mobile; toggle `Enabled`. |
| Simultaneous voices | ~32 active sources | Cap repeats and pool AudioPlayers. |
| Tweens | Hundreds are OK | But don't tween every coin; animate a few and pool them. |
| BillboardGuis (popups) | ≤ 30 live | Pool; set `MaxDistance`. |

Techniques:
- The engine already scales particle counts with the graphics quality level. Test at quality 1 *and* 10.
- Use the **MicroProfiler** (Ctrl+F6) and the Developer Console (F9) → Memory → Graphics and the Render stats to find costly FX.
- Run all FX on the client, cull by distance, and don't spawn effects for events more than 200 studs away.
- Prefer Attachment-parented emitters over whole parts (no extra physics/collision objects). If you must use a part, set `Anchored`, `CanCollide`, `CanQuery` and `CanTouch` all to false.
- Destroy or pool everything. Run a 10-minute soak test, watching the instance count (`Stats` / Developer Console), to catch leaks.

---

## 12. Complete Luau modules

All modules are client-side `ModuleScript`s in `ReplicatedStorage/Shared` unless noted, and are `--!strict`-friendly. Replace every `rbxassetid://0` with real, licensed asset IDs.

### 12.1 CameraShaker (trauma + Perlin, undo/apply around the camera update)

```lua
-- ReplicatedStorage/Shared/CameraShaker.luau
--!strict
-- Usage (client):
--   local CameraShaker = require(path.CameraShaker)
--   CameraShaker.AddTrauma(0.4)                         -- one-shot
--   CameraShaker.AddTraumaAt(0.8, explosionPos, 60)     -- distance-attenuated
--   CameraShaker.SetSustained("earthquake", 0.35)       -- sustained floor; set 0 to clear
--   CameraShaker.SetIntensity(0.5)                      -- player setting 0..1
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")

local CameraShaker = {}

local MAX_PITCH = math.rad(3.5)
local MAX_YAW = math.rad(3.5)
local MAX_ROLL = math.rad(2)
local MAX_OFFSET = Vector3.new(0.25, 0.25, 0.15)
local FREQUENCY = 16 -- noise samples per second; 12-25 impact, 3-6 rumble
local DECAY = 1.1 -- trauma lost per second

local trauma = 0
local intensity = 1
local sustained: { [string]: number } = {}
local seed = math.random() * 1000
local lastOffset = CFrame.identity
local started = false

local function clamp01(x: number): number
	return math.clamp(x, 0, 1)
end

local function sustainedFloor(): number
	local m = 0
	for _, v in sustained do
		m = math.max(m, v)
	end
	return m
end

local function noise(channel: number, t: number): number
	-- math.noise returns roughly [-1, 1] (mostly within +-0.5); scale and clamp
	return math.clamp(math.noise(seed + channel * 17.31, t * FREQUENCY, 0) * 2, -1, 1)
end

local function undo()
	local camera = Workspace.CurrentCamera
	if camera and lastOffset ~= CFrame.identity then
		camera.CFrame = camera.CFrame * lastOffset:Inverse()
	end
	lastOffset = CFrame.identity
end

local function apply(dt: number)
	local camera = Workspace.CurrentCamera
	if not camera then return end
	trauma = math.max(0, trauma - DECAY * dt)
	local level = math.max(trauma, sustainedFloor())
	if level <= 0 then return end
	local scale = intensity * (if GuiService.ReducedMotionEnabled then 0.25 else 1)
	local shake = level * level * scale
	local t = os.clock()
	local pitch = MAX_PITCH * shake * noise(1, t)
	local yaw = MAX_YAW * shake * noise(2, t)
	local roll = MAX_ROLL * shake * noise(3, t)
	local offset = Vector3.new(
		MAX_OFFSET.X * shake * noise(4, t),
		MAX_OFFSET.Y * shake * noise(5, t),
		MAX_OFFSET.Z * shake * noise(6, t)
	)
	lastOffset = CFrame.new(offset) * CFrame.Angles(pitch, yaw, roll)
	camera.CFrame = camera.CFrame * lastOffset
end

function CameraShaker.Start()
	if started then return end
	started = true
	-- Remove our previous offset BEFORE the default camera computes this frame...
	RunService:BindToRenderStep("CameraShaker_Undo", Enum.RenderPriority.Camera.Value - 1, undo)
	-- ...and add the new offset AFTER it.
	RunService:BindToRenderStep("CameraShaker_Apply", Enum.RenderPriority.Camera.Value + 1, apply)
end

function CameraShaker.Stop()
	if not started then return end
	started = false
	RunService:UnbindFromRenderStep("CameraShaker_Undo")
	RunService:UnbindFromRenderStep("CameraShaker_Apply")
	undo()
	trauma = 0
	table.clear(sustained)
end

function CameraShaker.AddTrauma(amount: number)
	CameraShaker.Start()
	trauma = clamp01(trauma + amount)
end

-- Attenuates trauma by distance from the camera (linear falloff to 0 at radius).
function CameraShaker.AddTraumaAt(amount: number, position: Vector3, radius: number)
	local camera = Workspace.CurrentCamera
	if not camera then return end
	local d = (camera.CFrame.Position - position).Magnitude
	local falloff = clamp01(1 - d / radius)
	if falloff > 0 then
		CameraShaker.AddTrauma(amount * falloff)
	end
end

function CameraShaker.SetSustained(key: string, level: number)
	CameraShaker.Start()
	sustained[key] = if level > 0 then clamp01(level) else nil
end

function CameraShaker.SetIntensity(value: number)
	intensity = clamp01(value)
end

function CameraShaker.GetTrauma(): number
	return trauma
end

return CameraShaker
```

Why undo/apply: the default camera module reads the previous camera CFrame for some calculations. If you only add offsets, the shake accumulates and the camera drifts or fights the player's input. Removing the offset before the module runs makes the shake purely additive. With `CameraType = Scriptable` (cutscenes), set your cutscene CFrame at a priority **at or before** `Camera.Value` and the shaker still layers on top.

### 12.2 Reward burst FX

```lua
-- ReplicatedStorage/Shared/RewardBurst.luau
--!strict
-- RewardBurst.Play(position, { count = 24, color = Color3, sound = "rbxassetid://...", big = false })
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Recipes = require(script.Parent.FxRecipes)
local Fx = require(script.Parent.Fx)
local CameraShaker = require(script.Parent.CameraShaker)

local RewardBurst = {}

type Options = { count: number?, color: Color3?, sound: string?, big: boolean?, volume: number? }

local MAX_ACTIVE = 12
local active = 0

local soundOut: AudioDeviceOutput? = nil
local function getOutput(): AudioDeviceOutput
	if soundOut and soundOut.Parent then return soundOut end
	local out = Instance.new("AudioDeviceOutput")
	out.Name = "RewardSfxOutput"
	out.Parent = game:GetService("SoundService")
	soundOut = out
	return out
end

local function playUiSound(assetId: string, volume: number, speed: number)
	local p = Instance.new("AudioPlayer")
	p.Asset = assetId
	p.Volume = volume
	p.PlaybackSpeed = speed
	local out = getOutput()
	p.Parent = out
	local w = Instance.new("Wire")
	w.SourceInstance = p
	w.TargetInstance = out
	w.Parent = p
	p.Ended:Once(function() p:Destroy() end)
	task.spawn(function()
		if not p.IsReady then
			local ok = false
			local conn = p:GetPropertyChangedSignal("IsReady"):Connect(function() ok = true end)
			local t0 = os.clock()
			while not ok and os.clock() - t0 < 2 do task.wait() end
			conn:Disconnect()
		end
		p:Play()
		Debris:AddItem(p, 10)
	end)
end

function RewardBurst.Play(position: Vector3, opts: Options?)
	local o: Options = opts or {}
	if active >= MAX_ACTIVE then return end
	active += 1

	local camera = Workspace.CurrentCamera
	if camera and (camera.CFrame.Position - position).Magnitude > 200 then
		active -= 1
		return -- too far to matter
	end

	local anchor = Fx.Anchor(position, 3)
	local coin = Fx.MakeEmitter(Recipes.CoinBurst, anchor)
	local sparkle = Fx.MakeEmitter(Recipes.MagicSparks, anchor)
	local flash = Fx.MakeEmitter(Recipes.MagicFlash, anchor)
	local tint = o.color or Color3.fromRGB(255, 215, 90)
	sparkle.Color = ColorSequence.new(tint)
	flash.Color = ColorSequence.new(tint)

	local light = Instance.new("PointLight")
	light.Color = tint
	light.Range = if o.big then 18 else 10
	light.Brightness = if o.big then 6 else 3
	light.Shadows = false
	light.Parent = anchor

	RunService.Heartbeat:Once(function()
		local n = o.count or 24
		coin:Emit(n)
		sparkle:Emit(math.floor(n * 0.6))
		flash:Emit(1)
		TweenService:Create(light, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Brightness = 0 }):Play()
	end)

	if o.sound then
		playUiSound(o.sound, o.volume or 0.7, 0.95 + math.random() * 0.1)
	end
	if o.big then
		CameraShaker.AddTraumaAt(0.25, position, 40)
	end

	task.delay(1.2, function()
		active -= 1
	end)
end

return RewardBurst
```

Pair it with a UI counter pop (`pop(coinLabel, 1.15)` from §5.1). For a better pickup, also tween the collected coin model toward the player (0.15 s, Quad In) and shrink it before destroying it, so it looks like it was absorbed.

### 12.3 Damage number popups

```lua
-- ReplicatedStorage/Shared/DamageNumbers.luau
--!strict
-- DamageNumbers.Show(worldPos, 37, isCrit)   DamageNumbers.ShowText(worldPos, "+5", Color3.new(1,1,0))
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local DamageNumbers = {}

local POOL_MAX = 30
local pool: { BillboardGui } = {}
local live = 0

local container: Folder? = nil
local function getContainer(): Folder
	if container and container.Parent then return container end
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local f = Instance.new("Folder")
	f.Name = "DamageNumbers"
	f.Parent = playerGui
	container = f
	return f
end

local function build(): BillboardGui
	local anchor = Instance.new("Attachment")
	anchor.Name = "DamageNumberAnchor"
	anchor.Parent = Workspace.Terrain

	local gui = Instance.new("BillboardGui")
	gui.Name = "DamageNumber"
	gui.Size = UDim2.fromOffset(160, 56)
	gui.AlwaysOnTop = true
	gui.LightInfluence = 0
	gui.MaxDistance = 150
	gui.Adornee = anchor
	gui.ResetOnSpawn = false

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.FontFace = Font.fromEnum(Enum.Font.FredokaOne)
	label.TextScaled = true
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Parent = gui

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2.5
	stroke.Color = Color3.fromRGB(30, 20, 20)
	stroke.Parent = label

	local scale = Instance.new("UIScale")
	scale.Parent = gui -- scales all descendants

	gui:SetAttribute("Anchor", true)
	anchor:SetAttribute("Owner", true)
	gui.Destroying:Once(function() anchor:Destroy() end)
	return gui
end

local function acquire(): BillboardGui?
	local gui = table.remove(pool)
	if gui then return gui end
	if live >= POOL_MAX then return nil end -- hard cap; skip rather than lag
	return build()
end

local function release(gui: BillboardGui)
	live -= 1
	gui.Enabled = false
	table.insert(pool, gui)
end

function DamageNumbers.ShowText(position: Vector3, text: string, color: Color3, big: boolean?)
	local gui = acquire()
	if not gui then return end
	live += 1

	local anchor = gui.Adornee :: Attachment
	local label = gui:FindFirstChild("Label") :: TextLabel
	local stroke = label:FindFirstChildOfClass("UIStroke") :: UIStroke
	local scale = gui:FindFirstChildOfClass("UIScale") :: UIScale

	-- random jitter so stacked hits don't overlap
	local jitter = Vector3.new((math.random() - 0.5) * 1.5, math.random() * 0.6, (math.random() - 0.5) * 1.5)
	anchor.WorldPosition = position + Vector3.new(0, 2, 0) + jitter
	gui.StudsOffset = Vector3.zero
	label.Text = text
	label.TextColor3 = color
	label.TextTransparency = 0
	stroke.Transparency = 0
	scale.Scale = 0
	gui.Parent = getContainer()
	gui.Enabled = true

	local peak = if big then 1.6 else 1.15
	local life = if big then 0.95 else 0.7
	local rise = if big then 3.5 else 2.5

	-- pop in (overshoot), settle, rise, fade
	local popIn = TweenService:Create(scale, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = peak })
	local settle = TweenService:Create(scale, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = if big then 1.25 else 1 })
	popIn.Completed:Once(function() settle:Play() end)
	popIn:Play()

	TweenService:Create(gui, TweenInfo.new(life, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		StudsOffset = Vector3.new(0, rise, 0),
	}):Play()

	local fadeInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, life - 0.25)
	local fade = TweenService:Create(label, fadeInfo, { TextTransparency = 1 })
	TweenService:Create(stroke, fadeInfo, { Transparency = 1 }):Play()
	fade.Completed:Once(function() release(gui) end)
	fade:Play()
end

function DamageNumbers.Show(position: Vector3, amount: number, crit: boolean?)
	local text = tostring(math.floor(amount + 0.5))
	if crit then
		DamageNumbers.ShowText(position, text .. "!", Color3.fromRGB(255, 200, 40), true)
	else
		DamageNumbers.ShowText(position, text, Color3.fromRGB(255, 255, 255), false)
	end
end

return DamageNumbers
```

Variants: heals in green with a "+" prefix, money in gold with a coin icon (ImageLabel beside the text), "MISS"/"BLOCK" in grey. Abbreviate big numbers (1.2K, 3.4M) via the formatter in chapter 03. Merge rapid hits on the same target into one rising, growing number (accumulate for 0.3 s) to cut clutter.

### 12.4 Hit-stop + flash on hit

```lua
-- ReplicatedStorage/Shared/HitFeedback.luau
--!strict
-- HitFeedback.Hit(victimModel, attackerModel?, strength?)  -- strength 0.5 (light) .. 2 (heavy)
-- Cosmetic, client-only: freezes animations briefly, flashes the victim white, shakes and buzzes.
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local CameraShaker = require(script.Parent.CameraShaker)

local HitFeedback = {}

local FLASH_NAME = "HitFlash"
local frozenUntil: { [Animator]: number } = {}
local savedSpeeds: { [AnimationTrack]: number } = {}
local haptic: HapticEffect? = nil

local function getAnimator(model: Model?): Animator?
	if not model then return nil end
	local holder = model:FindFirstChildOfClass("Humanoid") or model:FindFirstChildOfClass("AnimationController")
	return if holder then holder:FindFirstChildOfClass("Animator") else nil
end

local function freeze(animator: Animator, duration: number)
	local untilTime = os.clock() + duration
	local already = frozenUntil[animator] ~= nil
	frozenUntil[animator] = math.max(frozenUntil[animator] or 0, untilTime)
	if already then return end -- extend the existing freeze; don't double-save speeds

	for _, track in animator:GetPlayingAnimationTracks() do
		savedSpeeds[track] = track.Speed
		track:AdjustSpeed(0)
	end
	task.spawn(function()
		while os.clock() < (frozenUntil[animator] or 0) do
			task.wait()
		end
		frozenUntil[animator] = nil
		for _, track in animator:GetPlayingAnimationTracks() do
			local s = savedSpeeds[track]
			if s ~= nil then
				track:AdjustSpeed(s)
				savedSpeeds[track] = nil
			end
		end
		-- tracks that stopped during the freeze: forget them
		for track in savedSpeeds do
			if not track.IsPlaying then savedSpeeds[track] = nil end
		end
	end)
end

local function getFlash(model: Model): Highlight
	local h = model:FindFirstChild(FLASH_NAME)
	if h and h:IsA("Highlight") then return h end
	local hl = Instance.new("Highlight")
	hl.Name = FLASH_NAME
	hl.DepthMode = Enum.HighlightDepthMode.Occluded
	hl.FillColor = Color3.new(1, 1, 1)
	hl.OutlineColor = Color3.new(1, 1, 1)
	hl.OutlineTransparency = 1
	hl.FillTransparency = 1
	hl.Enabled = false
	hl.Parent = model -- created once, then only toggled (cheap)
	return hl
end

local flashTweens: { [Highlight]: Tween } = {}
local function flash(model: Model, duration: number, color: Color3?)
	local hl = getFlash(model)
	local old = flashTweens[hl]
	if old then old:Cancel() end
	hl.FillColor = color or Color3.new(1, 1, 1)
	hl.FillTransparency = 0
	hl.Enabled = true
	local tw = TweenService:Create(hl, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { FillTransparency = 1 })
	flashTweens[hl] = tw
	tw.Completed:Once(function(state)
		if state == Enum.PlaybackState.Completed then
			hl.Enabled = false
			flashTweens[hl] = nil
		end
	end)
	tw:Play()
end

local function playHaptic()
	if not haptic then
		local e = Instance.new("HapticEffect")
		e.Type = Enum.HapticEffectType.GameplayCollision
		e.Parent = Workspace
		haptic = e
	end
	(haptic :: HapticEffect):Play()
end

function HitFeedback.Hit(victim: Model, attacker: Model?, strength: number?)
	local s = math.clamp(strength or 1, 0.25, 3)
	local stop = 0.03 + 0.03 * s -- 60 ms at strength 1, 120 ms at 3

	local vAnim = getAnimator(victim)
	if vAnim then freeze(vAnim, stop) end
	local aAnim = getAnimator(attacker)
	if aAnim then freeze(aAnim, stop) end

	flash(victim, 0.06 + 0.03 * s)

	local localChar = Players.LocalPlayer.Character
	local involvesMe = (attacker ~= nil and attacker == localChar) or victim == localChar
	if involvesMe then
		CameraShaker.AddTrauma(if victim == localChar then 0.3 * s else 0.12 * s)
		playHaptic()
	else
		local root = victim:FindFirstChild("HumanoidRootPart") :: BasePart?
		if root then CameraShaker.AddTraumaAt(0.1 * s, root.Position, 30) end
	end
end

-- Red tint variant for "I took damage"
function HitFeedback.Hurt(model: Model)
	flash(model, 0.15, Color3.fromRGB(255, 60, 60))
end

return HitFeedback
```

Notes: true global time-freeze isn't possible on Roblox (physics runs on the server and on network owners). Hitstop is therefore an animation freeze on attacker and victim, optionally with `ParticleEmitter.TimeScale = 0` on the hit's own effect and a short `AdjustSpeed(0.2)` slow-mo instead of a full stop for heavy finishers. Never delay the server's damage calculation for hitstop.

### 12.5 Music crossfade manager (new Audio API, seamless loops, ducking)

```lua
-- ReplicatedStorage/Shared/MusicManager.luau
--!strict
-- Client-only. Instrumental tracks, seamless loops, equal-power-ish crossfades, ducking, settings volume.
--   MusicManager.Register("Lobby", "rbxassetid://0", { loopRegion = NumberRange.new(4.0, 92.0) })
--   MusicManager.Play("Lobby", 2)            -- crossfade over 2 s
--   MusicManager.Duck(0.35, 0.2, 2.5)        -- duck to 35% for 2.5 s (stinger)
--   MusicManager.SetUserVolume(0.8)          -- from settings slider (0..1)
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local MusicManager = {}

type TrackDef = { asset: string, loopRegion: NumberRange?, volume: number? }
type Track = { def: TrackDef, player: AudioPlayer, fader: AudioFader, tween: Tween? }

local BASE_BUS_VOLUME = 0.4 -- music sits well under SFX
local defs: { [string]: TrackDef } = {}
local tracks: { [string]: Track } = {}
local current: string? = nil
local userVolume = 1
local duckLevel = 1
local duckToken = 0

local function wire(source: Instance, target: Instance): Wire
	local w = Instance.new("Wire")
	w.SourceInstance = source
	w.TargetInstance = target
	w.Parent = target
	return w
end

-- Graph: AudioPlayer -> AudioFader(track) -> AudioFader(bus) -> AudioDeviceOutput
local root = Instance.new("Folder")
root.Name = "MusicSystem"
root.Parent = SoundService

local output = Instance.new("AudioDeviceOutput")
output.Name = "MusicOutput"
output.Parent = root

local bus = Instance.new("AudioFader")
bus.Name = "MusicBus"
bus.Volume = BASE_BUS_VOLUME
bus.Parent = root
wire(bus, output)

local function applyBus(fadeTime: number)
	local goal = BASE_BUS_VOLUME * userVolume * duckLevel
	if fadeTime <= 0 then
		bus.Volume = goal
	else
		TweenService:Create(bus, TweenInfo.new(fadeTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Volume = goal }):Play()
	end
end

local function waitReady(player: AudioPlayer, timeout: number): boolean
	if player.IsReady then return true end
	local t0 = os.clock()
	while not player.IsReady and os.clock() - t0 < timeout do
		task.wait(0.05)
	end
	return player.IsReady
end

local function getTrack(name: string): Track?
	local existing = tracks[name]
	if existing then return existing end
	local def = defs[name]
	if not def then
		warn("[MusicManager] unknown track", name)
		return nil
	end
	local player = Instance.new("AudioPlayer")
	player.Name = name
	player.Asset = def.asset
	player.Looping = true
	if def.loopRegion then
		player.LoopRegion = def.loopRegion -- skip intro/outro so the loop is seamless
	end
	player.Volume = def.volume or 1
	player.Parent = root

	local fader = Instance.new("AudioFader")
	fader.Name = name .. "_Fader"
	fader.Volume = 0
	fader.Parent = root

	wire(player, fader)
	wire(fader, bus)

	local t: Track = { def = def, player = player, fader = fader, tween = nil }
	tracks[name] = t
	return t
end

local function fadeTo(t: Track, volume: number, time: number, direction: Enum.EasingDirection, onDone: (() -> ())?)
	if t.tween then t.tween:Cancel() end
	local tw = TweenService:Create(t.fader, TweenInfo.new(math.max(time, 0.01), Enum.EasingStyle.Sine, direction), { Volume = volume })
	t.tween = tw
	if onDone then
		tw.Completed:Once(function(state)
			if state == Enum.PlaybackState.Completed then onDone() end
		end)
	end
	tw:Play()
end

function MusicManager.Register(name: string, asset: string, opts: { loopRegion: NumberRange?, volume: number? }?)
	defs[name] = { asset = asset, loopRegion = opts and opts.loopRegion, volume = opts and opts.volume }
end

-- Preload so the first crossfade has no gap (call during loading screen)
function MusicManager.Preload(names: { string })
	for _, n in names do
		local t = getTrack(n)
		if t then task.spawn(waitReady, t.player, 10) end
	end
end

function MusicManager.Play(name: string, fadeTime: number?, restart: boolean?)
	local fade = fadeTime or 2
	if current == name then return end
	local nextTrack = getTrack(name)
	if not nextTrack then return end

	local prevName = current
	current = name

	task.spawn(function()
		waitReady(nextTrack.player, 5)
		if current ~= name then return end -- another Play() happened while loading
		if restart or not nextTrack.player.IsPlaying then
			nextTrack.player.TimePosition = 0
			nextTrack.player:Play()
		end
		fadeTo(nextTrack, 1, fade, Enum.EasingDirection.Out)

		if prevName then
			local prev = tracks[prevName]
			if prev then
				fadeTo(prev, 0, fade, Enum.EasingDirection.In, function()
					if current ~= prevName then prev.player:Stop() end
				end)
			end
		end
	end)
end

function MusicManager.Stop(fadeTime: number?)
	local name = current
	current = nil
	if not name then return end
	local t = tracks[name]
	if t then
		fadeTo(t, 0, fadeTime or 1.5, Enum.EasingDirection.In, function()
			if current ~= name then t.player:Stop() end
		end)
	end
end

-- Temporarily lower music (stingers, cutscene lines, big SFX)
function MusicManager.Duck(level: number, fadeTime: number, holdTime: number)
	duckToken += 1
	local token = duckToken
	duckLevel = math.clamp(level, 0, 1)
	applyBus(fadeTime)
	task.delay(holdTime, function()
		if token ~= duckToken then return end
		duckLevel = 1
		applyBus(1.0)
	end)
end

function MusicManager.SetUserVolume(v: number)
	userVolume = math.clamp(v, 0, 1)
	applyBus(0.15)
end

-- Plays a one-shot stinger (instrumental) on the music bus's output with ducking
function MusicManager.Stinger(asset: string, volume: number?)
	local p = Instance.new("AudioPlayer")
	p.Asset = asset
	p.Volume = (volume or 1) * userVolume
	p.Parent = root
	wire(p, output)
	task.spawn(function()
		if not waitReady(p, 3) then p:Destroy() return end
		MusicManager.Duck(0.3, 0.15, math.max(p.TimeLength - 0.5, 0.5))
		p:Play()
		p.Ended:Once(function() p:Destroy() end)
	end)
end

function MusicManager.Current(): string?
	return current
end

return MusicManager
```

Zone music driver (client):

```lua
-- StarterPlayerScripts/MusicZones.client.luau
-- Parts in workspace.MusicZones with attribute Track="Forest". Uses spatial query every 0.5 s.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MusicManager = require(ReplicatedStorage.Shared.MusicManager)

MusicManager.Register("Lobby", "rbxassetid://0", { loopRegion = NumberRange.new(0, 96) })   -- REPLACE ids
MusicManager.Register("Forest", "rbxassetid://0")
MusicManager.Register("Boss", "rbxassetid://0")
MusicManager.Preload({ "Lobby", "Forest" })
MusicManager.Play("Lobby", 0.5)

local params = OverlapParams.new()
params.FilterType = Enum.RaycastFilterType.Include
params.FilterDescendantsInstances = { workspace:WaitForChild("MusicZones") }

while true do
	task.wait(0.5)
	local char = Players.LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if root then
		local hits = workspace:GetPartBoundsInRadius(root.Position, 0.5, params)
		local track = "Lobby"
		for _, part in hits do
			local t = part:GetAttribute("Track")
			if typeof(t) == "string" then track = t break end
		end
		MusicManager.Play(track, 2.5)
	end
end
```

Legacy fallback: if you must use `Sound`, the same design works with one `Sound` per track (`Looped = true`, optional `LoopRegion` + `PlaybackRegionsEnabled = true`), parented to a `SoundGroup` "Music", tweening `Sound.Volume` for crossfades.

### 12.6 Footstep system by material

```lua
-- ReplicatedStorage/Shared/Footsteps.luau
--!strict
-- Client-side: call Footsteps.Attach(character) for EVERY character the client sees
-- (local + others) so everyone hears steps without network traffic.
-- Requires SoundService.DefaultListenerLocation = Camera or Character (set in Studio).
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Footsteps = {}

-- REPLACE with licensed, non-vocal footstep variants (3-5 per surface).
local SOUNDS: { [string]: { string } } = {
	Default = { "rbxassetid://0", "rbxassetid://0", "rbxassetid://0" },
	Grass   = { "rbxassetid://0", "rbxassetid://0", "rbxassetid://0" },
	Wood    = { "rbxassetid://0", "rbxassetid://0", "rbxassetid://0" },
	Stone   = { "rbxassetid://0", "rbxassetid://0", "rbxassetid://0" },
	Metal   = { "rbxassetid://0", "rbxassetid://0", "rbxassetid://0" },
	Sand    = { "rbxassetid://0", "rbxassetid://0", "rbxassetid://0" },
	Snow    = { "rbxassetid://0", "rbxassetid://0", "rbxassetid://0" },
	Water   = { "rbxassetid://0", "rbxassetid://0", "rbxassetid://0" },
	Glass   = { "rbxassetid://0", "rbxassetid://0", "rbxassetid://0" },
	Fabric  = { "rbxassetid://0", "rbxassetid://0", "rbxassetid://0" },
}

local M = Enum.Material
local MATERIAL_TO_SURFACE: { [Enum.Material]: string } = {
	[M.Grass] = "Grass", [M.LeafyGrass] = "Grass", [M.Ground] = "Grass", [M.Mud] = "Grass",
	[M.Wood] = "Wood", [M.WoodPlanks] = "Wood", [M.Cardboard] = "Wood",
	[M.Concrete] = "Stone", [M.Brick] = "Stone", [M.Cobblestone] = "Stone", [M.Slate] = "Stone",
	[M.Granite] = "Stone", [M.Marble] = "Stone", [M.Rock] = "Stone", [M.Basalt] = "Stone",
	[M.Pavement] = "Stone", [M.Asphalt] = "Stone", [M.Limestone] = "Stone", [M.Sandstone] = "Stone",
	[M.Pebble] = "Stone", [M.CeramicTiles] = "Stone", [M.ClayRoofTiles] = "Stone",
	[M.Metal] = "Metal", [M.DiamondPlate] = "Metal", [M.CorrodedMetal] = "Metal", [M.Foil] = "Metal",
	[M.Sand] = "Sand", [M.Salt] = "Sand",
	[M.Snow] = "Snow", [M.Ice] = "Snow", [M.Glacier] = "Snow",
	[M.Glass] = "Glass",
	[M.Fabric] = "Fabric", [M.Carpet] = "Fabric", [M.Leather] = "Fabric", [M.Rubber] = "Fabric",
	[M.Water] = "Water",
}

local STRIDE_WALK = 4.2 -- studs per step at walk speed
local STRIDE_RUN = 5.5
local VOICES_PER_CHAR = 3

type State = {
	character: Model, humanoid: Humanoid, root: BasePart,
	emitter: AudioEmitter, players: { AudioPlayer }, nextVoice: number,
	distance: number, lastIndex: { [string]: number }, conns: { RBXScriptConnection },
}

local states: { [Model]: State } = {}

local function pickVariant(state: State, surface: string): string
	local list = SOUNDS[surface] or SOUNDS.Default
	if #list == 1 then return list[1] end
	local last = state.lastIndex[surface] or 0
	local i = math.random(1, #list - 1)
	if i >= last then i += 1 end -- never repeat the previous variant
	state.lastIndex[surface] = i
	return list[i]
end

local function playStep(state: State, loud: boolean?)
	local surface = MATERIAL_TO_SURFACE[state.humanoid.FloorMaterial] or "Default"
	local voice = state.players[state.nextVoice]
	state.nextVoice = state.nextVoice % #state.players + 1
	voice:Stop()
	voice.Asset = pickVariant(state, surface)
	local isLocal = state.character == Players.LocalPlayer.Character
	local base = if isLocal then 0.55 else 0.8
	voice.Volume = base * (if loud then 1.6 else 1) * (0.9 + math.random() * 0.2)
	voice.PlaybackSpeed = 0.92 + math.random() * 0.16
	voice.TimePosition = 0
	voice:Play()
end

function Footsteps.Attach(character: Model)
	if states[character] then return end
	local humanoid = character:WaitForChild("Humanoid", 10) :: Humanoid?
	local root = character:WaitForChild("HumanoidRootPart", 10) :: BasePart?
	if not humanoid or not root then return end

	-- silence the default running sound (legacy Sound or new-API AudioPlayer named "Running")
	local function mute(inst: Instance)
		if inst.Name == "Running" then
			if inst:IsA("Sound") then inst.Volume = 0 end
			if inst:IsA("AudioPlayer") then inst.Volume = 0 end
		end
	end
	for _, d in root:GetDescendants() do mute(d) end

	local emitter = Instance.new("AudioEmitter")
	emitter.Name = "FootstepEmitter"
	emitter.DistanceAttenuationMode = Enum.DistanceAttenuationMode.InverseTapered
	emitter.DistanceAttenuationBounds = NumberRange.new(5, 60)
	emitter.Parent = root

	local voices = {}
	for i = 1, VOICES_PER_CHAR do
		local p = Instance.new("AudioPlayer")
		p.Name = "Step" .. i
		p.Parent = emitter
		local w = Instance.new("Wire")
		w.SourceInstance = p
		w.TargetInstance = emitter
		w.Parent = p
		table.insert(voices, p)
	end

	local state: State = {
		character = character, humanoid = humanoid, root = root, emitter = emitter,
		players = voices, nextVoice = 1, distance = 0, lastIndex = {}, conns = {},
	}
	states[character] = state

	table.insert(state.conns, root.DescendantAdded:Connect(mute))

	table.insert(state.conns, RunService.Heartbeat:Connect(function(dt)
		if humanoid.Health <= 0 then return end
		if humanoid.FloorMaterial == Enum.Material.Air then return end
		local v = root.AssemblyLinearVelocity
		local speed = Vector2.new(v.X, v.Z).Magnitude
		if speed < 1.5 then
			state.distance = math.min(state.distance, STRIDE_WALK * 0.5) -- first step comes quickly
			return
		end
		local stride = if speed > 18 then STRIDE_RUN else STRIDE_WALK
		state.distance += speed * dt
		if state.distance >= stride then
			state.distance -= stride
			playStep(state)
		end
	end))

	table.insert(state.conns, humanoid.StateChanged:Connect(function(_, new)
		if new == Enum.HumanoidStateType.Landed then
			local fall = math.abs(root.AssemblyLinearVelocity.Y)
			playStep(state, fall > 30)
			state.distance = 0
		end
	end))

	table.insert(state.conns, character.Destroying:Connect(function()
		Footsteps.Detach(character)
	end))
	table.insert(state.conns, humanoid.Died:Connect(function()
		Footsteps.Detach(character)
	end))
end

function Footsteps.Detach(character: Model)
	local state = states[character]
	if not state then return end
	states[character] = nil
	for _, c in state.conns do c:Disconnect() end
	if state.emitter.Parent then state.emitter:Destroy() end
end

-- Convenience: attach to all current and future characters
function Footsteps.Start()
	local function onPlayer(plr: Player)
		if plr.Character then task.spawn(Footsteps.Attach, plr.Character) end
		plr.CharacterAdded:Connect(function(c) Footsteps.Attach(c) end)
	end
	for _, plr in Players:GetPlayers() do onPlayer(plr) end
	Players.PlayerAdded:Connect(onPlayer)
end

return Footsteps
```

Upgrade path: if your walk/run animations have `Footstep` markers, replace the distance accumulator with `track:GetMarkerReachedSignal("Footstep")` for perfect sync, and emit a small dust puff (`Recipes.Dust`, `Emit(2)`) at the foot. For performance with many players, skip characters more than 80 studs from the camera before calling `playStep`.

---

## 13. Checklists

### Per-feature juice pass
- [ ] Input acknowledged within 1 frame (sound or visual), even if the server result comes later.
- [ ] Anticipation pose or charge-up for anything powerful.
- [ ] Impact: flash + hitstop (if combat) + layered sound + particles + shake scaled to importance.
- [ ] Follow-through: lingering smoke/embers, recovery animation, popups.
- [ ] Randomization: pitch, rotation, position jitter, variant sounds.
- [ ] UI reacts (counter pop, bar tween, toast).
- [ ] Mobile haptic for key moments (with a setting toggle).
- [ ] Works at graphics quality 1 and with reduced motion.

### Audio pass
- [ ] All assets licensed (Creator Store or owned) and uploaded or permitted for the game's owner (group).
- [ ] Music instrumental, loops seamlessly (seam tested), crossfades between states.
- [ ] Separate Music/SFX sliders and a mute; music default ≤ 0.5 bus volume.
- [ ] `DefaultListenerLocation` set if using AudioEmitters.
- [ ] 3D sounds have sensible attenuation; the local player's sounds are crisp.
- [ ] Concurrency caps and limiter on the SFX bus.
- [ ] No vocal SFX unless requested.

### Animation pass
- [ ] Tracks loaded once and reused; correct priorities.
- [ ] Markers for hit frames, footsteps and VFX.
- [ ] Animations published under the game owner (user/group).
- [ ] Walk/run speed matches animation (no foot sliding).
- [ ] Idle has life (breathing / variants); no T-poses.

### Camera pass
- [ ] Shake uses trauma + Perlin, attenuated by distance, scaled by settings and `ReducedMotionEnabled`.
- [ ] FOV changes ≤ 15°, smoothed.
- [ ] Cutscenes skippable, restore camera state, no trapping after death.

### Performance pass
- [ ] Emitters disabled or culled when far; bursts instead of high rates.
- [ ] FX lights have `Shadows = false`.
- [ ] Highlights toggled, not recreated.
- [ ] All spawned FX cleaned (`Debris` or pool); 10-minute soak shows a stable instance count.
- [ ] MicroProfiler checked on a phone or the emulator at low quality.

---

## Sources

Official (local mirror at `reference/creator-docs/content/en-us`, snapshot 2026-11-05):
- `effects/particle-emitters.md` (rates: 400/s, 100/s mobile; squash; flipbooks; rain; particle limits), `effects/beams.md`, `effects/trails.md`, `effects/highlighting.md` (255 limit, performance tips), `effects/light-sources.md`
- `audio/objects.md` (2D/3D graphs; Sound/SoundGroup/SoundEffect discouraged), `audio/effects.md`, `audio/assets.md` (Creator Store, import limits, formats, privacy, visibility)
- `animation/using.md` (Animator, markers, replacing defaults, weights), `animation/events.md`, `animation/editor.md`, `animation/inverse-kinematics.md`, `animation/graph-editor.md`, `animation/graph-editor-state-machine.md`, `animation/capture.md`
- `workspace/camera/index.md`, `tutorials/use-case-tutorials/input-and-camera/control-the-users-camera.md`, `tutorials/use-case-tutorials/vfx/*`, `tutorials/use-case-tutorials/audio/add-2D-audio.md`, `add-3D-audio.md`
- `input/mobile.md` and `input/gamepad.md` (HapticEffect)
- Class/enum reference YAML: ParticleEmitter, Beam, Trail, Attachment, Highlight, Light, PointLight, SpotLight, SurfaceLight, Fire, Smoke, Camera, TweenService, Animator, AnimationTrack, IKControl, AnimationConstraint, AudioPlayer, AudioEmitter, AudioListener, AudioDeviceOutput, Wire, AudioFader, AudioEqualizer, AudioReverb, AudioCompressor, AudioFilter, AudioLimiter, AudioEcho, AudioPitchShifter, AudioAnalyzer, Sound, SoundGroup, SoundService, HapticService, HapticEffect, GuiService, BillboardGui, Humanoid; enums AnimationPriority, HapticEffectType, DistanceAttenuationMode, ListenerLocation, RollOffMode, CameraType, ParticleOrientation, ParticleFlipbookLayout/Mode, ParticleEmitterShape/Style, Material, EasingStyle
- Live docs: https://create.roblox.com/docs/audio/assets, https://create.roblox.com/docs/effects/particle-emitters

Local libraries (`reference/libraries`): Sleitnick RbxUtil `Shake` and `Spring` modules; Quenty NevermoreEngine `spring`, `camera`, `soundplayer`.

Community and talks (treated as data; summarized, not copied):
- Martin Jonasson & Petri Purho, "Juice It or Lose It" (Nordic Game, 2012)
- Jan Willem Nijman (Vlambeer), "The Art of Screenshake" (INDIGO Classes, 2013); recreation breakdown: https://dkliao.itch.io/the-art-of-screenshake-recreation/devlog/451576/quick-breakdown-of-all-the-effects
- Squirrel Eiserloh, "Math for Game Programmers: Juicing Your Cameras With Math" (GDC 2016): trauma-based Perlin shake
- Fraktality `spr`: https://github.com/Fraktality/spr ; DevForum "Spring-driven motion - spr": https://devforum.roblox.com/t/spring-driven-motion-spr/714728
- Sleitnick RbxCameraShaker (EZ Camera Shake port): https://devforum.roblox.com/t/ez-camera-shake-ported-to-roblox/98482
- DevForum `:Emit()` timing threads: https://devforum.roblox.com/t/particles-not-emitting/3884974 , https://devforum.roblox.com/t/emit-not-running/2851677 , https://devforum.roblox.com/t/particles-not-emitting-correctly/3628659 ; VFX breakdown: https://devforum.roblox.com/t/breakdown-on-how-vfx-work/1827443
- Emit attribute conventions in third-party tools: https://qp2-docs.pages.dev/guide/from-script/emission/ , https://zilibobi.github.io/forge-docs/effects/particle
- Roblox music partnerships: https://devforum.roblox.com/t/roblox-monstercat-3/688452 , https://devforum.roblox.com/t/amplify-your-experiences-with-new-music/3164792 , https://devforum.roblox.com/t/how-to-find-good-music-in-robloxs-audio-library-using-the-apm-music-website/2149632
