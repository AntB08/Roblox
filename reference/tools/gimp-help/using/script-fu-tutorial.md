## A Script-Fu Tutorial

 Script-Fu
 Tutorial

 In this training course, we'll introduce you to the fundamentals of Scheme
 necessary to use Script-Fu, and then build a handy script that you can add
 to your toolbox of scripts. The script prompts the user for some text,
 then creates a new image sized perfectly to the text. We will then enhance
 the script to allow for a buffer of space around the text. We will
 conclude with a few suggestions for ways to ramp up your knowledge of
 Script-Fu.

 This section was adapted from a tutorial written for the
 GIMP 1 User
 Manual by Mike Terry.

## Getting Acquainted With Scheme

## Start with Scheme

 Scheme
 is a dialect of the Lisp family of programming languages. GIMP uses
 TinyScheme, which is a lightweight interpreter of a subset of the
 so-called R5RS standard.

The first thing to learn is that:

 Every statement in Scheme is surrounded by parentheses ().

The second thing you need to know is that:

 The function name/operator is always the first item in the
 parentheses, and the rest of the items are parameters to the
 function.

 However, not everything enclosed in parentheses is a function —
 they can also be items in a list — but we'll get to that later.
 This notation is referred to as prefix notation, because the function
 prefixes everything else. If you're familiar with postfix notation, or
 own a calculator that uses Reverse Polish Notation (such as most HP
 calculators), you should have no problem adapting to formulating
 expressions in Scheme.

The third thing to understand is that:

 Mathematical operators are also considered functions, and thus are
 listed first when writing mathematical expressions.

 This follows logically from the prefix notation that we just
 mentioned.

## Examples Of Prefix, Infix, And Postfix Notations

 Here are some quick examples illustrating the differences between
 prefix, infix, and
 postfix notations. We'll add a 1 and 23 together:

 Prefix notation: + 1 23
 (the way Scheme will want it)

 Infix notation: 1 + 23
 (the way we normally write it)

 Postfix notation: 1 23 +
 (the way many HP calculators will want it)

## Practicing In Scheme

 In GIMP, select

 Filters
 Development
 Script-Fu
 Script-Fu Console
 from the main menu.
 This will start up the Script-Fu Console window, which allows us to
 work interactively in Scheme.

## The Script-Fu Console Window

 At the bottom of this window is a text entry field for commands.
 Here, we can test out simple Scheme commands interactively. Let's
 start out easy, and add some numbers:

 (+ 3 5)

 Typing this in and hitting Enter
 yields the expected answer of 8 in the center window.

## Use Script-Fu Console.

 The + function can take more arguments, so we can add
 more than one number:

 (+ 3 5 6)

This also yields the expected answer of 14.

 So far, so good — we type in a Scheme statement and it's executed
 immediately in the Script-Fu Console window. Now for a word of
 caution…

## Watch Out For Extra Parentheses

 If you're like me, you're used to being able to use extra parentheses
 whenever you want to — like when you're typing a complex
 mathematical
 equation and you want to separate the parts by parentheses to make it
 clearer when you read it. In Scheme, you have to be careful and not
 insert these extra parentheses incorrectly. For example, say we wanted
 to add 3 to the result of adding 5 and 6 together:

 3 + (5 + 6) + 7 = ?

 Knowing that the + operator can take a list of numbers to add, you
 might be tempted to convert the above to the following:

 (+ 3 (5 6) 7)

 However, this is incorrect — remember, every statement in Scheme
 starts and ends with parens, so the Scheme interpreter will think that
 you're trying to call a function named 5 in the second
 group of parens, rather than summing those numbers before adding them
 to 3.

The correct way to write the above statement would be:

 (+ 3 (+ 5 6) 7)

## Make Sure You Have The Proper Spacing, Too

 If you are familiar with other programming languages, like C/C++, Perl
 or Java, you know that you don't need white space around mathematical
 operators to properly form an expression:

 3+5, 3 +5, 3+ 5

 These are all accepted by C/C++, Perl and Java compilers. However, the
 same is not true for Scheme. You must have a space after a
 mathematical operator (or any other function name or operator) in
 Scheme for it to be correctly interpreted by the Scheme interpreter.

 Practice a bit with simple mathematical equations in the Script-Fu
 Console until you're totally comfortable with these initial concepts.

