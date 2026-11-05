.. index:: Shader Nodes; Math
.. _bpy.types.ShaderNodeMath:

.. Editor's Note: This page gets copied into:
.. - :doc:`</compositing/types/utilities/math>`
.. - :doc:`</modeling/modifiers/nodes/utilities/math>`

.. --- copy below this line ---

*********
Math Node
*********

.. figure:: /images/node-types_ShaderNodeMath.webp
   :align: right
   :alt: Math node.

The *Math Node* performs one of over 40 math operations on its inputs.
It is one of the most frequently used utility nodes in shader, compositing,
and geometry node setups — used for everything from adjusting texture brightness
to creating procedural masks and patterns.

The node's input sockets change dynamically depending on the selected operation.
Only the sockets relevant to the current operation are shown.


Inputs
======

The inputs are dynamic: they appear only when needed by the selected operation.

Value
   Numeric input. Most operations use one or two values, shown as separate *Value* sockets
   in the interface. Trigonometric functions interpret this value as radians.

Multiplier
   The multiplier for *Multiply Add*. The input value is multiplied by this before
   *Addend* is added.

Addend
   An extra value added after multiplication. Used only by *Multiply Add*.

Base
   The base value for operations like *Power* and *Logarithm*.

Exponent
   The exponent for *Power*.

Threshold
   The comparison threshold for *Less Than* and *Greater Than*.
   The output is 1.0 when the first value passes this threshold, 0.0 otherwise.

Epsilon
   The tolerance threshold for *Compare*. Smaller values require closer matches.

Distance
   The distance for *Smooth Minimum* and *Smooth Maximum*.
   Larger values create a wider blending zone between the two inputs.

Min
   The lower bound for *Wrap*. Values will not go below this.

Max
   The upper bound for *Wrap*. Values will be wrapped back into range when they exceed this.

Increment
   The step size for *Snap*. The output will be rounded to multiples of this value.

Scale
   The maximum value for *Ping-Pong*. The output bounces between 0.0 and this value.

Degrees
   Input angle in degrees for the *To Radians* conversion.

Radians
   Input angle in radians for the *To Degrees* conversion.


Properties
==========

