## Reporting Bugs and Requesting Enhancements

 GIMP
 Bugs

 Bugs

 Sad to say, no version of GIMP
 has yet been absolutely perfect. Even sadder, it is likely that no version
 ever will be. In spite of all efforts to make everything work, a program
 as complicated as GIMP
 is bound to screw things up occasionally, or even crash.

 But the fact that bugs are unavoidable does not mean that they should be
 passively accepted. If you find a bug in GIMP, the
 developers would like to know about it so they can at least try to fix it.

 Suppose, then, that you have found a bug, or at least think you have: you
 try to do something, and the results are not what you expect. What should
 you do? How should you report it?

 The procedure for making an enhancement
 request—that is, for asking the developers to add a
 missing feature—is the same as the procedure for reporting
 a bug.

 In common with many other free software projects,
 GIMP uses a bug-reporting mechanism called
 GitLab.
 This is a very powerful web-based system, capable of managing thousands
 of bug reports without losing track. In fact, GIMP
 shares its GitLab database with the entire Gnome project.

## Making sure it's a Bug

 The first thing you should do, before reporting a bug, is to make
 an effort to verify that what you are seeing really
 is a bug. It is hard to give a method for
 doing this that applies to all situations, but reading the
 documentation will often be useful, and discussing the question on
 IRC or on Discourse may also be quite helpful. If you are
 seeing a crash, as opposed to mere
 misbehavior, the odds that it is a true bug are pretty high: well
 written software programs are not designed to crash under
 any circumstances. In any case, if you have
 made a conscious effort to decide whether it is really a bug,
 and at the end still aren't sure, then please go ahead and report
 it: the worst that can happen is that you will waste a bit of
 time for the development team.

 Actually there are a few things that are known to cause
 GIMP to crash but have turned out to be too
 inconvenient to be worth fixing. One of them is asking
 GIMP to do something that requires vast amounts of
 memory, such as creating an image one million pixels on a side.

 You should also make sure that you are using an up-to-date version
 of GIMP: reporting bugs that have already been
 fixed is just a waste of everybody's time. (GIMP 1
 is no longer maintained, so if you use it and find bugs, either
 upgrade to GIMP 2 or live with
 them.) Particularly if you are using the development version of
 GIMP, make sure that you can see the bug in the
 latest release before filing a report.

 If after due consideration you still think you have a legitimate
 bug report or enhancement request, the next step is to go to
 GIMP's list of issues
 (),
 and try to see whether somebody else has already reported the same
 thing.

## Find a Specific Bug

 Enter some (space separated) search terms, e.g.

 filter crash

 in the "Search or filter results..." text box and press Enter. By
 default you only see open reports; you can change this by clicking "All"
 above the search field.

 The result is either a list of bug reports – hopefully not too
 long – or a message saying Sorry, your filter produced no
 results. If you
 don't find a related bug report by doing this, it may be worth trying
 another search with different terms. If in spite of your best efforts,
 you file a bug report and it ends up being closed as a
 duplicate, don't be too upset: it has happened
 repeatedly to the author of this documentation.

## Reporting the Bug

 Okay, so you have done everything you could to make sure, and you still
 think it's probably a bug. You should then go ahead and file a bug
 report on the GitLab page.

 The first time you file a bug report, you will be asked to create a
 GitLab account. The process is easy and painless, and you probably
 won't even get any spam as a result.

## File a New Issue

 Go to , and
 select New issue.

 If you are not logged in, you are automatically redirected to the
 login page. After entering your user name (login) and password,
 you get back to the New Issue page.

## Fill out the Template

 Select Choose a template and choose whether you
 plan to report a bug or to request a feature.
 Note that most of the information you enter can be changed later
 by the developers if you get it wrong, so try to get it right but
 don't be obsessive about it.

 Title

 Give a one-sentence summary that is descriptive enough so that
 somebody searching for similar bugs would find your bug report
 on the basis of the words this summary contains.

 Description

 Describe the problem. Be as specific as you can, try to provide
 all the information requested from you, and include
 all information that you think might possibly be relevant.
 The classic totally useless bug report is, GIMP
 crashes. This program sucks. There is no hope that the
 developers can solve a problem if they can't tell what it is.

 Sometimes it is very helpful to augment a bug report with a
 screenshot or some other type of data. If you need to do this, click
 on the button Attach a file,
 and follow the directions. But please don't do this unless you think
 the attachment is really going to be useful—and if you need to
 attach a screenshot, don't make it any larger than necessary. Bug
 reports are likely to remain on the system for years, so there is no
 sense in wasting memory.

 When you have filled out all of these things, press the
 Submit issue button and your bug report will be
 submitted. It will be assigned a number, which you may want to make
 note of; you will, however, be emailed any time somebody makes a
 comment on your bug report or otherwise alters it, so you will
 receive reminders in any case. You can see the current state of your
 bug report at any time by going to
 .

## What Happens to a Bug Report after you Submit it

 At any time after it is submitted, a bug report has a
 Status
 that describes how it is currently being handled. Here are the
 possible values of Status and what they mean:

-->