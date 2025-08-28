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


source ./NEPI_CONFIG.sh
wait

echo ""
echo "NEPI Docker Enviorment Setup"


#####################################
# Copy Files to NEPI Docker Config Folder
####################################
sudo mkdir $NEPI_DOCKER_CONFIG
echo "Copying nepi config files to ${NEPI_DOCKER_CONFIG}"
sudo cp $(dirname "$(pwd)")/resources/docker/* ${NEPI_DOCKER_CONFIG}/
sudo chown -R ${USER}:${USER} $NEPI_DOCKER_CONFIG


#####################################
#Update Docker Config File
#####################################

###############
echo "Updating nepi config file ${DOCKER_CONFIG_FILE}"

export DOCKER_CONFIG_FILE=${NEPI_DOCKER_CONFIG}/nepi_docker_config.yaml
cat /dev/null > $DOCKER_CONFIG_FILE
echo "# NEPI Docker Environment Variables" >> $DOCKER_CONFIG_FILE
echo "USER_NAME: ${NEPI_USER}" >> $DOCKER_CONFIG_FILE
echo "DEVICE_ID: ${NEPI_DEVICE_ID}" >> $DOCKER_CONFIG_FILE
echo "HW_TYPE: ${NEPI_HW_TYPE}" >> $DOCKER_CONFIG_FILE
echo "HW_MODEL: ${NEPI_HW_MODEL}" >> $DOCKER_CONFIG_FILE

echo "STATIC_IP: ${NEPI_IP}" >> $DOCKER_CONFIG_FILE
echo "IP_ALIASES: []" >> $DOCKER_CONFIG_FILE

echo "MANAGES_CLOCK: ${NEPI_MANAGES_CLOCK}" >> $DOCKER_CONFIG_FILE

echo "SUPPORTS_AB_FS: 1" >> $DOCKER_CONFIG_FILE
echo "IMPORT_PATH: ${NEPI_IMPORT_PATH}" >> $DOCKER_CONFIG_FILE
echo "EXPORT_PATH: ${NEPI_EXPORT_PATH}" >> $DOCKER_CONFIG_FILE

echo "# NEPI Docker File System Variables" >> $DOCKER_CONFIG_FILE
echo "ACTIVE_CONT: nepi_fs_a" >> $DOCKER_CONFIG_FILE
echo "ACTIVE_VERSION: 3p2p0" >> $DOCKER_CONFIG_FILE
echo "ACTIVE_TAG: ${NEPI_HW_TYPE}-${ACTIVE_VERSION}}" >> $DOCKER_CONFIG_FILE
echo "ACTIVE_ID: 0" >> $DOCKER_CONFIG_FILE

echo "INACTIVE_CONT: nepi_fs_b" >> $DOCKER_CONFIG_FILE
echo "INACTIVE_VERSION: uknown" >> $DOCKER_CONFIG_FILE
echo "INACTIVE_TAG: ${NEPI_HW_TYPE}-${INACTIVE_VERSION}" >> $DOCKER_CONFIG_FILE
echo "INACTIVE_ID: 0" >> $DOCKER_CONFIG_FILE

echo "STAGING_CONT: nepi_fs_staging" >> $DOCKER_CONFIG_FILE

echo "# Running NEPI Container Info" >> $DOCKER_CONFIG_FILE
echo "RUNNING: 0" >> $DOCKER_CONFIG_FILE
echo "RUNNING_CONT: None" >> $DOCKER_CONFIG_FILE
echo "RUNNING_VERSION: uknown" >> $DOCKER_CONFIG_FILE
echo "RUNNING_TAG: uknown" >> $DOCKER_CONFIG_FILE
echo "RUNNING_ID: 0" >> $DOCKER_CONFIG_FILE

echo "# FAIL COUNTER" >> $DOCKER_CONFIG_FILE
echo "MAX_COUNT: 3" >> $DOCKER_CONFIG_FILE
echo "FAIL_COUNT: 0" >> $DOCKER_CONFIG_FILE


sudo chown ${USER}:${USER} $DOCKER_CONFIG_FILE

##################################
echo ""
echo 'NEPI Docker Config Setup Complete'
##################################

