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

# Load NEPI SYSTEM CONFIG
SCRIPT_FOLDER=$(dirname "$(readlink -f "$0")")
ETC_FOLDER=${SCRIPT_FOLDER}/etc
if [ -d "$ETC_FOLDER" ]; then
    echo "Failed to find ETC folder at ${ETC_FOLDER}"
    exit 1
fi
source ${ETC_FOLDER}/load_system_config.sh
wait
if [ $? -eq 1 ]; then
    echo "Failed to load ${ETC_FOLDER}/load_system_config.sh"
    exit 1
fi

# Load NEPI DOCKER
CONFIG_SOURCE=$(pwd)/nepi_docker_config.yaml
source $(pwd)/load_docker_config.sh
wait
if [ $? -eq 1 ]; then
    echo "Failed to load ${CONFIG_SOURCE}"
    exit 1
fi

##########################################

if [[ $NEPI_IMPORTING == 0 ]]; then
    update_yaml_value "NEPI_IMPORTING" 1 "${CONFIG_SOURCE}"
else
    echo "You can only import one image at a time"
    exit 1
fi

source $(pwd)/load_docker_config.sh
wait

####################################
###### NEED TO GET LIST OF AVAILABLE TARS and Select Image
#IMAGE_FILE=nepi-jetson-3p2p0-rc2.tar
IMAGE_FILE=$1
echo $IMAGE_FILE
IMAGE_NAME=$2
IMAGE_TAG=$3
IMAGE_DATE=$4
######  NEED TO: Update from NEPI_IMPORT_PATH tar file
######
#INSTALL_IMAGE=${NEPI_IMPORT_PATH}/${IMAGE_FILE}
INSTALL_IMAGE=${NEPI_IMPORT_FILE_PATH}/''${IMAGE_FILE}
echo $INSTALL_IMAGE
#1) Stop any processes for INACTIVE_CONT
#docker stop ${RUNNING_CONT}
#2) Import INSTALL_IMAGE to STAGING_CONT
res=$(sudo docker import $INSTALL_IMAGE import_staging:temp)
wait
echo $res
#3) Remove INACTIVE_CONT
#docker stop ${ACTIVE_CONT}
#4) Rename STAGING_CONT to INACTIVE_CONT
hash=${res##*sha256:}
echo $hash
ID=${hash:0:12}
echo $ID


#6) Update inactive version,tags,ids in nepi_docker_config.yaml

if [[ "$NEPI_INACTIVE_FS" == "nepi_fs_a" ]]; then
update_yaml_value "NEPI_FSA_ID" "$ID" "$CONFIG_SOURCE"
[[ -v $IMAGE_NAME ]] && update_yaml_value "NEPI_FSA_NAME" "$IMAGE_NAME" "$CONFIG_SOURCE"
[[ -v $IMAGE_TAG ]] && update_yaml_value "NEPI_FSA_TAG" "$IMAGE_TAG" "$CONFIG_SOURCE"
[[ -v $IMAGE_DATE ]] && update_yaml_value "NEPI_FSA_BUILD_DATE" "$IMAGE_DATE" "$CONFIG_SOURCE"
source $(pwd)/load_docker_config.sh
wait

sudo docker tag "$NEPI_FSA_ID" "${NEPI_FSA_NAME}:${NEPI_FSA_TAG}"
else
update_yaml_value "NEPI_FSB_ID" "$ID" "$CONFIG_SOURCE"
[[ -v $IMAGE_NAME ]] && update_yaml_value "NEPI_FSB_NAME" "$IMAGE_NAME" "$CONFIG_SOURCE"
[[ -v $IMAGE_TAG ]] && update_yaml_value "NEPI_FSB_TAG" "$IMAGE_TAG" "$CONFIG_SOURCE"
[[ -v $IMAGE_DATE ]] && update_yaml_value "NEPI_FSB_BUILD_DATE" "$IMAGE_DATE" "$CONFIG_SOURCE"
source $(pwd)/load_docker_config.sh
wait

sudo docker tag "$NEPI_FSB_ID" "${NEPI_FSB_NAME}:${NEPI_FSB_TAG}"
sudo docker rmi "$NEPI_FSB_ID" "import_staging:temp"
fi

update_yaml_value "NEPI_FS_IMPORT" 0 "${CONFIG_SOURCE}"
update_yaml_value "NEPI_IMPORTING" 0 "${CONFIG_SOURCE}"


########################
# Update NEPI Docker Variables from nepi_docker_config.yaml
source $(pwd)/load_docker_config.sh
wait
########################

#######
# Start Switched Container
#  . ./start_nepi_docker


