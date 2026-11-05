.. _3dview-camera-navigate:

***********
Camera View
***********

.. figure:: /images/editors_3dview_navigate_camera-view_example.png

   Demonstration of camera view.

The Camera View shows the scene from the active camera's viewpoint.
It can be used to compose shots and preview how the scene will appear when rendered.
The rendered image contains everything within the camera frame, indicated by a dashed outline.

.. seealso::

   :doc:`Camera Settings </render/cameras>` for details on how camera settings
   affect the viewport display and rendering.

.. hint::

   While in Camera View, the camera can be selected by clicking its dashed frame,
   provided the camera object is not hidden.


.. _bpy.ops.view3d.view_camera:

Viewing the Active Camera
=========================

.. reference::

   :Mode:      All Modes
   :Menu:      :menuselection:`View --> Cameras --> Active Camera`,
               :menuselection:`View --> Viewpoint --> Camera`
   :Shortcut:  :kbd:`Numpad0`

Switches the viewport to the active camera's view.
Press :kbd:`Numpad0` again to return to the previous viewport perspective.


.. _bpy.ops.view3d.object_as_camera:

Setting the Active Camera
=========================

.. reference::

   :Mode:      Object Mode
   :Menu:      :menuselection:`View --> Cameras --> Set Active Object as Camera`
   :Shortcut:  :kbd:`Ctrl-Numpad0`

.. figure:: /images/editors_3dview_navigate_camera-view_cameras.png

   Active camera (left) displayed with a solid triangle above it.

Sets the selected object as the active camera and switches to Camera View.

The active camera determines the viewpoint used for rendering and when entering
Camera View. It can also be assigned in the *Scene* tab of the
:doc:`Properties </editors/properties_editor>`.

.. note::

   The active camera is normally defined at the scene level and shared across
   all 3D Viewports. However, a different camera can be assigned to an individual
   viewport using :ref:`Local Camera <bpy.types.SpaceView3D.use_local_camera>`.


Animated Camera Switching
-------------------------

A scene can contain multiple cameras, which can be bound to specific frames
to create cuts between different viewpoints during an animation.

See :ref:`Animating Cameras <bpy.ops.marker.camera_bind>`.


.. _bpy.ops.view3d.view_center_camera:

Frame Camera Bounds
===================

.. reference::

   :Mode:      All Modes
   :Menu:      :menuselection:`View --> Cameras --> Frame Camera Bounds`
   :Shortcut:  :kbd:`Home`

Centers the camera frame in the 3D Viewport and adjusts its size
to fit within the available area.


.. _bpy.ops.view3d.zoom_camera_1_to_1:

Zoom Camera 1:1
===============

.. reference::

   :Mode:      All Modes
   :Menu:      :menuselection:`View --> Navigation --> Zoom Camera 1:1`

Zooms the camera frame so that its displayed dimensions match the output resolution
in pixels. This allows previewing objects at their rendered size.


Camera View Roll
================

The Camera View has its own roll, independent of the regular viewport's orientation.
This allows the camera frame to be tilted within the viewport without changing
the camera object's rotation or the rendered image.

Use :kbd:`Shift-Numpad4` or :kbd:`Shift-Numpad6` to roll the view
clockwise or counterclockwise.

The Camera View and regular viewport maintain separate roll values.
Switching between them restores their respective orientations.

This is different from rotating the camera object around its local Z axis,
which changes the orientation of the camera itself and affects the rendered image.

.. seealso::

   :ref:`Roll <bpy.ops.view3d.view_roll>` for more information about viewport
   rolling and its configurable rotation increment.


Camera View Flip
================

The Camera View can be flipped horizontally to display a mirrored version
of the composition. This can help identify visual imbalances or asymmetry
that may be less noticeable in the original orientation.

Use :ref:`Flip View <bpy.ops.view3d.view_flip>` to toggle the mirrored view.

Flipping the view only affects the viewport display.
It does not change the camera object's transform or the rendered image.


Camera Positioning
==================

There are several ways to position and orient a camera in a scene.
These methods allow aligning the camera with the viewport, navigating
while controlling the camera, or performing traditional camera movements
such as rolling, panning, and tracking.

.. hint::

   The active camera can be any object assigned as the scene camera.
   These techniques can also be used to position and aim other objects,
   such as lights.


Align Active Camera to View
---------------------------

See :ref:`Align Active Camera to View <bpy.ops.view3d.camera_to_view>`.

Aligns the active camera with the current viewport perspective,
matching its position and orientation.

This is useful for composing a shot using standard viewport navigation
before placing the camera at that viewpoint.


Camera Navigation
-----------------

Enable :ref:`Lock Camera to View <bpy.types.SpaceView3D.lock_camera>`
and enter Camera View using :kbd:`Numpad0`.

When enabled, viewport navigation moves and rotates the camera object
instead of navigating independently of it.

The option can also be toggled using the navigation gizmo while in Camera View.

.. note::

   Without *Lock Camera to View*, navigating within Camera View can change
   how the camera frame is displayed without changing the camera object.
   These viewport adjustments do not affect the rendered image.

.. seealso::

   :ref:`Fly/Walk Navigation <3dview-fly-walk>` provides first-person
   navigation that can also be used to position the active camera.


Roll, Pan, Dolly, and Track
---------------------------

The camera can be positioned using standard object transform operators.
First select the camera and enter Camera View to see the results interactively.

Roll
   Rotates the camera around its local Z axis, tilting the composition
   without changing its viewing direction.

   Press :kbd:`R` to rotate the camera while in Camera View,
   or :kbd:`R`, then :kbd:`Z` twice to explicitly constrain rotation
   to the camera's local Z axis.

Vertical Pan or Pitch
   Rotates the camera around its local X axis, changing its viewing direction
   upward or downward.

   Press :kbd:`R`, then :kbd:`X` twice.

Horizontal Pan or Yaw
   Rotates the camera around its local Y axis, changing its viewing direction
   left or right.

   Press :kbd:`R`, then :kbd:`Y` twice.

Dolly
   Moves the camera forward or backward along its viewing direction.

   Press :kbd:`G`, then :kbd:`MMB`, or :kbd:`G`, then :kbd:`Z` twice
   to constrain movement to the camera's local Z axis.

Sideways Tracking
   Moves the camera horizontally or vertically without changing its orientation.

   Press :kbd:`G` and move the mouse.
   Use :kbd:`X` or :kbd:`Y` twice to constrain movement to the corresponding
   local axis.

.. tip::

   Pressing an axis key twice constrains a transformation to the object's
   local axis instead of the global axis.

   See :doc:`Axis Locking </scene_layout/object/editing/transform/control/axis_locking>`.
