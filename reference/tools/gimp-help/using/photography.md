## Working with Digital Camera Photos

 Photography

## Introduction

 One of the most common uses of GIMP is to fix digital camera images
 that for some reason are less than perfect. Maybe the image is
 overexposed or underexposed; maybe rotated a bit; maybe out of focus:
 these are all common problems for which GIMP has good tools. The purpose
 of this chapter is to give you an overview of those tools and the
 situations in which they are useful. You will not find detailed
 tutorials here: in most cases it is easier to learn how to use the tools
 by experimenting with them than by reading about them. (Also, each tool
 is described more thoroughly in the Help section devoted to it.) You
 will also not find anything in this chapter about the multitude of
 "special effects" that you can apply to an image using GIMP. You should
 be familiar with basic GIMP concepts before reading this chapter, but
 you certainly don't need to be an expert–if you are, you probably know
 most of this anyway. And don't hesitate to experiment: GIMP's powerful
 "undo" system allows you to recover from almost any mistake with a
 simple CtrlZ.

 Most commonly the things that you want to do to clean up an imperfect
 photo are of four types: improving the composition; improving the
 colors; improving the sharpness; and removing artifacts or other
 undesirable elements of the image.

## Improving Composition

## Rotating an Image

 It is easy, when taking a picture, to hold the camera not quite
 perfectly vertical, resulting in a picture where things are
 tilted at an angle. In GIMP, the way to fix this is to use the
 Rotate tool.
 Activate this by clicking its icon

 in the Toolbox, or by pressing the
 ShiftR while
 inside the image. Make sure the Tool Options are visible, and at
 the top, make sure for Transform: that the left
 button (Transform Layer) is selected. If you then
 click the mouse inside the image and drag it, you will see the image
 rotate as you drag. When the image looks right, click
 Rotate or press Enter, and
 the image will be rotated.

 Now as a matter of fact, it isn't so easy to get things right by this
 method: you often find that things are better but not quite perfect.
 One solution is to rotate a bit more, but there is a disadvantage to
 that approach. Each time you rotate an image, because the rotated
 pixels don't line up precisely with the original pixels, the image
 inevitably gets blurred a little bit. For a single rotation, the
 amount of blurring is quite small, but two rotations cause twice as
 much blurring as one, and there is no reason to blur things more than
 you have to. A better alternative is to undo the rotation and then do
 another, adjusting the angle.

 Fortunately, GIMP provides another way of doing it that is
 considerably easier to use: in the Rotate Tool Options, for the
 Transform Direction you can select "Corrective (Backward)". When you
 do this, instead of rotating the image to compensate for the error, you
 can rotate its frame to line up
 with the error. If this seems confusing, try it and you will see that
 it is quite straightforward.

 After you have rotated an image, there will be unpleasant triangular
 "holes" at the corners. One way to fix them is to create a background
 that fills the holes with some unobtrusive or neutral color, but
 usually a better solution is to crop the image. The greater the
 rotation, the more cropping is required, so it is best to get the
 camera aligned as well as possible when you take the picture in the
 first place.

## Cropping

 When you take a picture with a digital camera, you have some control
 over what gets included in the image but often not as much as you
 would like: the result is images that could benefit from trimming.
 Beyond this, it is often possible to enhance the impact of an image by
 trimming it so that the most important elements are placed at key
 points. A rule of thumb, not always to be followed but good to keep in
 mind, is the rule of thirds,
 which says that maximum impact is obtained by placing the center of
 interest one-third of the way across the image, both widthwise and
 heightwise.

 To crop an image, activate the
 Crop
 tool in the Toolbox, or by pressing Shift
 C while inside the image. With the tool active,
 clicking and dragging in the image will sweep out a crop rectangle.
 When everything is perfect, hit Enter. Note: if
 Delete cropped pixels in Crop Tool Options is
 disabled, the cropped part will not be removed from the image, only
 the visible image area will be adjusted.

## Improving Colors

## Automated Tools

 In spite of sophisticated exposure-control systems, pictures taken
 with digital cameras often come out over- or under-exposed, or with
 color casts due to imperfections in lighting. GIMP gives you a variety
 of tools to correct colors in an image, ranging to automated tools
 that run with a simple button-click to highly sophisticated tools that
 give you many parameters of control. We will start with the simplest
 first.

 GIMP gives you several automated color correction
 tools. Unfortunately they don't usually give you quite the results
 you are looking for, but they only take a moment to try out, and if
 nothing else they often give you an idea of some of the
 possibilities inherent in the image. Except for "Auto Levels", you
 can find these tools by following the menu path

 Colors
 Auto

 in the main menu.

