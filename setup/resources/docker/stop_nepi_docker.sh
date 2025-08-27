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

source /home/${USER}/NEPI_CONFIG.sh
wait

########################
# Update NEPI Docker Variables from nepi_docker_config.yaml
refresh_nepi
wait
########################


########################
# Stop Running Command
########################
if [[ ! -v RUNNING ]]; then
    if [[ ( -v RUNNING && "$RUNNING" -eq 1 ) ]]; then
        echo "Stopping Running NEPI Docker Process ${RUNNING_CONT}:${RUNNING_TAG} ID:${RUNNING_ID}"
        dstop $RUNNING_ID
    fi
else
    echo "Failed to Read NEPI Docker Config File"
    exit 1
fi 

########################
# Update NEPI Docker Variables from nepi_docker_config.yaml
refresh_nepi
wait
########################