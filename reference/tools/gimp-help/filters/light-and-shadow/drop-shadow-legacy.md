## Drop Shadow (legacy)

 Filters
 Light and Shadow
 Drop Shadow (legacy)

 Drop Shadow (legacy)

## Overview

## Example for the Drop Shadow (legacy) filter

Original image

 Drop Shadow (legacy) applied
 (white background layer added manually)

 This filter adds a drop-shadow to the current selection or to the image
 if there's no active selection. Optional the filter resizes the image if
 that's necessary for displaying the shadow.

 You may choose the color, position, and size of the shadow.

 Please note that the filter does not add a background layer to make the
 shadow visible. The shadow's background is transparent. The white
 background in the above example has not been created by the filter,
 instead it has been added later to let you see the shadow.

 If the image is in indexed mode, this menu entry is disabled.

## Activating the Filter

 This filter is found in the main menu under

 Filters
 Light and Shadow
 Drop Shadow (legacy)…
 .

## Options

## Drop Shadow (legacy) filter options

 Offset X
 Offset Y

 The layer containing the drop shadow will be moved horizontally
 by X pixels, vertically by Y pixels. So, X and Y offset
 determine where the shadow will be placed in relation to the
 image. High values make the imaginary source of light look like
 it's far away in horizontal or vertical direction, and low
 values will make it look closer to the image.

 The offsets may be negative, leading to a shadow on the left of
 the selection if offset X < 0, or above the selection if offset
 Y < 0.

 If there's no active selection, you must have Allow
 resizing enabled to see any effect.

 Blur radius

 After creating the shadow, a
 Gaussian blur with the
 specified radius is applied to the shadow layer, resulting in the
 realistic appearance of the drop shadow. It may be necessary to
 enable Allow resizing, since blurring extends
 the shadow.

 Color

 The shadow may have any color. Just click on the button, and
 select a color when the color selector pops up.

## Drop Shadow color example

 Opacity

 The shadow's opacity is just the opacity of the new layer
 containing the shadow (see
 ). It defaults to 80%, but
 you may select any other value from 0 (full transparency) to 100
 (full opacity) here. After applying the filter to an image you can
 change the opacity in the layers
 dialog.

 Allow resizing

 If enabled, the filter will resize the image if that is needed to
 make place for the shadow. The new size depends on the size of the
 selection, the blur radius, and the shadow offsets.