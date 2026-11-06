## Export Histogram

 Colors
 Export Histogram

 Export Histogram

## Overview

 Exports the image histogram to a text file, so it can be used by other programs
 and loaded into spreadsheets.
 The histogram is produced for the selected image area. Fully transparent pixels are not counted.

 The resulting file is a CSV file (Comma Separated Values), which can be imported directly
 in most spreadsheet programs. The first row of the CSV file is a title row. One data row is
 generated for each "Bucket". Each pixel value can be in the range of 0 to 255, and will
 be included in one of the buckets depending on the bucket's range.

 The first column is titled "Range Start" and contains the starting value of the bucket.
 The following columns contain the values for different channels. Which channels will
 be included depends on the image type. The meaning of the values in each of the channel
 columns, depends on the Output Format option.

## Example of file exported by Export Histogram

Range start, Value, Red, Green, Blue
 0, 0.0, 0.0, 486.0, 0.0
 1, 0.0, 0.0, 300.0, 0.0
 2, 0.0, 0.0, 336.0, 0.0
 3, 0.0, 0.0, 399.0, 0.0
 4, 0.0, 0.0, 510.0, 0.0
 ....

 The example file above was generated for an RGB image, using the
 Pixel count output format, and a Bucket Size of 1.
 The row starting with the number 3
 describes the fourth bucket and will include all pixels from value 3 up to (but not
 including) value 4. The number 399.0 in that row can then be interpreted as "There
 are 399 pixels that have a Green value of 3".

## Activating the Command

 You can access this command from the main menu through

 Colors
 Info
 Export Histogram…
 .

## Options

## Export Histogram options

 Histogram File

 The file into which the histogram will be exported.

 Bucket Size

 The Bucket Size lets you control the number
 of values considered as similar and counted in the same
 bucket. A higher bucket size will produce less buckets, and thus
 less rows in the exported file. For example, a Bucket Size of 1 will produced 256
 buckets, whereas a bucket size of 16 will produce 16 buckets.

 Sample Average

 If Sample Average is activated, the histogram will be generated
 for an image obtained by merging all visible layers. Otherwise, the histogram will
 only consider the current layer.

 Output format

 If the Pixel count option is chosen, the values in the generated
 file will reflect the amount of pixels in each bucket.
 If Normalized is chosen, the values will be the amount of
 pixels in the bucket divided by the total amount of pixels.
 The Percent option is
 similar to Normalized, but the values are formatted as percents.