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

echo ""
echo "Updating NEPI Config file nepi_config.yaml"

CONFIG_SOURCE=$(pwd)/NEPI_CONFIG.sh
echo "Looking for NEPI_CONFIG.sh file in ${CONFIG_SETUP}"
if [[ ! -f "$CONFIG_SOURCE" ]]; then
    echo "NO NEPI CONFIG FILE FOUND"
    exit 1
fi
source $CONFIG_SOURCE 
wait


if [[ ! -v CONFIG_DEST ]]; then
    CONFIG_DEST=${NEPI_ETC}/nepi_config.yaml
fi

###############
echo "Updating nepi config file ${CONFIG_DEST}"
cat /dev/null > $CONFIG_DEST

while IFS= read -r line || [[ -n "$line" ]]; do
  if [[ "$line" == "#"* ]]; then
    #echo "" >> $CONFIG_DEST
    echo "${line}" >> $CONFIG_DEST
  elif [[ "$line" == *"export"* ]]; then
    second_part="${line:7}"
    var_name=$(echo "$second_part" | cut -d "=" -f 1)
    var_value=$(eval "echo \$${var_name}")
    echo "${var_name}: ${var_value}" >> $CONFIG_DEST
  fi
done < "$CONFIG_SOURCE"


#######################
# Copy the nepi_config.yaml file to the factory_cfg folder
factory_config=${NEPI_CONFIG}/factory_cfg/etc/nepi_config.yaml
echo "Updating NEPI System Config Files in ${factory_config}"
if [ ! -d "${NEPI_CONFIG}" ]; then
    sudo sudo mkdir $NEPI_CONFIG
fi
if [ ! -d "${NEPI_CONFIG}/factory_cfg" ]; then
    sudo mkdir ${NEPI_CONFIG}/factory_cfg
fi
if [ ! -d "${NEPI_CONFIG}/factory_cfg/etc" ]; then
    sudo mkdir ${NEPI_CONFIG}/factory_cfg/etc
fi

#if [ -f "$factory_config" ]; then
#    sudo cp $factory_config ${factory_config}.bak
#fi
echo "Copying NEPI System Config File ${CONFIG_DEST} to ${factory_config}"
sudo cp ${CONFIG_DEST} ${factory_config}
sudo chown -R ${USER}:${USER} $NEPI_CONFIG

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
echo "Copying NEPI System Config File ${CONFIG_DEST} to ${sys_config}"
sudo cp ${CONFIG_DEST} ${sys_config}
sudo chown -R ${USER}:${USER} $NEPI_CONFIG


# Update NEPI_FOLDER owners
sudo chown -R ${NEPI_USER}:${NEPI_USER} ${CONFIG_DEST}


##############################################
echo "NEPI Config Setup Complete"
##############################################

