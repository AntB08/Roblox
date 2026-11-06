## Palettes

 Palette
 Introduction

 Color
 Palettes (color map)

 Indexed palette

 A palette is a set of discrete colors. In
 GIMP, palettes are used mainly for two purposes:

 They allow you to paint with a selected set of colors, in the same way
 an oil painter works with colors from a limited number of tubes.

 They form the colormaps of indexed images. An indexed image can use a
 maximum of 256 different colors, but these can be any colors. The
 colormap of an indexed image is called an "indexed palette" in
 GIMP.

 Actually neither of these functions fall very much into the mainstream of
 GIMP usage: it is possible to do rather sophisticated
 things in GIMP
 without ever dealing with palettes. Still, they are something that an
 advanced user should understand, and even a less advanced user may need to
 think about them in some situations, as for example when working with GIF
 files.

## The Palettes dialog

 When you install GIMP, it comes supplied with several
 dozen predefined
 palettes, and you can also create new ones. Some of the predefined
 palettes are commonly useful, such as the Web palette,
 which contains the set of colors considered web safe;
 many of the palettes seem to have been chosen more or less whimsically.
 You can access all of the available palettes using the
 Palettes dialog.
 This is also the starting point if you want to create a new palette.

## The Palette Editor

 Double-clicking on a palette in the Palettes dialog brings up the
 Palette Editor,
 showing the colors from the palette you clicked on. You can use this to
 paint with the palette: clicking on a color sets GIMP's
 foreground to that
 color, as shown in the Color Area of the Toolbox. Holding down the
 Ctrl key while clicking, on the other hand, sets
 GIMP's
 background color to the color you click on.

 You can also, as the name implies, use the Palette Editor to change the
 colors in a palette, so long as it is a palette that you have created
 yourself. You cannot edit the palettes that are supplied with
 GIMP;
 however you can duplicate them and then edit the copies.

 When you create palettes using the Palette Editor, they are automatically
 saved as soon as you exit GIMP, in the
 palettes
 folder of your personal GIMP directory.
 Any palette files in your
 directory, or in the system palettes
 directory created when GIMP is installed, are
 automatically loaded and
 shown in the Palettes dialog the next time you start
 GIMP. You can also
 add other folders to the palette search path using the
 Palette Folders
 page of the Preferences dialog.

 GIMP palettes are stored using a special file format,
 in files with the
 extension .gpl.
 It is a very simple format, and they are ASCII files, so if you happen
 to obtain palettes from another source, and would like to use them in
 GIMP, it probably won't be very hard to convert them:
 just take a look at
 any .gpl and you will see what to do.

## Colormap

 Confusingly, GIMP makes use of two types of palettes.
 The more
 noticeable are the type shown in the Palettes dialog: palettes that
 exist independently of any image. The second type,
 indexed palettes,
 form the colormaps of indexed images. Each indexed image has its own
 private indexed palette, defining the set of colors available in the
 image: the maximum number of colors allowed in an indexed palette is
 256. These palettes are called indexed because each
 color is associated with an index number. (Actually, the colors in
 ordinary palettes are numbered as well, but the numbers have no
 functional significance.)

## The Colormap dialog

 The colormap of an indexed image is shown in the
 Indexed Palette
 dialog,
 which should not be confused with the Palettes dialog. The Palettes
 dialog shows a list of all of the palettes available; the Colormap
 dialog shows the colormap of the currently active image, if it is an
 indexed image – otherwise it shows nothing.

 You can, however, create an ordinary palette from the colors in an
 indexed image—actually from the colors in any image. To do this,
 choose Import Palette
 from the right-click popup menu in the Palettes dialog: this pops up a
 dialog that gives you several options, including the option to import
 the palette from an image. (You can also import any of
 GIMP's gradients
 as a palette.) This possibility becomes important if you want to create
 a set of indexed images that all use the same set of colors.

 When you convert an image into indexed mode, a major part of the process
 is the creation of an indexed palette for the image. How this happens is
 described in detail in .
 Briefly, you have several methods to choose from, one of which is to
 use a specified palette from the Palettes dialog.

 Thus, to sum up the foregoing, ordinary palettes can be turned into
 indexed palettes when you convert an image into indexed mode; indexed
 palettes can be turned into ordinary palettes by importing them into the
 Palettes dialog.