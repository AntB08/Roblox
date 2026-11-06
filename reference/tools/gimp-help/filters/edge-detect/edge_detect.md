## Edge

 Filters
 Edge Detect
 Edge

 Edge

 Sobel

 Laplace

 Roberts

 Gradient

 Prewitt compass

 Differential

## Overview

## Applying example for the Edge filter

Original image

Filter applied

 This filter detects edges in an image using the method selected
 in Algorithm.

## Activating the Filter

 This filter is found in the main menu under

 Filters
 Edge-Detect
 Edge…
 .

## Options

## Edge filter options

 Presets
 Input Type
 Clipping
 Blending Options
 Preview
 Merge filter
 Split view

 Algorithm

 The algorithm selected here, determines what method is used
 to detect edges. The following methods are available:

 Sobel

 This is an alternative version of the separate
 Sobel filter.
 Contrary to that filter, this one has no additional settings
 that can be adjusted. This is the default; an example is
 shown at the top of the page.

 Prewitt compass

 The Prewitt
 operator is a relatively fast algorithm, that
 can be relatively crude for high frequency variations in
 an image.

 Algorithm set to Prewitt compass

 Gradient

 When using the Gradient algoritm, edges are thinner, less
 contrasted and more blurred than Sobel.

Algorithm set to Gradient

 Roberts

 The Roberts
 algorithm will highlight changes in intensity in a diagonal
 direction. However, it suffers greatly from sensitivity to
 noise.

Algorithm set to Roberts

 Differential

 This algorithm often causes edges to be less bright.

Algorithm set to Differential

 Laplace

 This is a different implementation of the
 Laplace
 filter, that gives different results.

Algorithm set to Laplace

 Amount

 A low value results in a black, high-contrasted image with thin
 edges. A high value results in thick edges with low contrast and
 many colors in dark areas.

 Border behavior

 This determines where the edge detector will get adjoining pixels
 for its calculations when it is working on the image boundaries.
 This setting will only affect the boundaries of the result
 (if any). Clamp is the default and
 the best choice in general.