## [Building Krita with Docker on Linux](#id1) 

This guide is useful when you are an advanced developer and want to build Krita with the same patched dependencies that are used for the AppImages. If you just want to hack on Krita, read the Build Krita from Source guide. 

The *Dockerfile* is based on the official KDE build environment that is used on KDE CI for building official AppImage packages. This guide is valid for Ubuntu and Ubuntu-based Linux distributions.  

Contents  
- 

[Building Krita with Docker on Linux](#building-krita-with-docker-on-linux)  
- 

[Prerequisites](#prerequisites) 
- 

[Downloading Krita sources](#downloading-krita-sources) 
- 

[Downloading prebuilt Krita dependencies](#downloading-prebuilt-krita-dependencies) 
- 

[Build the docker image and run the container](#build-the-docker-image-and-run-the-container) 
- 

[Cleanup the dependencies](#cleanup-the-dependencies) 
- 

[Enter the container and build Krita](#enter-the-container-and-build-krita) 
- 

[Building AppImage package for your version of Krita](#building-appimage-package-for-your-version-of-krita) 
- 

[Creating a full clone of the container](#creating-a-full-clone-of-the-container) 
- 

[Testing merge requests using container clones](#testing-merge-requests-using-container-clones) 
- 

[Updating dependencies in the docker](#updating-dependencies-in-the-docker) 
- 

[Extra developer tools](#extra-developer-tools) 
- 

[Stopping the container and cleaning up](#stopping-the-container-and-cleaning-up) 
- 

[Troubleshooting](#troubleshooting)  
- 

[Krita binary is not found after the first build](#krita-binary-is-not-found-after-the-first-build) 
- 

[PulseAudio socket fails to start after restarting the host system](#pulseaudio-socket-fails-to-start-after-restarting-the-host-system) 
- 

[.XAuthority file cannot be mounted on systems with Wayland](#xauthority-file-cannot-be-mounted-on-systems-with-wayland) 
- 

[OpenGL doesn’t work on NVidia GPU with proprietary drivers](#opengl-doesn-t-work-on-nvidia-gpu-with-proprietary-drivers) 
- 

[OpenGL doesn’t work on Intel/NVidia/AMD GPU with **opensource** drivers](#opengl-doesn-t-work-on-intel-nvidia-amd-gpu-with-opensource-drivers)        

### [Prerequisites](#id2) 

First make sure you have Docker installed 

```
sudo apt install docker.io

```
  

Decide where you want to store your Docker images. All the docker images and containers are by default stored in a special docker-daemon controlled folder under */var* directory. You might not have enough space there for building Krita (it needs about 10 GiB). In such a case it is recommended to move the docker images folder into another location, where there is enough space.  
- 

Stop docker service 

>  

```
sudo systemctl stop docker

```
    
- 

Edit the config file: 

>  

On newer systems, like Ubuntu 18.04 and higher you need to open file */etc/docker/daemon.json* and add the following json config options: 

```
{
    "data-root" : "/path/where/you/want/to/store/docker/images/"
}

```
  

If you have older version of Ubuntu, e.g. Ubuntu 16.04, then you need to do the following: 

```
echo 'DOCKER_OPTS="-g /path/where/you/want/to/store/docker/images/"' >> /etc/default/docker

```
    
- 

Restart the docker service 

>  

```
sudo systemctl start docker

```
     

Second, make sure that you have utility packages installed (python and wget): 

```
sudo apt install python3 python3-venv python3-pip wget

```
  

`python3-venv` package is used for bootstrapping the dependencies on the host system before building the docker image, so you need to have it preinstalled. 

 

Note 

This python is used for build scripts only. Python 3.10.x or higher can be used for that. Krita internally will use Python 3.13, which is built as part of the deps build process.    

### [Downloading Krita sources](#id3) 

Then you need to download deps and Krita source tree. These steps are not included into the *Dockerfile* to save internal bandwidth 

```
# create directory structure for container control directory
git clone https://invent.kde.org/dkazakov/krita-docker-env krita-auto-1

cd krita-auto-1
mkdir persistent

# copy/checkout Krita sources to 'persistent/krita'
cp -r /path/to/sources/krita ./persistent/krita

## or ...
# git clone kde:krita persistent/krita
# "kde:krita" should be replaced with a link for cloning the repository,
# such as "git@invent.kde.org:graphics/krita.git".

```
    

### [Downloading prebuilt Krita dependencies](#id4) 

```
# download the deps archive
./bin/bootstrap-deps.sh

```
  

If you want to build a Qt6 version of krita, instead use this command: 

```
# download the qt6 deps archive
./bin/bootstrap-deps.sh -b transition.now/qt6

```
  

 

Note 

If you want to build and ASAN-capable build of Krita, then you should make sure that this script installs an ASAN-capable version of Qt. To do that, declare an environment variable on your host **before** bootstrapping the deps: 

```
export KDECI_PACKAGE_ALIASES_YAML='{ ext_qt : ext_qt-asan }'

```
  

If you don’t want ASAN-capable, but just a debug-capable build of Qt, then change this variable to: 

```
export KDECI_PACKAGE_ALIASES_YAML='{ ext_qt : ext_qt-debug }'

```
     

### [Build the docker image and run the container](#id5) 

```
./bin/build_image
./bin/run_container

```
    

### [Cleanup the dependencies](#id6) 

The dependencies are cached in `~/persistent/deps/` folder. It may occupy up to 4.7 GiB. If you happen to have problems with space, make sure you removed all the cached checkout: 

```
# clean up about 2.4 GiB of the cached deps checkout

rm -rf ./persistent/deps/_install

```
  

If you need more space, you can freely remove the entire deps cache (it will be automatically refetched on the next call to `./bin/bootstrap-deps.sh`) 

```
# clean up everything

rm -rf ./persistent/deps/

```
    

### [Enter the container and build Krita](#id7) 

```
# enter the docker container (the name will be
# fetched automatically from '.container_name' file)

./bin/enter

```
  

… now you are inside the container with all the deps prepared … 

```
# build Krita as usual
# you should be in ~/appimage-workspace/krita-build/
~/bin/run_cmake.sh ~/persistent/krita
make -j8 install

# start Krita
../krita.appdir/usr/bin/krita

```
  

If you have the Qt6 dependencies, you need to pass additional CMake arguments: 

```
run_cmake.sh -DBUILD_WITH_QT6=ON -DALLOW_UNSTABLE=QT6 ~/persistent/krita/

```
  

 

Note 

If you need to build an ASAN-capable build of Krita (**and** you have passed `KDECI_PACKAGE_ALIASES_YAML` during the dependencies fetch phase), then pass `-DECM_ENABLE_SANITIZERS=address` to CMake as well.    

### [Building AppImage package for your version of Krita](#id8) 

If you want to build a portable package for your version of Krita, just enter the container and type: 

```
~/bin/build_krita_appimage.sh

```
  

The built package will be copied to *./persistent/* folder. 

By default, the package will be built in release mode. If you want to add debugging information, add *–debug* option to the command line: 

```
~/bin/build_krita_appimage.sh --debug

```
    

### [Creating a full clone of the container](#id9) 

It is possible to copy the container with the entire environment, sources, build directory and QtCreator installation and configuration. After cloning, no rebuild of Krita is needed! 

To copy container to *../krita-auto-2*, just type in the host system 

```
./bin/spawn-clone -d ../krita-auto-2

```
  

*spawn-clone* will make an image from the current container and create a new one out of it. This image will be cached for further usages. If you need to flush the cache, pass *-f* option to *spawn-clone*: 

```
./bin/spawn-clone -f -d ../krita-auto-2

```
  

You can start several instances of *spawn-clone* on the same container concurrently (e.g. for building multiple merge requests). It has internal locking mechanism for resolving concurrency problems   

### [Testing merge requests using container clones](#id10) 

To quickly build a merge request ‘123’ basing on the current state of the container type in the host system 

```
./bin/spawn-clone -m 123 -be

```
  

The script will clone the container, checkout the merge request branch, build it and provide you a terminal for running Krita. The container will be created at *./clones/clone-mr-123* subfolder of the current container. 

If you also want to build an AppImage, add *–release-appimage* option: 

```
./bin/spawn-clone -m 123 --release-appimage -be

```
  

AppImage will be places at *./persistent* subfolder of the clone. When finished with testing the merge request, you can remove the clone completely by running 

```
./bin/discard-clone /clones/clone-mr-123

```
  

You can build multiple merge requests at once!   

### [Updating dependencies in the docker](#id11) 

Sometimes dependencies in Krita change and building Krita or making the AppImage fails. To fix that, you need to update the dependencies. 

 

Note 

This method is slow, because you need to rebuild the whole docker, which includes rebuilding whole Krita.  

Run those commands in the console in the host system. If you want to update the dependencies in a clone docker, just go to the clone directory where you see `bin` and `persistent` directories and run those commands there. 

```
# remove old dependencies
rm ./persistent/deps/_install

# download new deps
./bin/bootstrap-deps.sh

# remove the current container
./bin/remove_container

# remove the image for the current container
docker image remove krita-auto-1

# build image
./bin/build_image

# run the container (it will create one)
./bin/run_container

```
  

After that you need to build Krita in the docker as usual. 

 

Note 

Don’t forget about setting `KDECI_PACKAGE_ALIASES_YAML` if you need any special flavour of the Qt library installed.    

### [Extra developer tools](#id12) 

QtCreator is usually installed into the docker image into `~/qtcreator/` folder. The fetching of the prebuilt QtCreator happens when you run `./bin/bootstrap-deps.sh` script. That is, if you skipped installing deps QtCreator will not be installed and you will have to download it manually from [this location](https://files.kde.org/krita/build/qtcreator-package.tar.gz) [https://files.kde.org/krita/build/qtcreator-package.tar.gz]. 

You may also try to download the official QtCreator installer from [https://download.qt.io/official_releases/qtcreator/](https://download.qt.io/official_releases/qtcreator/). In case you decide to use it, just enter the container and install it. Make sure you install it into ‘~/qtcreator’ directory without any version suffixes, then you will be able to run it directly from the host system using the script below: 

```
# from the host
./bin/qtcreator

```
    

### [Stopping the container and cleaning up](#id13) 

When not in use you can stop the container. All your filesystem state is saved, but all the currently running processes are killed (just ensure you logout from all the terminals before stopping). 

```
# stop the container
./bin/stop

# start the container
./bin/start

```
  

If you don’t need your container/image anymore, you can delete them from the docker 

```
# remove the container
sudo docker rm krita-auto-1

# remove the image
sudo docker rmi krita-deps

```
    

### [Troubleshooting](#id14)  

#### [Krita binary is not found after the first build](#id15) 

Either relogin to the container or just execute source ~/.devenv.inc   

#### [PulseAudio socket fails to start after restarting the host system](#id16) 

On KDE Neon the pulseaudio socket is sometimes created after the first usage of the audio playback. If you have any issues with that, just try to play any audio on your **host** system before running/starting the container.   

#### [.XAuthority file cannot be mounted on systems with Wayland](#id17) 

On some systems (e.g. KDE Neon) XWayland in started on-demand. Just start glxgears on the **host** system before running/starting the container to force your host system to initialize XWayland.   

#### [OpenGL doesn’t work on NVidia GPU with proprietary drivers](#id18) 

The docker run script automatically forwards the GPU devices into the container, but it doesn’t install the drivers for the GPU. You should install exactly the same version of the driver that is installed on your host system. Just run the following script when you are on host: 

```
./bin/install_nvidia_drivers.sh

```
    

#### [OpenGL doesn’t work on Intel/NVidia/AMD GPU with **opensource** drivers](#id19) 

Usually, opensource GPU drivers are already present in the docker container. Though sometimes these drivers are outdated in Ubuntu 20.04. In this case you need to update the drivers to the version that supports your GPU. 

We use a build of opensource GPU drivers provided by Intel. Since they are based on the opensource version of Mesa, they will also provide drivers for other GPUs. 

To install these drivers, just run this script on the host system: 

```
./bin/install_intel_drivers.sh

```