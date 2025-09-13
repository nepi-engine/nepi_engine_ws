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

source /home/${USER}/.nepi_bash_utils
wait

cd etc
source load_system_config.sh
wait
if [ $? -eq 1 ]; then
    echo "Failed to load load_system_config.sh"
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

if [[ $NEPI_RESTARTING == 0 ]]; then
    update_yaml_value "NEPI_RESTARTING" 1 "${CONFIG_SOURCE}"

else
    echo "You can only restart one image at a time"
    exit 1
fi

########################
# Stop Any Running NEPI Containers
########################
if [[ $NEPI_RUNNING_ID != "unknown" ]]; then
    ./nepi_docker_stop.sh
    wait
fi

#################################
# Create Nepi Required Folders
#################################
echo "Checking NEPI Required Folders"
rfolder=/opt/nepi
if [ ! -f "$rfolder" ]; then
    echo "Creating NEPI Folder: ${rfolder}"
    sudo mkdir -p $rfolder
    sudo chown -R ${USER}:${USER} $rfolder
fi

rfolder=/mnt/nepi_storage
if [ ! -f "$rfolder" ]; then
    echo "Creating NEPI Folder: ${rfolder}"
    sudo mkdir -p $rfolder
    sudo chown -R ${USER}:${USER} $rfolder
fi
rfolder=/mnt/nepi_config/docker_cfg
if [ ! -f "$rfolder" ]; then
    echo "Creating NEPI Folder: ${rfolder}"
    sudo mkdir -p $rfolder
    sudo chown -R ${USER}:${USER} $rfolder
fi
rfolder=/mnt/nepi_config/factory_cfg
if [ ! -f "$rfolder" ]; then
    echo "Creating NEPI Folder: ${rfolder}"
    sudo mkdir -p $rfolder
    sudo chown -R ${USER}:${USER} $rfolder
fi
rfolder=/mnt/nepi_config/system_cfg
if [ ! -f "$rfolder" ]; then
    echo "Creating NEPI Folder: ${rfolder}"
    sudo mkdir -p $rfolder
    sudo chown -R ${USER}:${USER} $rfolder
fi
#################################


#######################
# Update ETC Config Files
#######################

# Update Etc
cd etc
source update_etc_files.sh
wait
cd ..

########################################
# Update NEPI ETC to OS Host ETC Linked files
########################################
# sudo systemctl stop lsyncd
# sudo cp -r ${etc_source}/lsyncd /etc/
# lsyncd_file=$(pwd)/etc/lsyncd/lsyncd.conf
# function add_etc_sync(){
#     etc_sync=${NEPI_CONFIG}/docker_cfg/etc/${1}
#     etc_dest=/etc/${1}
#     echo "" | sudo tee -a $lsyncd_file
#     echo "sync {" | sudo tee -a $lsyncd_file
#     echo "    default.rsync," | sudo tee -a $lsyncd_file
#     echo '    source = "'${etc_sync}'/",' | sudo tee -a $lsyncd_file
#     echo '    target = "'${etc_dest}'/",' | sudo tee -a $lsyncd_file
#     echo "}" | sudo tee -a $lsyncd_file
#     echo " " | sudo tee -a $lsyncd_file
# }
# sudo chown -R ${USER}:${USER} ${lsyncd_file}

# add_etc_sync hosts
# add_etc_sync hostname
# if [ "$NEPI_MANAGES_NETWORK" -eq 1 ]; then
#     add_etc_sync /network/interfaces.d
#     add_etc_sync network/interfaces
#     add_etc_sync dhcp/dhclient.conf
#     add_etc_sync wpa_supplicant
# fi

# if [ "$NEPI_MANAGES_TIME" -eq 1 ]; then
#     add_etc_sync ${etc_path}
    
# fi

# if [ "$NEPI_MANAGES_SSH" -eq 1 ]; then
#     add_etc_sync ssh/sshd_config
# fi


#############################


########################
# Configure NEPI Host Services
########################
# echo "Updating NEPI Managed Services"
# if [ "$NEPI_MANAGES_NETWORK" -eq 1 ]; then
#     # sudo systemctl stop NetworkManager
#     # sudo ip addr flush eth0 && \
#     # sudo systemctl start networking.service && \
#     # sudo ifdown --force --verbose eth0 && \
#     # sudo ifup --force --verbose eth0
#     # sleep 2

#     if [ "$NEPI_DHCP_ON_STARTUP" -eq 1 ]; then
#         # # Remove and restart dhclient
#         # sudo dhclient -r
#         # sudo dhclient
#         # sudo dhclient -nw
#         # #ps aux | grep dhcp
#         :
#     fi
# fi

# if [ "$NEPI_MANAGES_TIME" -eq 1 ]; then
#     #sudo timedatectl set-ntp false
#     #sudo systemctl start chronyd
# fi


# if [ "$NEPI_MANAGES_SSH" -eq 1 ]; then
#     #sudo systemctl restart sshd
#     :
# fi


# start the sync service
#sudo systemctl start lsyncd



