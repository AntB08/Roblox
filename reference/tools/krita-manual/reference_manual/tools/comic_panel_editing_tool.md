## Comic Panel Editing Tool 

[img: toolcomicpanelediting] 

The Comic Panel Editing Tool allows the user to create comic panels by either slicing through shapes and adding a gutter in between the resulting halves, or merging the shapes by removing the gaps.  

### Tool Options  

#### Cutting mode 

[img: toolcomicpanelediting_cutting] 

This mode allows you to cut through shapes and create gaps (gutters) of a specified width. 

Note: you need to first create a vector layer, and on a vector layer create the initial shape. For example, for a classic comic, use the [Rectangle Tool](rectangle.xhtml#rectangle-tool) on a vector layer for the rectangle encompassing all panels. 

To create a gap between shapes, press and drag, until the line crosses all the shapes you want to cut through.  Unit of width

Defines the unit of width used for the presets below.  Thick Gap, Thin Gap, Special Gap

Three presets for your three most used gap widths.  Automatic

This option allows Krita to select the most appropriate gap width preset based on the angle of the line.  Horizontal, Vertical, Diagonal, Angle

In Automatic mode, if the angle between the line and a perfectly horizontal line is smaller than the Angle, use the preset specified by Horizontal; if the angle between the line and a perfectly vertical line is smaller than the Angle, use the preset specified by Vertical; otherwise, use the preset specified by Diagonal.       

#### Merging mode 

[img: toolcomicpanelediting_merging] 

Remove the gutter between shapes. 

To remove the gap, press on one side of the gap, drag and release on the other side of the gap. Note that you can only remove one gap at a time, and the gap removing line must cross exactly two shape edges for it to work correctly.