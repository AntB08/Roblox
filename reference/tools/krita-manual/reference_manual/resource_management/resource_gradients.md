## Gradients  

### Accessing a Gradient 

The Gradients configuration panel is accessed by clicking the Gradients icon (usually the icon next to the disk). [img: ../../_images/Gradient_Toolbar_Panel.png] 

Gradients are configurations of blending between colors. Krita provides over a dozen preset dynamic gradients for you to choose from. In addition, you can design and save your own. 

Some typical uses of gradients are:  
- 

Fill for vector shapes. 
- 

Gradient tool 
- 

As a source of color for the pixel brush.  

There is no gradients docker. They can only be accessed through the gradient “quick-menu” in the toolbar.   

### Editing a Gradient 

Krita has two gradient types:  
- 

Segmented Gradients, which are compatible with GIMP, have many different features but are also a bit complicated to make. 
- 

Stop Gradients, which are saved as SVG files and similar to how most applications do their gradients, but has less features than the segmented gradient.  

Initially we could only make segmented gradients in Krita, but in 3.0.2 we can also make stop gradients. [img: ../../_images/Krita_new_gradient.png] 

You can make a new gradient by going into the drop-down and selecting the gradient type you wish to have. By default Krita will make a stop-gradient.  

#### Stop Gradients 

Stop gradients are simply a list of *gradient stops*. A gradient stop has two properties associated with it: a position and a color. 

 

Added in version 4.4: Gradients can have stops that use the currently selected Foreground or Background colors. This makes them dynamic: if a gradient uses the Foreground or Background colors then changing those will also change the gradient appearance.  

As per SVG spec, you can make a sudden change between stops by moving them close together. The stops will overlap, but you can still drag them around: [img: ../../_images/Krita_stop_sudden_change.png] 

Right now, stop gradients are the only ones that are capable of handling [colors outside of sRGB](../../general_concepts/colors/color_space_size.xhtml#color-space-size).   

#### Segmented Gradients 

Segmented gradients are a list of *gradient segments*. A gradient segment has the following properties:  
- 

A start and end positions that denote where the segment is placed inside the gradient. 
- 

A start and end colors associated with the start and end positions. 

>  

 

Added in version 4.4: Gradients can have segment endpoints that use the currently selected Foreground or Background colors, and those endpoints can be transparent. This makes them dynamic: if a gradient uses the Foreground or Background colors then changing those will also change the gradient appearance. These features allow full compatibility with GIMP gradients.    
- 

A blending strategy used to fill the segment inbetween the extreme colors. This strategy is formed by two different properties: 

>  

 
- 

A color model: 

>  

[img: ../../_images/Krita_gradient_segment_color_model.png]  
- 

RGB - Does the blending in RGB model. 
- 

HSV clockwise - Blends the two colors using the HSV model, and follows the hue clockwise (red-yellow-green-cyan-blue-purple). The above screenshot is an example of this. 
- 

HSV counter-clock wise - Blends the color as the previous options, but then counter-clockwise.    
- 

An interpolation function used to determine how the colors should vary along the segment: 

>  

[img: ../../_images/Krita_gradient_segment_blending.png]  
- 

Linear - Does a linear blending between both extreme colors. 
- 

Curved - This causes the mix to ease-in and out faster. 
- 

Sine - Uses a sine function. This causes the mix to ease in and out slower. 
- 

Sphere, increasing - This puts emphasis on the later color during the mix. 
- 

Sphere, decreasing - This puts emphasis on the first color during the mix.       
- 

A segment middle position used to set where the *center* color obtained with the blending strategy should go. The visual effect is as if you stretched one half of the segment and squashed the other. 

>  

[img: ../../_images/Krita_gradient_segment_mid_position.png]