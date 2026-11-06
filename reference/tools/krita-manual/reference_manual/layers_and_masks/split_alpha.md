## Split Alpha 

Sometimes especially in the field of game development, artists need to work with the alpha channel of the texture separately. To assist such workflow, Krita has a special functionality called Split Alpha. It allows splitting alpha channel of a paint layer into a separate [Transparency Masks](transparency_masks.xhtml#transparency-masks). The artist can work on the transparency mask in an isolated environment and merge it back when he has finished working.  

### How to work with alpha channel of the layer  
- 

[img: mouseright] the paint layer in the layers docker. 
- 

Choose Split Alpha ‣ Alpha into Mask. 
- 

Use your preferred paint tool to paint on the Transparency Mask. Black paints transparency (see-through), white paints opacity (visible). Gray values paint semi-transparency. 
- 

If you would like to isolate alpha channel, enter Isolated Mode by [img: mouseright] + Isolate Layer (or the Alt + [img: mouseleft] shortcut). 
- 

When finished editing the Transparency Mask, [img: mouseright] on it and select Split Alpha ‣ Write as Alpha.    

### How to save a PNG texture and keep color values in fully transparent areas 

Normally, when saving an image to a file, all fully transparent areas of the image are filled with black color. It happens because when compositing the layers of the image, Krita drop color data of fully transparent pixels for efficiency reason. To avoid this of color data loss you can either avoid compositing of the image i.e. limit image to only one layer without any masks or effects, or use the following method:  
- 

[img: mouseright] the layer in the layers docker. 
- 

Choose Split Alpha ‣ Alpha into Mask. 
- 

[img: mouseright] on the created mask and select Split Alpha ‣ Save Merged….    

### Color channel values in transparent areas 

Krita treats all color channel values in fully transparent pixels as **undefined**. Effectively, it means that Krita will try to skip writing to (or reading from) a fully transparent pixel, unless it is really needed or explicitly requested. That is done for optimization purposes and allows Krita to speed up compositing the image by a lot.  

#### Example 1: erasing pixels on the image 

When erasing pixels with an eraser brush or when clearing a selection with Edit ‣ Clear action, the color data **is not actually cleared**. It is only the alpha channel that is zeroed, but color channels are kept intact. You can see it yourself if you try to apply Split Alpha ‣ Alpha into Mask on a layer after erasing with an eraser brush on it. 

To actually clear the color channels of transparent areas you need to apply a [Reset Transparent Filter](../filters/other.xhtml#reset-transparent-filter) on the image. It will zero-out all color channels of fully transparent pixels. 

Krita also has a special [Propagate Colors Filter](../filters/colors.xhtml#filter-propagate-colors). It fills the fully transparent areas with neighboring colors instead of just zeroing them out, which might be useful in some workflows.   

#### Example 2: compositing layers with color data inside fully transparent areas 

If you have multiple layers, which have any color data inside their fully transparent areas, the result of their merge **will not include this color data**. The resulting pixels will be just zeroed out. Obviously, you cannot blend two pixels with zero alpha, because you would have to divide by zero for that. 

For most workflows it just means that you should use Split Alpha ‣ Save Merged… action to properly save the result of this split alpha work. When exporting the result via File ‣ Export…, a compositing operation may (or may not) happen, clearing out the transparent areas.