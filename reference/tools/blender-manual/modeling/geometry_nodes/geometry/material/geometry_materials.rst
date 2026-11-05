.. index:: Geometry Nodes; Geometry Materials
.. _bpy.types.GeometryNodeGeometryMaterials:

***********************
Geometry Materials Node
***********************

.. figure:: /images/node-types_GeometryNodeGeometryMaterials.webp
   :align: right
   :alt: Geometry Materials Node.

The *Geometry Materials* node outputs a list of the materials used by a geometry
component. The list corresponds to the material slots stored on the selected
component type.

This can be used to access the materials assigned to geometry and process them
as a list, for example to retrieve individual materials or iterate over all
materials used by a component.


Inputs
======

Geometry
   The geometry containing the materials to retrieve.

Component Type
   The type of geometry component from which to retrieve the material list.


Outputs
=======

Materials
   A list containing the materials used by the selected geometry component.
