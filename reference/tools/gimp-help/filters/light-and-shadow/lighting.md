## Lighting Effects

 Filters
 Light and Shadow
 Lighting effects

 Lighting effects

## Overview

## The same image, before and after applying Lighting filter

Original image

Filter applied

 This filter simulates the effect you get when you light up a wall with
 a spot. It doesn't produce any drop shadows and, of course, doesn't
 reveal any new details in dark zones.

 If the image is in grayscale mode or indexed mode, this menu entry
 is disabled.

## Activating the Filter

 This filter is found in the main menu under

 Filters
 Light and Shadow
 Lighting Effects…
 .

## Options

## Lighting filter options

 Preview

 When Interactive is checked, parameter
 setting results are interactively displayed in preview without
 modifying the image until you click on OK
 button.

 If Interactive is not checked, changes are
 displayed in preview only when you click on the
 Update button.
 This option is useful with a slow computer.

 Any other options are organized in tabs:

## General Options

## 
 Lighting filter options (General Options)

 Transparent background

 Makes destination image transparent when bumpmap height
 is zero (height is zero in black areas of the bumpmapped
 image).

 Create new image

 Creates a new image when applying filter.

 Antialiasing

 Enabling this setting allows you to remove or reduce the
 aliasing effect that can show up on borders.

 For more information, see
 Anti-aliasing in
 the Glossary.

 Distance

 You can specify the distance of the light source from the
 center of the image with this slider. The range of values
 is from 0.0 to 2.0.

## Light Settings

## 
 Lighting filter options (Light Settings)

 In this tab, you can set light parameters. With
 Light 1 to
 Light 6 you can create six light sources
 and work on each of them separately.

 Type

 The filter provides several light types in
 a drop-down list:

 None

 This deletes the light source (light may persist).

 Directional

 The blue point is linked to preview center by a line which
 indicates the direction of light.

 Point

 Displays a blue point at center of preview. You can click
 and drag it to move light all over the preview.

 Spot

 Displays a blue point that cannot be moved. This light
 has a fixed direction.

 Color

 When you click on the color swatch, you bring a dialog up
 where you can select the light source color.

 Intensity

 With this option, you can set light intensity.

 Position

 Determines the light point
 position according to three coordinates: X coordinate for
 horizontal position, Y for vertical position, Z for source
 distance (the light darkens when distance increases). Values
 are from -1 to +1.

 Direction

 This option should allow you to fix the light direction in
 its three X, Y
 and Z coordinates.

 Isolate

 With this option, you can decide whether all light sources
 must appear in the Preview, or only the source you are
 working on.

 Lighting presets

 You can save your settings with the Save
 and get them back later with the
 Open.

## Material Properties

## 
 Lighting filter options (Material Properties)

 These options don't concern light itself, but light reflected by
 objects.

 Small spheres, on both ends of the input boxes, represent the
 action of every option, from its minimum (on the left) to its
 maximum (on the right). Help pop ups are more useful.

 Ambient intensity

 This option, also known as glowing, controls the amount of the
 original color to show where no direct light falls.

 Diffuse intensity

 This option, also known as brightness, controls the intensity of
 the original color to show when hit directly by a light source.

 Diffuse reflectivity

 This option controls how intense the light from the original
 color will be reflected.

 Specular reflectivity

 This option controls how intense the highlight will be.

 Highlight

 This option adjusts the polish or highlight. Higher values make
 the highlight more focused.

 Metallic

 When this option is checked, surfaces look metallic.

## Bump Map

## 
 Lighting filter options (Bump Map)

 In this tab, you can set filter options that give relief to the
 image. See .

 Enable bump mapping

 With this option, bright parts of the image will appear
 raised and dark parts will appear depressed. The aspect
 depends on the light source position.

 Bump map image

 Select a grayscale image to use as a bump map.
 See the Bump Map
 filter for more information.

 Curve

 This option defines the method that will be used when applying
 the bump map; that is, the bump height is a function of the
 specified curve.
 Four curve types are available:
 Linear,
 Logarithmic,
 Sinusoidal and
 Spherical.

 Maximum height

 This is the maximum height of bumps.

## Environment Map

## 
 Lighting filter options (Environment Map)

 Enable environment mapping

 When you check this box, the following option is enabled:

 Environment map image

 Select a RGB image to be used as environment map. Please note that
 for this option to work you should load another image with
 GIMP before using it.

 An example can be found at
 .