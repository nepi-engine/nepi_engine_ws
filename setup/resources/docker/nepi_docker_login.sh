#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##


# This file Switches a Running Containers

source /home/${USER}/.nepi_bash_utils
wait

source $(pwd)/load_system_config.sh
wait

CONFIG_SOURCE=$(pwd)/nepi_docker_config.yaml
source $(pwd)/load_docker_config.sh
wait

if [ $? -eq 1 ]; then
    echo "Failed to load ${CONFIG_SOURCE}"
    exit 1
fi

#########################################
# Connect to the Running Container
if [[ ! -v NEPI_RUNNING ]]; then
    if [[ ( -v NEPI_RUNNING && "$NEPI_RUNNING" -eq 1 ) ]]; then
        NEPI_RUNNING_NAME=$NEPI_ACTIVE_NAME
        NEPI_RUNNING_TAG=$NEPI_ACTIVE_TAG
        NEPI_RUNNING_ID=$(sudo docker container ls  | grep $NEPI_RUNNING_NAME | awk '{print $1}')
        echo "Logging into Running NEPI Container ${NEPI_RUNNING_NAME}:${NEPI_RUNNING_TAG} ID:${NEPI_RUNNING_ID}"
        sudo docker exec -it -u ${NEPI_USER} $NEPI_RUNNING_ID /bin/bash
    else
        echo "No Running NEPI Contatainer to Log Into"
    fi
else
    echo "Failed to Read NEPI Docker Config File"
    exit 1
fi 
########################

#######
# Start Switched Container
#  . ./start_nepi_docker


