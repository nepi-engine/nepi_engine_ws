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


if [[ "$NEPI_MANAGES_ETC" -eq 1 ]]; then
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

rfolder=${NEPI_CONFIG}/docker_cfg/etc
if [ ! -f "$rfolder" ]; then
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
ETC_DEST_PATH=${NEPI_CONFIG}/docker_cfg

echo ""
echo "Populating System ETC Folder from ${ETC_SOURCE_PATH} to ${ETC_DEST_PATH}"
sudo cp -R ${ETC_SOURCE_PATH} ${ETC_DEST_PATH}/
sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $ETC_DEST_PATH

###############
# RUN ETC UPDATE SCRIPT
cur_dir=$(pwd)
cd ${ETC_DEST_PATH}/etc
ls
echo "Updating NEPI Config files in ${ETC_DEST_PATH}/etc"
source update_etc_files.sh
wait
cd $cur_dir


#######################################
### Setup NEPI Docker Service
if [[ "$NEPI_MANAGES_ETC" -eq 1 ]]; then
    ##################################
    # Setting Up NEPI Managed Services on Host


    echo "Setting Up NEPI Managed Serices"
    etc_source=${NEPI_CONFIG}/docker_cfg/etc

    if [ "$NEPI_MANAGES_HOSTNAME" -eq 1 ]; then

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
    sudo cp -R -a ${NEPI_ETC}/hostname $file

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
    sudo cp -R -a ${NEPI_ETC}/hostname $file
    
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
    fi

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
            sudo mkdir ${etc_source}/wpa_supplicant
        fi
        
        if [ -d "/etc/wpa_supplicant.bak" ]; then
            sudo cp -a -r /etc/wpa_supplicant /etc/wpa_supplicant.bak
        fi
        sudo cp -a -r ${etc_source}/wpa_supplicant /etc/


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
        sudo systemctl enable chrony
        sudo systemctl restart chrony
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
        sudo cp ${DOCKER_ETC_FOLDER}/ssh/sshd_config /etc/ssh/sshd_config
        ###

        # Unmask if needed  https://www.baeldung.com/linux/systemd-unmask-services
        service_name=sshd

        #service_file=$(sudo find /etc /usr/lib -name "${service_name}.service*")
        #if [[ "$service_file" != "" ]]; then
        #    sudo systemctl unmask ${service_name}
        #    sudo rm ${service_file}
        #    sudo systemctl daemon-reload
        #fi
        sudo systemctl status ${service_name}
        sudo systemctl enable ${service_name}
        sudo systemctl restart ${service_name}
        sudo systemctl status ${service_name}
    fi


    # Setup NEPI ETC to OS Host ETC Link Service
    echo "Setting Up NEPI ETC Sycn service"
    sudo cp -r ${etc_source}/lsyncd /etc/
    sudo chown -R ${CONFIG_USER}:${CONFIG_USER} ${etc_source}/lsyncd


    #sudo systemctl enable lsyncd
    #sudo systemctl restart lsyncd

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
sudo cp ${DOCKER_ETC_FOLDER}/udev/rules.d/56-iqr-pan-tilt.rules /etc/udev/rules.d/56-iqr-pan-tilt.rules
    # USB Power Saving on Cameras Disabled
sudo cp ${DOCKER_ETC_FOLDER}/udev/rules.d/92-usb-input-no-powersave.rules /etc/udev/rules.d/92-usb-input-no-powersave.rules
sudo cp ${DOCKER_ETC_FOLDER}/udev/rules.d/100-microstrain.rules /etc/udev/rules.d/100-microstrain.rules


echo "Setting Up NEPI Docker Service"
sudo cp ${NEPI_DOCKER_CONFIG}/nepi_docker.service /etc/systemd/system/nepi_docker.service

ENABLE_NEPI
echo "Would You Like to Enable NEPI Docker Service on startup?"
while true; do
    read -p "$1 [Y/n]: " yn
    case $yn in
        [Yy]* ) ENABLE_NEPI=1; break;; # User entered 'y' or 'Y', return success (0)
        [Nn]* ) ENABLE_NEPI=0; break;; # User entered 'n' or 'N', return failure (1)
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




if [[ "$NEPI_MANAGES_ETC" -eq 1 ]]; then
    ########################
    # Create and link NEPI ETC folder
    folder=/etc
    create_nepi_path_link $folder

    # Create and link NEPI USR LIB SYSTEMD folder
    folder=/usr/lib/systemd/system
    create_nepi_path_link $folder

    # Create and link NEPI RUN SYSTEMD SYSfolder
    folder=/run/systemd/system
    create_nepi_path_link $folder

    # Create and link USR SYSTEMD USER folder
    folder=/usr/lib/systemd/user
    create_nepi_path_link $folder
fi





##################################
sudo chown -R ${CONFIG_USER}:${CONFIG_USER} ${NEPI_DOCKER_CONFIG}
echo ""
echo 'NEPI Docker Config Setup Complete'
##################################

