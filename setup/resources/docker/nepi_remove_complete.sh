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
# Remove NEPI Complete
########################

echo "Disabling NEPI DOCKER service: nepi_docker"
sudo systemctl disable nepi_docker

if [[ "$NEPI_MANAGES_ETC" -eq 1 ]]; then

    ########################

    target_path=/etc
    path_sync ${target_path}.org $target_path
    if [ "$?" -eq 0 ]; then
        path_delete ${target_path}.nepi
        path_delete ${target_path}.org
    else
      echo "Failed to remove NEPI config for path ${target_path}"
    fi

    # Sync USR LIB SYSTEMD folder
    target_path=/usr/lib/systemd/system
    target_path=/etc
    path_sync ${target_path}.org $target_path
    if [ "$?" -eq 0 ]; then
        path_delete ${target_path}.nepi
        path_delete ${target_path}.org
    else
      echo "Failed to remove NEPI config for path ${target_path}"
    fi

    # Sync RUN SYSTEMD SYSfolder

    target_path=/run/systemd/system
    target_path=/etc
    path_sync ${target_path}.org $target_path
    if [ "$?" -eq 0 ]; then
        path_delete ${target_path}.nepi
        path_delete ${target_path}.org
    else
      echo "Failed to remove NEPI config for path ${target_path}"
    fi

    # Sync USR SYSTEMD USER folder
    target_path=/usr/lib/systemd/user
    target_path=/etc
    path_sync ${target_path}.org $target_path
    if [ "$?" -eq 0 ]; then
        path_delete ${target_path}.nepi
        path_delete ${target_path}.org
    else
      echo "Failed to remove NEPI config for path ${target_path}"
    fi

fi
# Restore BASHRC files
home_folder=/home/${USER}
target_path=${home_folder}/.bashrc
path_sync ${target_path}.org $target_path
if [ "$?" -eq 0 ]; then
    path_delete ${target_path}.nepi
    path_delete ${target_path}.org
else
    echo "Failed to remove NEPI config for path ${target_path}"
fi

path_delete ${home_folder}/.nepi_docker_aliases
path_delete ${home_folder}/.nepi_bash_aliases

#ToDo: Remove NEPI Storage Folders


echo  "NEPI Remove Complete. Reboot Your Machine"

