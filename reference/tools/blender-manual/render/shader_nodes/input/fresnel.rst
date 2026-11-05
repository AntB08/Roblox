.. _bpy.types.ShaderNodeFresnel:

************
Fresnel Node
************

.. figure:: /images/node-types_ShaderNodeFresnel.webp
   :align: right
   :alt: Fresnel Node.

The *Fresnel* (or *Dielectric Fresnel*) node computes the proportion of light reflected
off a surface at a given viewing angle, based on the index of refraction (:term:`IOR`).
At grazing angles, more light is reflected than at a direct view —
matching real-world behavior where windows and water appear more reflective at the edges.
The output weight ranges from 0.0 to 1.0 and is used as a blend factor in a *Mix Shader* node.

This node provides a direct IOR input, which determines the strength of the Fresnel effect.
For cases where adjusting the IOR is not critical or where a simpler 0.0–1.0 value range is preferred,
consider the *Fresnel* output of the :doc:`Layer Weight Node </render/shader_nodes/input/layer_weight>`,
which maps a *Blend* value of 0.5 to an IOR of 1.5 and offers a more convenient input range.

The most common use is mixing between two shaders — for example, a glossy refraction shader
and a glossy reflection shader to create glass, or a diffuse base shader and a glossy coating
shader to create plastic. At grazing angles the glossy coating or reflection dominates;
straight-on, the diffuse base or refraction shows through.


Inputs
======

IOR
   Index of refraction (:term:`IOR`) of the material. Controls how strong the Fresnel
   effect appears. Common IOR values:

   - 1.00 : Air
   - 1.33 : Water
   - 1.50 : Typical glass / standard plastic
   - 1.52 : Window glass (float glass)
   - 1.77 : Sapphire
   - 2.42 : Diamond

   Higher values produce stronger reflection at edges.
   Lower values make the reflection visible over a wider range of viewing angles.
Normal
   Optional input for a bump or normal map. When connected, the surface angle
   at each point is modified by the bump/normal detail before computing the Fresnel weight.
   This makes the reflection pattern respond to surface texture, adding realism
   to materials with visible surface detail.


Properties
==========

This node has no properties.


Outputs
=======

Factor
   Fresnel weight in the range 0.0 to 1.0. At normal incidence (head-on view)
   the output reaches its minimum; at grazing angles it reaches 1.0 (maximum reflection).
   For a typical IOR of 1.5, the minimum value at normal incidence is approximately 0.04,
   corresponding to the ~4% reflection that even glass has when viewed straight-on.
   Use this as the *Fac* input of a *Mix Shader* node to blend between two shaders.


Examples
========

Glass Material (Refraction + Reflection)
----------------------------------------

.. figure:: /images/render_shader-nodes_input_fresnel_example-glass.png

   Glass material: the checkerboard floor is visible through the center (refraction),
   while the edges show strong reflection.

A classic glass setup using the Fresnel node:

- Connect the *Fresnel* node's *Factor* to the *Fac* of a *Mix Shader* node.
- Connect a *Glossy BSDF* (with roughness near 0.0) to the first shader input (refraction).
- Connect a second *Glossy BSDF* (also low roughness) to the second shader input (reflection).
- Set *IOR* to 1.5 for typical glass. At grazing angles, the reflection dominates;
  looking straight through, the refraction shows.
- Note: in modern Blender, a *Glass BSDF* or *Principled BSDF* with *Transmission*
  handles glass more conveniently. This manual setup is shown to illustrate
  how Fresnel-driven mixing works and can be applied to custom effects.

Plastic with Glossy Coating
---------------------------

.. figure:: /images/render_shader-nodes_input_fresnel_example-plastic.png

   Plastic material: the diffuse base color shows straight-on, while the glossy
   coating reflects the environment at the edges.

Create plastic or clear-coated materials by mixing a diffuse base with a glossy top layer:

- Connect the *Factor* output to the *Fac* of a *Mix Shader* node.
- Connect a *Diffuse BSDF* to the first shader input (the base material).
- Connect a *Glossy BSDF* to the second shader input (the coating).
- Set *IOR* to 1.5 for standard plastic. At edges, the glossy coating reflects the environment;
  straight-on, the diffuse color shows through.
- Adjust the *Glossy BSDF* roughness to control the sharpness of reflections.

Environment Map Reflection
--------------------------

.. figure:: /images/render_shader-nodes_input_fresnel_example-environment.png

   Environment map reflection: the checker pattern of the environment texture is
   reflected at the edges of the sphere, while the center stays diffuse.

Use the Fresnel weight to control the strength of an environment map:

- Connect the *Factor* output to the *Fac* of a *Mix Shader* node.
- Connect a *Diffuse BSDF* to the first shader input.
- Connect a *Glossy BSDF* (with low roughness) to the second shader input,
  with an *Environment Texture* driving its color.
- For a simple non-physical glow, an *Emission* shader can also be used.
- Lower the *IOR* (e.g. 0.9) to widen the reflective band and make the
  environment map more prominent across the surface.
- At edges, the environment is strongly visible, simulating a reflective coating.
- This creates a non-destructive way to add edge reflections without altering
  the base material.
