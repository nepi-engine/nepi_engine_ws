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
echo "NEPI DOCKER BASH SETUP"
echo "########################"

SCRIPT_FOLDER=$(cd -P "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source $(dirname "${SCRIPT_FOLDER}")/resources/bash/nepi_bash_utils 

# Load System Config File
source $(dirname ${SCRIPT_FOLDER})/config/load_system_config.sh
if [ $? -eq 1 ]; then
    echo "Failed to load ${SYSTEM_CONFIG_FILE}"
    exit 1
fi

# Check User Account
# CONFIG_USER=$NEPI_HOST_USER
# if [[ "$USER" != "$CONFIG_USER" ]]; then
#     echo "This script must be run by user account ${CONFIG_USER}."
#     echo "Log in as ${CONFIG_USER} and run again"
#     exit 2
# fi



#############
# Add nepi aliases to bashrc
echo "Updating NEPI aliases file"
BASHRC=/home/${USER}/.bashrc

### Backup USER BASHRC file if needed
echo "Backing Up Bashrc file "
source_path=$BASHRC
overwrite=0
path_backup $source_path "${source_path}.org" $overwrite


echo "Installing NEPI utils file"
NEPI_UTILS_SOURCE=$(dirname "${SCRIPT_FOLDER}")/resources/bash/nepi_bash_utils
NEPI_UTILS_DEST=${HOME}/.nepi_bash_utils
echo "Installing NEPI utils file ${NEPI_UTILS_DEST} "
if [ -f "$NEPI_UTILS_DEST" ]; then
    sudo rm $NEPI_UTILS_DEST
fi
sudo cp $NEPI_UTILS_SOURCE $NEPI_UTILS_DEST
sudo chown -R ${USER}:${USER} $NEPI_UTILS_DEST

NEPI_ALIASES_SOURCE=$(dirname "${SCRIPT_FOLDER}")/resources/bash/nepi_docker_aliases
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

### Backup NEPI BASHRC
source_path=$BASHRC
overwrite=1
path_backup $source_path ${source_path}.nepi $overwrite

#################################
sleep 1 & source $BASHRC
wait
# Print out nepi aliases
echo " "
echo "NEPI Bash Aliases Setup Complete"
echo " "
echo " "
. ${NEPI_ALIASES_DEST} && nepihelp