
.. index:: Geometry Nodes; Import SPZ
.. _bpy.types.GeometryNodeImportSPZ:

***************
Import SPZ Node
***************

.. figure:: /images/node-types_GeometryNodeImportSPZ.webp
   :align: right
   :alt: Import SPZ node.

The *Import SPZ* node imports 3D Gaussian Splat data from an SPZ file
and outputs it as point cloud geometry.

SPZ is a compressed file format for storing 3D Gaussian Splats, which represent
a scene using collections of three-dimensional Gaussian distributions.
Each splat contains properties such as position, rotation, scale, opacity, and color.

The imported point cloud can be processed using Geometry Nodes
and rendered using Gaussian Splat rendering.


Inputs
======

Path
   Path to the ``.spz`` file to import.


Outputs
=======

Points
   The imported point cloud geometry containing the 3D Gaussian Splats.
