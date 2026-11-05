.. _bpy.types.ShaderNodeShadowRaycast:

*******************
Shadow Raycast Node
*******************

:guilabel:`EEVEE Only`

.. figure:: /images/node-types_ShaderNodeShadowRaycast.webp
   :align: right
   :alt: Shadow Raycast Node.

The *Shadow Raycast* node provides a shadow mask for the light source currently being evaluated.

.. note::

   This node must be used alongside :ref:`Light Accumulation <bpy.types.ShaderNodeLightAccumulation>`.

Inputs
======

Position
   Evaluation position. Defaults to the shading surface position.
   If a custom position offsets the evaluation point beyond the object's bounding box,
   the material's :ref:`Max Distance <bpy.types.Material.max_vertex_displacement>` setting must be
   increased accordingly to prevent missing shadows artifacts.
Softness
   Shadow softness scaling factor. A value of 0.0 forces sharp shadows regardless of the light size,
   while 1.0 matches the physically correct shadow penumbra size.

Properties
==========

This node has no properties.


Outputs
=======

Color
   The calculated shadow mask (a grayscale color value where 1.0 represents unoccluded light and 0.0
   represents fully occluded shadow).
