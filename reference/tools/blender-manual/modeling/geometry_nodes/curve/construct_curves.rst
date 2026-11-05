
.. index:: Geometry Nodes; Construct Curves
.. _bpy.types.GeometryNodeConstructCurves:

*********************
Construct Curves Node
*********************

.. figure:: /images/node-types_GeometryNodeConstructCurves.webp
   :align: right
   :alt: Construct Curves node.

The *Construct Curves* node creates curves geometry from a list of point positions
and curve topology information.

Unlike nodes that generate curves from predefined shapes, this node allows the
number of curves, their point counts, and their positions to be defined explicitly.
This is useful for constructing procedural curves from externally generated data
or manipulating curve topology.

The topology is defined using *curve offsets*, which specify where each curve
begins within the combined list of points.


Inputs
======

Positions
   A list of 3D vectors defining the positions of all points in the curves.
   Points are ordered sequentially, with the points of each curve stored together.

Curve Offsets
   A list of integer offsets defining the start index of each curve in the *Positions* list.

   The offsets must follow these rules:

   - The first offset must be 0.
   - Each subsequent offset must be greater than the previous one.
   - The final offset must equal the total number of points.
   - The number of offsets must be one greater than the number of curves.

   The number of points in each curve is determined by the difference between
   consecutive offsets.

   For example, the offsets ``[0, 3, 4, 8]`` define three curves:

   - The first curve contains points 0 through 2.
   - The second curve contains point 3.
   - The third curve contains points 4 through 7.

   The offsets can also be calculated as the prefix sum of the curve point counts:

   .. list-table::
      :header-rows: 1

      * - Curve Point Counts
        - Curve Offsets
      * - ``[3, 1, 4]``
        - ``[0, 3, 4, 8]``


Outputs
=======

Curves
   The resulting curves geometry constructed from the supplied positions
   and curve offsets.