Operation
   The mathematical operator to be applied to the input values.

   Functions
      Basic arithmetic operations for scaling, offsetting, and combining values.

      :Add: The sum of the two values.
      :Subtract: The difference between the two values.
      :Multiply:
         The product of the two values. Multiplying by a value between 0 and 1 darkens; values above 1 brighten.
      :Divide: The division of the first value by the second value. Division by zero results in zero.
      :Multiply Add: Computes :math:`A × B + C`. Useful for scaling a value then adding an offset in a single node.
      :Power:
         The *Base* raised to the power of *Exponent*. Values above 1 steepen the curve; values below 1 flatten it.
      :Logarithm: The log of the value with a *Base* as its base.
      :Square Root: The square root of the value.
      :Inverse Square Root: One divided by the square root of the value.
      :Absolute:
         Outputs the value without regard to its sign, turning negative values into positive ones.
         Commonly used to convert signed noise (e.g. -1.0 to 1.0) into an unsigned range (0.0 to 1.0)
         suitable for use as a factor input.
      :Exponent:
         Raises Euler's number (:math:`e`) to the power of the value.

   Comparison
      Operations that compare two values or produce a 0 or 1 output.
      These are often used to create masks, thresholds, and conditional branching in node graphs.

      :Minimum: Outputs the smaller of the two values.
      :Maximum: Outputs the larger of the two values.
      :Less Than: Outputs 1.0 when the first value is smaller, and 0.0 otherwise. Useful for creating threshold masks.
      :Greater Than:
         Outputs 1.0 when the first value is larger, and 0.0 otherwise. Useful for creating threshold masks.
      :Sign: Outputs 1.0 for positive values, -1.0 for negative, and 0.0 for exactly zero.
      :Compare:
         Outputs 1.0 when the two values are within *Epsilon* of each other.
         Increase *Epsilon* to widen the match tolerance.
      :Smooth Minimum:
         Like *Minimum*, but blends smoothly between the two values when they are close together.
         The blend width is controlled by the *Distance* input.
         Useful for blending height maps or terrain without visible seams.
      :Smooth Maximum:
         Like *Maximum* but with a smooth transition controlled by *Distance*.

   Rounding
      Operations that change a value by snapping, wrapping, or extracting components.
      These are essential for creating repeating patterns, quantization effects, and cyclic motion.

      :Round: Rounds to the nearest integer, rounding 0.5 upward.
      :Floor:
         Rounds down to the nearest integer. For negative numbers, this moves away from zero (e.g. -1.3 becomes -2.0).
      :Ceil: Rounds up to the nearest integer.
      :Truncate: Removes the fractional part without rounding (e.g. 3.7 becomes 3.0, -3.7 becomes -3.0).
      :Fraction: Returns only the fractional part (e.g. 3.7 becomes 0.7). Useful for creating repeating gradients.
      :Truncated Modulo:
         Outputs the remainder of dividing the first value by the second, preserving the sign of the first value.
      :Floored Modulo:
         Outputs a positive remainder, even for negative inputs.
         Use this when you need the result to stay in the [0, divisor) range.
      :Wrap:
         Wraps the input value so it stays between *Min* and *Max* in a repeating loop.
         When the value passes *Max*, it wraps back to *Min*, and vice versa.
         Works like a sawtooth wave — useful for tiling, repeating patterns, and cyclic animations.
      :Snap:
         Rounds the value down to the nearest multiple of *Increment*. Use for quantization or grid-alignment effects.
         Note that this uses floor rounding (towards negative infinity), not rounding to the nearest multiple.
      :Ping-Pong:
         Bounces the value back and forth between 0.0 and *Scale* like a ball.
         As the input increases, the output rises to *Scale* then falls back to 0.0, repeating.
         Useful for back-and-forth animation and folding patterns.

   Trigonometric
      Sine, cosine, and tangent functions. The input is always in radians.
      Commonly used for wave patterns, circular gradients, and angle calculations.

      :Sine: The sine of the input. Output oscillates between -1.0 and 1.0.
      :Cosine: The cosine of the input. Same as sine but shifted by :math:`\pi/2`.
      :Tangent: The tangent of the input. Approaches infinity near :math:`\pi/2 + n \cdot \pi`.
         Results may be unstable or produce artifacts near these points.
      :Arcsine: The inverse sine. Returns an angle in radians in the range :math:`[-\pi/2, \pi/2]`.
      :Arccosine: The inverse cosine. Returns an angle in radians in the range :math:`[0, \pi]`.
      :Arctangent: The inverse tangent. Returns an angle in radians in the range :math:`[-\pi/2, \pi/2]`.
      :Arctan2: The two-argument arctangent. Given Y and X coordinates, returns the angle from the positive X-axis.
         This is the correct way to calculate the angle of a 2D vector, since it preserves quadrant information that
         single-argument arctangent loses.
         The first *Value* input corresponds to Y, the second to X.
      :Hyperbolic Sine: The hyperbolic sine of the input.
      :Hyperbolic Cosine: The hyperbolic cosine of the input.
      :Hyperbolic Tangent: The hyperbolic tangent of the input.

   Conversion
      Simple unit conversions between degree and radian angle representations.

      :To Radians: Converts the input from degrees to radians (multiplies by :math:`\pi/180`).
      :To Degrees: Converts the input from radians to degrees (multiplies by :math:`180/\pi`).

Clamp
   Limits the output to the range (0.0 to 1.0). See :term:`Clamp`.


Outputs
=======

Value
   Numerical value output.


Examples
========

Scaling and Offsetting a Texture Value
--------------------------------------

