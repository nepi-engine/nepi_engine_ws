#!/bin/bash

# Jetson-specific NEPI rootfs setup steps. This is a specialization of the base NEPI rootfs
# and calls that parent script as a pre-step.

# Run the parent script first
sudo ./setup_nepi_rootfs.sh

# The script is assumed to run from a directory structure that mirrors the Git repo it is housed in.
HOME_DIR=$PWD

# Install Jetpack SDK stuff
# Have to uncomment entries in /etc/apt/sources.list.d/nvidia-l4t-apt-source.list
sudo sed -i 's/\#deb/deb/g' /etc/apt/sources.list.d/nvidia-l4t-apt-source.list
sudo apt update
sudo apt install nvidia-jetpack

# Work-around opencv path installation issue on Jetson (after jetpack installation)
sudo ln -s /usr/include/opencv4/opencv2/ /usr/include/opencv
sudo ln -s /usr/lib/aarch64-linux-gnu/cmake/opencv4 /usr/share/OpenCV

# Clean up anything that jetpack puts on the Desktop
rm /home/nepi/Desktop/*

read -p "Does this device have EMMC (Xavier NX, etc) or not (Orin NX, etc)? Enter y/n:" response
case "$response" in
    [yY][eE][sS]|[yY]
        HAS_EMMC=Y
    ;;
    [nN][oO]|[nN]
        HAS_EMMC=N
    ;;
    *)
        echo "Invalid response: " + $response
        exit 1
    ;;
esac

# Copy the Jetson-specialized Linux config files
sudo cp -r ${HOME_DIR}/config_jetson/* /opt/nepi/config

# Update fstab - new file depends on whether this S2X has init rootfs on EMMC or NVME
sudo mv /etc/fstab /etc/fstab.bak
if [ $HAS_EMMC = 'Y' ]; then
    # NEPI Storage (SSD partition 3)
    sudo ln -sf /opt/nepi/config/etc/fstab_emmc /etc/fstab
else
    # NEPI Storage (SSD partition 4)
    sudo ln -sf /opt/nepi/config/etc/fstab_nvme_only /etc/fstab

# Set ownership and permissions properly - Awkardly, samba seems to use a mixed bag of samba and 
# system authentication, but the following works
sudo mount /mnt/nepi_storage
sudo chown -R nepi:sambashare /mnt/nepi_storage
sudo chmod -R 0775 /mnt/nepi_storage

# TODO: Zed SDK and zed_ros_wrapper per Stereolabs instructions
