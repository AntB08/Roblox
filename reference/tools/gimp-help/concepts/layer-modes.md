## Layer Modes

 Layer
 Modes

 Layer Modes

 Layer
 Blending Modes

 Blending Modes

 Modes of layers

 Color
 Merging layer Modes

 GIMP has a wide variety of layer modes, split up in seven
 groups: Normal,
 Lighten,
 Darken,
 Contrast,
 Inversion,
 HSV components, and
 LCh components.
 In addition to these layer modes, there are also the so-called
 legacy layer modes,
 which were used before GIMP 2.10.

 These legacy layer modes are still available, both for backwards
 compatibility with saved images from older GIMP versions, and also for
 specific effects, or for compatibility with other image formats, e.g.
 Photoshop PSD. In general, they are not used when creating new images.

 Layer modes are also called blending modes. Selecting a layer
 mode changes the appearance of the layer or image, based on the layer or
 layers beneath it.
 Each layer in an image can have a different layer mode. The effects of these
 layer modes are cumulative. However, setting the mode to anything but Normal
 for the bottom layer of any layer group and the bottom layer of the image
 has no effect.

 In addition to the generic layer modes, there is one more layer mode called
 Pass through, which is only available for
 group layers.

 Pass through mode, is less a blending mode in and of
 itself than an instruction for the group as a whole: it indicates that
 layers inside the group are to be rendered in combination with other layers
 below the group, instead of being rendered separately from them.

 For more details about Pass through, see
 in the Glossary.

 You can set the layer mode in the Mode drop-down menu
 at the top of the Layers Dialog.
 GIMP uses the layer mode to determine how to combine
 each pixel in the top layer with the pixel in the same location in the
 layer below it.

 When the active tool is a painting tool, there is a drop-down list in the
 Tool Options which contains modes that affect the painting tools in a
 similar way to the layer modes. You can use all of the same modes for
 painting that are available for layers, and there are additional modes
 just for the painting tools. See
 .

 Layer modes permit complex color changes in the image. They are often used
 with a new layer which acts as a kind of mask.
 For example, if you put a solid white layer over an image and set the layer
 mode of the new layer to HSV Saturation, the underlying
 visible layers will appear in shades of gray.

## Images used for the layer mode examples

Background image (bottom layer)

Mask (top layer)

 The examples below show the effects of each of the layer modes. Each
 example will also describe the effect of the layer mode.

 Since the results of each mode vary greatly depending upon the colors on
 the layers, these images can only give you a general idea of how the modes
 work. You are encouraged to try them out yourself. You might start with
 two similar layers, where one is a copy of the other, but slightly
 modified (by being blurred, moved, rotated, scaled, color-inverted, etc.),
 and see what happens when you change the layer mode of the top layer.

## Normal Layer Modes

 The Normal group is a bit of a misnomer. Most of the
 modes besides Normal are
 cancellation modes.

 Normal

 Layer Modes
 Normal

## Example for layer mode Normal

 Top layer is at 50% Opacity.

 With 100% opacity for the top layer, only the upper layer is
 shown when blending with Normal, except for
 the transparent areas.

 Normal
 mode is the default layer mode. The layer on top covers the layers
 below it. If you want to see anything below the top layer when you
 use this mode, the layer must have some transparent areas.

 Dissolve

 Layer Modes
 Dissolve

 Dissolve

## Example for layer mode Dissolve

 Top layer is at 50% Opacity. The effect of
 Dissolve is visible everywhere, except in areas
 that are completely transparent.

 With 100% opacity of the top layer, only some edges that are
 semi transparent are affected by Dissolve.

 Dissolve
 mode dissolves the upper layer into the layer beneath it by drawing
 a random pattern of pixels in areas of partial transparency. This is
 especially visible along the edges within an image. It can be useful
 as a layer mode, but it is also often used as a painting mode.

 Color Erase

 Layer Modes
 Color Erase

 Color Erase

## Example for layer mode Color Erase

 Top layer at 100% opacity using Color Erase
 mode.

 Color Erase
 mode erases the colors in the upper layer from the lower layer.
 Black pixels in the upper layer make those parts in the bottom layer
 transparent, while white pixels have no effect. Anything in between
 removes those specific colors from the bottom layer, leaving the
 other color components intact.

 Erase

 Layer Modes
 Erase

 Erase

