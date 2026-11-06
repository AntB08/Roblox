## [CMake Settings for Developers](#id2) 

The [CMake](https://www.cmake.org) [https://www.cmake.org] build system generators used by Krita is one of the most used build system generators in the C++ world. A build system is a system that describes how an application should be built from source code. CMake generates a build system from the information given in the CMakeLists.txt and *.cmake files. It is a complete but rather unusual language. 

If you start working on Krita, you will need knowledge of two things: how to run the cmake generator, and which variables are important there, and how to edit the CMakeLists.txt files. This page tells you how to run the cmake generator. 

The cmake generator is run like this: 

```
cmake -DSOME_CMAKE_VARIABLE=SOME_VALUE ../path/to/source

```
  

That is, every option is prefixed with -D, followed by a usually uppercase variable name, the equal sign and the value. The following variables are important for Krita. 

You cannot build Krita inside the source directory, so you need to give the path to the source directory, where the top-level CMakeLists.txt file is found.  

Contents  
- 

[CMake Settings for Developers](#cmake-settings-for-developers)  
- 

[BUILD_TESTING](#build-testing) 
- 

[CMAKE_INSTALL_PREFIX](#cmake-install-prefix) 
- 

[CMAKE_BUILD_TYPE](#cmake-build-type) 
- 

[CMAKE_PREFIX_PATH](#cmake-prefix-path) 
- 

[HIDE_SAFE_ASSERTS](#hide-safe-asserts) 
- 

[KRITA_DEVS](#krita-devs) 
- 

[PYQT_SIP_DIR_OVERRIDE](#pyqt-sip-dir-override) 
- 

[USE_LOCK_FREE_HASH_TABLE](#use-lock-free-hash-table) 
- 

[FOUNDATION_BUILD](#foundation-build) 
- 

[KRITA_ENABLE_BROKEN_TESTS](#krita-enable-broken-tests) 
- 

[LIMIT_LONG_TESTS](#limit-long-tests) 
- 

[ENABLE_PYTHON_2](#enable-python-2) 
- 

[BUILD_KRITA_QT_DESIGNER_PLUGINS](#build-krita-qt-designer-plugins)      

### [BUILD_TESTING](#id3) 

If set to ON, the unittests will be built. *All* developers should have this enabled! You run the unittests with ``make test``, or you can run them on their own from their location in the build tree.   

### [CMAKE_INSTALL_PREFIX](#id4) 

This determines where Krita will be installed to. By default this is ``/usr/local`` on Linux, which is not what you want.   

### [CMAKE_BUILD_TYPE](#id5) 

This has three options: Debug, RelWithDebInfo and Release. Developers should *always* use Debug, because otherwise ASSERTS will not fire, and developers should pay attention to asserts. Packagers should use RelWithDebInfo.   

### [CMAKE_PREFIX_PATH](#id6) 

This can be set to make the build system look for dependencies in other places than the default one.   

### [HIDE_SAFE_ASSERTS](#id7) 

If set to ON, Krita will not show popups whenever the code encounters a problem that developers need to know about, but users not. If set to OFF, Krita will popup a little message window telling you about the error, of OFF, it will print the information to the terminal. For developers, either is fine, at least, if you start Krita and pay attention to the terminal output. For packagers, it should be ON.   

### [KRITA_DEVS](#id8) 

This is to be used with the Debug CMAKE_BUILD_TYPE, to re-enable optimizations that make it possible to actually work with Krita. By default, Debug disables all compiler optimizations, and Krita needs those.   

### [PYQT_SIP_DIR_OVERRIDE](#id9) 

If you have built your own PyQt and SIP, use this to make sure Krita can find them.   

### [USE_LOCK_FREE_HASH_TABLE](#id10) 

This option enables the experimental lock free hash table. This is ON by default at the moment.   

### [FOUNDATION_BUILD](#id11) 

This option is for packaging Krita on systems that do not have the default color themes shipped by KDE Plasma.   

### [KRITA_ENABLE_BROKEN_TESTS](#id12) 

A number of unittests are known to be broken. They should be fixed, but in the meantime, having dozens of failing unittests hides regressions. Set this to ON to run the broken tests. These tests are always built.   

### [LIMIT_LONG_TESTS](#id13) 

When set to ON, the default, some unittests will be cut short. Set to OFF to test for stress conditions.   

### [ENABLE_PYTHON_2](#id14) 

Use Python 2 instead of Python 3. Only to be used when integrating Krita in a python2-based VFX pipeline.   

### [BUILD_KRITA_QT_DESIGNER_PLUGINS](#id15) 

OFF by default, enable this to build plugins for Qt Designer/Qt Creator so you can add Krita specific widgets to .ui files.