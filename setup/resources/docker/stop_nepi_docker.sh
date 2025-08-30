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
# This file Switches a Running Containers
source /home/${USER}/.nepi_bash_utils
wait

########################
# Update NEPI Docker Variables from nepi_docker_config.yaml
refresh_nepi_config
wait
########################


########################
# Stop Running Command
########################

if [[ ( -v NEPI_RUNNING && "$NEPI_RUNNING" -eq 1 ) ]]; then
    echo "Stopping Running NEPI Docker Process ${RUNNING_NAME}:${RUNNING_TAG} ID:${RUNNING_ID}"
    dstop $RUNNING_ID
    export NEPI_RUNNING: 0
    export NEPI_RUNNING_NAME: None
    export NEPI_RUNNING_VERSION: uknown
    export NEPI_RUNNING_TAG: uknown
    export NEPI_RUNNING_ID: 0
    export NEPI_RUNNING_LABEL: uknown
fi 

########################
# Update NEPI Docker Variables from nepi_docker_config.yaml
refresh_nepi_config
wait
########################