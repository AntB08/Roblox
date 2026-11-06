# 17 — External Creative Tools: 3D, 2D and Audio for Roblox

> Scope: every creative tool **outside Roblox Studio** that is useful for making original Roblox games: Blender (deepest section), Blockbench, MagicaVoxel, Substance 3D Painter, ZBrush/Nomad; Photoshop/Photopea/Krita/GIMP, Aseprite, Inkscape/Figma; Audacity, LMMS/BandLab/Reaper/FL Studio, sfxr-family generators. For each tool: what it is for in Roblox work, cost, a step-by-step core workflow, settings and numbers, common mistakes, and the best videos to learn it.
>
> **Not repeated here (read these instead):** chapter 09 covers the Studio 3D Importer settings, mesh limits (20k tris, one material per MeshPart), texel density, SurfaceAppearance properties, a full headless bpy low-poly tree generator and the free-model backdoor scanner. Chapter 05 covers the audio API (AudioPlayer, LoopRegion, mixing, crossfades) and the music rules. Chapter 16 covers critique of icons, thumbnails, logos and GFX. Chapter 07 covers thumbnail policy and the Home-page custom-thumbnail rule.
>
> **Sources.** Blender manual RST (CC-BY-SA 4.0) at `reference/tools/blender-manual/` (cited as `bm:<path>`); Roblox Creator Docs snapshot at `reference/creator-docs/content/en-us/` (cited as `cd:<path>`); local copies of the Blockbench site docs (`.sources/JannisX11_blockbench.net/content/`) and the Audacity support manual (`.sources/audacity_audacity-support/`); web sources linked inline. Versions as of 2026-11-05: Blender 5.1 (March 2026), Audacity 4.0.2 (4.0 shipped 2026-09-03; the local manual describes 3.7, so menu locations may have moved), Krita 5.3.4/6.0.4, GIMP 3.2.x, Blockbench 5.0.x, LMMS 1.2.2 stable (1.3 in alpha).
>
> **About the video summaries.** YouTube pages and captions cannot be fetched from the bot's cloud environment (bot check), so every "Best videos" summary below is written from the catalog metadata (title, channel, views, length, description snippet in `reference/video-library/catalog.json`) plus whatever web search found (official pages, companion posts, forum threads). **None of them comes from a watched video or a transcript.** Where a summary describes contents beyond the title and snippet, that detail came from a web source; otherwise treat it as "what the video says it covers". For deeper summaries the owner can run `pip install youtube-transcript-api && python3 scripts/fetch_youtube_transcripts.py --top 3` on a home connection; transcripts land in `.sources/youtube-transcripts/` and can be searched with `scripts/kb_search.sh "<term>" transcripts`. View counts are popularity, not quality.

---

## TL;DR rules for the bot

1. **Default stack is free:** Blender (3D), Photopea or Krita (2D painting/compositing), Inkscape (vector icons), Audacity (audio editing), LMMS or BandLab (music), ChipTone/jsfxr (retro SFX). Paid tools (Substance Painter, Photoshop, ZBrush, FL Studio, Aseprite) are optional upgrades, never requirements.
2. **Everything the bot makes must be reproducible by script** when possible: Blender via `blender -b --factory-startup -P script.py -- args`, images via Pillow/Inkscape CLI, audio via ffmpeg/sox. GUI tools are for the human owner, or for steps a script cannot do well (painting, composing).
3. **Blender → Roblox:** Units = None, apply transforms (Ctrl+A), origin at the pivot, one material per mesh, single UV map in 0–1. Export **glTF/GLB** for static props; **FBX** for rigs/animation with *Apply Scalings = FBX Unit Scale*, *Add Leaf Bones off*, *Path Mode Copy + Embed Textures*. Test with a 1×1×1 cube that must import as 1×1×1 studs (details in 09 §2).
4. **Normal maps are OpenGL (Y+, tangent space).** Blender bakes and Substance's "OpenGL" setting both match. DirectX normals need the green channel flipped.
5. **Mark non-color images as Non-Color** (normal, roughness, metalness, emissive mask) in Blender's Image Texture node, or bakes and previews will be wrong.
6. **Save painted/baked images explicitly** (Image ▸ Save, `Alt+S` in the Image Editor). Blender does not save painted pixels with the .blend unless you save or pack them.
7. **Pixel-art and voxel textures:** set `SurfaceAppearance.ResampleMode` / `ImageLabel.ResampleMode = Pixelated` (documented in `reference/creator-docs/.../SurfaceAppearance.yaml`; test in Studio), or upscale the PNG with nearest-neighbour ×4–×8 before upload. Otherwise Roblox's bilinear filtering blurs it.
8. **2D sizes:** game icon **512×512** (check it at 150×150); thumbnails **1920×1080, 16:9**, up to 10; badge, game pass and developer product icons **512×512** with important detail inside the centre circle; uploaded images must be **< 8000×8000** (Open Cloud ≤ 20 MB); UI art at **≤ 2×** its on-screen size; textures by world size (256 px ≈ 5 studs, 1024 px ≈ 20 studs).
9. **Transparent PNGs:** export RGBA, straight (non-premultiplied) alpha, no colour profile tricks; pad 9-slice art so corners are whole pixels and record the `SliceCenter` rect.
10. **Audio uploads:** `.ogg/.wav/.flac` (MP3 only if you must; it adds loop gaps), < 20 MB, < 7 min, ≤ 48 kHz, mono/stereo/3.0/5.1; 2,000 uploads per 30 days if ID-verified, 100 if not. Upload under the **group that owns the game**.
11. **SFX:** trim to the first transient (no leading silence), fade the tail, peak-normalize to −1 dBFS, mono for 3D emitters, stereo for UI/music. Keep a consistent loudness across the set (suggested house targets: music ≈ −16 to −18 LUFS integrated, SFX peaks ≤ −1 dBTP). These are conventions, not Roblox rules.
12. **Music:** instrumental only (no vocals, choir, humming, "aah" pads, vocal chops); loops built on whole bars; reverb tail folded onto the start; cut at exact sample counts; export lossless. Verify the seam by playing the last 3 s into the first 3 s.
13. **Originality and licences:** make your own art and audio. CC0 inputs are fine; CC-BY needs credit; skip NC/ND and anything "free for personal use". Never trace or reuse other games' icons, thumbnails or characters. Log sources in `CREDITS.md` (05 §8.6).
14. **Videos are pointers, not truth:** many Roblox tutorials repeat outdated FBX scale advice (0.01, Scene Unit Scale). The Creator Docs (`cd:art/blender.md`) win when they disagree.
15. **Before handing art to the owner**, run the chapter 16 critique checklist.

---

## Tool picker

| Task | Recommended tool | Free alternative | Notes |
|---|---|---|---|
| Low-poly props, buildings, weapons | Blender | (Blender is free) | Studio parts/CSG for blocky builds (09 §8) |
| Blocky / pixel-textured models | Blockbench | Blender with a pixel texture | Blockbench is faster for cube-built art |
| Voxel art | MagicaVoxel | Blockbench, or Luau-built parts | Clean up the OBJ in Blender |
| Hero sculpts (statues, creatures) | ZBrush | Blender Sculpt Mode; Nomad Sculpt (cheap, tablet) | Always retopo + bake to a low-poly |
| PBR texturing (smart materials, wear) | Substance 3D Painter | Blender texture paint + bakes; Material Maker for tiling materials | Export Color/Normal(OpenGL)/Roughness/Metalness |
| Hand-painted textures | Blender Texture Paint | Krita on an exported UV layout | Bake AO first, paint over it |
| Rigging + animation for R15 | Blender + community animation plugin | Studio Animation Editor / Moon Animator | FBX import via Animation Editor is official |
| GFX renders for icons/thumbnails | Blender (Cycles) + Photoshop | Blender + Photopea | Pose in Studio or Blender, paint over in 2D |
| Icons, thumbnails, logos, compositing | Photoshop | Photopea (browser), GIMP 3.2 | Photopea opens PSDs |
| Digital painting, concept, UI art | Photoshop | Krita | Krita is better for brush painting |
| Pixel art, pixel UI, sprite sheets | Aseprite (paid; source is free to compile) | LibreSprite, Pixelorama, Krita | Use ResampleMode Pixelated |
| Vector icons, logos | Illustrator | Inkscape | Export PNG at final size |
| UI mockups / full UI kits | Figma | Figma Starter (free tier), Penpot | Figma→Studio importer plugins exist |
| SFX editing | Audacity | (Audacity is free) | Reaper for heavy work |
| Retro/arcade SFX | ChipTone, jsfxr, bfxr, jfxr | (all free) | ChipTone output is CC0 |
| Instrumental music loops | FL Studio or Reaper | LMMS (desktop), BandLab (browser) | Export WAV, fold the tail |
| Foley recording | Phone/USB mic + Audacity | (same) | 48 kHz WAV, quiet room |

---

## 1. Blender (free, open source): the main 3D tool

