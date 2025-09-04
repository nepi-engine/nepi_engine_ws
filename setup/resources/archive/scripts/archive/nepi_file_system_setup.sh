#!/bin/bash

# Open a terminal on the device to install on
# Or ssh in if available

# Run one of the environment setup scripts based
# on the deployment type (Host or Container)

#(Host Install Only)
############################################
# HOST ENV SETUP 
############################################
# If installing directly to the host file system
# Run commands in the 

# nepi_host_env_setup-#p#p#.sh file

#(Container Install Only)
############################################
# CONTAINER ENV SETUP 
############################################
# If installing in a containerized file system
# Run commands in the 

# nepi_container_env_setup-#p#p#.sh file

#################################################################################

############################################
# NEPI File System Setup (All)
############################################




#########
# Define some system paths
# NOTE: THESE SHOULD HAVE BEEN Created in one of the ENV setup scripts above


REPO_DIR=${HOME_DIR}/nepi_engine
CONFIG_DIR=${REPO_DIR}/nepi_env/config
ETC_DIR=${REPO_DIR}/nepi_env/etc

NEPI_DIR=/opt/nepi
NEPI_RUI=${NEPI_DIR}/nepi_rui
NEPI_CONFIG=${NEPI_DIR}/config
NEPI_ENV=${NEPI_DIR}/ros
NEPI_ETC=${NEPI_DIR}/etc

NEPI_DRIVE=/mnt/nepi_storage



# Log in as nepi user

# The script is assumed to run from a directory structure that mirrors the Git repo it is housed in.
cd ~/
HOME_DIR=$PWD

#_________________________
####################

#___________________
#Install dependancies
sudo apt update
sudo apt upgrade

# Convenience applications
sudo apt install nano


#######################

# Uninstall ROS if reinstalling/updating
# sudo apt remove ros-noetic-*
# sudo apt-get autoremove
# After that, it's recommended to remove ROS-related environment variables from your .bashrc file 
# and delete the ROS installation directory, typically /opt/ros/noetic. 


# Install Python 
sudo apt update 

sudo apt-get install --reinstall ca-certificates
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install python3.10 
sudo apt install python3.10-distutils -f

# Update python symlinks
cd /usr/bin
sudo ln -sfn python3.10 python3
sudo ln -sfn python3 python

sudo apt install python3.10-venv 
sudo apt install python3.10-dev 

# Install pip
curl -sS https://bootstrap.pypa.io/get-pip.py | sudo python3.10
python3.10 -m pip --version




#create requirements file from current dev install then run both as normal and sudo user
# https://stackoverflow.com/questions/31684375/automatically-create-file-requirements-txt
# pip3 freeze > requirements.txt
# sed 's/==.*$//' requirements.txt > requirements_no_versions.txt
# then
# Copy to /mnt/nepi_storage/tmp
# ssh into tmp folder on nepi

#Install python requred packages
# 1) Copy nepi_env/config/home/nepi/requirements_no_versions to /mnt/nepi_storage/tmp
# 2) SSH into your nepi device and type



# Edit bashrc file
nano ~/.nepi_aliases
# Add to end of bashrc
    export SETUPTOOLS_USE_DISTUTILS=stdlib
    export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
    export PYTHONPATH=/usr/local/lib/python3.10/site-packages/:$PYTHONPATH


##_________________________
## Setup ROS

sudo apt-get install lsb-release -y

#  Install ros
#  https://wiki.ros.org/noetic/Installation/Ubuntu

cd /mnt/nepi_storage/tmp
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt install curl # if you haven't already installed curl
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
sudo apt update
####################
# Do if ROS not installed
sudo apt install ros-noetic-desktop-full
source /opt/ros/noetic/setup.bash
sudo apt install python3-rosdep 
sudo apt install python3-rosinstall 
sudo apt install python3-rosinstall-generator 
sudo apt install python3-wstool build-essential
sudo rosdep init
rosdep update


