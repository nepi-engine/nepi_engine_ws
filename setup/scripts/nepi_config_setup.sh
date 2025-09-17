#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##


# This file installs the NEPI Engine File System installation

echo "########################"
echo "NEPI CONFIG SETUP"
echo "########################"



###################

CONFIG_USER=nepi
NEPI_SYSTEM_CONFIG_SOURCE=$(dirname "$(pwd)")/config/nepi_system_config.yaml
NEPI_SYSTEM_PATH=/opt/nepi
NEPI_SYSTEM_CONFIG_DEST_PATH=/mnt/nepi_config/factory_cfg/etc
NEPI_SYSTEM_CONFIG_DEST=${NEPI_SYSTEM_CONFIG_DEST_PATH}/nepi_system_config.yaml


###################
# Copy ETC Files
###################
ETC_SOURCE_PATH=$(dirname "$(pwd)")/resources/etc
ETC_DEST_PATH=$NEPI_SYSTEM_CONFIG_DEST_PATH

echo ""
echo "Populating Factory ETC Folder from ${ETC_SOURCE_PATH} to ${ETC_DEST_PATH}"
sudo mkdir -p $ETC_DEST_PATH
sudo cp -R ${ETC_SOURCE_PATH}/* ${ETC_DEST_PATH}/
sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $ETC_DEST_PATH
sudo chmod -R 775 $ETC_DEST_PATH


SCRIPTS_SOURCE_PATH=$(dirname "$(pwd)")/resources/scripts
SCRIPTS_DEST_PATH=${NEPI_SYSTEM_PATH}/scripts
echo ""
echo "Populating System Scripts Folder from ${SCRIPTS_SOURCE_PATH} to ${SCRIPTS_DEST_PATH}"
sudo mkdir -p $SCRIPTS_DEST_PATH
sudo cp -R ${SCRIPTS_SOURCE_PATH}/* ${SCRIPTS_DEST_PATH}/
sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $SCRIPTS_DEST_PATH
sudo chmod -R 775 $SCRIPTS_DEST_PATH

if [ -f "$NEPI_SYSTEM_CONFIG_DEST" ]; then
    ## Check Selection
    echo ""
    echo ""
    echo "Do You Want to OverWrite System Config: ${OP_SELECTION}"
    select ovw in "View_Original" "View_New" "Yes" "No" "Quit"; do
        case $ovw in
            View_Original ) print_config_file $NEPI_SYSTEM_CONFIG_DEST;;
            View_New )  print_config_file $NEPI_SYSTEM_CONFIG_SOURCE;;
            Yes ) OVERWRITE=1; break;;
            No ) OVERWRITE=0; break;;
            Quit ) exit 1
        esac
    done


    if [ "$OVERWRITE" -eq 1 ]; then
    echo "Updating NEPI CONFIG ${NEPI_SYSTEM_CONFIG_DEST} "
    sudo cp ${NEPI_SYSTEM_CONFIG_SOURCE} ${NEPI_SYSTEM_CONFIG_DEST}
    fi

else
    sudo mkdir -p $NEPI_SYSTEM_CONFIG_DEST_PATH
    sudo cp ${NEPI_SYSTEM_CONFIG_SOURCE} ${NEPI_SYSTEM_CONFIG_DEST}

fi

echo "Refreshing NEPI CONFIG from ${NEPI_SYSTEM_CONFIG_DEST} "
source ${NEPI_SYSTEM_CONFIG_DEST_PATH}/load_system_config.sh
if [ $? -eq 1 ]; then
    echo "Failed to load ${NEPI_SYSTEM_CONFIG_DEST_PATH}/load_system_config.sh"
    exit 1
fi

CONFIG_USER=$NEPI_USER
if [[ "$USER" != "$CONFIG_USER" ]]; then
    echo "This script must be run by user account ${CONFIG_USER}."
    echo "Log in as ${CONFIG_USER} and run again"
    exit 1
fi


#################################
# Create Nepi Required Folders
echo "Checking NEPI Required Folders"
rfolder=$NEPI_BASE
if [ ! -d "$rfolder" ]; then
    echo "Creating NEPI Folder: ${rfolder}"
    sudo mkdir -p $rfolder
    sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $rfolder
fi
rfolder=$NEPI_STORAGE
if [ ! -d "$rfolder" ]; then
    echo "Creating NEPI Folder: ${rfolder}"
    sudo mkdir -p $rfolder
    sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $rfolder
fi

rfolder=${NEPI_CONFIG}/docker_cfg/etc
if [ ! -f "$rfolder" ]; then
    echo "Creating NEPI Folder: ${rfolder}"
    sudo mkdir -p $rfolder
    sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $rfolder
fi
rfolder=${NEPI_CONFIG}/factory_cfg/etc
if [ ! -d "$rfolder" ]; then
    echo "Creating NEPI Folder: ${rfolder}"
    sudo mkdir -p $rfolder
    sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $rfolder
fi
rfolder=${NEPI_CONFIG}/system_cfg/etc
if [ ! -d "$rfolder" ]; then
    echo "Creating NEPI Folder: ${rfolder}"
    sudo mkdir -p $rfolder
    sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $rfolder
fi
#################################


########################
# INSTALL NEPI SSH KEY
########################
CONFIG_USER=$USER
NEPI_SSH_DIR=/home/${CONFIG_USER}/ssh_keys
NEPI_SSH_FILE=nepi_engine_default_private_ssh_key

# Add nepi ssh key if not there
echo "Checking nepi ssh key file"
NEPI_SSH_PATH=${NEPI_SSH_DIR}/${NEPI_SSH_FILE}
NEPI_SSH_SOURCE=$(dirname "$(pwd)")/resources/ssh_keys/${NEPI_SSH_FILE}
if [ -e $NEPI_SSH_PATH ]; then
    echo "Found NEPI ssh private key ${NEPI_SSH_PATH} "
else
    echo "Installing NEPI ssh private key ${NEPI_SSH_PATH} "
    mkdir $NEPI_SSH_DIR
    cp $NEPI_SSH_SOURCE $NEPI_SSH_PATH
fi
sudo chmod 600 $NEPI_SSH_PATH
sudo chmod 700 $NEPI_SSH_DIR
sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $NEPI_SSH_DIR



###############
# RUN ETC UPDATE SCRIPT
###############
echo "Updating NEPI Config files in ${ETC_DEST_PATH}"
source ${ETC_DEST_PATH}/update_etc_files.sh
wait

##################################################
# Set up the NEPI sys env bash file
NEPI_ETC=${NEPI_BASE}/etc
echo "Updating system env bash file"
sudo chmod +x ${NEPI_ETC}/sys_env.bash
sudo rm ${NEPI_BASE}/sys_env.bash
sudo cp ${NEPI_ETC}/sys_env.bash ${NEPI_BASE}/sys_env.bash


#########################################
# Setup NEPI Engine services
#########################################
SYSTEMD_SERVICE_PATH=/etc/systemd/system
echo ""
echo "Setting up NEPI Engine Services"

sudo chmod +x ${NEPI_ETC}/services/*
sudo cp ${NEPI_ETC}/services/* ${SYSTEMD_SERVICE_PATH}/

sudo systemctl enable nepi_engine


#####################################
# Backup NEPI folders to catch final changes
#####################################
if [[ "$NEPI_MANAGES_ETC" -eq 1 ]]; then
    back_ext=nepi
    overwrite=1

    ### Backup ETC folder
    folder=/etc
    folder_back=${folder}.${back_ext}
    path_backup $folder $folder_back $overwrite

    ### Backup USR LIB SYSTEMD folder
    folder=/usr/lib/systemd/system
    folder_back=${folder}.${back_ext}
    path_backup $folder $folder_back $overwrite

    ### Backup RUN SYSTEMD folder
    folder=/run/systemd/system
    folder_back=${folder}.${back_ext}
    path_backup $folder $folder_back $overwrite

    ### Backup USR LIB SYSTEMD USER folder
    folder=/usr/lib/systemd/user
    folder_back=${folder}.${back_ext}
    path_backup $folder $folder_back $overwrite
fi

sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $NEPI_SYSTEM_PATH
##############################################
echo "NEPI Config Setup Complete"
##############################################

