#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##

# This script launches NEPI Container
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


########################
# Stop Any Running NEPI Containers
########################
. ./stop_nepi_docker.sh
wait

#######################
# Update Etc
export ETC_FOLDER=$(pwd)/etc
refresh_nepi_config $NEPI_CONFIG_FILE
wait
source $(pwd)/nepi_etc_update
wait

#***********************
##### TO DO
# NEED TO SYNC TO NEPI factory and system etc folders
#####
#***********************

########################
# Build Run Command
########################
echo "Building NEPI Docker Run Command"

########
# Initialize Run Command
DOCKER_RUN_COMMAND=" sudo docker run -d --privileged --rm -e UDEV=1 --user ${NEPI_USER} '\'
--mount type=bind,source=${NEPI_STORAGE},target=${NEPI_STORAGE} '\'
--mount type=bind,source=${NEPI_CONFIG},target=${NEPI_CONFIG} '\'
--mount type=bind,source=/dev,target=/dev '\'
-e DISPLAY=${DISPLAY} '\'
-v /tmp/.X11-unix/:/tmp/.X11-unix '\'
--net=host '\'"


# Set Clock Settings
if [[ "$NEPI_MANAGES_CLOCK" -eq 1 ]]; then
    echo "Disabling Host Auto Clock Updating"
    sudo timedatectl set-ntp no

DOCKER_RUN_COMMAND="${DOCKER_RUN_COMMAND}
--cap-add=SYS_TIME --volume=/var/empty:/var/empty -v /etc/ntpd.conf:/etc/ntpd.conf '\'"
fi 

# Set cuda support if needed
if [[ "$NEPI_DEVICE_ID" == "JETSON" ]]; then
    echo "Enabling Jetson GPU Support TRUE"

DOCKER_RUN_COMMAND="${DOCKER_RUN_COMMAND}
--gpus all '\'
--runtime nvidia '\'"
fi 

# Finish Run Command
DOCKER_RUN_COMMAND="${DOCKER_RUN_COMMAND}
<<<<<<< HEAD
${NEPI_ACTIVE_NAME}:${NEPI_ACTIVE_TAG} /bin/bash"
=======
${NEPI_ACTIVE_NAME}:${NEPI_ACTIVE_TAG} /bin/bash '\'
-c 'nepi_rui_start'"

#-c 'nepi_start_all'"

export NEPI_RUNNING_NAME=$NEPI_ACTIVE_NAME
export NEPI_RUNNING_TAG=$NEPI_ACTIVE_TAG
export NEPI_RUNNING_ID=$(sudo docker container ls  | grep $NEPI_RUNNING_NAME | awk '{print $1}')
echo "NEPI Container Running with ID ${NEPI_RUNNING_ID}"

>>>>>>> ed6950b4b7f6c45d73a725821c158e0a852c103b

########################
# Run NEPI Docker
########################

echo ""
echo "Launching NEPI Docker Container with Command"
echo "${DOCKER_RUN_COMMAND}"

run $DOCKER_RUN_COMMAND

########################
# Start NEPI Processes
########################

export NEPI_RUNNING_NAME=$NEPI_ACTIVE_NAME
export NEPI_RUNNING_TAG=$NEPI_ACTIVE_TAG
export NEPI_RUNNING_ID=$(sudo docker container ls  | grep $NEPI_RUNNING_NAME | awk '{print $1}')
echo "NEPI Container Running with ID ${NEPI_RUNNING_ID}"

sudo docker exec  $NEPI_RUNNING_ID /bin/bash -c "/opt/nepi/scripts/nepi_time_start"
sudo docker exec  $NEPI_RUNNING_ID /bin/bash -c "/opt/nepi/scripts/nepi_network_start"
sudo docker exec  $NEPI_RUNNING_ID /bin/bash -c "/opt/nepi/scripts/nepi_dhcp_start"
sudo docker exec  $NEPI_RUNNING_ID /bin/bash -c "/opt/nepi/scripts/nepi_ssh_start"
sudo docker exec  $NEPI_RUNNING_ID /bin/bash -c "/opt/nepi/scripts/nepi_samba_start"
sudo docker exec  $NEPI_RUNNING_ID /bin/bash -c "/opt/nepi/scripts/nepi_engine_start"
sudo docker exec  $NEPI_RUNNING_ID /bin/bash -c "/opt/nepi/scripts/nepi_license_start"



