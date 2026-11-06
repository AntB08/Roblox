## Automated Krita builds on CI matrix  

### Android   
|  |  

Release |  

Nightly |  

CI/MR |     
| 

`KRITACI_ANDROID_RELEASE_MODE` 

disables debug-signature and (presumably) strips some assets  |  

1 |  

0 |  

0 |   
| 

`ANDROIDDEPLOYQT_EXTRA_ARGS` 

(is set by `KRITACI_ANDROID_RELEASE_MODE`)  |  

`--release` |  

none |  

none |   
| 

packageId |  

`org.krita` |  

`org.krita.next` |  

`org.krita.debug` |   
| 

Signed by |  

Krita Foundation 

(manually by Halla)  |  

KDE e.V. 

(by signing service)  |  

default debug signature |   
| 

`BUILD_TYPE` |  

Release |  

Release |  

Release |   
| 

`HIDE_SAFE_ASSERTS` |  

ON |  

OFF |  

OFF |   
| 

`BUILD_TESTING` |  

OFF |  

ON |  

ON |   
| 

Run the tests 

Tests are skipped either by `--only-build` option or `KDECI_ONLY_BUILD` variable  |  

OFF |  

OFF |  

OFF |   
| 

Upload to [ci-builds](https://cdn.kde.org/ci-builds/graphics/krita) [https://cdn.kde.org/ci-builds/graphics/krita] |  

OFF |  

ON |  

OFF |   
| 

Job is triggered on |  

manually on tags |  

nightly |  

manually |       

### Linux   
|  |  

Release |  

Nightly |  

CI/MR |     
| 

Signed by |  

Krita Foundation (manually by Halla) |  

(**to be implemented**, by KDE e.V.) |  

none |   
| 

BUILD_TYPE (appimages don’t support debug symbols) |  

Release |  

Release |  

Release |   
| 

HIDE_SAFE_ASSERTS |  

ON |  

OFF |  

OFF |   
| 

BUILD_TESTING |  

OFF |  

OFF |  

ON |   
| 

Run the tests 

Tests are skipped either by `--only-build` option or `KDECI_ONLY_BUILD` variable  |  

OFF |  

OFF 

we run tests for every commit, no need to run them in nightlies  |  

ON |   
| 

Upload to [ci-builds](https://cdn.kde.org/ci-builds/graphics/krita) [https://cdn.kde.org/ci-builds/graphics/krita] |  

OFF |  

ON |  

OFF |   
| 

Job is triggered on |  

manually on tags |  

nightly |  

for all commits in branches and MRs |       

### Windows   
|  |  

Release |  

Nightly |  

Protected branches CI |  

CI for MRs |     
| 

Signed by |   
- 

.exe — by KDE e.V, using signing service 
- 

.msix — by Krita Foundation, automatically via Windows Store   |  

only .exe files are signed, by KDE e.v. |  

no signature for regular jobs, too expensive |  

no signature for unprotected branches |   
| 

BUILD_TYPE |  

RelWithDebInfo |  

RelWithDebInfo |  

Release |  

Release |   
| 

SKIP_DEBUG_PACKAGE |  

OFF |  

OFF |  

ON 

(too expensive to build debug package for every commit)  |  

ON 

(too expensive to build debug package for every commit)  |   
| 

BUILD_INSTALLERS |  

ON |  

ON |  

OFF 

(too expensive to build installers for every commit)  |  

OFF 

(too expensive to build installers for every commit)  |   
| 

HIDE_SAFE_ASSERTS |  

ON |  

OFF |  

OFF |  

OFF |   
| 

BUILD_TESTING |  

OFF |  

OFF |  

ON |  

ON |   
| 

Run the tests 

Tests are skipped either by `--only-build` option or `KDECI_ONLY_BUILD` variable  |  

OFF |  

OFF 

we run tests for every commit, no need to run them in nightlies  |  

ON |  

ON |   
| 

Upload to [ci-builds](https://cdn.kde.org/ci-builds/graphics/krita) [https://cdn.kde.org/ci-builds/graphics/krita] |  

OFF |  

ON |  

OFF |  

OFF |   
| 

Job is triggered on: |  

manually on tags |  

nightly |  

for every commit |  

for every commit |       

### MacOS   
|  |  

Release |  

Nightly |  

Protected branches CI |  

CI for MRs |     
| 

Signed by |   
- 

Standalone packages: by KDE e.V. 
- 

MacOS Store: by Halla, manually   |  

by KDE e.V. |  

by KDE e.V. |  

no signature for unprotected branches |   
| 

packageId |   
- 

Standalone packages: `org.krita` 
- 

MacOS Store: `org.kde.krita`   |  

`org.krita` |  

`org.krita` |  

`org.krita` |   
| 

BUILD_TYPE |  

Release |  

Release |  

Release |  

Release |   
| 

BUILD_TESTING |  

OFF |  

ON (since there are no per-commit builds) |  

ON |  

ON |   
| 

Run the tests 

Tests are skipped either by `--only-build` option or `KDECI_ONLY_BUILD` variable  |  

OFF |  

ON (since there are no per-commit builds) |  

ON |  

ON |   
| 

Upload to [ci-builds](https://cdn.kde.org/ci-builds/graphics/krita) [https://cdn.kde.org/ci-builds/graphics/krita] |  

OFF |  

ON |  

OFF |  

OFF |   
| 

Job is triggered on: |  

manually on tags |  

nightly |  

manually |  

manually |