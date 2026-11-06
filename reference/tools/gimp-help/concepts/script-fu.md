## Using Script-Fu Scripts

 Script-Fu
 Introduction

## Script-Fu?

 Script-Fu scripts are similar to very powerful macros that
 you may be familiar with from other programs. Script-Fu is based on an
 interpreted language called Scheme, and works by using functions that
 interact with GIMP's internal functions.
 You can do all kinds of things with Script-Fu, but an ordinary
 GIMP user will probably use it for automating things
 that:

You want to do frequently.

Are really complicated to do, and hard to remember.

 Remember that you can do a whole lot with Script-Fu. The scripts that
 come with GIMP can be quite useful, but they can also
 serve as models for learning Script-Fu, or at least as a framework and
 source of modification when you make your own script. Read the Script-Fu
 Tutorial in the next section if you want to learn more about how to
 write your own scripts.

 We will describe some of the most useful scripts in this chapter, but we
 won't cover them all. There are simply too many scripts. Some of the
 scripts are also very simple and you will probably not need any
 documentation to be able to use them.

## Installing Script-Fu scripts

 Script-Fu
 Install

 One of the great things about Script-Fu is that you can share your
 script with all your GIMP friends. There are many
 scripts that come with GIMP by default, but
 there are even more available for download online.

 If you have downloaded a script, copy or move it to one of
 GIMP's Scripts folders. The location of these
 folders can be found in
 Preferences:

 Folders
 Scripts
 .
 You can even add a new scripts folder there if that is more
 convenient for you.

 To be able to use the new script you have to restart
 GIMP if you had it open while adding the script.
 The script will appear in one of GIMP's menus. If you can't find
 it, look for it under the Filters menu, or use
 the command search
 using /.
 If it doesn't appear at all, something was wrong with the script
 (e.g. it contains syntax errors).

## Do's and Don'ts

 A common error when you are dealing with Script-Fus is that you simply
 bring them up and press the OK button. When nothing happens, you
 probably think that the script is broken or buggy, but there is most
 likely nothing wrong with it.

 A simple way to see if the script did anything is to check
 EditUndo
 . If your script made any changes to the current image,
 it will be listed as the last undo action.

## Different Kinds Of Script-Fus

 There are two kinds of Script-Fus:

 Standalone Script-Fus

 These scripts do not require an existing image. They usually
 create an image themselves. In the past there were several
 scripts supplied with GIMP that belonged to
 this category. However, the results all looked dated compared to
 todays standards and they were not well maintained. Which is the
 reason that they are not installed anymore since
 GIMP 2.10.

 In case you would like to keep using these scripts, they are still
 available as separate downloads that you have to install yourself.
 The scripts and other resources can be downloaded from
 here.

 Image-dependent Script-Fus

 Most scripts and plug-ins are logically categorized and added to
 the menu that resembles their function. Most of the scripts
 appear in the Filters menu, but there
 are also several in the Colors menu.

 Some scripts with specific functions appear in other menus, e.g.
 the script New Brush (script-fu-paste-as-brush)
 is integrated in the Edit menu
 (
 Edit
 Paste as
 Paste as New Brush…
 ),
 that is more logical.

 Some older scripts that haven't been updated may still appear
 in a dedicated top-level Script-Fu menu.