.. index:: Geometry Nodes; Rasterize Points
.. _bpy.types.GeometryNodeRasterizePoints:
.. --- copy below this line ---

*********************
Rasterize Points Node
*********************

.. figure:: /images/node-types_GeometryNodeRasterizePoints.webp
   :align: right
   :alt: Rasterize Points node.

The *Rasterize Points* node converts point data into volume grids by accumulating
point values in nearby voxels using a weighted sum.

Each point contributes to surrounding voxels according to a weighting function,
also called a *kernel*. The kernel determines how far each point's influence
extends and how its value is distributed across the grid.

This is the inverse operation of the :doc:`Sample Grid </modeling/geometry_nodes/volume/sample/sample_grid>`
node, which samples values from a grid at specified positions.

The node can generate multiple grids from different input fields,
allowing several attributes to be transferred to a volume simultaneously.


Inputs
======

Points
   The geometry containing the points to rasterize.

Grid Transform Mode
   Determines how the voxel grid is positioned and scaled.

   :Voxel Size:
      Defines the grid resolution using a uniform voxel size.

   :Matrix:
      Uses a transformation matrix to define the position, orientation, and scale
      of the voxel grid.

Voxel Size
   Size of each voxel in the generated grids.
   Smaller values provide higher resolution but require more memory and processing.

   Only available when the *Grid Transform Mode* is set to *Voxel Size*.

Matrix
   Transformation matrix defining the position, orientation, and scale of the voxel grid.

   Only available when the *Grid Transform Mode* is set to *Matrix*.

Kernel Type
   The weighting function used to distribute each point's value across nearby voxels.

   :Constant:
      Assigns each point's full value to its nearest voxel.
   :Linear:
      Distributes values using linear weights across two voxels along each axis.
   :Quadratic B-Spline:
      Distributes values across three voxels along each axis using a quadratic
      weighting function.
   :Cubic B-Spline:
      Distributes values across four voxels along each axis using a cubic
      weighting function.

Position
   The position of each point used to calculate its influence on the grid.
   This input can be used to rasterize points at positions other than their
   original coordinates.

Grid items can be added by dragging a scalar or vector socket onto the empty
socket below the *Position* input.


Properties
==========

.. _bpy.types.NodeGeometryRasterizePointsItem:

Grid Items
----------

The node supports multiple grid items, each with a corresponding input field.
This allows different values to be rasterized using the same points,
grid transform, and weighting function.

Type
   The data type of the values to rasterize.

   :Scalar:
      Rasterizes floating-point values into a scalar grid.
   :Vector:
      Rasterizes three-dimensional vector values into a vector grid.


Outputs
=======

Each grid item creates a corresponding output socket containing a volume grid
generated from its input field.

The output grid uses the data type specified by the grid item and stores the
weighted sum of values contributed by nearby points.
