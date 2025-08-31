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

########################
# Update NEPI Config Settings from nepi_config.yaml
NEPI_CONFIG_FILE=$(pwd)/nepi_config.yaml
refresh_nepi_config $NEPI_CONFIG_FILE
wait

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


#######################
# Rsync etc folder from factory folder
rsync -arh ${NEPI_CONFIG}/factory_cfg/etc ${NEPI_CONFIG}/docker_cfg

# Rsync etc folder from system folder
rsync -arh ${NEPI_CONFIG}/system_cfg/etc ${NEPI_CONFIG}/docker_cfg

docker_config=${NEPI_CONFIG}/docker_cfg/nepi_config.yaml
echo "Copying NEPI System Config File ${docker_config} to ${NEPI_DOCKER_CONFIG}"
sudo cp ${docker_config} ${NEPI_DOCKER_CONFIG}/
sudo chown -R ${USER}:${USER} $NEPI_CONFIG

# Rsync etc folder to system folder
rsync -arh  ${NEPI_CONFIG}/docker_cfg/etc ${NEPI_CONFIG}/system_cfg



########################
# Build Run Command
########################
echo "Building NEPI Docker Run Command"

########
# Initialize Run Command
DOCKER_RUN_COMMAND=" sudo docker run --privileged -e UDEV=1 --user ${NEPI_USER} '\'
--mount type=bind,source=${NEPI_STORAGE},target=${NEPI_STORAGE} '\'
--mount type=bind,source=${NEPI_CONFIG},target=${NEPI_CONFIG} '\'
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
--runtime nvidia '\'
-v /tmp/.X11-unix/:/tmp/.X11-unix '\'"

fi 




# Finish Run Command
DOCKER_RUN_COMMAND="${DOCKER_RUN_COMMAND}
${NEPI_ACTIVE_NAME}:${NEPI_ACTIVE_TAG} /bin/bash '\'
-c 'nepi_rui_start'"

#-c 'nepi_start_all'"



########################
# Run NEPI Docker
########################

echo ""
echo "Launching NEPI Docker Container with Command"
echo "${DOCKER_RUN_COMMAND}"

drun $DOCKER_RUN_COMMAND



