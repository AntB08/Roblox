## Supernova

 Filters
 Light and Shadow
 Supernova

 Supernova

## Overview

## Applying example for the Supernova filter

Original image

Filter applied

 This filter creates a big star reminding a supernova. It works with
 RGB and GRAY images. Light effect decreases according to 1/r where r
 is the distance from star center.

## Activating the Filter

 This filter is found in the main menu under

 Filters
 Light and Shadow
 Supernova…
 .

## Options

## Supernova filter options

 Presets
 Input Type
 Clipping
 Blending Options
 Preview
 Merge filter
 Split view

 Center X
 Center Y

 You can use input boxes to set horizontal (X) and vertical
 (Y) coordinates of Supernova center. You can also click and drag the
 supernova center in preview.

 Radius

 This is radius of the Supernova center: the upper limit seems to 
 be unlimited. When you increase the value, you increase the number 
 of central white pixels according to r*r (1, 4, 9, …).

 Radius is represented by a horizontal line in preview, with a cross 
 at end. You can click and drag this cross to set radius.

 Number of spokes

 This is number of rays (1-1024). Each pixel in the nova center
 emit one pixel wide rays. All these rays are more or less
 superimposed resulting in this glittering effect you get when
 you move this slider.

 Random hue

 Color rays at random. (0-360) value seems to be a range in
 HSV color wheel.

 Color

 When you click on the color swatch, you bring up the usual color
 selector.

 You also have a color picker. When it is selected, the mouse 
 pointer goes with a square on image: it's the color sample whose 
 size you can modify in the GEGL operation window under Toolbox.

 Random seed
 New Seed

 This option controls the randomness of the filter.
 The Random seed box lets you manually enter
 a seed for the randomization algorithm used. You can also generate
 a random seed by pressing the New Seed
 button. If the same random seed is used in the same situation,
 the filter produces exactly the same results. A different random
 seed produces different results.