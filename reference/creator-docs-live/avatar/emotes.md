---
title: "Emotes"
url: /docs/en-us/avatar/emotes
last_updated: 2026-11-05T19:15:48Z
description: "Emotes are full body animations that an avatar character can perform to communicate and celebrate with others in games."
---

# Emotes

**Emotes** are full body animations that an avatar character can perform to communicate and celebrate with others in a game, such as gestures, reactions, and dances. While Roblox provides a set of default emotes for each avatar on the platform, you can create and sell your own emotes on the Marketplace or within games.

> **Info:** Game developers can access and modify emotes within their games. For more information on this process, see [character emotes](/docs/en-us/characters/emotes.md).
## Components

Emotes are made up of an `Class.Animation` object with the unique `Class.Animation.AnimationId|AnimationId` property set to the asset ID of your animation sequence.

_`Animation` object in the Explorer window._

_`AnimationId` property in the Properties window._

All emotes must meet Roblox's technical [emote specifications](/docs/en-us/avatar/specifications.md), [Community Standards](https://en.help.roblox.com/hc/en-us/articles/203313410-Roblox-Community-Standards), and [Marketplace policies](/docs/en-us/marketplace/marketplace-policy.md).

## Create emotes

There are several ways you can create emotes using either Studio or a third-party animation tool. Review the following table for specific workflows and resources:

| Animation workflow | Description |
| --- | --- |
| Animation Capture | Use Studio's [Animation Capture](/docs/en-us/animation/capture.md#body) tool to convert a full body video into a keyframe sequence for your emote. |
| Manual animation with Animation Editor | Use Studio's [Animation Editor](/docs/en-us/animation/editor.md) to manually animate a character rig. For an in-depth tutorial on creating a character animation, see [Create character animations](/docs/en-us/tutorials/use-case-tutorials/animation/create-an-animation.md). |
| Third-party plug-ins | Use a third-party animation plugin, such as [Moon Animator](https://create.roblox.com/store/asset/4725618216/Moon-Animator-2), to generate your animation. |

To convert your keyframe sequence into an animation that you can upload to the Marketplace, see [Import emotes - Generate asset ID](/docs/en-us/avatar/import.md#generate-asset-id).
</document>

<document url="/docs/en-us/avatar/emotes/specifications.md" title="Emote specifications">
