## Histogram Dialog

 Dialogs
 Histogram

 Histogram

## The Histogram dialog

 The Histogram dialog shows you information about the statistical
 distribution of color values in the active layer or selection. This
 information is often useful when you are trying to
 color balance
 an image. However, the Histogram dialog is purely informational: nothing
 you do with it will cause any change to the image. If you want to perform
 a histogram-based color correction, use the
 Levels tool.

## Activating the Dialog

 This dialog is a dockable dialog; see the
 section for help on manipulating
 it.

 You can access it:

 from the main menu:

 Windows
 Dockable Dialogs
 Histogram
 .

 from the Tab menu in any dockable dialog by clicking the
 tab menu button

 and selecting

 Add Tab
 Histogram
 ,

 from the main menu:

 Colors
 Info
 Histogram
 .

 In the Windows menu, there is a list of
 detached windows which exists
 only if at least one dialog remains open. In this case, you can raise
 the Histogram dialog from the main menu:

 Windows
 Histogram
 .

## About Histograms

 In GIMP, each layer of an image can be decomposed into one or more color
 channels: for an RGB image, into R, G, and B channels; for a grayscale
 image, into a single Value channel. Layers that support transparency
 have an additional channel, the alpha channel. Each channel supports a
 range of intensity levels from 0 to 255 (integer valued). Thus, a black
 pixel is encoded by 0 on all color channels; a white pixel by 255 on all
 color channels. A transparent pixel is encoded by 0 on the alpha
 channel; an opaque pixel by 255.

 For RGB images, it is convenient to define a Value pseudochannel
 . This is not a real color channel: it does not reflect any
 information stored directly in the image. Instead, the Value at a pixel
 is given by the equation V = max(R,G,B).
 Essentially, the Value is what you would get at that pixel if you
 converted the image to Grayscale mode.

 For more information on channels, please consult the
 .

## Using the Histogram dialog

 The active layer name is shown at the top of the dialog.

 Channel

 The drop-down below the active layer name allows you to select which
 channel to use. The available options depend on the layer type of
 the active layer. Possible options are:

 Value

 For RGB and Grayscale images, this shows the distribution of
 brightness values across the layer. For a grayscale image,
 these are read directly from the image data. For an RGB
 image, they are taken from the Value pseudochannel.

 For an indexed image, the Value channel
 actually shows the distribution of frequencies for each
 colormap index: thus, it is a pseudocolor
 histogram rather than a true color histogram.

 Red
 Green
 Blue

 These only appear for layers from RGB images. They show the
 distribution of intensity levels for the Red, Green, or Blue
 channels respectively.

 Alpha

 This shows the distribution of opacity levels. If the layer
 is completely transparent (alpha = 0) or
 completely opaque (alpha = 255), the histogram
 will consist of a single bar on the left or right edge.

 Luminance

 This shows the distribution of lightness intensity.

 RGB

## 
 Combined histograms of R, G, and B channels.

 This entry, only available for RGB layers, shows the R, G,
 and B histograms superimposed, so that you can see all of
 the color distribution information in a single view.

 Linear

 Non-Linear

 Perceptual

 These three buttons determine whether the tone reproduction (TRC)
 will be displayed using a linear, non-linear, or perceptual X axis.

 Linear histogram

 Logarithmic histogram

 These two buttons determine whether the histogram will be displayed
 using a linear or logarithmic Y axis. For images taken from
 photographs, the linear mode is most commonly useful. For images
 that contain substantial areas of constant color, though, a linear
 histogram will often be dominated by a single bar, and a
 logarithmic histogram will often be more useful.

 Range Setting

## Dialog aspect after range fixing.

 You can restrict the analysis, for the statistics shown at the
 bottom of the dialog, to a limited range of values if you wish.
 You can set the range in one of three ways:

 Click and drag the pointer across the histogram display area,
 from the lowest level to the highest level of the range you
 want.

 Click and drag the black or white triangles on the slider
 below the histogram.

 Use the spinbutton entries below the slider (left entry:
 bottom of range; right entry: top of range).

 Statistics

 At the bottom of the dialog some basic statistics are shown
 describing the distribution of channel values, restricted to the
 selected range:

Mean: the mean value of the interval
 in the selected channel.

Std Dev: Standard deviation. Gives an
 idea about how homogeneous the distribution of values in the
 interval is.

Median: For example, the value of the
 fiftieth peak in a 100 peaks interval.

Pixels: The number of pixels in the
 active layer or selection.

Count: The number of pixels in a peak
 (when you click on the histogram) or in the interval.

Percentile: The ratio between the
 number of pixels in the interval and the total number of
 pixels in the active layer or selection.

 Compute unique colors

 When enabled, this computes and shows the amount of unique colors
 or grayscale values present in your image. When there is a
 selection, it will only count the colors inside the selection.

 This setting does not adjust for a selected range like the
 statistics above do.