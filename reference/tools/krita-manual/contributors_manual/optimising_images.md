## [Images for the Manual](#id5) 

This one is a little bit an extension to [Saving For The Web](../tutorials/saving-for-the-web.xhtml#saving-for-the-web). In particular it deals with making images for the manual, and how to optimise images.  

Contents  
- 

[Images for the Manual](#images-for-the-manual)  
- 

[Tools for making screenshots](#tools-for-making-screenshots)  
- 

[Windows](#windows) 
- 

[Linux](#linux) 
- 

[macOS](#macos)   
- 

[The appropriate file format for the job](#the-appropriate-file-format-for-the-job) 
- 

[Optimising Images in quality and size](#optimising-images-in-quality-and-size)  
- 

[Windows](#id1) 
- 

[Linux](#id2)  
- 

[Optimising PNG](#optimising-png) 
- 

[Optimising GIF](#optimising-gif) 
- 

[Optimising JPEG](#optimising-jpeg)   
- 

[macOS](#id3)   
- 

[Editing the metadata of a file](#editing-the-metadata-of-a-file)  
- 

[Windows and macOS](#windows-and-macos) 
- 

[Linux](#id4) 
- 

[Viewing Metadata](#viewing-metadata) 
- 

[Stripping Metadata](#stripping-metadata) 
- 

[Extracting metadata](#extracting-metadata) 
- 

[Embedding description metadata](#embedding-description-metadata) 
- 

[Embedding license metadata](#embedding-license-metadata)  
- 

[Using Properties](#using-properties) 
- 

[Using XMP](#using-xmp)          

### [Tools for making screenshots](#id6) 

Now, if you wish to make an image of the screen with all the dockers and tools, then [Saving For The Web](../tutorials/saving-for-the-web.xhtml#saving-for-the-web) won’t be very helpful: It only saves out the canvas contents, after all! 

So, instead, we’ll make a screenshot. Depending on your operating system, there are several screenshot utilities available.  

#### [Windows](#id7) 

Windows has a built-in screenshot tool. It is by default on the Print Screen key. On laptops you will sometimes need to use the Fn key.   

#### [Linux](#id8) 

Both Gnome and KDE have decent screenshot tools showing up by default when using the Print Screen key, as well do other popular desktop environments. If, for whatever reason, you have no  ImageMagick

With imagemagick, you can use the following command: 

```
import -depth 8 -dither <filename.png>

```
    

While we should minimize the amount of GIFs in the manual for a variety of accessibility reasons, you sometimes still need to make GIFs and short videos. Furthermore, GIFs are quite nice to show off features with release notes. 

For making short GIFs, you can use the following programs:  
- 

[Peek](https://github.com/phw/peek) [https://github.com/phw/peek] – This one has an AppImage and a very easy user-interface. Like many screenrecording programs it does show trouble on Wayland.    

#### [macOS](#id9) 

The Screenshot hotkey on macOS is Shift + Command + 3, according to [the official apple documentation](https://support.apple.com/en-us/HT201361) [https://support.apple.com/en-us/HT201361].    

### [The appropriate file format for the job](#id10) 

Different file formats are better for certain types of images. In the end, we want to have images that look nice and have a low filesize, because that makes the manual easier to download or browse on the internet.  GUI screenshots

This should use PNG, and if possible, in GIF.  Images that have a lot of flat colors.

This should use PNG.  Grayscale images

These should be GIF or PNG.  Images with a lot of gradients

These should be JPG.  Images with a lot of transparency.

These should use PNG.   

The logic is the way how each of these saves colors. JPEG is ideal for photos and images with a lot of gradients because it [compresses differently](../general_concepts/file_formats/lossy_lossless.xhtml#lossy-compression). However, contrasts don’t do well in JPEG. PNG does a lot better with images with sharp contrasts, while in some cases we can even have less than 256 colors, so GIF might be better. 

Grayscale images, even when they have a lot of gradients variation, should be PNG. The reason is that when we use full color images, we are, depending on the image, using 3 to 5 numbers to describe those values, with each of those values having a possibility to contain any of 256 values. JPEG and other ‘lossy’ file formats use clever psychological tricks to cut back on the amount of values an image needs to show its contents. However, when we make grayscale images, we only keep track of the lightness. The lightness is only one number, that can have 256 values, making it much easier to just use GIF or PNG, instead of JPEG which could have nasty artifacts. (And, it is also a bit smaller) 

**When in doubt, use PNG.**   

### [Optimising Images in quality and size](#id11) 

Now, while most image editors try to give good defaults on image sizes, we can often make them even smaller by using certain tools.  

#### [Windows](#id12) 

The most commonly recommended tool for this on Windows is [IrfranView](https://www.irfanview.com/) [https://www.irfanview.com/], but the dear writer of this document has no idea how to use it exactly. 

The other option is to use PNGCrush as mentioned in the linux section.   

#### [Linux](#id13)  

##### [Optimising PNG](#id14) 

There is a whole laundry list of [PNG optimisation tools](https://css-ig.net/png-tools-overview) [https://css-ig.net/png-tools-overview] available on Linux. They come in two categories: Lossy (Using psychological tricks), and Lossless (trying to compress the data more conventionally). The following are however the most recommended:  [PNGQuant](https://pngquant.org/) [https://pngquant.org/]

A PNG compressor using lossy techniques to reduce the amount of colors used in a smart way. 

To use PNGquant, go to the folder of choice, and type: 

```
pngquant --quality=80-100 image.png

```
  

Where *image* is replaced with the image file name. When you press the Enter key, a new image will appear in the folder with the compressed results. PNGQuant works for most images, but some images, like the color selectors don’t do well with it, so always double check that the resulting image looks good, otherwise try one of the following options:  [PNGCrush](https://pmt.sourceforge.io/pngcrush/) [https://pmt.sourceforge.io/pngcrush/]

A lossless PNG compressor. Usage: 

```
pngcrush image.png imageout.png

```
  

This will try the most common methods. Add `-brute` to try out all methods.  [Optipng](http://optipng.sourceforge.net/) [http://optipng.sourceforge.net/]

Another lossless PNG compressor which can be run after using PNGQuant, it is apparently originally a fork of png crush. Usage: 

```
optipng image.png

```
  

where image is the filename. OptiPNG will then proceed to test several compression algorithms and **overwrite** the *image.png* file with the optimised version. You can avoid overwriting with the `--out imageout.png` command.     

##### [Optimising GIF](#id15)  
- 

[FFmpeg](http://blog.pkh.me/p/21-high-quality-gif-with-ffmpeg.html) [http://blog.pkh.me/p/21-high-quality-gif-with-ffmpeg.html] 
- 

[Gifski](https://gif.ski/) [https://gif.ski/] 
- 

[LossyGif](https://kornel.ski/lossygif) [https://kornel.ski/lossygif]    

##### [Optimising JPEG](#id16) 

Now, JPEG is really tricky to optimize properly. This is because it is a [lossy file format](../general_concepts/file_formats/lossy_lossless.xhtml#lossy-compression), and that means that it uses psychological tricks to store its data. 

However, tricks like these become very obvious when your image has a lot of contrast, like text. Furthermore, JPEGs don’t do well when they are resaved over and over. Therefore, make sure that there’s a lossless version of the image somewhere that you can edit, and that only the final result is in JPEG and gets compressed further.    

#### [macOS](#id17)  
- 

[ImageOptim](https://imageoptim.com/mac) [https://imageoptim.com/mac] – A Graphical User Interface wrapper around commandline tools like PNGquant and gifski.     

### [Editing the metadata of a file](#id18) 

Sometimes, personal information gets embedded into an image file. Othertimes, we want to embed information into a file to document it better. 

There are no less than 3 to 4 different ways of handling metadata, and metadata has different ways of handling certain files. 

The most commonly used tool to edit metadata is **ExifTool**, another is to use **ImageMagick**.  

#### [Windows and macOS](#id19) 

To get exiftool, [just get it from the website](https://www.sno.phy.queensu.ca/~phil/exiftool/) [https://www.sno.phy.queensu.ca/~phil/exiftool/].   

#### [Linux](#id20) 

On Linux, you can also install exiftool.  Debian/Ubuntu

`sudo apt-get install libimage-exiftool-perl`     

#### [Viewing Metadata](#id21) 

Change the directory to the folder where the image is located and type: 

```
exiftool image

```
  

where image is the file you’d like to examine. If you just type `exiftool` in any given folder it will output all the information it can give about any file it comes across. If you take a good look at some images, you’ll see they contain author or location metadata. This can be a bit of a problem sometimes when it comes to privacy, and also the primary reason all metadata gets stripped. 

You can also use [ImageMagick’s identify](https://www.imagemagick.org/script/identify.php) [https://www.imagemagick.org/script/identify.php]: 

```
identify -verbose image

```
    

#### [Stripping Metadata](#id22) 

Stripping metadata from the example `image.png` can be done as follows:  [ExifTool](http://www.linux-magazine.com/Online/Blogs/Productivity-Sauce/Remove-EXIF-Metadata-from-Photos-with-exiftool) [http://www.linux-magazine.com/Online/Blogs/Productivity-Sauce/Remove-EXIF-Metadata-from-Photos-with-exiftool]

exiftool -all= image.png 

This empties all tags exiftool can get to. You can also be specific and only remove a single tag: exiftool -author= image.png  OptiPNG

optipng -strip image.png This will strip and compress the png file.  [ImageMagick](https://www.imagemagick.org/script/command-line-options.php#strip) [https://www.imagemagick.org/script/command-line-options.php#strip]

convert image.png –strip     

#### [Extracting metadata](#id23) 

Sometimes we want to extract metadata, like an ICC profile, before stripping everything. This is done by converting the image to the profile type:  [ImageMagick’s Convert](https://imagemagick.org/script/command-line-options.php#profile) [https://imagemagick.org/script/command-line-options.php#profile]

First extract the metadata to a profile by converting: 

```
convert image.png image_profile.icc

```
  

Then strip the file and readd the profile information: 

```
convert -profile image_profile.icc image.png

```
      

#### [Embedding description metadata](#id24) 

Description metadata is really useful for the purpose of helping people with screenreaders. Webbrowsers will often try to use the description metadata if there’s no alt text to generate the alt-text. Another thing that you might want to embed is stuff like color space data. 

ExifTool  ImageMagick

Setting an exif value: 

```
convert -set exif:ImageDescription "An image description" image.png image_modified.png

```
  

Setting the PNG chunk for description: 

```
convert -set Description "An image description" image.png image_modified.png

```
      

#### [Embedding license metadata](#id25) 

In a certain way, embedding license metadata is really nice because it allows you to permanently mark the image as such. However, if someone then uploads it to another website, it is very likely the metadata is stripped with imagemagick.  

##### [Using Properties](#id26) 

You can use dcterms:license for defining the document where the license is defined.  ImageMagick

For the GDPL: 

```
convert -set dcterms:license "GDPL 1.3+ https://www.gnu.org/licenses/fdl-1.3.txt" image.png

```
  

This defines a shorthand name and then license text. 

For Creative Commons BY-SA 4.0: 

```
convert -set dcterms:license "CC-BY-SA-4.0 https://creativecommons.org/licenses/by-sa/4.0/" image.png

```
    

The problem with using properties is that they are a non-standard way to define a license, meaning that machines cannot do much with them.   

##### [Using XMP](#id27) 

The creative commons website suggest we [use XMP for this](https://wiki.creativecommons.org/wiki/XMP) [https://wiki.creativecommons.org/wiki/XMP]. You can ask the Creative Commons License choose to generate an appropriate XMP file for you when picking a license. 

We’ll need to use the [XMP tags for exiftool](https://www.sno.phy.queensu.ca/~phil/exiftool/TagNames/XMP.html) [https://www.sno.phy.queensu.ca/~phil/exiftool/TagNames/XMP.html]. 

So that would look something like this: 

```
exiftool -Marked=true -License="https://creativecommons.org/licenses/by-sa/4.0" -UsageTerms="This work is licensed under a <a rel="license" href="https://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>." -Copyright="CC-BY-SA-NC 4.0" image.png

```
  

Another way of doing the marking is: 

```
exiftool -Marked=true -License="https://creativecommons.org/licenses/by-sa/4.0" -attributionURL="docs.krita.org" attributionName="kritaManual" image.png

```
   With imagemagick you can use the profile option again.

First extract the data (if there is any): 

```
convert image.png image_meta.xmp

```
  

Then modify the resulting file, and embed the image data: 

```
convert -profile image_meta.xmp image.png

```
    

The XMP definitions per license. You can generate an XMP file for the metadata on the creative commons website.