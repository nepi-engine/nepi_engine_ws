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

source $(dirname "$(pwd)")/NEPI_CONFIG.sh
wait

echo "########################"
echo "NEPI Docker Bash Setup"
echo "########################"



#######################
DOCKER_CONFIG=${NEPI_CONFIG}/docker_cfg
if [ ! -d "${DOCKER_CONFIG}" ]; then
    sudo mkdir -p ${DOCKER_CONFIG}
fi

# Creating nepi_config.yaml file in docker config folder
#export CONFIG_DEST_FILE=${NEPI_CONFIG}/docker_cfg/nepi_config.yaml
#echo "Initializing nepi_config.yaml in ${CONFIG_DEST_FILE}"

#source $(pwd)/docker_config_setup.sh
#wait


#############
# Add nepi aliases to bashrc
echo "Updating NEPI aliases file"
BASHRC=~/.bashrc

NEPI_CFG_SOURCE=$(pwd)/NEPI_CONFIG.sh
NEPI_CFG_DEST=${HOME}/.NEPI_CONFIG
echo "Installing NEPI Config ${NEPI_CFG_DEST} "
if [ -f "$NEPI_CFG_DEST" ]; then
    sudo rm $NEPI_CFG_DEST
fi
sudo cp $NEPI_CFG_SOURCE $NEPI_CFG_DEST
sudo chown -R ${USER}:${USER} $NEPI_CFG_DEST

NEPI_CFG_SOURCE=$(dirname "$(pwd)")/resources/bash/nepi_config
NEPI_CFG_DEST=${HOME}/.nepi_config
echo "Installing NEPI utils file ${NEPI_CFG_DEST} "
if [ -f "$NEPI_CFG_DEST" ]; then
    sudo rm $NEPI_CFG_DEST
fi
sudo cp $NEPI_CFG_SOURCE $NEPI_CFG_DEST
sudo chown -R ${USER}:${USER} $NEPI_CFG_DEST

NEPI_UTILS_SOURCE=$(dirname "$(pwd)")/resources/bash/nepi_bash_utils
NEPI_UTILS_DEST=${HOME}/.nepi_bash_utils
echo "Installing NEPI utils file ${NEPI_UTILS_DEST} "
if [ -f "$NEPI_UTILS_DEST" ]; then
    sudo rm $NEPI_UTILS_DEST
fi
sudo cp $NEPI_UTILS_SOURCE $NEPI_UTILS_DEST
sudo chown -R ${USER}:${USER} $NEPI_UTILS_DEST

NEPI_ALIASES_SOURCE=$(dirname "$(pwd)")/resources/bash/nepi_docker_aliases
NEPI_ALIASES_DEST=${HOME}/.nepi_docker_aliases
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