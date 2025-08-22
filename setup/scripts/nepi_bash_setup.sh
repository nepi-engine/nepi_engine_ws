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

SETUP_SCRIPTS_PATH=${PWD}/scripts
sudo chmod +x ${SETUP_SCRIPTS_PATH}/*


#####################################
# Add nepi aliases to bashrc
echo "Updating NEPI aliases file"
BASHRC=~/.bashrc

NEPI_UTILS_SOURCE=$(dirname "$(pwd)")/resources/bash/nepi_bash_utils
NEPI_UTILS_DEST=${HOME}/.nepi_bash_utils
echo "Installing NEPI utils file ${NEPI_UTILS_DEST} "
sudo rm $NEPI_UTILS_DEST
sudo cp $NEPI_UTILS_SOURCE $NEPI_UTILS_DEST
sudo chown -R ${NEPI_USER}:${NEPI_USER} $NEPI_UTILS_DEST

NEPI_ALIASES_SOURCE=$(dirname "$(pwd)")/resources/bash/nepi_system_aliases
NEPI_ALIASES_DEST=${NEPI_HOME}/.nepi_system_aliases
echo ""
echo "Populating System Folders from ${NEPI_ALIASES_SOURCE}"
echo ""
echo "Installing NEPI aliases file to ${NEPI_ALIASES_DEST} "
sudo rm $NEPI_ALIASES_DEST
sudo cp $NEPI_ALIASES_SOURCE $NEPI_ALIASES_DEST
sudo chown -R ${NEPI_USER}:${NEPI_USER} $NEPI_ALIASES_DEST


#############
echo "Updating bashrc file"
if grep -qnw $BASHRC -e "##### Source NEPI Aliases #####" ; then
    echo "Already Done"
else
    echo " " | sudo tee -a $BASHRC
    echo "##### Source NEPI Aliases #####" | sudo tee -a $BASHRC
    echo "if [ -f ${NEPI_ALIASES_DEST} ]; then" | sudo tee -a $BASHRC
    echo "    . ${NEPI_ALIASES_DEST}" | sudo tee -a $BASHRC
    echo "fi" | sudo tee -a $BASHRC
    echo "Done"
fi


ROOTRC=/root/.bashrc
# Maybe copy to root?


echo " "
echo "NEPI Bash Aliases Setup Complete"
echo " "

