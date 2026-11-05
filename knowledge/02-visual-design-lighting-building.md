# 02 — Visual Design, Lighting & Building for Roblox

> Chapter goal: give the bot everything it needs to make an ORIGINAL Roblox game look good. That means the kind of build that gets praised in DevForum "Creations Feedback" threads, on Roblox dev X/Twitter, and in ArtStation/Polycount-style critique, while still running on a low-end phone.
>
> Written 2026-11-05. Property names, class defaults and enum values were checked against the local API reference (`.sources/Roblox_creator-docs/content/en-us/reference/engine/**.yaml`) and the client API dump (`.sources/MaximumADHD_Roblox-Client-Tracker/Full-API-Dump.json`).
>
> Tags: **[official]** = Roblox docs or API reference. **[community]** = DevForum and other community sources: opinions, so treat them as starting points. **[synth]** = a starting value I derived from official tutorial numbers plus community posts. Always tune [synth] values by eye in the actual scene.

---

## 0. TL;DR rules for the bot

1. **Pick the art style and palette before placing a single part.** Fill in the Visual Style Spec (§17) first. Consistency across the whole game counts for more than how detailed any one asset is.
2. **`Lighting.Technology` is deprecated [official].** Lighting is now set by `Lighting.LightingStyle` (`Realistic` | `Soft`) and `Lighting.PrioritizeLightingQuality` (bool). The old modes map like this: Future ≈ Realistic + Prioritize=true, ShadowMap ≈ Soft + Prioritize=true, Voxel ≈ Soft + Prioritize=false [community, from the Unified Lighting announcement]. Both properties can be set by script.
3. **Defaults:** use `Realistic` for anything moody, interior-heavy, neon, horror or realistic. Use `Soft` for bright cartoon, simulator, obby, or the "classic Roblox" look. In both cases the engine scales quality down on weak devices by itself. Shadows switch off entirely below graphics quality level 4 [official].
4. **Never ship default lighting.** At minimum, set ClockTime, Ambient/OutdoorAmbient tint, an Atmosphere, a ColorCorrection grade and a Bloom. That takes 5 minutes and moves a scene from "baseplate" to "intentional".
5. **Keep Ambient ≤ OutdoorAmbient in every channel [official].** Tint them both. Pure grey ambient is the No. 1 "default look" tell. Cool shadows plus warm light is the safe fallback.
6. **If EnvironmentDiffuseScale / EnvironmentSpecularScale go up toward 1, bring Ambient/OutdoorAmbient down [official].** Metalness does nothing while EnvironmentSpecularScale = 0 [official].
7. **Fog: use `Atmosphere`, not `FogStart`/`FogEnd`.** The legacy fog properties are hidden and ignored while an Atmosphere exists [official].
8. **Post-processing should be subtle.** ColorCorrection Saturation ±0.3, Contrast ≤ 0.2. Keep Bloom Threshold ≥ ~0.9 unless the scene is dark. Use SunRays Intensity 0.02–0.15. Don't use DepthOfField in gameplay cameras except for menus, shops and cutscenes.
9. **Scale everything to the character.** Avatars are roughly 5 studs (classic) to 6.5 studs (humanoid/Rthro) tall [official]. Doors: 7–8 studs tall, 4–6 wide. Rooms: 10–14 studs floor-to-ceiling. Hallways: ≥ 8 wide (≥ 10 for combat/multiplayer traffic). Default jump height is 7.2 studs, so a "blocking" wall must be > 7.5 studs [official default].
10. **No flat, untextured, sharp-edged default-grey blocks in a finished build.** Every surface gets an intentional material and colour, and important edges get a bevel or a trim piece.
11. **Detail hierarchy is 60/30/10:** primary forms (big silhouettes) → secondary (trims, frames, supports) → tertiary (props, decals, grime). Rough out the primaries first and judge them from the player's camera height.
12. **Guide the eye:** one landmark visible from spawn, paths that act as leading lines, light and colour accents on goals, calm negative space around key interactables.
13. **Reuse meshes.** Instancing collapses copies of the same MeshId + texture into one draw call [official]. Upload each mesh once and duplicate it in Studio.
14. **Budget for low-end mobile:** keep Draw (scene) under ~1,000 draw calls and ~1M triangles on the baseline device [official]. Community guidance is stricter: 500 draw calls / 500k triangles. Limit shadow-casting local lights, partial transparency and particles.
15. **Mesh hygiene:** under 20,000 triangles per mesh [official hard limit]. Set CollisionFidelity = Box/Hull for decoration. Leave RenderFidelity = Automatic and never mass-set Precise. Small decorative parts get CastShadow = false, CanCollide/CanTouch/CanQuery = false, and Anchored = true.
16. **Textures:** 256² for ~5-stud props, 512² for ~10-stud, 1024² for ~20-stud [official]. Built-in materials use far less memory than custom textures, so use them wherever they work [official].
17. **StreamingEnabled is on by default.** Design for pop-in: set Model.LevelOfDetail = SLIM (or StreamingMesh) on landmarks, and use Atmosphere density so far edges fade instead of hard-cutting.
18. **Realistic lighting needs walls ≥ 1 stud thick** to avoid light leaking indoors [official].
19. **Test on a phone-class device at low graphics** before calling anything finished. A showcase that only looks good at graphics level 10 on PC is a failed game build.
20. **Original work only:** no copying named games' palettes or assets wholesale. Free-model mixing is the No. 2 "amateur" tell, because styles clash.

---

## 1. Lighting technology in 2026 (Unified Lighting)

### 1.1 What changed [official + community]
- `Lighting.Technology` is **Deprecated** and has `RobloxScriptSecurity`, so scripts can't read or write it. It has been "superseded by `LightingStyle` … and `PrioritizeLightingQuality`" [official, Lighting.yaml].
- `Enum.LightingStyle` has two values. `Realistic`: "The most advanced and realistic lighting and shadows Roblox can deliver." `Soft`: "A flat, retro-Roblox look with softer lights and shadows." [official]
- `PrioritizeLightingQuality`: "As the rendering quality level reduces, a setting of `true` prioritizes features such as advanced shadows and high-quality shaders at closer distances, while `false` prioritizes view distance. If lighting and shadows are very important to the artistic feel of your game, set this to `true`." [official]
- The Unified Lighting announcement ("Let There Be (Unified) Light! … Fully Live") maps the legacy modes as **Future → Realistic + Prioritize on; ShadowMap → Soft + Prioritize on; Voxel → Soft + Prioritize off** [community-reported summary of the official post]. Some places got darker after the migration. The reported fix is to re-tune Brightness/Exposure, or to add `ColorGradingEffect.TonemapperPreset = Retro` for the old look [community].
- **Soft + Prioritize=true uses shadow maps rather than voxel lighting** [official, LightingStyle description].
- `ShadowSoftness` only matters under `Realistic` [official].
- `Enum.Technology` still lists Legacy, Voxel, Compatibility, ShadowMap, Future and Unified, but treat them as legacy. Don't write code that depends on them.
- Both new properties have script security `None` in the API dump, so they can be set from the command bar, plugins or scripts. Set them at edit time anyway. Runtime switching is untested territory.
- Class defaults from the API dump (what `Instance.new` gives): `LightingStyle = Realistic`, `PrioritizeLightingQuality = true`. The official tutorials say "Studio begins every game with `Soft` lighting", so **always check and set the value explicitly**.

### 1.2 Cost and device behaviour
| Setting | Look | Relative cost | Notes |
|---|---|---|---|
| Realistic + Prioritize=true (≈Future) | Per-pixel local lights with shadows, specular highlights, crisp sun shadows | Highest | Best for neon, interiors, horror, realistic. On low-end devices it falls back to cheaper paths automatically. Community reports say old Future was rough on <2 GB RAM phones. |
| Soft + Prioritize=true (≈ShadowMap) | Sun shadow maps, softer local lights, flatter | Medium | Good default for stylized and cartoon outdoor games. |
| Soft + Prioritize=false (≈Voxel) | Flat, retro, 4×4×4 voxel light grid | Lowest | Obbies, huge maps, mass-player hangouts, classic/retro revival. |
| `GlobalShadows = false` | No sky occlusion at all, so OutdoorAmbient is ignored and Ambient applies everywhere [official] | Cheapest | The "Pet-Sim bright" look. Kills depth, so compensate with ColorShift_Top / contrast. |

- All modes share the voxel light grid as their base. "Future" adds shadow-mapped lighting for nearby lights on top of it [community, engine-engineer reply].
- **The engine degrades shadow quality as graphics quality drops and disables shadows below quality level 4** [official, performance docs]. Don't depend on shadows for gameplay readability (for example, telling where a platform edge is). Use colour and value contrast too.
- Local light `Range` is always clamped to 120 studs (`ExtendLightRangeTo120` is unused) [official].
- Shadow cost scales with the number and density of shadow-casting lights and small shadow-casting parts [official]. Mitigations: `Light.Shadows = false` on fill and decorative lights, smaller Range/Angle, fewer lights, room-by-room enabling, `BasePart.CastShadow = false` on small or distant parts [official].
- **Realistic interiors:** surround indoor spaces with parts ≥ 1 stud thick to prevent light leaks [official, indoor tutorial].

### 1.3 Decision rule
```
if style in {realistic, horror, sci-fi neon, cozy interior, night city}: Realistic, Prioritize=true
elif style in {cartoon/simulator, low-poly adventure, tycoon}:          Soft, Prioritize=true
elif style in {obby, classic/retro, 50+ player hangout, giant map}:     Soft, Prioritize=false
```
Then playtest at graphics level 1–3 and make sure the game still reads without shadows.

---

## 2. Lighting service property reference

Class defaults come from the API dump. They're what you get from a fresh `Lighting` instance, and **Studio templates override several of them**, so read your actual place. "Good range" is the band where scenes usually look right.

