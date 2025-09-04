#!/bin/bash

############################################
# PRE FILE SYSTEM SETUP (Host File System Only)
############################################
# DO THIS BEFORE FILE SYSTEM SETUP


# Set up the NEPI Standard ROOTFS (Typically on External Media (e.g SD, SSD, SATA))

# This script is tested to run from a fresh Ubuntu 18.04 install based on the L4T reference rootfs.
# Other base rootfs schemes may work, but should be tested.

# Run this script from anywhere on the device

# This is a specialization of the base NEPI rootfs
# and calls that parent script as a pre-step.

# Run the parent script first
sudo ./nepi_env_setup.sh



#########
# Define some system paths

HOME_DIR=$PWD
REPO_DIR=${HOME_DIR}/nepi_engine
CONFIG_DIR=${REPO_DIR}/nepi_env/config
ETC_DIR=${REPO_DIR}/nepi_env/etc

NEPI_DIR=/opt/nepi
NEPI_RUI=${NEPI_DIR}/nepi_rui
NEPI_CONFIG=${NEPI_DIR}/config
NEPI_ENV=${NEPI_DIR}/ros
NEPI_ETC=${NEPI_DIR}/etc

NEPI_DRIVE=/mnt/nepi_storage



#########
# Preliminary checks
# Internet connectivity:

if ! ping -c 2 google.com; then
    echo "ERROR: System must have internet connection to proceed"
    exit 1
fi

##########
#Resize image
resize2fs /dev/nvme0n1p2
resize2fs /dev/nvme0n1p3
resize2fs /dev/nvme0n1p3



# Install and configure chrony
echo "Installing chrony for NTP services"
sudo apt install chrony
sudo cp ${NEPI_CONFIG}/etc/chrony/chrony.conf ${NEPI_ETC}/chrony.conf
sudo ln -sf ${NEPI_ETC}/chrony.conf /etc/chrony/chrony.conf


# Install static IP tools
echo "Installing static IP dependencies"
sudo apt install ifupdown net-tools


# Install low-level drivers
sudo cp ${NEPI_CONFIG}/lib/wifi_drivers/* /lib/firmware

# Set up static IP addr.
sudo cp -R ${NEPI_CONFIG}/etc/network ${NEPI_ETC}
sudo ln -sf ${NEPI_ETC}/network/interfaces.d /etc/network/interfaces.d

sudo cp -R ${NEPI_CONFIG}/etc/network ${NEPI_ETC}
sudo cp ${NEPI_ETC}/network/interfaces /etc/network/interfaces

# Set up DHCP
sudo cp ${NEPI_CONFIG}/etc/dhcp/dhclient.conf ${NEPI_ETC}/dhclient.conf
sudo ln -sf ${NEPI_ETC}/dhclient.conf /etc/dhcp/dhclient.conf
sudo dhclient


# Install NEPI launch services
SYSTEMD_SERVICE_PATH=/etc/systemd/system

cp ${NEPI_CONFIG}/etc/roslaunch.service $SYSTEMD_SERVICE_PATH
sudo chmod +x ${SYSTEMD_SERVICE_PATH}/roslaunch.service
systemctl enable roslaunch


cp ${NEPI_CONFIG}/etc/nepi_rui.service $SYSTEMD_SERVICE_PATH
sudo chmod +x ${SYSTEMD_SERVICE_PATH}/nepi_rui.service
systemctl enable nepi_rui


sudo chown -R nepi:nepi /opt/nepi/etc
cd $NEPI_DIR
sudo cp -R etc etc.factoryls

#Once you have a unit file, you are ready to test the service:

############################################
# FILE SYSTEM SETUP (Host File System Only)
############################################
# FOLLOW INSTRUCTIONS IN nepi_file_system-#p#p#






