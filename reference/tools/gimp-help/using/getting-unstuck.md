## Common Causes of GIMP Non-Responsiveness

## There is a floating selection

## 
 Layers dialog showing a floating selection.

 Showing a floating selection that can be anchored (
 CtrlH) or
 turned into a new layer (
 ShiftCtrl
 N).

 How to tell:
 If there is a floating selection, many actions are impossible
 until the floating section is anchored.
 To check, look at the
 Layers Dialog, shortcut
 CtrlL (making sure
 it's set to the image you're working on) and see whether the top layer
 is called Floating Selection.

 How to solve:
 Right click on the floating selection to open the Layer menu and
 select either Anchor Layer
 (shortcut CtrlH)
 to anchor the floating selection to the layer below it, or convert it
 into an ordinary layer by selecting To New Layer
 (shortcut Shift
 CtrlN).
 If you need more help on how to do this, see
 Floating Selections.

## The selection is hidden

 How to tell:
 If this is the problem, merely reading this will already have made
 you realize it, probably, but to explain in any case: sometimes
 the flickering line that outlines the selection is annoying
 because it makes it hard to see important details of the image, so
 GIMP gives you the option of hiding the selection,
 by unchecking
 Show Selection
 in the View
 menu. It is easy to forget that you have done this, though.

 How to fix: Go to
 the View menu for the image and, if
 Show Selection is
 unchecked, click on it.

## You are acting outside the selection

## Fix selection using the "Select" menu

 From the Select menu choose All to make sure that
 everything is selected, choose None to remove
 the selection, or Invert to invert the selected
 area.

 How to tell:
 You may have previously selected a part of your image, but now you are
 trying to work on another part that is not inside the selection. Look
 for the selection outline and check if it is where you want it to be.

 How to fix:
 There are a couple of possibilities.

 If you can't see any selection, there may be a very small one, or
 it is outside the visible area on your screen, or it can even be one
 that contains no pixels. If this is the case, either display the
 selection via

 View
 Zoom
 Zoom to Selection
 ,
 or remove the selection via

 Select
 None

 or the shortcut ShiftCtrl
 A.

 If you can see a selection and thought you were inside it, it might
 be inverted from what you think. The easiest way to tell is to hit the
 Quick Mask button:
 the selected area will be clear and the unselected area will be masked.
 If this is the problem, you can solve it by choosing
 Invert in the Select menu (after
 turning the Quick Mask off if you still have that
 enabled).

 If doing this has destroyed a selection that you wanted to keep, use
 Undo (CtrlZ)
 to restore it, and then we can continue to figure out what the problem is.

## The active drawable is not visible

## Layer is invisible

 Layers dialog with visibility off for the active layer.

 How to tell:
 The Layers dialog gives you ability to toggle the visibility of
 each layer on or off. Look at the
 Layers Dialog, and see if
 the layer you are trying to work on is active (i.e., darkened) and
 has an eye symbol to the left of it. If not, this is your problem.

 How to fix:
 If your intended target layer is not active, click on it in the Layers
 dialog to activate it. If none of the layers are active, the
 active drawable might be a channel—you can look at the
 Channels Dialog to see.
 This does not change the solution, though.
 If the eye symbol is not visible, click in the Layers dialog at the left
 edge to toggle it: this should make the layer visible. See the Help
 section for the
 Layers Dialog if you need more
 help.

## The active drawable is transparent

## Layer opacity set to zero

 Layers dialog with opacity set to zero for the active layer.

 How to tell:
 When the opacity of a layer is 0, you cannot see anything you draw on it.
 Look at the Opacity slider at the top of the
 Layers Dialog and check the
 value next to it. If it is 0 or another very low value, that is your
 problem.

 How to fix: Move or click on the slider to change
 it to the desired value.

## You are trying to act outside the layer

 How to tell:
 In GIMP, layers don't need to have the same
 dimensions as the image: they can be larger or smaller. If you try to
 paint outside the borders of a layer, nothing happens. To see if this is
 the case, look for a black-and-yellow dashed rectangle that does
 not enclose the area you're trying to draw at.

 How to fix:
 You need to enlarge the layer. There are two commands near the bottom of
 the Layer menu that will let you do this:
 Layers to Image Size, which sets the layer
 bounds to match the image borders; and
 Layer Boundary Size, which brings up a dialog
 that allows you to set the layer dimensions to whatever you please.

## You are trying to act on a layer group

## Layer group selected

 Layers dialog where a layer group is selected.

 How to tell:
 Check the Layers Dialog to
 see if the active layer is actually a
 Layer group.
 When a layer group is not empty, a small icon 

 or

 appears in front of the layer group's thumbnail and name.
 Most actions don't work on a layer group, in which case an error message
 will show up: Cannot paint on layer groups.

 How to fix:
 You need to make a layer active that is not a layer group. Select a layer
 by clicking it in the Layers Dialog. If the active layer group has a
 + sign in front of it, it is collapsed. You can
 click it to expand and show the individual layers inside that group.

