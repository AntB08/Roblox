## The Gradient Editor

 Gradient
 Editor

## The gradient editor

 The Gradient Editor allows you to edit the colors in a gradient. It can
 only be used on gradients you have created yourself (or on a copy of a
 system gradient), not on system gradients that come pre-installed with
 GIMP. This is a sophisticated tool that may take a bit of effort to
 understand. The concept behind it is that a gradient can be decomposed
 into a series of adjoining segments,
 with each segment consisting of a smooth transition from the color on
 the left edge to the color on the right edge. The Gradient Editor allows
 you to pack together any number of segments, with any colors you want for
 the left and right edges of each segment, and with several options for the
 shape of the transition from left to right.

## How to Activate the Gradient Editor

 You can activate the Gradient Editor in several ways:

 by double-clicking on the gradient stripe in the Gradient dialog,

 from the context menu you get by right clicking on the selected
 gradient name,

 by clicking on the

 Edit gradient button in the Gradient Dialog,

 from the Gradient Menu you get by clicking on

 in the Gradient Dialog.

## Display

 Name

 This is where you can change under what name the gradient shows
 up in the list of gradients.

 The Gradient Preview Window 

 Below the name, you see the current result of your work. If you
 move the mouse pointer on this display, it works somewhat like a
 color-picker. Information about the pixel under the mouse is
 shown below the preview and slider area.

 Position is a number between 0.000 on the left
 and 1.000 on the right side of the gradient. Below that the color
 values in RGB and HSV
 mode are shown, followed by the Luminance and
 Opacity values.

 If you click-n-drag on display, then only position and RGB data
 are displayed. But they are passed on to the Foreground color in
 the Toolbox and to the four first gradients of the list (by
 pressing the Ctrl key, the Color is sent to the
 Background color of the Toolbox).

 Range Selection/Control Sliders

 Below the gradient display, you see a set of black and white
 triangles lined up in row which allow you to adjust endpoints
 and midpoints in the gradient preview. A
 segment is the space between two consecutive
 black triangles. Inside each segment is a
 white triangle, which is used to warp the colors
 in the segment, in the same way that the middle slider
 in the Levels tool warps the colors there. You can select a
 segment by clicking between the two black triangles that define
 it. It turns from white to blue. You can select a range of
 segments by Shift-clicking on them.
 The selected range always consists of a set of
 consecutive segments, so if you
 skip over any when Shift-clicking, they will
 be included automatically. If Instant update
 is checked, the display is updated immediately after any slider
 movement; if it is unchecked, updates only occur when you release
 the mouse button.

 You can move sliders, segments and selections. If you simply
 click-n-drag a slider,
 you only move the corresponding transition. By
 click-n-drag on a segment
 you can move this segment up to the next triangle. By
 Shift+click-n-drag on a segment/selection,
 you can move this segment/selection and compress/dilate next
 segments.

 Scrollbar

 Below the sliders is a scrollbar. This only comes into play if you
 zoom in using the buttons at the bottom.

 Feedback Area

 Below, a color swatch shows the color pointed by the mouse
 cursor. Information about this color and helpful hints or
 feedback messages may appear here.

 Buttons

 The button bar at the bottom offers the following functionality:

 Zoom Out

 Clicking this button shrinks the gradient display
 horizontally.

 Zoom In

 Clicking this button expands the gradient display
 horizontally. You can then use the scrollbar to pan the
 display left or right.

 Zoom All

 Clicking this button resizes the display horizontally so
 that it fits precisely into the window.

## The Gradient Editor pop-up Menu

 You can access the Gradient Editor menu either by right-clicking on the
 gradient display, or by choosing the top item in the dialog's tab menu.
 The menu allows you to edit endpoint's color (set the left and right
 edge colors for each segment), blend colors, select a color model and
 edit segments. This editor works only with custom gradients or a copy
 of a system gradient.

The following commands can be found in the menu:

