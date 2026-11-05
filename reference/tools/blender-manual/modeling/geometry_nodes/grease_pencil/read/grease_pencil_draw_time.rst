.. index:: Geometry Nodes; Grease Pencil Draw Time
.. _bpy.types.GeometryNodeGreasePencilDrawTime:

****************************
Grease Pencil Draw Time Node
****************************

.. figure:: /images/node-types_GeometryNodeGreasePencilDrawTime.webp
   :align: right
   :alt: Grease Pencil Draw Time Node.

The *Grease Pencil Draw Time* node outputs timing information stored for each point
of a Grease Pencil stroke.


Inputs
======

This node has no inputs.


Outputs
=======

Creation Time
   The time at which the point was created relative to the start of the stroke.

Delta Time
   The time elapsed between the creation of the point and the previous point in the stroke.
