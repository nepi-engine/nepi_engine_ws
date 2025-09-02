#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##

# This File Exports the Running Container

# This file Switches a Running Containers
source /home/${USER}/.nepi_bash_utils
wait

NEPI_DOCKER_CONFIG_FILE=${NEPI_CONFIG}/docker_cfg/nepi_docker_config.yaml

########################
# Update NEPI Docker Variables from nepi_docker_config.yaml
refresh_nepi_config
wait
########################

NEPI_DOCKER_CONFIG_FILE=${NEPI_CONFIG}/docker_cfg/nepi_docker_config.yaml

EXPORT_NAME="${RUNNING_CONT}-${RUNNING_TAG}"
echo $EXPORT_NAME

if [[ $RUNNING_ID != 0 ]]; then
    TAR_EXPORT_PATH=${EXPORT_PATH}/''${EXPORT_NAME}.tar
    #echo $TAR_EXPORT_PATH
    sudo docker export $RUNNING_ID > $TAR_EXPORT_PATH
else
    echo "No Running NEPI Container to Export"
fi
