---
title: "Cage meshes"
url: /docs/en-us/art/modeling/cage-meshes
last_updated: 2026-11-05T19:15:46Z
description: "Cage meshes are low-resolution surfaces that let one mesh reshape and layer over another, powering layered accessories."
---

# Cage meshes

**Cage meshes** are invisible surfaces of a `Class.MeshPart` that allow other supported meshes to stretch and deform over each other. With cage meshes, you can create a set of meshes that can dynamically resize, reshape, and layer over another mesh of any shape or size.

They power **layered accessories** — 3D accessories such as jackets, dresses, and cardigans that stretch to fit a character body and stack naturally on top of one another — and you can also apply them to any `Class.MeshPart`, as long as all the cage meshes [share the same UV mapping](#how-cages-pair).

#### Reshape volume

![A mesh's outer cage in Blender beside a plain cube and a checker mesh whose volume the cage has reshaped in Studio.](../../../assets/modeling/cage-meshes/Outer-Cage-Hero.png)_An outer cage is an invisible surface that can reshape a mesh's volume._

#### Deform any shape

![A single source cube asset deformed onto several different target shapes — a diamond, a sphere, a cube, and twisted shapes — in Studio.](../../../assets/modeling/cage-meshes/Cage-Intro-Hero.png)_A single caged mesh deformed onto many differently-shaped targets._

#### Layered accessories

![An avatar wearing a layered red coat over a camo shirt, shown fitting across different body shapes.](../../../assets/modeling/cage-meshes/Layered-Accessory-Hero.png)_Layered accessories stretch and stack to fit different avatar body shapes._

A cage mesh is a simplified copy of a render mesh that defines a wrapping surface. Unlike Roblox's [collision system](/docs/en-us/workspace/collisions.md), which works universally, cage meshes can only work with other paired cage meshes.

To fit one mesh over another, Roblox pairs the vertices of one cage with those of the other by their UV coordinates, then reshapes the render mesh so that its cage matches the target cage. Cage meshes are typically configured in a modeling tool such as [Blender](https://www.blender.org) or [Maya](https://www.autodesk.com/products/maya/overview).

> **Info:** In specific cases, you can also create and reshape cage meshes programmatically at runtime, such as in experiences that let users build and customize avatar items. See [Avatar in-experience creation](/docs/en-us/avatar/in-experience-creation.md).
## Cage mesh components

In Studio, cage meshes are children of a `Class.MeshPart` and are represented by descendants of the `Class.BaseWrap` class:

| Cage mesh type | In Blender | In Studio |
| --- | --- | --- |
| `Class.WrapTarget`<br><br> The initial caged surface that other paired cage meshes can target. <br><br>Every caging deformation requires a target mesh. | ![The Blender Outliner showing a render mesh with a single _OuterCage.](../../../assets/modeling/cage-meshes/Blender-Outliner-Target.png)<br>A render mesh with a single `_OuterCage` mesh. | ![The Studio Explorer showing a MeshPart with a child WrapTarget object.](../../../assets/modeling/cage-meshes/WrapTarget-Explorer.png)<br>A `Class.MeshPart` with a child `Class.WrapTarget`. |
| `Class.WrapLayer`<br><br> Allows its parent `Class.MeshPart` to wrap around a `Class.WrapTarget`, such as a layered clothing accessory wrapping over an avatar body.<br><br> All targets and layers must share identical UVs. | ![The Blender Outliner showing a render mesh with an _InnerCage and an _OuterCage.](../../../assets/modeling/cage-meshes/Blender-Outliner-Layer.png)<br>A render mesh with an `_InnerCage` and an `_OuterCage` mesh. | ![The Studio Explorer showing a MeshPart with a child WrapLayer object.](../../../assets/modeling/cage-meshes/WrapLayer-Explorer.png)<br>A `Class.MeshPart` with a child `Class.WrapLayer`. |

Because a cage behaves like a component of its parent, a `Class.MeshPart` is the only valid parent for these objects. You author cage meshes alongside your render mesh in a modeling application like [Blender](https://www.blender.org) or [Maya](https://www.autodesk.com/products/maya/overview) and import them together.

> **Info:** When you import a model that contains cage meshes, make sure **Uses Cages** is enabled in the [3D Importer](/docs/en-us/studio/importer.md#import-settings) so that Studio detects the cages and creates the cage objects for you.
## How cages pair

Roblox pairs cages by their **UV coordinates** rather than by position, so any two cages that share a UV layout can wrap over each other, even when their shapes differ. This is what lets a single accessory fit bodies of completely different shapes and sizes without remodeling it for each one.

![A shared UV layout in the Blender UV editor, laid out as an unwrapped cube cross.](../../../assets/modeling/cage-meshes/UV-Map.png)

The following shapes are completely different, but they all share the identical UV map above, so a single layered mesh can deform onto any of them.

![A cube in the Blender viewport.](../../../assets/modeling/cage-meshes/Cube-shape.png)_Cube_

![A sphere in the Blender viewport.](../../../assets/modeling/cage-meshes/Sphere-shape.png)_Sphere — shaped from a cube_

![A flattened, twisted shape in the Blender viewport.](../../../assets/modeling/cage-meshes/Flatten-Shape.png)_Flattened — sculpted from a cube_

## Create caged assets

Use the following guides to create caged assets. Each guide includes downloadable files and basic implementation steps to follow along.

- [Create cages in Blender](/docs/en-us/art/modeling/create-cages.md) — author the outer and inner cages for a model and import them into Studio.
- [Apply deformation](/docs/en-us/art/modeling/apply-deformation.md) — deform a caged mesh onto a target with a `Class.WrapLayer`.
- [Create your own layered accessory](/docs/en-us/art/accessories/creating.md) — create a layered accessory using Roblox's provided reference cages.
</document>

<document url="/docs/en-us/art/modeling/calisthenics-tool.md" title="Calisthenics Tool">
