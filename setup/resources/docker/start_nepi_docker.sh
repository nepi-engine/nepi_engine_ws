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

source /home/${USER}/NEPI_CONFIG.sh
wait

########################
# Update NEPI Docker Variables from nepi_docker_config.yaml
refresh_nepi
wait
########################


########################
# Stop Any Running NEPI Containers
########################
. ./stop_nepi_docker.sh
wait

########################
# Build Run Command
########################
echo "Building NEPI Docker Run Command"

########
# Initialize Run Command
DOCKER_RUN_COMMAND=" sudo docker run --privileged -e UDEV=1 --user ${USER_NAME} '\'
--mount type=bind,source=/mnt/nepi_storage,target=/mnt/nepi_storage '\'
--mount type=bind,source=/mnt/nepi_config,target=/mnt/nepi_config '\'
--mount type=bind,source=/dev,target=/dev '\'
-e DISPLAY=${DISPLAY} '\'"


# Set Remove Mode
if [[ ! -v REMOVE_MODE || ( -v REMOVE_MODE && "$REMOVE_MODE" -eq 1 ) ]]; then
    echo "Setting Remove Mode TRUE"
DOCKER_RUN_COMMAND="${DOCKER_RUN_COMMAND}
--rm '\'"
fi 

# Set Interactive Mode
if [[ ! -v IT_MODE || ( -v IT_MODE && "$IT_MODE" -eq 1 ) ]]; then
    echo "Setting Interactive Mode TRUE"
DOCKER_RUN_COMMAND="${DOCKER_RUN_COMMAND}
-it '\'"
fi 


# Set Clock Settings
if [[ "$MANAGES_CLOCK" -eq 1 ]]; then
    echo "Disabling Host Auto Clock Updating"
    sudo timedatectl set-ntp no

DOCKER_RUN_COMMAND="${DOCKER_RUN_COMMAND}
--cap-add=SYS_TIME --volume=/var/empty:/var/empty -v /etc/ntpd.conf:/etc/ntpd.conf '\'"

fi 


# Update Network Settings
echo "Setting Static IP"
echo "IP_ADDRESS"
DOCKER_RUN_COMMAND="${DOCKER_RUN_COMMAND}
--hostname ${USER_NAME}:${DEVICE_ID} '\'
--publish ${IP_ADDRESS}:80:8080 '\'"


#--net=host '\'
#"

#-add-host=${USER_NAME}:${NEPI_IP_ADDRESS} '\'"


if [[ LENGTH OF $IP_ALIASES > 0 ]]; then
    echo "Adding IP Aliases"
    echo $IP_ALIASES


fi 


# Set cuda support if needed
if [[ "$DEVICE_ID" == "JETSON" ]]; then
    echo "Enabling Jetson GPU Support TRUE"

DOCKER_RUN_COMMAND="${DOCKER_RUN_COMMAND}
--gpus all '\'
--runtime nvidia '\'
-v /tmp/.X11-unix/:/tmp/.X11-unix '\'"

fi 




# Finish Run Command
DOCKER_RUN_COMMAND="${DOCKER_RUN_COMMAND}
${ACTIVE_CONT}:${ACTIVE_TAG} /bin/bash '\'
-c '/opt/nepi/scripts/nepi_start_all.sh'"



########################
# Run NEPI Docker
########################

echo ""
echo "Launching NEPI Docker Container with Command"
echo "${DOCKER_RUN_COMMAND}"

drun $DOCKER_RUN_COMMAND



