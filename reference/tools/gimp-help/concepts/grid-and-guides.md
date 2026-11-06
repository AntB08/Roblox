## Grids and Guides

 Image
 Grid and guides

 Grid
 Overview

 Guides
 Overview

 You will probably have it happen many times that you need to place
 something in an image very precisely, and find that it is not easy to do
 using a mouse. Often you can get better results by using the arrow keys on
 the keyboard (which move the affected object one pixel at a time, or 25
 pixels if you hold down the Shift
 key), but GIMP also provides you with two other aids to
 make positioning easier: grids and guides.

## Image used for examples below

## The Image Grid

## Image with default grid

 Each image has a grid. It is always present, but by default it is not
 visible until you activate it by toggling

 View
 Show Grid

 in the main menu. If you want grids to be present more often than not,
 you can change the default behavior by checking Show grid in the
 Image Windows Appearance
 page of the Preferences dialog. (Note that there are separate settings
 for Normal Mode and Fullscreen Mode.)

 The default grid appearance, set up when you install
 GIMP, consists of solid lines,
 spaced every 10 pixels both vertically and horizontally. You can
 customize the default grid using the
 Default Image Grid
 page of the Preferences dialog. If you only want to change the grid
 appearance for the current image, you can do so by choosing

 Image
 Configure Grid…

 from the main menu: this brings up the
 Configure Grid dialog.

## A different grid style

 Not only can a grid be helpful for judging distances and spatial
 relationships, it can also permit you to align things exactly with
 the grid, if you toggle

 View
 Snap to Grid

 in the main menu: this causes the pointer to "warp" perfectly to
 any grid line located within a certain distance. You can
 customize the snap distance threshold by setting "Snap distance"
 in the Snapping Behavior
 page of the Preferences dialog, but most people seem to be happy
 with the default value of 8 pixels. (Note that it is perfectly
 possible to snap to the grid even if the grid is not visible.)

 To create a grid that is actually part of the image, use the
 Grid plug-in.

## Guides

## Image with four guides

 In addition to the image grid, GIMP also gives you a
 more flexible type of positioning aid: guides.
 These are horizontal or vertical lines you can temporarily display on an
 image while you are working on it.

 To create a guide, simply click on one of the rulers in the image window
 and pull out a guide, while holding the mouse
 Left Button pressed. The guide is then
 displayed as a line which follows the pointer. When you release the
 mouse button the guide is placed and becomes blue and dashed.

 You can also create a guide with the
 New Guide command, which
 allows you to precisely place the guide on the image, the
 New Guide (by
 Percent) command, or the
 New Guides from
 Selection command.

 You can create as many guides as you like, positioned wherever you like.
 To move a guide after you have created it, activate
 the Move tool in the Toolbox (or press the M key), you
 can then click and drag a guide; click-and-drag the intersection of
 two guides to move them together. To delete a guide,
 simply drag it outside the image. Holding down the Shift
 key, you can move everything but a guide, using the guides as an
 effective alignment aid.

 The behavior of the guides depends upon the Move
 mode of the Move tool. When
 Layer mode is selected, the mouse pointer turns
 into a small hand as soon as it gets close to a guide. Then the guide is
 activated and it turns red, and you can move the guide or delete it by
 moving it back into the ruler. If Selection mode is
 selected, you can position a guide, but you cannot move it after that.

 As with the grid, you can cause the pointer to snap to nearby
 guides, by toggling

 View
 Snap to Guides

 in the main menu. If you have a number of guides and they are
 making it difficult for you to judge the image properly, you can
 hide them by toggling

 View
 Show Guides
 .
 It is suggested that you only do this momentarily, otherwise you
 may get confused the next time you try to create a guide and
 don't see anything happening.

 If it makes things easier for you, you can change the default behavior
 for guides in the
 Image Windows
 Appearance page of the Preferences dialog. Disabling
 Show guides is probably a bad idea, though,
 for the reason just given.

 You can remove the guides with the

 Image
 Guides
 Remove all Guides

 command.

 Another use for guides: the
 Slice Using Guides plug-in
 can use guides to slice an image into a set of sub-images.