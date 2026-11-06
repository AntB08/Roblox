by by lexa
 2005-12-01 informalfigure replaced by figure by lexa
 -->

## Blur/Sharpen

 Tools
 Blur/Sharpen

 Blur/Sharpen

 The Blur/Sharpen tool uses the current brush to locally blur or sharpen your
 image. Blurring with it can be useful if some element of your image stands
 out too much, and you would like to soften it. If you want to blur a whole
 layer, or a large part of one, you will probably be better off using one
 of the Blur Filters.
 The direction of a brushstroke has no effect: if you want directional
 blurring, use the Smudge tool.

 In Sharpen mode, the tool works by increasing the contrast
 where the brush is applied. A little bit of this may be useful, but
 over-application will produce noise. Some of the
 Enhancement Filters, particularly
 the Unsharp Mask, do a
 much cleaner job of sharpening areas of a layer.

 You can create a more sophisticated sharpening brush using the Clone
 tool. To do this, start by duplicating the layer you want to work on,
 and run a sharpening filter, such as Unsharp Mask, on the copy. Then
 activate the Clone tool, and in its Tool Options set Source to
 Image source and Alignment to Registered.
 Set the Opacity to a modest value, such as 10. Then
 Ctrl-click on the copy to make it the source image. If
 you now paint on the original layer, you will mix together, where the
 brush is applied, the sharpened version with the unsharpened version.

 Both blurring and sharpening work incrementally: moving the brush
 repeatedly over an area will increase the effect with each additional
 pass. The Rate control allows you to determine how quickly the
 modifications accumulate. The Opacity control, however, can be used to
 limit the amount of blurring that can be produced by a single brushstroke,
 regardless of how many passes are made with it.

## Activating the Tool

 There are different possibilities to activate the tool:

 From the main menu:
 Tools
 Paint tools
 Blur/Sharpen
 .

 By clicking the tool icon

 in the Toolbox.

 By pressing the ShiftU
 keyboard shortcut.

## Key modifiers

 See the Paint Tools' Common
 Features for a description of key modifiers that have the same
 effect on all paint tools.

 Ctrl

 Holding down the Ctrl key toggles between Blur
 and Sharpen
 modes; it reverses the setting shown in the Tool Options.

## Options

## Tool Options Dialog

 Mode
 Opacity
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
 Lock brush to view
 Expand Layers

 Hard edge

 This option gives a hard contour to the blurred/sharpened area.

 Convolve Type

 Blur
 mode causes each pixel affected by the brush to be blended with
 neighboring pixels, thereby increasing the similarity of pixels
 inside the brushstroke area. Sharpen
 mode causes each pixel to become more different from its neighbors
 than it previously was: it increases contrast inside the
 brushstroke area. Too much Sharpen ends in an ugly flocculation
 aspect. Whatever setting you choose here, you can reverse
 it on-the-fly by holding down the Ctrl key.

 Convolve refers to a mathematical method using
 matrices.

 Rate

 The Rate
 slider sets the strength of the Blur/Sharpen effect.