# start the sync service
sudo systemctl start lsyncd

########################
# Build Run Command
########################
echo "Building NEPI Docker Run Command"
echo $NEPI_STORAGE
########
# Initialize Run Command
DOCKER_RUN_COMMAND="sudo docker run -d --privileged -it --rm -e UDEV=1 \
--mount type=bind,source=${NEPI_STORAGE},target=${NEPI_STORAGE} \
--mount type=bind,source=${NEPI_CONFIG},target=${NEPI_CONFIG} \
--mount type=bind,source=/dev,target=/dev \
-e DISPLAY=${DISPLAY} \
-v /tmp/.X11-unix/:/tmp/.X11-unix \
--net=host"

# -v ${NEPI_BASE}:${NEPI_BASE} \

# Set Clock Settings

#if [[ "$NEPI_MANAGES_CLOCK" -eq 1 ]]; then
#    echo "Disabling Host Auto Clock Updating"
#    sudo timedatectl set-ntp no

#DOCKER_RUN_COMMAND="${DOCKER_RUN_COMMAND}
#--cap-add=SYS_TIME --volume=/var/empty:/var/empty -v /etc/ntpd.conf:/etc/ntpd.conf \ "
#fi 

# Set cuda support if needed
if [[ "$NEPI_DEVICE_ID" == "device1" ]]; then
    echo "Enabling Jetson GPU Support TRUE"

DOCKER_RUN_COMMAND="${DOCKER_RUN_COMMAND} \
--gpus all \
--runtime nvidia "
fi 

# Finish Run Command
if [[ "$NEPI_ACTIVE_FS" == "nepi_fs_a" ]]; then
echo "nepi_fs_a"
DOCKER_RUN_COMMAND="${DOCKER_RUN_COMMAND} \
${NEPI_FSA_NAME}:${NEPI_FSA_TAG} /bin/bash"
else
echo "nepi_fs_b"
DOCKER_RUN_COMMAND="${DOCKER_RUN_COMMAND} \
${NEPI_FSB_NAME}:${NEPI_FSB_TAG} /bin/bash"
fi

########################
# Run NEPI Docker
########################

echo ""
echo "Launching NEPI Docker Container with Command"
echo "${DOCKER_RUN_COMMAND}"
eval "$DOCKER_RUN_COMMAND"

if [[ "$NEPI_ACTIVE_FS" == "nepi_fs_a" ]]; then
update_yaml_value "NEPI_RUNNING_TAG" "$NEPI_FSA_TAG" "${CONFIG_SOURCE}"
else
update_yaml_value "NEPI_RUNNING_TAG" "$NEPI_FSB_TAG" "${CONFIG_SOURCE}"
fi

update_yaml_value "NEPI_RUNNING" 1 "$CONFIG_SOURCE"
update_yaml_value "NEPI_RUNNING_FS" "$NEPI_ACTIVE_FS" "$CONFIG_SOURCE"

source $(pwd)/load_docker_config.sh
wait

CONTAINER_ID=$(sudo docker ps -aqf "ancestor=${NEPI_RUNNING_FS}:${NEPI_RUNNING_TAG}")
echo $CONTAINER_ID
update_yaml_value "NEPI_RUNNING_ID" $CONTAINER_ID "${CONFIG_SOURCE}"
update_yaml_value "NEPI_RUNNING_LAUNCH_TIME" "$(date +%Y-%m-%d)" "${CONFIG_SOURCE}"
update_yaml_value "NEPI_FS_RESTART" 0 "${CONFIG_SOURCE}"
update_yaml_value "NEPI_RESTARTING" 0 "${CONFIG_SOURCE}"

source $(pwd)/load_docker_config.sh
wait

########################
# Start NEPI Processes
########################

#export NEPI_RUNNING_NAME=$NEPI_ACTIVE_NAME
#export NEPI_RUNNING_TAG=$NEPI_ACTIVE_TAG
#export NEPI_RUNNING_ID=$(sudo docker container ls  | grep $NEPI_RUNNING_NAME | awk '{print $1}')
#echo "NEPI Container Running with ID ${NEPI_RUNNING_ID}"

#sudo docker exec  $NEPI_RUNNING_ID /bin/bash -c "/opt/nepi/scripts/nepi_time_start"
#sudo docker exec  $NEPI_RUNNING_ID /bin/bash -c "/opt/nepi/scripts/nepi_network_start"
#sudo docker exec  $NEPI_RUNNING_ID /bin/bash -c "/opt/nepi/scripts/nepi_dhcp_start"
#sudo docker exec  $NEPI_RUNNING_ID /bin/bash -c "/opt/nepi/scripts/nepi_ssh_start"
#sudo docker exec  $NEPI_RUNNING_ID /bin/bash -c "/opt/nepi/scripts/nepi_samba_start"
#sudo docker exec  $NEPI_RUNNING_ID /bin/bash -c "/opt/nepi/scripts/nepi_engine_start"
#sudo docker exec  $NEPI_RUNNING_ID /bin/bash -c "/opt/nepi/scripts/nepi_license_start"


