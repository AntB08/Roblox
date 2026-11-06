export
 2011-04-02 Michael: rewrote tutorial
 2007-05-11 lexa: initial version
-->

## Common Tasks

 Tutorial

This tutorial is based on text Copyright © 2004
 Carol Spears. The original tutorial can be found online:
 .

## Intention

 GIMP is a powerful image editing program with many
 options and tools. However, it is also well suited for smaller tasks. The
 following tutorials are meant for those who want to achieve these common
 tasks without having to learn all the intricacies of GIMP
 and computer graphics in general.

Hopefully, these tutorials will not only help you with your current
 task, but also get you ready to learn more complex tools and methods later,
 when you have the time and inspiration.

Open an image via

 File
 Open…
 from the image window.

## Change the Size of an Image for the screen

 Tutorial

 Image
 Scale

You have a huge image, possibly from a digital camera, and you want
 to resize it so that it displays nicely on a web page, online board or
 email message.

The first thing that you might notice after opening the image, is that
 GIMP opens the image at a logical size for viewing. If
 your image is very large, like the sample image,
 GIMP sets the zoom so that it displays nicely on the
 screen. The zoom level is shown in the
 status bar at the bottom of
 the image window. This does not change the actual image.

The other thing to look at in the title bar is the mode. If the mode
 shows as RGB in the title bar, you are fine. If the mode says 
 Indexed or Grayscale, read the
 .

Select

 Image
 Scale Image…
 . You can right click on the image to open the menu, or use
 the menu along the top of the Image window.

## Dialog for Image Scaling in Pixels

The unit of size for the purpose of displaying an image on a screen
 is the pixel. You can see the dialog has two sections: one for
 width and
 height and another for
 resolution. Resolution applies to
 printing only and has no effect on the image's size when it is displayed on
 a monitor or a mobile device. The reason is that different devices have
 different pixels sizes and so, an image that displays on one device (such
 as a smartphone) with a certain physical size, might display on other
 devices (such as an LCD projector) in another size altogether. For the
 purpose of displaying an image on a screen, you can ignore the resolution
 parameter. For the same reason, do not use any size unit other than the
 pixel in the height / width fields.

If you know the desired width, enter it in the dialog at the top
 where it says
 Width. This is shown in the figure
 above. If you don't have such a number in mind, choose an appropriate width
 for the desired use. Common screen sizes range between 600 pixels for simpler
 phones and 1920 pixels for an HD screen.

When you change one of the image's dimensions,
 GIMP changes the other dimension proportionally. To
 change the other dimension, see
 . Bear in mind that when you
 change the two dimensions arbitrarily, the image might become stretched or
 squashed.

## Change the Size of an Image for print

 Tutorial

 Image
 scale

As discussed before, pixels don't have a set size in the real world.
 When you set out to print an image on paper,
 GIMP needs to know how big each pixel is. We use a
 parameter called resolution to set the ratio between pixels and real-world
 units such as inches.

By default, most images open with the resolution set to 72. This
 number was chosen for historical reasons as it was the resolution of
 screens in the past, and means that when printed, every pixel is 1/72 of an
 inch wide. When printing images that are taken with modern digital cameras,
 this produces very large but chunky images with visible pixels. What we
 want to do is tell GIMP to print it with the size we
 have in mind, but not alter the pixel data so as not to lose
 quality.

To change the print size, select

 Image
 Print Size…
 . Select a size
 unit you are comfortable with, such as inches. Set one
 dimension, and let GIMP change the other one
 proportionally. Now examine the change in resolution. If the resolution is
 300 pixels per Inch or more, the printed image's quality will be very high
 and pixels will not be noticeable. With a resolution of between 200 and
 150 ppi, pixels will be somewhat noticeable, but the image will be fine as
 long as its not inspected too closely. Values lower than 100 are visibly
 coarse and should only be used for material that is seen from a distance,
 such as signs or large posters.

## Dialog for Setting Print Size

## Compressing Images

 Tutorial

 Image
 save

## Example Image for JPEG Saving