## Editing endpoint's color

 Left/Right color type

 This submenu allows you to select the endpoint color from the
 toolbox foreground and background colors.
 Whenever you change the foreground or background color, this
 endpoint color may be changed as well. The alternative is to
 select a Fixed endpoint color.

 The following commands can be found in the menu:

 Fixed

 Fixed

 Foreground Color

 Foreground Color

 Foreground Color (Transparent)

 Foreground Color (Transparent)

 Background Color

 Background Color

 Background Color (Transparent)

 Background Color (Transparent)

 Left [Right] Endpoint's Color

 These options allow you to choose a color for the respective
 endpoint using a Color Editor.

 This command is related to the previous one and becomes
 inactive if you have selected any other value than
 Fixed for the corresponding Left
 [Right] Color Type.

 Load Left [Right] Color From

 These options give you a number of alternative ways of assigning
 colors to the endpoints. From the submenu you can choose (assuming
 we're dealing with the left endpoint):

 Left Neighbor's Right Endpoint

 This choice will cause the color of the right endpoint of
 the segment neighboring on the left to be assigned to the
 left endpoint of the selected range.

 Right Endpoint

 This choice will cause the color of the right endpoint of
 the selected range to be assigned to the left endpoint.

 FG/BG color

 This choice causes GIMP's current foreground or background
 color, as shown in the Toolbox, to be assigned to the
 endpoint. Note that changing foreground or background color
 later will not change the endpoint's color.

 RGBA slots

 At the bottom of the menu are
 10 memory slots. You can assign colors to
 them using the Save menu option described
 below. If you choose one of the slots, the color in it will
 be assigned to the endpoint.

 Save Left [Right] Color To

 These options cause the color of the endpoint in question to be
 assigned to the memory slot selected from the
 submenu.

 Click and drag colors

 You can also click and drag a color from the toolbox FG-BG colors
 or from a palette

 to an endpoint (a black triangle), to set left [right] colors,

 to the gradient display area, to add a new endpoint with this
 color on both sides.

## Blending and coloring functions for segment

 Blending Function for Segment

 This option determines the course of the transition from one
 endpoint of the range (segment or selection) to the other, by
 fitting the specified type of function to the endpoints and
 midpoint of the range:

 Linear

 Default option. Color varies linearly from one endpoint of
 the range to the other.

 Curved

 Gradient varies more quickly on ends of the range than on
 its middle.

 Sinusoidal

 The opposite of the curved type. Gradients varies more
 quickly on center of the range than on its ends.

 Spherical (increasing)

 Gradient varies more quickly on the left of the range than
 on its right.

 Spherical (decreasing)

 Gradient varies more quickly on the right than on the left.

 Step

 Gradient changes from left value to right value in one step
 without intermediate colors.

 Coloring Type for Segment

 This option gives you additional control of the type of transition
 from one endpoint to the other: as a line either in RGB space or
 in HSV space.

 The following commands can be found in the menu:

 RGB

 RGB

 HSV (counter-clockwise hue)

 HSV (counter-clockwise hue)

 HSV (clockwise hue)

 HSV (clockwise hue)

## Modifying segments

 Flip Segment

 This option does a right-to-left flip of the selected range
 (segment or selection), flipping all colors and endpoint
 locations.

 Replicate Segment

 This option splits the selected range (segment or selection) into
 two parts, each of which is a perfect compressed copy of the
 original range.

 Split Segment at Midpoint

 This option splits each segment in the selected range in into two
 segments, splitting at the location of the white triangle.

 Split Segment Uniformly

 This option is similar to the previous one, but it splits each
 segment halfway between the endpoints, instead of at the white
 triangle.

 Delete Segment

 This option deletes all segments in the selected range, (segment
 or selection) replacing them with a single black triangle at the
 center, and enlarging the segments on both sides to fill the void.

 Re-center Segment's midpoint

 This option moves the white triangle for each segment in the
 selected range to a point halfway between the neighboring black
 triangles.

 Re-distribute Handles in Segment

 This option causes the black and white triangles in the selected
 range to be shifted so that the distances from one to the next are
 all equal.

## Blending colors

 These options are available only if more than one segment are
 selected.

 Blend Endpoints' Colors

 This option causes the colors at interior endpoints in the range
 to be averaged, so that the transition from each segment to the
 next is smooth.

 Blend Endpoints' Opacity

 This option does the same thing as the previous option, but with
 opacity instead of color.

 Edit Active Gradient

 When enabled, the gradient editor will automatically load the
 currently active gradient. If it is disabled, the gradient editor
 will not change when the active gradient changes.

 There is no undo available within the Gradient Editor,
 so be careful!

## Using example for the Gradient Editor

 Tutorials
 New gradient

 Gradient
 New gradient

 All these options can seem somewhat boring. Here is an example to clear
 ideas:

 Open the Gradient Dialog. Click

 New Gradient.
 The Gradient Editor is opened
 and shows a gradient from black to white.

## New gradient

 Right click in this new gradient and select
 Split Segment Uniformly.
 If wanted, adjust the number of segments.

## Gradient with three segments

 Every segment is limited with two black triangular sliders.
 Click a segment to activate it. By pressing the
 Shift key, you can select several contiguous
 segments.

 In the context menu you get by right-clicking in the gradient, set
 Left Endpoint Color and
 Right Endpoint Color for the selected segment
 or segment group.

## First segment colored

 Red has been chosen for left endpoint and yellow for the right
 endpoint.

 Go on the same way for other segments. Then use the
 Blending functions for segment to achieve
 various effects.