---
title: "Sound"
url: /docs/en-us/sound
last_updated: 2026-11-05T19:16:05Z
description: "An overview of legacy Sound objects and effects."
---

# Sound

> **Warning:** There is a newer set of [audio objects](/docs/en-us/audio/objects.md) and [effects](/docs/en-us/audio/effects.md) that offer more control and address robust use cases. For more information, see [Audio](/docs/en-us/audio.md).

Sound effects and music enhance your games and make them more immersive. You can import your own [audio assets](/docs/en-us/audio/assets.md) or search for free-to-use audio in the [Creator Store](/docs/en-us/production/creator-store.md), play audio through `Class.Sound` or objects, and enhance audio playback through [dynamic effects](#dynamic-effects).

## Sound objects

A [sound object](/docs/en-us/sound/objects.md) emits audio within a game. Roblox assigns each [audio asset](/docs/en-us/audio/assets.md) a unique ID that you can assign to `Class.Sound` objects to play a specific sound effect or music track. You can either set this audio to play automatically at runtime, or trigger it to play from scripts.

The location of where you place a `Class.Sound` object in the [Explorer](/docs/en-us/studio/explorer.md) hierarchy affects how users hear audio. If you want users to only hear audio near a specific position, you must parent the `Class.Sound` object to a 3D object or `Class.Attachment` to behave as positional audio. If you want users to hear audio regardless of their position, you must insert the `Class.Sound` object directly into `Class.Workspace` or `Class.SoundService` to behave as background audio.

## Sound groups

A [sound group](/docs/en-us/sound/groups.md) acts as an audio mixer for multiple audio objects, such as `Class.Sound` objects or additional `Class.SoundGroup|SoundGroups`, allowing you to control the volume and dynamic effects properties of multiple audio signals at once.

## Dynamic effects

[Dynamic effects](/docs/en-us/sound/dynamic-effects.md) modify or enhance the audio of individual `Class.Sound` objects or an entire `Class.SoundGroup`. You can apply these effects to make audio more immersive within the game, such as using `Class.EqualizerSoundEffect` to make rain sound muffled, `Class.CompressorSoundEffect` to control a sound's maximum volume, or `Class.ReverbSoundEffect` to add more realistic reflections of sound in interior spaces.
</document>

<document url="/docs/en-us/sound/objects.md" title="Sound objects">
