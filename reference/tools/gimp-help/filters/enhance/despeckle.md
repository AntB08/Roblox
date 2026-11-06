## Despeckle

 Filters
 Enhance
 Despeckle

 Despeckle

## Overview

 This filter is used to remove small defects due to dust, or scratches,
 on a scanned image, and also moiré effects on images scanned from a
 magazine. You should select isolated defects before applying this
 filter, in order to avoid unwanted changes in other areas of your image.
 The filter replaces each pixel with the median value of the pixels within
 the specified radius.

 If the image is in indexed mode, this menu entry is disabled.

## Activating the Filter

 This filter is found in the main menu under

 Filters
 Enhance
 Despeckle…
 .

## Options

## Despeckle filter options

 Preview

 If checked, parameter setting results are interactively displayed
 in preview.

 Filter Type

 Median

 The median value of the pixels within the set
 Radius around the target pixel is
 used to replace the target pixel value.

 Adaptive

 Adapts the radius to image or selection content by
 analyzing the histogram of the region around the target
 pixel. The adapted radius will always be equal to or
 smaller than the specified radius.

 Recursive-Median

 Repeats the Median filter action to get a stronger effect.

 Recursive-Adaptive

 Repeats the Adaptive filter action to get a stronger effect.

 Radius

 Sets size of action window from 1 (3×3 pixels) to 20 (41×41). This
 window moves over the image, and the color in it is smoothed, so
 imperfections are removed.

 Black level

 Only include pixels brighter than the set value in the histogram (-1-255).

 White level

 Only include pixels darker than the set value in the histogram (0-256).