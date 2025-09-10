#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##


# This file sets up the ROS package 

echo "########################"
echo "NEPI ROS SETUP"
echo "########################"

# Load System Config File
SCRIPT_FOLDER=$(pwd)
cd $(dirname $(pwd))/config
source load_system_config.sh
if [ $? -eq 1 ]; then
    echo "Failed to load ${SYSTEM_CONFIG_FILE}"
    cd $SCRIPT_FOLDER
    exit 1
fi
cd $SCRIPT_FOLDER

#######################################
## Configure NEPI Software Requirements
# Uninstall ROS if reinstalling/updating
# sudo apt remove ros-noetic-*
# sudo apt autoremove
# After that, it's recommended to remove ROS-related environment variables from your .bashrc file 
# and delete the ROS installation directory, typically 
# sudo rm -r /opt/ros/*

echo ""
echo "Installing ROS ${NEPI_ROS}"

# Create and change to tmp install folder
sudo chown -R nepi:nepi ${STORAGE}
TMP=${STORAGE}\tmp
mkdir $TMP
cd $TMP

HAS_ROS=$(dpkg -l | grep ros-)
if [[ ! -z "$HAS_ROS" ]]; then
    echo "ROS alread installed"
else

############################################
## Setup ROS
############################################
ros_version="${NEPI_ROS,,}"

if [[ "$ros_version" == 'noetic' ]]; then
    sudo apt-get update --fix-missing
    #  Install ros
    #  https://wiki.ros.org/noetic/Installation/Ubuntu

    cd $TMP
    sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
    sudo apt-get install curl -y # if you haven't already installed curl
    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F42ED6FBAB17C654
    sudo apt-get update --fix-missing
    ####################
    # Do if ROS not installed
    sudo apt-get install ros-noetic-desktop-full -y
    source /opt/ros/noetic/setup.bash
    sudo apt-get install -y python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential
    sudo rosdep init
    rosdep update

    #sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F42ED6FBAB17C654
    sudo apt-get update --fix-missing
    
    # Then
    sudo apt-get install ros-noetic-catkin 
    sudo python${PYTHON_VERSION} -m pip install --user git+https://github.com/catkin/catkin_tools.git


    # If needed remove old packages if installed
    #sudo apt remove ros-noetic-cv-bridge -y
    #sudo apt remove ros-noetic-web-video-server -y

    ADDITIONAL_ROS_PACKAGES="ros-${ros_version}-rosbridge-server \
        ros-${ros_version}-pcl-ros \
        ros-${ros_version}-cv-bridge \
        ros-${ros_version}-web-video-server \
        ros-${ros_version}-camera-info-manager \
        ros-${ros_version}-tf2-geometry-msgs \
        ros-${ros_version}-mavros \
        ros-${ros_version}-mavros-extras \
        ros-${ros_version}-serial \
        python3-rosdep" 

        # Deprecated ROS packages?
        #ros-${ros_version}-tf-conversions
        #ros-${ros_version}-diagnostic-updater 
        #ros-${ros_version}-vision-msgs

    sudo apt install $ADDITIONAL_ROS_PACKAGES -y
    source /opt/ros/noetic/setup.bash



    #########################################
    # Install Some Driver Libs
    #########################################
    ros_version="${NEPI_ROS,,}"
    sudo apt-get update --fix-missing
    
    # Install PIX4 & Mavros
    cd $TMP
    git clone https://github.com/PX4/PX4-Autopilot.git --recursive
    bash ./PX4-Autopilot/Tools/setup/ubuntu.sh

    sudo apt-get install ros-${ros_version}-mavros ros-${ros_version}-mavros-extras ros-${ros_version}-mavros-msgs
    wget https://raw.githubusercontent.com/mavlink/mavros/master/mavros/scripts/install_geographiclib_datasets.sh
    sudo bash ./install_geographiclib_datasets.sh


    # Install Driver Support Libs
    cd $TMP
    sudo apt-get install -y ros-${ros_version}-nmea-navsat-driver
    sudo apt-get install -y ros-${ros_version}-microstrain-inertial-driver

fi