## Variables And Functions

 Now that we know that every Scheme statement is enclosed in parentheses,
 and that the function name/operator is listed first, we need to know how
 to create and use variables, and how to create and use functions. We'll
 start with the variables.

## Declaring Variables

 Although there are a couple of different methods for declaring
 variables, the preferred method is to use the let*
 construct. If
 you're familiar with other programming languages, this construct is
 equivalent to defining a list of local variables and a scope in which
 they're active. As an example, to declare two variables, a and b,
 initialized to 1 and 2, respectively, you'd write:

 (let*
 (
 (a 1)
 (b 2)
 )
 (+ a b)
 )

or, as one line:

 (let* ( (a 1) (b 2) ) (+ a b) )

 You'll have to put all of this on one line if you're using the
 console window. In general, however, you'll want to adopt a similar
 practice of indentation to help make your scripts more readable.
 We'll talk a bit more about this in the section on White Space.

 This declares two local variables, a and b, initializes them, then
 prints the sum of the two variables.

## What Is A Local Variable?

 You'll notice that we wrote the summation (+ a b) within
 the parens of the let* expression, not after it.

 This is because the let*
 statement defines an area in your script in which the declared
 variables are usable; if you type the (+ a b)
 statement after the (let* …) statement,
 you'll get an error, because the declared
 variables are only valid within the context of the let*
 statement; they are what programmers call local variables.

## The General Syntax Of let*

The general form of a let* statement is:

 (let* ( variables )
 expressions )

 where variables are declared within parens, e.g.,
 (a 2), and
 expressions are any valid Scheme expressions. Remember that the
 variables declared here are only valid within the
 let* statement — they're local variables.

## White Space

 Previously, we mentioned the fact that you'll probably want to use
 indentation to help clarify and organize your scripts. This is a good
 policy to adopt, and is not a problem in Scheme — white space is
 ignored by the Scheme interpreter, and can thus be liberally applied
 to help clarify and organize the code within a script. However, if
 you're working in Script-Fu's Console window, you'll have to enter an
 entire expression on one line; that is, everything between the opening
 and closing parens of an expression must come on one line in the
 Script-Fu Console window.

## Assigning A New Value To A Variable

 Once you've initialized a variable, you might need to change its value
 later on in the script. Use the set! statement to change
 the variable's value:

 (let* ( (theNum 10) ) (set! theNum (+ theNum theNum)) )

 Try to guess what the above statement will do, then go ahead and enter
 it in the Script-Fu Console window.

