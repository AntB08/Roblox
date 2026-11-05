---
title: "Custom 3D assets"
url: /docs/en-us/art/modeling
last_updated: 2026-11-05T19:15:47Z
description: "External modeling is the use of a third-party modeling software to create custom 3D assets."
---

# Custom 3D assets

Meshes are **custom 3D assets** that let you personalize and stylize your game's environment and characters. Unlike parts, which you can directly create in Studio, you need to use a third-party modeling application like [Blender](https://www.blender.org) or [Maya](https://www.autodesk.com/products/maya/overview) to design and model meshes, then import them into Studio. Studio represents imported meshes as `Class.MeshPart` objects, descendants of the `Class.BasePart` class.

> **Info:** Many 3D assets are made up of several meshes that are parented to a single `Class.Model` object.

Meshes typically fall into one of three types of application in games:

- Meshes for **decorating your game's environment**, such as plants, buildings, and vehicles.
- Meshes for **individual body parts** for avatars or non-player characters (NPCs).
- Meshes for **cosmetic accessories** that characters can equip and wear, such as clothing, props, and weapons.

Each mesh type must meet specifications according to how you are going to use the mesh on the platform. For example, while all meshes must meet general mesh specifications, meshes for characters must also meet character specifications that account for rigging and skinning data. For a full list of specifications for different types of meshes, see [Resources](#resources).

In addition, if you meet certain account requirements, you can publish and sell collections of meshes that are parented to a single `Class.Model` object. For example, you can publish avatar-ready models on the Marketplace and earn a commission for each sale, or you can sell models on the Creator Store and earn 100% of net proceeds on each transaction.

> **Info:** For more information on monetizing meshes, see [Monetize avatar items](/docs/en-us/monetize-avatar.md) and [Creator Store - Distribute and sell assets](/docs/en-us/production/creator-store.md#distribute-and-sell-assets).

![A cluttered interior room with a candle in the forefront and spooky interior lighting from the Mystery of Duvall Drive game](../../assets/modeling/meshes/Mystery-of-Duvall-Example.png)_Use custom meshes and models to give your environments ambiance and depth_

![A floating alien creature in space, from the Beyond The Dark game](../../assets/modeling/meshes/Beyond-The-Dark-Example.png)_Design a custom character unique to your game_

![A Roblox avatar wearing a glossy puffy jacket and jeans](../../assets/modeling/surface-appearance/Layered-Clothing-Example.png)_Create custom accessories, clothing, and characters that anyone can wear and use_

## Supported 3D assets

Roblox supports many types of custom 3D assets, as long as they adhere to the [general mesh specifications](/docs/en-us/art/modeling/specifications.md). A basic custom 3D asset consists of at least one `Class.MeshPart` object and one texture:

![A plain white tree mesh without a texture](../../assets/art/Basic-Mesh-Example.png)_A `Class.MeshPart` object sets the shape and geometry of the 3D asset_

![Various color maps used to apply textures to the tree bark, and inner, middle, and outer leaves](../../assets/art/Basic-Texture-Example.png)_A texture image map applies a surface appearance and color_

![The tree mesh and the image maps combined to create a single tree](../../assets/art/Basic-Mesh-Combined-Example.png)_The mesh and texture combine to make a unique custom 3D asset_

Studio also supports custom 3D assets that include [rigging and skinning](#rigging-and-skinning) data, [PBR textures](#pbr-textures), and other [Studio-related objects](#studio-related-objects) like cage meshes and attachments. Many of these various components are required if you are creating avatar character models or accessories.

### Rigging and skinning

A **rigged mesh** is a `Class.MeshPart` object with an internal poseable skeleton rig and bone structure. Rigged meshes allow mesh surfaces to rotate and move where internal bone joints are placed within a model, such as a character's knee or elbow. Skinning a rigged mesh allows the mesh to bend organically, imitating the natural way joints would move in real life.

_Without skinning, the entire head mesh rotates on a single axis_

_With skinning, the head mesh bends naturally at the neck, and the bottom of the neck stays connected to the torso_

For more information on rigging and skinning, see [Rigging and skinning](/docs/en-us/art/modeling/rigging.md).

### PBR textures

**Physically-Based rendering** (PBR) textures allow you to represent realistic shading and lighting by using multiple types of texture images, or **maps**, on a single 3D asset. Combining multiple texture maps can more accurately simulate color, roughness, and reflectivity in any lighting environment, and can enhance the visual elements of your assets and environment.

![A realistic looking leafy bush with shadows and depth.](../../assets/modeling/surface-appearance/SurfaceAppearance-Example-1.jpg)![A realistic looking rock with moss on the top.](../../assets/modeling/surface-appearance/SurfaceAppearance-Example-3.jpg)

For more information on PBR textures, see [PBR textures](/docs/en-us/art/modeling/surface-appearance.md).

### Studio-related objects

Studio automatically converts certain types of objects found in 3D modeling files as specific workspace objects in the game. These are typically used when creating a character or accessory, and configuring these in your modeling software can sometimes be the primary way of correctly setting up these Studio objects.

The following objects are automatically created in Studio if they are detected by the 3D Importer:

- `Class.Attachment` - Created when Studio detects mesh objects that include `_Att` at the end of their name.
- `Class.WrapTarget` - Created when Studio detects mesh objects that include `_OuterCage` at the end of their name.
- `Class.WrapLayer` - Created when Studio detects a mesh object with `_InnerCage` and similarly named mesh object with `_OuterCage` at the end of their names.
- `Class.FaceControls` - Created when Studio detects an avatar character head and the appropriate facial animation data in the model.

For more information on how the `Class.WrapTarget` and `Class.WrapLayer` objects reshape and layer meshes, see [Cage meshes](/docs/en-us/art/modeling/cage-meshes.md).

## Resources

There are a variety of resources available for creators of all backgrounds to get started with custom 3D assets.

If you are interested in specific avatar creation topics, use the following table to find guides and resources that best match your needs:

| Topic | Resources |
| --- | --- |
| Reference files | [Example models, project kits, and templates](/docs/en-us/art/modeling/project-files.md) |
| Technical specs | [.FBX export settings](/docs/en-us/art/modeling/export-requirements.md)<br><br>[General mesh specifications](/docs/en-us/art/modeling/specifications.md)<br><br> [Avatar specifications](/docs/en-us/avatar/character-bodies/specifications.md)<br><br>[Accessory specifications](/docs/en-us/avatar/rigid-accessories.md)<br><br>[Marketplace policy](/docs/en-us/marketplace/marketplace-policy.md) |
| Bodies and clothing creation | [Accessories overview](/docs/en-us/avatar/rigid-accessories.md)<br><br>[Bodies overview](/docs/en-us/avatar/character-bodies.md)<br><br>[Face accessory creation](/docs/en-us/art/characters/facial-animation/create-face-accessories.md)<br><br>[Accessory Fitting Tool](/docs/en-us/avatar/accessory-fitting-tool.md)<br><br>[Accessory specifications](/docs/en-us/avatar/rigid-accessories/specifications.md)<br><br>[Marketplace requirements](/docs/en-us/marketplace/marketplace-policy.md) |
| Texturing | [Texture specifications](/docs/en-us/art/modeling/texture-specifications.md)<br><br>[PBR textures](/docs/en-us/art/modeling/surface-appearance.md) |
| Rigging and skinning | [Rigging and skinning overview](/docs/en-us/art/modeling/rigging.md)<br><br>[Basic mesh rigging](/docs/en-us/art/modeling/rig-a-simple-mesh.md) <br><br>[Facial bone rigging](/docs/en-us/art/characters/facial-animation/create-basic-heads.md#rig-and-skin-the-head)<br><br>[Facial bone skinning](/docs/en-us/art/characters/facial-animation/create-basic-heads.md#skin-joints)<br><br>[Avatar rigging requirements](/docs/en-us/avatar/character-bodies/specifications.md#rigging)<br><br>[Automatic skinning transfer](/docs/en-us/avatar/automatic-skinning-transfer.md) |
| Facial animation and live heads | [Basic head creation](/docs/en-us/art/characters/facial-animation/create-basic-heads.md)<br><br>[Face accessory creation](/docs/en-us/art/characters/facial-animation/create-face-accessories.md)<br><br>[FACS pose references](/docs/en-us/avatar/dynamic-heads/facs-poses-reference.md) |
| Testing and validation | [Calisthenics Tool](/docs/en-us/art/modeling/calisthenics-tool.md)<br><br>[Clothing Validation Tool](/docs/en-us/art/accessories/validation-tool.md) |
| Publishing and Marketplace | [Upload to Marketplace](/docs/en-us/marketplace/publish-to-marketplace.md)<br><br>[Marketplace policy](/docs/en-us/marketplace/marketplace-policy.md)<br><br>[Fees and commissions](/docs/en-us/marketplace/marketplace-fees-and-commissions.md) |
</document>

<document url="/docs/en-us/art/modeling/material-reference.md" title="Material references">
