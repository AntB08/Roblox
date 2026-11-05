*****
Shape
*****

The *Shape* panel contains settings that control the shape of the brush.

Falloff
   See :doc:`Falloff </sculpt_paint/brush/falloff>` for more information.

.. _bpy.types.Brush.hardness:

Hardness :guilabel:`Sculpt Mode`
   How close the brush falloff starts from the edge of the brush.

   :bl-icon:`stylus_pressure` (Hardness Pressure)
      Adjusts the hardness based on the stylus pressure when using a :ref:`Graphics Tablet <hardware-tablet>`.
   :bl-icon:`rightarrow` / :bl-icon:`downarrow_hlt` (Expand/Collapse)
      Show or hide the customizable pressure curve.

      Custom Curve
         By default this is a straight line with positive slope such that
         increased pressure results in a harder brush falloff.

         For the curve controls see: :ref:`Curve widget <ui-curve-widget>`.

.. _bpy.types.Brush.tip_roundness:

Tip Roundness :guilabel:`Sculpt Mode`
   The factor to control how round the brush is. A value of zero will make the brush square.
   Note, the :doc:`Falloff </sculpt_paint/brush/falloff>`
   is only applied to the rounded portions of the brush.

.. _bpy.types.Brush.tip_scale_x:

Tip Scale X :guilabel:`Sculpt Mode`
   Scale of the brush tip in the X axis. This is useful for achieving a painting stroke like a marker or paint
   roller.