#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##


# This file sets up NEPI File System on a device hosted a nepi file system 
# or inside a ubuntu docker container


# NEPI Hardware Host Options: GENERIC,JETSON,RPI
NEPI_HW=JETSON


###################################
# System Setup Variables
##################################
NEPI_IP=192.168.179.103
NEPI_USER=nepi

# NEPI PARTITIONS
NEPI_FS_A=/mnt/nepi_fs_a
NEPI_FS_B=/mnt/nepi_fs_b
NEPI_FS_STAGING=/mnt/nepi_staging
NEPI_STORAGE=/mnt/nepi_storage
NEPI_CONFIG=/mnt/nepi_config

FS_MIN_GB=50
STORAGE_MIN_GB=150
CONFIG_MIN_GB=1

##########################
# Process Folders
CURRENT_FOLDER=$PWD

##########################
# NEPI File System 
NEPI_HOME=/home/${NEPI_USER}
NEPI_BASE=/opt/nepi
NEPI_RUI=${NEPI_BASE}/rui
NEPI_ENGINE=${NEPI_BASE}/engine
NEPI_ETC=${NEPI_BASE}/etc

SYSTEMD_SERVICE_PATH=/etc/systemd/system

#################
# NEPI Storage Folders

declare -A STORAGE

STORAGE['nepi_fs_a']=${NEPI_FS_A}
STORAGE['nepi_fs_b']=${NEPI_FS_B}
STORAGE['nepi_staging']=${NEPI_FS_STAGING}
STORAGE['nepi_storage']=${NEPI_STORAGE}
STORAGE['nepi_config']=${NEPI_CONFIG}

STORAGE['data']=${NEPI_STORAGE}/data
STORAGE['ai_models']=${NEPI_STORAGE}/ai_models
STORAGE['ai_training']=${NEPI_STORAGE}/ai_training
STORAGE['automation_scripts']=${NEPI_STORAGE}/automation_scripts
STORAGE['databases']=${NEPI_STORAGE}/databases
STORAGE['install']=${NEPI_STORAGE}/install
STORAGE['license']=${NEPI_STORAGE}/install
STORAGE['nepi_src']=${NEPI_STORAGE}/nepi_src
STORAGE['nepi_full_img']=${NEPI_STORAGE}/nepi_full_img
STORAGE['nepi_full_img_archive']=${NEPI_STORAGE}/nepi_full_img_archive
STORAGE['sample_data']=${NEPI_STORAGE}/sample_data
STORAGE['user_cfg']=${NEPI_STORAGE}/user_cfg
STORAGE['tmp']=${NEPI_STORAGE}/tmp

STORAGE['system_cfg']=${NEPI_CONFIG}/system_cfg
STORAGE['factory_cfg']=${NEPI_CONFIG}/factory_cfg


##############
# Requirments

INTERNET_REQ=false
PARTS_REQ=false
DOCKER_REQ=false

###############################
## NEPI Tool Options
###############################
NEPI_STORAGE_TOOLS=false
NEPI_DOCKER_TOOLS=false
NEPI_SOFTWARE_TOOLS=false
NEPI_CONFIG_Tools=false

OP_SELECTION='NEPI Config Tools'

echo ""
echo ""
echo "Select NEPI Tools option:"
select yn in 'NEPI Drive Tools' 'NEPI Docker Tools' 'NEPI Software Tools' 'NEPI Config Tools'; do
    case $yn in
        NEPI Drive Tools )  NEPI_STORAGE_TOOLS=true;;
        NEPI Docker Tools ) INTERNET_REQ=true; PARTS_REQ=true; NEPI_DOCKER_TOOLS=true;;
        NEPI Software Tools ) INTERNET_REQ=true; PARTS_REQ=true; NEPI_SOFTWARE_TOOLS=true;;
        NEPI Config Tools ) NEPI_CONFIG_Tools=true;;
    esac
    OP_SELECTION=${yn}
done


## Check Selection
echo ""
echo ""
echo "Confirm Selection: ${OP_SELECTION}"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) exit 1;;
    esac
done



