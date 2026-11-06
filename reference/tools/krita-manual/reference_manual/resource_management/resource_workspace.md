## Workspaces 

Workspaces are basically saved configurations of dockers. Each workspace saves how the dockers are grouped and where they are placed on the screen. They allow you to easily move between workflows without having to manual reconfigure your setup each time. They can be as simple or as complex as you want. 

Workspaces can only be accessed via the toolbar or Window ‣ Workspaces There’s no docker for them. You can save workspaces, in which your current configuration is saved. You can also import them (from a `\*.kws` file), or delete them (which [deactivates](../resource_management.xhtml#deactivating-resources) them). 

Workspaces can technically be tagged, but outside of the resource manager this is not possible.  

### Window Layouts 

When you work with multiple screens, a single window with a single workspace won’t be enough. For multi monitor setups we instead can use sessions. Window layouts allow us to store multiple windows, their positions and the monitor they were on. 

You can access Window Layouts from the workspace drop-down in the toolbar.  Primary Workspace Follows Focus

This treats the workspace in the first window as the ‘primary’ workspace, and when you switch focus, it will switch the secondary windows to that primary workspace. This is useful when the secondary workspace is a very sparse workspace with few dockers, and the primary is one with a lot of different dockers.  Show Active Image In All Windows

This will synchronise the currently viewed image in all windows. Without it, different windows can open separate views for an image via Window ‣ New View ‣ document.kra.     

### Sessions 

Sessions allow Krita to store the images and windows opened. You can tell Krita to automatically save current or recover previous sessions if so configured in the [Miscellaneous](../preferences/general_settings.xhtml#misc-settings). 

You can access sessions from File ‣ Sessions.