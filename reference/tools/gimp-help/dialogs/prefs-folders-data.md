## Data Folders

 Dialogs
 Preferences
 Data folders

 Data folders
 Preferences

## Brush Folders Preferences

 GIMP uses several types of resources – such as brushes, patterns,
 gradients, etc. – for which a basic set are supplied by GIMP when it is
 installed, and others can be created or downloaded by the user. For each
 such resource type, there is a Preference page that allows you to specify
 the search path:
 the set of directories from which items of the type in question are
 automatically loaded when GIMP starts. These pages all look very much the
 same: the page for brushes is shown above as an example.

 By default, the search path consists of two locations:

 System Folder

 The system folder includes items that are
 included with GIMP by default.
 You should not alter the content in this folder.

 Personal Folder

 The personal folder is located inside
 your personal GIMP configuration folder.
 This is where you should place items added by you.
 If you cannot save items in this folder, make sure that the personal
 folder is marked as writable.

 GIMP uses the first writable folder in this list to save
 resources. You can customize the search path by using the buttons at the
 top of the dialog to move a folder up or down in the list.

## Activating the Dialog

 The preferences dialog can be accessed from the main menu, through

 Edit
 Preferences
 .

## Options

 Select a Folder

 If you click on one of the folders in the list, it is selected for
 whatever action comes next.

 Add/Replace Folder

 If you type the name of a folder in the entry space, or navigate to
 it using the file chooser button

 on the right, and then click the

 button, this will replace the
 selected folder with the one you have specified. If nothing in the
 list is selected, the folder will be added to the list.

 The

 or

 icon to the left of the text entry area informs you whether the
 folder which you have specified exists. GIMP will not create a new
 folder for you; you need to do this yourself.

 Move Up/Down

 If you click on the

 or

 buttons, the selected
 folder will be changed to the following or preceding one in the
 list. Since the folders are read in order, using those buttons
 change the loading precedence of the items located in those folders.

 Delete Folder

 If you click on the

 button, the selected folder will be
 deleted from the list. Note that the folder itself is not affected;
 it is merely removed from the search path. Deleting the system folder
 is probably a bad idea, but nothing prevents you from doing it.