| Property | Type | Class default | Hard range | Good range | Notes |
|---|---|---|---|---|---|
| `LightingStyle` | Enum | Realistic | Realistic/Soft | — | See §1. |
| `PrioritizeLightingQuality` | bool | true | — | true unless huge map | |
| `Brightness` | float | 1 | ≥0 | Day 2–3.5 (Soft) / 2–4 (Realistic); dusk 1–2; night 0.3–1 | Sun/moon intensity. Official examples: 0.5, 1.5, 3.75. |
| `ExposureCompensation` | float | 0 | −5 to 5 [official] | −0.5 to +0.5 | +1 = 2× exposure. Official indoor tutorial uses 0.5. A community "crispy" trick is −3 with high Brightness, but it fails at night. |
| `Ambient` | Color3 | (128,128,128) dump; doc says black | each ch ≤ OutdoorAmbient | Interiors (0–90) dark, tinted | Light in sky-occluded areas. |
| `OutdoorAmbient` | Color3 | (128,128,128) | ≥ Ambient | (60–160), tinted | Outdoor fill. Official evening example: (156,136,176) lilac. |
| `ColorShift_Top` | Color3 | (0,0,0) | — | subtle warm, e.g. (255,230,200) at low sun | Tint on sun-facing surfaces. |
| `ColorShift_Bottom` | Color3 | (0,0,0) | — | subtle cool | Tint on surfaces facing away from the sun. |
| `EnvironmentDiffuseScale` | float | 0 | 0–1 | Realistic 0.6–1; stylized 0.2–0.5 | Sky-derived ambient. Raise it and lower Ambient/OutdoorAmbient [official]. Some builders keep it < 1 because it washes out cool tones [community]. |
| `EnvironmentSpecularScale` | float | 0 | 0–1 | Realistic 1; stylized 0.2–0.5 | Needed for metal/reflections. Metalness maps do nothing at 0 [official]. |
| `GlobalShadows` | bool | false (dump) | — | true (except "flat bright" style) | |
| `ShadowSoftness` | float | 0.5 dump (doc says 0.2) | 0–1 | 0.1–0.3 crisp sun; 0.4–0.6 overcast | Realistic only [official]. |
| `ClockTime` | float | 14 | 0–24 | See table below | `TimeOfDay` is the string twin. |
| `GeographicLatitude` | float | 41.733 | degrees | 0–45 for tall midday sun; tune to cast shadows *across* the main play path | Official samples use 323 (≈ −37) and −18. |
| `FogColor/FogStart/FogEnd` | — | 0.75 grey / 0 / 100000 | — | Don't use with Atmosphere | Hidden when an Atmosphere exists [official]. |

### ClockTime cheat sheet [synth]
| Mood | ClockTime | Latitude hint |
|---|---|---|
| Crisp morning | 7.5–9 | 30–45 (long shadows) |
| Bright midday cartoon | 12.5–14 | 20–40 |
| Afternoon "golden-ish" | 15.5–16.5 | official indoor sample 15.6 + lat 323 |
| Sunset | 17.3–18.2 | official outdoor sample 17 |
| Blue hour | 18.4–18.9 | |
| Night | 20–4 (0 = darkest) | Moon position also follows latitude |

Run a day/night cycle only if gameplay needs it. Every preset in this chapter assumes a fixed time, and a cycle forces you to tune many states.

---

## 3. Atmosphere

Properties (verified): `Density`, `Offset`, `Color`, `Decay`, `Glare`, `Haze`. Class defaults: Density 0.395, Offset 0, Color (200,170,108), Decay (92,60,14), Glare 0, Haze 0.

| Property | What it does [official] | Range | Good range |
|---|---|---|---|
| `Density` | Amount of air particles. Obscures objects and terrain, and the skybox seen through them | 0–1 | Clear day 0.2–0.32; hazy 0.35–0.45; fog/horror 0.5–0.75; underwater 0.6–0.8 |
| `Offset` | Light transmission between the camera and the sky. High values silhouette the horizon, low values blend distant objects into the sky | 0–1 | 0–0.3 seamless open world; 0.5–0.7 dramatic horizon silhouettes (official curriculum sample 0.65) |
| `Color` | Atmosphere hue. Most visible with high Haze | Color3 | Match the sky's horizon colour |
| `Decay` | Hue away from the sun. Needs Haze **and** Glare > 0 | Color3 | Darker/cooler complement of Color |
| `Glare` | Glow around the sun. Needs Haze > 0 | 0–10 (Studio slider) | 0 (night/indoor) to 0.3–2 (sunsets) |
| `Haze` | Haziness above the horizon and in the distance | 0–10 (Studio slider) | 0.5–2.5 typical; official samples use 1, 2, 2.8 |

Rules:
- **Balance Offset against Density.** A low offset can show the skybox through geometry, and a high offset leaves distant terrain too detailed [official warning].
- Haze, Glare and Decay only show when chained: Glare needs Haze, Decay needs both [official].
- Density is the cheapest way to hide the streaming edge and the far LOD (§13).
- Some atmosphere scattering is reduced at low graphics levels [community], so check that fog-gated gameplay (horror) still works.
- Official reference values: outdoor campfire tutorial Density 0.272, Haze 1, Color (85,78,54); indoor tutorial Density 0.5; environment-art curriculum Density 0.285, Offset 0.65, Glare 0.3, Haze 2.

---

## 4. Sky, skyboxes, clouds

### 4.1 Sky (verified properties)
`SkyboxBk/Dn/Ft/Lf/Rt/Up` (ContentId; `Skybox*Content` twins), `SkyboxOrientation` (Vector3, applied Y→X→Z), `SunAngularSize` (default 21, clamped 0–60), `MoonAngularSize` (default 11, 0–60), `SunTextureId`, `MoonTextureId`, `StarCount` (default 3000), `CelestialBodiesShown` (default true).

- A skybox has 6 seamless images that must tile along all edges when folded into a cube [official].
- Hide the sun/moon but keep the stars by setting `SunAngularSize`/`MoonAngularSize = 0` [official].
- `SkyboxOrientation` is cheap and works on all platforms. Use it to slowly spin a stylized sky (official sample: 5°/s around Y with a 30° X tilt). Celestial bodies don't rotate with it [official].
- **Make the sky part of the palette.** The sky drives EnvironmentDiffuse/Specular light, so a purple sky tints the scene purple once those are raised.
- Original games should use **original skyboxes**. Paint 6 faces, render a cubemap in Blender, or generate and paint over. A recognizable stock skybox reads as low effort.
- Stylized games: a simple gradient plus soft cloud shapes reads cleaner than photo skies. Realistic games: photo HDRI-derived cubes.

### 4.2 Dynamic clouds [official]
- `Clouds` renders **only when parented under `Workspace.Terrain`**. Properties: `Cover` (0–1, default 0.5), `Density` (default 0.7), `Color` (default white), `Enabled`.
- Lighting and Atmosphere also tint clouds. Clouds move with `Workspace.GlobalWind`, which also drives terrain grass sway (and particles that opt in).
- Starting points [synth]: fair-weather cartoon Cover 0.45, Density 0.5. Stormy Cover 0.85, Density 0.9, Color (150,155,165). Sunset Cover 0.55, Density 0.6 (the sun colours them).

---

## 5. Post-processing

All effects go in `Lighting` (everyone sees them) or `Workspace.CurrentCamera` (per player, for low-HP tint, menu blur or underwater) [official]. Only the most recently parented `ColorGradingEffect` applies [official].

| Effect | Properties (verified) | Class defaults | Recommended | Pitfalls |
|---|---|---|---|---|
| `ColorCorrectionEffect` | Brightness, Contrast, Saturation, TintColor | 0, 0, 0, white | Brightness −0.05 to 0.05; Contrast 0–0.2; Saturation −0.4 to 0.3; Tint very near white (e.g. (255,245,230) warm, (230,240,255) cool) | Tint is **multiplicative**: (255,0,0) zeroes green and blue [official]. Saturation > 0.4 looks cheap. Official indoor tutorial: Contrast 0.05, Saturation 0.1. |
| `BloomEffect` | Intensity, Size, Threshold | 0.4, 24, 0.95 | Day: Intensity 0.3–0.6, Size 20–30, Threshold 1.0–1.5. Night/neon: Intensity 0.8–1.5, Size 24–40, Threshold 0.8–1.0 | Threshold 0 = everything blooms. 1 = only pure white [official]. Low thresholds in daylight make skies and white walls glow. |
| `SunRaysEffect` | Intensity, Spread | 0.25, 1 | Intensity 0.02–0.15, Spread 0.2–0.7 | Spread outside 0–1 is undefined behaviour [official]. The default 0.25 is too strong. Official indoor sample: 0.023 / 0.266. |
| `DepthOfFieldEffect` | FarIntensity, FocusDistance, InFocusRadius, NearIntensity | 0.75, 0.05, 10, 0.75 | Gameplay: off, or Far 0.05–0.15 with InFocusRadius ≥ 50. Shops/menus/photo: Far 0.5–1, Near 0.5 | The defaults blur almost everything. Never ship them as-is. Blurring hides your build work and makes mobile text unreadable. |
| `BlurEffect` | Size | 24 | 6–16 behind menus, camera-parented | Whole-screen blur. Only for UI states. |
| `ColorGradingEffect` | TonemapperPreset | Default | `Default` = post-2019 vivid, high contrast. `Retro` = pre-2019 look | For a full retro look: Retro plus all lights ≤ Brightness 1.0 [official]. |

**Neon and glow [community]:** neon glow depends on part colour brightness as well as Bloom. Dark neon colours won't glow, so use bright, near-white-saturated colours. A Bloom Threshold just above 1 stops the sky glowing while neon still glows. For localized glow without global bloom, add a small, bright PointLight or SurfaceLight, or use a SurfaceAppearance `EmissiveMaskContent` with `EmissiveStrength`. Emissive values saturate to white if pushed too high [official].

---

## 6. Mood presets [synth]

These presets are tuned starting points. Apply one, then adjust Brightness/Exposure first, then Ambient tint, then Atmosphere. Colours are RGB 0–255.

### 6.1 Lighting
| Preset | Style / Prio | Bright. | Expo | Clock | Lat | Ambient | OutdoorAmb | EnvDiff | EnvSpec | GlobalShadows | ShadowSoft | ColorShift_Top |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Bright cartoon simulator | Soft / true | 3 | 0.1 | 13.5 | 30 | (95,100,120) | (165,165,180) | 0.4 | 0.2 | true | – | (255,245,225) |
| Cozy sunset | Realistic / true | 2 | 0 | 17.7 | 40 | (60,45,55) | (150,110,105) | 1 | 1 | true | 0.3 | (255,200,150) |
| Foggy horror | Realistic / true | 0.6 | −0.4 | 0.5 | 41.7 | (12,12,16) | (38,42,52) | 0.3 | 0.6 | true | 0.15 | (0,0,0) |
| Sci-fi neon | Realistic / true | 1 | 0 | 0 | 20 | (18,16,32) | (50,40,80) | 0.6 | 1 | true | 0.2 | (0,0,0) |
| Realistic daytime | Realistic / true | 3 | −0.2 | 14.5 | 38 | (10,10,15) | (70,75,85) | 1 | 1 | true | 0.2 | (0,0,0) |
| Underwater (camera-local) | Realistic / true | 1 | −0.3 | 13 | 30 | (15,50,70) | (35,100,130) | 0.5 | 0.5 | true | 0.4 | (150,230,255) |
| Night city | Realistic / true | 0.7 | 0.2 | 21.5 | 35 | (22,22,38) | (55,55,85) | 0.5 | 1 | true | 0.2 | (0,0,0) |

