## Difference of Gaussians

 Filters
 Edge Detect
 Difference of Gaussians

 Difference of Gaussians

## Overview

## 
 Applying example for the Difference of Gaussians filter

Original image

 Filter Difference of Gaussians applied with radius 1 = 
 1.000 and radius 2 = 0.100.

 This filter does edge detection using the
 so-called Difference of Gaussians
 algorithm, which works by performing two different Gaussian blurs on the
 image, with a different blurring radius for each, and subtracting them
 to yield the result.

 This algorithm is very widely used in artificial vision, and is pretty
 fast because there are very efficient methods for doing Gaussian blurs.

## Activating the Filter

 This filter is found in the main menu under

 Filters
 Edge-Detect
 Difference of Gaussians…
 .

## Options

## 
 Gaussian Difference filter options

 Presets
 Input Type
 Clipping
 Blending Options
 Preview
 Merge filter
 Split view

 Radius 1
 Radius 2

 Radius 1 and Radius 2
 are the blurring radii for the two Gaussian blurs.
 Increasing Radius 1 tends to give
 thicker-appearing edges, and decreasing the
 Radius 2 tends to increase the
 threshold for recognizing something as an edge.

 If you want to produce something that looks like a sketch,
 in most cases setting Radius 2 smaller than
 Radius 1 will give better results.

 In situations where you have a light figure on the dark background,
 reversing them may actually improve the result.