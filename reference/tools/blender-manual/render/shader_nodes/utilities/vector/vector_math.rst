.. _bpy.types.ShaderNodeVectorMath:
.. Editor's Note: This page gets copied into:
.. - :doc:`</compositing/types/utilities/vector/vector_math>`
.. - :doc:`</modeling/geometry_nodes/vector/vector_math>`

.. --- copy below this line ---

****************
Vector Math Node
****************

.. figure:: /images/node-types_ShaderNodeVectorMath.webp
   :align: right
   :alt: Vector Math Node.

The *Vector Math* node performs the selected math operation on vectors.
It is widely used for transforming normals, computing directional relationships,
manipulating texture coordinates, and building procedural effects in shader and geometry node setups.

The node's inputs and outputs change dynamically depending on the selected operation.
Some operations output a single float value (e.g. *Dot Product*, *Length*),
while others output a vector (e.g. *Add*, *Cross Product*).


Inputs
======

The inputs are dynamic: they appear only when needed by the selected operation.
The labels of the input sockets also change depending on the operation.

Vector
   The primary vector input :math:`A = \begin{pmatrix} A_x \\ A_y \\ A_z \end{pmatrix}`.
   When *Power* is selected, this input is labeled *Base*.

Vector
   The secondary vector input :math:`B = \begin{pmatrix} B_x \\ B_y \\ B_z \end{pmatrix}`.

   This input is hidden for single-operand operations:
   *Sine*, *Cosine*, *Tangent*, *Ceil*, *Floor*, *Length*, *Absolute*,
   *Fraction*, *Normalize*, *Sign*, *Round*, and *Scale*.

   The label changes depending on the operation:

   - *Power* → *Exponent*
   - *Multiply Add* → *Multiplier*
   - *Faceforward* → *Incident*
   - *Wrap* → *Max*
   - *Snap* → *Increment*

Vector
   The tertiary vector input :math:`C = \begin{pmatrix} C_x \\ C_y \\ C_z \end{pmatrix}`.

   Only available for *Faceforward*, *Multiply Add*, and *Wrap*.

   The label changes depending on the operation:

   - *Multiply Add* → *Addend*
   - *Faceforward* → *Reference*
   - *Wrap* → *Min*

Scale / IOR
   Scalar input.

   Only available for *Scale* (as a multiplier) and *Refract* (as the IOR ratio).


Properties
==========

Operation
   The vector math operator to be applied on the input vectors.

   .. rubric:: Vector Operations

   Basic component-wise arithmetic on vectors. Each component (X, Y, Z) is processed independently.
   Used for combining, scaling, and offsetting vector values like texture coordinates or normals.

   :Add:
      The sum of A and B.
      :math:`\begin{pmatrix} A_x + B_x \\ A_y + B_y \\ A_z + B_z \end{pmatrix}`
   :Subtract:
      The difference between A and B.
      :math:`\begin{pmatrix} A_x - B_x \\ A_y - B_y \\ A_z - B_z \end{pmatrix}`
   :Multiply:
      The component-wise product of A and B.
      :math:`\begin{pmatrix} A_x \cdot B_x \\ A_y \cdot B_y \\ A_z \cdot B_z \end{pmatrix}`
   :Divide:
      The component-wise division of A by B. Division by zero results in zero.
      :math:`\begin{pmatrix} A_x / B_x \\ A_y / B_y \\ A_z / B_z \end{pmatrix}`
   :Multiply Add:
      Component-wise combination of multiply and add: :math:`A × B + C`.
      Useful for scaling then offsetting vectors in a single node.
   :Scale:
      The result of multiplying A by the scalar *Scale* input.
      :math:`\begin{pmatrix} s \cdot A_x \\ s \cdot A_y \\ s \cdot A_z \end{pmatrix}`

   .. rubric:: Vector Products

   Operations that produce a meaningful geometric result from two vectors.
   These are essential for lighting, orientation, and 3D math calculations.

   :Dot Product:
      The dot product of A and B. The result is a single scalar value.
      :math:`A_x \cdot B_x + A_y \cdot B_y + A_z \cdot B_z`
      Positive values mean the vectors point in a similar direction; negative means opposite;
      zero means perpendicular. Commonly used for lighting (angle between surface normal and light direction)
      and to determine which side of a plane a point lies on.
   :Cross Product:
      The cross product of A and B. The result is a vector perpendicular to both inputs.
      :math:`\begin{pmatrix} A_y \cdot B_z - A_z \cdot B_y \\ A_z \cdot B_x - A_x \cdot B_z
      \\ A_x \cdot B_y - A_y \cdot B_x \end{pmatrix}`
      Used to compute surface normals, perpendicular directions, and rotation axes.

   .. rubric:: Vector Manipulation

   Operations that transform vectors in space — normalizing, aligning, reflecting, and correcting directions.

   :Normalize:
      Scales A to have a length of 1 while preserving its direction.
      If A is (0, 0, 0), the result is (0, 0, 0).
   :Absolute:
      The component-wise absolute value of A. Turns each component positive.
      Useful for making signed vector effects bidirectional.
   :Project:
      The projection of A onto B — finds the component of A that lies along the direction of B.
      Think of it as "how much of A points in B's direction." Useful for decomposing vectors
      into parallel and perpendicular components.
   :Reflect:
      Reflects the vector A around the normal B, as if bouncing off a surface.
      B does not need to be normalized. Commonly used for mirror-like effects and
      computing reflected view or light directions.
   :Refract:
      Computes the refraction vector when light passes between two media.
      Takes an incident vector A, surface normal B, and a ratio of indices of refraction (IOR),
      provided by the *Scale* input.
      The IOR is the ratio of the first medium's IOR to the second's (e.g. air-to-water = 1.0/1.33 ≈ 0.75).
   :Faceforward:
      Flips a vector A to point toward (rather than away from) a surface.
      Given a reference normal C, this ensures A points in the same general direction as C.
      Computes :math:`(B \cdot C < 0) \;?\; A : -A`.
      Commonly used to make normals always face the camera, regardless of backface orientation.

   .. rubric:: Measurement

   Operations that produce scalar measurements from vectors.

   :Distance: The distance between A and B. Outputs a scalar value.
   :Length: The length (magnitude) of A. :math:`\sqrt{A_x^2 + A_y^2 + A_z^2}`

   .. rubric:: Component Math

   Operations adapted from the regular :doc:`Math Node </render/shader_nodes/utilities/math/math>`
   that work on vectors component by component. Each component (X, Y, Z) is processed independently
   with the same operation.

   :Power: Component-wise power where A is the base and B is the exponent (:math:`A^B`).
   :Sign: Component-wise sign extraction. Each component outputs 1.0, -1.0, or 0.0.
   :Minimum: Component-wise minimum of A and B.
   :Maximum: Component-wise maximum of A and B.
   :Round: Component-wise round to nearest integer, with 0.5 rounding upward.
   :Floor: Component-wise floor (round down).
   :Ceil: Component-wise ceil (round up).
   :Fraction: Component-wise fractional part.
   :Modulo: Component-wise modulo of A by B.
   :Wrap:
      Component-wise wrap of A between the minimum (C) and maximum (B).
      Creates a repeating sawtooth pattern along each axis.
   :Snap: Component-wise round down to the nearest multiple of B.

   .. rubric:: Trigonometry

   Trigonometric functions applied component-wise to each element of the input vector.

   :Sine: The component-wise sine of A.
   :Cosine: The component-wise cosine of A.
   :Tangent: The component-wise tangent of A.


