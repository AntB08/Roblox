## Dither

 Colors
 Dither

 Dither

 This filter can reduce the number of colors in an image by reducing the
 levels per channel (colors and alpha). Different dithering methods can be
 specified to counteract quantization induced banding.

## Activating the Command

 You can access this command from the main menu through

 Colors
 Dither…
 .

## Options

## Dither filter dialog

 Presets
 Input Type
 Clipping
 Blending Options
 Preview
 Merge filter
 Split view

 Red levels
 Green levels
 Blue levels
 Alpha levels

 These sliders allow you to set the number of levels for the
 respective red, green, blue and alpha channels.

 Dithering method

 Here you can specify the dithering method to use.

 None

 No dithering will be performed on the image.

 Floyd-Steinberg

 This is the most commonly used method of dithering and the
 default for this filter. For more information see
 Floyd–Steinberg
 dithering on Wikipedia.

 Bayer

 The Bayer Matrix is another common method of dithering used
 to reduce the number of colors. The algorithm is
 characterized by noticeable crosshatch patterns in the result.
 For more information see
 Ordered
 dithering on Wikipedia.

 Random
 Random Covariant

 These methods of dithering use randomization of the pixel
 values to reduce the number of colors.

 Arithmetic add
 Arithmetic add covariant
 Arithmetic xor
 Arithmetic xor covariant

 These methods of dithering are spatially stable, based on
 magic numbers and arithmetic.
 For more information see
 a dither.

 Blue Noise
 Blue Noise Covariant

 These dithering methods using so-called blue noise have been
 found to be the least unsightly and distracting.
 For more information see
 Dithering
 in image processing on Wikipedia.

 Random seed
 New Seed

 This option controls the randomness of the filter.
 The Random seed box lets you manually enter
 a seed for the randomization algorithm used. You can also generate
 a random seed by pressing the New Seed
 button. If the same random seed is used in the same situation,
 the filter produces exactly the same results. A different random
 seed produces different results.