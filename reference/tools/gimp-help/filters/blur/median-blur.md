## Median Blur

 Filters
 Blur
 Median Blur

 Median Blur

## Overview

## Example for the Median Blur filter

Original image

Filter applied

 While the Gaussian blur filter calculates the mean of the 
 neighboring pixels, the Median blur filter calculates the 
 median:

## Calculating Median

A 3×3 neighborhood. Values in ascending order. Median 
 surrounded in red.

 This calculation does not create a new value, and an unrepresentative 
 pixel in the neighborhood will not affect the result. So, the filter 
 preserves edges and rounds corners. It is used to reduce noise, 
 especially salt and pepper noise, and delete scratches on photographs.

## Activating the Filter

 This filter is found in the main menu under

 Filters
 Blur
 Median Blur…
 .

## Options

## Median filter parameters

 Presets
 Input Type
 Clipping
 Blending Options
 Preview
 Merge filter
 Split view

 Neighborhood

 The shape of the neighborhood. Three options:
 Square, Circle (default),
 Diamond. Differences are subtle and not
 predictable: experiment, on-canvas editing makes this easy.

## Median Neighborhood

 Radius=3. Left: Square.

 Middle: Circle. Right: Diamond.

 Radius

 The radius of the neighborhood. Increasing radius increases blur.
 Contrary to the Gaussian filter, edges are not
 blurred. Corners are rounded and convex surfaces are eroded.

## Median blur vs Gaussian
 blur

 Left: Original image

 Middle: Median Blur filter applied

 Right: Gaussian Blur filter applied

 Increasing radius too much can create unwanted effects:

 Left: Origin

 Right: Radius=100

 Percentile

 By default, the Median Blur filter finds the median value at the
 neighborhood of each pixel. In spite of its name, the filter can
 actually find *any* arbitrary percentile, not just the median 
 (i.e., the 50th percentile). The "Percentile" parameter controls 
 the percentile used for the color components. Lower values shift 
 the image toward darker tones and higher values toward brighter 
 ones.

 Left: Origin

 Middle: Percentile=0. Image is darker. Stems are enlarged but 
 sharp.

 Right: Percentile=100. Image is brighter and much blurred.

 Alpha percentile

 To see the effect of this parameter, you need an image with
 transparency. If the alpha channel is opaque everywhere, the
 result will also be fully opaque, regardless of the percentile.

 Lower values for the Alpha percentile parameter
 shift the image toward more transparency, and higher values shift
 the image toward more opacity, where a value of 50% is balanced.
 Roughly speaking, values less than 50% make the opaque regions of
 the image smaller, while values greater than 50% make the opaque
 regions of the image larger.

## Alpha percentile option example

 Left: Origin. The image has an alpha channel. A circle is
 transparent.

 Middle: Percentile=0%. Transparent circle is enlarged.

 Right: Alpha percentile=100%. Transparent circle is reduced.

 Abyss policy

 Abyss policy (border management) is treated with
 .

 High precision

 This option avoids clipping and quantization but is slower.

## Using Median Blur

 Reducing salt and pepper noise

 Left: origin

 Middle: radius = 1 applied twice

 Right: radius = 1 applied three times

 Reducing scratches

 Left: origin

 Middle: radius = 2

 Right: radius = 1 applied twice. The image is less blurred.