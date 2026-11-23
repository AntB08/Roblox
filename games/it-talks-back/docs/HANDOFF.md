# Handoff: It Talks Back

**For a Claude instance continuing this project on the owner's PC.** Everything below was built
in a cloud session that had **no Roblox Studio and no access to the owner's PC**. As a result, nothing
has ever been playtested in Studio. Read this file first, then `CLAUDE.md` (in this folder) and
`~/Roblox/CLAUDE.md` (the knowledge base rules).

Branch: `claude/vigilant-wozniak-hfxj0v` in `antb08/roblox`. Game folder: `games/it-talks-back/`.

---

## 1. What the game is
A co-op Roblox horror game for **13+, voice-chat only**. Players spend **nights** in a dark house finishing a
task checklist (fuses → generator, haunted radio, candles, key), then escape through the north gate.
**The Tenant** hunts them. It *talks*: GPT writes its lines and Roblox text-to-speech speaks them through a
horror effects chain. It *listens*: players' voice chat goes through speech-to-text, so talking is noise,
saying a room name lures it there, and it answers nearby players out loud.
Full design: `docs/DESIGN.md`. Systems map: `docs/SYSTEMS.md`. Look: `docs/STYLE.md`.

## 2. The owner's decisions and preferences (follow these)
- **Fun first.** The owner rejected a "GPT dialogue demo" in favor of a real game loop.
- **Voice chat only, 13+.** Text chat is hidden, and players without voice are kicked (`VoiceGateService`, off in Studio).
- **The monster's voice must sound unique and scary, not like plain TTS.** It uses a 2-layer TTS, an effects chain and random
  pitch warp/glitches. The owner may record their own lines later (`src/shared/Config/VoiceLines.luau`).
- **GPT (OpenAI) writes the lines.** The key is in the experience **Secrets store** as `openai_api_key` (never in code).
  Roblox `TextGenerator` is the fallback, then canned lines. All AI text is filtered with `TextService`.
- **Objectives like other popular night-based horror games, but never copied:** nights, a checklist, escalation.
- **Every replay should feel different:** monster personalities, night twists, random spawn, surprise events (`VarietyService`).
- **Animations should be "fluent like Doors"**, and the monster should look **realistic and high-detail**, built
  with real Blender techniques rather than primitive shapes.
- **Originality matters.** The owner shared two reference images that belong to other artists (a concept painting
  and a 3D model). Use them for mood only and never copy them. The owner also said an earlier version looked too
  much like **Figure from Doors** (a head that is mostly a giant horizontal mouth). The current design deliberately avoids
  that: the face **splits vertically** into two jaw halves with teeth interlocking across the gap, and it has **four milky eyes**.
- The owner doesn't want to use Rojo. They open `.rbxl` place files in Studio. A Claude on the PC should use the
  **Roblox Studio MCP server** to work in Studio directly, if it's set up.
- Communication: the owner writes short, casual messages. Show visuals (renders or video) before calling something done.

## 3. Current state
### Game code (Luau, Rojo project, all type-checked and building, NOT playtested)
- Server: `src/server/Services/*`. Rounds, nights and tasks, monster AI (`MonsterService`: patrol, investigate,
  chase, search, pull out of closets, grab), noise, hiding, cage and rescue, callouts, speech, voice, variety director, voice gate.
- Client: `src/client/Controllers/*`. HUD, input (touch, keyboard, gamepad), voice playback (TTS + effects + radio relay),
  monster FX, cutscenes (night intro, catch jumpscare, escape), prompts, crouch pose, speech-to-text.
- Monster rig in game: `src/server/Game/MonsterRig.luau`, a **103-joint** rig made of rounded primitive parts, animated
  procedurally by `src/client/FX/MonsterAnimator.luau` (layered poses expanded to 103 joints + springs).
  The game can also wear generated meshes (`ServerStorage.TenantMeshes`, see `assets/meshes/README.md`), but that
  mesh set is the **older stylized design, now superseded** by the Blender model below.
- Place file: `rojo build default.project.json -o build/ItTalksBack.rbxl` (the owner opens this in Studio).

