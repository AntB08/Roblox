---
title: "Parts"
url: /docs/en-us/parts
last_updated: 2026-11-05T19:15:55Z
description: "Parts are Roblox's primary building blocks."
---

# Parts

`Class.Part|Parts` are descendants of the `Class.BasePart` class and are Roblox's primitive building blocks with properties like position, size, orientation, and color. You can use basic parts as is, or you can apply [solid modeling](/docs/en-us/parts/solid-modeling.md) operations to combine parts into more complex shapes.

For advanced and intricate 3D models, you can also import third-party model files as `Class.MeshPart|MeshParts` as outlined in [Meshes](/docs/en-us/parts/meshes.md).

![A single gray sphere part](../assets/modeling/parts/Basic-Part-Sphere.png)_Basic sphere part_

![A bright blue hollow bowl that was made with solid modeling operations.](../assets/modeling/parts/Part-Example-CSG.jpg)_Bowl created with solid modeling_

![A high-quality treasure chest mesh with a texture.](../assets/modeling/parts/Mesh-Example.jpg)_Mesh with texture_

By default, parts are rigid bodies that follow real-world physical mechanics, including gravity, collision, and momentum. You can connect related parts together as a single [assembly](/docs/en-us/physics/assemblies.md) using a `Class.WeldConstraint`, or a joint like `Class.Motor6D` or `Class.Bone`. As an assembly, the connected parts act as a single rigid entity, referencing a common position, orientation, and scale.

You can use a `Class.Model` container to group related parts together and access the group as a single assembly in the [Explorer](/docs/en-us/studio/explorer.md). See [Models](/docs/en-us/parts/models.md) for more information.

## Basic part types

`Class.Part` objects can take the shape of blocks, spheres, cylinders, wedges, or corner wedges. In addition, `Class.TrussPart` acts as a truss beam that characters can climb like a ladder.

![A single Block part.](../assets/modeling/parts/Basic-Part-Block.png)_ Block_

![A single Sphere part.](../assets/modeling/parts/Basic-Part-Sphere.png)_ Sphere_

![A single Cylinder part.](../assets/modeling/parts/Basic-Part-Cylinder.png)_ Cylinder_

![A single Wedge part.](../assets/modeling/parts/Basic-Part-Wedge.png)_ Wedge_

![A single Corner Wedge part.](../assets/modeling/parts/Basic-Part-Corner-Wedge.png)_ Corner Wedge_

## Part properties

Each part has a variety of properties that you can customize through the [Properties](/docs/en-us/studio/properties.md) window.

![A close up view of the Properties window with the Appearance and Transform properties highlighted.](../assets/studio/properties/Sections-Example.png)

The following are commonly utilized properties:

