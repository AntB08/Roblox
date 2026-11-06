## Advanced Merge Request Guide 

Since April 2019, we’re using Gitlab to review merge requests and patches to the code. Check [Forking on Gitlab](intro_hacking_krita.xhtml#forking-gitlab) on how to start with making a merge request.  

### When to make a merge request 

There’s three times you need to make merge requests.  
- 

When you do not have commit access. 
- 

When the change you are making is huge, like with feature development, large refactors, complex bugfixes. For these we do not fork, but instead make a branch in the main repository in the following format: `name/number-shortdescription`. Check [Developing Features](new_features.xhtml#developing-features) for more information. 
- 

When you are not sure about whether what you did is correct. It is common within the Krita community that even developers with commit access will have a weaning period in which they still make merge requests for each change as they’re getting comfortable with the codebase. It is not mandatory to do so at this point, but requests are the best way for us to help one another with writing good code.    

### Checklist for review 

Here’s a quick checklist that is gone over when reviewing patches. While some requests require specialist knowledge, these items are so universal that anyone who knows how to check them can do so and comment on them. Feel free to do this yourself on [open requests](https://invent.kde.org/graphics/krita/-/merge_requests?scope=all&state=opened) [https://invent.kde.org/graphics/krita/-/merge_requests?scope=all&state=opened], we welcome it! 

Also check out the [manual for reviewing merge requests in Gitlab](https://invent.kde.org/help/user/project/merge_requests/index.md) [https://invent.kde.org/help/user/project/merge_requests/index.md].  Does the code build

Most important check. Apply the patch locally and build it. If it doesn’t build, the patch will not be accepted at all.  Does it not crash?

Basically, build the patch, run Krita, and check if the functions associated doesn’t crash. If it does, make a backtrace and post it in the review.  Does it leak memory? Does the patch break tests? CPP features used.

Is the usage of CPP in accordance with HACKING and the [Modern C++ usage guidelines for the Krita codebase](modern_cpp_in_krita.xhtml#modern-cpp-in-krita) guidelines? So for example, is auto not used outside of the single case we accept it?  Is the code in conformance with KDE/Krita style?

Check the HACKING file for directions.  Are the commit messages sensible?

There’s several guides for this, but in general, try to make sure that the commit messages actually explain what you did.  
- 

[https://github.com/RomuloOliveira/commit-messages-guide](https://github.com/RomuloOliveira/commit-messages-guide)   Does the patch make sense.

This is in the category of specialist knowledge, but you can apply some common sense here. If a patch for a filter also adjusts the resource management, you can ask yourself why this would be necessary. Furthermore, does the patch actually fix the thing it says it is fixing? These are not easy checks to make, but important things to consider when looking at the patch.   

Requests that need changes to them need to be labeled with `needs-changes`. Requests that are accepted should be labeled `accepted`. This is to ensure we can figure out which requests are in need of review. Requests that need to be reviewed need to lack both labels.