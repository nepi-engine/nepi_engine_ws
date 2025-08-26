#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##


# This file configigues an installed NEPI File System


source ./NEPI_CONFIG.sh
wait

echo ""
echo "NEPI Docker Enviorment Setup"

# Change to tmp install folder
TMP=${STORAGE["tmp"]}
mkdir $TMP
cd $TMP



#################################
# Install Software Requirments
echo ""
echo "Installing NEPI Docker Required Software Packages"
#Install yq
#https://mikefarah.gitbook.io/yq/v3.x
sudo add-apt-repository ppa:rmescandon/yq
sudo apt update
sudo apt install yq -y

sudo apt install git -y
sudo apt install gitk -y

# Visual Code?



#################################
# Install docker if not present
if [ $NEPI_ARCH -eq arm64 -o $NEPI_ARCH -eq amd ]; then
    # https://docs.docker.com/engine/install/ubuntu/
    echo ""
    echo ""
    echo "Installing Docker & Docker Compose"
    # Update Package Lists and Install Prerequisites.
    sudo apt update
    sudo apt install apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=${NEPI_ARCH}] https://download.docker.com/linux/ubuntu focal stable"
    sudo apt update
    sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo docker info
    docker compose version
elif [ $NEPI_ARCH -eq rpi ]; then
    echo "RPI not supported yet"
    exit 1
fi


    # Setup Docker Services
    echo "Enabling Docker Service"
    sudo systemctl enable docker
    sudo systemctl status docker


    echo "Stopping Docker Service"
    sudo systemctl stop docker
    sudo systemctl stop docker.socket

###########
# Set docker service root location
#https://stackoverflow.com/questions/44010124/where-does-docker-store-its-temp-files-during-extraction
# https://forums.docker.com/t/how-do-i-change-the-docker-image-installation-directory/1169
echo ""
echo "Setting Docker File Path to ${NEPI_DOCKER}"

## Update docker file
echo "Updating docker file /etc/default/docker"
FILE=/etc/default/docker
KEY=DOCKER_OPTS
UPDATE=DOCKER_OPTS="'""--dns 8.8.8.8 --dns 8.8.4.4  -g ${NEPI_DOCKER}""'"
sed -i "/^$KEY/c\\$UPDATE" "$FILE"


## Update docker service file
echo "Updating docker file /usr/lib/systemd/system/docker.service"
FILE=/etc/default/docker
KEY=ExecStart
UPDATE="ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --data-root=${NEPI_DOCKER}"
sed -i "/^$KEY/c\\$UPDATE" "$FILE"


#######
# Edit Docker Config


if [[ "$NEPI_HW_TYPE" -eq "JETSON" ]]; then
    echo "Configuring Docker for NVIDIA Jetson "
    # Install nvidia toolkit
    #https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
    && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
        sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

    sudo apt-get update

    export NVIDIA_CONTAINER_TOOLKIT_VERSION=1.17.8-1
    sudo apt-get install --fix-broken -y \
        nvidia-container-toolkit=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
        nvidia-container-toolkit-base=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
        libnvidia-container-tools=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
        libnvidia-container1=${NVIDIA_CONTAINER_TOOLKIT_VERSION}

    
    #runtime configure --runtime=docker --config=$HOME/.config/docker/daemon.json
    sudo mv /etc/docker/daemon.json /etc/docker/daemon.json.bak
    sudo nvidia-ctk runtime configure --runtime=docker


fi

if [[ "$NEPI_HW_TYPE" -eq "GENERIC" ]]; then
    ### BLANK
fi

if [[ "$NEPI_HW_TYPE" -eq "RPI" ]]; then
    ### BLANK
fi

#Then reload and restart docker
echo "Restarting Docker Service"
sudo systemctl daemon-reload
sudo systemctl start docker.socket
sudo systemctl start docker
sudo systemctl status docker

'
#Test Docker install
sudo docker pull hello-world
sudo docker container run hello-world

#Some Debug Commands
sudo dockerd --debug

sudo vi /etc/docker/daemon.json

sudo systemctl stop docker
sudo systemctl stop docker.socket
sudo systemctl daemon-reload
sudo systemctl start docker.socket
sudo systemctl start docker
sudo systemctl status docker
sudo docker info
'

echo ""
echo "Docker Setup Complete"
echo ""


# Disable Host Services if Required
echo "Disabling Host Services that are managed by NEPI"
if [ $NEPI_MANAGES_SSH -eq 1 ]; then
    echo "Disabling Host SSD Service"
    sudo systemctl enable --now sshd.service
fi

if [ $NEPI_MANAGES_TIME -eq 1 ]; then
    echo "Disabling Host Auto Time Data Service"
    sudo systemctl enable --now chrony.service
fi

if [ $NEPI_MANAGES_SHARE -eq 1 ]; then
    echo "Disabling Host Samba Drive Share Service"
    sudo systemctl enable --now samba.service
fi

if [ $NEPI_MANAGES_NETWORK -eq 1 ]; then
    echo "Disabling Host Network Management Service"
    sudo systemctl disable NetworkManager
fi

#####################################
Update Docker Config File
#####################################

###############
echo "Updating nepi config file etc/nepi_config.yaml"
DOCKER_CONFIG_FILE=${DOCKER_CONFIG_FILE}/nepi_docker_config.yaml
cat /dev/null > $DOCKER_CONFIG_FILE
echo "NEPI_HW_TYPE: ${NEPI_HW_TYPE}" >> $DOCKER_CONFIG_FILE
echo "NEPI_HW_MODEL: ${NEPI_HW_MODEL}" >> $DOCKER_CONFIG_FILE

