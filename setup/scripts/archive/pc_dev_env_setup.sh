#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##

# This file sets up a pc side nepi develoment environment

export CONFIG_SOURCE=$(dirname "$(pwd)")/nepi_system_config.yaml
source $(pwd)/load_system_config.sh
wait

SETUP_SCRIPTS_PATH=${PWD}/scripts
sudo chmod +x ${SETUP_SCRIPTS_PATH}/*

###################################
# Variables
NEPI_IP=192.168.179.103
NEPI_USER=nepi

NEPI_SSH_DIR=~/ssh_keys
NEPI_SSH_FILE=nepi_engine_default_private_ssh_key


#############
# Install Required Software


#############
# Add nepi ip to /etc/hosts if not there
HOST_FILE=/etc/hosts
NEPI_HOST="${NEPI_IP} ${NEPI_USER}"
echo "Updating NEPI IP in ${HOST_FILE}"
if grep -qnw $HOST_FILE -e ${NEPI_HOST}; then
    echo "Found NEPI IP in ${HOST_FILE} ${NEPI_HOST} "
else
    echo "Adding NEPI IP in ${HOST_FILE}"
    echo $NEPI_HOST | sudo tee -a $HOST_FILE
    echo "${NEPI_HOST}-${NEPI_DEVICE_ID}" | sudo tee -a $HOST_FILE
fi


#############
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
sudo chown -R ${USER}:${USER} $NEPI_SSH_DIR



#############
# Add nepi aliases to bashrc
. ${SETUP_SCRIPTS_PATH}/pc_bash_setup.sh