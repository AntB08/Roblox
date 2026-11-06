## Texture 

This allows you to have textured strokes. This parameter always shows up as two parameters:  

### Texture  Pattern

Which pattern you’ll be using.  Scale

The size of the pattern. 1.0 is 100%. [img: ../../../_images/Krita_2_9_brushengine_texture_05.png]  Horizontal Offset & Vertical Offset

How much a brush is offset, random offset sets a new per stroke. [img: ../../../_images/Krita_2_9_brushengine_texture_04.png]  Texturing mode

All texture modes affect the alpha channel, with the exception of *lightness map* and *gradient map*, which affect the color channels. [img: ../../../_images/Krita_2_9_brushengine_texture_01.png] [img: ../../../_images/Krita_4_4_brushengine_texture_lightness_gradient_demo.png]  Soft Texturing

 

Added in version 5.3.  

When the strength option is on, its value is used as a factor on how the texture is applied using the selected texturing mode. By toggling the soft texturing option you can alter this behavior.     

With 100% strength the texturing looks the same no matter the state of the soft texturing option, which is the same as when the strength option is off. But when using lower values for the strength, soft texturing will take effect: if it is off then, for lower strength values, the texturing is applied normally but the stroke seems to disappear, giving an effect similar to rubbing a drawing tool against some textured surface with more or less pressure. On the other hand, if the soft texturing option is on then, for lower strength values, the stroke looks more like as if the texture was not applied at all, leaving the stroke with the un-textured look. 

>  

>  

The soft texturing can be activated to better replicate the Photoshop brushes for the modes other than height and linear height.  

In the following explanations, the sample strokes go from low strength on the left side to high strength on the right side. The top stroke uses a hard brush tip and the bottom one a soft brush tip. On the left side of the strokes there are two non-textured dots, just for comparison sake.  Multiply

Uses alpha multiplication to determine the effect of the texture. Has a soft feel.  [img: ../../../_images/multiply.png]  

*Soft texturing off*    [img: ../../../_images/soft_multiply.png]  

*Soft texturing on*    Subtract

Uses subtraction to determine the effect of the texture. Has a harsher, more texture feel.  [img: ../../../_images/subtract.png]  

*Soft texturing off*    [img: ../../../_images/soft_subtract.png]  

*Soft texturing on*    Lightness Map

 

Added in version 4.4.  

Applies lightness values of the texture to the paint. Can be used to simulate paper/canvas, or for painting a texture, like reptile skin or tree bark.  [img: ../../../_images/lightness_map.png]   Gradient Map

 

Added in version 4.4.  

Maps gray/lightness values of the texture to the currently selected gradient. Useful for painting textures with multiple colors, like reptile skin, tree bark, stars, etc.  [img: ../../../_images/gradient_map.png]   Darken

 

Added in version 5.0.  

This mode chooses the minimum alpha value between the brush tip and the texture. The effect is as if the texture made holes in the opaque areas of the brush tip.  [img: ../../../_images/darken.png]  

*Soft texturing off*    [img: ../../../_images/soft_darken.png]  

*Soft texturing on*    Overlay

 

Added in version 5.0.  

The texture is softly applied to the semi-transparent areas of the brush tip. This mode produces a result similar to *multiply* but allowing for full coverage when high strength values are used.  [img: ../../../_images/overlay.png]  

*Soft texturing off*    [img: ../../../_images/soft_overlay.png]  

*Soft texturing on*    Color Dodge

 

Added in version 5.0.  

This mode produces features with somewhat hard edges on the brush tip by making it more opaque where the texture values are brighter.  [img: ../../../_images/color_dodge.png]  

*Soft texturing off*    [img: ../../../_images/soft_color_dodge.png]  

*Soft texturing on*    Burn

 

Added in version 5.0.  

This mode produces holes with somewhat hard edges on the brush tip by making it more transparent where the texture values are darker.  [img: ../../../_images/color_burn.png]  

*Soft texturing off*    [img: ../../../_images/soft_color_burn.png]  

*Soft texturing on*    Linear Dodge

 

Added in version 5.0.  

Similar to *color dodge* but the opacity of the brush tip is increased even more.  [img: ../../../_images/linear_dodge.png]  

*Soft texturing off*    [img: ../../../_images/soft_linear_dodge.png]  

*Soft texturing on*    Linear Burn

 

Added in version 5.0.  

The result is similar to *burn* but with the opacity decreased a bit more. It also is similar to the *subtract* mode but with the texture inverted.  [img: ../../../_images/linear_burn.png]  

*Soft texturing off*    [img: ../../../_images/soft_linear_burn.png]  