## Example for layer mode Erase

 Top layer at 100% opacity using Erase mode.
 The white parts here are transparent.

 Erase
 mode erases any non transparent area of the upper layer from the
 lower layer, making those parts in the bottom layer transparent.

 Merge

 Layer Modes
 Merge

 Merge

## Example for layer mode Merge

 Top layer at 100% opacity using Merge mode.

 Merge
 mode sums opacity values during blending and can yield 100% opacity
 in cases where Normal does not, like when blending cut-and-pasted
 content with soft edges whose opacities are mutually exclusive from
 each other.

 This mode is commutative if (but only if)
 the total opacity between both layers is 100% or less.
 Otherwise, especially for content that already has 100% opacity,
 Merge yields the same result as Normal.

 Split

 Layer Modes
 Split

 Split

## Example for layer mode Split

 Top layer at 100% opacity using Split mode.
 The white parts here are transparent.

 Split
 mode is the inverse of Merge: it subtracts the top layer's opacity
 from the bottom layer. This can yield full transparency in cases
 where Erase does not, like if erasing a value of 50% opacity from
 a layer containing 50% opacity.

## Lighten Layer Modes

 The Lighten group contains layer modes that make the result
 lighter.

 Lighten only

 Layer Modes
 Lighten only

 Lighten only

## Example for layer mode Lighten only

 Top layer at 100% opacity using Lighten only
 mode.

 Lighten only
 mode compares each component of each pixel in the upper layer with
 the corresponding one in the lower layer and uses the larger value
 in the resulting image. Completely black layers have no effect on
 the final image and completely white layers result in a white image.

 The mode is commutative; the order of the two layers doesn't matter
 (except for transparent areas in the bottom layer).

 Luma/Luminance lighten only

 Layer Modes
 Luma/Luminance lighten only

 Luma/luminance lighten only

## Example for layer mode Luma/Luminance lighten
 only

 Top layer at 100% opacity using Luma/Luminance Lighten
 only mode.

 Luma/Luminance Lighten only
 mode compares the luminance of each pixel in the upper layer with
 the corresponding one in the lower layer and uses the larger value
 in the resulting image. Completely black layers have no effect on
 the final image and completely white layers result in a white image.
 Luma is the perceptual version of Luminance.

 The mode is commutative; the order of the two layers doesn't matter
 (except for transparent areas in the bottom layer).

 Screen

 Layer Modes
 Screen

 Screen

## Example for layer mode Screen

 Top layer at 100% opacity using Screen mode.

 Screen
 mode inverts the values of each of the visible pixels in the two
 layers of the image. (That is, it subtracts each of them from 1.0.)
 Then it multiplies them together, and inverts this value again.
 The resulting image is usually brighter, and sometimes
 washed out in appearance. The exceptions to this are
 a black layer, which does not change the other layer, and a white
 layer, which results in a white image. Darker colors in the image
 appear to be more transparent.

 The mode is commutative; the order of the two layers doesn't matter.

 Dodge

 Layer Modes
 Dodge

 Dodge

## Example for layer mode Dodge

 Top layer at 100% opacity using Dodge mode.

 Dodge
 mode divides the pixel value of the lower layer by the inverse of
 the pixel value of the top layer. The resulting image is usually
 lighter, but some colors may be inverted.

 In photography, dodging is a technique used in a darkroom to
 decrease the exposure in particular areas of the image. This brings
 out details in the shadows. When used for this purpose, dodge may
 work best on Grayscale images and with a painting tool, rather than
 as a layer mode.

 Addition

 Layer Modes
 Addition

 Addition

## Example for layer mode Addition

 Top layer at 100% opacity using Addition mode.

 Addition
 mode is very simple. The pixel values of the upper and lower layers
 are added to each other. The resulting image is usually lighter. The
 equation can result in color values greater than 1.0.

 The mode is commutative; the order of the two layers doesn't matter.

## Darken Layer Modes

 The Darken group contains layer modes that make the result
 darker.

 Darken only

 Layer Modes
 Darken only

 Darken only

