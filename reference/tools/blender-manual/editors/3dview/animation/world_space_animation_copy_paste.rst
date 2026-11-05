*********************
World Space Animation
*********************

Copy the :term:`world space` animation between selected objects or bones.
Any copied data is stored on disk in a temporary file so it is possible to copy paste between
different files.
The tool also works with multiple objects or bones at once. Blender will apply the
animation data in the correct order to preserve the world space.

Matching Logic
   When working with multiple objects or bones,
   Blender matches the animation data to an element based on the following rules.

   * Copy and paste to a single element: animation is just pasted.
   * Copy one element, paste to more than one: The same animation is pasted to all selected.
   * Copy more than one element, paste to one or more: The name between the pasted element
     and the copied element has to match. Note that this still works between objects and bones
     as long as they are named the same.


.. reference::

   :Panel:     :menuselection:`3D Viewport --> Sidebar --> Animation --> World Space Animation`


.. figure:: /images/copy_world_space_anim-main.png
   :align: right


.. _bpy.ops.anim.world_space_copy:

Copy Playback Range
   Copies the animation of the selected Objects (in Object mode) or Bones (in Pose mode)
   and stores it as a temporary file on disk. The range of frames copied is the current playback range.
   That means if the :ref:`Preview Range <graph-preview-range>` is enabled it is used,
   otherwise the scene range is used.


.. _bpy.ops.anim.world_space_paste:

Paste
   Pastes the copied animation onto the selected Objects or Bones.
   The matching logic described above is used to determine which data is pasted to what object or bone.
   The keys are placed at the same frames that they were copied from.

Paste at Playhead
   Same as *Paste* except that the keys are placed starting at the current
   :ref:`Playhead <playhead>` position. That allows creating a time offset when pasting.


Limitations
===========

Pasting a transform adjusts the Object/Bone's location, rotation, and
scale. This means that when copying a skewed transform, this skew is lost.

Pasting to Objects or Bones with constraints is not supported. It may not produce
the correct world space result.

Pasting animation always results in keys on every frame. Pasting animation only on frames where
the object or bone has existing keys is not yet supported.

when the rotation mode is animated, pasting world space animation will override all keys in the
baked range to be the value at the start of the range.


.. warning::

   These tools are not compatible with :doc:`World Space Transform <copy_global_transform>`.
   Data copied from one can not be pasted with the other.
