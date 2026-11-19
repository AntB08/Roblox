# It Talks Back (prototype)

A co-op Roblox horror game: find 3 fuses, power the generator and escape a dark house while
**The Tenant** hunts you. It talks to you, and it listens.

- **It speaks from where it stands.** 3D text-to-speech from its head, plus subtitles when you're close.
- **It hears you.** Server-measured footsteps (running is loud, crouching is silent), fuses, closet doors and rescues.
- **It lies.** Fuse "hints" are true half the time. When it lies, it waits for you in that room.
- **Voice chat only.** Text chat is hidden. Talk with your mic, and it hears you too: talking makes
  noise, saying a room name sends it there, and when it's close it answers you out loud.
- **You can lie back.** Callout buttons ("I'm in the Basement!") tell teammates where you are, and the
  monster hears them too. Fake one to lure it away. Lie twice and it stops listening to you.
- **Hiding works, unless it watched you get in.** Break line of sight first.
- **Getting caught isn't death.** You go to the basement cage, and a teammate can break the lock (loudly).
- Optional fresh lines from Roblox's built-in `TextGenerator` (filtered). Canned lines always back it up.

Design: `docs/DESIGN.md`. How it's built: `docs/SYSTEMS.md`. Tuning: `src/shared/Config/HorrorConfig.luau`.

## Play it in Studio
1. Install the tools: `rokit install` (Rojo 7.7.1 etc.).
2. Build a place file: `rojo build default.project.json -o build/game.rbxl` and open it in Studio,
   **or** run `rojo serve` and connect from the Rojo plugin in an empty baseplate.
3. Data saving: either enable *Game Settings → Security → Studio Access to API Services*, or set the
   Workspace attribute `UseMockData = true` (in-memory store).
4. Press **Play**. The round starts after the 15 s lobby countdown (1 player is enough).
   For co-op, use *Test → Clients and Servers* with 2–3 players.
5. Try the phone emulator first (most players are on mobile).

## Controls
| Action | Keyboard | Gamepad | Touch |
|---|---|---|---|
| Run (hold) | Shift | L3 | RUN button |
| Crouch | C | B | CROUCH |
| Flashlight | F | Y | LIGHT |
| Callouts | 1–4 | D-pad | "Call out" menu |
| Hide / take / insert / rescue | E (prompt) | X | tap the prompt |

## Things to know
- **Voice:** `AudioTextToSpeech` needs a published experience, and it may stay silent in some Studio
  setups. Subtitles always show. If you hear nothing in a live server, check the Output for
  `[VoiceService]` / `[VoiceController]` warnings.
- **GPT (OpenAI) lines:** the monster's lines are written by GPT and spoken out loud by Roblox's
  text-to-speech. Setup: Creator Hub → your experience → **Secrets** → create `openai_api_key`
  (domain `api.openai.com`) with your OpenAI key. In Studio: *File → Experience Settings → Security*,
  turn on **Allow HTTP Requests**, and add the same key under **Local Secrets** for testing. Pick the
  model in `HorrorConfig.Voice.OpenAI.Model`. Every line is filtered by Roblox before players hear it.
  Never paste the key into a script.
- **Roblox AI fallback:** if GPT fails, it tries Roblox's `TextGenerator`, which usually only works in a published game. If it fails 3 times, the server
  quietly falls back to `src/server/Config/Lines.luau`. The kill switch is the Creator Hub config
  `monster_ai_dialogue = false`.
- **Audio:** footsteps use a built-in engine sound. Add your own instrumental music
  (`Assets.Music.Ambient` / `Chase`) and record it in `assets/ASSETS.md`.
- **Map and HUD** are generated: edit `tools/build_map.py` / `tools/build_hud.py` and re-run them, or
  stop using the scripts and edit in Studio (then save the result back to the files).
- **Voice setup:** turn on voice chat for the experience (*Game Settings → Communication*). The place
  file already sets `VoiceChatService.UseAudioApi = Enabled`. Speech-to-text needs a published
  game and players with voice chat (ID-verified 13+). Players without voice can still play using the
  callout buttons.

## Not done yet
It hasn't been playtested (it was built without Studio). It has grey-box art only (no monster
mesh or animations), no music, and no spectator camera. Tuning numbers are first guesses.
