.. _bpy.types.ShaderNodeMixShader:

**********
Mix Shader
**********

.. figure:: /images/node-types_ShaderNodeMixShader.webp
   :align: right
   :alt: Mix Shader node.

The *Mix Shader* node blends between two shaders based on a *Factor* value.
When *Factor* is 0.0, only the first shader is visible; at 1.0, only the second.
Values between produce a blend of both.

This node is the central hub for most material layering workflows —
it is used with the :doc:`Fresnel </render/shader_nodes/input/fresnel>` or
:doc:`Layer Weight </render/shader_nodes/input/layer_weight>` nodes to create
angle-dependent materials (plastic coatings, glass, edge effects), with textures
to mix surface details, or with vertex colors and masks for game-ready assets.

For mixing colors rather than shaders, use the
:doc:`Mix Node </render/shader_nodes/color/mix>` instead.


Inputs
======

Shader
   Standard shader input. The node provides two shader inputs:
   the top socket is the first shader (visible when *Factor* is 0.0),
   the bottom socket is the second shader (visible when *Factor* is 1.0).
Factor
   Blend weight in the range 0.0 to 1.0. Controls the visibility of each shader:
   0.0 shows only the first shader, 1.0 shows only the second.
   Typically driven by a Fresnel, Layer Weight, texture, or vertex color node.


Properties
==========

This node has no properties.


Outputs
=======

Shader
   Standard shader output. Connect this to the *Surface* input of a *Material Output* node.


Examples
========

.. figure:: /images/render_shader-nodes_shader_mix_example.jpg

   A mix of a glossy and a diffuse shader makes a nice ceramic material.

Common Factor Sources
---------------------

The *Factor* input can be driven by many different nodes, each producing a different visual result:

- :doc:`Fresnel </render/shader_nodes/input/fresnel>` — creates angle-dependent mixing
  where the second shader dominates at grazing angles. Ideal for glossy coatings and glass.
- :doc:`Layer Weight </render/shader_nodes/input/layer_weight>` — offers both Fresnel
  (IOR-based) and Facing (geometric) weight outputs with a simpler 0.0–1.0 input range.
- *Image Texture* or *Noise Texture* — drives the mix with grayscale values,
  creating textured transitions or procedural wear effects.
- *Vertex Color* or *Attribute* — enables per-vertex control of material blending,
  commonly used in game assets for terrain blending or damage maps.

Mixing shaders can increase render noise compared to a single shader
because Cycles uses the *Factor* to probabilistically select which shader
to evaluate for each ray. For simple color blending (e.g. combining two
colors for the same roughness), use a :doc:`Mix Node </render/shader_nodes/color/mix>`
to blend colors before feeding them into a single BSDF — this is often more
efficient and produces less noise.
