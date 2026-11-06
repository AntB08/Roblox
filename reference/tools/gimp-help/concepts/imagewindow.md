## Image Window

 Image windows
 Description

 Status bar
 Image window

 Navigation preview

 Preview
 Navigation preview

 GIMP user interface is available in two modes: single-window mode
 (default), and multi-windows mode that you can get unchecking the

 Windows
 Single-Window Mode
 option.

 When you start GIMP without any image open, the image
 window seems to be absent in single-window mode, while, in multi-window
 mode, an image window exists, even if no image is open.

 We will begin with a brief description of the components that are
 present by default in an ordinary image window. Some of the
 components can be removed by using commands in the
 View menu.

## The Image Area in Single-Window Mode

## The Image Window in Multi-Window Mode

 Despite Single-window Mode, we will use
 image window for image area.

 Title Bar:
 The Title Bar in an image window without an image displays
 GNU Image Manipulating Program.
 An image window with an image displays the image name
 and its specifications in the title bar according to the settings
 in Preferences Dialog.
 The Title Bar is provided by the operating system, not by
 GIMP, so its appearance is likely to vary with
 the operating system, window manager, and/or theme.

 If you have opened a non-xcf image, it is (imported)
 as a .xcf file and its original name appears in the status bar at the
 bottom of the image window.

 When an image is modified, an asterisk appears in front of its title.

 Main Menu:
 Directly below the Title Bar appears the Menu bar (unless
 it has been suppressed).
 The Main Menu provides access to nearly every
 operation you can perform on an image. You can also right-click
 on an image to display a pop-up menu,

 Users with an Apple Macintosh and a one button mouse can use

 Ctrl
 Mouse Button
 instead.

,
 or by left-clicking on the little arrow-head symbol in
 the upper left corner, called Menu Button,
 described just below.
 Many menu commands are also associated with keyboard
 shortcuts as shown in the menu.
 You can define your own custom shortcuts for menu actions in the
 Keyboard Shortcuts
 Dialog.

 Menu Button:
 Click the Menu Button to display the Main Menu in a column, (essential
 in full screen mode).
 If you like to use keyboard shortcuts, use
 ShiftF10
 to open the menu.

 Ruler:
 In the default layout, rulers are shown above and to the left of the
 image. Use the rulers to determine coordinates within the image.
 The default unit for rulers is pixels; use the settings
 described below to use a unit other than pixels.

 One of the most important uses of rulers is to create
 guides.
 Click and drag a ruler into the image to create a guide.
 A guide is a line that helps you accurately position
 things—or verify that another line is truly horizontal
 or vertical.
 Using the Move tool, you can
 click and drag a guide. Drag a guide out of the
 image to delete it; you can always drag another guide into the
 image. You can even use multiple guides at the same time.

 In ruler area, the mouse pointer position is marked with two small
 arrow-heads pointing vertically and horizontally.

 Quick Mask Toggle:
 The small button in the lower left corner of the image toggles the
 Quick Mask on and off. When the Quick Mask is toggled, the button
 changes color, or is outlined in red for color icon themes. See
 Quick Mask
 for more details on this highly useful tool.

 Pointer Coordinates:
 When the pointer (mouse cursor, if you are using a mouse) is
 within the image boundaries, the rectangular area in the lower
 left corner of the window displays the current pointer
 coordinates. The units are the same as for the rulers.

 Units Menu:
 Use the Units Menu to change the units used for rulers and several
 other purposes. The default unit is pixels, but you can quickly
 change to inches, cm, or several other possibilities using this menu.
 Note that the setting of
 Dot for dot in the View menu affects how the display is
 scaled: see Dot for Dot
 for more information.

 Zoom Button:
 There are a number of ways to zoom the image in or out, but the Zoom
 Button is perhaps the simplest. You can directly enter a zoom level in
 the text box for precise control.

 Status Area:
 The Status Area is at the bottom of the image window.
 By default, the Status Area displays the original name of the image.xcf
 file, and the amount of system memory used by the image. Please use

 Edit
 Preferences
 Image Windows
 Title & Status

 to customize the information displayed in the Status Area.
 During time-consuming operations, the status area temporarily
 shows the running operation and how complete the operation is.

 Note that the memory used by the image is very
 different from the image file size. For instance, a 70 kB .PNG
 image may occupy 246 kB in RAM when displayed.
 There are two primary reasons the difference in memory usage.
 First, a .PNG file is compressed format, and the image is
 reconstituted in RAM in uncompressed form.
 Second, GIMP uses extra memory, and copies
 of the image, for use by the Undo command.

 Cancel Button:
 During complex time-consuming operations, usually a plug-in,
 a Cancel button temporarily appears in the lower right corner
 of the window. Use the Cancel button to stop the operation.

 A few plug-ins respond badly to being canceled, sometimes
 leaving corrupted pieces of images behind.

 Navigation
 Navigation button

 Navigation Control:
 This is the

 button at the lower right corner of the image window.
 Click and hold (do not release the mouse button)
 on the navigation control to display the Navigation Preview.
 The Navigation Preview has a miniature view of the image
 with the displayed area outlined. Use the Navigation Preview
 to quickly pan to a different part of the
 image—move the mouse while keeping the button pressed.
 The Navigation Window is often the most convenient way to
 quickly navigate around a large image with only a small portion
 displayed. See
 Navigation Dialog
 for other ways to access the Navigation Window.

 Inactive Padding Area:
 When the image dimensions are smaller than the image window, this
 padding area separates the active image display from the rest of the
 user interface, so you're able to distinguish between them. You cannot
 apply any Filters or Operations in general to the inactive area.

 Image Display:
 The most important part of the image window is, of course, the image
 display or canvas. It occupies the central area of the window,
 surrounded by a yellow dotted line showing the image boundary, against
 a neutral gray background.

 Besides the Navigation Control mentioned above, you can also pan
 across the image using a keyboard or mouse directly:

 Hold the Shift key, then use the arrow keys to pan
 the view in that direction.

 Use the scroll wheel on your mouse to pan the image vertically
 (up or down); hold the Shift key while using
 the scroll wheel to pan horizontally (left or right) instead.

 If your mouse has a middle-button, click and drag with it to pan across
 the image.

 Alternatively, you can press and hold Spacebar
 in combination with moving the mouse.

 You can change the zoom level of the image display in a variety of ways,
 including using the Zoom
 Button mentioned above, and the Zoom setting described below.
 Other ways of adjusting the zoom are using Ctrl
 mousewheel, using the Zoom commands
 in the View menu, and using the
 Zoom Tool.

 Image Window Resize Toggle:
 Without enabling this feature, if you change the size of the image
 window by click-and-dragging border limits, the image size and zoom
 does not change. If you make the
 window larger, for example, then you will see more of the image.
 If this button is pressed, however, the image resizes when the window
 resizes so that (mostly) the same portion of the image is displayed
 before and after the window is resized.

 Drag and drop an image into the Toolbox window from a file browser to
 open the image in its own Image window or tab.

 Dragging an image file into the Layers dialog adds it to the image as a
 new layer.

 Image size and image window size can be different. You can make image fit
 window, and vice versa, using two keyboard shortcuts:

 CtrlJ: this
 command keeps the zoom level; it adapts window size to image size.
 The Shrink Wrap command does the same.

 CtrlShift
 J: this command modifies the zoom level
 to adapt the image display to the window.