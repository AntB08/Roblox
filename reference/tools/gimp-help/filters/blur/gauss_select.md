## Selective Gaussian Blur

 Filters
 Blur
 Selective Gaussian

 Selective Gaussian Blur

## Overview

## The Selective Gaussian Blur filter

Original image

Filter applied

 Contrary to the other blur plug-ins, the Selective Gaussian Blur plug-in
 doesn't act on all pixels: blur is applied only if the difference
 between its value and the value of the surrounding pixels is less than a
 defined Delta value. So, contrasts are preserved because difference is
 high on contrast limits. It is used to blur a background so that the
 foreground subject will stand out better. This add a sense of depth to
 the image with only a single operation.

## Activating the Filter

 This filter is found in the main menu under

 Filters
 Blur
 Selective Gaussian Blur…
 .

## Options

## 
 Selective Gaussian filter parameters settings

 Presets
 Input Type
 Clipping
 Blending Options
 Preview
 Merge filter
 Split view

 Aux

 If there is another image on screen, you can select it as
 auxiliary input.

 Blur radius

 Here you can set the blur intensity, in pixels.

 Max. delta

 Maximum delta sets the maximum difference (0.0-1.0) between the
 pixel to be blurred and its surrounding pixels. When the value is
 above this delta, the blur will not be applied to that pixel.