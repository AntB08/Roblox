## Export Image as PNG

 Export Image as PNG

 PNG

 Formats
 PNG

## Overview

## The PNG Export dialog

 The PNG format supports indexed images. Using fewer colors,
 therefore, results in a smaller file; this is especially useful
 for creating web images;
 see .

 Computers work on 8 bits blocks named Byte.
 A byte allows 256 colors. Reducing the number of colors below 256
 is not useful: a byte will be used anyway and the file size will not
 be less. More, this PNG8
 format, like GIF, uses only one bit for transparency; only two
 transparency levels are possible, transparent or opaque.

## Options

 Pixel format

 By default your PNG image is exported in a pixelformat that
 resembles the settings of your image in GIMP.
 This is usually what you want, but when you need a specific
 output format you can change this here to 8 or 16 bits per channel
 RGB or Grayscale, with or without alpha channel.

 Compression level

 Since compression is not lossy, the only reason to use a
 compression level less than 9, is if it takes too long to
 compress a file on a slow computer.
 Nothing to fear from
 decompression: it is as quick whatever the compression level.

 Interlacing

 Checking interlace allows an image on a web page to be
 progressively displayed as it is downloaded.
 Progressive image display is useful with slow connection
 speeds, because you can stop an image that is of no
 interest; interlace is of less use today with our faster
 connection speeds.

 Save color values from transparent pixels

 When this option is checked, the color values are saved even if
 the pixels are completely transparent. But this is possible only
 with a single layer, not with a merged composition. When a
 multi-layer image gets exported to a single-layer file format,
 there is no way GIMP could preserve the color
 values in the transparent pixels.

 Save background color

 If your image has many transparency levels, the Internet
 browsers that recognize only two levels, will use the
 background color of your Toolbox instead.

 Save layer offset

 PNG supports an offset value called the
 oFFs chunk, which provides position data.
 Unfortunately, PNG offset support in GIMP
 is broken, or at least is not compatible with other
 applications,
 and has been for a long time. Do not enable offsets,
 let GIMP flatten the layers before
 saving, and you will have no problems.

 Save resolution

Save the image resolution, in ppi (pixels per inch).

 Save creation time

 Date the file was saved.

 Save comment

 You can read this comment in the
 Image Properties.

 Save Settings

 Click to save the current settings. Later, you can use
 Load Saved Settings to load the saved
 settings.