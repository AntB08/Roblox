## Selection masks

 Masks
 Selection mask

 Selection
 Selection mask

 Masks
 Channel mask

 Channel
 Channel mask

 Masks
 Quick mask

## A selection composed out of channels.

 Channels can be used to save and restore your selections.
 In the Channels dialog you can see a thumbnail representing the selection.
 Selection Masks are a graphical way to build selections into a gray level
 channel where white pixels are selected and black pixels are not selected.
 Therefore gray pixels are partially selected. You can think of them as
 feathering the selection, a smooth transition between selected and not
 selected. This is important to avoid the ugly pixelization effect when you
 fill the selection or when you erase its content after isolating a subject
 from background.

 Creating Selection Masks

 There are several ways to initialize a selection mask.

 From the main menu

 Select
 Save to Channel

 if there is an active selection.

 In the image window the bottom-left

 button creates a
 Quick Mask; the content
 will be initialized with the active selection.

 From the Channels dialog, when you click on the
 New channel button or from the context
 menu. When created, this Selection mask appears in the
 Channels dialog, named Selection maskcopy with
 a queuing number. You can change this by using the context
 menu that you get by right-clicking on the channel.

## Using Selection Masks

 Once the channel is initialized, selected (highlighted in blue), visible
 (eye-icon in the dialog), and displayed as you want (color and opacity
 attributes), you can start to work with all the paint tools. The colors
 used are important. If you paint with some color other than white, gray,
 or black, the color Value (luminosity) will be used to define a gray
 (medium, light, or dark). When your mask is painted, you can transform
 it to a selection by clicking on the

 button (Channel to
 Selection) or from the
 context menu.

 You can work in selection masks not only with the paint tool but also
 with other tools. For instance, you can use the selection tools to fill
 areas uniformly with gradients or patterns. By adding many selection
 masks in your list you can easily compose very complex selections. One
 can say that a selection mask is to a selection as a layer is to an
 image.

 As long as a selection mask is activated you are working in the mask
 and not in the image. To work in the image you have to deactivate all
 selection masks. Don't forget also to stop displaying masks in the
 image by removing the eye icon. Check also that all RGB and Alpha
 channels are activated and displayed in the image.