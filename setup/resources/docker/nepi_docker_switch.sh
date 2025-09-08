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
NEPI_DOCKER_CONFIG_PATH=$(pwd)/nepi_docker_config.yaml
#echo $NEPI_DOCKER_CONFIG_PATH

### SET INACTIVE DATA AS ACTIVE DATA
update_yaml_value "NEPI_ACTUVE_FS" "${NEPI_INACTIVE_FS}" "${NEPI_DOCKER_CONFIG_PATH}"
update_yaml_value "NEPI_INACTIVE_FS" "${NEPI_ACTUVE_FS}" "${NEPI_DOCKER_CONFIG_PATH}"
update_yaml_value "NEPI_FS_SWITCH" 0 "${NEPI_DOCKER_CONFIG_PATH}"


source $(pwd)/load_docker_config.sh


########################
# Update NEPI Docker Variables from nepi_docker_config.yaml

########################

#######
# Start Switched Container
#  . ./start_nepi_docker


