## HSX 

Krita has four different HSX coordinate systems. The difference between them is how they handle tone.  

### HSI 

HSI is a color coordinate system, using Hue, Saturation and Intensity to categorize a color. Hue is roughly the wavelength, whether the color is red, yellow, green, cyan, blue or purple. It is measured in 360°, with 0 being red. Saturation is the measurement of how close a color is to gray. Intensity, in this case, is the tone of the color. What makes intensity special is that it recognizes yellow (rgb:1,1,0) having a higher combined rgb value than blue (rgb:0,0,1). This is a non-linear tone dimension, which means it’s gamma-corrected.   

### HSL 

HSL is a color coordinate system that describes colors in Hue, Saturation and Lightness. Lightness specifically puts both yellow (rgb:1,1,0), blue (rgb:0,0,1) and middle gray (rgb:0.5,0.5,0.5) at the same lightness (0.5).   

### HSV 

HSV, occasionally called HSB, is a color coordinate system that measures colors in Hue, Saturation, and Value (also called Brightness). Value or Brightness specifically refers to strength at which the pixel-lights on your monitor have to shine. It sets Yellow (rgb:1,1,0), Blue (rgb:0,0,1) and White (rgb:1,1,1) at the same Value (100%).   

### HSY 

HSY is a color coordinate system categorizing colors in Hue, Saturation and Luminosity. Well, not really, it uses Luma instead of true luminosity, the difference being that Luminosity is linear while Luma is gamma-corrected and just weights the rgb components. Luma is based on scientific studies of how much light a color reflects in real-life. While like intensity it acknowledges that yellow (rgb:1,1,0) is lighter than blue (rgb:0,0,1), it also acknowledges that yellow (rgb:1,1,0) is lighter than cyan (rgb:0,1,1), based on these studies.   

### HSX Blending Modes  

#### Color, HSV, HSI, HSL, HSY 

This takes the Luminosity/Value/Intensity/Lightness of the colors on the lower layer, and combines them with the Saturation and Hue of the upper pixels. We refer to Color HSY as ‘Color’ in line with other applications.  [img: ../../_images/Blending_modes_Color_HSI_Gray_0.4_and_Gray_0.5.png]  

Left: **Normal**. Right: **Color HSI**.    [img: ../../_images/Blending_modes_Color_HSI_Light_blue_and_Orange.png]  

Left: **Normal**. Right: **Color HSI**.    [img: ../../_images/Blending_modes_Color_HSI_Sample_image_with_dots.png]  

Left: **Normal**. Right: **Color HSI**.    [img: ../../_images/Blending_modes_Color_HSL_Sample_image_with_dots.png]  

Left: **Normal**. Right: **Color HSL**.    [img: ../../_images/Blending_modes_Color_HSV_Sample_image_with_dots.png]  

Left: **Normal**. Right: **Color HSV**.    [img: ../../_images/Blending_modes_Color_Sample_image_with_dots.png]  

Left: **Normal**. Right: **Color**.     

#### Hue HSV, HSI, HSL, HSY 

Takes the saturation and tone of the lower layer and combines them with the hue of the upper-layer. Tone in this case being either Value, Lightness, Intensity or Luminosity.  [img: ../../_images/Blending_modes_Hue_HSI_Sample_image_with_dots.png]  

Left: **Normal**. Right: **Hue HSI**.    [img: ../../_images/Blending_modes_Hue_HSL_Sample_image_with_dots.png]  

Left: **Normal**. Right: **Hue HSL**.    [img: ../../_images/Blending_modes_Hue_HSV_Sample_image_with_dots.png]  

Left: **Normal**. Right: **Hue HSV**.    [img: ../../_images/Blending_modes_Hue_Sample_image_with_dots.png]  

Left: **Normal**. Right: **Hue**.     

#### Increase Value, Lightness, Intensity or Luminosity. 

Similar to Lighten, but specific to tone. Checks whether the upper layer’s pixel has a higher tone than the lower layer’s pixel. If so, the tone is increased, if not, the lower layer’s tone is maintained.  [img: ../../_images/Blending_modes_Increase_Intensity_Sample_image_with_dots.png]  

Left: **Normal**. Right: **Increase Intensity**.    [img: ../../_images/Blending_modes_Increase_Lightness_Sample_image_with_dots.png]  

Left: **Normal**. Right: **Increase Lightness**.    [img: ../../_images/Blending_modes_Increase_Value_Sample_image_with_dots.png]  

Left: **Normal**. Right: **Increase Value**.    [img: ../../_images/Blending_modes_Increase_Luminosity_Sample_image_with_dots.png]  

Left: **Normal**. Right: **Increase Luminosity**.     

#### Increase Saturation HSI, HSV, HSL, HSY 

Similar to Lighten, but specific to Saturation. Checks whether the upper layer’s pixel has a higher Saturation than the lower layer’s pixel. If so, the Saturation is increased, if not, the lower layer’s Saturation is maintained.  [img: ../../_images/Blending_modes_Increase_Saturation_HSI_Sample_image_with_dots.png]  

Left: **Normal**. Right: **Increase Saturation HSI**.    [img: ../../_images/Blending_modes_Increase_Saturation_HSL_Sample_image_with_dots.png]  

