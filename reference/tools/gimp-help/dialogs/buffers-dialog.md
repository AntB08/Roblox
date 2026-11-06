## Buffers Dialog

 Dialogs
 Buffers

 Buffers
 Dialog

 Buffers
 Cut named

 Buffers
 Copy named

 Buffers
 Paste named

 Cut Named

 Copy Named

 Paste Named

## The Buffers dialog (as a list)

 Buffers are a kind of temporary storage for image data, created when
 you cut or copy part of a drawable (a layer, layer mask, etc.).
 The following commands are available from the Edit menu
 to save an image to a buffer:

 Cut Named…

 Edit
 Buffer
 Cut Named…

 This command cuts the selected part from the current drawable
 (usually a layer) and places it in a buffer. If there is no
 selection the whole drawable will be used. You will be asked to
 give the buffer a name. The image will be removed from the
 selection after this is done.

 Copy Named…

 Edit
 Buffer
 Copy Named…

 This command copies the selected part from the current drawable
 (usually a layer) and places it in a buffer. If there is no
 selection the whole drawable will be used. You will be asked to
 give the buffer a name.

 Copy Visible Named…

 Edit
 Buffer
 Copy Visible Named…

 This command copies the selected part from all the visible
 drawables and places it in a buffer. If there is no selection the
 whole image will be used. You will be asked to give the buffer
 a name.

 Paste Named…

 Edit
 Buffer
 Paste Named…

 This menu command opens the Buffers Dialog.
 To actually paste a buffer, choose one of the buttons from this
 dialog, or the context menu. Both of which will be explained below.

 The Buffers dialog shows you the contents of all existing
 named buffers, and allows you to operate on them in several ways. It
 also shows you, at the top, the contents of the Global Buffer (the contents
 of the clipboard). This Global Buffer is merely a display: you can't do
 anything with it.
 There is no hard limit on the number of named buffers you can create,
 except that it will consume a share of your available computer memory.

 Named buffers are not saved across sessions: they will be gone when you
 close GIMP. The only way to save their contents is to paste them into
 images.

## Activating the Dialog

 This dialog is a dockable dialog; see the
 section for help on manipulating
 it.

 You can access it:

 from the main menu:

 Edit
 Buffer
 Paste Named…
 ;

 from the main menu:

 Windows
 Dockable Dialogs
 Buffers
 ;

 from the Tab menu in any dockable dialog by clicking the
 tab menu button

 and selecting

 Add Tab
 Buffers
 .

 In the Windows menu, there is a list of
 detached windows which exists
 only if at least one dialog remains open. In this case, you can raise
 the Buffers dialog from the main menu:

 Windows
 Buffers
 .

## Using the Buffers dialog

 Clicking on a buffer in the display area makes it the active buffer,
 i.e., the one that will be used for paste commands executed from the
 Buffers context menu, or the buttons at the bottom of the dialog.
 Double-clicking on a buffer causes its contents to be pasted to the
 active image as a floating selection; this is a quick way of executing
 the Paste Buffer command.

 At the bottom of the dialog are five buttons. The operations they
 perform can also be accessed from the Buffers Menu that you get by right
 clicking on the active buffer.

## The Buffers dialog (Grid View)

 In the Tab menu for the Buffers dialog, you can choose
 between View as Grid and
 View as List.
 In Grid mode, the buffers are laid out in a rectangular array.
 In List mode, they are lined up vertically, with each row showing
 a thumbnail of the contents of the buffer, its name, and its pixel
 dimensions.

 CtrlF
 opens a search field.
 See 

 You can change the size of the buffer previews in the dialog using
 the Preview Size submenu of the dialog's Tab menu.

## Buttons at the bottom

 The button bar at the bottom offers the following functionality:

 Paste Buffer

 Paste Buffer In Place

 This command pastes the contents of the selected buffer into the
 active image, as a floating selection. The only difference
 between this and the ordinary
 Paste
 command is that it uses the selected buffer rather than the
 global clipboard buffer.

 With the Shift key pressed, it pastes the buffer
 at its original location.

 Paste Buffer Into The Selection

 Paste Buffer Into The Selection In Place

 This command pastes the contents of the selected buffer into
 the active image's selection, as a floating selection. The
 only difference between this and the ordinary
 Paste Into
 Selection command is that it uses the selected buffer
 rather than the global clipboard buffer.

 With the Shift key pressed, it pastes the buffer
 into the active selection at its original location.

 Paste Buffer as New Layer

 Paste Buffer as New Layer in Place

 This command creates a new layer in the active image out of the
 contents of the selected buffer. The only difference between
 this and the ordinary
 Paste as New
 Image command is that it uses the selected buffer rather
 than the content of the global clipboard buffer.

 With the Shift key pressed, it creates the
 layer at the original location of the buffer.

 Paste Buffer as New Image

 This command creates a new single-layer image out of the
 contents of the selected buffer. The only difference between
 this and the ordinary
 Paste as New
 Image command is that it uses the selected buffer rather
 than the content of the global clipboard buffer.

 Delete Buffer

 This command deletes the selected named buffer, no questions
 asked. You cannot delete the Global Buffer.

## Buffers Dialog Context menu

 These commands are the same as available through the buttons at the
 bottom of the dialog and are explained there.