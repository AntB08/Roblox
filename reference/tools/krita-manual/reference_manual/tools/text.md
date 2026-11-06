## Text Tool 

[img: tooltext] 

This tool allows you to add text to your artwork. It is used in conjunction with the [Text Properties Docker](../dockers/text_properties.xhtml#text-properties-docker). Some text operations can also be handled by the [Shape Selection Tool](shape_selection.xhtml#shape-selection-tool). See [Working with Text](../../user_manual/working_with_text.xhtml#working-with-text) for an overview of all text features. 

To create a text, click on the canvas with [img: mouseleft] and a text with “Placeholder Text” will appear, ready for editing.  

### Editing Text 

If you have just created a text, a blinking cursor will be visible on the text. You will now be able to move it around with the keyboard arrow keys, type and remove text with back space and delete keys, as well as use any system input methods for complex text input. Selecting text can be done by holding shift while navigating with the arrow keys to the end point of the selection. You can also use [img: mouseleft] + drag to select text, double-click + [img: mouseleft] to select a word and triple-click + [img: mouseleft] to select the whole text. 

 

Note 

Because you need the keys on your keyboard to type text, many shortcuts will be disabled. If you want to use a particular shortcut while editing text, it is best to set it up to use either with Ctrl, Alt or Ctrl + Shift as modifiers, as Krita will consider others text to be input. Canvas input gestures like touch rotate, [img: mousemiddle] pan, or [img: mousescroll] will work by virtue of not having any keyboard keys associated. 

In addition Krita supports all of [Qt’s default text movement shortcuts](https://doc.qt.io/qt-5/qkeysequence.html#standard-shortcuts) [https://doc.qt.io/qt-5/qkeysequence.html#standard-shortcuts]. These correspond to the default for a given operating system, so for example, Ctrl + → will move the cursor to the end of words on Windows, while on MacOS the same action corresponds to Alt + →. Because Krita supports vertical text, we will also check against the appropriate keys for the given writing mode, meaning that in vertical, Ctrl + ↓ will move to the end of the word.  

To finish editing text, click outside the text box, or start editing a different text. To do so, hover over any other text. This can be on the same layer or on any other editable vector layer. When hovering over the text, its bounding box will be highlighted. Clicking on it will then select the layer, and enter the editing mode on that text. 

Beyond editing the contents, you can also move the text. To move a text, hover over the bounding box so the cursor will switch to a move cursor. Then [img: mouseleft] + drag will move the text. 

To change the styling of text, use the [Text Properties Docker](../dockers/text_properties.xhtml#text-properties-docker).   

### Text Types 

Krita has full SVG 2 text support, which means there’s support for various text types, which can be subdivided into roughly five categories:  

#### Preformatted 

The most basic type of text. This type does not auto wrap. However, white spaces are not collapsed, meaning that new lines can be created by pressing the Enter key.   

#### Pre-positioned 

*Pre-positioned* is an SVG 1.1 text, where each line is positioned absolutely, and the white-space rule is set to collapse any extra spaces. Older versions of Krita created such texts, and it is still useful for SVGs that will be exported and used in other SVG 1.1 renderers. 

 

Tip 

When handling text coming from old versions of Krita, use the text type conversion to switch them to either Preformatted or Inline Wrapped to make editing text easier. Pre-positioned is only useful when you intend to use the SVG representation later, such as for EPUB3 or web use.    

#### Text on Path 

To create *Text on Path*, hover over an existing shape. When hovering over the boundary, the cursor will change to a text-on-path cursor, and [img: mouseleft] will create a text on path.  [img: A curved path, outlined in red, with a cursor over it. The cursor shape has changed to a "T" standing on a curve.]  

To edit a text on path, set the blinking cursor within said text. A handle will appear to edit the start offset and the side of the path the text is laid out on. By dragging this handle, the text can be moved along the path, and by flipping it to the other side, the text will be set to use the other side of the path.  [img: The text "Secrets of the Rose Garden", following the curled path.]  

 

Note 

All text types without auto-wrap can in theory be used mixed in a single text shape. Creating such a shape requires using the SVG source editor to edit the SVG directly, but it does mean that the division between them is not as strict as this typology might make them seem. Krita will do it’s best to inform you which text type it thinks the shape is for the conversion functions in the tool options, but keep in mind that it might guess wrong.    

#### Inline Wrapped 

To create a simple wrapped text (*Inline Wrapped*), doing [img: mouseleft] + drag to create a rectangular area. When the area is larger than the currently selected font’s line height, the cursor image will start showing the cursor for inline wrapped. Releasing the mouse button will then add the default text with wrapping enabled. To avoid creating a wrapped text while dragging, press Ctrl while dragging.  [img: ../../_images/inline-wrapped-cursor.png]  

Dragging a large enough area will show the inline wrapped cursor.   

When editing a Inline Wrapped text, you can also edit the wrapping area. Two handles will appear on each side of the text, showing the limits at which the text will wrap. By doing [img: mouseleft] + drag on these handles, you can increase or decrease the wrapping area. When the text is aligned to one of the handles, moving one of the other will swap the text alignment so it stays aligned to that handle. When the alignment is set to the middle, the text will stay in between the two bars. If you want the text to stay at the same place when editing a centered text and only change the wrapping area width, hold Ctrl while dragging.  [img: ../../_images/inline-wrapped-text.png]  

Inline wrapped will show two handles at each side of the area. These can be adjusted directly on canvas.     

#### Text in Shape 

To create *Text in Shape*, hover over the an existing closed shape. When hovering over the fill will change the cursor to a text-in-shape cursor, and [img: mouseleft] will flow the text into that shape. Both text on path and text in shape will show a new icon to the top right of the shape. Clicking this will switch to the [Shape Selection Tool](shape_selection.xhtml#shape-selection-tool), where the shapes can be modified.  [img: ../../_images/text-in-shape-cursor.png]  

Hovering over a closed shape will show the text in shape cursor.   

Text can be wrapped into one or multiple shapes. When flowing in multiple shapes, each *inside* shape is first filled up with as much text as possible before the next shape in the chain is started. Then there’s also *subtract* shapes. These are subtracted from the inside shapes to create the text areas.  [img: Text wrapped into a green rectangle and an orange ellipse. A blue triangle overlaps both.]  

Example of text wrapped into multiple shapes. The green rectangle and orange ellipse are inside shapes, while the triangle is a subtract shape. The outline shows the effect text areas, while arrows between the areas show how they are chained.   

When editing text in shape, the final text area border is drawn on the screen. A chain of arrows is drawn between text areas to show the order in which the areas are evaluated. The [shape padding and margin](../dockers/text_properties.xhtml#text-property-text-area) can be modified by hovering over the text area border and [img: mouseleft] + dragging it. If the cursor was closer to a subtraction shape when starting to drag, the margin will be modified. Conversely, when the cursor is closer to an inside shape when starting the drag, the shape padding will be modified.  [img: Image of a witch on a broom, looking at some houses below. Her speech bubble says: "Let's halt for the night down there." There's some padding, outlined by a red dashed line, and the cursor is hovering over it, indicating the line can be adjusted.]  

This speech bubble has shape padding applied, by dragging the hovered border. Image courtesy of Pepper and Carrot, CC-BY David Revoy.   

Editing the order of the text areas in the chain is done in [Shape Selection Tool](shape_selection.xhtml#shape-selection-tool), as is adding and removing shapes from a text.    

### Tool Options [img: ../../_images/Krita-tool-options-text.png]  Create new texts with…

This allows choosing which properties to use when creating new texts. Text can be made with any [Style Presets](../resource_management/resource_style_presets.xhtml#resource-style-presets), or use the current properties in the text properties docker by toggling Current Text Properties.  Options Use Visual Cursor

Use the visual order for the text caret bidirectional text. When text is bidirectional, the logical order of the letters can go left or right depending on where it is in the text, with the paragraph direction determining which of ← and → is the forward key. When visual order is enabled, the caret will ignore the logical order in favour of the visual order.  Paste Rich Text by Default

Krita can read styled text like SVG and HTML from the system clipboard, and has separate actions in the shortcuts for pasting either this ‘rich’ text or to paste plain text. This toggle controls whether to also paste rich text when using the regular Ctrl + V Paste action from the edit menu.    Open Text Properties

Opens the [Text Properties Docker](../dockers/text_properties.xhtml#text-properties-docker). The text properties docker is where the majority of text styling functionality is located.  Type Setting Mode

Toggles [Type Setting Mode](#type-setting-mode).  Dialogs Edit SVG Source

Opens the [SVG Source Editor](#svg-source-editor).  Glyph Palette

Opens the [Glyph Palette](#glyph-palette).    Convert Type…

These buttons allow converting a selected text. Said conversion functions are also available as shortcut actions under “Interaction Tool” in the shortcut preferences.  Preformatted

Converts text so that it does not wrap automatically. In addition, the CSS [White Space](../dockers/text_properties.xhtml#text-property-white-space) collapse rule is applied so that any hidden white space is removed, and the rule is switched so that additional white spaces are not removed. Any absolute SVG 1.1 character transforms are changed to become new lines.  Inline Wrapped

Converts text so that it wraps around a maximum inline length (width for horizontal text, and height for vertical text). As with Preformatted, the CSS [White Space](../dockers/text_properties.xhtml#text-property-white-space) rule and character transforms are processed to create line breaks and avoid the collapse of additional white spaces.  Pre-positioned

Converts text to SVG 1.1 style text, where additional [White Space](../dockers/text_properties.xhtml#text-property-white-space) get collapsed and new lines are positioned absolutely. This is how previous versions of Krita handled text, as well as the dominant way to handle SVG text. Use this to prepare text for export when the end result should show in a SVG 1.1 compatible renderer.   

Text in shape and text on path are not among the conversion options. Instead, use Flow Text in Shape and Put Text On Path from the rightclick menu in the [Shape Selection Text Options](shape_selection.xhtml#shape-selection-tool-text).     

### Type Setting Mode 

This mode enables on-canvas text styling for a number of text properties.  [img: ../../_images/type-setting-mode.png]  

Text in Type Setting Mode, with “Setting” selected, and the cursor hovering over the Font Size metric line.   

When enabled, the selection will be replaced with a number of metric lines. When there’s no selection, these lines are drawn for the paragraph, and uses the paragraph’s font metrics, while with a selection, it will use the selected glyphs font metrics as retrieved during the text layout. 

Hovering over the lines will highlight them, and show the name of the relevant metric. [img: mouseleft] + drag on these lines will increase or decrease the size of this metric. This way, [Font Size](../dockers/text_properties.xhtml#text-property-font-size), [Line Height](../dockers/text_properties.xhtml#text-property-line-height) and [Baseline Shift](../dockers/text_properties.xhtml#text-property-baseline-shift) can be modified directly on canvas. Pressing Shift will display a different set of metrics: the [Baseline](../dockers/text_properties.xhtml#text-property-baseline). Clicking a baseline will set [Dominant Baseline](../dockers/text_properties.xhtml#text-property-dominant-baseline) and [Alignment Baseline](../dockers/text_properties.xhtml#text-property-alignment-baseline) to that baseline, allowing the alignment of text of different sizes to said baseline.  [img: ../../_images/type-setting-mode-baselines.png]  

The alternate baseline mode. Cursor is hovering over the Hanging baseline.   

When text is Preformatted or Pre-positioned, two additional controls are visible at the start and end of a selection. These allow modifying the position and rotation of each cluster. The square handle allows moving the whole selection, while the round handle scales and rotates the selection. There’s a series of actions for moving the square handle available in the shortcuts configuration for the text tool. These (for each direction) Move Text Selection Down By 1 Pixel, and will move the selected text in the given direction. There’s also Remove Character Transforms which will remove all character transforms, (relative, absolute and rotation) from the given range.  [img: ../../_images/type-setting-mode-handle-adjust.png]  

The selected word has been rotated by [img: mouseleft] + dragging the handles.   

 

Note 

For fine-tuned typographic adjustments, like manual kerning, it’s recommended to use these two handles over CSS [Letter Spacing](../dockers/text_properties.xhtml#text-property-letter-spacing). The latter is intended for spacing letters over a whole chunk of text, and implemented in subtly different ways in every implementation. 

Internally, these modify SVG 1.1 relative character transforms, which means they don’t break the shaping, and are supported in all the major browsers.    

### SVG Source Editor 

A small window to directly edit the SVG source of the text. The text layout is capable of more complex text than the text tool can edit on-canvas. If you are familiar with SVG, you will be able to edit it directly and use powerful features like nested [Baseline Shift](../dockers/text_properties.xhtml#text-property-baseline-shift), [Text Decoration](../dockers/text_properties.xhtml#text-property-text-decoration) and [Direction](../dockers/text_properties.xhtml#text-property-direction). [img: ../../_images/Text-editor-example.png] 

Editing 

>  

Press Save as you’re done with your edits to preview them on canvas.   File Save Ctrl + S

Save current edits to the text on canvas.  Close Ctrl + W

Close the editor.    Edit

Basic editing functions:  Undo Ctrl + Z

Undo the last action in the text editor.  Redo Ctrl + Shift + Z

Redo the last undone action in the text editor.  Cut Ctrl + X

Cut selected text to the clipboard.  Copy Ctrl + C

Copy selected text to the clipboard.  Paste Ctrl + V

Paste text from the clipboard.  Select all Ctrl + A

Select all text in the active editor.  Deselect Ctrl + Shift + A

Deselect any selected text.  Find Ctrl + F

Pops up a window with an input to find the given text in the active editor.  Find Next F3

Searches for the next text using the last search key.  Find Previous Shift + F3

Searches for the last text using the last search key.  Replace… Ctrl + R

Pops up a dialog with two inputs: The string you wish to find, and the string you wish to replace it with. Will always replace ALL found instances.    View Zoom Out Ctrl + -

Zoom out the text.  Zoom In Ctrl + +

Zoom in the text.    Settings

Here you can edit the colors used for code formatting.     

### Glyph Palette 

The glyph palette dialog provides a grid view of alternative characters available in a font through opentype features or unicode character variants. It is meant as a companion to the [OpenType Features](../dockers/text_properties.xhtml#text-property-open-type) in the text property docker.  

#### Glyph Alternates  [img: ../../_images/glyph_palette_alternates.png]  

Glyph alternates for the character “A” in the font “Junicode”. Not all fonts have this many alternates available.   

This shows any available alternates for the current code point. There’s two kinds of alternates:  Unicode Character Variants

These are officially defined character variants. Simple examples of these include slashed 0 as an alternative to 0, but more commonly these are used for Han ideographs. In particular, place and people names require certain glyph variants to be used to look recognisable, and character variants provide this access. Krita will only show variants that are available in the font itself.  Open Type features

These are glyph alternates that are available via a number of open type features, such as the character variants, access all alternates or stylistic alternates.     

#### Character Map 

This provides a character map for the given font. At the left there is a list of unicode blocks that can be used to filter the character map. 

At the top there’s a search bar, where typing a character will show that character or the codepoints that decompose to that character (That is, A will show ‘Á’, ‘Å’ and even ‘Ấ’). This input also accepts characters in U+HEXCODE format. 

The remaining area is dedicated to the character map itself. Clicking a character will show a pop-up with glyph alternates (if available), and double clicking will add said character at the cursor position in the active text.