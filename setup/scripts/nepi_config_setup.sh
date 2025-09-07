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
echo "STARTING NEPI CONFIG SETUP"
echo "########################"


CONFIG_SOURCE=$(dirname "$(pwd)")/nepi_system_config.yaml
source $(pwd)/load_system_config.sh
wait

if [ $? -eq 1 ]; then
    echo "Failed to load ${CONFIG_SOURCE}"
    exit 1
fi

###################
# Copy Config Files
ETC_SOURCE_PATH=$(dirname "$(pwd)")/resources/etc
ETC_DEST_PATH=${NEPI_ETC}

SCRIPTS_SOURCE_PATH=$(dirname "$(pwd)")/resources/scripts
SCRIPTS_DEST_PATH=${NEPI_SCRIPTS}

CONFIG_USER=${NEPI_USER}


echo ""
echo "Updating System Scrips from ${SCRIPTS_SOURCE_PATH}"
sudo cp -R ${SCRIPTS_SOURCE_PATH}/* ${SCRIPTS_DEST_PATH}/
sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $SCRIPTS_DEST_PATH
sudpo chmod +x $SCRIPTS_DEST_PATH/*
sudo cp ${SCRIPTS_SOURCE_PATH}/nepi_docker_start.sh /nepi_docker_start.sh

echo ""
echo "Updating System Etc from ${ETC_SOURCE_PATH}"
sudo cp -R ${ETC_SOURCE_PATH}/* ${ETC_DEST_PATH}/
sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $ETC_DEST_PATH

# Update Deployed Config

NEPI_CONFIG_SOURCE=${CONFIG_SOURCE}
echo $NEPI_CONFIG_SOURCE

NEPI_CONFIG_ETC_DEST_PATH=${NEPI_BASE}/etc
NEPI_CONFIG_DEST=${NEPI_CONFIG_ETC_DEST_PATH}/nepi_system_config.yaml
echo $NEPI_CONFIG_DEST
if [ ! -d "${NEPI_CONFIG_ETC_DEST_PATH}" ]; then
    sudo mkdir -p ${NEPI_CONFIG_ETC_DEST_PATH}
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
  echo "Updating NEPI CONFIG ${NEPI_CONFIG_DEST} "
  sudo cp ${NEPI_CONFIG_SOURCE} ${NEPI_CONFIG_DEST}
fi

echo $NEPI_CONFIG_ETC_DEST_PATH

sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $NEPI_CONFIG_ETC_DEST_PATH
export_config_file ${NEPI_CONFIG_DEST}

###############

echo "Updating NEPI Config files in ${ETC_DEST_PATH}"
source ${ETC_DEST_PATH}/update_etc_files.sh
wait


#######################
# Copy the nepi_system_config.yaml file to the factory_cfg folder
source_config=${ETC_DEST_PATH}/nepi_system_config.yaml
dest_etc=${NEPI_CONFIG}/factory_cfg/etc
dest_config=${dest_etc}/nepi_system_config.yaml
echo "Updating NEPI System Files in ${dest_config}"
sudo mkdir -p ${dest_etc}
sudo cp $source_config $dest_config
sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $dest_etc

# Copy the nepi_system_config.yaml file to the system_cfg folder
source_config=${ETC_DEST_PATH}/nepi_system_config.yaml
dest_etc=${NEPI_CONFIG}/system_cfg/etc
dest_config=${dest_etc}/nepi_system_config.yaml
echo "Updating NEPI System Files in ${dest_config}"
sudo mkdir -p ${dest_etc}
sudo cp $source_config $dest_config
sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $dest_etc




###################
# Set up the default hostname
# Hostname Setup - the link target file may be updated by NEPI specialization scripts, but no link will need to move
if [ "$NEPI_IN_CONTAINER" -eq 0 ]; then
    if [ "$NEPI_MANAGES_NETWORK" -eq 1 ]; then
        echo " "
        echo "Updating system hostname"

        #sudo chmod 744 /etc/host*
        #sudo cp -p /etc/hosts /etc/hosts.bak
        if [ ! -f /etc/hosts ]; then
            sudo rm /etc/hosts
        fi
        sudo ln -sf ${NEPI_ETC}/hosts /etc/hosts

        #sudo cp -p /etc/hostname /etc/hostname.bak
        if [ ! -f "/etc/hostname" ]; then
            sudo rm /etc/hostname
        fi
        sudo ln -sf ${NEPI_ETC}/hostname /etc/hostname


        # Set up static IP addr.
        echo "Updating Network interfaces.d"
        if [ ! -f "/etc/network/interfaces.d" ]; then
            #sudo cp -p -r /etc/network/interfaces.d /etc/network/interfaces.d.bak
            sudo rm -r /etc/network/interfaces.d
        fi
        sudo ln -sf ${NEPI_ETC}/network/interfaces.d /etc/network/interfaces.d

        echo "Updating Network interfaces"
        if [ ! -f "/etc/network/interfaces" ]; then
            #sudo cp -p -r /etc/network/interfaces /etc/network/interfaces.bak
            sudo rm /etc/network/interfaces
        fi
        sudo cp ${NEPI_ETC}/network/interfaces /etc/network/interfaces

        # Set up DHCP
        echo "Updating Network dhclient.conf"
        if [ ! -f "/etc/dhcp/dhclient.conf" ]; then
            #sudo cp -p -r /etc/dhcp/dhclient.conf /etc/dhcp/dhclient.conf.bak
            sudo rm /etc/dhcp/dhclient.conf
        fi
        sudo ln -sf ${NEPI_ETC}/dhcp/dhclient.conf /etc/dhcp/dhclient.conf


        # Set up WIFI
        echo "Updating Network wpa_supplicant.conf"
        if [ ! -d "/etc/wpa_supplicant" ]; then
            sudo mkdir /etc/wpa_supplicant
        fi
        if [ -f "/etc/wpa_supplicant/wpa_supplicant.conf" ]; then
            sudo cp -p -r /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf.bak
        fi
        sudo ln -sf ${NEPI_ETC}/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
    fi
fi




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


    if [ ! -f "/etc/ssh/sshd_config" ]; then
        sudo cp -p -r /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
        sudo rm -r /etc/ssh/sshd_config
    fi
    sudo ln -sf ${NEPI_ETC}/ssh/sshd_config /etc/ssh/sshd_config



    ###########################################
    # Set up Samba
    echo "Configuring nepi storage Samba share drive"
    if [ ! -f "/etc/samba/smb.conf" ]; then
        sudo cp -p -r /etc/samba/smb.conf /etc/samba/smb.conf.bak
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

    ###########################################
    # Set up Chrony
    echo " "
    echo "Configuring Chrony"
    sudo cp -p /etc/chrony/chrony.conf /etc/chrony/chrony.conf.bak
    sudo ln -sf ${NEPI_ETC}/chrony/chrony.conf /etc/chrony/chrony.conf


    ###########################################
    # Install Modeprobe Conf
    echo " "
    echo "Configuring nepi_modprobe.conf"
    etc_path=modprobe.d/nepi_modprobe.conf
    if [ -f "/etc/${etc_path}" ]; then
        sudo cp -p -r /etc/${etc_path} /etc/${etc_path}.bak
    fi
    sudo ln -sf ${NEPI_ETC}/${etc_path} /etc/${etc_path}



    ##################################################
    # Set up the NEPI sys env bash file
    echo "Updating system env bash file"
    sudo chmod +x ${NEPI_ETC}/sys_env.bash
    sudo cp -p ${NEPI_ETC}/sys_env.bash ${NEPI_ETC}/sys_env.bash.bak
    if [ ! -f "${NEPI_BASE}/sys_env.bash" ]; then
        sudo rm ${NEPI_BASE}/sys_env.bash
    fi
    sudo ln -sf ${NEPI_ETC}/sys_env.bash ${NEPI_BASE}/sys_env.bash
    if [ ! -f "${NEPI_BASE}/sys_env.bash.bak" ]; then
        sudo rm ${NEPI_BASE}/sys_env.bash.bak
    fi
    sudo ln -sf ${NEPI_ETC}/sys_env.bash.bak ${NEPI_BASE}/sys_env.bash.bak

    ################################
    # Update fstab
    echo "Updating fstab"
    if [ ! -f "/etc/fstab" ]; then
        sudo mv /etc/fstab /etc/fstab.bak
    fi
    sudo cp -p ${NEPI_ETC}/fstab /etc/fstab
    sudo chown root:root /etc/fstab


    #########################################
    # Setup supervisor
    echo ""
    echo "Setting up NEPI Supervisord"

    if [ -d "/etc/supervisor" ]; then
        if [ ! -f "/etc/supervisor/conf.d/supervisord_nepi.conf" ]; then
            sudo cp -p -r /etc/supervisor/conf.d/supervisord_nepi.conf /etc/supervisor/conf.d/supervisord_nepi.conf.bak
            sudo rm /etc/supervisor/conf.d/supervisord_nepi.conf
        fi
        sudo ln -sf ${NEPI_ETC}/supervisor/conf.d/supervisord_nepi.conf /etc/supervisor/conf.d/supervisord_nepi.conf 
    fi


    #############################################
    # Set up some udev rules for plug-and-play hardware
    echo " "
    echo "Setting up udev rules"
        # IQR Pan/Tilt
    sudo cp ${NEPI_ETC}/udev/rules.d/56-iqr-pan-tilt.rules /etc/udev/rules.d/56-iqr-pan-tilt.rules
        # USB Power Saving on Cameras Disabled
    sudo cp ${NEPI_ETC}/udev/rules.d/92-usb-input-no-powersave.rules /etc/udev/rules.d/92-usb-input-no-powersave.rules


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

    #########################################
    # Setup system services
    echo ""
    echo "Setting up NEPI Engine Service"

    sudo chmod +x ${NEPI_ETC}/services/*

    sudo cp ${NEPI_ETC}/services/nepi_engine.service ${SYSTEMD_SERVICE_PATH}/nepi_engine.service
    sudo systemctl enable nepi_engine


    echo "NEPI Engine Service Setup Complete"


#########################################
# Setup NEPI etc sync process
sudo cp -r ${etc_source}/lsyncd /etc/
sudo chown -R ${USER}:${USER} ${lsyncd_file}

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
sudo systemctl disable lsyncd



##############################################
echo "NEPI Config Setup Complete"
##############################################

