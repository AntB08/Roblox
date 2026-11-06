## The Selection

 Selections
 Concepts

 Often when you operate on an image, you only want part of it to be
 affected. In GIMP, you make this happen by
 selecting
 that part. Each image has a selection
 associated with it. Most, but not all, GIMP operations
 act only on the selected portions of the image.

## How would you isolate the tree?

 There are many, many situations where creating just the right selection is
 the key to getting the result you want, and often it is not easy to
 do. For example, in the above image, suppose you want to cut the tree out
 from its background, and paste it into a different image. To do
 this, you need to create a selection that contains the tree and nothing
 but the tree. It is difficult because the tree has a complex shape, and
 in several spots is hard to distinguish from the objects behind it.

## Selection shown as usual with dashed line.

 Now here is a very important point, and it is crucial to understand this.
 Ordinarily when you create a selection, you see it as a dashed line
 enclosing a portion of the image. The common, not entirely accurate,
 idea you could get from this, is that
 the selection is a sort of container, with the selected parts of the image
 inside, and the unselected parts outside. Although this concept of
 selection is okay for many purposes, it is not entirely correct.

 Actually the selection is implemented as a channel.
 In terms of its internal structure, it is identical to the red, green,
 blue, and alpha channels of an image. Thus, the selection has a value
 defined at each pixel of the image, ranging between 0 (unselected) and 255
 (fully selected). The advantage of this approach is that it allows some
 pixels to be partially selected,
 by giving them intermediate values between 0 and 255. As you will see,
 there are many situations where it is desirable to have smooth transitions
 between selected and unselected regions.

 What, then, is the dashed line that appears when you create a selection?

 The dashed line is a contour line, dividing areas
 that are more
 than half selected from areas that are less than half selected.

## Same selection in Quick Mask mode.

 While looking at the dashed line that represents the selection, always
 remember that the line only tells part of the story. If you want to see the
 selection in full detail, the easiest way is to click the
 Quick Mask button
 in the lower left corner of the image window. This causes the selection to
 be shown as a translucent overlay atop the image. Selected areas are
 unaffected; unselected areas are reddened. The more completely selected an
 area is, the less red it appears.

 Many operations work differently in Quick Mask mode, as mentioned in the
 Quick Mask overview.
 Use the Quick Mask button in the lower left corner of the image window to
 toggle Quick Mask mode on and off.

## Same selection in Quick Mask mode after feathering.

## Feathering

 With the default settings, the basic selection tools, such as the
 Rectangle Select tool, create sharp selections. Pixels inside the dashed
 line are fully selected, and pixels outside completely unselected. You
 can verify this by toggling Quick Mask: you see a clear rectangle with
 sharp edges, surrounded by uniform red.
 Use the Feather edges checkbox in the Tool Options to
 toggle between graduated selections and sharp selections.
 The feather radius, which
 you can adjust, determines the distance over which the transition
 occurs.

 If you are following along, try this with the Rectangle Select tool,
 and then toggle Quick Mask. You will see that the clear rectangle has
 a fuzzy edge.

 Feathering is particularly useful when you are cutting and pasting, so
 that the pasted object blends smoothly and unobtrusively with its
 surroundings.

 It is possible to feather a selection at any time, even if it
 was originally created as a sharp selection. Use

 Select
 Feather

 from the main menu to open the Feather Selection dialog. Set the
 feather radius and click OK. Use

 Select
 Sharpen

 to do the opposite—sharpen a graduated selection into an
 all-or-nothing selection.

 For technically oriented readers: feathering works by applying a
 Gaussian blur to the selection channel, with the specified blurring
 radius.

## Making a Selection Partially Transparent

 You can set layer opacity, but you cannot do that directly for a
 selection. It is quite useful to make the image of a glass
 transparent. Use the following methods to set the layer opacity:

 For simple selections, use the Eraser tool with the desired opacity.

 For complex selections: go to

 Select
 Float

 and choose one of Cut and Float or
 Copy and Float. Either of these creates
 a new layer with the selection called Floating Layer
 ().

 Set the opacity slider in the Layers dialog to the desired opacity.
 Then anchor the selection: outside the selection, the mouse pointer
 includes an anchor. When you click while the mouse pointer includes
 the anchor, the floating selection
 disappears from the Layers dialog and the selection is at the right
 place and partially transparent (anchoring works this way only if a
 selection tool is activated: you can also use the Anchor Layer
 command in the context menu by right clicking on the selected layer
 in the Layers dialog).

 And, if you use this function frequently:

 Ctrl
 C
 to copy the selection, and

 Ctrl
 V
 to paste the clipboard as a new layer.
 You can now adjust the opacity of the new layer.

 Another way: use

 Layer
 Mask
 Add Layer Masks…

 to add a layer mask to the layer with the
 selection, initializing it with the selection. Then use a brush with
 the desired opacity to paint the selection with black, i.e. paint it
 with transparency. Then Layer
 MaskApply Layer Masks
 . See .

 To make the solid background of an image
 transparent, add an Alpha channel, and use Fuzzy
 Select to select the background. Then, use the Color Picker
 tool to select the background color, which becomes the foreground
 color in Toolbox. Use the Bucket Fill tool with the selected color.
 Set the Bucket Fill mode to Color Erase, which erases
 pixels with the selected color; other pixels are partially erased
 and their color is changed.

 The simplest method is to use

 Edit
 Clear
 , which gives complete transparency to a selection.