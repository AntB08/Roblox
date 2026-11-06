by by lexa
 2005/09/29 translated to german by axel.wernicke
-->

## Depth Merge

 Filters
 Combine
 Depth Merge

 Depth Merge

 Depth Merge is a Combine Filter which is useful to combine two different
 pictures or layers. You can decide which part of every image or layer will
 stay visible.

## Overview

## Filter example

Original image

Filter applied

 Every image is associated with a map which works as a mask. Simply
 create this map as a grayscale gradient: when applied onto the image,
 dark areas of the mask will show the underlying image and bright areas
 will mask the image.

 To work with this filter, images and maps must have the same size.
 All images to be selected must be present on screen.

 You can also use this filter on an image with several layers. All
 layers will appear in the drop-down lists used to select images.
 These layers must have the same size.

 If the image is in indexed mode, this menu entry is disabled.

## Activating the Filter

 This filter is found in the main menu under

 Filters
 Combine
 Depth Merge…

## Options

## Depth Merge filter options

 Source 1
 Source 2

 Defines the source images to use for the blending.

 Depth map 1
 Depth map 2

 Define the pictures to use as transformation maps for the sources.

 Overlap

Creates soft transitions between images.

 Offset

 This option shifts the merging limit, giving more or less
 importance to an image against the other.

 Scale 1
 Scale 2

 Same as above for Offset, but more sensitive and applied to each
 map separately. When you scale to a lower value, it will affect
 the map image's value, making it darker. So, black is more
 dominant in the merge and you will see more of the image.

## Using example

 Maps are grayscale gradients created with the
 Gradient tool and modified with 
the
 Curve tool.

## Source images and their maps

Source image 1

Source image 2

Map 1

Map 2

 You can understand what's going on. Image-1 is treated by map-1: the red
 square is masked and the yellow square remains visible. Image-2 is
 treated by map-2: the red circle is masked and the green circle remains
 visible. In total, the green circle and the yellow square stay visible.

## Results

 No offset and no overlap.
 The limit between both images is sharp and is situated
 in the middle of the mask gradient.

 Offset = 0.980 : the limit, sharp,
 is shifted so that the image-2 area is increased.

 Overlap = 0.520 : the limit is blurred.

 Scale 1
 reduced to 0.056 : as with Offset, the limit is shifted. Image-1
 area is increased.