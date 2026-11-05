---
title: "Dynamic heads"
url: /docs/en-us/avatar/dynamic-heads
last_updated: 2026-11-05T19:15:48Z
description: "Facial animations enable avatars to create dynamic facial expressions."
---

# Dynamic heads

**Dynamic heads** are rigged avatar character heads that support facial animations and custom expressions. When users purchase dynamic heads on the [Marketplace](https://www.roblox.com/catalog), they can trigger emotes that combine both facial and body animations.

There are four main layers of a dynamic head that structure how the head looks and works on the platform:

- **Mesh & textures** that make up the head's visual appearance.
- **Facial animation data** that determine how the character's face moves and expresses the character's personality and emotions.
- **Cage meshes** that determine how the character's head equips facial accessories that deform with facial expressions, such as facial hair that moves accordingly when the character changes facial expressions.
- **Attachments** that determine how the character's head attaches accessories like hair and hats.

While you can create each of these layers manually in third-party modeling tools like [Blender](https://www.blender.org/) or [Maya](https://www.autodesk.com/products/maya/overview), some have strict configuration requirements to meet Roblox's technical [dynamic head specifications](/docs/en-us/avatar/specifications.md) that guarantee your dynamic head animates consistently from game to game. Before you create your first custom dynamic head, it's recommended to:

1. Understand the [essential components](#dynamic-head-components) of a dynamic head and how they work together.
2. Review all [resources](#resources) that Roblox provides to standardize and expedite the [creation process](#creation-process), such as Blender and Maya project files, Studio tooling, and step-by-step guides.
3. Follow the [basic dynamic head creation tutorial](/docs/en-us/art/characters/facial-animation/create-basic-heads.md) that covers how to add facial joints, apply skinning data, pose joints into expressions, and map poses on a head model in Blender.

Once you have a custom dynamic head, you can import it with a character body into Studio and use the Avatar Setup tool to process your creation into an avatar asset that's ready to be sold on the [Marketplace](/docs/en-us/marketplace.md).

## Dynamic head components

All dynamic heads are made up of the same fundamental components that allow users to equip facial accessories that stretch, fit, and layer over a target character's head with consistent behavior.

### Mesh part

_Masculine dynamic head mesh object._

_Feminine dynamic head mesh object._

All dynamic heads require a single mesh object that represents the head's geometry. In Studio, this mesh object is represented as a `Class.MeshPart` object nested under a single `Class.Model`.

### Textures

_Textures apply color and surface details to your character model._

_A texture image map's opacity can combine with the `Class.MeshPart.Color` to apply custom skin tones to characters._

Textures are image files that define the surface appearance of your character's head. You can create textures using a texture painting program or 3D modeling software. In Studio, you must import textures as image files and set them to `Class.MeshPart` objects by a child `Class.SurfaceAppearance` object or the mesh's `Class.MeshPart.TextureID|TextureID` property.

### Face animation data

_Each avatar character face is rigged and skinned to create various expressions_

_Each pose is mapped to a pose name within the Custom Properties (Extra Attributes in Maya) of the Head_Geo object_

_Each required face pose is saved as a keyframe in the animation timeline._

Facial animation data from the character's facial joints allow avatars to express emotions with their eyes, mouth, and teeth. Each character includes facial joints, skinning data, animation timeline data, and mapped pose data that allows these expressions. In Studio, these facial animation elements are represented by a `Class.FaceControls` instance.

### Cage meshes

_Head geometry and cage mesh objects (wireframe)_

_Cage objects must exist for each of the 15 body parts, including the dynamic head_

Cage meshes set the invisible outer boundary for facial accessories to stretch and fit over the character's head, allowing facial accessories to deform as the head animates and emotes. In Studio, outer cage mesh objects are represented by a `Class.WrapTarget` instance.

If you are caging your own non-template character model, it's important to use one of Roblox's body cage [project files](/docs/en-us/avatar/resources.md#mannequin-models) to ensure you are using a Roblox standard cage mesh. Removing or adding vertices from this standard mesh can cause issues with how facial accessories deform and import.

### Attachments

_Each character has common attachment points for equipping rigid cosmetics_

_Each avatar character must include their associated 19 attachment points, including those on the dynamic head_

Attachment points set the specific points where rigid accessories and in-game equippable objects attach to the character's head. These are not rendered on the platform, but they are represented visually as spheres in 3D modeling software when you use Roblox's **R15 Rig and Attachments** [project file](/docs/en-us/avatar/resources.md#project-files).

When you import a rig with these visual representations, the spheres are created as `Class.Attachment` objects using standardized names.

> **Info:** When users wear a layered accessory, the layered accessory isn't attached directly to the attachment, but it does reference the associated attachment point during ragdoll and dismemberment animations.
## Creation process

When designing a dynamic head in [Blender](https://www.blender.org/) or [Maya](https://www.autodesk.com/products/maya/overview), you must export all of the avatar components in a single `.fbx` or `.gltf` for import into Studio. Since 3D creation isn't a linear process and always requires reiteration and testing, the process of creating a dynamic head can differ between individuals and various creation workflows. Some choose to modify a rigged character model to meet Roblox's [dynamic head specifications](/docs/en-us/avatar/specifications.md), while others prefer to create one from scratch.

In general, the creation process follows the following workflow:

_ Dynamic Head Workflow_

> **Warning:** Ensure that all assets you create follow Roblox's [Community Standards](https://en.help.roblox.com/hc/en-us/articles/203313410-Roblox-Community-Standards) and any applicable [Marketplace policies](/docs/en-us/marketplace/marketplace-policy.md).
## Resources

There are a variety of resources available for creators of all backgrounds to get started with dynamic head creation. Review the following table for specific topics and resources:

| Topic | Resources |
| --- | --- |
| Tutorials | [Basic dynamic head creation tutorial](/docs/en-us/art/characters/facial-animation/create-basic-heads.md)<br><br>[Basic facial accessory creation tutorial](/docs/en-us/art/characters/facial-animation/create-face-accessories.md) |
| Reference files | [Avatar references and project files](/docs/en-us/character-bodies/project-files.md)<br><br>[Example mesh/model objects](/docs/en-us/art/modeling/project-files.md)<br><br>[Dynamic head caging best practices](/docs/en-us/dynamic-heads/caging-best-practices.md)<br><br>[FACS pose references](/docs/en-us/dynamic-heads/facs-poses-reference.md) |
| Technical specs | [Dynamic head specifications](/docs/en-us/avatar/specifications.md)<br><br>[General mesh specifications](/docs/en-us/art/modeling/specifications.md)<br><br>[Marketplace policy](/docs/en-us/marketplace/marketplace-policy.md) |
| Cosmetic creation | [Accessories overview](/docs/en-us/rigid-accessories.md)<br><br>[Creating face accessories](/docs/en-us/art/characters/facial-animation/create-face-accessories.md)<br><br>[Accessory Fitting Tool](/docs/en-us/accessory-fitting-tool.md)<br><br>[Accessory specifications](/docs/en-us/rigid-accessories/specifications.md)<br><br>[Marketplace requirements](/docs/en-us/marketplace/marketplace-policy.md) |
| Texturing | [PBR textures](/docs/en-us/art/modeling/surface-appearance.md) |
| Rigging and skinning | [Rigging and skinning overview](/docs/en-us/art/modeling/rigging.md)<br><br>[Humanoid rig requirements](/docs/en-us/character-bodies/specifications.md#rigging)<br><br>[Rigging facial bones](/docs/en-us/art/characters/facial-animation/create-basic-heads.md#rig-and-skin-the-head)<br><br>[Skinning facial bones](/docs/en-us/art/characters/facial-animation/create-basic-heads.md#skin-joints)<br><br>[Automatic Skinning Transfer](/docs/en-us/automatic-skinning-transfer.md) |
| Animation | [Animate dynamic heads](/docs/en-us/art/characters/facial-animation/animate-heads.md) |
| Testing and validation | [Test dynamic heads](/docs/en-us/avatar/test.md)<br><br>[Validation process](/docs/en-us/avatar/validate.md) |
| Publishing and Marketplace | [Uploading to Marketplace](/docs/en-us/marketplace/publish-to-marketplace.md)<br><br>[Marketplace policy](/docs/en-us/marketplace/marketplace-policy.md)<br><br>[Fees and commissions](/docs/en-us/marketplace/marketplace-fees-and-commissions.md) |
</document>

<document url="/docs/en-us/avatar/dynamic-heads/specifications.md" title="Dynamic head specifications">
