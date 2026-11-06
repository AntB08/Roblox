## [Enable static analyzer](#id2)  

Contents  
- 

[Enable static analyzer](#enable-static-analyzer)    
- 

Install the latest version of clang-tidy 

>  

 

For older versions of Ubuntu 

If you are using older version of Ubuntu (e.g. via [Krita Docker build environment](https://invent.kde.org/dkazakov/krita-docker-env) [https://invent.kde.org/dkazakov/krita-docker-env]) make sure that you added the backports repository: 

```
sudo add-apt-repository ppa:savoury1/llvm-defaults-11
sudo apt-get update

```
   

```
sudo apt install clang-11 clang-format-11 clang-tidy-11 clang-tools-11

```
    
- 

Go to the Analyser settings in QtCreator (Options->Analyser) 
- 

In the field for Clang-Tidy executable select the script from Krita source tree sdk/clang-tidy-arguments-wrapper.sh. This script removes GCC-specific compile options not supported by clang. Without the wrapper script the analyser tool will fail. 
- 

Open “Diagnostic Configuration” dialog. Duplicate the default configuration, switch to “Clang-Tidy Checks” tab and choose “Use .clang-tidy config file” 
- 

In the “Project Settings” pane make sure that your new Diagnostic Configuration is activated. 
- 

Start analysing by clicking on Analyze->Clang Tidy and Clazy…