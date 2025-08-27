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



#############################
## Configure NEPI Environment
NEPI_ETC_SOURCE=./resources/etc
NEPI_ALIASES_SOURCE=./resources/aliases/.nepi_system_aliases 
NEPI_ALIASES=${NEPI_HOME}/.nepi_system_aliases


if [ true ]; then

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

        
    sudo chown -R ${NEPI_USER}:${NEPI_USER} /opt/nepi/etc


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
    sudo ln -sf ${NEPI_ETC}/hostname/hostname /etc/hostname/hostname

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

    mkdir -p ${NEPI_HOME}/.ssh
    sudo chown ${USER}:${USER} ${NEPI_HOME}/.ssh
    chmod 0700 ${NEPI_HOME}/.ssh

    sudo ln -sf ${NEPI_ETC}/ssh/sshd_config /etc/ssh/sshd_config
    # And link default public key - Make sure all ownership and permissions are as required by SSH
    sudo chown ${USER}:${USER} ${NEPI_ETC}/ssh/authorized_keys
    sudo chmod 0600 ${NEPI_ETC}/ssh/authorized_keys
    ln -sf ${NEPI_ETC}/ssh/authorized_keys ${NEPI_HOME}/.ssh/authorized_keys


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



    '
    #############################################
    # Setting up Baumer GenTL Producers (Genicam support)
    echo " "
    echo "Setting up Baumer GAPI SDK GenTL Producers"
    # Set up the shared object links in case they werent copied properly when this repo was moved to target
    NEPI_BAUMER_PATH=/opt/baumer/gentl_producers
    ln -sf $NEPI_BAUMER_PATH/libbgapi2_usb.cti.2.14.1 $NEPI_BAUMER_PATH/libbgapi2_usb.cti.2.14
    ln -sf $NEPI_BAUMER_PATH/libbgapi2_usb.cti.2.14 $NEPI_BAUMER_PATH/libbgapi2_usb.cti
    ln -sf $NEPI_BAUMER_PATH/libbgapi2_gige.cti.2.14.1 $NEPI_BAUMER_PATH/libbgapi2_gige.cti.2.14
    ln -sf $NEPI_BAUMER_PATH/libbgapi2_gige.cti.2.14 $NEPI_BAUMER_PATH/libbgapi2_gige.cti




    # Disable apport to avoid crash reports on a display
    sudo systemctl disable apport
    '

    # Set up static IP addr.

    sudo ln -sf ${NEPI_ETC}/network/interfaces.d /etc/network/interfaces.d

    sudo cp ${NEPI_ETC}/network/interfaces /etc/network/interfaces

    # Set up DHCP
    sudo ln -sf ${NEPI_ETC}/dhcp/dhclient.conf /etc/dhcp/dhclient.conf
    sudo dhclient





    ##############
    # Install Manager File
    #sudo cp -R ${NEPI_CONFIG}/etc/license/nepi_check_license.py ${NEPI_ETC}/nepi_check_license.py
    sudo dos2unix ${NEPI_ETC}/license/nepi_check_license.py
    sudo ./${NEPI_ETC}/license/setup_nepi_license.sh



fi


