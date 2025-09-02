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

NEPI_DOCKER_CONFIG_FILE=${NEPI_CONFIG}/docker_cfg/nepi_docker_config.yaml

########################
# Update NEPI Docker Variables from nepi_docker_config.yaml
refresh_nepi_config
wait
########################

IMPORT_PATH=$IMPORT_PATH
echo $IMPORT_PATH
###### NEED TO GET LIST OF AVAILABLE TARS and Select Image
#IMAGE_FILE=nepi-jetson-3p2p0-rc2.tar
IMAGE_FILE=$1
echo $IMAGE_FILE
######  NEED TO: Update from IMPORT_PATH tar file
IMAGE_VERSION=3p2p0
echo $IMAGE_VERSION
######
#INSTALL_IMAGE=${IMPORT_PATH}/${IMAGE_FILE}
INSTALL_IMAGE=${EXPORT_PATH}/''${IMAGE_FILE}
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
NEW_NAME=$NEPI_INACTIVE_NAME
echo $NEW_NAME
NEW_TAG=$NEPI_INACTIVE_TAG
printf 'Create a Custom Tag (y/n)? '
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then 
    echo 'Enter Custom Tag: ' 
    read CUSTOM_TAG
    NEW_TAG=$CUSTOM_TAG
    echo ''
else
    echo ''
fi
NEW_VERSION=$IMAGE_VERSION
printf 'Create a Custom Version (y/n)? '
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then 
    echo 'Enter Custom Version: ' 
    read CUSTOM_TAG
    NEW_TAG=$CUSTOM_TAG
    echo ''
else
    echo ''
fi


sudo docker tag $ID ${NEW_NAME}:${NEW_TAG}
#6) Update inactive version,tags,ids in nepi_docker_config.yaml
update_yaml_value "NEPI_INACTIVE_VERSION" "$INACTIVE_VERSION" "$NEPI_DOCKER_CONFIG_FILE"
update_yaml_value "NEPI_INACTIVE_DATE" "$NEW_DATE" "$NEPI_DOCKER_CONFIG_FILE"
update_yaml_value "NEPI_INACTIVE_TAG" "$NEW_TAG" "$NEPI_DOCKER_CONFIG_FILE"
update_yaml_value "NEPI_INACTIVE_ID" "$NEW_VERSION" "$NEPI_DOCKER_CONFIG_FILE"
echo "  ADD SOME PRINT OUTS  "

########################
# Update NEPI Docker Variables from nepi_docker_config.yaml
refresh_nepi_config
wait
########################

#######
# Start Switched Container
#  . ./start_nepi_docker


