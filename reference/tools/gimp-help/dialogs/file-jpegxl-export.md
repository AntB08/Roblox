## Export Image as JPEG XL

 JPEG XL

 .jxl

 Export Image as JPEG XL

 Formats
 JPEG XL

## Overview

 JPEG XL
 is an image format that supports both lossy and lossless compression.
 The lossy compression is similar to that of JPEG, but significantly
 improved. Besides that there is a modular mode, that can
 be used for lossless compression similar to PNG, and also as an
 alternate lossy compression mode.

 You can export your image in this format when you choose the
 .jxl extension, or explicitly choose JPEG XL
 as file type in the export dialog.

## The JPEG XL Export dialog

## Options

 Lossless

 When checked, the image will be exported with lossless
 compression. This will create a higher quality image at
 the cost of a larger file size.

 When unchecked, the image will use a lossy compression technique
 that can reduce the file size more.

 Compression/maxError

 When Lossless is unchecked, this setting
 influences the amount of compression. Lower values give higher
 quality. At the minimum value of 1.0 it is visually almost
 the same as lossless.

 Effort/Speed

 This setting determines how much effort the encoder will put into
 reaching the desired quality, influenced by the
 Compression/maxError parameter.

 A higher effort may create more accurate results, but sometimes
 higher file size in lossy compression mode. A higher effort also
 consumes more memory too. Usually there is no reason to change
 the default value (squirrel).

 Bit depth

 Determines if the pixel data should be stored using 8 bits or
 16 bits per color channel.

 Save Exif

 If checked, the Exif metadata is embedded in the exported image.

 Save XMP

 If checked, the XMP metadata is embedded in the exported image.