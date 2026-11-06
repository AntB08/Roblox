## Wavelet Decompose

 Filters
 Enhance
 Wavelet-decompose

 Wavelet-decompose

## Overview

 Explanations are mostly inspired from the Pat David's tutorials 
 and .

## Example for Wavelet decompose filter

Original image

Wavelet Decompose applied. Only scale 2 is 
 made visible in the layer group.

 This filter decomposes the active layer or selection into several layers,
 named scales, each of them containing a particular set of
 details. The finest details are in the first layer, each layer below it
 has less details until you get to the last one, at bottom. This last layer
 is called residual and holds what is left after all detail
 layers have been removed; it represents the global contrast and colors of
 the image.

 Each of the scale layers are set to be combined using the Grain Merge
 layer mode. This means that pixels that have a 50% value will not affect
 the final result. So, painting a wavelet scale with neutral gray
 (R:50% G:50% B:50%) will erase details.

 Note that for images using integer
 precision, the
 legacy grain merge
 mode is used. This avoids imperfect reconstruction of the image when using
 integer precision. When using floating point precision, the regular
 grain merge mode is used.

 Wavelet-decompose is a wonderful filter for skin smoothing and
 retouching, removing blemishes, wrinkles, or spots from your photos. It
 can also be used for sharpening and local contrast enhancement and for
 removing stains, colors, or tones. All this is well explained in the
 tutorials mentioned above.

 If the image is in indexed mode, this menu entry is disabled.

## Activating the Filter

 This filter is found in the main menu under

 Filters
 Enhance
 Wavelet decompose
 .

## Options

## Wavelet decompose options

 Scales

 Default scales number is 5. You can increase it to increase
 scale fineness.

 Create a layer group to store the decomposition

 Layer groups are treated in .

 Add a layer mask to each scale layer

 Layer masks are treated in .