- `Class.BasePart|Anchored` controls if physics affects the position of the part. When this property is set to true, the part never changes position due to gravity or any other force. You should anchor most parts in your game or gravity and physics will affect your parts as soon as the game runs.
  > **Success:** To view lighted outlines around the base of anchored parts in order to visualize which parts cannot move under gravity or physics, toggle on **Anchored parts** from the [Visualization Options](/docs/en-us/studio/overview.md#visualization-options) widget in the upper‑right corner of the 3D viewport.
- `Class.BasePart|CanCollide` controls whether or not a part can collide with other parts. When this property is set to true, the part is impenetrable and the physics engine accounts for it within your game. Conversely, when this property is set to false, the part can pass through anything, and the physics engine does **not** account for it.
- `Class.BasePart|Transparency` sets a part's visibility to any value between the default value of 0 (fully visible) and 1 (fully transparent). If you have many partially transparent parts, they can slow down performance. To alleviate this, merge them using [solid modeling](/docs/en-us/parts/solid-modeling.md).

## Insert parts

The **Part** insertion button, accessible from the **Home** and **Model** tab toolbars, inserts a new part into the workspace. Click‑holding over the small corner arrow on the button lets you select either **Block**, **Sphere**, **Wedge**, **Corner Wedge**, or **Cylinder**.

![Part tool and its part type picker menu.](../assets/studio/general/Toolbar-Insert-Part-Widget.png)
> **Info:** To insert a `Class.TrussPart` (not available on the insertion menu), use the [Explorer](/docs/en-us/studio/explorer.md) as outlined [here](/docs/en-us/studio/explorer.md#insert-and-parent).
## Select parts

As you hover over parts in the 3D viewport, they are outlined to indicate their potential selection. You can select an outlined part by clicking it, or you can select multiple parts by holding `Shift`, `Ctrl`, or `⌘` as you hover over and click them. For advanced methods of selecting parts in the viewport, see [object selection](/docs/en-us/studio/overview.md#object-selection).

![Multiple models selected in 3D viewport](../assets/studio/general/Editor-Window-Object-Selection.jpg) ## Transform parts

You can move, scale, and rotate selected parts either through modeling tools or by setting a new position, size, or orientation in the [Properties](#part-properties) window.

![Transform tools indicated in Studio's toolbar.](../assets/studio/general/Toolbar-Transform-Tools.png)

![Move draggers shown on part in 3D viewport.](../assets/modeling/parts/Transform-Move-SM.png)_Move_

![Scale draggers shown on part in 3D viewport.](../assets/modeling/parts/Transform-Scale-SM.png)_Scale_

![Rotate draggers shown on part in 3D viewport.](../assets/modeling/parts/Transform-Rotate-SM.png)_Rotate_

When using the tools, you can move, scale, or rotate parts in either **world** orientation or **local** orientation by pressing `Ctrl``L` on Windows or `⌘``L` on Mac. When you enable local orientation, the arrow axis indicators change to a part's local orientation, and an **L** indicator displays.

#### World

![An angled block part with draggers in World orientation mode.](../assets/modeling/parts/Move-World-Orientation.png)

#### Local

![An angled block part with draggers in Local orientation mode.](../assets/modeling/parts/Move-Local-Orientation.png)

Tool transform **snapping** increments are based on **studs** for moving/scaling or **degrees** for rotating, each adjustable in the toolbar. While transforming, you can temporarily toggle snapping by holding the `Shift` key.

![Transform snapping tools indicated in Studio's toolbar.](../assets/studio/general/Toolbar-Transform-Snapping.png)
> **Info:** To quickly jump to the **move/scale** increment input, press `Shift``2`. To quickly jump to the **rotate** increment input, press `Alt``R` (Windows) or `⌥``R` (Mac).
### Move

You can move a selected part to a new position using the **Move** tool (default shortcut `2`) or by **cursor dragging**. While moving a part, you can temporarily toggle snapping by holding `Shift`.

#### Move Tool

To move a part by an axis dragger along the **X**, **Y**, or **Z** axis, click/drag an arrow pointing along the desired axis of movement.

![A block part with the Move tool's visual aids.](../assets/modeling/parts/Transform-Move.png)

After releasing the drag, the numerical **distance indicator** remains visible. If desired, fine‑tune the distance that was moved by clicking inside the indicator and entering any number.

![A moved part showing the distance moved in an indicator/input field](../assets/modeling/parts/Transform-Move-Indicator.png)

If you drag a part by its [pivot](/docs/en-us/studio/pivot-tools.md) point while the **Move** tool is selected, the pivot will "soft snap" to surfaces and edges of nearby parts.

![A block part with an offset pivot soft-snapping to the surface of a nearby part.](../assets/modeling/parts/Transform-Move-Pivot-Snap.png)

#### Cursor Drag

To move a part by cursor dragging, click anywhere on the part to grab it. If snapping is **enabled**, a ruler will appear as you hover, showing what point you'll grab the part by. As you drag the part around, another ruler will appear on the surface/edge of nearby parts, indicating alignment of the grab point.

![A block part showing the grab point and snapping ruler on a neighboring part.](../assets/modeling/parts/Transform-Move-Ruler-Snap.png)

If snapping is **disabled**, the part will "soft snap" to surfaces and edges of nearby parts.

![A block part soft-snapping to the corner edges of a neighboring part.](../assets/modeling/parts/Transform-Move-Cursor-Drag-Snap.png)

While cursor dragging, `T` and `R` can be used to quickly rotate the part in 90° increments around the point you picked it up by. `T` tilts the part 90° towards the camera, while `R` rotates the part 90° around the normal of the hovered surface.

![Diagram showing how parts can be tilted and rotated with the T and R keys respectively.](../assets/modeling/parts/Transform-Move-Cursor-Drag-T-R.png)

### Scale

To scale (resize) a selected part along the **X**, **Y**, or **Z** axis, use the **Scale** tool (default shortcut `3`) and click/drag a handle. While dragging, you can temporarily toggle snapping by holding `Shift`.

![A block part with the Scale tool's visual aids.](../assets/modeling/parts/Transform-Scale.png) ### Rotate

To rotate a selected part around the **X**, **Y**, or **Z** axis, use the **Rotate** tool (default shortcut `4`) and click/drag a rotation ring. While dragging, you can temporarily toggle snapping by holding `Shift`.

![A block part with the Rotate tool's visual aids.](../assets/modeling/parts/Transform-Rotate.png)
> **Info:** In addition to using the **Rotate** tool, you can quickly rotate selected objects 90° about their **X** axis by pressing `Ctrl``T` (`⌘``T`) or 90° about their **Y** axis by pressing `Ctrl``R` (`⌘``R`).
## Other actions

### Group

You can group objects into a [model](/docs/en-us/parts/models.md) by selecting them and clicking the **Group** button. This action has a default shortcut of `Ctrl``G` (Windows) or `⌘``G` (Mac).

Alternatively, you can group objects into a [folder](/docs/en-us/studio/explorer.md#organizing-by-folders) by click‑holding over the small corner arrow on the button and selecting **Group as Folder** (default shortcut of `Alt``Ctrl``G` or `⌥``⌘``G`).

![Group tool indicated in Studio's toolbar](../assets/studio/general/Toolbar-Group.png)

To **ungroup** an existing model or folder, select **Ungroup** from the **Edit** menu (default shortcut of `Ctrl``U` or `⌘``U`).

### Anchor

The **Anchor** toggle controls whether the part will be **immovable** by physics. When `Class.BasePart.Anchored|Anchored`, a part will never change position due to gravity, other parts collisions, overlapping other parts, or any other physics-related causes. This action has a default shortcut of `Alt``A` (Windows) or `⌥``A` (Mac).

![Anchor toggle indicated in Studio's toolbar](../assets/studio/general/Toolbar-Anchor.png)
> **Info:** If you prefer a click-to-toggle workflow in the 3D viewport, click‑hold over the small corner arrow on the **Anchor** button and enable **Click object to anchor**. Once enabled, the tool operates as a "key" for both states — clicking on an unanchored object in the viewport anchors it, while clicking on an anchored object unanchors it.
### Color

While a part is gray by default, you can change it to any color through the following methods.

#### Color Button

Clicking the **Color** button applies the selected color to all selected parts. You can choose a color by click‑holding over the small corner arrow on the **Color** button to reveal a hexagonal picker.

![Color widget's hexagonal picker.](../assets/studio/general/Toolbar-Color-Picker.png)
> **Info:** If you prefer a fill/paint workflow in the 3D viewport, enable **Click object to apply color** at the bottom of the hexagonal picker popup and then click parts in the viewport to apply the chosen color.

#### Color Popup

The **Color** popup allows you to set a color through your operating system's color picker widget. To access it, navigate to the [Properties](/docs/en-us/studio/properties.md) window and click the small box to the left of the `Class.BasePart.Color|Color` property.

![A close up view of the Properties window with the Color property's color box highlighted.](../assets/studio/properties/Color-Picker.png)

#### RGB Value

To define a specific RGB color value for a part, enter an RGB value into the `Class.BasePart.Color|Color` property field.

![A close up view of the Properties window with the Color property's RGB color value highlighted.](../assets/studio/properties/Color-RGB-Entry.png)

### Material

Similar to [color](#color), you can customize a part's [material](/docs/en-us/parts/materials.md) to simulate real‑world materials such as wood, glass, or fabric. Click‑holding over the small corner arrow on the **Material** button reveals the [material](/docs/en-us/parts/materials.md) picker.

![Material widget's picker highlighted.](../assets/studio/general/Toolbar-Material-Picker.png)

When selecting a material, consider the following:

- **Material affects the physical traits of a part, not just its appearance**. For example, the `Enum.Material.Concrete|Concrete` material is heavier than the `Enum.Material.Plastic|Plastic` material, so a concrete brick will have higher density than a plastic brick and sink in water faster.
- Some materials have special physical effects. For example, parts will appear to glow if they are set to the `Enum.Material.Neon|Neon` material.![An angled red block part with a smooth plastic material.](../assets/modeling/parts/Material-SmoothPlastic.png)_SmoothPlastic_![An angled red block part with a glowing neon material.](../assets/modeling/parts/Material-Neon.png)_Neon_

See [Materials](/docs/en-us/parts/materials.md) for more information on how to apply both default and custom materials to parts.

### Lock

The **Lock** toggle controls whether the part can be selected from the 3D viewport. This action has a default shortcut of `Alt``L` (Windows) or `⌥``L` (Mac).

![Lock tool indicated in Studio's toolbar](../assets/studio/general/Toolbar-Lock.png)
> **Info:** If you prefer a click-to-toggle workflow in the 3D viewport, click‑hold over the small corner arrow on the **Lock** button and enable **Click object to lock**. Once enabled, the tool operates as a "key" for both states — clicking on an unlocked object in the viewport locks it, while clicking on a locked object unlocks it.

To unlock all objects, select **Unlock All** from the **Edit** menu.
</document>

<document url="/docs/en-us/parts/materials.md" title="Materials">
