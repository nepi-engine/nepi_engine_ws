#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##


# This file initializes the nepi_docker_config.yaml file

echo "########################"
echo "NEPI DOCKER CONFFIG SETUP"
echo "########################"


echo "Updating NEPI aliases file"


# # Load System Config File
# SCRIPT_FOLDER=${SCRIPT_FOLDER}
# cd $(dirname ${SCRIPT_FOLDER})/config
# source load_system_config.sh
# if [ $? -eq 1 ]; then
#     echo "Failed to load ${SYSTEM_CONFIG_FILE}"
#     cd $SCRIPT_FOLDER
#     exit 1
# fi
# cd $SCRIPT_FOLDER

#############################################

SCRIPT_FOLDER=$(cd -P "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
NEPI_SYSTEM_CONFIG_SOURCE=$(dirname "${SCRIPT_FOLDER}")/config/nepi_system_config.yaml
NEPI_SYSTEM_CONFIG_DEST_PATH=/mnt/nepi_config/factory_cfg/etc
NEPI_SYSTEM_CONFIG_DEST=${NEPI_SYSTEM_CONFIG_DEST_PATH}/nepi_system_config.yaml


###################
# Copy ETC Files
###################
ETC_SOURCE_PATH=$(dirname "${SCRIPT_FOLDER}")/resources/etc
ETC_DEST_PATH=$NEPI_SYSTEM_CONFIG_DEST_PATH
sudo mkdir -p $ETC_DEST_PATH
echo ""
echo "Populating System ETC Folder from ${ETC_SOURCE_PATH} to ${ETC_DEST_PATH}"
sudo cp -R ${ETC_SOURCE_PATH}/* ${ETC_DEST_PATH}/
sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $ETC_DEST_PATH



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
    echo $NEPI_SYSTEM_CONFIG_SOURCE
    echo $NEPI_SYSTEM_CONFIG_DEST
    sudo cp ${NEPI_SYSTEM_CONFIG_SOURCE} ${NEPI_SYSTEM_CONFIG_DEST}
    fi
    #print_config_file $NEPI_SYSTEM_CONFIG_DEST
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

CONFIG_USER=$NEPI_HOST_USER
if [[ "$USER" != "$CONFIG_USER" ]]; then
    echo "This script must be run by user account ${CONFIG_USER}."
    echo "Log in as ${CONFIG_USER} and run again"
    exit 1
fi

#################################
# Create Nepi Required Folders
#################################

# Run NEPI Docker Storage Config File
source ${SCRIPT_FOLDER}/docker_storage_setup.sh
if [ $? -eq 1 ]; then
    echo "Failed to load ${SCRIPT_FOLDER}/nepi_storage_setup.sh"
    exit 1
fi



########################
# INSTALL NEPI SSH KEY
########################
CONFIG_USER=$USER
NEPI_SSH_DIR=/home/${CONFIG_USER}/ssh_keys
NEPI_SSH_FILE=nepi_engine_default_private_ssh_key

# Add nepi ssh key if not there
echo "Checking nepi ssh key file"
NEPI_SSH_PATH=${NEPI_SSH_DIR}/${NEPI_SSH_FILE}
NEPI_SSH_SOURCE=$(dirname "${SCRIPT_FOLDER}")/resources/ssh_keys/${NEPI_SSH_FILE}
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

#####################################
# Copy Files to NEPI Docker Config Folder
####################################
NEPI_DOCKER_CONFIG=${NEPI_CONFIG}/docker_cfg
if [ -d "$NEPI_DOCKER_CONFIG" ]; then
    sudo mkdir -p $NEPI_DOCKER_CONFIG
fi
echo "Copying nepi  docker config files to ${NEPI_DOCKER_CONFIG}"
sudo cp $(dirname "${SCRIPT_FOLDER}")/resources/docker/* ${NEPI_DOCKER_CONFIG}/
#sudo cp -R -p $(dirname "${SCRIPT_FOLDER}")/resources/etc ${NEPI_DOCKER_CONFIG}/

sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $NEPI_DOCKER_CONFIG


#####################################
# Setup NEPI Docker Service
####################################
SYSTEMD_SERVICE_PATH=/etc/systemd/system
echo "Setting Up NEPI Docker Service"
sudo cp ${NEPI_DOCKER_CONFIG}/nepi_docker.service ${SYSTEMD_SERVICE_PATH}/nepi_docker.service

ENABLE_NEPI
echo "Would You Like to Enable NEPI Docker Service on startup?"
while true; do
    read -p "$1 [Y/n]: " yn
    case $yn in
        [Yy]* ) ENABLE_NEPI=1; break;; # User entered 'y' or 'Y', return success (0)
        [Nn]* ) ENABLE_NEPI=0; break;; # User entered 'n' or 'N', return failure (1)
        * ) echo "Please answer yes or no.";; # Invalid input, prompt again
    esac
done

if [[ "$ENABLE_NEPI" -eq 1 ]]; then
    sudo systemctl enable nepi_docker
    echo "########################"
    echo "NEPI Docker Service enabled on startup"
    echo "You can manually enable/disable nepi_docker service with nepienable/nepidisable"
    echo "########################"
else
    echo "########################"
    echo "NEPI Docker Service disabled on startup"
    echo "You can manually enable/disable nepi_docker service with nepienable/nepidisable"
    echo "########################"
fi

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

##################################
echo 'NEPI Docker Config Setup Complete'
##################################

