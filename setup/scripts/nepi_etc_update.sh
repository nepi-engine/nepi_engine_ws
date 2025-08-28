#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##


# This file installs the NEPI Engine File System installation

source /home/${USER}/.nepi_config
wait


echo ""
echo "Updating NEPI etc files"




###############
echo "Updating nepi config file ${NEPI_ETC}/nepi_config.yaml"
NEPI_ETC_CONFIG=${NEPI_ETC}/nepi_config.yaml
cat /dev/null > $NEPI_ETC_CONFIG
echo "NEPI_HW_TYPE: ${NEPI_HW_TYPE}" >> $NEPI_ETC_CONFIG
echo "NEPI_HW_MODEL: ${NEPI_HW_MODEL}" >> $NEPI_ETC_CONFIG

# PYTHON VERSION
echo "NEPI_PYTHON: ${NEPI_PYTHON}" >> $NEPI_ETC_CONFIG
echo "NEPI_ROS: ${NEPI_ROS}" >> $NEPI_ETC_CONFIG

# NEPI HOST SETTINGS
echo "NEPI_IN_CONTAINER: ${NEPI_IN_CONTAINER}" >> $NEPI_ETC_CONFIG
echo "NEPI_HAS_CUDA: ${NEPI_HAS_CUDA}" >> $NEPI_ETC_CONFIG
echo "NEPI_HAS_XPU: ${NEPI_HAS_XPU}" >> $NEPI_ETC_CONFIG

# NEPI Managed Resources. Set to 0 to turn off NEPI management of this resouce
# Note, if enabled for a docker deployment, these system functions will be
# disabled in the host OS environment
echo "NEPI_MANAGES_SSH: ${NEPI_MANAGES_SSH}" >> $NEPI_ETC_CONFIG
echo "NEPI_MANAGES_SHARE: ${NEPI_MANAGES_SHARE}" >> $NEPI_ETC_CONFIG
echo "NEPI_MANAGES_TIME: ${NEPI_MANAGES_TIME}" >> $NEPI_ETC_CONFIG
echo "NEPI_MANAGES_NETWORK: ${NEPI_MANAGES_NETWORK}" >> $NEPI_ETC_CONFIG

# System Setup Variables
echo "NEPI_USER: ${NEPI_USER}" >> $NEPI_ETC_CONFIG
echo "NEPI_DEVICE_ID: ${NEPI_DEVICE_ID}" >> $NEPI_ETC_CONFIG
echo "NEPI_IP: ${NEPI_IP}" >> $NEPI_ETC_CONFIG


# NEPI PARTITIONS
echo "NEPI_DOCKER: ${NEPI_DOCKER}" >> $NEPI_ETC_CONFIG
echo "NEPI_STORAGE: ${NEPI_STORAGE}" >> $NEPI_ETC_CONFIG
echo "NEPI_CONFIG: ${NEPI_CONFIG}" >> $NEPI_ETC_CONFIG

# NEPI File System 
echo "NEPI_ENV: ${NEPI_ENV}" >> $NEPI_ETC_CONFIG
echo "NEPI_HOME: ${NEPI_HOME}" >> $NEPI_ETC_CONFIG
echo "NEPI_BASE: ${NEPI_BASE}" >> $NEPI_ETC_CONFIG
echo "NEPI_RUI: ${NEPI_RUI}" >> $NEPI_ETC_CONFIG
echo "NEPI_ENGINE: ${NEPI_ENGINE}" >> $NEPI_ETC_CONFIG
echo "NEPI_ETC: ${NEPI_ETC}" >> $NEPI_ETC_CONFIG
echo "NEPI_SCRIPTS: ${NEPI_SCRIPTS}" >> $NEPI_ETC_CONFIG

echo "NEPI_CODE: ${NEPI_CODE}" >> $NEPI_ETC_CONFIG
echo "NEPI_SRC: ${NEPI_SRC}" >> $NEPI_ETC_CONFIG

echo "NEPI_IMAGE_INSTALL: ${NEPI_IMAGE_INSTALL}" >> $NEPI_ETC_CONFIG
echo "NEPI_IMAGE_ARCHIVE: ${NEPI_IMAGE_ARCHIVE}" >> $NEPI_ETC_CONFIG

echo "NEPI_USR_CONFIG: ${NEPI_USR_CONFIG}" >> $NEPI_ETC_CONFIG
echo "NEPI_DOCKER_CONFIG: ${NEPI_DOCKER_CONFIG}" >> $NEPI_ETC_CONFIG
echo "NEPI_FACTORY_CONFIG: ${NEPI_FACTORY_CONFIG}" >> $NEPI_ETC_CONFIG
echo "NEPI_SYSTEM_CONFIG: ${NEPI_SYSTEM_CONFIG}" >> $NEPI_ETC_CONFIG

echo "NEPI_CODE: ${NEPI_CODE}" >> $NEPI_ETC_CONFIG
echo "NEPI_ALIASES_FILE: ${NEPI_ALIASES_FILE}" >> $NEPI_ETC_CONFIG

echo "NEPI_AB_FS: ${NEPI_AB_FS}" >> $NEPI_ETC_CONFIG




# Update NEPI_FOLDER owners
sudo chown -R ${NEPI_USER}:${NEPI_USER} ${NEPI_ETC}


##############################################
echo "NEPI ETC Update Complete"
##############################################

