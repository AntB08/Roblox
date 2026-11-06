## Export Image as TIFF

 Export Image as TIFF

 TIFF

 Formats
 TIFF

## Overview

## The TIFF Export dialog

## Options

 Compression

 This option allows you to specify the algorithm used to
 compress the image.

 None

 No compression is used. This is fast, and lossless, but the
 resulting file can be very large.

 LZW

 The image is compressed using the
 Lempel-Ziv-Welch algorithm, a lossless
 compression technique. This is efficient and fast.
 More information at
 .

 Pack Bits

 This is a fast, simple compression scheme for run-length
 encoding of data. Apple introduced the PackBits format with
 the release of MacPaint on the Macintosh computer.

 A PackBits data stream consists of packets of one byte of
 header followed by data. (Source:
 )

 Deflate

 This is a lossless data compression algorithm that uses a
 combination of the LZ77 algorithm and Huffman coding. It is
 also used in Zip and Gzip files and PNG images. Source:
 .

 JPEG

 This is a very good compression algorithm but lossy. This is
 the same compression as used in JPEG images. Since it is
 lossy, you should not use this when image quality is
 important. This compression can not be used when your image
 is in indexed mode.

 CCITT Group 3 fax
 CCITT Group 4 fax

 These are black and white formats developed to transfer
 images by FAX.

 These two compression modes can only be selected, if the
 image is in indexed mode and reduced to two colors. Use

 Image
 Mode
 Indexed

 to convert the image to indexed mode. Make sure that
 Use black and white (1-bit) palette is
 checked.

 Save layers

 When enabled, each layer will be stored as a separate page in the
 TIFF image, starting from the bottom. When disabled, only the merged
 result will be stored.

 Not all image viewers support loading more than the first page of
 a TIFF image. Since the background layer is what we store first,
 it may be better to disable this setting if other programs
 you work with can't handle that.

 Crop layers

 When Save layers is checked, this option,
 which is enabled by default, will resize all layers to the size
 of the image. TIFF images can not have negative offsets. This
 option enables you to import the TIFF again without having to
 change the position of layers that had a different size as the
 image in the original.

 Save color values from transparent pixels

 When this is enabled the color values are saved even if the pixels
 are completely transparent.

 Save GeoTIFF data

 When this option is enabled GeoTIFF metadata that was present in
 the original image will be saved in the exported TIFF image.

 Save comment

 Here you can enable saving a comment that is associated with the
 image. The comment can be entered in the text box below this
 option.