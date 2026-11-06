## New Layer

 Layer
 Stack managing
 Create a new layer

 New Layer

 The New Layer… command opens the Create
 a New Layer dialog that allows you to add one or more new, empty
 layers to the layer stack of the image, just above the selected layer(s).

 If multiple layers are selected, a new layer will be created above each
 of them.

 When a floating selection is
 present, this command will show up as
 To New Layer.
 Using this, will turn the floating selection into a normal layer without
 opening the New Layer dialog.

## Activating the Command

 You can access this command from the main menu through

 Layer
 New Layer…
 .

 You can also use the keyboard shortcut

 Shift
 Ctrl
 N
 .

 From the
 Layers Dialog, you
 can access it through the New Layer command
 of its context menu, or by clicking on the

 New Layer

 icon button on the bottom of that dialog.

## Description of the New Layer Dialog

## The New Layer dialog

 Below the title Create a new layer, the name of the image
 that this new layer will belong to, is displayed. To the right of the
 title a thumbnail of that image is shown. This will enable you to check
 that you are adding the layer to the correct image when there is more than
 one image open.

 Layer Name

 The name of the new layer. It does not have any functional
 significance; it is simply a convenient way for you to remember
 the purpose of the layer. The default name is Layer,
 but it remembers the last name you used. If a layer with the name
 you chose already exists, a number is automatically appended to it
 to make the name unique (e.g., Layer #1) when you
 click OK to create the layer.

 Color tag

 If you click on one of these color buttons, the "Eye" icon box
 of the created layer will have this color. This can help you
 identify or group layers to make them easier to spot when you
 have a lot of layers in your image.

 Mode

 A layer's mode determines how the layer is combined with the layers
 below it. The default is Normal. The drop-down list
 offers a wide choice of layer modes, also known as blend modes.
 On the right, there is another drop-down list to select between
 Default or Legacy layer modes.

 Layer modes are described in more detail in
 Layer Modes and
 Legacy Layer
 Modes.

 Blend space

 Composite space

 The color space used for blending or compositing the layer with the
 layers below it. Blending determines how the colors
 of the upper and lower layer are mixed together, and
 compositing how the upper and lower layer are merged
 together with respect to the transparency of each pixel.

 Depending on the layer mode (see above) one or both of these
 settings may be disabled. It is only enabled for layer modes where
 setting this has any effect. When enabled, the default is
 Auto. Note that what Auto
 translates to, depends on the chosen layer mode. It is not the same
 for all modes. Some use linear, others use perceptual.

 Besides Auto, the choices are
 RGB (linear),
 RGB (from color profile) and
 RGB (perceptual).

 The linear and perceptual (non-linear) encodings are described in
 choosing
 precision and encoding and in the
 Glossary.

 RGB (from color profile) is what was called
 RGB (perceptual) in older versions of
 GIMP. It was renamed, because it was only
 perceptual when you used an sRGB image.

 To keep compatibility with older XCF images, this was not removed.
 In general, you should prefer the new
 RGB (perceptual) that does work with any
 color profile.

 When changing the layer mode, both Blend space
 and Composite space are always reset to
 Auto to make sure the settings make sense
 for that particular layer mode.

 Composite mode

 The layer Mode, sometimes referred to as its
 blend mode (Normal, Multiply, etc.), determines how
 the color values of the layer and its backdrop
 are combined (together with the Blend space
 setting).
 The composite mode of a layer determines how
 the alpha values of the layer and its backdrop
 are combined (together with the Composite space
 setting). The layer's backdrop is the content against which
 the layer is composited; namely, it's the combination of the layers
 below it.

 There are two regions of interest when compositing the layer
 against its backdrop: the opaque region of the backdrop, and the
 opaque region of the layer. The layer's blend mode determines how
 to combine the colors of the intersection of
 these two regions: i.e., the common opaque region of both the
 backdrop and the layer (pixels belonging to only one of these
 regions don't need to be combined with anything, and retain their
 original color). The layer's composite mode determines which part
 of these regions to keep, and which to discard.

 The example images below show the composition of two layers —
 the bottom layer containing a red feathered circle, and the top
 layer containing a green feathered circle — using
 Addition mode, and different composite modes
 (applied to the top layer).

 Union:
 keeps the opaque regions of both the layer and its backdrop,
 i.e their union.

## Union option example

 Clip to backdrop:
 keeps only the opaque regions of the backdrop (this includes
 the common opaque region to both the backdrop and the layer i.e
 their intersection).

## Clip to backdrop option example

 Clip to layer:
 keeps only the opaque region of the layer (this includes
 the common opaque region to both the backdrop and the layer,
 i.e their intersection).

## Clip to layer option example

 Intersection:
 keeps only the opaque region to both the backdrop and the
 layer, i.e their intersection.

## Intersection option example

 Auto:
 Auto mode is not a separate composite mode, but
 rather corresponds to one of the other composite modes,
 depending on the layer's blend mode: for Normal,
 Dissolve, and Merge, it
 corresponds to Union, and for the other modes
 (that support different composite modes) it corresponds to
 Clip to Backdrop.

 Opacity

 Sets the opacity of painting on the layer. Default is 100%.

 Width
 Height

 The dimensions of the new layer. When the dialog appears, the
 values are initialized to the dimensions of the image. You can
 change them by using the two text boxes. You can also change
 the units in the pull-down menu to the right.

 Offset X
 Offset Y

 The default origin of the new layer is the upper left corner of the
 image canvas. Here, you can set the exact position of the layer. By
 choosing a negative offset, you can set the layer to be partially
 outside the image canvas.

 Fill With

 There are numerous options for filling the new layer:
 the current Foreground color,
 the current Background color,
 Middle Gray (CIELAB),
 White,
 Transparency,
 and the current Pattern.

 Switches

 The switches Visible, Lock
 pixels, Lock position and size,
 Lock visibility and Lock
 alpha on the right side of this dialog are described in
 the Layers dialog documentation. See
 Layer Attributes.