#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##

# This script Updates NEPI ETC Files

source /home/${USER}/.nepi_bash_utils
wait

source $(pwd)/load_system_config.sh
wait


echo "########################"
echo "UPDATING ETC FILES FROM NEPI CONFIG"
echo "########################"

function update_text_value(){
  KEY=$2
  UPDATE=$3
  FILE=$1
  if [ -f "$FILE" ]; then
    sudo echo "Updating NEPI Config Yaml file from: ${FILE}"
    if grep -q "$KEY" "$FILE"; then
      sed -i "/^$KEY/c\\$UPDATE" "$FILE"
    else
      echo "$UPDATE" | sudo tee -a $FILE
    fi
  else
    echo "File not found ${FILE}"
  fi
}
export -f update_text_value

function update_hostname(){
    HOST_NAME_FILE=${ETC_FOLDER}/hostname
    echo $HOST_NAME_FILE
    KEY=$1
    echo $KEY
    UPDATE=$2
    echo $UPDATE
    if [ -f "$HOST_NAME_FILE" ]; then
    if grep -q "$KEY" "$HOST_NAME_FILE"; then
        sed -i "s/$KEY/$UPDATE/g" "$HOST_NAME_FILE"

    else
        echo "$UPDATE" | sudo tee -a $HOST_NAME_FILE
    fi
    else
    echo "File not found ${HOST_NAME_FILE}"
    fi
}
export -f update_hostname


function update_etc_files(){
  :
}


echo "Updating NEPI Config files in ${NEPI_CFG_DEST}"


####################################
### SYNC WITH NEPI CONFIG FOLDERS
DOCKER_ETC=${NEPI_CONFIG}/docker_cfg/etc
#############
# Sync with factory config first
cp ${DOCKER_ETC}/nepi_system_config.yaml ${DOCKER_ETC}/nepi_system_config.tmp
cp ${DOCKER_ETC}/nepi_etc_update.yaml ${DOCKER_ETC}/nepi_etc_update.tmp

sudo rsync -arh ${NEPI_CONFIG}/factory_cfg/etc/ ${NEPI_CONFIG}/docker_cfg/

mv ${DOCKER_ETC}/nepi_system_config.tmp ${DOCKER_ETC}/nepi_system_config.yaml
mv ${DOCKER_ETC}/nepi_etc_update.tmp ${DOCKER_ETC}/nepi_etc_update.yaml
# Update Etc

update_etc_files
sudo rsync -arh ${NEPI_CONFIG}/docker_cfg/etc/ ${NEPI_CONFIG}/factory_cfg/

#############
# Sync with system config
cp ${DOCKER_ETC}/nepi_system_config.yaml ${DOCKER_ETC}/nepi_system_config.tmp
cp ${DOCKER_ETC}/nepi_etc_update.yaml ${DOCKER_ETC}/nepi_etc_update.tmp

sudo rsync -arh ${NEPI_CONFIG}/system_cfg/etc/ ${NEPI_CONFIG}/docker_cfg/

mv ${DOCKER_ETC}/nepi_system_config.tmp ${DOCKER_ETC}/nepi_system_config.yaml
mv ${DOCKER_ETC}/nepi_etc_update.tmp ${DOCKER_ETC}/nepi_etc_update.yaml
echo "Updated NEPI Config file ${NEPI_CFG_DEST}"

update_etc_files
sudo rsync -arh ${NEPI_CONFIG}/docker_cfg/etc/ ${NEPI_CONFIG}/system_cfg/

##############################################
echo "NEPI ETC Update Complete"
##############################################

