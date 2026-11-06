## Channels Dialog

 Dialogs
 Channels

 Channel
 Dialog

## The Channels dialog

 The Channels dialog is the main interface to edit, modify and manage your
 channels. Channels have a double usage. This is why the dialog is divided
 into two parts: the first part for color channels and the second part for
 selection masks.

 Color channels apply to the image and not to a
 specific layer. Basically, three primary colors are necessary to render
 all the wide range of natural colors. As other digital software,
 GIMP uses Red, Green, and Blue as primary colors. The
 first and primary channels display the Red,
 Green, and Blue values of each
 pixel in your image.

 Next to the channel name is a thumbnail displaying a grayscale
 representation of each channel, where white is 100% and black is
 0% of the primary color. Alternatively, if your image is not a colored but
 a Grayscale image, there is only one primary channel called
 Gray. For an Indexed image with a fixed number of
 known colors there is also only one primary channel called
 Indexed.

 Then there is an optional channel called Alpha. This
 channel displays transparency values of each pixel in your image
 (See Alpha Channel in
 Glossary). In front of this channel is a thumbnail displaying a grayscale
 representation of the transparency where white is opaque and visible, and
 black is transparent and invisible. If you create your image without
 transparency then the Alpha channel is not present, but you can add it
 from the Layers Dialog context
 menu.
 Also, if you have more than one layer in your image,
 GIMP automatically creates an Alpha channel.

GIMP doesn't support CMYK or YUV color models.

## Representation of an image with channels

Red channel

Green channel

Blue channel

Alpha channel

All channels

 The right image is decomposed in three color channels (red, green, and
 blue) and the Alpha channel for transparency. On the right image the
 transparency is displayed as a gray checkerboard. In the color channel
 white is always white because all the colors are present and black is
 black. The red hat is visible in the red channel but quite invisible in
 the other channels. This is the same for plain green and blue which are
 visible only in their own channels and invisible in others.

## Activating the Dialog

 This dialog is a dockable dialog; see the
 section for help on manipulating
 it.

 You can access it:

 From the main menu through

 Windows
 Dockable Dialogs
 Channels
 .

 From the Tab menu in any dockable dialog by clicking on

 and selecting

 Add Tab
 Channels
 .

 In the Windows menu, there is a list of
 detached windows which exists
 only if at least one dialog remains open. In this case, you can raise
 the Channels dialog from the main menu:

 Windows
 Channels
 .

