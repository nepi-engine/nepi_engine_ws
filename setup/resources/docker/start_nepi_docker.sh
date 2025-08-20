#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##


# This file configigues an installed NEPI File System


source ./_nepi_config.sh
echo "Starting with NEPI Home folder: ${NEPI_HOME}"

echo ""
echo "start_nepi_docker"

# Change to tmp install folder
#TMP=${STORAGE["tmp"]}
#mkdir $TMP
#cd $TMP

# Read in nepi_docker_config info


# Run docker compose with nepi-docker-compose.yml and correct nepi_fs


