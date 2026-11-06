## *.exr 

`.exr` is the prime file format for saving and loading [floating point bit depths](../colors/bit_depth.xhtml#bit-depth), and due to the library made to load and save these images being fully open source, the main interchange format as well. 

Floating point bit-depths are used by the computer graphics industry to record scene referred values, which can be made via a camera or a computer renderer. Scene referred values means that the file can have values whiter than white, which in turn means that such a file can record lighting conditions, such as sunsets very accurately. These EXR files can then be used inside a renderer to create realistic lighting. 

Krita can load and save EXR for the purpose of paint-over (yes, Krita can paint with scene referred values) and interchange with applications like Blender, Mari, Nuke and Natron.  

### Color Management 

EXR file format does not have any internal color management capabilities, i.e. when saving the data into the file, no color space information is written into the file. Next time you load the same file into Krita, Krita will assign the default color space to the file (usually “Rec 709 Linear”). It may cause the file to change visually. 

In general, there are two ways to handle the color management for the EXR files: OCIO and profile-based.  

#### OCIO-based workflow 

You need to select OCIO configuration and share it between Krita and other tools you use (Blender, Natron and etc). When using OCIO Krita will **not** use the assigned profile and will use the OCIO configuration you selected.   

#### Profile-based workflow 

Alternatively, you can assign the necessary ICC profile to the imported image. If you import the image and you know its color space is not “Rec 709 Linear TRC”, just use Tools ‣ Scripts ‣ Assign Profile to Image plugin to assign a different profile. 

 

Note 

If you do not see Assign Profile plugin, make sure it is activated in the Python Plugin Manager: Settings ‣ Configure Krita… ‣ Python Plugin Manager. After activating the plugin, restart Krita.  

If your work is based on some non-default color space (e.g. ACES), then you can set this color space as the default for loading EXR images. Go to Settings ‣ Configure Krita… ‣ Color Management and select the required color space at Color profile for imported EXR images selector. Next time you load any EXR image, this color space will be assigned automatically. [img: screenshot of Color profile for imported EXR images selector] 

If you want to read more about color managed workflows, check [this chapter](../colors/color_managed_workflow.xhtml#color-managed-workflow).