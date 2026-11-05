.. index:: Geometry Nodes; Mesh to Volume
.. _bpy.types.GeometryNodeMeshToVolume:

*******************
Mesh to Volume Node
*******************

.. figure:: /images/node-types_GeometryNodeMeshToVolume.webp
   :align: right
   :alt: Mesh to Volume node.

The *Mesh to Volume* node converts a mesh into a fog volume by generating a
scalar grid named ``density``. Voxels inside the mesh are assigned the specified
density value, while voxels outside remain empty.


Inputs
======

Mesh
   The mesh geometry used to generate the volume.

Density
   Value of voxels inside the generated fog volume.

Resolution Mode
   How the voxel size is specified.

   :Amount:
      Specify the approximate number of voxels along the diagonal.
   :Size:
      Specify the voxel side length. It is recommended to be careful when tweaking this value,
      because small changes can have a large effect on the processing time.

Voxel Amount :guilabel:`Amount`
   Specify the approximate number of voxels along the diagonal.

Voxel Size :guilabel:`Size`
   Specify the voxel side length.

Interior Band Width
   The maximum distance of the included voxels to the surface on the inside of the mesh.


Outputs
=======

Volume
   The generated volume geometry containing a ``density`` grid.
