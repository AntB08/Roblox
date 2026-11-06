## Files

 Files

 GIMP is capable of reading and writing a large
 variety of graphics file formats. With the exception of
 GIMP's native XCF file format, file handling is done by
 plug-ins. This makes it relatively easy to extend GIMP
 to support new file types when the need arises.

## Save / Export Images

 Save/Export Images

 Export Images

 When you open an image, let's say in JPG or PNG file format, it is
 imported into GIMP's own XCF format, as a new project.

 For example, a sunflower.png image will be loaded as
 *[sunflower] (imported)-1.0 (indexed color, 1 layer).
 The leading asterisk indicates that this file has been changed. This
 image can be saved as sunflower.xcf by using the
 Save command. If you need your image in another
 format, you should use the Export command.

 When you are finished working with an image, you will save the results.
 In fact, it is often a good idea to save at intermediate stages too.
 GIMP is a pretty robust program, but on rare occasions
 crashes have happened.

 GIMP's native format XCF is special. It is the only
 format that can store everything about an image
 (with the exception of undo information).
 This is the reason that saving can only be done in this format.
 It makes the XCF format especially suited for storing intermediate
 results, and for saving images to be re-opened later in
 GIMP.

 XCF files are not readable by most other programs that display images.
 Once you have finished editing your image, you can export it to the
 format of your choice.
 GIMP supports a wide range of formats. Most file
 formats that can be imported, can also be used for exporting.

## File Formats

 There are several commands for saving and 
 exporting images. They are listed in the section covering
 the File Menu. More information on
 how to use them can be found there.

GIMP allows you to export the
 images you create in a wide variety of formats. It is important to
 realize that the only format capable of saving all of
 the information in an image, including layers, transparency, etc., is
 GIMP's native XCF format. Every other format preserves some image
 properties and loses others. It is up to you to understand the
 capabilities of the format you choose.

 Exporting an image does not modify the image itself, so you do not lose
 anything by exporting. See
 Export file.

 When you close an image (possibly by quitting GIMP), you are warned if
 the image has been changed without subsequently being saved (an asterisk
 is in front of the image name in the title bar of the main window).