#!/bin/sh

# Set up the NEPI Init ROOTFS (Typically on EMMC/Flash partition)

# This script is tested to run from a fresh Ubuntu 18.04 install based on the L4T reference rootfs.
# Other base rootfs schemes may work, but should be tested.

# The script is assumed to run from a directory structure that mirrors the Git repo it is housed in.

HOME_DIR=$PWD

# Clear the Desktop
rm ~/Desktop/*

# Update the Background Image
sudo mkdir -p /opt/nepi/resources
sudo cp ${HOME_DIR}/resources/nepi_wallpaper.png /opt/nepi/resources/
sudo chown nepi:nepi /opt/nepi/resources/nepi_wallpaper.png
gsettings set org.gnome.desktop.background picture-uri file:////opt/nepi/resources/nepi_wallpaper.png

# Add a static IP address for guaranteed network reachability
sudo mkdir -p /etc/network/interfaces.d
sudo cp ${HOME_DIR}/config/etc/network/interfaces.d/nepi_static_ip /etc/network/interfaces.d/

# Install static IP tools
echo "Installing static IP dependencies"
sudo apt install ifupdown net-tools

# Add the informative README to the Desktop and Home folder to make it highly visible whether user comes
# in graphically or at cmd line (e.g., SSH).
cp ${HOME_DIR}/resources/README_This_is_not_your_filesystem.txt ~/Desktop/
cp ${HOME_DIR}/resources/README_This_is_not_your_filesystem.txt ~

# Set the hostname
sudo echo "nepi-init-rootfs" > /etc/hostname

# Copy all the required files around the filesystem
sudo cp ${HOME_DIR}/rootfs_ab_handling/nepi_rootfs_ab_handling.service /etc/systemd/system
sudo cp ${HOME_DIR}/rootfs_ab_handling/nepi_rootfs_ab_custom_env.sh /opt/nepi/
sudo cp ${HOME_DIR}/rootfs_ab_handling/nepi_rootfs_ab_handling.sh /opt/nepi/
sudo chmod 777 /opt/nepi/nepi_rootfs_ab_handling.sh

# Setup the service to do NEPI rootfs A/B handling
sudo systemctl daemon-reload
sudo systemctl enable nepi_rootfs_ab_handling.service

echo 'Service to handle rootfs A/B from external media installed'
echo 'Make sure that you have' 
echo '   a. Copied the rootfs to A/B partitions on external medial'
echo '   b. Updated the nepi_rootfs_ab_custom_env.sh file to specify PRIMARY, BACKUP, and STAGING partitions'
echo 'Reboot for changes to take effect.'

# Finally, disable NetworkManager so that static IP doesn't get hosed
sudo systemctl disable NetworkManager