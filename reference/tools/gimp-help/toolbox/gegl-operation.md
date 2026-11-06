## GEGL Operation

 Tools
 GEGL operation

 GEGL operation

## Overview

 GEGL (Generic Graphical Library) is a
 graph based image processing library designed to handle various image
 processing tasks needed in GIMP. Most
 GEGL operations have their own menu commands in
 GIMP. The majority of them are filters found in the
 Colors and Filters menus.

 However, there are some GEGL operations that don't have
 their own command. Either because the operation was not considered important
 enough, or because the operation may still be experimental.

 The GEGL Operation filter was added to give access to all
 these operations that you can't use in another way. It enables applying
 GEGL operations to the image and gives on-canvas previews
 of the results.
 New GEGL operations made by third-party developers
 will also show up in this dialog.

## Activating the Tool

 You can get to this tool only from the main menu:

 Tools
 GEGL Operation…
 .

## Options

## Tool Options Dialog

GEGL Operation with no operation selected.

 Operation

 Click on this button to select the operation you want to apply to
 the active selection or, if there is no selection, to the active
 layer.

 Some of these operations are very basic operations like
 color which fills the active selection or layer
 with the specified color, while operations like
 fractal-explorer produce fairly complex patterns
 — just like a rendering
 filter.

 Operation Settings

 The operation settings depend on the selected
 Operation:

## Operation Settings example

 GEGL operation Gaussian Blur selected.

 If the options of the selected GEGL operation
 are not self-explanatory (guess what's the purpose of the
 color operation's Color option)
 you can look for a corresponding non-GEGL tool.
 For example, the Fractal
 Explorer filter may have the same or similar options as the
 fractal-explorer operation.

 Or you can make use of the nice realtime preview feature and just
 experiment with different settings.

 Preview

 If this option is checked, as it is by default, you will get an
 on-canvas preview of the selected operation as soon as the
 operation is finished. You will have to press the
 OK button to actually apply the operation
 to the image.

## The buttons

 Reset

 Pressing this button resets the operation settings to their
 defaults.

 Cancel

 Clicking on this button aborts the GEGL
 operation and leaves your image untouched. This is equivalent
 to close the dialog window using the usual
 Close button provided by your window
 manager.

 OK

 You have to press this button to apply the selected operation to
 the image. Then the dialog window will be closed.