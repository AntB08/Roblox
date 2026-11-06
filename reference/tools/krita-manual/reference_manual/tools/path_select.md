## Path Selection Tool 

[img: toolselectpath] 

This tool, represented by an ellipse with a dashed border and a curve control, allows you to make a [Selections](../../user_manual/selections.xhtml#selections-basics) of an area by drawing a path around it. Click where you want each point of the path to be. Click and drag to curve the line between points. Finally click on the first point you created to close your path.  

### Hotkeys and Sticky keys  
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

Hovering over a selection allows you to move it. 
- 

When not actively making a selection, [img: mouseright] will open up a selection quick menu with amongst others the ability to edit the selection. If you already began making a selection, [img: mouseright] will undo the last added point.   

 

Note 

You can switch the behavior of the Alt key to use the Ctrl key instead by toggling the switch in the [General Settings](../preferences/general_settings.xhtml#general-settings).    

### Tool Options 

 

Added in version 4.1.3:   Autosmooth Curve

Toggling this will have nodes initialize with smooth curves instead of angles. Untoggle this if you want to create sharp angles for a node. This will not affect curve sharpness from dragging after clicking.     Anti-aliasing

This toggles whether or not to give selections feathered edges. Some people prefer hard-jagged edges for their selections.   

 

Added in version 4.2:   Autosmooth Curve

Toggling this will have nodes initialize with smooth curves instead of angles. Untoggle this if you want to create sharp angles for a node. This will not affect curve sharpness from dragging after clicking.     Angle Snapping Delta

The angle to snap to.  Activate Angle Snap

Angle snap will make it easier to have the next line be at a specific angle of the current. The angle is determined by the Angle Snapping Delta.