## The image is in indexed color mode.

 How to tell: GIMP can handle
 three different color modes:
 RGB(A), Grayscale and Indexed.
 The indexed color mode uses a colormap, where all colors used in the
 image are indexed. The
 color picker in
 GIMP however, lets you choose RGB colors.
 That means, if you try to paint with a different color than is indexed
 in the colormap, you can end up with the wrong color.

 How to fix: If possible, use the RGB color mode to
 paint on images. You can verify and select another color mode from the
 Mode menuitem in the
 Image menu. If you need to use indexed mode you can
 pick the color you want to use from the
 Colormap Dialog.

## No visible effect when trying to use a brush, eraser or other tool

 How to tell: You are trying to use the brush or eraser
 but you are not seeing anything changing.

 How to fix: Check the
 Tool Options and make sure
 that Opacity is not set to 0.

## No visible effect when trying to use the move tool, rotate or other
 transform tool

 How to tell: You are trying to move (or perform a
 transformation) on a layer but you do not see anything changing.

 How to fix: Check the
 status bar to see
 if there is a message telling you what is happening, next check
 Tool Options and make sure
 that the tool you are using is not set to work on a
 Selection or Path. These
 little buttons are at the top of the
 Tool Options for Transform
 Tools.

## Eraser and brushes no longer work

 You have selected the clipboard brush and the clipboard is empty.

## Empty Clipboard Brush

 How to tell: You are trying to use a brush or the
 eraser and nothing is happening.

 How to fix: Check the
 Brush Dialog to see which
 brush is currently in use. If it is the Clipboard Brush and it shows
 an empty rectangle then select a different brush to use.

## Eraser does not make area transparent

 How to tell: You are trying to use the eraser to
 remove all color but instead of a transparent area appearing it turns
 into the background color (usually white).

 How to fix: Check the active layer in the
 Layers Dialog: right click on it
 to open a menu and see if Add Alpha Channel is
 enabled. If it is, then your layer has no alpha channel: click that
 menu item to add an alpha channel. With that fixed, you will be able
 to erase to transparency.

## Unexpected colors when trying to use a brush or eraser

 How to tell: You are trying to use the brush or
 eraser but the outcome is not as you expected.

 How to fix: Check whether the layer you are painting
 on has a Layer Mask. If there is,
 you may be painting on the Layer Mask instead of the Layer itself. In that
 case click the Layer to make that the active painting area.

 Another similar possibility is that a Channel is active instead of a
 Layer. In that case click a layer in the Layers Dialog to make a layer
 active.

## The crop tool leaves an empty area after cropping

 How to tell: After cropping using the
 Crop Tool the image canvas is still
 using the old size and only the visible part was cropped.

 How to fix: Go to the
 Tool Options and make
 sure that Delete cropped pixels is checked.

## I've been waiting for a long time and GIMP is not responding

 How to tell: your mouse cursor is spinning or the
 window is saying it is not responding and you can't do anything in GIMP.

 How to fix: some filters and other operations can
 take a long time, especially on large images or if your computer does not
 have a lot of free memory. In these cases, you may just need more
 patience. It can sometimes help to reduce the part you are working on by
 making a selection around a specific area.

 GIMP, just like any other software, is not perfect. You may have found a
 bug. The best thing to do is report it, since you may be the first to
 encounter it. Not reporting it may mean it won't get fixed until someone
 else reports it.

 First check to make sure that you are using the latest version of GIMP; if
 not update and check if the problem is still there. If it is, check if
 the issue is already known by searching our
 list of
 issues (also check the closed issues, fixed issues get closed even
 if there is no new version available yet). If you don't see it there,
 please open a new issue, making sure to give us all details like your
 Operating System, GIMP version, what tool or filter you were using and
 what exactly happened. Adding a screenshot, or uploading the image
 you are using can also be helpful in certain cases.

## General guidelines on what to check if you are stuck

 Check the status
 bar to see if there is a message telling you what is happening.

 If you add the Error
 Console to one of your docks most of the warnings will
 appear there. This can make it easier to spot any problems.

 Check the
 Tool Options and make
 sure that all settings there have expected values, or else try to
 reset to default values.

 Check which Image Mode your
 image is using. Some operations have limitations when using Indexed
 mode.

 Check if a selection is active and if needed
 remove the selection.

 Check the
 Layers Dialog and make sure
 the correct layer is active, that the opacity, blending mode and
 layer attributes are set as expected.

 Check the
 View Menu to see if the part
 of the user interface that you are looking for is hidden, or to
 make sure that snapping is enabled or disabled as desired.