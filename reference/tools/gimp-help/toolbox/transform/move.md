## Move

 Tools
 Move

 Move

 The Move Tool is used to move layers, selections, paths or guides. It
 works also on texts.

## Activating the Tool

 There are different possibilities to activate the tool:

 From the main menu:

 Tools
 Transform Tools
 Move
 .

 By clicking the tool icon

 in the Toolbox.

 By pressing the M keyboard shortcut.

 The Move tool is automatically activated when you create a
 guide.

 Space bar

 If the function of the Space bar is set to
 Activate the Move tool (which is not the
 default, but can be changed in your Preferences, see below), then
 holding down the Space bar temporarily changes the
 active tool to Move. The Move tool remains active as long as
 the space bar is held down. The original tool is reactivated
 after releasing the space bar.

 To enable this behavior you have to change the setting called
 While space bar is pressed to
 Switch to Move tool. This setting can be
 changed in the Preferences dialog:

 Edit
 Preferences
 Image Windows
 Space Bar
 .

## Options

## Tool Options Dialog

 Move

 Keep in mind that your Move choice persists after quitting the
 tool.

 Tool toggle (Shift)

## 
 prevents the from being included
 in the "msgid" of the po file. So remove the tags
 only if necessary for translating.
 -->
 If Move is on Layer

 Pick a layer or guide

 On an image with several layers, the mouse pointer turns to
 a crosshair when it goes over an element belonging to the
 current layer. Then you can click-and-drag it. If the mouse
 pointer has a small hand shape (showing that you do
 not pick an element of the active
 layer), you will move a non-active layer instead (it becomes
 the active layer while moving).

 If a guide exists on your image, it will turn to red when
 the mouse pointer goes over. Then it is activated and you
 can move it.

 At the point of intersection of two guides, you can 
 click-and-drag to move them together. This is useful when the 
 guides are used to mark a point, rather than a pair of lines 
 (e.g, as is the case for the mandala symmetry guides, which 
 mark the symmetry point of origin).

 Move the selected layers

 Only the selected layers will be moved (if smaller than 
 canvas). This may be useful if you want to move layers with 
 transparent areas, where you can easily pick the wrong layer 
 through these transparent areas.

 You also can move the selected layers by setting its offset in 
 the Edit Layer Attributes dialog.

## 

 If Move is on Selection

 The selection's outline will be moved (see
 ).

## 

 If Move is on Path

 Pick a path

 That's the default option. The mouse pointer turns to a
 small hand when it goes over a
 visible path.
 Then you can move this path by click-and-dragging it (it
 will be the active path while moving).

 Move the active path

 Only the current path will be moved. You can change the
 current path in the
 Paths Dialog.

## Summary of Move tool actions

 Moving a selection

 The Move tool allows to move the selection outline only. If the
 Move Mode is Layer, you must hold down
 CtrlAlt keys.

 If the Move Mode is Selection, you can click-and-drag any point in
 canvas to move the selection outline. You can also use the arrow
 keys to move selections precisely. Then, holding down the 
 Shift key moves then by increments of 25 pixels.

 When you move a selection with the Move tool, the center of the
 selection is marked with a small cross. This cross and selection
 boundaries snap to guides or grid if the

 View
 Snap to Guides (or Grid)

 option is checked: this makes aligning selections easier.

 See Moving
 selections for other possibilities.

 Moving a layer

 Layer
 Move

 The Move Mode must be Layer. Then you can choose
 between Move the selected layers and, if you
 have one or more layers, Point to Layer (or
 Guide).

 Moving Grouped Layers

 If layers are grouped they
 will all move, regardless of which layer is currently active.

 Moving a guide

 Guide
 Move

 When you pull a guide from a ruler, the Move tool is automatically
 activated. That's not the case after using another tool, and you
 have to activate it by yourself. When the mouse pointer goes over a
 guide, this guide turns to red and you can click-and-drag to move
 it.

 Moving a path

 Path
 Move

 The Path Tool dialog has its own moving function: see
 . But you can also use the Move
 Tool. The Move Mode must be set to Path. Note that
 the path becomes invisible; make it visible in the Paths dialog.
 You can choose the path to be moved or move the active path.

 Moving a text

 Text
 Move

 Every text has its own layer and can be moved as layers. See
 .