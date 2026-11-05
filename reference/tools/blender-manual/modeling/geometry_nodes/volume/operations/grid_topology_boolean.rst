.. index:: Geometry Nodes; Grid Topology Boolean
.. _bpy.types.GeometryNodeGridTopologyBoolean:

**************************
Grid Topology Boolean Node
**************************

.. figure:: /images/node-types_GeometryNodeGridTopologyBoolean.webp
   :align: right
   :alt: Grid Topology Boolean node.

The *Grid Topology Boolean* node combines the topology of active voxels and tiles of two or more
grids. The result is a grid with active voxels where at least one input grid has an active voxel,
depending on the *operation*.

The boolean combination happens in index space. All input grids should have the same grid transform,
otherwise the node will show a warning.

Conceptually this node is similar to the
:doc:`SDF Grid Boolean node </modeling/geometry_nodes/volume/operations/sdf_grid_boolean>`. Unlike
the SDF node it only takes active voxel state into account instead of signed distance values.


Inputs
======

Grid 1
   The first input grid for boolean combination.
   The output grid uses voxel values of this grid, or its background value.

Grid 2
   The secondary input grids that are combined with *Grid 1*.


Properties
==========

Data Type
   The data type stored in the grid (e.g. *Float*, *Integer*, *Boolean*, *Vector*).
   This determines the type of the *Grid* output.

Operation
   The boolean operation to perform between the input grids:

   :Intersection:
      Creates active voxels where all input grids have active voxels.
      The voxel value is the value of the first input grid.
   :Union:
      Creates active voxels where any input grid has an active voxel.
      The voxel value is the value of the first input grid, or its background value if the voxel is
      inactive in the first input grid.
   :Difference:
      Creates active voxel where the first input grid is active but none of the secondary input
      grids are active.
      The voxel value is the value of the first input grid.


Outputs
=======

Grid
   The resulting grid after the boolean operation is applied.
   The grid values are the same as in the first input grid, using the background value for any
   newly added voxels in *Union* mode.
