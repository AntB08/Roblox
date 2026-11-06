## Desaturate

 Colors
 Desaturate
 Desaturate

 Desaturate

 By using the Desaturate command, you can convert
 all of the colors on the active layer to corresponding shades of gray. This
 differs from converting the image to grayscale in two respects. First, it
 only operates on the active layer and second, the colors on the layer are
 still RGB values with three components, with R=G=B, which makes gray.
 This means that you then can paint on the layer, or individual parts of it,
 using non-gray colors.

 This command only works on layers of
 RGB images. If the image is in
 Grayscale or Indexed mode, it can do nothing.

## Activating the Command

 You can access this command from the main menu through

 Colors
 Desaturate
 Desaturate…
 .

## Options

## The Desaturate option dialog

Mode: Five options are available for converting
 from color to black and white:

 Presets
 Blending Options
 Preview
 Merge filter
 Split view

 Luminance

The shades of gray will be calculated using

 linearized sRGB as

 Luminance =
 (0.22 × R) +
 (0.72 × G) +
 (0.06 × B)

 Luma

The shades of gray will be calculated using non-linearized sRGB

 Luma = (0.22 × R) + (0.72 × G) + (0.06 × B)

 Lightness (HSL)

The shades of gray will be calculated as

 Lightness (HSL) = ½ × (max(R,G,B) + min(R,G,B))

 Average (HSI Intensity)

The shades of gray will be calculated as

 Average (HSI Intensity) = (R + G + B) ÷ 3

 Value (HSV)

The shades of gray will be calculated as

 Value (HSV) = max(R,G,B)

## Using the five modes to convert two very different color images
 to black and white

Original image

Original image

Luminance applied

Luminance applied

 Luma applied.

 Luma applied.

 Lightness (HSL) applied.

 Lightness (HSL) applied.

 Average (HSI Intensity) applied.

 Average (HSI Intensity) applied.

 Value (HSV) applied.

 Value (HSV) applied.

## Comparing results from using different options for
 converting from color to black and white:

 The degree and direction from which the various ways to convert
 an image to black and white diverge from a straight Luminance conversion
 to black and white depends on:

 The conversion method you choose.

 The RGB color space in which the conversion is done.

 How saturated the colors in the original image happen to
 be, with more saturated starting colors (such as the red globe and the
 bright yellow sunflower) producing greater amounts of deviation from a
 straight Luminance conversion.

 The hues (for example yellows vs reds) of the various
 saturated colors in an image also make a difference.

 Being the maximum of the RGB channel values for each
 pixel, an HSV Value conversion to black and white is always lighter than
 the original color image, and also lighter than all the other ways to
 convert to black and white.

 Comparing the red globe to the yellow sunflower:

 For the red globe Lightness (HSL) produces a result very
 similar to Luminance, and Luma produces a conversion that is much darker.

 For the sunflower, Luma produces a result very similar to
 Luminance, and Lightness (HSL) produces a conversion that is much darker.

 Notice that the less saturated parts of each image look
 more or less the same, regardless of which method is chosen for converting
 from color to black and white.

## More information about the five options for
 converting from color to black and white:

More information about Luminance:

 "Luminance" is the only physically meaningful way to
 convert a color image to black and white, as the resulting black and
 white image has the same relative luminance (reflects the same
 percentage of light from the various shades of gray) as the colors in
 the original color image.

 Luminance must be calculated using linearized RGB values.

 For convenience we say "Luminance", but what we really
 mean is "Relative Luminance". For more information, see
 Relative
 Luminance and

 CIE 1931 [XYZ] color space.

 GIMP uses hard-coded sRGB values to do Luminance
 conversions to black and white. "Future GIMP" will support correct
 conversions for images in other color spaces.

 More information about Luma:

 "Luma" is what you get if you use the formula for
 Luminance on RGB values that haven't been properly linearized.

 The multipliers have been properly Bradford-adapted to
 D50, which is required for use in an ICC profile color-managed editing
 application (at least until the next version of the ICC specs is
 released and people figure out how to deal with the new freedom to use
 non-D50 reference white points).

 GIMP uses hard-coded sRGB values to do Luma
 conversions to black and white. "Future GIMP" will support correct
 conversions for images in other color spaces.

 More information about Lightness, Average, and Value:

 The "Lightness (HSL)", "Average (HSI Intensity)", and "Value (HSV)"
 ways to convert a color image to black and white use color space models
 that were invented for fast processing on consumer-grade computers from the
 1990s. For details see
 HSL and HSV,
 paying particular attention to the section on
 Disadvantages.

 In case you are wondering why LAB Lightness is
 not among the options
 for converting an RGB image to black and white, a properly calculated
 conversion from RGB to LAB Lightness, and then back to RGB, produces exactly
 the same result as the Luminance conversion to black and white. Here is why:

 In the XYZ color space, Y is Luminance. So if you
 convert a color RGB image to XYZ, the "Y" of XYZ is the same number as
 the R=G=B values that you get when you calculate RGB Luminance.

 LAB is a perceptually uniform transform of XYZ. If you
 convert from RGB to XYZ and then to LAB, and set A=B=0.0 (or 0.5 for
 image editors that put the midpoint of the A and B axes as 0.5 instead
 of at 0.0), and then convert back to XYZ, the X and Z values will
 change, but Y will not change.

 Tutorials that produce anything other than Relative Luminance when
 converting an RGB image to black and white using LAB Lightness, very sadly
 are trading on various mathematical mistakes in the conversion routines.