Here they are, with a few words about each:

 Equalize

 This is a very powerful adjustment that tries to spread the
 colors in the image evenly across the range of possible
 intensities. In some cases the effect is amazing, bringing out
 contrasts that are very difficult to get in any other way; but
 more commonly, it just makes the image look weird. Oh well, it
 only takes a moment to try.

 White balance

 This may enhance images with poor white or black by
 removing little used colors and stretch the remaining
 range as much as possible.

 Stretch Contrast

 This is useful for underexposed images: it adjusts the whole image
 until the brightest point is right at the saturation limit, and
 the darkest point is black. The downside is that the amount of
 brightening is determined entirely by the lightest and darkest
 points in the image, so even one single white pixel and/or one
 single black pixel will make normalization ineffective.
 It operates on the red, green, and blue channels independently.
 It often has the useful effect of reducing color casts.

 Stretch Contrast HSV

 Does the same as Stretch Contrast but works in HSV color
 space, rather than RGB color space. It preserves the Hue.

 Color Enhance

 This command increases the saturation range of the colors in the
 layer, without altering brightness or hue. So this command does
 not work on grayscale images.

 Auto Levels

 This is done by selecting

 Colors
 Levels…

 in the main menu,
 and then pressing the Auto Input Levels button near
 the center of the dialog. You will see a preview of the result;
 you must press Okay for it to take
 effect. Pressing Cancel instead will
 cause your image to revert to its previous state.

 If you can find a point in the image that ought to be perfect
 white, and a second point that ought to be perfect black, then
 you can use the Levels tool to do a semi-automatic adjustment
 that will often do a good job of fixing both brightness and
 colors throughout the image. First, bring up the Levels tool as
 previously described. Now, look down near the bottom of the
 Levels dialog for three buttons with symbols on them that look
 like eye-droppers (at least, that is what they are supposed to
 look like). The one on the left, if you mouse over it, shows its
 function to be Pick Black Point.
 Click on this, then click on a point in the image that ought
 to be black–really truly perfectly black, not just sort of
 dark–and watch the image change. Next, click on the rightmost of
 the three buttons ( Pick White Point
 ), and then click a point in the image that ought to be white,
 and once more watch the image change. If you are happy with the
 result, click the Okay button otherwise
 Cancel.

 Those are the automated color adjustments: if you find that none of
 them quite does the job for you, it is time to try one of the
 interactive color tools. All of these, except one, can be accessed via
 ColorsAuto
 in the main menu.

## Exposure Problems

 The simplest tool to use is the Brightness/Contrast
 tool. It is also the least powerful, but in many cases it does
 everything you need. This tool is often useful for images that are
 overexposed or underexposed; it is not useful for correcting color
 casts. The tool gives you two sliders to adjust, for
 Brightness and Contrast. If you have
 the option Preview checked (and almost certainly you
 should), you will see any adjustments you make reflected in the
 image. When you are happy with the results, press
 Okay and they will take effect. If you
 can't get results that you are happy with, press
 Cancel and the image will revert to its
 previous state.

 A more sophisticated, and only slightly more difficult, way of
 correcting exposure problems is to use the Levels tool. The
 dialog for this tool looks very complicated, but for the basic
 usage we have in mind here, the only part you need to deal
 with is the Input Levels area, specifically the three
 triangular sliders that appear below the histogram. We refer
 you to the Levels Tool Help
 for instructions;
 but actually the easiest way to learn how to use it is to
 experiment by moving the three sliders around, and watching
 how the image is affected. (Make sure that Preview is
 checked at the bottom of the dialog.)

 A very powerful way of correcting exposure problems is to use the
 Curves
 tool. This tool allows you to click and drag control points on a
 curve, in order to create a function mapping input brightness levels
 to output brightness levels. The Curves tool can replicate any effect
 you can achieve with Brightness/Contrast or the Levels tool, so it is
 more powerful than either of them. Once again, we refer you to the
 Curves Tool Help
 for detailed instructions, but the easiest way to learn how to use it
 is by experimenting.

 The most powerful approach to adjusting brightness and contrast across
 an image, for more expert GIMP users, is to create a new layer above
 the one you are working on, and then in the Layers dialog set the Mode
 for the upper layer to Multiply.
 The new layer then serves as a gain control
 layer for the layer below it, with white yielding maximum gain and
 black yielding a gain of zero. Thus, by painting on the new layer, you
 can selectively adjust the gain for each area of the image, giving you
 very fine control. You should try to paint only with smooth gradients,
 because sudden changes in gain will give rise to spurious edges in the
 result. Paint only using shades of gray, not colors, unless you want
 to produce color shifts in the image.

 Actually, Multiply is not the only mode that is useful
 for gain control. In fact, Multiply mode can only
 darken parts of an image, never lighten them, so it is only useful
 where some parts of an image are overexposed. Using
 Divide mode has the opposite effect: it can brighten
 areas of an image but not darken them. Here is a trick that is often
 useful for bringing out the maximum amount of detail across all areas
 of an image:

 Duplicate the layer (producing a new layer above it).

