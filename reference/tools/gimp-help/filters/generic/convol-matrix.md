## Convolution Matrix

 Filters
 Generic
 Convolution Matrix

 Convolution Matrix

## Overview

 Here is a mathematician's domain. Most of filters are using convolution
 matrix. With the Convolution Matrix filter, if the fancy takes you, you
 can build a custom filter.

 What is a convolution matrix? It's possible to get a rough idea of it
 without using mathematical tools that only a few ones know. Convolution
 is the treatment of a matrix by another one which is called
 kernel.

 The Convolution Matrix filter uses a first matrix which is the Image to
 be treated. The image is a bi-dimensional collection of pixels in
 rectangular coordinates. The used kernel depends on the effect you want.

 GIMP uses 5×5 or 3×3 matrices. We will consider only 3×3 matrices, they
 are the most used and they are enough for all effects you want. If all
 border values of a kernel are set to zero, then system will consider it
 as a 3×3 matrix.

 The filter studies successively every pixel of the image. For each of
 them, which we will call the initial pixel, it
 multiplies the value of this pixel and values of the 8 surrounding
 pixels by the kernel corresponding value. Then it adds the results,
 and the initial pixel is set to this final result value.

 A simple example:

 On the left is the image matrix: each pixel is marked with its value.
 The initial pixel has a red border. The kernel action area has a green
 border. In the middle is the kernel and, on the right is the convolution
 result.

 Here is what happened: the filter read successively, from left to right
 and from top to bottom, all the pixels of the kernel action area. It
 multiplied the value of each of them by the kernel corresponding value
 and added results. The initial pixel has become 42:
 (40*0)+(42*1)+(46*0) + (46*0)+(50*0)+(55*0) + (52*0)+(56*0)+(58*0) = 42.
 (the filter doesn't work on the image but on a copy). As a graphical
 result, the initial pixel moved a pixel downwards.

## Activating the Filter

 This filter is found in the main menu under

 Filters
 Generic
 Convolution Matrix…
 .

## Options

## Convolution matrix options

 Presets
 Input Type
 Clipping
 Blending Options
 Preview
 Merge filter
 Split view

 Matrix

 This is the 5×5 kernel matrix: you enter wanted values directly
 into boxes.

 Divisor

 The result of previous calculation will be divided by this
 divisor. You will hardly use anything else than 1, which
 leaves results unchanged, and 9 or 25 according to matrix size,
 which gives the average of pixel values. The divisor can only
 be changed when Normalize is unchecked.

 Offset

 This value is added to the division result. This is useful
 if result may be negative. This offset may be negative. It
 can only be changed when Normalize is unchecked.

 Channels

 Here you can select which channels the filter should change.

 Normalize

 If this option is checked, The Divisor takes the result value of
 convolution. If this result is equal to zero (it's not possible
 to divide by zero), then a 128 offset is applied. If it is
 negative (a negative color is not possible), a 255 offset is
 applied (inverts result).

 Alpha-weighting

 If this option is not checked, the filter doesn't take in account
 transparency and this may be cause of some artefacts when
 blurring.

 Border

 When the initial pixel is on a border, a part of the kernel is
 outside the image. You have to decide what the filter should do:

## Border examples

 Source image

 Clamp border

 None border

 Loop border

 None

This part of the kernel is not taken into account.

 Clamp

 Pixels on borders are not modified, but they are cropped.

 Loop

 This part of the kernel will be affected by pixels of the
 opposite border, so pixels disappearing from one side
 reappear on the other side.

 Black

 Pixels on borders are changed to black.

 White

 Pixels on borders are changed to white.

## Examples

 Design of kernels is based on high levels mathematics. You can find
 ready-made kernels on the Web. Here are a few examples:

## Sharpen

## Blur

## Edge enhance

## Edge detect

## Emboss