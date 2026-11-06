## Discard Color Profile

 Image
 Color Management
 Discard Color Profile

 Color Management
 Discard Color Profile

 Discard Color Profile

 Discard Color Profile discards the image's
 currently assigned ICC profile, and instead assigns GIMP's
 built-in sRGB profile.

Assigning a new profile to an image doesn't change the image's
 actual channel values. Assigning a new ICC profile only changes the meaning
 of the channel values, which means the image appearance will change (unless
 the original and new profile are functionally equivalent).

## Activating the Command

 You can access this command from the main menu through

 Image
 Color Management
 Discard Color Profile…
 .

## Usage Notes for the Command

 If you discard the image's color profile:

 The image's appearance will change
 (unless the image is already in an ICC profile color space that has the
 same colorants and channel encoding as the newly-assigned GIMP sRGB
 color space).

 The image's channel values are not
 changed by discarding the currently assigned profile and instead assigning
 GIMP's built-in sRGB profile.

 Discarding the image's currently assigned profile is useful if
 you wish to export an image to disk without an embedded ICC profile.

 Discard Color Profile can only be used
 if the ICC color profile assigned to the image is not a GIMP built-in
 sRGB profile. GIMP's built-in sRGB profiles are not embedded in images
 that are exported to disk.