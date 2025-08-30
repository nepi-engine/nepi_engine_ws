#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##


# This file initializes the nepi_docker_config.yaml file

echo ""
echo "NEPI Docker Config Setup"


#####################################
# Copy Files to NEPI Docker Config Folder
####################################
sudo mkdir $NEPI_DOCKER_CONFIG
echo "Copying nepi config files to ${NEPI_DOCKER_CONFIG}"
sudo cp $(dirname "$(pwd)")/resources/docker/* ${NEPI_DOCKER_CONFIG}/



#####################################
#Update Docker Config File
#####################################

###############


export CONFIG_DEST=${NEPI_DOCKER_CONFIG}/nepi_config.yaml
echo "Creating nepi config file ${CONFIG_DEST}"
source nepi_config_setup.sh
wait


##################################
echo ""
echo 'NEPI Docker Config Setup Complete'
##################################

