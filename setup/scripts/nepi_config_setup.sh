#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##


# This file installs the NEPI Engine File System installation

echo "########################"
echo "NEPI CONFIG SETUP"
echo "########################"


# # Load System Config File
# SCRIPT_FOLDER=$(pwd)
# cd $(dirname $(pwd))/config
# source load_system_config.sh
# if [ $? -eq 1 ]; then
#     echo "Failed to load ${SYSTEM_CONFIG_FILE}"
#     cd $SCRIPT_FOLDER
#     exit 1
# fi
# cd $SCRIPT_FOLDER

### Backup ETC folder if needed


### Backup ETC folder if needed
folder=/etc
org_path_backup $folder
### Backup USR LIB SYSTEMD  folder if needed
folder=/usr/lib/systemd/system
org_path_backup $folder
### Backup RUN SYSTEMD  folder if needed
folder=/run/systemd/system
org_path_backup $folder
### Backup USR LIB SYSTEMD USER  folder if needed
folder=/usr/lib/systemd/user
org_path_backup $folder


###################

CONFIG_USER=nepi

NEPI_SYSTEM_CONFIG_SOURCE=$(dirname "$(pwd)")/config/nepi_system_config.yaml
NEPI_SYSTEM_CONFIG_DEST_PATH=/opt/nepi/etc
NEPI_SYSTEM_CONFIG_DEST=${NEPI_SYSTEM_CONFIG_DEST_PATH}/nepi_system_config.yaml





if [ -f "$NEPI_SYSTEM_CONFIG_DEST" ]; then
    ## Check Selection
    echo ""
    echo ""
    echo "Do You Want to OverWrite System Config: ${OP_SELECTION}"
    select ovw in "View_Original" "View_New" "Yes" "No" "Quit"; do
        case $ovw in
            View_Original ) print_config_file $NEPI_SYSTEM_CONFIG_DEST;;
            View_New )  print_config_file $NEPI_SYSTEM_CONFIG_SOURCE;;
            Yes ) OVERWRITE=1; break;;
            No ) OVERWRITE=0; break;;
            Quit ) exit 1
        esac
    done


    if [ "$OVERWRITE" -eq 1 ]; then
    echo "Updating NEPI CONFIG ${NEPI_SYSTEM_CONFIG_DEST} "
    sudo cp ${NEPI_SYSTEM_CONFIG_SOURCE} ${NEPI_SYSTEM_CONFIG_DEST}
    fi

else
    sudo mkdir -p $NEPI_SYSTEM_CONFIG_DEST_PATH
    sudo cp ${NEPI_SYSTEM_CONFIG_SOURCE} ${NEPI_SYSTEM_CONFIG_DEST}

fi

echo "Refreshing NEPI CONFIG from ${NEPI_SYSTEM_CONFIG_DEST} "
load_config_file ${NEPI_SYSTEM_CONFIG_DEST}

#################################
# Create Nepi Required Folders
echo "Checking NEPI Required Folders"
rfolder=$NEPI_BASE
if [ ! -d "$rfolder" ]; then
    echo "Creating NEPI Folder: ${rfolder}"
    sudo mkdir -p $rfolder
    sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $rfolder
fi
rfolder=$NEPI_STORAGE
if [ ! -d "$rfolder" ]; then
    echo "Creating NEPI Folder: ${rfolder}"
    sudo mkdir -p $rfolder
    sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $rfolder
fi

# Ensure required config folder is setup
if [ ! -d "/mnt/nepi_config" ]; then
    sudo mkdir -p ${NEPI_STORAGE}/nepi_config
    sudo ln -sf ${NEPI_STORAGE}/nepi_config /mnt/nepi_config
fi

rfolder=${NEPI_CONFIG}/docker_cfg/etc
if [ ! -d "$rfolder" ]; then
    echo "Creating NEPI Folder: ${rfolder}"
    sudo mkdir -p $rfolder
    sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $rfolder
fi
rfolder=${NEPI_CONFIG}/factory_cfg/etc
if [ ! -d "$rfolder" ]; then
    echo "Creating NEPI Folder: ${rfolder}"
    sudo mkdir -p $rfolder
    sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $rfolder
