
*******
Options
*******

.. reference::

   :Mode:      Sculpt Mode
   :Tool:      :menuselection:`Toolbar --> Options`

.. _sculpt-options-transform_only_origin:

Transform Only -- Pivot
   Transforms the sculpt pivot without affecting the shape of the mesh
   when using sculpt transform operators.

   See :doc:`Transforming </sculpt_paint/sculpting/introduction/transforming>` for more information.

.. _bpy.types.Paint.show_low_resolution:

Display -- Fast Navigate
   For multiresolution models, shows low resolution while navigating in the viewport.

.. _bpy.types.Paint.use_sculpt_delay_updates:

Display -- Delay Viewport Updated
   Update the geometry when it enters view. This provides for faster navigation.

.. _bpy.types.Paint.use_deform_only:

Display -- Use Deform Only
   Limits the activated modifiers on the active object to Deform Modifiers, and Multiresolution.
   Constructive modifiers (like Subdivision Surface, Mirror and other) get deactivated,
   because they could give inaccurate results.

.. seealso::

   See the :ref:`Display <sculpt-paint-brush-display>` options.


Gravity
=======

.. _bpy.types.Sculpt.gravity:

Factor
   Setting the factor allows you to add gravity to your brush strokes,
   giving it a draping effect.

.. _bpy.types.Sculpt.gravity_object:

Orientation
   Using another object, the gravity can be oriented to the set object's local Z axis,
   changing the direction of the gravity.
