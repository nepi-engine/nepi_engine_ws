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

#if [ -v NEPI_RESTART -a "$NEPI_RESTART" -eq 0 ]



#####################################
# Update NEPI Docker Config 
####################################
sudo mkdir $NEPI_DOCKER_CONFIG
echo "Copying nepi config files to ${NEPI_DOCKER_CONFIG}"
sudo cp $(dirname "$(pwd)")/resources/docker/* ${NEPI_DOCKER_CONFIG}/
sudo cp $(pwd)/nepi_etc_update.sh ${NEPI_DOCKER_CONFIG}/

source $(pwd)/docker_bash_config.sh
wait

###################
# Initialize Docker Config ETC Folder
NEPI_ETC_SOURCE=$(dirname "$(pwd)")/resources/etc
echo ""
echo "Populating System Folders from ${NEPI_ETC_SOURCE}"
sudo cp -R ${NEPI_ETC_SOURCE}/* ${NEPI_DOCKER_CONFIG}
sudo cp nepi_etc_update.sh ${NEPI_DOCKER_CONFIG}/
sudo chown -R ${NEPI_USER}:${NEPI_USER} $NEPI_DOCKER_CONFIG

# Rsync etc folder from factory folder
rsync -arh ${NEPI_CONFIG}/factory_cfg/etc ${NEPI_CONFIG}/docker_cfg

# Rsync etc folder from system folder
rsync -arh ${NEPI_CONFIG}/system_cfg/etc ${NEPI_CONFIG}/docker_cfg

docker_config=${NEPI_CONFIG}/docker_cfg/nepi_config.yaml
echo "Copying NEPI System Config File ${docker_config} to ${NEPI_DOCKER_CONFIG}"
sudo cp ${docker_config} ${NEPI_DOCKER_CONFIG}/
sudo chown -R ${USER}:${USER} $NEPI_CONFIG


##################################
# Setting Up NEPI Docker Host Services Links

echo "Setting up NEPI Docker Host services"
etc_source=$(dirname "$(pwd)")/resources/etc
etc_dest=/etc
etc_sync=${NEPI_COFNIG}/docker_cfg/etc/docker/etc
lsyncd_file=${etc_dest}/lsyncd/lsyncd.conf



sudo ln -sf ${etc_source}/hosts ${etc_sync}//hosts
if [ ! -f "/etc/hosts.bak" ]; then
    sudo cp -p /etc/hosts /etc/hosts.bak
fi

sudo ln -sf ${etc_source}/hostname ${etc_sync}/hostname
if [ ! -f "/etc/hostname.bak" ]; then
    sudo cp -p /etc/hostname /etc/hostname.bak
fi

if [ "$NEPI_MANAGES_NETWORK" -eq 1 ]; then

    sudo ln -sf ${etc_source}/network/interfaces.d ${etc_sync}/network/interfaces.d
    # Set up static IP addr.
    echo "Updating Network interfaces.d"
    if [ -d "/etc/network/interfaces.d" -a ! -d "/etc/network/interfaces.d.bak" ]; then
        sudo cp -p -r /etc/network/interfaces.d /etc/network/interfaces.d.bak
    fi
    echo "Updating Network interfaces"
    if [ -f "/etc/network/interfaces" -a ! -f "/etc/network/interfaces.bak" ]; then
        sudo cp -p -r /etc/network/interfaces /etc/network/interfaces.bak
    fi


    # Set up DHCP
    sudo ln -sf ${etc_source}/dhcp/dhclient.conf ${etc_sync}/dhcp/dhclient.conf
    echo "Updating Network dhclient.conf"
    if [ -f "/etc/dhcp/dhclient.conf" -a ! -f "/etc/dhcp/dhclient.conf.bak" ]; then
        sudo cp -p -r /etc/dhcp/dhclient.conf /etc/dhcp/dhclient.conf.bak
    fi

    # Set up WIFI
    if [ ! -d "etc/wpa_supplicant" ]; then
        sudo mkdir ${etc_sync}/wpa_supplicant
    fi
    sudo ln -sf ${etc_source}/wpa_supplicant/wpa_supplicant.conf ${etc_sync}/etc/wpa_supplicant/wpa_supplicant.conf
    if [ -d "/etc/wpa_supplicant.bak" ]; then
        sudo cp -p -r /etc/wpa_supplicant /etc/wpa_supplicant.bak
    fi
    
fi

# Rsync etc folder to system folder
rsync -arh  ${NEPI_CONFIG}/docker_cfg/etc ${NEPI_CONFIG}/system_cfg

sudo cp -r ${etc_source}/lsyncd ${etc_dest}
if [[ "$NEPI_MANAGES_NETWORK" -eq 1 ]]; then
    echo "" | sudo tee -a $lsyncd_file
    echo "sync {" | sudo tee -a $lsyncd_file
    echo "    default.rsync," | sudo tee -a $lsyncd_file
    echo '    source = "'${etc_sync}'/",' | sudo tee -a $lsyncd_file
    echo '    target = "'${etc_dest}'/",' | sudo tee -a $lsyncd_file
    echo "}" | sudo tee -a $lsyncd_file
fi

sudo systemctl restart lsyncd



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
${NEPI_ACTIVE_NAME}:${NEPI_ACTIVE_TAG} /bin/bash '\'
-c 'nepi_rui_start'"

#-c 'nepi_start_all'"

export NEPI_RUNNING_NAME=$NEPI_ACTIVE_NAME
export NEPI_RUNNING_TAG=$NEPI_ACTIVE_TAG
export NEPI_RUNNING_ID=$(sudo docker container ls  | grep $NEPI_RUNNING_NAME | awk '{print $1}')
echo "NEPI Container Running with ID ${NEPI_RUNNING_ID}"


########################
# Run NEPI Docker
########################

echo ""
echo "Launching NEPI Docker Container with Command"
echo "${DOCKER_RUN_COMMAND}"

drun $DOCKER_RUN_COMMAND



