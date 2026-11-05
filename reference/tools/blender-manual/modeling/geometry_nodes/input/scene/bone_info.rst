.. index:: Geometry Nodes; Bone Info
.. _bpy.types.GeometryNodeBoneInfo:
.. --- copy below this line ---

**************
Bone Info Node
**************

.. figure:: /images/node-types_GeometryNodeBoneInfo.webp
   :align: right
   :alt: Bone Info node.

The *Bone Info* node retrieves transform information for a bone from an armature object.

This can be used to drive Geometry Nodes with an armature, create
procedural rigging effects, or implement custom armature deformation using
vertex group attributes.

.. note::

   A dependency cycle can occur if the *Bone Info* node uses one bone and another bone in the same armature in turn
   depends on the modified object, for example using a :doc:`/animation/constraints/relationship/geometry_attribute`.
   Inside an armature each bone can be referenced individually, but the geometry modifier node can only add a
   dependency on the entire armature. This is because the bone name is a generic string that does not generally point
   to a single bone.


Inputs
======

Armature
   Armature object to get bone poses from.

Bone Name
   Name of the bone to evaluate.

   If the specified bone does not exist, a warning is displayed unless the
   *Exists* output is used.


Properties
==========

Transform Space
   The space in which pose transforms are defined.

   :Original:
      Output the pose and rest pose relative to the armature object origin.
   :Relative:
      Bring the pose and rest pose into the modified object's space.


Outputs
=======

Pose
   Evaluated final transform of the bone.
Local Pose
   Difference between the pose and rest pose, relative to the parent bone. Not affected by the transform space.
Transform Pose
   Matrix representing the bone's location, rotation, and scale properties. Not affected by the transform space.
Rest Pose
   Original transform of the bone as defined in edit mode.
Rest Length
   Original length of the bone.
Exists
   Whether the specified bone exists in the armature.


Envelope
--------

The following outputs provide the bone's envelope properties as defined in Edit Mode.
These values can be used to calculate procedural deformation weights or reproduce
envelope-based deformation in Geometry Nodes.

Envelope Distance
   Distance beyond the bone's head and tail radii over which its envelope influence extends.

Radius Head
   Radius of the bone's envelope at its head.

Radius Tail
   Radius of the bone's envelope at its tail.
