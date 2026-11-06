## Long Shadow

 Filters
 Long Shadow

 Long Shadow

## Overview

 This GEGL-based filter
 simplifies creating long shadows in several visual styles.

 It is available if the selected layer holds an Alpha channel
 (see ).
 Otherwise, it is disabled.

## Activating the Filter

 This filter is found in the main menu under

 Filters
 Light and Shadow
 Long Shadow…
 .

## Options

## Long Shadow filter options

 Presets
 Input Type
 Clipping
 Blending Options
 Preview
 Merge filter
 Split view

 Style

 Original image.

 The layers of the image. The text layer was created via
 the "Layers to Image Size" function in the "Layer" menu.

 Finite is the default style. Other available
 styles are Infinite,
 Fading,
 and Fading (fixed length).

## Style option examples

 Finite (default)

 Infinite

 Fading

 Fading (fixed length); length = 30

 Angle

 Shadow angle, in degrees.

 Angle = 110°

 Length

 Shadow length, in pixels. Only available when
 Style is set to
 Finite or
 Fading (fixed length).

 Length = 30

 Midpoint

 Shadow fade midpoint. Only available when
 Style is set to
 Fading or
 Fading (fixed length).

 Color

 You can choose the color of the shadow here. Just click on the
 color swatch, and select a color when the color selector pops up,
 or use the eye-dropper to pick a color from the image.

 Composition

 The Output composition selects how the output of
 this filter will be determined. There are three choices:

 Shadow plus image will output both the
 input image and the created shadow. This is the default.

 Shadow only will output only the created
 shadow.

 Shadow minus image will output the
 created shadow but subtracts the area hidden by the image.

## Composition option examples

 Shadow only

 Shadow minus image