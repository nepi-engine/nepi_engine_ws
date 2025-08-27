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
NEPI_STORAGE_TOOLS=false
NEPI_DOCKER_TOOLS=false
NEPI_SOFTWARE_TOOLS=false
NEPI_CONFIG_Tools=false

NEPI_ETC_SOURCE=./resources/etc
NEPI_ALIASES_SOURCE=./resources/aliases/.nepi_system_aliases
NEPI_ALIASES=${NEPI_HOME}/.nepi_system_aliases
BASHRC=${NEPI_HOME}/.bashrc

if [ true ]; then
    echo ""
    echo "Setting up NEPI Environment"


    #####################################
    # Add nepi aliases to bashrc
    echo "Updating NEPI aliases file"


    echo ""
    echo "Installing NEPI aliases file ${NEPI_ALIASES} "
    cp $NEPI_ALIASES_SOURCE $NEPI_ALIASES
    sudo chown -R ${NEPI_USER}:${NEPI_USER} $NEPI_ALIASES

    echo "Updating bashrc file"
    if grep -qnw $BASHRC -e "##### Source NEPI Aliases #####" ; then
        echo "Done"
    else
    	echo "" | sudo tee -a $BASHRC
        echo "##### Source NEPI Aliases #####" | sudo tee -a $BASHRC
        echo "if [ -f ~/.nepi_system_aliases ]; then" | sudo tee -a $BASHRC
        echo "    . ~/.nepi_system_aliases" | sudo tee -a $BASHRC
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
    sudo chown -R ${NEPI_USER}:${NEPI_USER} ${NEPI_BASE}
    ###################
    # Copy Config Files
    echo ""
    echo "Populating System Folders"
    cp -R ${NEPI_ETC_SOURCE} ${NEPI_BASE}/
    sudo chown -R ${NEPI_USER}:${NEPI_USER} ${NEPI_ETC}
  


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
    sudo ln -sf ${NEPI_ETC}/hostname/hostsname /etc/hostname

    ##############################################
    # Update the Desktop background image
    echo ""
    echo "Updating Desktop background image"
    gsettings set org.gnome.desktop.background picture-uri file:///${NEPI_ETC}/nepi/nepi_wallpaper.png

    # Update the login screen background image - handled by a sys. config file
    # No longer works as of Ubuntu 20.04 -- there are some Github scripts that could replace this -- change-gdb-background
    #echo "Updating login screen background image"
    #sudo ln -sf ${NEPI_ETC}/usr/share/gnome-shell/theme/ubuntu.css /usr/share/gnome-shell/theme/ubuntu.css


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

    ###########################################
    # Set up SSH
    echo " "
    echo "Configuring SSH Keys"



    # And link default public key - Make sure all ownership and permissions are as required by SSH
    mkdir -p ${NEPI_HOME}/.ssh
    chmod 0700 /home/nepi/.ssh

    sudo cp ${NEPI_ETC}/ssh/authorized_keys ${NEPI_HOME}/.ssh/authorized_keys

    sudo chown -R ${NEPI_USER}:${NEPI_USER} ${NEPI_HOME}/.ssh
    sudo chown ${NEPI_USER}:${NEPI_USER} ${NEPI_HOME}/.ssh/authorized_keys
    sudo chmod 0600 ${NEPI_HOME}/.authorized_keys
    
    sudo ln -sf ${NEPI_ETC}/ssh/sshd_config /etc/ssh/sshd_config


    ################################
    # Set up Chrony
    sudo ln -sf ${NEPI_ETC}/chrony/chrony.conf /etc/chrony/chrony.conf



    ###########################################
    # Set up Samba
    echo "Configuring nepi storage Samba share drive"
    sudo ln -sf ${NEPI_ETC}/samba/smb.conf /etc/samba/smb.conf
    printf "nepi\nepi\n" | sudo smbpasswd -a nepi

    # Create the mountpoint for samba shares (now that sambashare group exists)
    #sudo chown -R nepi:sambashare ${NEPI_STORAGE}
    #sudo chmod -R 0775 ${NEPI_STORAGE}

    sudo chown -R ${NEPI_USER}:${NEPI_USER} ${NEPI_STORAGE}
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
    # Set up the shared object links in case they werent copied properly when this repo was moved to target
    sudo ln -sf ${NEPI_ETC}/opt/baumer /opt/baumer
    NEPI_BAUMER_PATH=${NEPI_ETC}/opt/baumer/gentl_producers
    sudo ln -sf $NEPI_BAUMER_PATH/libbgapi2_usb.cti.2.14.1 $NEPI_BAUMER_PATH/libbgapi2_usb.cti.2.14
    sudo ln -sf $NEPI_BAUMER_PATH/libbgapi2_usb.cti.2.14 $NEPI_BAUMER_PATH/libbgapi2_usb.cti
    sudo ln -sf $NEPI_BAUMER_PATH/libbgapi2_gige.cti.2.14.1 $NEPI_BAUMER_PATH/libbgapi2_gige.cti.2.14
    sudo ln -sf $NEPI_BAUMER_PATH/libbgapi2_gige.cti.2.14 $NEPI_BAUMER_PATH/libbgapi2_gige.cti




    # Disable apport to avoid crash reports on a display
    sudo systemctl disable apport


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
    sudo chmod +x ${NEPI_ETC}/license/nepi_check_license_start.py
    sudo chmod +x ${NEPI_ETC}/license/nepi_check_license.py
    sudo ln -sf ${NEPI_ETC}/license/nepi_check_license.service /etc/systemd/system/
    sudo gpg --import ${NEPI_ETC}/license/nepi_license_management_public_key.gpg
    sudo systemctl enable nepi_check_license
    #gpg --import /opt/nepi/config/etc/nepi/nepi_license_management_public_key.gpg


    ################################
    # Update fstab
    sudo ln -sf ${NEPI_ETC}/fstabs/fstab /etc/fstab
    sudo cp -p ${NEPI_ETC}/fstabs/fstab ${NEPI_ETC}/fstabs/fstab.bak
    sudo ln -sf ${NEPI_ETC}/fstabs/fstab /etc/fstab
    sudo ln -sf ${NEPI_ETC}/fstabs/fstab.bak /etc/fstab.bak
    
    #########################################
    # Setup system scripts
    echo ""
    echo "Setting up NEPI Supervisord and Scripts"
    
    
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
    :'
    egm2008-2_5.pgm  egm2008-2_5.pgm.aux.xml  egm2008-2_5.wld  egm96-15.pgm  egm96-15.pgm.aux.xml  egm96-15.wld
    from
    https://www.3dflow.net/geoids/
    to
    /opt/nepi/databases/geoids
    :'


    echo "NEPI Script Setup Complete"



fi


