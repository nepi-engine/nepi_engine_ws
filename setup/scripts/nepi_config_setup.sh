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

CONFIG_SETUP=$(pwd)/NEPI_CONFIG.sh
echo "Looking for NEPI_CONFIG.sh file in ${CONFIG_SETUP}"
if [[ -f "$CONFIG_SETUP" ]]; then
    CONFIG_SOURCE=$CONFIG_SETUP
else
    CONFIG_HOME=/home/${USER}/.nepi_config
    if [[ -f "$CONFIG_HOME" ]]; then
        echo "Looking for .nepi_config file in ${CONFIG_HOME}"
        CONFIG_SOURCE=$CONFIG_HOME
    else
        echo "NO NEPI CONFIG FILE FOUND"
        exit 1
    fi
fi
source $CONFIG_SOURCE 
wait


if [[ ! -v CONFIG_DEST ]]; then
    CONFIG_DEST=${NEPI_ETC}/nepi_config.yaml
fi



echo ""
echo "Updating NEPI Config file at "




###############
echo "Updating nepi config file ${CONFIG_DEST}"
cat /dev/null > $CONFIG_DEST

echo "# NEPI Settings" >> $CONFIG_DEST
echo "NEPI_USER: ${NEPI_USER}" >> $CONFIG_DEST
echo "NEPI_DEVICE_ID: ${NEPI_DEVICE_ID}" >> $CONFIG_DEST
echo "NEPI_BOOT_DEVICE: ${NEPI_BOOT_DEVICE}" >> $CONFIG_DEST
echo "NEPI_FS_DEVICE: ${NEPI_FS_DEVICE}" >> $CONFIG_DEST
echo "NEPI_STORAGE_DEVICE: ${NEPI_STORAGE_DEVICE}" >> $CONFIG_DEST

echo "NEPI_HW_TYPE: ${NEPI_HW_TYPE}" >> $CONFIG_DEST
echo "NEPI_HW_MODEL: ${NEPI_HW_MODEL}" >> $CONFIG_DEST

# PYTHON VERSION
echo "NEPI_PYTHON: ${NEPI_PYTHON}" >> $CONFIG_DEST
echo "NEPI_ROS: ${NEPI_ROS}" >> $CONFIG_DEST

# NEPI HOST SETTINGS
echo "NEPI_IN_CONTAINER: ${NEPI_IN_CONTAINER}" >> $CONFIG_DEST
echo "NEPI_HAS_CUDA: ${NEPI_HAS_CUDA}" >> $CONFIG_DEST
echo "NEPI_HAS_XPU: ${NEPI_HAS_XPU}" >> $CONFIG_DEST

echo "NEPI_MANAGES_SSH: ${NEPI_MANAGES_SSH}" >> $CONFIG_DEST
echo "NEPI_MANAGES_SHARE: ${NEPI_MANAGES_SHARE}" >> $CONFIG_DEST

# NETWORK SETUP
echo "# NEPI Network Config" >> $CONFIG_DEST
echo "NEPI_MANAGES_NETWORK: ${NEPI_MANAGES_NETWORK}" >> $CONFIG_DEST
echo "NEPI_IP: ${NEPI_IP}" >> $CONFIG_DEST
echo "NEPI_TCP_PORTS:" >> $CONFIG_DEST
for tport in "${NEPI_TCP_PORTS[@]}"; do
    echo " - ${tport}" >> $CONFIG_DEST
done
echo "NEPI_UDP_PORTS:" >> $CONFIG_DEST
for uport in "${NEPI_UDP_PORTS[@]}"; do
    echo " - ${uport}" >> $CONFIG_DEST
done
echo "NEPI_IP_ALIASES:" >> $CONFIG_DEST
for alias in "${NEPI_IP_ALIASES[@]}"; do
    echo " - ${alias}" >> $CONFIG_DEST
done

# TIME DATE SETUP
echo "# NEPI TIME Config" >> $CONFIG_DEST
echo "NEPI_MANAGES_TIME: ${NEPI_MANAGES_TIME}" >> $CONFIG_DEST
echo "NEPI_NTP_SOURCES:" >> $CONFIG_DEST
for ntps in "${NEPI_NTP_SOURCES[@]}"; do
    echo " - ${ntps}" >> $CONFIG_DEST
done


# NEPI PARTITIONS
echo "# NEPI Folder Config" >> $CONFIG_DEST
echo "NEPI_DOCKER: ${NEPI_DOCKER}" >> $CONFIG_DEST
echo "NEPI_STORAGE: ${NEPI_STORAGE}" >> $CONFIG_DEST
echo "NEPI_CONFIG: ${NEPI_CONFIG}" >> $CONFIG_DEST

# NEPI File System 
echo "NEPI_ENV: ${NEPI_ENV}" >> $CONFIG_DEST
echo "NEPI_HOME: ${NEPI_HOME}" >> $CONFIG_DEST
echo "NEPI_BASE: ${NEPI_BASE}" >> $CONFIG_DEST
echo "NEPI_RUI: ${NEPI_RUI}" >> $CONFIG_DEST
echo "NEPI_ENGINE: ${NEPI_ENGINE}" >> $CONFIG_DEST
echo "NEPI_ETC: ${NEPI_ETC}" >> $CONFIG_DEST
echo "NEPI_SCRIPTS: ${NEPI_SCRIPTS}" >> $CONFIG_DEST

echo "NEPI_CODE: ${NEPI_CODE}" >> $CONFIG_DEST
echo "NEPI_SRC: ${NEPI_SRC}" >> $CONFIG_DEST

echo "NEPI_IMAGE_INSTALL: ${NEPI_IMAGE_INSTALL}" >> $CONFIG_DEST
echo "NEPI_IMAGE_ARCHIVE: ${NEPI_IMAGE_ARCHIVE}" >> $CONFIG_DEST

echo "NEPI_USR_CONFIG: ${NEPI_USR_CONFIG}" >> $CONFIG_DEST
echo "NEPI_DOCKER_CONFIG: ${NEPI_DOCKER_CONFIG}" >> $CONFIG_DEST
echo "NEPI_FACTORY_CONFIG: ${NEPI_FACTORY_CONFIG}" >> $CONFIG_DEST
echo "NEPI_SYSTEM_CONFIG: ${NEPI_SYSTEM_CONFIG}" >> $CONFIG_DEST

echo "NEPI_ALIASES_FILE: ${NEPI_ALIASES_FILE}" >> $CONFIG_DEST

echo "NEPI_AB_FS: ${NEPI_AB_FS}" >> $CONFIG_DEST




# Update NEPI_FOLDER owners
sudo chown -R ${NEPI_USER}:${NEPI_USER} ${CONFIG_DEST}


##############################################
echo "NEPI Config Setup Complete"
##############################################

