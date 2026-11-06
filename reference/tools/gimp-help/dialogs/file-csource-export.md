## Export Image as C-Source

 C

 Export Image as C-Source

 Formats
 C-Source

## Overview

## The C-Source Export dialog

 The C-source export dialog allows you to export your image as a C
 source file that can be included in a program written in C.

## Options

 Prefixed name

 The name of the variable that will hold the image data.

 Comment

 A comment that will be added to the image data.

 Save comment to file

 The Comment will only be exported to the C
 file when this setting is checked.

 Use GLib types (guint8*)

 When checked GLib datatypes like guint8 will be
 used. When unchecked, plain C datatypes will be used instead.

 Use macros instead of a struct

 When checked, macros will be used to define the image data. When
 unchecked, a struct will be used instead.

 Use 1-bit Run-Length-Encoding

 When checked, the image data will be encoded using
 Run-Length-Encoding compression. A function macro called
 GIMP_IMAGE_RUN_LENGTH_DECODE
 will be added to the source file that can be used to decode the
 image data.

 Save alpha channel (RGBA/RGB)

 When checked, the image data will include the alpha channel.

 Save as RGB565 (16-bit)

 When checked, the image data will be saved in 16-bit RGB565 format,
 using only two bytes instead of three to store the image data.

 Opacity

 This slider allows you to set the opacity of the image data.