## Normal Map

 Filters
 Generic
 Normal Map

 Normal Map

## Overview

 This filter generates a normal map from a
 height map. It's early initial work and a lot more
 is expected to be done.

 We will use a height map created with
 :

## Normal Map Example

 The height map

 Filter applied with default options, giving the Normal Map

## Activating the Filter

 This filter is found in the main menu under

 Filters
 Generic
 Normal Map…
 .

## Options

## Normal Map options

 Presets
 Input Type
 Clipping
 Blending Options
 Preview
 Merge filter
 Split view

 Scale

 The amount by which to scale the heights values: increase or
 decrease bumps.

 Scale = 2

 X Component
 Y Component

 The component used for X, Y coordinates: you can choose between the
 three RGB colors for the bumps.

 Note that if you change these values, new colors are added to the
 existing colors, giving the complementary colors.

-->

 Flip X
 Flip Y

 Flip the X, Y coordinates: flip bumps colors, horizontally and
 vertically. Bumps have a clear border and an opposite dark border,
 giving a feeling that light comes from a certain direction. To see
 bumps instead of hollows, light must come from the upper left
 corner; play with Flip X and Flip Y to get this lighting.

 After playing with Flip X and Flip Y

 Full Z Range

 Use the full [0, 1] range to encode the Z coordinates: You can
 get a more abrupt color gradient.

 Tileable

 If checked, the resulting image will be seamlessly tileable.
 The right side will match the left side and the top will
 match the bottom. This is interesting if your image will be
 repeatedly used in a Web background.