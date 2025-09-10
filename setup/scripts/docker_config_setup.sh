#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##


# This file initializes the nepi_docker_config.yaml file

echo "########################"
echo "NEPI DOCKER CONFFIG SETUP"
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
if [ ! -d "/etc.bak" ]; then
    echo "Backing Up ETC folder to /etc.bak"
    sudo cp -R /etc /etc.bak
fi
#############################################

CONFIG_USER=$USER

NEPI_SYSTEM_CONFIG_SOURCE=$(dirname "$(pwd)")/config/nepi_system_config.yaml
NEPI_SYSTEM_CONFIG_DEST_PATH=/mnt/nepi_config/docker_cfg/etc
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
if [ ! -f "$rfolder" ]; then
    echo "Creating NEPI Folder: ${rfolder}"
    sudo mkdir -p $rfolder
    sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $rfolder
fi
rfolder=$NEPI_STORAGE
if [ ! -f "$rfolder" ]; then
    echo "Creating NEPI Folder: ${rfolder}"
    sudo mkdir -p $rfolder
    sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $rfolder
fi

rfolder=${NEPI_CONFIG}/docker_cfg/etc
if [ ! -f "$rfolder" ]; then
    echo "Creating NEPI Folder: ${rfolder}"
    sudo mkdir -p $rfolder
    sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $rfolder
fi
rfolder=${NEPI_CONFIG}/factory_cfg/etc
if [ ! -f "$rfolder" ]; then
    echo "Creating NEPI Folder: ${rfolder}"
    sudo mkdir -p $rfolder
    sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $rfolder
fi
rfolder=${NEPI_CONFIG}/system_cfg/etc
if [ ! -f "$rfolder" ]; then
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
ETC_DEST_PATH=${NEPI_CONFIG}/docker_cfg

echo ""
echo "Populating System ETC Folder from ${ETC_SOURCE_PATH} to ${ETC_DEST_PATH}"
sudo cp -R ${ETC_SOURCE_PATH} ${ETC_DEST_PATH}/
sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $ETC_DEST_PATH

###############
# RUN ETC UPDATE SCRIPT
cur_dir=$(pwd)
cd ${ETC_DEST_PATH}/etc
echo "Updating NEPI Config files in ${ETC_DEST_PATH}/etc"
source $(pwd)/update_etc_files.sh
wait
cd $cur_dir


#######################################
### Setup NEPI Docker Service
echo "Setting Up NEPI Docker Service"
sudo cp ${NEPI_DOCKER_CONFIG}/nepi_docker.service /etc/systemd/system/nepi_docker.service

ENABLE_NEPI
echo "Would You Like to Enable NEPI Docker Service on startup?"
while true; do
    read -p "$1 [Y/n]: " yn
    case $yn in
        [Yy]* ) ENABLE_NEPI=1;; # User entered 'y' or 'Y', return success (0)
        [Nn]* ) ENABLE_NEPI=0;; # User entered 'n' or 'N', return failure (1)
        * ) echo "Please answer yes or no.";; # Invalid input, prompt again
    esac
done

if [[ "$ENABLE_NEPI" -eq 1 ]]; then
    sudo systemctl enable nepi_docker
    echo "NEPI Docker Service enabled on startup"
else
    echo "NEPI Docker Service disabled on startup"
    echo "You can manually enable/disable nepi_docker service with nepienable/nepidisable"
fi

#sudo systemctl enable lsyncd
#sudo systemctl restart lsyncd


##################################
# Setting Up NEPI Managed Services on Host

echo "Setting Up NEPI Managed Serices"
etc_source=${NEPI_CONFIG}/docker_cfg/etc

#etc_sync=${NEPI_CONFIG}/docker_cfg/etc/docker/etc


# Setup NEPI ETC to OS Host ETC Link Service
sudo cp -r ${etc_source}/lsyncd /etc/
sudo chown -R ${CONFIG_USER}:${CONFIG_USER} ${etc_source}/lsyncd

### Update hosts file
if [ ! -f "/etc/hosts.bak" ]; then
    sudo cp -a /etc/hosts /etc/hosts.bak
fi
sudo copy ${etc_source}/hosts ${etc_dest}/

### Update hostname file
if [ ! -f "/etc/hostname.bak" ]; then
    sudo cp -a /etc/hostname /etc/hostname.bak
fi
sudo copy ${etc_source}/hostname ${etc_dest}/