# Then
#sudo apt-get install ros-noetic-catkin python-catkin-tools
#sudo pip3 install --user git+https://github.com/catkin/catkin_tools.git

ROS_VERSION=noetic

ADDITIONAL_ROS_PACKAGES="python3-catkin-tools \
    ros-${ROS_VERSION}-rosbridge-server \
    ros-${ROS_VERSION}-pcl-ros \
    ros-${ROS_VERSION}-web-video-server \
    ros-${ROS_VERSION}-camera-info-manager \
    ros-${ROS_VERSION}-tf2-geometry-msgs \
    ros-${ROS_VERSION}-mavros \
    ros-${ROS_VERSION}-mavros-extras \
    ros-${ROS_VERSION}-serial \
    python3-rosdep" 

    # Deprecated ROS packages?
    #ros-${ROS_VERSION}-tf-conversions
    #ros-${ROS_VERSION}-diagnostic-updater 
    #ros-${ROS_VERSION}-vision-msgs

sudo apt install $ADDITIONAL_ROS_PACKAGES


sudo apt install ros-noetic-cv-bridge
sudo apt install ros-noetic-web-video-server

####################
sudo pip install bagpy
sudo pip install pycryptodome-test-vectors


# 1) edit the following file: 
#sudo su
#cd /opt/ros/noetic/lib/rosbridge_server/
#cp rosbridge_websocket.py  rosbridge_websocket.bak
#vi rosbridge_websocket.py
# Add the following lines under import sys


# Mavros requires some additional setup for geographiclib
sudo /opt/ros/${ROS_VERSION}/lib/mavros/install_geographiclib_datasets.sh

# Need to change the default .ros folder permissions for some reason
//sudo mkdir /home/nepi/.ros
sudo chown -R nepi:nepi /home/nepi/.ros

# Setup rosdep
#sudo rm -r /etc/ros/rosdep/sources.list.d/20-default.list
#sudo rosdep init
#rosdep update

source /opt/ros/noetic/setup.bash


############################################
# Maybe not
  //- upgrade python hdf5
  //sudo pip install --upgrade h5py

_________________________





#Manual installs some additinal packages in sudo one at a time
################################
# Install some required packages
sudo apt-get install python-debian
sudo pip install cffi
pip install open3d --ignore-installed
sudo pip install open3d --ignore-installed

#sudo pip uninstall netifaces
sudo pip install netifaces

sudo apt-get install onboard
sudo apt-get install setools
sudo apt-get install ubuntu-advantage-tools

sudo apt-get install -y iproute2

sudo apt-get install scons # Required for num_gpsd
sudo apt-get install zstd # Required for Zed SDK installer
sudo apt-get install dos2unix # Required for robust automation_mgr
sudo apt-get install libv4l-dev v4l-utils # V4L Cameras (USB, etc.)
sudo apt-get install hostapd # WiFi access point setup
sudo apt-get install curl # Node.js installation below
sudo apt-get install v4l-utils
sudo apt-get install isc-dhcp-client
sudo apt-get install wpasupplicant
sudo apt-get install -y psmisc
sudo apt-get install scapy
sudo apt-get install minicom
sudo apt-get install dconf-editor


#############
# Other general python utilities
pip install --user labelImg # For onboard training
pip install --user licenseheaders # For updating license files and source code comments

# Install additional python requirements
# Copy the requirements files from nepi_engine/nepi_env/setup to /mnt/nepi_storage/tmp
cd /mnt/nepi_storage/tmp
sudo su
cat requirements_no_versions.txt | sed -e '/^\s*#.*$/d' -e '/^\s*$/d' | xargs -n 1 python3.10 -m pip install
exit


# Revert numpy
sudo pip uninstall numpy
sudo pip3 install numpy=='1.24.4'