*Soft texturing on*    Hard Mix (Photoshop)

 

Added in version 5.0.  

This mode produces a result similar to *burn* or *linear burn* and allows to obtain full coverage when high strength values are used. The resulting edges are very hard (in fact, aliased).  [img: ../../../_images/hard_mix_ps.png]  

*Soft texturing off*    [img: ../../../_images/soft_hard_mix_ps.png]  

*Soft texturing on*    Hard Mix Softer (Photoshop)

 

Added in version 5.0.  

This mode tries to emulate *hard mix (photoshop)* while producing softer, antialiased, edges.  [img: ../../../_images/hard_mix_softer_ps.png]  

*Soft texturing off*    [img: ../../../_images/soft_hard_mix_softer_ps.png]  

*Soft texturing on*    Height

 

Added in version 5.0.  

This mode is similar to the *subtract* mode but with a higher range of possibilities when applying the strength. Contrary to *subtract*, it allows to achieve full coverage with one stroke.  [img: ../../../_images/height.png]  

*Soft texturing off*    [img: ../../../_images/soft_height.png]  

*Soft texturing on*    Linear Height

 

Added in version 5.0.  

Same as *height* but combined with *multiply* to achieve softer transitions.  [img: ../../../_images/linear_height.png]  

*Soft texturing off*    [img: ../../../_images/soft_linear_height.png]  

*Soft texturing on*    Height (Photoshop)

 

Added in version 5.0.  

As the *height* mode, this mode is similar to the *subtract* mode but with a higher range of possibilities when applying the strength. Contrary to *subtract*, it allows to achieve full coverage with one stroke. This mode tries to emulate the height mode present in Photoshop and it only differs from Krita’s *height* mode on how the strength is mapped in the algorithm. When using a strength value of 0.1 the results are almost identical to the *subtract* mode with a strength of 1.  [img: ../../../_images/height_ps.png]  

*Soft texturing off*    [img: ../../../_images/soft_height_ps.png]  

*Soft texturing on*    Linear Height (Photoshop)

 

Added in version 5.0.  

Same as *height (photoshop)* but combined with *multiply* to achieve softer transitions.  [img: ../../../_images/linear_height_ps.png]  

*Soft texturing off*    [img: ../../../_images/soft_linear_height_ps.png]  

*Soft texturing on*       Cutoff policy

Cutoff policy will determine what range and where the strength will affect the textured outcome.  Disabled

Doesn’t cut off. Full range will be used.  Pattern

Cuts the pattern off.  Brush

Cuts the brush tip off.   [img: ../../../_images/Krita_2_9_brushengine_texture_02.png]  Cutoff

Cutoff is… the grayscale range that you can limit the texture to. This also affects the limit takes by the strength. In the below example, we move from the right arrow moved close to the left one, resulting in only the darkest values being drawn. After that, three images with larger range, and underneath that, three ranges with the left arrow moved, result in the darkest values being cut away, leaving only the lightest. The last example is the pattern without cutoff. [img: ../../../_images/Krita_2_9_brushengine_texture_07.png]  Invert Pattern

Invert the pattern. [img: ../../../_images/Krita_2_9_brushengine_texture_06.png]  Auto Invert For Eraser

 

Added in version 5.3.0.  

Automatically inverts the pattern when the brush is switched into eraser mode. If “Invert Pattern” option is enabled, then switching to eraser mode disables inversion.  Brightness and Contrast

 

Added in version 3.3.1.  

Adjust the pattern with a simple brightness/contrast filter to make it easier to use. Because Subtract and Multiply work differently, it’s recommended to use different values with each: [img: ../../../_images/Krita_3_1_brushengine_texture_07.png]   

 

Added in version 4.4: Neutral Point adjustment:   Neutral Point

Adjust the gray value that is considered neutral in the texture. 0.5 keeps the texture as is; higher values make the texture darker, and lower values make the texture lighter. Works a bit differently from the brightness option, and is mostly useful to adjust existing textures to work well with Lightness Map and Gradient Map modes (though it can have applications with the other two modes).     

### Strength 

This allows you to set the texture to Sensors. It will use the cutoff to continuously draw lighter values of the texture (making the result darker). 

 

Added in version 4.4: For Lightness Map and Gradient Map modes, Strength controls how much of the texture is applied compared to how much of the selected paint color comes through.  [img: ../../../_images/Krita_2_9_brushengine_texture_03.png] 

 

See also 

[David Revoy describing the texture feature (old)](https://www.davidrevoy.com/article107/textured-brush-in-floss-digital-painting) [https://www.davidrevoy.com/article107/textured-brush-in-floss-digital-painting].