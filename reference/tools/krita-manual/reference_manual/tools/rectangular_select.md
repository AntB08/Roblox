## Rectangular Selection Tool 

[img: toolselectrect] 

This tool, represented by a rectangle with a dashed border, allows you to make [Selections](../../user_manual/selections.xhtml#selections-basics) in a rectangular shape. To create a rectangular selection simply [img: mouseleft] and drag on the area of the canvas that you wish to select. 

 

Important 

Most of the behavior of the Rectangular Selection Tool is common to all other selection tools, please make sure to read [Selections](../../user_manual/selections.xhtml#selections-basics) to learn more about this tool.   

### Hotkeys and Stickykeys  
- 

Ctrl + R selects this tool. 
- 

[img: mouseleft] + Shift constrains the selection to a perfect square. (Make sure to press [img: mouseleft] before Shift key) 
- 

[img: mouseleft] + Ctrl makes the selection resize from the center. (Make sure to press [img: mouseleft] before Ctrl key) 
- 

[img: mouseleft] + Alt allows you to move the selection. (Make sure to press [img: mouseleft] before Alt key) 
- 

Shift + [img: mouseleft] sets the subsequent selection to ‘add’. You can release the Shift key while dragging, but it will still be set to ‘add’. Same for the others. 
- 

Alt + [img: mouseleft] sets the subsequent selection to ‘subtract’. 
- 

Ctrl + [img: mouseleft] sets the subsequent selection to ‘replace’. 
- 

Shift + Alt + [img: mouseleft] sets the subsequent selection to ‘intersect’.  

 

Added in version 4.2:   
- 

Hovering your cursor over the dashed line of the selection, or marching ants as it is commonly called, turns the cursor into the move tool icon, which you [img: mouseleft] and drag to move the selection. 
- 

[img: mouseright] will open up a selection quick menu with amongst others the ability to edit the selection.   [img: Menu of rectangular selection] 

 

Added in version 5.0:   
- 

[img: mouseleft] + Ctrl + Alt allows you to rotate the rectangle around the marked corner. (Make sure to press [img: mouseleft] before Ctrl + Alt shortcut) 
- 

[img: mouseleft] + Ctrl + Alt + Shift allows you to rotate a constrained perfect square around the marked corner. (Make sure to press [img: mouseleft] before Ctrl + Alt + Shift shortcut)   

 

Hint 

To subtract a perfect square, you can do the following: Press Alt + [img: mouseleft] shortcut, then release the Alt key while dragging and press Shift key to constrain.  

 

Tip 

You can switch the behavior of the Alt key to use Ctrl key instead by toggling the switch in the [General Settings](../preferences/general_settings.xhtml#general-settings)    

### Tool Options [img: Rectangular selection options]  Mode

This option is explained in the [Pixel and Vector Selection Types](../../user_manual/selections.xhtml#pixel-vector-selection) section.  Action

This option is explained in the [Pixel and Vector Selection Types](../../user_manual/selections.xhtml#pixel-vector-selection) section.  Anti-aliasing

This toggles whether or not to give selections feathered edges. Some people prefer hard-jagged edges for their selections.   

 

Note 

Anti-aliasing is only available on Pixel Selection Mode.   Width

Shows you the current width while you are creating the selection. You can manually type the value and use the ‘Lock Width’ for your next selection to have the selected value.  Lock Width

Forces the next selection to have the current width.  Height

Shows you the current height while you are creating the selection. You can manually type the value and use the ‘Lock Height’ for your next selection to have the selected value.  Lock Height

Forces the next selection to have the current height.  Ratio

Shows the ratio between height and width of the selection. Similar to Height, and Width, you can manually type the value and use the ‘Lock Ratio’ for your next selection to have the selected value.  Lock Ratio

Forces the next selection to have the current ratio.   

 

Hint 

If you want your selection to be of specific size:  
- 

Type the width and height. 
- 

Press the Lock Width and Lock Height buttons. 
- 

[img: mouseleft] where you want your selection to be.   

 

Added in version 4.1.3:   Round X

The horizontal radius of the rectangle corners.  Round Y

The vertical radius of the rectangle corners.  Chain Link

When linked the aspect ratio between the roundness of X and Y coordinates will be locked. To disconnect the chain just click in the links and it will separate in two parts.