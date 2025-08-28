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


source ./NEPI_CONFIG.sh
wait


#######################################
## Configure NEPI Software Requirements


echo ""
echo "Installing Software Requirements"

# Create and change to tmp install folder
sudo chown -R nepi:nepi ${STORAGE}
TMP=${STORAGE}\tmp
mkdir $TMP
cd $TMP






sudo apt-get update

#### Install Software

sudo apt-get install nvidia-utils-515 -y
sudo apt-get install cmake -y
sudo apt-get install lsb-release -y
sudo apt-get install nano -y
sudo apt-get install git -y
sudo apt-get install nano -y


sudo apt-get install trash-cli -y
sudo apt-get install onboard -y
sudo apt-get install setools -y
sudo apt-get install ubuntu-advantage-tools -y

sudo apt-get install iproute2 -y

sudo apt-get install scons -y # Required for num_gpsd
sudo apt-get install zstd -y # Required for Zed SDK installer
sudo apt-get install dos2unix -y # Required for robust automation_mgr
sudo apt-get install libv4l-dev v4l-utils -y # V4L Cameras (USB, etc.)
sudo apt-get install hostapd -y # WiFi access point setup
sudo apt-get install curl -y # Node.js installation below
sudo apt-get install v4l-utils -y
sudo apt-get install isc-dhcp-client -y
sudo apt-get install wpasupplicant -y
sudo apt-get install psmisc -y
sudo apt-get install scapy -y
sudo apt-get install minicom -y
sudo apt-get install dconf-editor -y
sudo apt-get install python-debian -y

sudo apt-get install python3-scipy -y

sudo apt-get install libffi-dev -y # Required for python cryptography library
sudo apt-get install scons -y # Required for num_gpsd
sudo apt-get install zstd -y # Required for Zed SDK installer
sudo apt-get install dos2unix -y # Required for robust automation_mgr
sudo apt-get install libv4l-dev v4l-utils -y # V4L Cameras (USB, etc.)
sudo apt-get install hostapd -y # WiFi access point setup
sudo apt-get install curl -y # Node.js installation below
sudo apt-get install gparted -y
sudo apt-get install chromium-browser -y # At least once, apt-get seemed to work for this where apt-get did not, hence the command here
sudo apt-get install socat protobuf-compiler -y

sudo apt-get install gnupg -y
sudo apt-get install kgpg -y

### Install NEPI Managed Services 
sudo apt-get install supervisor -y

sudo apt-get install snapd -y
sudo apt-get install xz-utils


### Install ccache
#https://askubuntu.com/questions/470545/how-do-i-set-up-ccache
cd $TMP
sudo apt install -y ccache
#sudo /usr/sbin/update-ccache-symlinks
echo 'export PATH="/usr/lib/ccache:$PATH"' | tee -a ~/.bashrc
source ~/.bashrc && echo $PATH
ccache --version


### Install Boost 1.6.1


# https://stackoverflow.com/questions/8430332/uninstall-boost-and-install-another-version
# First uninstall older version
sudo apt-get -y install libboost-all-dev libboost-doc libboost-dev




####FROM THE NEPI BUILD PACKAGE
# Install Boost
cd $TMP
sudo unzip Boost.XXX
sudo ./b2 install

# OR BUILD FROM SOURCE
'
sudo apt-get -y install build-essential g++ python-dev autotools-dev libicu-dev libbz2-dev
cd $TMP
wget http://downloads.sourceforge.net/project/boost/boost/1.68.0/boost_1_68_0.tar.gz
tar -zxf boost_1_68_0.tar.gz
cd boost_1_68_0
# get the no of cpucores to make faster
./bootstrap.sh  # this will generate ./b2
sudo ./b2
sudo ./b2 install
'


### Install MSCL
# https://github.com/LORD-MicroStrain/MSCL/blob/master/BuildScripts/buildReadme_Linux.md
cd $TMP
git clone https://github.com/LORD-MicroStrain/MSCL.git
cd MSCL
mkdir build
cd build
cmake .. -DMSCL_BUILD_PYTHON3=ON -DBOOST_ROOT=/usr/local/include/boost
cmake --build . -j$(nproc)


