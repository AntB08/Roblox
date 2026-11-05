.. index:: Geometry Nodes; Grid Solve Poisson
.. _bpy.types.GeometryNodeGridSolvePoisson:

***********************
Grid Solve Poisson Node
***********************

.. figure:: /images/node-types_GeometryNodeGridSolvePoisson.webp
   :align: right
   :alt: Grid Solve Poisson node.

The *Grid Solve Poisson* node is an advanced math node for solving a wide range of problems in
geometry and physics simulation using 3D grids.

It solves `Poisson's equation <https://en.wikipedia.org/wiki/Poisson%27s_equation>`__, which relates
the value of each grid voxel to its neighbors using the
`Laplace operator <https://en.wikipedia.org/wiki/Laplace_operator>`__.

The Laplace operator computes the difference between a voxel and the average of its neighbors.
The node solves the *inverse* problem, reconstructing the original potential where applying the
Laplace operator produces the input grid again.

The solution to the Poisson equation is not unique, for example adding a constant to every voxel
results in the same difference from the neighborhood average (one *degree-of-freedom*). The solution
has as many degrees-of-freedom as there are boundary voxels. To fully define the solution the
*boundary conditions* at the edge of the solution space must also be specified.

The default boundary condition enforces a solution value of *zero* at the
boundary everywhere. Other modes allow enforcing custom fixed values
(`Dirichlet condition <https://en.wikipedia.org/wiki/Dirichlet_boundary_condition>`__),
or custom gradient values of the resulting function
(`Neumann condition <https://en.wikipedia.org/wiki/Neumann_boundary_condition>`__),
or a combination of both ("Mixed" boundary condition).

.. figure:: /images/modeling_geometry-nodes_volume_grid-poisson-solve-colors.png
   :align: center
   :alt: 2D grid slice with input values and resulting Poisson solution.

Inputs
======

Grid
   "Source" values on the right-hand side of the Poisson equation. The active voxels of the grid
   define the solution space.

   .. warning::

      The input grid must have a uniform voxel size (all components are the same).

Max Iterations
   Maximum number of iterations the solver will use.

Error Threshold
   Threshold below which the solution is considered valid. After each iteration the solver computes
   the maximum absolute residual error of all voxels and compares it to the threshold value.

Threshold Mode
   Defines how the *Error Threshold* is interpreted:

   :Relative:
      The error threshold is relative to the `maximum norm <https://en.wikipedia.org/wiki/Norm_(mathematics)#Maximum_norm_(special_case_of:_infinity_norm,_uniform_norm,_or_supremum_norm)>`__
      of the input grid, including boundary conditions. In the case that the norm is zero the
      relative error is used like an absolute error threshold.
   :Absolute:
      The solution error is compared directly to the error threshold value.

Boundary
   Mode that defines what boundary conditions to use for the solution:

   :Fixed:
      The solution must be equal to the specified *Boundary Value* at the boundary.
      This is equivalent to a Dirichlet boundary condition with a custom value.
   :Gradient:
      The gradient of the solution must be equal to the specified *Boundary Gradient* at the
      boundary. This is equivalent to a Neumann boundary condition with a custom vector value.
   :Mixed:
      Enforce both *Fixed* and *Gradient* conditions, using the *Boundary Factor* to mix between both.
      This can be used to apply different types of boundary conditions in different regions of the
      boundary.

      A typical use case is to distinguish between empty (air) cells and obstacles in a fluid
      simulation.

Boundary Value :guilabel:`Fixed` :guilabel:`Mixed`
   Value of the solution at boundary voxels.

Boundary Gradient :guilabel:`Gradient` :guilabel:`Mixed`
   Value of the normal components of the solution gradient at boundary voxels.

Boundary Factor :guilabel:`Mixed`
   Factor to mix between *Fixed* and *Gradient* boundary conditions. Factor ``0`` is a pure
   Dirichlet condition while factor ``1`` is a pure Neumann condition. Values between ``0`` and
   ``1`` enforce a mixture of both conditions.

.. note::
   The boundary fields are evaluated only in a thin 1-voxel band around the active solution space.
   Any voxel that is inactive but adjacent to an active voxel is a boundary voxel.

   For *Gradient* boundary conditions only the component along the boundary face normal is used. The
   vector defined by the boundary field defines +-X/Y/Z components for its active neighbors in
   the respective directions.

Outputs
=======

Solution
   The solution of the Poisson equation. The grid has the same topology (active voxels) as the input
   grid.

Success
   Single value indicating whether the solver succeeded or not.

Iterations
   Number of iterations used by the solver.

   If this matches the *Max Iterations* input (and the *Success* output is ``false``) then
   the solver may require more iterations to compute a valid solution.

Absolute Error
   Maximum residual error of any solution voxel.

Relative Error
   Maximum residual error of any solution voxel, relative to the maximum norm of the input grid.

Debug
   Various debug outputs to help investigate potential issues.

   Boundary Value
      Grid values of the evaluated *Boundary Value* input field.
   Boundary Gradient
      Grid values of the evaluated *Boundary Gradient* input field.
   Boundary Factor
      Grid values of the evaluated *Boundary Factor* input field.
