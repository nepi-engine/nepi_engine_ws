#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##


# This file Switches a Running Containers
source /home/${USER}/.nepi_bash_utils
wait

CONFIG_SOURCE=$(dirname "$(pwd)")/nepi_docker_config.yaml
source $(pwd)/load_docker_config.sh
wait

if [ $? -eq 1 ]; then
    echo "Failed to load ${CONFIG_SOURCE}"
    exit 1
fi

NEPI_IMPORT_PATH=$NEPI_IMPORT_PATH
echo $NEPI_IMPORT_PATH
###### NEED TO GET LIST OF AVAILABLE TARS and Select Image
#IMAGE_FILE=nepi-jetson-3p2p0-rc2.tar
IMAGE_FILE=$1
echo $IMAGE_FILE
######  NEED TO: Update from NEPI_IMPORT_PATH tar file
if [[ "$NEPI_INACTIVE_FS" == "nepi_fs_a" ]]; then
IMAGE_VERSION=$NEPI_FSA_VERSION
echo $IMAGE_VERSION
else
IMAGE_VERSION=$NEPI_FSB_VERSION
echo $IMAGE_VERSION
fi
######
#INSTALL_IMAGE=${NEPI_IMPORT_PATH}/${IMAGE_FILE}
INSTALL_IMAGE=${NEPI_IMPORT_PATH}/''${IMAGE_FILE}
echo $INSTALL_IMAGE
#1) Stop any processes for INACTIVE_CONT
#docker stop ${RUNNING_CONT}
#2) Import INSTALL_IMAGE to STAGING_CONT
res=$(sudo docker import $INSTALL_IMAGE)
echo $res
#3) Remove INACTIVE_CONT
#docker stop ${ACTIVE_CONT}
#4) Rename STAGING_CONT to INACTIVE_CONT
hash=${res##*sha256:}
echo $hash
ID=${hash:0:12}
echo $ID
NEW_DATE=$(date +%Y-%m-%d)
echo $NEW_DATE
if [[ "$NEPI_INACTIVE_FS" == "nepi_fs_a" ]]; then
NEW_NAME=$NEPI_FSA_NAME
echo $NEW_NAME
else
NEW_NAME=$NEPI_FSB_NAME
echo $NEW_NAME
fi
if [[ "$NEPI_INACTIVE_FS" == "nepi_fs_a" ]]; then
NEW_TAG=$NEPI_FSA_TAG
echo $NEW_TAG
else
NEW_TAG=$NEPI_FSB_TAG
echo $NEW_TAG
fi


printf 'Create a Custom Tag (y/n)? '
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then 
    echo 'Enter Custom Tag: ' 
    read CUSTOM_TAG
    NEW_TAG=$CUSTOM_TAG
    echo $CUSTOM_TAG
    echo ''
else
    echo ''
fi
NEW_VERSION=$IMAGE_VERSION
printf 'Create a Custom Version (y/n)? '
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then 
    echo 'Enter Custom Version: ' 
    read CUSTOM_VERSION
    NEW_VERSION=$CUSTOM_VERSION
    echo ''
else
    echo ''
fi


sudo docker tag $ID ${NEW_NAME}:${NEW_TAG}
#6) Update inactive version,tags,ids in nepi_docker_config.yaml

if [[ "$NEPI_INACTIVE_FS" == "nepi_fs_a" ]]; then
update_yaml_value "NEPI_FSA_NAME" "$NEW_NAME" "$CONFIG_SOURCE"
update_yaml_value "NEPI_FSA_TAG" "$NEW_TAG" "$CONFIG_SOURCE"
update_yaml_value "NEPI_FSA_ID" "$ID" "$CONFIG_SOURCE"
update_yaml_value "NEPI_FSA_VERSION" "$NEW_VERSION" "$CONFIG_SOURCE"
update_yaml_value "NEPI_FSA_BUILD_DATE" "$NEW_DATE" "$CONFIG_SOURCE"
else
update_yaml_value "NEPI_FSB_NAME" "$NEW_NAME" "$CONFIG_SOURCE"
update_yaml_value "NEPI_FSB_TAG" "$NEW_TAG" "$CONFIG_SOURCE"
update_yaml_value "NEPI_FSB_ID" "$ID" "$CONFIG_SOURCE"
update_yaml_value "NEPI_FSB_VERSION" "$NEW_VERSION" "$CONFIG_SOURCE"
update_yaml_value "NEPI_FSB_BUILD_DATE" "$NEW_DATE" "$CONFIG_SOURCE"
fi

#echo "  ADD SOME PRINT OUTS  "
update_yaml_value "NEPI_FS_IMPORT" 0 "${CONFIG_SOURCE}"


########################
# Update NEPI Docker Variables from nepi_docker_config.yaml
source $(pwd)/load_docker_config.sh
wait
########################

#######
# Start Switched Container
#  . ./start_nepi_docker


