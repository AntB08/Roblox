## A Python plug-in writing Tutorial

 Python
 Tutorial

 This tutorial will teach you the basics about writing a Python plug-in for
 GIMP 3.0. You are expected to already have some basic knowledge about
 writing Python in general. If not, there are enough Python courses online,
 we are not going to duplicate them here.

 GIMP plug-ins in Python (and other languages too) are called from within
 GIMP to perform certain actions. To be able to know how to communicate with,
 and call the plug-in, GIMP needs to know by what name to call it and what
 functions it supports.

 There are certain requirements regarding a plug-in's filename and directory
 name, which have to be the same. For more details see
 Installing New Plug-Ins.

## The basic elements of a plug-in for GIMP

 We will discuss the basic parts of a plug-in that are required, or at
 least very common for working with GIMP.

 Required on Linux and macOS, and common practice on Windows, is to
 start with a so-called shebang or hashbang, an encoding, and
 a copyright notice.
 The first line is a
 shebang,
 which specifies how this script can be executed.
 The next line specifies the encoding of the
 Python file. We recommend utf-8. Usually this is followed by several
 lines specifying the license under which you publish the script and
 a short description of what the script does. We will not go deeper
 into this, since this is common to Python in general.

 Importing required modules to get access to GIMP and
 optionally GEGL functions.

 Declare a class with several pre-defined functions that you need to
 adjust, so that GIMP knows what functions are available in your
 plug-in, and what functionality they support. We will go into more
 detail about this below.

 A call that starts your plug-in, or queries its capabilities,
 depending on the arguments sent to it by GIMP.

## Required modules

 To be able to access GIMP functions, we start with
 import gi. This module can figure out what
 functions are available in each module defined through object
 introspection. What this means for us, is that we import all
 GIMP related modules that we may need through calls to
 gi.repository.

 For basic functionality, only the Gimp and GimpUi modules may be
 enough. If you want to run your plug-in from the command line, you
 don't even need GimpUi. Let's start with an example.

 .

import sys

import gi
gi.require_version('Gimp', '3.0')
from gi.repository import Gimp
gi.require_version('GimpUi', '3.0')
from gi.repository import GimpUi
from gi.repository import GLib]]>

 We start with importing sys, which we need at the end for access to
 sys.argv, following that
 import gi tells Python that it needs to load
 the gi module. This module is used to enable access to GIMP specific
 functions through object introspection.

 In the next line we tell gi that we require GIMP's API version to
 be version 3.0. (This plug-in won't work with older versions of
 GIMP.) The following line requests to import all functions, classes,
 etc. from the Gimp module.

 The next two lines, do the same thing for GimpUi. GimpUi contains
 all the interface related elements for GIMP. If you plan to make
 a plug-in that is only going to be called from the command line, then
 you won't need this. We finish with importing GLib, which we need later
 for access to GLib.Error.

 There are other optional modules that you can use, too, like Gegl
 and many others, but we won't go into that here.

## Define your plug-in class

 GIMP needs to knows what functions are available, what functionality
 they support, and what menu location to use. For that we define a
 class that is derived from the Gimp.PlugIn
 class.

 A minimal plug-in needs at least the following functions defined
 in this class:

 A do_query_procedure method, which GIMP calls
 to find out the names of the procedures that can be called in
 this plug-in.

 A do_set_i18n method, which GIMP calls to
 find out if your plug-in supports translations.

 A do_create_procedure method, which GIMP
 calls to start one of your plug-ins functions.
 When this is called you should initialize certain information for
 GIMP. You start by creating a procedure that tells GIMP the name
 of the Python function to call to start your plug-in. Then you
 supply additional information, like what types of images your
 plug-in supports, where in the menu should your plug-in be found,
 and other optional settings.

 The actual function (called procedure by GIMP) that you specified
 above. We often call this run, but it can
 have any name allowed by Python. This function is where you will
 add your own code to apply your desired effects.

 We will go into a little more detail now. Not included below is
 the first part of the Python code that was shown above. This only
 shows the basic layout of your class.

 /Filters/Tutorial/')

 procedure.set_documentation("My first Python plug-in tryout",
 "My first Python 3 plug-in for GIMP 3",
 name)
 procedure.set_attribution("Your name", "Your name", "2023")

 return procedure

 def run(self, procedure, run_mode, image, drawables, config, run_data):
 Gimp.message("Hello world!")
 # do what you want to do, then, in case of success, return:
 return procedure.new_return_values(Gimp.PDBStatusType.SUCCESS, GLib.Error())]]>

 Let's take a closer look at do_query_procedures.
 In the line return [ "jb-plug-in-first-try" ]
 we tell GIMP what the name of our procedure is: we call it
 "jb-plug-in-first-try". This is the name that will be shown in GIMP's
 Procedure Browser.

 You can have more than one procedure defined in a plug-in. In that case,
 you would list all names, separated by a comma.

 It is good practice to start all your procedures with your initials
 or some other recognizable and unique tag. This way, it is less
 likely that your name will be the same as someone elses plug-in,
 which may confuse GIMP. Besides that, you are free to name it the
 way you like.

 Next we tell GIMP that we don't support translations by returning
 False in the call to do_set_i18n. What to do when
 you want your plug-in to be translated is beyond the scope of this
 tutorial.

 The do_create_procedure method is where most of
 the initializing for GIMP is done.