If you have images that take up a large space on disk, you can reduce
 that space even without changing the image dimensions. One of the best
 image compressions is achieved by using the JPG format,
 but even if the image is already in this format, you can usually still make
 it take up less space, as the JPG format has an adaptive compression
 scheme that allows saving in varying levels of compression. The trade-off
 is that the less space an image takes, the more detail from the original
 image you lose. You should also be aware that repeated saving in the JPG
 format causes more and more image degradation.

 Images are loaded and saved as .XCF files. Your JPG
 image has been loaded as XCF. GIMP offers you to

 File
 Overwrite image-name.jpg
 or

 File
 Export As
 to open the Export Image dialog.

## Export Image Dialog

 The dialog opens with the file name already selected in the
 Name field, with the default extension.
 Delete the existing extension and type .jpg
 instead. GIMP will determine the file type from the
 extension.
 Click Export. This opens the
 Export Image as JPEG
 dialog that contains the Quality control.

The Export Image as JPEG dialog uses default
 values that reduce size in memory while retaining good visual quality;
 this is the safest and quickest thing to do.

## Example for Moderate JPEG Compression

Quality: 90 (default); Size: 33.7 KiloBytes

Quality: 75; Size: 20.1 KiloBytes

Reduce the image Quality to make the image even
 smaller. Reduced quality degrades the image, so be certain to check
 Show preview in image window to visually gauge the
 degradation. A Quality setting of 10 produces a very
 poor quality image that uses very little disk space.
 A quality of 75 produces a reasonable image using
 much less disk space, which will, in turn, load much faster on a web page.
 Although the image is somewhat degraded, it is acceptable for the intended
 purpose.

Finally, here is a comparison of the same picture with varying
 degrees of compression:

## Example for High JPEG Compression

Quality: 10; Size: 3.4 KiloBytes

Quality: 40; Size: 9.3 KiloBytes

## Example for Moderate JPEG Compression

Quality: 70; Size: 15.2 KiloBytes

Quality: 100; Size: 72.6 KiloBytes

## Crop An Image

 Tutorial

 Image
 crop

## Example Image for Cropping

Source image

Image after cropping

There are many reasons to crop an image; for example, fitting an
 image to fill a frame, removing a portion of the background to emphasize
 the subject, etc. There are two methods to activate the crop tool. Click
 the

 button in the Toolbox, or use

 Tools
 Transform Tools
 Crop
 in the image window. This changes the cursor and allow you to
 click and drag a rectangular shape. The button in the toolbox is the
 easiest way to get to any of the tools.

## Select a Region to Crop

Click on one corner of the desired crop area and drag your mouse to
 create the crop rectangle. You don't have to be accurate as you can change
 the exact shape of the rectangle later.

## Dialog for Cropping

 Crop tool options with the Fixed Aspect ratio option

 Crop rectangle with a fixed aspect ratio

After completing the click and drag motion, a rectangle with special
 regions is shown on the canvas. As the cursor is moved over the different
 areas of the selected crop area, the cursor changes. You can then drag the
 rectangle's corners or edges to change the dimensions of the selected area.
 As shown in the figure above, as the crop area is resized, the dimensions
 and ratio are shown in the status bar. Double-click inside the rectangle
 or press Enter to complete cropping. See
 for more information on cropping in
 GIMP.

If you would like to crop the image in a specific
 aspect ratio, such as a square, make sure the tool options are visible
 (
 Windows
 Dockable Dialogs
 Tool Options
 ). In the Tool Options
 dockable, check the mark next to
 Fixed Aspect Ratio. Type the desired aspect ratio
 in the text field below, such as 1:1.

You also have buttons to change the aspect from landscape to
 portrait. After you set the aspect ratio, drag one of the corners of the
 crop rectangle to update it. The rectangle changes to the chosen ratio,
 and when you drag it should maintain that ratio.

## Find Info About Your Image

 Tutorial

 Image
 information

When you need to find out information about your image, select

 Image
 Image Properties
 from the main menu. The Image Properties
 dialog contains information about the image size, resolution, mode
 and much more.

 See also .

## Image Properties Dialog

## Change the Mode

 Tutorial

 Image
 change Mode

