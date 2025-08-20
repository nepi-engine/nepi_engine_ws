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
#TMP=${STORAGE["tmp"]}
#mkdir $TMP
#cd $TMP

cd /mnt
# Create nepi_config folder
sudo mkdir nepi_config
# Create nepi_docker folder
sudo mkdir nepi_docker
# Create nepi_full_img folder
sudo mkdir nepi_full_img
# Create nepi_storage folder
sudo mkdir nepi_storage

# Partition Data for nepi_docker # NOTE: Do we need nepi_full_img

# Install docker if not present
# Install Docker & Docker Compose
echo ""
echo ""
echo "Installing Docker & Docker Compose"
# Update Package Lists and Install Prerequisites.
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
# Add Docker's Official GPG Key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# Add the Docker Repository to APT Sources
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
# Update the Package Database with the Docker Packages
sudo apt update
# Install Docker Engine
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# Enable Docker to Start on Launch
sudo systemctl enable docker
# Verify the Installation.
#https://www.forecr.io/blogs/installation/how-to-install-and-run-docker-on-jetson-nano
# Check if Docker & Docker Compose are Installed
docker --version
docker compose version

echo ""
echo ""
echo "Select the NEPI Hardware Host Options"
select yn in 'JETSON' 'GENERIC' 'RPI'; do
    case $yn in
        GENERIC ) break;;
        JETSON ) break;;
        RPI ) break;;
    esac
    NEPI_HW=${yn}
done

if [[ "$NEPI_HW" == "JETSON" ]]; then
    # Install nvidia toolkit
    #https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html
    sudo apt-get install -y nvidia-container-toolkit
    sudo apt-get install nvidia-container-run
    #runtime configure --runtime=docker --config=$HOME/.config/docker/daemon.json

    sudo vim /etc/docker/daemon.json
    # Edit the file to:
    {
        "runtimes": {
            "nvidia": {
                "path": "nvidia-container-runtime",
                "runtimeArgs": []
            }
        },
        "data-root": "/mnt/${NEPI_DOCKER}" 
    }
    # Then save and quit
fi

if [[ "$NEPI_HW" == "GENERIC" ]]; then
    ### BLANK
fi

if [[ "$NEPI_HW" == "RPI" ]]; then
    ### BLANK
fi

sudo vi /etc/default/docker
# Edit this line and uncomment
DOCKER_OPTS="--dns 8.8.8.8 --dns 8.8.4.4"  -g /mnt/${NEPI_DOCKER}/

# Set docker service root location
#https://stackoverflow.com/questions/44010124/where-does-docker-store-its-temp-files-during-extraction
sudo vi /usr/lib/systemd/system/docker.service
#Comment out ExecStart line and add below
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --data-root=/mnt/${NEPI_DOCKER}/
#Then reload
sudo systemctl daemon-reload

#start docker
sudo systemctl start docker.socket
sudo systemctl start docker
sudo docker info

##################################
echo 'Setup Complete'
##################################