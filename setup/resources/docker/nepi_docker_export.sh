#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##

# This File Exports the Running Container

# This file Switches a Running Containers

source /home/${USER}/.nepi_bash_utils
wait

cd etc
source load_system_config.sh
wait
if [ $? -eq 1 ]; then
    echo "Failed to load $(pwd)/load_system_config.sh"
    exit 1
fi
cd ..

CONFIG_SOURCE=$(pwd)/nepi_docker_config.yaml
source $(pwd)/load_docker_config.sh
wait

if [ $? -eq 1 ]; then
    echo "Failed to load ${CONFIG_SOURCE}"
    exit 1
fi

####################################
if [[ $NEPI_EXPORTING == 0 ]]; then
    update_yaml_value "NEPI_EXPORTING" 1 "${CONFIG_SOURCE}"

else
    echo "You can only export one image at a time"
    exit 1
fi

source $(pwd)/load_docker_config.sh
wait

# EXPORT_NAME=nepi_export_staging-temp-tag

# sudo docker commit $NEPI_RUNNING_ID nepi_labeling_staging:temp-tag
# wait

# STAGING_CONTAINER_ID=$(sudo docker run -d --name nepi_labeling_staging --label "NEPI_TAG=$NEPI_EXPORT_TAG" --label "NEPI_SIZE_MB=$NEPI_EXPORT_SIZE_MB" \
#  --label "NEPI_HW_TYPE=$NEPI_EXPORT_HW_TYPE" --label "NEPI_HW_MODEL=$NEPI_EXPORT_HW_MODEL" --label "NEPI_BUILD_DATE=$NEPI_EXPORT_BUILD_DATE" \
#  --label "NEPI_DESCRIPTION=$NEPI_EXPORT_DESCRIPTION" nepi_labeling_staging:temp-tag)
# wait

# sudo docker commit $STAGING_CONTAINER_ID nepi_export_staging:temp-tag
# wait

# EXPORT_CONTAINER_ID=$(sudo docker run -d --name nepi_export_staging nepi_export_staging:temp-tag)
# wait

EXPORT_CONTAINER_ID=$NEPI_RUNNING_ID
DATE=$(date +"%Y-%m-%d")
EXPORT_NAME=$NEPI_RUNNING_FS'_'$NEPI_RUNNING_TAG'_'$DATE

if [[ $EXPORT_CONTAINER_ID != 0 ]]; then
    TAR_EXPORT_PATH=${NEPI_EXPORT_PATH}/''${EXPORT_NAME}.tar
    #echo $TAR_EXPORT_PATH
    sudo docker export $EXPORT_CONTAINER_ID > $TAR_EXPORT_PATH
else
    echo "No Running NEPI Container to Export"
fi

update_yaml_value "NEPI_FS_EXPORT" 0 "${CONFIG_SOURCE}"
update_yaml_value "NEPI_EXPORTING" 0 "${CONFIG_SOURCE}"

source $(pwd)/load_docker_config.sh
wait