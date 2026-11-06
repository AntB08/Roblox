## Linux Command Line 

As a native Linux program, Krita allows you to do operations on images without opening the program when using the Terminal. This option was disabled on Windows and macOS, but with 3.3 it is enabled for them! 

This is primarily used in bash or shell scripts, for example, to mass convert KRA files into PNGs.  

### Export 

This allows you to quickly convert files via the terminal: 

`krita importfilename --export --export-filename exportfilename`  importfilename

Replace this with the filename of the file you want to manipulate.     --export 

Export a file selects the export option.    --export-filename <filename> 

Export filename says that the following word is the filename it should be exported to.   exportfilename

Replace this with the name of the output file. Use a different extension to change the file format.   

Example: 

`krita file.png --export --export-filename final.jpg` 

This line takes the file `file.png` and saves it as `file.jpg`.   --export-sequence 

 

Added in version 4.2.  

Export animation to the given filename and exit. 

If a KRA file has no animation, then this command prints “This file has no animation.” error and does nothing. 

`krita --export-sequence --export-filename file.png test.kra` 

This line takes the animation in *test.kra*, and uses the value of –export-filename (*file.png*), to determine the sequence fileformat(‘png’) and the frame prefix (‘file’).    

### PDF export 

PDF export looks a bit different, using the `--export-pdf` option. 

`krita file.png --export-pdf --export-filename final.pdf` 

This option exports the file `file.png` as a PDF file. 

 

Warning 

This has been removed from 3.1 because the results were incorrect.    

### Open with Custom Screen DPI   --dpi <dpiX,dpiY>  

This legacy option does not do anything anymore.   

### Open template 

Open krita and automatically open the given image file as a template. This allows you to, for example, create a shortcut to Krita that opens a given template, so you can get to work immediately! 

`krita --template path/to/the/templatename.kra`   --template path/to/the/templatename.kra 

Open the target image file as a template. 

Supported format: all the one already supported by Krita (eg. PNG, JPG, KRA, etc…). 

`krita --template /home/username/sketchbook/sketch-template-page.kra` 

This opens the file sketch-template-page.kra as a template. 

`krita --template /home/username/sketchbook/sketch-template-page.kra /home/username/sketchbook/sketch-template-page.kra` 

This opens the file sketch-template-page.kra as a template twice, in separate documents.    

### Start up 

 

Added in version 3.3:    --nosplash 

Starts krita without showing the splash screen.    --canvasonly 

Starts krita in canvasonly mode.    --fullscreen 

Starts krita in fullscreen mode.    --workspace Workspace 

Starts krita with the given workspace. So for example… 

>  

`krita --workspace Animation` 

Starts Krita in the Animation workspace.     --file-layer <filename> 

Starts krita with `filename` added as a file-layer. Note that you must either open an existing file or create a new file using the `new-image` argument. 

Example: 

`krita file.kra --file-layer image.png` 

`krita --new-image RGBA,U8,1000,1000 --file-layer image.jpg` 

If an instance of Krita is already running and Multiple [instances](preferences/general_settings.xhtml#window-settings) are disabled, then this option can be used alone to add a file-layer to the running krita document. 

Example: `krita --file-layer image.png`