## Distance Map

 Filters
 Generic
 Distance Map

 Distance Map

## Overview

 Each pixel in the image is replaced with a gray value dependent on the 
 distance to the nearest obstacle pixel, generally a boundary pixel. 
 Different methods can be used to calculate the distance.

## Activating the Filter

 This filter is found in the main menu under

 Filters
 Generic
 Distance Map…
 .

## Options

## Distance Map options

 Presets
 Input Type
 Clipping
 Blending Options
 Preview
 Merge filter
 Split view

 Metric

 Metric is a topology term. Three methods are 
 available:

 Edge handling

 This defines how areas outside the input are considered when
 calculating distance. Choices are:
 Below threshold and
 Above threshold.

 Threshold low

 Default is 0. Increasing this value selects higher lightness pixels

 Original image for examples. Threshold low will be progressively 
 increased. Lightness: dark red = 0.070; bright red = 0.223; green 
 = 0.133

## Threshold low example

 Threshold low = 0: only border distances are visible.

 Threshold low = 0.070: dark red circle appears.

 Threshold low = 0.133: green circle appears.

 Threshold low = 0.223: bright red circle 
 appears.

 Threshold high

 Default is 1. Decreasing this value makes result darker.

 Grayscale Averaging

 Number of computations for grayscale averaging.

 Normalize

 This option is checked by default. When checked, all distances are
 normalized into a range of 0.0 to 1.0.

 If you uncheck this option, non-obstacle pixels will appear white
 because their calculated distance will be greater than or equal to
 1.0.

## Normalize example

 Normalize option checked.

 Normalize option unchecked.

## Using Distance Map filter

 Searching for an example using Distance map filter in image processing...

 -->