## Example for layer mode Darken only

 Top layer at 100% opacity using Darken only
 mode.

 Darken only
 mode compares each component of each pixel in the upper layer with
 the corresponding one in the lower layer and uses the smaller value
 in the resulting image. Completely white layers have no effect on
 the final image and completely black layers result in a black image.

 The mode is commutative; the order of the two layers doesn't matter.

 Luma/Luminance darken only

 Layer Modes
 Luma/Luminance darken only

 Luma/luminance darken only

## Example for layer mode Luma/luminance darken
 only

 Top layer at 100% opacity using Luma/Luminance Darken
 only mode.

 Luma/luminance Darken only
 mode compares the luminance of each pixel in the upper layer with
 the corresponding one in the lower layer and uses the smaller value
 in the resulting image. Completely white layers have no effect on
 the final image and completely black layers result in a black image.
 Luma is the perceptual version of Luminance.

 The mode is commutative; the order of the two layers doesn't matter
 (except for transparent areas in the bottom layer).

 Multiply

 Layer Modes
 Multiply

 Multiply

## Example for layer mode Multiply

 Top layer at 100% opacity using Multiply mode.

 Multiply
 mode multiplies the pixel values of the upper layer with those of
 the layer below it. The result is usually a darker image. If either
 layer is white, the resulting image is the same as the other layer.
 If either layer is black, the resulting image is completely black.

 The mode is commutative; the order of the two layers doesn't matter
 (except for transparent areas in the bottom layer).

 Burn

 Layer Modes
 Burn

 Burn

## Example for layer mode Burn

 Top layer at 100% opacity using Burn mode.

 Burn
 mode inverts the pixel value of the lower layer, divides that by the
 pixel value of the upper layer, then inverts the result. It tends to
 make the image darker, somewhat similar to Multiply
 mode.

 In photography, burning is a technique used in a darkroom to
 increase the exposure in particular areas of the image. This brings
 out details in the highlights. When used for this purpose, burn may
 work best on Grayscale images and with a painting tool, rather than
 as a layer mode.

 Linear burn

 Layer Modes
 Linear burn

 Linear burn

## Example for layer mode Linear burn

 Top layer at 100% opacity using Linear Burn
 mode.

 Linear Burn
 mode adds the pixel values of the upper and lower layers, and then
 subtracts 1.0. It tends to
 make the image darker, somewhat similar to Multiply
 mode.

## Contrast Layer Modes

 The Contrast group contains layer modes that enhance
 contrast.

 Overlay

 Layer Modes
 Overlay

 Overlay

## Example for layer mode Overlay

 Top layer at 100% opacity using Overlay mode.

 Overlay
 mode multiplies the upper layer with two times the lower layer when
 the component value of the lower layer is less than 0.5.
 When the component value is greater than or equal to 0.5, it
 inverts the components of the lower and upper layer, multiplies
 those values, then multiplies with 2.0, and then inverts the result.
 It darkens the image, but not as much as with
 Multiply mode.

 Soft light

 Layer Modes
 Soft light

 Soft light

## Example for layer mode Soft light

 Top layer at 100% opacity using Soft Light
 mode.

 Soft light is not related to
 Hard light in anything but the name, but it
 does tend to make the edges softer and the colors not so
 bright. It is similar to Overlay mode.
 Soft light has a more complicated formula. It
 uses the result of Multiply mode, then
 multiplies that with the inverse of the lower layer; then adds to
 that the multiplication of the result of Screen
 mode with the lower layer.

 Hard light

 Layer Modes
 Hard light

 Hard light

## Example for layer mode Hard light

 Top layer at 100% opacity using Hard Light
 mode.

 Hard light
 mode is rather complicated because the equation consists of two
 parts, one for darker color components and one for lighter ones. If
 the color component of the upper layer is greater than 0.5, the
 inverse of the lower layer is multiplied with the inverse of: the
 upper layer minus 0.5 times 2.0. Then the result of this is compared
 with the inverse of this result and the lower value of both is used.
 If the color component of the upper layer is less than or equal to
 0.5, the lower layer is multiplied with 2 times the upper layer. The
 result of that is compared with 1.0 and the lower value of that is
 used. You might use this mode to combine two photographs and obtain
 bright colors and sharp edges.

 Vivid light

 Layer Modes
 Vivid light

 Vivid light

