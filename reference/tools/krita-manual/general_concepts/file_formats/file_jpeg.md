## *.jpg 

`.jpg`, `.jpeg` or `.jpeg2000` are a family of file-formats designed to encode photographs. 

Photographs have the problem that they have a lot of little gradients, which means that you cannot index the file like you can with [*.gif](file_gif.xhtml#file-gif) and expect the result to look good. What JPEG instead does is that it converts the file to a perceptual color space ([YCrCb](../colors/color_models.xhtml#model-ycrcb)), and then compresses the channels that encode the colors, while keeping the channel that holds information about the relative lightness uncompressed. This works really well because human eye-sight is not as sensitive to colorfulness as it is to relative lightness. JPEG also uses other [lossy](lossy_lossless.xhtml#lossy-compression) compression techniques, like using cosine waves to describe image contrasts. 

However, it does mean that JPEG should be used in certain cases. For images with a lot of gradients, like full scale paintings, JPEG performs better than [*.png](file_png.xhtml#file-png) and [*.gif](file_gif.xhtml#file-gif). 

But for images with a lot of sharp contrasts, like text and comic book styles, PNG is a much better choice despite a larger file size. For grayscale images, [*.png](file_png.xhtml#file-png) and [*.gif](file_gif.xhtml#file-gif) will definitely be more efficient. 

Because JPEG uses lossy compression, it is not advised to save over the same JPEG multiple times. The lossy compression will cause the file to reduce in quality each time you save it. This is a fundamental problem with lossy compression methods. Instead use a lossless file format, or a working file format while you are working on the image.