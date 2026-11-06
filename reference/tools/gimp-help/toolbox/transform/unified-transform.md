## Unified Transform

 Tools
 Unified Transform

 Unified Transform

## Unified Transform tool

 This tool combines several tools: Rotate, Scale, Shear and Perspective, performing one or 
 several of these actions at once in one single operation.
 Combining two or more options gives you almost infinite possibilities of 
 transformation.

 As the other transformation tools, this tool works on the active layer 
 (default).

 After selecting the Unified Transform tool in the toolbox, click on the 
 image window. Several elements appear on the image window:

 Several kinds of handles, on 
 the edges:

 Diamonds for shearing

 Squares for scaling.

 Small diamonds for changing perspective, in large squares for 
 Scaling.

 Click and drag a handle to perform the action of the concerned tool

 A circle with a cross inside at 
 the center of the image window for the pivot. Click and 
 drag this circle to move the pivot. It can be placed out 
 of the image window, and even where you want on screen (but you can 
 no longer see it, unless you enlarge the image window).

 The mouse pointer comes with small 
 icons which vary according to position:

 On the layer: Move icon,

 Outside the layer: Rotate icon,

 On handles: Shear or perspective or Scale 
 icon,

 On rotation center circle: Move icon and 
 Rotation icon.

 The status bar, at the bottom of 
 the image window, displays the name of the current tool.

## Activating the Tool

 There are different possibilities to activate the tool:

 From the main menu:

 Tools
 Transform Tools
 Unified transform
 .

 By clicking the tool icon

 in the Toolbox.

 By pressing the ShiftT 
 keyboard shortcut.

## Options

## Tool Options Dialog

 Transform
 Direction
 Interpolation
 Clipping
 Show image preview
 Guides

 Constrain

 Move: when this option is unchecked, moving 
 the layer is smooth. Checking the option constrains movement to 45° 
 from center.

 Scale: when this option is checked, the aspect 
 ratio is preserved.

## Scale Constraint Option

 "Scale" option under "Constrain" not checked;
 "Scale" option under "From pivot" not checked

 "Scale" option under "Constrain" checked;
 "Scale" option under "From pivot" not checked

 Rotate: default rotation is smooth. When this 
 option is checked, rotation goes by 15° steps.

 Shear: normally, to shear the layer, 
 you drag the corresponding icon along a layer edge. If this option 
 is unchecked (default), you may move away from this edge. If this 
 option is checked, shear handles remain on this edge.

 Perspective: normally, to change perspective, 
 you drag the corresponding icon along a layer edge. If this option 
 is unchecked (default), you may move away from this edge. If this 
 option is checked, perspective handles remain on this edge or on a 
 diagonal.

## Perspective Constraint Option

 "Perspective" option under "Constrain" not checked;
 "Perspective" option under "From pivot" not checked

 "Perspective" option under "Constrain" checked;
 "Perspective" option under "From pivot" not checked

 From pivot

 Scale: 

## Scale from pivot

 "Scale" option under "Constrain" checked;
 "Scale" option under "From pivot" not checked

 "Scale" option under "Constrain" checked;
 "Scale" option under "From pivot" also checked

 Shear: 
 When this option is unchecked (default), the opposite edge is fixed 
 and the pivot moves with shearing. When the option 
 is checked, shearing is performed around a fixed pivot and the 
 opposite side is sheared by the same amount, but in the opposite 
 direction.

 Perspective: when this option is checked, the 
 position of pivot is maintained.

## Perspective from pivot

 "Perspective" option under "Constrain" checked;
 "Perspective" option under "From pivot" not checked

 "Perspective" option under "Constrain" checked;
 "Perspective" option under "From pivot" also checked

 Pivot

 Snap: if this option is checked, the 
 pivot snaps to center or to corners when it comes close to them.

 Lock: locks pivot.

## Key modifiers

 Key modifiers are active when an action (move, scale, rotate, etc.) is 
 selected. Hold on:

 Shift to check all Constrain unchecked options 
 and uncheck already checked ones if a transformation handle is 
 selected, or, if the pivot is selected, to snap pivot to center or 
 corner,

 Ctrl to check all From pivot 
 unchecked options and uncheck already checked ones.

## The Unified Transform adjustment dialog

## 
 The Unified Transform adjustment dialog

 When you click on the image window, the adjustment dialog appears. 

 Transform Matrix

 The information window shows a mathematical representation
 of the perspective transformation. You can find more
 information about transformation matrices on
 Wikipedia.

 Readjust button

 With this button
 you can reset the transform handles back to the original square
 shape, while keeping the current transformation and zoom level.
 This enables you to create more complex transformations by making
 the transformation in several steps.