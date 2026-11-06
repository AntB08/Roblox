%entities;
]>

## How to Contribute

 GIMP
 How to contribute

 Welcome to the GIMP-Help team!

 This tutorial is intended for writing documentation. If you want to
 translate the documentation or the user interface,
 please go to "https://l10n.gnome.org/teams/xx" where "xx"
 is your language code: ISO 639-1 language codes can be found at
 .

## Prerequisites

## Join Discourse

You can join Gnome's
 Discourse server and subscribe to the
 gimp and
 documentation
 tags. Please, feel free to ask questions. If you do, remember to set
 the relevant tags, or we may not see the message.

## Create a Local Working Copy of Code

 The GIMP help Manual is lodged in a central repository at
 https://gitlab.gnome.org/GNOME/gimp-help. Creating a local copy of this
 repository to work on makes sure that everyone can work on his own
 without fuzzing around into works of other contributors.

 As a newbie, you will access the git repository anonymously (without an
 account). Open a terminal and type:

 git clone https://gitlab.gnome.org/GNOME/gimp-help.git
 .

 If you have a GNOME account, the command is:

 git clone git@gitlab.gnome.org:GNOME/gimp-help.git
 .

 This will create a gimp-help folder in your current
 directory. Be patient! That's a big download: about 700 MB.

## Installing your sandbox

 After downloading your local copy, run:
 cd gimp-help then
 ./autogen.sh --without-gimp ALL_LINGUAS="en xx".

 When running ./autogen.sh, you can notice some not found packages, for
 example checking for dblatex... no. Most of them are
 related to PDF files and you have to install them before running
 ./autogen.sh again if you want to create PDF files.

## The gimp-help folder

 The GIMP User Manual is maintained in the xml files of the
 src folder. You will use these xml files to work on.

## Workflow

## Writing

 The language is English (USA).

 To edit XML files, use your preferred text editor (this guide's
 author prefers the free editor Kate). You must set the editor for:

 English-US language.

 Indent with 2 spaces (the Tab key must move
 pointer by two spaces).

 Replace tabs with spaces (for compatibility with all text
 editors and web browsers).

 80 characters per line.

 Automatic spell checking with English (USA) for default
 language.

 Source files are written in the XML language according to the DocBook
 DTD. DocBook specifications can be found at
 .

 Don't be afraid. We don't use all these items and you will learn XML
 progressively reading existing XML files. For new files, please use
 the templates you can find in the gimp-help/docs/templates folder.

 If you write a new file, you must add it in the src/gimp.xml file,
 or in the XML file that calls it (for example, the
 src/menus/edit.xml file calls undo.xml, redo.xml, fade.xml, and so
 on).

## Validating

 When you have finished writing, you should validate your work:

 For a single file, you can use the following command line:
 xmllint --noout --nonet --valid your-file.xml.
 This command displays nothing if your file is OK. When an error
 is found it will show a message indicating the kind of error and
 where in your file it was encountered.

 This command can be used for quickly checking an xml file. It
 can miss or may not find some errors. In case of external
 references to other files it also may show incorrect error
 messages, because this command only checks a single file.

 (The Kate editor has an option (a plug-in) to validate the active
 xml file.)

 When you want to check multiple files or the whole gimp-help
 repository you should run make validate-en.
 You should get a No error message.

 If not, a list of validity errors is displayed with line numbers
 referring to the en.xml log file that you can find in the /log
 folder.

 Open this en.xml file in a text editor, use the
 jump to line command of your editor (the Kate
 editor command is
 CtrlG),
 and enter the line number to jump to the concerned line in the
 en.xml file. There, you will find the error.

 If you have worked on several XML files, look above in the en.xml
 file to find (in the xml:base field of the
 id tag), in which xml file the error is.

 Fix the error. Don't forget to save the file and run
 make validate-en again.

 A common mistake is editing the en.xml log file instead of the
 XML file.

## Images

 You also have to manage screenshots. Here are some hints for
 making good screenshots:

 reduce screenshot area as much as possible cropping the window
 manager borders and disabling the help button (you can do it
 in the preference dialog),

 set the image mode to indexed 255 colors

 Image
 Mode
 Indexed

 This is not necessary for icons and if your image has only few
 colors. In these cases, indexed images are bigger than
 non-indexed.

 set print resolution to 144 ppi (not for small images like
 icons). You can do this easily with GIMP from

 Image
 Print Size…

 Export images in the PNG format.

 Don't include English text in images. Translators can't translate it
 and many users don't like that. Use XML captions instead, or provide a
 .xcf file in the

 Docs
 xcf images

 folder, indicating it by a comment in the XML file:
 <!--TO TRANSLATORS: Corresponding .xcf file is in https://gitlab.gnome.org/GNOME/gimp-help/tree/master/docs/xcf%20images -->

 Icons for GIMP are in
 /usr/share/gimp/&gimp.api.version;/icons/.
 GTK icons are in
 /usr/share/icons/.

 To include an icon in the text:

 <guiicon> <inlinemediaobject> <imageobject>
 <imagedata fileref="path-to-icon"/> </imageobject>
 </inlinemediaobject> </guiicon>

 Three commands to manage your images:

 make check-image-resolutions-en: gives the
 references of images whose resolution is not 144 ppi.

 make check-images-en: give references of
 missing or orphaned images.

 mogrify units PixelsPerTrack -density 144x144
 *.png to set the print resolution of all PNG images.

## Create HTML Files

 Once XML files have been validated, run make
 html-en. Creating HTML files is important to have
 an idea about what users will see. You will probably notice
 some improvements to be made on your XML file.

 You can make an HTML draft (when the folder xml/en has been created
 during validation) for a single source xml file, by running, for
 instance, the command
 make preview-xml/en/path-to-file.xml. This creates
 draft.html file in the html folder.

 You can also use yelp and run yelp
 file:///your-file.xml.

## Sending your files

 When your files are ready:

 You don't have a GNOME account

 if you don't have a GNOME account, you must find a correspondent
 who accepts to "push" files for you; that will not be difficult
 if you send a message to the list. Either you send your xml
 files and the attached images in a compressed file, (in a tree
 reproducing that of the src and images folders if you send
 several files to make your correspondent's task easier), or you
 send a "patch" that you have to create.

 Before creating a patch, you have to get all your xml files
 and images in the index. Being in the gimp-help folder, do
 git status. If you have files in the
 Untracked files section, run git add -A.

 Then run git diff --full-index --binary origin >
 name-of-the-patch to create the patch.

 You have a GNOME account

All being well, you know how to manage Git. There are many
 tutorials for that on the Web.

 A common workflow is:

- make validate-en

- git status

- git stash

- git pull

- git status

- git stash apply

- Fix any conflicts

- git add -A

- git status

- git commit -m "a message"

- git push

## Annexes

 XML notes

ID's

 ID's, which identify commands and are used when pressing the F1 key
 in the GIMP interface, are in
 https://git.gnome.org/browse/gimp/tree/app/widgets/gimphelp-ids.h

XML Tags Examples

 procedure: in using/web.xml.

 table: in
 toolbox/tools-painting.xml.

 programlisting: in
 using/script-fu-tutorial.xml.

 segmentedlist: in
 dialogs/path-dialog.xml for a n columns list.

 Parents and Children

 Here is a diagram I often use.

## Working under Windows

 The documentation here was outdated. For now, please refer to
 our
 README for the gimp-help repository.