## Testing Strategy  

### Overview 

We’re always working on the next version of Krita. We fix bugs and implement new features. Every change to any software comes with a risk of introducing other issues. That’s where testing comes in. The tester’s job is to uncover defects as early as possible in the development process: a bug caught early enough means easier fixing, better user experience and less load on user support.   

### The Functional Test Suite 

When testing functionality we employ multiple strategies that translate into several layers of the test suite: 

>  

 
- 

Unit tests are our safeguard against breakage during development. 
- 

End to end tests check that the basic high level workflows function properly. 
- 

Exploratory testing experiments. Unexpected combinations, uncharted workflows.    

#### Test Suite Layers  

##### Unit Tests 

Unit tests are the base of our test suite. They are designed to ensure that every individual unit of source code (both backend and UI components) functions as expected. They are fully automated and fast to execute. They are run by developers during development. Also part of nightly testing suite. 

In-depth unit testing doc: [https://docs.krita.org/en/untranslatable_pages/unit_tests_in_krita.html](https://docs.krita.org/en/untranslatable_pages/unit_tests_in_krita.html)   

##### End-to-end UI Tests 

Formalized high level tests performed on the running application; carried out either by a computer or by a human. 

End to end tests cover both the GUI and the command line interface.   

##### Exploratory Testing 

While the other layers of the test suite are composed of carefully curated scripted tests, balancing between coverage and efficiency, exploratory testing approaches testing quite differently. It’s purpose is to allow humans to apply their unique tools: learning, creativity, intuition. There are no suites, scenarios, defined steps. Just you and Krita. Explore and experiment. Try basic workflows. Try unexpected combinations. Try to break things. Then report bugs.    

#### When Do We Test  

##### Continuous testing as part of continuous integration 

Automatic test suite is run nightly against the last nightly build.   

##### Beta Testing 

Beta testing is a type of user acceptance testing, where a subgroup of target users validates the upcoming release. 

As a part of the release process, we collect features and bugs (mainly high impact bugs and those that benefit from testing in multiple different conditions) to test in a Phabricator task connected to the release. From that collection we create a survey on survey.kde.org and publicly release the beta version. Link to the survey is available on the welcome page of the beta release.