### 6.2 Atmosphere + post
| Preset | Atm Density / Offset / Haze / Glare | Atm Color / Decay | CC Bright / Contrast / Sat / Tint | Bloom I / Size / Thr | SunRays I / Spread | DoF |
|---|---|---|---|---|---|---|
| Cartoon simulator | 0.25 / 0.2 / 0.5 / 0 | (200,225,255) / (150,180,230) | 0.02 / 0.1 / 0.25 / (255,252,245) | 0.4 / 24 / 1.2 | 0.05 / 0.4 | off |
| Cozy sunset | 0.35 / 0.15 / 1.8 / 1.5 | (255,190,150) / (120,80,120) | 0 / 0.08 / 0.15 / (255,240,225) | 0.6 / 30 / 1.0 | 0.12 / 0.6 | off |
| Foggy horror | 0.7 / 0 / 2.5 / 0 | (90,95,100) / (40,40,50) | −0.05 / 0.15 / −0.4 / (220,230,255) | 0.3 / 20 / 1.5 | off | off |
| Sci-fi neon | 0.4 / 0.1 / 1.5 / 0 | (120,90,200) / (40,20,80) | 0 / 0.15 / 0.2 / (235,230,255) | 1.0 / 32 / 0.95 | off | off |
| Realistic daytime | 0.3 / 0.25 / 1 / 0.2 | (200,210,225) / (110,120,140) | 0 / 0.05 / 0.05 / (255,252,245) | 0.35 / 24 / 1.2 | 0.04 / 0.3 | optional Far 0.1, Radius 60, Focus 50 |
| Underwater | 0.75 / 0 / 3 / 0 | (40,140,170) / (10,50,80) | 0 / 0.05 / −0.1 / (170,225,255) | 0.5 / 30 / 1.0 | off | Far 0.4, Focus 20, Radius 30, Near 0 |
| Night city | 0.35 / 0.2 / 1.2 / 0 | (90,100,140) / (50,40,80) | 0 / 0.12 / 0.1 / (225,230,255) | 0.8 / 28 / 1.0 | off | off |

Preset notes:
- **Cartoon simulator:** plastic/SmoothPlastic, saturated mid-value colours, chunky bevels. Community trick: `GlobalShadows=false` + OutdoorAmbient (255,255,255) gives the super-flat "Pet Sim" look, but it is easy to overshoot ("burning my eyes"). Prefer the table values.
- **Horror:** the player needs a light source (a camera-local SpotLight flashlight, `Shadows=true` on that one light only). Use Atmosphere for darkness, not near-black Ambient everywhere, or mobile players see nothing. Stage dread with pools of light along the path.
- **Neon:** keep the base world dark and desaturated so neon accents carry the hue (one primary plus one secondary accent). Wet-floor feel comes from `Reflectance`/low-roughness materials with EnvironmentSpecularScale 1.
- **Underwater:** apply it on the client when the camera is below the water surface (check `workspace.Terrain:ReadVoxels` at the camera position, or compare against the water plane height). Restore the previous preset when the camera surfaces. Also tune `Terrain.WaterColor/WaterTransparency`.
- **Night city:** the sky is dark navy, not black. StarCount 300–800 suggests light pollution. Lots of small non-shadow-casting PointLights with Range 8–16, plus a handful of shadow-casting hero lights.

### 6.3 Luau: preset module (runtime or edit time)

```lua
--!strict
-- ReplicatedStorage/LightingPresets (ModuleScript)
-- Usage (server for global look, or client LocalScript for per-player looks):
--   local Presets = require(game.ReplicatedStorage.LightingPresets)
--   Presets.apply("CozySunset")             -- instant
--   Presets.apply("Underwater", 0.6)        -- tween over 0.6 s (numbers/Color3 only)

local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local rgb = Color3.fromRGB
type Props = { [string]: any }
type Preset = {
	lighting: Props,
	atmosphere: Props?,
	colorCorrection: Props?,
	bloom: Props?,
	sunRays: Props?,       -- nil => disabled
	depthOfField: Props?,  -- nil => disabled
	tonemapper: Enum.TonemapperPreset?,
}

local PRESETS: { [string]: Preset } = {
	CartoonSimulator = {
		lighting = {
			LightingStyle = Enum.LightingStyle.Soft, PrioritizeLightingQuality = true,
			Brightness = 3, ExposureCompensation = 0.1, ClockTime = 13.5, GeographicLatitude = 30,
			Ambient = rgb(95, 100, 120), OutdoorAmbient = rgb(165, 165, 180),
			EnvironmentDiffuseScale = 0.4, EnvironmentSpecularScale = 0.2,
			GlobalShadows = true, ColorShift_Top = rgb(255, 245, 225), ColorShift_Bottom = rgb(0, 0, 0),
		},
		atmosphere = { Density = 0.25, Offset = 0.2, Haze = 0.5, Glare = 0,
			Color = rgb(200, 225, 255), Decay = rgb(150, 180, 230) },
		colorCorrection = { Brightness = 0.02, Contrast = 0.1, Saturation = 0.25, TintColor = rgb(255, 252, 245) },
		bloom = { Intensity = 0.4, Size = 24, Threshold = 1.2 },
		sunRays = { Intensity = 0.05, Spread = 0.4 },
	},
	CozySunset = {
		lighting = {
			LightingStyle = Enum.LightingStyle.Realistic, PrioritizeLightingQuality = true,
			Brightness = 2, ExposureCompensation = 0, ClockTime = 17.7, GeographicLatitude = 40,
			Ambient = rgb(60, 45, 55), OutdoorAmbient = rgb(150, 110, 105),
			EnvironmentDiffuseScale = 1, EnvironmentSpecularScale = 1,
			GlobalShadows = true, ShadowSoftness = 0.3,
			ColorShift_Top = rgb(255, 200, 150), ColorShift_Bottom = rgb(0, 0, 0),
		},
		atmosphere = { Density = 0.35, Offset = 0.15, Haze = 1.8, Glare = 1.5,
			Color = rgb(255, 190, 150), Decay = rgb(120, 80, 120) },
		colorCorrection = { Brightness = 0, Contrast = 0.08, Saturation = 0.15, TintColor = rgb(255, 240, 225) },
		bloom = { Intensity = 0.6, Size = 30, Threshold = 1.0 },
		sunRays = { Intensity = 0.12, Spread = 0.6 },
	},
	FoggyHorror = {
		lighting = {
			LightingStyle = Enum.LightingStyle.Realistic, PrioritizeLightingQuality = true,
			Brightness = 0.6, ExposureCompensation = -0.4, ClockTime = 0.5, GeographicLatitude = 41.7,
			Ambient = rgb(12, 12, 16), OutdoorAmbient = rgb(38, 42, 52),
			EnvironmentDiffuseScale = 0.3, EnvironmentSpecularScale = 0.6,
			GlobalShadows = true, ShadowSoftness = 0.15,
			ColorShift_Top = rgb(0, 0, 0), ColorShift_Bottom = rgb(0, 0, 0),
		},
		atmosphere = { Density = 0.7, Offset = 0, Haze = 2.5, Glare = 0,
			Color = rgb(90, 95, 100), Decay = rgb(40, 40, 50) },
		colorCorrection = { Brightness = -0.05, Contrast = 0.15, Saturation = -0.4, TintColor = rgb(220, 230, 255) },
		bloom = { Intensity = 0.3, Size = 20, Threshold = 1.5 },
	},
	SciFiNeon = {
		lighting = {
			LightingStyle = Enum.LightingStyle.Realistic, PrioritizeLightingQuality = true,
			Brightness = 1, ExposureCompensation = 0, ClockTime = 0, GeographicLatitude = 20,
			Ambient = rgb(18, 16, 32), OutdoorAmbient = rgb(50, 40, 80),
			EnvironmentDiffuseScale = 0.6, EnvironmentSpecularScale = 1,
			GlobalShadows = true, ShadowSoftness = 0.2,
			ColorShift_Top = rgb(0, 0, 0), ColorShift_Bottom = rgb(0, 0, 0),
		},
		atmosphere = { Density = 0.4, Offset = 0.1, Haze = 1.5, Glare = 0,
			Color = rgb(120, 90, 200), Decay = rgb(40, 20, 80) },
		colorCorrection = { Brightness = 0, Contrast = 0.15, Saturation = 0.2, TintColor = rgb(235, 230, 255) },
		bloom = { Intensity = 1.0, Size = 32, Threshold = 0.95 },
	},
	RealisticDay = {
		lighting = {
			LightingStyle = Enum.LightingStyle.Realistic, PrioritizeLightingQuality = true,
			Brightness = 3, ExposureCompensation = -0.2, ClockTime = 14.5, GeographicLatitude = 38,
			Ambient = rgb(10, 10, 15), OutdoorAmbient = rgb(70, 75, 85),
			EnvironmentDiffuseScale = 1, EnvironmentSpecularScale = 1,
			GlobalShadows = true, ShadowSoftness = 0.2,
			ColorShift_Top = rgb(0, 0, 0), ColorShift_Bottom = rgb(0, 0, 0),
		},
		atmosphere = { Density = 0.3, Offset = 0.25, Haze = 1, Glare = 0.2,
			Color = rgb(200, 210, 225), Decay = rgb(110, 120, 140) },
		colorCorrection = { Brightness = 0, Contrast = 0.05, Saturation = 0.05, TintColor = rgb(255, 252, 245) },
		bloom = { Intensity = 0.35, Size = 24, Threshold = 1.2 },
		sunRays = { Intensity = 0.04, Spread = 0.3 },
	},
	Underwater = {
		lighting = {
			Brightness = 1, ExposureCompensation = -0.3,
			Ambient = rgb(15, 50, 70), OutdoorAmbient = rgb(35, 100, 130),
			EnvironmentDiffuseScale = 0.5, EnvironmentSpecularScale = 0.5,
			ColorShift_Top = rgb(150, 230, 255),
		},
		atmosphere = { Density = 0.75, Offset = 0, Haze = 3, Glare = 0,
			Color = rgb(40, 140, 170), Decay = rgb(10, 50, 80) },
		colorCorrection = { Brightness = 0, Contrast = 0.05, Saturation = -0.1, TintColor = rgb(170, 225, 255) },
		bloom = { Intensity = 0.5, Size = 30, Threshold = 1.0 },
		depthOfField = { FarIntensity = 0.4, FocusDistance = 20, InFocusRadius = 30, NearIntensity = 0 },
	},
	NightCity = {
		lighting = {
			LightingStyle = Enum.LightingStyle.Realistic, PrioritizeLightingQuality = true,
			Brightness = 0.7, ExposureCompensation = 0.2, ClockTime = 21.5, GeographicLatitude = 35,
			Ambient = rgb(22, 22, 38), OutdoorAmbient = rgb(55, 55, 85),
			EnvironmentDiffuseScale = 0.5, EnvironmentSpecularScale = 1,
			GlobalShadows = true, ShadowSoftness = 0.2,
			ColorShift_Top = rgb(0, 0, 0), ColorShift_Bottom = rgb(0, 0, 0),
		},
		atmosphere = { Density = 0.35, Offset = 0.2, Haze = 1.2, Glare = 0,
			Color = rgb(90, 100, 140), Decay = rgb(50, 40, 80) },
		colorCorrection = { Brightness = 0, Contrast = 0.12, Saturation = 0.1, TintColor = rgb(225, 230, 255) },
		bloom = { Intensity = 0.8, Size = 28, Threshold = 1.0 },
	},
}

-- Properties that cannot be tweened (enums/bools) are always set instantly.
local function isTweenable(v: any): boolean
	local t = typeof(v)
	return t == "number" or t == "Color3"
end

local function getOrCreate(className: string, name: string, parent: Instance): Instance
	local existing = parent:FindFirstChild(name)
	if existing and existing.ClassName == className then
		return existing
	end
	local inst = Instance.new(className)
	inst.Name = name
	inst.Parent = parent
	return inst
end

local function applyProps(inst: Instance, props: Props, duration: number?)
	local tweenGoals: Props = {}
	for key, value in props do
		if duration and duration > 0 and isTweenable(value) then
			tweenGoals[key] = value
		else
			(inst :: any)[key] = value
		end
	end
	if next(tweenGoals) then
		TweenService:Create(inst, TweenInfo.new(duration :: number, Enum.EasingStyle.Sine), tweenGoals):Play()
	end
end

local function setOptionalEffect(className: string, name: string, props: Props?, duration: number?)
	if props then
		local effect = getOrCreate(className, name, Lighting)
		;(effect :: any).Enabled = true
		applyProps(effect, props, duration)
	else
		local effect = Lighting:FindFirstChild(name)
		if effect then
			(effect :: any).Enabled = false
		end
	end
end

local LightingPresets = {}
LightingPresets.names = {} :: { string }
for name in PRESETS do
	table.insert(LightingPresets.names, name)
end

function LightingPresets.apply(name: string, duration: number?)
	local preset = PRESETS[name]
	assert(preset, `Unknown lighting preset "{name}"`)

	applyProps(Lighting, preset.lighting, duration)
	if preset.atmosphere then
		applyProps(getOrCreate("Atmosphere", "Atmosphere", Lighting), preset.atmosphere, duration)
	end
	if preset.colorCorrection then
		applyProps(getOrCreate("ColorCorrectionEffect", "PresetColorCorrection", Lighting), preset.colorCorrection, duration)
	end
	if preset.bloom then
		applyProps(getOrCreate("BloomEffect", "PresetBloom", Lighting), preset.bloom, duration)
	end
	setOptionalEffect("SunRaysEffect", "PresetSunRays", preset.sunRays, duration)
	setOptionalEffect("DepthOfFieldEffect", "PresetDepthOfField", preset.depthOfField, duration)

	local grading = getOrCreate("ColorGradingEffect", "PresetColorGrading", Lighting) :: ColorGradingEffect
	grading.TonemapperPreset = preset.tonemapper or Enum.TonemapperPreset.Default
end

return LightingPresets
```

