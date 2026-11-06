## Use sRGB Profile

 Image
 Color Management
 Use sRGB Profile

 Color Management
 Use sRGB Profile

 Use sRGB Profile

 When checked, Use sRGB Profile
 assigns a GIMP built-in sRGB color space to your image.

 Also, if you've selected to display the image's assigned ICC color profile
 in the window title (which is the default) or status bar (see
 Image Title & Statusbar
 Format preferences), checking Use sRGB
 Profile will show GIMP built-in sRGB in
 the title or status bar in place of the image's assigned color profile.

For images without color profile, or that have a sRGB profile
 Use sRGB Profile is disabled and checked by
 default. For images that have a different color profile this option will be
 enabled and unchecked. It's best to leave it that way unless you know what
 you are doing.

## Activating the Command

 You can access this command from the main menu through

 Image
 Color Management
 Use sRGB Profile
 .

## Usage Notes for the Command

 The best possible advice is to never check
 Use sRGB Profile when you are using
 a different color profile.

 The same channel encoding as the channel encoding that
 GIMP happens to be using at the time you uncheck Enable Color Management.

 The same chromaticities as the chromaticities of the
 built-in GIMP sRGB profiles.

 In the above case unchecking Enable Color Management is the
 functional equivalent of assigning the built-in sRGB profile to your image,
 except that simply assigning the built-in sRGB profile to your image
 doesn't produce a misleading status or title bar message that the image is
 "not color managed".

 -->

## 
 What does GIMP do when
 Use sRGB Profile is checked?

 When you check the option to
 Use sRGB Profile, GIMP does two things:

 Whatever ICC profile is currently assigned to the image, is stored
 (pending subsequent editing, Encoding, and Color Management
 actions), but isn't used. And then a built-in GIMP sRGB profile is
 assigned in place of the previously assigned ICC profile:

If the image is in Non-linear encoding,
 the ICC profile "GIMP built-in sRGB" is assigned.

 If the image is in Linear light encoding, the ICC
 profile "GIMP built-in Linear sRGB" is assigned.

 You can confirm that one of GIMP's built-in sRGB color spaces has
 been assigned by selecting Image
 Image Properties and checking
 the Color Profile.

## 
 When Use sRGB Profile is checked, what happens
 to the image and the image appearance?

 Assigning a new profile to an image doesn't change the image's actual
 channel values. Assigning a new ICC profile only changes the meaning
 of these values, which means the image appearance will change
 (unless the original and new profile are functionally equivalent).

 When Use sRGB Profile is checked, one of GIMP's
 built-in sRGB profiles is assigned to the image. Assigning a new ICC
 profile to an image doesn't change the image's channel values, but it does
 more or less drastically change the image's appearance:

 If the image was already in one of GIMP's built-in color spaces (or if
 the assigned ICC profile is a profile that is functionally equivalent
 to the assigned GIMP built-in sRGB profile) then the image's
 appearance will not change.

 If the image was not already in one of GIMP's built-in color spaces
 (and is not in a color space that is functionally equivalent to the
 assigned GIMP built-in sRGB profile), the image's appearance will
 change more or less drastically depending on three things:

 What GIMP channel
 encoding — Linear light or Non-linear — the
 image was in before the Use sRGB
 Profile box was checked.

 How far the image's originally assigned ICC profile's channel
 encoding ("TRC") is from the GIMP channel encoding.

 How far the image's originally assigned ICC profile's
 Red, Green, and Blue chromaticities are from GIMP's built-in sRGB
 chromaticities.

## 
 A screenshot showing an example of incorrect image appearance after
 checking Use sRGB Profile

 The image is color managed: An ICC profile is assigned to the image, and
 that profile is being used to send the image colors to the screen. After
 checking Use sRGB Profile, one of GIMP's
 built-in sRGB profiles has been incorrectly assigned to the image, so the
 colors look wrong.

 In the screenshot below, the channel encoding of the original profile
 matches the GIMP channel encoding (both are linear), but the
 LargeRGB-elle-V4-g10.icc profile chromaticities don't match
 the GIMP built-in sRGB chromaticities. So after checking
 Use sRGB Profile, the tonality is correct but
 the colors are wrong. The image is still color managed, but it's color
 managed using the wrong ICC profile:

## A screenshot illustrating the effect of checking use sRGB.

 Image using LargeRGB-elle-V4-g10.icc profile.

 Same image after checking Use sRGB Profile.

 If your image's originally assigned ICC profile doesn't have the same
 channel encoding and chromaticities as the GIMP built-in sRGB profile,
 and you check and then immediately change your mind and uncheck
 Use sRGB Profile, the originally assigned
 ICC profile will be reassigned to your image and your image channel
 values will be unchanged.

 Otherwise, whether or not you can recover the originally assigned ICC
 profile and correct colors for your image depends on what else you've
 done between the checking and unchecking of
 Use sRGB Profile.

 Again, the best possible advice is to
 never check Use sRGB
 Profile.

In screenshot 3 above, the sRGB-elle-V4-srgbtrc.icc chromaticities
 match the chromaticities of the GIMP built-in linear sRGB profile, but the
 sRGB-elle-V4-srgbtrc.icc profile channel encoding doesn't match the current
 GIMP linear channel encoding. So after unchecking Enable Color
 Management, the colors are correct but the tonality is wrong.

In screenshot 4 below, both the channel encoding and chromaticities
 are mismatched:

In Screenshot 4 above, the channel encoding of the original
 LargeRGB-elle-V4-g10.icc profile is linear, but GIMP is using the
 Non-linear encoding. Also the LargeRGB-elle-V4-g10.icc
 chromaticities don't match the GIMP built-in sRGB chromaticities.
 So after unchecking Enable Color Management, the tonality is
 wrong (it's too dark) and the colors are wrong.
-->