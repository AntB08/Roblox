## Deform Brush Engine [img: ../../../_images/deformbrush.svg] 

The Deform Brush is a brush that allows you to pull and push pixels around. It’s quite similar to the [Liquify](../../tools/transform.xhtml#liquify-mode), but where liquify has higher quality, the deform brush has the speed.  

### Options  
- 

[Brush Tips](../brush_settings/brush_tips.xhtml#option-brush-tip) 
- 

[Deform Options](#option-deform) 
- 

[Blending Modes](../../blending_modes.xhtml#blending-modes) 
- 

[Opacity and Flow](../brush_settings/opacity_and_flow.xhtml#option-opacity-n-flow) 
- 

[Size](../brush_settings/options.xhtml#option-size) 
- 

[Rotation](../brush_settings/options.xhtml#option-rotation) 
- 

[Airbrush](../brush_settings/options.xhtml#option-airbrush)    

### Deform Options  [img: ../../../_images/Krita_deform_brush_examples.png]  

1: undeformed, 2: Move, 3: Grow, 4: Shrink, 5: Swirl Counter Clock Wise, 6: Swirl Clockwise, 7: Lens Zoom In, 8: Lens Zoom Out   

These decide what strangeness may happen underneath your brush cursor.  Grow

This bubbles up the area underneath the brush-cursor.  Shrink

This pinches the Area underneath the brush-cursor.  Swirl Counter Clock Wise

Swirls the area counter clock wise.  Swirl Clock Wise

Swirls the area clockwise.  Move

Nudges the area to the painting direction.  Color Deformation

This seems to randomly rearrange the pixels underneath the brush.  Lens Zoom In

Literally paints a enlarged version of the area.  Lens Zoom Out

Paints a minimized version of the area.    [img: ../../../_images/Krita_deform_brush_colordeform.png]  

Showing color deform.    Deform Amount

Defines the strength of the deformation.    [img: ../../../_images/Krita_deform_brush_bilinear.png]  

Bilinear Interpolation    Bilinear Interpolation

Smoothens the result. This causes calculation errors in 16bit.  Use Counter

Slows down the deformation subtlety.    [img: ../../../_images/Krita_deform_brush_useundeformed.png]  

Without ‘use undeformed’ to the left and with to the right.    Use Undeformed Image

Samples from the previous version of the image instead of the current. This works better with some deform options than others. Move for example seems to almost stop working, but it works really well with Grow.