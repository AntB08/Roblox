## Pre-installed Python plugins 

This page describes all plugins that are available in Krita by default (you don’t need to install them). 

 

See also 

If you want to see a selection of custom user-made Python plugins that you can additionally download and install, see [User-made Python Plugins](../resources_page.xhtml#custom-python-plugins).  

To learn how to manage your plugins, see [Managing Python plugins](../user_manual/python_scripting/install_custom_python_plugin.xhtml#install-custom-python-plugins). 

If you want to know more about an individual plugin, you can access the plugin’s manual by going to Settings ‣ Configure Krita… menu, and then choosing the `Python Plugin Manager` tab. Then you can click on a specific plugin and the manual will appear in the bottom text area.  

### Usability 

Mixer Slider Docker 

>  

Docker that allows you to choose a color from gradients between the current color and other selected colors.  

Palette Docker 

>  

Docker that allows you to control palettes more easily. You can add swatches, groups and export the palette settings, or even the palette itself as a GIMP Palette or Inkscape SVG.  

Quick Settings Docker 

>  

Docker that allows you to quickly set the opacity, flow and size from a predefined list.  

Ten Brushes 

>  

Plugin that assigns presets to one of ten configurable hotkeys. To use, go to Tools ‣ Scripts ‣ Ten Brushes, and a window will pop up with a preset chooser and ten boxes above it. Underneath the boxes is the hotkey the box is associated with. 

Customize your shortcuts by editing the configurations in Settings ‣ Configure Krita ‣ Keyboard Shortcuts, and then change the “Activate Brush Preset” actions under “Ten Brushes”.  

Workflow Buttons 

>  

Docker that allows you to create multi-action buttons. Each button can select a tool, a brush preset, a color, and launch a python script.    

### Workflow Improvements 

Comics Project Management Tools 

>  

Plugin that simplifies comics creation.  
- 

Organize and quickly access their pages. 
- 

Export to multiple formats with proper metadata. 
- 

Random suggestions for metadata to avoid spending time on finding the perfect title before starting the project.   

Batch Exporter 

>  

Plugin for Game Developers and Graphic Designers.  
- 

Batch export of assets to multiple sizes, file types and custom paths. 
- 

Renaming layers quickly with the smart rename tool. 
- 

Export all layers or only selected layers.  

By default, the plugin exports the images in an `export` folder next to the Krita document and follows the structure of your layer stack.    

### Image/Document Actions 

Assign Profile Dialog 

>  

Allows you to assign a profile to an image instead of converting it to that profile. The difference is that it allows only interpreting the colors by the new profile, but not change any of the values. It can be found in Tools ‣ Assign Profile to Image…, and will present a list of profiles for the current image’s color model.  

Color Space 

>  

Allows you to select a document and convert its colors to a new color space, like RGBA, CMYKA or L*a*b.  

Channels to Layers 

>  

Splits channels from a layer to sub-layers.  

Document Tools 

>  

Allows you to select a document and scale, crop and rotate in one action.  

Filter Manager 

>  

Quickly apply a filter on selected documents.  

High Pass 

>  

Performs a high pass filter on the active document.    

### File Actions 

Export Layers 

>  

Allows you to select a document and export its layers in an ordered and sensible manner.  

Last Documents Docker 

>  

Script that shows the recently opened documents as a thumbnail image.    

### Python Scripting 

Krita Script Starter 

>  

A script that helps set up the various files that Krita expects to see when it runs a script, namely:  
- 

`.desktop` meta data file; 
- 

the main directory for your plugin; 
- 

`__init__.py` file; 
- 

the main python file for your package; 
- 

`Manual.html` file for your documentation;   

Python Plugin Importer 

>  

Imports Python plugins from zip files. See [Managing Python plugins](../user_manual/python_scripting/install_custom_python_plugin.xhtml#install-custom-python-plugins).  

Scripter 

>  

A small Python scripting console, allows to write code in an editor and run it, with feedback related to the output of the execution. You can also debug your code using the “Debug” button.  

Ten Scripts 

>  

Similar to Ten Brushes, this plugin allows an assignment of Python scripts to ten configurable hotkeys.