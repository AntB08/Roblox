## Image Import and Export

 Using
 Preferences
 Image Import and Export

 Image Import and Export

## Image Import and Export Preferences

 This page lets you customize settings related to importing and
 exporting images.

## Activating the Dialog

 The preferences dialog can be accessed from the main menu, through

 Edit
 Preferences
 .

## Options

## Import Policies

 Import Policies

 Promote imported images to floating point precision

 When enabled, all imported images have their precision changed to
 32-bit floating point.

 Dither images when promoting to floating point

 When the previous setting is enabled, this setting allows you to
 choose whether
 dithering should
 be applied when a lower precision image is changed to 32-bit floating
 point.

 Add an alpha channel to imported images

 When enabled, an alpha channel is automatically added to any imported
 image that doesn't have one yet. This can be useful if you usually
 require an alpha channel to be present for your workflow.

 Color profile policy

 When importing an image that has a color profile attached to it,
 you can choose here what action needs to be taken. See
 File Open Behavior
 in the Color Management preferences.

 Metadata rotation policy

 When importing an image that has metadata about the rotation of the
 image attached to it, you can choose here what action needs to be
 taken.

 Ask what to do This is the default. Every
 time you open an image with rotation metadata, a dialog opens
 that asks you whether to rotate the image according to the
 metadata.

 Discard metadata without rotating When
 selecting this, rotation metadata will be ignored when opening
 an image.

 Rotate the image then discard metadata When
 selecting this, an image will always be rotated according to the
 metadata when it is opened. After that is done, the rotation
 metadata is discarded and replaced by default values for the
 rotation metadata.

## Export Policies

 Export Policies

 The following export policies define the
 default values when exporting an
 image. Most formats have image export dialogs where, among other things,
 you can further adjust the relevant setting for that specific format.
 These per format settings are remembered across restarts.

 Not all image formats support all of the below settings. They are only
 relevant for image formats that support the setting.

 It is good to be aware of the implications of including certain
 metadata. Metadata can contain sensitive personal information that you
 may want to review first before deciding to include it or not.
 Examples are GPS metadata that can show an exact location, or name and
 address of the creator of the image.

 Export the image's color profile by default

 When enabled, the default for exporting images is to include the
 color profile.

 Export the image's comment by default

 When enabled, the default for exporting images is to include the
 comment.

 Export the image's thumbnail by default

 When enabled, the default for exporting images is to include the
 thumbnail.

 Export exif metadata by default when available

 When enabled, the default for exporting images is to include
 exif metadata.

 Export XMP metadata by default when available

 When enabled, the default for exporting images is to include
 XMP metadata.

 Export IPTC metadata by default when available

 When enabled, the default for exporting images is to include
 IPTC metadata.

 Update metadata automatically

 When enabled, GIMP adds and updates metadata
 automatically. When disabled, only the minimum necessary metadata
 changes are made, without changing e.g. modification date,
 synchronizing comment and other tags, or updating the software and
 change history metadata.

 Even when disabled, you can still change metadata by using the
 Metadata Editor.
 Changes made there will be included in your exported image, unless
 you disabled exporting metadata.

## Export File Type

 Export File Type

 Default export file type

 This setting allows you to select what file format should be used
 by default when exporting an image, without explicitly choosing an
 extension of a known image file format.

 Note that this is only relevant when exporting a new image created
 in GIMP.
 When exporting an image that was previously imported,
 GIMP uses the extension of that imported image.

## Raw Image Importer

 Raw Image Importer

 Plug-in

 This setting shows a list of known plug-ins that can be used for
 opening and processing RAW image formats. Most common apps used here
 are Darktable and RawTherapee. If no plug-in is registered, GIMP
 will show a placeholder value here.