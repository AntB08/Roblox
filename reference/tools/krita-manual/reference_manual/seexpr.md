## [SeExpr Quick Reference](#id1) 

This page details all the available variables, functions, and operators in SeExpr. It is a heavily edited version of the official [user documentation](https://wdas.github.io/SeExpr/doxygen/userdoc.html) [https://wdas.github.io/SeExpr/doxygen/userdoc.html], adapted for usage with Krita. 

 

See also  
- 

Source code at [KDE Invent](https://invent.kde.org/lsegovia/seexpr) [https://invent.kde.org/lsegovia/seexpr] 
- 

Disney’s SeExpr [API Documentation](http://wdas.github.io/SeExpr/doxygen/) [http://wdas.github.io/SeExpr/doxygen/]   

 

See also  
- 

[Introduction to SeExpr](../tutorials/seexpr.xhtml#seexpr-tut-intro) 
- 

[SeExpr](layers_and_masks/fill_layer_generators/seexpr.xhtml#seexpr-fill-layer) 
- 

[SeExpr Scripts](resource_management/seexpr_scripts.xhtml#resource-seexpr-scripts) 
- 

[“Procedural texture generator (example and wishes)” on Krita Artists](https://krita-artists.org/t/procedural-texture-generator-example-and-wishes/7638) [https://krita-artists.org/t/procedural-texture-generator-example-and-wishes/7638] 
- 

[Inigo Quilez’s articles](https://iquilezles.org/www/index.htm) [https://iquilezles.org/www/index.htm] 
- 

[The Book of Shaders](https://thebookofshaders.com/) [https://thebookofshaders.com/]    

Contents  
- 

[SeExpr Quick Reference](#seexpr-quick-reference)  
- 

[Variables](#variables)  
- 

[External variables](#external-variables) 
- 

[Local Variables](#local-variables)   
- 

[Control Structures](#control-structures) 
- 

[Operators (listed in decreasing precedence)](#operators-listed-in-decreasing-precedence) 
- 

[Assignment Operators](#assignment-operators) 
- 

[Comments](#comments) 
- 

[Logging Functions](#logging-functions) 
- 

[Color, Masking, and Remapping Functions](#color-masking-and-remapping-functions) 
- 

[Noise Functions](#noise-functions) 
- 

[Selection Functions](#selection-functions) 
- 

[General Mathematical Constants and Functions](#general-mathematical-constants-and-functions) 
- 

[Trigonometry Functions](#trigonometry-functions) 
- 

[Vector Functions](#vector-functions) 
- 

[Vector Support](#vector-support) 
- 

[Curve Functions](#curve-functions) 
- 

[Custom Plugins](#custom-plugins)      

### [Variables](#id2)  

#### [External variables](#id3) 

These variables are provided by host applications, in this case Krita. They are registered with SeExpr’s autocomplete help, which can be accessed by Ctrl+Space.  $u, $v

Pixel position in normalized coordinates.  $w, $h

Image’s width and height in pixels.     

#### [Local Variables](#id4) 

Local variables can be defined at the start of the expression: 

```
$a = noise($P);
$b = noise($a * 1);
pow($a, 0.5) + $b

```
  

External variables can also be overridden by local assignment. This can be useful to scale the noise frequency for instance: 

```
$P = $P * 10; # increase noise frequency
fbm(vnoise($P) + $P/4)

```
  

You can also define namespaced variables, e.g.: 

```
$A::a = $u * 10;

```
     

### [Control Structures](#id5) 

SeExpr provides the well-known if conditional structure: 

```
if ($ u > 0.5) {
    $color = [0, 0, 1];
}
else {
    $color = [1, 0, 0];
}

$color

```
  

And the *ternary operator*: 

```
$u = $i < .5 ? 0.0 : 10.0

```
  

You can freely nest ternary operators, e.g.: 

```
$color = $u < .5 ? ($v < 0.5 ? [0, 0, 1] : [1, 0, 0]) : [0, 1, 0];
$color

```
  

You can also achieve the same with if structures: 

```
if ($ u > 0.5) {
    if ($v < 0.5) {
        $color = [0, 0, 1];
    }
    else {
        $color = [1, 0, 0];
    }
}
else {
    $color = [1, 0, 0];
}

$color

```
    

### [Operators (listed in decreasing precedence)](#id6)  [a,b,c]

vector constructor  $P[ n ]

vector component access 

 

Hint 

`n` must be 0, 1, or 2, e.g.: 

```
$P[0]

```
    ^

exponentiation 

 

Note 

Same as the `pow` function.   !

logical NOT  ~

inversion 

 

Hint 

```
~$A

```
  

gives the same result as: 

```
1 - $A

```
    */ %

multiply, divide, modulus 

 

Note 

`%` is the same as the `fmod` function.   +-

add, subtract  <> <= >=

comparison: less than, greater than, less or equal than, greater or equal than 

 

Note 

Only uses the first component of a vector.   == !=

equality, inequality  &&

logical AND  ||

logical OR  ?:

ternary `if` operator 

 

Hint 

Example: 

```
$u < .5 ? 0 : 1

```
    ->

apply - The function on the right of the arrow is applied to the expression on the left. 

 

Hint 

Examples: 

```
$Cs->contrast(.7) -> clamp(0.2,0.8)
$u->hsi(20,1.2,1,$Cs->gamma(1.2))

```
       

### [Assignment Operators](#id7) 

Besides the basic assignment statement: 

```
$foo = $bar

```
  

you can also do operator assignments such as: 

```
$foo += $bar;

```
  

which is equivalent to: 

```
$foo = $foo + $bar;

```
  

Additionally, there are:  
- 

`+=` 
- 

`-=` 
- 

`/=` 
- 

`%=` 
- 

`*=` 
- 

`^=`    

### [Comments](#id8) 

You can add comments to your script by using the `#` character. SeExpr will then skip the rest of the line for rendering purposes. However, they are not ignored; comments can still be used to declare the valid value range of integer, float, and vector variables. This enables you to manage them using widgets that will accept the specified range. 

 

Hint 

`$var0` is an integer variable that ranges between 0 and 10 inclusive: 

```
$var0 = 0; # 0, 10

```
  

`$var1` is a floating point variable with the same range: 

```
$var1 = 0; # 0.000, 10.000

```
  

`$var2` is a vector variable: 

```
$var2 = [0, 0, 0] # 0.000, 10.000

```
  

The latter is very helpful; SeExpr considers vectors with range `[0, 1]` as colors: 

```
# this is a dark red
$color = [0.5, 0, 0] # 0.000, 1.000

```
  

In all cases, if not specified, the associated widgets’ range will go from 0 to 1.  

For a multi-line expression, each line may have its own comment.   

### [Logging Functions](#id9)  float **printf** ( string format, [param0, param1, …] )

Prints a string to stdout that is formatted as given. Formatting parameters possible are `%f` for float (takes the first component of vector argument) or `%v` for vector. 

 

Hint 

For example, if you wrote: 

```
$u = printf("test %f %v",[1,2,3],[4,5,6]);

```
  

you would get in your console: 

```
test 1 [4,5,6]

```
    string **sprintf** ( string format, [double|string, double|string, …] )

Returns a string formatted from the given values. See `man sprintf` for format details.     

### [Color, Masking, and Remapping Functions](#id10)  float **bias** ( float x, float b)

Variation of gamma where control parameter goes from `0` to `1` with values `> 0.5` pulling the curve up and values `< 0.5` pulling the curve down. Defined as `pow(x, log(b)/log(0.5))`.  float **boxstep** ( float x, float a )float **gaussstep** ( float x, float a, float b )float **linearstep** ( float x, float a, float b )float **smoothstep** ( float x, float a, float b )

The step functions are zero for `x < a` and one for `x > b` (or `x > a` in the case of boxstep). Between `a` and `b`, the value changes continuously between zero and one. The `gausstep` function uses the standard Gaussian “bell” curve which is based on an exponential curve. The `smoothstep` function uses a cubic curve. Intuitively, `gausstep` has a sharper transition near one and a softer transition near zero whereas `smoothstep` has a medium softness near both one and zero.  float **clamp** ( float x, float lo, float hi )

Constrain `x` to range `[lo, hi]`.  float **compress** ( float x, float lo, float hi )

Compress the dynamic range from `[0, 1]` to `[lo, hi]`.  float **contrast** ( float x, float c )

Adjust the contrast. For `c` from `0` to `0.5`, the contrast is decreased. For `c > 0.5`, the contrast is increased.  float **expand** ( float x, float lo, float hi )

Expand the dynamic range from `[lo, hi]` to `[0, 1]`.  float **fit** ( float x, float a1, float b1, float a2, float b2 )

Linear remapping of `[a1..x..b1]` to `[a2..x..b2]`  float **gamma** ( float x, float g)

`pow(x, 1/g)`  float **invert** ( float x )

Invert the value. Defined as `1 - x`.  color **hsi** ( color x, float h, float s, float i, float map=1 )

The `hsi` function shifts the hue by `h` (in degrees) and scales the saturation and intensity by `s` and `i` respectively. A map may be supplied which will control the shift - the full shift will happen when the map is one and no shift will happen when the map is zero. The shift will be scaled back for values between zero and one.  color **hsltorgb** ( color hsl )color **rgbtohsl** ( color rgb )

RGB to HSL color space conversion. HSL is Hue, Saturation, Lightness (all in the range `[0, 1]`). These functions have also been extended to support RGB and HSL values outside of the range `[0, 1]` in a reasonable way. For any RGB or HSL value (except for negative values), the conversion is well-defined and reversible.  color **midhsi** ( color x, float h, float s, float i, float map, float falloff=1, int interp=0 )

The `midhsi` function is just like the `hsi` function except that the control map is centered around the mid point (value of `0.5`) and can scale the shift in both directions. At the mid point, no shift happens. At *1.0*, the full shift happens, and at `0.0`, the full inverse shift happens. Additional `falloff` and `interp` controls are provided to adjust the map using the `remap` function. The default `falloff` and `interp` values result in no remapping.  float **mix** ( float a, float b, float alpha )

Blend of a and b according to alpha. Defined as `a*(1-alpha) +b*alpha`.  float **remap** ( float x, float source, float range, float falloff, int interp )

General remapping function. When `x` is within `± range` of source, the result is one. The result falls to zero beyond that range over `falloff` distance. The falloff shape is controlled by `interp`. 

 

Note 

Numeric values or named constants may be used:  
- 

int **linear** = 0 
- 

int **smooth** = 1 
- 

int **gaussian** = 2       

### [Noise Functions](#id11)  float **cellnoise** ( vector v )float **cellnoise1** ( float x )float **cellnoise2** ( float x, float y )float **cellnoise3** ( float x, float y, float z )color **ccellnoise** ( vector v )

`cellnoise` generates a field of constant colored cubes based on the integer location. This is the same as the [PRMan cellnoise function](https://renderman.pixar.com/resources/RenderMan_20/cellnoise.html) [https://renderman.pixar.com/resources/RenderMan_20/cellnoise.html]. 

 

Note 

`ccellnoise` outputs color cellnoise.   float **fbm** ( vector v, int octaves=6, float lacunarity=2, float gain=0.5 )color **cfbm** ( vector v, int octaves=6, float lacunarity=2, float gain=0.5 )vector **vfbm** ( vector v, int octaves=6, float lacunarity=2, float gain=0.5 )float **fbm4** ( vector v, float time, int octaves=6, float lacunarity=2, float gain=0.5 )color **cfbm4** ( vector v, float time, int octaves=6, float lacunarity=2, float gain=0.5 )vector **vfbm4** ( vector v, float time, int octaves=6, float lacunarity=2, float gain=0.5 )

`fbm` (Fractal Brownian Motion) is a multi-frequency noise function. The base frequency is the same as the `noise` function. The total number of frequencies is controlled by `octaves`. The `lacunarity` is the spacing between the frequencies - a value of 2 means each octave is twice the previous frequency. The `gain` controls how much each frequency is scaled relative to the previous frequency. 

 

Note 

`cfbm` and `cfbm4` outputs color noise. 

`vfbm` and `vfbm4` outputs vector noise.   float **hash** ( float seed1, [float seed2, …] )

Like `rand`, but with no internal seeds. Any number of seeds may be given and the result will be a random function based on all the seeds.  float **noise** ( vector v )float **noise** ( float x, float y )float **noise** ( float x, float y, float z )float **noise** ( float x, float y, float z, float w )color **cnoise** ( vector v)color **cnoise4** ( vector v, float t)float **pnoise** ( vector v, vector period )float **snoise** ( vector v)float **snoise4** ( vector v, float t)vector **vnoise** (vector v )vector **vnoise4** (vector v, float t )

`noise` is a random function that smoothly blends between samples at integer locations. This is Ken Perlin’s original noise function. 

 

Note 

`cnoise` and `cnoise4` output color noise. 

`noise4` outputs signed vector noise. 

`pnoise` outputs periodic noise. 

`snoise` and `snoise4` output signed noise with range `[-1, 1]`. 

`vnoise` outputs signed vector noise.   float **rand** ( [float min, float max], [float seed] )

Random number between `[min, max]` (or `[0, 1]` if unspecified). If a seed is supplied, it will be used in addition to the internal seeds and may be used to create multiple distinct generators.  float **turbulence** ( vector v, int octaves=6, float lacunarity=2, float gain=0.5 )color **cturbulence** ( vector v, int octaves=6, float lacunarity=2, float gain=0.5 )vector **vturbulence** ( vector v, int octaves=6, float lacunarity=2, float gain=0.5 )

`turbulence` is a variant of `fbm` where the absolute value of each noise term is taken. This gives a more billowy appearance.  float **voronoi** ( vector v, int type=1, float jitter=0.5, float fbmScale=0, int fbmOctaves=4, float fbmLacunarity=2, float fbmGain=0.5)color **cvoronoi** ( vector v, int type=1, float jitter=0.5, float fbmScale=0, int fbmOctaves=4, float fbmLacunarity=2, float fbmGain=0.5)vector **pvoronoi** ( vector v, float jitter=0.5, float fbmScale=0, int fbmOctaves=4, float fbmLacunarity=2, float fbmGain=0.5)

`voronoi` is a cellular noise pattern. It is a jittered variant of `cellnoise`. The type parameter describes different variants of the noise function. The `jitter` param controls how irregular the pattern is (0 is like ordinary cellnoise). The `fbm...` params can be used to distort the noise field. When `fbmScale` is zero (the default), there is no distortion. The remaining params are the same as for the `fbm` function. 

 

Hint 

Voronoi types 1 through 5: 

[img: image0] [img: image1] [img: image2] [img: image3] [img: image4]  

 

Note 

`cvoronoi` returns a random color for each cell and `pvoronoi` returns the point location of the center of the cell.      

### [Selection Functions](#id12)  float **choose** ( float index, float choice1, float choice2, […] )

Chooses one of the supplied choices based on the index (assumed to be in the range `[0, 1]`).  int **cycle** ( int index, int loRange, int hiRange )

Cycles through values between loRange and hiRange based on supplied index. This is an offset `mod` function. The result is computed as `loRange + value % (hiRange-loRange+1)`.  int **pick** ( float index, int loRange, int hiRange, [ float weights, … ] )

Picks values randomly between loRange and hiRange based on supplied index (which is automatically hashed). The values will be distributed according to the supplied weights. Any weights not supplied are assumed to be 1.0.  float **wchoose** ( float index, float choice1, float weight1, float choice2, float weight2, […] )

Chooses one of the supplied choices based on the index (assumed to be in range `[0, 1]`). The values will be distributed according to the supplied weights.   

 

Hint 

This example returns integer values between 1 and 10: 

```
pick(value, 1, 10)

```
  

This example returns the values 1 and 2 twice and 2.5 times as often respectively as compared to the other values (3-10): 

```
pick(value, 1, 10, 2, 2.5)

```
  

This example returns 10, 11, and 13 through 20 (12 is skipped due to zero weight): 

```
pick(value, 10, 20, 1, 1, 0)

```
     

### [General Mathematical Constants and Functions](#id13)  float **PI**

```
float PI = 3.14159...

```
   float **E**

```
float E = 2.71828...

```
     float **abs** ( float x)

Absolute value of `x`.  float **cbrt** ( float x )

Cube root.  float **ceil** ( float x )

Next higher integer.  float **exp** ( float x )

`E` raised to the `x` power.  float **floor** ( float x )

Next lower integer.  float **fmod** ( float x, float y )

Remainder of `x / y`. 

 

Note 

Also available as the `%` operator.   float **log** ( float x )

Natural logarithm.  float **log10** ( float x )

Base 10 logarithm.  float **max** ( float a, float b )

Greater of `a` and `b`.  float **min** ( float a, float b )

Lesser of `a` and `b`.  float **pow** ( float x, float y )

`x` to the `y` power. 

 

Note 

Also available as the `^` operator.   float **round** ( float x )

Nearest integer.  float **sqrt** ( float x )

Square root.  float **trunc** ( float x )

Nearest integer towards zero.     

### [Trigonometry Functions](#id14)  float **acos** ( float x )

Arc cosine.  float **acosd** ( float x )

Arc cosine in degrees.  float **acosh** ( float x )

Hyperbolic arc cosine.  float **asin** ( float x )

Arc sine.  float **asind** ( float x )

Arc sine in degrees.  float **asinh** ( float x )

Hyperbolic arc sine.  float **atan** ( float x )

Arc tangent.  float **atand** ( float x )

Arc tangent in degrees.  float **atan2** ( float y, float x)

Arc tangent of `y/x` between `-PI` and `PI`.  float **atan2d** ( float y, float x )

Arc tangent in degrees of `y/x` between `-180º` and `180º`.  float **atanh** ( float x )

Hyperbolic arc tangent.  float **cos** ( float x )

Cosine.  float **cosd** ( float x )

Cosine in degrees.  float **cosh** ( float x )

Hyperbolic cosine.  float **deg** ( float x )

Radians to degrees.  float **hypot** ( float x, float y )

Length of 2D vector `[x, y]`.  float **rad** ( float x )

Degrees to radians.  float **sin** ( float x )

Sine.  float **sind** ( float x )

Sine in degrees.  float **sinh** ( float x )

Hyperbolic sine.  float **tan** ( float x )

Tangent.  float **tand** ( float x )

Tangent in degrees.  float **tanh** ( float x )

Hyperbolic tangent.     

### [Vector Functions](#id15)  float angle ( vector a, vector b )

Angle between two vectors (in radians).  vector **cross** ( vector a, vector b )

Vector cross product.  float **dist** ( vector a, vector b )

Distance between two points.  float **dot** ( vector a, vector b)

Vector dot product.  float **length** ( vector v )

Length of vector.  vector **norm** ( vector v )

Vector scaled to unit length.  vector **ortho** ( vector a, vector b )

Vector orthographic to two vectors.  vector **rotate** ( vector v, vector axis, float angle )

Rotates `v` around axis by the given `angle` (in radians).  vector **up** ( vector v, vector up )

Rotates `v` such that the Y axis points in the given `up` direction.     

### [Vector Support](#id16) 

*Vectors* (points, colors, or 3D vectors) may be intermixed with *scalars* (simple floating point values). If a scalar is used in a vector context, it is replicated into the three components, e.g. `0.5` becomes `[0.5, 0.5, 0.5]`. 

If a vector is used in a scalar context, only the first component is used. One of the benefits of this is that all the functions that are defined to work with scalars automatically extend to vectors. For instance, `pick`, `choose`, `cycle`, `spline`, etc., will work just fine with vectors. 

Arithmetic operators such as `+`, `*`, etc., and scalar functions are applied component-wise to vectors. For example, applying the `gamma` function to a map adjusts the gamma of all three color channels.   

### [Curve Functions](#id17) 

Interpolation of parameter values to a set of control points is governed by the following functions.  color **ccurve** ( float param, float pos0, color val0, int interp0, float pos1, color val1, int interp1, […] )

Interpolates color ramp given by control points at `param`. Control points are specified by triples of parameters `pos_i`, `val_i`, and `interp_i`. 

 

Hint 

Interpolation codes are:  
- 

0 - none 
- 

1 - linear 
- 

2 - smooth 
- 

3 - spline 
- 

4 - monotone (non-oscillating) spline    float **curve** ( float param, float pos0, float val0, int interp0, float pos1, float val1, int interp1, […] )

Interpolates a 1D ramp defined by control points at `param`. Control points are specified by triples of parameters `pos_i`, `val_i`, and `interp_i`. 

 

Hint 

Interpolation codes are:  
- 

0 - none 
- 

1 - linear 
- 

2 - smooth 
- 

3 - spline 
- 

4 - monotone (non-oscillating) spline    float **spline** ( float param, float y1, float y2, float y3, float y4, […] )

Interpolates a set of values to the parameter specified where `y1`, …, `yn` are distributed evenly from `[0, 1]`.     

### [Custom Plugins](#id18) 

Custom functions may be written in C++ and loaded as one or more dynamic plugins. See [Writing Custom Expression Plugins](https://wdas.github.io/SeExpr/doxygen/plugins.html) [https://wdas.github.io/SeExpr/doxygen/plugins.html] for more details. 

 

Warning 

This functionality is not supported in Krita.