Texture nodes like *Noise Texture* output values in a fixed range (typically 0.0 to 1.0).
To adjust the contrast and brightness of such values, chain two *Math* nodes:

.. list-table::

   * - .. figure:: /images/render_shader-nodes_utilities_math_example-scale-baseline.png
          :width: 320px

          Noise texture with no scaling.

     - .. figure:: /images/render_shader-nodes_utilities_math_example-scale-multiply.png
          :width: 320px

          Noise scaled by Multiply (×2).

   * - .. figure:: /images/render_shader-nodes_utilities_math_example-scale-add.png
          :width: 320px

          Two nodes: Multiply (×2) then Add (-1).

     - .. figure:: /images/render_shader-nodes_utilities_math_example-scale-multiply-add.png
          :width: 320px

          One node: Multiply Add (Mult=2, Addend=-1).

- *Multiply* to scale the range (e.g. multiply by 2.0 to expand to 0.0–2.0, or 0.5 to compress to 0.0–0.5).
- *Add* to shift the range (e.g. add -1.0 after multiplying by 2.0 to get -1.0 to 1.0).

The *Multiply Add* operation combines both steps into a single node:
:math:`\text{Value} × \text{Multiplier} + \text{Addend}`.

Creating a Threshold Mask
-------------------------

Use *Greater Than* or *Less Than* to create a hard-edged mask:

.. list-table::

   * - .. figure:: /images/render_shader-nodes_utilities_math_example-threshold-baseline.png
          :width: 210px

          Noise texture with no mask.

     - .. figure:: /images/render_shader-nodes_utilities_math_example-threshold-0_5.png
          :width: 210px

          Greater Than 0.5.

     - .. figure:: /images/render_shader-nodes_utilities_math_example-threshold-0_7.png
          :width: 210px

          Greater Than 0.7.

- Connect a *Noise Texture* (Factor output) to the first Value.
- Set the second Value to a threshold (e.g. 0.5).
- The output will be 1.0 wherever the noise is above the threshold, and 0.0 below.

To get a softer transition, chain the result through *Mix* or *Map Range* after the comparison,
or use *Smooth Minimum* and *Smooth Maximum* for soft blending between values.

Blending Height Maps
--------------------

When combining two height maps (e.g. from different noise textures), *Smooth Minimum*
creates a seamless blend that looks like natural terrain erosion:

.. list-table::

   * - .. figure:: /images/render_shader-nodes_utilities_math_example-height-blend-0_01.png
          :width: 210px

          Distance = 0.01, sharp crease.

     - .. figure:: /images/render_shader-nodes_utilities_math_example-height-blend-0_3.png
          :width: 210px

          Distance = 0.3, smooth valleys.

     - .. figure:: /images/render_shader-nodes_utilities_math_example-height-blend-1.png
          :width: 210px

          Distance = 1.0, wide blend.

- Connect two height sources to the two Value inputs.
- Set the *Distance* to control how wide the blend zone is.
- A small *Distance* gives sharp creases; a larger value creates gentle valleys.

Repeating a Pattern with Wrap
-----------------------------

*Wrap* forces any increasing value to cycle back between *Min* and *Max* in a repeating loop,
creating a sawtooth-like output. This is useful for driving procedural patterns and gradients
that repeat automatically as the input increases:

.. list-table::

   * - .. figure:: /images/render_shader-nodes_utilities_math_example-wrap-no.png
          :width: 340px

          Multiply only — values beyond 1.0 are clamped, no repetition.

     - .. figure:: /images/render_shader-nodes_utilities_math_example-wrap-yes.png
          :width: 340px

          Multiply then Wrap — values cycle back, creating repeating bands.

- Connect a *Texture Coordinate* node's X axis (via *Separate XYZ*) to the Value input.
- Set *Min* = 0.0 and *Max* = 1.0. Multiply the axis value first to control how many repeats
  appear across the surface (e.g. ×5.0 for five cycles).
- Connect the output to a *Color Ramp* set to black and white to see the repeating bands.
