.. _bpy.types.ShaderNodeLightAccumulation:

******************
Light Accumulation
******************

.. figure:: /images/node-types_ShaderNodeLightAccumulation.webp
   :align: right
   :alt: Light Accumulation node.

:guilabel:`EEVEE Only`

The *Light Accumulation* node allows authoring how the Material reacts to Lights.
This can, for example, be used for toon and stylized shading, but also for complex physical effects like iridescence.

The Light inputs are evaluated once for each light affecting the surface point,
and scaled by their corresponding light :ref:`influence <render_eevee_light_settings_influence>`.
Each light contribution is calculated as:

| *(diffuse_light \* diffuse_color \* diffuse_influence) +*
| *(glossy_light \* glossy_color \* glossy_influence) +*
| *(transmission_light \* transmission_color \* transmission_influence)*

The final result is the sum of the calculated contributions from all the lights.
The accumulated result of each input is also made available in its corresponding
:ref:`Compositor Pass <render_layers_passes_light_eevee>`.

.. note::

   *Material Lighting* nodes
   (:ref:`Light Evaluation <bpy.types.ShaderNodeLightEvaluation>`,
   :ref:`Light Info <bpy.types.ShaderNodeLightInfo>`,
   :ref:`Shadow Raycast <bpy.types.ShaderNodeShadowRaycast>`,
   :ref:`Attribute (Light mode) <bpy.types.ShaderNodeAttribute>`, and
   :ref:`Vector Transform (Light space) <bpy.types.ShaderNodeVectorTransform>`)
   must be part of the *Light Accumulation* input tree, so they are evaluated once for each light.

   .. figure:: /images/render_shader-nodes_light_accumulation_correct_example.webp
      :alt: Correct Light Accumulation setup.

      Correct setup.

   .. figure:: /images/render_shader-nodes_light_accumulation_error_example.webp
      :alt: Light Accumulation setup error.

      Setup error.

Inputs
======

Diffuse Light
   Color of the diffuse light contribution.
Diffuse Color
   Color tint to scale the diffuse light contribution (albedo / base color).

Glossy Light
   Color of the glossy (specular) light contribution.
Glossy Color
   Color tint to scale the glossy light contribution (specular tint).

Transmission Light
   Color of the transmission light contribution.
Transmission Color
   Color tint to scale the transmission light contribution (transmission tint).


Properties
==========

This node has no properties.


Outputs
=======

Shader
   The accumulated result of all the lights.

Examples
========

.. figure:: /images/render_shader-nodes_light_accumulation_example.webp
   :alt: Diffuse Halftone Toon Shader.

   Diffuse Halftone Toon Shader.

.. figure:: /images/render_shader-nodes_light_accumulation_example_nodes.webp
   :alt: Diffuse Halftone Toon Shader Nodes.

   Diffuse Halftone Toon Shader setup.