Left: **Normal**. Right: **Increase Saturation HSL**.    [img: ../../_images/Blending_modes_Increase_Saturation_HSV_Sample_image_with_dots.png]  

Left: **Normal**. Right: **Increase Saturation HSV**.    [img: ../../_images/Blending_modes_Increase_Saturation_Sample_image_with_dots.png]  

Left: **Normal**. Right: **Increase Saturation**.     

#### Intensity 

Takes the Hue and Saturation of the lower layer and outputs them with the intensity of the upper layer.  [img: ../../_images/Blending_modes_Intensity_Sample_image_with_dots.png]  

Left: **Normal**. Right: **Intensity**.     

#### Value 

Takes the Hue and Saturation of the lower layer and outputs them with the Value of the upper layer.  [img: ../../_images/Blending_modes_Value_Sample_image_with_dots.png]  

Left: **Normal**. Right: **Value**.     

#### Lightness 

Takes the Hue and Saturation of the lower layer and outputs them with the Lightness of the upper layer.  [img: ../../_images/Blending_modes_Lightness_Sample_image_with_dots.png]  

Left: **Normal**. Right: **Lightness**.     

#### Luminosity 

As explained above, actually Luma, but called this way as it’s in line with the terminology in other applications. Takes the Hue and Saturation of the lower layer and outputs them with the Luminosity of the upper layer. The most preferred one of the four Tone blending modes, as this one gives fairly intuitive results for the Tone of a hue.  [img: ../../_images/Blending_modes_Luminosity_Sample_image_with_dots.png]  

Left: **Normal**. Right: **Luminosity**.     

#### Saturation HSI, HSV, HSL, HSY 

Takes the Intensity and Hue of the lower layer, and outputs them with the HSI saturation of the upper layer.  [img: ../../_images/Blending_modes_Saturation_HSI_Sample_image_with_dots.png]  

Left: **Normal**. Right: **Saturation HSI**.    [img: ../../_images/Blending_modes_Saturation_HSL_Sample_image_with_dots.png]  

Left: **Normal**. Right: **Saturation HSL**.    [img: ../../_images/Blending_modes_Saturation_HSV_Sample_image_with_dots.png]  

Left: **Normal**. Right: **Saturation HSV**.    [img: ../../_images/Blending_modes_Saturation_Sample_image_with_dots.png]  

Left: **Normal**. Right: **Saturation**.     

#### Decrease Value, Lightness, Intensity or Luminosity 

Similar to Darken, but specific to tone. Checks whether the upper layer’s pixel has a lower tone than the lower layer’s pixel. If so, the tone is decreased, if not, the lower layer’s tone is maintained.  [img: ../../_images/Blending_modes_Decrease_Intensity_Gray_0.4_and_Gray_0.5.png]  

Left: **Normal**. Right: **Decrease Intensity**.    [img: ../../_images/Blending_modes_Decrease_Intensity_Light_blue_and_Orange.png]  

Left: **Normal**. Right: **Decrease Intensity**.    [img: ../../_images/Blending_modes_Decrease_Intensity_Sample_image_with_dots.png]  

Left: **Normal**. Right: **Decrease Intensity**.    [img: ../../_images/Blending_modes_Decrease_Lightness_Sample_image_with_dots.png]  

Left: **Normal**. Right: **Decrease Lightness**.    [img: ../../_images/Blending_modes_Decrease_Value_Sample_image_with_dots.png]  

Left: **Normal**. Right: **Decrease Value**.    [img: ../../_images/Blending_modes_Decrease_Luminosity_Sample_image_with_dots.png]  

Left: **Normal**. Right: **Decrease Luminosity**.     

#### Decrease Saturation HSI, HSV, HSL, HSY 

Similar to Darken, but specific to Saturation. Checks whether the upper layer’s pixel has a lower Saturation than the lower layer’s pixel. If so, the Saturation is decreased, if not, the lower layer’s Saturation is maintained.  [img: ../../_images/Blending_modes_Decrease_Saturation_HSI_Gray_0.4_and_Gray_0.5.png]  

Left: **Normal**. Right: **Decrease Saturation HSI**.    [img: ../../_images/Blending_modes_Decrease_Saturation_HSI_Light_blue_and_Orange.png]  

Left: **Normal**. Right: **Decrease Saturation HSI**.    [img: ../../_images/Blending_modes_Decrease_Saturation_HSI_Sample_image_with_dots.png]  

Left: **Normal**. Right: **Decrease Saturation HSI**.    [img: ../../_images/Blending_modes_Decrease_Saturation_HSL_Sample_image_with_dots.png]  

Left: **Normal**. Right: **Decrease Saturation HSL**.    [img: ../../_images/Blending_modes_Decrease_Saturation_HSV_Sample_image_with_dots.png]  

Left: **Normal**. Right: **Decrease Saturation HSV**.    [img: ../../_images/Blending_modes_Decrease_Saturation_Sample_image_with_dots.png]  

Left: **Normal**. Right: **Decrease Saturation**.     

#### Tint 

 

Added in version 5.3.  

Tint applies the destination by taking the input and interpolating it between white and the destination color. This is useful for images where you want to preserve any mid-tones while still colorizing them, and allows colorizing with black.