if [ "$NEPI_MANAGES_NETWORK" -eq 1 ]; then

    #sudo systemctl stop NetworkManager
    #sudo systemctl stop networking.service

    
    # Set up static IP addr.
    echo "Updating Network interfaces.d"
    if [ -d "/etc/network/interfaces.d" -a ! -d "/etc/network/interfaces.d.bak" ]; then
        sudo cp -a -r /etc/network/interfaces.d /etc/network/interfaces.d.bak
    fi
    sudo cp -a -r ${etc_source}/network/interfaces.d /etc/network/

    echo "Updating Network interfaces"
    if [ -f "/etc/network/interfaces" -a ! -f "/etc/network/interfaces.bak" ]; then
        sudo cp -a -r /etc/network/interfaces /etc/network/interfaces.bak
    fi
    sudo cp -a -r ${etc_source}/network/interfaces /etc/network/interfaces

    # Set up DHCP
    echo "Updating Network dhclient.conf"
    if [ -f "/etc/dhcp/dhclient.conf" -a ! -f "/etc/dhcp/dhclient.conf.bak" ]; then
        sudo cp -a -r /etc/dhcp/dhclient.conf /etc/dhcp/dhclient.conf.bak
    fi
    sudo cp -a -r ${etc_source}/dhcp/dhclient.conf /etc/dhcp/dhclient.conf

    # Set up WIFI
    if [ ! -d "etc/wpa_supplicant" ]; then
        sudo mkdir ${etc_sync}/wpa_supplicant
    fi
    
    if [ -d "/etc/wpa_supplicant.bak" ]; then
        sudo cp -a -r /etc/wpa_supplicant /etc/wpa_supplicant.bak
    fi
    sudo cp -a -r ${etc_source}/wpa_supplicant /etc/


    #sudo systemctl start NetworkManager
    #sudo systemctl stop networking.service
    #nmcli n on
    # # RESTART NETWORK
    # #sudo ip addr flush eth0 && 
    # sudo systemctl enable -now networking.service
    # sudo ifdown --force --verbose eth0
    # sudo ifup --force --verbose eth0

    # # Remove and restart dhclient
    # sudo dhclient -r
    # sudo dhclient
    # sudo dhclient -nw
    # #ps aux | grep dhcp

    
fi

###########################################
if [ "$NEPI_MANAGES_TIME" -eq 1 ]; then
    
    # Install NTP Sources
    echo " "
    echo "Configuring chrony.conf"
    etc_path=chrony/chrony.conf
    if [ -f "/etc/${etc_path}" ]; then
        sudo cp -a -r /etc/${etc_path} /etc/${etc_path}.bak
    fi
    sudo cp ${etc_source}/${etc_path} /etc/${etc_path}
    ###
    sudo timedatectl set-ntp false
    sudo systemctl enable chronyd
    sudo systemctl restart chronyd
fi



###########################################
if [ "$NEPI_MANAGES_SSH" -eq 1 ]; then
    # Set up SSH

    echo " "
    echo "Configuring SSH Keys"
    DOCKER_ETC_FOLDER=${NEPI_DOCKER_CONFIG}/etc
    # And link default public key - Make sure all ownership and permissions are as required by SSH
    sudo chown ${CONFIG_USER}:${CONFIG_USER} ${DOCKER_ETC_FOLDER}/ssh/authorized_keys
    sudo chmod 0600 ${DOCKER_ETC_FOLDER}/ssh/authorized_keys

    if [ -f "/home/${CONFIG_USER}/.ssh" ]; then
        sudo rm /home/${CONFIG_USER}/.ssh/authorized_keys
    fi
    sudo cp ${DOCKER_ETC_FOLDER}/ssh/authorized_keys /home/${CONFIG_USER}/.ssh/authorized_keys
    sudo chown ${CONFIG_USER}:${CONFIG_USER} /home/${CONFIG_USER}/.ssh/authorized_keys
    sudo chmod 0600 /home/${CONFIG_USER}/.ssh/authorized_keys

    sudo chmod 0700 /home/${CONFIG_USER}/.ssh
    sudo chown -R ${CONFIG_USER}:${CONFIG_USER} /home/${CONFIG_USER}/.ssh


    if [ ! -f "/etc/ssh/sshd_config" ]; then
        sudo cp -a -r /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
        sudo rm -r /etc/ssh/sshd_config
    fi
    sudo cp ${NEPI_ETC}/ssh/sshd_config /etc/ssh/sshd_config
    ###
    sudo systemctl enable sshd
    sudo systemctl restart sshd
fi



###########################################
# Install Modeprobe Conf
echo " "
echo "Configuring nepi_modprobe.conf"
etc_path=modprobe.d/nepi_modprobe.conf
if [ -f "/etc/${etc_path}" ]; then
    sudo cp -a -r /etc/${etc_path} /etc/${etc_path}.bak
fi
sudo cp ${etc_source}/${etc_path} /etc/${etc_path}

#############################################
# Set up some udev rules for plug-and-play hardware
echo " "
echo "Setting up udev rules"
    # IQR Pan/Tilt
sudo cp ${NEPI_ETC}/udev/rules.d/56-iqr-pan-tilt.rules /etc/udev/rules.d/56-iqr-pan-tilt.rules
    # USB Power Saving on Cameras Disabled
sudo cp ${NEPI_ETC}/udev/rules.d/92-usb-input-no-powersave.rules /etc/udev/rules.d/92-usb-input-no-powersave.rules
sudo cp ${NEPI_ETC}/udev/rules.d/100-microstrain.rules /etc/udev/rules.d/100-microstrain.rules






##################################
sudo chown -R ${CONFIG_USER}:${CONFIG_USER} ${NEPI_DOCKER_CONFIG}
echo ""
echo 'NEPI Docker Config Setup Complete'
##################################

