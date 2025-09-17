#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##


# This file sets up the OS software requirements for a NEPI File System installation



echo "########################"
echo "NEPI ENVIRONMENT SETUP"
echo "########################"

# Load System Config File
source $(dirname $(pwd))/config/load_system_config.sh
if [ $? -eq 1 ]; then
    echo "Failed to load ${SYSTEM_CONFIG_FILE}"
    exit 1
fi

# Check User Account
CONFIG_USER=$NEPI_USER
if [[ "$USER" != "$CONFIG_USER" ]]; then
    echo "This script must be run by user account ${CONFIG_USER}."
    echo "Log in as ${CONFIG_USER} and run again"
    exit 2
fi

#######################################
## Configure NEPI Software Requirements


echo ""
echo "Installing Software Requirements"

# Create and change to tmp install folder
sudo chown -R nepi:nepi ${STORAGE}
TMP=${STORAGE}\tmp
mkdir $TMP
cd $TMP

echo ""
echo "Installing vim full package"

#sudo update-alternatives --config vim
vim --version | grep clipboard




#Install yq
#https://mikefarah.gitbook.io/yq/v3.x


sudo apt update

#### Install Software

sudo apt install nvidia-utils-515 -y

sudo apt install lsb-release -y
sudo apt install nano -y
sudo apt install git -y
sudo apt install nano -y


sudo apt install trash-cli -y
sudo apt install onboard -y
sudo apt install setools -y
sudo apt install ubuntu-advantage-tools -y

sudo apt install iproute2 -y

sudo apt install scons -y # Required for num_gpsd
sudo apt install zstd -y # Required for Zed SDK installer
sudo apt install dos2unix -y # Required for robust automation_mgr
sudo apt install libv4l-dev v4l-utils -y # V4L Cameras (USB, etc.)
sudo apt install hostapd -y # WiFi access point setup
sudo apt install curl -y # Node.js installation below
sudo apt install v4l-utils -y
sudo apt install isc-dhcp-client -y
sudo apt install wpasupplicant -y
sudo apt install psmisc -y
sudo apt install scapy -y
sudo apt install minicom -y
sudo apt install dconf-editor -y
sudo apt install python-debian -y

sudo apt install python3-scipy -y

sudo apt install libffi-dev -y # Required for python cryptography library
sudo apt install scons -y # Required for num_gpsd
sudo apt install zstd -y # Required for Zed SDK installer
sudo apt install dos2unix -y # Required for robust automation_mgr
sudo apt install libv4l-dev v4l-utils -y # V4L Cameras (USB, etc.)
sudo apt install hostapd -y # WiFi access point setup
sudo apt install curl -y # Node.js installation below
sudo apt install gparted -y
sudo apt install chromium-browser -y # At least once, apt seemed to work for this where apt did not, hence the command here
sudo apt install socat protobuf-compiler -y

sudo apt install gnupg -y
sudo apt install kgpg -y

### Install NEPI Managed Services 
sudo apt install supervisor -y

sudo apt install snapd -y
sudo apt install xz-utils

sudo apt install vim-gtk3 -y
#sudo update-alternatives --config vim
vim --version | grep clipboard

sudo apt install nmap -y

sudo apt install -y lsyncd rsync

sudo add-apt-repository ppa:rmescandon/yq -y
sudo apt update 
sudo apt install yq -y
sudo apt install cmake -y
sudo apt install cmake-doc ninja-build -y


### Install ccache
#https://askubuntu.com/questions/470545/how-do-i-set-up-ccache

sudo apt install -y ccache
sudo /usr/sbin/update-ccache-symlinks
echo 'export PATH="/usr/lib/ccache:$PATH"' | tee -a ~/.bashrc
source ~/.bashrc && echo $PATH
ccache --version




# https://stackoverflow.com/questions/8430332/uninstall-boost-and-install-another-version
# First uninstall older version
sudo apt -y install libboost-all-dev libboost-doc libboost-dev
sudo apt install -y lsyncd rsync


###################################
# Config System Services 
sudo apt install openssh-server -y

sudo apt install samba -y

echo "Installing chrony for NTP services"
sudo apt install chrony -y

# Disable NetworkManager (for next boot)... causes issues with NEPI IP addr. management



