## Gradients Dialog

 Dialogs
 Gradient Dialog

 Gradient
 Dialog

## The screenshot illustrates the Gradients dialog

 The Gradients dialog offers a gradient palette which is
 used to select a gradient — a set of colors arranged in a linear
 scale — for use with the
 Gradient tool and numerous
 other operations. It also gives you access to several functions for
 manipulating gradients. You can select a gradient by clicking on it in
 the list: it will then be shown in the Brush/Pattern/Gradient area of
 the Toolbox. A few dozen nice gradients come pre-installed with GIMP.
 You can create more using the
 Gradient Editor.
 General information about gradients and how they are used in GIMP can be
 found in the Gradients
 section.

 The first five gradients are particular: they reproduce the gradient
 between Foreground and background colors of toolbox in different ways.

 FG to BG (Hardedge): only black and white with a
 sharp limit.

 FG to BG (HSV clock-wise/counter-clockwise Hue):
 all hues in the color wheel between the Foreground and the
 background color, clockwise or counter-clockwise.

FG to BG (RGB): default gradient, between the
 Foreground and the background colors of the Toolbox, in the RGB mode.

 FG to Transparent: only uses one color (the
 Foreground color) from complete opacity to complete transparency.
 This gradient is very useful when you work with softly blended
 collages or fog effects.

## Activating the Dialog

 This dialog is a dockable dialog; see the
 section for help on manipulating
 it.

 You can access it:

 from the main menu:

 Windows
 Dockable Dialogs
 Gradients
 ;

 from the Tab menu in any dockable dialog by clicking the
 tab menu button

 and selecting

 Add Tab
 Gradients
 ,

 from the Toolbox, by clicking on the current gradient in the
 Brush/Pattern/Gradient area
 (if you have checked the
 Show active brush, pattern and gradient option in the
 toolbox preferences).

 From the image by using the CtrlG shortcut.

 In the Windows menu, there is a list of
 detached windows which exists
 only if at least one dialog remains open. In this case, you can raise
 the Gradients dialog from the main menu:

 Windows
 Gradients
 .

## Using the Gradients dialog

 The most basic, and most commonly used, operation with the dialog is
 simply to click on one of the gradients in the scrollable list, in order
 to make it GIMP's current gradient, which will then be used by any
 operation that involves a gradient.

 If you double-click
 on a gradient, you open the Gradient Editor where you will be able to
 edit its name. Note, however, that you are only allowed to change the
 names of gradients that you have created yourself, not the ones that
 come pre-installed with GIMP. If you try to rename a pre-installed
 gradient, you will be able to edit the name, but as soon as you hit
 return or click somewhere else, the name will revert to its original
 value. It is a general rule that you cannot alter the resources that
 GIMP pre-installs for you: brushes, patterns, gradients, etc; only ones
 that you create yourself.

 Grid/List modes

 In the Tab menu, you can choose between View as
 Grid and View as List.
 In Grid mode, the gradients are laid out in a rectangular
 array. They look quite dazzling when viewed this way, but it is
 not very easy to pick the one you want, because of visual
 interference from the neighboring ones. In List mode, the
 more usable default, the gradients are lined up vertically, with
 each row showing its name.

 In the Tab menu, the option Preview Size
 allows you to adapt the size of gradient previews to your
 liking.

 The button bar at the bottom offers the following functionality:

 Edit Gradient

 This button activates the
 Gradient Editor.

 New Gradient

 This creates a new gradient, initialized as a simple grayscale,
 and activates the Gradient Editor so that you can alter it.

 Gradients that you create are automatically saved in the
 gradients folder of your personal
 GIMP directory. Any gradient files (ending with
 the extension .ggr) found in one of these
 folders, will automatically be loaded when you start
 GIMP. You can add more directories to the
 gradient search path, if you want to, in the Gradients tab of the
 Data Folders
 section of the Preferences dialog.

 Duplicate Gradient

 This creates a copy of the currently selected gradient. You will
 be able to edit the copy as editing the original is not supported.

 Delete Gradient

 This removes all traces of the gradient, if you have permission to
 do so. It asks for confirmation before doing anything.

 Refresh Gradients

 If you add gradients to your personal
 gradients
 folder by some means other than this dialog, this button causes
 the list to be reloaded, so that the new entries will be
 available.

 The functions performed by these buttons can also be accessed from the
 dialog pop-up menu, activated by right-clicking anywhere in the
 gradient list, or via Gradient Menu in the
 Tab menu.

 The gradient menu also gives you some additional functions:

 Save as POV-Ray…

 This allows you to save the gradient in the format used by
 the POV-Ray 3D ray-tracing
 program.

 Copy Gradient Location

 This command allows you to copy the gradient file location to
 the clipboard. You can then use it in a text editor.

 Show in File Manager

 Show in File Manager opens the location of
 the gradient in the default File Manager on your system.

 Custom Gradient…

 This command creates a sample image filled with the selected
 gradient. You can select width and height of the image as well as
 the gradient direction in the dialog window.

 Save Gradient as CSS…

 Gradient CSS code snippet

 The CSS (Cascading Style Sheets) language is used to format the
 display of HTML and XML files, for instance background color,
 background gradient, or font size. The "CSS Save" plug-in is a CSS3
 linear gradient generator that allows you to save a CSS3
 code snippet, containing the gradient data for a given GIMP
 gradient. This code snippet is a text file: you can copy-paste it to
 the stylesheet related to your HTML file, to get a gradient
 background on opening the HTML file in Firefox, Chrome or Safari web
 navigators. This CSS3 code snippet can also be used as a gradient in
 SVG files.

 Here is an example of a CSS3 code snippet, using the Blue
 Green gradient:

## A CSS snippet created with Save as CSS

background-image: linear-gradient(top, rgb(0,123,255) 0%, rgb(72,226,255) 56%,
 rgb(0,255,161) 100%);

## Tagging

 You can use tags to reorganize the gradients display. 
 See .