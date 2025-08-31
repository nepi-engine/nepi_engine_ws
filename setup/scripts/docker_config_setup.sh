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

echo "########################"
echo "NEPI Docker Config Setup"
echo "########################"

source /home/${USER}/NEPI_CONFIG.sh

#####################################
# Copy Files to NEPI Docker Config Folder
####################################
sudo mkdir $NEPI_DOCKER_CONFIG
echo "Copying nepi config files to ${NEPI_DOCKER_CONFIG}"
sudo cp $(dirname "$(pwd)")/resources/docker/* ${NEPI_DOCKER_CONFIG}/

source $(pwd)/docker_bash_config.sh
wait

###################
# Initialize Docker Config ETC Folder
NEPI_ETC_SOURCE=$(dirname "$(pwd)")/resources/etc
echo ""
echo "Populating System Folders from ${NEPI_ETC_SOURCE}"
sudo cp -R ${NEPI_ETC_SOURCE}/* ${NEPI_DOCKER_CONFIG}
sudo cp nepi_etc_update.sh ${NEPI_DOCKER_CONFIG}/
sudo chown -R ${NEPI_USER}:${NEPI_USER} $NEPI_DOCKER_CONFIG

# Rsync etc folder from factory folder
rsync -arh ${NEPI_CONFIG}/factory_cfg/etc ${NEPI_CONFIG}/docker_cfg

# Rsync etc folder from system folder
rsync -arh ${NEPI_CONFIG}/system_cfg/etc ${NEPI_CONFIG}/docker_cfg

docker_config=${NEPI_CONFIG}/docker_cfg/nepi_config.yaml
echo "Copying NEPI System Config File ${docker_config} to ${NEPI_DOCKER_CONFIG}"
sudo cp ${docker_config} ${NEPI_DOCKER_CONFIG}/
sudo chown -R ${USER}:${USER} $NEPI_CONFIG

# Rsync etc folder to system folder
rsync -arh  ${NEPI_CONFIG}/docker_cfg/etc ${NEPI_CONFIG}/system_cfg

##################################
echo ""
echo 'NEPI Docker Config Setup Complete'
##################################

