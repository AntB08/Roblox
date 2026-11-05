---
title: "Character bodies"
url: /docs/en-us/avatar/character-bodies
last_updated: 2026-11-05T19:15:48Z
description: "All Roblox users are represented by an avatar character which can be customized with body parts, accessories, and clothes from the Marketplace or within games."
---

# Character bodies

**Character bodies** for avatars are models with technical components that work together to create a character that can interact with objects in the 3D space and wear cosmetics, clothing, and accessories. There are four main layers of the avatar body that structure how the character looks and moves on the platform:

- **Body parts & textures** that make up the character's visual appearance.
- **Rigging armature** that determines how the character moves.
- **Facial animation data** in the character's head that expresses the character's personality and emotions.
- **Cage meshes & attachments** that determine how the character attaches accessories and wears clothing.

While you can create each of these layers manually in third-party modeling tools like [Blender](https://www.blender.org/) or [Maya](https://www.autodesk.com/products/maya/overview), some have strict configuration requirements to meet Roblox's technical [character specifications](/docs/en-us/avatar/specifications.md) that guarantee your avatar behaves consistently from game to game. Before you create your first custom character body, it's recommended to:

1. Understand the [essential components](#character-body-components) of an avatar's character body and how they work together on the platform.
2. Review all [resources](#resources) that Roblox provides to standardize and expedite the [creation process](#creation-process), such as Blender and Maya project files, Studio tooling, and step-by-step guides.
3. Follow the [basic character creation tutorial](/docs/en-us/art/characters/creating.md) that uses Roblox templates in collaboration with common Blender modeling and texturing tools.

Once you have a custom character body model, you can import it into Studio and use the Avatar Setup tool to process your creation into an avatar asset that's ready to be sold on the [Marketplace](/docs/en-us/marketplace.md).

## Character body components

All character bodies for avatars are made up of several fundamental components that provide users the functionality and flexibility to interact with their world. Many of these components are never made visible to the user, but they enable powerful avatar features that enhance social and environmental interactions. When creating avatar characters, all of these components are typically created first in your modeling software and then converted to their appropriate Roblox Studio instance on import.

Each avatar character is made up of the following rendered and non-rendered components:

#### Rendered

_15 separate body part meshes make up the shape and contours of the character._

_Texture image maps apply a surface color and appearance to the character's skin._

#### Non-Rendered

_A rigging armature allows the body parts to properly connect with each other, driving movement, expressions, and animations._

_Facial animation data allows avatars to express virtually all types of facial expressions for chatting and socializing._

_Cage meshes define the surface where layered accessories can wrap and stretch over._

_Attachment points define where rigid accessories attach to a character._

### Body parts

_Each avatar character is made up of 15 separate mesh objects_

_These meshes must follow a standard naming convention_

An avatar's physical body geometry is made up of 15 separate mesh body parts that define the shape and contours of the character:

- Head
- Upper and lower torso
- Left upper arm, lower arm, and hand
- Right upper arm, lower arm, and hand
- Left upper leg, lower leg, and foot
- Right upper leg, lower leg, and foot

In Studio, these geometries are represented as `Class.MeshPart` objects and are nested under a single `Class.Model`.

### Textures

_Textures apply color and surface details to your character model._

_A texture image map's opacity can combine with the `Class.MeshPart.Color` to apply custom skin tones to characters._

Textures are image files that define the surface appearance of your character. You can create textures using a texture painting program or 3D modeling software. In Studio, you must import textures as image files and set them to `Class.MeshPart` objects by a child `Class.SurfaceAppearance` object or the mesh's `Class.MeshPart.TextureID|TextureID` property.

> **Warning:** When texturing parts of your character model's body, ensure that your character model includes a modesty layer over sensitive regions. See [Community Standards](https://en.help.roblox.com/hc/en-us/articles/203313410#safety) for more information on Roblox's policies.
### Rigging armature

_The rigging armature includes at least 16 bones, 1 for each body part and a root bone. Higher-fidelity rigs can include up to 37 additional bones._

_Bones must follow a specific hierarchy and naming convention_

Inside of the avatar's physical body is a non-rendered rigging armature that allows the character to articulate its limbs. Often referred to as joints or bones, a rigging armature includes skinning data that allows connections between limbs to bend organically, such as the character's knees and elbows.

[Standard avatar rigs](/docs/en-us/avatar/specifications.md#standard-r15-rigs) (R15) require 15 poseable joints to articulate the character's 15 body parts. However, if you want to create higher-fidelity characters with a greater level of realism, there are up to 37 additional optional joints for [advanced R15 rigs](/docs/en-us/avatar/specifications.md#advanced-r15-rigs) that you can create for articulated hands, shoulders, and spine movements.

In Studio, each joint of the rigging armature is represented by `Class.Bone` objects that connect the character's body part `Class.MeshPart` objects together. `Class.Bone` objects must follow a specific hierarchy and naming convention for the avatar to function properly in Studio and on the Marketplace. For more information, see [Rigging](/docs/en-us/avatar/specifications.md#rigging).

### Face animation data

_Each avatar character face is rigged and skinned to create various expressions_

_Each pose is mapped to a pose name within the Custom Properties (Extra Attributes in Maya) of the Head_Geo object_

_Each required face pose is saved as a keyframe in the animation timeline._

Facial animation data from either the character's rigging armature or facial joints allow avatars to express emotions with their eyes, mouth, and teeth. Each character includes facial joints, skinning data, animation timeline data, and mapped pose data that allows these expressions. In Studio, these facial animation elements are represented by a `Class.FaceControls` instance.

### Cage meshes

_Head and Upper Torso cage mesh objects (wireframe)_

_Cage objects must exist for each of the 15 body parts_

Cage meshes set the invisible outer boundary for layered accessories to stretch and fit over body parts, allowing clothes to fit over models of different shapes and sizes without you having to remodel the clothing item each time. In Studio, outer cage mesh objects are represented by a `Class.WrapTarget` instance.

If you are caging your own non-template character model, it's important to use one of Roblox's body cage [project files](/docs/en-us/avatar/resources.md#mannequin-models) to ensure you are using a Roblox standard cage mesh. Removing or adding vertices from this standard mesh can cause issues with clothing fit and import.

### Attachments

_Each character has common attachment points for equipping rigid cosmetics_

_Each avatar character must include their associated 19 attachment points_

Attachment points set the specific points where rigid accessories and in-game equippable objects attach to the character's body. These are not rendered on the platform, but they are represented visually as spheres in 3D modeling software when you use Roblox's **R15 Rig and Attachments** [project file](/docs/en-us/avatar/resources.md#project-files).

When you import a rig with these visual representations, the spheres are created as `Class.Attachment` objects using standardized names.

> **Info:** When users wear a layered accessory, the layered accessory isn't attached directly to the attachment, but it does reference the associated attachment point during ragdoll and dismemberment animations.
## Creation process

When designing a character body in [Blender](https://www.blender.org/) or [Maya](https://www.autodesk.com/products/maya/overview), you must export all of the avatar components in a single `.fbx` or `.gltf` for import into Studio. Since 3D creation isn't a linear process and always requires reiteration and testing, the process of creating an avatar character model can differ between individuals and various creation workflows.

In general, the creation process follows these typical workflows:

**Basic Creation with Templates**

Customize a [character body template](/docs/en-us/art/characters/creating.md) that already includes all the necessary components.

**Advanced Creation from Scratch**

Create characters from scratch, allowing full customization of the avatar character's components.

> **Warning:** Ensure that all assets you create follow Roblox's [Community Standards](https://en.help.roblox.com/hc/en-us/articles/203313410-Roblox-Community-Standards) and any applicable [Marketplace policies](/docs/en-us/marketplace/marketplace-policy.md).
## Resources

There are a variety of resources available for creators of all backgrounds to get started with character creation. Review the following table for specific topics and resources:

| Topic | Resources |
| --- | --- |
| Tutorials | [Basic character creation tutorial](/docs/en-us/art/characters/creating.md) |
| Reference files | [Avatar references and project files](/docs/en-us/avatar/project-files.md)<br><br>[Example mesh/model objects](/docs/en-us/art/modeling/project-files.md) |
| Technical specs | [.FBX export settings](/docs/en-us/avatar/export.md)<br><br>[Avatar specifications](/docs/en-us/avatar/specifications.md)<br><br>[General mesh specifications](/docs/en-us/art/modeling/specifications.md)<br><br>[Accessory specifications](/docs/en-us/rigid-accessories/specifications.md)<br><br>[Marketplace policy](/docs/en-us/marketplace/marketplace-policy.md) |
| Cosmetic creation | [Accessories overview](/docs/en-us/rigid-accessories.md)<br><br>[Creating face accessories](/docs/en-us/art/characters/facial-animation/create-face-accessories.md)<br><br>[Accessory Fitting Tool](/docs/en-us/accessory-fitting-tool.md)<br><br>[Accessory specifications](/docs/en-us/rigid-accessories/specifications.md)<br><br>[Marketplace requirements](/docs/en-us/marketplace/marketplace-policy.md) |
| Texturing | [Texturing requirements](/docs/en-us/art/modeling/texture-specifications.md)<br><br>[PBR textures](/docs/en-us/art/modeling/surface-appearance.md) |
| Rigging and skinning | [Rigging and skinning overview](/docs/en-us/art/modeling/rigging.md)<br><br>[Humanoid rig requirements](/docs/en-us/avatar/specifications.md#rigging)<br><br>[Rigging facial bones](/docs/en-us/art/characters/facial-animation/create-basic-heads.md#rig-and-skin-the-head)<br><br>[Automatic Skinning Transfer](/docs/en-us/automatic-skinning-transfer.md)<br><br>[Skinning facial bones](/docs/en-us/art/characters/facial-animation/create-basic-heads.md#skin-joints) |
| Facial animation and live heads | [Basic head creation](/docs/en-us/art/characters/facial-animation/create-basic-heads.md)<br><br>[Face accessory creation](/docs/en-us/art/characters/facial-animation/create-face-accessories.md)<br><br>[FACS pose references](/docs/en-us/dynamic-heads/facs-poses-reference.md) |
| Testing and validation | [Calisthenics Tool](/docs/en-us/art/modeling/calisthenics-tool.md)<br><br>[Clothing Validation Tool](/docs/en-us/art/accessories/validation-tool.md) |
| Publishing and Marketplace | [Uploading to Marketplace](/docs/en-us/marketplace/publish-to-marketplace.md)<br><br>[Marketplace policy](/docs/en-us/marketplace/marketplace-policy.md)<br><br>[Fees and commissions](/docs/en-us/marketplace/marketplace-fees-and-commissions.md) |
</document>

<document url="/docs/en-us/avatar/character-bodies/project-files.md" title="Character body reference files">