Desaturate the new layer.

 Apply a Gaussian blur to the result, with a large radius (100 or
 more).

Set Mode in the Layers dialog to Divide.

 Control the amount of correction by adjusting opacity in the
 Layers dialog, or by using Brightness/Contrast, Levels, or Curves
 tools on the new layer.

 When you are happy with the result, you can use
 Merge Down
 to combine the control layer and the original layer into a single
 layer.

 In addition to Multiply and Divide, you
 may every so often get useful effects with other layer combination
 modes, such as Dodge, Burn, or
 Soft Light. It is all too easy, though,
 once you start playing with these things, to look away from
 the computer for a moment and suddenly find that you have just
 spent an hour twiddling parameters. Be warned: the more
 options you have, the harder it is to make a decision.

## Adjusting Hue and Saturation

 In our experience, if your image has a color cast—too much red, too
 much blue, etc—the easiest way to correct it is to use the Levels
 tool, adjusting levels individually on the red, green, and blue
 channels. If this doesn't work for you, it might be worth your while
 to try the Color Balance tool or the Curves tool, but these are much
 more difficult to use effectively. (They are very good for creating
 certain types of special effects, though.)

 Sometimes it is hard to tell whether you have adjusted colors
 adequately. A good, objective technique is to find a point in the
 image that you know should be either white or a shade of gray.
 Activate the
 Color Picker
 tool (the eyedropper symbol in the Toolbox), and
 Shift-click on the aforesaid point: this brings up
 the Color Picker dialog. If the colors are correctly adjusted, then the
 red, green, and blue components of the reported color should all be
 equal; if not, then you should see what sort of adjustment you need to
 make. This technique, when well used, allows even color-blind people
 to color-correct an image.

 If your image is washed out—which can easily happen when you take
 pictures in bright light—try the
 Hue/Saturation
 tool, which gives you three sliders to manipulate, for Hue, Lightness,
 and Saturation. Raising the saturation will probably make the image
 look better. In some cases it is useful to adjust the lightness at the
 same time. ( Lightness here is similar to
 Brightness
 in the Brightness/Contrast tool, except that they are formed from
 different combinations of the red, green, and blue channels.) The
 Hue/Saturation tool gives you the option of adjusting restricted
 subranges of colors (using the buttons at the top of the dialog), but
 if you want to get natural-looking colors, in most cases you should
 avoid doing this.

 Even if an image does not seemed washed out, often you can increase
 its impact by pushing up the saturation a bit. Veterans of the film
 era sometimes call this trick Fujifying,
 after Fujichrome film, which is notorious for producing highly
 saturated prints.

 When you take pictures in low light conditions, in some cases you have
 the opposite problem: too much saturation. In this case too the
 Hue/Saturation tool is a good one to use, only by reducing the
 saturation instead of increasing it.

## Adjusting Sharpness

## Unblurring

 If the focus on the camera is not set perfectly, or the camera is
 moving when the picture is taken, the result is a blurred image. If
 there is a lot of blurring, you probably won't be able to do much
 about it with any technique, but if there is only a moderate amount,
 you should be able to improve the image.

 The most generally useful technique for sharpening a fuzzy image is
 called the Sharpen (Unsharp
 Mask).
 In spite of the rather confusing name, which derives from its
 origins as a technique used by film developers, its result is to make
 the image sharper, not unsharp.
 It is a plug-in, and you can access it via 
 Filters
 Enhance
 Sharpen (Unsharp Mask)…
 in the main menu. There are two parameters,
 Radius and Amount.
 The default values often work pretty well, so you should try them
 first. Increasing either the radius or the amount increases the
 strength of the effect. Don't get carried away, though: if you make
 the unsharp mask too strong, it will amplify noise in the image and
 also give rise to visible artifacts where there are sharp edges.

 Sometimes using Sharpen (Unsharp Mask) can cause color distortion
 where there
 are strong contrasts in an image. When this happens, you can often
 get better results by decomposing the image into separate
 Hue-Saturation-Value (HSV) layers, and running Sharpen (Unsharp Mask)
 on the Value layer only, then recomposing. This works because the
 human eye has much finer resolution for brightness than for color. See
 the sections on
 Decompose and
 Compose for more information.

 In some situations, you may be able to get useful results by
 selectively sharpening specific parts of an image using the
 Blur/Sharpen
 tool from the Toolbox, in "Sharpen" mode. This allows you to increase
 the sharpness in areas by painting over them with any paintbrush. You
 should be restrained about this, though, or the results will not look
 very natural: sharpening increases the apparent sharpness of edges in
 the image, but also amplifies noise.

