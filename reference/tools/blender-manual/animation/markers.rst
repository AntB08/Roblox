.. _bpy.types.TimelineMarker:
.. _bpy.ops.marker:

*******
Markers
*******

Markers are used to denote frames with key points or significant events within an animation.
E.g. it could be that a character's animation starts, the camera changes position, or a door opens.
Markers can be given names to make them more meaningful at a quick glance.
They are available in many of Blender's editors.

.. note::

   Unlike keyframes, markers are always placed at a whole frame number, you cannot set a marker at frame 2.5.

Markers can be created and edited in the following editors:

- :doc:`Graph Editor </editors/graph_editor/introduction>`
- :doc:`Dope Sheet </editors/dope_sheet/introduction>`
- :doc:`NLA Editor </editors/nla/index>`
- :doc:`Video Sequence Editor </video_editing/index>`

.. note::

   A marker created in one of these editors will also appear in all others that support them.


.. _marker-types:

Types
=====

Blender supports two types of markers: *timeline markers* and *pose markers*.

- **Timeline Markers** -- Mark specific frames in the scene's timeline.
  They are shared across animation editors and can be used to identify important events,
  animation transitions, or other points of interest.

  See :doc:`Timeline Markers </animation/markers>` for more information.

- **Pose Markers** -- Mark specific frames within an :doc:`Action </animation/actions>`,
  allowing poses or shape key configurations to be identified and organized.

  Unlike timeline markers, pose markers belong to an individual Action rather than the scene.
  They are displayed in the *Action Editor* and *Shape Key Editor* modes of the Dope Sheet
  when the corresponding Action is active.

  Pose markers can be used to label key poses, identify important animation states,
  and make it easier to navigate and reuse poses within an Action.

  Existing timeline markers can be converted into pose markers using
  :ref:`Convert to Pose Markers <bpy.ops.action.markers_make_local>`.


Visualization
=============

In the supported editors, if at least one is created, markers are visualized
in a separate row at their bottom.
This area can be disabled per editor via the :menuselection:`View --> Show Markers` menu option.

.. note::

   While the markers area is disabled, markers operators are not available in that editor,
   and in the header the *Marker* menu is hidden.


Standard
--------

.. figure:: /images/animation_markers_standard.png
   :align: right

Regular markers are shown as small white triangles, empty if unselected or filled if selected,
and with a dashed line that covers the editor height at the corresponding frame.
If they have a name, this is shown to their right in white.


3D Viewport
-----------

.. figure:: /images/animation_markers_3d-view.png
   :align: right

The 3D Viewport does not allow you to create, edit or remove markers,
but it shows their name in the Object Info in the upper left corner,
when on their frame.


Pose Markers
------------

.. figure:: /images/animation_markers_pose.png
   :align: right

Pose markers show a diamond-shaped icon in the Dope Sheet.
In the NLA editor pose markers are shown as a red dashed line inside the relative action strip.

.. container:: lead

   .. clear


.. _bpy.ops.marker.add:

Add Marker
==========

.. reference::

   :Mode:      All modes
   :Menu:      :menuselection:`Marker --> Add Marker`
   :Shortcut:  :kbd:`M`

The simplest way to add a marker is to move to the frame where you would like it to appear,
and press :kbd:`M`.

.. hint::

   Markers can also be added during playback.


.. _marker-pose-add:

Pose Markers
------------

If :ref:`bpy.types.SpaceDopeSheetEditor.show_pose_markers` is enabled, a pose marker is added.


.. _bpy.ops.marker.select:

Selecting
=========

.. reference::

   :Mode:      All modes
   :Shortcut:  :kbd:`LMB`

Click :kbd:`LMB` on the marker's triangle to select it.
Use :kbd:`Shift-LMB` to select multiple markers.

In the Graph Editor, Dope Sheet, NLA Editor, Timeline, and Video Sequence Editor,
you can also select all markers with :kbd:`A` while hovering the mouse over the marker row,
and apply selection tools on them like Box Select, etc.
(as usual, :kbd:`LMB` to select, :kbd:`RMB` to deselect).
The corresponding options are found in the Select menu of these editors.


.. _animation-markers-editing:

Editing
=======

.. _bpy.ops.marker.duplicate:

Duplicate Marker
----------------

.. reference::

   :Mode:      All modes
   :Menu:      :menuselection:`Marker --> Duplicate Marker`
   :Shortcut:  :kbd:`Shift-D`

You can duplicate the selected markers by pressing :kbd:`Shift-D`. Once duplicated,
the new ones are automatically placed in select mode, so you can move them to the desired location.

