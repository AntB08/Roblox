## The Python-Fu Submenu

 Python-Fu
 Sub-menu

 By default this submenu just contains the Python-Fu console.

 Python-Fu
 is a set of Python
 modules that act as a wrapper to libgimp allowing
 the writing of plug-ins for GIMP.

## Activating the Submenu

 You can access this submenu from the main menu through

 Filters
 Development
 Python-Fu
 .

## The Python-Fu Console

 The Python-Fu console is a dialog window running a Python
 shell (a Python interpreter in interactive mode). This console
 is set up to make use of the internal GIMP library
 routines of libgimp.

 You can use the Python-Fu console to interactively test Python commands.

 The console consists of a large scrollable main window for input and
 output, where you can type Python commands. When you type in a Python
 command and then press the Enter key, the command is
 executed by the Python interpreter. The command's output as well as its
 return value (and its error message, if any) will be displayed in the
 main window.

## The Python-Fu Console

## The Python-Fu Console Buttons

 Save

 This command lets you save the content of the main window, that is
 the Python-Fu console input and output (including the
 >>> prompt).

 Clear

 When you click on this button, the content of the main window will
 be removed. Note that you can't get back the removed content using
 the Save command.

 Browse

 procedure browser pops
 up, with an additional button at the bottom of the window:

 The additional button of the Procedure Browser

 -->

 When clicked, the
 procedure browser pops
 up, with an additional button Apply.

 When you press this Apply button in the
 procedure browser, a call to the selected procedure will be pasted
 into the console window as a Python command:

Applied PDB procedure

 Now you just have to replace the parameter names (here:
 width, height, and
 type) with actual values, e.g.

 config.set_property('width', 400)
 config.set_property('height', 300)
 config.set_property('type', Gimp.ImageBaseType.RGB)

 Then press Enter to execute the command.

 You can (and should!) use the constants you find in the description
 of the procedure's parameters, for example
 RGB-IMAGE or OVERLAY-MODE. But note
 that you have to replace hyphens (-) with
 underscores (_): RGB_IMAGE,
 OVERLAY_MODE.

 Python-Fu is not limited to just calling procedures from the
 PDB
 (GIMP procedural database). To create a new
 image object like in the example above, you can also type

 image = gimp.Image(width, height, type)

 (with actual values for width,
 height, and type).

 Close

 Pressing this button closes the console.