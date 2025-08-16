#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##


# This file sets up NEPI File System on a device hosted a nepi file system 
# or inside a ubuntu docker container


# NEPI Hardware Host Options: GENERIC,JETSON,RPI
if [[ ! -v NEPI_HW ]]; then
    # NEPI Hardware Host Options: GENERIC,JETSON,RPI
    NEPI_HW=JETSON


    ###################################
    # System Setup Variables
    ##################################
    NEPI_IP=192.168.179.103
    NEPI_USER=nepi

    # NEPI PARTITIONS
    NEPI_DOCKER=/mnt/nepi_docker
    NEPI_STORAGE=/mnt/nepi_storage
    NEPI_CONFIG=/mnt/nepi_config

    FS_MIN_GB=50
    STORAGE_MIN_GB=150
    CONFIG_MIN_GB=1

    ##########################
    # Process Folders
    CURRENT_FOLDER=$PWD

    ##########################
    # NEPI File System 
    NEPI_HOME=/home/${NEPI_USER}
    NEPI_BASE=/opt/nepi
    NEPI_RUI=${NEPI_BASE}/nepi_rui
    NEPI_ENGINE=${NEPI_BASE}/nepi_engine
    NEPI_ETC=${NEPI_BASE}/etc

    SYSTEMD_SERVICE_PATH=/etc/systemd/system

    #################
    # NEPI Storage Folders

    declare -A STORAGE
    STORAGE['data']=${NEPI_STORAGE}/data
    STORAGE['ai_models']=${NEPI_STORAGE}/ai_models
    STORAGE['ai_training']=${NEPI_STORAGE}/ai_training
    STORAGE['automation_scripts']=${NEPI_STORAGE}/automation_scripts
    STORAGE['databases']=${NEPI_STORAGE}/databases
    STORAGE['install']=${NEPI_STORAGE}/install
    STORAGE['nepi_src']=${NEPI_STORAGE}/nepi_src
    STORAGE['nepi_full_img']=${NEPI_STORAGE}/nepi_full_img
    STORAGE['nepi_full_img_archive']=${NEPI_STORAGE}/nepi_full_img_archive
    STORAGE['sample_data']=${NEPI_STORAGE}/sample_data
    STORAGE['user_cfg']=${NEPI_STORAGE}/user_cfg
    STORAGE['tmp']=${NEPI_STORAGE}/tmp

    STORAGE['nepi_cfg']=${NEPI_CONFIG}/nepi_cfg
    STORAGE['factory_cfg']=${NEPI_CONFIG}/factory_cfg


    NEPI_ETC_SOURCE=./../etc
    NEPI_ALIASES_SOURCE=./../aliases/.nepi_system_aliases
    NEPI_ALIASES=${NEPI_HOME}/.nepi_system_aliases
    BASHRC=${NEPI_HOME}/.bashrc
fi



#######################################
## Configure NEPI Software Requirements


echo ""
echo "Installing Software Requirements"

# Change to tmp install folder
cd /mnt/nepi_storage
mkdir tmp
cd tmp


# Download and install required software
sudo wget https://github.com/LORD-MicroStrain/MSCL/releases/download/v67.1.0/MSCL_arm64_Python3.10_v67.1.0.deb
sudo dpkg -i MSCL*



sudo apt-get update

#### Install Software
sudo apt-get install lsb-release -y
sudo apt-get install nano
sudo apt-get install git -y
sudo apt-get install nano


sudo apt-get install trash-cli
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
sudo apt-get install python-debian

sudo apt-get install python3-scipy
#sudo -H pip install --upgrade scipy

sudo apt-get install libffi-dev # Required for python cryptography library
sudo apt-get install scons # Required for num_gpsd
sudo apt-get install zstd # Required for Zed SDK installer
sudo apt-get install dos2unix # Required for robust automation_mgr
sudo apt-get install libv4l-dev v4l-utils # V4L Cameras (USB, etc.)
sudo apt-get install hostapd # WiFi access point setup
sudo apt-get install curl # Node.js installation below
sudo apt-get install gparted
sudo apt-get install chromium-browser # At least once, apt-get seemed to work for this where apt-get did not, hence the command here
sudo apt-get install socat protobuf-compiler

sudo apt-get install gnupg
sudo apt-get install kgpg

### Install NEPI Managed Services 
sudo apt-get install supervisor
sudo systemctl enable supervisor

sudo apt-get install -y openssh-server
#sudo systemctl enable sshd

echo "Installing chrony for NTP services"
sudo apt-get install chrony
#sudo systemctl enable --now chrony.service

sudo apt-get install samba
#systemctl enable samba

### Install static IP tools
echo "Installing static IP dependencies"
sudo apt-get install ifupdown net-tools
    

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
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get update
sudo apt-get install python3.10 
sudo apt-get install python3.10-distutils -f

# Update python symlinks
sudo ln -sfn /usr/bin/python3.10 /usr/bin/python3
sudo ln -sfn /usr/bin/python3 /usr/bin/python

sudo apt-get install python3.10-venv 
sudo apt-get install python3.10-dev 

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

sudo pip install bagpy
sudo pip install pycryptodome-test-vectors

# Fix some issues
sudo vi /usr/lib/python3/dist-packages/Cryptodome/Util/_raw_api.py
# Comment out line 258 "#raise OSError("Cannot load native module '%s': %s" % (name, ", ".join(attempts)))"
sudo vi /usr/lib/python3/dist-packages/Cryptodome/Cipher/AES.py
# Line 69 Add "if _raw_cpuid_lib is not None:" befor try:


cd ${FOLDER}



# 1) edit the following file: 
#sudo su
#cd /opt/ros/noetic/lib/rosbridge_server/
#cp rosbridge_websocket.py  rosbridge_websocket.bak
#vi rosbridge_websocket.py
# Add the following lines under import sys


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
# pip install --upgrade h5py

_________________________





#Manual installs some additinal packages in sudo one at a time
################################
# Install some required packages

sudo pip install cffi
pip install open3d --ignore-installed
sudo pip install open3d --ignore-installed

#sudo pip uninstall netifaces
sudo pip install netifaces



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

sudo pip install supervisor 
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




        sudo pip install yap
        #pip install yap
        sudo pip install yapf






sudo /opt/ros/${ROS_VERSION}/lib/mavros/install_geographiclib_datasets.sh






#########
# Work-around opencv path installation issue on Jetson (after jetpack installation)
sudo ln -s /usr/include/opencv4/opencv2/ /usr/include/opencv
sudo ln -s /usr/lib/aarch64-linux-gnu/cmake/opencv4 /usr/share/OpenCV










#pip install --user -U pip
#pip install --user virtualenv


# NEPI runtime python3 dependencies. Must install these in system folders such that they are on root user's python path
sudo -H pip install python-gnupg websockets onvif_zeep geographiclib PyGeodesy onvif harvesters WSDiscovery pyserial










# Install Base Node.js Tools and Packages (Required for RUI, etc.)
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
export NVM_DIR="$HOME/.nvm"
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

