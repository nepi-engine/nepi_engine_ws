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

source ./NEPI_CONFIG.sh
wait


#######################################
## Configure NEPI Software Requirements


echo ""
echo "Installing Software Requirements"

# Create and change to tmp install folder
sudo chown -R nepi:nepi ${STORAGE}
TMP=${STORAGE}\tmp
mkdir $TMP
cd $TMP



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

    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F42ED6FBAB17C654
    sudo apt-get update --fix-missing
    
    # Then
    #sudo apt-get install ros-noetic-catkin python-catkin-tools
    #sudo python${PYTHON_VERSION} -m pip3 install --user git+https://github.com/catkin/catkin_tools.git


    # If needed remove old packages if installed
    #sudo apt remove ros-noetic-cv-bridge -y
    #sudo apt remove ros-noetic-web-video-server -y

    ADDITIONAL_ROS_PACKAGES="python3-catkin-tools \
        ros-${ros_version}-rosbridge-server \
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


    source /opt/ros/noetic/setup.bash
    wait


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


    # Install ROS Microstrain
    cd $TMP
    sudo apt-get install -y ros-${ros_version}-nmea-navsat-driver
    sudo apt-get install -y ros-${ros_version}-microstrain-inertial-driver

fi






#########################################
# Setup RUI Required Software
#########################################

python${PYTHON_VERSION} -m pip install --no-input --user -U pip
python${PYTHON_VERSION} -m pip install --no-input --user virtualenv


# Install Base Node.js Tools and Packages (Required for RUI, etc.)
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
export NVM_DIR="${NEPI_HOME}/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install 8.11.1 # RUI-required Node version as of this script creation






