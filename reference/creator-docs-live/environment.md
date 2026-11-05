---
title: "Lighting and effects"
url: /docs/en-us/environment
last_updated: 2026-11-05T19:15:53Z
description: "Create more immersive environments through lighting, atmospheres, and special effects."
---

# Lighting and effects

The `Class.Lighting` container services let you control and customize a game's environment such as [lighting](#global-lighting), [atmosphere](#atmospheric-effects), and [clouds](#clouds-and-skies). You can also apply [post-processing effects](#post-processing-effects) to adjust how the game appears on the screen.

## Global lighting

The `Class.Lighting` service contains properties that you can adjust to update the global lighting in a game, such as the `Class.Lighting.ClockTime|ClockTime` and `Class.Lighting.Brightness|Brightness`.

#### ClockTime = 0

![Lighting with ClockTime of 0 (TimeOfDay of 00:00:00)](../assets/lighting-and-effects/lighting-properties/TimeOfDay-0.jpg)

#### ClockTime = 6.3

![Lighting with ClockTime of 6.3 (TimeOfDay of 06:18:00)](../assets/lighting-and-effects/lighting-properties/TimeOfDay-6.3.jpg)

#### Brightness = 0.5

![Lighting with Brightness property of 0.5](../assets/lighting-and-effects/lighting-properties/Brightness-0.5.jpg)

#### Brightness = 3.75

![Lighting with Brightness property of 3.75](../assets/lighting-and-effects/lighting-properties/Brightness-3.75.jpg)

> **Info:** In addition to global lighting, you can create and attach [light sources](/docs/en-us/effects/light-sources.md) to parts or attachments to simulate objects like lamps, torches, spotlights, or TV screens.
## Atmospheric effects

[Atmospheric effects](/docs/en-us/environment/atmosphere.md) simulate realistic environments by scattering sunlight in unique ways. Using the `Class.Atmosphere` object in the `Class.Lighting` service, you can control air particle [density](/docs/en-us/environment/atmosphere.md#density), simulate [haze](/docs/en-us/environment/atmosphere.md#haze) or [glare](/docs/en-us/environment/atmosphere.md#glare), set an atmosphere's [color](/docs/en-us/environment/atmosphere.md#color), and more.

![Atmospheric effects used to render a brilliant sunset scene](../assets/lighting-and-effects/atmosphere/Showcase.jpg)_Atmospheric effects used to render a brilliant sunset scene_

## Clouds and skies

By default, the `Class.Sky` object forms a [skybox](/docs/en-us/environment/skybox.md) with celestial bodies such as a sun, moon, and stars. In addition, you can adjust the cloud cover, density, and color properties of the `Class.Clouds` object to render realistic, [dynamic clouds](/docs/en-us/environment/clouds.md) that drift slowly across the sky through [global wind](/docs/en-us/environment/global-wind.md).

_Wind blowing dynamic clouds across the sky_

## Post-processing effects

**Post-processing effects** are customizable filters that allow you to quickly enrich the visuals of your game. Using the post-processing effect objects in the `Class.Lighting` service or `Class.Camera`, you can:

- Simulate a camera viewing a bright light and exaggerate its glow.
- Apply a Gaussian blur to the entirety of your game or add a blur to parts of your game that aren't in focus.
- Enhance an environment's appearance to create a specific mood through hue.
- Render a halo of light that moves with the sun.

![Landscape with depth-of-field effect applied, simulating distance blur](../assets/lighting-and-effects/post-processing/DepthOfFieldEffect-With.jpg)_Landscape with depth-of-field effect applied, simulating distance blur_
</document>

<document url="/docs/en-us/environment/lighting.md" title="Global lighting">