.. note::

   Note that unlike most other duplications in Blender,
   the names of the duplicated markers are not altered at all
   (no ``.001`` numeric counter append).


.. _bpy.ops.marker.make_links_scene:

Duplicate Marker to Scene
-------------------------

.. reference::

   :Mode:      All modes
   :Menu:      :menuselection:`Marker --> Duplicate Marker to Scene...`

Duplicates the selected markers into another scene.


.. _bpy.ops.marker.delete:

Delete Marker
-------------

.. reference::

   :Mode:      All modes
   :Menu:      :menuselection:`Marker --> Delete Marker`
   :Shortcut:  :kbd:`X`

To delete the selected markers simply press :kbd:`X`,
and confirm the pop-up message with :kbd:`LMB`.


Rename Marker
-------------

.. reference::

   :Mode:      All modes
   :Menu:      :menuselection:`Marker --> Rename Marker`
   :Shortcut:  :kbd:`F2`

Having dozens of markers scattered throughout your scene's time will not help you much unless you
know what they stand for. You can name a marker by selecting it, pressing :kbd:`F2`,
typing the name, and press :kbd:`Return`


.. _bpy.ops.marker.move:

Move Marker
-----------

.. reference::

   :Mode:      All modes
   :Menu:      :menuselection:`Marker --> Move Marker`
   :Shortcut:  :kbd:`G`

Once you have one or more markers selected, press :kbd:`G`,
while hovering with the mouse over the marker bar,
to move them, and confirm the move with :kbd:`LMB` or :kbd:`Return`
(as usual, cancel the move with :kbd:`RMB`, or :kbd:`Esc`).
Or drag them with the :kbd:`LMB`.

By default, you move the markers in one-frame steps, but if you hold :kbd:`Ctrl`,
the markers will move in steps corresponding to 1 second (according to the scene's *FPS*).


Select
------

.. reference::

   :Mode:      All modes
   :Menu:      :menuselection:`Marker --> Select`

Convenient operators for selecting Marks; see :ref:`bpy.ops.marker.select` for more information on selecting Markers.

.. _bpy.ops.marker.select_all:

All :kbd:`A`
   Selects all Markers.
None :kbd:`Ctrl-A`
   Deselects any already selected Markers.
Invert :kbd:`Ctrl-I`
   Select all unselected Markers and deselects all selected Markers.

.. _bpy.ops.marker.select_leftright:

Before Current Frame :kbd:`[`
   Selects all markers before the current frame, including the marker on the current frame if one exists.
After Current Frame :kbd:`]`
   Selects all markers after the current frame, including the marker on the current frame if one exists.

.. tip::

   Markers can also be selected interactively by clicking with :kbd:`Ctrl-LMB` on either side of the playhead.


.. _bpy.types.SpaceDopeSheetEditor.show_pose_markers:

Show Pose Markers
-----------------

.. reference::

   :Editor:    Dope Sheet
   :Mode:      Action Editor or Shape Keys Editor mode
   :Menu:      :menuselection:`Marker --> Show Pose Markers`

Shows markers belonging to the active action instead of scene markers.


.. _bpy.ops.action.markers_make_local:

Convert to Pose Markers
-----------------------

.. reference::

   :Editor:    Dope Sheet (Action Editor mode only)
   :Menu:      :menuselection:`Marker --> Convert to Pose Markers`

Converts timeline markers into :ref:`Pose Markers <marker-types>`
associated with the active Action.

The original timeline markers are removed during conversion.
To preserve them, duplicate the markers before converting.


.. _bpy.ops.screen.marker_jump:

Jump to Next/Previous Marker
----------------------------

.. reference::

   :Mode:      All modes
   :Menu:      :menuselection:`Marker --> Jump to Next/Previous Marker`

Moves the Playhead to the next/previous marker relative to the current frame.


.. _bpy.ops.marker.camera_bind:

Bind Camera to Markers
======================

.. reference::

   :Mode:      All modes
   :Menu:      :menuselection:`Marker --> Bind Camera to Markers`
   :Shortcut:  :kbd:`Ctrl-B`

*Bind Camera to Markers* allows markers to be used to set the active object as the active camera.

To use this operator, select the object to become the active camera
and select a marker to bind the active camera to.
If no marker is selected when the operator is applied, a marker will be added.
When an object is bound to a marker, the marker will be renamed to the name of the active object.
These markers also have a camera icon next to the left of the name
to easily distinguish them from other informative markers.

These markers can be moved to change the frame at which
the active camera is changed to the object the marker is bound to.
