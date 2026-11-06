## Antialias

 Filters
 Enhance
 Anti-alias

 Anti-alias

## Overview

 This filter reduces alias effects
 (see Anti-aliasing)
 using the Scale3X edge-extrapolation algorithm.

 Scale3X is derived from Scale2X, which is a graphics effect to increase
 the size of small bitmaps guessing the missing pixels without
 interpolating pixels and blurring the images.

 .

 Scale2X was originally developed to improve the quality of old Arcade
 and PC games with a low video resolution played with video hardware like
 TVs, Arcade monitors, PC monitors and LCD screens.

 .

 The Antialias filter works as follows: for every pixel, the filter
 expands the original pixel in 9 (3×3) new pixels according to the
 Scale3X algorithm, using the colors of the pixel and its 8 adjacent
 pixels (extrapolation); then it subsamples the new pixels to a weighted
 average pixel.

## Activating the Filter

 This filter is found in the main menu under

 Filters
 Enhance
 Antialias
 .

## Examples

 The following examples illustrate the effect on some patterns. The
 small squares are one pixel in size (zoom 16:1).

Original image (zoom 16:1)

Antialias applied (zoom 16:1)