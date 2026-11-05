
######################
  Editing Bone Poses
######################

Pose editing allows adjusting the position, rotation, and scale of bones to create
different poses without changing the armature's rest pose.

Most pose editing is performed by transforming selected bones, but additional
operators can be used to mirror, copy, apply, or clear transformations, as well
as create intermediate poses for animation. These tools are available from the
:menuselection:`Pose` menu.

When posing an armature, any objects deformed by it are updated in real time,
allowing the effect of each adjustment to be seen immediately. With complex rigs
or high-resolution meshes, this can reduce interactive performance. In those
cases, enabling *Delay Deform* in the armature's settings delays updating the
deformed objects until the transform operation is confirmed.

.. toctree::
   :maxdepth: 2

   transform.rst
   clear.rst
   apply.rst
   propagate.rst
   copy_paste.rst
   pose_library.rst
   inverse_kinematics.rst
   flip_quats.rst
   show_hide.rst
