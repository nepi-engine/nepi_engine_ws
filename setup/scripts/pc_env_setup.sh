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




echo "########################"
echo "NEPI PC ENVIRONMENT Setup"
echo "########################"

# Load System Config File
SCRIPT_FOLDER=$(pwd)
cd $(dirname $(pwd))/config
source load_system_config.sh
if [ $? -eq 1 ]; then
    echo "Failed to load ${SYSTEM_CONFIG_FILE}"
    cd $SCRIPT_FOLDER
    exit 1
fi
cd $SCRIPT_FOLDER


# Change to tmp install folder
TMP=${STORAGE["tmp"]}
mkdir $TMP
cd $TMP

INSTALL_ROS=0
echo ""
echo ""
echo "Would you like to install ROS as part of this setup"
select yn in 'Yes' 'No'; do
    case $yn in
        Yes ) break;;
        No ) break;;
    esac
    INSTALL_ROS=${yn}
done




#################################
# Install Software Requirments

echo ""
echo "Installing vim full package"
sudo apt install vim-gtk3 -y
#sudo update-alternatives --config vim
vim --version | grep clipboard




#Install yq
#https://mikefarah.gitbook.io/yq/v3.x
sudo add-apt-repository ppa:rmescandon/yq
sudo apt update
sudo apt install yq -y

sudo apt install git -y
sudo apt install gitk -y

# Visual Code?
sudo snap install code --channel=edge --classic

sudo apt install nmap -y



####### Add NEPI IP Addr to eth0
#sudo ip addr add ${NEPI_IP}/24 dev eth0

####### Install ROS if Needed
if [[ "$INSTALL_ROS" -eq 1]]; then
    source ros_setup.sh
fi


##################################
echo ""
echo 'NEPI PC Environment Setup Complete'
##################################

