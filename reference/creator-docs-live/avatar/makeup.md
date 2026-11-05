---
title: "Makeup"
url: /docs/en-us/avatar/makeup
last_updated: 2026-11-05T19:15:48Z
description: "Makeup is a cosmetic look made up of multiple facial textures and optional eyebrow and eyelashes."
---

# Makeup

**Makeup** is a cosmetic item that you can apply to a face of an avatar or non-playable character for additional creative expression, such as traditional makeup art (e.g., eyeshadow, lipstick, and blush), face paint, battle markings, and camouflage.

Makeup is made up of multiple specialized texture layers baked into a `Class.Decal` object, and each texture layer contains a unique makeup component like the lips or eyes region. Players can purchase makeup as a set on the [Marketplace](https://www.roblox.com/catalog) and apply it as a complete cohesive look, or swap out individual makeup components for others that match their own avatar's style.

> **Info:** This guide covers authoring makeup assets in Studio. To let players create and purchase makeup directly within your experience at runtime, see [In-experience creation for makeup](/docs/en-us/in-experience-creation-makeup.md).

_Complete look_

_Eyes texture layer_

_Lip texture layer_

_Face texture layer_

This guide provides several [makeup templates](#resources) that you can use within your creation process, such as:

- Template textures that you can use in 2D editing software to author makeup.
- Template heads that you can use to view and test your makeup before export.
- Reference game you can use to import and test your makeup assets on characters with different skin tones and body types.

You can either use these templates as a pure reference to see how everything works, or you can use all of them at each step of the suggested creation process.

_Reference template render_

_Reference template data model_

## Makeup components

You can apply textures to three primary regions of the face: the eyes region, lips region, and face region. Each region has overlapping surfaces with other regions to allow for seamless, continuous looks between makeup components.

_Eyes region_

_Lips region_

_Face region_

In addition, you can include eyebrows and eyelashes with your makeup creations. Eyebrows and eyelashes are `Class.Model` objects that contain `Class.MeshPart` objects with skinning and caging data. This allows them to animate properly as the character's face changes expressions.

_Eyebrow and eyelash mesh objects_

_Eyebrow and eyelash data model_

When you import your makeup creation from your favorite third-party modeling software into the [reference game](#reference-game), Studio automatically detects mesh names, then generates the necessary `Class.Decal` objects under the imported model. You can then quickly apply your makeup `Class.Decal` objects and accessories by dragging them from the imported reference head into a character's **Makeup** or **Accessories** folder.

_The imported model contains your makeup decals and face accessories_

_Your makeup displays at runtime when you drag your makeup assets into the correct folders_

> **Info:** Makeup assets that you create for the [Marketplace](https://www.roblox.com/catalog) can include up to 6 total `Class.Decal` objects, comprised of any combination of regions.
## Resources

The following are downloadable resources you can use within the creation process:

- See [Template textures](#template-textures) for image and project files you can use in 2D editing software like GIMP or Photoshop.
- See [Template heads](#template-heads) for required 3D models you can use to view and test your makeup assets.
- See [Reference game](#reference-game) to import and test your makeup assets into Studio

> **Info:** For resources that include two templates, in almost every case **it's recommended to use the mesh template** to create makeup because: - It's easier and more intuitive to use because it mimics applying makeup in the real world. - It contains a higher-fidelity mesh and UVs with minimal distortion.
>
> Some creators prefer using the cage template because there is only one transfer when projecting the texture, while there are two transfers before projecting the texture for the mesh template. This can result in makeup transferring more accurately with less artifacts.
> **Warning:** Be sure to review your options **before** starting to create makeup because you cannot start with one template, then transfer your makeup to the other.
### Template textures

When you are finished making changes to any of the following template texture images:

1. Export your new textures.** Exporting from Photoshop**
  > **Info:** The video presenter uses **File** > **Export** > **Layers to Files** to export each layer as its own `.png` file.** Exporting from Substance Painter**** Exporting from Procreate** To export textures from Procreate:
  1. Navigate to the **Layers** pane, then hide everything but your first makeup component layer, such as your eyes, lips, or face layer.
  2. With your makeup component layer active, navigate to the **Actions** menu > **Share** tab > **Share Textures - PNG** to save all of your makeup component's textures to a location on your device.
  3. Delete all of the head, eyebrows, and eyelash textures.
    1. Open the location where you saved all of your makeup component's textures.
    2. Delete everything except for the following PBR textures:
      - `TransferTarget_FullHead_Mat-Color`
      - `TransferTarget_FullHead_Mat-Metallic`
      - `TransferTarget_FullHead_Mat-Roughness`
  4. Replace your makeup component's `TransferTarget_FullHead_Mat-Color` layer with a version that will export transparency in the output texture.
    1. Copy your active makeup component layer.
    2. Navigate to the **Gallery** > **Plus** icon > **Clipboard**. A new Procreate file displays with your makeup component layer.
    3. In the **Layers** pane, disable the **Background color** layer. Your makeup component displays without a background.
    4. With your makeup component layer active, navigate to the **Actions** menu > **Share** tab > **Share Image - PNG**.
    5. In the file browser, navigate to the location on your device with all of your makeup component's textures, then save/override the `TransferTarget_FullHead_Mat-Color` texture.
  5. Rename your makeup component's PBR textures appropriately so that you can easily reference each makeup component's PBR data when you reassign your textures in Blender or Maya. For example, if you are exporting texture maps for lips:
    - `Lips-Color`
    - `Lips-Metallic`
    - `Lips-Roughness`
  6. Repeat this process for every makeup component you want to import for your makeup look.
2. [Reassign the preset textures](/docs/en-us/avatar/reassign-textures.md) in a [template head](#template-heads) with your new textures.
3. [Import the reference head](/docs/en-us/avatar/import.md) with your new textures into Studio.

Photoshop / GIMP texture images

A comprehensive `.zip` folder with realistic texture images for use in Photoshop or your preferred image editor.

[Mesh Template](../../assets/makeup/resources/Photoshop-Gimp-Realistic-Mesh.zip)

[Cage Template](../../assets/makeup/resources/Photoshop-Gimp-Realistic-Cage.zip)

Substance Painter files

A comprehensive `.zip` folder with realistic texture files for use in Substance Painter, an industry-standard PBR authoring software.

[Mesh Template](../../assets/makeup/resources/SubstancePainter-Realistic-Mesh.zip)

[Cage Template](../../assets/makeup/resources/SubstancePainter-Realistic-Cage.zip)

Procreate texture images

A comprehensive `.zip` folder with realistic texture images for use in Procreate.

[Mesh Template](../../assets/makeup/resources/Procreate-Realistic-Mesh.zip)

[Cage Template](../../assets/makeup/resources/Procreate-Realistic-Cage.zip)

Photoshop / GIMP texture images

A comprehensive `.zip` folder with blocky texture images for use in Photoshop or your preferred image editor.

[Mesh Template](../../assets/makeup/resources/Photoshop-Gimp-Blocky-Mesh.zip)

Substance Painter files

A comprehensive `.zip` folder with blocky texture files for use in Substance Painter, an industry-standard PBR authoring software.

[Mesh Template](../../assets/makeup/resources/SubstancePainter-Blocky-Mesh.zip)

Procreate texture images

A comprehensive `.zip` folder with blocky texture images for use in Procreate.

[Mesh Template](../../assets/makeup/resources/Procreate-Blocky-Mesh.zip)

### Template heads

Each template head includes:

- Target head mesh object or head cage mesh object
- Eye, lip, and multiple face region mesh objects, fully linked to reference PBR textures
- Eyebrows and eyelash mesh objects

> **Info:** The Blender and Maya templates also include a facial region reference `.png` file that you can use to reference how your makeup assets fit into the eye, lips, and face/cheek regions.

Blender template reference files

A comprehensive `.zip` folder of Blender assets, including multiple realistic reference heads pre-configured for testing in the Makeup test place or for authoring your own makeup.

[Mesh Template](../../assets/makeup/resources/Blender-Realistic-Mesh.zip)

[Cage Template](../../assets/makeup/resources/Blender-Realistic-Cage.zip)

Maya template reference files

A comprehensive `.zip` folder of Maya assets, including multiple realistic reference heads pre-configured for testing in the Makeup test place or for authoring your own makeup.

[Mesh Template](../../assets/makeup/resources/Maya-Realistic-Mesh.zip)

[Cage Template](../../assets/makeup/resources/Maya-Realistic-Cage.zip)

FBX / GLTF template reference files

A comprehensive `.zip` folder of `.fbx` and `.gltf` assets, including realistic heads with various example makeup looks that are ready to be implemented into Studio for testing purposes.

[Mesh Template](../../assets/makeup/resources/FBX-GLTF-Realistic-Mesh.zip)

[Cage Template](../../assets/makeup/resources/FBX-GLTF-Realistic-Cage.zip)

Blender template reference files

A comprehensive `.zip` folder of Blender assets, including multiple blocky reference heads pre-configured for testing in the Makeup test place or for authoring your own makeup.

[Mesh Template](../../assets/makeup/resources/Blender-Blocky-Mesh.zip)

Maya template reference files

A comprehensive `.zip` folder of Maya assets, including multiple blocky reference heads pre-configured for testing in the Makeup test place or for authoring your own makeup.

[Mesh Template](../../assets/makeup/resources/Maya-Blocky-Mesh.zip)

FBX / GLTF template reference files

A comprehensive `.zip` folder of `.fbx` and `.gltf` assets, including blocky heads with various example makeup looks that are ready to be implemented into Studio for testing purposes.

[Mesh Template](../../assets/makeup/resources/FBX-GLTF-Blocky-Mesh.zip)

### Reference game

Reference place file (download)

At this time, you can only test makeup on the downloadable placefile.

In Github, select the download icon on the right-side to download the `MakeupBeta.zip` file.

[Github link](https://github.com/Roblox/avatar/blob/main/Makeup/MakeupBeta.zip)

## Creation process

> **Warning:** This process assumes that you are proficient in 3D modeling software, such as Blender or Maya, and that you understand how to update, replace, export, save, and alter materials within your modeling tool and any additional texturing software or plugins.

_Download the 3D reference template head and texture templates applicable to your workflow._

_Modify the texture images in the tools of your choice._

_In Blender or Maya, replace the textures in the template with your new textures and export._

While you can easily swap `Class.Decal` objects in Studio to make a quick change to a character's makeup, the following instruction is best practice for implementing PBR-based textures into Roblox makeup at scale. This process requires:

- The [Makeup test place and template files](#resources)
- A 3D modeling tool such as [Blender](https://www.blender.org) or [Maya](https://www.autodesk.com/products/maya/overview)
- Any PBR texturing software, such as [Substance Painter](https://www.adobe.com/products/substance3d/apps/painter.html), [Materialize](http://boundingboxsoftware.com/materialize/index.php), or plugins like [Ucupaint](https://extensions.blender.org/add-ons/ucupaint/) (Blender).

As always with 3D art and creation workflows, there are many ways to achieve a specific goal, and the makeup and PBR publishing flow is no exception. It's recommended to try the workflow in this guide first, then adjust as necessary for your own creation requirements:

1. Download a [reference template head](#resources) and open it in the general modeling software of your choice.
2. Using your texturing tools or image editing software, modify the texture images associated with the different regions: `TransferTexture_Eyes`, `TransferTexture_Face`, or `TransferTexture_Lips`.
3. When you've created your new texture images, use Blender or Maya to reassign the existing file textures in the template. For more information, see [Reassign textures](/docs/en-us/avatar/reassign-textures.md).
4. Review [Face caging best practices](/docs/en-us/avatar/dynamic-heads/caging-best-practices.md) for guidance on how to adjust face cages so that your makeup displays correctly for your use case.
5. Export the entire template file as a `.fbx` or `.gltf`. All 3D modeling [export requirements](/docs/en-us/art/modeling/export-requirements.md) apply, but there are a few makeup-specific settings you must configure:
  - If you are using Blender,
    1. In the export file browser window, navigate to the **Include** section, then enable the **Custom Properties** toggle for makeup UV data transfer purposes.
    2. In the **Armature** section, enable **Only Deform Bones** to ensure your export file includes skinning data for eyebrows and eyelashes._All necessary Blender export settings for makeup_
  - If you are using Maya, in the export file browser window, navigate to the **Deformed Models** section, then enable the **Skins** toggle to ensure your export file includes skinning data for eyebrows and eyelashes.
6. [Import](/docs/en-us/avatar/import.md) the template file into Studio. Studio automatically detects your mesh object names and associated textures, and generates `Decal` objects.
7. Apply any makeup decals or eyebrow and eyelash accessories to characters in the test place by dropping makeup assets in the appropriate character's `Makeup` or `Accessories` folder.
8. Click the **Play** button, then navigate to the character with new makeup assets to preview.
</document>

<document url="/docs/en-us/avatar/makeup/reassign-textures.md" title="Reassign textures">
