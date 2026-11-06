## Simple Linear Iterative Clustering (SLIC)

 Filters
 Artistic
 Simple Linear Iterative Clustering

 Simple Linear Iterative Clustering

## Overview

 This filter creates superpixels based on k-means clustering.

 Superpixels are small cluster of pixels that share 
 similar properties. Superpixels simplifies images with a great number of 
 pixels making them more easy to be treated in many domains (computer 
 vision, pattern recognition and machine intelligence). GIMP's aim is more 
 humble: create a posterization effect.

 k-means clustering is one of the most used algorithms 
 to create superpixels. Superpixel color is the mean of pixels color in 
 the corresponding region.

## Activating the Filter

 This filter is found in the main menu under

 Filters
 Artistic
 Simple Linear Iterative Clustering…
 .

## Options

## Simple Linear Iterative Clustering options

 Presets
 Input Type
 Clipping
 Blending Options
 Preview
 Merge filter
 Split view

 Regions size

 Increasing regions size collects more pixels, and so superpixels size 
 increases also.

## Regions size example

 Regions size = 16

 Regions size = 32

 Compactness

 Superpixels borders may be irregular. Increasing this option gives 
 superpixels more regular border.

## Compactness example

 Compactness = 20

 Compactness = 40: look at the dome.

 Iterations

 How many times filter is repeated. Increasing this value gives more 
 details.

## Regions size example

 Iterations = 1 (default)

 Iterations = 15