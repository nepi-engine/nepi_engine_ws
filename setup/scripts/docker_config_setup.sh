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


CONFIG_SOURCE=$(dirname "$(pwd)")/NEPI_CONFIG.sh
source ${CONFIG_SOURCE}
wait


#####################################
# Copy Files to NEPI Docker Config Folder
####################################
NEPI_DOCKER_CONFIG=${NEPI_CONFIG}/docker_cfg
sudo mkdir $NEPI_DOCKER_CONFIG
echo "Copying nepi config files to ${NEPI_DOCKER_CONFIG}"
sudo cp $(dirname "$(pwd)")/resources/docker/* ${NEPI_DOCKER_CONFIG}/
sudo cp -R -p $(dirname "$(pwd)")/resources/etc ${NEPI_DOCKER_CONFIG}/

sudo chown -R ${USER}:${USER} ${NEPI_DOCKER_CONFIG}

###################
# Copy Config Files
SOURCE_PATH=$(dirname "$(pwd)")/resources/etc
DEST_PATH=${NEPI_CONFIG}/docker_cfg
CONFIG_USER=${USER}

echo ""
echo "Populating System Folders from ${SOURCE_PATH}"
sudo cp -R ${SOURCE_PATH} ${DEST_PATH}/etc
sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $DEST_PATH

# Rsync etc folder from factory folder
rsync -arh ${NEPI_CONFIG}/factory_cfg/etc ${NEPI_CONFIG}/docker_cfg

# Rsync etc folder from system folder
rsync -arh ${NEPI_CONFIG}/system_cfg/etc ${NEPI_CONFIG}/docker_cfg


NEPI_CFG_SOURCE=${CONFIG_SOURCE}
NEPI_CFG_DEST=${NEPI_CONFIG}/docker_cfg/.NEPI_CONFIG
###################
# Copy Config Files
SOURCE_PATH=$(dirname "$(pwd)")/resources/etc
DEST_PATH=${NEPI_ETC}
CONFIG_USER=${NEPI_USER}


echo ""
echo "Populating System Folders from ${SOURCE_PATH}"
sudo cp -R ${SOURCE_PATH}/* ${DEST_PATH}/
sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $DEST_PATH


NEPI_CONFIG_SOURCE=${CONFIG_SOURCE}
NEPI_CONFIG_DEST=/home/${CONFIG_USER}/.NEPI_CONFIG

## Check Selection
echo ""
echo ""
echo "Do You Want to OverWrite System Config: ${OP_SELECTION}"
select ovw in "View_Original" "View_New" "Yes" "No" "Quit"; do
    case $ovw in
        View_Original ) cat ${NEPI_CONFIG_DEST};;
        View_New )  cat ${NEPI_CONFIG_SOURCE};;
        Yes ) OVERWRITE=1; break;;
        No ) OVERWRITE=0; break;;
        Quit ) exit 1
    esac
done


if [ "$OVERWRITE" -eq 1 ]; then
  echo "Installing NEPI CONFIG ${NEPI_CONFIG_DEST} "
  sudo rm ${NEPI_CONFIG_SOURCE}
  # Create a symlink in the home folder
  sudo cp ${NEPI_CONFIG_SOURCE} ${NEPI_CONFIG_DEST}
  sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $NEPI_CONFIG_DEST
else
  source ${NEPI_CONFIG_DEST}
fi

# Create a symlink in the config folder
NEPI_CFG_SOURCE=$NEPI_CFG_DEST
NEPI_CFG_DEST=${NEPI_CONFIG}/docker_cfg/nepi_config.yaml
sudo rm $NEPI_CFG_DEST
ln -s ${NEPI_CFG_SOURCE} ${NEPI_CFG_DEST} 
sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $NEPI_CFG_DEST

source ${DEST_PATH}/etc/update_etc_files.sh
wait

echo "Updated NEPI Config file ${NEPI_CONFIG_FILE}"

sudo chown -R ${CONFIG_USER}:${CONFIG_USER} ${DEST_PATH}

#######################
# Copy the nepi_config.yaml file to the factory_cfg folder
source_config=${DEST_PATH}/etc/nepi_config.yaml
dest_etc=${NEPI_CONFIG}/factory_cfg/etc
dest_config=${dest_etc}/nepi_config.yaml
echo "Updating NEPI System Files in ${dest_config}"
sudo mkdir -p ${dest_etc}
sudo cp $source_config $dest_config
sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $dest_etc

# Copy the nepi_config.yaml file to the system_cfg folder
source_config=${DEST_PATH}/etc/nepi_config.yaml
dest_etc=${NEPI_CONFIG}/system_cfg/etc
dest_config=${dest_etc}/nepi_config.yaml
echo "Updating NEPI System Files in ${dest_config}"
sudo mkdir -p ${dest_etc}
sudo cp $source_config $dest_config
sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $dest_etc



##################################
# Setting Up NEPI Docker Host Services Links

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

    sudo systemctl disable NetworkManager

    sudo ln -sf ${etc_source}/network/interfaces.d ${etc_sync}
    # Set up static IP addr.
    echo "Updating Network interfaces.d"
    if [ -d "/etc/network/interfaces.d" -a ! -d "/etc/network/interfaces.d.bak" ]; then
        sudo cp -p -r /etc/network/interfaces.d /etc/network/interfaces.d.bak
    fi
    echo "Updating Network interfaces"
    if [ -f "/etc/network/interfaces" -a ! -f "/etc/network/interfaces.bak" ]; then
        sudo cp -p -r /etc/network/interfaces /etc/network/interfaces.bak
    fi


    # Set up DHCP
    sudo ln -sf ${etc_source}/dhcp/dhclient.conf ${etc_sync}
    echo "Updating Network dhclient.conf"
    if [ -f "/etc/dhcp/dhclient.conf" -a ! -f "/etc/dhcp/dhclient.conf.bak" ]; then
        sudo cp -p -r /etc/dhcp/dhclient.conf /etc/dhcp/dhclient.conf.bak
    fi

    # Set up WIFI
    if [ ! -d "etc/wpa_supplicant" ]; then
        sudo mkdir ${etc_sync}/wpa_supplicant
    fi
    sudo ln -sf ${etc_source}/wpa_supplicant/wpa_supplicant.conf ${etc_sync}
    if [ -d "/etc/wpa_supplicant.bak" ]; then
        sudo cp -p -r /etc/wpa_supplicant /etc/wpa_supplicant.bak
    fi
    
fi

#sudo ln -sf ${NEPI_ETC}/ssh ${etc_sync}/ssh
#if [ ! -f "/etc/ssh/sshd_config.bak" ]; then
#    sudo cp -p -r /etc/ssh /etc/ssh
#fi




sudo cp -r ${etc_source}/lsyncd ${etc_dest}
if [[ "$NEPI_MANAGES_NETWORK" -eq 1 ]]; then
    echo "" | sudo tee -a $lsyncd_file
    echo "sync {" | sudo tee -a $lsyncd_file
    echo "    default.rsync," | sudo tee -a $lsyncd_file
    echo '    source = "'${etc_sync}'/",' | sudo tee -a $lsyncd_file
    echo '    target = "'${etc_dest}'/",' | sudo tee -a $lsyncd_file
    echo "}" | sudo tee -a $lsyncd_file
fi

sudo systemctl enable lsyncd
sudo systemctl restart lsyncd



###########################################
# Set up SSH
echo " "
echo "Configuring SSH Keys"
ETC_FOLDER=${NEPI_DOCKER_CONFIG}/etc
# And link default public key - Make sure all ownership and permissions are as required by SSH
sudo chown ${USER}:${USER} ${ETC_FOLDER}/ssh/authorized_keys
sudo chmod 0600 ${ETC_FOLDER}/ssh/authorized_keys

if [ -f "/home/${USER}/.ssh" ]; then
    sudo rm /home/${USER}/.ssh/authorized_keys
fi
sudo cp ${ETC_FOLDER}/ssh/authorized_keys /home/${USER}/.ssh/authorized_keys
sudo chown ${USER}:${USER} /home/${USER}/.ssh/authorized_keys
sudo chmod 0600 /home/${USER}/.ssh/authorized_keys

sudo chmod 0700 /home/${USER}/.ssh
sudo chown -R ${USER}:${USER} /home/${USER}/.ssh

###########################################
# Install Modeprobe Conf
echo " "
echo "Configuring nepi_modprobe.conf"
etc_path = modeprobe.d/nepi_modprobe.conf
if [ ! -f "/etc/${etc_path}" ]; then
    sudo cp -p -r /etc/${etc_path} /etc/${etc_path}
    sudo rm -r /etc/ssh/sshd_config
fi
sudo cp ${NEPI_ETC}/${etc_path} /etc/${etc_path}



##################################
echo ""
echo 'NEPI Docker Config Setup Complete'
##################################