## Setting up do_create_procedure

 If you define more than one procedure in your plug-in, you first
 need to check the "name" parameter to see which procedure is being
 called by GIMP. We won't go into that here.

 To initialize your plug-in procedure, we first need to create it and
 fill in the name of our Python function that will do the actual
 work. We do that by calling
 Gimp.ImageProcedure.new.

 In this case we define the name of our plug-in as
 self.run. When we qualify our function
 with "self.", it means that it is a method inside our class.
 If you prefer, you can also define it as a regular function
 outside your class, in that case you would omit "self.".
 Naming it "run" is not required, you can give it any name
 that Python accepts.

 Next we will tell GIMP what types of images this plug-in can work
 with by calling
 procedure.set_image_types.
 In case the type of image doesn't matter, we use "*", which means
 all types supported by GIMP.
 Other examples:

 "RGB*,GRAY*", where the "*" here means we support
 both the versions with and without A(lpha) channel.

 "INDEXED", plug-in only works on indexed images, without alpha
 channel.

 "RGBA", plug-in only works on RGB image with alpha channel.

 Being able to start your plug-in from GIMP's menu is usually a good
 idea. We start by defining a descriptive label for the menu entry:
 procedure.set_menu_label.

 Followed by specifying where in the menu it should appear:
 procedure.add_menu_path.
 In this case we tell it to add our plug-in in the Filters menu,
 under the Tutorial category (submenu).

 If you like you can also add an extra help tip, by using
 procedure.set_documentation,
 and you can set your name as author of the plug-in by using
 procedure.set_attribution.

 The last line in create procedure is
 return procedure, which sends the information
 added above back to GIMP. Following this, GIMP will call your
 run procedure.

## Adding the main entry point to your plug-in

 Every plug-in gets started by a call to Gimp.main.

 The only thing you need to change in this line for your plug-in, is the
 name of your plug-in class, here called MyFirstPlugin.

## The complete Python plug-in

Below we present the entire python script, which should run,
 provided it is given the correct name in a directory with the same
 name in a location that GIMP knows of. It will show the message
 Hello world! in the error console or in a popup dialog.

 .

import sys

import gi
gi.require_version('Gimp', '3.0')
from gi.repository import Gimp
gi.require_version('GimpUi', '3.0')
from gi.repository import GimpUi

from gi.repository import GLib

class MyFirstPlugin (Gimp.PlugIn):
 def do_query_procedures(self):
 return [ "jb-plug-in-first-try" ]

 def do_set_i18n (self, name):
 return False

 def do_create_procedure(self, name):
 procedure = Gimp.ImageProcedure.new(self, name,
 Gimp.PDBProcType.PLUGIN,
 self.run, None)

 procedure.set_image_types("*")

 procedure.set_menu_label("My first Python plug-in")
 procedure.add_menu_path('/Filters/Tutorial/')

 procedure.set_documentation("My first Python plug-in tryout",
 "My first Python 3 plug-in for GIMP 3.0",
 name)
 procedure.set_attribution("Your name", "Your name", "2023")

 return procedure

 def run(self, procedure, run_mode, image, drawables, config, run_data):
 Gimp.message("Hello world!")
 # do what you want to do, then, in case of success, return:
 return procedure.new_return_values(Gimp.PDBStatusType.SUCCESS, GLib.Error())

Gimp.main(MyFirstPlugin.__gtype__, sys.argv)]]>