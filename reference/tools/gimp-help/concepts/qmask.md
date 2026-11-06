## The Quick Mask

 Quick Mask

## Image with Quick Mask enabled

 The usual selection tools
 involve tracing an outline around an area of interest, which does not
 work well for some complex selections. The Quick Mask, however, allows
 you to paint a selection instead of just tracing its outline.

## Overview

 Normally, a selection in GIMP is represented by
 marching ants
 that trace the selection outline, but there
 may be more to a selection than the marching ants show. A
 GIMP selection is actually a full-fledged grayscale
 channel, covering the image, with pixel values ranging from 0
 (unselected) to 255 (fully selected). The marching ants are drawn along
 a contour of half-selected pixels. Thus, what the marching ants show you
 as either inside or outside the boundary is really just a slice through
 a continuum.

 The Quick Mask is GIMP's way of showing the full
 structure of the selection.
 Quick Mask also provides the ability to interact with the
 selection in more powerful ways.
 Click the bottom-left

 button in the image window to
 toggle Quick Mask on and off. The button switches between Quick Mask
 mode, and marching ants mode.
 You can also use

 Select
 Toggle Quick Mask
 , or
 ShiftQ,
 to toggle between Quick Mask and marching ants mode.

 In Quick Mask mode, the selection is shown as a
 translucent screen overlying the image, whose transparency at each pixel
 indicates the degree to which that pixel is selected. By default the
 mask is shown in red, but you can change this if another mask color
 is more convenient. The less a pixel is selected, the more it is
 obscured by the mask. Fully selected pixels are shown completely clear.

 In Quick Mask mode, many image manipulations act on the
 selection channel rather than the image itself. This includes, in
 particular, paint tools. Painting with white selects pixels, and
 painting with black unselects pixels.
 You can use any of the paint tools, as well as the bucket
 fill and gradient fill tools, in this way. Advanced users of
 GIMP learn that painting the selection
 is the easiest and most effective way to delicately manipulate the
 image.

 To save a Quick Mask selection to a new channel; Make
 sure that there is a selection and that Quick Mask mode is not
 active in the image window. Use

 Select
 Save to Channel

 to create a new channel in the Channels dialog called
 Selection Mask copy (repeating this command
 creates …copy#1, …copy#2 and
 so on).

 In Quick Mask mode, Cut and Paste act on the selection rather
 than the image. You can sometimes make use of this as the most
 convenient way of transferring a selection from one image to another.

 You can learn more on
 Selection masks in the
 section dedicated to the Channels dialog.

## Properties

 There are two Quick Mask properties you can change by right-clicking
 on the Quick Mask button.

 Normally the Quick Mask shows unselected areas fogged over
 and selected areas in clear, but you can
 reverse this by choosing Mask Selected Areas instead
 of the default Mask Unselected Areas.

 Use Configure Color and Opacity… to open
 a dialog that allows you to set these to values other
 than the defaults, which are red at 50% opacity.