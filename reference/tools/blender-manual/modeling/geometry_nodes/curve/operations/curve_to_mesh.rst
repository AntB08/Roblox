.. index:: Geometry Nodes; Curve to Mesh
.. _bpy.types.GeometryNodeCurveToMesh:

******************
Curve to Mesh Node
******************

.. figure:: /images/node-types_GeometryNodeCurveToMesh.webp
   :align: right
   :alt: The Curve to Mesh node.

The *Curve to Mesh* node converts the splines of a curve into a mesh.
A profile curve can optionally be provided to define the cross-section of the
generated mesh. Without a profile, each spline is converted into a chain of edges.

Attributes from the input curves are transferred to the resulting mesh.
Attributes that are built-in on meshes but not curves, such as ``sharp_face``,
are transferred to the appropriate mesh domain.

.. tip::

   The output mesh can have :ref:`sharp edges <geometry-nodes_builtin-attributes>`
   generated automatically from the profile curve. If a spline in the profile
   curve is a Bézier spline and any of its control points use *Free* or *Vector*
   handles, the corresponding edges of the generated mesh are marked sharp.


Inputs
======

Curve
   The curve geometry to convert to a mesh.
   Non-curve components are ignored.

Profile Curve
   The cross-section to extrude along each spline of the input *Curve*.

   When no profile is provided, each spline is converted into a chain of edges.

Scale
   Scales the profile at each point of the input curve.

Fill Caps
   Fills the ends of the generated mesh with n-gons when the corresponding
   profile spline is cyclic.

   The resulting mesh is :term:`Manifold`, with each cap connected directly to
   the existing boundary edges.


Miter Scale
-----------

Controls how the profile is scaled around sharp turns in the input curve.
The profile is stretched along the direction of the turn to maintain a more
consistent apparent width around corners.

Limit
   Limits the amount of miter scaling at sharp corners. When the corner angle
   reaches the specified limit, the scale stops increasing, preventing
   excessively long geometry at very sharp turns.


Outputs
=======

Mesh
   The generated mesh geometry.
