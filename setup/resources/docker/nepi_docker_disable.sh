#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##

# This script Stops a Running NEPI Container

source /home/${USER}/.nepi_bash_utils
wait

cd etc
source load_system_config.sh
wait
if [ $? -eq 1 ]; then
    echo "Failed to load $(pwd)/load_system_config.sh"
    exit 1
fi
cd ..

CONFIG_SOURCE=$(pwd)/nepi_docker_config.yaml
source $(pwd)/load_docker_config.sh
wait

if [ $? -eq 1 ]; then
    echo "Failed to load ${CONFIG_SOURCE}"
    exit 1
fi

########################
# Disable NEPI Docker System
########################
echo "Disabling NEPI DOCKER service: nepi_docker"
sudo systemctl disable nepi_docker

if [[ "$NEPI_MANAGES_ETC" -eq 1 ]]; then

    ########################
    # Link ETC folder
    folder=/etc
    org_path_enable $folder

    # Link USR LIB SYSTEMD folder
    folder=/usr/lib/systemd/system
    org_path_enable $folder

    # Link RUN SYSTEMD SYSfolder
    folder=/run/systemd/system
    org_path_enable $folder

    # Link USR SYSTEMD USER folder
    folder=/usr/lib/systemd/user
    org_path_enable $folder

fi

# Restore BASHRC file
file=/home/${USER}/.bashrc
org_path_enable $file




echo  "NEPI Disable Complete. Reboot Your Machine"