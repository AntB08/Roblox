## Gamut Masks 

 

Added in version 4.2.  

Gamut masking is an approach to color formalized by James Gurney, based on the idea that any color scheme can be expressed as shapes cut out from the color wheel. 

It originates in the world of traditional painting, as a form of planning and premixing palettes. However, it translates well into digital art, enabling you to explore and analyze color, plan color schemes and guide your color choices. 

How does it work? 

You draw one or multiple shapes on top of the color wheel. You limit your color choices to colors inside the shapes. By leaving colors out, you establish a relationship between the colors, thus creating harmony. 

Gamut masking is available in both the Advanced and Artistic Color Selectors. 

 

See also  
- 

[Color Wheel Masking, Part 1 by James Gurney](https://gurneyjourney.blogspot.com/2008/01/color-wheel-masking-part-1.html) [https://gurneyjourney.blogspot.com/2008/01/color-wheel-masking-part-1.html] 
- 

[The Shapes of Color Schemes by James Gurney](https://gurneyjourney.blogspot.com/2008/02/shapes-of-color-schemes.html) [https://gurneyjourney.blogspot.com/2008/02/shapes-of-color-schemes.html] 
- 

[Gamut Masking Demonstration by James Gurney (YouTube)](https://youtu.be/qfE4E5goEIc) [https://youtu.be/qfE4E5goEIc]    

### Selecting a gamut mask 

For selecting and managing gamut masks open the [Gamut Masks Docker](../reference_manual/dockers/gamut_mask_docker.xhtml#gamut-mask-docker): Settings ‣ Dockers ‣ Gamut Masks.  [img: ../_images/Krita_Gamut_Mask_Docker.png]  

Gamut Masks docker   

In this docker you can choose from several classic gamut masks, like the ‘Atmospheric Triad’, ‘Complementary’, or ‘Dominant Hue With Accent’. You can also duplicate those masks and make changes to them (3,4), or create new masks from scratch (2). 

Clicking the thumbnail icon (1) of the mask applies it to the color selectors. 

 

See also  
- 

[Gamut Masks Docker](../reference_manual/dockers/gamut_mask_docker.xhtml#gamut-mask-docker)     

### In the color selector 

You can rotate an existing mask directly in the color selector, by dragging the rotation slider on top of the selector (2). 

The mask can be toggled off and on again by the toggle mask button in the top left corner (1).  [img: ../_images/GamutMasks_Selectors.png]  

Advanced and Artistic color selectors with a gamut mask   

 

See also  
- 

[Artistic Color Selector Docker](../reference_manual/dockers/artistic_color_selector.xhtml#artistic-color-selector-docker) 
- 

[Advanced Color Selector](../reference_manual/dockers/advanced_color_selector.xhtml#advanced-color-selector-docker)     

### Editing/creating a custom gamut mask 

 

Tip 

To rotate a mask around the center point use the rotation slider in the color selector.  

If you choose to create a new mask, edit, or duplicate selected mask, the mask template documents open as a new view (1). 

There you can create new shapes and modify the mask with standard vector tools ([Vector Graphics](vector_graphics.xhtml#vector-graphics)). Please note, that the mask is intended to be composed of basic vector shapes. Although interesting results might arise from using advanced vector drawing techniques, not all features are guaranteed to work properly (e.g. grouping, vector text, etc.). 

 

Warning 

Transformations done through the transform tool or layer transform cannot be saved in a gamut mask. The thumbnail image reflects the changes, but the individual mask shapes do not.  

You can Preview the mask in the color selector (4). If you are satisfied with your changes, Save the mask (5). Cancel (3) will close the editing view without saving your changes.  [img: ../_images/Krita_Gamut_Mask_Docker_2.png]  

Editing a gamut mask     

### Importing and exporting 

Gamut masks can be imported and exported in bundles in the Resource Manager. See [Resource Management](../reference_manual/resource_management.xhtml#resource-management) for more information.