# PYTHON VERSION
echo "NEPI_PYTHON: ${NEPI_PYTHON}" >> $DOCKER_CONFIG_FILE
echo "NEPI_ROS: ${NEPI_ROS}" >> $DOCKER_CONFIG_FILE

# NEPI HOST SETTINGS
echo "NEPI_IN_CONTAINER: ${NEPI_IN_CONTAINER}" >> $DOCKER_CONFIG_FILE
echo "NEPI_HAS_CUDA: ${NEPI_HAS_CUDA}" >> $DOCKER_CONFIG_FILE
echo "NEPI_HAS_XPU: ${NEPI_HAS_XPU}" >> $DOCKER_CONFIG_FILE

# NEPI Managed Resources. Set to 0 to turn off NEPI management of this resouce
# Note, if enabled for a docker deployment, these system functions will be
# disabled in the host OS environment
echo "NEPI_MANAGES_SSH: ${NEPI_MANAGES_SSH}" >> $DOCKER_CONFIG_FILE
echo "NEPI_MANAGES_SHARE: ${NEPI_MANAGES_SHARE}" >> $DOCKER_CONFIG_FILE
echo "NEPI_MANAGES_TIME: ${NEPI_MANAGES_TIME}" >> $DOCKER_CONFIG_FILE
echo "NEPI_MANAGES_NETWORK: ${NEPI_MANAGES_NETWORK}" >> $DOCKER_CONFIG_FILE

# System Setup Variables
echo "NEPI_USER: ${NEPI_USER}" >> $DOCKER_CONFIG_FILE
echo "NEPI_DEVICE_ID: ${NEPI_DEVICE_ID}" >> $DOCKER_CONFIG_FILE
echo "NEPI_IP: ${NEPI_IP}" >> $DOCKER_CONFIG_FILE


# NEPI PARTITIONS
echo "NEPI_DOCKER: ${NEPI_DOCKER}" >> $DOCKER_CONFIG_FILE
echo "NEPI_STORAGE: ${NEPI_STORAGE}" >> $DOCKER_CONFIG_FILE
echo "NEPI_CONFIG: ${NEPI_CONFIG}" >> $DOCKER_CONFIG_FILE

# NEPI File System 
echo "NEPI_ENV: ${NEPI_ENV}" >> $DOCKER_CONFIG_FILE
echo "NEPI_HOME: ${NEPI_HOME}" >> $DOCKER_CONFIG_FILE
echo "NEPI_BASE: ${NEPI_BASE}" >> $DOCKER_CONFIG_FILE
echo "NEPI_RUI: ${NEPI_RUI}" >> $DOCKER_CONFIG_FILE
echo "NEPI_ENGINE: ${NEPI_ENGINE}" >> $DOCKER_CONFIG_FILE
echo "NEPI_ETC: ${NEPI_ETC}" >> $DOCKER_CONFIG_FILE
echo "NEPI_SCRIPTS: ${NEPI_SCRIPTS}" >> $DOCKER_CONFIG_FILE

echo "NEPI_CODE: ${NEPI_CODE}" >> $DOCKER_CONFIG_FILE
echo "NEPI_SRC: ${NEPI_SRC}" >> $DOCKER_CONFIG_FILE

echo "NEPI_IMAGE_INSTALL: ${NEPI_IMAGE_INSTALL}" >> $DOCKER_CONFIG_FILE
echo "NEPI_IMAGE_ARCHIVE: ${NEPI_IMAGE_ARCHIVE}" >> $DOCKER_CONFIG_FILE

echo "NEPI_USR_CONFIG: ${NEPI_USR_CONFIG}" >> $DOCKER_CONFIG_FILE
echo "DOCKER_CONFIG_FILE: ${DOCKER_CONFIG_FILE}" >> $DOCKER_CONFIG_FILE
echo "NEPI_FACTORY_CONFIG: ${NEPI_FACTORY_CONFIG}" >> $DOCKER_CONFIG_FILE
echo "NEPI_SYSTEM_CONFIG: ${NEPI_SYSTEM_CONFIG}" >> $DOCKER_CONFIG_FILE

echo "NEPI_CODE: ${NEPI_CODE}" >> $DOCKER_CONFIG_FILE
echo "NEPI_ALIASES_FILE: ${NEPI_ALIASES_FILE}" >> $DOCKER_CONFIG_FILE

echo "NEPI_AB_FS: ${NEPI_AB_FS}" >> $DOCKER_CONFIG_FILE

# NEPI Docker Config
## NEED TO: Read these from nepi_config.yaml file
ACTIVE_CONT: nepi_fs_a
ACTIVE_VERSION: 3p2p0-RC2
ACTIVE_UPLOAD_DATE: 0
ACTIVE_TAG: jetson-3p2p0-rc2
ACTIVE_ID: 0
INACTIVE_CONT: nepi_fs_a
INACTIVE_VERSION: 3p2p0
INACTIVE_UPLOAD_DATE: 2025-08-26
INACTIVE_TAG: 3p2p3-CUDA_PYTORCH
INACTIVE_ID: 3p2p0
STAGING_CONT: nepi_staging
IMPORT_PATH: $NEPI_IMAGE_INSTALL
EXPORT_PATH: $NEPI_IMAGE_ARCHIVE
######  NEED TO: Update from current docker status
RUNNING_CONT: None
RUNNING_VERSION: uknown
RUNNING_TAG: uknown
RUNNING_ID: 0

# UPDATED VARS
COUNT: 0
SUPPORTS_A_B: $NEPI_AB_FS

sudo chown ${NEPI_USER}:${NEPI_USER} DOCKER_CONFIG_FILE

##################################
echo ""
echo 'NEPI Docker Setup Complete'
##################################