Notes:
- Global looks go in a server Script (Lighting replicates). Per-player looks (underwater, low-HP, cutscene) go in a LocalScript, which only changes that client's Lighting. For those, consider parenting the post effects to `workspace.CurrentCamera` instead.
- Tweening `ClockTime` across midnight (23 → 1) goes backwards. Handle the wrap yourself.
- The module never creates a `Sky`. Skyboxes are art assets, so place a `Sky` with original textures in Lighting by hand.

### 6.4 Command-bar script (paste into Studio's Command Bar, edit time)
It sets up a scene in one undoable step and prints a summary. Change `PRESET` at the top.

```lua
-- STUDIO COMMAND BAR. Applies a look at edit time, undoable with Ctrl+Z.
local PRESET = "CozySunset" -- CartoonSimulator | CozySunset | FoggyHorror | SciFiNeon | RealisticDay | NightCity
local L = game:GetService("Lighting")
local CHS = game:GetService("ChangeHistoryService")
local rgb = Color3.fromRGB
local P = {
	CartoonSimulator = { style = Enum.LightingStyle.Soft, B = 3, E = 0.1, T = 13.5, Lat = 30, A = rgb(95,100,120), OA = rgb(165,165,180), D = 0.4, S = 0.2,
		atm = {0.25, 0.2, 0.5, 0, rgb(200,225,255), rgb(150,180,230)}, cc = {0.02, 0.1, 0.25, rgb(255,252,245)}, bloom = {0.4, 24, 1.2}, rays = {0.05, 0.4} },
	CozySunset = { style = Enum.LightingStyle.Realistic, B = 2, E = 0, T = 17.7, Lat = 40, A = rgb(60,45,55), OA = rgb(150,110,105), D = 1, S = 1,
		atm = {0.35, 0.15, 1.8, 1.5, rgb(255,190,150), rgb(120,80,120)}, cc = {0, 0.08, 0.15, rgb(255,240,225)}, bloom = {0.6, 30, 1.0}, rays = {0.12, 0.6} },
	FoggyHorror = { style = Enum.LightingStyle.Realistic, B = 0.6, E = -0.4, T = 0.5, Lat = 41.7, A = rgb(12,12,16), OA = rgb(38,42,52), D = 0.3, S = 0.6,
		atm = {0.7, 0, 2.5, 0, rgb(90,95,100), rgb(40,40,50)}, cc = {-0.05, 0.15, -0.4, rgb(220,230,255)}, bloom = {0.3, 20, 1.5} },
	SciFiNeon = { style = Enum.LightingStyle.Realistic, B = 1, E = 0, T = 0, Lat = 20, A = rgb(18,16,32), OA = rgb(50,40,80), D = 0.6, S = 1,
		atm = {0.4, 0.1, 1.5, 0, rgb(120,90,200), rgb(40,20,80)}, cc = {0, 0.15, 0.2, rgb(235,230,255)}, bloom = {1.0, 32, 0.95} },
	RealisticDay = { style = Enum.LightingStyle.Realistic, B = 3, E = -0.2, T = 14.5, Lat = 38, A = rgb(10,10,15), OA = rgb(70,75,85), D = 1, S = 1,
		atm = {0.3, 0.25, 1, 0.2, rgb(200,210,225), rgb(110,120,140)}, cc = {0, 0.05, 0.05, rgb(255,252,245)}, bloom = {0.35, 24, 1.2}, rays = {0.04, 0.3} },
	NightCity = { style = Enum.LightingStyle.Realistic, B = 0.7, E = 0.2, T = 21.5, Lat = 35, A = rgb(22,22,38), OA = rgb(55,55,85), D = 0.5, S = 1,
		atm = {0.35, 0.2, 1.2, 0, rgb(90,100,140), rgb(50,40,80)}, cc = {0, 0.12, 0.1, rgb(225,230,255)}, bloom = {0.8, 28, 1.0} },
}
local p = assert(P[PRESET], "unknown preset")
local ok, rec = pcall(function() return CHS:TryBeginRecording("Apply lighting preset " .. PRESET) end)
local function get(class, name)
	local i = L:FindFirstChildOfClass(class) or Instance.new(class)
	i.Name = name; i.Parent = L; return i
end
L.LightingStyle = p.style; L.PrioritizeLightingQuality = true; L.GlobalShadows = true
L.Brightness = p.B; L.ExposureCompensation = p.E; L.ClockTime = p.T; L.GeographicLatitude = p.Lat
L.Ambient = p.A; L.OutdoorAmbient = p.OA; L.EnvironmentDiffuseScale = p.D; L.EnvironmentSpecularScale = p.S
L.ShadowSoftness = 0.25
local atm = get("Atmosphere", "Atmosphere")
atm.Density, atm.Offset, atm.Haze, atm.Glare, atm.Color, atm.Decay = table.unpack(p.atm)
local cc = get("ColorCorrectionEffect", "ColorCorrection")
cc.Brightness, cc.Contrast, cc.Saturation, cc.TintColor = table.unpack(p.cc)
local bl = get("BloomEffect", "Bloom")
bl.Intensity, bl.Size, bl.Threshold = table.unpack(p.bloom)
local sr = get("SunRaysEffect", "SunRays")
sr.Enabled = p.rays ~= nil
if p.rays then sr.Intensity, sr.Spread = table.unpack(p.rays) end
local dof = L:FindFirstChildOfClass("DepthOfFieldEffect"); if dof then dof.Enabled = false end
if ok and rec then CHS:FinishRecording(rec, Enum.FinishRecordingOperation.Commit) end
print(("[Lighting] %s applied: Style=%s Brightness=%.2f Clock=%.1f AtmDensity=%.2f"):format(PRESET, tostring(L.LightingStyle), L.Brightness, L.ClockTime, atm.Density))
```

### 6.5 Command-bar audit (find visual and perf problems)
```lua
-- STUDIO COMMAND BAR: report common visual/perf issues in Workspace.
local counts = {parts=0, meshes=0, unions=0, defaultGrey=0, precise=0, preciseCollision=0, castShadowSmall=0, partialTransparent=0, lights=0, shadowLights=0, decals=0, particles=0}
local meshIds = {}
for _, d in workspace:GetDescendants() do
	if d:IsA("BasePart") then
		counts.parts += 1
		if d.Material == Enum.Material.Plastic and d.Color == Color3.fromRGB(163,162,165) then counts.defaultGrey += 1 end
		if d.Transparency > 0.02 and d.Transparency < 0.98 then counts.partialTransparent += 1 end
		if d.CastShadow and d.Size.Magnitude < 2 then counts.castShadowSmall += 1 end
		if d:IsA("MeshPart") then
			counts.meshes += 1
			meshIds[d.MeshId] = (meshIds[d.MeshId] or 0) + 1
			if d.RenderFidelity == Enum.RenderFidelity.Precise then counts.precise += 1 end
			if d.CollisionFidelity == Enum.CollisionFidelity.PreciseConvexDecomposition then counts.preciseCollision += 1 end
		elseif d:IsA("UnionOperation") then counts.unions += 1 end
	elseif d:IsA("Light") then
		counts.lights += 1; if d.Shadows then counts.shadowLights += 1 end
	elseif d:IsA("Decal") or d:IsA("Texture") then counts.decals += 1
	elseif d:IsA("ParticleEmitter") then counts.particles += 1 end
end
local unique = 0; for _ in meshIds do unique += 1 end
for k, v in counts do print(k, v) end
print("unique MeshIds", unique)
```
Targets: `defaultGrey` = 0 in finished areas, `precise` ≈ 0, `preciseCollision` only where gameplay needs it, `shadowLights` small (a handful per area), `partialTransparent` small, and unique MeshIds far fewer than total meshes.

