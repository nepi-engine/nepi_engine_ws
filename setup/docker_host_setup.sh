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

SETUP_SCRIPTS_PATH=${PWD}/scripts
sudo chmod +x ${SETUP_SCRIPTS_PATH}/*

#############
# Add nepi aliases to bashrc
echo "Updating NEPI aliases file"
BASHRC=~/.bashrc

NEPI_UTILS_SOURCE=${PWD}/resources/bash/nepi_bash_utils
NEPI_UTILS_DEST=${HOME}/.nepi_bash_utils
echo "Installing NEPI utils file ${NEPI_UTILS_DEST} "
sudo rm $NEPI_UTILS_DEST
sudo cp $NEPI_UTILS_SOURCE $NEPI_UTILS_DEST
sudo chown -R ${USER}:${USER} $NEPI_UTILS_DEST

NEPI_ALIASES_SOURCE=${PWD}/resources/bash/nepi_docker_aliases
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

echo " "
echo "NEPI Bash Aliases Setup Complete"
echo " "

sleep 1 & source $BASHRC
wait
# Print out nepi aliases
. ${NEPI_ALIASES_DEST} && helpn