###################################
# Config System Services
sudo apt-get install openssh-server -y
if [ $NEPI_MANAGES_SSH == 1 ]; then
    sudo systemctl enable --now sshd.service
fi

echo "Installing chrony for NTP services"
sudo apt-get install chrony -y
if [ $NEPI_MANAGES_TIME == 1 ]; then
    sudo systemctl enable --now chrony.service
fi

sudo apt-get install samba -y
if [ $NEPI_MANAGES_SHARE == 1 ]; then
    sudo systemctl enable --now samba.service
fi

# Disable NetworkManager (for next boot)... causes issues with NEPI IP addr. management

if [ $NEPI_MANAGES_NETWORK == 1 ]; then
    sudo systemctl disable NetworkManager
fi

######################################

### Install static IP tools
echo "Installing static IP dependencies"
sudo apt-get install ifupdown -y 
sudo apt-get install net-tools -y 
    
# Install some additional libraries
sudo apt update
sudo apt install -y build-essential cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev python3-dev python3-numpy libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libdc1394-22-dev
sudo apt-get install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
sudo apt-get install -y python3.8-dev python-dev python-numpy python3-numpy
sudo apt-get install -y libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libdc1394-22-dev
sudo apt-get install -y libv4l-dev v4l-utils qv4l2 v4l2ucp    
sudo apt-get install -y libopenblas-base libopenmpi-dev libomp-dev 
sudo apt-get -y install libopenblas-dev

sudo apt-get install trash-cli -y   
#sudo apt --fix-broken install

# Set Container Install Conditional Configs
if [ $NEPI_IN_CONTAINER == 0 ]; then
    sudo apt install usbmount -y
fi


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
#sudo apt-get remove --purge python3.x
#sudo rm -r /usr/bin/python*
#sudo rm -r /usr/lib/python*
#sudo apt-get autoremove

# Uninstall ROS if reinstalling/updating
# sudo apt-get remove ros-noetic-*
# sudo apt-get autoremove
# After that, it's recommended to remove ROS-related environment variables from your .bashrc file 
# and delete the ROS installation directory, typically /opt/ros/noetic. 

#######################
# Install Python 
#######################

# Create USER python folder
mkdir -p ${HOME}/.local/lib/python${NEPI_PYTHON}/site-packages

sudo apt-get update 

sudo apt-get install --reinstall ca-certificates
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa -y 
sudo apt-get update
sudo apt-get install python${PYTHON_VERSION} -f -y 

# Make sure there is user local package
mkdir -p $(python -m site --user-site)

# Install pip
curl -sS https://bootstrap.pypa.io/get-pip.py | sudo python${PYTHON_VERSION}

sudo apt-get install python${PYTHON_VERSION}-distutils -y
sudo apt-get install python${PYTHON_VERSION}-venv -y
sudo apt-get install python${PYTHON_VERSION}-dev -y 


# Update python symlinks
sudo ln -sfn /usr/bin/python${PYTHON_VERSION} /usr/bin/python3
sudo ln -sfn /usr/bin/python3 /usr/bin/python
sudo python${PYTHON_VERSION} -m pip --version

# ** This is just for notes, 
# these commmands are part of nepi_system_aliases 
# installed during nepi setup process
# Edit bashrc file  
# nano ~/.nepi_aliases
# Add to end of bashrc
#    export SETUPTOOLS_USE_DISTUTILS=stdlib
#    export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
#    export PYTHONPATH=/usr/.local/lib/python${PYTHON_VERSION}/site-packages/:$PYTHONPATH

sudo -H python${PYTHON_VERSION} -m pip install cmake
sudo -H python${PYTHON_VERSION} -m pip install numpy
sudo -H python${PYTHON_VERSION} -m pip install scikit-build ninja 
#sudo -H python${PYTHON_VERSION} -m pip install mkl-static mkl-include
# Maybe
# Revert numpy
#sudo python${PYTHON_VERSION} -m pip uninstall numpy
#sudo python${PYTHON_VERSION} -m pip3 install numpy=='1.24.4'