---

## 7. Materials, MaterialVariant, SurfaceAppearance, PBR

### 7.1 Built-in materials [official]
- Built-in materials are PBR, so they react to Realistic lighting with proper roughness and metalness. Raise EnvironmentSpecularScale to see metal properly.
- **Built-in materials use far less memory than custom textures** [official]. Make built-ins plus colour your workhorse, and save custom textures for hero assets.
- Texel density: parts show a 1024² texture across an 8×8-stud face, terrain shows 512² per 8×8 studs [official]. Custom textures should roughly match this so assets don't look blurrier or sharper than the world around them.
- `MaterialService.Use2022Materials` switches the built-in pack. Leave it on (modern look) unless you're doing a deliberate retro build.
- Stylized and low-poly: `SmoothPlastic` (Reflectance 0–0.2 [community]) or `Plastic`. Avoid noisy realistic materials such as Granite, Slate or Cobblestone on cartoon geometry. The noise fights the shapes.
- **Neon** is for emissive accents only (signs, energy, UI-like world markers). It's unlit: a large neon surface flattens the scene and blows out bloom.
- **Glass:** use it sparingly, because partial transparency is expensive (overdraw), and keep panes thin.

### 7.2 MaterialVariant + MaterialService (custom tileable materials) [official]
- Create a variant in **Material Manager** (or insert a `MaterialVariant` under `MaterialService`). Properties: `BaseMaterial`, `ColorMap`, `NormalMap`, `RoughnessMap`, `MetalnessMap` (plus `*Content` twins), `EmissiveMaskContent`, `EmissiveStrength`, `EmissiveTint`, `StudsPerTile` (default 10), `MaterialPattern` (`Regular` = ordered, man-made like brick and planks; `Organic` = less repetition, like stone and dirt), `AlphaMode`, `CustomPhysicalProperties`.
- Apply a variant per part with `BasePart.MaterialVariant = "VariantName"`. This is a **name string**, so a model reused elsewhere will pick up a same-named variant there. **Overrides** (`MaterialService.<Material>Name`, e.g. `GrassName`) replace a built-in material everywhere, terrain included.
- The prompt-based **Material Generator** in Studio can draft variants. Always check the result for tiling seams and value range.
- **Script security:** texture-map properties on MaterialVariant and SurfaceAppearance are `PluginSecurity`. They can be set from the command bar or plugins, but **not from game scripts at runtime**. `BaseMaterial` writes are also PluginSecurity. Author these at edit time.
- Keep a small library (6–12 variants) per game. Each one costs texture memory. Use `Organic` for natural surfaces to hide tiling, and set StudsPerTile so a brick or plank reads at real scale against a 5–6.5-stud avatar. For example, wood planks at about 0.5–1 stud per board.

### 7.3 SurfaceAppearance (per-mesh PBR) [official]
- Child of a `MeshPart`. Supports colour/albedo (with alpha), normal (**OpenGL tangent-space only**), roughness, metalness, emissive mask. Also `Color` tint, `AlphaMode`, and `ResampleMode` (Default = bilinear; pixel-art can use point sampling).
- MaterialVariant = **tileable** surfaces. SurfaceAppearance = **unique UV-mapped** asset textures. If both are present, SurfaceAppearance maps win for textures.
- Texture formats: albedo RGB 24-bit, normal RGB 24-bit, roughness/metalness/emissive single-channel 8-bit.
- For the most realistic reflections with metalness: EnvironmentSpecularScale and EnvironmentDiffuseScale = 1, Ambient/OutdoorAmbient = (0,0,0) [official recommendation in the metalness docs]. In practice, keep a little ambient for gameplay readability.
- Metalness maps should be mostly pure black or pure white. Use intermediate values only for grime over metal [official].
- Draw-call note: meshes instance together only when their SurfaceAppearances are identical [official]. Avoid duplicate SurfaceAppearance uploads of the same texture set.

### 7.4 Decals and Textures
Decals and Textures don't batch well and add draw calls [official]. Use them for tertiary detail (posters, grime, signage) on a limited number of surfaces. For repeated grime, prefer a MaterialVariant or a trim sheet on a mesh.

---

## 8. Colour theory and palettes for Roblox

### 8.1 Principles
1. **Value before hue.** Check the scene in greyscale (temporarily set `ColorCorrection.Saturation = -1`). Gameplay-critical things (paths, interactables, enemies, collectibles) must separate from the background by **value**, not just hue. That also helps colour-blind players.
2. **Limit the palette.** Pick 1 dominant hue family for the environment, 1 secondary, and 1 accent reserved for interactables, rewards and goals. Use 3–5 base colours, each with a light and a dark step (≈ 9–15 swatches total).
3. **60-30-10:** 60% dominant (ground, walls), 30% secondary (structures, foliage), 10% accent (doors, pickups, UI-matching highlights).
4. **Temperature contrast:** warm light with cool shadows (or the reverse at night). Implement it with ColorShift_Top/Ambient tints and Atmosphere Color/Decay.
5. **Saturation hierarchy:** the most saturated colours belong to the most important objects. Fully saturated backgrounds are the classic "kid game noise" problem. Distant objects get less saturated and lighter (aerial perspective), and Atmosphere does part of this for free.
6. **Don't use pure black or pure white surfaces.** They clip under tonemapping and bloom. Keep albedo roughly between RGB 30 and 240.
7. **Break up large flat areas** with ±3–8% colour variation between neighbouring parts or tiles, so a wall isn't 40 identical bricks [community: "change colors on models just a little bit"].
8. **Tie the UI to the world palette.** Accent colours in the HUD should match world accents, so players learn "orange = interactable".

### 8.2 Style palettes
| Style | Saturation | Value range | Notes |
|---|---|---|---|
| Bright cartoon / simulator | High (but backgrounds one step lower) | Mid–high | Pastel grounds, saturated props, warm sun. SmoothPlastic. Bloom subtle. |
| Stylized adventure | Medium-high | Full | Strong shape language, painted textures or flat colour, chunky bevels. |
| Low-poly / flat shaded | Medium | Mid | Harmonious analogous palette chosen *before* modelling [community]. Flat shading on meshes. |
| Realistic | Low–medium | Full, true blacks in shadows | Built-in PBR materials, EnvScales 1, neutral grade, light desaturation of foliage greens. |
| Horror | Low (desaturated), one sickly accent | Low | Readability comes from lights. Keep the playable path brighter than the surroundings. |
| Sci-fi neon | Low base, very high accents | Low base | Complementary accents (cyan/magenta, teal/orange). Neon only on trims. |
| Classic / studs revival | Medium-high BrickColor-era primaries | Mid | `Soft` style + `TonemapperPreset.Retro`, Studs surface textures, lights ≤ 1 Brightness [official tip]. |

### 8.3 Avoiding the "default grey" look
Default part colour is (163,162,165) Medium stone grey Plastic on a grey baseplate under (128,128,128) ambient. Every one of those should change. Recolour the ground (terrain or a textured floor), tint ambient, pick a palette, and use at least 3 materials with intent.

---

## 9. Choosing an art style

| Style | Best for | Cost to build | Perf | Risks |
|---|---|---|---|---|
| Low-poly / flat | Adventure, survival, tycoon, small teams | Low–med (Blender helps) | Excellent | Generic if the palette and shapes are bland. Needs strong silhouettes. |
| Stylized (hand-painted / chunky bevels) | Simulators, RPG, platformers, most front-page genres | Medium | Good | Inconsistent bevel sizes and texture styles. |
| Realistic | Horror, military, roleplay cities, showcases | High (PBR, SurfaceAppearance) | Heavy (textures, lights) | Uncanny next to blocky avatars. Mobile memory. |
| Classic / studs revival | Nostalgia, obby, retro hangout | Low | Excellent | Can look lazy unless deliberate (consistent studs, retro tonemap, crisp shapes). |
| Voxel / pixel | Building, sandbox | Low–med | Good if instanced | Needs point-sampled textures and a strict grid. |

Pick based on (a) the genre's player expectations, (b) the bot's production capacity (built-in parts and materials vs authored meshes), and (c) target devices. **Stylized with built-in materials plus selective meshes** is the safest default for an original game made by an automated builder.

---

## 10. Building technique

### 10.1 Scale reference
| Thing | Studs | Source |
|---|---|---|
| 1 stud | ≈ 28 cm (official). Builders often treat 1 stud ≈ 1 ft for architecture (community). | [official]/[community] |
| Classic avatar height | ~4.75–5 | [official] |
| Typical R15 / humanoid avatars | ~5.25–6.5 (Rthro Normal 5.75–6.5) | [official] |
| Design reference character | **~5.5** (work with a dummy R15 rig in the scene) | brief / [community] |
| Default jump height | 7.2 (`StarterPlayer.CharacterJumpHeight`) | [official default] |
| Default walk speed | 16 studs/s | [official default] |
| Door (house) | 7–8 tall × 4–6 wide | [community, varies 6–8 × 4.5–6] |
| Door (public/commercial) | 8–10 tall × 6–8 wide (double) | [synth] |
| Interior ceiling (home) | 10–12 | [synth/community] |
| Interior ceiling (public, shops, halls) | 14–20 | [synth] |
| Corridor (single player) | ≥ 6–8 wide | [synth] |
| Corridor/doorway (multiplayer combat) | ≥ 10 wide, walls ≥ 10 tall | [official laser-tag curriculum] |
| Modular grid example | 20×16×20 cells, walls 20×16×1 | [official battle-royale doc] |
| Stair step | rise 1 × run 1–1.5 (or a smooth ramp with stairs as visual only) | [synth] |
| Railing / table / counter | ~3 / ~3 / ~3.5 | [synth] |
| Window sill | ~3 | [synth] |