## Reducing Graininess

 When you take pictures in low-light conditions or with a very fast
 exposure time, the camera does not get enough data to make good
 estimates of the true color at each pixel, and consequently the
 resulting image looks grainy. You can smooth out
 the graininess by blurring the image, but then you will also lose
 sharpness. There are a couple of approaches that may give better
 results. Probably the best, if the graininess is not too bad, is to
 use the filter called
 Selective
 Gaussian Blur, setting the blurring radius to 1 or 2 pixels.
 The other approach is to use the
 Despeckle filter. This
 has a nice preview, so you can play with the settings and try to
 find some that give good results. When graininess is really bad,
 though, it is often very difficult to fix by anything except
 heroic measures (i.e., retouching with paint tools).

## Softening

 Every so often you have the opposite problem: an image is
 too
 crisp. The solution is to blur it a bit: fortunately blurring an image
 is much easier than sharpening it. Since you probably don't want to
 blur it very much, the simplest method is to use one of the
 Blur filters, accessed via 
 FiltersBlur
 from the main menu. This
 will soften the focus of the image a little bit. If you want more
 softening, just repeat until you get the result you desire.

## Removing Unwanted Objects from an Image

 There are two kinds of objects you might want to remove from an image:
 first, artifacts caused by junk such as dust or hair on the lens;
 second, things that were really present but impair the quality of the
 image, such as a telephone wire running across the edge of a beautiful
 mountain landscape.

## Despeckling

 A good tool for removing dust and other types of lens grunge is the
 Despeckle
 filter, accessed via Filters
 EnhanceDespeckle…
 from the main menu.
 Very important: to use this filter effectively, you must begin by
 making a small selection containing the artifact and a small area
 around it. The selection must be small enough so that the artifact
 pixels are statistically distinguishable from the other pixels inside
 the selection. If you try to run despeckle on the whole image, you
 will hardly ever get anything useful. Once you have created a
 reasonable selection, activate Despeckle, and watch the preview as you
 adjust the parameters. If you are lucky, you will be able to find a
 setting that removes the junk while minimally affecting the area
 around it. The more the junk stands out from the area around it, the
 better your results are likely to be. If it isn't working for you, it
 might be worthwhile to cancel the filter, create a different
 selection, and then try again.

 If you have more than one artifact in the image, it is necessary to
 use Despeckle on each individually.

## Garbage Removal

 The most useful method for removing unwanted clutter
 from an image is the Clone

 tool, which allows you to paint over one part of an image using pixel
 data taken from another part (or even from a different image). The
 trick to using the clone tool effectively is to be able to find a
 different part of the image that can be used to
 copy over
 the unwanted part: if the area surrounding the unwanted object is very
 different from the rest of the image, you won't have much luck. For
 example, if you have a lovely beach scene, with a nasty human walking
 across the beach who you would like to teleport away, you will
 probably be able to find an empty part of the beach that looks similar
 to the part he is walking across, and use it to clone over him. It is
 quite astonishing how natural the results can look when this technique
 works well.

 Consult the
 Clone Tool Help
 for more detailed instructions. Cloning is as much an art as a
 science, and the more you practice at it, the better you will get. At
 first it may seem impossible to produce anything except ugly blotches,
 but persistence will pay off.

 Another tool looking very much as the clone tool, but smarter, is the
 healing tool which also takes
 the area around the destination into account when cloning. A typical
 usage is removal of wrinkles and other minor errors in images.

 In some cases you may be able to get good results by simply cutting
 out the offending object from the image, and then using a plug-in
 called Resynthesizer
 to fill in the void. This plug-in is not included with the main GIMP
 distribution, but it can be obtained from the author's web site
 .
 As with many things, your mileage may vary.

