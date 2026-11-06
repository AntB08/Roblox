## Float

 Selection
 Floating selection (command)

 Selection
 Cut and Float

 Selection
 Copy and Float

 The Float submenu consists of commands to convert
 a selection into a floating selection.

 A floating selection (sometimes called a floating layer) is
 a type of temporary layer which is similar in function to a normal layer,
 except that before you can resume working on any other layers in the
 image, a floating selection must be anchored.
 That is, you have to attach it to a normal (non-floating) layer, usually
 the original layer (the one which was active previously), or turn it into
 a new layer.

 You cannot perform any operations on other layers while the image has a
 floating selection!

 You can use various operations to change the image data on the floating
 selection. There can only be one floating selection in an image at a time.

 If you display the layer boundary by using the
 Show Layer Boundary
 command, you may have difficulty selecting a precise area of the
 image which you want in a layer. To avoid this problem, you can make a
 rectangular selection, transform it into a floating selection and
 anchor it to a new layer. Then simply remove the original layer.

## Activating the Submenu

 You can access this submenu from the main menu through

 Select
 Float
 .

## Contents of the Float submenu

 The Float submenu commands are described below.

 Cut and Float

 The Cut and Float command cuts the image selection
 from the layer and converts it into a floating selection.

## Activating the Command

 You can access this command from the main menu through

 Select
 Float
 Cut and Float
 .

 You can also use the keyboard shortcut

 Shift
 Ctrl
 L
 .

 Copy and Float

 The Copy and Float command copies the image selection
 from the layer and converts it into a floating selection.

## Activating the Command

 You can access this command from the main menu through

 Select
 Float
 Copy and Float
 .

## Creating a Floating Selection Automatically

 Some image operations create a floating selection automatically:

 The paste operations
 Paste Buffer,
 Paste Buffer In Place,
 Paste Buffer Into The Selection,
 Paste Buffer Into The Selection In Place,
 Paste as Floating Data or
 Paste as Floating Data In Place or
 Paste as Floating Data Into Selection or
 Paste as Floating Data Into Selection In Place,
 also create a floating selection.

 In addition, all the Transform tools:
 Unified Transform,
 Rotate,
 Scale,
 Shear,
 Flip,
 Perspective,
 3D Transform,
 and
 Handle Transform,
 create a floating selection when they are used on a selection,
 rather than a layer. When the Transform mode is
 Layer and a selection already exists,
 these tools transform the selection and create a floating selection
 with the result. If a selection does not exist, they transform the
 current layer and do not create a floating selection. (If the
 Transform mode is
 Selection, they also do not create a
 floating selection.)

 By click-and-dragging a selection while pressing the
 CtrlAlt, or
 ShiftAlt keys
 (see ) you also
 automatically create a floating selection.

## Anchor a Floating Selection

You can anchor a floating selection in various ways:

 You can anchor the floating selection to the current layer the
 selection is originating from. To do this, click anywhere on the
 image except on the floating selection. This merges the floating
 selection with the current layer.

 Use the
 Anchor layer command
 (CtrlH).

 By clicking on the anchor button

 Anchor the floating Layer

 of the Layers Dialog, that
 appears when the floating selection is created,
 instead of the default Merge layers icon.

 Use the
 To New Layer command (

 Shift
 Ctrl
 N
 ) to
 turn the floating selection into a newly created layer.