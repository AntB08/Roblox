.. index:: Geometry Nodes; Join Geometry
.. _bpy.types.GeometryNodeJoinGeometry:

******************
Join Geometry Node
******************

The *Join Geometry* node merges separately generated geometries into a single one.
If the geometry inputs contain different types of data, the output will also contain different data types.

.. figure:: /images/node-types_GeometryNodeJoinGeometry.webp
   :alt: Join Geometry node.

.. note::

   The node cannot handle the case when more than one geometry input has a volume component.


Materials
=========

When multiple mesh inputs contain different materials, the material slots from each mesh geometry
are merged so that the output mesh will contain all the input materials.


.. editors note: keep up to date with :doc:`/modeling/geometry_nodes/instances/realize_instances`

Attributes
==========

When merging attributes from multiple geometry inputs, the highest complexity data type is chosen
for the output attribute. For example, if a ``weight`` attribute is a Boolean on one geometry input
and a vector on another, the ``weight`` attribute on the output geometry will use the vector data type.

.. note::

   Vertex groups are preserved when realizing instances or joining geometries.
   If the domain and type propagation rules above result with the vertex domain and float type,
   then an attribute will be a vertex group on the output mesh.

In the case where some geometry inputs contain an attribute that the other geometry inputs don't,
that attribute is :ref:`default-intialized <default-initialization>` on all elements of
the geometry inputs that don't have that attribute.
This applies whether that attribute is named or anonymous.


Indices
=======

When merging multiple geometry inputs, the indices of the elements of each geometry input are not
reordered when merging.

The indices of the elements of the geometry inputs are merged in the order of the geometry inputs
of the multi-input socket. For example, if there are 3 geometry inputs going into the multi-input
socket with indices ranging from 0-9 each, then after merging, the indices of the top geometry
input range from 0-9, the indices of the middle geometry input range from 10-19 and the indices of
the bottom geometry input range from 20-29. As the indices of the elements of the geometry inputs
are not reordered when merging, the indices of the top geometry input are the same as before merging
while the the indices of the middle and bottom geometry input simply have offsets added to their
indices when compared to before merging.

The same behavior applies to material indices.


Indices of Instanced Geometries
-------------------------------

When merging multiple geometry inputs that contain instances of geometries, The indices of the instanced
geometries may be reordered when merging. This means that while the order of the indices of the instances
are guaranteed to be the same as before merging, the order of the indices of the geometries that are
being instanced may be different than before merging.

The same behavior applies to material indices.


Inputs
======

Geometry
   Geometry that will be joined. Multiple inputs are allowed.
   When the node is muted, only the first link will be passed through.


Output
======

Geometry
   Standard geometry output.
