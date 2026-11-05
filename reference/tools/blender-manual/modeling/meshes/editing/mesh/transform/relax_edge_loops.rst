.. _bpy.ops.mesh.relax_edge_loops:

****************
Relax Edge Loops
****************

.. reference::

   :Mode:      Edit Mode
   :Menu:      :menuselection:`Mesh --> Transform --> Relax Edge Loops`

The *Relax Edge Loops* operator smooths selected edge loops by adjusting the positions
of their vertices while preserving the overall shape of the mesh.

Only separate edge loops containing two or more edges can be relaxed.
Faces must not be selected.

.. note::

   The operator requires at least one separate edge loop containing two or more selected edges.
   It cannot be used when faces are selected.


Options
=======

Iterations
   Number of times the relaxation is applied.
   Higher values produce a smoother distribution of vertices.

Space Evenly
   Distribute vertices at constant distances along the loop.

Interpolation
   Algorithm used to compute the new vertex positions.

   :Cubic:
      Uses a natural cubic spline to produce a smooth distribution that better
      preserves the curvature of the loop.
   :Linear:
      Interpolates directly along the existing edges.
      This is faster and preserves straight edge segments.
