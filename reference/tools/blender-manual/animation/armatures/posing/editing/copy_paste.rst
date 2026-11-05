
***************
Copy/Paste Pose
***************

Blender allows poses to be copied between armatures using a temporary pose buffer.
Poses can be pasted normally or mirrored across the X axis.


.. _bpy.ops.pose.copy:

Copy Pose
=========

.. reference::

   :Mode:      Pose Mode
   :Menu:      :menuselection:`Pose --> Copy Pose`
   :Shortcut:  :kbd:`Ctrl-C`

Copies the pose of the selected bones to the pose buffer.
Only selected bones are included, allowing individual parts of a pose to be copied.


.. _bpy.ops.pose.paste:

Paste Pose
==========

.. reference::

   :Mode:      Pose Mode
   :Menu:      :menuselection:`Pose --> Paste Pose`
   :Shortcut:  :kbd:`Ctrl-V`

Applies the transforms stored in the pose buffer to bones in the active armature.
Bones are matched by name, so only bones with corresponding names are affected.

Flipped on X-Axis
   Mirrors the pasted pose across the X axis.
   This is useful for transferring poses between opposite sides of an armature,
   such as from the left arm to the right arm.
On Selected Only
   Applies the stored pose only to selected bones.
   When disabled, all bones with matching names can be affected, regardless of selection.
Factor
   Blends between the current pose and the pasted pose.
   A value of 0 leaves the current pose unchanged, while a value of 1 fully applies the pasted pose.
   Values in between produce a blend of the two poses.


Paste Pose Flipped
==================

.. reference::

   :Mode:      Pose Mode
   :Menu:      :menuselection:`Pose --> Paste Pose Flipped`
   :Shortcut:  :kbd:`Shift-Ctrl-V`

Pastes the buffered pose with the *Flipped on X-Axis* option enabled,
mirroring the pose across the X axis.


How Copy/Paste Works
====================

The pose buffer has the following characteristics:

- The buffer is shared across the entire :term:`Blender session`,
  allowing poses to be copied between armatures, scenes, and blend-files.
  However, the buffer is not saved and is cleared when Blender closes.
- Only one pose can be stored in the buffer at a time.
  Copying another pose replaces the previous contents.
- Only selected bones are copied, but bone selection is ignored when pasting.
  Instead, the copied transforms are applied to bones with matching names.
- The copied transforms include each bone's location, rotation, and scale
  relative to its own space.

Because transforms are stored in each bone's local space, the resulting pose
may differ from the original depending on:

- The rest position of the bones.
- The current pose of their parent bones.


Examples
========

.. list-table::

   * - .. figure:: /images/animation_armatures_posing_editing_copy-paste_examples-1.png

          The rest position of the original armature.

     - .. figure:: /images/animation_armatures_posing_editing_copy-paste_examples-2.png

          The rest position of the destination armature.

.. list-table:: Examples of pose copy/paste.

   * - .. figure:: /images/animation_armatures_posing_editing_copy-paste_examples-3.png

          The first copied pose (only two bones are selected and copied).

     - .. figure:: /images/animation_armatures_posing_editing_copy-paste_examples-4.png

          The pose pasted onto the destination armature.

     - .. figure:: /images/animation_armatures_posing_editing_copy-paste_examples-5.png

          The mirrored pose pasted onto the destination armature.

   * - .. figure:: /images/animation_armatures_posing_editing_copy-paste_examples-6.png

          The same pose is copied, this time with all bones selected.

     - .. figure:: /images/animation_armatures_posing_editing_copy-paste_examples-7.png

          The pose pasted onto the destination armature.

     - .. figure:: /images/animation_armatures_posing_editing_copy-paste_examples-8.png

          The mirrored pose pasted onto the destination armature.
