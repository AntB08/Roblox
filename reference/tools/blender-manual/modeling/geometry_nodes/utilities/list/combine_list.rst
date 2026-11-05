
.. index:: Geometry Nodes; Combine List
.. _bpy.types.GeometryNodeCombineList:

*****************
Combine List Node
*****************

.. figure:: /images/node-types_GeometryNodeCombineList.webp
   :align: center
   :alt: Combine List node.

The *Combine List* node creates a list by combining individual values into an ordered sequence.

Each input corresponds to an item in the resulting list, with the order of the inputs
determining the order of the items. Additional items can be added or removed to control
the size of the list.

This node is useful for constructing lists from individual values, which can then be
passed to other nodes that operate on lists.


Inputs
======

The node provides a separate input socket for each item defined in the *Items* list.

Each input specifies the value of the corresponding item in the resulting list.
The inputs are evaluated in the same order as they appear on the node.


Properties
==========

Data Type
   The type of data stored in the list. All items in the list use the same data type.


.. _bpy.ops.node.combine_list_item_add:
.. _bpy.ops.node.combine_list_item_remove:

Items
-----

A list of items that defines the number and order of the node's input sockets.

Each item creates a corresponding input socket on the node.
Items can be reordered to change their position in the resulting list.

The :bl-icon:`add` button adds a new item, while the :bl-icon:`remove` buttons
removes the selected item.


Outputs
=======

List
   A list containing the values of all input items, in the order defined by the *Items* list.
