---
title: "Rigid accessories"
url: /docs/en-us/avatar/rigid-accessories
last_updated: 2026-11-05T19:15:48Z
description: "Rigid accessories are 3D assets that attach to an avatar according to the attachment points around the character's body."
---

# Rigid accessories

A high-level overview of rigid accessories on Roblox.

Create and sell your first basic rigid accessory.

**Rigid accessories** are 3D objects that attach to attachment points around an avatar character's body. When users purchase rigid accessories on the [Marketplace](https://www.roblox.com/catalog), such as props, weapons, and hats, they can adjust the position and rotation of the item away from the attachment point according to their avatar's body type.

There are two main layers of a rigid accessory that structure how the accessory looks and works on the platform:

- **Mesh & textures** that make up the rigid accessory's visual appearance.
- **Attachments** that determine how the accessory attaches to the character's body.

While you can create the first of these layers manually in third-party modeling tools like [Blender](https://www.blender.org/) or [Maya](https://www.autodesk.com/products/maya/overview), attachments have strict configuration requirements to meet Roblox's technical [rigid accessory specifications](/docs/en-us/avatar/specifications.md) that guarantee your rigid accessories behave consistently from game to game. Before you create your first custom rigid accessory, it's recommended to:

1. Understand the [essential components](#rigid-accessory-components) of a rigid accessory and how they work together.
2. Review all [resources](#resources) that Roblox provides to standardize and expedite the [creation process](#creation-process), such as Blender and Maya project files, Studio tooling, and step-by-step guides.
3. Follow the [basic rigid accessory creation tutorial](/docs/en-us/art/accessories/creating-rigid.md) that covers how to convert a simple 3D model into a rigid accessory.

Once you have a custom rigid accessory, you can import it into Studio and use the Avatar Setup tool to process your creation into an avatar asset that's ready to be sold on the [Marketplace](/docs/en-us/marketplace.md).

> **Info:** Unlike rigid accessories that don't deform when they attach to a specific point on the avatar, layered accessories stretch and wrap over a target until it fits over the character's body. For more information, see [Layered accessories](/docs/en-us/layered-accessories.md).
## Rigid accessory components

All rigid accessories are made up of the same fundamental components that allow users to equip 3D items with consistent behavior **according** to the character's [body type](/docs/en-us/avatar/specifications.md#body-scale).

> **Warning:** Layered accessories require [additional components](/docs/en-us/layered-accessories.md) to apply the layerable effect to the 3D item.
### Mesh part

_Bow rigid accessory mesh object._

_Hair rigid accessory mesh object._

All rigid accessories require a single mesh object that represents the accessory's geometry. In Studio, this mesh object is represented as a `Class.MeshPart` nested under a single `Class.Model`.

### Textures

_2D texture map for the bow rigid accessory._

_2D texture map for the hair rigid accessory._

Textures are image files that define the surface appearance of your rigid accessory. You can create textures within a texture painting program or 3D modeling software.

In Studio, you must import textures as image files and set them to `Class.MeshPart` objects by a child `Class.SurfaceAppearance` object or the mesh's `Class.MeshPart.TextureID|TextureID` property.

### Attachments

_The bow's attachment point enables the bow to connect to a character's back._

_The hair's attachment point enables the hair to connect to a character's head._

Attachment points define where accessories attach to a character's body. In Studio, attachment points are represented by `Class.Attachment` objects.

> **Info:** You can automatically generate attachment points for your rigid accessories using the [Accessory Fitting Tool](/docs/en-us/avatar/accessory-fitting-tool.md).
## Creation process

When designing a rigid accessory in [Blender](https://www.blender.org/) or [Maya](https://www.autodesk.com/products/maya/overview), you must export all of the avatar components in a single `.fbx` or `.gltf` for import into Studio. Since 3D creation isn't a linear process and always requires reiteration and testing, the process of creating a rigid accessory can differ between individuals and various creation workflows.

In general, the creation process follows the following workflow:

_ Rigid Accessory Workflow_

## Resources

There are a variety of resources available for creators of all backgrounds to get started with rigid accessory creation. Review the following table for specific topics and resources:

| Topic | Resources |
| --- | --- |
| Tutorials | [Rigid accessory creation](/docs/en-us/art/accessories/creating-rigid.md) |
| Reference files | [Accessory and clothing reference files](/docs/en-us/art/modeling/project-files.md) |
| Technical specs | [.FBX export settings](/docs/en-us/art/modeling/export-requirements.md)<br><br>[General mesh specifications](/docs/en-us/art/modeling/specifications.md)<br><br>[Rigid accessory specifications](/docs/en-us/avatar/rigid-accessories/specifications.md)<br><br>[Marketplace policy](/docs/en-us/marketplace/marketplace-policy.md) |
| Cosmetic creation | [Rigid accessories overview](/docs/en-us/avatar/rigid-accessories.md)<br><br>[Layered clothing overview](/docs/en-us/avatar/layered-accessories.md)<br><br><br>[Accessory Fitting Tool](/docs/en-us/avatar/accessory-fitting-tool.md)<br><br>[Rigid accessory specifications](/docs/en-us/avatar/rigid-accessories/specifications.md)<br><br>[Marketplace requirements](/docs/en-us/marketplace/marketplace-policy.md) |
| Texturing | [Texturing requirements](/docs/en-us/art/modeling/texture-specifications.md)<br><br>[PBR textures](/docs/en-us/art/modeling/surface-appearance.md) |
| Rigging and skinning | [Rigging and skinning overview](/docs/en-us/art/modeling/rigging.md)<br><br>[Humanoid rig requirements](/docs/en-us/avatar/character-bodies/specifications.md#rigging)<br><br>[Rig facial bones](/docs/en-us/art/characters/facial-animation/create-basic-heads.md#rig-and-skin-the-head)<br><br>[Automatic Skin Transfer](/docs/en-us/avatar/automatic-skinning-transfer.md)<br><br>[Skin facial bones](/docs/en-us/art/characters/facial-animation/create-basic-heads.md#skin-joints) |
| Publishing and Marketplace | [Uploading to Marketplace](/docs/en-us/marketplace/publish-to-marketplace.md)<br><br>[Marketplace Policy](/docs/en-us/marketplace/marketplace-policy.md)<br><br>[Fees and commissions](/docs/en-us/marketplace/marketplace-fees-and-commissions.md) |
</document>

<document url="/docs/en-us/avatar/rigid-accessories/specifications.md" title="Rigid accessory specifications">
