by by lexa
 2005-11-30 replaced informalfigure by axel.wernicke
 050830 de replaced informalfigure by axel.wernicke
 050901 de added by axel.wernicke
-->

## Erode

 Filters
 Generic
 Erode

 Erode

## Overview

## Applying example for the Erode filter

Original image

Filter applied

 This filter widens and enhances dark areas of the active layer or
 selection.

 For every image pixel, it brings the pixel Value (luminosity) into line
 with the lowest Value (the darkest) of the 8 neighboring pixels (3×3
 matrix). So, a dark pixel is added around dark areas. An isolated pixel
 on a brighter background will be changed to a big pixel,
 composed of 9 pixels, and that will create some noise in the image.

 In this image, the studied pixel has a red border and the studied 3×3
 matrix has a green border. Thus when the pixel marked with I
 is inside the green border, the studied pixel turns to black.

 A larger dark area will expand by one pixel in all directions:

 The filter was applied 3 times.

 On more complex images, dark areas are widened and enhanced the same,
 and somewhat pixelated. Here, the filter was applied 3 times:

 Of course, if background is darker than foreground, it will cover the
 whole image.

## Activating the Filter

 This filter is found in the main menu under

 Filters
 Generic
 Erode
 .

## Examples

## Erode text