######################################

### Install static IP tools
echo "Installing static IP dependencies"
sudo apt install ifupdown -y 
sudo apt install net-tools -y 
    
# Install some additional libraries
sudo apt update
sudo apt install -y build-essential cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev python3-dev python3-numpy libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libdc1394-22-dev
sudo apt install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
sudo apt install -y python3.8-dev python-dev python-numpy python3-numpy
sudo apt install -y libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libdc1394-22-dev
sudo apt install -y libv4l-dev v4l-utils qv4l2 v4l2ucp    
sudo apt install -y libopenblas-base libopenmpi-dev libomp-dev 
sudo apt -y install libopenblas-dev

sudo apt install trash-cli -y   
#sudo apt --fix-broken install

# Set Container Install Conditional Configs
if [ $NEPI_IN_CONTAINER == 0 ]; then
    sudo apt install usbmount -y
fi

#sudo apt install -y apt-show-versions
#######################
# To Updgrade from an existing python version
#######################

#create requirements file from current dev install then run both as normal and sudo user
# https://stackoverflow.com/questions/31684375/automatically-create-file-requirements-txt
# pip3 freeze > requirements.txt
# sed 's/==.*$//' requirements.txt > requirements_no_versions.txt
# then
# Copy to /mnt/nepi_storage/tmp
# ssh into tmp folder on nepi

# Remove old pythons
#sudo apt remove --purge python3.x
#sudo rm -r /usr/bin/python*
#sudo rm -r /usr/lib/python*
#sudo apt autoremove



#######################
# Install Python 
#######################

# Create USER python folder
if [ ! -d "/home/${NEPI_USER}/.local/lib/python${NEPI_PYTHON}/site-packages" ]; then
    mkdir -p /home/${NEPI_USER}/.local/lib/python${NEPI_PYTHON}/site-packages
fi

# Install Python
sudo apt update 

sudo apt install --reinstall ca-certificates
sudo apt install software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa -y 
sudo apt update
sudo apt install python${NEPI_PYTHON} -f -y 

# Make sure there is user local package
mkdir -p $(python -m site --user-site)

# Install pip
sudo apt remove python-pip
sudo apt remove python3-pip
sudo cd /usr/local/bin
sudo rm pip*
# for python 3.9+
#curl -sS https://bootstrap.pypa.io/get-pip.py | sudo python${NEPI_PYTHON}
# for python 3.8
sudo apt install python3-pip
cd /usr/bin
#Then
ln -s /usr/bin/pip3 /home/${NEPI_USER}/.local/lib/python${NEPI_PYTHON}/site-packages/pip
sudo rm /usr/bin/pip
sudo ln -s /usr/bin/pip3 /usr/bin/pip

sudo apt install python${NEPI_PYTHON}-distutils -y
sudo apt install python${NEPI_PYTHON}-venv -y
sudo apt install python${NEPI_PYTHON}-dev -y 


# Update python symlinks
sudo ln -sfn /usr/bin/python${NEPI_PYTHON} /usr/bin/python3
sudo ln -sfn /usr/bin/python3 /usr/bin/python
sudo python${NEPI_PYTHON} -m pip --version


# ** This is just for notes, 
# these commmands are part of nepi_system_aliases 
# installed during nepi setup process
# Edit bashrc file  
# nano ~/.nepi_aliases
# Add to end of bashrc
#    export SETUPTOOLS_USE_DISTUTILS=stdlib
#    export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
#    export PYTHONPATH=/usr/.local/lib/python${NEPI_PYTHON}/site-packages/:$PYTHONPATH

sudo -H python${NEPI_PYTHON} -m pip install cmake
sudo -H python${NEPI_PYTHON} -m pip install numpy
sudo -H python${NEPI_PYTHON} -m pip install scikit-build ninja 
#sudo -H python${NEPI_PYTHON} -m pip install mkl-static mkl-include
# Maybe
# Revert numpy
#sudo python${NEPI_PYTHON} -m pip uninstall numpy
#sudo python${NEPI_PYTHON} -m pip3 install numpy=='1.24.4'