#############
# Cuda Dependant Install Options
if [ $NEPI_HAS_CUDA -eq 0 ]; then
    sudo python${PYTHON_VERSION} -m pip install --no-input opencv-python
    sudo python${PYTHON_VERSION} -m pip install --no-input torch
    sudo python${PYTHON_VERSION} -m pip install --no-input torchvision
    sudo python${PYTHON_VERSION} -m pip install --no-input open3d --ignore-installed
else
    sudo ./nepi_cuda_setup.sh
fi

sudo -H python${PYTHON_VERSION} -m pip uninstall --no-input ultralytics
sudo -H python${PYTHON_VERSION} -m pip install --no-input ultralytics



#############
#Manual installs some additinal packages in sudo one at a time

sudo -H python${PYTHON_VERSION} -m pip install --upgrade setuptools

sudo -H python${PYTHON_VERSION} -m pip uninstall --no-input wheel
sudo -H python${PYTHON_VERSION} -m pip install --no-input wheel

sudo -H python${PYTHON_VERSION} -m pip install --no-input cffi
sudo -H python${PYTHON_VERSION} -m pip uninstall --no-input netifaces
sudo -H python${PYTHON_VERSION} -m pip install --no-input netifaces

sudo -H python${PYTHON_VERSION} -m pip install --no-input pyserial 
sudo -H python${PYTHON_VERSION} -m pip install --no-input websockets 
sudo -H python${PYTHON_VERSION} -m pip install --no-input geographiclib 
sudo -H python${PYTHON_VERSION} -m pip install --no-input PyGeodesy 
sudo -H python${PYTHON_VERSION} -m pip install --no-input harvesters 
sudo -H python${PYTHON_VERSION} -m pip install --no-input WSDiscovery 
sudo -H python${PYTHON_VERSION} -m pip install --no-input python-gnupg 
sudo -H python${PYTHON_VERSION} -m pip install --no-input onvif_zeep
sudo -H python${PYTHON_VERSION} -m pip install --no-input onvif 
sudo -H python${PYTHON_VERSION} -m pip install --no-input rospy_message_converter
sudo -H python${PYTHON_VERSION} -m pip install --no-input PyUSB
sudo -H python${PYTHON_VERSION} -m pip install --no-input jetson-stats

sudo -H python${PYTHON_VERSION} -m pip install --no-input --user labelImg # For onboard training
sudo -H python${PYTHON_VERSION} -m pip install --no-input --user licenseheaders # For updating license files and source code comments

sudo -H python${PYTHON_VERSION} -m pip install --no-input yap
sudo -H python${PYTHON_VERSION} -m pip install --no-input yapf

sudo -H python${PYTHON_VERSION} -m pip install --no-input python-gnupg

sudo -H python${PYTHON_VERSION} -m pip install --upgrade --no-input tornado
sudo -H python${PYTHON_VERSION} -m pip install --no-input Flask
sudo -H python${PYTHON_VERSION} -m pip install --no-input supervisor 

sudo -H python${PYTHON_VERSION} -m pip install --upgrade --no-input scipy

# upgrade python hdf5
# sudo python${PYTHON_VERSION} -m pip install --no-input --upgrade h5py




#############
# Other general python utilities
python${PYTHON_VERSION} -m pip install --no-input --user labelImg # For onboard training
python${PYTHON_VERSION} -m pip install --no-input --user licenseheaders # For updating license files and source code comments





#############
# Install additional python requirements
# Copy the requirements files from nepi_engine/nepi_env/setup to /mnt/nepi_storage/tmp
NEPI_REQ_SOURCE=$(dirname "$(pwd)")/resources/requirements
sudo cp ${NEPI_REQ_SOURCE}/nepi_requirements.txt ./
cat nepi_requirements.txt | sed -e '/^\s*#.*$/d' -e '/^\s*$/d' | xargs -n 1 sudo python${PYTHON_VERSION} -m pip install



############################################
## Setup ROS
############################################
source ros_setup.sh
wait

#########################################
# Setup RUI Required Software
#########################################

python${PYTHON_VERSION} -m pip install --no-input --user -U pip
python${PYTHON_VERSION} -m pip install --no-input --user virtualenv


# Install Base Node.js Tools and Packages (Required for RUI, etc.)
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
export NVM_DIR="${NEPI_HOME}/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install 8.11.1 # RUI-required Node version as of this script creation






