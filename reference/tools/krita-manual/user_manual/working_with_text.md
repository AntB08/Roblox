## Working with Text 

Krita has a number of features for creating and editing text. While basic use is straightforward, there’s many advanced features that make working with text really fast. This chapter will give an overview of how the different parts work together.  

### Overview 

The main tool for text is the [Text Tool](../reference_manual/tools/text.xhtml#text-tool), which allows you to create text objects. It also allows you to edit ranges of text, that is, typing, copying and pasting text. But also setting the font, color and size on a range, and even more advanced type setting, like selecting glyph alternates and precise positioning of glyphs. 

The Text Tool is used together with the [Text Properties Docker](../reference_manual/dockers/text_properties.xhtml#text-properties-docker), which gives you full control over all text properties. It also has [Style Presets](../reference_manual/resource_management/resource_style_presets.xhtml#resource-style-presets) to make it easy to reuse certain property combinations. 

However, the Text Tool can only edit a single text at a time. To edit multiple texts, you can use the [Shape Selection Tool](../reference_manual/tools/shape_selection.xhtml#shape-selection-tool). The Text Properties Docker will edit all selected text objects when using the Shape Selection Tool. Additionally, the Shape Selection Tool can be used to set text on path, or put text into multiple shapes. 

To show how these tools are used together, lets go over some examples:   

### Creating A Decorative Header 

Say you want to add some text to an illustration, like you would do for a poster or greeting card. 

Select the [Text Tool](../reference_manual/tools/text.xhtml#text-tool) and [img: mouseleft] the canvas to create a new text. You can now type your text.  [img: Text saying "Secrets of the Rose Garden" in a plain black sans-serif font.]  

To adjust the colors and stroke, you can select a color directly from any of Krita’s color selectors. For the font and text size however, you will need to use the [Text Properties Docker](../reference_manual/dockers/text_properties.xhtml#text-properties-docker).  [img: Text saying "Secrets of the Rose Garden", the font has been switched to a cursive one, the text is made green, while "Rose Garden" was made pink.]  

In the Text Properties Docker, the Paragraph tab will change the properties over the whole text, while the Character tab will only change properties for the current selection. 

When you have changed a property in the character tab, the button on the left will be activated. Pressing it will undo the change, but it being active also tells you which properties are set on characters. Properties that are set on the characters won’t be affected by the properties set on the paragraph.  [img: ../_images/working_text_decorative_3.png]  

An underline was added the Character tab.   

For example, lets underline this bit of text. Select the text. Then go to the Character tab and to Add Property at the bottom, and type “underline”. You will see Text Decoration in the list. Select this. Now, toggle Underline.  [img: ../_images/working_text_decorative_4.png]  

Here, we went back to the Paragraph tab, and only changed the font family.   

Now when you go back to the Paragraph tab, and adjust the font, the underline is kept on our original selection.  [img: ../_images/working_text_decorative_5.png]  

Same as above. Each of these samples uses a different font. Because in the Character tab we only adjusted the underline, we can change the font family for the whole text in the Paragraph tab.   

This can be used with any of the [Character Properties](../reference_manual/dockers/text_properties.xhtml#text-character-properties), and can be used to keep consistency in a text while still being able to style each character individually.  

#### Using Glyph Alternates 

Some fonts have alternate [glyphs](#term-Glyphs) for specific characters for decorative effects. To access them, you can use the [OpenType Features](../reference_manual/dockers/text_properties.xhtml#text-property-open-type) in the text properties docker, but it is more convenient to use the [Glyph Palette](../reference_manual/tools/text.xhtml#glyph-palette). 

To open the glyph palette, go to the Text Tool options, and press Glyph Palette.  [img: The text "Secrets of the Rose Garden", with the "R" of "Rose" changed to one with a dramatic swash. The glyph palette is visible underneath, showing all the glyph alternates for "R".]  

If there’s a text active, and the font supports glyph alternates for the given glyph, it will be show in the palette. 

Double [img: mouseleft] an alternate glyph to select it.    

### Curving And Per-Character Positioning 

Sometimes you want to have more control over the position of the [glyphs](#term-Glyphs). You can do this with the [Type Setting Mode](../reference_manual/tools/text.xhtml#type-setting-mode) in the Text Tool options. First ensure that the text is preformatted by selecting Preformatted in the Text Tool options. Then, click the Type Setting Mode button to enable it.  [img: The text "Secrets of the Rose Garden", with "Rose Garden" selected.]   [img: Same as above, however, the selection has changed to a series of lines, with a handle at the start and end.]  

The selection area on canvas will now have been replaced with a series of lines. And two dots will be at the start and end of the selection area. You can [img: mouseleft] + drag the dots to move the whole selection.  [img: Same as above, but handles have been selected to drag "Rose Garden" so it slots tightly under "Secrets of the".]  

While this is powerful, sometimes you want to have the whole text follow a path without having to adjust every character individually. 

To do so, first, create a path on a vector layer.  [img: A curved path, outlined in red, with a cursor over it. The cursor shape has changed to a "T" standing on a curve.]  

Then hover over the path with the [Text Tool](../reference_manual/tools/text.xhtml#text-tool), and press [img: mouseleft].  [img: The text "Secrets of the Rose Garden", following the curled path.]  

You will now be able to adjust the text postion on the path, and with the [Shape Edit Tool](../reference_manual/tools/shape_edit.xhtml#shape-edit-tool) you can adjust the path. You will first need to go into contour mode (the top right icon) and then select and edit the path as usual. 

To hide the path, use the [Shape Selection Tool](../reference_manual/tools/shape_selection.xhtml#shape-selection-tool) to select it and set the opacity to 0%.  [img: A close up of the letter "R", now converted to a path.]  

Finally, if these two functions don’t do what you need them to do, there’s always Convert to Path in the [Shape Edit Tool](../reference_manual/tools/shape_edit.xhtml#shape-edit-tool) options. Using this will convert the text into a regular vector shape (if you have multiple colors in use, it will produce a group shape, so you will need to ungroup with the [Shape Selection Tool](../reference_manual/tools/shape_selection.xhtml#shape-selection-tool) context menu).   

### Comics 

When creating a comic, you can add text at any given moment. The examples here focus on the most common moments: At the very start, when planning a comic, or at the very end, when type setting a comic. 

Now, when creating a comic, it is important that the text is consistent and easy to read. To ensure that, you can use [Style Presets](../reference_manual/resource_management/resource_style_presets.xhtml#resource-style-presets). First, create a text. Then, with the [Text Properties Docker](../reference_manual/dockers/text_properties.xhtml#text-properties-docker), set the preferred font, and the font size. Finally, create a style preset by going to the Preset tab, and there selecting New Preset. A dialog will pop up, where you can set the name and the style sample.  [img: Window for creating a style preset. It shows a "Comic Text" style, using the font "Komika Text" at 11 points.]  

Now, you can go into the tool options for the Text Tool, and untick Current Text Properties, then select your new preset in the dropdown. New texts will now be created with that preset, making it easy to keep everything consistent. 

 

Tip 

It can be tricky to determine a readable font size, as images on screen are bigger or smaller than their printed outputs depending on the screen. This is because programs like Krita display images so that at 100% a single pixel in the image is a single pixel on the screen. But it is possible to switch to physical size too. There’s a button next to the zoom slider at the bottom that allows you to switch between pixel sizing and physical sizing. When switched to physical sizing, Krita will display the image zoomed to its physical size at 100%. 

To determine a readable font size, you then create a text with your preferred font. Then switch to physical size. If you work at twice the physical size, you will need to zoom to 50%, if not, zoom to 100%. Then, sit at an arms’ length from the monitor, and adjust the font size of the text until it is pleasant to read. 

If you don’t work for print, you can skip the physical zoom step, and instead adjust the zoom so that it is the same size on screen as the end result. Then adjust the font size as necessary.   

#### Planning A Comic 

Methods that put text onto a comic at the very start do so because the artist wants to make sure that the text has enough room, and they plan the images around the text. 

Now, you might be working off a script or a very rough sketch. The first thing you do then is create new texts. You can do this with the [Text Tool](../reference_manual/tools/text.xhtml#text-tool), by [img: mouseleft] + dragging a large rectangle to create a [Inline Wrapped](../reference_manual/tools/text.xhtml#text-inline-wrapped) area. Then type your text. This inline-wrapped length is useful here because it doesn’t cut off at any given point, so you can focus on typing text and adjusting it afterwards. 

You can use the [Shape Selection Tool](../reference_manual/tools/shape_selection.xhtml#shape-selection-tool) to select multiple text shapes and adjust them with the [Text Properties Docker](../reference_manual/dockers/text_properties.xhtml#text-properties-docker). This will only affect the Paragraph level properties.  [img: A rough layout of a comic of five panels. Panel 1: Boy sees something, and says "Huh?". Panel 2: A girl's back. Panel 3: Boy yells "Hey, don't go there!". Panel 4: Girl turns, looks confused, "What do you mean?". Panel 5: We see boy's face, past the girl's back of the head. "You don't know?", "It's super dangerous over there!".]  

With all the texts in place, this comic page is ready to be pencilled. By having the texts laid out like this, it becomes clear to see how much space there is left for the images.     

#### Type Setting A Comic 

The other method of putting text on comics is at the very end, after all colors and images are finished. This is usually referred to as “Type Setting” a comic, as it is not just about putting the text in place, but also making it look good together with the images. 

Now, all the previous examples already showed how we can make the kind of decorative text for titles and onomatopoeia. For this section, we’ll be focusing on flowing text directly into a speech bubble.  [img: Image of a witch on a broom, looking at some houses below. An empty speech bubble is pointing at her head.]  

Image (and later example text) courtesy of Pepper and Carrot, CC-BY David Revoy.   

First, create a closed shape on a vector layer.  [img: Same image of the witch. The empty speech bubble is outlined in red, and the cursor that now hovers over the balloon is showing a "T" in a shape.]  

Then hover over the center with the [Text Tool](../reference_manual/tools/text.xhtml#text-tool) and [img: mouseleft]. 

You can now type the text.  [img: Same image of the witch. Her speech bubble is now filled with "Let's halt for the night down there." There's some padding, outlined by a red dashed line, and the cursor is hovering over it, indicating the line can be adjusted.]  

If you want to add some padding, hover over the border of the shape, and [img: mouseleft] + drag inwards to add some padding. 

An alternative manner of putting text in a shape is to create a text, and a shape for it to flow in. Then, with the [Shape Selection Tool](../reference_manual/tools/shape_selection.xhtml#shape-selection-tool) select both, and [img: mouseright] for the context menu. There, select Text ‣ Flow Text in Shape. If you have multiple shapes selected, you can flow the text into multiple shapes as well. 

When you have a text in shape, you can adjust it’s size by resizing with the shape selection tool, but you can also switch into contour mode (by clicking the new button at the top right) to move the shapes individually.    

### Vertical Text 

To make a vertical text, create a text with the Text Tool. Then go to the [Text Properties Docker](../reference_manual/dockers/text_properties.xhtml#text-properties-docker), into the Paragraph tab. Go to Add Property at the bottom, and select [Writing Mode](../reference_manual/dockers/text_properties.xhtml#text-property-writing-mode). There you can switch it to Vertical, Right to Left to set the whole text vertical. 

It can be useful to create a Style Preset for this if you use it frequently. 

 

Note 

At this moment, Krita does not support mixed writing modes or text orientations.    

### Right To Left Text 

While Krita does implement a [Bidirectional](#term-Bidirectional) algorithm, you do need to explicitly set the direction of the paragraph. For a right-to-left paragraph, create a text. Then go to the [Text Properties Docker](../reference_manual/dockers/text_properties.xhtml#text-properties-docker), into the Paragraph tab. Go to Add Property at the bottom, and select [Direction](../reference_manual/dockers/text_properties.xhtml#text-property-direction). Set that to Right To Left. 

This will initialize the Bidirectional algorithm properly. It will also make sure that [Text Align](../reference_manual/dockers/text_properties.xhtml#text-property-text-align) will switch the meaning of Start and End. Finally, it will show the [Unicode Bidi](../reference_manual/dockers/text_properties.xhtml#text-property-direction) property in the Character tab, which can be used to fine-tune the behaviour of the Bidirectional algorithm.   

### Text Term Glossary 

There’s a number of technical terms that are used throughout the manual to describe certain functionality. These technical terms are so common that it is easier to provide a glossary of their meanings than to explain them every time their come up.  Characters

This refers to individual letters in a text. “Individual” is doing a lot of heavy lifting here, as not all languages have unique letters, but instead use clusters of letters that get represented by a single glyph. In any case, within the documentation we’ll be using character to refer to the text as it is typed, and glyph to refer to the pictures that make up the text.  Glyphs

This is the name of the image or vector shape that represents a character or cluster of characters. The glyph selected is determined by the font, language and any OpenType features that are enabled.  OpenType

Fonts are not just collections of glyphs for each character and cluster, but also contain a tiny program that instructs the text layout how to use the glyphs. OpenType is a standard for these programs, and Krita allows you to configure the features of the program via various OpenType feature controls.  Advance

This refers to how much space a glyph takes up in the line it’s laid out in. Sometimes this is bigger or smaller than the size of the glyph itself, and is influenced by properties like Kerning and Letter spacing.  Kerning

When you have a line of text, you put the glyphs next to one another. Sometimes this can lead to little gaps appearing between some glyph combinations. Fonts usually have a list of places where this happens and instruct the text layout to pull the glyphs back a little, so the gap closes. This is called Kerning.  Bidirectional

Some scripts are written left-to-right, while others are written right-to-left. When a text has a mix of both, it needs to sort and adjust each segment so the words in each script stay together. For this there’s the Unicode bidirectional algorithm.