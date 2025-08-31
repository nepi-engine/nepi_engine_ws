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

echo "########################"
echo "NEPI Docker Bash Setup"
echo "########################"

source /home/${USER}/NEPI_CONFIG.sh

SETUP_SCRIPTS_PATH=${PWD}
sudo chmod +x ${SETUP_SCRIPTS_PATH}/*
sudo chown -R ${USER}:${USER} ${SETUP_SCRIPTS_PATH}/*

sudo cp -p ${SETUP_SCRIPTS_PATH}/docker* /home/${USER}/

#######################
NEPI_CONFIG=/mnt/nepi_config
# Creating nepi_config.yaml file in docker config folder
export CONFIG_DEST=${NEPI_CONFIG}/docker_cfg/nepi_config.yaml
echo "Initializing nepi_config.yaml in ${CONFIG_DEST}"
if [ ! -d "${NEPI_CONFIG}" ]; then
    sudo sudo mkdir $NEPI_CONFIG
fi
if [ ! -d "${NEPI_CONFIG}/docker_cfg" ]; then
    sudo mkdir ${NEPI_CONFIG}/docker_cfg
fi
source $(pwd)/nepi_config_setup.sh
wait


#############
# Add nepi aliases to bashrc
echo "Updating NEPI aliases file"
BASHRC=~/.bashrc

NEPI_CFG_SOURCE=$(dirname "$(pwd)")/resources/bash/nepi_config.sh
NEPI_CFG_DEST=${HOME}/.nepi_config
echo "Installing NEPI utils file ${NEPI_CFG_DEST} "
sudo rm $NEPI_CFG_DEST
sudo cp $NEPI_CFG_SOURCE $NEPI_CFG_DEST
sudo chown -R ${USER}:${USER} $NEPI_CFG_DEST

NEPI_UTILS_SOURCE=$(dirname "$(pwd)")/resources/bash/nepi_bash_utils
NEPI_UTILS_DEST=${HOME}/.nepi_bash_utils
echo "Installing NEPI utils file ${NEPI_UTILS_DEST} "
sudo rm $NEPI_UTILS_DEST
sudo cp $NEPI_UTILS_SOURCE $NEPI_UTILS_DEST
sudo chown -R ${USER}:${USER} $NEPI_UTILS_DEST

NEPI_ALIASES_SOURCE=$(dirname "$(pwd)")/resources/bash/nepi_docker_aliases
NEPI_ALIASES_DEST=${HOME}/.nepi_docker_aliases
echo "Installing NEPI aliases file ${NEPI_ALIASES_DEST} "
sudo rm $NEPI_ALIASES_DEST
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