## Clipping Masks and Alpha Inheritance 

Krita doesn’t have clipping mask functionality in the manner that Photoshop and programs that mimic Photoshop’s functionality have. That’s because in Krita, unlike such software, a group layer is not an arbitrary collection of layers. Rather, in Krita, group layers are composited separately from the rest of the stack, and then the result is added into the stack. In other words, in Krita group layers are in effect distinct images inside your image. [img: Animation showing that groups are composed before the rest of composition takes place.] 

The exception is when using pass-through mode, meaning that alpha inheritance won’t work right when turning on pass-through on the layer. [img: An image showing the way layers composite in Krita.] 

When we turn on alpha inheritance, the alpha-inherited layer keeps the same transparency as the layers below. [img: An image showing how the alpha inheritance works and affects layers.] 

Combined with group layers this can be quite powerful. A situation where this is particularly useful is the following: [img: An image with line art and a layer for each flat of color.] 

Here we have an image with line art and a layer for each flat of colors. We want to add complicated multi-layered shading to this, while keeping the neatness of the existing color flats. To get a clipping mask working, you first need to put layers into a group. You can do this by making a group layer and drag-and-dropping the layers into it, or by selecting the layers you want grouped and pressing the Ctrl + G shortcut. Here we do that with the iris and the eye-white layers. [img: An image showing how the alpha inheritance works and affects layers.] 

We add a layer for the highlight above the other two layers, and add some white scribbles. [img: Clipping mask step 3.] [img: Clipping mask step 4.] 

In the above, we have our layer with a white scribble on the left, and on the right, the same layer, but with alpha inheritance active, limiting it to the combined area of the iris and eye-white layers. [img: Clipping mask step 5.] 

Now there’s an easier way to set up alpha inheritance. If you select a layer or set of layers and press the Ctrl + Shift + G shortcut, you create a quick clipping group. That is, you group the layers, and a ‘mask layer’ set with alpha inheritance is added on top. [img: Clipping mask step 6.] [img: Clipping mask step 7.] 

The fact that alpha inheritance can use the composited transparency from a combination of layers means that you can have a layer with the erase-blending mode in between, and have that affect the area that the layer above is clipped to. Above, the lower image is exactly the same as the upper one, except with the erase-layer hidden. Filters can also affect the alpha inheritance: [img: Filter layers and alpha inheritance.] 

Above, the blur filter layer gives different results when in different places, due to different parts being blurred.