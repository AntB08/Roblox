## SeExpr Scripts [img: ../../_images/SeExpr_editor.png] 

SeExpr scripts allow you to render dynamically generated textures. They are saved as .se files. They can be used as fill for generated layers. 

 

See also  
- 

[Introduction to SeExpr](../../tutorials/seexpr.xhtml#seexpr-tut-intro) 
- 

[SeExpr Quick Reference](../seexpr.xhtml#seexpr) 
- 

[SeExpr](../layers_and_masks/fill_layer_generators/seexpr.xhtml#seexpr-fill-layer) 
- 

[“Procedural texture generator (example and wishes)” on Krita Artists](https://krita-artists.org/t/procedural-texture-generator-example-and-wishes/7638) [https://krita-artists.org/t/procedural-texture-generator-example-and-wishes/7638] 
- 

[Inigo Quilez’s articles](https://iquilezles.org/www/index.htm) [https://iquilezles.org/www/index.htm] 
- 

[The Book of Shaders](https://thebookofshaders.com/) [https://thebookofshaders.com/]    

### Adding new scripts 

Like with [Patterns](resource_patterns.xhtml#resource-patterns), there is a similar UI with which you can manage SeExpr presets. This panel is available by opening the Fill Layer dialog, and selecting SeExpr: [img: ../../_images/SeExpr_script.png] 

At the bottom of the tab, beneath the resource-filter input field, there are the Import resource and Delete resource buttons. Select the former to add presets to the list. 

Similarly, removing presets can be done by pressing the Delete resource button. Krita will not delete the actual file then, but rather [deactivate](../resource_management.xhtml#deactivating-resources) it, and thus not load it.   

### Temporary scripts 

Layers keep a copy of the textual script that was used to generate them. You can access it by going to the Options tab and copying the text. You can then paste it into a new SeExpr Fill Layer.