#############
# Cuda Dependant Install Options
if [ $NEPI_HAS_CUDA -eq 0 ]; then
    sudo python${NEPI_PYTHON} -m pip install --no-input opencv-python
    sudo python${NEPI_PYTHON} -m pip install --no-input torch
    sudo python${NEPI_PYTHON} -m pip install --no-input torchvision
    sudo python${NEPI_PYTHON} -m pip install --no-input open3d --ignore-installed
else
    sudo ./nepi_cuda_setup.sh
fi

sudo -H python${NEPI_PYTHON} -m pip uninstall --no-input ultralytics
sudo -H python${NEPI_PYTHON} -m pip install --no-input ultralytics



#############
#Manual installs some additinal packages in sudo one at a time

sudo -H python${NEPI_PYTHON} -m pip install --upgrade setuptools

sudo -H python${NEPI_PYTHON} -m pip uninstall --no-input wheel
sudo -H python${NEPI_PYTHON} -m pip install --no-input wheel

sudo -H python${NEPI_PYTHON} -m pip install --no-input cffi
sudo -H python${NEPI_PYTHON} -m pip uninstall --no-input netifaces
sudo -H python${NEPI_PYTHON} -m pip install --no-input netifaces

sudo -H python${NEPI_PYTHON} -m pip install --no-input pyserial 
sudo -H python${NEPI_PYTHON} -m pip install --no-input websockets 
sudo -H python${NEPI_PYTHON} -m pip install --no-input geographiclib 
sudo -H python${NEPI_PYTHON} -m pip install --no-input PyGeodesy 
sudo -H python${NEPI_PYTHON} -m pip install --no-input harvesters 
sudo -H python${NEPI_PYTHON} -m pip install --no-input WSDiscovery 
sudo -H python${NEPI_PYTHON} -m pip install --no-input python-gnupg 
sudo -H python${NEPI_PYTHON} -m pip install --no-input onvif_zeep
sudo -H python${NEPI_PYTHON} -m pip install --no-input onvif 
sudo -H python${NEPI_PYTHON} -m pip install --no-input rospy_message_converter
sudo -H python${NEPI_PYTHON} -m pip install --no-input PyUSB
sudo -H python${NEPI_PYTHON} -m pip install --no-input jetson-stats

sudo -H python${NEPI_PYTHON} -m pip install --no-input --user labelImg # For onboard training
sudo -H python${NEPI_PYTHON} -m pip install --no-input --user licenseheaders # For updating license files and source code comments

sudo -H python${NEPI_PYTHON} -m pip install --no-input yap
sudo -H python${NEPI_PYTHON} -m pip install --no-input yapf

sudo -H python${NEPI_PYTHON} -m pip install --no-input python-gnupg

sudo -H python${NEPI_PYTHON} -m pip install --upgrade --no-input tornado
sudo -H python${NEPI_PYTHON} -m pip install --no-input Flask
sudo -H python${NEPI_PYTHON} -m pip install --no-input supervisor 

sudo -H python${NEPI_PYTHON} -m pip install --upgrade --no-input scipy

# upgrade python hdf5
# sudo python${NEPI_PYTHON} -m pip install --no-input --upgrade h5py




#############
# Other general python utilities
python${NEPI_PYTHON} -m pip install --no-input --user labelImg # For onboard training
python${NEPI_PYTHON} -m pip install --no-input --user licenseheaders # For updating license files and source code comments





#############
# Install additional python requirements
# Copy the requirements files from nepi_engine/nepi_env/setup to /mnt/nepi_storage/tmp
NEPI_REQ_SOURCE=$(dirname "$(pwd)")/resources/requirements
sudo cp ${NEPI_REQ_SOURCE}/nepi_requirements.txt ./
cat nepi_requirements.txt | sed -e '/^\s*#.*$/d' -e '/^\s*$/d' | xargs -n 1 sudo python${NEPI_PYTHON} -m pip install



############################################
## Setup ROS
############################################
source ros_setup.sh
wait

#########################################
# Setup RUI Required Software
#########################################

python${NEPI_PYTHON} -m pip install --no-input --user -U pip
python${NEPI_PYTHON} -m pip install --no-input --user virtualenv


# Install Base Node.js Tools and Packages (Required for RUI, etc.)
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
export NVM_DIR="${NEPI_HOME}/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install 8.11.1 # RUI-required Node version as of this script creation







