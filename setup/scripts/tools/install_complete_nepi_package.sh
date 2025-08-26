#!/bin/bash
##
## NEPI Dual-Use License
## Project: nepi_edge_sdk_base
##
## This license applies to any user of NEPI Engine software
##
## Copyright (C) 2023 Numurus, LLC <https://www.numurus.com>
## see https://github.com/numurus-nepi/nepi_edge_sdk_base
##
## This software is dual-licensed under the terms of either a NEPI software developer license
## or a NEPI software commercial license.
##
## The terms of both the NEPI software developer and commercial licenses
## can be found at: www.numurus.com/licensing-nepi-engine
##
## Redistributions in source code must retain this top-level comment block.
## Plagiarizing this software to sidestep the license obligations is illegal.
##
## Contact Information:
## ====================
## - https://www.numurus.com/licensing-nepi-engine
## - mailto:nepi@numurus.com
##
##


# This interactive script installs an entire local copy of the /opt/nepi/nepi_engine directory
# to a remote machine, overwriting the existing folder if it exists.
# Before overwriting, the existing /opt/nepi/nepi_engine directory on the remote target
# is archived locally.

# The following environment variables can be set ahead of time outside this script for
# faster running:
# SSH_KEY_PATH ==> full path to the private key for the remote system. Defaults to $HOME/.ssh/numurus/numurus_3dx_jetson_sshkey
# REMOTE_HOST ==> IP address or resolvable hostname for the remote system. Defaults to 192.168.179.102
# SRC_PATH ==> Path to the "nepi_engine" folder to be written to /opt/nepi/nepi_engine on the remote system. Defaults to ../../
# SERIAL_NUM ==> Device serial number. Defaults to 0000

#echo "THIS SCRIPT NEEDS REWORK TO INSTALL ENTIRE /opt/nepi FOLDER"
#exit 1
echo "Warning -- this script will overwrite existing settings on the device."

if [ -z "$SSH_KEY_PATH" ]; then
	SSH_KEY_PATH=$HOME/.ssh/numurus_3dx_jetson_sshkey
fi

if [ ! -f "$SSH_KEY_PATH" ]; then
	echo "Enter the path to the SSH key for the remote system"
	read -e -p "Enter the path to the SSH key for the remote system
	> " -i $SSH_KEY_PATH SSH_KEY_PATH
	if [ ! -f "$SSH_KEY_PATH" ]; then
		echo "Error: $SSH_KEY_PATH does not exist... exiting"
		exit 1
	fi
fi

if [ -z "$REMOTE_HOST" ]; then
	REMOTE_HOST=192.168.179.102
	read -e -p "Enter the remote hostname or IP address
	> " -i $REMOTE_HOST REMOTE_HOST
fi

# Set the source path. Assumes this is running from nepi_engine/share
if [ -z "$SRC_PATH" ]; then
	SRC_PATH=../..
	read -e -p "Enter the path to the installation folder (parent of 'nepi_engine' subfolder)
	> " -i $SRC_PATH SRC_PATH
fi

cd $SRC_PATH
#echo "Navigated to `pwd`"

if [ ! -d "./nepi_engine" ]; then
	echo "Error: Installation folder `pwd`/nepi_engine does not exist... exiting"
	exit 1
fi

if [ -z "$SERIAL_NUM" ]; then
	SERIAL_NUM=000000
	read -e -p "Enter the serial number for the device
	> " -i $SERIAL_NUM SERIAL_NUM
fi

echo "Check these selections carefully. Press ctl+C to abort the install or press enter to continue"
echo "   Remote Host   = $REMOTE_HOST"
echo "   Source Path   = `pwd`/nepi_engine"
echo "   Serial Number = $SERIAL_NUM"
read CONTINUE

# This no longer works because serial number is at /opt/nepi/sys_env.bash on the remote system
#cp nepi_engine/etc/sys_env_base.bash nepi_engine/etc/sys_env.bash
#sed -i 's/DEVICE_TYPE=TBD/DEVICE_TYPE=3dsc/' nepi_engine/etc/sys_env.bash
#sed -i 's/DEVICE_SN=.*/DEVICE_SN='$SERIAL_NUM'/' nepi_engine/etc/sys_env.bash
#sed -i 's/SDK_PROJECT=TBD/SDK_PROJECT=num_sdk_jetson/' nepi_engine/etc/sys_env.bash

# Stop the running SDK
echo numurus | ssh -tt -i $SSH_KEY_PATH numurus@$REMOTE_HOST "sudo systemctl stop roslaunch; sudo systemctl stop numurus_rui"

# Copy the entire existing folder for archive purposes
NOW=`date +"%F_%H%M%S"`
ARCHIVE_FOLDER=`pwd`/pre_install_archive_$REMOTE_HOST_$NOW
echo "Archiving the existing installation to $ARCHIVE_FOLDER.tar.gz... this may take a moment"
sleep 3
rsync -avzhe "ssh -i $SSH_KEY_PATH" numurus@$REMOTE_HOST:/opt/nepi/nepi_engine $ARCHIVE_FOLDER
tar -czf $ARCHIVE_FOLDER.tar.gz $ARCHIVE_FOLDER
rm -rf $ARCHIVE_FOLDER

# Delete the remote folder
echo "Removing the old installation on the remote system"
sleep 3
echo numurus | ssh -tt -i $SSH_KEY_PATH numurus@$REMOTE_HOST "rm -rf /opt/nepi/nepi_engine/*"

# Write the new folder to the remote system
echo "Uploading the new installation"
sleep 3
rsync -avzhe "ssh -i $SSH_KEY_PATH" nepi_engine/* numurus@192.168.179.102:/opt/nepi/nepi_engine/

# All done
echo "Installation Complete. Prior installation is archived at $ARCHIVE_FOLDER.tar.gz"
echo "Reboot the remote device to complete the update"
