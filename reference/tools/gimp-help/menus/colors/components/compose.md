## Compose

 Colors
 Components
 Compose

 Compose

## Overview

## Example for the Compose command

Decomposed image (RGB decomposition)

Compose applied

 This command constructs an image from several grayscale images or
 layers, for instance from extracted RGB, HSV, etc. components. You can
 also build an image from grayscale images or layers created independently.

## Activating the Command

 You can access this command from the main menu through

 Colors
 Components
 Compose…
 .
 It is enabled if your image is grayscale.

## Options

## Compose command options

 Compose Channels

 Here you can select the color space to be used: RGB, HSV, etc.
 The available options are described in the
 Decompose
 command.

 Channel Representation

 Allows you to select which layer or image will be used for each
 channel. You may use this option, for example, to exchange color
 channels:

## 
 Channel Representation example: exchange two channels

Original image

Decomposed to layers

Composed image after using Channel Representation to
 switch red and green channels

 Mask Value: Instead of selecting a layer or
 an image to build the channel, you can give the channel a value
 from 0 to 255. But note that at least one channel must be formed
 from a layer or image.

 If you use different settings in Compose than when you used Decompose,
 for instance an image decomposed to
 RGB then re-composed to
 LAB, you will get
 interesting color effects. Test it!