## System Resources

 Using
 Preferences
 System Resources

 System Resources

## System Resources Preferences

 This page lets you customize the amount of system memory allocated
 for various purposes. It also allows you to set the size of thumbnail
 files that GIMP produces.

## Activating the Dialog

 The preferences dialog can be accessed from the main menu, through

 Edit
 Preferences
 .

## Options

## Resource Consumption

 Minimal number of undo levels

 GIMP allows you to undo most actions by maintaining an
 Undo History
 for each image, for which a certain amount of memory is allocated.
 Regardless of memory usage, however, GIMP always permits some
 minimal number of the most recent actions to be undone: this is
 the number specified here. See

 for more information about GIMP's Undo mechanism.

 Maximum undo memory

 This is the amount of undo memory allocated for each image. If the
 Undo History size exceeds this, the oldest points are deleted,
 unless this would result in fewer points being present than the
 minimal number specified above.

 Tile cache size

 This is the amount of system RAM allocated for GIMP image
 data. If GIMP requires more memory than this, it begins to
 swap to disk, which may in some circumstances cause a
 dramatic slowdown. You are given an opportunity to set this
 number when you install GIMP, but you can alter it here. See
 How to Set Your
 Tile Cache for more information.

 Maximum new image size

 This is not a hard constraint: if you try to create a new image
 larger than the specified size, you are asked to confirm that you
 really want to do it. This is to prevent you from accidentally
 creating images much larger than you intend, which can either
 crash GIMP or cause it to respond verrrrrrrry slowwwwwwwwly.

 Swap compression

 This sets the compression method used for tile data stored in the
 swap. Compression can both reduce the swap size, and increase its
 speed, by minimizing input and output. Values are best
 performance (the default),
 balanced, and best
 compression, or none to disable
 compression altogether.

 Number of threads to use

 Multi-threading allows making use of multiple cores for 
 processing. Not all features make use of that for the moment. A 
 point of interest is that multi-threading happens through GEGL 
 processing, but also in GIMP core itself, for instance to separate 
 painting from display.

## Network Access

 Check for updates

 When this option is enabled, GIMP will regularly check at
 start-up if a new version is available. If there is, you will
 get an alert that you can update. Note that this option requires
 you to have an internet connection and for GIMP to be allowed
 access to the internet.

## Image Thumbnails

 Size of thumbnails

 This options allows you to set the size of the thumbnails shown
 in the File Open dialog (and also saved for possible use by
 other programs). The options are No thumbnails,
 Normal (128x128), and
 Large (256x256).

 Maximum filesize for thumbnailing

 If an image file is larger than the specified maximum size, GIMP
 will not generate a thumbnail for it. This options allows you to
 prevent thumbnailing of extremely large image files from slowing
 GIMP to a crawl.

## Document History

 Keep record of used files in the Recent Documents list

 When checked, files you have opened will be saved in the
 Document history. You can access the list of files with the
 Document history
 dialog from the main menu:

 File
 Open Recent
 Document History
 .