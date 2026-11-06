## Quick Mask

## Dialog Quick Mask

 A Quick Mask is a
 Selection Mask
 intended to be used temporarily to paint a selection. Temporarily means
 that, unlike a normal selection mask, it will be deleted from the
 channel list after its transformation to selection. The
 selection tools
 sometimes show their limits when they have to be used for doing complex
 drawing selection, as progressive. In this case, using the Quick Mask is a
 good idea which can give very good results.

## Activating the Dialog

 The Quick Mask can be activated in different ways:

 From the main menu:

 Select
 Toggle Quick Mask
 .

 By clicking the bottom-left

 button highlighted in the screenshot.

 By using the

 ShiftQ

 shortcut.

## Creating a Quick Mask

 To initialize a Quick Mask,
 click the bottom-left

 button in the image window. If a selection was
 active in your image, then its content appears unchanged while the
 border is covered with a translucent red color. If no selection was
 active then all the image is covered with a translucent red color.
 Another click on the bottom-left button will deactivate the quick mask.

 From the Channels dialog you can double click on the name or the
 thumbnail to edit the QMask attributes. Then you
 can change the Opacity and its filling color. At
 every moment you can hide the mask by clicking on the eye icon

 in front of the QMask.

 The mask is coded in gray tones, so you must use white or gray to
 decrease the area limited by the mask and black to increase it. The area
 painted in light or dark gray will be transition areas for the selection
 like feathering. When your mask is ready, click again on the bottom-left
 button in the image window and the quick mask will be removed from the
 channel list and converted to a selection.

 Quick mask's purpose is to paint a selection and its transitions with
 the paint tools without worrying about managing selection masks. It's a
 good way to isolate a subject in a picture because once the selection is
 made you only have to remove its content (or inverse if the subject is
 in the selection).

## Using Quick Mask with a gradient

 Screenshot of the image window with activated Quick Mask. As long as
 the Quick Mask is activated, all operations are done on it. A
 gradient from black (left) to white (right) has been applied to the
 mask.

 The Quick Mask is now disabled. The selection occupies the right half
 part of the image (marching
 ants) because the limit of the selection is at the middle of
 the gradient.

 A stroke is now added during the enabled selection. Weird! The
 gradient, although not visible, remains active all over the image,
 in selected and non selected areas!

 After the Quick Mask Button is pressed, the command generates a
 temporary 8-bit (0-255) channel, on which the progressive selection
 work is stored. If a selection is already present the mask is
 initialized with the content of the selection. Once Quick Mask has been
 activated, the image is covered by a red semi-transparent veil. This
 one represents the non-selected pixels. Any
 paint tool
 can be used to create the selection on the Quick Mask. They should use
 only grayscale color, conforming the channel properties, white enabling
 to define the future selected place. The selection will be displayed as
 soon as the Quick Mask will be toggled but its temporary channel will
 not be available anymore.

 To save in a channel the selection done with the Quick Mask select in
 the main menu

 Select
 Save to Channel
 .

## Usage

 Open an image or begin a
 new document.

 Activate the Quick Mask using the left-bottom button in the image
 window. If a selection is present the mask is initialized with the
 content of the selection.

 Choose a drawing tool
 and use it with grayscale colors on the Quick Mask.

 Deactivate the Quick Mask using the left-bottom button in the image
 window.