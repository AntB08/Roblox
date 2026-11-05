
.. _bpy.types.NodeComment:

************
Comment Node
************

.. figure:: /images/interface_controls_nodes_comment_example.webp
   :align: right

   A Comment node displaying formatted text.

The *Comment* node adds text annotations to a node tree, making it easier to
document complex setups and explain how different parts of a node tree work.

Unlike :doc:`Frame Nodes </interface/controls/nodes/types/layout/frame>`,
which are primarily used to organize nodes into groups,
Comment nodes are designed for longer descriptions and notes.
They support multiple lines of text and basic Markdown formatting, allowing
comments to include headings, emphasis, and links.

Comment nodes have no input or output sockets and do not affect the
evaluation of the node tree.

The background color matches that of Frame nodes, with alternating shades
when nested inside frames to help distinguish the comment from its surroundings.


Editing Comments
================

.. figure:: /images/interface_controls_nodes_comment_editing.png
   :align: right

   Editing the text of a Comment node.

The text of a Comment node can be edited in several ways:

- Double-click the node.
- Select the node and press :kbd:`F2`.
- Hover over the node and press :kbd:`Return`.
- Click the :bl-icon:`greasepencil` icon on the node.
- Edit the text in the :menuselection:`Sidebar --> Node --> Properties` panel.

When not being edited, the comment is displayed with its Markdown formatting applied.


Text Formatting
===============

Comment nodes support basic Markdown syntax for formatting text.
For example:

.. code-block:: markdown

   # Main Heading

   ## Subheading

   **Bold text** and *italic text*.

   [Link to documentation](https://docs.blender.org/)

Markdown formatting is rendered directly within the node,
making it possible to create readable documentation without additional nodes.
