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


source ./_nepi_config.sh
echo "Starting with NEPI Home folder: ${NEPI_HOME}"

echo ""
echo "Docker Enviorment Setup"

# Change to tmp install folder
TMP=${STORAGE["tmp"]}
mkdir $TMP
cd $TMP



#################################
# Install Software Requirments

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
#???https://www.forecr.io/blogs/installation/how-to-install-and-run-docker-on-jetson-nano
# https://docs.docker.com/engine/install/ubuntu/
echo ""
echo ""
echo "Installing Docker & Docker Compose"
# Update Package Lists and Install Prerequisites.
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=arm64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Setup Docker service
sudo docker info
docker compose version
sudo systemctl enable docker
sudo systemctl status docker


###########
# Set docker service root location
#https://stackoverflow.com/questions/44010124/where-does-docker-store-its-temp-files-during-extraction
# https://forums.docker.com/t/how-do-i-change-the-docker-image-installation-directory/1169

sudo systemctl stop docker
sudo systemctl stop docker.socket


sudo vi /etc/default/docker
# Edit this line and uncomment
DOCKER_OPTS="--dns 8.8.8.8 --dns 8.8.4.4  -g $NEPI_DOCKER"


sudo vi /usr/lib/systemd/system/docker.service
#Comment out ExecStart line and add below
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --data-root=${NEPI_DOCKER}

#Then reload and restart docker
sudo systemctl daemon-reload
sudo systemctl start docker.socket
sudo systemctl start docker
sudo systemctl status docker
sudo docker info

##########
#Test Docker install
sudo docker pull hello-world
sudo docker container run hello-world

#Some Debug Commands
'
sudo dockerd --debug

sudo vi /etc/docker/daemon.json

sudo systemctl stop docker
sudo systemctl stop docker.socket
sudo systemctl daemon-reload
sudo systemctl start docker.socket
sudo systemctl start docker
sudo systemctl status docker
'


#######
# Edit Docker Config

#Stop docker
sudo systemctl stop docker
sudo systemctl stop docker.socket

if [[ "$NEPI_HW" == "JETSON" ]]; then

    
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

    #Then reload and restart docker
    sudo systemctl daemon-reload
    sudo systemctl start docker.socket
    sudo systemctl start docker
    sudo systemctl status docker
    #sudo docker info

fi

if [[ "$NEPI_HW" == "GENERIC" ]]; then
    ### BLANK
fi

if [[ "$NEPI_HW" == "RPI" ]]; then
    ### BLANK
fi

#Then reload and restart docker
sudo systemctl daemon-reload
sudo systemctl start docker.socket
sudo systemctl start docker
sudo systemctl status docker
sudo docker info

##############
# Setup Docker Compose




# Disable Host Services if Required
if [ $NEPI_MANAGES_SSH == 1 ]; then
    sudo systemctl enable --now sshd.service
fi

if [ $NEPI_MANAGES_TIME == 1 ]; then
    sudo systemctl enable --now chrony.service
fi

if [ $NEPI_MANAGES_SHARE == 1 ]; then
    sudo systemctl enable --now samba.service
fi

if [ $NEPI_MANAGES_NETWORK == 1 ]; then
    sudo systemctl disable NetworkManager
fi

##################################
echo 'Setup Complete'
##################################


#############################################################################


##################################
# Import Image Container
##################################


##################################
# Switch Active Container
##################################


##################################
# Build new Jetson Container
##################################
# https://catalog.ngc.nvidia.com/orgs/nvidia/containers/l4t-jetpack

sudo docker run -it --net=host --runtime nvidia -e DISPLAY=$DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix nvcr.io/nvidia/l4t-jetpack:r35.1.0

### Within container do this:
# Set root password
passwd
nepi
nepi


## Add nepi user
# https://stackoverflow.com/questions/27701930/how-to-add-users-to-docker-container
addgroup nepi
adduser --ingroup nepi nepi
visudo /etc/sudoers
nepi    ALL=(ALL:ALL) ALL

su nepi
passwd
nepi
nepi