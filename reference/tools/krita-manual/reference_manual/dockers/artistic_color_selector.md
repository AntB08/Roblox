## Artistic Color Selector Docker 

A color selector inspired by traditional color wheel and workflows.  

### Usage  [img: ../../_images/Krita_Artistic_Color_Selector_Docker.png]  

Artistic color selector with a gamut mask.   

Select hue and saturation on the wheel (5) and value on the value scale (4). [img: mouseleft] changes foreground color (6). [img: mouseright] changes background color (7). 

The blip shows the position of current foreground color on the wheel (black&white circle) and on the value scale (black&white line). Last selected swatches are outlined. 

Parameters of the wheel can be set in [Color wheel preferences](#artistic-color-selector-docker-wheel-preferences) menu (2). Selector settings are found under [Selector settings](#artistic-color-selector-docker-selector-settings) menu (3).  

#### Gamut Masking 

You can select and manage your gamut masks in the [Gamut Masks Docker](gamut_mask_docker.xhtml#gamut-mask-docker). 

In the gamut masking toolbar (1) you can toggle the selected mask off and on (left button). You can also rotate the mask with the rotation slider (right).    

### Color wheel preferences  [img: ../../_images/Krita_Artistic_Color_Selector_Docker_3.png]  

Color wheel preferences.    Sliders 1, 2, and 3

Adjust the number of steps of the value scale, number of hue sectors and saturation rings on the wheel, respectively.  Continuous Mode

The value scale and hue sectors can also be set to continuous mode (with the infinity icon on the right of the slider). If toggled on, the respective area shows a continuous gradient instead of the discrete swatches.  Invert saturation (4)

Changes the order of saturation rings within the hue sectors. By default, the wheel has gray in the center and most saturated colors on the perimeter. Invert saturation puts gray on the perimeter and most saturated colors in the center.  Reset to default (5)

Loads default values for the sliders 1, 2, and 3. These default values are configured in selector settings.     

### Selector settings  [img: ../../_images/Krita_Artistic_Color_Selector_Docker_2.png]  

Selector settings menu.    Selector Appearance (1) Show background color indicator

Toggles the bottom-right triangle with current background color.  Show numbered value scale

If checked, the value scale includes a comparative gray scale with lightness percentage.    Color Space (2)

Set the color model used by the selector. For detailed information on color models, see [Color Models](../../general_concepts/colors/color_models.xhtml#color-models).  Luma Coefficients (3)

If the selector’s color space is HSY, you can set custom Luma coefficients and the amount of gamma correction applied to the value scale (set to 1.0 for linear scale; see [Gamma and Linear](../../general_concepts/colors/linear_and_gamma.xhtml#linear-and-gamma)).    Gamut Masking Behavior (4)

The selector can be set either to Enforce gamut mask, so that colors outside the mask cannot be selected, or to Just show the shapes, where the mask is visible but color selection is not limited.  Default Selector Steps Settings

Values the color wheel and value scale will be reset to default when the Reset to default button in [Color wheel preferences](#artistic-color-selector-docker-wheel-preferences) is pressed.     

### External Info  
- 

[HSI and HSY for Krita’s advanced colour selector by Wolthera van Hövell tot Westerflier](https://wolthera.info/?p=726) [https://wolthera.info/?p=726]. 
- 

[The Color Wheel, Part 7 by James Gurney](https://gurneyjourney.blogspot.com/2010/02/color-wheel-part-7.html) [https://gurneyjourney.blogspot.com/2010/02/color-wheel-part-7.html].