
.. index:: Geometry Nodes; Set Point Cloud Type
.. _bpy.types.GeometryNodePointsSetType:

*************************
Set Point Cloud Type Node
*************************

.. figure:: /images/node-types_GeometryNodeSetPointRadius.webp
   :align: right
   :alt: Set Point Cloud Type node.

The *Set Point Cloud Type* node changes the representation of a point cloud between
regular points and 3D Gaussian Splats.

Regular point clouds represent points using their positions and radii, while
3D Gaussian Splats use additional attributes to define the shape and orientation
of each point as a three-dimensional Gaussian distribution.

This node can be used to prepare point cloud geometry for different workflows,
including procedural point manipulation and Gaussian Splat rendering.


Inputs
======

Points
   Point cloud geometry to change the type of.

Type
   The representation to use for the point cloud.

   :Points:
      A regular point cloud consisting of points with positions and radii.
   :3D Gaussian Splat:
      A point cloud using the original 3D Gaussian Splat representation,
      where points are represented by three-dimensional Gaussian distributions.


Outputs
=======

Points
   The resulting point cloud geometry with the specified type.