## Maybe not needed with requirements
        # NEPI runtime python3 dependencies. Must install these in system folders such that they are on root user's python path
        sudo -H pip install pyserial 
        sudo -H pip install websockets 
        sudo -H pip install geographiclib 
        sudo -H pip install PyGeodesy 
        sudo -H pip install harvesters 
        sudo -H pip install WSDiscovery 
        sudo -H pip install python-gnupg 
        sudo -H pip install onvif_zeep
        sudo -H pip install onvif 
        sudo -H pip install rospy_message_converter
        sudo -H pip install PyUSB
        sudo -H pip install jetson-stats


        sudo -H pip install --user labelImg # For onboard training
        sudo -H pip install --user licenseheaders # For updating license files and source code comments
        #pip install --user labelImg # For onboard training
        #pip install --user licenseheaders # For updating license files and source code comments


        # NOT Sure
        sudo apt-get install python3-scipy
        #sudo -H pip install --upgrade scipy

        sudo pip install yap
        #pip install yap
        sudo pip install yapf






sudo /opt/ros/${ROS_VERSION}/lib/mavros/install_geographiclib_datasets.sh






#########
# Work-around opencv path installation issue on Jetson (after jetpack installation)
sudo ln -s /usr/include/opencv4/opencv2/ /usr/include/opencv
sudo ln -s /usr/lib/aarch64-linux-gnu/cmake/opencv4 /usr/share/OpenCV








# Install Base Python Packages
echo "Installing base python packages"
sudo apt install python3-pip
pip install --user -U pip
pip install --user virtualenv
sudo apt install libffi-dev # Required for python cryptography library

# NEPI runtime python3 dependencies. Must install these in system folders such that they are on root user's python path
sudo -H pip install python-gnupg websockets onvif_zeep geographiclib PyGeodesy onvif harvesters WSDiscovery pyserial




sudo apt install scons # Required for num_gpsd
sudo apt install zstd # Required for Zed SDK installer
sudo apt install dos2unix # Required for robust automation_mgr
sudo apt install libv4l-dev v4l-utils # V4L Cameras (USB, etc.)
sudo apt install hostapd # WiFi access point setup
sudo apt install curl # Node.js installation below
sudo apt install gparted
sudo apt-get install chromium-browser # At least once, apt-get seemed to work for this where apt did not, hence the command here

# Install Base Node.js Tools and Packages (Required for RUI, etc.)
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install 8.11.1 # RUI-required Node version as of this script creation



# Mavros requires some additional setup for geographiclib
sudo /opt/ros/${ROS_VERSION}/lib/mavros/install_geographiclib_datasets.sh

# Need to change the default .ros folder permissions for some reason
sudo mkdir /home/nepi/.ros
sudo chown -R nepi:nepi /home/nepi/.ros

# Setup rosdep
sudo rosdep init
rosdep update

# Install nepi-link dependencies
sudo apt install socat protobuf-compiler
pip install virtualenv


# Disable NetworkManager (for next boot)... causes issues with NEPI IP addr. management
sudo systemctl disable NetworkManager

# Clean-up unnecessary installed s/w
sudo apt autoremove



#########
#- add Gieode databases to FileSystem
:'
egm2008-2_5.pgm  egm2008-2_5.pgm.aux.xml  egm2008-2_5.wld  egm96-15.pgm  egm96-15.pgm.aux.xml  egm96-15.wld
from
https://www.3dflow.net/geoids/
to
/opt/nepi/databases/geoids
:'




##############################
#OS Env Setup
##############################

# Update bash files

# SETUP Aliases
# 1) Copy nepi_env/config/home/nepi/nepi_device_aliases to /mnt/nepi_storage/tmp
# 2) SSH into your nepi device and type
cp /mnt/nepi_storage/tmp/nepi_device_aliases ~/.nepi_aliases
source ~/.nepi_aliases

# Update bashrc
# 1) Copy nepi_env/config/home/nepi/bashrc_NVIDIA_JETSON to /mnt/nepi_storage/tmp
# 2) SSH into your nepi device and type
cp /mnt/nepi_storage/tmp/bashrc_NVIDIA_JETSON ~/.bashrc
source ~/.bashrc


