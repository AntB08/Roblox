---
title: "3D workspace"
url: /docs/en-us/workspace
last_updated: 2026-11-05T19:16:10Z
description: "Describes the workspace container service, which holds all objects that exist in the 3D world."
---

# 3D workspace

`Class.Workspace` is a container service that holds objects that you want the Roblox Engine to render in the 3D world. You typically will add these objects to the workspace:

- `Class.BasePart` objects, which includes both `Class.Part` and `Class.MeshPart` objects.
- `Class.Attachment` objects, which you can attach to special effect generators like a `Class.ParticleEmitter`, UI objects like a `Class.BillboardGui`, physical `Class.Constraint|Constraints`, and more.
- `Class.Model` objects that organize geometric groupings.
- `Class.Script` objects that are parented by other objects in the workspace. Scripts aren't rendered but can affect another object's rendering.

## Parts

`Class.Part` objects represent the primitive building blocks in Roblox. By default, all parts have their physics simulated and are rendered if they appear in the 3D workspace. Parts can take the shape of blocks, spheres, cylinders, wedges, or corner wedges. In addition, `Class.TrussPart` acts as a truss beam that characters can climb like a ladder.

![A single Block part.](../assets/modeling/parts/Basic-Part-Block.png)_ Block_

![A single Sphere part.](../assets/modeling/parts/Basic-Part-Sphere.png)_ Sphere_

![A single Cylinder part.](../assets/modeling/parts/Basic-Part-Cylinder.png)_ Cylinder_

![A single Wedge part.](../assets/modeling/parts/Basic-Part-Wedge.png)_ Wedge_

![A single Corner Wedge part.](../assets/modeling/parts/Basic-Part-Corner-Wedge.png)_ Corner Wedge_

You can also apply [solid modeling](/docs/en-us/parts/solid-modeling.md) operations to parts, such as union or negate, to combine them into something more complex like bowls or hollow pipes.

## Meshes

A `Class.MeshPart` is an object that represents a mesh (a collection of vertices, edges, and faces that make up a 3D object). You typically create meshes using third-party software such as [Blender](https://www.blender.org) or [Maya](https://www.autodesk.com/products/maya/overview), then import them as a `Class.MeshPart` using Studio.

Meshes can include far more detail than any solid modeling you can do in Studio. They can also have internal rigs and textures, allowing you to create lifelike objects that you can pose and animate.

![A high-quality treasure chest mesh with a texture.](../assets/modeling/meshes/Mesh-Textured.jpg)_Mesh with texture_

![A realistic looking leafy bush with shadows and depth.](../assets/modeling/meshes/Mesh-SurfaceAppearance.jpg)_Mesh with SurfaceAppearance_

## Terrain

The `Class.Terrain` object allows you to generate and sculpt detailed and realistic terrain environments, such as mountains, bodies of water, grass-covered hills, or a flat desert. Using the [Terrain Editor](/docs/en-us/studio/terrain-editor.md), you can easily generate and alter large regions of terrain.

![A viewport view of desert terrain with mountains in the distance.](../assets/modeling/terrain/Showcase.jpg) ## Models

A `Class.Model` is a container object for **geometric groupings**, such as `Class.BasePart`, `Class.Motor6D` objects, and other models. Models can be simple groupings or you can set a primary part within the model, so that it functions as an assembly, which the physics engine treats as a single rigid body. Models can also contain scripts that act on the individual objects of the model.

![A humanoid model of a creepy girl with four red eyes standing in an A pose. She wears a maroon dress with webs and bright red stockings.](../assets/modeling/model-objects/Model-Example-3D.jpg)_A model named Octavia_

![A close up view of the model's children in the Explorer window that comprise the model.](../assets/modeling/model-objects/Model-Example-Hierarchy.png)_The groupings that comprise the model_

## Workspace access in scripts

Within a script, you can access a place's `Class.Workspace` in three different ways, all of which are valid.

- `game:GetService("Workspace")`
- `workspace`
- `game.Workspace`

From there, you can carry out a large set of use cases to script logic for your games and create dynamic worlds and interactions. For example:

- Obtain a reference to any object in the workspace to change its properties during runtime.
- Obtain a reference to a user's `Class.Camera` object to [manipulate their view](/docs/en-us/workspace/camera.md) of the workspace.
- Listen for events on objects in the workspace to carry out logic at specific times, such as when a user's playable character [touches an object](/docs/en-us/workspace/collisions.md).
</document>

<document url="/docs/en-us/workspace/raycasting.md" title="Raycasting">
