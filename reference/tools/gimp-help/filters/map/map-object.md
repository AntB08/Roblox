## Map Object

 Filters
 Map
 Map Object

 Map Object

## Overview

## 
 The Map Object filter applied to a photograph

Original image

Filter applied

 This filter maps a picture to an object (plane, sphere, box or
 cylinder).

 If the image is in grayscale mode or indexed mode, this menu entry
 is disabled.

## Activating the Filter

 This filter is found in the main menu under

 Filters
 Map
 Map Object…
 .

## Options

## Preview

This preview has several possibilities:

 Preview!

 Preview is automatic for some options but you will have to press
 this button to update Preview after modifying many other
 parameters.

 When mouse pointer is on Preview and the Light tab is selected,
 it takes the form of a small hand to grab the blue
 point which marks light source origin and to
 displace it.
 This blue point may not be visible if light source has negative
 X and Y settings in the Light tab.

 Zoom out
 Zoom in

 Zoom buttons allow you to enlarge or to reduce image in Preview.
 Their action is limited, but may be useful in case of a large
 image.

 Show wireframe

 Puts a grid over the preview to make displacements and rotations
 more easy. Works well on a plan.

 Update preview live

 To have preview working as usual.

## General Options

## Map Object options (General)

 Map to

 This drop-down list allows you to select the object the image
 will be mapped on. It can be a Plane, a
 Sphere, a Box or a
 Cylinder.

 Transparent background

 This option makes image transparent around the object. If not
 set, the background is filled with the current background color.

 Tile source image

 When moving Plane object and displacing it with Orientation tab
 options, a part of the image turns empty. By checking the
 Tile source image, source image copies
 will fill this empty space in. This option seems not to work
 with the other objects.

 This option works with Plane only.

 Create new image

 When this option is checked, a new image is created with the
 result of the filter, preserving the original image.

 Create new layer

 When this option is checked, a new layer is created with the
 result of the filter, leaving the original layer unchanged.
 This has no effect if Create new image is
 also checked.

 Antialiasing

 Enabling this setting allows you to remove or reduce the
 aliasing effect that can show up on borders. When checked,
 this enables the following settings:

 Depth

 Defines the anti-aliasing quality. A higher value gives
 better quality at the cost of being slower.

 Threshold

 Defines anti-aliasing limits. Anti-aliasing stops when the
 value difference between pixels becomes lower than the
 value set here.

## Light

## Map Object options (Light)

 Light Settings

 Light source type

 You can select among
 Point light, Directional
 light and No light.

 Light source color

 Press this button to open the Color Selector dialog.

 Position

 If Point light is selected, you can control there
 light source Position (the blue point),
 according to X, Y and Z coordinates.

 If Directional light is selected, these X, Y and
 Z parameters control the Direction vector
 (effect is not evident).

## Viewpoint

## Map Object options (Viewpoint)

 Viewpoint Position

When Light Source Type is set
 to "Point Light", changing the X, Y, and Z values moves
 the "viewer" closer to or further from the object in those
 directions.

Note that this will not visually affect images set
 to "Plane" in the Map To field.

 First Axis
 Second Axis

When Map To is set
 to "Plane", changing the X, Y, and Z values
 simulates the effect of tilting the plane on
 the Y and Z axes. This impacts how the Material
 tab settings affect the render.

## Orientation

## Map Object options (Orientation)

 Position

 These three sliders and their input boxes allows you to vary
 object position in image, according to the X, Y, Z coordinates
 of the object upper left corner.

 Rotation

 These three sliders make the object rotate around X, Y, Z axes
 respectively.

## Material

## Map Object options (Material)

 Intensity Levels

 Ambient

 Amount of color to show where no light falls directly.

 Diffuse

 Intensity of original color when lit by a light source.

 Reflectivity

 Diffuse

 Higher values make object reflect more light (looks
 brighter).

 Specular

 Controls how intense the highlights will be.

 Highlight

 Higher values make the highlights more focused.

## Sphere

 This tab appears only when you select the Sphere object.

## Map Object options (Sphere)

 Size

 Radius

 The radius ratio in comparison to the image size.

## Box

 This tab appears only when you select the Box object.

## Map Object options (Box)

 Map Images to Box Faces

 Select an image
 for every face of the box. These images must be present on your
 screen when you call the Map Object filter.

 Scale X
 Scale Y
 Scale Z

 These X, Y, Z sliders allow you to change the size of
 every X, Y, Z dimension of the box.

## Cylinder

 This tab appears only when you select the Cylinder object.

## Map Object options (Cylinder)

 Images for the Cap Faces

 Select an image
 for every face of the cylinder. Images must be
 present on your screen when you call the Map Object filter.

 Size

 Radius

 This slider and its input boxes let you control the
 Cylinder diameter. Unfortunately, this setting works on the
 image mapped onto the cylinder and resamples this image to
 adapt it to the new cylinder size. It would be better to
 have the possibility of setting size cylinder before mapping
 so that we could map a whole image.

 Cylinder length

 Controls cylinder length.