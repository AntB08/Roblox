## Paper Tile

 Filters
 Map
 Paper Tile

 Paper Tile

## Overview

## Papertile filter example.

Original image

Filter applied

 This filter cuts the image (active layer or selection) into several
 pieces, with square form, and then slides them so that they, more or
 less, overlap or move apart. They can go out image borders a little.

## Activating the Filter

 This filter is found in the main menu under

 Filters
 Map
 Paper Tile…
 .

## Options

## Paper Tile filter options

 Presets
 Input Type
 Clipping
 Blending Options
 Preview
 Merge filter
 Split view

 Tile Width
 Tile Height

 Filter starts cutting image before it displaces pieces; so, piece
 size and number of pieces in horizontal (Width) and vertical
 (Height) directions must be convenient to image size.

 When these options are linked, tiles are square.

 Move rate

 This is the maximum displacement percentage against the side
 size of squares.

 Wrap around

 As tiles move, some can go out image borders. If this option
 is checked, what goes out on one side goes in on the
 opposite side.

 Fractional type

 Because of image cutting, original pixels can persist. There are
 three ways treating them:

 Force

 Remaining pixels will be cut also.

 Ignore

 Background Type option is not taken
 into account and remaining pixels are kept.

 Background

 Remaining pixels will be replaced with the background type
 defined in the following section.

 Centering

 If this option is checked, tiles will rather be gathered together
 in the center of the image.

 Background Type

 You can select the background type which will be used, if the
 Background radio-button is checked, among
 six options:

 Inverted image

 Background colors will be inverted (255-value in every color
 channel).

 Transparent

 Background will be transparent.

 Image

 Background colors will be unchanged. The original image is
 the background.

 Color

 Remaining pixels will be replaced by the color you can
 select. Default is the Foreground color of toolbox. You can
 choose another color using the color button or the color
 picker.

 Random seed
 New Seed

 This option controls the randomness of the filter.
 The Random seed box lets you manually enter
 a seed for the randomization algorithm used. You can also generate
 a random seed by pressing the New Seed
 button. If the same random seed is used in the same situation,
 the filter produces exactly the same results. A different random
 seed produces different results.