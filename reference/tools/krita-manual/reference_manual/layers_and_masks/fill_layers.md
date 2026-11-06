## Fill Layers 

A Fill Layer is a special layer that Krita generates on-the-fly that can contain either a pattern or a solid color. [img: ../../_images/Fill_Layer.png] 

By default, the dialog selects the flat color fill. This fills the layer with a singular color. Newly created colored fill layers will be assigned to the currently active foreground color, unless they were made by drag-and-dropping a [palette swatch](../dockers/palette_docker.xhtml#palette-docker) onto the [layer stack](../dockers/layers.xhtml#layer-docker). 

However, there are many more options, with more complex features: 

  
- [Gradient Fill](fill_layer_generators/gradient.xhtml) 
- [Multigrid](fill_layer_generators/multigrid.xhtml) 
- [Pattern Fill](fill_layer_generators/pattern_fill.xhtml) 
- [Screentone](fill_layer_generators/screentone.xhtml) 
- [SeExpr](fill_layer_generators/seexpr.xhtml) 
- [Simplex Noise](fill_layer_generators/simplex_noise.xhtml)    

### Painting on a fill layer 

A fill-layer is a single-channel layer, meaning it only has transparency. Therefore, you can erase and paint on fill-layers to make them semi-opaque, or for when you want to have a particular color only. Being single channel, fill-layers are also a little bit less memory-consuming than regular 4-channel paint layers.