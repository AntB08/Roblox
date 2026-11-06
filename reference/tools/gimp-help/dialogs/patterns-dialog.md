## Patterns Dialog

 Dialogs
 Patterns

 Patterns
 Dialog

 In GIMP, a pattern
 is a small image used to fill areas by placing copies of side by side. See
 the Patterns
 section for basic information on patterns and how they can be created and
 used.

 You can use them with the
 Bucket Fill
 and Clone tools and the
 Fill with pattern command.

 The Patterns dialog is used to select a pattern, by
 clicking on it in a list or grid view: the selected pattern will then be
 shown in the Brush/Pattern/Gradient area of the Toolbox. A few dozen more
 or less randomly chosen patterns are supplied with GIMP, and you can
 easily add new patterns of your own.

## Activating the Dialog

 This dialog is a dockable dialog; see the
 section for help on manipulating
 it.

 You can access it:

 From the Toolbox, by clicking on the pattern symbol in the
 Brush/Pattern/Gradient area
 (if you have checked the
 Show active brush, pattern and gradient option in the
 toolbox preferences).

 from the main menu:

 Windows
 Dockable Dialogs
 Patterns
 ;

 from the Tab menu in any dockable dialog by clicking the
 tab menu button

 and selecting

 Add Tab
 Patterns
 .

 From the Tool Options dialog of the
 Clone tool and the
 Bucket Fill tool, by
 clicking on the pattern source button, you get a pop-up with
 similar functionality that permits you to quickly choose a pattern
 from the list; if you clic on the Bucket Fill button present on the
 right bottom of the pop-up, you open the real pattern dialog. Note
 that, depending on your Preferences, a pattern selected with the
 pop-up may only apply to the currently active tool, not to other
 paint tools. See the
 Tool Option Preferences
 section for more information.

## Using the pattern dialog

 Grid/List modes

 In the Tab menu, you can choose between
 View as Grid
 and View as List.
 In Grid mode, the patterns are laid out in a rectangular array,
 making it easy to see many at once and find the one you are
 looking for. In List mode, the patterns are lined up in a list,
 with the names beside them.

 Independent of the real size of a pattern all patterns are shown
 the same size in the dialog. So for larger patterns this means
 that you see only a small portion of the pattern in the dialog
 at all - no matter whether you view the dialog in the list or
 the grid view. To see the full pattern you simply click on the
 pattern and hold the mouse button
 for a second.

 In the Tab menu, the option Preview Size
 allows you to adapt the size of pattern previews to your liking.

## The Patterns dialog

List view

Grid mode

 Using the Patterns dialog (Grid mode)

 At the top appears the name of the currently selected
 patterns, and its dimensions in pixels.

 In the center appears a grid view of all available patterns,
 with the currently selected one outlined. Clicking on one of
 them sets it as GIMP's current pattern, and causes it to
 appear in the Brush/Pattern/Gradient area of the Toolbox.

 Using the Patterns dialog (List view)

 In this view, instead of a grid, you see a list of patterns,
 each labeled with its name and size. Clicking on a row in
 the list sets that pattern as GIMP's current pattern, just
 as it does in the grid view.

 If you double-click
 on the name of a pattern, you will be able to edit the name.
 Note that you are only allowed to rename patterns that you
 have added yourself, not the ones that are supplied with
 GIMP. If you edit a name that you don't have permission to
 change, as soon as you hit return or move to a different
 control, the name will revert back to its previous value.

 Everything else in the List view works the same way as it
 does in the Grid view.

 Buttons

 The button bar at the bottom offers the following functionality:

 Duplicate Pattern

 Pressing this button make a copy of the current pattern. It will
 have the same name as the original but with copy
 added to it.

 Delete Pattern

 Pressing this button removes the pattern from the list and causes
 the file representing it to be deleted from disk. Note that you
 cannot remove any of the patterns that are supplied with GIMP and
 installed in the system patterns
 directory; you can only remove patterns that you have added to
 folders where you have write permission.

 Refresh Patterns

 Pressing this button causes GIMP to rescan the
 folders in your pattern search path, adding any newly discovered
 patterns to the list. This button is useful if you add new
 patterns to a folder, and want to make them available without
 having to restart GIMP.

 Open pattern as image

 If you click on this button, the current pattern is opened in a
 new image window. So, you can edit it. But if you try to save it
 with the .pat, even with a
 new name, you will bang into a Denied permission 
 problem because this image file is root. But this
 is possible under Windows, less protected.

## Patterns Context Menu

 Patterns
 Menu

 Overview

 You can get the patterns context menu by right clicking on a
 pattern.
 Most of the operations on patterns are also available through
 buttons at the bottom of the patterns dialog. Those operations are
 documented there.

 Open Pattern as Image
 Delete Pattern
 Refresh Patterns

 See
 Patterns Dialog.

 Copy Pattern Location

 Copy Pattern Location allows you to
 copy the path of the selected pattern to the clipboard.

 Show in File Manager

 Show in File Manager opens the
 location of the pattern in the default File Manager on
 your system.

## Tagging

 You can use tags to reorganize the patterns display.
 See .

## The Clipboard pattern

 Clipboard pattern

 Patterns
 Clipboard pattern

 When you use the Copy or Cut command, a copy appears as a
 new pattern as the first entry in the Patterns dialog.
 This pattern will persist until you use the Copy (or Cut) command again.
 It will disappear when you close GIMP.

## A new Clipboard Pattern

 You can save this clipboard pattern with

 Edit
 Paste as
 Paste as New Pattern…

 as soon as it appears in the Patterns dialog.
 See .