## Warp

 Filters
 Map
 Warp

 Warp

## Overview

 This filter displaces pixels of active layer or selection according to
 the gray levels of a Displacement map. Pixels are
 displaced according to the gradient slope in the displacement map.
 Pixels corresponding to solid areas are not displaced; the higher the
 slope, the higher the displacement.

## 
 From left to right: original image, displacement map, displaced image

 Solid areas of displacement map lead to no displacement. Abrupt
 transitions give an important displacement. A linear gradient
 gives a regular displacement. Displacement direction is
 perpendicular to gradient direction (angle = 90°).

## With a non-linear gradient

A non-linear gradient leads to curls.

## With a complex gradient:

 And a complex gradient, such as the
 Solid Noise
 filter can create, gives a swirl effect.

 This filter offers the possibility of masking a part of the image to
 protect it against filter action.

 If the image is in indexed mode, this menu entry is disabled.

## Activating the Filter

 This filter is found in the main menu under

 Filters
 Map
 Warp…
 .
 This filter has no Preview.

## Options

## Warp filter options

## Basic Options

 Step size

 Step is displacement distance for every filter
 iteration. A 10 value is necessary to get a one pixel
 displacement. This value can be negative to invert
 displacement direction.

 Iterations

 The number of repetitions of effect when applying filter.

 On edges

 Because of displacement, a part of pixels are driven over the
 borders of layer or selection, and, on the opposite side, pixels
 places are emptying. The four following options allow you to fix
 this issue:

 Wrap

 What goes out on one side is going into the opposite side
 (this is the default).

 Smear

 Emptying places are filled with a spreading of the
 neighboring image line.

 Black

 Emptying places are filled with black color.

 Foreground color

 Emptying places are filled with the Foreground color of the
 color area in Toolbox.

 Displacement map

 To be listed in this file picker, the displacement map, which
 should be a grayscale image, must be present on your
 screen when you call this filter and must have the same size as
 the original image.

## Advanced Options

 Dither size

 Once all pixels are displaced, this option scatters them randomly,
 giving grain to the image. The higher this value (0.00-100.00),
 the thinner the grain.

## With a 3.00 dither size:

 Rotation angle

 This option sets the displacement angle of pixels according to the
 slope direction of the gradient. Previous examples have been
 created with a vertical gradient and a 90° angle: so, pixels were
 displaced horizontally and nothing went out of the image borders.
 Here is an example with a 10° angle and 6 iterations:

## With a 10° angle and 6 iterations:

 Displacement is made according to a 10° angle against
 vertical. Pixels going out the lower border on every
 iteration are going in through the upper border (Wrap
 option checked), giving a dotted line.

 Substeps

 If you specify a value > 1, the displacement vector is computed in
 several substeps, giving you a finer control to the displace
 process.

 Magnitude map

 In addition to displacement map, you can add a Magnitude map. This
 map should also be a grayscale image, with the same size as the
 source image and which must be present on your screen when you
 call the filter. This map gives more or less strength to the
 filter on some parts of the image, according to the gray levels of
 this magnitude map. Image areas corresponding to white parts of
 this map will undergo all the strength of the filter. Image areas
 corresponding to black parts of the map will be spared by the
 filter. Intermediate gray levels will lessen the filter action on
 corresponding areas of the image.
 Use magnitude map must be checked
 for that.

## Magnitude Map example:

 From left to right: original image, displacement map,
 magnitude map, after applying Warp
 filter. You can see that the black areas of the magnitude
 map prevent the filter from taking action.

## More Advanced Options

 These extra options let you add two new maps, a gradient map and/or
 a vector map.

 To test these options alone, you must use a map with a solid color
 for all the other maps.

 Gradient scale

 Using a gradient map, (this map should also be a grayscale
 image), the displacement of pixels depends on the direction of
 grayscale transitions. The Gradient scale
 option lets you set how much the grayscale variations will
 influence the displacement of pixels. On every iteration, the
 filter works on the whole image, not only on the red object: this
 explains blurredness.

## Gradient scale example

 From left to right: original image, Gradient map, filter
 applied.

 In the example above, Warp filter is applied with a
 gradient map (Gradient scale = 10.0). The gradient is oblique,
 from top left to right bottom. The part of the image corresponding
 to the gradient is moved obliquely, 90° rotated (Rotation angle
 90° in Advanced Options).

 Vector magnitude

 With this map, the displacement depends on the angle you set in
 the Angle text box. 0° is upwards. Angles go
 counter-clockwise. The vector control map
 determines by how many pixels the image will move on every
 iteration.

## Vector magnitude example

 From left to right: original image, displacement map,
 filter applied.

 In the above example, Warp filter is applied with a
 Vector magnitude. Gradient is vertical, from top to bottom. Vector
 angle is 45°. The image is moved obliquely, 45° to the top left
 corner. The image is blurred because every iteration works on the
 whole image, and not only on the red bar.

 Angle

Angle for fixed vector map (see above).