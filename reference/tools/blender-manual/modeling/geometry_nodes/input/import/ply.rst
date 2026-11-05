.. index:: Geometry Nodes; Import PLY
.. _bpy.types.GeometryNodeImportPLY:

***************
Import PLY Node
***************

.. figure:: /images/node-types_GeometryNodeImportPLY.webp
   :align: right
   :alt: Import PLY node.

The *Import PLY* node imports geometry from a ``.ply`` (Polygon File Format or Stanford Triangle Format) file.

PLY files are commonly used to store geometry from 3D scanning and modeling software.
They can contain mesh data with attributes such as vertex colors and normals,
as well as Gaussian splats used for rendering captured scenes.

The node automatically detects the type of geometry stored in the file,
importing it as either a mesh or a :ref:`point cloud <point_cloud-index>`
containing Gaussian splats.
This allows both types of PLY files to be used in Geometry Nodes without additional setup.

.. seealso::

   :ref:`PLY Import Operator <bpy.ops.wm.ply_import>`


Inputs
======

Path
   The path to the ``.ply`` file to import.


Outputs
=======

Geometry
   The geometry imported from the PLY file.
   The resulting geometry type depends on the file contents.
