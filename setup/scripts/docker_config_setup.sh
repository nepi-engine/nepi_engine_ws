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
echo "NEPI Docker Config Setup"
echo "########################"


CONFIG_SOURCE=$(dirname "$(pwd)")/nepi_system_config.yaml
source $(pwd)/load_system_config.sh
wait

if [ $? -eq 1 ]; then
    echo "Failed to load ${CONFIG_SOURCE}"
    exit 1
fi



#####################################
# Copy Files to NEPI Docker Config Folder
####################################
NEPI_DOCKER_CONFIG=${NEPI_CONFIG}/docker_cfg
if [ -d "$NEPI_DOCKER_CONFIG" ]; then
    sudo mkdir -p $NEPI_DOCKER_CONFIG
fi
echo "Copying nepi config files to ${NEPI_DOCKER_CONFIG}"
sudo cp $(dirname "$(pwd)")/resources/docker/* ${NEPI_DOCKER_CONFIG}/
sudo cp -r -p $(dirname "$(pwd)")/resources/etc ${NEPI_DOCKER_CONFIG}/

sudo chown -R ${USER}:${USER} $NEPI_DOCKER_CONFIG

###################
# Copy Config Files
SOURCE_PATH=$(dirname "$(pwd)")/resources/etc
DEST_PATH=${NEPI_CONFIG}/docker_cfg
CONFIG_USER=${USER}

echo ""
<<<<<<< HEAD
echo "Populating System Folders from ${SOURCE_PATH} to ${DEST_PATH}"
sudo cp -R ${SOURCE_PATH} ${DEST_PATH}/

=======
<<<<<<< HEAD
echo "Populating System Folders from ${SOURCE_PATH} to ${DEST_PATH}"
sudo cp -R ${SOURCE_PATH} ${DEST_PATH}/

=======
echo "Populating System Folders from ${SOURCE_PATH}"
sudo cp -R ${SOURCE_PATH} ${DEST_PATH}/
>>>>>>> ed6950b4b7f6c45d73a725821c158e0a852c103b
>>>>>>> ac1c03d57908885f2d6673a8ebba302e63aadfaa
sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $DEST_PATH

# Rsync etc folder from factory folder
sudo rsync -arh ${NEPI_CONFIG}/factory_cfg/etc ${NEPI_CONFIG}/docker_cfg/

# Rsync etc folder from system folder
# sudo rsync -arh ${NEPI_CONFIG}/system_cfg/etc ${NEPI_CONFIG}/docker_cfg/
<<<<<<< HEAD

# Update Deployed Config
=======
>>>>>>> ed6950b4b7f6c45d73a725821c158e0a852c103b

# Update Deployed Config

NEPI_CONFIG_SOURCE=${CONFIG_SOURCE}
echo $NEPI_CONFIG_SOURCE

NEPI_CONFIG_DEST_PATH=${NEPI_CONFIG}/docker_cfg/etc
NEPI_CONFIG_DEST=${NEPI_CONFIG_DEST_PATH}/nepi_system_config.yaml
echo $NEPI_CONFIG_DEST
if [ ! -d "${NEPI_CONFIG_DEST_PATH}" ]; then
    sudo mkdir -p ${NEPI_CONFIG_DEST_PATH}
fi
if [ ! -f "${NEPI_CONFIG_DEST}" ]; then
    sudo cp ${NEPI_CONFIG_SOURCE} ${NEPI_CONFIG_DEST}
fi

## Check Selection
echo ""
echo ""
echo "Do You Want to OverWrite System Config: ${OP_SELECTION}"
select ovw in "View_Original" "View_New" "Yes" "No" "Quit"; do
    case $ovw in
        View_Original ) print_config_file $NEPI_CONFIG_DEST;;
        View_New )  print_config_file $NEPI_CONFIG_SOURCE;;
        Yes ) OVERWRITE=1; break;;
        No ) OVERWRITE=0; break;;
        Quit ) exit 1
    esac
done


if [ "$OVERWRITE" -eq 1 ]; then
<<<<<<< HEAD
  echo "Updating NEPI CONFIG ${NEPI_CONFIG_DEST} "
  sudo cp ${NEPI_CONFIG_SOURCE} ${NEPI_CONFIG_DEST}
fi

echo $NEPI_CONFIG_DEST_PATH
=======
<<<<<<< HEAD
  echo "Updating NEPI CONFIG ${NEPI_CONFIG_DEST} "
=======
  echo "Installing NEPI CONFIG ${NEPI_CONFIG_DEST} "
>>>>>>> ed6950b4b7f6c45d73a725821c158e0a852c103b
  sudo cp ${NEPI_CONFIG_SOURCE} ${NEPI_CONFIG_DEST}
fi

<<<<<<< HEAD
echo $NEPI_CONFIG_DEST_PATH

sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $NEPI_CONFIG_DEST_PATH
export_config_file ${NEPI_CONFIG_DEST}

###############
# Update etc config files
NEPI_CFG_DEST=${DEST_PATH}/etc/nepi_system_config.yaml
=======
>>>>>>> ac1c03d57908885f2d6673a8ebba302e63aadfaa

sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $NEPI_CONFIG_DEST_PATH
export_config_file ${NEPI_CONFIG_DEST}
exit 1
###############
# Update etc config files
<<<<<<< HEAD
NEPI_CFG_DEST=${DEST_PATH}/etc/nepi_system_config.yaml
=======
NEPI_CFG_DEST=${DEST_PATH}/etc/nepi_config.yaml
>>>>>>> ed6950b4b7f6c45d73a725821c158e0a852c103b
>>>>>>> ac1c03d57908885f2d6673a8ebba302e63aadfaa
echo ""
echo "Updating NEPI Config file ${NEPI_CFG_DEST} from ${NEPI_CONFIG_DEST}"
cat /dev/null > ${NEPI_CFG_DEST}

while IFS= read -r line || [[ -n "$line" ]]; do
  #echo ${line}
  if [[ "$line" == "#"* ]]; then
    #echo "" >> $NEPI_CFG_DEST
    echo "${line}" >> $NEPI_CFG_DEST
  elif [[ "$line" == *"export"* ]]; then
    second_part="${line:7}"
    var_name=$(echo "$second_part" | cut -d "=" -f 1)
    var_value=$(eval "echo \$${var_name}")
    echo "${var_name}: ${var_value}"
    echo "${var_name}: ${var_value}" >> $NEPI_CFG_DEST
  fi
done < "$NEPI_CONFIG_DEST"

echo "Updating NEPI Config files in ${NEPI_CFG_DEST}"

source ${DEST_PATH}/etc/update_etc_files.sh
wait

<<<<<<< HEAD
=======
<<<<<<< HEAD
>>>>>>> ac1c03d57908885f2d6673a8ebba302e63aadfaa


# Create simlinks
NEPI_LOAD_SOURCE=${NEPI_CONFIG}/docker_cfg/etc/load_system_config.sh
NEPI_LOAD_DEST=${NEPI_CONFIG}/docker_cfg/load_system_config.sh

if [ -f "$NEPI_LOAD_DEST" ]; then
    sudo rm ${NEPI_LOAD_DEST}
fi
echo "Creating symlink from ${NEPI_LOAD_SOURCE} to ${NEPI_LOAD_DEST}"
sudo ln -sf ${NEPI_LOAD_SOURCE} ${NEPI_LOAD_DEST} 
###
NEPI_UPDATE_SOURCE=${NEPI_CONFIG}/docker_cfg/etc/update_etc_files.sh
NEPI_UPDATE_DEST=${NEPI_CONFIG}/docker_cfg/update_etc_files.sh

if [ -f "$NEPI_UPDATE_DEST" ]; then
    sudo rm ${NEPI_UPDATE_DEST}
fi
echo "Creating symlink from ${NEPI_UPDATE_SOURCE} to ${NEPI_UPDATE_DEST}"
sudo ln -sf ${NEPI_UPDATE_SOURCE} ${NEPI_UPDATE_DEST} 
###
NEPI_CFG_SOURCE=${NEPI_CONFIG}/docker_cfg/etc/nepi_system_config.yaml
NEPI_CFG_DEST=${NEPI_CONFIG}/docker_cfg/nepi_system_config.yaml
<<<<<<< HEAD
=======

if [ -f "$NEPI_CFG_DEST" ]; then
    sudo rm ${NEPI_CFG_DEST}
fi
echo "Creating NEPI symlink from ${NEPI_CFG_SOURCE} to ${NEPI_CFG_DEST}"
sudo ln -sf ${NEPI_CFG_SOURCE} ${NEPI_CFG_DEST} 

###
=======
# Create a simlink 
NEPI_CFG_SOURCE=${NEPI_CONFIG}/docker_cfg/etc/nepi_config.yaml
NEPI_CFG_DEST=${NEPI_CONFIG}/docker_cfg/nepi_config.yaml
>>>>>>> ac1c03d57908885f2d6673a8ebba302e63aadfaa

if [ -f "$NEPI_CFG_DEST" ]; then
    sudo rm ${NEPI_CFG_DEST}
fi
echo "Creating NEPI symlink from ${NEPI_CFG_SOURCE} to ${NEPI_CFG_DEST}"
sudo ln -sf ${NEPI_CFG_SOURCE} ${NEPI_CFG_DEST} 
<<<<<<< HEAD

###
=======
sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $NEPI_CFG_DEST
>>>>>>> ed6950b4b7f6c45d73a725821c158e0a852c103b
>>>>>>> ac1c03d57908885f2d6673a8ebba302e63aadfaa
sudo chown -R ${CONFIG_USER}:${CONFIG_USER} ${DEST_PATH}

echo "Updated NEPI Config file ${NEPI_CFG_DEST}"


#######################
# Update Factory Config

# Rsync etc folder from factory folder
sudo rsync -arh ${NEPI_CONFIG}/docker_cfg/etc  ${NEPI_CONFIG}/factory_cfg/

<<<<<<< HEAD
# Copy the nepi_system_config.yaml file to the factory_cfg folder
#source_config=${DEST_PATH}/etc/nepi_system_config.yaml
#dest_etc=${NEPI_CONFIG}/factory_cfg/etc
#dest_config=${dest_etc}/nepi_system_config.yaml
=======
<<<<<<< HEAD
# Copy the nepi_system_config.yaml file to the factory_cfg folder
#source_config=${DEST_PATH}/etc/nepi_system_config.yaml
#dest_etc=${NEPI_CONFIG}/factory_cfg/etc
#dest_config=${dest_etc}/nepi_system_config.yaml
=======
# Copy the nepi_config.yaml file to the factory_cfg folder
#source_config=${DEST_PATH}/etc/nepi_config.yaml
#dest_etc=${NEPI_CONFIG}/factory_cfg/etc
#dest_config=${dest_etc}/nepi_config.yaml
>>>>>>> ed6950b4b7f6c45d73a725821c158e0a852c103b
>>>>>>> ac1c03d57908885f2d6673a8ebba302e63aadfaa
#echo "Updating NEPI System Files in ${dest_config}"
#sudo mkdir -p ${dest_etc}
#sudo cp $source_config $dest_config
#sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $dest_etc

<<<<<<< HEAD
# Copy the nepi_system_config.yaml file to the system_cfg folder
#source_config=${DEST_PATH}/etc/nepi_system_config.yaml
#dest_etc=${NEPI_CONFIG}/system_cfg/etc
#dest_config=${dest_etc}/nepi_system_config.yaml
=======
<<<<<<< HEAD
# Copy the nepi_system_config.yaml file to the system_cfg folder
#source_config=${DEST_PATH}/etc/nepi_system_config.yaml
#dest_etc=${NEPI_CONFIG}/system_cfg/etc
#dest_config=${dest_etc}/nepi_system_config.yaml
=======
# Copy the nepi_config.yaml file to the system_cfg folder
#source_config=${DEST_PATH}/etc/nepi_config.yaml
#dest_etc=${NEPI_CONFIG}/system_cfg/etc
#dest_config=${dest_etc}/nepi_config.yaml
>>>>>>> ed6950b4b7f6c45d73a725821c158e0a852c103b
>>>>>>> ac1c03d57908885f2d6673a8ebba302e63aadfaa
#echo "Updating NEPI System Files in ${dest_config}"
#sudo mkdir -p ${dest_etc}
#sudo cp $source_config $dest_config
#sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $dest_etc



##################################
# Setting Up NEPI Docker Host Conf Files

echo "Setting up NEPI Docker Host services"
etc_source=${NEPI_CONFIG}/docker_cfg/etc

etc_dest=/etc
etc_sync=${NEPI_CONFIG}/docker_cfg/etc/docker/etc
lsyncd_file=${etc_dest}/lsyncd/lsyncd.conf

sudo rm -r ${NEPI_DOCKER_CONFIG}/etc/docker/etc/*
sudo chown -R ${USER}:${USER} ${NEPI_DOCKER_CONFIG}

sudo ln -sf ${etc_source}/hosts ${etc_sync}
if [ ! -f "/etc/hosts.bak" ]; then
    sudo cp -p /etc/hosts /etc/hosts.bak
fi

sudo ln -sf ${etc_source}/hostname ${etc_sync}
if [ ! -f "/etc/hostname.bak" ]; then
    sudo cp -p /etc/hostname /etc/hostname.bak
fi

if [ "$NEPI_MANAGES_NETWORK" -eq 1 ]; then

<<<<<<< HEAD
    sudo systemctl disable NetworkManager
    sudo systemctl stop NetworkManager
    sudo systemctl stop networking.service
=======
<<<<<<< HEAD
    sudo systemctl disable NetworkManager
    sudo systemctl stop NetworkManager
    sudo systemctl stop networking.service
=======
    #sudo systemctl stop NetworkManager
>>>>>>> ed6950b4b7f6c45d73a725821c158e0a852c103b
>>>>>>> ac1c03d57908885f2d6673a8ebba302e63aadfaa

    sudo ln -sf ${etc_source}/network/interfaces.d ${etc_sync}
    # Set up static IP addr.
    echo "Updating Network interfaces.d"
    if [ -d "/etc/network/interfaces.d" -a ! -d "/etc/network/interfaces.d.bak" ]; then
        sudo cp -p -r /etc/network/interfaces.d /etc/network/interfaces.d.bak
    fi
    sudo cp -p -r ${etc_source}/network/interfaces.d /etc/network/

    echo "Updating Network interfaces"
    if [ -f "/etc/network/interfaces" -a ! -f "/etc/network/interfaces.bak" ]; then
        sudo cp -p -r /etc/network/interfaces /etc/network/interfaces.bak
    fi
    sudo cp -p -r ${etc_source}/network/interfaces /etc/network/interfaces


    # Set up DHCP
    sudo ln -sf ${etc_source}/dhcp/dhclient.conf ${etc_sync}
    echo "Updating Network dhclient.conf"
    if [ -f "/etc/dhcp/dhclient.conf" -a ! -f "/etc/dhcp/dhclient.conf.bak" ]; then
        sudo cp -p -r /etc/dhcp/dhclient.conf /etc/dhcp/dhclient.conf.bak
    fi
    sudo cp -p -r ${etc_source}/dhcp/dhclient.conf /etc/dhcp/dhclient.conf

    # Set up WIFI
    if [ ! -d "etc/wpa_supplicant" ]; then
        sudo mkdir ${etc_sync}/wpa_supplicant
    fi
    sudo ln -sf ${etc_source}/wpa_supplicant ${etc_sync}/wpa_supplicant
    if [ -d "/etc/wpa_supplicant.bak" ]; then
        sudo cp -p -r /etc/wpa_supplicant /etc/wpa_supplicant.bak
    fi
    sudo cp -p -r ${etc_source}/wpa_supplicant /etc/

    # RESTART NETWORK
    sudo ip addr flush eth0 && sudo systemctl restart networking.service
    sudo ifdown --force --verbose eth0 && sudo ifup --force --verbose eth0

    # Remove and restart dhclient
    sudo dhclient -r
    sudo dhclient
    sudo dhclient -nw
    
fi

<<<<<<< HEAD




=======




>>>>>>> ac1c03d57908885f2d6673a8ebba302e63aadfaa
###########################################
# Set up SSH

#sudo ln -sf ${NEPI_ETC}/ssh ${etc_sync}/ssh
#if [ ! -f "/etc/ssh/sshd_config.bak" ]; then
#    sudo cp -p -r /etc/ssh /etc/ssh
#fi


echo " "
echo "Configuring SSH Keys"
DOCKER_ETC_FOLDER=${NEPI_DOCKER_CONFIG}/etc
# And link default public key - Make sure all ownership and permissions are as required by SSH
sudo chown ${USER}:${USER} ${DOCKER_ETC_FOLDER}/ssh/authorized_keys
sudo chmod 0600 ${DOCKER_ETC_FOLDER}/ssh/authorized_keys

if [ -f "/home/${USER}/.ssh" ]; then
    sudo rm /home/${USER}/.ssh/authorized_keys
fi
sudo cp ${DOCKER_ETC_FOLDER}/ssh/authorized_keys /home/${USER}/.ssh/authorized_keys
sudo chown ${USER}:${USER} /home/${USER}/.ssh/authorized_keys
sudo chmod 0600 /home/${USER}/.ssh/authorized_keys

sudo chmod 0700 /home/${USER}/.ssh
sudo chown -R ${USER}:${USER} /home/${USER}/.ssh

###########################################
if [ "$NEPI_MANAGES_TIME" -eq 1 ]; then
    sudo timedatectl set-ntp false
    # Install NTP Sources
    echo " "
    echo "Configuring chrony.conf"
    etc_path=chrony/chrony.conf
    if [ -f "/etc/${etc_path}" ]; then
        sudo cp -p -r /etc/${etc_path} /etc/${etc_path}.bak
    fi
    sudo cp ${etc_source}/${etc_path} /etc/${etc_path}
    sudo systemctl enable chrony
    sudo systemctl start chrony
fi

###########################################
# Install Modeprobe Conf
echo " "
echo "Configuring nepi_modprobe.conf"
etc_path=modprobe.d/nepi_modprobe.conf
if [ -f "/etc/${etc_path}" ]; then
    sudo cp -p -r /etc/${etc_path} /etc/${etc_path}.bak
<<<<<<< HEAD
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


#############################################
### Configure and restart nepi etc sync process

sudo cp -r ${etc_source}/lsyncd ${etc_dest}
if [[ "$NEPI_MANAGES_NETWORK" -eq 1 ]]; then
    echo "" | sudo tee -a $lsyncd_file
    echo "sync {" | sudo tee -a $lsyncd_file
    echo "    default.rsync," | sudo tee -a $lsyncd_file
    echo '    source = "'${etc_sync}'/",' | sudo tee -a $lsyncd_file
    echo '    target = "'${etc_dest}'/",' | sudo tee -a $lsyncd_file
    echo "}" | sudo tee -a $lsyncd_file
fi
=======
fi
sudo cp ${etc_source}/${etc_path} /etc/${etc_path}
>>>>>>> ed6950b4b7f6c45d73a725821c158e0a852c103b

<<<<<<< HEAD
#############################################
# Set up some udev rules for plug-and-play hardware
echo " "
echo "Setting up udev rules"
    # IQR Pan/Tilt
sudo cp ${NEPI_ETC}/udev/rules.d/56-iqr-pan-tilt.rules /etc/udev/rules.d/56-iqr-pan-tilt.rules
    # USB Power Saving on Cameras Disabled
sudo cp ${NEPI_ETC}/udev/rules.d/92-usb-input-no-powersave.rules /etc/udev/rules.d/92-usb-input-no-powersave.rules


#############################################
### Configure and restart nepi etc sync process

sudo cp -r ${etc_source}/lsyncd ${etc_dest}
if [[ "$NEPI_MANAGES_NETWORK" -eq 1 ]]; then
    echo "" | sudo tee -a $lsyncd_file
    echo "sync {" | sudo tee -a $lsyncd_file
    echo "    default.rsync," | sudo tee -a $lsyncd_file
    echo '    source = "'${etc_sync}'/",' | sudo tee -a $lsyncd_file
    echo '    target = "'${etc_dest}'/",' | sudo tee -a $lsyncd_file
    echo "}" | sudo tee -a $lsyncd_file
fi

=======
>>>>>>> ac1c03d57908885f2d6673a8ebba302e63aadfaa
#sudo systemctl enable lsyncd
#sudo systemctl restart lsyncd


##################################
echo ""
echo 'NEPI Docker Config Setup Complete'
##################################