## Functions

 Now that you've got the hang of variables, let's get to work with some
 functions. You declare a function with the following syntax:

 (define
 (
 name
 param-list
 )
 expressions
 )

 where name is the name assigned to this
 function, param-list is a space-delimited
 list of parameter names, and expressions
 is a series of expressions that the function executes when it's
 called. For example:

 (define (AddXY inX inY) (+ inX inY) )

 AddXY is the function's name and
 inX and inY
 are the variables. This function takes its two parameters and adds
 them together.

 If you've programmed in other imperative languages (like C/C++, Java,
 Pascal, etc.), you might notice that a couple of things are absent in
 this function definition when compared to other programming languages.

 First, notice that the parameters don't have any
 types (that is,
 we didn't declare them as strings, or integers, etc.). Scheme is a
 type-less language. This is handy and allows for quicker script
 writing.

 Second, notice that we don't need to worry about how to
 return the result of our function — the last
 statement is the value returned when calling this
 function. Type the function into the
 console, then try something like:

 (AddXY (AddXY 5 6) 4)

## Lists, Lists And More Lists

 We've trained you in variables and functions, and now enter the
 murky swamps of Scheme's lists.

## Defining A List

 Before we talk more about lists, it is necessary that you know
 the difference between atomic values and lists.

 You've already seen atomic values when we initialized
 variables in the previous lesson. An atomic value is a single
 value. So, for example, we can assign the variable
 x the
 single value of 8 in the following statement:

 (let* ( (x 8) ) x)

 (We added the expression x at the end to print out
 the value assigned to x—normally you won't
 need to do this. Notice how let* operates just like a
 function: The value of the last statement is the value returned.)

 A variable may also refer to a list of values, rather than a
 single value. To assign the variable x the
 list of values 1, 3, 5, we'd type:

 (let* ( (x '(1 3 5))) x)

 Try typing both statements into the Script-Fu Console and
 notice how it replies. When you type the first statement in,
 it simply replies with the result:

 8

 However, when you type in the other statement, it replies with
 the following result:

 (1 3 5)

 When it replies with the value 8 it is informing you that
 x contains the atomic value 8. However,
 when it replies with (1 3 5), it is
 then informing you that
 x contains not a single value, but a list
 of values. Notice that there are no commas in our declaration
 or assignment of the list, nor in the printed result.

The syntax to define a list is:

 '(a b c)

 where a, b, and
 c are literals. We use the apostrophe
 (')
 to indicate that what follows in the parentheses is a list of
 literal values, rather than a function or expression.

An empty list can be defined as such:

 '()

or simply:

 ()

Lists can contain atomic values, as well as other lists:

(let*
 (
 (x
 '("GIMP" (1 2 3) ("is" ("great" () ) ) )
 )
 )
 x
)

 Notice that after the first apostrophe, you no longer need to use an
 apostrophe when defining the inner lists. Go ahead and copy the
 statement into the Script-Fu Console and see what it returns.

 You should notice that the result returned is not a list of
 single, atomic values; rather, it is a list of a literal
 ("GIMP"), the list (1 2 3), etc.

## How To Think Of Lists

 It's useful to think of lists as composed of a head
 and a tail.
 The head is the first element of the list, the tail the rest of the
 list. You'll see why this is important when we discuss how to add to
 lists and how to access elements in the list.

## Creating Lists Through Concatenation (The Cons Function)

 One of the more common functions you'll encounter is the cons
 function. It takes a value and places it to its second argument, a
 list. From the previous section, I suggested that you think of a list
 as being composed of an element (the head) and the remainder of the
 list (the tail). This is exactly how cons functions — it adds an
 element to the head of a list. Thus, you could create a list as
 follows:

 (cons 1 '(2 3 4) )

The result is the list (1 2 3 4).

You could also create a list with one element:

 (cons 1 () )

 You can use previously declared variables in place of any literals, as
 you would expect.

## Defining A List Using The list Function

 To define a list composed of literals or previously declared
 variables, use the list function:

 (list 5 4 3 a b c)

 This will compose and return a list containing the values held
 by the variables a, b
 and c. For example:

 (let* (
 (a 1)
 (b 2)
 (c 3)
 )

 (list 5 4 3 a b c)
 )

 This code creates the list (5 4 3 1 2 3).

## Accessing Values In A List

 To access the values in a list, use the functions
 car and cdr,
 which return the first element of the list and the rest of the list,
 respectively. These functions break the list down into the head::tail
 construct I mentioned earlier.

## The car Function

 car returns the first element of the list (the
 head of the list). The list needs to be non-null (not empty). Thus, the
 following returns the first element of the list:

 (car '("first" 2 "third"))

which is:

 "first"

## The cdr function

 cdr returns the remainder of the list after the
 first element (the tail of the list). If there is only one element in
 the list, it returns an empty list.

 (cdr '("first" 2 "third"))

returns:

 (2 "third")

whereas the following:

 (cdr '("one and only"))

returns:

 ()

## Accessing Other Elements In A List

 OK, great, we can get the first element in a list, as well as
 the rest of the list, but how do we access the second, third
 or other elements of a list? There exist several "convenience"
 functions to access, for example, the head of the head of the
 tail of a list (caadr), the tail of the tail of a
 list (cddr), etc.

 The basic naming convention is easy: The a's and d's represent
 the heads and tails of lists, so

 (car (cdr (car x) ) )

could be written as:

 (cadar x)

 To get some practice with list-accessing functions, try typing in the
 following (except all on one line if you're using the console); use
 different variations of car and
 cdr to access the different elements of the list:

 (let* (
 (x '( (1 2 (3 4 5) 6) 7 8 (9 10) )
 )
 )
 ; place your car/cdr code here
 )

 Try accessing the number 3 in the list using only two function
 calls. If you can do that, you're on your way to becoming a
 Script-Fu Master!

 In Scheme, a semicolon (;) marks the beginning of a
 comment. It, and everything that follows it on the same line, are
 ignored by the script interpreter, so you can use this to add
 comments to refresh your memory when you look at the script later.

## Your First Script-Fu Script

 Do you not need to stop and catch your breath? No? Well then,
 let's proceed with your fourth lesson — your first Script-Fu
 Script.

## Creating A Text Box Script

 One of the most common operations I perform in GIMP
 is creating a box with some text in it for a web page, a logo or
 whatever. However, you never quite know how big to make the
 initial image when you start out. You don't know how much
 space the text will fill with the font and font size you
 want.

 This problem can be solved and automated with Script-Fu.

 We will, therefore, create a script, called Text Box, which
 creates an image correctly sized to fit snugly around a line
 of text the user inputs. We'll also let the user choose the
 font, font size and text color.

## Editing And Storing Your Scripts

 Up until now, we've been working in the Script-Fu Console. Now,
 however, we're going to switch to editing script files. Script files
 should be plain text files that you can edit in a text or code editor.
 The name you give is not that important, except for being able to
 recognize the script. You should give your script file the extension
 .scm.

 Where you place your scripts is a matter of preference. In GIMP's
 folder preferences
 you can see in which folders GIMP looks for scripts. It is also possible
 to add a new folder there.
 The folder where GIMP stores its own scripts is usually not the best
 choice for your scripts, but for the rest feel free to choose
 what suits you best.

## The Bare Essentials

 Every Script-Fu script defines at least one function, which is the
 script's main function. This is where you do the work.

 Every script must also register with the procedural database, so you
 can access it within GIMP.

We'll define the main function first:

 (define (script-fu-text-box inText inFont inFontSize inTextColor))

 Here, we've defined a new function called
 script-fu-text-box that
 takes four parameters, which will later correspond to some text, a
 font, the font size, and the text's color. The function is currently
 empty and thus does nothing. So far, so good — nothing new,
 nothing fancy.

## Naming Conventions

 Scheme's naming conventions seem to prefer lowercase letters with
 hyphens, which I've followed in the naming of the function. However,
 I've departed from the convention with the parameters. I like more
 descriptive names for my parameters and variables, and thus add the
 "in" prefix to the parameters so I can quickly see that they're values
 passed into the script, rather than created within it. I use the
 prefix "the" for variables defined within the script.

 It's GIMP convention to name your script functions
 script-fu-abc,
 because then when they're listed in the procedural database, they'll
 all show up under Script-Fu when you're listing the functions. This
 also helps distinguish them from plug-ins.

## Registering The Function

 Now, let's register the function with GIMP. This is
 done by calling the function script-fu-register.
 When GIMP reads in a
 script, it will execute this function, which registers the
 script with the procedural database. You can place this
 function call wherever you wish in your script, but I usually
 place it at the end, after all my other code.

 Here's the listing for registering this function (I will
 explain all its parameters in a minute):

 /Filters/Tutorial")
 ]]>

 Save these functions in a text file with a
 .scm suffix in a subdirectory
 of your script directory, with the same name as your script file, then
 restart GIMP.
 The new script will appear as

 Filters
 Tutorial
 Text Box
 .

 If you invoke this new script, it won't do anything, of course, but
 you can view the prompts you created when registering the script (more
 information about what we did is covered next).

 Finally, if you invoke the Procedure Browser (

 Help
 Procedure Browser
 ),
 you'll notice that our script now appears in the database.

## Steps For Registering The Script

 To register our script with GIMP, we call the
 function script-fu-register, fill in the seven
 required parameters and add our script's own parameters, along with a
 description and default value for each parameter.

## The Required Parameters

 The name of the function we
 defined. This is the function called when our script is invoked
 (the entry-point into our script). This is necessary because we may
 define additional functions within the same file, and
 GIMP needs to
 know which of these functions to call. In our example, we only
 defined one function, text-box, which we registered.

 The menu label is the name that will be
 shown in the menu. To specify the location, see
 .

 A description of your
 script, to be displayed in the Procedure Browser.

 Your name (the author of the script).

Copyright information.

 The date the script was
 made, or the last revision of the script.

 The types of images the script
 works on. This may be any of the following: RGB, RGBA, GRAY,
 GRAYA, INDEXED, INDEXEDA. Or it may be none
 at all — in our case,
 we're creating an image, and thus don't need to define the type of
 image on which we work.

## Registering The Script's Parameters

 Once we have listed the required parameters, we then need to list the
 parameters that correspond to the parameters our script needs. When we
 list these params, we give hints as to what their types are. This is
 for the dialog which pops up when the user selects our script. We also
 provide a default value.

 This section of the registration process has the following format:

Param Type

Description

Example

SF-IMAGE

 If your script operates on an open image, this should be the
 first parameter after the required parameters.
 GIMP will
 pass in a reference to the image in this parameter.

3

SF-DRAWABLE

 If your script operates on an open image, this should be the
 second parameter after the SF-IMAGE
 param. It
 refers to the active layer. GIMP will pass
 in a reference to the active layer in this parameter.

17

SF-STRING

Accepts strings.

"Some text"

SF-COLOR

 Indicates that a color is requested in this parameter.

'(0 102 255)

SF-TOGGLE

 A checkbox is displayed, to get a Boolean value.

TRUE or FALSE

## Registering the Menu Location

 Once we have registered our script, we need to tell GIMP where it
 should be found in the menu.

 The best menu location of your script depends on its function. Most
 scripts are found in the Filters and
 Colors menus.

 For the current script, which creates a new image, we choose a submenu
 of

 Filters
 Tutorial
 .
 This is what the line with the script-fu-menu-register
 function does.
 Thus, we registered our Text Box script here:

 Filters
 Tutorial
 Text Box
 .

 Any submenu that you specify in your script that doesn't exist yet
 will be automatically created by GIMP.

## Adding Additional Functionality

 Let us continue with our training and add some functionality to our
 script.

## Creating A New Image

 In the previous lesson, we created an empty function and registered it
 with GIMP. In this lesson, we want to provide
 functionality to our script — we want to create a new image,
 add the user's text to it and resize the image to fit the text exactly.

 Once you know how to set variables, define functions and access list
 members, the rest is all downhill — all you need to do is
 familiarize yourself with the functions available in
 GIMP's procedural database and call those functions
 directly. Open the
 .

 Let's begin by making a new image. We'll create a new variable,
 theImage, set to the result of calling
 GIMP's
 built-in function gimp-image-new.

 As you can see from the DB Browser, the function
 gimp-image-new takes three parameters — the
 image's width, height and the type of image. Because we'll
 later resize the image to fit the text, we'll make a 10×10 pixels
 RGB
 image. We'll store the image's width and sizes in some
 variables, too, as we'll refer to and manipulate them later in
 the script.

 (define (script-fu-text-box inText inFont inFontSize inTextColor)
 (let*
 (
 ; define our local variables
 ; create a new image:
 (theImageWidth 10)
 (theImageHeight 10)
 (theImage (car
 (gimp-image-new
 theImageWidth
 theImageHeight
 RGB
 )
 )
 )
 (theText) ;a declaration for the text
 ;we create later

 Note: We used the value RGB to specify that the image
 is an RGB image. We could have also used
 0, but RGB is more descriptive
 when we glance at the code.

 You should also notice that we took the head of the result of the
 function call. This may seem strange, because the database explicitly
 tells us that it returns only one value — the ID of the newly
 created image. However, all GIMP functions return a
 list, even if there is
 only one element in the list, so we need to get the head of the list.

## Adding A New Layer To The Image

 Now that we have an image, we need to add a layer to it. We'll
 call the gimp-layer-new function to create the
 layer, passing
 in the ID of the image we just created. (From now on, instead
 of listing the complete function, we'll only list the lines
 we're adding to it. You can see the complete script
 here.)
 Because we've declared all of the local variables we'll use,
 we'll also close the parentheses marking the end of our
 variable declarations:

 ;create a new layer for the image:
 (theLayer
 (car
 (gimp-layer-new
 theImage
 "layer 1"
 theImageWidth
 theImageHeight
 RGB-IMAGE
 100
 LAYER-MODE-NORMAL
 )
 )
 )
 ) ;end of our local variables

Once we have the new layer, we need to add it to the image:

 (gimp-image-insert-layer theImage theLayer 0 0)

 Now, just for fun, let's see the fruits of our labors up until this
 point, and add this line to show the new, empty image:

 (gimp-display-new theImage)

 Save your work, restart GIMP,
 run the script and a new image should pop up. It will probably
 contain garbage (random colors), because we haven't erased
 it. We'll get to that in a second.

## Adding The Text

 Go ahead and remove the line to display the image (or comment
 it out with a (;) as the first character of the line).

 Before we add text to the image, we need to set the background
 and foreground colors so that the text appears in the color
 the user specified. We'll use the
 gimp-context-set-back/foreground functions:

 (gimp-context-set-background '(255 255 255) )
 (gimp-context-set-foreground inTextColor)

 With the colors properly set, let's now clean out the garbage
 currently in the image by filling the drawable with the background
 color:

 (gimp-drawable-fill theLayer FILL-BACKGROUND)

With the image cleared, we're ready to add some text:

 (set! theText
 (car
 (gimp-text-font
 theImage theLayer
 0 0
 inText
 0
 TRUE
 inFontSize
 inFont)
 )
 )

 Although a long function call, it's fairly straightforward if
 you go over the parameters while looking at the function's
 entry in the DB Browser. Basically, we're creating a new text
 layer and assigning it to the variable
 theText.

 Now that we have the text, we can grab its width and height and resize
 the image and the image's layer to the text's size:

 (set! theImageWidth (car (gimp-drawable-get-width theText) ) )
 (set! theImageHeight (car (gimp-drawable-get-height theText) ) )

 (gimp-image-resize theImage theImageWidth theImageHeight 0 0)

 (gimp-layer-resize theLayer theImageWidth theImageHeight 0 0)

 If you're like me, you're probably wondering what a drawable is when
 compared to a layer. The difference between the two is that a drawable
 is anything that can be drawn into, including layers but also
 channels, layer masks, the selection, etc; a layer is a more specific
 version of a drawable. In most cases, the distinction is not
 important.

 With the image ready to go, we can now re-add our display line:

 (gimp-display-new theImage)

 Save your work, restart GIMP and give your first
 script a run!

## Clearing The Dirty Flag

 If you try to close the image created without first saving the file,
 GIMP will ask you if you want to save your work
 before you close the
 image. It asks this because the image is marked as dirty, or unsaved.
 In the case of our script, this is a nuisance for the times when we
 simply give it a test run and don't add or change anything in the
 resulting image — that is, our work is easily reproducible in
 such a simple script, so it makes sense to get rid of this dirty flag.

 To do this, we can clear the dirty flag after displaying the image:

 (gimp-image-clean-all theImage)

 This will set dirty count to 0, making it appear to be a
 clean image.

 Whether to add this line or not is a matter of personal taste. I use
 it in scripts that produce new images, where the results are trivial,
 as in this case. If your script is very complicated, or if it works on
 an existing image, you will probably not want to use this function.

## Extending The Text Box Script

## Handling Undo Correctly

 When creating a script, you want to give your users the ability to
 undo their actions, should they make a mistake. This is easily
 accomplished by calling the functions
 gimp-image-undo-group-start
 and gimp-image-undo-group-end
 around the code that manipulates the image. You can think of them as
 matched statements that let GIMP know when to start
 and stop recording manipulations on the image, so that those
 manipulations can later be undone.

 If you are creating a new image entirely, it doesn't make sense to use
 these functions because you're not changing an existing image.
 However, when you are changing an existing image, you most surely want
 to use these functions.

 Undoing a script works nearly flawlessly when using these functions.

## Extending The Script A Little More

 Now that we have a very handy-dandy script to create text
 boxes, let's add two features to it:

 Currently, the image is resized to fit exactly around the
 text — there's no room for anything, like drop shadows or
 special effects (even though many scripts will automatically
 resize the image as necessary). Let's add a buffer around
 the text, and even let the user specify how much buffer to
 add as a percentage of the size of the resultant text.

 This script could easily be used in other scripts that work
 with text. Let's extend it so that it returns the image and
 the layers, so other scripts can call this script and use
 the image and layers we create.

## 
 Modifying The Parameters And The Registration Function

 To let the user specify the amount of buffer, we'll add a parameter to
 our function and the registration function:

 (define (script-fu-text-box inTest inFont inFontSize inTextColor inBufferAmount)
 (let*
 (
 ; define our local variables
 ; create a new image:
 (theImageWidth 10)
 (theImageHeight 10)
 (theImage (car
 (gimp-image-new
 theImageWidth
 theImageHeight
 RGB
 )
 )
 )
 (theText) ;a declaration for the text
 ;we create later

 (theBuffer) ;added

 (theLayer
 (car
 (gimp-layer-new
 theImage
 "layer 1"
 theImageWidth
 theImageHeight
 RGB-IMAGE
 100
 LAYER-MODE-NORMAL
 )
 )
 )
 ) ;end of our local variables

 [Code here]
 )

 /Filters/Tutorial")
 ]]>

## Adding The New Code

 We're going to add code in two places: right before we resize
 the image, and at the end of the script (to return the new
 image, the layer and the text).

 After we get the text's height and width, we need to resize
 these values based on the buffer amount specified by the
 user. We won't do any error checking to make sure it's in the
 range of 0-100% because it's not life-threatening, and because
 there's no reason why the user can't enter a value like
 200 as the percent of buffer to add.

 (set! theBuffer (* theImageHeight (/ inBufferAmount 100) ) )

 (set! theImageHeight (+ theImageHeight theBuffer theBuffer) )
 (set! theImageWidth (+ theImageWidth theBuffer theBuffer) )

 All we're doing here is setting the buffer based on the height of the
 text, and adding it twice to both the height and width of our new
 image. (We add it twice to both dimensions because the buffer needs to
 be added to both sides of the text.)

 Now that we have resized the image to allow for a buffer, we
 need to center the text within the image. This is done by
 moving it to the (x, y) coordinates of (theBuffer,
 theBuffer). I added this line after
 resizing the layer and the image:

 (gimp-layer-set-offsets theText theBuffer theBuffer)

 Go ahead and save your script, and try it out after restarting
 GIMP.

 All that is left to do is return our image, the layer, and the text
 layer. After displaying the image, we add this line:

 (list theImage theLayer theText)

 This is the last line of the function, making this list available to
 other scripts that want to use it.

 To use our new text box script in another script, we could write
 something like the following:

 (set! theResult (script-fu-text-box
 "Some text"
 "Charter" "30"
 '(0 0 0)
 "35"
 )
 )
 (gimp-image-flatten (car theResult))

 Congratulations, you are on your way to your Black Belt of Script-Fu!

## Your script and its working

## What you write

Below the complete script:

 /Filters/Tutorial")
 (define (script-fu-text-box inText inFont inFontSize inTextColor inBufferAmount)
 (let*
 (
 ; define our local variables
 ; create a new image:
 (theImageWidth 10)
 (theImageHeight 10)
 (theImage)
 (theImage
 (car
 (gimp-image-new
 theImageWidth
 theImageHeight
 RGB
 )
 )
 )
 (theText) ;a declaration for the text
 (theBuffer) ;create a new layer for the image
 (theLayer
 (car
 (gimp-layer-new
 theImage
 "layer 1"
 theImageWidth
 theImageHeight
 RGB-IMAGE
 100
 LAYER-MODE-NORMAL
 )
 )
 )
 ) ;end of our local variables
 (gimp-image-insert-layer theImage theLayer 0 0)
 (gimp-context-set-background '(255 255 255) )
 (gimp-context-set-foreground inTextColor)
 (gimp-drawable-fill theLayer FILL-BACKGROUND)
 (set! theText
 (car
 (gimp-text-font
 theImage theLayer
 0 0
 inText
 0
 TRUE
 inFontSize
 inFont)
 )
 )
 (set! theImageWidth (car (gimp-drawable-get-width theText) ) )
 (set! theImageHeight (car (gimp-drawable-get-height theText) ) )
 (set! theBuffer (* theImageHeight (/ inBufferAmount 100) ) )
 (set! theImageHeight (+ theImageHeight theBuffer theBuffer) )
 (set! theImageWidth (+ theImageWidth theBuffer theBuffer) )
 (gimp-image-resize theImage theImageWidth theImageHeight 0 0)
 (gimp-layer-resize theLayer theImageWidth theImageHeight 0 0)
 (gimp-layer-set-offsets theText theBuffer theBuffer)
 (gimp-floating-sel-to-layer theText)
 (gimp-display-new theImage)
 (list theImage theLayer theText)
 )
 )
 ]]>

## What you obtain

## The dialog

## The resulting image