### The realistic monster (latest, approved direction)
- `tools/blender/build_tenant.py` builds it in Blender 4.0 from code:
  - **Body:** a Skin-modifier body with Subdivision Surface.
  - **Skull:** sculpted, with four eye sockets. A boolean cut splits the face vertically.
  - **Surface:** voxel remesh, then sculpt passes (ribs, spine, collarbones, belly, knuckles, wrinkles).
  - **Teeth:** fangs rooted along both split edges via raycast.
  - **Tongue and skin:** a curve tongue, and a wet subsurface skin shader.
  - **Outputs:** `TheTenant.blend` (ready-to-open scene), `tenant_hi.blend` and `tenant_joints.json` (skeleton points).
    A copy of the scene is in `assets/blender/TheTenant.blend`.
  - Run: `blender -b -P tools/blender/build_tenant.py -- <out_dir> [--samples=N] [--only=front,face] [--scene-only] [--norender]`
- About 100k triangles at source quality. **No rig and no animation yet.**

## 4. Next steps (in order)
1. **Rig + animate the Blender model** (this was in progress when the session moved):
   - Build an armature from `tenant_joints.json`. Bones: Hips, Spine1-3, Neck1-3, Head, **JawL/JawR** (the split
     halves swing outward around Z), Tongue1-4, Clavicle/UpperArm/ForeArm/Hand, 3 bones per finger plus a 2-bone thumb, Thigh/Shin/Foot/Toes.
   - Skin with automatic weights, then hand-assign the face around the split to JawL/JawR by side so it peels open.
     Teeth are rigid to their jaw half, eyes rigid to Head. Limit to 4 influences per vertex for Roblox.
   - Keyframe actions with anticipation, overlap and follow-through: **Idle, Walk (creep), Run (chase sprint),
     Listen, Speak/Roar (jaw splits, tongue lashes), Grab (wind-up, lunge, lift and shake), Look, Snuff, Dormant, Emerge**.
     These names match `Assets.Animations.Monster` in the game.
   - Render previews and show the owner.
2. **Make it game-ready:** decimate to about 15–20k triangles and bake normal, color and roughness maps (SurfaceAppearance).
   Export a skinned FBX of the rig, plus one FBX per animation.
3. **Integrate:** import the rig into Studio (as a skinned MeshPart with Bones), publish the animations, and paste the IDs
   into `src/shared/Config/Assets.luau` → `Animations.Monster`. The client already plays AnimationTracks when those IDs
   exist (`MonsterFxController`). `MonsterRig` must be changed to clone the imported rigged model (keep
   `HumanoidRootPart`, `Humanoid` + `Animator`, a `Head` part or attachment for the voice emitter and the eyes tagged `MonsterEye`)
   instead of building primitives.
4. **First real playtest in Studio:** test with 2–3 clients and the phone emulator. Log it in `docs/PLAYTEST.md`.
   Likely issues to check:
   - monster pathfinding through doors and down the basement ramp
   - prompts, closets and the cage
   - TTS loudness and the effects chain
   - speech-to-text needs a published place with voice enabled
5. **Publishing chores:**
   - Experience settings: voice chat on, HTTP requests on, the `openai_api_key` secret, and the 13+ maturity questionnaire.
   - Music: upload instrumental tracks for `Assets.Music.Ambient` and `Chase`.

## 5. Tools used in the cloud (install equivalents locally)
- Rojo 7.7.1, StyLua 2.6, Lune 0.11, luau-lsp 1.70 (type check), Blender 4.0, Python 3 with numpy, trimesh and Pillow.
- Checks used before each commit:
  - `stylua --check src tests lune`
  - the luau-lsp analyze command, as in `scripts/check.sh`
  - `rojo build default.project.json -o build/ItTalksBack.rbxl`
  - `lune run lune/scan-place build/ItTalksBack.rbxl`
- Useful scripts:
  - `lune run lune/build-animations`: export the procedural animations as KeyframeSequences.
  - `lune run lune/export-rig-spec`: rig spec to JSON.
  - `python3 tools/build_map.py` and `python3 tools/build_hud.py`: regenerate the map and HUD.
