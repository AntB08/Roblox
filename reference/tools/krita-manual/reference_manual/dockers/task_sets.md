## Task Sets Docker 

Task sets are for sharing a set of steps, like a tutorial. You make them with the task-set docker. [img: ../../_images/Task-set.png] 

Task sets can record any kind of command also available via the shortcut manager. It is not a macro recorder, right now, Krita does not have that kind of functionality. 

The tasksets docker has a record button, and you can use this to record a certain workflow. All *Actions* can be recorded. These include every action available in the [Main Menu](../main_menu.xhtml#main-menu), but also all actions available via Ctrl + Enter. Then use this to let items appear in the taskset list. Afterwards, turn off record. You can then click any action in the list to make them happen. Press the Save icon to name and save the taskset. 

Task sets are a [resource](../resource_management.xhtml#resource-management). As such, they can be saved, tagged, reordered. They are stored as `*.kts` files, which are XML files: 

```
<Taskset name="example" version="1">
    <action>add_new_paint_layer</action>
    <action>add_new_clone_layer</action>
    <action>add_new_file_layer</action>
</Taskset>

```