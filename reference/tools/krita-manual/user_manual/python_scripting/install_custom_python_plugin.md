## Managing Python plugins  

### How to install a Python plugin 

 

Caution 

Custom Python plugins are made by users of Krita and the Krita team does not guarantee that they work, that they are useful or that they are *safe*. Note that a Python plugin can do everything that Krita can do, which means for example access to your files. Krita team isn’t responsible for any damage you might suffer from the plugin, and you install it on your own risk.   

#### Using Python plugin importer 

 

Note 

This method doesn’t always import action files (responsible for shortcuts) correctly.  

You need to ensure that you have the plugin in a `*.zip` file. Inside the zip file there should be a file `pluginname.desktop` and a folder `pluginname` (instead of `pluginname` there should be an actual unique name of the plugin). 

Go to Tools ‣ Scripts ‣ Import Python Plugin…, find the `*.zip` file and press OK. Restart Krita. 

Go to Configure Krita ‣ Python Plugins Manager, find the plugin and enable it. Restart Krita. 

Now the plugin should be available.   

#### Manually 

If the plugin is inside a `*.zip` archive, you need to extract it first. 

Go to Settings ‣ Manage Resources ‣ Open Resource Folder. Put file `pluginname.desktop` and folder `pluginname` (instead of `pluginname` there should be an actual unique name of the plugin) inside the `pykrita` folder. Put file `pluginname.action` into the `actions` folder. Restart Krita. 

Now the plugin should be available.    

### How to get to the plugin? 

Plugins in Krita are either dockers or extensions. 

If it’s an extension, it will be available in the menu Tools ‣ Scripts. 

When it’s a docker, you can find it in Settings ‣ Dockers. 

If the plugin has any shortcuts, and you imported the action file properly, you can change the shortcuts in Configure Krita ‣ Keyboard Shortcuts.   

### How to enable and disable a plugin? 

You can enable and disable all plugins (no matter if they’re pre-installed or custom) in Configure Krita ‣ Python Plugins Manager.