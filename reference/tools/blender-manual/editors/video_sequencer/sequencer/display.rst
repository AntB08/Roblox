
*******
Display
*******

.. _bpy.types.SpaceSequenceEditor.show_overlays:
.. _bpy.types.SequencerTimelineOverlay:

Sequencer Overlays
==================

.. reference::

   :Location:    :menuselection:`Header --> Overlays`

.. figure:: /images/editors-video_sequencer-sequencer-overlays.png

Overlays are information that is displayed on top of the sequencer region.
Clicking :bl-icon:`overlay` (Show Overlays) toggles all overlays in one go,
while the drop-down button shows a pop-over where you can toggle individual ones:

.. _bpy.types.SequencerTimelineOverlay.show_grid:

Grid
   Shows vertical lines at regular time intervals.

.. _bpy.types.SequencerCacheOverlay.show_cache:

Cache
   Visualize cached images on the timeline.


Strips
------

.. _bpy.types.SequencerTimelineOverlay.show_strip_name:

Name
   Shows the :ref:`Name <bpy.types.Strip.name>` of each strip.

.. _bpy.types.SequencerTimelineOverlay.show_strip_source:

Source
   Shows the file path of each strip.

.. _bpy.types.SequencerTimelineOverlay.show_strip_duration:

Duration
   Shows the length of each strip (in frames).

.. _bpy.types.SequencerTimelineOverlay.show_fcurves:

Animation Curves
   Shows animation curves for volume (Sound strips) and opacity (other strips).

.. _bpy.types.SequencerTimelineOverlay.show_strip_tag_color:

Color Tags
   Displays each strip in its designated custom color (if applied) rather than a
   :ref:`color representing its type <sequencer-strip-colors>`. To set a custom color,
   either click the *Color Tag* button next to the strip's name in
   :menuselection:`Sidebar --> Strip`, or use *Set Color Tag* in the strip's context menu.

.. _bpy.types.SequencerTimelineOverlay.show_strip_offset:

Offsets
   Shows overflow bars of content that was trimmed from the strip (by moving
   the strip's handles). See :ref:`bpy.types.Strip.frame_offset_start`.


.. _bpy.types.SequencerTimelineOverlay.show_thumbnails:

Thumbnails
----------

Displays previews of the source images or video frames within strips in the Timeline.
Thumbnails make it easier to identify the contents of strips without using the Preview.

Thumbnails can be toggled on or off in the panel's header.

.. _bpy.types.SequencerTimelineOverlay.thumbnail_display_style:

Display Style
   Determines how thumbnails are arranged within strips.

   The thumbnail size depends on the vertical zoom level, which can be adjusted
   by dragging vertically with :kbd:`Ctrl-MMB`.
   Zooming in makes strips taller, displaying larger but fewer thumbnails,
   while zooming out makes strips shorter, displaying smaller but more thumbnails.

   :Middle:
      Displays a single thumbnail in the center of each strip.
      Useful for identifying the contents of strips while keeping the Timeline uncluttered.
   :Strip Ends:
      Displays thumbnails at the beginning and end of each strip.
      Useful for identifying the first and last frames without displaying intermediate thumbnails.
   :Continuous:
      Displays thumbnails continuously across the width of Movie and Image strips.
      The thumbnails represent frames at different points in the strip,
      making it easier to identify scenes and locate specific content.


Waveforms
---------

.. _bpy.types.SequencerTimelineOverlay.waveform_display_type:

Type
   Global options for waveform display on Sound strips.

   :On: Enable waveforms for all strips.
   :Strip:
      Use the :ref:`Display Waveform <bpy.types.SoundStrip.show_waveform>`
      option of each individual strip.
   :Off: Disable waveforms for all strips.

.. _bpy.types.SequencerTimelineOverlay.waveform_display_style:

Style
   How Waveforms are displayed.

   :Full: Displays the audio amplitude.
   :Half: Displays the audio level.
