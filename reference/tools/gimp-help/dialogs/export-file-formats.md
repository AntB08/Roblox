## Export File Formats

 Export File Formats

 When exporting an image, most file formats have additional options that
 can be set. If that is the case, a new dialog opens after you have selected
 the filename and export file format. The following pages document the
 dialogs for export file formats in alphabetical order.

 Be aware that not all formats support all kinds of images. In particular
 certain formats may not be able to show transparency (like jpeg), while
 only a few formats support exporting an animation (like webp and gif).

## Exporting Animations

 Some file formats supported by GIMP allow you to
 export an animation, most notably
 webp and
 gif, but also
 mng, however this last format
 isn't supported very well by most applications.

 There is limited support in GIMP for creating
 animations. When exporting it is assumed that each layer in your image
 represents a frame in your animation. Exporting to animations usually
 doesn't support layer groups, so it's best not to use those if you
 want to make an animation.

 You can adjust the name of a layer, by adding some parameters in
 parenthesis, to let the animation export know how that layer needs to
 be animated and for how long it should be shown before going to the
 next frame. When both these things are set a name usually looks like this:
 My layer name (delay in ms)(animation command).

 The delay sets the amount of time the frame will be visible, e.g.
 (200 ms) to set it to 200 milliseconds.

 The animation command specifies how the frame is combined with the
 previous one. You can only choose one animation command for each layer.
 The available commands are:

 replace

 The (replace) command means that this layer (frame)
 will completely replace the previous one.

 combine

 The (combine) command means that this layer (frame)
 will be combined with the previous one. Only the visible parts in
 this layer will replace that of the previous layer.
 Using (combine) can reduce the size of the animation
 and may improve playback speed for large size animations.

 You can use the
 optimize (for GIF)
 command to change your (replace) layers to
 (combine).
 This adjusts the layer to only contain what is different from the
 previous one and then sets it to (replace).
 Don't hesitate to use this, even if you plan to export to
 a different format than GIF. This command was named at a time that
 there were not many other animation options than GIF, but can be
 used for any animation format that supports combining.

 Note that you can also do the reverse and
 unoptimize the
 animation, setting each layer to (replace).

 GIMP has a limited
 animation playback ability
 that you can use to preview your animation.