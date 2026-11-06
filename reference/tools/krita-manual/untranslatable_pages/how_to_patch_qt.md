## [How to patch Qt](#id2)  

Contents  
- 

[How to patch Qt](#how-to-patch-qt)   

The Qt repository is split into submudules, so pushing a fix for it is not very trivial. Let’s assume you have Krita deps built using Krita’s build scripts and you want to modify Qt and push a fix into the registry.  
- 

Make a commit in QtBase submodule 

>  

When using submodules, the submodule folder is in “detached” state without any branch assigned, so we need to reset the branch head after we make a commit: 

```
cd qtbase
git commit -a -m "your commit message"

# reset the branch head (make sure you don't have any local
# changes in 'krita/5.15' branch!)

git update-ref refs/heads/krita/5.15 HEAD
git checkout krita/5.15
git pull --rebase

cd ..

```
      
- 

Make a commit in the root repository and push 

>  

```
git checkout krita/5.15
git pull --rebase
git commit -a -m "commit message for the root repo"
git push --recurse-submodules=on-demand

```
    
- 

Update the sha1-link in Krita’s repository 

>  

 
- 

Open `3rdparty/ext_qt/CMakeLists.txt` 
- 

Modify `QT_GIT_TAG` with the newly pushed sha1 
- 

Push!