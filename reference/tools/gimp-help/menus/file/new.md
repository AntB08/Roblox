## New…

 Image
 New

 New

 New Image

 Using the Create a New Image dialog, you can
 create a new empty image and set its
 properties. The image is shown in a new image window.
 You may have more than one image on your screen at the same time.

## Activating the Command

 You can access this command from the main menu through

 File
 New…
 .

 You can also use the keyboard shortcut

 Ctrl
 N
 .

## Options

## The Create a New Image dialog

 Template
 Menu

 Image
 Image size
 When creating

 Image size

 Template

 Rather than entering all the values by hand, you can select some
 predefined values for your image from a menu of templates, which
 represent image types that are somewhat commonly useful. The
 templates set values for the size, resolution, comments, etc. If
 there is a particular image shape that you use often and it
 does not appear on the list, you can create a new template, using
 the Templates dialog.

 Image Size

 Here you set the Width and
 Height of the new image. The
 default units are pixels, but you can choose a different
 unit if you prefer, using the adjoining menu. If you do,
 note that the resulting pixel size is determined by
 the X and Y resolution (which you can change in the
 Advanced Options), and by setting
 Dot for Dot in the
 View menu.

 If no image is open, the New image is opened in
 the empty image window, with the default size you have determined.
 If you open the Newimage when another is open (or
 has been), then it is opened in another window, with the same
 size as the first image.

 Portrait/Landscape buttons

 Portrait/Landscape mode

 These buttons toggle between Portrait and Landscape mode.
 Their effect is to exchange the values for Width
 and Height. If the X and Y resolutions are
 different (in Advanced Options), then these values are also
 exchanged. On the right, image size, image resolution and
 color space are displayed.

## Advanced Options

 Precision

 8-bit, 16-bit, 32-bit

 The Advanced Options
 are mostly of interest to more advanced GIMP
 users. You can display these options by clicking on the small triangle
 on the lower edge of the dialog window. Note that you will need to scroll
 down to see all the available options.

 Image
 Resolution
 Setting when creating

 Resolution
 Setting when creating

 X and Y resolution

 The values in the X resolution and
 Y resolution
 fields relate mainly to printing: they do not affect the size of
 the image in pixels, but they may determine its physical size when
 it is printed. The X and Y resolution values can determine how
 pixels are translated into other measurement units, such as
 millimeters or inches.

 If you want to display the image on the screen at the
 correct dimensions, select

 View
 Dot for Dot
 .
 Set the zoom factor to 100% to see the image at its true
 screen size. The calibration of the screen size is normally
 done when GIMP is installed,
 but if the image does not display at the correct size,
 you may have to adjust the screen parameters in
 GIMP. You can do this in
 the Preferences
 dialog.

 Color space

 You can create the new image in different
 color modes, as either an
 RGB image or a grayscale image.

 RGB color

 The image is created in the Red, Green, Blue color system,
 which is the one used by your monitor or your television
 screen.

 Grayscale

 The image is created in black and white, with various shades
 of gray. Aside from your artistic interests, this type of
 image may be necessary for some plug-ins. Nevertheless,
 GIMP allows you to
 change an RGB
 image into grayscale, if you would like.

 You cannot create an indexed image directly with this menu, but of
 course you can always convert the image to indexed mode after it
 has been created. To do that, use the

 Image
 Mode
 Indexed
 command.

 Precision

 This setting lets you define the encoding used to store pixel
 information. For more details, please see the

 Image Encoding section.

 Five options are available:

 8-bit integer

 16-bit integer

 32-bit integer

 16-bit floating point

 32-bit floating point

 If you wonder what the difference is between integer and floating
 point (in the graphics area): If you have an image with 16-bit
 integer precision per channel, then you have 65,536 shades of
 different red, green and blue color tones – all of them equally
 stepped to each other (equal color distance). If you have it in
 floating point, then there are no equal-wide steps – so you can
 distribute the possible color values over selected ranges. For
 example: if you know that you have a very dark image with many
 shades of dark red color tones then you would benefit from floating
 point because you can decrease the importance of the brighter color
 tones and get most color detail out of only the darker reds.

## Precision example

 Left image is 8-bit, right is 32-bit. You can see that there
 are much more available colors between color transitions on
 the right image.

 Gamma

 Here you can choose the
 channel encoding
 for your image. Choices are Non-linear and
 Linear light.
 For 8-bit integer precision the default is Non-linear, and for
 32-bit floating point precision it is Linear light. For more
 information see
 which
 precision options should you choose.

 Color profile

 Here you can choose a color profile to be used for your image.
 The default is GIMP's standard color profile based on
 Color space, Precision,
 and Gamma.
 If you prefer to use a different color profile you can select an
 ICC color profile file from a location on your computer by
 choosing Select color profile from disk….

 Soft-proofing color profile

 You can attach a CMYK color profile to the image with this option.
 This profile will be used to create a soft-proofed display of the
 image when the Proof Colors option is enabled
 in the View menu.
 As with the Color Profile, if you prefer to use
 a different color profile you can select an ICC color profile file
 from a location on your computer by choosing
 Select color profile from disk….

 Soft-proofing rendering intent

 This option lets you select the rendering intent that will be used
 to convert the colors from the soft-proofed image to your display
 device when

 View
 Color Management
 Proof Colors

 is enabled. The four intents are Perceptual,
 Relative colorimetric, Saturation
 and Absolute colorimetric.
 See and
 for more information.

 Use Black Point Compensation

 When enabled, the BPC algorithm attempts to adjust the display of
 darker areas in the image when the Proof Colors
 option is enabled in the View menu.

 Fill with

 Here, you specify the background color that is used for your new
 image. It is certainly possible to change the background of an
 image later, too. You can find more information about doing that
 in the Layers Dialog.

There are several choices:

 Fill the image with the current Foreground
 color, shown in the Toolbox.

 Note that you can change the foreground color while the
 New Image dialog window is open.

 Fill the image with the current Background
 color, shown in the Toolbox. (You can change the
 background color too, while the dialog window is open.)

 Fill the image with Middle Gray (CIELAB).
 This will create a layer with a gray color that is 50% of perceptual
 lightness in the selected color mode.

 Fill the image with White.

 Fill the image with Transparency. If you
 choose this option, the image is created with an alpha channel and
 the background is transparent. The transparent parts of the
 image are then displayed with a checkered pattern, to indicate
 the transparency.

 Fill the image with a Pattern. If you
 choose this option, the image is filled with the currently
 active pattern (which you can change while this dialog is open).

 Comment

 Image
 Comment

 Comment

 You can write a descriptive comment here. The text is
 attached to the image as a
 parasite, and is saved
 with the image by some file formats (PNG, JPEG, GIF).

 You can view and edit this comment in the
 Image Properties
 dialog.