.. index:: Geometry Nodes; Is Viewport
.. _bpy.types.GeometryNodeIsViewport:
.. --- copy below this line ---

****************
Is Viewport Node
****************

.. figure:: /images/node-types_GeometryNodeIsViewport.webp
   :align: right
   :alt: Is Viewport Node.

The *Is Viewport* node outputs whether the node tree is being evaluated for an
interactive viewport rather than for a final render.

This can be used to switch between different parts of a node tree depending on
the evaluation context. For example, computationally expensive operations can
be replaced with simpler alternatives while working interactively, while the
full-quality result is used for the final render.

In Geometry Nodes, the output is true when the node tree is evaluated for the
3D Viewport. In the Compositor, it is true when evaluated by the
:ref:`Viewport Compositor <bpy.types.View3DShading.use_compositor>`.
For a final render, the output is false.


Inputs
======

This node has no inputs.


Outputs
=======

Is Viewport
   Boolean value indicating whether the node tree is being evaluated for an
   interactive viewport.


Example
=======

.. figure:: /images/modeling_geometry-nodes_is_viewport_example.jpg

   Using *Is Viewport* to switch between lower and higher quality geometry.
