#!/bin/bash

########## Preliminaries, before parent script can run ##########

########## Run first as root user to set up the nepi user and requirements ##############
if [ "$(whoami)" != "nepi" ]; then
    echo "Running root-user preliminaries"
        
    # Set up a user account
    useradd -m nepi
    echo "Enter nepi at password prompt below"
    passwd nepi

    # Install sudo... parent script expects it
    apt install sudo

    usermod -aG sudo nepi

    echo "Now switch to nepi user via \"# su nepi\" and rerun this script"
    exit
fi
######### End root user setup ############################################################



# Install git
sudo apt install git
########## End Preliminaries ####################################

# Run the parent script.
./setup_nepi_rootfs.sh

########## After Parent Script Runs #############################
# The script is assumed to run from a directory structure that mirrors the Git repo it is housed in.
HOME_DIR=$PWD

# Copy the RB5-specialized Linux config files
sudo cp -r ${HOME_DIR}/config_rb5/* /opt/nepi/config

# Link RB5 fstab (mounts SD Card partition 3 as nepi_storage)
sudo mv /etc/fstab /etc/fstab.bak
sudo ln -sf /opt/nepi/config/etc/fstab /etc/fstab

# And mount it to ensure that expected nepi_storage folders exist
sudo mount /mnt/nepi_storage
sudo mkdir -p /mnt/nepi_storage/data
sudo mkdir -p /mnt/nepi_storage/ai_models
sudo mkdir -p /mnt/nepi_storage/automation_scripts
sudo mkdir -p /mnt/nepi_storage/logs
# For S2X, the software update/archive folders are in nepi_storage, too... but that is not always the case (e.g., updated from USB)
sudo mkdir -p /mnt/nepi_storage/nepi_full_img
sudo mkdir -p /mnt/nepi_storage/nepi_full_img_archive
sudo mkdir -p /mnt/nepi_storage/license
# Set ownership and permissions properly - Awkardly, samba seems to use a mixed bag of samba and system authentication, but the following works
sudo chown -R nepi:sambashare /mnt/nepi_storage
sudo chmod -R 0775 /mnt/nepi_storage

# Link RB5 interfaces (uses NEPI interfaces.d scheme)
sudo ln -sf /opt/nepi/config/etc/network/interfaces /etc/network/interfaces

# Install some necessary network tools
sudo apt install ifupdown net-tools isc-dhcp-client rsync

# Apparmor must be disabled -- it is blocking chrony from running off the NEPI config file, even after removing the usr.sbin.chronyd profile
# Could be that there is a much less heavy-handed approach here, but for now just fully disabling
sudo systemctl disable apparmor
