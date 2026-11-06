## Clothify

 Filters
 Artistic
 Clothify

 Clothify

## Overview

## Example of Clothify

Filter Clothify applied (in selection)

 Clothify command is a script which
 adds a cloth-like texture to the selected region or alpha.

 If the image is in indexed mode, this menu entry is disabled.

This effect is achieved through the following steps:

 Create an image in the same size as the original image, or selection
 or region in alpha if it is given, then add a layer to this image
 filled with white and
 noisified strongly.

 Reproduce a layer from the recently added layer and set the mode of
 the upper layer to
 Multiply.

 Apply Gaussian blur in
 different directions, horizontally on the lower layer by the given
 parameter Blur X as the radius, and vertically
 on the upper layer with Blur Y.

 Merge these two layers into an image and make its contrast
 expanded as 
possibly, then
 slightly noisify again on this working image.

 Finally do bump map on the
 original image by the working image with parameters
 Azimuth, Elevation, and
 Depth.

## Activating the Filter

 This filter is found in the main menu under

 Filters
 Artistic
 Clothify…
 .

## Options

## Clothify filter options

 Azimuth, Elevation, and
 Depth come from
 Bump Map filter.

 Blur X
 Blur Y

 These parameters lengthen fibers of the texture, horizontally
 by Blur X, and vertically by
 Blur Y. The range of value is between
 3 to 100.

 Azimuth

 Azimuth slider controls the bearings
 where light comes from according to the point of the compass.
 Both the minimum value (0.00) and the maximum value (360.00)
 are the direction of three o'clock on the dial panel of an
 analogue clock. Increasing value goes counter-clockwise.

 Elevation

 Elevation slider controls the height
 where light comes from. For the minimal value (0.50)
 the light comes from horizon, and for the maximum value
 (90.0) the light comes from zenith.

 Depth

 Depth slider controls distance between bump
 height and hollow depth. Increasing value causes more rugged
 features. Values vary from 1 to 65.