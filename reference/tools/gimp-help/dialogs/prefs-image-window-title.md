## Image Title and Statusbar Format

 Dialogs
 Preferences
 Title and Statusbar

 Title bar
 Preferences

 Status bar
 Preferences

## Image Title and Statusbar Format Preferences

 This page lets you customize the text that appears in two
 places: the title bar of an image, and the status bar. The
 title bar should appear above the image; however this depends
 on cooperation from the window manager, so it is not
 guaranteed to work in all cases. The statusbar appears
 underneath the image. See the Image Window
 section for more information.

## Activating the Dialog

 The preferences dialog can be accessed from the main menu, through

 Edit
 Preferences
 .

## Choosing a Format

 You can choose among several predesigned formats, or you can
 create one of your own, by writing a format
 string in the entry area. Here is how to understand
 a format string: anything you type is shown exactly as you type
 it, with the exception of variables, whose
 names all begin with %. Here is a list of the variables
 you can use:

 Variable
 Meaning

 %f
 Bare filename of the image, or Untitled

 %F
 Full path to file, or Untitled

 %p
 Image id number (this is unique)

 %i

 View number, if an image has more than one display

 %t
 Image type (RGB, grayscale, indexed)

 %z
 Zoom factor as a percentage

 %s
 Source scale factor (zoom level = %d/%s)

 %d
 Destination scale factor (zoom level = %d/%s)

 %Dx

 Expands to x if the image is dirty, nothing otherwise

 %Cx

 Expands to x if the image is clean, nothing otherwise

 %l
 The number of layers

 %L
 Number of layers (long form)

 %m
 Memory used by the image

 %n
 Name of the active layer/channel

 %o
 Name of the color profile

 %P
 id of the active layer/channel

 %w
 Image width in pixels

 %W
 Image width in real-world units

 %h
 Image height in pixels

 %H
 Image height in real-world units

 %u
 Unit symbol (eg. px for Pixel)

 %U
 Unit abbreviation

 %x
 Active layer width in pixels

 %X
 Active layer width in real-world units

 %y
 Active layer height in pixels

 %Y
 Active layer height in real-world units

 %%
 A literal % symbol