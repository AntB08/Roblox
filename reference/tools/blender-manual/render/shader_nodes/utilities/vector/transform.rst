.. _bpy.types.ShaderNodeVectorTransform:

*********************
Vector Transform Node
*********************

.. figure:: /images/node-types_ShaderNodeVectorTransform.webp
   :align: right
   :alt: Vector Transform node.

The *Vector Transform* node allows converting a vector, point, or normal between
world, camera, object, and light coordinate spaces.


Inputs
======

Vector Input
   Standard vector input.


Properties
==========

Type
   Specifies the input/output type.

   Vector, Point, Normal.
Convert From
   Coordinate Space to convert from:

   World, Object, Camera, Light *(EEVEE Only)*.
Convert To
   Coordinate Space to convert to:

   World, Object, Camera, Light *(EEVEE Only)*.

.. note::

   *Light* space represents the object coordinate space of the light source currently being evaluated.
   When converting from or to Light space,
   this node must be used alongside :ref:`Light Accumulation <bpy.types.ShaderNodeLightAccumulation>`.

Outputs
=======

Vector Output
   The transformed output vector.