**What it is for:** every custom MeshPart: props, modular kits, weapons, vehicles, characters, accessories, plus baking normal/AO maps, rigging and animating, and rendering GFX for icons and thumbnails. **Cost:** free (GPL), Windows/macOS/Linux. Current release 5.1 (March 2026); the bundled manual snapshot matches the 5.x series. Official Roblox page: `cd:art/blender.md` (live: https://create.roblox.com/docs/art/blender).

### 1.1 Interface essentials (what to know before anything else)

- **Workspaces** (tabs at the top): *Layout* (general), *Modeling*, *UV Editing* (UV Editor left, 3D right), *Texture Paint*, *Shading* (node editor + material preview), *Animation*, *Scripting* (Python console + text editor). Switching tabs changes the layout, not the file.
- **Editors you will use:** 3D Viewport, Outliner (scene tree: names here become MeshPart names), Properties (wrench = modifiers, red sphere = materials, green triangle = mesh data incl. UV Maps, scene cone = units), Shader Editor, UV Editor, Image Editor, Timeline/Dope Sheet.
- **Modes:** Object Mode (move whole objects), Edit Mode (`Tab`; vertices/edges/faces), Sculpt, Texture Paint, Weight Paint, Pose Mode (armatures).
- **Sidebar `N`:** exact location/rotation/scale and dimensions (check sizes in studs here); add-on panels also live here. **Toolbar `T`.**
- **Statistics overlay:** Viewport Overlays ▸ *Statistics* shows vertex/face/**triangle** counts. Keep it on; the Roblox limit is 20,000 triangles per mesh.
- **Face Orientation overlay:** blue = outward normals, red = flipped. Fix with `Shift+N` (Recalculate Outside, `bm:modeling/meshes/editing/mesh/normals.rst`).
- **F3 = operator search.** If you know the name ("Smart UV Project", "Merge by Distance"), search it instead of hunting menus. **F9** re-opens the last operator's options (the "Adjust Last Operation" panel, bottom left).
- **Scene setup for Roblox** (Properties ▸ Scene ▸ Units): Unit System **None**, Rotation **Degrees** (`cd:art/blender.md` "Configure units"). Then 1 Blender unit = 1 stud with glTF or FBX Unit Scale.

### 1.2 The ~45 shortcuts that matter (default keymap, Blender 4.x/5.x)

Shortcuts verified against the manual where listed (e.g. `bm:scene_layout/object/editing/apply.rst` Ctrl-A, `join.rst` Ctrl-J, `duplicate_linked.rst` Alt-D, mesh tool pages for I, Ctrl-R, K, Ctrl-B, M, P, U, Shift-S, O, V).

| Key | Action | Key | Action |
|---|---|---|---|
| MMB drag / Shift+MMB / wheel | Orbit / pan / zoom | `Numpad .` | Frame selected |
| `Numpad 1 / 3 / 7` (+Ctrl = opposite) | Front / right / top view | `Numpad 5` | Toggle ortho/perspective |
| `Numpad /` | Local view (isolate selection) | `` ` `` (backquote) | View pie |
| `Z` | Shading pie (solid/material/render) | `Alt+Z` | X-ray toggle |
| `Tab` | Object ↔ Edit Mode | `1 / 2 / 3` (Edit Mode) | Vertex / edge / face select |
| `A` / `Alt+A` | Select all / none | `Ctrl+I` | Invert selection |
| `B` / `C` | Box select / circle select | `Alt+Click` | Select edge loop |
| `L` / `Ctrl+L` | Select linked under cursor / linked to selection | `Shift+Click` | Add to selection |
| `G` / `R` / `S` | Move / rotate / scale | then `X/Y/Z`, `Shift+Z` | Constrain to axis / exclude axis |
| type `0.5` while transforming | Exact value | `Ctrl` (hold) | Snap while transforming |
| `Shift+S` | Snap pie (cursor to selected, selection to cursor) | `Ctrl+A` | Apply transforms (All Transforms) |
| `Shift+D` / `Alt+D` | Duplicate / linked duplicate | `Shift+A` | Add menu |
| `X` | Delete menu | `Ctrl+J` / `P` | Join objects / separate (Edit Mode) |
| `M` | Merge (By Distance cleans duplicate verts) | `Ctrl+P` | Parent |
| `H` / `Alt+H` / `Shift+H` | Hide / unhide / hide unselected | `F2` | Rename active |
| `E` | Extrude | `I` | Inset faces |
| `Ctrl+R` | Loop cut and slide | `Ctrl+B` / `Ctrl+Shift+B` | Bevel edges / bevel vertices |
| `K` | Knife | `F` | Fill (new edge/face) |
| `J` | Connect vertex path | `G G` | Edge/vertex slide |
| `Shift+N` | Recalculate normals outside | `Alt+N` | Normals menu |
| `U` | UV unwrap menu | `Ctrl+E` | Edge menu (Mark Seam, Mark Sharp) |
| `O` | Proportional editing | `V` | Rip |
| `Ctrl+T` / `Alt+J` | Triangulate / tris to quads | `Ctrl+1…5` (Object Mode) | Add Subdivision Surface at level |
| `F3` | Operator search | `F9` | Adjust last operation |
| `Shift+R` | Repeat last | `Ctrl+Z` / `Ctrl+Shift+Z` | Undo / redo |
| `N` / `T` | Sidebar / toolbar | `Ctrl+Space` | Maximize editor |

### 1.3 Low-poly modeling workflow (the bot's default style)

Low-poly, flat-shaded models with a small palette are the most reliable good look for an AI agent (09 §5). Workflow:

1. **Block out at true Roblox scale.** Keep a 5-stud-tall reference block (R15 avatar height) in the file. Doors ≈ 4×7 studs, steps 1 stud, rooms 12–16 studs tall. Check sizes in the `N` sidebar.
2. **Start from primitives** (`Shift+A`): cube, cylinder with **6–12 vertices** (not the default 32), UV sphere at 8×6 or an icosphere at subdivision 1–2.
3. **Shape with few cuts:** `Ctrl+R` loop cuts, `E` extrude, `I` inset, `S` scale edge loops. Move vertices for silhouette. Keep faces large; detail comes from silhouette and colour, not edge count.
4. **Mirror symmetric objects** (Mirror modifier, §1.5) and delete the duplicate half first.
5. **Bevel only edges the camera sees in profile.** A 1-segment bevel catches light and stops the "CAD box" look.
6. **Shade Flat** (Object ▸ Shade Flat) for faceted style. For bevelled hard-surface use *Shade Auto Smooth* (adds the Smooth by Angle modifier, default 30°; `bm:modeling/modifiers/normals/smooth_by_angle.rst`). The old per-mesh "Auto Smooth" checkbox is gone since 4.1.
7. **Colour with a palette texture:** one small palette image (e.g. 8×8 or 16×16 swatches). Unwrap, then in the UV Editor scale each face's UVs down (`S 0`) and drop them onto a swatch. Set the Image Texture node interpolation to **Closest** in Blender, and `ResampleMode = Pixelated` in Roblox, so swatches don't bleed. One palette = one texture for the whole kit = memory win.
8. **Clean up:** `M` ▸ By Distance, delete interior faces, `Shift+N`, check Statistics (props 50–1,500 tris, hero 2–5k).
9. **Origin** at the pivot (Object ▸ Set Origin ▸ Origin to 3D Cursor after snapping the cursor to the base centre), **apply transforms** `Ctrl+A ▸ All Transforms`, name the object, export (§1.10).

**Common mistakes:** default 32-segment cylinders everywhere (tri blow-up); modelling at metre scale then scaling ×0.28 in Studio; leaving scale unapplied; hidden interior faces from joined primitives; mixing flat and smooth shading inside one prop by accident.

### 1.4 Hard-surface workflow (crates, guns, machines, vehicles)

1. Block the main volumes with cubes/cylinders; keep each part a separate object while designing.
2. Cut panels and recesses with **inset + extrude inwards** (`I`, then `E` and move along normal) rather than booleans where possible; for complex cuts use a Boolean modifier (Difference) with a cutter object, then apply and clean the n-gons (`J` to connect, or triangulate).
3. **Bevel modifier** for edge highlights (Limit Method *Angle*, 30°), then **Weighted Normal** modifier (*Keep Sharp* on) so large flat faces shade flat without extra geometry.
4. Optional high-poly path: duplicate the low-poly, add Subdivision Surface + support loops on the copy, then **bake** its normals to the low-poly (§1.8). Usually unnecessary for Roblox stylized art; bevel + weighted normals is enough.
5. Join parts that share a texture into one mesh (fewer MeshParts); keep moving parts (doors, wheels, triggers) separate with origins at their hinges/axles.
6. Before export, apply booleans and check for n-gons and non-manifold geometry (Select ▸ Select All by Trait ▸ Non Manifold).

**Common mistakes:** leaving live Boolean modifiers that export as garbage; n-gon fans that shade badly after triangulation; 4-segment bevels on every edge of a background prop.

### 1.5 Modifiers worth knowing (with Roblox settings)

Modifiers are non-destructive; they are baked into the exported mesh only if the exporter's *Apply Modifiers* is on (glTF *Data ▸ Mesh ▸ Apply Modifiers*; FBX *Geometry ▸ Apply Modifiers*), or if you apply them (`Ctrl+A` over the modifier header). The bot should apply them explicitly before export so the triangle count it checks is the real one.

| Modifier | Use in Roblox work | Settings that work | Gotchas |
|---|---|---|---|
| **Mirror** (`bm:modeling/modifiers/generate/mirror.rst`) | Symmetric props, characters, vehicles | Axis X; **Clipping** on (verts can't cross the plane); **Merge** on (welds the seam) | Delete the other half first; centre seam verts must sit exactly at 0 |
| **Bevel** (`.../generate/bevel.rst`) | Edge highlights | Width 0.02–0.1 studs; Segments 1–2; Limit Method **Angle** 30°; *Harden Normals* on for hard-surface | Unapplied object scale makes widths uneven: apply scale first |
| **Solidify** (`.../generate/solidify.rst`) | Give thickness to planes (cloth, leaves, signs, walls) so collision and back faces work | Thickness 0.05–0.2 studs; *Even Thickness*; Offset −1 | Doubles tri count; for foliage cards prefer a single plane + `DoubleSided` |
| **Array** (`.../generate/array.rst`, `array_legacy.rst`) | Fences, stairs, rails, chains | Count; Relative Offset 1.0 on the run axis; Merge on to weld | In 5.x the default *Array* is a new geometry-nodes modifier; *Array (Legacy)* is the classic one (`bpy` type `'ARRAY'`). For repeated props it is often better to export one segment and repeat it in Studio (instanced meshes are cheap) |
| **Weighted Normal** (`.../normals/weighted_normal.rst`) | Makes big flat faces shade flat on bevelled meshes | Weighting Mode *Face Area*; Weight 50; **Keep Sharp** on; place after Bevel | Exports custom normals: glTF keeps them; for FBX set *Smoothing = Normals Only* |
| **Decimate** (`.../generate/decimate.rst`) | Reduce imported/sculpted/voxel meshes under budget | *Collapse* Ratio 0.1–0.5 for organic; *Planar* Angle Limit 1–5° for voxel/CAD meshes with big flat areas; *Un-Subdivide* for grid meshes | Wrecks UVs and topology on carefully built low-poly; use it on imports, not on your own clean models |
| Triangulate | Predictable triangulation before export/bake | Quad Method *Beauty* | Bake and export with the same triangulation |
| Subdivision Surface | High-poly bake source only | Levels 2 | Never export a subdivided mesh as the game mesh |

### 1.6 UV unwrapping

Needed whenever a mesh uses an image texture (palette, painted, baked or PBR). Rules from 09 §2–3: one UV map, inside 0–1, margins of a few pixels at final resolution.

1. Switch to the **UV Editing** workspace. In Edit Mode select edges for seams and `Ctrl+E ▸ Mark Seam`. Put seams on hard edges and hidden places (bottom, back, inside corners). Cylinders need one vertical seam plus the cap loops.
2. Select all and `U ▸ Unwrap`. Blender 5.x offers three methods in the menu: **Angle Based** (default, good for most), **Conformal** (LSCM, simple shapes) and **Minimum Stretch** (SLIM, least distortion) (`bm:modeling/meshes/editing/uv.rst`).
3. Quick alternatives: **Smart UV Project** (Angle Limit ~66°, Island Margin ~0.01–0.02) for hard-surface props the bot generates; **Cube Projection** for boxy objects; **Follow Active Quads** for strips such as trims and rails.
4. Check distortion with a checker texture: in the UV Editor *Image ▸ New*, Generated Type **UV Grid** or **Color Grid**, assign it in the material. Squares should be square and similar in size across the model (consistent texel density).
5. **Pack Islands** (UV ▸ Pack Islands) with a margin; rotate islands for tighter packing. Straighten rectangular islands (they waste less space and paint more easily).
6. Overlapping UVs are allowed in Roblox (mirrored halves, trim sheets) but not for **baking** AO/normal, where overlapping islands will fight.
7. For the palette workflow (§1.3) no real unwrap is needed: collapse each face's UVs onto a swatch.

**Common mistakes:** forgetting seams then getting a single stretched island; islands outside 0–1 (Roblox wants 0–1); tiny margins causing colour bleed at low mip levels (Roblox streams low mips first); two UV maps on one mesh (only one is used).

### 1.7 Texture painting in Blender

Good for hand-painted stylized props, quick colour blocking on a baked AO base, and fixing seams on a Substance export.

1. UV-unwrap first (§1.6).
2. In the **Texture Paint** workspace, the Properties ▸ Tool ▸ Texture Slots panel offers **+** to create a Base Color image: 1024×1024 for a 20-stud object, 512 for 10 studs, 256 for 5 studs (`cd:art/modeling/texture-specifications.md`). Untick Alpha unless you need transparency.
3. Paint: `F` resize brush, `Shift+F` strength, `S` sample colour, `Ctrl`-drag to invert. Use **face selection masking** (header button) to paint only selected faces, and the **stencil/mask** textures for patterns.
4. Typical stylized recipe: flat base colours → bake AO and multiply it in softly → gradient from dark bottom to light top → hand-painted edge highlights → small hue shifts. Keep painted lighting subtle: Roblox lights the mesh too (09 §4.3).
5. **Save the image:** Image Editor ▸ *Image ▸ Save As* (PNG, 8-bit). Unsaved paint is lost when Blender closes. Alternatively *File ▸ External Data ▸ Pack Resources* to keep it inside the .blend.
6. For big painting sessions, export the UV layout (*UV ▸ Export UV Layout*, PNG) and paint in Krita/Photoshop on top of it, then reload the image in Blender.

### 1.8 Baking normal and AO maps (and other maps)

The baking pipeline is outlined in 09 §4.2; these are the exact panel settings (`bm:render/cycles/baking.rst`).

1. Render Engine **Cycles** (baking is Cycles-only). Device GPU if available. Bake samples can be low (32–128) for AO.
2. Low-poly (game mesh) is UV-unwrapped with no overlapping islands. High-poly (bevelled/sculpted/subdivided copy) occupies the same space.
3. In the low-poly's material add an **Image Texture node** with a new image (1024×1024; for normal maps set the image's colour space to **Non-Color**), and make that node **active (selected)**. The bake writes into the active image node. "No active image found in material" means you skipped this.
4. Select the high-poly, then Shift-select the low-poly (active). In Render ▸ Bake:
   - *Bake Type* **Normal**, *Space* **Tangent**, swizzle **+X +Y +Z** (OpenGL, which is what Roblox needs).
   - **Selected to Active** on. Either *Extrusion* + *Max Ray Distance* (start 0.02–0.1 studs), or a **Cage** object (a slightly inflated copy of the low-poly) with *Cage Extrusion*.
   - *Output ▸ Margin* 8–16 px, type *Extend* (prevents seam lines at lower mips).
5. Click **Bake**, then save the image (PNG). Repeat with *Bake Type* **Ambient Occlusion** (no high-poly needed for self-AO: untick Selected to Active), and optionally **Diffuse** with only *Color* contribution to transfer a high-poly's colours.
6. In Roblox there is no AO slot: multiply AO into the ColorMap (Photopea/Krita layer at 30–60% Multiply) or bake it in with a MixRGB node.
7. Name outputs with affixes `Prop_Color.png`, `Prop_Normal.png`, `Prop_Roughness.png`, `Prop_Metalness.png` (the Importer and `cd:art/modeling/texture-specifications.md` expect these maps).

**Common mistakes:** red/black blotches = ray distance too small or flipped normals on the low-poly; wavy gradients on flat faces = low-poly smooth-shaded without hard edges at UV seams (split seams at hard edges, or use Weighted Normal); a normal map saved as sRGB; baking with the high-poly hidden from render.

### 1.9 Materials → Roblox SurfaceAppearance

Roblox's Importer reads Principled BSDF connections and creates a `SurfaceAppearance` automatically when PBR textures are wired correctly (`cd:art/modeling/assign-textures.md`, `cd:studio/importer.md`). Connect only these:

| Blender (Principled BSDF) | Roblox SurfaceAppearance | Image format |
|---|---|---|
| Image Texture `Color` → **Base Color** | `ColorMap` | RGB 24-bit (RGBA if using alpha) |
| Image alpha → **Alpha** | ColorMap alpha + choose `AlphaMode` (Overlay / Transparency / TintMask) in Studio | |
| Image `Color` → **Normal Map** node (Tangent) → **Normal** | `NormalMap` | RGB, **OpenGL** tangent space, Non-Color |
| Image `Color` → **Roughness** | `RoughnessMap` | 8-bit grayscale, Non-Color |
| Image `Color` → **Metallic** | `MetalnessMap` | 8-bit grayscale, mostly 0 or 1 |
| Emission colour/strength | `EmissiveMaskContent` (grayscale) + `EmissiveTint`/`EmissiveStrength` set in Studio | 8-bit grayscale |
| AO, Specular, IOR, Subsurface, Sheen, Coat, Transmission | **Not used** | Bake AO into Color; ignore the rest |

Faster setup: **Node Wrangler** (bundled add-on, `bm:addons/node_wrangler.rst`) — select the Principled node and press `Ctrl+Shift+T` (*Add Principled Texture Setup*), pick all maps; it wires them by filename suffix and sets Non-Color where appropriate.

One material per mesh. If a mesh has several materials the Importer splits it into several MeshParts (09 §2.2). Textures embed automatically in GLB; for FBX use *Path Mode Copy* + *Embed Textures*. Texture maps on SurfaceAppearance cannot be changed by game scripts at runtime (09 §4.1), so plan variants as separate SurfaceAppearance instances.

### 1.10 Export settings for Roblox (quick reference)

From `cd:art/blender.md`, `cd:avatar/character-bodies/export.md`, `cd:avatar/emotes/export.md` and the Blender manual (`bm:files/import_export/fbx_legacy.rst`, `bm:addons/scene_gltf2.rst`). In Blender 5.x *File ▸ Import ▸ FBX* is a new C++ importer; **export still uses the FBX add-on** whose options are documented in `fbx_legacy.rst`.

| Setting | glTF 2.0 (.glb), static props | FBX, static | FBX, rigged/skinned | FBX, animation |
|---|---|---|---|---|
| Include | **Selected Objects** (Limit to Selected) | Selected Objects | Selected (mesh + armature) | Selected (mesh + armature) |
| Format / Path Mode | **glTF Binary (.glb)**; Images PNG | Path Mode **Copy**, **Embed Textures** on | Copy + Embed | Copy + Embed |
| Scale | (none needed) | *Apply Scalings* **FBX Unit Scale**, Scale 1.0 | same | same |
| Axes | **+Y Up** on | Forward **Z**, Up **Y** (per Roblox docs; verify with an arrow-shaped test asset) | same | same |
| Apply Modifiers | on | on | on (but never a Mirror after an Armature) | on |
| Custom Properties | — | — | on | on |
| Leaf bones | — | — | **Add Leaf Bones off** | off |
| Bake Animation | off | off | off | **on**; uncheck *NLA Strips*, *All Actions*, *Force Start/End Keying*; *Simplify* **0.0** |
| Timeline | — | — | — | Start/End cover all keyframes |

Then in Studio: *File ▸ Import* (Importer), World Forward *Front*, World Up *Top*, Scale Unit *Stud*, Creator = the game's group (09 §2.5). Alternatives if FBX scale is still wrong: export Scale 0.01, or Scene Unit Scale 0.01 (docs note the latter can cause camera/modifier issues). Old tutorials often recommend these; prefer FBX Unit Scale or glTF.

**Official Roblox Blender plugin:** an open-source add-on that uploads selected objects straight to your Roblox account through Open Cloud (`cd:art/modeling/roblox-blender-plugin.md`, https://github.com/Roblox/roblox-blender-plugin). Check its repository for Blender-version compatibility before relying on it; the file-export route always works.

### 1.11 Rigging and animation for Roblox (R15 and custom)

There are three separate jobs; don't confuse them.

**A. Animate a standard R15/R6 character (most common).** Roblox animations are `Animation` assets referencing keyframe data on Motor6D joints. Two routes from Blender:

1. **Community round-trip plugin** (what most 2025–2026 videos use): the *Blender Animations* plugin, originally by Den_S and now maintained by Cautioned (Studio plugin + Blender add-on; DevForum thread "Blender rig exporter/animation importer", https://devforum.roblox.com/t/blender-rig-exporteranimation-importer/34729). Typical flow reported in that thread and in the videos below: select the rig in Studio ▸ export it with the plugin ▸ import into Blender with the add-on (it builds an armature matching the Motor6Ds) ▸ animate in Pose Mode ▸ in the add-on's `N`-panel tab press *Export Animation* ▸ in Studio select the rig ▸ *Import Animation* ▸ save/publish from the Animation Editor. It is third-party: read its current release notes, keep Blender at a version it supports, and expect breakage after Roblox or Blender updates. Forum tips: rotate Studio-generated R15 rigs 180° before export if they come in backwards; use the plugin's cleanup button to remove helper parts.
2. **Official FBX import:** with a standard R15 rig selected in the Animation Editor, *⋯ ▸ Import ▸ From File* and choose an FBX exported with the "animation" column above (`cd:avatar/emotes/import.md`). Convert to a `CurveAnimation` (Curve Editor button) if you need emote-grade data, then *⋯ ▸ Publish to Roblox*. Bone names in the FBX must match the R15 part names (HumanoidRootPart, LowerTorso, UpperTorso, Head, LeftUpperArm, LeftLowerArm, LeftHand, and so on). Start from the official template rigs in `cd:art/modeling/project-files.md` rather than building your own skeleton.

**B. Custom skinned meshes** (monsters, NPC crowds, layered clothing). Build an armature (root bone at origin, ≤ 4 influences per vertex, no weights on root; `cd:art/modeling/specifications.md`), parent the mesh with *Automatic Weights* (`Ctrl+P ▸ With Automatic Weights`), fix weights in Weight Paint, export FBX with the "rigged" column, import with the Importer's *Rig Type* set. Bones become `Bone` instances you can animate in Studio's Animation Editor, or import animation onto them. Studio's *Avatar Setup* can auto-rig and cage a humanoid mesh (09 §12.4).

**C. Emotes for the Marketplace:** under 10 s, standard R15, root may not travel far, must be a CurveAnimation (`cd:avatar/emotes/specifications.md`). Not needed for in-game animations.

Animation craft (applies in any tool): block key poses first (contact, down, passing, up for walks), then breakdowns, then polish curves in the Graph Editor; loops must have identical first and last poses (copy the first keyframe to the end, `Ctrl+C/Ctrl+V` in the Dope Sheet); keep the root still for in-place locomotion; set Animation Priority in Studio (05 §7.2). Match Blender's scene frame rate to the Animation Editor's frame-rate setting so key timing survives.

**Rigify** (bundled, `bm:addons/rigify/`) is excellent for film-style rigs but its bone names and extra control bones do not match Roblox R15; use it only for custom skinned characters, and bake to deform bones before export.

### 1.12 Add-ons useful for Roblox

Since Blender 4.2, most add-ons install from the Extensions platform (*Edit ▸ Preferences ▸ Get Extensions*, https://extensions.blender.org; or `blender --command extension install <id>`, `bm:advanced/command_line/extension_arguments.rst`). Prefer free extensions; never install add-ons from unknown sites (they are arbitrary Python).

| Add-on | Cost | Why |
|---|---|---|
| Node Wrangler (bundled) | free | `Ctrl+Shift+T` PBR setup, preview nodes |
| glTF 2.0 importer/exporter (bundled) | free | GLB export for Roblox |
| Rigify (bundled) | free | Custom skinned characters only |
| LoopTools (extension) | free | Circle/relax/space loops; clean cylinders and holes |
| Bool Tool (extension) | free | Quick boolean cutters for hard-surface |
| 3D Print Toolbox (extension) | free | Finds non-manifold edges, zero-area faces and intersections (useful "is it watertight?" check for accessories) |
| Texel Density Checker (extension) | free | Measure and set px/stud across props |
| Roblox Blender plugin (Roblox, GitHub) | free | Upload to Roblox without the Importer |
| Blender Animations plugin (Cautioned, DevForum) | free | R15/R6 animation round trip |
| UVPackmaster, Zen UV, Hard Ops/BoxCutter | paid | Faster packing/UV/hard-surface; never required |

### 1.13 Headless bpy scripting for an AI agent

Chapter 09 §10 has a complete generator (`make_lowpoly_tree.py`). This section adds the pieces an agent needs around it: validating, exporting, baking and rendering icons without a GUI.

Command line (`bm:advanced/command_line/arguments.rst`): `-b` background, `-P <file>` run script, `--factory-startup` ignore user prefs/startup file (reproducible), `--python-exit-code 1` return non-zero when the script raises (lets the agent detect failure), `--` ends Blender's args (everything after goes to `sys.argv` for your script), `--addons a,b` enable add-ons.

```bash
blender -b --factory-startup --python-exit-code 1 assets/src/crate.blend \
  -P tools/validate_export.py -- --out build/meshes --max-tris 4000
```

```python
# tools/validate_export.py — validate every mesh in the open .blend and export one GLB each.
# Blender 4.2+/5.x. Fails (non-zero exit with --python-exit-code) on any rule violation.
import bpy, sys, os, argparse, math

argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
ap = argparse.ArgumentParser()
ap.add_argument("--out", required=True)
ap.add_argument("--max-tris", type=int, default=20000)   # Roblox hard limit is 20,000
args = ap.parse_args(argv)
os.makedirs(args.out, exist_ok=True)

problems = []
depsgraph = bpy.context.evaluated_depsgraph_get()

for obj in [o for o in bpy.context.scene.objects if o.type == "MESH"]:
    # 1) Transforms applied?
    if any(abs(s - 1.0) > 1e-4 for s in obj.scale) or any(abs(r) > 1e-4 for r in obj.rotation_euler):
        problems.append(f"{obj.name}: unapplied rotation/scale (Ctrl+A > All Transforms)")
    # 2) Triangle count of the evaluated mesh (modifiers included)
    ev = obj.evaluated_get(depsgraph)
    me = ev.to_mesh()
    tris = sum(len(p.vertices) - 2 for p in me.polygons)
    # 3) UVs inside 0-1
    uv_out = False
    if me.uv_layers:
        uv = me.uv_layers.active.data
        uv_out = any(not (-1e-4 <= d.uv.x <= 1.0001 and -1e-4 <= d.uv.y <= 1.0001) for d in uv)
    ev.to_mesh_clear()
    if tris > args.max_tris:
        problems.append(f"{obj.name}: {tris} tris > {args.max_tris}")
    if len(obj.data.uv_layers) > 1:
        problems.append(f"{obj.name}: {len(obj.data.uv_layers)} UV maps (Roblox uses one)")
    if uv_out:
        problems.append(f"{obj.name}: UVs outside 0-1")
    if len([m for m in obj.data.materials if m]) > 1:
        problems.append(f"{obj.name}: more than one material (importer will split it)")
    print(f"[ok?] {obj.name}: {tris} tris")

if problems:
    raise SystemExit("VALIDATION FAILED:\n  " + "\n  ".join(problems))

# Export each mesh separately as GLB (static props). Selection drives use_selection.
for obj in [o for o in bpy.context.scene.objects if o.type == "MESH"]:
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.export_scene.gltf(
        filepath=os.path.join(args.out, f"{obj.name}.glb"),
        export_format="GLB",
        use_selection=True,
        export_apply=True,      # apply modifiers
        export_yup=True,        # +Y up
    )
print("exported to", args.out)
```

FBX equivalent for a rigged character (operator arguments of the FBX add-on):

```python
bpy.ops.export_scene.fbx(
    filepath="build/Monster.fbx", use_selection=True,
    apply_scale_options="FBX_SCALE_UNITS", global_scale=1.0,
    axis_forward="Z", axis_up="Y",          # Roblox docs: Z Forward, Y Up — verify with a test asset
    add_leaf_bones=False, use_custom_props=True,
    bake_anim=False,                        # True only when exporting an animation
    path_mode="COPY", embed_textures=True,
)
```

Headless AO + normal bake into images (Cycles), after the low-poly has a UV map and a material:

```python
import bpy, os
scene = bpy.context.scene
scene.render.engine = "CYCLES"
scene.cycles.samples = 64
low, high = bpy.data.objects["Crate_low"], bpy.data.objects["Crate_high"]
os.makedirs(bpy.path.abspath("//textures"), exist_ok=True)   # needs a saved .blend for "//"

def target_image(obj, name, size=1024, non_color=False):
    img = bpy.data.images.new(name, size, size, alpha=False)
    if non_color:
        img.colorspace_settings.name = "Non-Color"
    mat = obj.active_material
    if mat is None:                            # bake needs a material with an image node
        mat = bpy.data.materials.new(obj.name + "_Bake")
        obj.data.materials.append(mat)
    node = mat.node_tree.nodes.new("ShaderNodeTexImage")
    node.image = img
    mat.node_tree.nodes.active = node          # bake writes into the ACTIVE image node
    return img

bpy.ops.object.select_all(action="DESELECT")
high.select_set(True); low.select_set(True)
bpy.context.view_layer.objects.active = low

nrm = target_image(low, "Crate_Normal", non_color=True)
bpy.ops.object.bake(type="NORMAL", normal_space="TANGENT", use_selected_to_active=True,
                    cage_extrusion=0.05, margin=16)
nrm.filepath_raw = "//textures/Crate_Normal.png"; nrm.file_format = "PNG"; nrm.save()

high.select_set(False)                       # self-AO: bake only the low-poly
ao = target_image(low, "Crate_AO")
bpy.ops.object.bake(type="AO", use_selected_to_active=False, margin=16)
ao.filepath_raw = "//textures/Crate_AO.png"; ao.file_format = "PNG"; ao.save()
```

Render a transparent 512×512 icon or Creator Store preview of a model (three-point lighting, orthographic 3/4 view):

```python
import bpy, math, mathutils
scene = bpy.context.scene
for engine in ("BLENDER_EEVEE", "BLENDER_EEVEE_NEXT"):     # name changed between 4.2 and 5.0
    try:
        scene.render.engine = engine; break
    except TypeError:
        pass
scene.render.resolution_x = scene.render.resolution_y = 512
scene.render.film_transparent = True                    # alpha background
scene.render.image_settings.file_format = "PNG"
scene.render.image_settings.color_mode = "RGBA"
scene.view_settings.view_transform = "Standard"         # keep palette colours true (not Filmic/AgX)

target = bpy.data.objects["Crate"]
center = sum((target.matrix_world @ mathutils.Vector(c) for c in target.bound_box), mathutils.Vector()) / 8
size = max(target.dimensions)

cam_data = bpy.data.cameras.new("IconCam"); cam_data.type = "ORTHO"; cam_data.ortho_scale = size * 1.6
cam = bpy.data.objects.new("IconCam", cam_data); scene.collection.objects.link(cam)
cam.location = center + mathutils.Vector((size * 2, -size * 2, size * 1.6))
cam.rotation_euler = (center - cam.location).to_track_quat("-Z", "Y").to_euler()
scene.camera = cam

def light(name, energy, loc):
    d = bpy.data.lights.new(name, "SUN"); d.energy = energy
    o = bpy.data.objects.new(name, d); scene.collection.objects.link(o)
    o.rotation_euler = (center - (center + mathutils.Vector(loc))).to_track_quat("-Z", "Y").to_euler()
light("Key", 3.0, (3, -2, 4)); light("Fill", 1.0, (-3, -1, 2)); light("Rim", 2.5, (0, 4, 3))

scene.render.filepath = "//renders/Crate_icon.png"
bpy.ops.render.render(write_still=True)
```

Agent rules for bpy: run every script in `--factory-startup` mode; keep generated `.blend` sources and scripts in the repo (art as code); re-run validation after every change; print a one-line summary per asset (name, tris, materials, size in studs) so the log can be checked; never `pip install` into Blender's Python from untrusted sources.

### 1.14 Best videos to learn Blender (for Roblox)

*Fundamentals*
- [Beginner Blender Tutorial (2026)](https://www.youtube.com/watch?v=z-Xl9tGqH14) — Blender Guru · 4:19:10. The full "donut" course in one video, remade for Blender 5.0 (Blender Guru's site lists the 5.0 series from November 2025, https://www.blenderguru.com/posts/blender-donut-v5-tutorial). It teaches navigation, modelling, modifiers, materials, geometry nodes scattering, lighting and rendering. Long and not game-specific, but it is the standard first course and uses the current interface.
- [ABSOLUTE Beginner Basics.. Blender For Noobs 2025](https://www.youtube.com/watch?v=peSv5IT5Ve4) — RoBuilder · 8:27. A short Roblox-creator-oriented introduction to the interface (2M views). Watch it before the donut if four hours is too much.
- [The ULTIMATE Blender Modeling Guide for Noobs! (Make Assets For Games!)](https://www.youtube.com/watch?v=W337AL7n3dc) — SmartyRBX · 34:20. Game-asset modelling for Roblox creators, ending with an FBX export into Studio (per the snippet). If it uses FBX defaults, apply the scale settings in §1.10 instead.
- [10 Tools Every Blender Noob Should Learn](https://www.youtube.com/watch?v=KfSQh2dFCik) — Brad Colbow · 9:44. A short tour of the core modelling tools (extrude, inset, loop cut, bevel and similar), the ones in §1.2.
- [Blender 4.0 Short Cut Keys | Tips For Beginners](https://www.youtube.com/watch?v=9WTjowONPRw) — FlowPoly · 15:33. Walks through the commonly used shortcuts in one video; pairs with the table in §1.2.
- [Starting Blender? Advice from a Pro](https://www.youtube.com/watch?v=-rO1o5uzCOc) — Blender Guru · 8:03. Learning-path advice; the description's first line is "Don't learn geometry nodes" (i.e. learn modelling fundamentals first). Useful to keep the owner from over-scoping.

*Low-poly and hard-surface*
- [Learn Low Poly Modeling in Blender 2.9 / 2.8](https://www.youtube.com/watch?v=1jHUY3qoBu8) — Imphenzia · 1:23:16. A long walkthrough of Imphenzia's low-poly techniques including palette-texture colouring; a learner's notes describe linking the palette to Base Color and switching interpolation from Linear to Closest (https://gist.github.com/mschneider247/c0cb850a23303ea9764675def782d3f6). Old UI, still the best fit for the bot's default style.
- [Step by Step Low Poly Modeling in Blender 4 4](https://www.youtube.com/watch?v=0GPJCdYCLnA) — Imphenzia · 1:16:57. The same approach in Blender 4.4 with a public-domain palette texture (per the description). Watch this one if the 2.9 UI is confusing.
- [9 Low Poly Hacks I Wish I Knew Sooner](https://www.youtube.com/watch?v=1BkBXRHnFJw) — Imphenzia · 3:43. Quick tips companion to the long videos.
- [Beginner Blender 4.2 Tutorial: Modelling a Low-Poly Well - Part1](https://www.youtube.com/watch?v=QPh8h0hWkg0) — Grant Abbitt · 15:30. A complete small prop from simple primitives, a good first Roblox-style asset.
- [Blender Hard-Surface Modeling Fundamentals](https://www.youtube.com/watch?v=nsTjnQ067sw) — CG Boost (Louis du Mont) · 31:06. Core hard-surface techniques on a fun object; [6 Blender Hard-Surface Modeling Tricks I Wish I Knew Earlier](https://www.youtube.com/watch?v=Ml2t8uxPAQU) (9:32) is the short follow-up on speed tricks.
- [COMPLETE Beginners Guide to Hard Surface Modeling](https://www.youtube.com/watch?v=1qVbGr_ie30) — Josh, Blender Bros · 40:05. Booleans, bevels and shading workflow. Their style targets high-poly renders: for Roblox keep the bevel + weighted-normal subset.

*UVs, painting, baking, PBR*
- [Blender 4.0: How to UV Unwrap Anything](https://www.youtube.com/watch?v=XleO7DBm1Us) — On Mars 3D · 7:36. A short method for choosing seams on any shape (750k views); the channel's [Blender 5.0 version](https://www.youtube.com/watch?v=dm3bBpZVmnE) (28:34) is longer and current.
- [Blender 5 - UV Unwrapping Just Got WAY Easier](https://www.youtube.com/watch?v=DmuZTw3UZ-c) — Grant Abbitt · 4:54. What changed in Blender 5's UV tools (overhauled UV selection and new island-alignment operators, per release coverage).
- [GAME ASSET BEGINNER TUTORIAL - UV Unwrapping In Blender (Part 2/5)](https://www.youtube.com/watch?v=-uYwkBCPpiQ) — LMHPOLY · 12:23. Unwrapping a game-asset barrel within a full low-poly-to-texture series: exactly the prop workflow Roblox needs.
- [Blender 5.1 Texture Painting: A Detailed Guide for Beginners](https://www.youtube.com/watch?v=7kSRXnAi7uA) — Grant Abbitt · 21:08. Step-by-step texture painting in the current version.
- [Blender 4.0 - Texture Painting quick start guide](https://www.youtube.com/watch?v=iwWoXMWzC_c) — Jamie Dunbar · 5:31. The five-minute version (900k views).
- [How to Bake Perfect Normals in Blender](https://www.youtube.com/watch?v=0r-cGjVKvGw) — Blender Guru · 12:41. High-to-low normal baking with a starter file. Nine years old (old UI), but the concepts (cage, ray distance, artifacts) are unchanged; [Ryan King Art's 6:47 version](https://www.youtube.com/watch?v=dPbrhqqrZck) uses a newer UI.
- [How To Add Realistic Materials and Textures in Roblox Studio | Surface Appearance & PBR](https://www.youtube.com/watch?v=Fsj-y9NHOgo) — Paul1Rb · 8:29. The Roblox side: what each PBR map does and how SurfaceAppearance uses them.
- [Blender 3.4 - Instantly Set Up PBR Materials](https://www.youtube.com/watch?v=GdfyTXHBsyE) — Quick Tech Tips · 0:19. The Node Wrangler `Ctrl+Shift+T` trick in 19 seconds.

*Roblox import/export, rigging and animation*
- [Blender to Roblox Studio! (FULL GUIDE)](https://www.youtube.com/watch?v=-fxuMKQim9Q) — RoBuilder · 10:08, and [Importing and Exporting on Roblox/Blender! (FULL GUIDE)](https://www.youtube.com/watch?v=vbXVLmSpQe4) (8:46). Both directions of the pipeline for Roblox creators. Check their scale settings against §1.10.
- [Blender to Roblox Scale Setup (1:1 + 0.01 Export + Apply Transforms)](https://www.youtube.com/watch?v=qCOuV6PK8Io) — Corg · 2:17. The snippet describes modelling at 1:1, applying rotation/scale and exporting FBX at 0.01. That is one of the docs' alternatives; FBX Unit Scale or glTF is simpler.
- [Roblox Animation in Blender: Full Beginner Guide [2026]](https://www.youtube.com/watch?v=eg6COxaPCyo) — Nisky · 7:46 (520k views), and its [Advanced Guide (2026)](https://www.youtube.com/watch?v=EM9u4gIHoRg) (31:26). The most-watched current series on animating Roblox rigs in Blender, with tutorial files linked in the description.
- [Roblox Blender Animation Tutorial 2025](https://www.youtube.com/watch?v=k8hanW7FFuA) — Meep Man · 19:31. Covers the switch from the old dead plugin to Cautioned's rebuilt Blender Animations plugin (per the description), with the DevForum download.
- [Import Blender Animations Into Roblox R6 AND R15 Rigs [2026]](https://www.youtube.com/watch?v=X140xvLc_Rs) — Sw1tch · 11:21. Both rig types through the add-on.
- [[ROBLOX/Blender] How to attach rigged weapons/items to IK rigs](https://www.youtube.com/watch?v=UfQSPaHR3pA) — tankFlatter · 4:19. Animating with a held tool using Cautioned's plugin; needed for combat animations.

*GFX and stylized assets*
- [How to Make Roblox GFX in 2026](https://www.youtube.com/watch?v=wqtbhRFM_P8) — gfxrhino · 13:20. Current end-to-end Studio → Blender → 2D GFX workflow (see §6.6).
- [How To Render Roblox Characters In Blender!](https://www.youtube.com/watch?v=kpALOtLhX-Q) — Cyress · 17:22. Step-by-step character import, lighting and rendering.
- [How to Make Stylized Trees & Assets [NEWEST METHOD]](https://www.youtube.com/watch?v=0_lkryX-CgM) — DatBoiEle · 19:24. Stylized foliage for Roblox Studio using Blender (2.92) and Photopea (per description). Check the result's tri count and use `AlphaMode = Transparency` for leaf cards.
- [Retopology in Blender (Beginner Tutorial)](https://www.youtube.com/watch?v=X2GNyEUvpD4) — CG Boost · 14:15. Full retopology with free built-in tools: needed after sculpting (§4).

---

## 2. Blockbench (free, open source): blocky and pixel-textured models

**What it is for:** cube-built models with pixel-art textures: blocky props, tools, pets, low-poly characters, anything in a "voxel-ish but smooth" style that suits Roblox's blocky heritage. Since 5.0 ("The Element Update") it has armatures with a Weight Brush, spline meshes and smooth shading (https://github.com/jannisx11/blockbench/releases/tag/v5.0.0). **Cost:** free (GPL), desktop for Windows/macOS/Linux plus a browser version (https://web.blockbench.net). Docs: local copy `.sources/JannisX11_blockbench.net/content/guides/`.

### Core workflow

1. **New project ▸ Generic Model** (free-form; not a Minecraft format, which adds size and rotation limits). Per-face UV mode is the easiest to texture.
2. **Grid:** 1 grid unit = 1 "pixel"; 16 units = 1 block by default (`guides/blockbench-overview-tips.md`, Settings ▸ Snapping ▸ Grid Resolution). Decide a mapping now, e.g. **16 Blockbench units = 1 stud**, so a 5-stud character is 80 units tall.
3. Build with cubes; rotate in 22.5° steps for clean pixel alignment; use **Mesh** elements (5.x) for wedges and bevels. Group parts in the Outliner (groups become pivots; set pivot points where joints rotate).
4. **Texture:** create a texture at a small power-of-two size (16–64 px per block face; e.g. 64×64 or 128×128 for the whole model). Paint directly on the model with the pixel brush; keep a limited palette.
5. **Export** (`guides/export-formats.md`): *File ▸ Export ▸ Export glTF* (embedded textures, keeps hierarchy) or *Export OBJ* (simplest). glTF converts quads to tris; that is fine for Roblox.
6. **Import into Studio** with the Importer. Check the size against a 1×1×1 part; Blockbench's export scale setting (Settings ▸ Export) and your unit mapping decide the result, so fix scale once in Blockbench rather than per import.
7. **Fix the blur:** set the imported `SurfaceAppearance.ResampleMode` (or the MeshPart texture route's equivalent) to **Pixelated**, or upscale the texture ×8 with nearest-neighbour (e.g. 64→512 px) and re-upload. The DevForum has years of threads on this blur (https://devforum.roblox.com/t/mesh-texture-pixel-art/2303754/10).

**Common mistakes:** Minecraft formats chosen by accident (Java Block/Item is limited to 3×3×3 blocks, per `content/blockbench/formats.md`); textures with semi-transparent edge pixels (halos); one huge texture per small prop; inconsistent pixel density between props (keep e.g. 16 px per stud for everything).

### Best videos to learn Blockbench
- [BLOCKBENCH for BEGINNERS - The Interface & All Basics](https://www.youtube.com/watch?v=dsax5p4brN8) — MoreByKev · 17:05. The most-watched interface walkthrough (1.1M views): panels, cubes, UV, texturing, outliner.
- [How to create a Low Poly 3D MODEL | Tutorial](https://www.youtube.com/watch?v=WbyCbA1c8BM) — Blockbench (official) · 14:48. Low-poly mesh models with pixel-art textures, from the developers' own channel.
- [How to Make Low-Poly Models with Pixel Texture](https://www.youtube.com/watch?v=GukhptdHlPk) — Brandon James Greer · 17:26. An information-dense beginner session by a pixel artist; strong on texturing.
- [BlockBench - Stupidly Easy 3D Modeling App!](https://www.youtube.com/watch?v=RC1CYzAEgzE) — Gamefromscratch · 12:37. An overview/review of modelling, texturing and animating features; good for deciding whether Blockbench fits a project.
- [Blockbench to Roblox - Fixing Blurry Texture](https://www.youtube.com/watch?v=GM74Gp4io70) — DevDrawn · 7:41, and [How to Import BLOCKBENCH Models to ROBLOX - Fix Blurry Edges](https://www.youtube.com/watch?v=e4z7nd3Amn8) — Scrypter · 3:40. Both address the pixel blur; the first links an upscaler (the pre-ResampleMode fix). Try `ResampleMode = Pixelated` first.
- [How to make a Tool in Blockbench and import it to Roblox Studio](https://www.youtube.com/watch?v=K2EyoKf7-XQ) — GameDevBase · 2:41. A minimal end-to-end Roblox tool with chapter markers.

---

## 3. MagicaVoxel (free): voxel art

**What it is for:** voxel props, characters and dioramas; fast concept models. **Cost:** free (by ephtracy, Windows/macOS; https://ephtracy.github.io); updates are infrequent. Built-in path-traced renderer is great for concept images and marketing stills.

### Core workflow
1. Set the model size (up to 256³ per model). Pick or load a palette (256 colours); keep to a few hues.
2. Build with Attach/Erase/Paint brushes in Voxel, Face, Box or Line mode; mirror on X for symmetric models.
3. **Export ▸ obj**: produces an `.obj`, an `.mtl` and a tiny palette PNG (256×1). The mesh is already merged into large quads per face.
4. **Clean in Blender** (recommended): import OBJ, `M ▸ By Distance`, Decimate *Planar* 1°, check tri count, set the palette texture interpolation to *Closest*, scale so 1 voxel = your stud fraction (e.g. 0.25 studs), apply transforms, export GLB.
5. In Studio set `ResampleMode = Pixelated` (a 256×1 palette blurred by bilinear filtering bleeds neighbouring colours into each other).

**Common mistakes:** exporting a 128³ model straight to Roblox (tens of thousands of tris); expecting voxel-perfect collision (use Box/Hull collision); mixing voxel props with smooth realistic props. For simple blocky shapes, building the voxels as Parts from Luau may be cheaper and keeps everything in code (09 §9).

### Best videos to learn MagicaVoxel
- [Magicavoxel Beginners Guide: Basics](https://www.youtube.com/watch?v=BxuY48y6JEM) — ArtChanny · 15:19. Start of a beginner series covering the interface and brushes.
- [MagicaVoxel: The Complete Guide (Tips & Tricks)](https://www.youtube.com/watch?v=G7TzsxY-7xE) — MadMaraca · 2:34:56. The whole tutorial series in one video, from basics up, per the description.
- [How to Create 3D Voxel Art with MagicaVoxel](https://www.youtube.com/watch?v=uKOBIHSgIwI) — PremiumBeat · 34:31. A step-by-step project from start to rendered scene.
- [Magicavoxel - Organic looking trees in 20 minutes](https://www.youtube.com/watch?v=83pvUjWMlEY) — Pedro Casavecchia · 22:49. Organic shapes in voxels, useful for environment kits.

---

## 4. Substance 3D Painter (paid): PBR texturing → Roblox

**What it is for:** layered PBR texturing with smart materials, edge wear, dirt, generators and masks: weapons, vehicles, hero props, UGC. **Cost (2026, verify before buying):** Steam perpetual "Substance 3D Painter 2026" around $199.99 (launched 2026-03-17), or an Adobe Substance subscription (Indie/Texturing around $24.99/month per third-party listings; https://design-offset.com/20260318-adobe-substance-3d-on-steam/). **Free alternatives:** Blender texture painting + bakes (§1.7–1.8); Material Maker (free, procedural tiling materials, good for `MaterialVariant`); Roblox's own Texture/Material Generators (09 §13).

### Core workflow
1. In Blender: finish the low-poly, UV-unwrap (no overlaps), triangulate, one material per texture set, export FBX (and the high-poly if baking).
2. **New project:** template *PBR – Metallic Roughness*; **Normal Map Format: OpenGL**; Document Resolution 1024 (or 512 for small props; Roblox renders up to 4K, but size by world size).
3. **Texture Set Settings ▸ Bake Mesh Maps:** Normal, World Space Normal, ID, AO, Curvature, Position, Thickness; high-poly as source if you have one. Smart materials and masks depend on these bakes.
4. Layer: base material → smart material (edge wear from curvature) → dirt/grime generators from AO → hand-painted details → colour correction. Keep roughness varied; avoid fully black or white roughness areas.
5. **Export Textures** with a custom preset for Roblox (create once under *Output Templates*):

| Output file | Channels | Format |
|---|---|---|
| `$mesh_Color` | Base Color RGB (+ Opacity in A only if needed) | PNG 8-bit |
| `$mesh_Normal` | Normal **OpenGL** RGB | PNG 8-bit |
| `$mesh_Roughness` | Roughness, grayscale | PNG 8-bit |
| `$mesh_Metalness` | Metallic, grayscale | PNG 8-bit |
| `$mesh_Emissive` (optional) | Emissive as grayscale mask | PNG 8-bit |

   Padding: *Dilation + transparent* or *Dilation infinite* so seams don't show at low mips. Size: 1024 or 512.
6. Bake AO into Color by adding an AO fill layer set to Multiply at low opacity, because Roblox has no AO slot.
7. In Studio, create a `SurfaceAppearance` under the MeshPart and assign the four maps (or connect them in Blender and let the Importer build it, §1.9).

**Common mistakes:** DirectX normal format (looks inverted: lit from below); 4K exports for small props; relying on height maps (Roblox has no height/parallax slot: convert height into the normal map, which Painter does with the default normal output); realistic grime on a cartoony game.

### Best videos to learn Substance Painter
- [Bare BASICS of Substance Painter! (Start Here)](https://www.youtube.com/watch?v=CSRt6ybEg1s) — RoBuilder · 5:49. A five-minute orientation from a Roblox-focused channel.
- [Beginner Tutorial - Texturing in Substance Painter!](https://www.youtube.com/watch?v=JFGWe3G8uIo) — ProductionCrate · 34:57. The essential steps of a texturing project (import, bake, layers, export) as a beginner course.
- [Substance Painter Beginner Tutorial | 2026 | Complete Guide for Game Developers & Artists](https://www.youtube.com/watch?v=6SmTmY-7w6o) — HALbot Studios · 1:09:21. Current-version, game-oriented full course.
- [How to get textures from Substance Painter into Roblox Studio!](https://www.youtube.com/watch?v=Sgom579jF-o) — Smallhat 3d · 6:27. The export-to-SurfaceAppearance step for Roblox.
- [Roblox Accessory Texturing Tutorial (Substance Painter Workflow)](https://www.youtube.com/watch?v=x1ffbTm-qzM) — Lemonsie · 4:36. A compact accessory texturing workflow (UGC-focused, applies to props).
- [Emissive Maps w/ Roblox Studio & Substance Painter](https://www.youtube.com/watch?v=n8ILBMq3kLg) — Jabloozy · 2:57. Making an emissive map and wiring it into Roblox's emissive mask.

---

## 5. ZBrush and Nomad Sculpt (brief)

**What they are for:** sculpting organic high-poly detail (creatures, statues, stylized rocks, sculpted hats). Roblox can't use a sculpt directly: the pipeline is always **sculpt → decimate or retopologize to a low-poly → UV → bake normal/AO (§1.8) → texture**. **Cost:** ZBrush is a Maxon subscription (desktop and iPad versions); Nomad Sculpt is a cheap one-time purchase on iPad/Android with a free trial; **Blender's Sculpt Mode is free** and enough for Roblox-scale detail.

Workflow notes: sculpt with Dynamesh/Remesh (ZBrush) or Dyntopo/Voxel Remesh (Blender/Nomad) for forms, then subdivide for detail; export the high-poly as OBJ/PLY (decimated to 1–2 M polys with ZBrush's Decimation Master if needed); retopo in Blender (CG Boost video in §1.14) or decimate for background rocks; bake. For stylized Roblox art keep detail large and readable: fine pores and scratches vanish at 1024 px and mobile mip levels.

### Best videos
- [Learn Zbrush in 8 Minutes - Zbrush Beginner Tutorial](https://www.youtube.com/watch?v=pCjzgYuS6WQ) — Gatz 3D · 9:07. A fast orientation in ZBrush's unusual interface.
- [Getting Started with Sculpting - ZBrush for Beginners Tutorial](https://www.youtube.com/watch?v=_yKGfcp2z3k) — FlippedNormals · 59:20. The classic thorough beginner session (2M views); old version, same fundamentals.
- The catalog has no Nomad Sculpt video. Nomad's official documentation and its in-app tutorials are the starting point; the sculpt → retopo → bake logic above is identical.

---

## 6. 2D art: icons, thumbnails, GUI art, decals

### 6.1 The sizes Roblox needs (verified)

| Asset | Size / format | Source |
|---|---|---|
| Game icon | **512×512** square; shown down to ~150×150, so test it small; must pass moderation | `cd:production/publishing/experience-icons.md` |
| Thumbnails (images) | **16:9, ideally 1920×1080**; `.jpg .gif .png .tga .bmp`; up to **10** images/videos per game; 2+ active thumbnails turns on thumbnail personalization | `cd:production/publishing/thumbnails.md` |
| Video thumbnails | Authentic gameplay only; quota 3 uploads/month; not on console/VR | same |
| Badge icon | 512×512; **cropped to a circle** on upload, keep detail inside it | `cd:production/publishing/badges.md` |
| Developer product icon | ≤ 512×512, `.jpg/.png/.bmp`, important detail inside the circle | `cd:production/monetization/developer-products.md` |
| Game pass icon | Treat like badges: 512×512, circle-safe | (same convention) |
| Images / decals (upload) | `.png .jpeg .bmp .tga`, **< 8000×8000 px**; Open Cloud ≤ 20 MB per file | `cd:cloud/guides/usage-assets.md` |
| Mesh textures | Renderer supports up to **4096×4096**; size by object: 256 ≈ 5 studs, 512 ≈ 10, 1024 ≈ 20 | `cd:art/modeling/texture-specifications.md` |
| Classic Shirt/Pants template | 585×559 | 09 §12.5 |
| UI images | Export at **1×–2×** the largest on-screen size, no more; pack small icons into sheets (`ImageRectOffset/ImageRectSize`) | 09 TL;DR 13 |

Thumbnail content must accurately represent the game (07 §7.11); craft rules for clickable icons and thumbnails are in chapter 16 §8.

### 6.2 Export rules for transparent PNGs, 9-slice and sheets

- **RGBA PNG, 8 bits per channel, straight alpha.** Photoshop/Photopea: *Export As ▸ PNG* with Transparency on; Krita: *File ▸ Export* PNG, "Store alpha channel"; GIMP: *File ▸ Export As* `.png` (add an alpha channel first: *Layer ▸ Transparency ▸ Add Alpha Channel*).
- **No halos:** paint or composite on transparent, not on white then erase. Fringe pixels with partial alpha and a white/black RGB become visible outlines when Roblox scales the image. In Photoshop, *Layer ▸ Matting ▸ Defringe 1 px* fixes inherited fringes.
- **Keep a 2–4 px transparent margin** around icons in a sheet so mipmapping does not bleed neighbours in.
- **9-slice art** (buttons, panels, frames that stretch): design at 2× (e.g. a 128×128 rounded panel with 24 px corners). Corners must be fully inside the corner regions; the centre should be flat or tileable. In Studio set `ScaleType = Slice`, `SliceCenter = Rect.new(24, 24, 104, 104)` (pixel coordinates of the stretchable centre in the source image) and `SliceScale` (0.5 if the art was drawn at 2×), or use the 9-Slice Editor (`cd:ui/9-slice.md`). Record the rect next to the PNG (`panel_round.png  slice=24,24,104,104`).
- **Pixel art UI:** scale by whole numbers in the art tool (nearest neighbour) and set `ResampleMode = Pixelated` on the ImageLabel.
- **Colour:** export sRGB; avoid embedding odd colour profiles; check contrast on light and dark backgrounds.
- **Script it when you can:** an agent can generate or verify icons with Pillow (size, mode RGBA, alpha present, circle-safe content) and render vectors with Inkscape's CLI:

```bash
inkscape icons/coin.svg --export-type=png --export-width=256 --export-filename=build/ui/coin@2x.png
krita --export --export-filename build/ui/panel.png art/panel.kra      # Krita headless export
```

```python
# tools/check_icon.py — sanity-check a 512x512 game/badge icon (pip install pillow)
import sys
from PIL import Image
im = Image.open(sys.argv[1])
assert im.size == (512, 512), f"icon is {im.size}, expected 512x512"
if im.mode in ("RGBA", "LA"):
    lo, hi = im.getchannel("A").getextrema()
    assert hi > 0, "icon is fully transparent"
    if lo < 255:
        print("note: icon has transparency; game icons are shown on varied backgrounds, prefer opaque")
small = im.convert("RGB").resize((150, 150), Image.LANCZOS)
small.save(sys.argv[1].replace(".png", "_150preview.png"))   # look at this before uploading
if "--circle" in sys.argv:                                   # badges/passes are cropped to a circle
    corners = [im.convert("RGBA").getpixel(p) for p in [(8, 8), (503, 8), (8, 503), (503, 503)]]
    print("corner pixels (will be cropped away):", corners)
print("ok", im.mode, im.size)
```

### 6.3 Photoshop (paid) and Photopea (free, browser)

**What for:** compositing GFX thumbnails and icons, logos with layer effects, UI panels and buttons, texture touch-ups (multiply AO, colour-correct a ColorMap, make a tileable texture with *Filter ▸ Other ▸ Offset*). **Cost:** Photoshop is an Adobe subscription; **Photopea** (https://www.photopea.com) is free in the browser with ads (an optional premium removes them), opens and saves PSDs, and has nearly the same menus, layer styles, adjustment layers, smart objects and shortcuts. Because Photopea runs in the browser, the owner can use it on any computer.

**Core workflow (icon or thumbnail compositing):**
1. New document 512×512 (icon) or 1920×1080 (thumbnail), 72 ppi, RGB 8-bit.
2. Place the render (from Blender or a Studio screenshot) as its own layer; background on a separate layer below.
3. Non-destructive adjustments above it: Curves (contrast), Hue/Saturation (+10–20 saturation for simulator/bright games), Color Balance (warm highlights, cool shadows).
4. **Shading/paint-over** on new layers clipped to the subject (`Ctrl+Alt+G` / right-click ▸ Create Clipping Mask): Multiply layer for shadows, Overlay/Color Dodge layer for highlights and rim light, soft round brush at low flow.
5. Effects: outer glow or a stroke on the subject to separate it from the background; subtle radial light behind the subject; motion lines or particles sparingly.
6. Text/logo: few words, heavy font, thick stroke (layer style *Stroke* 6–12 px at 512), drop shadow, gradient overlay; keep away from the edges (safe margin ~6%).
7. Sharpen the final (*Filter ▸ Sharpen ▸ Smart Sharpen*, small radius), then **check at 150 px** (*View ▸ 25%*) and export PNG (icon) or high-quality JPG/PNG (thumbnail).

**Common mistakes:** text too small or with a thin outline; over-saturation and heavy glow everywhere; blurry upscaled screenshots (render at final size or bigger); copyrighted characters, logos or fonts you don't have rights to; misleading content that isn't in the game.

**Best videos (Photopea/Photoshop for Roblox):**
- [HOW TO Make a FREE Roblox GAME ICON in 10 Minutes | Photopea Online Tutorial](https://www.youtube.com/watch?v=ROuqllP6_I8) — Pogo · 12:42. A complete free icon made in Photopea.
- [How To Make Professional Roblox Thumbnails WITHOUT BLENDER](https://www.youtube.com/watch?v=th2DJ7-5MnU) — bubDEV · 18:10. Thumbnails from Studio captures plus 2D work only, for when a Blender render is overkill.
- [SHADING TUTORIAL [Photoshop/Photopea] | ROBLOX GFX](https://www.youtube.com/watch?v=_DwZiSHfTsQ) — gfxrhino · 7:43. The basics of painting shading over a render in Photoshop or Photopea: step 4 above.
- [how to make 3d text in photopea || roblox gfx tutorial](https://www.youtube.com/watch?v=NqIc8WLHZ8k) — nami gfx · 3:37. Layered/extruded title text, the usual logo trick.
- [Game UI Tutorial - Make a Game Icon without Painting on Photoshop | Path & Shape](https://www.youtube.com/watch?v=R32QxeoBNKU) — WOO Visual Art · 14:07. Builds a fantasy quest-book icon from paths and shapes instead of painting; a technique that suits clean UI icons and is easy to keep consistent.
- [The Art of Game UI - Good VS Boring](https://www.youtube.com/watch?v=dL152bMdK0k) — Angelikatosh · 20:30. Not a tool tutorial: a design discussion of what makes game UI art appealing, useful before drawing any UI kit.

### 6.4 Krita (free): painting

**What for:** digital painting (concept art, painted textures over a UV layout, hand-painted UI elements, painted thumbnail backgrounds). Brush engine and stabilizers are excellent; layer styles exist but compositing is less convenient than Photopea. **Cost:** free (GPL), Windows/macOS/Linux/Android; 5.3.x (Qt5) and 6.0.x (Qt6) lines were released together in March 2026 (Krita's site: https://krita.org; manual: https://docs.krita.org).

Workflow: new document at 2× final size → sketch layer → flat colour layer (use *Alpha Lock* on the layer to paint inside shapes) → shading layers set to Multiply/Overlay → *Filter ▸ Adjust* for colour → *File ▸ Export* PNG with alpha. For textures, enable *wrap-around mode* (`W`) to paint seamless tiles; import the UV layout exported from Blender as a reference layer. Pixel art: use the *Pixel Art* brush preset and turn off antialiasing.

**Best videos:**
- [Krita Basics: The Best FREE Drawing App For Beginners](https://www.youtube.com/watch?v=T8i94iQxyNw) — halishy · 8:09. Brushes, layers and colour basics in eight minutes.
- [How to Use KRITA - Digital Art Tutorial for Beginners](https://www.youtube.com/watch?v=Uv7Tu-cOzPw) — Winged Canvas · 18:02. A structured first lesson from an art-school channel.
- [Digital Painting. Krita for beginners](https://www.youtube.com/watch?v=tRY5bGsJ0f0) — Krita (official) · 15:52. The official channel's introduction.

### 6.5 GIMP (free): photo editing and batch work

**What for:** cropping, colour correction, background removal, alpha cleanup and simple compositing when Photopea is unavailable offline. **Cost:** free; GIMP 3.2 (March 2026) added non-destructive link layers and vector layers (https://gimp.org/news/2026/03/14/gimp-3-2-released). GIMP 3 has non-destructive filters, so many old 2.10 tutorials are dated.

Typical Roblox uses: *Image ▸ Canvas Size* to pad to 512×512; *Colors ▸ Curves*; *Layer ▸ Transparency ▸ Color to Alpha* for quick keying of flat backgrounds; *Filters ▸ Map ▸ Tile Seamless* for tiling textures; *File ▸ Export As* PNG.

**Best videos:**
- [Learn GIMP 3.0 Photo Editing for Beginners in 25 Minutes](https://www.youtube.com/watch?v=pXsP6vNtjck) — Davies Media Design · 25:37. Current-version photo editing start to finish.
- [GIMP in Less Than 10 Minutes: Beginners Guide](https://www.youtube.com/watch?v=_L_MMU22bAw) — Davies Media Design · 8:35. Older (2.x) but a fast orientation to the interface.

### 6.6 Making a clickable icon or thumbnail (the GFX workflow)

"GFX" in Roblox slang means a rendered, painted-over promotional image. Pipeline:

1. **Plan** (chapter 16 §8): one clear subject doing the game's core action, readable at 150 px, colours that signal the genre, no clutter, accurate to the game.
2. **Pose in Studio** (fastest): build a mini set, load characters (your own avatar or original NPC rigs), pose with the Animation Editor or Moon Animator, set showcase lighting (02 §15), raise graphics quality, and either screenshot at high resolution or export the selection (*File ▸ Export Selection*, OBJ) to Blender.
   **Or pose in Blender:** import the exported rig (gfx videos use an R15 rig file or a plugin to bring the avatar with textures), pose bones in Pose Mode.
3. **Render in Blender:** Cycles, 1920×1080 (thumbnail) or 1024×1024 (icon, downsized later), denoise on; three-point light (key warm, rim strong behind the subject, cool fill) or an HDRI plus a rim light; camera with a slightly wide lens (24–35 mm) and a low angle for drama; *Film ▸ Transparent* if compositing over a painted background. Fix the classic issues: re-link missing textures after OBJ import (the "FIX Roblox Studio to Blender Map Textures" video below), set material roughness so plastic avatars don't look matte grey.
4. **Paint over in Photopea/Photoshop** (§6.3): background, colour grade, rim light and shading paint-over, glow, title text.
5. **Check and export:** view at 150 px and on a phone screen; export PNG; upload as icon/thumbnail; for Home-page eligibility a custom thumbnail is now required (07 §7.11). Make 2–3 genuinely different concepts and let thumbnail personalization test them.

**Best videos (GFX, thumbnails, icons):**
- [How to Make Roblox GFX in 2026](https://www.youtube.com/watch?v=wqtbhRFM_P8) — gfxrhino · 13:20. Current versions of Blender and Studio, step by step, from capture to finished GFX (per the description).
- [How To Create Quality Roblox Thumbnails | Complete Tutorial](https://www.youtube.com/watch?v=uS4cB1w_7gI) — Cyress · 36:26. Rendering an avatar in Blender and composing a full game thumbnail from it.
- [The SIMPLE Fix to Bad Posing | Roblox GFX Tutorial](https://www.youtube.com/watch?v=4NvaH2KFsoY) — gfxrhino · 11:02. Posing rigs with weight, line of action and personality instead of stiff "soldier" poses (the same critique chapter 16 records).
- [CHARACTER LIGHTING (RIM LIGHT EFFECT) IN BLENDER | ROBLOX GFX TUTORIAL](https://www.youtube.com/watch?v=okGb9t8DeUQ) — ArielGFX · 3:11. Rim lighting with an HDRI (Poly Haven) to separate the subject.
- [How to Make HIGH CTR Roblox GFX](https://www.youtube.com/watch?v=GyoA8dHKdZw) — gfxrhino · 14:51, and [How to ACTUALLY Make High CTR Roblox Thumbnails](https://www.youtube.com/watch?v=SjjPGduApZU) — CallMeDogey · 6:24. The current "high CTR" style. Use with judgement: chapter 16 notes clickbait CTR does not retain players, and thumbnails must match the game.
- [How to make HIGH QUALITY CTR LOGOS for your ROBLOX GAMES (FULL GUIDE)](https://www.youtube.com/watch?v=iLrdGStjUWg) — velli · 8:17. Game title logos with assets linked in the description (a Blender lighting setup is mentioned).
- [FIX Roblox Studio to Blender Map Textures](https://www.youtube.com/watch?v=daxc17ab32w) — gfxrhino · 2:30. Fixing textures missing after exporting a Studio map to Blender.

### 6.7 Aseprite (paid, source available) and pixel art

**What for:** pixel-art icons, pixel UI kits, sprite sheets and flipbook animations (e.g. for `ImageLabel` frame animation or particle flipbooks), textures for Blockbench models. **Cost:** $19.99 on Steam or itch.io (https://www.aseprite.org); the source is on GitHub under a source-available licence and can be compiled for free for personal use. **Free alternatives:** LibreSprite (a fork of the last GPL version), Pixelorama, Krita with the pixel brush.

Workflow: new sprite at the true pixel size (16×16, 32×32 icons; up to 64×64); indexed colour mode with a limited palette (8–32 colours; e.g. a public palette from Lospec, checking its licence); draw with the pencil (`B`), pixel-perfect stroke on, shade with hue-shifted ramps (shadows cooler and more saturated, highlights warmer), animate with frames and onion skin; *File ▸ Export Sprite Sheet* (packed, with JSON data if you script the frames); export scaled ×4–×8 with nearest neighbour for Roblox, or upload at 1× and set `ResampleMode = Pixelated`.

**Best videos:**
- [Everything You Need to Know About ASEPRITE | Pixel Art Fundamentals](https://www.youtube.com/watch?v=Ep-_nJNHPc4) — Watt · 17:13. A tour of Aseprite's most useful tools and how to use them effectively.
- [Aseprite Guide for Beginners (Pixelart Tutorial)](https://www.youtube.com/watch?v=Md6W79jtLJM) — MortMort · 19:02. The classic beginner guide (1M views); older UI but the tools are unchanged.
- [The ONLY Pixel Art Guide You Need (Beginner to Advanced)](https://www.youtube.com/watch?v=DKmrBUpd0yw) — Juniper Dev · 15:02. Pixel-art principles (resolution, palettes, shading, outlines) independent of tool.

### 6.8 Inkscape (free) and Figma (freemium): vector icons and UI mockups

**Inkscape** (free, https://inkscape.org) is for vector icons, logos and UI glyphs: they stay crisp at any size and the bot can write SVG directly and render it with the CLI (§6.2). Workflow: document at the final pixel size (e.g. 256×256), build icons from simple shapes with *Path ▸ Union/Difference*, a consistent stroke width (e.g. 12 px at 256) and corner radius, a 2-tone or 3-tone palette per icon set; *Export* panel ▸ PNG at 1× and 2×. Keep one SVG per icon with ids; batch export by script.

**Figma** (https://www.figma.com) is for laying out full UI screens: frames at a phone and desktop size, auto-layout for lists and buttons, components for reusable buttons and panels, then exporting each image element as PNG for Roblox. The free Starter plan gives a small number of team files (reported as 3) plus unlimited personal drafts (verify on Figma's pricing page). Community plugins on the DevForum import Figma frames into Studio as native UI (for example Figblox, RoImport, UILint; see the DevForum thread list at https://devforum.roblox.com/t/best-ways-to-transform-figma-projects-into-roblox-ui/1500253). Treat any plugin as untrusted code and read its permissions. Design at a Roblox-sized frame (e.g. 1280×720 plus a 390×844 phone frame), use **Scale-based** layout in Studio afterwards (03 covers UI layout), and export elements at 2×.

**Best videos (Inkscape/Figma/UI):**
- [Inkscape Tutorial: Complete Starter Guide for New Users](https://www.youtube.com/watch?v=fzk-suGcqrc) — Logos By Nick · 48:20. A complete overview of the application for beginners.
- [Inkscape Beginner Tutorial: Drawing Simple Shapes](https://www.youtube.com/watch?v=HeRAFSX2vaM) — Logos By Nick · 23:06. Iconic depictions built only from simple shapes: the right method for consistent game icons.
- [How To Design & Prepare App Icons in Inkscape](https://www.youtube.com/watch?v=r2Kv61cd2P4) — Logos By Nick · 18:36. Designing and exporting icons at required sizes; translate the iOS/Android sizes to Roblox's 512×512.
- [The Greatest Cartoony UI Tutorial on Roblox (w/ Figma)](https://www.youtube.com/watch?v=z16zs2v-FNI) — Kek · 41:54, and [The Greatest Stud UI Tutorial on Roblox (w/ Figma)](https://www.youtube.com/watch?v=gnIKtS3nUqo) — Kek · 1:01:51. Step-by-step front-page-style Roblox UI designed in Figma, in two popular styles. A related DevForum post by the same creator describes a free importing plugin ("Kekui") used to bring Figma UI into Studio.
- [How to create Roblox Guis using Figma!](https://www.youtube.com/watch?v=_UfFmap5cow) — MonzterDEV · 22:08. Designing GUIs in Figma and moving them into Studio (158k views).
- [Should I Use Figma For Roblox UI Design?](https://www.youtube.com/watch?v=YNCTZwIkpGg) — gfxcomet · 8:30. Pros and cons of Figma versus building directly in Studio.
- [Figma Tutorial for Beginners (13-min crash course!)](https://www.youtube.com/watch?v=jQ1sfKIl50E) — Flux Academy · 13:22. Generic Figma basics (frames, auto-layout, components) if the Roblox-specific videos move too fast.

---

## 7. Audio: SFX and instrumental music

House rules (from the owner's preferences, also in 05 §8.5): **instrumental music only** (no vocals, lyrics, choir, humming, "ooh/aah" pads, vocal chops or vocoder leads), **seamless loops**, **non-vocal SFX** (no grunts, shouts or voice lines unless the owner asks), original or properly licensed sources.

### 7.1 Roblox audio upload facts (verified)

From `cd:audio/assets.md`: single track in `.mp3`, `.ogg`, `.wav` or `.flac`; **< 20 MB** and **< 7 minutes**; sample rate **≤ 48 kHz**; channels mono, stereo 2.0, 3.0 or 5.1; you must hold the rights. ID-verified accounts can import **2,000** audio assets per 30 days, unverified **100**. Upload through the Asset Manager, Creator Dashboard or Open Cloud (`POST https://apis.roblox.com/assets/v1/assets`, `assetType: "Audio"`). Studio transcodes on import and rejects files with broken headers from old tools. Uploads are auto-classified as **sound effect** or **song**; only songs that pass moderation/copyright checks and meet duration and play thresholds can appear on the game's detail page. Audio is private to its owner: upload under the group that owns the game (05 §8.6).

Format choice: **WAV** (16-bit or 24-bit PCM) or **FLAC** for masters and for anything that loops; **OGG Vorbis** (quality 6+) when a long track would exceed 20 MB; avoid MP3 for loops, because encoder padding adds silence at the start and end, which causes a gap at the loop point. 44.1 or 48 kHz both work; don't export 96 kHz (rejected).

### 7.2 Audacity (free): the SFX workbench

**What for:** trimming, fading, cleaning and normalizing SFX and recordings; cutting music loops; batch-converting formats. **Cost:** free (GPL). **Version note:** Audacity 4.0 shipped on 2026-09-03 with a new Qt6 interface, a new `.aup4` project format (it opens `.aup3`) and a reworked clip model (https://phoronix.com/news/Audacity-4.0-Released); 4.0.2 followed on 2026-11-02. The local manual (`.sources/audacity_audacity-support/`) documents 3.7, so effect names below are from 3.7; in 4.x look for the same effect names under the Effect menu or use the search.

**Core SFX workflow** (each step cites the 3.7 manual):
1. **Import** the raw file (*File ▸ Import ▸ Audio*, or drag in). Record foley at 48 kHz, 24-bit if possible.
2. **Clean** a recording: select a noise-only stretch ▸ *Effect ▸ Noise Removal and Repair ▸ Noise Reduction ▸ Get Noise Profile*, then select all and apply gently (6–12 dB) (`repairing-audio/noise-reduction-removal.md`). High-pass (*Filter Curve EQ* or *High-Pass Filter*) at 80–120 Hz removes rumble from small sounds.
3. **Trim:** select the useful part and *Trim Audio* (`Ctrl+T`), or delete around it; press **`Z`** (*At Zero Crossings*) so selection edges sit on zero crossings and don't click (`basics/keyboard-shortcuts.md`). The sound must start at its first transient: leading silence feels like input lag in game.
4. **Fade:** *Effect ▸ Fading ▸ Fade Out* on the last 20–200 ms of the tail (longer for ambiences); a 2–5 ms *Fade In* removes a click without dulling the attack. *Studio Fade Out* gives a more musical fade; the Envelope tool allows custom curves (`basics/keyboard-shortcuts.md` lines on Fade In/Out).
5. **Dynamics:** *Effect ▸ Volume and Compression ▸ Compressor* for sounds that must cut through on phone speakers (try a factory preset first), and *Limiter* as a final safety (`audio-editing/reducing-dynamic-range-compressor-limiter.md`).
6. **Level:** *Normalize* (peak) to **−1.0 dBFS** for one-shot SFX; *Loudness Normalization* (LUFS) for music and ambiences so tracks sit at the same perceived level (`audio-editing/loudness-normalization.md`: Normalize is peak-based; Loudness Normalization targets perceived loudness and is best as the final step). Suggested house targets: music −16 to −18 LUFS integrated, ambience loops −22 to −26 LUFS, then fine-tune with `Volume` in Studio. Roblox does not publish a LUFS spec; consistency matters more than the exact number.
7. **Channels:** mix to **mono** (*Tracks ▸ Mix ▸ Mix Stereo Down to Mono*) for anything played from a 3D emitter (positional audio is mono anyway, and mono halves the file); keep stereo for music, UI and 2D ambience.
8. **Export:** *File ▸ Export Audio*, WAV 16-bit (or FLAC), 44.1/48 kHz; for many files use *Export Multiple* split by labels (`Ctrl+B` adds a label at the selection) so one recording session becomes `footstep_grass_01.wav … _06.wav`.

**Variation:** make 3–6 variants of frequent sounds (footsteps, hits, coins) instead of one, and randomize pitch ±5% in Roblox (05 covers playback). In Audacity, *Change Pitch* by ±1–2 semitones and *Change Tempo* are quick ways to derive variants.

**Batch / scripted alternative for the bot** (ffmpeg, reproducible):

```bash
# Peak-safe loudness normalisation and trim of leading silence, mono, 48 kHz, 16-bit WAV
ffmpeg -i raw/coin.wav -af "silenceremove=start_periods=1:start_threshold=-50dB,\
loudnorm=I=-16:TP=-1.5:LRA=11,afade=t=out:st=0.45:d=0.15" -ac 1 -ar 48000 -c:a pcm_s16le out/coin.wav
# Music master to OGG (quality 6) without changing length
ffmpeg -i out/theme_loop.wav -c:a libvorbis -q:a 6 out/theme_loop.ogg
```

**Common mistakes:** clipping (red in the meters) from boosting after normalizing; leading silence; reverb baked into short UI sounds (muddy when spammed); stereo 3D sounds; 30 near-identical SFX at wildly different loudness; exporting loops as MP3.

**Best videos (Audacity and SFX):**
- [How To Make Sound Effects For Games](https://www.youtube.com/watch?v=Kux_LvRl57U) — Jonas Tyroller · 18:54. A beginner sound-design tutorial covering recording through editing in Audacity (per the description), from an indie game developer. The best single starting point for making original SFX.
- [How to Edit in Audacity | Essential Controls](https://www.youtube.com/watch?v=GHe_Og-yEow) — Mike Russell · 5:19. Selection, time-shift, envelope and zoom tools. Old (3.x-era UI) but the controls carry over.
- [10 Powerful Tips Every Audacity User Should Know](https://www.youtube.com/watch?v=ox0NSwdOiyA) — Mike Russell · 8:53. Productivity tricks; skim for the editing ones (several are voice-focused).
- [How to use Audacity for Sound Design](https://www.youtube.com/watch?v=ijj0DzS0HWA) — Akash Thakkar · 5:21. A game sound designer using Audacity's effects (pitch, reverse, layering) creatively rather than for cleanup.
- [Create a Seamless Audio Loop in Audacity](https://www.youtube.com/watch?v=DlAqCK8cKh8) — Musician Startup · 5:42. Looping a track or selection in Audacity; pair with §7.5.
- [How To Foley Footsteps (for games and other media)](https://www.youtube.com/watch?v=yjhdPQmX62A) — Aturax Audio · 5:39. A simplified footstep foley process, with free footstep SFX linked.
- [So You Wanna Make Games?? | Episode 8: Sound Design](https://www.youtube.com/watch?v=KcorIwJscFA) — Riot Games · 14:32. Not a tool tutorial: what makes a game sound communicate clearly (readability, priority, feedback). Useful for deciding which sounds matter.

### 7.3 sfxr, jsfxr, bfxr, jfxr and ChipTone (free): generated game SFX

**What for:** instant retro/arcade SFX (coin, jump, laser, hit, explosion, power-up, UI blip) with no recording. **Tools:** jsfxr (https://sfxr.me, browser), bfxr (https://www.bfxr.net, browser/desktop), jfxr (https://jfxr.frozenfractal.com; its author states sounds you make are yours to use, including commercially, https://github.com/ttencate/jfxr), **ChipTone** (https://sfbgames.itch.io/chiptone, browser/desktop; the developer states all sounds made with it are **CC0**). jsfxr's own site does not clearly state a licence for generated sounds; prefer ChipTone or jfxr when the licence must be unambiguous.

Workflow:
1. Pick a category preset (Pickup/Coin, Laser/Shoot, Explosion, Powerup, Hit/Hurt, Jump, Blip/Select); press it several times or *Mutate* until one fits.
2. Shape: shorten the envelope (most game SFX are 50–400 ms), reduce harsh square waves (sine/triangle sounds softer), lower the volume.
3. Export **WAV** (44.1 kHz, 16-bit).
4. Polish in Audacity: trim, 2 ms fade-in, normalize to −1 dBFS, optional low-pass at 6–10 kHz to take the edge off for a modern stylized game, a short light reverb only for big moments.
5. Layer for modern games: generated "sparkle" + a soft recorded click/thump makes a coin that doesn't sound 8-bit. Save the generator's parameter string or preset file next to the WAV so it can be regenerated.

Fit check: pure chiptune SFX suit pixel/retro/obby/arcade games; in a cartoony 3D simulator, use them only as layers.

**Best videos:**
- [ChipTone -- A Beautiful Free Sound Effects Tool](https://www.youtube.com/watch?v=v51fDrZXh_I) — Gamefromscratch · 9:18. A tour of ChipTone, which descends from bfxr/sfxr, covering its sound designer.
- [Random SFX Maker in 2022 - jfxr](https://www.youtube.com/watch?v=pBntj3cb_8Q) — qubodup · 8:05. jfxr as the modern browser successor to sfxr/bfxr/as3sfxr, with notes on when a real recording is better.
- [Jsfxr Pro retro sound fx feature review](https://www.youtube.com/watch?v=F33rEmasC44) — mccormix (the jsfxr maintainer) · 3:56. Features of the pro.sfxr.me version.
- [Designing Retro Game Sounds (Bfxr)](https://www.youtube.com/watch?v=NDhSfn3ra90) — Michael Games · 27:42. Making a set of retro SFX in Bfxr and adding them to a game: a realistic full session.

### 7.4 Music: LMMS, BandLab, Reaper, FL Studio

| DAW | Cost (2026) | Best for | Notes |
|---|---|---|---|
| **LMMS** (https://lmms.io) | Free, open source, desktop | Beginner electronic/chiptune/orchestral-ish loops with built-in synths and SF2 soundfonts | Stable 1.2.2; 1.3 is in alpha (projects saved in 1.3 can't open in 1.2) |
| **BandLab** (https://www.bandlab.com) | Free, browser and mobile | Quick loops anywhere, huge free loop library | Exports mixdown/tracks as WAV (16-bit) per BandLab help; read the licence of BandLab Sounds loops (royalty-free for use in your music, not for redistribution as loops) |
| **Reaper** (https://www.reaper.fm) | $60 discounted licence (individuals/businesses under $20k/yr revenue), $225 commercial; 60-day full evaluation | Editing, sound design, rendering loops precisely; scripting | Roblox has an official Reaper page: `cd:art/reaper.md` (fades, ReaComp compression, EQ) |
| **FL Studio** (https://www.image-line.com) | Paid tiers, lifetime free updates | Fast pattern/piano-roll composing; most game-music YouTube uses it | Fruity Edition lacks audio recording; fine for MIDI composing |
| Bosca Ceoil (free) | Free | Very simple chiptune loops | Good for jam-speed retro music |

**Composing an instrumental Roblox loop (any DAW):**
1. **Decide function and length:** lobby/menu (calm, 60–90 s loop), exploration (mid tempo, 90–120 s), combat/round (driving, 60–90 s, plus an intensity stem), victory/defeat stingers (2–6 s, no loop). Longer loops reduce fatigue; 05 §8.5 covers rotation and adaptive stems.
2. **Set tempo and key first**, 4/4 at a round tempo (e.g. 100 or 120 BPM), and work in whole bars. Length in seconds = bars × beats per bar × 60 / BPM (32 bars at 120 BPM = 64 s).
3. **Instrumentation without voices:** piano, marimba/mallets, plucked strings, acoustic/electric guitar, bass, synth leads and arps, brass/woodwind patches, drums and percussion, string pads. Avoid choir, "vox"/"aah" pads and vocal sample packs (check pad presets: many "atmos" presets contain voice samples).
4. **Structure:** A (theme) → B (variation/contrast) → A′, with the final bar leading back to the first chord (e.g. ending on the dominant, or the same chord as bar 1) so the loop resolves into itself.
5. **Mix:** leave headroom (peaks ≈ −6 dBFS before mastering), high-pass non-bass instruments, keep the melody out of the 2–4 kHz zone where SFX live, or keep melodies sparse so gameplay sounds read on top. Master with a gentle limiter to about −16 LUFS, −1 dBTP.
6. **Render the loop** (next section), export WAV, upload, set `Looping` (and `LoopRegion` if there is an intro) per 05 §8.5.

### 7.5 Making a seamless music loop (step by step)

The two failure modes are a **click/gap** at the seam (bad cut point, MP3 padding) and a **reverb/decay "hole"** (the tail of the last notes is cut off at the end and missing at the start).

1. **Compose on the grid:** the loop is exactly N bars. Notes may ring past the end; that is the "tail".
2. **Render loop + tail:** render from bar 1 to the loop end **plus 2–4 extra bars** with the loop's beginning repeated after the end (or just the ringing tail), so reverb and decays are captured naturally.
3. **Fold the tail:** cut the audio at the exact loop end; take everything after it (the tail) and **mix it onto the start** of the file (overlay, not insert). Now the start contains the end's decay, as it will when the loop repeats. Reaper does this with items on two tracks (see the REAPER Blog video); in Audacity copy the tail, then at time 0 use *Edit ▸ Paste* on a new track and mix down (*Tracks ▸ Mix and Render*).
4. **Cut at exact sample counts:** loop length in samples = seconds × sample rate (64 s × 48,000 = 3,072,000 samples). Set the selection by typing start and end into the selection toolbar in samples. If you must nudge, cut both ends at zero crossings (`Z`), or apply a 5–10 ms crossfade at the seam (`audio-editing/making-crossfades.md`).
5. **Intro/outro:** if the track has an intro, keep it in the file and use `AudioPlayer.LoopRegion` to loop only the body (05 §8.5). Don't fade out the end of a loop file.
6. **Export lossless** (WAV/FLAC), or OGG if size forces it; never MP3 for a loop.
7. **Test the seam:** in the DAW loop the junction (last 3 s → first 3 s) a dozen times; in Studio set `TimePosition` to the loop end minus 3 s and listen. Listen on headphones and a phone speaker.

**Best videos (music and looping):**
- [5 Ways to Make Perfect Loops for Video Game Music](https://www.youtube.com/watch?v=bIlkXq3r6_w) — Adam Morton · 16:14. Five techniques for loops that players don't notice, from a game composer.
- [You're Looping Your Game Music Wrong](https://www.youtube.com/watch?v=CHCJG_A_cvQ) — Steven Melin · 11:57. The description says most composers export straight from the DAW or mishandle the reverb tail at the end; the video addresses the tail problem (step 3 above). The same tail-wrap fix is described in written form at https://www.moddb.com/tutorials/making-a-loop-loop-better.
- [Making Seamless Music Loops](https://www.youtube.com/watch?v=ahsbmzAqXUM) — The REAPER Blog · 7:29. A Reaper technique using three sections of the music to build a seamless loop for games and interactive media (per the description).
- [Seamless Loops for Games & Mediated Environments](https://www.youtube.com/watch?v=KOiHmM-cOBk) — GQ Audio · 36:08. A longer discussion of methods for continuous loops in games and installations.
- [A Guide to Making Video Game Music](https://www.youtube.com/watch?v=dMkTdYmOgiQ) — Zectro · 10:36. A popular, approachable overview of writing game music (1M views).
- [How to make VIDEO GAME MUSIC for free (beginners' guide)](https://www.youtube.com/watch?v=l61EBjVd9tw) — Composer Code (Matt Kenyon) · 23:33. Free tools and composition basics, with free learning resources linked.
- [How To Use LMMS - Tutorial For Beginners (FREE DAW)](https://www.youtube.com/watch?v=3qfa9hGJzoY) — Transverse Audio · 15:52. The standard LMMS basics tutorial (1.4M views); [How to Make Better Melodies in LMMS](https://www.youtube.com/watch?v=0sRvkaxh8EU) (feezo, 27:52) turns a simple melody into a more interesting one.
- [How To Use BandLab Studio](https://www.youtube.com/watch?v=NmUaIoydldg) — BandLab (official) · 16:06. Navigating the free browser DAW; [BandLab Bootcamp For Beginners](https://www.youtube.com/watch?v=TAHn_0Vy-Zg) (The Songwriting Studio, 24:34) goes deeper. Both include vocal recording, which the bot should skip.
- [Reaper for Game Audio | Part 1 - Intro and Setup](https://www.youtube.com/watch?v=uNJSKNhbsgA) — Akash Thakkar · 12:36. Setting Reaper up for game sound work; [Why Reaper For Game Audio](https://www.youtube.com/watch?v=gMMuTi4U9mE) (David Dumais, 9:59) explains why game audio teams favour it.
- [Beginner's Guide to Game Audio from a Sound Design Expert!](https://www.youtube.com/watch?v=TjRZ3897xI4) — GameDev.tv · 8:32. A conversation with Ovani Sound about choosing music and SFX for a game: good for planning an audio list.

### 7.6 Licensing quick reference

| Source | OK for a Roblox game? | What to do |
|---|---|---|
| Your own recordings, compositions, generated SFX from ChipTone (CC0) or jfxr | Yes | Keep project files as proof of authorship |
| CC0 / public domain (e.g. Freesound filtered to CC0, Kenney assets, Poly Haven HDRIs/textures) | Yes | Note the source in `CREDITS.md` |
| CC-BY | Yes, with credit | Credit in the game description or an in-game credits screen, plus `CREDITS.md` |
| CC-BY-NC / "personal use only" / "free for non-commercial" | **No** (games with monetization are commercial) | Skip |
| CC-BY-ND | Usually no (editing = derivative) | Skip |
| Roblox Creator Store audio (Roblox and licensed partners) | Yes, on Roblox only | Use the asset ID; don't download and re-upload |
| Loops from BandLab Sounds or DAW sample packs | Usually yes inside your own composition; never redistribute raw loops | Read the pack licence |
| AI-generated music or art | Depends on the service's terms; output may be unprotectable or restricted | Prefer own work; if used, record the service and terms |
| Commercial songs, game rips, "no copyright" YouTube uploads | **No** | Never upload |

Same rules for images: original art only, no traced characters, no other games' logos, no fonts without a licence that allows embedding in images (most Google Fonts are OFL and fine).

---

## 8. End-to-end checklists

**3D prop (Blender → Studio)**
- [ ] Built at stud scale, Units = None; transforms applied; origin at pivot; named
- [ ] Tris within budget (props 50–1,500; hero ≤ 5k; hard limit 20k); Statistics overlay checked
- [ ] One material; one UV map in 0–1; normals outward; no loose/duplicate verts
- [ ] Textures: Color (+ Normal OpenGL, Roughness, Metalness) at a size matching world size; non-colour maps marked Non-Color; images saved, not just painted
- [ ] Exported GLB (static) or FBX with the §1.10 settings; 1×1×1 test cube passes
- [ ] Imported with Creator = game's group; anchored; collision fidelity chosen (09 §7); `ResampleMode` set for pixel textures
- [ ] Source `.blend` + export script committed

**2D asset**
- [ ] Correct size (icon 512², thumbnail 1920×1080, badge/pass/product 512² circle-safe, UI ≤ 2×)
- [ ] RGBA PNG, no halos, margins in sheets, 9-slice rect recorded
- [ ] Viewed at 150 px (icons) and on a phone (thumbnails); chapter 16 checklist passed
- [ ] Original content, accurate to the game, fonts licensed

**Audio asset**
- [ ] Non-vocal; instrumental music; original or licensed (logged in `CREDITS.md`)
- [ ] SFX trimmed to the transient, faded, peak −1 dBFS, mono if 3D; 3–6 variants for frequent sounds
- [ ] Music loop on whole bars, tail folded, cut at exact samples, seam tested; WAV/FLAC/OGG, ≤ 48 kHz, < 20 MB, < 7 min
- [ ] Uploaded under the game's group; IDs recorded in the sound registry module (05)

---

## 9. When to use which tool (decision notes for the bot)

- **Can Studio do it with Parts or Luau?** Blocky buildings, voxel-ish props, simple UI shapes (Frames + UICorner + UIStroke + UIGradient): do it in Studio/code first. It is cheaper, consistent and needs no uploads (09 §8–9, 03).
- **Need a real silhouette?** Blender low-poly with a palette texture. Script it with bpy if it is one of many variants.
- **Need surface detail?** Bevel + weighted normals first; bake normals only for hero assets; Substance only if the owner has it and the art style is PBR.
- **Pixel/blocky style?** Blockbench (3D) and Aseprite/LibreSprite (2D), with `ResampleMode = Pixelated` everywhere and one pixel density.
- **Promotional art?** Studio pose → Blender render → Photopea paint-over. Make concepts quickly and let personalization test them.
- **SFX?** Record or generate, then Audacity polish. **Music?** LMMS/BandLab (free) or Reaper/FL (owner's choice), instrumental only, loop-rendered per §7.5.
- **Unsure whether a tutorial is current?** Check the version in its title/age. Blender 2.8–2.9 videos are fine for modelling concepts but menus have moved; Audacity 3.x videos predate the 4.0 interface; FBX scale advice older than 2024 is often wrong for Roblox's current Importer.

---

## Sources

- Blender manual RST (CC-BY-SA 4.0), `reference/tools/blender-manual/`: `modeling/modifiers/generate/{mirror,bevel,solidify,array,array_legacy,decimate}.rst`, `modeling/modifiers/normals/{weighted_normal,smooth_by_angle}.rst`, `modeling/meshes/editing/uv.rst`, `render/cycles/baking.rst`, `files/import_export/{fbx,fbx_legacy}.rst`, `addons/{scene_gltf2,node_wrangler}.rst`, `addons/rigify/`, `scene_layout/object/editing/{apply,join,duplicate_linked,parent}.rst`, `advanced/command_line/{arguments,extension_arguments}.rst`. Online: https://docs.blender.org/manual/en/latest/
- Roblox Creator Docs (`reference/creator-docs/content/en-us/`): `art/blender.md`, `art/reaper.md`, `art/modeling/{texture-specifications,assign-textures,specifications,project-files,roblox-blender-plugin}.md`, `studio/importer.md`, `avatar/emotes/{import,export,specifications}.md`, `avatar/character-bodies/export.md`, `audio/assets.md`, `production/publishing/{experience-icons,thumbnails,badges}.md`, `production/monetization/developer-products.md`, `cloud/guides/usage-assets.md`, `ui/9-slice.md`, `reference/engine/classes/SurfaceAppearance.yaml` (ResampleMode). Live: https://create.roblox.com/docs/
- Blockbench docs (local copy `.sources/JannisX11_blockbench.net/content/`): `guides/export-formats.md`, `guides/blockbench-overview-tips.md`, `blockbench/formats.md`; 5.0 release notes https://github.com/jannisx11/blockbench/releases/tag/v5.0.0
- Audacity support manual (local copy `.sources/audacity_audacity-support/`): `audio-editing/loudness-normalization.md`, `audio-editing/reducing-dynamic-range-compressor-limiter.md`, `audio-editing/making-crossfades.md`, `music/working-with-audio-loops/making-audio-loops.md`, `repairing-audio/noise-reduction-removal.md`, `basics/keyboard-shortcuts.md`, `basics/saving-and-exporting-projects.md`. Audacity 4.0 release: https://phoronix.com/news/Audacity-4.0-Released
- Version and pricing checks (web, 2026): Blender 5.1 https://80.lv/articles/blender-5-1-now-available ; Blender Guru donut v5 https://www.blenderguru.com/posts/blender-donut-v5-tutorial ; GIMP 3.2 https://gimp.org/news/2026/03/14/gimp-3-2-released ; Krita 5.3/6.0 https://mail.kde.org/pipermail/kimageshop/2026-March/017385.html ; Aseprite https://steambase.io/games/aseprite/price ; Substance 3D Painter on Steam https://design-offset.com/20260318-adobe-substance-3d-on-steam/ ; LMMS https://en.wikipedia.org/wiki/LMMS ; BandLab formats https://help.bandlab.com/hc/en-us/articles/360036010533-Supported-Audio-Formats- ; Reaper licence https://www.audeobox.com/learn/reaper/beat-making-on-a-budget/ ; ChipTone licence https://sfbgames.itch.io/chiptone ; jfxr https://github.com/ttencate/jfxr ; Figma Starter plan https://dupple.com/learn/is-figma-free
- Community: Blender Animations plugin thread https://devforum.roblox.com/t/blender-rig-exporteranimation-importer/34729 ; pixel-art texture blur https://devforum.roblox.com/t/mesh-texture-pixel-art/2303754/10 ; Figma→Studio tools https://devforum.roblox.com/t/best-ways-to-transform-figma-projects-into-roblox-ui/1500253 ; palette workflow notes https://gist.github.com/mschneider247/c0cb850a23303ea9764675def782d3f6 ; loop tail technique https://www.moddb.com/tutorials/making-a-loop-loop-better
- Video catalog: `reference/video-library/catalog.json` (metadata only; summaries above are from titles, description snippets and web sources, not transcripts).
