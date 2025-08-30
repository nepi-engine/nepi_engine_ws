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

echo "Adding NEPI Docker variables to nepi config file ${CONFIG_DEST}"

echo "# NEPI Docker Docker System Variables" >> $CONFIG_DEST
echo "NEPI_ACTIVE_NAME: nepi_fs_a" >> $CONFIG_DEST
echo "NEPI_ACTIVE_VERSION: 3p2p0" >> $CONFIG_DEST
echo "NEPI_ACTIVE_TAG: ${NEPI_HW_TYPE}-${ACTIVE_VERSION}}" >> $CONFIG_DEST
echo "NEPI_ACTIVE_ID: 0" >> $CONFIG_DEST
echo "NEPI_ACTIVE_LABEL: uknown" >> $CONFIG_DEST


echo "NEPI_INACTIVE_NAME: nepi_fs_b" >> $CONFIG_DEST
echo "NEPI_INACTIVE_VERSION: uknown" >> $CONFIG_DEST
echo "NEPI_INACTIVE_TAG: ${NEPI_HW_TYPE}-${INACTIVE_VERSION}" >> $CONFIG_DEST
echo "NEPI_INACTIVE_ID: 0" >> $CONFIG_DEST
echo "NEPI_INACTIVE_LABEL: uknown" >> $CONFIG_DEST

echo "NEPI_STAGING_NAME: nepi_fs_staging" >> $CONFIG_DEST

echo "# Running NEPI Container Info" >> $CONFIG_DEST
echo "NEPI_RUNNING: 0" >> $CONFIG_DEST
echo "NEPI_RUNNING_NAME: None" >> $CONFIG_DEST
echo "NEPI_RUNNING_VERSION: uknown" >> $CONFIG_DEST
echo "NEPI_RUNNING_TAG: uknown" >> $CONFIG_DEST
echo "NEPI_RUNNING_ID: 0" >> $CONFIG_DEST
echo "NEPI_RUNNING_LABEL: uknown" >> $CONFIG_DEST

echo "# Boot Fail Config" >> $CONFIG_DEST
echo "NEPI_MAX_COUNT: 3" >> $CONFIG_DEST
echo "NEPI_FAIL_COUNT: 0" >> $CONFIG_DEST

#######################
# Copy the nepi_config.yaml file to the system_cfg folder
sys_config=${NEPI_CONFIG}/system_cfg/etc/nepi_config.yaml
echo "Updating NEPI System Config Files in ${sys_config}"
if [ ! -d "${NEPI_CONFIG}/system_cfg/etc" ]; then
    sudo sudo mkdir $NEPI_CONFIG
fi
if [ ! -d "${NEPI_CONFIG}/system_cfg" ]; then
    sudo mkdir ${NEPI_CONFIG}/system_cfg
fi
if [ ! -d "${NEPI_CONFIG}/system_cfg/etc" ]; then
    sudo mkdir ${NEPI_CONFIG}/system_cfg/etc
fi

#if [ -f "$sys_config" ]; then
#    sudo cp $sys_config ${sys_config}.bak
#fi
docker_config=${NEPI_CONFIG}/docker_cfg/nepi_config.yaml
echo "Copying NEPI System Config File ${docker_config} to ${sys_config}"
sudo cp ${docker_config} ${sys_config}
sudo chown -R ${USER}:${USER} $NEPI_CONFIG

##################################
echo ""
echo 'NEPI Docker Config Setup Complete'
##################################

