## Adding New Brushes

 Brushes
 Add New

 There is a quick method to add a new brush:
 .

 To add a new brush, after either creating or downloading it, you need to
 save it in a format GIMP can use. The brush file needs to be placed in the
 GIMP's brush search path, so that GIMP is able to index and display it in
 the Brushes dialog. You can hit the Refresh
 button, which reindexes the brush directory. GIMP uses three file formats
 for brushes:

 Brushes
 File formats

 GBR

 GBR

 Formats
 GBR

 The .gbr ("gimp
 brush") format is used for ordinary and
 color brushes. You can convert many other types of images,
 including many brushes used by other programs, into GIMP
 brushes by opening them in GIMP and saving them with file
 names ending in .gbr. This brings up a
 dialog box in which you can set the default Spacing for the
 brush.

 A technical specification of the GBR file format can be found on

 developer.gimp.org.

## 
 Save a .gbr brush

 GIH

 GIH

 Formats
 GIH

 The .gih ("gimp
 image hose") format
 is used for animated brushes. These brushes are constructed
 from images containing multiple layers: each layer may
 contain multiple brush-shapes, arranged in a grid. When you
 save an image as a .gih file, a dialog
 comes up that allows you to describe the format of the brush.
 See for more
 information about the dialog.

 A technical specification of the GIH file format can be found on

 developer.gimp.org.

 VBR

 VBR

 Formats
 VBR

 The .vbr format is used for parametric
 brushes, i. e., brushes created using the Brush Editor.
 There is really no other meaningful way of obtaining files
 in this format.

 MYB

 MYB

 Formats
 MYB

 The .myb format is used for MyPaint brushes.
 Please refer to for more
 information.

 To make a brush available, place it in one of the folders in GIMP's brush
 search path. By default, the brush search path includes two folders, the
 system brushes folder, which you should not use or
 alter, and the brushes folder inside your personal
 GIMP directory. You can add new folders to the brush search path using the
 Brush Folders
 page of the Preferences dialog. Any GBR, GIH, or VBR file included in a
 folder in the brush search path will show up in the Brushes dialog the
 next time you start GIMP, or as soon as you press the
 Refresh button in the Brushes dialog.

 When you create a new parametric brush using the Brush Editor, it
 is automatically saved in your personal
 brushes folder.

 There are a number of web sites with downloadable collections of GIMP
 brushes. Rather than supplying a list of links that will soon be out of
 date, the best advice is to do a search with your favorite search engine
 for GIMP brushes.
 There are also many collections of brushes for other programs with
 painting functionality. Some can be converted easily into GIMP brushes,
 some require special conversion utilities, and some cannot be converted at
 all. Most fancy procedural brush types fall into the last category. If you
 need to know, look around on the web, and if you don't find anything, look
 for an expert to ask.