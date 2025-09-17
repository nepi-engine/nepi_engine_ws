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
# Configure NEPI Host Services
########################
if [[ "$NEPI_MANAGES_ETC" -eq 1 ]]; then
    # start the sync service
    echo "Stopping NEPI ETC Sycn service"
    sudo systemctl stop lsyncd
fi


########################
# Stop Running Command
########################
echo $NEPI_RUNNING_FS
#if [[ ( -v NEPI_RUNNING_FS && "$NEPI_RUNNING_FS" -eq 1 ) ]]; then
# if [[ "$NEPI_RUNNING_FS" == "nepi_fs_a" ]]; then
# echo "Stopping Running NEPI Docker Process ${NEPI_FSA_NAME}:${NEPI_FSA_TAG} ID:${RUNNING_ID}"
# sudo docker stop $NEPI_RUNNING_FS_ID
# #sudo docker rm $NEPI_RUNNING_FS_ID
# else
# echo "Stopping Running NEPI Docker Process ${NEPI_FSB_NAME}:${NEPI_FSB_TAG} ID:${RUNNING_ID}"
# sudo docker stop $NEPI_RUNNING_FS_ID
# #sudo docker rm $NEPI_RUNNING_FS_ID
# fi
echo "Stopping Running NEPI Docker Process ${NEPI_RUNNING_FS}:${NEPI_RUNNING_TAG} ID:${NEPI_RUNNING_ID}"
sudo docker stop $NEPI_RUNNING_ID
update_yaml_value "NEPI_RUNNING" 0 "${CONFIG_SOURCE}"
update_yaml_value "NEPI_RUNNING_FS" "unknown" "${CONFIG_SOURCE}"
update_yaml_value "NEPI_RUNNING_ID" 0 "${CONFIG_SOURCE}"
update_yaml_value "NEPI_RUNNING_LAUNCH_TIME" 0 "${CONFIG_SOURCE}"

#fi 

########################
# Update NEPI Docker Variables from nepi_docker_config.yaml
source $(pwd)/load_docker_config.sh
wait
########################