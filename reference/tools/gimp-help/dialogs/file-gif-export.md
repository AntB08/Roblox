## Export Image as GIF

 GIF

 .gif

 Export Image as GIF

 Formats
 GIF

## Overview

## The GIF Export dialog

 The GIF file format does not support some basic image
 properties such as partial transparency and
 print resolution.

 GIMP also only supports exporting with a maximum of
 256 colors. For best results, set your image to
 indexed mode when you
 intend to export to GIF.
 If you care for these properties, use a different file format like
 PNG.

## Options

 GIF Options

 Interlace

 Checking interlace allows an image on a web page to be
 progressively displayed as it is downloaded.
 Progressive image display is useful with slow connection
 speeds, because you can stop an image that is of no
 interest; interlace is of less use today with our faster
 connection speeds.

 Save comment

 GIF comments support only 7-bit ASCII characters.
 If you use a character outside the 7-bit ASCII set,
 GIMP will export the image without
 a comment, and then inform you that the comment was not
 saved.

 Animated GIF Options

 Animation
 Animated GIF options

 When working on an animation, the name of the layer can be used
 to specify certain parameters. For more details see
 exporting animations.

 Note: exporting a GIF animation does not support layer groups.

 As animation

 When this option is checked, the image will be
 exported as an animation. Note that this option
 will be disabled (and the animation options will
 not be visible) if the image has only one layer.

 Number of repeats

 You can set how many times the animation will
 repeat before it stops. This value is ignored if
 Loop forever is checked.

 Loop forever

 When this option is checked, the animation will
 play repeatedly until you stop it.

 Delay between frames when unspecified

 You can set the delay, in milliseconds, between frames
 if it has not been set before. In this case, you can
 modify every delay in the Layers dialog. Note that some
 operating systems and applications may override with a
 lower frame rate due to computer speed, performance, or
 other technical limitations.

 Frame disposal when unspecified

 If this has not been set before, you can set how frames
 will be superimposed. You can select among three options:

 I don't care:
 you can use this option if all your layers are
 opaque. Layers will overwrite what is beneath.

 Cumulative layers (combine):
 previous frames will not be deleted when a new one
 is displayed.

 One frame per layer (replace):
 previous frames will be deleted before displaying a
 new frame.

 Use delay entered above for all frames

 The Delay between frames when unspecified
 value will be used for all frames.

 Use disposal entered above for all frames

 The Frame disposal when unspecified
 value will be used for all frames.