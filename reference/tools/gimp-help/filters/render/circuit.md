## Circuit

 Filters
 Render
 Circuit

 Circuit

## Overview

## Example of Circuit

Filter applied

 Circuit command is a script that fills the
 selected region (or alpha) with traces like those on the back of an old
 circuit board. It looks even better when gradmapped with a suitable
 gradient.

 The effect seems to work best on odd shaped selections because of
 some limitations in the maze codes selection handling ability.

 If the image is in indexed mode, this menu entry is disabled.

 This filter creates a gray level image in RGB mode.

 The resulting image doesn't depend on the original image.

## Activating the Filter

 This filter is found in the main menu under

 Filters
 Render
 Circuit…
 .

## Options

## Circuit filter options

 Oilify mask size

 With this option you can set the option value of the
 Oilify filter in pixels
 (range 3 to 50). Larger values make lines more fuzzy.
 17 is the default value.

 Circuit seed

 You can give a randomizing seed number between 1 and 3000000.
 The default value is 3.

 No background (only for separate layer)

 If this option is enabled, dark pixels of the circuit are made
 transparent so that the underlying image is shown through
 these holes. This option is disabled in default settings.
 The Separate layer option is required.

 Keep selection

 If an active selection exists when this script is called,
 you can keep the selection and its
 marching ants
 with this option. This option is enabled in default settings.

 Separate layer

 If this option is not checked, the generated texture is drawn
 on the active layer. When this option is enabled (in default),
 this script adds a layer to draw the circuit texture is on.

## Making the Circuit effect

The Circuit effect is achieved through the following steps:

 First, draw maze with 5 pixels
 width pathways and walls with the Depth First
 algorithm. The pattern of maze is set by Circuit
 seed.

 Oilify this maze with a
 brush of Oilify mask size.

 Then apply the extract edge
 filter with Sobel algorithm, Smear option and Amount to 2.0, to
 the oilified maze image. This crowds high contrast winding curves
 like as a circuit map.

 Finally, Desaturate
 the map with gray color in RGB mode.