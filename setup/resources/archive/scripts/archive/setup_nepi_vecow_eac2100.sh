#!/bin/bash

# EAC-2000/2100 specific NEPI rootfs setup steps. This is a specialization of the NEPI Jetson rootfs
# and calls that parent script as a pre-step.

# Run the parent script first
sudo ./setup_nepi_jetson_rootfs.sh

# The script is assumed to run from a directory structure that mirrors the Git repo it is housed in.
HOME_DIR=$PWD

# Copy the EAC2100-specialized Linux config files
sudo cp -r ${HOME_DIR}/config_eac2100/* /opt/nepi/config

# Install the Zed SDK
# TODO: We should ensure that we are installing the proper SDK for the current jetpack -- below assumes jetpack 5.1.1
mkdir ~/tmp && cd ~/tmp
wget https://download.stereolabs.com/zedsdk/4.0/l4t35.3/jetsons
chmod a+x jetsons
echo "Installing Zed SDK (FOR JETPACK 5.1.1): Interactive steps required"
./jetsons
cd $HOME_DIR
rm -rf ~/tmp
# And the Zed ROS Wrapper
mkdir -p ~/zed_ros_ws/src
cd ~/zed_ros_ws/src
git clone --recursive https://github.com/stereolabs/zed-ros-wrapper.git
cd ..
catkin build --profile=Release
cd ..