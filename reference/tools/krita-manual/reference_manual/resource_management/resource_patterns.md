## Patterns [img: ../../_images/Krita_Patterns.png] 

Patterns are small raster files that tile. They can be used as following:  
- 

As fill for a vector shape. 
- 

As fill-tool color. 
- 

As height-map for a brush using the ‘texture’ functionality. 
- 

As fill for a generated layer.   

### Adding new patterns 

You can add new patterns via the pattern docker, or the pattern-quick-access menu in the toolbar. At the bottom of the docker, beneath the resource-filter input field, there are the Import resource and Delete resource buttons. Select the former to add png or JPG files to the pattern list. 

Similarly, removing patterns can be done by pressing the Delete resource button. Krita will not delete the actual file then, but rather [deactivate](../resource_management.xhtml#deactivating-resources) it, and thus not load it.   

### Temporary patterns and generating patterns from the canvas 

You can use the pattern drop-down to generate patterns from the canvas but also to make temporary ones. 

First, draw a pattern and open the pattern drop-down. [img: ../../_images/Generating_custom_patterns1.png] 

Then go into custom and first press Update to show the pattern in the docker. Check if it’s right. Here, you can also choose whether you use this layer only, or the whole image. Since 3.0.2, Krita will take into account the active selection as well when getting the information of the two. [img: ../../_images/Generating_custom_patterns2.png] 

Then, click either Use as Pattern to use it as a temporary pattern, or Add to predefined patterns to save it into your pattern resources! 

You can then start using it in Krita by for example making a canvas and doing Edit –> Fill with Pattern. [img: ../../_images/Generating_custom_patterns3.png]   

### [Patterns Docker](../dockers/pattern_docker.xhtml#pattern-docker) 

You can tag patterns here, and filter them with the resource filter.