# Set jetson power mode (look up options for your device online)
sudo nvpmodel -m 8


##############################
#Install NEPI code
##############################

#Follow build from source instructions at
#https://nepi.com/nepi-tutorials/nepi-engine-building-from-source-code/


###### Add udev rules to system
sudo cp /opt/nepi/config/etc/udev/rules.d/* /etc/udev/rules.d/


########
# install license managers

sudo apt-get install gnupg
sudo apt-get install kgpg

sudo rm -R /opt/nepi/config
sudo cp -r /mnt/nepi_storage/tmp/nepi/config/ ./
sudo chown -R nepi:nepi /opt/nepi/config
sudo chown -R nepi:nepi /mnt/nepi_storage/tmp/nepi/config

sudo /opt/nepi/config/etc/license/setup_nepi_license.sh

######
# install ssh server
sudo apt-get install -y openssh-server
# Set up SSH
sudo mv /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sudo ln -sf /opt/nepi/config/etc/ssh/sshd_config /etc/ssh/sshd_config
# And link default public key - Make sure all ownership and permissions are as required by SSH
mkdir -p /home/nepi/.ssh
sudo chown nepi:nepi /home/nepi/.ssh
chmod 0700 /home/nepi/.ssh
sudo chown nepi:nepi /opt/nepi/config/home/nepi/ssh/authorized_keys
chmod 0600 /opt/nepi/config/home/nepi/ssh/authorized_keys
ln -sf /opt/nepi/config/home/nepi/ssh/authorized_keys /home/nepi/.ssh/authorized_keys
sudo chown nepi:nepi /home/nepi/.ssh/authorized_keys
chmod 0600 /home/nepi/.ssh/authorized_keys
sudo service ssh restart




# Test Nepi Engine
rosstop
rostart




##############################
#Install RUI repo
##############################

cd /mnt/nepi_storage/tmp
sudo apt-get install python python3-wstool python3-catkin-tools python3-pip
pip install --user -U pip
pip install --user virtualenv
mkdir $HOME/.nvm
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install 8.11.1 # RUI-required Node version as of this script creation
# Upgrade node version
nvm install 14.1.0
nvm use 14.1.0
npm install -S rtsp-relay express
npm install -g yarn
//yarn add ffmpeg-kit-react-native

rm /opt/nepi/rui/.nvmrc
echo 14.1.0 >> /opt/nepi/rui/.nvmrc


cd /opt/nepi/rui
python -m virtualenv venv
source ./devenv.sh
pip install -r requirements.txt
npm install
deactivate


# Build RUI
cd /opt/nepi/rui
source ./devenv.sh
cd src/rui_webserver/rui-app
npm run build

npm install --save react-zoom-pan-pinch
deactivate


sudo systemctl start nepi_rui.service
#Check the status of the service:

sudo systemctl status nepi_rui.service

### Test RUI
# For Container Install Only
# sudo /opt/nepi/rui/etc/start_rui.sh

# For Host Install Only
#rosrun nepi_rui run_webserver.py






##############################
#Additional Packages
##############################

#### This does not work, need to copy folder from normal system
#https://www.stereolabs.com/developers
#sudo chmod +x filename.run
#./filename.run

Copy /usr/local/zed from host to /usr/local/zed in container
then 
sudo chown -R nepi:nepi /usr/local/zed/




############################################
## Updates for gpu support on jetson
############################################


# Don't do this
            ______________________________
            # OPENCV WITH JETSON CUDA
            # Replace pip opencv with Jetson Cuda supported jetson build
            # https://forums.developer.nvidia.com/t/opencv-surf-with-cuda-is-not-faster-by-a-noticeable-amount-on-agx-orin/313713

            # First uninstall pip opencv if installed
            sudo pip uninstall opencv-python
            sudo apt remove python3-apt
            sudo apt-get autoremove
            sudo apt autoremove
            sudo apt autoclean
            sudo apt install python3-apt
            # dowload build opencv with jetson cuda support
            # https://www.forecr.io/blogs/installation/how-to-install-opencv-with-cuda-support?srsltid=AfmBOor-VwEGF1OqR-RkGF9w2unMkqGC2gD7vUnjDaU_jpZHtAK90DOG

            # Download from this link and cp to your the nepi user tmp folder at /mnt/nepi_storage/tmp
            # https://hs.forecr.io/hubfs/BLOG%20ATTACHMENTS/How%20to%20Install%20OpenCV%20with%20CUDA%20Support%20on%20Jetson%20Modules/OpenCV_4_4_0_for_Jetson.zip
            # ssh in to /mnt/nepi_storage/tmp and unzip the copied file
            unzip OpenCV_4_4_0_for_Jetson.zip
            cd OpenCV_4_4_0_for_Jetson
            sudo ./opencv-install.sh
            ______________________________ 










############################################
- installed pytorch for jetson
Follow these instructions:
https://docs.nvidia.com/deeplearning/frameworks/install-pytorch-jetson-platform/index.html
another reference
https://medium.com/@yixiaozengprc/set-up-pytorch-environment-on-nvidia-jetson-platform-9eda291db716
https://docs.nvidia.com/deeplearning/frameworks/pytorch-release-notes/index.html


a. 
sudo apt-get -y update
sudo apt-get -y install python3-pip libopenblas-dev

b. Setup Pytorch in NEPI device
Go or create temp folder and install:
cd /mnt/nepi_storage/tmp


find cuda version
sudo apt-cache show nvidia-jetpack


Dowload latest version for your jetpack version from
Find pytorch version for jetpack version
https://forums.developer.nvidia.com/t/pytorch-for-jetson/72048
another resource
https://developer.download.nvidia.com/compute/redist/jp/

Copy link address and 

wget <link to whl file>
export TORCH_INSTALL=<whl location>

Ex
5.0.2
wget https://developer.download.nvidia.com/compute/redist/jp/v502/pytorch/torch-1.13.0a0+410ce96a.nv22.12-cp38-cp38-linux_aarch64.whl

export TORCH_INSTALL=/mnt/nepi_storage/tmp/torch-1.13.0a0+410ce96a.nv22.12-cp38-cp38-linux_aarch64.whl

5.1.2
wget https://developer.download.nvidia.cn/compute/redist/jp/v512/pytorch/torch-2.3.5+41361538.nv23.06-cp38-cp38-linux_aarch64.whl

export TORCH_INSTALL=/mnt/nepi_storage/tmp/torch-2.3.5+41361538.nv23.06-cp38-cp38-linux_aarch64.whl


c. Setup Pytorch in NEPI device 3

sudo python3 -m pip install --upgrade pip
sudo pip3 install numpy=='1.24.4'
sudo pip3 install --no-cache $TORCH_INSTALL

d.test install
! python -c "import torch; print(torch.cuda.is_available())"

############################################
- install torchvision

f) Fix NEPI package versions

pip install setuptools==49.4.0
sudo pip install setuptools==49.4.0

Installing Torchvision
Instructions can be found https://forums.developer.nvidia.com/t/pytorch-forjetson/

https://forums.developer.nvidia.com/t/how-to-install-torchvision-with-torch1-14-0-with-cuda-11-4/245657/2
a. find compatable version to torch version https://pypi.org/project/torchvision/

python 
import torch
print(torch.__version__)
quit()

NOTE: You can find the torch and torchvision compatibility matrix here:
https://github.com/pytorch/vision 

then look under "Tags" find version, then click the "tar.gz" file link

b. download and install On your PC Download 
Example:

for torch 1.13
https://github.com/pytorch/vision/archive/refs/tags/v0.14.0.tar.gz


https://github.com/pytorch/vision/archive/refs/tags/v0.16.2.tar.gz


c. copy to your /mnt/nepi_storage/tmp/ folder and unzip 
connect NEPI to internet

sshn in

sudo apt-get install libjpeg-dev zlib1g-dev libpython3-dev libopenblas-dev libavcodec-dev libavformat-dev libswscale-dev
cd /mnt/nepi_storage/tmp/

Example
tar -xvzf vision-0.14.0.tar.gz
cd vision-0.14.0
export BUILD_VERSION=0.14.0
cd ..
sudo chown -R nepi:nepi vision-0.14.0
cd vision-0.14.0
sudo python setup.py install

tar -xvzf vision-0.16.2.tar.gz
cd vision-0.16.2
export BUILD_VERSION=0.16.2
cd ..
sudo chown -R nepi:nepi vision-0.16.2
cd vision-0.16.2
sudo python setup.py install


Check Installed
! python -c "import torchvision; print(torchvision.__version__)"


rosstop
rosstart # Look for errors





###############################
- Install ultralytics for yolov5 ai model support
1) 
then add this to bashrc
vi ~/.bashrc

export SETUPTOOLS_USE_DISTUTILS=stdlib


1) connect nepi to internet

in nepi tmp folder
##git clone https://github.com/ultralytics/ultralytics.git
##cd ultralytics
##pip install -e '.[dev]'

pip install -U ultralytics


then reboot

*** Must Do ***

2) May need to do twice
power cycle

rosstop
rosstart

connect nepi to internet
connect camera

Connect NEPI to internet and start a yolov5 model from RUI AI detector

*****(



############################################
Install cupy

# Ref https://forums.developer.nvidia.com/t/cupy-install-for-jetson-xavier-nx/210913

___________________________________________________________
1) Connect your NEPI device to the internet

___________________________________________________________
2) Modify .bashrc file. 
FROM REF https://github.com/jetsonhacks/buildLibrealsense2TX/issues/13
a) SSH into your NEPI device
b) Open your .bashrc file "vi ~/.bashrc", and add the following to the end 

# cupy for cuda
export CUDA_PATH=/usr/local/cuda-11
export CUPY_NVCC_GENERATE_CODE=current

c) Save and exit
d) Re-source the file

source ~/.bashrc

__________________________________________________________
2) install cupy for cuda


pip install cupy-cuda11x
sudo pip install cupy-cuda11x

c) check python module import

python -c "import cupy; print(cupy)"
sudo python -c "import cupy; print(cupy)"




#################################
#pip install open3d --ignore-installed
#sudo pip install open3d --ignore-installed

OR 
From source

Install open3d with cuda support

# Ref https://www.open3d.org/docs/0.13.0/arm.html


___________________________________________________________
1) Connect your NEPI device to the internet

___________________________________________________________
2) Modify .bashrc file. 
FROM REF https://github.com/jetsonhacks/buildLibrealsense2TX/issues/13
a) SSH into your NEPI device
b) Open your .bashrc file "vi ~/.bashrc", and add the following to the end 

Update this line in the ~/.bashrc or ~/.nepi_aliases file
export CUDA_HOME=/usr/local/cuda-11.4
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CUDA_HOME/bin/lib64:$CUDA_HOME/bin/extras/CUPTI/lib64
export PATH=$PATH:$CUDA_HOME/bin

c) Save and exit
d) Re-source the file

source ~/.bashrc
source ~/.nepi_aliases


__________________________________________________________
3) Install CUDA 11.8

#### COULD NOT GET THIS TO WORK 

a) SSH into your NEPI device and type the following

rosstop

###No
#Needs cuda 11.5+ Use 11.8

#Download source from 
https://forums.developer.nvidia.com/t/how-to-manually-install-cuda-and-all-necessary-packages-on-my-jetson-nano-without-sdk-manager/284095/7
#https://developer.download.nvidia.com/compute/cuda/opensource/
# Copy to /mnt/nepi_storage/tmp


https://developer.nvidia.com/cuda-toolkit-archive




#https://forums.developer.nvidia.com/t/upgrading-cuda-11-4-to-cuda-11-8/305766
#https://developer.nvidia.com/cuda-11-8-0-download-archive?target_os=Linux&target_arch=aarch64-jetson&Compilation=Native&Distribution=Ubuntu&target_version=20.04&target_type=deb_local


wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/arm64/cuda-ubuntu2004.pin
sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/11.8.0/local_installers/cuda-tegra-repo-ubuntu2004-11-8-local_11.8.0-1_arm64.deb
sudo dpkg -i cuda-tegra-repo-ubuntu2004-11-8-local_11.8.0-1_arm64.deb
sudo cp /var/cuda-tegra-repo-ubuntu2004-11-8-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt upgrade

#sudo apt-get install aptitude
#sudo aptitude install cuda
sudo apt-get update
sudo apt-get -y install cuda-toolkit-11-8
#sudo apt-get -y install cuda


#Check
nvcc --version


#https://www.gpu-mart.com/blog/install-nvidia-cuda-11-on-ubuntu
wget https://developer.download.nvidia.com/compute/cuda/11.8.0/local_installers/cuda_11.8.0_520.61.05_linux.run
$ sudo sh cuda_11.8.0_520.61.05_linux.run


sudo dpkg -i cuda-tegra-repo-ubuntu2004-11-8-local_11.8.0-1_arm64.deb
sudo cp /var/cuda-tegra-repo-ubuntu2004-11-8-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install cuda

#Check
nvcc --version


#__________________________________________________________
#4) Install Open3d with Cuda support
NOTE: **The make process below took over an 5 hours to run. Maybe faster with rosstop
# Ref https://www.open3d.org/docs/0.13.0/arm.html
# Ref https://www.open3d.org/docs/0.11.0/compilation.html
# Ref https://groups.google.com/g/alembic-discussion/c/SVO3PEpzQvk?pli=1
# Ref https://stackoverflow.com/questions/72278881/no-cmake-cuda-compiler-could-be-found-when-installing-pytorch
# Ref https://www.open3d.org/docs/latest/tutorial/Advanced/headless_rendering.html


b) Setup python virtual environment. SSH into your NEPI device and type the following

# Just run once, then use the source and deactivate to enter/exit venv

cd /mnt/nepi_storage/tmp
#sudo apt install python3.8-venv
python3.8 -m venv open3d_venv


# Run to enter venv

source open3d_venv/bin/activate


e.  Make sure python is using 3.#
https://unix.stackexchange.com/questions/410579/change-the-python3-default-version-in-ubuntu
cd /usr/bin
sudo ln -sfn python3 python


c)

pip install cmake
sudo pip install cmake

NEED TO get Open3d 18.0 from
https://github.com/isl-org/Open3D/tags
Download, unzip and move to /mnt/nepi_storage/tmp

b)Edit the CMakeLists.txt line 328. Change "find_package(Python3 3.6" line to
find_package(Python3 3.8 EXACT

d) Build Open3D cpp and python modules

cd /mnt/nepi_storage/tmp
sudo chown -R nepi:nepi Open3D-0.18.0
cd Open3D-0.18.0/
mkdir build
cd build

sudo CUDACXX=/usr/local/cuda-11/bin/nvcc cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_CUDA_MODULE=ON \
    -DBUILD_GUI=ON \
    -DBUILD_TENSORFLOW_OPS=OFF \
    -DBUILD_PYTORCH_OPS=OFF \
    -DBUILD_UNIT_TESTS=OFF \
    -DPYTHON_EXECUTABLE=$(which python) \
    ..

#IN python software us
#https://www.open3d.org/docs/latest/tutorial/visualization/cpu_rendering.html
#import os
#os.environ['EGL_PLATFORM'] = 'surfaceless'   # Ubuntu 20.04+
#import open3d as o3d



#Or compile HEADLESS (Untested)
#https://github.com/isl-org/Open3D/issues/5505


sudo CUDACXX=/usr/local/cuda-11/bin/nvcc cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_CUDA_MODULE=ON \
    -DENABLE_HEADLESS_RENDERING=ON \
    -DBUILD_GUI=ON \
    -DBUILD_TENSORFLOW_OPS=OFF \
    -DBUILD_PYTORCH_OPS=OFF \
    -DBUILD_UNIT_TESTS=OFF \
    -DPYTHON_EXECUTABLE=$(which python) \
    ..


#sudo make -j$(nproc)
#[JRM: $(nproc) is not defined on my system, so replace with an explicit CPU count
sudo make -j4
sudo make install
sudo make install-pip-package -j4
b) (Optional) test the install. Run Open3D GUI (optional, available on when -DBUILD_GUI=ON)

./Open3D/Open3D

7) make and install python package

a) exit python venv
# Skip this step if you want to install  in python venv
# If you deactivate, it will be installed in normal nepi python environment

deactivate


b) Upgrade pip
sudo python3.8 -m pip install --upgrade pip

c) First install the new cuda open3d package
# You will get an error on this step. Ignore it

cd lib/python_package/pip_package
sudo pip install open3d-0.18.0-cp38-cp38-manylinux_2_31_aarch64.whl --ignore-installed

[ That step seems strange to me... I don't think pip can find that whl file so I'm not sure what actual effect (if any) this has ]

# Check installed open3d module version

pip freeze | grep open3d

#Future Fix python gpu Package
#https://github.com/isl-org/Open3D/issues/3406
#https://github.com/CMU-cabot/cabot/issues/86
Modify /usr/local/lib/python3.8/dist-packages/open3d/__init__.py and check the details of the error. 
https://github.com/intel-isl/Open3D/blob/e7574588ab23cd97bc49353327a3dced4cf1ac18/python/open3d/__init__.py#L52-L72
https://stackoverflow.com/questions/74413921/how-to-project-a-point-cloud-to-a-depth-image-using-open3ds-project-to-depth-im
Modify __init__.py as follows to see the details.
line 71:	str(next((_Path(__file__).parent / 'cuda').glob('pybind*'))), winmode=0)



python -W default -c "import open3d as o3d"


d) Next install standard open3d-cpu without overwriting the cuda version to fix python import error
# You will get an error on this step. Ignore it

sudo pip install open3d --ignore-installed
pip freeze | grep open3d


# TEST Install

sudo python -c "import open3d; from open3d._build_config import _build_config; print(_build_config)"
python -c "import open3d; from open3d._build_config import _build_config; print(_build_config)"
python /examples/python/visualization_tools/headless_rendering.py
sudo python -c "from open3d import core; print(core.cuda_is_available())"

#ISSUES
https://github.com/isl-org/Open3D/issues/5505


___________________________________________
############################
Install cv2 with cuda support
*****
Create an image backup before this step incase something goes wrong
****
a. Connect nepi device to internet

b. copy "install_opencv4.10.0_Jetson.sh" scrip from resources folder in repo nepi_rootfs_tools/nepi_main_rootfs/resources to nepi_storage/tmp folder

c. *** Check installed print(cv2.__version__) and change version as needed in script ***
python
import cv2
print(cv2.getBuildInformation())


d. ssh in and 
rosstop
cd /mnt/nepi_storage/tmp
sudo chmod +x install_opencv4.10.0_Jetson.sh
//sudo ./install_opencv4.10.0_Jetson.sh
** Yes to all questions
./install_opencv4.10.0_Jetson.sh
** Yes to all questions


e.  Make sure python is using 3.8.10
https://unix.stackexchange.com/questions/410579/change-the-python3-default-version-in-ubuntu
cd /usr/bin
sudo ln -sfn python3 python

python -V




f. remove and install cv_bridge
sudo apt remove ros-noetic-cv-bridge
sudo apt install ros-noetic-cv-bridge

g. fix web_video_server not launch error
sudo apt remove ros-noetic-web-video-server
sudo apt install ros-noetic-web-video-server

h. reboot

i. Check if cuda support

! python -c "import cv2; print(cv2.cuda.getCudaEnabledDeviceCount())"





