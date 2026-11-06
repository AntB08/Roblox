## Selections 

Selections allow you to pick a specific area of your artwork to change. This is useful when you want to move a section of the painting, transform it, or paint on it without affecting the other sections. There are many selection tools available that select in different ways. Once an area is selected, most tools will stay inside that area. On that area you can draw or use gradients to quickly get colored and/or shaded shapes with hard edges. The selections in Krita are not limited to the canvas boundary, so you can also select portions of the painting that are beyond the canvas boundary.  

### Creating Selections 

The most common selection tools all exist at the bottom of the toolbox. Each tool selects things slightly differently. The links for each tool go into a more detailed description of how to use it.   
| 

[Rectangular Selection Tool](../reference_manual/tools/rectangular_select.xhtml#rectangle-selection-tool) |  

[img: toolselectrect] |  

Select the shape of a square. |   
| 

[Elliptical Selection Tool](../reference_manual/tools/elliptical_select.xhtml#ellipse-selection-tool) |  

[img: toolselectellipse] |  

Select the shape of a circle. |   
| 

[Polygonal Selection Tool](../reference_manual/tools/polygonal_select.xhtml#polygonal-selection-tool) |  

[img: toolselectpolygon] |  

Click where you want each point of the Polygon to be. Double click to end your polygon and finalize your selection area. Use the Shift + Z shortcut to undo last point. |   
| 

[Freehand Selection Tool](../reference_manual/tools/freehand_select.xhtml#freehand-selection-tool) |  

[img: toolselectfreehand] |  

freehand/Lasso tool is used for a rough selection by drawing the selection outline freehand on the canvas. |   
| 

[Similar Color Selection Tool](../reference_manual/tools/similar_select.xhtml#similar-selection-tool) |  

[img: toolselectsimilar] |  

Similar Color Selection Tool. |   
| 

[Contiguous Selection Tool](../reference_manual/tools/contiguous_select.xhtml#contiguous-selection-tool) |  

[img: toolselectcontiguous] |  

Contiguous or “Magic Wand” selects a field of color. Adjust the Fuzziness to allow more changes in the field of color, by default limited to the current layer. |   
| 

[Path Selection Tool](../reference_manual/tools/path_select.xhtml#path-selection-tool) |  

[img: toolselectpath] |  

Path select an area based on a vector path, click to get sharp corners or drag to get flowing lines and close the path with the Enter key or connecting back to the first point. |   
| 

[Magnetic Selection Tool](../reference_manual/tools/magnetic_select.xhtml#magnetic-selection-tool) |  

[img: toolselectmagnetic] |  

Magnetic selection makes a free hand selection where the selection snaps to sharp contrasts in the image. |     

 

Note 

You can also use the transform tools on your selection, a great way to try different proportions on parts of your image.    

### Editing Selections 

The tool options for each selection tool gives you the ability to modify your selection.   
| 

Action |  

Modifier |  

Description |   
| 

Replace |  

Ctrl |  

Replace the current selection. |   
| 

Intersect |  

Shift + Alt |  

Get the overlapping section of both selections. |   
| 

Add |  

Shift |  

Add the new selection to the current selection. |   
| 

Subtract |  

Alt |  

Subtract the selection from the current selection. |   
| 

Symmetric Difference |  

– |  

Make a selection where both the new and current do not overlap. |     

You can change this in [Tools Settings](../reference_manual/preferences/general_settings.xhtml#tool-options-settings). 

If you hover over a selection with a selection tool and no selection is activated, you can move it. To quickly go into transform mode, [img: mouseright] and select Edit Selection.   

### Removing Selections 

If you want to delete the entire selection, the easiest way is to deselect everything. Select ‣ Deselect. Shortcut Ctrl + Shift + A. When you have one of the selection tool active, and the mode of selection is in intersect, replace or symmetric difference then you can also deselect by just [img: mouseleft] anywhere on the canvas.   

### Display Modes 

In the bottom left-hand corner of the status bar there is a button to toggle how the selection is displayed. The two display modes are the following: (Marching) Ants and Mask. The red color with Mask can be changed in the preferences. You can edit the color under Settings ‣ Configure Krita… ‣ Display ‣ Selection Overlay. If there is no selection, this button will not do anything. [img: ../_images/Ants-displayMode.jpg] 

Ants display mode (default) is best if you want to see the areas that are not selected. [img: ../_images/Mask-displayMode.jpg] 

Mask display mode is good if you are interested in seeing the various transparency levels for your selection. For example, when you have a selection with very soft edges due using feathering. 

 

Changed in version 4.2: Mask mode is activated as well when a selection mask is the active layer so you can see the different selection levels.    

### Global Selection Mask (Painting a Selection) 

The global Selection Mask is your selection that appears on the layers docker. By default, this is hidden, so you will need to make it visible via Select ‣ Show Global Selection Mask. [img: ../_images/Global-selection-mask.png] 

Once the global Selection Mask is shown, you will need to create a selection. The benefit of using this is that you can paint your selection using any of the normal painting tools, including the transform and move. The information is saved as grayscale. 

You can enter the global selection mask mode quickly from the selection tools by doing [img: mouseright] and select Edit Selection.   

### Selection from layer transparency 

You can create a selection based on a layer’s transparency by right-clicking on the layer in the layer docker and selecting Select Opaque from the context menu. 

 

Added in version 4.2: You can also do this for adding, subtracting and intersecting by going to Select ‣ Select Opaque, where you can find specific actions for each. 

If you want to quickly select parts of layers, you can hold the Ctrl + [img: mouseleft] shortcut on the layer *thumbnail*. To add a selection do Ctrl + Shift + [img: mouseleft], to remove Ctrl + Alt + [img: mouseleft] and to intersect Ctrl + Shift + Alt + [img: mouseleft]. This works with any mask that has pixel or vector data (so everything but transform masks).    

### Pixel and Vector Selection Types 

Vector selections allow you to modify your selection with vector anchor tools. Pixel selections allow you to modify selections with pixel information. They both have their benefits and disadvantages. You can convert one type of selection to another. [img: ../_images/Vector-pixel-selections.jpg] 

When creating a selection, you can select what type of selection you want from the Mode in the selection tool options: Pixel or Vector. By default this will be Vector. 

Vector selections can be modified as any other [vector shape](vector_graphics.xhtml#vector-graphics) with the [Shape Selection Tool](../reference_manual/tools/shape_selection.xhtml#shape-selection-tool), if you try to paint on a vector selection mask it will be converted into a pixel selection. You can also convert vector shapes to selection. In turn, vector selections can be made from vector shapes, and vector shapes can be converted to vector selections using the options in the Selection menu. Krita will add a new vector layer for this shape. 

One of the most common reasons to use vector selections is that they give you the ability to move and transform a selection without the kind of resize artifacts you get with a pixel selection. You can also use the [Shape Edit Tool](../reference_manual/tools/shape_edit.xhtml#shape-edit-tool) to change the anchor points in the selection, allowing you to precisely adjust bezier curves or add corners to rectangular selections. 

If you started with a pixel selection, you can still convert it to a vector selection to get these benefits. Go to Select ‣ Convert to Vector Selection. 

 

Note 

If you have multiple levels of transparency when you convert a selection to vector, you will lose the semi-transparent values.    

### Selection Action Bar 

This assistant toolbar is used to perform actions on selections. It appears when you have a selection active, and it provides quick access to common selection-related actions. 

Go to Settings ‣ Configure Krita.. ‣ General ‣ Tools, to enable or disable the Selection Action Bar.  Actions Select All

Select all content in the current layer.  Deselect

Deselect the current selection.  Invert Selection

Invert the current selection, selecting everything that was not selected before.  Crop to Selection

Crop to the current selection, removing everything outside of it.  Fill with Foreground Color

Fill the current selection with the foreground color.  Copy to New Layer

Copy the current selection to a new layer.  Drag Handle

Click and drag this handle to move the selection around the canvas.       

### Common Shortcuts while Using Selections  
- 

Copy – Ctrl + C or Ctrl + Ins 
- 

Paste – Ctrl + V or Shift + Ins 
- 

Cut – Ctrl + X, Shift + Del 
- 

Copy From All Layers – Ctrl + Shift + C 
- 

Copy Selection to New Layer – Ctrl + Alt + J 
- 

Cut Selection to New Layer – Ctrl + Shift + J 
- 

Display or hide selection with Ctrl + H 
- 

Select Opaque – Ctrl + [img: mouseleft] on layer thumbnail. 
- 

Select Opaque (Add) – Ctrl + Shift + [img: mouseleft] on layer thumbnail. 
- 

Select Opaque (Subtract) – Ctrl + Alt + [img: mouseleft] on layer thumbnail. 
- 

Select Opaque (Intersect) – Ctrl + Shift + Alt + [img: mouseleft] on layer thumbnail.