## Example for layer mode Vivid light

 Top layer at 100% opacity using Vivid Light
 mode.

 Vivid light
 mode, increases contrast very strongly, especially in highlights and
 shadows. The effect is a combination of Burn (in the shadows) and
 Dodge (in the highlights), apart from the doublings in the
 denominators.
 This mode also consists of two parts depending on the color
 component value, where 0.5 is the limit, the same as with Hard
 light.
 If the upper layer value is smaller than or equal to 0.5: divide the
 inverse of the lower layer by 2 times the upper layer and invert
 the result. If the result is less than zero, return zero.
 If the upper layer value is greater than 0.5: divide the lower layer
 by two times the inverse of the upper layer. If the result is larger
 than 1.0, return 1.0.

 Pin light

 Layer Modes
 Pin light

 Pin light

## Example for layer mode Pin light

 Top layer at 100% opacity using Pin Light mode.

 Pin light
 mode is a combination of the Darken and Lighten modes. Mid-tone
 regions remain almost uninfluenced.
 If the component value of the upper layer is greater than 0.5:
 subtract 0.5 from the upper layer and multiply by 2.0. Then the
 result is the maximum from this value and the value of the lower
 layer.
 If the component value is less than or equal to 0.5: take the
 minimum value of the lower layer and two times the upper layer.

 Linear light

 Layer Modes
 Linear light

 Linear light

## Example for layer mode Linear light

 Top layer at 100% opacity using Linear Light
 mode.

 Linear light
 mode increases contrast slightly less than vivid light. It resembles
 Burn, but with twice the impact on the foreground's tonal values.
 If the component value is less than or equal to 0.5: the result is
 the lower layer plus two times the upper layer minus 1.0.
 If the component value is greater than 0.5: subtract 0.5 from the
 upper layer and multiply by 2.0, then add the lower layer.

 Hard mix

 Layer Modes
 Hard mix

 Hard mix

## Example for layer mode Hard mix

 Top layer at 100% opacity using Hard Mix mode.

 Hard mix
 mode only contains the six primary colors, black and white.
 The upper and lower layer components are added together. Any
 component which is more than or equal to 1.0 is set to 1. Anything
 else is set to 0.

## Inversion Layer Modes

 The Inversion group contains layer modes that invert the
 colors in one way or another.

 Difference

 Layer Modes
 Difference

 Difference

## Example for layer mode Difference

 Top layer at 100% opacity using Difference
 mode.

 Difference
 mode subtracts the pixel value of the upper layer from that of the
 lower layer and then takes the absolute value of the result. This
 mode can be used to compare two layers. If they are identical the
 difference is zero (black), otherwise the result shows the variance
 of the tonal values in each pixel. A white foreground inverts the
 background whereas a white background inverts the foreground.

 The mode is commutative; the order of the two layers doesn't matter.

 Exclusion

 Layer Modes
 Exclusion

 Exclusion

## Example for layer mode Exclusion

 Top layer at 100% opacity using Exclusion mode.

 Exclusion
 mode causes inversion to the other layer for bright regions, very
 dark regions change nothing at all. In this way this mode resembles
 Difference mode. However, medium gray values greatly decrease
 contrast of the respective other layer, in extreme cases up to zero.

 The mode is commutative; the order of the two layers doesn't matter.

 Subtract

 Layer Modes
 Subtract

 Subtract

## Example for layer mode Subtract

 Top layer at 100% opacity using Subtract mode.

 Subtract
 mode subtracts the pixel values of the upper layer from the pixel
 values of the lower layer. The resulting image is normally darker.
 You might get a lot of black or near-black in the resulting image.

 Grain extract

 Layer Modes
 Grain extract

 Grain extract

## Example for layer mode Grain extract

 Top layer at 100% opacity using Grain Extract
 mode.

 Grain extract
 mode is supposed to extract the film grain
 from a layer to produce a new layer that is pure grain, but it can
 also be useful for giving images an embossed appearance. It
 subtracts the pixel value of the upper layer from that of the lower
 layer and adds 0.5.

 Grain merge

 Layer Modes
 Grain merge

 Grain merge

