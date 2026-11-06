## Indexed mode

 Image
 Convert
 To indexed mode

 Modes (color)
 Indexed

 Indexed colors

 The Indexed command converts your image to
 indexed mode. See
 indexed colors in the
 Glossary for more information about Indexed Color Mode.

## Activating the Command

 You can access this command from the main menu through

 Image
 Mode
 Indexed…
 .

## The Convert Image to Indexed Colors dialog

 The Indexed command opens the
 Convert Image to Indexed Colors dialog.

## The Convert Image to Indexed Colors dialog

 Colormap Options

Generate optimum palette:
 This option generates the best possible palette with a
 default maximum number of 256 colors (classic GIF format).
 You can reduce this
 Maximum Number of Colors, although
 this may create unwanted effects (color banding) on smooth
 transitions. You may be able to lessen the unwanted effects
 by using dithering, however.

Use web-optimized palette: use a
 palette that is optimized for the web.

Use black and white (1-bit) palette:
 This option generates an image which uses only two colors,
 black and white.

Use custom palette:
 This button lets you select a custom palette from a list.
 The number of colors is indicated for each palette. The
 Web palette, with 216 colors, is the
 web-safe palette. It was originally created
 by Netscape to
 provide colors that would look the same on both Macs and
 PCs, and Internet Explorer 3 could manage it. Since
 version 4, MSIE handles a 212 color palette. The problem
 of color similarity between all platforms has not been
 solved yet and it probably never will be. When designing a
 web page, you should keep two principles in mind: use light
 text on a dark background or dark text on a light
 background, and never rely on color to convey information.

 Some colors in the palette may not be used if your image
 does not have many colors. They will be removed from the
 palette if the Remove unused colors from final
 palette option is checked.

 Dithering Options

 Since an indexed image contains 256 colors or less, some colors
 in the original image may not be available in the palette. This
 may result in some blotchy or solid patches in areas which
 should have subtle color changes. The dithering options let you
 correct the unwanted effects created by the Palette Options.

 A dithering filter tries to approximate a color which is
 missing from the palette by instead using clusters of pixels
 of similar colors which are in the palette. When seen from a
 distance, these pixels give the impression of a new color. See
 the Glossary for more information on
 dithering.

 Three filters (plus None) are available. It is
 not possible to predict what the result of a particular filter
 will be on your image, so you will have to try all of them and
 see which works best. The
 Positioned Color Dithering filter is well
 adapted to animations.

## Example: full color, with no dithering

 This is an example image with a smooth transition in
 RGB Mode.

## Example: four colors, with no dithering

 The same image, after being transformed to four indexed
 colors, without dithering.

## Example: Floyd-Steinberg (normal)

 The same image, with four indexed colors and
 Floyd-Steinberg (normal) dithering.

## Example: Floyd-Steinberg (reduced color bleeding)

 The same image, with four indexed colors and
 Floyd-Steinberg (reduced color bleeding)
 dithering.

 In a GIF image, transparency is encoded in 1 bit: transparent
 or not transparent. To give the illusion of partial
 transparency, you can use the Enable dithering of
 transparency option. However, the
 Semi-flatten
 plug-in may give you better results.

 Enable dithering of text layers: dithering 
 text layers will make them uneditable.

 You can edit the color palette of an indexed image by using the
 Colormap Dialog.