Rules:
- **Roblox scale is not real-world scale.** Avatars have big heads and short legs, and the third-person camera sits behind and above. Real-proportion rooms feel cramped, so build **~1.2–1.5× larger interiors** than "real" [community consensus: start with the character height and test by walking].
- The camera needs space. In tight rooms the default zoom collides with walls, so interior spaces should be ≥ 12–14 studs across where players turn around.
- Keep a dummy rig in the place while building (remove before ship) and check every doorway, stair and counter against it.
- Verticality: if a ledge should be climbable by jumping, keep it ≤ ~6.5 studs. If it must block, make it ≥ 8 (jump height is 7.2).

### 10.2 Proportion and shape language
- Proportion beats detail: "it doesn't matter how detailed the build is, it will look bad if the proportions are messed up" [community].
- Shape language: circles and rounded forms = friendly (simulators). Squares = stable and civic. Triangles and sharp angles = danger and sci-fi. Keep one dominant shape family per area.
- Avoid "everything square": vary roof pitches, add overhangs, taper towers, offset windows. Too square is the most common builder mistake [community].
- Exaggerate key features for stylized games: chunky trims, thick window frames, oversized doors and handles. Thin, realistic-thickness details disappear at mobile resolution.

### 10.3 Edges, bevels, flat parts
- Sharp 90° box edges catch no light, and they're the main "default part" tell. Options, cheapest first:
  1. **Trim pieces:** thin contrasting parts on edges and corners (baseboards, cornices, frames). They're part-only and instanced well.
  2. **Bevel plugins** that build bevels from native parts (wedges and cylinders), which keep materials [community: several plugins, e.g. "Edge Bevel"]. Mesh-based bevel plugins lose material support [community].
  3. **Model in Blender** with a bevel modifier: a small width with 1 segment for low-poly/stylized, 2–4 for realistic [community, "Realism 101"]. Keep segments low, since every bevel segment multiplies triangles.
- Bevel size must be **consistent across the game** (for example, 0.1–0.2 stud on 1-stud-thick props for stylized). Inconsistent bevels look kitbashed from different packs.
- No large untextured flat planes. Floors get a material variant, colour variation, rugs, and trim at wall junctions. Walls get a base trim, a mid-rail or panels, and a top cornice.

### 10.4 Detail hierarchy (primary / secondary / tertiary)
| Tier | What | Share of visual attention | Built with |
|---|---|---|---|
| Primary | Big silhouettes: buildings, cliffs, landmark, terrain masses | ~60% | Large parts/meshes, terrain |
| Secondary | Structure breaking up primaries: window frames, beams, roof trims, supports, balconies, ledges, rock clusters | ~30% | Trim parts, modular meshes |
| Tertiary | Props and surface detail: crates, signs, plants, cables, decals, grime, lamps | ~10% | Small reused meshes, decals |

