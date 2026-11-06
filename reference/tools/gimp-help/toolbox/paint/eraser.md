## Eraser

 Tools
 Eraser

 Eraser

 Transparency
 Eraser tool

 The Eraser is used to remove areas of color from the current layer or from
 a selection of this layer. If the Eraser is used on something that does
 not support transparency (a selection mask channel, a layer mask, or the
 Background layer if it lacks an alpha channel), then erasing will show the
 background color, as displayed in the Color Area of the Toolbox (in case
 of a mask, the selection will be modified). Otherwise, erasing will
 produce either partial or full transparency, depending on the settings for
 the tool options. You can learn more on how to add an alpha channel to a
 layer in .

## Eraser and Alpha channel

 The Background Color
 is White. The image has no Alpha channel. The Eraser
 (Opacity 100%) shows the white background color.

 The image has an Alpha channel. The Eraser shows
 transparency using a
 checkerboard pattern.

 If you need to erase some group of pixels completely, leaving no trace
 behind of their previous contents, you should check the "Hard edge" box in
 the Tool Options. Otherwise, sub-pixel brush placement will cause partial
 erasure at the edges of the brush-stroke, even if you use a hard-edged
 brush.

 If you use GIMP with a tablet, you may find it convenient to treat the
 reverse end of the stylus as an eraser. To make this work, all you need
 to do is click the reverse end on the Eraser tool in the Toolbox.
 Because each end of the stylus is treated as a separate input device,
 and each input device has its own separate tool assignment, the reverse
 end will then continue to function as an Eraser as long as you don't
 select a different tool with it.

## Activating the Tool

 There are different possibilities to activate the tool:

 From the main menu:

 Tools
 Paint Tools
 Eraser
 .

 By clicking the tool icon

 in the Toolbox.

 By pressing the ShiftE
 keyboard shortcut.

## Key modifiers

 See the for a description of key
 modifiers that have the same effect on all paint tools.

 Ctrl

 For the Eraser, holding down the Ctrl key puts it
 into color picker mode, so that it selects the
 color of any pixel it is clicked on. Unlike other brush tools,
 however, the Eraser sets the background
 color rather than the foreground color. This is more useful,
 because on drawables that don't support transparency, erasing
 replaces the erased areas with the current background color.

 Alt

 For the Eraser, holding down the Alt key switches
 it into anti-erase mode, as described below in the
 Tool Options section. Note that on some systems, the
 Alt key is trapped by the Window Manager. If this
 happens to you, you may be able to use
 AltShift
 instead.

## Options

## Tool Options Dialog

 Mode
 Brush
 Size
 Aspect Ratio
 Angle
 Spacing
 Hardness
 Force
 Dynamics
 Dynamics Options
 Apply Jitter
 Smooth Stroke
 Lock brush size to view
 Incremental

 Opacity

 The Opacity slider, in spite of its name,
 in this tool determines the strength of the tool.
 Thus, when you erase on a layer with an alpha channel, the higher
 the opacity you use, the more transparency you get!

 Hard Edge

 This option avoids partial erasure at the edges of the
 brush-stroke. See above.

 Anti Erase

 The Anti Erase option of the Erase tool can un-erase areas of an
 image, even if they are completely transparent. This feature only
 works when used on layers with an alpha channel. In addition to
 the check-button in the Tool Options, it can also be activated
 on-the-fly by holding down the Alt key (or, if
 the Alt key is trapped by the Window Manager, by
 holding down
 AltShift).

 To understand how anti-erasing is possible, you should realize
 that erasing (or cutting, for that matter) only affects the
 alpha channel, not the RGB channels that contain the image data.
 Even if the result is completely transparent, the RGB data is
 still there, you simply can't see it. Anti-erasing increases the
 alpha value so that you can see the RGB data once again.

 Selection
 Change shape

 You can use the Eraser tool to change the shape of a floating
 selection. By erasing, you can trim the edges of the selection.