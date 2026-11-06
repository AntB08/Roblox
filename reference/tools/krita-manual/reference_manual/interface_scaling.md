## Interface Scaling 

Krita’s interface scale will automatically use the scaling of your screen set in your operating system. You can disable this behavior via the [Enable Hi-DPI support](preferences/general_settings.xhtml#hi-dpi-support) setting. 

You can also force a specific interface scale by setting the `QT_SCALE_FACTOR` environment variable. A value of `1` means 100%, `1.5` is 150% and so on. Values below 100% are unsupported.  

### Android Interface Scale 

On Android, you will be prompted to adjust the interface scale when Krita starts. Change the slider to make the interface larger and smaller. 100% is the minimum, you can’t make it smaller than that. 

After you’ve seen it once, Krita will show you the option to disable the dialog on startup. The option doesn’t appear the first time around to make sure you have a way out of setting a wrong scale by closing and reopening Krita. 

You can bring back the dialog manually via Settings ‣ Change Interface Scale… in the top menu bar. 

If you turn off the [Enable Hi-DPI support](preferences/general_settings.xhtml#hi-dpi-support) setting, the dialog will not be available until you re-enable the setting and restart Krita. 

>  

[img: ../_images/android_scaling_dialog.jpg]