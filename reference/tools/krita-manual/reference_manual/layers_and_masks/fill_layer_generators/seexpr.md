## SeExpr 

 

Added in version 4.4.  [img: ../../../_images/SeExpr-David-Revoy.jpg] 

Fills the layer with a pattern specified through Disney Animation’s [SeExpr expression language](https://wdas.github.io/SeExpr) [https://wdas.github.io/SeExpr]. 

 

See also  
- 

[Introduction to SeExpr](../../../tutorials/seexpr.xhtml#seexpr-tut-intro) 
- 

[SeExpr Quick Reference](../../seexpr.xhtml#seexpr) 
- 

[SeExpr Scripts](../../resource_management/seexpr_scripts.xhtml#resource-seexpr-scripts) 
- 

[“Procedural texture generator (example and wishes)” on Krita Artists](https://krita-artists.org/t/procedural-texture-generator-example-and-wishes/7638) [https://krita-artists.org/t/procedural-texture-generator-example-and-wishes/7638] 
- 

[Inigo Quilez’s articles](https://iquilezles.org/www/index.htm) [https://iquilezles.org/www/index.htm] 
- 

[The Book of Shaders](https://thebookofshaders.com/) [https://thebookofshaders.com/]   

SeExpr is an embeddable, arithmetic expression language that enables you to write shader-like scripts. Through this language, Krita can add dynamically generated textures like lava (example above), force fields, wood, marble, etc. to your layers. 

As with Patterns, you can create your own and use those as well. For some examples, please check out the thread [“Procedural texture generator (example and wishes)” on Krita Artists](https://krita-artists.org/t/procedural-texture-generator-example-and-wishes/7638) [https://krita-artists.org/t/procedural-texture-generator-example-and-wishes/7638]. You can download them as a bundle through [Amyspark’s blog](https://www.amyspark.me/blog/posts/2020/07/03/third-alpha-release.html) [https://www.amyspark.me/blog/posts/2020/07/03/third-alpha-release.html].  Script

Select the desired preset out of any existing bundled presets. This tab is identical to the Pattern preset selector. [img: ../../../_images/SeExpr_script.png]  Options

This tab allows you to edit the selected preset, and apply its script to the layer. [img: ../../../_images/SeExpr_editor.png] 

There are three sections. The first bar allows you to edit and save the selected preset: [img: ../../../_images/SeExpr_editor_preset_mgmt.png] 

If your script is syntactically correct, the middle box lets you adjust its variables through widgets. [img: ../../../_images/SeExpr_editor_widgets.png] 

The lower box contains the script text, and shows the detected syntax errors, if any. [img: ../../../_images/SeExpr_editor_script_error.png] 

You can adjust how much space the latter two boxes have through their splitter.