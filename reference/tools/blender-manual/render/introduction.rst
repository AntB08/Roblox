
************
Introduction
************

Rendering is the process of generating a two-dimensional image from a three-dimensional scene.
It combines geometry, materials, lighting, and camera settings to determine the appearance
of the final image.

Blender supports rendering both still images and animations, ranging from stylized illustrations
to photorealistic scenes. The rendering process can also produce additional image data,
such as depth, normals, and object masks, for further processing in the Compositor.


Render Engines
==============

Blender provides several :doc:`render engines <render_engines>`, each designed for
different workflows and performance requirements.

:doc:`EEVEE <eevee/index>`
   A real-time render engine designed for fast, interactive rendering.
   It uses rasterization and other techniques to approximate lighting and reflections,
   making it suitable for animation, stylized rendering, and interactive previews.

:doc:`Cycles <cycles/index>`
   A physically based path-tracing engine that simulates the behavior of light
   as it interacts with surfaces and materials.
   It is particularly useful for photorealistic rendering and scenes requiring
   accurate lighting, reflections, and indirect illumination.

:doc:`Workbench <workbench/index>`
   A simplified render engine optimized for modeling, scene layout, and previews.
   It emphasizes the visibility of geometry rather than realistic lighting and materials.

Additional render engines may be available through third-party extensions.

The active render engine is selected in the Render Properties.
Each engine provides its own settings for controlling render quality, performance,
and supported features.


Scene Appearance
================

The appearance of a rendered image is determined by several components of the scene.

:doc:`Cameras <cameras>`
   Define the viewpoint, framing, and perspective of the rendered image.
   Camera settings also control properties such as focal length and depth of field.

:doc:`Lights <lights/index>`
   Illuminate objects and influence the appearance of their surfaces.
   Different light types can be used to simulate directional, point, spot,
   and area lighting.

:doc:`Materials <materials/index>`
   Define how surfaces interact with light, including their color, roughness,
   transparency, and other shading properties.

:doc:`World Environment <lights/world>`
   Defines the environment surrounding the scene, including background colors
   and environmental lighting.

While EEVEE and Cycles share many of these settings, some features behave
differently or are supported by only one engine.


Viewport Rendering
==================

Blender supports interactive rendering in the 3D Viewport,
allowing materials, lighting, and other scene properties to be previewed
without producing a final render.

The :doc:`Viewport Shading </editors/3dview/display/shading>` controls provide several
display modes, including Material Preview and Rendered shading.

Rendered shading uses the active render engine to display the scene
with its lighting and materials. This is useful for evaluating changes
and refining the appearance of a scene before rendering.

Viewport rendering may use different quality or sampling settings
than the final render to maintain interactivity.


Render Layers & Passes
======================

A scene can be divided into multiple
:doc:`View Layers </render/layers/index>`, allowing different collections
of objects to be rendered or processed independently.

Each View Layer can also produce additional :doc:`render passes </render/layers/passes>`
containing information such as depth, surface normals, diffuse lighting,
and other properties.

These passes provide greater control over the final image by allowing
individual components of the render to be adjusted during compositing.


Freestyle
=========

:doc:`Freestyle <freestyle/index>` is a non-photorealistic line rendering system
that generates stylized outlines and strokes from scene geometry.

It can be used to create technical illustrations, architectural drawings,
cartoon outlines, and other line-based rendering effects.

Freestyle provides controls for selecting which edges are rendered,
including silhouettes, creases, and material boundaries.
Line styles can be customized using properties such as thickness,
color, transparency, and stroke patterns.

Freestyle is integrated into the rendering process and can be combined
with the rendered image to produce stylized results.


Compositing
===========

:doc:`Compositing </compositing/index>` combines rendered images and passes
to produce the final appearance of a scene.

The Compositor can be used to adjust colors, apply visual effects,
combine multiple render layers, or integrate rendered elements
with photographs and video footage.

Compositing can also be organized into a
:doc:`stack of Scene Effects </compositing/scene_effects>`,
where each effect processes the output of the preceding effect.
This allows effects to be managed independently without requiring
a single large node tree.


Color Management
================

:doc:`Color Management <color_management/index>` controls how rendered colors
are transformed for display and output.

Rendering calculations are generally performed in a scene-linear color space.
Color management applies the appropriate transforms to display these values
on a monitor or encode them into an output image.

Settings such as view transforms, exposure, and contrast influence
how the rendered image appears without changing the underlying scene lighting.

A consistent color management workflow is important when combining
renders with external images or transferring work between applications.


Final Rendering
===============

Once the scene is configured, a final image or animation can be rendered.

- :menuselection:`Render --> Render Image` (:kbd:`F12`) renders the current frame.
- :menuselection:`Render --> Render Animation` (:kbd:`Ctrl-F12`) renders the animation
  over the specified frame range.

The final render uses the active render engine and the settings configured
in the Render and Output Properties.

:doc:`Output Properties <output/properties/index>` control the resolution,
frame range, frame rate, file format, and destination of rendered files.

Still images can be saved in formats such as PNG or OpenEXR.
Animations can be rendered directly to video files or as image sequences,
which can be assembled into a video afterward.

.. tip::

   Rendering an animation as an image sequence allows individual frames
   to be re-rendered without restarting the entire animation.
   This is particularly useful for long renders or scenes with high
   computational requirements.

The final image can be inspected in the Render Result of the Image Editor.
If compositing is enabled, the composited result is included in the
rendering workflow.