- Work in passes: **greybox (primary) → secondary → lighting → tertiary → polish**. The official environment-art curriculum follows this order: greybox, then an asset library, then construct, then polish, then optimize.
- Spread detail with rhythm. Cluster tertiary props near points of interest and leave "rest areas" calmer. Uniform detail density reads as noise.
- **Detail where the camera is:** players see the ground plane and eye level most. Spend detail at 0–12 studs above the floor and less on rooftops nobody sees (unless they're part of the skyline silhouette).

### 10.5 Kitbashing and modular kits
- Build a **modular kit** on a grid: walls, corners, floors, door frames, window frames, pillars, stairs, roof pieces, all snapping to a consistent grid (e.g. 4- or 8-stud modules, or the official 20×16×20 example). Each asset should be big enough that rotating and moving it never causes clashing geometry (the official kit uses ≥ 5 studs) [official].
- **Trim sheets:** one texture with horizontal strips of trim/panel detail, mapped onto many meshes. That gives high variety at low memory, and the official curriculum uses them for door frames and ceilings.
- Kitbash = recombining your *own* kit pieces (rotated, scaled, overlapped) to make variety. This is also what keeps draw calls low via instancing [official].
- Use Packages for kit pieces so edits propagate.

### 10.6 Composition, guidance, landmarks
- **Landmark:** one tall, unique silhouette per zone (tower, giant tree, crashed ship, glowing crystal) visible from spawn and most of the zone. It orients players and is your thumbnail subject.
- **Leading lines:** paths, fences, rivers, cables, rows of lamps and roof lines pointing toward goals. Keep them subtle, because players notice obvious artificial guidance [community].
- **Light as guidance:** make goal areas brighter or warmer, or give them a colour accent. Leave the dead ends darker. The official indoor tutorial uses sun placement and sun rays to create a point of interest [official].
- **Framing:** arches, doorways, trees and cliff edges framing the next destination.
- **Silhouettes:** distinct outlines for interactables, enemies and NPCs. Test by temporarily setting Lighting Brightness 0 with a bright sky, or look at the greyscale view.
- **Negative space:** open areas around key interactables and the spawn so they read. Don't fill every gap with props. Empty space gives the eye a rest and the player room to move (especially on mobile thumbsticks).
- **Rule of thirds / thumbnail framing:** design 2–3 "postcard" camera views (spawn, landmark vista, hub) and compose them deliberately. These become the icon and thumbnails.
- **Gameplay-first:** visual clutter must never hide hazards, collectibles or the path. Readability beats beauty.

### 10.7 Environmental storytelling
- Every area should answer "what happened here?": worn paths where NPCs walk, overgrowth on abandoned structures, scorch marks near the reactor, stacked crates near the dock, a half-eaten meal in the cabin.
- Use the props, decals and lighting you already have to tell the story. No new systems needed.
- Reward exploration with small secrets (behind waterfalls, rooftop nooks) that pay off visually: a vista, a lore prop, a light shaft.

---

## 11. Terrain, water, foliage

### 11.1 Terrain basics [official]
- Voxel-based, edited with the Terrain Editor (Generate, Sculpt, Paint, Smooth, Flatten, Fill, Replace; plus heightmap and colormap import).
- **Material colours:** `Terrain:SetMaterialColor(material, color)` / `GetMaterialColor` recolour a built-in terrain material across the place. Use this to match the palette (e.g. a more saturated cartoon grass, or a desaturated realistic grass).
- **Custom terrain materials (new in 2026):** enable `Workspace` **Expanded Terrain** (per place, requires reopening the place) to paint up to **62 custom materials**, each with a colour and an optional MaterialVariant. It also brings smaller place files and better terrain streaming. Limits: MaterialVariant custom physics aren't respected yet, Team Create editing can glitch, thin terrain (< 16 voxels thick) can vanish with small streaming radii, and deleted-but-used materials show purple [official].
- Material overrides (MaterialService) apply to terrain too, but one override per base material. Use custom terrain materials for multiple grass shades.
- Terrain sculpt tips [synth/community]: block out big landforms first with a large brush, then smooth. Vary slope steepness. Cliffs = Rock/Slate/Basalt, flats = Grass/Ground, transitions = Mud/Ground/Pebble. Paint material along slopes (rock on steep faces, grass on flats) to sell form. Avoid perfectly circular hills and uniform height noise.
- Performance: terrain triangle counts aren't directly controllable, and the default grass plate eats a big share of mobile draw calls [community]. Don't generate huge empty terrain. Keep the play area tight and use Atmosphere to fade the edges.

### 11.2 Water [official]
| Property | Default | Notes |
|---|---|---|
| `WaterColor` | (13,84,92) dark teal | Match the palette: cartoon = brighter cyan, horror = murky green-grey |
| `WaterTransparency` | 0.3 | 0 opaque – 1 clear |
| `WaterReflectance` | 1 | 0–1 |
| `WaterWaveSize` | 0.15 | 0–1 studs |
| `WaterWaveSpeed` | 10 | 0–100 waves/min |
Some water properties only preview while playtesting, or with Editor Quality Level set to max [official]. Starting points [synth]: tropical (40,180,200) / 0.6 / 0.8 / 0.2 / 12. Lake (30,90,100) / 0.4 / 1 / 0.1 / 8. Swamp (60,75,50) / 0.15 / 0.4 / 0.05 / 4.

### 11.3 Grass and foliage
- Terrain grass: `Terrain.Decoration = true` (Grass material only), `GrassLength` 0.1–1 (default 0.7). It sways with `Workspace.GlobalWind`. Reduce Motion lowers its speed [official]. It isn't interactive or customizable [community].
- Trees and bushes: use **card/plane leaves with alpha textures** or chunky stylized leaf meshes, not hundreds of individual leaf parts [community]. Keep tree meshes reused (3–5 variants rotated and scaled) so they instance.
- Transparent foliage is expensive (overdraw), so cluster it carefully and avoid stacking many alpha cards in view [official/community].
- Set CastShadow off on small ground-cover meshes, CanCollide/CanTouch/CanQuery off on foliage, and Anchor everything [official/community].
- Scatter foliage at the edges of paths and buildings (where ground meets wall). It hides hard intersections, the cheapest polish there is.
- Optional client-side sway scripts are fine if they're distance-limited [community].

---

## 12. Meshes vs parts vs unions, and the Blender pipeline

### 12.1 Choosing the primitive
| Use | When | Perf notes |
|---|---|---|
| **Parts** (Block/Wedge/Cylinder/Ball) | Greybox, architecture with built-in materials, stylized builds | Cheap, batch OK. Part counts in the tens of thousands are fine if anchored and simple. |
| **MeshParts** | Anything organic, curved, beveled, repeated many times | Best when the **same MeshId is reused** (instancing). Need sensible CollisionFidelity. |
| **Unions** (solid modeling) | Quick one-off boolean shapes in Studio | Generate messy triangulation and collision hulls. Export and clean in Blender for anything repeated [community]. Avoid in volume. |

Community guidance: a Blender-made shape usually has fewer triangles than the same shape built from Studio parts and unions, and avoids union collision artifacts.

### 12.2 Mesh specs and settings [official]
- **Hard limit: 20,000 triangles per mesh.** Practical targets [synth]: small props 50–500 tris, medium props 500–2k, hero props and buildings 2k–10k. A big building should be split into modular pieces, which also helps streaming and culling.
- **RenderFidelity:** Automatic (default) = LOD by distance (<250 studs highest, 250–500 medium, >500 lowest), Precise = always full detail (expensive, avoid at scale), Performance = most aggressive.
- **CollisionFidelity:** Box (cheapest, small/decor), Hull (convex), Default (concave approximation), PreciseConvexDecomposition (most expensive), Tunable (`CollisionPrecision` slider, PluginSecurity, edit time). Decoration gets Box, or `CanCollide=false`. Walkable complex meshes: build invisible Box-collision parts as custom collision instead [official].
- `DoubleSided` exists on MeshPart. Only use it for leaf cards and cloth. Prefer real geometry thickness.
- Model level of detail: `Model.LevelOfDetail` = `SLIM` (recommended, needs streaming, a published place and Team Create) or `StreamingMesh` (coarse untextured imposter) for distant rendering. Imposters don't collide and can't be raycast [official].

### 12.3 Blender → Roblox checklist
1. Units: follow the official Blender setup. FBX export: **Transform → Apply Scalings = FBX Unit Scale** (recommended). Alternatives are Scale 0.01, or Scene Unit Scale 0.01, which causes Blender quirks [official]. Studio import: set **File Geometry → Scale Unit = Stud**. glTF export is also supported.
2. Apply transforms (Ctrl+A → All Transforms) before export. Scale 1, rotation 0 [official for rigs; good practice for all].
3. **Pivot/origin:** put the origin where the piece should snap. For modular kits that's the bottom-centre or a grid corner, consistent across the kit. Re-check the Studio Pivot after import.
4. Build modular pieces at grid-friendly sizes (snap Blender's grid to 1 = 1 stud), matching your Studio kit grid [community "Realism 101"].
5. **UVs:** one UV set, 0–1 space, overlaps allowed [official]. Consistent texel density across assets (e.g. 256 px per 2 studs).
6. Normals: flat shading for low-poly, auto-smooth or weighted normals for beveled stylized/realistic. Normal maps must be **OpenGL tangent space** [official].
7. One material per mesh object [official]. Split by material or atlas the textures.
8. Triangulate-aware modelling: count tris (not quads) against the 20k limit. Use Decimate (Planar for hard surfaces) for heavy imports [community].
9. Export only the selected objects, so hidden objects don't inflate the file [community].
10. Name objects meaningfully. The importer converts `_Att` suffixed objects to Attachments [official].
11. Upload each unique mesh **once**, then duplicate in Studio. Re-importing a whole map as one file can produce duplicate asset IDs and break instancing [official].
12. After import: set CollisionFidelity, CastShadow, Anchored and CanQuery/CanTouch per piece, and check RenderFidelity is Automatic.

### 12.4 Texture resolution guidelines [official]
| Asset size | Texture |
|---|---|
| ~1×1×1 (tiny) | 64–128² |
| ~2×2×2 / ~5×5-stud face | 256² |
| ~4×4×4 / ~10×10 | 512² |
| ~8×8×8 / ~20×20 | 1024² |
| Upload max | 4096² supported, but the engine streams lower mips first and may downsample when many textures render. Stick to ≤ 1024² for environment assets (the official UV section still lists 1024 as max). |
Trim sheets and tileables (MaterialVariant) beat many unique textures on memory.

---

## 13. StreamingEnabled and visual pop-in

- `Workspace.StreamingEnabled` is **on by default for new places** and can't be set by script [official]. `StreamingMinRadius` defaults to 64 studs, `StreamingTargetRadius` to 1024 [official API].
- Content beyond the target radius may be missing on the client. Without LOD, distant models simply vanish, and with SLIM they stay visible as optimized stand-ins [official].
- Visual strategies:
  1. Landmarks and the skyline: `Model.LevelOfDetail = SLIM` (or StreamingMesh) so the horizon never empties. Use `ModelStreamingMode = Persistent` only for small critical models (it costs memory).
  2. Atmosphere Density/Haze sized so objects fade into haze around or before the target radius, which hides pop-in.
  3. Group props into Models with sensible `ModelStreamingMode` (Atomic for things that must appear whole, e.g. a building with its door). Set `Workspace.ModelStreamingBehavior = Improved` [official recommended].
  4. Terrain features thinner than 16 voxels can disappear with small radii [official]. Thicken them.
  5. Don't put critical visuals (paths, signage) far from the player where they may not be streamed.
- Spawn areas: make sure everything visible from spawn is within the min radius or SLIM'd, so the first impression isn't a half-loaded world.

---

## 14. Performance budgets for visuals (low-end mobile first)

Most Roblox players are on lower-spec mobile devices [official]. Set the baseline device early.

| Metric (Shift+F2 render stats, F9 console) | Official guidance | Community stricter target |
|---|---|---|
| Draw calls, Draw (scene) | stay below ~1,000 on the baseline device | ~500 in scene; UI ~150 |
| Triangles in view | below ~1,000,000 | ~250k–500k (mid phones hold 60 fps at 250k, drop toward 30 fps past 500k [community anecdote]) |
| Frame budget | 16.67 ms at 60 fps | — |
| Shadows | Off below quality 4. Fewer shadow-casting lights and small parts | ≤ ~4–8 shadow-casting local lights visible at once [synth] |
| Transparency | Avoid values other than 0 and 1. Watch overdraw | — |
| Memory | Built-in materials over custom textures. Reuse meshes and textures | — |

Visual performance checklist:
- [ ] All static geometry Anchored. Decor has CanCollide/CanTouch/CanQuery = false.
- [ ] CastShadow = false on small, distant or moving decor.
- [ ] Local lights: `Shadows = false` except hero lights. Range and Angle trimmed. Lights disabled per room when out of view.
- [ ] No mass `RenderFidelity = Precise`. No mass `PreciseConvexDecomposition`.
- [ ] Repeated meshes share a MeshId and identical textures/SurfaceAppearance (check with the §6.5 audit).
- [ ] Partially transparent surfaces minimized and not layered (glass behind glass, fog cards stacked).
- [ ] ParticleEmitters: low Rate, short Lifetime, small counts. Avoid changing emitter properties every frame [official].
- [ ] Decals/Textures limited (they add draw calls).
- [ ] Streaming on, LOD/SLIM on distant models, play area compact.
- [ ] Tested 10–15 minutes on a real phone for thermal throttling [official].
- [ ] Profiled with the MicroProfiler: `ShadowMapSystem`, `LightGridCPU`, `Perform/Scene/RenderView` [official scopes].

---

## 15. Showcase quality vs game quality

| Aspect | Showcase (DevForum/X screenshots) | Shipping game |
|---|---|---|
| Lighting | Realistic, heavy bloom, DoF, sun rays, many shadow lights | Realistic or Soft depending on genre. Few shadow lights. No gameplay DoF. |
| Camera | Hand-composed angles at golden hour | Every angle, every time of day you allow, at a 5–6.5-stud eye height |
| Density | Max props, unique textures | Instanced kit, built-in materials, tertiary detail only near points of interest |
| Devices | PC at graphics 10 | Low-end phone at graphics 1–5 must still read |
| Readability | Can sacrifice it | Never sacrifice it: paths, hazards, interactables first |

Strategy: build the game version first. Then make a **separate "showcase" lighting preset** (or a duplicated place) with heavier DoF, bloom and denser dressing for thumbnails, trailers and promo shots. Never ship the showcase preset as the gameplay default. Thumbnails must still represent the real game honestly.

---

## 16. "Looks amateur" mistakes, and the fix for each

| Mistake | Fix |
|---|---|
| Default grey Plastic parts on a grey baseplate, default lighting | Palette + materials + lighting preset (§6, §8) |
| Free-model mishmash with clashing styles and bevel sizes | Build or own a consistent kit. Restyle anything imported to match. |
| Everything a sharp-edged box | Trims, bevels, varied silhouettes, overhangs |
| Wrong scale (tiny doors, giant chairs, cramped rooms) | Dummy rig. Doors 7–8 tall. Interiors 1.2–1.5× real. |
| Uniform detail everywhere, or empty flat fields | Detail hierarchy. Cluster at points of interest. Ground-cover transitions. |
| Oversaturated rainbow colours, neon everywhere | Limited palette, saturation hierarchy, neon only as accent |
| Pure grey ambient, flat shadows | Tinted Ambient/OutdoorAmbient, ColorShift, Atmosphere |
| Bloom Threshold so low the sky and white walls glow | Threshold ≥ 1 by day |
| Default DepthOfField or SunRays (too strong) | DoF off in gameplay. SunRays 0.02–0.15. |
| Stretched or blurry textures, mismatched texel density | Follow §12.4. Set StudsPerTile. Organic pattern on natural surfaces. |
| Visible tiling repetition on large surfaces | Organic pattern, colour variation, decals and props to break it up, larger StudsPerTile |
| Z-fighting (coplanar overlapping parts flicker) | Offset by ≥ 0.01–0.05 stud, or remove the hidden face part |
| Floating props and gaps where meshes meet terrain | Sink props slightly into the ground. Foliage and rocks at intersections. |
| Light leaks through thin walls (Realistic) | Walls ≥ 1 stud thick |
| Stock or recognizable skybox | Original sky matching the palette |
| Huge empty map that pops in | Tight play space, Atmosphere fade, SLIM landmarks |
| Text and decals unreadable on mobile | Big, high-contrast signage. Test on a phone. |
| Mixed art styles (realistic textures on cartoon shapes) | One style spec, enforced |
| Unions everywhere (bad shading, collision) | Meshes from Blender, or clean parts |

---

## 17. Visual Style Spec (fill out per game before building)

```markdown
# Visual Style Spec — <Game Name>

## 1. Pillars (3 words)            e.g. "cozy, chunky, glowing"
## 2. Art style                    low-poly | stylized | realistic | classic-studs | voxel
   Reference mood (describe, don't copy games): ...
## 3. Target devices & budgets     baseline device: ... | draw calls ≤ ... | tris ≤ ... | shadow lights ≤ ...
## 4. Lighting
   LightingStyle: Realistic|Soft   PrioritizeLightingQuality: true|false   GlobalShadows: ...
   Preset: <name from §6 or custom>  ClockTime: ..  Latitude: ..  Day/night cycle: yes/no
   Brightness .. Exposure .. Ambient (r,g,b) .. OutdoorAmbient (r,g,b) .. EnvDiffuse .. EnvSpecular ..
   Atmosphere: Density .. Offset .. Haze .. Glare .. Color .. Decay ..
   Post: CC(B/C/S/Tint) .. Bloom(I/S/T) .. SunRays .. DoF(off|menus) .. Tonemapper Default|Retro
   Sky: original skybox description; Clouds Cover/Density; StarCount
## 5. Palette (hex or RGB)
   Dominant (60%): light / base / dark
   Secondary (30%): light / base / dark
   Accent (10%, interactables only): ...
   Danger colour: ...   Reward colour: ...   UI must reuse accent/danger/reward.
## 6. Materials
   Built-ins allowed: ...   Banned: ...   MaterialVariants (name, base, StudsPerTile, pattern): ...
   Neon usage rule: ...   Glass/transparency rule: ...
## 7. Shape language & detail
   Dominant shapes: round|square|angular   Bevel size: .. studs   Trim style: ...
   Detail split: primary/secondary/tertiary targets per zone
## 8. Scale
   Reference char: 5.5 studs   Door: .. × ..   Ceiling: ..   Corridor: ..   Grid module: ..
## 9. Zones & landmarks
   Zone | mood/preset tweak | landmark | accent colour | story beat
## 10. Terrain & foliage
   Terrain materials + colours (SetMaterialColor) | Expanded Terrain yes/no | water settings | grass on/off, length | tree variants
## 11. Streaming/LOD
   StreamingTargetRadius .. | SLIM models: ... | Atmosphere fade distance ...
## 12. Postcard shots
   3 composed camera views for thumbnails: ...
## 13. Acceptance tests
   [ ] greyscale readability  [ ] phone low-graphics pass  [ ] no default grey  [ ] audit script clean
```

---

## 18. Final visual QA checklist

- [ ] Style spec filled in. Every zone follows it.
- [ ] Lighting: style chosen deliberately, tinted ambients, Atmosphere present, legacy fog unused, post effects subtle, original sky.
- [ ] Greyscale test passes: path, interactables and hazards separate by value.
- [ ] Scale walk-through with a dummy: doors, stairs, ceilings, camera clearance.
- [ ] No default-grey parts, no z-fighting, no floating props, no light leaks.
- [ ] Landmark visible from spawn. Leading lines toward the first objective. Negative space around interactables.
- [ ] Detail hierarchy respected. Points of interest dressed. Rest areas calm.
- [ ] Mesh reuse verified. Collision and Render fidelity sane. Decor non-colliding and shadowless where small.
- [ ] Streaming plus SLIM/LOD on the skyline. Atmosphere hides the far edge.
- [ ] Phone test at low graphics: readable, ≥ 30 fps (target 60), no thermal collapse after 10–15 minutes.
- [ ] Separate showcase preset for thumbnails, not shipped as the gameplay default.

---

## Sources

Official (local mirror of Roblox/creator-docs, `.sources/Roblox_creator-docs/content/en-us/`, plus the API dump):
- Global lighting — `environment/lighting.md` — https://create.roblox.com/docs/environment/lighting
- Atmospheric effects — `environment/atmosphere.md` — https://create.roblox.com/docs/environment/atmosphere
- Skyboxes — `environment/skybox.md` — https://create.roblox.com/docs/environment/skybox
- Dynamic clouds — `environment/clouds.md` — https://create.roblox.com/docs/environment/clouds
- Global wind — `environment/global-wind.md` — https://create.roblox.com/docs/environment/global-wind
- Post-processing effects — `environment/post-processing-effects.md` — https://create.roblox.com/docs/environment/post-processing-effects
- Materials / Material Manager — `parts/materials.md` — https://create.roblox.com/docs/parts/materials
- Custom terrain materials (Expanded Terrain) — `parts/custom-terrain-materials.md` — https://create.roblox.com/docs/parts/custom-terrain-materials
- Terrain — `parts/terrain.md` — https://create.roblox.com/docs/parts/terrain
- Meshes — `parts/meshes.md` — https://create.roblox.com/docs/parts/meshes
- Mesh specifications — `art/modeling/specifications.md` — https://create.roblox.com/docs/art/modeling/specifications
- Texture specifications — `art/modeling/texture-specifications.md` — https://create.roblox.com/docs/art/modeling/texture-specifications
- PBR / SurfaceAppearance — `art/modeling/surface-appearance.md` — https://create.roblox.com/docs/art/modeling/surface-appearance
- Blender configuration — `art/blender.md` — https://create.roblox.com/docs/art/blender
- Improve performance (draw calls, shadows, instancing) — `performance-optimization/improve.md` — https://create.roblox.com/docs/performance-optimization/improve
- Design for performance (1,000 draw calls / 1M tris, transparency, materials memory) — `performance-optimization/design.md` — https://create.roblox.com/docs/performance-optimization/design
- Test on hardware — `performance-optimization/test-on-hardware.md` — https://create.roblox.com/docs/performance-optimization/test-on-hardware
- Instance streaming — `workspace/streaming/index.md` — https://create.roblox.com/docs/workspace/streaming
- SLIM — `workspace/streaming/slim.md` — https://create.roblox.com/docs/workspace/streaming/slim
- Enhance outdoor environments (realistic lighting) — https://create.roblox.com/docs/tutorials/use-case-tutorials/lighting/enhance-outdoor-environments
- Enhance indoor environments — https://create.roblox.com/docs/tutorials/use-case-tutorials/lighting/enhance-indoor-environments
- Environmental art curriculum (greybox, asset library, trim sheets, optimize) — https://create.roblox.com/docs/tutorials/curriculums/environmental-art
- Units (1 stud ≈ 28 cm) — `physics/units.md`. Avatar heights — `studio/avatar-settings.md`, `avatar/rigid-accessories/specifications.md`
- API reference YAML: Lighting, Atmosphere, Sky, Clouds, ColorCorrectionEffect, BloomEffect, SunRaysEffect, DepthOfFieldEffect, ColorGradingEffect, MaterialVariant, MaterialService, SurfaceAppearance, Terrain, Workspace, Model. Enums: LightingStyle, Technology, TonemapperPreset, RenderFidelity, CollisionFidelity, ModelLevelOfDetail, ModelStreamingMode, MaterialPattern. Class defaults and script security from `MaximumADHD_Roblox-Client-Tracker/Full-API-Dump.json`.

Community (DevForum and others, accessed via search on 2026-11-05; devforum.roblox.com was not directly fetchable from this environment, so claims come from search-result extracts):
- Let There Be (Unified) Light! Unified Lighting is Fully Live — https://devforum.roblox.com/t/let-there-be-unified-light-unified-lighting-is-fully-live/3401512
- Games became darker since ShadowMap and Compatibility are gone — https://devforum.roblox.com/t/games-became-darker-since-shadowmap-and-compatibility-are-gone-for-unknown-reason/3847914
- Gamefam Studios on Unified Lighting beta — https://x.com/gamefamstudios/status/1883961554053275857
- Roblox Lighting Modes | What do I use for my game? — https://devforum.roblox.com/t/roblox-lighting-modes-what-do-i-use-for-my-game/1687174
- If I care about performance on mobile which Lighting mode should I use? — https://devforum.roblox.com/t/if-i-care-about-performance-on-mobile-which-lighting-mode-should-i-use/431662
- Future vs Shadowmap performance — https://devforum.roblox.com/t/future-vs-shadowmap-performance/3246937
- Progressive Rollout of Future Lighting on Android — https://devforum.roblox.com/t/progressive-rollout-of-future-lighting-on-android-devices-client-beta/3064250
- Guide to Lighting — https://devforum.roblox.com/t/guide-to-lighting/2764787
- Realistic Roblox Lighting — https://devforum.roblox.com/t/realistic-roblox-lighting/3144291
- Realistic Textures In Roblox + More — https://devforum.roblox.com/t/realistic-textures-in-roblox-more-displacement-maps-ambient-occlusion-lighting/1472776
- Hyper realistic Lighting Settings? — https://devforum.roblox.com/t/hyper-realistic-lighting-settings/915802
- Improve Lighting (STEP BY STEP) — https://devforum.roblox.com/t/improve-lighting-step-by-step/1387033
- Lighting Settings For Cartoony Style — https://devforum.roblox.com/t/lighting-settings-for-cartoony-style/2167959
- How To Make Lighting Better For Games — https://devforum.roblox.com/t/how-to-make-lighting-better-for-games/1104439
- The Complete Guide to Lighting in Roblox Studio — https://devforum.roblox.com/t/the-complete-guide-to-lighting-in-roblox-studio/1876371
- Best Horror Ambience & Lighting settings? — https://devforum.roblox.com/t/best-horror-ambience-lighting-settings/1784673
- Horror game lighting — https://devforum.roblox.com/t/horror-game-lighting/1086876
- Neon in Future is bright fades too easily? — https://devforum.roblox.com/t/neon-in-future-is-bright-fades-too-easily/231193
- Unified Neon and Bloom [Poll] — https://devforum.roblox.com/t/unified-neon-and-bloom-poll/180359
- Tips and Tricks for Building — https://devforum.roblox.com/t/tips-and-tricks-for-building/1668709
- What Should Be The Ideal Door Size? — https://devforum.roblox.com/t/what-should-be-the-ideal-door-size/2200910
- Scaling Buildings Properly — https://devforum.roblox.com/t/scaling-buildings-properly/1054615
- Building advice / feedback threads — https://devforum.roblox.com/t/building-advice/1645206 , https://devforum.roblox.com/t/any-basic-tips-for-noob-builders/1190645
- Low-Poly Building Style Tips — https://devforum.roblox.com/t/low-poly-building-style-tips/293535
- Common Mistakes and ways to Improve when Modeling Low Poly — https://devforum.roblox.com/t/common-mistakes-and-ways-to-improve-when-modeling-low-poly/525676
- Why the Low-Poly Graphics Style is so Common — https://devforum.roblox.com/t/why-the-low-poly-graphics-style-is-so-common/511551
- Edge Bevel plugin — https://devforum.roblox.com/t/edge-bevel-easily-bevel-the-edges-corners-of-parts/2940227
- IntersectAsync-Based Part Bevel Plugin — https://devforum.roblox.com/t/intersectasync-based-part-bevel-plugin/3962811
- Realism 101: Building in Roblox using Blender — https://devforum.roblox.com/t/realism-101-building-in-roblox-using-blender/4081400
- MeshPart Usage, Performance & Optimizations — https://devforum.roblox.com/t/meshpart-usage-performance-optimizations/1319217
- Real world building and scripting optimization for Roblox (500 draw calls / 500k tris) — https://devforum.roblox.com/t/real-world-building-and-scripting-optimization-for-roblox/3127146
- Best way to optimize structures & big fields of nature? — https://devforum.roblox.com/t/best-way-to-optimize-structures-big-fields-of-nature/2097373
- How To Optimize (foliage) — https://devforum.roblox.com/t/how-to-optimize/3175261
- Client-Sided Foliage — https://devforum.roblox.com/t/client-sided-foliage/2157143
- Optimize Smooth Terrain Better — https://devforum.roblox.com/t/optimize-smooth-terrain-better/3781706
- What Roblox Custom Terrain Materials Changed for Creators (2026, secondary blog, low confidence) — https://gamineai.com/blog/what-roblox-custom-terrain-materials-changed-for-creators-2026
