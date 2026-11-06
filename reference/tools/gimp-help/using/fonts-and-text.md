## Text

 Image
 Text

## Adding Fonts

 Text
 Fonts

 Fonts
 Add

 GIMP uses the FreeType 2 font engine to render fonts, and a system
 called Fontconfig to manage them.
 FreeType 2 supports many common font file formats.

 Any font in Fontconfig's font path is available in GIMP. In addition,
 any font which is located in GIMP's Font Folders
 is available in GIMP. Font Folders are set on the
 Fonts page in the
 Folders preferences.

 By default, there are two Font Folders: The system
 GIMP fonts folder (which you should not alter), and a
 fonts folder inside your personal GIMP directory.
 You can also add additional font folders if wanted.

## Linux

There are several ways to install a font:

 Use an application like GNOME Fonts or
 KFontView to install the font.

 Place the font file in the directory
 ~/.local/share/fonts/. This will make the font
 available to you only.

 If you have administrator rights, place the font file in the
 directory /usr/local/share/fonts/.
 This will make the font available to all users.

 In all cases, the font will become available to all programs that use
 Fontconfig.

## Microsoft Windows

There are several ways to install a font system-wide:

 Drag the font file into the Fonts directory
 C:\Windows\Fonts
 C:\\Windows\\Fonts.

 Install the font via the Settings app.
 In Windows, go to Settings, select
 Personalization, then from there go to
 Fonts.

## macOS

 Install the font via the Font Book application.

 The installed fonts will show up the next time you start GIMP. If you
 want to use it in an already running GIMP instance, press the
 Refresh

 button in the Fonts dialog.

 If for some reason you run into problems trying to install a font
 system-wide, try to install the font in the fonts
 folder of your personal GIMP directory instead (see above).

## Font Problems

 Fonts
 Problems

 In most cases, problems with fonts are caused by malformed font files
 or outdated font formats.
 If you experience crashes at start-up when GIMP scans your
 font directories, as a quick workaround you can start GIMP
 with the --no-fonts
 command line
 argument, but then you will not be able to use the text tool.