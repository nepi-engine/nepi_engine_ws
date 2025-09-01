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

source $(pwd)/NEPI_CONFIG.sh
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

CONFIG_DEST_FILE=${NEPI_DOCKER_CONFIG}/nepi_config.yaml
source $(pwd)/nepi_config_setup.sh
wait

sudo chown -R ${USER}:${USER} ${CONFIG_DEST_FILE}

#source $(pwd)/docker_bash_config.sh
#wait

###################
# Initialize Docker Config ETC Folder
NEPI_ETC_SOURCE=$(dirname "$(pwd)")/resources/etc
echo ""
echo "Populating System Folders from ${NEPI_ETC_SOURCE}"
sudo cp -R ${NEPI_ETC_SOURCE} ${NEPI_DOCKER_CONFIG}
sudo cp nepi_etc_update.sh ${NEPI_DOCKER_CONFIG}/
sudo chown -R ${USER}:${USER} $NEPI_DOCKER_CONFIG

# Rsync etc folder from factory folder
rsync -arh ${NEPI_CONFIG}/factory_cfg/etc ${NEPI_CONFIG}/docker_cfg

# Rsync etc folder from system folder
rsync -arh ${NEPI_CONFIG}/system_cfg/etc ${NEPI_CONFIG}/docker_cfg

docker_config=${NEPI_DOCKER_CONFIG}/nepi_config.yaml
etc_config=${NEPI_DOCKER_CONFIG}/etc/nepi_config.yaml
echo "Copying NEPI System Config File ${docker_config} to ${etc_config}"
sudo cp ${docker_config} ${etc_config}
sudo chown -R ${USER}:${USER} $NEPI_CONFIG


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


# Rsync etc folder to system folder
export NEPI_CONFIG_FILE=$CONFIG_DEST_FILE
export ETC_FOLDER=${NEPI_DOCKER_CONFIG}/etc
#source $(pwd)/nepi_etc_update.sh
#wait

rsync -arh  ${NEPI_CONFIG}/docker_cfg/etc ${NEPI_CONFIG}/system_cfg

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





##################################
echo ""
echo 'NEPI Docker Config Setup Complete'
##################################