## Removing Red-eye

 Red-eyes

 When you take a flash picture of somebody who is looking directly
 toward the camera, the iris of the eye can bounce the light of the
 flash back toward the camera in such a way as to make the eye appear
 bright red: this effect is called red eye,
 and looks very bizarre. Many modern cameras have special flash modes
 that minimize red-eye, but they only work if you use them, and even
 then they don't always work perfectly. Interestingly, the same effect
 occurs with animals, but the eyes may show up as other colors, such as
 green.

 GIMP provides a special remove red eye filter.
 Make a selection with one of the selection tools of the red part of
 the eye and then choose the Red Eye Removal filter.
 You may have to fiddle around a bit with the threshold slider to
 get the right color.

## Saving Your Results

## Files

 What file format should you use to save the results of your work, and
 should you resize it? The answers depend on what you intend to use the
 image for.

 If you intend to open the image in GIMP again for further work,
 you should save it in GIMP's native XCF format (i. e., name it
 something.xcf), because this is the only format that guarantees
 that none of the information in the image is lost.

 If you intend to print the image on paper, you should avoid
 shrinking the image, except by cropping it. The reason is that
 printers are capable of achieving much higher resolutions than
 video monitors — 600 to 1400 dpi (dots per
 inch, the physical density) for typical printers, as
 compared to 72 to 100 pixels per inch for monitors. A
 3000×5000-pixel image looks huge on a monitor, but it
 only comes to about 5 inches by 8 inches on paper at 600 ppi.
 There is usually no good reason to expand the
 image either: you can't increase the true resolution that way, and
 it can always be scaled up at the time it is printed. As for the
 file format, it will usually be fine to use JPEG at a quality
 level of 75 to 85. In rare cases, where there are large swaths of
 nearly uniform color, you may need to set the quality level even
 higher or use a lossless format such as TIFF instead.

 If you intend to display the image on screen or project it with a
 video projector, bear in mind the highest screen resolutions for
 most commonly available systems. There is nothing to gain by
 keeping the image much larger than these resolutions. For this
 purpose, the JPEG format is almost always a good choice.

 If you want to put the image on a web page or send it by email, it
 is a good idea to make every effort to keep the file size as small
 as possible. First, scale the image down to the smallest size that
 makes it possible to see the relevant details (bear in mind that
 other people may be using different sized monitors and/or
 different monitor resolution settings). Second, export the image as
 a JPEG file. In the JPEG export dialog, check the option to
 Preview in image window,
 and then adjust the Quality slider to the lowest level that
 gives you acceptable image quality. (You will see in the image the
 effects of each change.) Make sure that the image is zoomed at 1:1
 while you do this, so you are not misled by the effects of
 zooming.

 See the File Formats
 section for more information.

## Printing Your Photos

 Printing
 Printing your photos

 You print photos from the main menu through

 File
 Print…
 .
 However it is very useful to keep in mind some elementary concepts
 to prevent some unpleasant surprises when looking at the result, or
 to fix them if they occur. You must always remember:

 that image displayed on the screen is in RGB mode and printing
 will be in CMYK mode; consequently color feature you'll get on
 printed sheet will not be exactly what you was waiting for. That
 depends on the used corresponding chart. For the curious ones some
 adding explanations can be got through a click on these useful
 Wikipedia links:

 ICC-Profile 

 CMYK 

 Gamut 

 that a screen resolution is roughly within a range from 75 up to
 100 dpi; a printer resolution is about 10x higher (or more) than a
 screen one; printed image size depends on available pixels and
 resolution; so actual printed size doesn't correspond inevitably
 to what is displayed on screen nor available sheet size.

 Consequently, before any printing, go to

 Image
 Print Size…

 and choose a convenient output size in the
 Print Size box adjusting either sizes or resolution.
 The

 symbol shows that the both values are linked. You can dissociate x
 and y resolution by clicking on that symbol, but it is risky. Only
 some printers support different X vs. Y resolutions.

 Last recommendation: think of checking your margins as well as
 centering. It would be a pity if a too large margin cuts off some
 part of your image or if an inappropriate centering damages your work
 especially if you use a special photo paper.

## EXIF Data

 Digital cameras, when you take a picture, add information to your
 image about the camera settings and the circumstances under
 which the picture was taken. This so-called metadata is included in
 most image files in a structured format called EXIF.

 GIMP stores all metadata it can handle when loading
 an image. When exporting your image, you can select which types of
 metadata you want included. Not all file formats support all types of
 metadata.
 For JPEG files, EXIF metadata will be included if enabled in the
 export dialog. Besides values that directly depend on changes you
 made to your image (e.g. dimensions) most values will be saved
 unchanged from when the image was loaded.

 You can view the contents of the EXIF, XMP and IPTC metadata, by
 using the metadata-viewer
 plug-in. You can access it via Image
 MetadataView Metadata
 from the main menu.