## Example for layer mode Grain merge

 Top layer at 100% opacity using Grain Merge
 mode.

 Grain merge mode merges a grain layer
 (possibly one created from the Grain extract
 mode) into the current layer, leaving a grainy version of the
 original layer. It does just the opposite of
 Grain extract. It adds the pixel values of the
 upper and lower layers together and subtracts 0.5.

 Divide

 Layer Modes
 Divide

 Divide

## Example for layer mode Divide

 Top layer at 100% opacity using Divide mode.

 Divide
 mode divides each pixel value in the lower layer by the
 corresponding pixel value of the upper layer (while avoiding
 dividing by zero).
 The resulting image is often lighter, and sometimes looks
 burned out.

## HSV Components Layer Modes

 This group contains layer modes that blend layers using
 properties of the HSV
 or HSL color models.

 HSV Hue

 Layer Modes
 HSV Hue

 HSV Hue

## Example for layer mode HSV Hue

 Top layer at 100% opacity using HSV Hue mode.

 HSV Hue
 mode uses the Hue of the upper layer and the Saturation and Value of
 the lower layer to form the resulting image. However, if the
 Saturation of the upper layer is zero, the Hue is taken from the
 lower layer, too.

 HSV Saturation

 Layer Modes
 HSV Saturation

 HSV Saturation

## Example for layer mode HSV Saturation

 Top layer at 100% opacity using HSV Saturation
 mode.

 HSV Saturation
 mode uses the Saturation of the upper layer and the Hue and Value of
 the lower layer to form the resulting image.

 HSL Color

 Layer Modes
 HSL Color

 HSL Color

## Example for layer mode HSL Color

 Top layer at 100% opacity using HSL Color mode.

 HSL Color
 mode uses the Hue and Saturation of the upper layer and the
 Lightness of the lower layer to form the resulting image.

 HSV Value

 Layer Modes
 HSV Value

 HSV Value

## Example for layer mode HSV Value

 Top layer at 100% opacity using HSV Value mode.

 HSV Value
 mode uses the Value of the upper layer and the Saturation and Hue of
 the lower layer to form the resulting image. You can use this mode
 to reveal details in dark and light areas of an image without
 changing the Saturation.

## LCh Components Layer Modes

 The LCh group contains layer modes that make use of the
 LCh color model. LCh stands for Lightness, Chroma, Hue.
 It is mathematically derived from the CIELAB reference color space.
 See also CIELCh.

 LCh Hue

 Layer Modes
 LCh Hue

 LCh Hue

## Example for layer mode LCh Hue

 Top layer at 100% opacity using LCh Hue mode.

 LCh Hue
 mode corresponds to HSV Hue but is based on different mathematical
 formulas.

 LCh Chroma

 Layer Modes
 LCh Chroma

 LCh Chroma

## Example for layer mode LCh Chroma

 Top layer at 100% opacity using LCh Chroma
 mode.

 LCh Chroma
 mode corresponds to HSV Saturation but is based on different
 mathematical formulas.

 LCh Color

 Layer Modes
 LCh Color

 LCh Color

## Example for layer mode LCh Color

 Top layer at 100% opacity using LCh Color mode.

 LCh Color
 mode is a combination of LCh Chroma and LCh Hue, and corresponds to
 HSV Color, but is based on different mathematical formulas.
 See A tutorial on GIMP's very awesome LCH
 Blend Modes for information on using this layer mode.

 LCh Lightness

 Layer Modes
 LCh Lightness

 LCh Lightness

## Example for layer mode LCh Lightness

 Top layer at 100% opacity using LCh Lightness
 mode.

 LCh Lightness
 mode corresponds to HSV Value, but is based on different
 mathematical formulas. See A tutorial on GIMP's very
 awesome LCH Blend Modes for information on using this layer
 mode.

 Luminance

 Layer Modes
 Luminance

 Luminance

## Example for layer mode Luminance

 Top layer at 100% opacity using Luminance mode.

 Luminance
 mode is similar to CIE luminance, but does not alter saturation.
 It divides the upper layer luminance by the lower layer luminance;
 then uses that result to multiply with the lower layer component.