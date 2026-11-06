## Xach-Effect

 Filters
 Light and Shadow
 Xach-Effect

 Xach-Effect

## Overview

## Example for the Xach-Effect filter

Original image

Xach-Effect applied

 This filter adds a subtle translucent 3D effect to the selected region
 or alpha channel. This 3D effect is achieved by

 Highlighting the selection: a new layer (Highlight)
 will be created above the active layer, filled with the highlight
 color. Then a layer mask will
 be added to that layer making the unmasked pixel partially
 transparent.

Highlight layer with layer mask

 Painting the selection's left and top edges with the highlight
 color: for that the Highlight layer will be extended
 by one pixel left and up. These small areas will be opaque.

 Creating a drop shadow
 at the bottom right side of the selection.

 You may vary these default settings, for example select different colors
 for highlight or shadow and change amount and directions of offsets.

 If the image is in indexed mode, this menu entry is disabled.

## Activating the Filter

 This filter is found in the main menu under

 Filters
 Light and Shadow
 Xach-Effect…
 .

## Options

 There are two groups of options, each controlling the highlight or the
 shadow, and a checkbox for the selection behaviour.

## Xach-Effect options

 Highlight X offset
 Highlight Y offset

 The selection's left and top edge are painted with the highlight
 color. The highlight offset is the size (width or height) of the
 respective area. If offset is less than 0 (this is the default),
 the left (X offset < 0) or top (Y offset < 0) area will be
 colored. If offset is greater than 0, the right (X offset > 0)
 or bottom (Y offset > 0) area will be painted.

 Highlight color

 This is the color used to highlight the selected area. It defaults
 to white, but clicking on the swatch button brings up a color
 selector and you may select any other color.

 Highlight opacity

 The selection will be covered by a partially transparent area
 filled with the highlight color. This option lets you set the
 level of transparency. Since a
 layer mask will be used,
 the value ranges from 0 (full transparency) to 255 (full opacity).

 The highlight opacity defaults to 66, which is equivalent to 26%.

 Drop shadow options

 These options work like the respective
 Drop Shadow options
 (without resizing). Briefly:

 Drop shadow color

 Click on the button to open a color selector.

 Drop shadow opacity

 The opacity (0% - 100%) of the layer containing the shadow.

 Drop shadow blur radius

 The radius used by the
 Gaussian blur filter,
 which will be applied to the shadow.

 Drop shadow X offset
 Drop shadow Y offset

 Direction and amount, by which the shadow will be moved from
 the selection.

 Keep selection

 If checked, the active selection will remain active when the
 filter has been applied.