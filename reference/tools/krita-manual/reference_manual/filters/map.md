## Map 

Filters that are signified by them mapping the input image.  

### Small Tiles 

Tiles the input image, using its own layer as output.   

### Phong Bumpmap [img: ../../_images/Krita-normals-tutoria_4.png] 

Uses the input image as a height-map to output a 3d something, using the phong-lambert shading model. Useful for checking one’s height maps during game texturing. Checking the Normal Map box will make it use all channels and interpret them as a normal map.   

### Round Corners 

Adds little corners to the input image.   

### Normalize 

This filter takes the input pixels, puts them into a 3d vector, and then normalizes (makes the vector size exactly 1) the values. This is helpful for normal maps and some minor image-editing functions.   

### Gradient Map [img: ../../_images/Krita_filter_gradient_map.png] 

Maps the lightness of the input to the selected gradient. Useful for fancy artistic effects. 

In 3.x you could only select predefined gradients. In 4.0, you can select gradients and change them on the fly, as well as use the gradient map filter as a filter layer or filter brush.  

#### Color Modes  
- 

**Blend:** smoothly blend colors between stops 
- 

**Nearest:** selects color from nearest stops 
- 

**Dither:** dithers between stop colors as per [Dithering Threshold Modes](#dithering-threshold-modes).     

### Palettize 

Maps the color of the input to the nearest color in the selected palette. Useful for limiting color in pixel art and for artistic effects. 

Optional dithering may be applied with the covered value range controlled by the spread value.  

#### Colorspace Modes  
- 

**Lab:** finds nearest colors in Lab colorspace 
- 

**RGB:** finds nearest colors in RGB colorspace    

#### Dithering Threshold Modes  
- 

**Pattern:** uses the lightness or alpha value of the selected pattern to threshold the input color between palette colors 
- 

**Noise:** uses a randomly generated value per pixel to threshold the input color between palette colors    

#### Dithering Color Modes  
- 

**Per-Component Offset:** independently offsets each color channel by the threshold amount, scaled by the offset scale value 
- 

**Nearest Colors:** finds the two nearest colors then applies the threshold amount to the relative distances of the two color to find the resulting color    

#### Dithering Alpha Modes  
- 

**Clip:** thresholds alpha at the clip position 
- 

**Index:** uses the selected palette index as the transparent color 
- 

**Dither:** applies dither to the alpha value as per [Dithering Threshold Modes](#dithering-threshold-modes)