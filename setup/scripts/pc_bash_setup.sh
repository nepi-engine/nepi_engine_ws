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

source $(dirname "$(pwd)")/NEPI_CONFIG.sh
wait

###################################
# Variables
NEPI_SSH_DIR=~/ssh_keys
NEPI_SSH_FILE=nepi_engine_default_private_ssh_key


#############
# Install Required Software





#############
# Add nepi aliases to bashrc
echo "Updating NEPI aliases file"
BASHRC=~/.bashrc

NEPI_UTILS_SOURCE=$(dirname "$(pwd)")/resources/bash/nepi_bash_utils
NEPI_UTILS_DEST=${HOME}/.nepi_bash_utils
echo "Installing NEPI utils file ${NEPI_UTILS_DEST} "
if [ -f "$NEPI_UTILS_DEST" ]; then
    sudo rm $NEPI_UTILS_DEST
fi
sudo cp $NEPI_UTILS_SOURCE $NEPI_UTILS_DEST
sudo chown -R ${USER}:${USER} $NEPI_UTILS_DEST

NEPI_ALIASES_SOURCE=$(dirname "$(pwd)")/resources/bash/nepi_pc_aliases
NEPI_ALIASES_DEST=${HOME}/.nepi_pc_aliases
echo "Installing NEPI aliases file ${NEPI_ALIASES_DEST} "
if [ -f "$NEPI_ALIASES_DEST" ]; then
    sudo rm $NEPI_ALIASES_DEST
fi
sudo cp $NEPI_ALIASES_SOURCE $NEPI_ALIASES_DEST
sudo chown -R ${USER}:${USER} $NEPI_ALIASES_DEST

echo "Updating bashrc file"
if grep -qnw $BASHRC -e "##### Source NEPI Aliases #####" ; then
    echo "Already Done"
else
    echo " " | sudo tee -a $BASHRC
    echo "##### Source NEPI Aliases #####" | sudo tee -a $BASHRC
    echo "if [ -f ${NEPI_ALIASES_DEST} ]; then" | sudo tee -a $BASHRC
    echo "    . ${NEPI_ALIASES_DEST}" | sudo tee -a $BASHRC
    echo "fi" | sudo tee -a $BASHRC
    echo "Update Done"
fi

sudo chmod 755 ${HOME}/.*

echo " "
echo "NEPI Bash Aliases Setup Complete"
echo " "

sleep 1 & source $BASHRC
wait
# Print out nepi aliases
. ${NEPI_ALIASES_DEST} && helpn


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
