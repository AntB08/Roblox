## Grayscale mode

 Image
 Convert
 To grayscale

 Grayscale
 Convert to grayscale

 Modes (color)
 Grayscale

 You can use the Grayscale
 command to convert your image to grayscale. The resulting grayscale image
 will have a single channel composed of various shades of gray ranging from
 black to white.

 The number of available tonal steps between black and white depends on the
 image precision:

 At integer precision:

 An 8-bit integer grayscale image provides 255 available tonal steps
 from 0 (black) to 255 (white).

 A 16-bit integer grayscale image provides 65535 available tonal
 steps from 0 (black) to 65535 (white).

 A 32-bit integer grayscale image theoretically will
 provide 4294967295 tonal steps from 0 (black) to 4294967295 (white).
 But as high bit depth GIMP does all internal processing at
 32-bit floating point precision, the actual number of steps will be
 no more than the number of tonal steps available in a 32-bit
 floating point image.

 At floating point precision: the available number of tonal steps in a
 grayscale image depends on the specified bit depth (8-bit, 16-bit, or
 32-bit) and the type of floating point that is requested by the program
 (see 
 Floating-point arithmetic for details).

## Activating the Command

 You can access this command from the main menu through

 Image
 Mode
 Grayscale
 .