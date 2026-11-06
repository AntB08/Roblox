## Painting fur  

### Question 

What brushes are best for fur textures? [img: Some example of furs and hair.] 

So typically, you see the same logic applied on fur as on regular [Brush-tips:Hair](hair.xhtml#hair). 

However, you can make a brush a little easier by using the Gradient, Mix and HSV options in the [pixel and color smudge brushes](../../reference_manual/brushes/brush_engines/pixel_brush_engine.xhtml#pixel-brush-engine). Basically, what we want to do is have a stroke start dark and then become lighter as we draw with it, to simulate how hair-tips catch more light and look lighter due to being thinner at the ends, while at the base they are frequently more dark. 

 

Note 

This tutorial contains outdated screenshots, but you should be able to follow along if you ignore a bit different look of the brush editor. Originally it also used brush preset and brush tip from the older resources set (ink_brush_25 and A - 2 Dirty Brush), but you should be able to get similar results with brush preset b) Basic-5 Size and brush tip sparkle or other similar brush preset (based on Pixel Engine) and similar brush tip (multiple dots).  [img: Brush setting dialog for fur brush.] 

Take the b) Basic-5 Size and choose under Brush Tip ‣ Predefined “sparkle”. Set the spacing to Auto and right-click the spacing bar to type in a value between 0.25 and 0.4. Also turn on the Enable Pen Settings on flow. Replicate the pressure curve above on the size option. We don’t want the hairs to collapse to a point, hence why the curve starts so high. [img: Brush setting dialog for fur.] 

Then activate value and reproduce this curve with the Distance or Fade sensor. Like how the pressure sensor changes a value (like size) with the amount of pressure you put on the stylus, the distance sensor measures how many pixels your stroke is, and can change an option depending on that. For the HSV sensors: If the curve goes beneath the middle, it’ll become remove from that adjustment, and above the vertical middle it’ll add to that adjustment. So in this case, for the first 100px the brush dab will go from a darkened version of the active paint color, to the active paint color, and then for 100px+ it’ll go from the active color to a lightened version. The curve is an inverse S-curve, because we want to give a lot of room to the mid-tones. [img: Brush setting dialog showing color gradation.] 

We do the same thing for saturation, so that the darkened color is also slightly desaturated. Notice how the curve is close to the middle: This means its effect is much less strong than the value adjustment. The result should look somewhat like the fifth one from the left on the first row of this: [img: Result of the brush that we made.] 

The others are done with the smudge brush engine, but a similar setup, though using color rate on distance instead. Do note that it’s very hard to shade realistic fur, so keep a good eye on your form shadow. You can also use this with grass, feathers and other vegetation: [img: Using the fur brush to make grass and hair.] 

For example, if you use the mix option in the pixel brush, it’ll mix between the fore and background color. You can even attach a gradient to the color smudge brush and the pixel brush. For color smudge, this is just the Gradient option, and it’ll use the active gradient. For the pixel brush, set the color-source to Gradient and use the mix option. [img: Fur brush with the color source to gradient and mix option.] 

You can also combine this with the lighter color blending mode and wraparound mode to make making grass-textures really easy!