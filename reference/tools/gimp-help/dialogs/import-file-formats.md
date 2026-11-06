## Import File Formats

 Import File Formats

 When opening a non-XCF image, some file formats have additional options that
 can be set to determine how GIMP will open the image. If that is the case,
 then a new dialog will open. This section will document the dialogs for all
 file formats that have such an import options dialog.

## Import from PDF

 PDF

 .pdf

 Import PDF Image

 Formats
 PDF

## The PDF Import dialog

 If you open a PDF file in GIMP, a dialog opens where
 you can set how the PDF should be loaded.

 Open pages as

 If this is set to Images, then GIMP will open
 each of the selected pages as a separate image. If it is set to
 Layers, then GIMP will create one image with
 each of the selected pages in its own layer.

 Select range

 You can select pages by typing one or more page numbers or
 ranges, separated by commas. For example, 4-7,9
 selects pages 4, 5, 6, 7, and 9 of the document. The default is to
 select all of the pages in the document.

 Select All

 Use this button to select all pages in the document.

 Width
 Height
 Resolution

 The size of the image created is controlled by the
 Width, Height,
 and Resolution settings. Each document
 contains information about its width and height in units
 of physical length so it is meaningful to set the width or
 height of the image in pixels or its resolution in pixels
 per physical unit of length: as you set any of these three
 parameters, the other two will automatically adjust to match.

 Load in reverse order

 By default the first page is loaded first, meaning it will become
 the bottom layer. If you check this option, the first page will
 be loaded last and become the top-most layer.

 Use Anti-aliasing

 Check this box to apply
 anti-aliasing
 to text in the image.

 Fill transparent areas with white

 When checked, all transparent areas in PDF pages will be filled
 with white. When unchecked, transparent areas will stay transparent.

## Import from PostScript

 Postscript

 .ps

 .eps

 Import Postscript Image

 Formats
 PS

 Formats
 EPS

## The Postscript Import dialog

 If you open a PostScript file in GIMP, a dialog opens
 where you can set how the file should be loaded. Note: the page selection
 settings only appear when there are at least two pages in the document.

 Open pages as

 If this is set to Images, then GIMP will open
 each of the selected pages as a separate image. If it is set to
 Layers, then GIMP will create one image with
 each of the selected pages in its own layer.

 Select range

 You can select pages by typing one or more page numbers or
 ranges, separated by commas. For example, 4-7,9
 selects pages 4, 5, 6, 7, and 9 of the document. The default is to
 select all of the pages in the document.

 Select All

 Use this button to select all pages in the document.

 Width
 Height
 Resolution

 The size of the image created is controlled by the
 Width, Height,
 and Resolution settings. Each
 document contains information about its width and height in
 units of physical length so it is meaningful to set the width
 or height of the image in pixels or its resolution in pixels
 per physical unit of length: as you set any of these three
 parameters, the other two will automatically adjust to match.

 Try Bounding Box

 If this is checked, GIMP will use the bounding box information
 in the PostScript file to determine how much of the page to use:
 effectively, this is equivalent to cropping whitespace from the
 edges of the image. It is possible for a PostScript file to contain
 no bounding box information, in which case this option will be
 ignored.

 Coloring

 Select B/W to have GIMP create the image
 as a 2-color indexed image, Gray for a
 grayscale image, or Color for an RGB image
 (see 
 for a full explanation of these different image modes).
 If you select Automatic then GIMP will try
 to determine the most suitable mode from the contents of the
 file.

 Text anti-aliasing
 Graphic anti-aliasing

 You can choose to have GIMP apply
 anti-aliasing
 separately for text and for graphics in the imported image. Choices
 are None, Weak and
 Strong. It determines how much anti-aliasing
 is applied: usually you should select Strong.