#################################
## Run Required Checks
#################################

###################
## Check Internet
if [ $INTERNET_REQ ]; then
    echo "Checking for rerquired internet connection"
    check=false
    while [$check == false]
    do
        if ! ping -c 2 google.com; then
            echo "No Internet Connection"
            check=false
        else
            echo "Internet Connected"
            check=true
        fi
        if [ $check == false]; then
            echo "Connect to internet and Try Again or Quit Setup"
            select yn in "Yes" "No"; do
                case $yn in
                    Try Again ) break;;
                    Quit Setup ) exit 1;;
                esac
            done
        fi
    done



###################
## Check Partitions

NEPI_FS_A=/mnt/nepi_fs_a
NEPI_FS_B=/mnt/nepi_fs_b
NEPI_FS_STAGING=/mnt/nepi_staging
NEPI_STORAGE=/mnt/nepi_storage
NEPI_CONFIG=/mnt/nepi_config

FS_MIN_GB=50
STORAGE_MIN_GB=150
CONFIG_MIN_GB=1

if [ $PARTS_REQ ]; then
    echo "Checking for rerquired NEPI SSD Folders"
    check=false
    while [$check == false]
    do
        check = false
        if [! -d ${NEPI_FS_A} ]; then
            check = 
            echo "Missing required folder: ${NEPI_FS_A} with min partition size ${FS_MIN_GB}"
            check=false
        else
            check=true
        fi

        if [! -d ${NEPI_FS_B} ]; then
            check = 
            echo "Missing required folder: ${NEPI_FS_B} with min partition size ${FS_MIN_GB}"
            check=false
        else
            check=true
        fi

        if [! -d ${NEPI_FS_STAGING} ]; then
            check = 
            echo "Missing required folder: ${NEPI_FS_STAGING} with min partition size ${FS_MIN_GB}"
            check=false
        else
            check=true
        fi

        if [! -d ${NEPI_STORAGE} ]; then
            check = 
            echo "Missing required folder: ${NEPI_STORAGE} with min partition size ${STORAGE_MIN_GB}"
            check=false
        else
            check=true
        fi

        if [! -d ${NEPI_CONFIG} ]; then
            check = 
            echo "Missing required folder: ${NEPI_CONFIG} with min partition size ${STORAGE_MIN_GB}"
            check=false
        else
            check=true
        fi

        if [ $check == false]; then
            echo "Please create missing nepi partitions with required sizes and edit /etc/fstab file with the shown folder mount points"
            select yn in "Yes" "No"; do
                case $yn in
                    Try Again ) break;;
                    Quit Setup ) exit 1;;
                esac
            done
        fi
    done

###################
## Check HARDWARE
if [ $DOCKER_REQ ]; then
    echo "Checking for rerquired internet connection"
    check=false
    if [ -f /.dockerenv ]; then
        echo "Running in Docker"
        check=true
    else
        echo "Internet Connected"
        check=true
    fi
    if [ $check == false]; then
        echo "Connect to internet and Try Again or Quit Setup"
        select yn in "Yes" "No"; do
            case $yn in
                Try Again ) break;;
                Quit Setup ) exit 1;;
            esac
        done
    fi





#################################
## Docker Tools
#################################

SETUP_DOCKER=false
BUILD_CONTAINER=false

DK_SELECTION='Build New Container'

if [ $NEPI_DOCKER_TOOLS]; then

    echo ""
    echo ""
    echo "Select the file system task, or select DO ALL to run all processes:"
    select yn in 'Setup Docker Env' 'Build New Container' ; do
        case $yn in            
            Setup Docker Env ) SETUP_DOCKER=true;;
            Build New Container ) BUILD_CONTAINER=true;;
        esac
        DK_SELECTION=${yn}
    done

    ## Check Selection
    echo ""
    echo ""
    echo "Confirm Selection: ${SELECTION}"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) break;;
            No ) exit 1;;
        esac
    done
fi






