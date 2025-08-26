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

source ./NEPI_CONFIG.sh
wait

sudo su
exit


echo ""
echo "Setting up NEPI Engine"


#####################################
# Add nepi aliases to bashrc
source nepi_bash_setup.sh




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
echo "Creating system folders in ${NEPI_BASE}"
sudo mkdir -p ${NEPI_BASE}
sudo mkdir -p ${NEPI_RUI}
sudo mkdir -p ${NEPI_ENGINE}
sudo mkdir -p ${NEPI_ETC}
sudo mkdir -p ${NEPI_SCRIPTS}

echo "Creating dev folders"
sudo mkdir -p ${NEPI_CODE}
sudo mkdir -p ${NEPI_SRC}


echo "Creating image install folders"
sudo mkdir -p ${NEPI_IMAGE_INSTALL}
sudo mkdir -p ${NEPI_IMAGE_ARCHIVE}


echo "Creating config folders"
sudo mkdir -p ${NEPI_USR_CONFIG}
sudo mkdir -p ${NEPI_FACTORY_CONFIG}
sudo mkdir -p ${NEPI_SYSTEM_CONFIG}

# Create some backward compatable links
sudo ln -sf ${NEPI_BASE}/nepi_engine ${NEPI_BASE}/ros
sudo ln -sf ${NEPI_BASE}/nepi_engine ${NEPI_BASE}/engine
sudo ln -sf ${NEPI_BASE}/nepi_rui ${NEPI_BASE}/rui


# Update NEPI_FOLDER owners
sudo chown -R ${NEPI_USER}:${NEPI_USER} ${NEPI_BASE}
sudo chown -R ${NEPI_USER}:${NEPI_USER} ${NEPI_STORAGE}
sudo chown -R ${NEPI_USER}:${NEPI_USER} ${NEPI_CONFIG}

