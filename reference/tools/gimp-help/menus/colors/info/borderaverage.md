2007-04-03 KoSt: added 'no'
 2006-12-20 de adapted description by ude
 2006-11-01 Changes in the description of the action and Number of colors by j.h
 2005-12-07 replaced by by lexa
 2005-08-30 de replaced informalfigure by axel.wernicke
 2005-08-24 de added by axel.wernicke
-->

## Border Average

 Colors
 Border Average

 Border Average

## Overview

## Example for the Border Average filter

Original image

Foreground color in
 the Toolbox after applying the Border Average
 filter

 This plug-in calculates the most often used color in a specified border
 of the active layer or selection. It can gather similar colors together
 so that they become predominant. The calculated color becomes the
 foreground color in the Toolbox.
 This filter is interesting when
 you have to find a Web page color background that differs as little as
 possible from your image border. The action of this filter is not
 registered in Undo History and can't be undone with
 CtrlZ:
 it doesn't modify the image.

 This command only works on RGB images. If the image is Grayscale or
 Indexed, the menu entry is disabled.

## Activating the Command

 You can access this command from the main menu through

 Colors
 Info
 Border Average…
 .

## Options

## Options of the Border Average filter

 Border Size

 The border Thickness in pixels.

 Number of Colors

 The Bucket Size lets you control the number
 of colors considered as similar and counted with the same
 bucket. A low bucket size value (i.e. a high bucket
 number) gives you better precision in the calculation of the
 average color. Note that better precision does not necessarily
 mean better results (see example below).

## 
 Examples illustrating the Border Average filter

## Original image

 Original image: colors are pure Red (255;0;0), pure Blue
 (0;0;255), and different but similar kinds of Green
 (0;255;0 , 63;240;63 , 48;224;47 , 0;192;38).

## Number of Colors is set to 8:

 The resulting color is a Red (254,2,2).

 The bucket size is low. So the bucket number is high. All color shades
 can be stored in different buckets. Here, the bucket containing red is
 the most filled. The resulting color is a nearly pure
 Red (254,2,2) and becomes the foreground color in the Toolbox.

## Number of Colors is set to 64:

 The resulting color is Green (32,224,32).

 Here the bucket size is high, the number of buckets low. Similar colors
 (here green) are stored in a same bucket. This green
 bucket is now the most filled.
 All colors in this bucket have the same values for the two most
 significant bits: (00******;11******;00******). The remaining 6 bits
 may have any values from 0 to 63 for the respective channel. So
 in this bucket, color red channels range from 0 to 63, green channels
 from 192 to 255, blue channels from 0 to 63. The resulting color is
 Green (32,224,32), which, for every channel, is the average between the
 limits of the channel range (63 + 0)/2, (255+192)/2 , (63+0)/2.