## 

 Paths

 Paths
 Using

 Image
 Paths

 Paths are curves (known as Bézier-curves). To understand their concepts
 and mechanism, look at the glossary
 Bézier-curve or Wikipedia
 .
 The Paths tool allows you to design complex shapes.
 When designing a shape, you first use the
 Paths tool in GIMP
 to create a path. After that you usually stroke or fill the path.

 In GIMP, the term Stroke path means to
 apply a specific style to the path (color, width, pattern, etc).

 A path can be used in several ways:

You can convert a closed path to a selection.

 Any path, open or closed, can be stroked;
 that is, painted on the image in a variety of ways.

 A path can be filled with a color or pattern.
 If the path is not closed, it will try to figure out the shape and then
 fill it. However, this will not work if the path is a straight line.

## Illustration of four different paths

 Four examples of GIMP paths: one closed and polygonal; one open and
 polygonal; one closed and curved; one with a mixture of straight and
 curved segments.

## Path Creation

 Start by drawing the outline for your path; the outline
 can be modified later (see the
 Paths tool).
 To start, select the Paths tool using one of the following methods:

 Use

 Tools
 Paths

 from the menu.

 Use the relevant icon

 in toolbox.

Use the B keyboard shortcut.

 When the Paths tool is selected, the mouse cursor changes into a
 crosshair with a curve by default. The actual shape depends on your
 mouse pointer mode setting.
 Make sure that the Paths Edit Mode in
 Tool Options is set to
 Design.

 Left click in the image to create the first point of the path. Move
 the mouse to a new point and left click to create another
 point linked to the previous point. Although you can create as many
 points as you desire, you only need two points to learn about Paths.

 While adding points, the mouse cursor has a little +
 next to the curve, which indicates that clicking will add a new
 point.

 When the mouse cursor is close to one of the path points, the
 + changes into a cross with arrows; like the move tool.
 You can then move the existing path point.

 To close your path, go with the mouse on top of the point you want to
 connect to, and then click that point. When you are done designing
 your path, you can press Enter. This will turn the
 path into a Selection. You can also keep adding more points, or start
 changing the curves of the path.

 To edit the curves of your path, move the mouse cursor close to a line
 segment, left-click and drag the line segment. Two events occur.

The line segment bends and curves as it is pulled.

 Each line segment has two start points and end points marked by
 little square rectangles, these are called handles.
 A direction line now projects from each start point
 for the line segment that was moved. This direction line usually has
 a different color than the lines of the path.

 The curved line segment leaves an end point in the same direction that
 the direction line leaves the start point. The length of
 this line controls how far the line segment projects along the
 direction line before curving towards the other path point.

 The handle at the end of each direction line can be
 dragged to change the direction and length of the curve. The handles
 on the other end, where they connect to the path, can be used to move
 the position of that path point.

## Appearance of a path while it is manipulated

 Appearance of a path while it is manipulated using the Paths tool.

 The path is comprised of two components with both straight and curved
 segments. Black squares are anchor points, the open circle indicates
 the selected anchor, and the two open squares are the handles associated
 with the selected anchor.

## Path Properties

 Paths, like layers and channels, are components of an image. When an
 image is saved in GIMP's native XCF file format, any
 paths it has are saved with it. The list of paths in an image can be
 viewed and operated on using the
 Paths Dialog.
 You can move a path from one image to another by copying and pasting
 using the pop-up menu in the Paths dialog, or by dragging an icon from
 the Paths dialog into the destination image window.

 GIMP paths belong to a mathematical type called
 Bezier paths. What this means in practical terms is that
 they are defined by anchors and
 handles. Anchors are points the path
 goes through. Handles define the direction of a path when
 it enters or leaves an anchor point: each anchor point has two handles
 attached to it.

 Paths can be very complex. If you create them by hand using the
 Paths tool, they probably won't
 contain more than a few dozen anchor points and usually a lot less than
 that. However, if you create them by transforming a selection into a
 path, or by transforming text into a path, the result can easily contain
 hundreds or even thousands of anchor points.

 A path may contain multiple components. A
 component is a part of a path whose anchor points are all
 connected to each other by path segments. The ability to have multiple
 components in paths allows you to convert them into selections having
 multiple disconnected parts.

 Each component of a path can be either open or
 closed: closed means that the last
 anchor point is connected to the first anchor point.
 If you transform a path into a selection, any open components are
 automatically converted into closed components by connecting the last
 anchor point to the first anchor point with a straight line.

 Path segments can be either straight or curved. A path is called
 polygonal if all of its segments are straight.
 A new path segment is always created straight; the handles for the
 anchor points are directly on top of the anchor points, yielding
 handles of zero length, which produces straight-line segments.
 Drag a handle away from an anchor point to cause a segment
 to curve.

 One nice thing about paths is that they use very few resources,
 especially in comparison with images. Representing
 a path in RAM requires storing only the coordinates of its anchors and
 handles. Therefore, it is possible to have literally hundreds of paths in
 an image without causing any significant stress to your system. Even a
 path with thousands of segments consumes minimal resources in comparison
 to a typical layer or channel.

 Paths can be created and manipulated using the
 Paths tool.

