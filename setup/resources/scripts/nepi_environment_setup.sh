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

if [[ -v NEPI_HW ]]; then
    # NEPI Hardware Host Options: GENERIC,JETSON,RPI
    NEPI_HW=JETSON


    ###################################
    # System Setup Variables
    ##################################
    NEPI_IP=192.168.179.103
    NEPI_USER=nepi

    # NEPI PARTITIONS
    NEPI_DOCKER=/mnt/nepi_fs_a
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


    NEPI_ETC_SOURCE=./../etc
    NEPI_ALIASES_SOURCE=./../aliases/.nepi_system_aliases
    NEPI_ALIASES=${NEPI_HOME}/.nepi_system_aliases
    BASHRC=${NEPI_HOME}/.bashrc
fi


if [  $NEPI_ENV == true -o $SYS_DO_ALL == true ]; then

    echo ""
    echo "Setting up NEPI Environment"


    #####################################
    # Add nepi aliases to bashrc
    echo "Updating NEPI aliases file"

    BASHRC=~/.bashrc
    echo ""
    echo "Installing NEPI aliases file ${NEPI_ALIASES} "
    cp $NEPI_ALIASES_SOURCE $NEPI_ALIASES
    sudo chown -R ${NEPI_USER}:${NEPI_USER} $NEPI_ALIASES

    echo "Updating bashrc file"
    if grep -qnw $BASHRC -e "##### Source NEPI Aliases #####" ; then
        echo "Done"
    else
        echo " "
        echo "##### Source NEPI Aliases #####" | sudo tee -a $BASHRC
        echo "if [ -f ~/.nepi_system_config ]; then" | sudo tee -a $BASHRC
        echo "    . ~/.nepi_system_config" | sudo tee -a $BASHRC
        echo "fi" | sudo tee -a $BASHRC
        echo "Done"
    fi


    echo " "
    echo "NEPI Bash Aliases Setup Complete"
    echo " "



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
    sudo chown -R ${NEPI_USER}:${NEPI_USER} $NEPI_ETC



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

    if [ ! -f /etc/hosts ]; then
        sudo rm /etc/hosts
    fi
    sudo ln -sf ${NEPI_ETC}/hosts /etc/hosts

    if [ ! -f "/etc/hostname" ]; then
        sudo rm /etc/hostname
    fi
    sudo ln -sf ${NEPI_ETC}/hostname /etc/hostname


    ##############################################
    # Update the Desktop background image
    echo ""
    echo "Updating Desktop background image"
    gsettings set org.gnome.desktop.background picture-uri file:///${NEPI_ETC}/nepi/nepi_wallpaper.png

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

    sudo cp ${NEPI_ETC}/services/nepi_engine.service ${SYSTEMD_SERVICE_PATH}/nepi_engine.service
    sudo systemctl enable nepi_engine
    sudo cp ${NEPI_ETC}/services/nepi_rui.service ${SYSTEMD_SERVICE_PATH}/nepi_rui.service
    sudo systemctl enable nepi_rui

    echo "NEPI Services Setup Complete"

    
    ###########################################
    # Set up Chrony
    echo " "
    echo "Configuring Chrony"
    sudo ln -sf ${NEPI_ETC}/chrony/chrony.conf /etc/chrony/chrony.conf

    ###########################################
    # Set up SSH
    echo " "
    echo "Configuring SSH Keys"

    # And link default public key - Make sure all ownership and permissions are as required by SSH
    sudo chown ${NEPI_USER}:${NEPI_USER} ${NEPI_ETC}/ssh/authorized_keys
    sudo chmod 0600 ${NEPI_ETC}/ssh/authorized_keys



    sudo cp ${NEPI_ETC}/ssh/authorized_keys ${NEPI_HOME}/.ssh/authorized_keys
    sudo chown ${NEPI_USER}:${NEPI_USER} ${NEPI_HOME}/.ssh/authorized_keys
    sudo chmod 0600 ${NEPI_HOME}/.ssh/authorized_keys

    sudo chmod 0700 ${NEPI_HOME}.ssh
    sudo chown -R ${NEPI_USER}:${NEPI_USER} ${NEPI_HOME}.ssh

    if [ ! -f "/etc/ssh/sshd_config" ]; then
        sudo rm -r /etc/ssh/sshd_config
    fi
    sudo ln -sf ${NEPI_ETC}/ssh/sshd_config /etc/ssh/sshd_config


    ###########################################
    # Set up Samba
    echo "Configuring nepi storage Samba share drive"
    if [ ! -f "/etc/samba/smb.conf" ]; then
        sudo rm -r /etc/samba/smb.conf
    fi
    sudo ln -sf ${NEPI_ETC}/samba/smb.conf /etc/samba/smb.conf
    #printf "nepi\nepi\n" | sudo smbpasswd -a nepi

    # Create the mountpoint for samba shares (now that sambashare group exists)
    #sudo chown -R nepi:sambashare ${NEPI_STORAGE}
    #sudo chmod -R 0775 ${NEPI_STORAGE}

    #sudo chown -R ${NEPI_USER}:${NEPI_USER} ${NEPI_STORAGE}
    #sudo chown nepi:sambashare ${NEPI_STORAGE}
    #sudo chmod -R 0775 ${NEPI_STORAGE}


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


    if [ ! -f "/opt/baumer" ]; then
        sudo rm -r /opt/baumer
    fi
    sudo ln -sf ${NEPI_ETC}opt/baumer /opt/baumer
    sudo chown ${NEPI_USER}:${NEPI_USER} /opt/baumer

    # Disable apport to avoid crash reports on a display
    sudo systemctl disable apport


    # Set up static IP addr.
    if [ ! -f "/etc/network/interfaces.d" ]; then
        sudo rm -r /etc/network/interfaces.d
    fi
    sudo ln -sf ${NEPI_ETC}/network/interfaces.d /etc/network/interfaces.d


    if [ ! -f "/etc/network/interfaces" ]; then
        sudo rm /etc/network/interfaces
    fi
    sudo cp ${NEPI_ETC}/network/interfaces /etc/network/interfaces

    # Set up DHCP
    if [ ! -f "/etc/dhcp/dhclient.conf" ]; then
        sudo rm /etc/dhcp/dhclient.conf
    fi
    sudo ln -sf ${NEPI_ETC}/dhclient.conf /etc/dhcp/dhclient.conf
    sudo dhclient

    # Set up WIFI
    if [ ! -f "/etc/wpa_supplicant/wpa_supplicant.conf" ]; then
        sudo rm /etc/wpa_supplicant/wpa_supplicant.conf
    fi
    sudo ln -sf ${NEPI_ETC}/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
    sudo dhclient




    ##############
    # Install Manager File
    #sudo cp -R ${NEPI_CONFIG}/etc/license/nepi_check_license.py ${NEPI_ETC}/nepi_check_license.py
    sudo dos2unix ${NEPI_ETC}/license/nepi_check_license.py
    sudo chmod +x ${NEPI_ETC}/license/nepi_check_license_start.py
    sudo chmod +x ${NEPI_ETC}/license/nepi_check_license.py
    sudo ln -sf ${NEPI_ETC}/license/nepi_check_license.service /etc/systemd/system/
    sudo gpg --import ${NEPI_ETC}/license/nepi_license_management_public_key.gpg
    sudo systemctl enable nepi_check_license
    #gpg --import /opt/nepi/config/etc/nepi/nepi_license_management_public_key.gpg


    ################################
    # Update fstab
    sudo cp -sf ${NEPI_ETC}/fstabs/fstab_emmc ${NEPI_ETC}/fstabs/fstab
    sudo ln -sf ${NEPI_ETC}/fstabs/fstab /etc/fstab
    sudo cp ${NEPI_ETC}/fstabs/fstab /etc/fstab.bak
    
    #########################################
    # Setup system scripts
    echo ""
    echo "Setting up NEPI Supervisord and Scripts"
    
    if [ ! -f "/etc/supervisor/conf.d/supervisord_nepi.conf" ]; then
        sudo rm /etc/supervisor/conf.d/supervisord_nepi.conf
    fi
    sudo ln -sf ${NEPI_ETC}/supervisord/conf.d/supervisord_nepi.conf /etc/supervisor/conf.d/supervisord_nepi.conf 

    sudo chmod +x ${NEPI_ETC}/scripts/*
    sudo ln -sf ${NEPI_ETC}/scripts/nepi_start_all.sh /nepi_start_all.sh
    sudo ln -sf ${NEPI_ETC}/scripts/nepi_engine_start.sh /nepi_engine_start.sh
    sudo ln -sf ${NEPI_ETC}/scripts/nepi_rui_start.sh /nepi_rui_start.sh
    sudo ln -sf ${NEPI_ETC}/scripts/nepi_samba_start.sh /nepi_samba_start.sh
    sudo ln -sf ${NEPI_ETC}/scripts/nepi_storage_init.sh /nepi_storage_init.sh
    sudo ln -sf ${NEPI_ETC}/scripts/nepi_license_start.sh /nepi_license_start.sh


    #########
    #- add Gieode databases to FileSystem
    
    #egm2008-2_5.pgm  egm2008-2_5.pgm.aux.xml  egm2008-2_5.wld  egm96-15.pgm  egm96-15.pgm.aux.xml  egm96-15.wld
    #from
    #https://www.3dflow.net/geoids/
    #to
    #/opt/nepi/databases/geoids
    #:'


    echo "NEPI Script Setup Complete"

    # Source nepi aliases before exit
    echo " "
    echo "Sourcing bashrc with new nepi_aliases"
    sleep 1 & source $BASHRC
    wait
    # Print out nepi aliases
    . ${NEPI_ALIASES} && nepi



fi