fi
rfolder=${NEPI_CONFIG}/system_cfg/etc
if [ ! -d "$rfolder" ]; then
    echo "Creating NEPI Folder: ${rfolder}"
    sudo mkdir -p $rfolder
    sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $rfolder
fi
#################################

#####################################
# Copy Files to NEPI Docker Config Folder
####################################
NEPI_DOCKER_CONFIG=${NEPI_CONFIG}/docker_cfg
if [ -d "$NEPI_DOCKER_CONFIG" ]; then
    sudo mkdir -p $NEPI_DOCKER_CONFIG
fi
echo "Copying nepi  docker config files to ${NEPI_DOCKER_CONFIG}"
sudo cp $(dirname "$(pwd)")/resources/docker/* ${NEPI_DOCKER_CONFIG}/
sudo cp -R -p $(dirname "$(pwd)")/resources/etc ${NEPI_DOCKER_CONFIG}/

sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $NEPI_DOCKER_CONFIG

###################
# Copy Config Files
ETC_SOURCE_PATH=$(dirname "$(pwd)")/resources/etc
ETC_DEST_PATH=${NEPI_BASE}

echo ""
echo "Populating System ETC Folder from ${ETC_SOURCE_PATH} to ${ETC_DEST_PATH}"
sudo cp -R ${ETC_SOURCE_PATH} ${ETC_DEST_PATH}/
sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $ETC_DEST_PATH

###############
# RUN ETC UPDATE SCRIPT
cur_dir=$(pwd)
cd ${ETC_DEST_PATH}/etc
echo "Updating NEPI Config files in ${ETC_DEST_PATH}/etc"
source update_etc_files.sh
wait
cd $cur_dir



#############################################

# Update fstab
echo "Updating fstab"
if [ ! -f "/etc/fstab" ]; then
    sudo mv /etc/fstab /etc/fstab.bak
fi
sudo cp -a ${NEPI_ETC}/fstab /etc/fstab
sudo chown root:root /etc/fstab

    ###################################
    # SSH Setup
    CONFIG_USER=$USER
    NEPI_SSH_DIR=/home/${CONFIG_USER}/ssh_keys
    NEPI_SSH_FILE=nepi_engine_default_private_ssh_key

    # Add nepi ssh key if not there
    echo "Checking nepi ssh key file"
    NEPI_SSH_PATH=${NEPI_SSH_DIR}/${NEPI_SSH_FILE}
    NEPI_SSH_SOURCE=./resources/ssh_keys/${NEPI_SSH_FILE}
    if [ -e $NEPI_SSH_PATH ]; then
        echo "Found NEPI ssh private key ${NEPI_SSH_PATH} "
    else
        echo "Installing NEPI ssh private key ${NEPI_SSH_PATH} "
        mkdir $NEPI_SSH_DIR
        cp $NEPI_SSH_SOURCE $NEPI_SSH_PATH
    fi
    sudo chmod 600 $NEPI_SSH_PATH
    sudo chmod 700 $NEPI_SSH_DIR
    sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $NEPI_SSH_DIR

    #########################################
    # Update ETC HOSTS File
    file=/etc/hosts
    org_path_backup $file

    if [ ! -f "$file" ]; then
        sudo rm $file
    fi
    sudo ln -sf ${NEPI_ETC}/hostname $file

    entry="${NEPI_IP} ${NEPI_USER}"
    echo "Updating NEPI IP in ${file}"
    if grep -qnw $file -e ${entry}; then
        echo "Found NEPI IP in ${file} ${entry} "
    else
        echo "Adding NEPI IP in ${file}"
        echo $entry | sudo tee -a $file
        echo "${entry}-${NEPI_DEVICE_ID}" | sudo tee -a $file
    fi

    entry="${NEPI_IP} ${NEPI_ADMIN_USER}"
    echo "Updating NEPI IP in ${file}"
    if grep -qnw $file -e ${entry}; then
        echo "Found NEPI IP in ${file} ${entry} "
    else
        echo "Adding NEPI IP in ${file}"
        echo $entry | sudo tee -a $file
        echo "${entry}-${NEPI_DEVICE_ID}" | sudo tee -a $file
    fi

    entry="${NEPI_IP} ${NEPI_HOST_USER}"
    echo "Updating NEPI IP in ${file}"
    if grep -qnw $file -e ${entry}; then
        echo "Found NEPI IP in ${file} ${entry} "
    else
        echo "Adding NEPI IP in ${file}"
        echo $entry | sudo tee -a $file
        echo "${entry}-${NEPI_DEVICE_ID}" | sudo tee -a $file
    fi

    ######################
    # Update ETC HOSTNAME File
    file=/etc/hostname
    org_path_backup $file

    if [ ! -f "$file" ]; then
        sudo rm $file
    fi
    sudo ln -sf ${NEPI_ETC}/hostname $file
    
    entry="${NEPI_DEVICE_ID}"
    echo "Updating NEPI IP in ${file}"
    if grep -qnw $file -e ${entry}; then
        echo "Found NEPI IP in ${file} ${entry} "
    else
        echo "Adding NEPI IP in ${file}"
        echo $entry | sudo tee -a $file
        echo "${entry}-${NEPI_DEVICE_ID}" | sudo tee -a $file
    fi

    echo "Restarting hostnamed service"
    sudo systemctl restart systemd-hostnamed

    ###########################################
    # Network Setup 

    echo "Updating Network Config"

    sudo systemctl disable NetworkManager
    sudo systemctl stop NetworkManager


    # Set up static IP addr.
    echo "Updating Network interfaces.d"
    if [ ! -f "/etc/network/interfaces.d" ]; then
        #sudo cp -a -r /etc/network/interfaces.d /etc/network/interfaces.d.bak
        sudo rm -r /etc/network/interfaces.d
    fi
    sudo ln -sf ${NEPI_ETC}/network/interfaces.d /etc/network/interfaces.d

    echo "Updating Network interfaces"
    if [ ! -f "/etc/network/interfaces" ]; then
        #sudo cp -a -r /etc/network/interfaces /etc/network/interfaces.bak
        sudo rm /etc/network/interfaces
    fi
    sudo cp ${NEPI_ETC}/network/interfaces /etc/network/interfaces

    # Set up DHCP
    echo "Updating Network dhclient.conf"
    if [ ! -f "/etc/dhcp/dhclient.conf" ]; then
        #sudo cp -a -r /etc/dhcp/dhclient.conf /etc/dhcp/dhclient.conf.bak
        sudo rm /etc/dhcp/dhclient.conf
    fi
    sudo ln -sf ${NEPI_ETC}/dhcp/dhclient.conf /etc/dhcp/dhclient.conf


    # Set up WIFI
    echo "Updating Network wpa_supplicant.conf"
    if [ ! -d "/etc/wpa_supplicant" ]; then
        sudo mkdir /etc/wpa_supplicant
    fi
    if [ -f "/etc/wpa_supplicant/wpa_supplicant.conf" ]; then
        sudo cp -a -r /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf.bak
    fi
    sudo ln -sf ${NEPI_ETC}/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
  
  

    ###########################################
    # Set up SSH
    echo " "
    echo "Configuring SSH Keys"

    # And link default public key - Make sure all ownership and permissions are as required by SSH
    sudo chown ${NEPI_USER}:${NEPI_USER} ${NEPI_ETC}/ssh/authorized_keys
    sudo chmod 0600 ${NEPI_ETC}/ssh/authorized_keys


    sudo rm ${NEPI_HOME}/.ssh/authorized_keys
    sudo cp ${NEPI_ETC}/ssh/authorized_keys ${NEPI_HOME}/.ssh/authorized_keys
    sudo chown ${NEPI_USER}:${NEPI_USER} ${NEPI_HOME}/.ssh/authorized_keys
    sudo chmod 0600 ${NEPI_HOME}/.ssh/authorized_keys

    sudo chmod 0700 ${NEPI_HOME}.ssh
    sudo chown -R ${NEPI_USER}:${NEPI_USER} ${NEPI_HOME}.ssh

    if [ -d "$/home/${NEPI_ADMIN}/.ssh" ]; then
        sudo rm -r /home/${NEPI_ADMIN}/.ssh
    fi
    sudo cp -R -a /home/${NEPI_USER}/.ssh /home/${NEPI_ADMIN}/.ssh

    if [ -d "$/home/${NEPI_HOST}/.ssh" ]; then
        sudo rm -r /home/${NEPI_HOST}/.ssh
    fi
    sudo cp -R -a /home/${NEPI_USER}/.ssh /home/${NEPI_HOST}/.ssh


    if [ ! -f "/etc/ssh/sshd_config" ]; then
        sudo cp -a -r /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
        sudo rm -r /etc/ssh/sshd_config
    fi
    sudo ln -sf ${NEPI_ETC}/ssh/sshd_config /etc/ssh/sshd_config

    sudo systemctl enable sshd.service
    sudo systemctl restart sshd.service

    ###########################################
    # Set up Chrony
    echo " "
    echo "Configuring Chrony"
    if [ ! -f "/etc/fstab" ]; then
        sudo cp -a -r /etc/chrony/chrony.conf /etc/chrony/chrony.conf.bak
        sudo rm -r /etc/chrony/chrony.conf.bak
    fi 
    sudo ln -sf ${NEPI_ETC}/chrony/chrony.conf /etc/chrony/chrony.conf


    ###########################################
    # Set up Samba
    echo "Configuring nepi storage Samba share drive"
    if [ ! -f "/etc/samba/smb.conf" ]; then
        sudo cp -a -r /etc/samba/smb.conf /etc/samba/smb.conf.bak
        sudo rm -r /etc/samba/smb.conf
    fi
    sudo ln -sf ${NEPI_ETC}/samba/smb.conf /etc/samba/smb.conf

    sudo systemctl enable smbd
    sudo systemctl restart smbd

    
    #printf "nepi\nepi\n" | sudo smbpasswd -a nepi

    # Create the mountpoint for samba shares (now that sambashare group exists)
    #sudo chown -R nepi:sambashare ${NEPI_STORAGE}
    #sudo chmod -R 0775 ${NEPI_STORAGE}

    #sudo chown -R ${NEPI_USER}:${NEPI_USER} ${NEPI_STORAGE}
    #sudo chown nepi:sambashare ${NEPI_STORAGE}
    #sudo chmod -R 0775 ${NEPI_STORAGE}


    ##########################################


if [ "$NEPI_IN_CONTAINER" -eq 0 ]; then
    echo "Restarting NEPI Engine Services"

    sudo systemctl enable networking.service
    # sudo systemctl stop networking.service
    # sudo ip addr flush eth0 && 
 
    # sudo systemctl restart networking.service
    # sudo ifdown --force --verbose eth0
    # sudo ifup --force --verbose eth0
    sudo systemctl start networking.service

    sudo systemctl enable chrony
    sudo systemctl restart chrony

else

    #########################################
    # Setup supervisor
    echo ""
    echo "Setting up NEPI Supervisord"

    if [ -d "/etc/supervisor" ]; then
        if [ ! -f "/etc/supervisor/conf.d/supervisord_nepi.conf" ]; then
            sudo cp -a -r /etc/supervisor/conf.d/supervisord_nepi.conf /etc/supervisor/conf.d/supervisord_nepi.conf.bak
            sudo rm /etc/supervisor/conf.d/supervisord_nepi.conf
        fi
        sudo ln -sf ${NEPI_ETC}/supervisor/conf.d/supervisord_nepi.conf /etc/supervisor/conf.d/supervisord_nepi.conf 
    fi
    sudo systemctl enable supervisor.service
    sudo systemctl restart supervisor.service

    #########################################
    # Setup NEPI etc sync process
    sudo cp -r ${NEPI_ETC}/lsyncd /etc/
    sudo chown -R ${USER}:${USER} ${NEPI_ETC}/lsyncd

    lsyncd_file=/etc/lsyncd/lsyncd.conf
    etc_sync=${NEPI_BASE}/etc
    etc_dest=${NEPI_CONFIG}/docker_cfg/etc
    echo "" | sudo tee -a $lsyncd_file
    echo "sync {" | sudo tee -a $lsyncd_file
    echo "    default.rsync," | sudo tee -a $lsyncd_file
    echo '    source = "'${etc_sync}'/",' | sudo tee -a $lsyncd_file
    echo '    target = "'${etc_dest}'/",' | sudo tee -a $lsyncd_file
    echo "}" | sudo tee -a $lsyncd_file
    echo " " | sudo tee -a $lsyncd_file

    # Make sure lsyncd is only started manually by nepi_launch.sh script
    # sudo systemctl disable lsyncd

fi

    echo "NEPI Engine Service Setup Complete"


    ############################################
    # Install Modeprobe Conf
    echo " "
    echo "Configuring nepi_modprobe.conf"
    etc_path=modprobe.d/nepi_modprobe.conf
    if [ -f "/etc/${etc_path}" ]; then
        sudo cp -a -r /etc/${etc_path} /etc/${etc_path}.bak
    fi
    sudo ln -sf ${NEPI_ETC}/${etc_path} /etc/${etc_path}

    #############################################
    # Set up some udev rules for plug-and-play hardware
    echo " "
    echo "Setting up udev rules"
        # IQR Pan/Tilt
    sudo cp ${NEPI_ETC}/udev/rules.d/56-iqr-pan-tilt.rules /etc/udev/rules.d/56-iqr-pan-tilt.rules
        # USB Power Saving on Cameras Disabled
    sudo cp ${NEPI_ETC}/udev/rules.d/92-usb-input-no-powersave.rules /etc/udev/rules.d/92-usb-input-no-powersave.rules
    sudo cp ${NEPI_ETC}/udev/rules.d/100-microstrain.rules /etc/udev/rules.d/100-microstrain.rules

    ##############################################
    # Update the Desktop background image
    echo ""
    echo "Updating Desktop background image"
    # Update the login screen background image - handled by a sys. config file
    # No longer works as of Ubuntu 20.04 -- there are some Github scripts that could replace this -- change-gdb-background
    #echo "Updating login screen background image"
    #sudo cp ${NEPI_CONFIG}/usr/share/gnome-shell/theme/ubuntu.css ${NEPI_ETC}/ubuntu.css
    #sudo ln -sf ${NEPI_ETC}/ubuntu.css /usr/share/gnome-shell/theme/ubuntu.css
    gsettings set org.gnome.desktop.background picture-uri file:///${NEPI_ETC}/nepi/nepi_wallpaper.png

    ##################################################
    # Set up the NEPI sys env bash file
    echo "Updating system env bash file"
    sudo chmod +x ${NEPI_ETC}/sys_env.bash
    sudo cp -a ${NEPI_ETC}/sys_env.bash ${NEPI_ETC}/sys_env.bash.bak
    if [ ! -f "${NEPI_BASE}/sys_env.bash" ]; then
        sudo rm ${NEPI_BASE}/sys_env.bash
    fi
    sudo ln -sf ${NEPI_ETC}/sys_env.bash ${NEPI_BASE}/sys_env.bash
    if [ ! -f "${NEPI_BASE}/sys_env.bash.bak" ]; then
        sudo rm ${NEPI_BASE}/sys_env.bash.bak
    fi
    sudo ln -sf ${NEPI_ETC}/sys_env.bash.bak ${NEPI_BASE}/sys_env.bash.bak


    #########################################
    # Setup NEPI Engine services
    echo ""
    echo "Setting up NEPI Engine Service"

    sudo chmod +x ${NEPI_ETC}/services/*

    sudo cp ${NEPI_ETC}/services/nepi_engine.service ${SYSTEMD_SERVICE_PATH}/nepi_engine.service
    sudo systemctl enable nepi_engine

##############################################
echo "NEPI Config Setup Complete"
##############################################