## Paths and Selections

 GIMP lets you transform the selection of an image into a path. It also
 lets you transform paths into selections. For information about the
 selection and how it works, see the
 Selection section.

 When you transform a selection into a path, the path closely follows the
 marching ants.
 Now, the selection is a two-dimensional entity, but a path is a
 one-dimensional entity, so there is no way to transform the selection
 into a path without losing information. In fact, any information about
 partially selected areas (i.e., feathering) are lost when a
 selection is turned into a path. If the path is transformed back into a
 selection, the result is an all-or-none selection, similar to what is
 obtained by executing Sharpen
 from the Select menu.

## Transforming Paths

 Each of the Transform tools
 (Rotate, Scale, Perspective, etc) can be set
 to act on a layer, selection, or path. Select the transform tool in the
 toolbox, then select

 layer,

 selection, or

 path for the
 Transform option in the tool's Tool Options
 dialog. This gives you a powerful set of
 methods for altering the shapes of paths without affecting other
 elements of the image.

 By default a Transform tool, when it is set to affect paths, acts only on
 the active path which is shown highlighted in the
 Paths Dialog. You can make a
 transformation affect more than one path by selecting additional paths.
 Selecting multiple paths is done by using the mouse and
 Shift key, for adding a range of paths, or
 Ctrl key, for adding or removing the clicked path.

## Stroking a Path

## Stroking paths

 The four paths from the top illustration, each stroked in a
 different way.

 Paths do not alter the appearance of the image pixel data unless
 they are stroked, using

 Edit
 Stroke Paths…

 from the main menu or the
 Paths Dialog right-click menu,
 or the Stroke Path button in the Tool Options dialog for
 the Paths tool.

 Choosing Stroke Path by any of these means brings up a
 dialog that allows you to control the way the stroking is done. You
 can choose from a wide variety of line styles, or you can stroke with
 any of the Paint tools, including unusual ones such as the Clone tool,
 Smudge tool, Eraser, etc.

## The Stroke Path dialog

See for more information.

 You can further increase the range of stroking effects by stroking a
 path multiple times, or by using lines or brushes of different widths.
 The possibilities for getting interesting effects in this way are almost
 unlimited.

## Paths and Text

## Text converted to a path

 Text converted to a path and then transformed using the
 Perspective tool.

 The path shown above, stroked with a fuzzy brush and then
 gradient-mapped using the Gradient Map filter with the
 Yellow Contrast gradient.

 A text item created using the Text
 tool can be transformed into a path using the
 Text to Path command
 in the context menu of the Text tool. This can be useful for several
 purposes, including:

 Stroking the path, which gives you many possibilities for fancy
 text.

 More importantly, transforming the text. Converting text into a
 path, then transforming the path, and finally either stroking the
 path or converting it to a selection and filling it, often leads to
 much higher-quality results than rendering the text as a layer and
 transforming the pixel data.

 You can also wrap text along an existing path using the
 Text along Path
 command.

## Paths and SVG files

 SVG, standing for Scalable Vector
 Graphics, is a popular file format for
 vector graphics, in which graphical elements are
 represented in a resolution-independent format, in contrast to
 raster graphics; in which graphical elements are
 represented as arrays of pixels. GIMP is mainly a raster graphics
 program, but paths are vector entities.

 Fortunately, paths are represented in SVG files in
 almost exactly the same way they are represented in GIMP. This
 compatibility makes it possible to store GIMP paths as
 SVG files without losing any information. You can
 access this capability in the
 Paths Dialog.

 It also means that GIMP can create paths from
 SVG files saved in other programs, such as
 Inkscape,
 a popular open-source vector graphics application. This is nice
 because dedicated vector editing programs have much more powerful
 path-manipulation tools than GIMP does. You can import a path from an
 SVG file using the Paths dialog.

 The SVG
 format handles many other graphical elements than just paths: among
 other things, it handles figures such as squares, rectangles, circles,
 ellipses, regular polygons, etc. GIMP cannot do anything with these
 entities, but it can load them as paths.

 Creating paths is not the only thing GIMP can do with
 SVG files. It can also open
 SVG files as GIMP images, in the usual way.