## Scale Image

 Scale Image

 The Scale Image command enlarges or reduces
 the physical size of the image by changing the number of pixels it
 contains. It changes the size of the contents of the image and resizes
 the canvas accordingly.

 It operates on the entire image. If your image has layers of different
 sizes, making the image smaller could shrink some of them down to nothing,
 since a layer cannot be less than one pixel wide or high. If this happens,
 you will be warned before the operation is performed.

 If you only want to scale a particular layer, use the
 Scale Layer command.

 If scaling would produce an image larger than the
 Maximum new image size set in the
 System Resources page
 of the Preferences dialog (which has a default of 128 MiB), you are
 warned and asked to confirm the operation before it is performed.
 You may not experience any problems if you confirm the operation, but
 you should be aware that very large images consume a lot of resources and
 extremely large images may take more resources than you have,
 causing GIMP to crash or not perform well.

## Activating the Command

 You can access this command from the main menu through

 Image
 Scale Image…
 .

## The Scale Image Dialog

## The Scale Image dialog

 Image Size

 You should keep in mind that an image can be located in one of
 four places: in the image file, in RAM after it has been loaded,
 on your screen when it is displayed, or on paper after it has been
 printed. Scaling the image changes the number of pixels (the
 amount of information) the image contains, so it directly affects
 the amount of memory the image needs (in RAM or in a file).

 However printing size also depends upon the resolution of the
 image, which essentially determines how many pixels there will
 be on each inch of paper. If you want to change the printing
 size without scaling the image and changing the number of pixels
 in it, you should use the
 Print Size dialog.
 The screen size depends not only on the number of pixels, but
 also on the screen resolution, the zoom factor and the setting
 of the Dot for Dot
 option.

 If you enlarge an image beyond its original size,
 GIMP calculates the missing pixels by
 interpolation, but it does not add any new detail. The more you
 enlarge an image, the more blurred it becomes. The appearance of
 an enlarged image depends upon the interpolation method you
 choose. You may improve the appearance by using the
 Sharpen (Unsharp 
 Mask) filter after you
 have scaled an image, but it is best to use high resolution when
 you scan, take digital photographs or produce digital images by
 other means. Raster images inherently do not scale up well.

 You may need to reduce your image if you intend to use it on a web
 page. You have to consider that most internet users have
 relatively small screens which cannot completely display a large
 image, for example on mobile devices.

 Adding or removing pixels is called Resampling.

 Width
 Height

 When you click on the Scale
 command, the dialog displays the dimensions of the
 original image in pixels. You can set the
 Width and the
 Height you want to give to your
 image by adding or removing pixels. If the

 chain icon next
 to the Width and Height boxes is unbroken, the Width and
 Height will stay in the same proportion to each other. If
 you break the chain by clicking on it, you can set them
 independently, but this will distort the image.

 However, you do not have to set the dimensions in pixels.
 You can choose different units from the drop-down menu.
 If you choose percent as the units, you can set the image
 size relative to its original size. You can also use
 physical units, such as inches or millimeters. If you do
 that, you should set the X resolution
 and Y resolution fields to
 appropriate values, because they are used to convert
 between physical units and image dimensions in pixels.

 X resolution
 Y resolution

 You can set the printing resolution for the image in the
 X resolution
 and Y resolution
 fields. You can also change the units of measurement by
 using the drop-down menu.

 Quality

 To change the image size, either some pixels have to be removed
 or new pixels must be added. The process you use determines the
 quality of the result. The Interpolation
 drop-down list provides a selection of available methods of
 interpolating the color of pixels in a scaled image:

 Interpolation methods are described in 
 .

 See also the Scale tool,
 which lets you scale a layer, a selection or a path.