#################################
## NEPI_SOFTWARE_SETUP Options
#################################
USER_ENV=false
SOFTWARE_ENV=false
CUDA_SOFTWARE=false
NEPI_ENV=false
NEPI_SOFTWARE=false
NEPI_STORAGE=false
SYS_DO_ALL=false

SW_SELECTION='DO ALL'


if [ $NEPI_SOFTWARE_TOOLS]; then

    echo ""
    echo ""
    echo "Select the file system task, or select DO ALL to run all processes:"
    select yn in 'User Environment'  'Software Environment' 'CUDA Software' 'NEPI Environment' 'NEPI Software' 'DO ALL'; do
        case $yn in
            User Environment ) USER_ENV=true;;
            Software Environment ) SOFTWARE_ENV=true;;
            NEPI Environment ) NEPI_ENV=true;;
            NEPI Software ) NEPI_SOFTWARE=true;;
            NEPI Storage ) NEPI_STORAGE=true;;
            DO ALL )  SYS_DO_ALL=true;;
        esac
        SW_SELECTION=${yn}
    done

    ## Check Selection
    echo ""
    echo ""
    echo "Confirm Selection: ${SW_SELECTION}"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) break;;
            No ) exit 1;;
        esac
    done
fi

##################
# Setup NEPI User

# Add nepi user and group if does not exist
if [ $USER_ENV -o $SYS_DO_ALL]; then
    echo ""
    echo "Setting up nepi user account"
    group="nepi"
    user="nepi"
    if grep -q $group /etc/group;  then
          echo "group exists"
    else
          echo "group $group does not exist, creating"
          addgroup nepi
    fi

    if id -u "$user" >/dev/null 2>&1; then
      echo "User $user exists."
    else
      echo "User $user does not exist, creating"
      adduser --ingroup nepi nepi
      echo "nepi ALL=(ALL:ALL) ALL" >> /etc/sudoers

      su nepi
      passwd
      nepi
      nepi
    fi

    # Add nepi user to dialout group to allow non-sudo serial connections
    sudo adduser nepi dialout

    #or //https://arduino.stackexchange.com/questions/74714/arduino-dev-ttyusb0-permission-denied-even-when-user-added-to-group-dialout-o
    #Add your standard user to the group "dialout'
    sudo usermod -a -G dialout nepi
    #Add your standard user to the group "tty"
    sudo usermod -a -G tty nepi

    # Clear the Desktop
    sudo rm /home/nepi/Desktop/*

    echo "User Account Setup Complete"
fi



#######################################
## Configure NEPI Software Requirements

if [ $SOFTWARE_ENV -o $SYS_DO_ALL]; then
    echo ""
    echo "Installing Software Requirements"

      sudo apt-get install nano
      sudo apt update
      sudo apt install git -y
      git --version

      sudo apt install samba

      sudo pip install supervisor      

    #___________________
    #Install dependancies
    sudo apt update
    sudo apt upgrade

    # Convenience applications
    sudo apt install nano


    #######################

    # Uninstall ROS if reinstalling/updating
    # sudo apt remove ros-noetic-*
    # sudo apt-get autoremove
    # After that, it's recommended to remove ROS-related environment variables from your .bashrc file 
    # and delete the ROS installation directory, typically /opt/ros/noetic. 


    # Install Python 
    sudo apt update 

    sudo apt-get install --reinstall ca-certificates
    sudo apt-get install software-properties-common
    sudo add-apt-repository ppa:deadsnakes/ppa
    sudo apt update
    sudo apt install python3.10 
    sudo apt install python3.10-distutils -f

    # Update python symlinks
    cd /usr/bin
    sudo ln -sfn python3.10 python3
    sudo ln -sfn python3 python

    sudo apt install python3.10-venv 
    sudo apt install python3.10-dev 

    # Install pip
    curl -sS https://bootstrap.pypa.io/get-pip.py | sudo python3.10
    python3.10 -m pip --version




    #create requirements file from current dev install then run both as normal and sudo user
    # https://stackoverflow.com/questions/31684375/automatically-create-file-requirements-txt
    # pip3 freeze > requirements.txt
    # sed 's/==.*$//' requirements.txt > requirements_no_versions.txt
    # then
    # Copy to /mnt/nepi_storage/tmp
    # ssh into tmp folder on nepi

    #Install python requred packages
    # 1) Copy nepi_env/config/home/nepi/requirements_no_versions to /mnt/nepi_storage/tmp
    # 2) SSH into your nepi device and type



    # Edit bashrc file
    nano ~/.nepi_aliases
    # Add to end of bashrc
        export SETUPTOOLS_USE_DISTUTILS=stdlib
        export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
        export PYTHONPATH=/usr/local/lib/python3.10/site-packages/:$PYTHONPATH


    ##_________________________
    ## Setup ROS

    sudo apt-get install lsb-release -y

    #  Install ros
    #  https://wiki.ros.org/noetic/Installation/Ubuntu

    cd /mnt/nepi_storage/tmp
    sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
    sudo apt install curl # if you haven't already installed curl
    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
    sudo apt update
    ####################
    # Do if ROS not installed
    sudo apt install ros-noetic-desktop-full
    source /opt/ros/noetic/setup.bash
    sudo apt install python3-rosdep 
    sudo apt install python3-rosinstall 
    sudo apt install python3-rosinstall-generator 
    sudo apt install python3-wstool build-essential
    sudo rosdep init
    rosdep update


    # Then
    #sudo apt-get install ros-noetic-catkin python-catkin-tools
    #sudo pip3 install --user git+https://github.com/catkin/catkin_tools.git

    ROS_VERSION=noetic

    ADDITIONAL_ROS_PACKAGES="python3-catkin-tools \
        ros-${ROS_VERSION}-rosbridge-server \
        ros-${ROS_VERSION}-pcl-ros \
        ros-${ROS_VERSION}-web-video-server \
        ros-${ROS_VERSION}-camera-info-manager \
        ros-${ROS_VERSION}-tf2-geometry-msgs \
        ros-${ROS_VERSION}-mavros \
        ros-${ROS_VERSION}-mavros-extras \
        ros-${ROS_VERSION}-serial \
        python3-rosdep" 

        # Deprecated ROS packages?
        #ros-${ROS_VERSION}-tf-conversions
        #ros-${ROS_VERSION}-diagnostic-updater 
        #ros-${ROS_VERSION}-vision-msgs

    sudo apt install $ADDITIONAL_ROS_PACKAGES


    sudo apt install ros-noetic-cv-bridge
    sudo apt install ros-noetic-web-video-server

    ####################
    sudo pip install bagpy
    sudo pip install pycryptodome-test-vectors


    # 1) edit the following file: 
    #sudo su
    #cd /opt/ros/noetic/lib/rosbridge_server/
    #cp rosbridge_websocket.py  rosbridge_websocket.bak
    #vi rosbridge_websocket.py
    # Add the following lines under import sys


    # Mavros requires some additional setup for geographiclib
    sudo /opt/ros/${ROS_VERSION}/lib/mavros/install_geographiclib_datasets.sh

    # Need to change the default .ros folder permissions for some reason
    //sudo mkdir /home/nepi/.ros
    sudo chown -R nepi:nepi /home/nepi/.ros

    # Setup rosdep
    #sudo rm -r /etc/ros/rosdep/sources.list.d/20-default.list
    #sudo rosdep init
    #rosdep update

    source /opt/ros/noetic/setup.bash


    ############################################
    # Maybe not
    //- upgrade python hdf5
    //sudo pip install --upgrade h5py

    _________________________





    #Manual installs some additinal packages in sudo one at a time
    ################################
    # Install some required packages
    sudo apt-get install python-debian
    sudo pip install cffi
    pip install open3d --ignore-installed
    sudo pip install open3d --ignore-installed

    #sudo pip uninstall netifaces
    sudo pip install netifaces
    sudo apt-get install trash-cli
    sudo apt-get install onboard
    sudo apt-get install setools
    sudo apt-get install ubuntu-advantage-tools

    sudo apt-get install -y iproute2

    sudo apt-get install scons # Required for num_gpsd
    sudo apt-get install zstd # Required for Zed SDK installer
    sudo apt-get install dos2unix # Required for robust automation_mgr
    sudo apt-get install libv4l-dev v4l-utils # V4L Cameras (USB, etc.)
    sudo apt-get install hostapd # WiFi access point setup
    sudo apt-get install curl # Node.js installation below
    sudo apt-get install v4l-utils
    sudo apt-get install isc-dhcp-client
    sudo apt-get install wpasupplicant
    sudo apt-get install -y psmisc
    sudo apt-get install scapy
    sudo apt-get install minicom
    sudo apt-get install dconf-editor


    #############
    # Other general python utilities
    pip install --user labelImg # For onboard training
    pip install --user licenseheaders # For updating license files and source code comments

    # Install additional python requirements
    # Copy the requirements files from nepi_engine/nepi_env/setup to /mnt/nepi_storage/tmp
    cd /mnt/nepi_storage/tmp
    sudo su
    cat requirements_no_versions.txt | sed -e '/^\s*#.*$/d' -e '/^\s*$/d' | xargs -n 1 python3.10 -m pip install
    exit


    # Revert numpy
    sudo pip uninstall numpy
    sudo pip3 install numpy=='1.24.4'


    ## Maybe not needed with requirements
            # NEPI runtime python3 dependencies. Must install these in system folders such that they are on root user's python path
            sudo -H pip install pyserial 
            sudo -H pip install websockets 
            sudo -H pip install geographiclib 
            sudo -H pip install PyGeodesy 
            sudo -H pip install harvesters 
            sudo -H pip install WSDiscovery 
            sudo -H pip install python-gnupg 
            sudo -H pip install onvif_zeep
            sudo -H pip install onvif 
            sudo -H pip install rospy_message_converter
            sudo -H pip install PyUSB
            sudo -H pip install jetson-stats


            sudo -H pip install --user labelImg # For onboard training
            sudo -H pip install --user licenseheaders # For updating license files and source code comments
            #pip install --user labelImg # For onboard training
            #pip install --user licenseheaders # For updating license files and source code comments


            # NOT Sure
            sudo apt-get install python3-scipy
            #sudo -H pip install --upgrade scipy

            sudo pip install yap
            #pip install yap
            sudo pip install yapf






    sudo /opt/ros/${ROS_VERSION}/lib/mavros/install_geographiclib_datasets.sh






    #########
    # Work-around opencv path installation issue on Jetson (after jetpack installation)
    sudo ln -s /usr/include/opencv4/opencv2/ /usr/include/opencv
    sudo ln -s /usr/lib/aarch64-linux-gnu/cmake/opencv4 /usr/share/OpenCV








    # Install Base Python Packages
    echo "Installing base python packages"
    sudo apt install python3-pip
    pip install --user -U pip
    pip install --user virtualenv
    sudo apt install libffi-dev # Required for python cryptography library

    # NEPI runtime python3 dependencies. Must install these in system folders such that they are on root user's python path
    sudo -H pip install python-gnupg websockets onvif_zeep geographiclib PyGeodesy onvif harvesters WSDiscovery pyserial




    sudo apt install scons # Required for num_gpsd
    sudo apt install zstd # Required for Zed SDK installer
    sudo apt install dos2unix # Required for robust automation_mgr
    sudo apt install libv4l-dev v4l-utils # V4L Cameras (USB, etc.)
    sudo apt install hostapd # WiFi access point setup
    sudo apt install curl # Node.js installation below
    sudo apt install gparted
    sudo apt-get install chromium-browser # At least once, apt-get seemed to work for this where apt did not, hence the command here

    # Install Base Node.js Tools and Packages (Required for RUI, etc.)
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    nvm install 8.11.1 # RUI-required Node version as of this script creation



    # Mavros requires some additional setup for geographiclib
    sudo /opt/ros/${ROS_VERSION}/lib/mavros/install_geographiclib_datasets.sh

    # Setup rosdep
    sudo rosdep init
    rosdep update

    # Install nepi-link dependencies
    sudo apt install socat protobuf-compiler
    pip install virtualenv


    # Disable NetworkManager (for next boot)... causes issues with NEPI IP addr. management
    sudo systemctl disable NetworkManager




    #################################
    # Install Required Software
    #################################


    # Install and setup supervisor\\
    #https://www.digitalocean.com/community/tutorials/how-to-install-and-manage-supervisor-on-ubuntu-and-debian-vps
    #https://test-dockerrr.readthedocs.io/en/latest/admin/using_supervisord/

    sudo apt install supervisor

    #sudo supervisorctl status
    #sudo supervisorctl stop all

    ########
    # install license managers

    sudo apt-get install gnupg
    sudo apt-get install kgpg


    # install ssh server
    sudo apt-get install -y openssh-server
    sudo systemctl sshd

    # Install and configure chrony
    echo "Installing chrony for NTP services"
    sudo apt install chrony
    sudo systemctl enable --now chrony.service
    systemctl enable chronyd
    systemctl start chronyd



    # Install static IP tools
    echo "Installing static IP dependencies"
    sudo apt install ifupdown net-tools







fi


#############################
## Configure NEPI Environment
NEPI_ETC_SOURCE=./resources/etc
NEPI_ALIASES_SOURCE=./resources/aliases/.nepi_system_aliases 
NEPI_ALIASES=${NEPI_HOME}/.nepi_system_aliases


if [  $NEPI_ENV -o $SYS_DO_ALL ]; then

    echo ""
    echo "Setting up NEPI Environment"


    #####################################
    # Add nepi aliases to bashrc
    echo "Updating NEPI aliases file"

    BASHRC=~/.bashrc
    echo ""
    echo "Installing NEPI aliases file ${NEPI_ALIASES} "
    cp $NEPI_ALIASES_SOURCE $NEPI_ALIASES
    sudo chown -R ${USER}:${USER} $NEPI_ALIASES

    echo "Updating bashrc file"
    if grep -qnw $BASHRC -e "##### Source NEPI Aliases #####" ; then
        echo "Done"
    else
        echo "##### Source NEPI Aliases #####" | sudo tee -a $BASHRC
        echo "if [ -f ~/.nepi_system_config ]" | sudo tee -a $BASHRC
        echo "    . ~/.nepi_system_config" | sudo tee -a $BASHRC
        echo "fi" | sudo tee -a $BASHRC
        echo "Done"
    fi


    echo " "
    echo "NEPI Bash Aliases Setup Complete"
    echo " "
    # Source nepi aliases before exit
    echo " "
    echo "Sourcing bashrc with new nepi_aliases"
    sleep 1 & source $BASHRC
    wait
    # Print out nepi aliases
    . ${NEPI_ALIASES} && nepi


    ###################################
    # Mod some system settings
    echo ""
    echo "Modifyging some system settings"

    # Fix gpu accessability
    #https://forums.developer.nvidia.com/t/nvrmmeminitnvmap-failed-with-permission-denied/270716/10
    sudo usermod -aG sudo,video,i2c nepi

    # Fix USB Vidoe Rate Issue
    sudo rmmod uvcvideo
    sudo sudo modprobe uvcvideo nodrop=1 timeout=5000 quirks=0x80


    # Create System Folders
    echo ""
    echo "Creating system folders"
    sudo mkdir -p ${NEPI_BASE}
    sudo mkdir -p ${NEPI_RUI}
    sudo mkdir -p ${NEPI_ENGINE}
    sudo mkdir -p ${NEPI_ETC}

    ###################
    # Copy Config Files
    echo ""
    echo "Populating System Folders"
    cp -R ${NEPI_ETC_SOURCE}/* ${NEPI_ETC}
    sudo chown -R ${USER}:${USER} $NEPI_ETC

    sudo cp -R ${NEPI_ETC}/etc ${NEPI_BASE}/
    sudo chown -R ${NEPI_USER}:${NEPI_USER} /opt/nepi


    # Set up the NEPI sys env bash file
    echo "Updating system env bash file"
    sudo cp ${NEPI_ETC}/sys_env.bash ${NEPI_BASE}/sys_env.bash
    sudo chmod +x ${NEPI_BASE}/sys_env.bash
    sudo cp ${NEPI_ETC}/sys_env.bash ${NEPI_BASE}/sys_env.bash.bak
    sudo chmod +x ${NEPI_BASE}/sys_env.bash.bak

    ###################
    # Set up the default hostname
    # Hostname Setup - the link target file may be updated by NEPI specialization scripts, but no link will need to move
    echo " "
    echo "Updating system hostname"
    sudo ln -sf ${NEPI_ETC}/hostname /etc/hostname

    ##############################################
    # Update the Desktop background image
    echo ""
    echo "Updating Desktop background image"
    gsettings set org.gnome.desktop.background picture-uri file:///${NEPI_ETC}/home/nepi/nepi_wallpaper.png

    # Update the login screen background image - handled by a sys. config file
    # No longer works as of Ubuntu 20.04 -- there are some Github scripts that could replace this -- change-gdb-background
    #echo "Updating login screen background image"
    #sudo cp ${NEPI_CONFIG}/usr/share/gnome-shell/theme/ubuntu.css ${NEPI_ETC}/ubuntu.css
    #sudo ln -sf ${NEPI_ETC}/ubuntu.css /usr/share/gnome-shell/theme/ubuntu.css


    #########################################
    # Setup system services
    echo ""
    echo "Setting up NEPI Services"

    sudo chmod +x ${NEPI_ETC}/services/*

    sudo ln -sf ${NEPI_ETC}/services/nepi_engine.service ${SYSTEMD_SERVICE_PATH}/nepi_engine.service
    sudo systemctl enable nepi_engine
    sudo ln -sf ${NEPI_ETC}/services/nepi_rui.service ${SYSTEMD_SERVICE_PATH}/nepi_rui.service
    sudo systemctl enable nepi_rui

    echo "NEPI Services Setup Complete"

    #########################################
    # Setup system scripts
    echo ""
    echo "Setting up NEPI Scripts"

    sudo chmod +x ${NEPI_ETC}/scripts/*
    sudo ln -sf ${NEPI_ETC}/scripts/nepi_start_all.sh /nepi_start_all.sh
    sudo ln -sf ${NEPI_ETC}/scripts/nepi_engine_start.sh /nepi_engine_start.sh
    sudo ln -sf ${NEPI_ETC}/scripts/nepi_rui_start.sh /nepi_rui_start.sh
    sudo ln -sf ${NEPI_ETC}/scripts/nepi_samba_start.sh /nepi_samba_start.sh
    sudo ln -sf ${NEPI_ETC}/scripts/nepi_storage_init.sh /nepi_storage_init.sh
    sudo ln -sf ${NEPI_ETC}/scripts/nepi_license_start.sh /nepi_license_start.sh

    echo "NEPI Script Setup Complete"

    ###########################################
    # Set up SSH
    echo " "
    echo "Configuring SSH Keys"

    sudo ln -sf ${NEPI_ETC}/ssh/sshd_config /etc/ssh/sshd_config
    # And link default public key - Make sure all ownership and permissions are as required by SSH
    sudo chown ${USER}:${USER} ${NEPI_ETC}/ssh/authorized_keys
    sudo chmod 0600 ${NEPI_ETC}/authorized_keys
    ln -sf ${NEPI_ETC}/ssh/authorized_keys /home/nepi/.ssh/authorized_keys
    sudo chown ${USER}:${USER} /home/nepi/.ssh/authorized_keys
    sudo chmod 0600 /home/nepi/.ssh/authorized_keys

    mkdir -p /home/nepi/.ssh
    sudo chown ${USER}:${USER} /home/nepi/.ssh
    chmod 0700 /home/nepi/.ssh




    ###########################################
    # Set up Samba
    echo "Configuring nepi storage Samba share drive"
    sudo ln -sf ${NEPI_ETC}/samba/smb.conf /etc/samba/smb.conf
    printf "nepi\nepi\n" | sudo smbpasswd -a nepi

    # Create the mountpoint for samba shares (now that sambashare group exists)
    #sudo chown -R nepi:sambashare ${NEPI_STORAGE}
    #sudo chmod -R 0775 ${NEPI_STORAGE}

    sudo chown -R ${USER}:${USER} ${NEPI_STORAGE}
    sudo chown nepi:sambashare ${NEPI_STORAGE}
    sudo chmod -R 0775 ${NEPI_STORAGE}


    #############################################
    # Set up some udev rules for plug-and-play hardware
    echo " "
    echo "Setting up udev rules"
      # IQR Pan/Tilt
    sudo ln -sf ${NEPI_ETC}/udev/rules.d/56-iqr-pan-tilt.rules /etc/udev/rules.d/56-iqr-pan-tilt.rules
      # USB Power Saving on Cameras Disabled
    sudo ln -sf ${NEPI_ETC}/udev/rules.d/92-usb-input-no-powersave.rules /etc/udev/rules.d/92-usb-input-no-powersave.rules




    #############################################
    # Setting up Baumer GenTL Producers (Genicam support)
    echo " "
    echo "Setting up Baumer GAPI SDK GenTL Producers"
    # Set up the shared object links in case they weren't copied properly when this repo was moved to target
    NEPI_BAUMER_PATH=${NEPI_CONFIG}/opt/baumer/gentl_producers
    ln -sf $NEPI_BAUMER_PATH/libbgapi2_usb.cti.2.14.1 $NEPI_BAUMER_PATH/libbgapi2_usb.cti.2.14
    ln -sf $NEPI_BAUMER_PATH/libbgapi2_usb.cti.2.14 $NEPI_BAUMER_PATH/libbgapi2_usb.cti
    ln -sf $NEPI_BAUMER_PATH/libbgapi2_gige.cti.2.14.1 $NEPI_BAUMER_PATH/libbgapi2_gige.cti.2.14
    ln -sf $NEPI_BAUMER_PATH/libbgapi2_gige.cti.2.14 $NEPI_BAUMER_PATH/libbgapi2_gige.cti

    sudo ln -sf ${NEPI_ETC}opt/baumer /opt/baumer
    sudo chown ${USER}:${USER} /opt/baumer



    # Disable apport to avoid crash reports on a display
    sudo systemctl disable apport


    # Set up static IP addr.

    sudo ln -sf ${NEPI_ETC}/network/interfaces.d /etc/network/interfaces.d

    sudo cp ${NEPI_ETC}/network/interfaces /etc/network/interfaces

    # Set up DHCP
    sudo ln -sf ${NEPI_ETC}/dhclient.conf /etc/dhcp/dhclient.conf
    sudo dhclient





    ##############
    # Install Manager File
    #sudo cp -R ${NEPI_CONFIG}/etc/license/nepi_check_license.py ${NEPI_ETC}/nepi_check_license.py
    sudo dos2unix ${NEPI_ETC}/license/nepi_check_license.py
    sudo ${NEPI_ETC}/license/setup_nepi_license.sh






fi






#################################
## System Config Options
#################################
INSTALL_CONTAINER=false
CONFIGURE_LAUNCH=false
CONFIGURE_FACTORY=false
CONFIGURE_SETTINGS=false

CF_SELECTION='Configure NEPI Settings'


if [ $NEPI_CONFIG_TOOLS]; then

    echo ""
    echo ""
    echo "Select the file system task, or select DO ALL to run all processes:"
    select yn in 'Install NEPI Container' 'Configure NEPI Launch' 'Configure System Factory' 'Configure NEPI Settings' ; do
        case $yn in
            Install NEPI Container ) INSTALL_CONTAINER=true;;
            Configure NEPI Launch) CONFIGURE_LAUNCH=true;;
            Configure System Factory) CONFIGURE_FACTORY=true;;
            Configure NEPI Settings) CONFIGURE_SETTINGS=true;;
        esac
        CF_SELECTION=${yn}
    done

    ## Check Selection
    echo ""
    echo ""
    echo "Confirm Selection: ${CF_SELECTION}"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) break;;
            No ) exit 1;;
        esac
    done
fi
