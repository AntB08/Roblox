## Animated Brushes 

Animated brushes are officially called ‘image hoses’, and they’re quite fun. They are basically [brush tips](../../reference_manual/brushes/brush_settings/brush_tips.xhtml#predefined-brush-tip) with multiple image files. 

The typical way to make them is to first draw the ‘frames’ on a small canvas, per layer: [img: Krita Animated brush tip layer setup.] 

You can use the Alt + [img: mouseleft] shortcut on the layer thumbnails to isolate layers without hiding them. [img: Animated brush tips isolated layers.] 

When done you should have a mess like this. 

Go into the brush settings (F5 key), and go to predefined brush-tips, and click stamp. You will get this window. [img: Predefined brush tips dialog.] 

And then use style **animated** and selection mode set to **random**. 

Krita uses [Gimp’s image hose format](../../general_concepts/file_formats/file_gih.xhtml#file-gih) which allows for random selection of the images, angle based selection, pressure based selection, and incremental selection. 

When you create a brushtip, Krita will automatically switch to it for the current brush, but you will always be able to find it in the predefined brushes tab. [img: Result of an animated brush.] 

And now you can use it to paint trees! (for example) 

You can also use animated brush tips to emulate [bristle brush tips](bristle_from_heightmap_brush_tip.xhtml#heightmap-bristle-brush-tips) that go from very fine bristles to a fully opaque stamp based on pressure, like a dry paintbrush might do. Or make incremental patterns like the ones you see on porcelain. [img: Incremental brush tip example.]