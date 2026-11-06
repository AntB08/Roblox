## Pop-up Palette Settings 

 

Added in version 5.0.  

These settings affect the [Pop-up Palette](../popup-palette.xhtml#pop-up-palette).  Number of Brush Presets

This determines the number of available slots to offer the brush presets of the selected tag.  Palette Size

This determines the diameter of the circular main element.  Color Selector

This offers two options for the color selector in the palette center:  sRGB Triangle Selector

This is a minimalistic HSV selector with a triangle to select Value and Saturation and a ring to select the Hue. The triangle tip with the most intense color always points to the selected Hue on the ring. As the name implies, this selector is limited to sRGB color gamut.  Wide Gamut Selector

This selector supports multiple configurations derived from [Color Selector Settings](color_selector_settings.xhtml#color-selector-settings). To fit the circular design, linear sliders become mirrored arcs instead. It also adapts to the color space of the current layer in order to offer the full gamut. 

 

Note 

The circular design is not suitable for a 4-channel selector, so CMYK will fall back to sRGB. Furthermore, unlike the sRGB Triangle Selector, this selector currently lacks automatic gamut limitation, so it will show (and select) colors out of gamut for CMYK.     Selector Size

The size of the color selector in the center of the palette.  Dynamically Adjust Slot Count

When having a tag with less presets than there are slots, the slot count will be adjusted automatically. Some people prefer this, while others prefer the slot count to be static.  Show Color History Ring

Enables the color history ring around the color selector in the pop-up palette.  Show Rotation Ring

Enables the canvas rotation ring on the pop-up palette.