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
echo "Installing vim full package"
sudo apt install vim-gtk3 -y
#sudo update-alternatives --config vim
vim --version | grep clipboard

sudo apt install nmap -y


#Install yq
#https://mikefarah.gitbook.io/yq/v3.x
sudo add-apt-repository ppa:rmescandon/yq
sudo apt update
sudo apt install yq -y

sudo apt install git -y
sudo apt install gitk -y

# Visual Code?
sudo snap install code --channel=edge --classic




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


####### Add NEPI IP Addr to eth0
sudo ip addr add ${NEPI_IP}/24 dev eth0



##################################
echo ""
echo 'NEPI Docker Environment Setup Complete'
##################################

