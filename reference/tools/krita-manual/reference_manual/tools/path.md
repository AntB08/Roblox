## Bezier Curve Tool 

[img: toolbeziercurve] 

You can draw curves by using this tool. Click [img: mouseleft] to indicate the starting point of the curve, then click again for consecutive control points of the curve. While creating a control point, drag to create the handles, they will show as red lines. 

With an intermediate control point (i.e. a point that is not the starting point and not the ending point), you can move the direction handles separately to have the curve enter and leave the point in different directions. After editing a point, you can just click on the canvas to continue adding points to the curve. When creating a path on a vector layer, the resulting path can be further edited with the [Shape Edit Tool](shape_edit.xhtml#shape-edit-tool).  [img: ../../_images/path_tool_usage.png]  

The path preview that shows while drawing a path. The start of the path is indicated with a white square, the preview for the path itself in black, and the red dotted lines being the control points for the current handle.   

Double-click [img: mouseleft] on any point of the curve or press the Enter key to finish drawing, or press the Esc key to cancel the entire curve. 

While drawing a curve, pressing the Ctrl key while dragging will push the handles both ways. The Alt key will create a sharp corner, and the Shift key will allow you to make a handle while at the end of the curve. [img: mouseright] will undo the last added point.  

### Tool Options 

 

Added in version 4.1.3:   Autosmooth Curve

Toggling this will have nodes initialize with smooth curves instead of angles. Untoggle this if you want to create sharp angles for a node. This will affect curve sharpness from dragging after clicking.     Angle Snapping Delta

The angle to snap to.  Activate Angle Snap

Angle snap will make it easier to have the next line be at a specific angle of the current. The angle is determined by the Angle Snapping Delta.