---
title: "Layered accessories"
url: /docs/en-us/avatar/layered-accessories
last_updated: 2026-11-05T19:15:48Z
description: "Layered accessories are 3D assets that stretch, fit, and layer over any character body type."
keywords: ["Layered clothing","Layerable accessories","Layered clothing accessories"]
---

# Layered accessories

A high-level overview of layered accessories on Roblox.

Create and sell your first basic layered accessory.

**Layered accessories**, often referred to as **layered clothing**, are 3D assets that stretch and fit on an avatar character's body according to their rigging armature and cage meshes. When users purchase layered accessories on the Marketplace, such as jackets, dresses, and cardigans, they expect it to move with the character's animations and layer appropriately on top of existing clothing the character is wearing.

There are three main layers of a layered accessory that structure how the accessory looks and works on the platform:

- **Mesh & textures** that make up the layered accessory's visual appearance.
- **Rigging armature** that determines how the character moves and animates with the layered accessory.
- **Cage meshes & attachments** that determine how the layered accessory stretches, fits, and layers over the character's body.

While you can create most of these layers manually in third-party modeling tools like [Blender](https://www.blender.org/) or [Maya](https://www.autodesk.com/products/maya/overview), cage meshes and attachments have strict configuration requirements to meet Roblox's technical [layered accessory specifications](/docs/en-us/avatar/specifications.md) that guarantee your layered accessories behave consistently from game to game. Before you create your first custom layered accessory, it's recommended to:

1. Understand the [essential components](#layered-accessory-components) of a layered accessory and how they work together.
2. Review all [resources](#resources) that Roblox provides to standardize and expedite the [creation process](#creation-process), such as Blender and Maya project files, Studio tooling, and step-by-step guides.
3. Follow the [basic layered accessory creation tutorial](/docs/en-us/art/accessories/creating.md) that covers how to create your own avatar-ready sweater from scratch in Blender.

Once you have a custom layered accessory, you can import it into Studio and use the Avatar Setup tool to process your creation into an avatar asset that's ready to be sold on the [Marketplace](/docs/en-us/marketplace.md).

> **Info:** Unlike layered accessories that stretch and wrap over a target until it fits over the character's body, rigid accessories don't deform and only attach to a specific point on the avatar. For more information, see [Rigid accessories](/docs/en-us/rigid-accessories.md).
> **Warning:** If you are a game developer and are looking for information on manually equipping or configuring layered accessories within a game, such as implementing layered accessories on a non-standard character model, see [Character appearance](/docs/en-us/characters/appearance.md).
## Layered accessory components

All layered accessories are made up of the same fundamental components that allow users to equip 3D items that stretch, fit, and layer over a target character and existing clothing items with consistent behavior **regardless** of the character's [body type](/docs/en-us/character-bodies/specifications.md#body-scale).

### Mesh part

_Jumpsuit layered accessory mesh object._

_Shoulder pads layered accessory mesh object._

All layered accessories require a single mesh object that represents the accessory's geometry. In Studio, this mesh object is represented as a `Class.MeshPart` nested under a single `Class.Model`.

### Textures

_2D texture map for the jumpsuit layered accessory._

_2D texture map for the shoulder pads layered accessory._

Textures are image files that define the surface appearance of your layered accessory. You can create textures within a texture painting program or 3D modeling software.

In Studio, you must import textures as image files and set them to `Class.MeshPart` objects by a child `Class.SurfaceAppearance` object or the mesh's `Class.MeshPart.TextureID|TextureID` property.

### Rigging armature

_To ensure the layered accessory can deform with the character's body, it must be weighted to a rigging armature._

_When the rigging armature is properly set up, the layered accessory moves and bends as the character moves in the 3D space._

Inside of the avatar's physical body is a non-rendered rigging armature that allows the character to articulate its limbs. Often referred to as joints or bones, a rigging armature includes skinning data that allows connections between limbs to bend organically, such as the character's knees and elbows. In Studio, this rigging and skinning data is saved to the mesh geometry.

The rigging armature also defines how layered accessories move and deform as the character moves in the 3D space. Using rigging and skinning techniques, you can configure areas of your layered accessories to move naturally with the character's joints, such as a shirt sleeve following the natural movement of the character's elbow and shoulder during a walk cycle.

### Cage meshes

_The inner cage defines the inner surface of the clothing item where the clothes wrap over._

_The outer cage defines the outer surface of the clothing item where any additional clothes can wrap and layer over._

Cage meshes set the inner and outer surfaces of a layered accessory. For example, the inner cage of a t-shirt defines how a layered accessory t-shirt stretches and fits over a character body, and the outer cage defines how other layered accessories can stretch and fit over the t-shirt itself.

In Studio, these cages are represented by `Class.WrapLayer` objects.

### Attachments

_The jumpsuit layered accessory's attachment point._

_The shoulder pads layered accessory's attachment point._

Attachment points for layered accessories set which body part the accessory is attached to when the character body ragdolls or dismembers in a game. In Studio, attachment points are represented by `Class.Attachment` objects.

> **Info:** You can automatically generate attachment points for your layered accessories using the [Accessory Fitting Tool](/docs/en-us/avatar/accessory-fitting-tool.md).
## Creation process

When designing a layered accessory in [Blender](https://www.blender.org/) or [Maya](https://www.autodesk.com/products/maya/overview), you must export all of the avatar components in a single `.fbx` or `.gltf` for import into Studio. Since 3D creation isn't a linear process and always requires reiteration and testing, the process of creating a layered accessory can differ between individuals and various creation workflows.

In general, the creation process follows the following workflow:

_ Layered Accessory Workflow_

## Resources

There are a variety of resources available for creators of all backgrounds to get started with layered accessory creation. Review the following table for specific topics and resources:

| Topic | Resources |
| --- | --- |
| Tutorials | [Create your first layered accessory](/docs/en-us/art/accessories/creating.md) |
| Reference files | [Accessory and clothing reference files](/docs/en-us/art/modeling/project-files.md) |
| Technical specs | [.FBX export settings](/docs/en-us/art/modeling/export-requirements.md)<br><br>[General mesh specifications](/docs/en-us/art/modeling/specifications.md)<br><br>[Accessory specifications](/docs/en-us/avatar/rigid-accessories/specifications.md)<br><br>[Marketplace policy](/docs/en-us/marketplace/marketplace-policy.md) |
| Cosmetic creation | [Accessories overview](/docs/en-us/rigid-accessories.md)<br><br>[Layered clothing overview](/docs/en-us/layered-accessories.md)<br><br>[Create face accessories](/docs/en-us/art/characters/facial-animation/create-face-accessories.md)<br><br>[Accessory Fitting Tool](/docs/en-us/accessory-fitting-tool.md)<br><br>[Accessory specifications](/docs/en-us/rigid-accessories/specifications.md)<br><br>[Marketplace requirements](/docs/en-us/marketplace/marketplace-policy.md) |
| Texturing | [Texturing requirements](/docs/en-us/art/modeling/texture-specifications.md)<br><br>[PBR textures](/docs/en-us/art/modeling/surface-appearance.md) |
| Rigging and skinning | [Rigging and skinning overview](/docs/en-us/art/modeling/rigging.md)<br><br>[Humanoid rigging requirements](/docs/en-us/avatar/character-bodies/specifications.md#rigging)<br><br>[Rigging facial bones](/docs/en-us/art/characters/facial-animation/create-basic-heads.md#rig-and-skin-the-head)<br><br>[Auto skin transfer](/docs/en-us/avatar/automatic-skinning-transfer.md)<br><br>[Skin facial bones](/docs/en-us/art/characters/facial-animation/create-basic-heads.md#skin-joints) |
| Testing and validation | [Calisthenics tool](/docs/en-us/art/modeling/calisthenics-tool.md)<br><br>[Clothing validation tool](/docs/en-us/art/accessories/validation-tool.md) |
| Publishing and Marketplace | [Upload to Marketplace](/docs/en-us/marketplace/publish-to-marketplace.md)<br><br>[Marketplace policy](/docs/en-us/marketplace/marketplace-policy.md)<br><br>[Fees and commissions](/docs/en-us/marketplace/marketplace-fees-and-commissions.md) |
</document>

<document url="/docs/en-us/avatar/layered-accessories/project-files.md" title="Layered accessory reference files">
