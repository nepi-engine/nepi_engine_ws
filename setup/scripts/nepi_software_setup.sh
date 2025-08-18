#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##


# This file sets up the OS software requirements for a NEPI File System installation


source ./nepi_variales_setup.sh
echo "Starting with NEPI Home folder: ${NEPI_HOME}"


#######################################
## Configure NEPI Software Requirements


echo ""
echo "Installing Software Requirements"

# Change to tmp install folder
TMP=${STORAGE["tmp"]}
mkdir $TMP
cd $TMP


# Download and install required software
sudo wget https://github.com/LORD-MicroStrain/MSCL/releases/download/v67.1.0/MSCL_arm64_Python3.10_v67.1.0.deb
sudo dpkg -i MSCL*



sudo apt-get update

#### Install Software
sudo apt-get install lsb-release -y
sudo apt-get install nano -y
sudo apt-get install git -y
sudo apt-get install nano -y


sudo apt-get install trash-cli -y
sudo apt-get install onboard -y
sudo apt-get install setools -y
sudo apt-get install ubuntu-advantage-tools -y

sudo apt-get install iproute2 -y

sudo apt-get install scons -y # Required for num_gpsd
sudo apt-get install zstd -y # Required for Zed SDK installer
sudo apt-get install dos2unix -y # Required for robust automation_mgr
sudo apt-get install libv4l-dev v4l-utils -y # V4L Cameras (USB, etc.)
sudo apt-get install hostapd -y # WiFi access point setup
sudo apt-get install curl -y # Node.js installation below
sudo apt-get install v4l-utils -y
sudo apt-get install isc-dhcp-client -y
sudo apt-get install wpasupplicant -y
sudo apt-get install psmisc -y
sudo apt-get install scapy -y
sudo apt-get install minicom -y
sudo apt-get install dconf-editor -y
sudo apt-get install python-debian -y

sudo apt-get install python3-scipy -y
#sudo -H pip install --upgrade scipy

sudo apt-get install libffi-dev -y # Required for python cryptography library
sudo apt-get install scons -y # Required for num_gpsd
sudo apt-get install zstd -y # Required for Zed SDK installer
sudo apt-get install dos2unix -y # Required for robust automation_mgr
sudo apt-get install libv4l-dev v4l-utils -y # V4L Cameras (USB, etc.)
sudo apt-get install hostapd -y # WiFi access point setup
sudo apt-get install curl -y # Node.js installation below
sudo apt-get install gparted -y
sudo apt-get install chromium-browser -y # At least once, apt-get seemed to work for this where apt-get did not, hence the command here
sudo apt-get install socat protobuf-compiler -y

sudo apt-get install gnupg -y
sudo apt-get install kgpg -y

### Install NEPI Managed Services 
sudo apt-get install supervisor -y


sudo apt-get install openssh-server -y
#sudo systemctl enable sshd

echo "Installing chrony for NTP services"
sudo apt-get install chrony -y
#sudo systemctl enable --now chrony.service

sudo apt-get install samba -y
#systemctl enable samba

### Install static IP tools
echo "Installing static IP dependencies"
sudo apt-get install ifupdown -y 
sudo apt-get install net-tools -y 
    



I

# Maybe?
#sudo apt-get upgrade



#######################
# Remove old pythons
#sudo apt-get remove --purge python3.x
#sudo rm -r /usr/bin/python*
#sudo rm -r /usr/lib/python*
#sudo apt-get autoremove


# Uninstall ROS if reinstalling/updating
# sudo apt-get remove ros-noetic-*
# sudo apt-get autoremove
# After that, it's recommended to remove ROS-related environment variables from your .bashrc file 
# and delete the ROS installation directory, typically /opt/ros/noetic. 


# Install Python 
sudo apt-get update 

sudo apt-get install --reinstall ca-certificates
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa -y 
sudo apt-get update
sudo apt-get install python3.10 -y 

# Install pip
curl -sS https://bootstrap.pypa.io/get-pip.py | sudo python3.10


sudo apt-get install python3.10-distutils -y
sudo apt-get install python3.10-venv -y
sudo apt-get install python3.10-dev -y 



# Update python symlinks
sudo ln -sfn /usr/bin/python3.10 /usr/bin/python3
sudo ln -sfn /usr/bin/python3 /usr/bin/python
sudo python3.10 -m pip --version



#Manual installs some additinal packages in sudo one at a time
################################
# Install some required packages

#sudo pip uninstall wheel
#sudo pip install --no-input wheel
#python setup.py bdist_wheel 

sudo pip install --no-input cffi
sudo pip uninstall netifaces
sudo pip install --no-input netifaces



#sudo pip uninstall psutil
#sudo pip uninstall --no-input psutil

sudo pip install --upgrade setuptools



#############
# Other general python utilities
pip install --no-input --user labelImg # For onboard training
pip install --no-input --user licenseheaders # For updating license files and source code comments


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
# nano ~/.nepi_aliases
# Add to end of bashrc
#    export SETUPTOOLS_USE_DISTUTILS=stdlib
#    export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
#    export PYTHONPATH=/usr/local/lib/python3.10/site-packages/:$PYTHONPATH


