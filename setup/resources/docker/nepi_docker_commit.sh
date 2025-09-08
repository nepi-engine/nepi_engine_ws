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

source $(pwd)/load_system_config.sh
wait

CONFIG_SOURCE=$(pwd)/nepi_docker_config.yaml
source $(pwd)/load_docker_config.sh
wait

if [ $? -eq 1 ]; then
    echo "Failed to load ${CONFIG_SOURCE}"
    exit 1
fi

########################


########################
# Commit Running Command
########################
# Commit the Running Container
if [[ ! -v NEPI_RUNNING ]]; then
    if [[ ( -v NEPI_RUNNING && "$NEPI_RUNNING" -eq 1 ) ]]; then
        echo "Stopping Running NEPI Docker Process ${NEPI_RUNNING_FS}:${NEPI_RUNNING_TAG} ID:${NEPI_RUNNING_ID}"
        dcommit $NEPI_RUNNING_ID ${1}:${2}
    else
        echo "No Running NEPI Contatainer to Commit"
    fi
else
    echo "Failed to Read NEPI Docker Config File"
    exit 1
fi 

