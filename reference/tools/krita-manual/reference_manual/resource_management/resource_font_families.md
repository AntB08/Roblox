## Font Families 

Since Krita 5.3, Font Families are a resource inside Krita. 

Font Families don’t correspond to single font files. Instead, they can represent a collection of fonts of varying types. Krita will spend some time trying to organize all the fonts on your system into a proper hierarchy, so you can select fonts as desired while using the text properties like font-weight and font-style to indicate the weight and width you need. 

Font families are unique in their localization support. Krita will try to retrieve the correct OpenType names for a given locale, and show those in the UI. It will also try to get an appropriate sample for all the scripts the font supports and display that per-locale. 

As resources, font families can be searched and tagged, as well as disabled in the resource manager. Embedding of Font Families is not supported at this moment.  

### Font Types 

The font family picker will show whether the font is an old fashioned bitmap font, a postscript font or an [OpenType](../../user_manual/working_with_text.xhtml#term-OpenType) font (Which can be ether ttf or otf files). Furthermore, it will also show an icon to indicate whether the font is a variable font, or, for color fonts, to indicate which color technologies are available.  Bitmap Font

A variety of formats just pixel bitmaps instead of vector shapes for their [Glyphs](../../user_manual/working_with_text.xhtml#term-Glyphs). Krita supports these through **FreeType**.  PostScript Font

An older vector font format, using the PostScript vector format. These fonts are much more limited than [OpenType](../../user_manual/working_with_text.xhtml#term-OpenType) fonts.  Variable Font

[OpenType](../../user_manual/working_with_text.xhtml#term-OpenType) variable fonts are special in that unlike normal font families, simple variations like width and weights are all included into a single font. Variable fonts are able to smoothly interpolate between the different variations, with width and weight becoming an *axis* of variation. It is not limited to these either, other examples include Slant or Optical Size. Krita has full support for these fonts, and their axes can be modified in the [Font Style](../dockers/text_properties.xhtml#text-property-font-style) section of the Text Properties Docker.  Color Font

A font that doesn’t just define [Glyphs](../../user_manual/working_with_text.xhtml#term-Glyphs), but also the colors on those glyphs. 

Krita doesn’t support all color fonts at this time, with only Bitmap and Colrv0 tables supported. Fonts with only SVG and Colrv1 tables will display hex blocks when used.     

### Adding new fonts 

You can add fonts by installing new fonts on your system, or adding them to the “fonts” folder inside the Krita resource directory. The latter is useful when on a system that doesn’t allow installing fonts. 

When adding new fonts, Krita will rebuild the internal list of fonts dynamically. However, while new fonts will appear in the fonts list, updating old fonts will require a restart of Krita.