As with anything else, images come in different kinds and serve
 different purposes. Sometimes, a small size is important (for web sites)
 and at other times, retaining a high color depth (e.g., a family portrait)
 is what you want.
 GIMP can handle all of this, primarily by converting
 between three fundamental image modes, via Image
 Mode in the main menu.
 These three available modes are:

 RGB: This is the default mode, used for high-quality
 images, and able to display millions of colors. This is also the mode for
 most of your image work including scaling, cropping, and even flipping. In
 RGB mode, each pixel consists of three different components: R->Red,
 G->Green, B->Blue. Each of these in turn can have an intensity value
 of 0-255. What you see at every pixel is an additive combination of these
 three components.

 Indexed: This is the mode usually used when file size
 is of concern, or when you are working with images with few colors. It
 involves using a fixed number of colors (256 or less) for the entire image
 to represent colors. By default, when you change an image to a paletted
 image, GIMP generates an optimum palette
 to best represent your image.

## The Convert Image to Indexed Colors dialog

As you might expect, since the information needed to represent the
 color at each pixel is less, the file size is smaller. However, sometimes,
 there are options in the various menus that are disabled for no apparent
 reason. This usually means that the filter or option cannot be applied when
 your image is in its current mode. Changing the mode to RGB, as outlined
 above, should solve this issue. If RGB mode doesn't work either, perhaps
 the option you're trying requires your layer to have the ability to be
 transparent. This can be done just as easily via

 Layer
 Transparency
 Add Alpha Channel
 .

 Grayscale: Grayscale images have only shades of gray.
 This mode has some specific uses and takes less space on the hard drive in
 some formats, but is not recommended for general use as reading it is not
 supported by many applications.

There is no need to convert an image to a specific mode before saving
 it in your favorite format, as GIMP is smart enough to
 properly export the image.

## Flip An Image

 Tutorial

 Image
 Flip

Use this option when you need the person in the photo looking in the
 other direction, or you need the top of the image to be the bottom. Select

 Tools
 Transform Tools
 Flip
 from the main menu, or use the

 button on the toolbox. After selecting the flip tool from the
 toolbox, click inside the canvas. Controls in the Tool Options dockable let
 you switch between Horizontal and Vertical modes.

After selecting the flip tool from the toolbox, click inside the
 canvas. The tool flips the image horizontally. Use the options dialog to
 switch between horizontal and vertical. If it is not already displayed in
 the dock under the toolbox, double click the toolbox button. You can also
 use the Ctrl key to switch between
 horizontal and vertical.

In the images below, all possible flips are demonstrated:

## Example Image to Flip

Source image

Horizontal flipped image

Vertical flipped image

Horizontal and vertical flipped image

## Rotate An Image

 Tutorial

 Image
 Rotate

Images that are taken with digital cameras sometimes need to be
 rotated. To do this, select

 Image
 Transform
 Rotate 90° clockwise
 (or counter-clockwise) from the main menu. The images
 below demonstrate a 90 degrees CCW rotation.

## Example for
 Rotate An Image 

Source Image

Rotated image 90 degree CCW

## Separating an Object From Its Background

 Tutorial

## Object with Background

 Sometimes you need to separate the subject of an image from its
 background. You may want to have the subject on a flat color, or keep the
 background transparent so you can use it on an existing background, or
 any other thing you have in mind. To do this, you must first use
 GIMP's selection tools to draw a selection around your
 subject. This is not an easy task, and selecting the correct tool is
 crucial. You have several tools to accomplish this:

 The Free Select
 Tool allows you to draw a border using either
 freehand or straight lines. Use this when the subject has a
 relatively simple shape. Read more about this tool here:

## Free Select Tool

 The Scissors Select
 tool lets you select a freehand border and uses
 edge-recognition algorithms to better fit the border around the
 object. Use this when the subject is complex but distinct enough
 against its current background. Read more about this tool here:

## Scissors Select Tool

 The Foreground Select
 Tool lets you mark areas as
 Foreground or Background and refines
 the selection automatically. Read more about this tool here:

## Foreground Select Tool

## Once you have selected your subject

 Once you have selected your subject successfully, use
 Select
 Invert. Now,
 instead of the subject, the background is selected. What you do now
 depends on what you intended to do with the background:

To fill the background with a single color:

 Click the foreground color swatch (the top left of the two
 overlapping colored rectangles) in the toolbox and select the
 desired color. Next, use 
 to replace the background with your chosen color.

## Result of Adding a Plain Color Background

 To make a black-and-white background while keeping the subject in
 color:

 Use

 Colors
 Desaturate
 . In the dialog that opens, cycle between the modes
 and select the best-looking one, then click OK.

## Result of Desaturating the Background