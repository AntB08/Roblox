************
Transforming
************

Sculpt Mode supports :doc:`Move, Rotate, and Scale </sculpt_paint/sculpting/tools/transforms>`
operators for transforming the mesh directly, similar to Object and Edit Modes.
These transformations can be used to reposition, rotate, or resize parts of a sculpt
without relying on individual brush strokes.

Unlike other modes, Sculpt Mode uses a separate :term:`Pivot Point`
that can be positioned independently of the object's origin.
The sculpt pivot moves together with the transformed geometry,
allowing transformations to be centered around specific areas of the sculpt,
such as joints or other features.


Sculpt Pivot
============

The sculpt pivot determines the center of rotation and scaling transformations.
When entering Sculpt Mode, the pivot is reset to the object's origin.
It can then be repositioned independently without changing the object origin or mesh geometry.

To position the pivot manually, use :kbd:`Shift-RMB` to place it on the mesh surface
under the cursor. Alternatively, the :ref:`Set Pivot <bpy.ops.sculpt.set_pivot_position>`
menu provides options to position the pivot at the object origin, active vertex,
average position of unmasked vertices, or mask boundary.

The pivot can also be positioned automatically using
:ref:`Mask Expand <bpy.ops.sculpt.mask_expand>`.
When expanding a mask, the pivot can be positioned at the mask boundary.
This is particularly useful for rotating or repositioning
parts of a sculpt, such as limbs.

.. tip::

   - Use :kbd:`Shift-RMB` to quickly reposition the pivot before applying a transformation.
   - The :ref:`Transform Only -- Pivot <sculpt-options-transform_only_origin>` option
     allows transforming the sculpt pivot independently without affecting the mesh geometry.


Transform Gizmos
================

The :doc:`viewport gizmos </editors/3dview/display/gizmo>` can be enabled
to display transform controls without keeping a transform operator active.

These gizmos provide direct access to translation, rotation, and scaling
around the sculpt pivot, making it easier to adjust the shape interactively.

.. note::

   Transform gizmos can sometimes obstruct parts of the mesh and prevent sculpting
   on the surface beneath them. Reposition the pivot to move the gizmo out of the way.


Sculpt Brushes
==============

In addition to the transform operators, Sculpt Mode provides brushes that
deform the mesh using more localized or specialized transformations.

:doc:`Pose </sculpt_paint/sculpting/brushes/pose>`
   Rotates, translates, or scales parts of the mesh using a pose-like deformation.
   Useful for adjusting limbs and other articulated shapes.

:doc:`Boundary </sculpt_paint/sculpting/brushes/boundary>`
   Deforms the mesh relative to a boundary, allowing nearby geometry
   to be bent, expanded, or otherwise transformed.

:doc:`Elastic Deform </sculpt_paint/sculpting/brushes/elastic_deform>`
   Deforms the mesh with an elastic falloff, producing smooth transformations
   that influence surrounding geometry.
