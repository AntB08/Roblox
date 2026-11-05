********************
Weight Paint Brushes
********************

.. _bpy.types.Brush.weight_brush_type:

Brush Types
===========

See :ref:`Brush Type <sculpt-tool-settings-brush-type>`.

Available brush types are listed below, together with brushes from the
*Essentials* asset library that use them.

:Draw:
   Paints weight onto the affected vertices.

   Brush Settings:

   - :ref:`bpy.types.Brush.blend`
   - :ref:`bpy.types.Brush.weight`
   - :ref:`bpy.types.Brush.size`
   - :ref:`bpy.types.Brush.strength`


   Brushes: Set Weight, Add Weight

:Blur:
   Smooths the weights of adjacent vertices by reducing differences between them.
   Strength controls how strongly the weights are smoothed.

   Brush Settings:

   - :ref:`bpy.types.Brush.size`
   - :ref:`bpy.types.Brush.strength`

   Brushes: Blur

:Average:
   Paints the average weight of the vertices under the brush.

   Brush Settings:

   - :ref:`bpy.types.Brush.size`
   - :ref:`bpy.types.Brush.strength`

   Brushes: Average

:Smear:
   Smudges weights by sampling them from the initial brush position and
   dragging them across the surface.

   Brush Settings:

   - :ref:`bpy.types.Brush.size`
   - :ref:`bpy.types.Brush.strength`

   Brushes: Smear


Brush Assets
============

Add Weight
----------

Adds weight to vertices with a relatively low strength.
Uses the *Add* blend mode and accumulation, allowing repeated brush strokes
to progressively increase the weight.


Average
-------

Smooths variations in weight by painting the average weight of the vertices
under the brush.


Blur
----

Smooths the weights of adjacent vertices, reducing differences between them.
Uses accumulation with a low strength for gradual smoothing.


Set Weight
----------

Paints the specified weight onto vertices using the *Mix* blend mode.
Uses a constant falloff curve so the weight is applied uniformly within
the main area of the brush.


Smear
-----

Smudges existing weights by sampling them from the initial brush position
and dragging them across the surface.
