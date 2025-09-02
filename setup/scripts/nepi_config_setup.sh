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

echo "########################"
echo "STARTING NEPI CONFIG SETUP"
echo "########################"


CONFIG_SOURCE=$(dirname "$(pwd)")/NEPI_CONFIG.sh
source ${CONFIG_SOURCE}
wait

###################
# Copy Config Files
SOURCE_PATH=$(dirname "$(pwd)")/resources/etc
DEST_PATH=${NEPI_ETC}
CONFIG_USER=${NEPI_USER}


echo ""
echo "Populating System Folders from ${SOURCE_PATH}"
sudo cp -R ${SOURCE_PATH}/* ${DEST_PATH}/
sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $DEST_PATH


NEPI_CONFIG_SOURCE=${CONFIG_SOURCE}
NEPI_CONFIG_DEST=/home/${CONFIG_USER}/.NEPI_CONFIG

## Check Selection
echo ""
echo ""
echo "Do You Want to OverWrite System Config: ${OP_SELECTION}"
select ovw in "View_Original" "View_New" "Yes" "No" "Quit"; do
    case $ovw in
        View_Original ) cat ${NEPI_CONFIG_DEST};;
        View_New )  cat ${NEPI_CONFIG_SOURCE};;
        Yes ) OVERWRITE=1; break;;
        No ) OVERWRITE=0; break;;
        Quit ) exit 1
    esac
done


if [ "$OVERWRITE" -eq 1 ]; then
  echo "Installing NEPI CONFIG ${NEPI_CONFIG_DEST} "
  sudo cp ${NEPI_CONFIG_SOURCE} ${NEPI_CONFIG_DEST}
  sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $NEPI_CONFIG_DEST
else
  source ${NEPI_CONFIG_DEST}
fi

###############
# Update etc config files
NEPI_CFG_DEST=${DEST_PATH}/nepi_config.yaml
echo ""
echo "Updating NEPI Config file ${NEPI_CFG_DEST} from ${NEPI_CONFIG_DEST}"
cat /dev/null > ${NEPI_CFG_DEST}

while IFS= read -r line || [[ -n "$line" ]]; do
  #echo ${line}
  if [[ "$line" == "#"* ]]; then
    #echo "" >> $NEPI_CFG_DEST
    echo "${line}" >> $NEPI_CFG_DEST
  elif [[ "$line" == *"export"* ]]; then
    second_part="${line:7}"
    var_name=$(echo "$second_part" | cut -d "=" -f 1)
    var_value=$(eval "echo \$${var_name}")
    echo "${var_name}: ${var_value}"
    echo "${var_name}: ${var_value}" >> $NEPI_CFG_DEST
  fi
done < "$NEPI_CONFIG_DEST"

echo "Updating NEPI Config files in ${DEST_PATH}"
source ${DEST_PATH}/update_etc_files.sh
wait


#######################
# Copy the nepi_config.yaml file to the factory_cfg folder
source_config=${DEST_PATH}/nepi_config.yaml
dest_etc=${NEPI_CONFIG}/factory_cfg/etc
dest_config=${dest_etc}/nepi_config.yaml
echo "Updating NEPI System Files in ${dest_config}"
sudo mkdir -p ${dest_etc}
sudo cp $source_config $dest_config
sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $dest_etc

# Copy the nepi_config.yaml file to the system_cfg folder
source_config=${DEST_PATH}/nepi_config.yaml
dest_etc=${NEPI_CONFIG}/system_cfg/etc
dest_config=${dest_etc}/nepi_config.yaml
echo "Updating NEPI System Files in ${dest_config}"
sudo mkdir -p ${dest_etc}
sudo cp $source_config $dest_config
sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $dest_etc


##############################################
echo "NEPI Config Setup Complete"
##############################################

