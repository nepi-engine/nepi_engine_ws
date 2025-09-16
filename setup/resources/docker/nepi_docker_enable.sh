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

# Load NEPI SYSTEM CONFIG
SCRIPT_FOLDER=$(dirname "$(readlink -f "$0")")
ETC_FOLDER=${SCRIPT_FOLDER}/etc
if [ -d "$ETC_FOLDER" ]; then
    echo "Failed to find ETC folder at ${ETC_FOLDER}"
    exit 1
fi
source ${ETC_FOLDER}/load_system_config.sh
wait
if [ $? -eq 1 ]; then
    echo "Failed to load ${ETC_FOLDER}/load_system_config.sh"
    exit 1
fi

# Load NEPI DOCKER
CONFIG_SOURCE=$(pwd)/nepi_docker_config.yaml
source $(pwd)/load_docker_config.sh
wait
if [ $? -eq 1 ]; then
    echo "Failed to load ${CONFIG_SOURCE}"
    exit 1
fi

########################
# Enable NEPI Docker System
########################

if [[ "$NEPI_MANAGES_ETC" -eq 1 ]]; then

    ########################
    # Sync ETC folder
    source_path=/etc.nepi
    target_path=/etc
    path_sync $source_path $target_path

    # Sync USR LIB SYSTEMD folder
    source_path=/usr/lib/systemd/system.nepi
    target_path=/usr/lib/systemd/system
    path_sync $source_path $target_path

    # Sync RUN SYSTEMD SYSfolder
    source_path=/run/systemd/system.nepi
    target_path=/run/systemd/system
    path_sync $source_path $target_path

    # Sync USR SYSTEMD USER folder
    source_path=/usr/lib/systemd/user.nepi
    target_path=/usr/lib/systemd/user
    path_sync $source_path $target_path

fi
# Restore BASHRC file
source_path=/home/${USER}/.bashrc.nepi
target_path=/home/${USER}/.bashrc
create_nepi_path_link $file

# Start nepi docker service
echo "Enabling NEPI DOCKER service: nepi_docker"
sudo systemctl enable nepi_docker

echo  "NEPI Enable Complete. Reboot Your Machine"