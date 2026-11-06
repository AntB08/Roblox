%entities;
]>

## Plug-Ins

 Plug-ins
 Introduction

## Introduction

 One of the nicest things about GIMP is how easily its
 functionality can be extended, by using plug-ins.
 GIMP plug-ins are external programs that run under the
 control of the main GIMP application and interact
 with it very closely. Plug-ins can manipulate images in almost any way
 that users can. Their advantage is that it is much easier to add a
 capability to GIMP by writing a small plug-in than by
 modifying the huge mass of complex code that makes up the
 GIMP core. Many valuable plug-ins have C source code
 that only comes to 100-200 lines or so.

 Several dozen plug-ins are included in the main GIMP
 distribution, and installed automatically along with
 GIMP. Most of them can be accessed through the
 Filters menu (in fact, everything in that menu is a
 plug-in), but a number are located in other menus. In many cases you can
 use one without ever realizing that it is a plug-in: for example, the
 "Normalize" function for automatic color correction is actually a
 plug-in, although there is nothing about the way it works that would tell
 you this. Even importing and exporting of images is done by plug-ins.

 Everyone can write a GIMP plug-in and make it available
 online. There are many useful plug-ins that can be obtained this way. Some
 of them are described elsewhere in the User's Manual.

 With this free availability comes a certain degree of risk. The fact that
 anyone can release plug-ins means that there is no effective quality
 control. The plug-ins distributed with GIMP have all
 been tested and tuned by the developers. Additional plug-ins available
 online, may have been hacked together in a few hours and then
 abandoned. Some plug-in creators don't care about robustness, and even for
 those who do, their ability to test on a variety of systems in a variety
 of situations is often quite limited. Basically, when you download a
 plug-in, you are getting something for free, and sometimes you get exactly
 what you pay for. This is not to discourage you, just to make sure you
 understand that not all plug-ins available online will deliver what you
 expect from them.

 Plug-ins, being full-fledged executable programs, can do all of the
 things that any other program can do. This includes installing
 back-doors on your system or otherwise compromise its security. Don't
 install a plug-in unless it comes from a trusted source.

 GIMP 3.0 needed to change its plug-in API in many
 places. Because of that, plug-ins written for older versions need to
 be updated and won't work without changes.

## Using Plug-Ins

 For the most part you can use a plug-in like any other
 GIMP tool, without needing to be aware that it is a
 plug-in. But there are a few things about plug-ins that are useful to
 understand.

 One is that plug-ins are generally not as robust as the
 GIMP core. When GIMP crashes, it
 is considered a very serious thing: it can cost the user a lot of
 trouble and headache. When a plug-in crashes, the consequences are
 usually not as serious. In most cases you can continue working
 without worrying about it too much.

 Because plug-ins are separate programs, they communicate with
 GIMP in a special way: The GIMP
 developers call it talking over a wire. When a plug-in
 crashes, the communication breaks down, and you may see an error
 message about a wire read error.

 When a plug-in crashes, GIMP gives you a very
 ominous-looking message telling you that the plug-in may have left
 GIMP in a corrupted state, and you should consider
 saving your images and exiting. Strictly speaking, this is quite
 correct, because plug-ins have the power to alter almost anything in
 GIMP, but for practical purposes, experience has
 shown that corruption is actually quite rare, and many users just
 continue working and don't worry about it. Our advice is that you
 simply think about how much trouble it would cause you if something
 went wrong, and weigh it against the odds.

 Because of the way plug-ins communicate with GIMP,
 they do not have any mechanism for being informed about changes you make
 to an image after the plug-in has been started. If you start a plug-in,
 and then alter the image using some other tool, the plug-in may crash.
 Even if it doesn't, doing this may cause incorrect results. You should
 avoid running more than one plug-in at a time on an image, and avoid
 doing anything to the image until the plug-in has finished working on it.
 If you ignore this advice, not only could you screw up the image, you
 may also screw up the undo system, so that you won't be able to recover
 from your mistake.

## Installing New Plug-Ins

 Plug-ins
 Install

 The plug-ins that are distributed with GIMP don't
 require installation. Plug-ins that you download yourself do.
 Usually the default location is in GIMP's user
 directory in a folder under /plug-ins, where the
 folder name needs to be the same as the plug-in filename.
 You can find the default locations where GIMP searches
 for plug-ins in the Data
 Folders preferences. There you can also add new locations where
 GIMP should look for plug-ins.
 There are several scenarios, depending on what OS you are using and how
 the plug-in is structured.

## Linux / Unix-like systems

 Most plug-ins fall into two categories: small ones whose source
 code is distributed as a single .c file, and larger ones whose
 source code is distributed as a directory containing multiple
 files including a Makefile.

 For a simple one-file plug-in, call it borker.c,
 installing it is just a matter of running the command
 gimptool-&gimp.app.version; --install borker.c. This command
 compiles the plug-in and installs it in your personal plug-in directory,
 ~/gimp-&gimp.app.version;/plug-ins unless you have changed it.
 This will cause it to be loaded automatically the next time you start
 GIMP. You don't need to be root to do these things;
 in fact, you shouldn't be. If the plug-in fails to compile, well, be
 creative.

## Windows

 Most GIMP plug-ins available on Windows supply either
 an installer, or can be downloaded in a pre-compiled binary format
 ready to copy to a folder of your choice that is recognized by
 GIMP.

 If an installer is available, that should do all the work for you
 selecting an appropriate folder and copying all relevant files.
 If not, you may have to check in GIMP's folder
 preferences where the plug-ins should be copied to. Remember, each
 plug-in needs to be in its own folder with the same name as the plug-in.

## Apple Mac OS X

 How you install plug-ins on OS X mostly depends on how you installed
 GIMP itself. If you were one of the brave and
 installed GIMP
 through one of the package managers like fink
 or darwinports
 , the
 plug-in installation works exactly the way it is described for the
 Linux platform already. The only difference is, that a couple of
 plug-ins might even be available in the repository of your package
 manager, so give it a try.

 If, on the other hand, you prefer to use a prebuilt
 GIMP package, you most likely want
 a prebuilt plug-in too. You can try to get a prebuilt version of
 the plug-in of your dreams from the author of the plug-in. Building your
 own binaries unfortunately involves installing GIMP.

## Running the installed plug-in

 Once you have installed the plug-in, how do you activate it? The menu
 path is determined by the plug-in itself, so to answer this you need to
 either look at the documentation for the plug-in (if there is any),
 explore the menus, or use GIMP's command search
 function by pressing / and then entering the name of the
 plug-in. If you know how to read source code you could also check that to
 see in what menu it registers itself.

 For more complex plug-ins, organized as a directory with multiple
 files, there usually is a file inside called either
 INSTALL or README, with
 instructions. If not, the best advice is to toss the plug-in in the
 trash and spend your time on something else: any code written with so
 little concern for the user is likely to be frustrating in myriad
 ways.

 If you install a plug-in in your personal plug-in directory that has the
 same name as one in the system plug-in directory, only one can be
 loaded, and it will be the one in your home directory. You will
 receive messages telling you this each time you start
 GIMP. This is probably a situation best avoided.

## Writing Plug-ins

 Plug-ins
 Write

 If you want to learn how to write a plug-in, you can find plenty of help
 at the GIMP Developers web site
 .
 GIMP is a complex
 program, but the development team has made strenuous efforts to flatten
 the learning curve for plug-in writing: there are good instructions and
 examples, and the main library that plug-ins use to interface with
 GIMP (called libgimp) has a
 well-documented API. Good programmers, learning by
 modifying existing plug-ins, are often able to accomplish interesting
 things after just a couple of days of work.