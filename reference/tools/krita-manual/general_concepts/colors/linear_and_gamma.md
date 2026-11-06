## Gamma and Linear 

Now, the situation we talk about when talking theory is what we would call ‘linear’. Each step of brightness is the same value. Our eyes do not perceive linearly. Rather, we find it more easy to distinguish between darker grays than we do between lighter grays. 

As humans are the ones using computers, we have made it so that computers will give more room to darker values in the coordinate system of the image. We call this ‘gamma-encoding’, because it is applying a gamma function to the TRC or transfer function of an image. The TRC in this case being the Tone Response Curve or Tone Reproduction Curve or Transfer function (because color management specialists hate themselves), which tells your computer or printer how much color corresponds to a certain value.  [img: ../../_images/Pepper_tonecurves.png]  

One of the most common issues people have with Krita’s color management is the assigning of the right colorspace to the encoded TRC. Above, the center Pepper is the right one, where the encoded and assigned TRC are the same. To the left we have a Pepper encoded in sRGB, but assigned a linear profile, and to the right we have a Pepper encoded with a linear TRC and assigned an sRGB TRC. Image from [Pepper & Carrot](https://www.peppercarrot.com/) [https://www.peppercarrot.com/].   

The following table shows how there’s a lot of space being used by lighter values in a linear space compared to the default sRGB TRC of our modern computers and other TRCs available in our delivered profiles: [img: ../../_images/trc_gray_gradients.svg] 

If you look at linear of Rec. 709 TRCs, you can see there’s quite a jump between the darker shades and the lighter shades, while if we look at the Lab L* TRC or the sRGB TRC, which seem more evenly spaced. This is due to our eyes’ sensitivity to darker values. This also means that if you do not have enough bit depth, an image in a linear space will look as if it has ugly banding. Hence why, when we make images for viewing on a screen, we always use something like the Lab L*, sRGB or Gamma 2.2 TRCs to encode the image with. 

However, this modification to give more space to darker values does lead to wonky color maths when mixing the colors. 

We can see this with the following experiment:  [img: ../../_images/Krita_2_9_colormanagement_blending_1.png]  

**Left:** Colored circles blurred in a regular sRGB space. **Right:** Colored circles blurred in a linear space.   

Colored circles, half blurred. In a gamma-corrected environment, this gives an odd black border. In a linear environment, this gives us a nice gradation. 

This also counts for Krita’s color smudge brush:  [img: ../../_images/Krita_2_9_colormanagement_blending_2.png]  

That’s right, the ‘muddying’ of colors as is a common complaint by digital painters everywhere, is in fact, a gamma-corrected colorspace mucking up your colors. If you had been working in LAB to avoid this, be sure to try out a linear rgb color space.    

### What is happening under the hood 

Imagine we want to mix red and green. 

First, we would need the color coordinates of red and green inside our color space’s color model. So, that’d be…   
| 

Color |  

Red |  

Green |  

Blue |     
| 

Red |  

1.0 |  

0.0 |  

0.0 |   
| 

Green |  

0.0 |  

1.0 |  

0.0 |     

We then average these coordinates over three mixes:   
|  |  

Red |  

Mix1 |  

Mix2 |  

Mix3 |  

Green |     
| 

Red |  

1.0 |  

0.75 |  

0.5 |  

0.25 |  

0.0 |   
| 

Green |  

0.0 |  

0.25 |  

0.5 |  

0.75 |  

1.0 |   
| 

Blue |  

0.0 |  

0.0 |  

0.0 |  

0.0 |  

0.0 |     

But to figure out how these colors look on screen, we first put the individual values through the TRC of the color-space we’re working with: [img: ../../_images/Basicreading3trcsv2.svg] 

Then we fill in the values into the correct spot. Compare these to the values of the mixture table above! [img: ../../_images/red_green_mixes_trc.svg] 

And this is why color mixtures are lighter and softer in linear space. Linear space is more physically correct, but sRGB is more efficient in terms of space, so hence why many images have an sRGB TRC encoded into them. In case this still doesn’t make sense: *sRGB gives largely* **darker** *values than linear space for the same coordinates*. 

So different TRCs give different mixes between colors, in the following example, every set of gradients is in order a mix using linear TRC, a mix using sRGB TRC and a mix using Lab L* TRC. [img: ../../_images/3trcsresult.png] 

So, you might be asking, how do I tick this option? Is it in the settings somewhere? The answer is that we have several ICC profiles that can be used for this kind of work:  
- 

scRGB (linear) 
- 

All ‘elle’-profiles ending in ‘g10’, such as *sRGB-elle-v2-g10.icc*.  

In fact, in all the ‘elle’-profiles, the last number indicates the gamma. 1.0 is linear, higher is gamma-corrected and ‘srgbtrc’ is a special gamma correction for the original sRGB profile. 

If you use the color space browser, you can tell the TRC from the ‘estimated gamma’(if it’s 1.0, it’s linear), or from the TRC widget in Krita 3.0, which looks exactly like the curve graphs above. 

Even if you do not paint much, but are for example making textures for a videogame or rendering, using a linear space is very beneficial and will speed up the renderer a little, for it won’t have to convert images on its own. 

The downside of linear space is of course that white seems very overpowered when mixing with black, because in a linear space, light grays get more room. In the end, while linear space is physically correct, and a boon to work in when you are dealing with physically correct renderers for videogames and raytracing, Krita is a tool and no-one will hunt you down for preferring the dark mixing of the sRGB TRC.