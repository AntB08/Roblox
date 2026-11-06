## Vector Layers  

### What is a Vector Layer? 

A Vector Layer, also known as a Shape Layer, is a type of layers that contains only vector graphics elements. 

The vector layer appear in **Krita**’s [Layers docker](../dockers/layers.xhtml#layer-docker) with the following icon [img: icon_vectorlayer] right to the layer thumbnail. [img: ../../_images/Vectorlayer.png] 

 

About Vector Graphics & Raster Images 

**Krita** is primarily a [Raster Graphics](https://en.wikipedia.org/wiki/Raster_graphics) [https://en.wikipedia.org/wiki/Raster_graphics] editing tool, which means that most of the editing changes the values of the pixels on the raster that makes up the image. 

A [Vector Graphics](https://en.wikipedia.org/wiki/Vector_graphics) [https://en.wikipedia.org/wiki/Vector_graphics] editing tool will use mathematics to describe shapes. Shapes can be edited at any time (modified, deleted). Because it uses formulas, vector graphics can be resized to any size without any ‘pixel’ or ‘blur’ effect. 

Vector Graphics are useful to generate logo and banners. They’re also useful to manipulate and render texts (a vector graphic text can be edited where a rasterized text can’t).    

### Creating a Vector Layer 

In [Layers docker](../dockers/layers.xhtml#layer-docker), click on dropdown arrow right to the *Add layer* [img: icon_add] button; this will popup a sub-menu with the Add Vector Layer entry. 

Default shortcut to create a new vector layer is Shift + Ins.   

### Creating Shapes 

When active layer is a vector layer, the following tools can be used to create vector shapes.  Specialized vector shapes

Krita provides differents specialized vector shapes tools:  
- 

[img: toolcalligraphy] [Calligraphy Tool](../tools/calligraphy.xhtml#calligraphy-tool) 
- 

[img: toolellipse] [Ellipse Tool](../tools/ellipse.xhtml#ellipse-tool) (also allow to create pie shapes) 
- 

[img: toolrectangle] [Rectangle Tool](../tools/rectangle.xhtml#rectangle-tool) (also allow to create rounded rectangle shapes)   Paths shapes

Krita provides differents paths shapes tools:  
- 

[img: toolbeziercurve] [Bezier Curve Tool](../tools/path.xhtml#bezier-curve-tool) 
- 

[img: toolfreehandpath] [Freehand Path Tool](../tools/freehand_path.xhtml#freehand-path-tool) 
- 

[img: toolline] [Straight Line Tool](../tools/line.xhtml#line-tool) 
- 

[img: toolpolygon] [Polygon Tool](../tools/polygon.xhtml#polygon-tool) 
- 

[img: toolpolyline] [Polyline Tool](../tools/polyline.xhtml#polyline-tool)   Text shapes 
- 

[img: tooltext] [Text Tool](../tools/text.xhtml#text-tool)   Import of SVG document

In addition, you can import a [Scalable Vector Graphic](https://en.wikipedia.org/wiki/SVG) [https://en.wikipedia.org/wiki/SVG] (SVG):  
- 

Paste a SVG content copied from another software like [Inkscape](https://inkscape.org/) [https://inkscape.org/] for example 
- 

Open a SVG file in a new document, edit Vector Layer content, copy/paste it or copy/paste shapes from it      

### Arranging Shapes 

A vector layer has its own hierarchy of shapes, also named *z-Order*. 

When a Vector Layer is rendered, shapes are drawn from the bottom to the top:   
|  [img: ../../_images/arrange00.png]  

*z-Order* Visualization of shapes    |   [img: ../../_images/arrange01.png]  

Rendered image from shapes    |     

The *z-Order* of shapes can be modified in 2 way:  
- 

From [Docker Arrange](../dockers/arrange.xhtml#arrange-docker) 
- 

From context menu, accessible with [img: mouseright]  

Both provides the same functions:  
- 

[img: icon_arrange_front] Bring to Front: move *z-Order* position to the top 
- 

[img: icon_arrange_raise] Raise: move *z-Order* position on step up 
- 

[img: icon_arrange_lower] Lower: move *z-Order* position on step down 
- 

[img: icon_arrange_back] Send to Back: move *z-Order* position to the bottom    
|  [img: ../../_images/arrange02.png]  

Red square has been “Bring to front”    |       

### Selecting Shapes 

To manipulate shapes, you need to select them with the [Shape Selection Tool](../tools/shape_selection.xhtml#shape-selection-tool) [img: toolshapeselection]. 

The [Shape Selection Tool](../tools/shape_selection.xhtml#shape-selection-tool) also provides access to options to manage shape geometry, stroke and fill properties.   

### Editing Shapes Outline 

Outline for a shape can be edited with the [Shape Edit Tool](../tools/shape_edit.xhtml#shape-edit-tool) [img: toolshapeedit].   

### Rendering Vector Layer content 

By default, vector layer content are rendered using an anti-aliasing algorithm. [img: ../../_images/antialiasing.png]  
- 

 

In the [Layers docker](../dockers/layers.xhtml#layer-docker) the vector layer icon [img: selectpixel] indicates the anti-aliasing is disabled 

On blue vector shapes, you can see aliased pixels in magnified view   
- 

 

In the [Layers docker](../dockers/layers.xhtml#layer-docker) the vector layer icon [img: selectshape] indicate the anti-aliasing is enabled 

On pink vector shapes, you can see anti-aliased pixels in magnified view