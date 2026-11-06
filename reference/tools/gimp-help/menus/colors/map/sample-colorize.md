by by lexa
 2005-08-22 de added by axel.wernicke
 2005-08-30 de replaced informalfigure by axel.wernicke
-->

## Sample Colorize

 Colors
 Sample Colorize

 Sample Colorize

## Overview

## Example for the Sample Colorize filter

Original image

Filter Sample Colorize applied

 This filter allows you to colorize old black-and-white images by mapping
 a color source image or a gradient against it.

## Activating the Command

 You can access this command from the main menu through

 Colors
 Map
 Sample Colorize…
 .

## Options

## Options of the Sample Colorize filter

 The filter window is divided into two parts: Destination on the left,
 Sampling on the right.

 Destination
 Sample

 By default, displayed image previews reproduce the image you
 invoked the filter from.

 The sample can be the whole preview, or a
 selection of this preview. With the drop list, you can select
 another sample-image among the names of images present on
 your screen when you called the filter. If you choose
 From Gradient (or From Inverse
 Gradient), the selected gradient in Gradient Dialog
 (or its inverse) will be the sample. It will be displayed into
 the gradient bar below the sample preview. The sampling preview
 is grayed out and two cursors allow you to select the gradient
 range that will be applied to the image or selection.

 Destination is, by default, the source
 image. The drop list displays the list of images present on your
 screen when you evoked the filter and allow you to select
 another destination image. If there is a selection in this
 image, it will be grayscale, else the whole preview will be
 grayscale.

 Show selection

 This option toggles between the whole image and the selection,
 if it exists.

 Show color

 This option toggles between colors and grayscale.

 Input levels

 Three input boxes and three sliders allow to fix importance of
 dark tones, mid tones and light tones. Result appears
 interactively in destination preview.

 Output levels

 Two input boxes and two sliders act the same: they limit the
 color range which will be applied to destination image. You can
 choose this range accurately. Result appears interactively in
 destination preview.

 Hold intensity

 If this option is checked, the average light intensity of
 destination image will be the same as that of source image.

 Original intensity

 If this option is checked, the In levels intensity settings will
 not be taken in account: original intensity will be preserved.

 Get Sample Colors

 When you click on this button, the gradient bar below the
 sample preview displays colors of the sample. If your sample
 holds few colors, transitions may be abrupt. Check
 Smooth samples option to improve them.

 Use subcolors is more difficult to
 understand. Let's say first that in a grayscale image there is
 information only for Value (luminosity, more or less light). In a
 RGB image, each pixel has information for the three colors and
 Value. So, pixels with different color may have the same Value.
 If this option is checked, colors will be mixed and applied to
 Destination pixels having that Value. If it is unchecked, then
 the dominating color will be applied.