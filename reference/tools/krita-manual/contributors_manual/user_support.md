## [Introduction to User Support](#id3)  

Contents  
- 

[Introduction to User Support](#introduction-to-user-support)  
- 

[Tablet Support](#tablet-support)  
- 

[Quick solutions](#quick-solutions) 
- 

[Gathering information](#gathering-information) 
- 

[Additional information for supporters](#additional-information-for-supporters)   
- 

[Animation](#animation) 
- 

[Onion skin issues](#onion-skin-issues) 
- 

[Crash](#crash) 
- 

[Other possible questions with quick solutions](#other-possible-questions-with-quick-solutions) 
- 

[Advice for supporters](#advice-for-supporters) 
- 

[How to share a file](#how-to-share-a-file)      

### [Tablet Support](#id4) 

The majority of help requests are about pen pressure and tablet support in general.  

#### [Quick solutions](#id5) 

 

Note 

With every change mentioned below you might need to restart your PC to see the effect.  

*For Windows, all devices:*  
- 

Change API in Settings ‣ Configure Krita… ‣ Tablet Settings. 

>  

 
- 

Wintab: older standard; it supports multiple buttons and high number of pressure levels. If it works fine for you, don’t change to Windows Ink. 2-in-1 devices by default use Windows Ink, you can get a Wintab driver but you need to install it separately. 
- 

Windows 8+ Pointer (Windows Ink): newer standard; it cuts the pressure levels to 1024. It is more suitable for 2-in-1 devices like Surface Pro and Yoga. Some less known brands might not have this standard implemented.     

*For Windows, tablet/digitizer devices (not convertible/2-in-1 ones):*  
- 

Reinstall your driver (Windows Update often breaks tablet driver settings, reinstallation helps). 
- 

*Wacom tablets:* if you get straight lines at the beginnings of the strokes, first try to update your driver: it should be fixed in 6.3.34-3. If it doesn’t work, disable/minimize “double-click distance” in Wacom settings. 
- 

*XP-Pen tablets, pressure being uneven:* either switch to Windows 8+ Pointer (Windows Ink) in Configure Krita ‣ Tablet Settings, or disable Windows Ink in XP-Pen settings.    

#### [Gathering information](#id6)  
- 

Which OS do you use? 
- 

Which tablet do you have? 
- 

What is the version of the tablet driver? 
- 

Please collect Tablet Tester (Configure Krita ‣ Tablet Settings ‣ Tablet Tester) text output and share it: [How to share a file](#intro-user-support-sharing-files). 
- 

More detailed Tablet Events log: 

>  

 
- 

Go to Settings ‣ Dockers ‣ Log Viewer docker, make sure it’s checked. 
- 

In the Log Viewer docker, make sure the first button is pressed (which means the logging is turned on). 
- 

Press Ctrl + Shift + T to turn on tablet events logging. 
- 

Make a few strokes (depending on the situation, the user supporter or developer can ask you for specific series of strokes). 
- 

Press Ctrl + Shift + T to turn off the logging of the tablet events. 
- 

Press the third button in the Log Viewer to save the output into a file. 
- 

Share the file or share the content of the file: [How to share a file](#intro-user-support-sharing-files).  

On Linux, you can just use a console instead of Log Viewer – then you’d only need to enable tablet events logging, not logging in general.      

#### [Additional information for supporters](#id7)  
- 

Except for the issue with beginnings of the strokes, Wacom tablets usually work no matter the OS. 
- 

Huion tablets should work on Windows and on Linux, on macOS there might be issues. 
- 

XP-Pen tablets and the rest of brands can have issues everywhere (on all systems). 
- 

If someone asks about a tablet to buy, generally a cheaper Wacom or a Huion are the best options. 
- 

[Possibly useful instruction in case of XP-Pen tablet issues](https://www.reddit.com/r/krita/comments/btzh72/xppen_artist_12s_issue_with_krita_how_to_fix_it/) [https://www.reddit.com/r/krita/comments/btzh72/xppen_artist_12s_issue_with_krita_how_to_fix_it/].     

### [Animation](#id8) 

Issues with rendering animation can be of various shapes and colors. First thing to find out is whether the issue happens on Krita’s or FFmpeg’s side (Krita saves all the frames, then FFmpeg is used to render a video using this sequence of images). To learn that, instruct the user to render as “Image Sequence”. If the image sequence is correct, FFmpeg (or more often: render options) are at fault. If the image sequence is incorrect, either the options are wrong (if for example not every frame got rendered), or it’s a bug in Krita. 

 

Note 

If the user opens the Log Viewer docker, turns on logging and then tries to render a video, Krita will print out the whole ffmpeg command to Log Viewer so it can be easily investigated.  

There is a log file called *log_encode.log* in the directory that user tries to render to. It can contain information useful to investigation of the issue (sharing files: [How to share a file](#intro-user-support-sharing-files)).   

### [Onion skin issues](#id9) 

The great majority of issues with onion skin are just user errors, not bugs. Nonetheless, you need to find out why it happens and direct the user how to use onion skin properly.   

### [Crash](#id10) 

In case of crash try to determine if the problem is known, if not, instruct user to create a bug report (or create it yourself) with following information:  
- 

What happened, what was being done just before the crash. 
- 

Is it possible to reproduce (repeat)? If yes, provide a step-by-step instruction to get the crash. 
- 

Backtrace (crashlog) – the instruction for Windows is here: [Dr. MinGW Debugger](../reference_manual/dr_minw_debugger.xhtml#dr-minw), and the debug symbols can be found in the announcement of the version of Krita that the user has. But it could be easier to just point the user to [https://download.kde.org/stable/krita](https://download.kde.org/stable/krita).    

### [Other possible questions with quick solutions](#id11)  
- 

When the user has any weird issue, something you’ve never heard about, ask them to reset the configuration: [Resetting Krita configuration](../KritaFAQ.xhtml#faq-reset-krita-configuration). 
- 

When the user on Windows has trouble with anything related to preview or display, ask them to change Canvas Graphics Acceleration in Settings ‣ Configure Krita ‣ Display. 

>  

 

Note 

Telling people to disable canvas acceleration to get better performance is something we shouldn’t do, ever.       

### [Advice for supporters](#id12)  
- 

If you don’t understand the question, ask for clarification – asking for a screen recording or a screenshot is perfectly fine. 
- 

If you don’t know the solution but you know what information will be needed to investigate the issue further, don’t hesitate to ask. Other supporters may know the answer, but have too little time to move the user through the whole process, so you’re helping a lot just by asking for additional information. This is very much true in case of tablet issues, for example. 
- 

If you don’t know the answer/solution and the question looks abandoned by other supporters, you can always ask for help on Krita IRC channel. It’s #krita on Libera.Chat: [The Krita Community](community.xhtml#the-krita-community). 
- 

Explain steps the user needs to make clearly, for example if you need them to change something in settings, clearly state the whole path of buttons and tabs to get there. 
- 

Instead of Settings ‣ Configure Krita… use just Configure Krita – it’s easy enough to find and macOS users (where you need to select Krita ‣ Preferences…) won’t get confused. 
- 

If you ask for an image, mention usage of [Imgur](https://imgur.com) [https://imgur.com] or [Pasteboard](https://pasteboard.co) [https://pasteboard.co] ([How to share a file](#intro-user-support-sharing-files)), otherwise Reddit users might create a new post with this image instead of including it to the old conversation. 
- 

If you want to quickly answer someone, just link to the appropriate place in this manual page – you can click on the little link icon next to the section or subsection title and give the link to the user so they for example know what information about their tablet issue you need.    

### [How to share a file](#id13)  
- 

Images (e.g. screenshots): [Imgur](https://imgur.com) [https://imgur.com] [*], [Pasteboard](https://pasteboard.co) [https://pasteboard.co] 
- 

Text only: [Pastebin](https://pastebin.com) [https://pastebin.com] [*], [BPaste](https://bpaste.net) [https://bpaste.net], [paste.ubuntu.org.cn](https://paste.ubuntu.org.cn) [https://paste.ubuntu.org.cn], [CentOS’s Pastebin Service](https://paste.centos.org/) [https://paste.centos.org/] or [KDE Snippets (needs KDE Identity)](https://invent.kde.org/dashboard/snippets) [https://invent.kde.org/dashboard/snippets]. 
- 

`.kra` and other formats: by mail? Or encode the file using *base64* command on Linux, send by mail or on Pastebin, then decode using the same command. 

 

Attention 

If you ask user to store their log or other data on a website, make sure it stays there long enough for you to get it – for example bpaste.net stores files by default only for a day! And you can extend it only to one week.  

 

Blocked websites 

If the user is behind a firewall of some sorts (for example lives in China), websites with [*] will probably be blocked; please use the alternatives.