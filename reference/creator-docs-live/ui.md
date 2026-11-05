---
title: "User interface"
url: /docs/en-us/ui
last_updated: 2026-11-05T19:16:10Z
description: "Explore the wide variety of user interface elements that players can interact with."
---

# User interface

You can quickly create high-quality graphical user interfaces with minimal scripting requirements using built-in [UI objects](#ui-objects). Depending on where you create it, UI renders either [on-screen](#on-screen-ui) or [within a game's 3D world](#in-game-ui).

## On-screen UI

[On-screen containers](/docs/en-us/ui/on-screen-containers.md) hold UI objects that you want to display on a player's screen, including [frames](/docs/en-us/ui/frames.md), [labels](/docs/en-us/ui/labels.md), [buttons](/docs/en-us/ui/buttons.md), and more. All on-screen UI objects and code are stored and changed on the client.

![Example ScreenGui with various GuiObject children, including a Frame, TextLabel, TextBox, and ImageButton.](../assets/ui/ui-objects/ScreenGui-Example.jpg)

## In-game UI

[In-game containers](/docs/en-us/ui/in-experience-containers.md) such as `Class.SurfaceGui|SurfaceGuis` and `Class.BillboardGui|BillboardGuis` hold UI objects that you want to display within your game's 3D world.

## UI objects

Most UI elements are `Class.GuiObject|GuiObjects`, 2D graphical user interface objects that you can parent to containers. The four most common are [frames](/docs/en-us/ui/frames.md), [labels](/docs/en-us/ui/labels.md), [buttons](/docs/en-us/ui/buttons.md), and [text input](/docs/en-us/ui/text-input.md) objects.

| Object | Description |
| --- | --- |
| [Frame](/docs/en-us/ui/frames.md) | `Class.Frame\|Frames` act as containers for other UI objects. When you manipulate frames, you also manipulate the objects they contain. |
| [Label](/docs/en-us/ui/labels.md) | `Class.TextLabel` and `Class.ImageLabel` objects allow you to display customizable text and images. |
| [Button](/docs/en-us/ui/buttons.md) | `Class.TextButton` and `Class.ImageButton` objects allow users to prompt an action. |
| [Text Input](/docs/en-us/ui/text-input.md) | `Class.TextBox` objects allow users to input text. |

Using the `Class.GuiObject.Position|Position`, `Class.GuiObject.Size|Size`, `Class.GuiObject.AnchorPoint|AnchorPoint`, and `Class.GuiObject.ZIndex|ZIndex` properties, you have complete control on how to [position](/docs/en-us/ui/position-and-size.md#position), [size](/docs/en-us/ui/position-and-size.md#size), and [layer](/docs/en-us/ui/position-and-size.md#zindex) `Class.GuiObject|GuiObjects`. You can also use [tweening](/docs/en-us/ui/animation.md) to transition a `Class.GuiObject` smoothly from one state to another and provide dynamic visual feedback.

## Layout and design

Beyond basic properties for adjusting position and size, Roblox also provides layout structures like [list/flex](/docs/en-us/ui/list-flex-layouts.md) and [grid](/docs/en-us/ui/grid-table-layouts.md), as well as [size modifiers](/docs/en-us/ui/size-modifiers.md) and [appearance modifiers](/docs/en-us/ui/appearance-modifiers.md).

_`Class.UIListLayout` for horizontal or vertical item sequences_

_`Class.UIStroke` on `Class.TextLabel`_

_`Class.UIStroke` with `Class.UIGradient`_

## Universal styling

[Universal styling](/docs/en-us/styling.md) is a Roblox solution to stylesheets, similar to CSS, that lets you declare and globally apply overrides to UI instance properties. This engine‑level support is the foundation for the [Style Editor](/docs/en-us/styling/editor.md) and the end‑to‑end token pipeline.

## Interactive frameworks

In addition to the core [user interface objects](#ui-objects), the following frameworks provide built‑in and customizable interactivity for your games.

### Proximity prompts

[Proximity prompts](/docs/en-us/ui/proximity-prompts.md) are unique built-in UI objects which prompt user interaction to trigger an action when they approach in-game objects such as doors, light switches, and buttons.

### UI drag detectors

[UI drag detectors](/docs/en-us/ui/ui-drag-detectors.md) facilitate and encourage interaction with 2D user interface elements such as sliders, spinners, and more.

### 3D drag detectors

[3D drag detectors](/docs/en-us/ui/3D-drag-detectors.md) encourage physical interaction with 3D objects in a game, such as opening doors and drawers, sliding a part around, grabbing and tossing a bowling ball, pulling back and firing a slingshot, and much more.
</document>

<document url="/docs/en-us/ui/labels.md" title="Text & image labels">
