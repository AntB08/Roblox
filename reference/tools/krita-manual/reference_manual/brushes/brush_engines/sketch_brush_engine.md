## Sketch Brush Engine [img: ../../../_images/sketchbrush.svg] 

A line based brush engine, based on the Harmony brushes. Very messy and fun.  

### Parameters 

Has the following parameters:  
- 

[Brush Tips](../brush_settings/brush_tips.xhtml#option-brush-tip) 
- 

[Blending Modes](../../blending_modes.xhtml#blending-modes) 
- 

[Opacity and Flow](../brush_settings/opacity_and_flow.xhtml#option-opacity-n-flow) 
- 

[Size](../brush_settings/options.xhtml#option-size) 
- 

[Ratio](../brush_settings/options.xhtml#option-ratio) 
- 

[Line Width](#option-line-width) 
- 

[Offset Scale](#option-offset-scale) 
- 

[Density](#option-sketch-density) 
- 

[Rotation](../brush_settings/options.xhtml#option-rotation) 
- 

[Airbrush](../brush_settings/options.xhtml#option-airbrush)    

### Line Width 

The width of the rendered lines. [img: ../../../_images/Krita_2_9_brushengine_sketch_linewidth.png]   

### Offset Scale 

When curve lines are formed, this value roughly determines the distance from the curve lines to the connection lines:  
- 

This is a bit misleading, because a value of 0% and a value of 100% give similar outputs, as do a value of say 30% and 70%. You could think that the actual value range is between 50% and 200%. 
- 

0% and 100% correspond to the curve lines touching the connection lines exactly. 
- 

Above 100%, the curve lines will go further than the connection lines, forming a fuzzy effect.  [img: ../../../_images/Krita_2.9_brushengine_sketch_offset.png] [img: ../../../_images/Krita-sketch_offset_scale2.png]   

### Density 

The density of the lines. This one is highly affected by the Brush-tip, as determined by the Distance Density toggle. [img: ../../../_images/Krita_2.9_brushengine_sketch_density.png]  Use Distance Density

The further the line covered is from the center of the area of effect, the less the density of the resulting curve lines.  Magnetify

Magnetify is *on* by default. It’s what causes curve lines to form between two close line sections, as though the curve lines are attracted to them like magnets. With Magnetify *off*, the curve line just forms on either side of the current active portion of your connection line. In other words, your line becomes fuzzier when another portion of the line is nearby, but the lines don’t connect to said previous portion.  Random RGB

Causes some slight RGB variations.  Random Opacity

The curve lines get random opacity. This one is barely visible, so for the example I used line width 12 and 100% opacity.  Distance Opacity

The distance based opacity. When you move your pen fast when painting, the opacity will be calculated based on the distance from the center of the effect area.  Simple Mode

This mode exists for performance reasons, and doesn’t affect the output in a visible way. Check this for large brushes or thick lines for faster rendering.  Paint Connection Line

What appears to be the connection line is usually made up of an actual connection line and many smaller curve lines. The many small curve lines make up the majority of the line. For this reason, the only time this option will make a visible difference is if you’re drawing with 0% or near 0% density, and with a thick line width. The rest of the time, this option won’t make a visible difference.  Anti-aliasing

This applies anti-aliasing to the lines, giving a smoother feel. 

 

Added in version 5.1.