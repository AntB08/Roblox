.. _bpy.types.ShaderNodeLayerWeight:

*****************
Layer Weight Node
*****************

.. figure:: /images/node-types_ShaderNodeLayerWeight.webp
   :align: right
   :alt: Layer Weight Node.

The *Layer Weight* node outputs weight values used for blending between two shaders
via the *Mix Shader* node. It provides two types of angle-dependent weights that control
how much of each shader is visible at different viewing angles.

It is most commonly used to create realistic materials where the surface appearance
changes depending on whether you are looking at it head-on or at a glancing angle —
such as a glossy coating over a rough base, or edge highlights on a diffuse surface.


Inputs
======

Blend
   Controls the spread and sharpness of the transition. The default value of
   0.5 is a good starting point. Higher values sharpen the edge, lower values
   produce a wider, more gradual blend.
   For the *Fresnel* output, *Blend* maps to the index of refraction:
   0.5 corresponds to IOR 1.5 (glass/plastic), lower values approximate lower
   IOR (weaker reflection), higher values produce stronger, mirror-like reflection.
Normal
   Optional input for a bump or normal map. When connected, the surface angle
   at each point is modified by the bump/normal detail before computing the weight.
   This makes the weight respond to surface texture — raised areas and depressions
   produce different blending values, adding realism to layered materials.


Properties
==========

This node has no properties.


Outputs
=======

Fresnel
   Dielectric Fresnel weight in the range 0.0 to 1.0. At 0.0 the surface is
   viewed head-on (no Fresnel effect); at 1.0 the surface is at a grazing angle
   (maximum reflection). Use this as the *Fac* input of a *Mix Shader* node.

   Common use: mix a diffuse base shader with a glossy coating shader
   to create plastic or clear-coated materials.

Facing
   Geometric angle weight in the range 0.0 to 1.0. Outputs 1.0 when the surface
   directly faces the viewer, and 0.0 when viewed at a grazing angle.
   Unlike *Fresnel*, this output is not affected by the index of refraction —
   it is purely based on surface orientation.

   Common use: create edge glow or rim light effects by placing an *Emission*
   shader in the first slot of a *Mix Shader* node (since Fac = 0 at edges
   shows the first shader), with a diffuse surface in the second slot.

.. tip::

   Use *Fresnel* when you need physically accurate reflection (plastic, glass, coated).
   Use *Facing* for artistic control or when IOR-based behavior is not desired.


Examples
========

Glossy Coating over Diffuse (Fresnel)
-------------------------------------

.. figure:: /images/render_shader-nodes_input_layer-weight_example-coating.png

   Glossy coating over a diffuse base: the *Diffuse BSDF* shows through the center
   while the *Glossy BSDF* dominates the edges.

A classic setup for plastic or clear-coated materials:

- Connect the *Fresnel* output to the *Fac* input of a *Mix Shader* node.
- Connect a *Diffuse BSDF* to the first shader input (the base).
- Connect a *Glossy BSDF* to the second shader input (the coating).
- Adjust *Blend* to control how strong the reflection appears at edges.
- At grazing angles, the glossy coating dominates; straight-on, the diffuse base shows through.


Edge Glow with Emission (Facing)
--------------------------------

.. figure:: /images/render_shader-nodes_input_layer-weight_example-edge-glow.png

   Edge glow effect: the *Diffuse BSDF* is visible at the center while the *Emission*
   shader creates a bright rim light at the edges.

Since *Facing* outputs 1.0 at the center and 0.0 at edges,
place the emission in the first shader slot of the *Mix Shader* node:

- Connect the *Facing* output to the *Fac* input of a *Mix Shader* node.
- Connect an *Emission* shader to the first shader input.
- Connect a *Diffuse BSDF* (or *Principled BSDF*) to the second shader input.
- At the center (Fac ≈ 1.0), the second shader (diffuse) dominates.
- At the edges (Fac ≈ 0.0), the first shader (emission) dominates,
  creating a rim light effect.

Alternatively, use the *Fresnel* output for a more intuitive setup:
connect *Diffuse* to the first slot, *Emission* to the second slot —
*Fresnel* naturally puts the weight at the edges.
Adjust *Blend* to control the width of the glow band.


Bump/Normal Map Interaction
---------------------------

.. figure:: /images/render_shader-nodes_input_layer-weight_example-bump.png

   Connecting a *Bump* node to the *Normal* input of *Layer Weight* makes the
   Fresnel/Facing weight respond to surface texture. The reflection becomes
   irregular, following the bumps and depressions instead of a smooth gradient.

To make the weight respond to surface texture:

- Connect a *Noise Texture* to a *Bump* node.
- Connect the *Bump* node output to the *Normal* input of the *Layer Weight* node.
- Now the *Fresnel* (or *Facing*) weight varies across the bumps —
  raised areas and depressions produce different mixing values,
  giving the material surface a more realistic, detailed appearance.
