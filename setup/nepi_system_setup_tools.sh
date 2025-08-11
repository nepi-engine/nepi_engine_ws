#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##


# This file sets up NEPI File System on device hosting a nepi file system 
# or inside a docker container


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
NEPI_RUI=${NEPI_BASE}/nepi_rui
NEPI_CONFIG=${NEPI_BASE}/config
NEPI_ENGINE=${NEPI_BASE}/engine
NEPI_ETC=${NEPI_BASE}/etc

SYSTEMD_SERVICE_PATH=/etc/systemd/system

#################
# NEPI Storage Folders

declare -A STORAGE
STORAGE['data']=${NEPI_STORAGE}/data
STORAGE['ai_models']=${NEPI_STORAGE}/ai_models
STORAGE['ai_training']=${NEPI_STORAGE}/ai_training
STORAGE['automation_scripts']=${NEPI_STORAGE}/automation_scripts
STORAGE['databases']=${NEPI_STORAGE}/databases
STORAGE['install']=${NEPI_STORAGE}/install
STORAGE['nepi_src']=${NEPI_STORAGE}/nepi_src
STORAGE['nepi_full_img']=${NEPI_STORAGE}/nepi_full_img
STORAGE['nepi_full_img_archive']=${NEPI_STORAGE}/nepi_full_img_archive
STORAGE['sample_data']=${NEPI_STORAGE}/sample_data
STORAGE['user_cfg']=${NEPI_STORAGE}/user_cfg
STORAGE['tmp']=${NEPI_STORAGE}/tmp

STORAGE['nepi_cfg']=${NEPI_CONFIG}/nepi_cfg
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

fi


#############################
## Configure NEPI Environment
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
    sudo mkdir -p ${NEPI_CONFIG}
    sudo mkdir -p ${NEPI_ENGINE}
    sudo mkdir -p ${NEPI_ETC}

    ###################
    # Copy Config Files
    echo ""
    echo "Populating System Folders"
    cp -R ${NEPI_CONFIG_SOURCE}/* ${NEPI_CONFIG}
    sudo chown -R ${USER}:${USER} $NEPI_CONFIG

    sudo cp -R ${NEPI_CONFIG}/etc ${NEPI_BASE}/
    sudo cp -R ${NEPI_BASE}/etc ${NEPI_BASE}/etc.factory
    sudo chown -R ${NEPI_USER}:${NEPI_USER} /opt/nepi


    # Set up the NEPI sys env bash file
    echo "Updating system env bash file"
    sudo cp ${NEPI_CONFIG}/sys_env.bash ${NEPI_BASE}/sys_env.bash
    sudo chmod +x ${NEPI_BASE}/sys_env.bash
    sudo cp ${NEPI_CONFIG}/sys_env.bash ${NEPI_BASE}/sys_env.bash.bak
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

    sudo ln -sf ${NEPI_ETC}/sshd_config /etc/ssh/sshd_config
    # And link default public key - Make sure all ownership and permissions are as required by SSH
    sudo chown ${USER}:${USER} ${NEPI_ETC}/authorized_keys
    sudo chmod 0600 ${NEPI_ETC}/authorized_keys
    ln -sf ${NEPI_ETC}/authorized_keys /home/nepi/.ssh/authorized_keys
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
    sudo ln -sf ${NEPI_ETC}/56-iqr-pan-tilt.rules /etc/udev/rules.d/56-iqr-pan-tilt.rules
      # USB Power Saving on Cameras Disabled
    sudo ln -sf ${NEPI_ETC}/92-usb-input-no-powersave.rules /etc/udev/rules.d/92-usb-input-no-powersave.rules




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

    sudo cp -R ${NEPI_CONFIG}/opt/baumer ${NEPI_ETC}/baumer
    sudo ln -sf ${NEPI_ETC}/baumer /opt/baumer
    sudo chown ${USER}:${USER} /opt/baumer



    # Disable apport to avoid crash reports on a display
    sudo systemctl disable apport



    ##############
    # Install Manager File
    #sudo cp -R ${NEPI_CONFIG}/etc/license/nepi_check_license.py ${NEPI_ETC}/nepi_check_license.py
    sudo dos2unix ${NEPI_ETC}/license/nepi_check_license.py
    sudo ${NEPI_ETC}/license/setup_nepi_license.sh




    #################################
    # Install Required Software
    #################################


    # Install and setup supervisor\\
    #https://www.digitalocean.com/community/tutorials/how-to-install-and-manage-supervisor-on-ubuntu-and-debian-vps
    #https://test-dockerrr.readthedocs.io/en/latest/admin/using_supervisord/



    sudo supervisorctl status
    sudo supervisorctl stop all

    sudo apt update && sudo apt install supervisor
    sudo vi /etc/supervisor/conf.d/nepi.conf
    # Add these lines


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