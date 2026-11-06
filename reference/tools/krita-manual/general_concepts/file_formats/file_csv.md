## *.csv 

`.csv` is the abbreviation for Comma Separated Values. It is an open, plain text spreadsheet format. Since the CSV format is a plain text itself, it is possible to use a spreadsheet program or even a text editor to edit the `*.csv` file. 

Krita supports the CSV version used by TVPaint, to transfer layered animation between these two software and probably with others, like Blender. This is not an image sequence format, so use the document loading and saving functions in Krita instead of the Import animation frames and Render Animation menu items. 

The format consists of a text file with `.csv` extension, together with a folder under the same name and a `.frames` extension. The CSV file and the folder must be on the same path location. The text file contains the parameters for the scene, like the field resolution and frame rate, and also contains the exposure sheet for the layers. The folder contains [*.png](file_png.xhtml#file-png) picture files. Unlike image sequences, a key frame instance is only a single file and the exposure sheet links it to one or more frames on the timeline.  [img: ../../_images/Csv_spreadsheet.png]  

A `.csv` file as a spreadsheet in **LibreOffice Calc**.   

Krita can both export and import this format. It is recommended to use 8bit sRGB color space because that’s the only color space for **TVPaint**. Layer groups and layer masks are also not supported. 

TVPaint can only export this format by itself. In **TVPaint 11**, use the Export to… option of the File menu, and on the upcoming Export footage window, use the Clip: Layers structure tab.  [img: ../../_images/Csv_tvp_csvexport.png]  

Exporting into `.csv` in TVPaint.   

To import this format back into TVPaint there is a George language script extension. See the “Packs, Plugins, Third party” section on the TVPaint community forum for more details and also if you need support for other software. Moho/Anime Studio and Blender also have plugins to import this format. 

 

See also  
- 

[CSV import script for TVPaint](https://forum.tvpaint.com/viewtopic.php?f=26&t=9759) [https://forum.tvpaint.com/viewtopic.php?f=26&t=9759]. 
- 

[CSV import script for Moho/Anime Studio](https://forum.tvpaint.com/viewtopic.php?f=26&t=10050) [https://forum.tvpaint.com/viewtopic.php?f=26&t=10050]. 
- 

[CSV import script for Blender](https://developer.blender.org/T47462) [https://developer.blender.org/T47462].