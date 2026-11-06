## Fuzzy Selection (Magic wand)

 Tools
 Fuzzy Selection

 Selection
 Fuzzy selection

 Fuzzy Selection

 Magic Wand

 Diagonal Neighbors

 The Fuzzy Select tool is designed to select areas of the
 current layer or image based on color similarity.

 When using this tool, it is very important to pick the right starting
 point. If you select the wrong spot, you might get something very
 different from what you want, or even the opposite.

 Fuzzy Select is a good tool for selecting objects with sharp edges. It is fun
 to use, so beginners often start out using it a lot. You will probably
 find, however, that the more you use it, the more frustrated you become
 with the difficulty of selecting exactly what you want, no more, no less.
 More experienced users find that the
 Path and
 Color Select
 tools are often more efficient, and use the Fuzzy Select tool less. Still, it is useful
 for selecting an area within a contour, or touching up imperfect
 selections. It often works very well for selecting a solid-colored (or nearly
 solid-colored) background area.

 Note that as the selected area expands outward from the center, it does
 not only propagate to pixels that touch each other: it is capable of
 jumping over small gaps, depending on Threshold option.
 To increase/decrease Threshold, during the use of Fuzzy Selection, after the
 first button-press, dragging the pointer downward (or to the right) or
 upward (or to the left).

## Activating the Tool

 There are different possibilities to activate the tool:

 From the main menu:

 Tools
 Selection Tools
 Fuzzy Select
 .

 By clicking the tool icon

 in the Toolbox.

 By pressing the U keyboard shortcut.

## Key modifiers

 The Fuzzy Select tool does not have any special key modifiers, only the
 ones that affect all selection tools in the same way. See
 for help with these.

## Tool handling

## 
 Using the Fuzzy Select tool: selected pixels are contiguous

 It starts selecting when you click at a spot in the image, and expands
 outwards like water flooding low-lying areas, selecting contiguous
 pixels whose colors are similar to the starting pixel. You can control
 the threshold of similarity by dragging the mouse downward or to the
 right: the farther you drag it, the larger you get the selected region.
 And you can reduce the selection by dragging upwards or to the left.

 You can move the selection outline using Alt + arrow
 keys.

## Options

## Tool Options Dialog

 Mode
 Antialiasing
 Feather edges

 Finding Similar Colors

 These options affect the way Fuzzy Select expands the selection
 out from the initial point.

 Select Transparent Areas

 This option gives Fuzzy Select the ability to select areas
 that are completely transparent. If this option is not
 checked, transparent areas will never be included in the
 selection.

 Sample Merged

 If you enable this option, sampling is not calculated only
 from the values of the active layer, but from all visible layers.

 For more information, see the
 Glossary entry.

 Diagonal Neighbors

 When activated, the tool considers diagonally neighboring
 pixels as connected when calculating the affected area. In
 other words, instead of looking at the four orthogonal
 neighbors of each pixel, it looks at all eight pixels

## Example for Diagonal Neighbors

 A pixel with 4 orthogonal neighbors

 A pixel with 4 diagonal neighbors

 A pixel with 8 neighbors

## Example for Diagonal Neighbors option applied

 Diagonal Neighbors option unchecked

 Diagonal Neighbors option checked

 Threshold

 This slider determines the range of colors that will be
 selected at the moment you click the pointer on the initial
 point, before dragging it: the higher the threshold, the
 larger the resulting selection. After the first
 button-press, dragging the pointer downward or to the right
 will increase the size of the selection; dragging upward or
 to the left will decrease it. Thus, you have the same set of
 possibilities regardless of the Threshold setting: what
 differs is the amount of dragging you have to do to get the
 result you want.

 Select by

 This option determines which component of the image
 GIMP uses to calculate the similarity in color.

 You can choose from
 Composite,
 Red,
 Green,
 Blue,
 HSV Hue,
 HSV Saturation,
 HSV Value.
 LCh Lightness,
 LCh Chroma,
 LCh Hue, and
 Alpha.

 Draw Mask

 This option can help to visualize the selection. Selected
 areas marked with
 marching ants
 may not be evident when
 selecting with Fuzzy Select. If this option is
 checked, selected areas will be filled with a magenta color
 as long as you keep pressing on the left mouse button, and
 this mask will disappear as soon as you release this button.

## Example for Draw mask option applied

 Fuzzy Select used with Draw Mask option unchecked

 Fuzzy Select used with Draw Mask option checked, left
 mouse button not released yet.