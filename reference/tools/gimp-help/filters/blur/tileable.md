## Tileable Blur

 Filters
 Blur
 Tileable Blur

 Tileable Blur

## Overview

## Example for the Tileable filter

Original image

Filter applied

 Tileable Blur is actually implemented by a Script-Fu script that invokes
 the Gaussian blur plug-in.

 This filter is used to soften tile seams in images used in tiled
 backgrounds. It does this by blending and blurring the boundary between
 images that will be next to each other after tiling.

 If you want to treat only images borders, you can't apply filter
 to the whole image. The solution to get the wanted effect is as
 follows:

 Duplicate layer
 (
 Layer
 Duplicate Layers
 )
 and select it to work on it.

 Apply Tileable Blur filter with a 20 pixels radius
 to this layer.

 Select all
 (CtrlA) and
 reduce selection
 (
 Selection
 Shrink
 )
 to create a border with the wanted width.

 Give a feathered border to the selection by using

 Selection
 Feather
 .

 Delete selection with
 CtrlK.

 Merge layers with

 Layer
 Merge down
 .

 If the image is in grayscale mode or indexed mode, this menu entry
 is disabled.

## Activating the Filter

 This filter is found in the main menu under

 Filters
 Blur
 Tileable Blur…
 .

## Options

## Tileable Blur filter options

 Radius

 The bigger the radius, the more marked is the blur. By selecting
 Horizontal and Vertical,
 you can make the horizontal and vertical borders tileable.

 Blur vertically
 Blur horizontally

 These options are self-explanatory.

 Blur type

This setting is ignored.