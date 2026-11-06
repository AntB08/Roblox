## Merge Down

 Layer
 Stack managing
 Merge current layer with the underlying layer

 Merge Down

 The Merge Down
 command merges the active layer with the layer just below it in the stack,
 taking into account the various properties of the active layer, such as
 its opacity and layer
 mode.
 The resulting merged layer will be in Normal mode, have opacity set to 100%,
 and will have an alpha channel even if the original layers didn't have one.
 If the layer below is not opaque, or if it is in some mode other than
 Normal, then this command will generally change the appearance of the image.

 The most common use of Merge Down is to
 construct a layer, by starting with a base layer (usually
 opaque and in Normal mode, so that you can see what you are doing), and
 adding a modification layer on top of it, with whatever
 shape, opacity, and layer mode you need. In this case, merging down the
 modification layer will combine the two layers into one, without
 changing the way the image looks.

 The Merge Down command is not available when
 a floating layer is present.

## Activating the Command

 You can access this command from the main menu through

 Layer
 Merge Down
 .

 From the
 Layers Dialog, you
 can access it through the Merge Down command
 of its context menu, or by clicking on the

 Merge Down

 icon button on the bottom of that dialog.