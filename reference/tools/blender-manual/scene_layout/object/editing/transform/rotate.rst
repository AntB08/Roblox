.. _bpy.ops.transform.rotate:

******
Rotate
******

.. reference::

   :Mode:      Object and Edit Modes
   :Menu:      :menuselection:`Object/Mesh/Curve/Surface --> Transform --> Rotate`
   :Shortcut:  :kbd:`R`

Rotation changes the orientation of the selected elements (vertices, edges,
faces, objects, etc.) around the current
:doc:`Pivot Point </editors/3dview/controls/pivot_point/index>`.
Depending on the selected pivot point, elements rotate around their own origins,
the median point of the selection, the active element, the 3D Cursor, or another
reference point.

The angle of rotation is displayed in the header of the 3D Viewport while the
operation is active.

.. figure:: /images/scene-layout_object_editing_transform_rotate_display-values.png

   Rotation values.

During the operation, you can constrain the rotation to an axis by pressing
:kbd:`X`, :kbd:`Y`, or :kbd:`Z`, or constrain it to an axis of the current
:doc:`Transform Orientation </editors/3dview/controls/orientation>` by pressing
the same key a second time.

Rotation can also be entered numerically by typing an angle. Positive values
rotate counterclockwise around the chosen axis, while negative values rotate clockwise.

.. seealso::

   Using a combination of shortcuts gives you more control over transformations.
   See :doc:`Transform Control </scene_layout/object/editing/transform/control/index>`.


.. rubric:: Options
   :heading-level: 2

Angle
   The angle to rotate the selected elements.

Axis
   Constrains the rotation to one or more axes.

Orientation
   Specifies the transform orientation used for axis constraints.
   See :doc:`Transform Orientations </editors/3dview/controls/orientation>` for more information.

Proportional Editing
   Rotates nearby geometry with a falloff based on the proportional editing settings.
   See :doc:`Proportional Editing </editors/3dview/controls/proportional_editing>` for more information.


.. _bpy.ops.transform.trackball:

Trackball Rotation
==================

.. reference::

   :Mode:      Object and Edit Modes
   :Shortcut:  :kbd:`R R`

*Trackball Rotation* rotates the selection freely around the viewport's
horizontal and vertical axes, similar to rolling a virtual trackball. This
allows multiple axes to be rotated simultaneously without first choosing a
rotation axis.

Moving the mouse horizontally rotates around the viewport's vertical axis,
while moving it vertically rotates around the viewport's horizontal axis. The
combined movement determines the final rotation.

Like the standard Rotate operator, Trackball Rotation supports numeric input,
axis constraints, and proportional editing.
