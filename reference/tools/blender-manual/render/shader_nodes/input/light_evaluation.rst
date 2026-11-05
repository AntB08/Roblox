.. _bpy.types.ShaderNodeLightEvaluation:

*********************
Light Evaluation Node
*********************

:guilabel:`EEVEE Only`

.. figure:: /images/node-types_ShaderNodeLightEvaluation.webp
   :align: right
   :alt: Light Evaluation Node.

The *Light Evaluation* node computes shading reflection factors, direction, distance,
and attenuation masks for the light source currently being evaluated.

.. note::

   This node must be used alongside :ref:`Light Accumulation <bpy.types.ShaderNodeLightAccumulation>`.

Inputs
======

Position
   Evaluation position. Defaults to the shading surface position.
Normal
   Evaluation normal. Defaults to the geometry shading normal.
Roughness
   Surface roughness value. Used to compute the *Factor* output when *Mode* is set to *Glossy*.

Properties
==========

Mode
   Selects the shading model used to compute the *Factor* output (e.g. *Diffuse* or *Glossy*).

Outputs
=======

Factor
   Calculated shading reflection factor (diffuse or glossy depending on *Mode*), scaled by PI.

Mask
   | *Point & Area lights:* Smooth cutoff mask applied at the light boundary distance.
   | *Spot lights:* Cutoff mask combined with spot cone angular attenuation.
   | *Sun lights:* 1.0 (sun lights do not attenuate by distance or cone angle).

Direction
   | *Point, Spot & Area lights:* Normalized unit vector pointing from the evaluation position toward the light position.
   | *Sun lights:* Reverse direction vector of the sun light rays (``Sun direction * -1.0``).

Distance
   | *Point, Spot & Area lights:* Distance from the evaluation position to the light position.
   | *Sun lights:* 1.0.
