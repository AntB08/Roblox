## [Unittests in Krita](#id6)  

Contents  
- 

[Unittests in Krita](#unittests-in-krita)  
- 

[What is a unit test is and why is it needed?](#what-is-a-unit-test-is-and-why-is-it-needed)  
- 

[Debugging of new code](#debugging-of-new-code) 
- 

[Changing/refactoring existing code](#changing-refactoring-existing-code) 
- 

[Automated regression testing](#automated-regression-testing)   
- 

[How to build and run tests?](#how-to-build-and-run-tests)  
- 

[Building the tests](#building-the-tests) 
- 

[Run all the tests](#run-all-the-tests) 
- 

[Run a single test](#run-a-single-test) 
- 

[Environment variables for running tests](#environment-variables-for-running-tests)   
- 

[When to write a unit test?](#when-to-write-a-unit-test) 
- 

[What should unit test include?](#what-should-unit-test-include) 
- 

[How to write a unittest?](#how-to-write-a-unittest) 
- 

[Krita-specific testing utils](#krita-specific-testing-utils)  
- 

[Fetching reference images](#fetching-reference-images) 
- 

[Compare test result against a reference QImage](#compare-test-result-against-a-reference-qimage) 
- 

[QImageBasedTest for complex actions](#qimagebasedtest-for-complex-actions) 
- 

[MaskParent object](#maskparent-object)        

### [What is a unit test is and why is it needed?](#id7)  Wiki:

A unit test is a piece of code that automatically checks if your class or subsystem works correctly. The goal of unit testing is to isolate each part of the program and show that the individual parts are correct. A unit test provides a strict, written contract that the piece of code must satisfy. As a result, it affords several benefits [[1]](#id5).  Comment:

In other words unit testing allows the developer to verify if his initial design decisions has been implemented correctly and all the corner-cases are handled correctly.   

In Krita Project we use unit tests for several purposes. Not all of them work equally good, but all together they help developing a lot.  

#### [Debugging of new code](#id8)  Wiki:

Unit testing finds problems early in the development cycle. This includes both bugs in the programmer’s implementation and flaws or missing parts of the specification for the unit. The process of writing a thorough set of tests forces the author to think through inputs, outputs, and error conditions, and thus more crisply define the unit’s desired behavior. The cost of finding a bug before coding begins or when the code is first written is considerably lower than the cost of detecting, identifying, and correcting the bug later; bugs may also cause problems for the end-users of the software [[1]](#id5).  Comment:

Krita is a big project and has numerous subsystems that communicate with each other in complicated ways. It makes debugging and testing new code in the application itself difficult. What is more, just compiling and running the entire application to check a one-line change in a small class is very time-consuming. So when writing a new subsystem we usually split it into smaller parts (classes) and test each of them individually. Testing a single class in isolation helps to catch all the corner-cases in the class public interface, e.g. “what happens if we pass 0 here instead of a valid pointer?” or “what if the index we just gave to this method is invalid?”     

#### [Changing/refactoring existing code](#id9)  Wiki:

Unit testing allows the programmer to refactor code or upgrade system libraries at a later date, and make sure the module still works correctly (e.g., in regression testing). The procedure is to write test cases for all functions and methods so that whenever a change causes a fault, it can be quickly identified. Unit tests detect changes which may break a design contract [[1]](#id5).  Comment:

Imagine someone decides to refactor the code you wrote a year ago. How would he know whether his changes didn’t break anything in the internal class structure? Even if he/she asks you, how would you know if the changes to a year-old class, whose details are already forgotten, are valid?     

#### [Automated regression testing](#id10) 

Most of our unit tests are run nightly on the CI. You can see the results and coverage reports at [https://build.kde.org/job/Extragear/job/krita/](https://build.kde.org/job/Extragear/job/krita/). 

However, some of the unit tests are not stable enough to be run automatically and therefore are disabled. (They do straightforward QImage comparisons, so the test results can depend no only on version of the libraries installed, but also on build options and even type of CPU the tests are run on.) While the overall coverage is decent, this issue limits the ability of the unit test suite to catch regressions in several parts of the codebase. (More information on that in the respective Phabricator task: [https://phabricator.kde.org/T11904](https://phabricator.kde.org/T11904).)    

### [How to build and run tests?](#id11)  

#### [Building the tests](#id12) 

To enable unit tests, build Krita with an additional cmake flag: `-DBUILD_TESTING=ON`. 

```
# example build command
you@yourcomputer:~/kritadev/build>cmake ../krita \
  -DCMAKE_INSTALL_PREFIX=$HOME/kritadev/install \
  -DCMAKE_BUILD_TYPE=Debug \
  -DKRITA_DEVS=ON \
  -DBUILD_TESTING=ON

```
  

 

See also  
- 

If you need help with building from source, see [Building Krita from Source](building_krita.xhtml#building-krita) 
- 

For more information about cmake options, please refer to [CMake Settings for Developers](cmake_settings_for_developers.xhtml#cmake-settings-for-developers)   

Once built, the tests are run from the **build** directory. There you can either run the whole suite at once or you can run a single test (or even a single test with a single data row for data-driven tests).   

#### [Run all the tests](#id13) 

```
# change to the build directory
you@yourcomputer:~/> cd kritadev/build
# run the whole suite
you@yourcomputer:~/kritadev/build> make test

```
    

#### [Run a single test](#id14) 

Every test class is built into a separate executable file. This executable file resides in the build directory tree. The relative path is the same as the path in source directory. 

To run all tests in a single test class, run the executable: 

```
# running all tests in a test class
you@yourcomputer:~/kritadev/build>./libs/ui/tests/KisSpinBoxSplineUnitConverterTest

```
  

You can also run a single test method from the class or invoke the test method with a single test data row, if you have a data-driven test. Add the test method name (and optionally the test data row name) as an argument to the test class executable: 

```
# the syntax for running single tests:
# you@yourcomputer:~/kritadev/build>./test-class-executable "test method name":"data row name"

# run a single method in a test class
you@yourcomputer:~/kritadev/build>./libs/ui/tests/KisSpinBoxSplineUnitConverterTest testCurveCalculationTwoWay

# run a single method in a test class with the selected test data row
you@yourcomputer:~/kritadev/build>./libs/ui/tests/KisSpinBoxSplineUnitConverterTest testCurveCalculationTwoWay:"0.5 in (0, 10) = 5"

```
    

#### [Environment variables for running tests](#id15) 

Prior to running the tests, you can set several environment variables to change the behavior of the tests.  
- 

Suppress safe assert dialogs: 

```
you@yourcomputer:~/kritadev/build> export KRITA_NO_ASSERT_MSG=1

```
   
- 

Set source directory for QImage-based test data 

```
you@yourcomputer:~/kritadev/build> export KRITA_UNITTESTS_DATA_DIR=<directory>

```
   
- 

Create reference images for QImage-based tests 

```
you@yourcomputer:~/kritadev/build> export KRITA_WRITE_UNITTESTS=1

```
       

### [When to write a unit test?](#id16) 

Ideally a unit test should be written for any new class that implements some logic and provides any kind of public interface. It is especially true if this public interface is going to be used more that one client-class.   

### [What should unit test include?](#id17)  
- 

corner cases. E.g. what happens if we request merging of two layers, one of which has Inherit Alpha option enabled? What properties and composition mode the final layer should have? Answers to these questions should be given and tested in the unit test. 
- 

non-obvious design decisions. E.g. if a paint device has a non-transparent default pixel, then its ``exactBounds()`` returns the rect, not smaller that the size of the image, even though technically the device might be empty.    

### [How to write a unittest?](#id18) 

Suppose you want to write a unittest for kritaimage library. You need to perform just a few steps:  
- 

Add files for the test class into `./image/tests/` directory: 

>  

`kis_some_class_test.h` 

```
#ifndef __KIS_SOME_CLASS_TEST_H
#define __KIS_SOME_CLASS_TEST_H

#include <QtTest/QtTest>

class KisSomeClassTest : public QObject
{
    Q_OBJECT
private Q_SLOTS:
    void test();
};

#endif /* __KIS_SOME_CLASS_TEST_H */</syntaxhighlight>

```
  

`kis_some_class_test.cpp` 

```
#include "kis_some_class_test.h"

#include <QTest>

void KisSomeClassTest::test()
{
}

QTEST_MAIN(KisSomeClassTest, GUI)</syntaxhighlight>

```
    
- 

Modify ./image/tests/CMakeLists.txt to include your new test class: 

>  

```
# ...
########### next target ###############
set(kis_some_class_test_SRCS kis_some_class_test.cpp )
ecm_add_tests(${kis_some_class_test_SRCS}
NAME_PREFIX "libs-somelib-"
LINK_LIBRARIES kritaimage Qt5::Test)
# ...

```
    
- 

Write your test. You can use any macro commands provided by Qt (QVERIFY, QCOMPARE or QBENCHMARK). 

>  

```
void KisSomeClassTest::test()
{
    QString cat("cat");
    QString dog("dog");

    QVERIFY(cat != dog);
    QCOMPARE(cat, "cat");
}

```
    
- 

Run your test by running an executable in ./image/test/ folder    

### [Krita-specific testing utils](#id19)  

#### [Fetching reference images](#id20) 

All the testing files/images are usually stored in the test’s data folder (e.g. ./krita/image/tests/data/). But there are some files which are used throughout all the unit tests. These files are stored in the global folder ./krita/sdk/tests/data/. If you want to access any file, just use `TestUtil::fetchDataFileLazy`. It first searches the file in the local test’s folder and if nothing is found checks the global folder. 

Example: 

```
QImage refImage(TestUtil::fetchDataFileLazy("lena.png"));
QVERIFY(!refImage.isNull());

```
    

#### [Compare test result against a reference QImage](#id21) 

There are two helper functions to compare a given QImage against an image saved in the data folder. 

```
bool TestUtil::checkQImage(const QImage &image, const QString &testName,
                           const QString &prefix, const QString &name,
                           int fuzzy = 0, int fuzzyAlpha = -1, int maxNumFailingPixels = 0);
bool TestUtil::checkQImageExternal(const QImage &image, const QString &testName,
                                   const QString &prefix, const QString &name,
                                   int fuzzy = 0, int fuzzyAlpha = -1, int maxNumFailingPixels = 0);

```
  

The functions search for a PNG file with path 

```
./tests/data/<testName>/<prefix>/<prefix>_<name>.png
# or without a subfolder
./tests/data/<testName>/<prefix>_<name>.png

```
  

The supplied QImage is compared against the saved PNG, and the result is returned to the caller. If the images do not coincide, two images are dumped into the current directory: one with actual result and another with what is expected. 

The second version of the function is different. It searches the image in “an external repository”. The point is that PNG images occupy quite a lot of space and bloat the repository size. So we decided to put all the images that are big enough (>10KiB) into an external SVN repository. To configure an external test files repository on your computer, please do the following:  
- 

Checkout the data repository: 

>  

```
# create the tests data folder and enter it
mkdir ~/testsdata
cd ~/testsdata

# checkout the extra repository
svn checkout svn+ssh://svn@svn.kde.org/home/kde/trunk/tests/kritatests

```
    
- 

Add environment variable pointing to your repository to your ~/.bashrc 

>  

`export KRITA_UNITTESTS_DATA_DIR= ~/testsdata/kritatests/unittests`   
- 

Use `TestUtil::checkQImageExternal` in your unittest and it will fetch data from the external source. If an external repository is not found then the test is considered “passed”.    

#### [QImageBasedTest for complex actions](#id22) 

Sometimes you need to test some complex actions like cropping or transforming the whole image. The main problem of such action is that it should work correctly with any kind of layer or mask, e.g. KisCloneLayer, KisGroupLayer or even KisSelectionMask. To facilitate such complex testing conditions, Krita provides a special class `QImageBasedTest`. It helps you to create a really complex image and check the contents of its layers. You can find the best example of its usage in `KisProcessingsTest`. Basically, to use this class, one should derive its own testing class from it, and call a set of callbacks, which do all the work. Let’s consider the code from KisProcessingsTest: 

```
// override QImageBasedTest class
class BaseProcessingTest : public TestUtil::QImageBasedTest
{
public:
    BaseProcessingTest()
        : QImageBasedTest("processings")
    {
    }

    // The method is called by test cases. If the test fails, a set of PNG images
    // is saved into working directory
    void test(const QString &testname, KisProcessingVisitorSP visitor) {

        // create an image and regenerate its projection
        KisSurrogateUndoStore *undoStore = new KisSurrogateUndoStore();
        KisImageSP image = createImage(undoStore);
        image->initialRefreshGraph();

        // check if the image is correct before testing anything
        QVERIFY(checkLayersInitial(image));

        // do the action we are trying to test
        KisProcessingApplicator applicator(image, image->root(),
                                        KisProcessingApplicator::RECURSIVE);

        applicator.applyVisitor(visitor);
        applicator.end();
        image->waitForDone();

        // check the result, and dump images if something went wrong
        QVERIFY(checkLayers(image, testname));

        // Check if undo(!) works correctly
        undoStore->undo();
        image->waitForDone();

        if (!checkLayersInitial(image)) {
            qWarning() << "NOTE: undo is not completely identical "
                    << "to the original image. Falling back to "
                    <<"projection comparison";
            QVERIFY(checkLayersInitialRootOnly(image));
        }
    }
};

```
    

#### [MaskParent object](#id23) 

`TestUtil::MaskParent` is a simple class that, in its constructor, creates an RGB8 image with a single paint layer, which you can use for further testing. The image and the layer can be accessed as simple member variables. 

Example: 

```
void KisMaskTest::testCreation()
{
    // create an image and a simple layer
    TestUtil::MaskParent p;

    // create a mask and attach its selection to the created layer
    TestMaskSP mask = new TestMask;
    mask->initSelection(p.layer);

    QCOMPARE(mask->extent(), QRect(0,0,512,512));
    QCOMPARE(mask->exactBounds(), QRect(0,0,512,512));
}

```
  

 

 [1] ([1](#id2),[2](#id3),[3](#id4)) 

[https://en.wikipedia.org/wiki/Unit_testing](https://en.wikipedia.org/wiki/Unit_testing)