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

source $(pwd)/load_system_config.sh
wait

CONFIG_SOURCE=$(pwd)/nepi_docker_config.yaml
source $(pwd)/load_docker_config.sh
wait

if [ $? -eq 1 ]; then
    echo "Failed to load ${CONFIG_SOURCE}"
    exit 1
fi

####################################
CONFIG_SOURCE=${NEPI_CONFIG}/docker_cfg/nepi_docker_config.yaml

if [[ "$NEPI_RUNNING_FS" == "nepi_fs_a" ]]; then
EXPORT_NAME="${NEPI_RUNNING_FS}-${NEPI_FSA_TAG}"
echo $EXPORT_NAME
else
EXPORT_NAME="${NEPI_RUNNING_FS}-${NEPI_FSB_TAG}"
echo $EXPORT_NAME
fi

if [[ $NEPI_RUNNING_FS_ID != 0 ]]; then
    TAR_EXPORT_PATH=${NEPI_EXPORT_PATH}/''${EXPORT_NAME}.tar
    #echo $TAR_EXPORT_PATH
    sudo docker export $NEPI_RUNNING_FS_ID > $TAR_EXPORT_PATH
else
    echo "No Running NEPI Container to Export"
fi

update_yaml_value "NEPI_FS_EXPORT" 0 "${CONFIG_SOURCE}"

source $(pwd)/load_docker_config.sh
wait