%entities;
]>

## Running GIMP

 Running GIMP

 Usually you start GIMP either by clicking
 GIMP's icon on your desktop (if available), selecting
 it from a menu, or by typing gimp on a command line.
 If you have multiple versions of GIMP installed, you may
 need to add the exact version number:
 gimp-&gimp.app.version;.

 You can, if you want, provide a list of image file names on the command
 line after the program name so that GIMP automatically
 opens those files after it starts.
 It is also possible to open files from within GIMP once
 it is running using the Open Image
 Dialog.

 Most operating systems support file associations, which associates a
 class of files (as determined by their filename extension, such as .jpg)
 with a corresponding application (such as GIMP).
 When image files are properly associated with
 GIMP, you can double click an image in your file browser
 to open it in GIMP.

 If you installed the
 Flatpak version of
 GIMP from flathub.org, you start
 GIMP either by clicking an icon, or by typing
 flatpak run org.gimp.GIMP//stable on a command line.

## Changing the Language

 Languages

 GIMP automatically detects and uses the system
 language. In the unlikely event that language detection fails, or if
 you want to use a different language, the easiest way is to change the
 language used in the Interface
 Preferences:

 Edit
 Preferences
 , then go to the Interface section;
 Language can be set at the top.

 If you prefer to change language by setting environment variables, you
 can use:

 Under Linux

 In LINUX: in console mode,
 type LANGUAGE=en gimp or
 LANG=en gimp
 replacing en with fr, de, etc. according to the language you
 want. Background: Using LANGUAGE=en
 sets an environment variable for the executed
 program gimp.

 Under Windows

 Control Panel
 System
 Advanced
 Environment

 button in System Variables area:
 Add button: Enter LANG for Name and fr,
 de, etc. for Value. Watch out! You have to click OK
 three successive times to validate your choice.

 If you change languages often, you can create a batch file to
 change the language. Open NotePad. Type the following
 commands (for French for instance):

 set lang=fr
start gimp-&gimp.app.version;.exe
 Save this file as GIMP-FR.BAT (or another
 name, but always with a
 .BAT extension). Create
 a shortcut and drag it to your desktop.

 Under Apple macOS

 From System Settings, click General in the sidebar. Then
 select Language & Region. The desired language should be the first in the
 list.

 Another GIMP Instance

 New instance

 You can use command line parameter -n to run
 multiple instances of GIMP. For example,
 gimp-&gimp.app.version; starts GIMP in the
 default system language, and
 LANGUAGE=en gimp-&gimp.app.version; -n starts
 another instance of GIMP in English. This can be
 very useful for translators.

## Command Line Arguments

 Command line Arguments

 Although command line arguments are not required when starting
 GIMP, they can be useful in certain situations.
 On a Unix system, you can use
 man gimp for a complete list.

 These arguments must be added to the command line that you use
 to start GIMP as
 gimp-&gimp.app.version; [OPTION...] [FILE|URI...],
 where OPTION... can be one or more of the arguments
 listed below, followed by one or more file names.

 -?, -h, --help

Display a list of all command line options.

 --help-all

 Show all help options, including those for GEGL
 and GTK.

 --help-gegl

Show all GEGL options.

 --help-gtk

Show GTK options.

 -v, --version

 Print the GIMP version and exit.

 --license

Show license information and exit.

 --verbose

Show detailed start-up messages.

 -n, --new-instance

Start a new GIMP instance.

 -a, --as-new

Open images as new.

 -i, --no-interface

Run without a user interface.

 -d, --no-data

 Do not load patterns, gradients, palettes, or brushes. Often
 used when running in non-interactive mode to minimize startup time.

 -f, --no-fonts

Do not load any fonts. This is useful to load
 GIMP
 faster for scripts that do not use fonts, or to find problems
 related to malformed fonts that hang GIMP.

 -s, --no-splash

Do not show the splash screen while starting.

 --no-shm

Do not use shared memory between GIMP and
 plug-ins. 

 --no-cpu-accel

Do not use special CPU acceleration
 functions. Useful for finding or disabling buggy accelerated
 hardware or functions.

 --session=name

 Use a different sessionrc file for this
 GIMP session.
 The given session name is appended to the default
 sessionrc filename.

 -g, --gimprc=filename

 Use an alternative gimprc file instead of the
 default one. The gimprc file contains a
 record of your preferences. Useful in cases where plug-in paths
 or machine specs may be different.

 --system-gimprc=filename

Use an alternate system gimprc file.

 -b, --batch=commands

 Execute the set of commands non-interactively. The set of commands
 is typically in the form of a script that can be executed by one
 of the GIMP scripting interpreters.
 When the command is -, commands
 are read from standard input.

 --batch-interpreter=proc

Specify the procedure to use to process batch commands.
 The default procedure is Script-Fu.

 --quit

Quit immediately after performing requested actions

 -c, --console-messages

 Do not display dialog boxes on errors or warnings. Print the
 messages on the console instead.

 --pdb-compat-mode=mode

PDB compatibility mode (off|on|warn).

 --stack-trace-mode=mode

Debug in case of a crash (never|query|always).

 --debug-handlers

Enable non-fatal debugging signal
 handlers. Useful for GIMP debugging.

 --g-fatal-warnings

Make all warnings fatal. Useful for debugging.

 --dump-gimprc

Output a gimprc file with default
 settings. Useful if you messed up the gimprc file.

 --show-playground

 Show a preferences page
 with experimental features.

 --show-debug-menu

 Show a Debug submenu under File with commands useful for debugging
 GIMP.

 --display=display

 Use the designated X display (does not apply to all platforms).

## Configuration Folder

 Setup

 When first run, GIMP creates a configuration folder.
 All of the configuration information is stored in this folder. If you
 remove or rename the folder, GIMP repeats the
 initial configuration process and creates a new configuration folder.

 The exact location of your configuration folder depends on your
 Operating System:

 Under Linux:

 $XDG_CONFIG_HOME

 Usually: $HOME/.config/GIMP/&gimp.app.version;/

 Under Microsoft Windows using

 environment variables:

 %APPDATA%\GIMP\&gimp.app.version;\

 Usually: %USERPROFILE%\AppData\Roaming\GIMP\&gimp.app.version;\

 Under Apple macOS:

 NSApplicationSupportDirectory

 Usually: ~/Library/Application Support/GIMP/&gimp.app.version;/

## Tips and Tricks

 Just a couple of suggestions before you start:

 GIMP can provide tips you can read at any
 time using the menu command

 Help
 Tip of the Day
 .
 The tips provide information that is considered useful, but not
 easy to learn by experimenting; so they are worth reading. Please
 consider reading the tips when you have the time.

 If at some point you are trying to do something, and
 GIMP seems to have suddenly stopped functioning,
 the Getting Unstuck
 section may be able to help you out.

 Don't forget to check out the
 Preferences Dialog.
 GIMP is very customizable. There are a lot of
 settings that you can adjust to your personal preferences.