###################
# Copy Config Files
NEPI_ETC_SOURCE=$(dirname "$(pwd)")/resources/etc
echo ""
echo "Populating System Folders from ${NEPI_ETC_SOURCE}"
sudo cp -R ${NEPI_ETC_SOURCE}/* ${NEPI_ETC}
sudo chown -R ${NEPI_USER}:${NEPI_USER} $NEPI_ETC

###############
echo "Updating nepi config file etc/nepi_config.yaml"
NEPI_ETC_CONFIG=${NEPI_ETC}/nepi_config.yaml
cat /dev/null > $NEPI_ETC_CONFIG
echo "NEPI_HW_TYPE: ${NEPI_HW_TYPE}" >> $NEPI_ETC_CONFIG
echo "NEPI_HW_MODEL: ${NEPI_HW_MODEL}" >> $NEPI_ETC_CONFIG

# PYTHON VERSION
echo "NEPI_PYTHON: ${NEPI_PYTHON}" >> $NEPI_ETC_CONFIG
echo "NEPI_ROS: ${NEPI_ROS}" >> $NEPI_ETC_CONFIG

# NEPI HOST SETTINGS
echo "NEPI_IN_CONTAINER: ${NEPI_IN_CONTAINER}" >> $NEPI_ETC_CONFIG
echo "NEPI_HAS_CUDA: ${NEPI_HAS_CUDA}" >> $NEPI_ETC_CONFIG
echo "NEPI_HAS_XPU: ${NEPI_HAS_XPU}" >> $NEPI_ETC_CONFIG

# NEPI Managed Resources. Set to 0 to turn off NEPI management of this resouce
# Note, if enabled for a docker deployment, these system functions will be
# disabled in the host OS environment
echo "NEPI_MANAGES_SSH: ${NEPI_MANAGES_SSH}" >> $NEPI_ETC_CONFIG
echo "NEPI_MANAGES_SHARE: ${NEPI_MANAGES_SHARE}" >> $NEPI_ETC_CONFIG
echo "NEPI_MANAGES_TIME: ${NEPI_MANAGES_TIME}" >> $NEPI_ETC_CONFIG
echo "NEPI_MANAGES_NETWORK: ${NEPI_MANAGES_NETWORK}" >> $NEPI_ETC_CONFIG

# System Setup Variables
echo "NEPI_USER: ${NEPI_USER}" >> $NEPI_ETC_CONFIG
echo "NEPI_DEVICE_ID: ${NEPI_DEVICE_ID}" >> $NEPI_ETC_CONFIG
echo "NEPI_IP: ${NEPI_IP}" >> $NEPI_ETC_CONFIG


# NEPI PARTITIONS
echo "NEPI_DOCKER: ${NEPI_DOCKER}" >> $NEPI_ETC_CONFIG
echo "NEPI_STORAGE: ${NEPI_STORAGE}" >> $NEPI_ETC_CONFIG
echo "NEPI_CONFIG: ${NEPI_CONFIG}" >> $NEPI_ETC_CONFIG

# NEPI File System 
echo "NEPI_ENV: ${NEPI_ENV}" >> $NEPI_ETC_CONFIG
echo "NEPI_HOME: ${NEPI_HOME}" >> $NEPI_ETC_CONFIG
echo "NEPI_BASE: ${NEPI_BASE}" >> $NEPI_ETC_CONFIG
echo "NEPI_RUI: ${NEPI_RUI}" >> $NEPI_ETC_CONFIG
echo "NEPI_ENGINE: ${NEPI_ENGINE}" >> $NEPI_ETC_CONFIG
echo "NEPI_ETC: ${NEPI_ETC}" >> $NEPI_ETC_CONFIG
echo "NEPI_SCRIPTS: ${NEPI_SCRIPTS}" >> $NEPI_ETC_CONFIG

echo "NEPI_CODE: ${NEPI_CODE}" >> $NEPI_ETC_CONFIG
echo "NEPI_SRC: ${NEPI_SRC}" >> $NEPI_ETC_CONFIG

echo "NEPI_IMAGE_INSTALL: ${NEPI_IMAGE_INSTALL}" >> $NEPI_ETC_CONFIG
echo "NEPI_IMAGE_ARCHIVE: ${NEPI_IMAGE_ARCHIVE}" >> $NEPI_ETC_CONFIG

echo "NEPI_USR_CONFIG: ${NEPI_USR_CONFIG}" >> $NEPI_ETC_CONFIG
echo "NEPI_DOCKER_CONFIG: ${NEPI_DOCKER_CONFIG}" >> $NEPI_ETC_CONFIG
echo "NEPI_FACTORY_CONFIG: ${NEPI_FACTORY_CONFIG}" >> $NEPI_ETC_CONFIG
echo "NEPI_SYSTEM_CONFIG: ${NEPI_SYSTEM_CONFIG}" >> $NEPI_ETC_CONFIG

echo "NEPI_CODE: ${NEPI_CODE}" >> $NEPI_ETC_CONFIG
echo "NEPI_ALIASES_FILE: ${NEPI_ALIASES_FILE}" >> $NEPI_ETC_CONFIG

echo "NEPI_AB_FS: ${NEPI_AB_FS}" >> $NEPI_ETC_CONFIG



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
echo "Setting up NEPI Engine Service"

sudo chmod +x ${NEPI_ETC}/services/*

sudo cp ${NEPI_ETC}/services/nepi_engine.service ${SYSTEMD_SERVICE_PATH}/nepi_engine.service
sudo systemctl enable nepi_engine


echo "NEPI Engine Service Setup Complete"


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
NEPI_BAUMER_PATH=${NEPI_ETC}/opt/baumer/gentl_producers
ln -sf $NEPI_BAUMER_PATH/libbgapi2_usb.cti.2.14.1 $NEPI_BAUMER_PATH/libbgapi2_usb.cti.2.14
ln -sf $NEPI_BAUMER_PATH/libbgapi2_usb.cti.2.14 $NEPI_BAUMER_PATH/libbgapi2_usb.cti
ln -sf $NEPI_BAUMER_PATH/libbgapi2_gige.cti.2.14.1 $NEPI_BAUMER_PATH/libbgapi2_gige.cti.2.14
ln -sf $NEPI_BAUMER_PATH/libbgapi2_gige.cti.2.14 $NEPI_BAUMER_PATH/libbgapi2_gige.cti


if [ ! -f "/opt/baumer" ]; then
    sudo rm -r /opt/baumer
fi
sudo ln -sf ${NEPI_ETC}/opt/baumer /opt/baumer
sudo chown ${NEPI_USER}:${NEPI_USER} /opt/baumer

# Disable apport to avoid crash reports on a display
echo "Disabling apport service"
sudo systemctl disable apport


# Set up static IP addr.
echo "Updating Network interfaces.d"
if [ ! -f "/etc/network/interfaces.d" ]; then
    sudo rm -r /etc/network/interfaces.d
fi
sudo ln -sf ${NEPI_ETC}/network/interfaces.d /etc/network/interfaces.d

echo "Updating Network interfaces"
if [ ! -f "/etc/network/interfaces" ]; then
    sudo rm /etc/network/interfaces
fi
sudo cp ${NEPI_ETC}/network/interfaces /etc/network/interfaces

# Set up DHCP
echo "Updating Network dhclient.conf"
if [ ! -f "/etc/dhcp/dhclient.conf" ]; then
    sudo rm /etc/dhcp/dhclient.conf
fi
sudo ln -sf ${NEPI_ETC}/dhcp/dhclient.conf /etc/dhcp/dhclient.conf


# Set up WIFI
echo "Updating Network wpa_supplicant.conf"
if [ -f "/etc/wpa_supplicant/wpa_supplicant.conf" ]; then
    sudo ln -sf ${NEPI_ETC}/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
fi




##############
# Install License Manager File
echo "Setting Up Lic Mgr"
sudo dos2unix ${NEPI_ETC}/license/nepi_check_license.py
sudo chmod +x ${NEPI_ETC}/license/nepi_check_license_start.py
sudo chmod +x ${NEPI_ETC}/license/nepi_check_license.py
sudo ln -sf ${NEPI_ETC}/license/nepi_check_license.service /etc/systemd/system/
sudo gpg --import ${NEPI_ETC}/license/nepi_license_management_public_key.gpg
sudo systemctl enable nepi_check_license
#gpg --import /opt/nepi/config/etc/nepi/nepi_license_management_public_key.gpg


################################
# Update fstab
echo "Updating fstab"
sudo cp -sf ${NEPI_ETC}/fstabs/fstab_emmc ${NEPI_ETC}/fstabs/fstab
sudo ln -sf ${NEPI_ETC}/fstabs/fstab /etc/fstab
if [ ! -f "/etc/fstab.bak" ]; then
    sudo rm /etc/fstab.bak
fi
sudo cp ${NEPI_ETC}/fstabs/fstab /etc/fstab.bak

#########################################
# Setup supervisor
echo ""
echo "Setting up NEPI Supervisord"

if [ ! -f "/etc/supervisor/conf.d/supervisord_nepi.conf" ]; then
    sudo rm /etc/supervisor/conf.d/supervisord_nepi.conf
fi
sudo ln -sf ${NEPI_ETC}/supervisor/conf.d/supervisord_nepi.conf /etc/supervisor/conf.d/supervisord_nepi.conf 

#########################################
# Setup system scripts
NEPI_SCRIPTS_SOURCE=$(dirname "$(pwd)")/resources/scripts
echo ""
echo "Populating System Scripts from ${NEPI_SCRIPTS_SOURCE}"

sudo cp -R ${NEPI_SCRIPTS_SOURCE} $NEPI_BASE/
sudo chmod +x ${NEPI_SCRIPTS}/*

echo "NEPI Script Setup Complete"

#########
#- add Gieode databases to FileSystem

#egm2008-2_5.pgm  egm2008-2_5.pgm.aux.xml  egm2008-2_5.wld  egm96-15.pgm  egm96-15.pgm.aux.xml  egm96-15.wld
#from
#https://www.3dflow.net/geoids/
#to
#/opt/nepi/databases/geoids
#:'

#######################
# Install some premade python packages
#######################
USER_SITE_PACKAGES_PATH=$(python -m site --user-site)
NEPI_PYTHON_SOURCE=$(dirname "$(pwd)")/resources/software/python3
# Install MSCL lib
#sudo wget https://github.com/LORD-MicroStrain/MSCL/releases/download/v67.0.1/MSCL_arm64_Python3.10_v67.0.1.deb
#sudo wget https://github.com/LORD-MicroStrain/MSCL/releases/download/v67.1.0/MSCL_arm64_Python3.10_v67.1.0.deb
#sudo dpkg -i MSCL*

sudo cp -R ${NEPI_PYTHON_SOURCE}/* ${USER_SITE_PACKAGES_PATH}/


# Update NEPI_BASE owner
sudo chown -R ${NEPI_USER}:${NEPI_USER} ${NEPI_BASE}

###########################################
# Fix some NEPI package issues
###########################################

'
FILE=/usr/lib/python3/dist-packages/Cryptodome/Util/_raw_api.py
KEY=
LINE=69
UPDATE=
echo "Updating docker file ${FILE} line: ${Line}"
sed -i "/^$KEY/c\\$UPDATE" "$FILE"
'


'
DO THIS MAYBE
sudo vi /usr/lib/python3/dist-packages/Cryptodome/Util/_raw_api.py
## Comment out line 258 "#raise OSError("Cannot load native module '%s': %s" % (name, ", ".join(attempts)))"
sudo vi /usr/lib/python3/dist-packages/Cryptodome/Cipher/AES.py
## Line 69 Add "if _raw_cpuid_lib is not None:" before try, then indent try and except section
'


##############################################
# Populate factory config folder
##############################################
echo "Populating NEPI Factory Config Folder ${NEPI_FACTORY_CONFIG}"
sudo cp -R -p /opt/nepi/etc ${NEPI_FACTORY_CONFIG}/



# Update NEPI_FOLDER owners
sudo chown -R ${NEPI_USER}:${NEPI_USER} ${NEPI_BASE}
sudo chown -R ${NEPI_USER}:${NEPI_USER} ${NEPI_STORAGE}
sudo chown -R ${NEPI_USER}:${NEPI_USER} ${NEPI_CONFIG}



##############################################
echo "NEPI Engine Setup Complete"
##############################################


# Source nepi aliases before exit
echo " "
echo "Sourcing bashrc with nepi aliases"
sleep 1 & source $BASHRC
wait
# Print out nepi aliases
. ${NEPI_ALIASES_DEST} && helpn