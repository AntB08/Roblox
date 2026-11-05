---
title: "Effects"
url: /docs/en-us/effects
last_updated: 2026-11-05T19:15:53Z
description: "Learn how to add visual effects to your games."
---

# Effects

You can create special effects by parenting special effect objects to other objects or attachments.

## Light sources

Light sources let you attach lighting effects to objects or attachments. There are three types of light sources:

- A `Class.PointLight` emits light spherically from a single point. This object is ideal for non-directional lights like bulbs, torches, and fireballs.
- A `Class.SpotLight` emits light in the shape of a cone with a spherical base. This object is ideal for directional lights like street lamps, flashlights, and headlights.
- A `Class.SurfaceLight` emits light from the face of a BasePart. This object is ideal for lighting from TV or computer screens, billboards, and fluorescent panels.

_Point lights_

_Spotlights_

_Surface lights_

## Particle emitters

A [particle emitter](/docs/en-us/effects/particle-emitters.md) is an object that emits customizable 2D images (particles) into the world, useful for simulating special effects like fire, smoke, and sparks.

## Beams

A [beam](/docs/en-us/effects/beams.md) is an object that renders a texture between two `Class.Attachment` objects `Class.Beam.Attachment0` and `Class.Beam.Attachment1`. By setting beam properties, you can:

- Add a [texture](/docs/en-us/effects/beams.md#texture) and [color gradient](/docs/en-us/effects/beams.md#color) to create interesting visuals like waterfalls and force fields.
- Modify a beam's [transparency](/docs/en-us/effects/beams.md#transparency) so that it fades over time.
- Warp its shape by changing the [width](/docs/en-us/effects/beams.md#width) or [curve](/docs/en-us/effects/beams.md#curve) of each attachment point.

## Trails

A [trail](/docs/en-us/effects/trails.md) is an object that creates a trail between and behind two `Class.Attachment` objects as they move through space. Trails can help players visualize movement, such as a sword slashing through the air, projectiles flying to their target, or footprints walking away.

By setting trail properties, you can:

- Add a [texture](/docs/en-us/effects/trails.md#texture) to create interesting visuals.
- Set a constant or gradient [color](/docs/en-us/effects/trails.md#color).
- Modify a trail's [lifetime](/docs/en-us/effects/trails.md#lifetime).

## Highlighting

`Class.Highlight` is a visual effect which you can use to call attention to a specific object within a game, such as to provide visual feedback that the object is important and/or interactable. See [Highlighting Objects](/docs/en-us/effects/highlighting.md) for details.

![A tree mesh against a grey background.](../assets/ui/highlighting-objects/OutlineTransparency-1.jpg)_Base object_

![The same tree mesh with a white outline and a red highlight interior.](../assets/ui/highlighting-objects/Adding-Highlight.jpg)_White outline, 50% red interior_

![The same tree mesh with a yellow outline and a black highlight interior.](../assets/ui/highlighting-objects/Overview-Yellow-Outline.jpg)_Yellow outline, black interior_
</document>

<document url="/docs/en-us/effects/light-sources.md" title="Light sources">