## Using the Channels Dialog

 Overview

 The Channels Dialog consists of a list of color channels and the
 optional Alpha channel.
 Below that is a list of selection mask channels.
 A right-click in a channel list entry opens the
 channel context menu.

 The color channels are always organized in the same order. They
 cannot be removed. You can only change their visibility and
 select or unselect them. By default, all of these channels are
 visible and selected.

 To select a channel, click on a color channel in the list.
 This toggles the selection of the channel, meaning a selected
 channel will become unselected and vice versa.
 The selected color channels appear highlighted in the dialog.

 Unselecting one of the color channels red, blue, or green has
 severe consequences. For instance if you disable the blue channel,
 all pixels from now on added to the image will not have a blue
 component, and so a white pixel will have the yellow complementary
 color.

 Making one of the color channels invisible does not influence how
 tools work and only changes what is currently displayed on your
 screen. For example, a brush will continue to paint as usual, and
 the eraser will change the alpha value of pixels also when the
 alpha channel is set to be not visible.

 The selected color channels define which parts of a tool's action
 are applied to the layer. For example, the eraser will not change
 your image if the alpha channel is not selected.

 The duplicate and selection commands documented below can also
 be used on the color channels. However, this only works when
 accessing the command from the right-click context menu, and
 only for one channel at a time.

 Selecting multiple channels

 GIMP allows you to select multiple selection mask
 channels and perform actions on them. You can e.g. move them to a
 different location in the channels stack, and convert them to
 selections.
 Selecting multiple channels is done by using the mouse and
 Shift key, for adding a range of channels, or
 Ctrl key, for adding or removing the clicked
 channel.

 Channel list header

 Directly above the list of selection masks is the header bar. On
 the left you see the icons that identify the visibility and lock
 columns. In the middle a text label will tell you how many channels
 are currently selected if it is more than one.

 Search layers and Saved searches.

 -->

 Channel attributes

 Every channel is shown in the list with its own attributes, which are
 very similar to the layer
 attributes:

 Channel visibility

 By default, all color channels are visible, and color mask
 channels are invisible.
 Clicking on the eye-symbol, or the empty space if the channel
 is not visible, will toggle the visibility of the channel.
 Shift-clicking on the icon causes
 all other channels to be hidden.

 Channel lock attributes

 Each selection mask channel has lock attributes. If one of its
 attributes is set, the respective lock icon will show up in front
 of the thumbnail.

 When multiple attributes are set, a double lock icon will
 show here. Clicking in this column allows you to change
 these attributes.

 Lock pixels

 This icon shows when lock pixels is
 enabled for the current channel. When this is enabled,
 the channel is locked for any action that changes
 pixels, meaning there will be no changes done to this
 channel.

 Lock position and size

 This icon shows when lock position and size
 is enabled for the current channel. When this is enabled,
 the channel is locked for any action that changes its
 position or size.

 Lock visibility

 This toggle button controls the Lock
 setting for the visibility of the channel. If this is
 enabled, the channel visibility cannot be changed until
 you disable the lock.

 Thumbnail

 A small preview icon represents the effect of the channel. This
 preview can be enlarged by holding down the left mouse button
 on it.

 Channel name

 The name of the channel, which must be unique within the image.
 Double-clicking on the name of a selection mask channel will
 allow you to edit it. The names of the primary channels (Red,
 Green, Blue, Alpha) can not be changed.
 Double-clicking on the preview icon will open a dialog where
 you can set all channel attributes.

 Managing channels

 Channel
 Edit Channel Attributes

 Channel
 Create a New Channel Mask

 Channel
 Move Channel Mask

 Channel
 Duplicate Channel Mask

 Channel
 Delete Channel Mask

 Channel
 Channel to Selection

 The button bar at the bottom offers the following functionality:

 New Channel

 This creates a new channel. A dialog will open where you can set
 the Channel name, the
 Color tag, the
 channel attributes and
 lock attributes,
 and finally the Opacity and color used for
 the mask in the image window. A click on the color button
 displays the GIMP color selector where you can change the mask
 color.

 If you press the Shift key while clicking the
 New Channel button, the New Channel
 dialog will not be opened. Instead the new channel will be
 created with the same settings as used previously.
 This new channel is a selection mask applied over the image.
 See for more details
 Selection Mask.

 Raise Channels

 This moves the selected channels up in the list.
 Press the Shift key to move the selected
 channels to the top of the list.

 Lower Channels

 This moves selected channels down in the list.
 Press the Shift key to move the selected
 channels to the bottom of the list.

 Duplicate Channels

 This creates a copy of the selected channels. The name
 of the new channels is suffixed with a number.

 You can also duplicate color channels or the Alpha channel.
 It's an easy way to keep a copy of them and to use them later
 as a selection in an image.
 Note that you can only duplicate one color channel at a
 time, and only using the right-click context menu.

 Replace the Selection with Selected Channels

 This transforms the selected channels to become a selection. By
 default the selection derived from channels replaces the
 active selection. You can change this by using control keys.

 Shift:
 the selection derived from a channel is added to the
 active selection. The final selection is merged from both.

 Ctrl:
 the final selection is the subtraction of the selection
 derived from a channel from the active selection.

 ShiftCtrl
 :
 the final selection is the intersection of the selection
 derived from a channel with the active one. Only the
 selected parts common to both are kept.

 Delete Channels

 This deletes the selected channels.