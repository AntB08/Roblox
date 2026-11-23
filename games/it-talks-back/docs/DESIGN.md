# Design doc: It Talks Back

**Hook:** a co-op haunted-house escape where the monster *talks*. It taunts you, reacts to what it
hears, gives fuse "hints" that may be lies, and hears your callouts, so you can lie to it too.

**One sentence:** It's hide-and-seek horror where you find 3 fuses to escape while a monster that
speaks (and listens) hunts you through a dark house.

## Audience and session
- Friend groups of 2–4 (works solo for testing). Mobile first. Rounds of about 3–7 minutes.

## Core loop (seconds)
explore → hear the monster's voice and footsteps → choose: sneak (crouch, no light) or rush (run,
light) → spotted → run, break line of sight, loop furniture, hide in a closet → grab a fuse → generator.

## Session loop (one round)
1. Lobby countdown (15 s), then everyone starts in the foyer. The monster sleeps for 12 s.
2. Find 3 fuses (random spots, at most 2 per room) and insert them at the hallway generator.
   Each insert is heard house-wide.
3. Power on: the gate opens and the monster rages (faster, sees farther). Reach the north exit.
4. Caught players go to the basement cage. Teammates hold "Break Lock" (loud) to free everyone.
5. The round ends when no one is left inside or after 7 minutes.

## Nights and tasks
Each round is a **night** with a checklist (HUD top-left). The exit gate opens only when every task is done.
| Night | Tasks | Monster speed |
|---|---|---|
| 1 | 2 fuses, find the key and unlock the gate | ×1.00 |
| 2 | 3 fuses, turn off the haunted radio, light 4 candles | ×1.04 |
| 3+ | 3 fuses, radio, candles, key | ×1.08, +3% per extra night (max ×1.25) |
- **Radio:** on in a random room, noisy every 6 s (pulls the monster there), and the monster's voice also comes out of it. Hold 2.5 s to switch it off.
- **Candles:** one per room; the monster snuffs lit candles it walks past (50%), so lighting them is a race.
- **Key:** random spot; carry it to the gate. Caught = dropped where you were caught.
Survive (1+ escape) → next night. Nobody escapes → replay the night. Best night is saved per player.

## Every night feels different (VarietyService, HorrorConfig.Variety)
Already random: fuse/key/radio spots, hints, patrol. On top of that, each night rolls:
- **Personality** (never twice in a row): Stalker (sees far, rarely talks, remembers longer), Chatty (taunts 2×, lies 70%),
  Hunter (+10% speed, forgets fast), Listener (hears 1.5×, sees 0.7×). Announced as a hint ("It's quiet tonight. Too quiet.").
- **Twist**: None, Barricades (up to 2 doorways boarded, every room stays reachable), Blackout (lamps dead), Fog, Jammed closets.
- **Spawn**: a random patrol point far from the foyer.
- **Events** every 55–95 s: power surge (lights die 8 s), knocking in an empty room (it goes to check), vanish (it goes quiet
  and reappears far from everyone).

## The talking monster (what makes it original)
| It… | Gameplay effect |
|---|---|
| speaks from where it stands (3D TTS) | you can locate it by ear: "it's in the basement" |
| reacts to noises ("Footsteps... in the Kitchen") | tells you that you were heard |
| gives hints ("There's a fuse in the Study") | 50% true; when it lies it goes to wait in that room. Watch where it walks |
| hears callouts ("I'm in the Basement!") | teammates know where you are, and so does it. Shout a fake room to lure it away. Lie twice and it holds a grudge and ignores you for 60 s |
| pulls you out of a closet if it saw you get in | hide *after* breaking line of sight |
| optionally uses Roblox TextGenerator for flavor lines | fresh taunts. Hints, catches and timing never depend on the AI |

## Player verbs
walk, run (stamina 5 s), crouch (quiet, hard to spot), flashlight (see more, be seen more), hide,
take/insert fuse, break the cage lock, call out a room.

## Tuning (src/shared/Config/HorrorConfig.luau)
Player walk 14 < monster chase 16.5 < player sprint 22 → chases are won by breaking sight, not raw
speed. Sprint footsteps are heard 34 studs away, walking 9 and crouching 0.

## Meta (not in prototype)
Coins from escapes and rescues are saved (ProfileStore) for a future cosmetic shop (flashlight
colors, lobby emotes). No pay-to-win.

## Cut list / next
Voice-chat hearing via `AudioSpeechToText` (opt-in, 13+ voice users only); more monsters or
houses; real mesh, animations and sound design; a spectator camera for caged and escaped players.

## Kill criteria
If, after 3 playtests with real friend groups, players don't want "one more round", or ignore the
voice and the callouts, rethink the hook before adding content.