Outputs
=======

The output of the node is dynamic. It is either a vector or a scalar depending on the operator.
For instance, the *Length* operator has a scalar output while the *Add* operator has a vector output.

Vector
   Output vector (available when the operation produces a vector result).
Value
   Output value (available when the operation produces a scalar result, e.g. *Dot Product*, *Distance*, *Length*).


Examples
========

Lambertian Lighting with Dot Product
------------------------------------

.. figure:: /images/render_shader-nodes_utilities_vector_math_example-lambertian-lighting.png

      Lambertian lighting with Dot Product.

The *Dot Product* computes the cosine of the angle between two vectors,
making it the standard way to calculate how much a surface faces a light source:

- Plug the *Geometry* node's *Normal* output into Vector A.
- Plug a fixed light direction into Vector B.
- Use a *Color Ramp* to visualize the intensity gradient, then drive an *Emission* shader.
- The result ranges from 1 (surface faces the light directly) to -1 (surface faces away).


Normalizing World Position
--------------------------

.. list-table:: Without Normalize (left) vs. with Normalize (right)
   :widths: 50 50

   * - .. figure:: /images/render_shader-nodes_utilities_vector_math_example-normalize-texcoords-direct.png

          Without Normalize — Position feeds directly into the checker.

     - .. figure:: /images/render_shader-nodes_utilities_vector_math_example-normalize-texcoords-normalized.png

          With Normalize — Position is normalized first, producing a radial pattern.

*Normalize* scales a vector to length 1 while preserving its direction.
When applied to world *Position* coordinates,
it projects every point onto a unit sphere centered at the world origin:

- Place a grid plane and apply a checker texture.
- Without *Normalize*: plug the *Geometry* node's *Position* directly
  into the checker — the pattern forms a uniform grid in world space.
- With *Normalize*: route *Position* through *Normalize* first — the pattern becomes denser near
  the center and stretched toward the outer edges, as if the grid is being mapped onto the surface of a sphere.


Procedural Gradient with Distance
---------------------------------

.. figure:: /images/render_shader-nodes_utilities_vector_math_example-distance-gradient.png

      Procedural radial gradient with Distance.

*Distance* computes the Euclidean distance between two vectors, producing a scalar value:

- Plug *Geometry* → *Position* into Vector A.
  The second *Vector* input can be left at its default (0, 0, 0) to measure distance from the world origin.
- The output is 0 at the center and increases outward.
- Feed the result into a *Color Ramp* → *Emission* to produce a smooth radial gradient.
- This technique is the foundation for procedural spots, vignettes, proximity effects, and signed distance fields.


Reflecting the View Direction
-----------------------------

.. list-table:: Incoming direction (left) vs. reflected direction (right)
   :widths: 50 50

   * - .. figure:: /images/render_shader-nodes_utilities_vector_math_example-reflect-incoming.png

          Incoming direction mapped directly — near-uniform color.

     - .. figure:: /images/render_shader-nodes_utilities_vector_math_example-reflect-reflected.png

          Reflected direction — vibrant color bands from the surface normal.

*Reflect* computes the bounce direction of a ray hitting a surface, using the surface normal as the mirror axis.
The contrast between the incoming and reflected directions reveals how Reflect works:

- Place two UV Spheres side by side.
- On the left sphere: plug *Geometry* → *Incoming* through *Normalize* and
  remap it to RGB colors — the incoming direction varies smoothly across the surface,
  producing a near-uniform color.
- On the right sphere: route *Incoming* through *Reflect* (with *Normal* as B) first,
  then normalize and remap — the reflected direction changes more sharply across the surface,
  producing a varied, colorful pattern.
- The left sphere shows the unchanged viewing direction;
  the right sphere shows how Reflect redirects it based on the surface normal.
