
.. index:: Geometry Nodes; Get Grid Names
.. _bpy.types.GeometryNodeGetGridNames:

*******************
Get Grid Names Node
*******************

.. figure:: /images/node-types_GeometryNodeGetGridNames.webp
   :align: right
   :alt: Get Grid Names node.

The *Get Grid Names* node retrieves the names of all grids stored in a volume
and outputs them as a list of strings.

A volume can contain multiple grids, each storing different types of volumetric data,
such as density, temperature, or velocity. This node can be used to inspect the
available grids or dynamically access them by name.

The grid names are returned in alphabetical order, matching the order used by OpenVDB
when loading VDB files.


Inputs
======

Volume
   Volume geometry containing the grids to retrieve names from.


Outputs
=======

Names
   A list of strings containing the names of all grids in the volume,
   sorted alphabetically.
