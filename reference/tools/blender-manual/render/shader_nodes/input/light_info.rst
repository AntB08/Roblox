.. _bpy.types.ShaderNodeLightInfo:

***************
Light Info Node
***************

:guilabel:`EEVEE Only`

.. figure:: /images/node-types_ShaderNodeLightInfo.webp
   :align: right
   :alt: Light Info Node.

The *Light Info* node outputs basic properties (color, power,
and position) of the light source currently being evaluated.

.. note::
   This node must be used alongside :ref:`Light Accumulation <bpy.types.ShaderNodeLightAccumulation>`.

Inputs
======

This node has no inputs.


Properties
==========

This node has no properties.


Outputs
=======

Color
   The color of the evaluated light source, matching the *Color* setting in :menuselection:`Properties --> Light`.
Power
   The radiant intensity of the evaluated light source, divided by PI.
Position
   The world-space position of the evaluated light source.
