## Layer masks

 Layer mask

 Masks
 Layer mask

## Add mask dialog

 Overview

 A transparency mask can be added to each layer, which defines what
 parts of the layer are transparent or opaque. We call this a layer
 mask. A layer mask has the same size and same number of pixels as
 the layer to which it is attached. Every pixel of the mask can then
 be coupled with a pixel at the same location in the layer. The mask
 is a set of pixels in grayscale. The pixels with a value 0 are black
 and give a full transparency to the coupled pixel in the layer.
 The pixels with the maximum value (either 1.0 or 255) are white and
 give full opacity to the coupled pixel in the layer.

 To create a layer mask start with a right click on the layer to call
 the context menu and select Add Layer Masks…
 in the menu. A dialog appears where you can initialize the content of
 the mask:

White (full opacity):
 the mask is white
 in the Layers dialog. So, all pixels of the layer are visible
 in the image window since painting the mask with white makes
 layer pixels fully visible. You will paint with black to make
 layer pixels transparent.

Black (full transparency): the mask is
 black in the Layers dialog. So, the layer is fully transparent
 since painting the mask with black makes layer pixels
 transparent. Painting with white will remove the mask and make
 layer pixels visible.

Layer's alpha channel: the mask is
 initialized according to the contents of the layer's alpha
 channel.

Transfer layer's alpha channel:
 Does the same thing as the previous option, except that it
 also resets the layer's alpha channel to full opacity.

Selection: the mask is initialized
 according to pixel values found in the current selection.

Grayscale copy of layer: the mask
 is initialized according to a grayscale representation of the
 pixel values of the layer.

Channel: The layer mask is initialized
 with a selection mask you have created before, stored in the
 Channels dialog.

Invert mask: This checkbox allows you to
 invert: black turns to white and white turns to black.

 When the mask is created, it appears as a thumbnail next to that of
 the layer itself. You can select the layer or the mask for editing by
 clicking on their respective thumbnails. The active item has a white
 border (which may not be clearly visible when you have a white mask).

 When working with masks, it is a good idea to keep the Layers Dialog
 prominently visible, because you can't see, by looking at the canvas,
 whether the layer or the mask is active.

 Pressing Alt (or
 CtrlAlt and
 clicking on the layer mask thumbnail) is equivalent to the
 Show Layer Mask
 command: the layer mask border turns to green. If you press
 Ctrl the border is red and the result is
 equivalent to the
 Disable Layer Mask
 command. To return to normal view repeat the last operation. These
 options are for greater convenience in your work.

 Layer Mask example

## A layer with layer mask

 Original image.

 This image has a background layer with a flower and another
 blue layer, fully opaque. A white layer mask has been added to
 the blue layer. The blue layer remains
 visible because a white mask makes layer pixels visible.

## Painting the layer mask

 Foreground color set to black; Resulting image.

 The layer mask is active. Painting with black makes the layer
 transparent: the underlying layer becomes visible.