##_________________________
## Setup ROS



#  Install ros
#  https://wiki.ros.org/noetic/Installation/Ubuntu

cd /mnt/nepi_storage/tmp
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-get install curl # if you haven't already installed curl
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
sudo apt-get update
####################
# Do if ROS not installed
sudo apt-get install ros-noetic-desktop-full
source /opt/ros/noetic/setup.bash
sudo apt-get install python3-rosdep 
sudo apt-get install python3-rosinstall 
sudo apt-get install python3-rosinstall-generator 
sudo apt-get install python3-wstool build-essential
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

sudo apt-get install $ADDITIONAL_ROS_PACKAGES


sudo apt-get install ros-noetic-cv-bridge
sudo apt-get install ros-noetic-web-video-server

####################
# Try and fix issues

#sudo pip install --no-input bagpy
#sudo pip install --no-input pycryptodome-test-vectors

# Fix some issues
#sudo vi /usr/lib/python3/dist-packages/Cryptodome/Util/_raw_api.py
# Comment out line 258 "#raise OSError("Cannot load native module '%s': %s" % (name, ", ".join(attempts)))"
#sudo vi /usr/lib/python3/dist-packages/Cryptodome/Cipher/AES.py
# Line 69 Add "if _raw_cpuid_lib is not None:" befor try:


#cd ${FOLDER}


# Mavros requires some additional setup for geographiclib
sudo /opt/ros/${ROS_VERSION}/lib/mavros/install_geographiclib_datasets.sh


# Maybe?
# Change the default .ros folder permissions for some reason
#sudo mkdir /home/ros
#sudo chown -R nepi:nepi /home/ros

# Setup rosdep
#sudo rm -r /etc/ros/rosdep/sources.list.d/20-default.list
#sudo rosdep init
#rosdep update

source /opt/ros/noetic/setup.bash






############################################
# Maybe not
# upgrade python hdf5
# sudo pip install --no-input --upgrade h5py
sudo pip install --no-input open3d --ignore-installed
sudo pip install --upgrade tornado
_________________________

# Install additional python requirements
# Copy the requirements files from nepi_engine/nepi_env/setup to /mnt/nepi_storage/tmp
NEPI_REQ_SOURCE=$(dirname "$(pwd)")/resources/requirements
sudo cp ${NEPI_REQ_SOURCE}/requirements.txt ./
cat requirements.txt | sed -e '/^\s*#.*$/d' -e '/^\s*$/d' | xargs -n 1 sudo python3.10 -m pip install







# Revert numpy
sudo pip uninstall numpy
sudo pip3 install numpy=='1.24.4'

sudo pip install --no-input supervisor 
## Maybe not needed with requirements
        # NEPI runtime python3 dependencies. Must install these in system folders such that they are on root user's python path
        sudo -H pip install --no-input pyserial 
        sudo -H pip install --no-input websockets 
        sudo -H pip install --no-input geographiclib 
        sudo -H pip install --no-input PyGeodesy 
        sudo -H pip install --no-input harvesters 
        sudo -H pip install --no-input WSDiscovery 
        sudo -H pip install --no-input python-gnupg 
        sudo -H pip install --no-input onvif_zeep
        sudo -H pip install --no-input onvif 
        sudo -H pip install --no-input rospy_message_converter
        sudo -H pip install --no-input PyUSB
        sudo -H pip install --no-input jetson-stats


        sudo -H pip install --no-input --user labelImg # For onboard training
        sudo -H pip install --no-input --user licenseheaders # For updating license files and source code comments




        sudo pip install --no-input yap
        sudo pip install --no-input yapf



sudo /opt/ros/${ROS_VERSION}/lib/mavros/install_geographiclib_datasets.sh


#########
# Work-around opencv path installation issue on Jetson (after jetpack installation)
sudo ln -s /usr/include/opencv4/opencv2/ /usr/include/opencv
sudo ln -s /usr/lib/aarch64-linux-gnu/cmake/opencv4 /usr/share/OpenCV



#pip install --no-input --user -U pip
#pip install --no-input --user virtualenv


# NEPI runtime python3 dependencies. Must install these in system folders such that they are on root user's python path
sudo -H pip install python-gnupg websockets onvif_zeep geographiclib PyGeodesy onvif harvesters WSDiscovery pyserial


# Install Base Node.js Tools and Packages (Required for RUI, etc.)
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
export NVM_DIR="${NEPI_HOME}/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install 8.11.1 # RUI-required Node version as of this script creation


#################################
# Install Required Software
#################################


# Install and setup supervisor\\
#https://www.digitalocean.com/community/tutorials/how-to-install-and-manage-supervisor-on-ubuntu-and-debian-vps
#https://test-dockerrr.readthedocs.io/en/latest/admin/using_supervisord/






#### Make System Changes
# Disable NetworkManager (for next boot)... causes issues with NEPI IP addr. management
sudo systemctl disable NetworkManager

