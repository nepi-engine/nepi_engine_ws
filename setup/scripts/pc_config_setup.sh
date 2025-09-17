#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##


# This file sets up nepi bash aliases and util functions



echo "########################"
echo "NEPI PC CONFIG SETUP"
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



###################################
# SSH Setup
CONFIG_USER=$USER
NEPI_SSH_DIR=/home/${CONFIG_USER}/ssh_keys
NEPI_SSH_FILE=nepi_engine_default_private_ssh_key

# Add nepi ssh key if not there
echo "Checking nepi ssh key file"
NEPI_SSH_PATH=${NEPI_SSH_DIR}/${NEPI_SSH_FILE}
NEPI_SSH_SOURCE=./resources/ssh_keys/${NEPI_SSH_FILE}
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

#########################################
# Update ETC HOST File
file=/etc/hosts
org_path_backup $file

entry="${NEPI_IP} ${NEPI_USER}"
echo "Updating NEPI IP in ${file}"
if grep -qnw $file -e ${entry}; then
    echo "Found NEPI IP in ${file} ${entry} "
else
    echo "Adding NEPI IP in ${file}"
    echo $entry | sudo tee -a $file
    echo "${entry}-${NEPI_DEVICE_ID}" | sudo tee -a $file
fi

entry="${NEPI_IP} ${NEPI_ADMIN_USER}"
echo "Updating NEPI IP in ${file}"
if grep -qnw $file -e ${entry}; then
    echo "Found NEPI IP in ${file} ${entry} "
else
    echo "Adding NEPI IP in ${file}"
    echo $entry | sudo tee -a $file
    echo "${entry}-${NEPI_DEVICE_ID}" | sudo tee -a $file
fi

entry="${NEPI_IP} ${NEPI_HOST_USER}"
echo "Updating NEPI IP in ${file}"
if grep -qnw $file -e ${entry}; then
    echo "Found NEPI IP in ${file} ${entry} "
else
    echo "Adding NEPI IP in ${file}"
    echo $entry | sudo tee -a $file
    echo "${entry}-${NEPI_DEVICE_ID}" | sudo tee -a $file
fi



#################################
echo " "
echo "NEPI PC Config Setup Complete"
