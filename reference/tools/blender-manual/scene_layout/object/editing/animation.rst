
*********
Animation
*********

.. _bpy.ops.anim.rotation_mode_convert:

Convert Rotation Mode
=====================

.. reference::

   :Mode:      Object Mode, Pose Mode
   :Menu:      :menuselection:`Object --> Animation --> Convert Rotation Mode`,
               :menuselection:`Pose --> Animation --> Convert Rotation Mode`
   :Shortcut:  :kbd:`Ctrl-R` :guilabel:`Pose Mode`

Converts the rotation animation of the selected objects or pose bones from one
:doc:`rotation mode </advanced/appendices/rotations>`
to another while preserving the evaluated orientation over time.

Unlike simply changing the :ref:`rotation mode <bpy.types.Object.rotation_mode>` property,
this operator converts the existing animation curves so that the animated motion
is maintained as closely as possible in the new rotation representation.

.. rubric:: Options

Rotation Mode
   The rotation mode to convert the animation to.

Bake
   Inserts a keyframe on every frame before converting the animation.

   This preserves the evaluated motion more accurately when converting between
   rotation modes, at the cost of creating additional keyframes.

.. note::

   - The converted animation is always fully keyed for the destination rotation
     mode, even if only some rotation channels were originally keyed.
   - Interpolation between keyframes may change after conversion. This is expected,
     as different rotation modes represent rotations differently.
   - Keyframe types are preserved when possible.
   - Animation is converted in all actions associated with the selected object or pose bones.
