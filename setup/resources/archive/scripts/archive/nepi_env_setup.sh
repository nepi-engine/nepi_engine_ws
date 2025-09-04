#!/bin/bash

###################################
# Variables

if ! ping -c 2 google.com; then
    echo "ERROR: System must have internet connection to proceed"
    exit 1
fi


#########
# Add nepi user and group if does not exist
group="nepi"
user="nepi"
read -p "enter group name: " group
if grep -q $group /etc/group
  then
       echo "group exists"
else
       echo "group $group does not exist, creating"
       addgroup nepi
fi


if id -u "$user" >/dev/null 2>&1; then
  echo "User $user exists."
else
  echo "User $user does not exist, creating"
  adduser --ingroup nepi nepi
  echo "nepi ALL=(ALL:ALL) ALL" >> /etc/sudoers

  su nepi
  passwd
  nepi
  nepi
fi
exit


# Add nepi user to dialout group to allow non-sudo serial connections
sudo adduser nepi dialout

#or //https://arduino.stackexchange.com/questions/74714/arduino-dev-ttyusb0-permission-denied-even-when-user-added-to-group-dialout-o
#Add your standard user to the group "dialout'
sudo usermod -a -G dialout nepi
#Add your standard user to the group "tty"
sudo usermod -a -G tty nepi


# Clear the Desktop
sudo rm /home/nepi/Desktop/*


# Fix gpu accessability
#https://forums.developer.nvidia.com/t/nvrmmeminitnvmap-failed-with-permission-denied/270716/10
sudo usermod -aG sudo,video,i2c nepi


# Install some required applications
sudo apt update
sudo apt install git -y
git --version

sudo apt-get install nano

# The script is assumed to run from a directory structure that mirrors the Git repo it is housed in.
cd /home/nepi
HOME_DIR=$PWD

REPO_DIR=${HOME_DIR}/nepi_engine
CONFIG_DIR=${REPO_DIR}/nepi_env/config
ETC_DIR=${REPO_DIR}/nepi_env/etc

NEPI_DIR=/opt/nepi
NEPI_RUI=${NEPI_DIR}/nepi_rui
NEPI_CONFIG=${NEPI_DIR}/config
NEPI_ENV=${NEPI_DIR}/ros
NEPI_ETC=${NEPI_DIR}/etc

NEPI_DRIVE=/mnt/nepi_storage




#############
# Create System Folders
sudo mkdir -p ${NEPI_DIR}
sudo mkdir -p ${NEPI_RUI}
sudo mkdir -p ${NEPI_CONFIG}
sudo mkdir -p ${NEPI_ENV}
sudo mkdir -p ${NEPI_ETC}




################################
# Install and configure samba with default passwords

echo "Installing samba for network shared drives"
sudo apt install samba

# Create the mountpoint for samba shares (now that sambashare group exists)
#sudo chown -R nepi:sambashare ${NEPI_DRIVE}
#sudo chmod -R 0775 ${NEPI_DRIVE}

sudo chown -R nepi:nepi ${NEPI_DRIVE}
sudo chown nepi:sambashare ${NEPI_DRIVE}
sudo chmod -R 0775 ${NEPI_DRIVE}

##############
# Install Baumer GenTL Producers (Genicam support)
echo "Installing Baumer GAPI SDK GenTL Producers"
# Set up the shared object links in case they weren't copied properly when this repo was moved to target
NEPI_BAUMER_PATH=${NEPI_CONFIG}/opt/baumer/gentl_producers
ln -sf $NEPI_BAUMER_PATH/libbgapi2_usb.cti.2.14.1 $NEPI_BAUMER_PATH/libbgapi2_usb.cti.2.14
ln -sf $NEPI_BAUMER_PATH/libbgapi2_usb.cti.2.14 $NEPI_BAUMER_PATH/libbgapi2_usb.cti
ln -sf $NEPI_BAUMER_PATH/libbgapi2_gige.cti.2.14.1 $NEPI_BAUMER_PATH/libbgapi2_gige.cti.2.14
ln -sf $NEPI_BAUMER_PATH/libbgapi2_gige.cti.2.14 $NEPI_BAUMER_PATH/libbgapi2_gige.cti
# And the master link

#######################################
# Clone the nepi_engine repo
cd ~/
sudo git clone https://github.com/nepi-engine/nepi_engine.git

# Copy "config" rootfs folder to device from the nepi_engine/nepi_env repo folder

sudo cp -r ${HOME_DIR}/config ${NEPI_CONFIG}
sudo chown -R nepi:nepi /opt/nepi


##############################################
# Update the Desktop background image
echo "Updating Desktop background image"
sudo cp ${NEPI_CONFIG}/home/nepi/nepi_wallpaper.png ${NEPI_ETC}/nepi_wallpaper.png
gsettings set org.gnome.desktop.background picture-uri file:///${NEPI_ETC}/nepi_wallpaper.png

# Update the login screen background image - handled by a sys. config file
# No longer works as of Ubuntu 20.04 -- there are some Github scripts that could replace this -- change-gdb-background
#echo "Updating login screen background image"
#sudo cp ${NEPI_CONFIG}/usr/share/gnome-shell/theme/ubuntu.css ${NEPI_ETC}/ubuntu.css
#sudo ln -sf ${NEPI_ETC}/ubuntu.css /usr/share/gnome-shell/theme/ubuntu.css

############################################
# Set up the default hostname
# Hostname Setup - the link target file may be updated by NEPI specialization scripts, but no link will need to move
sudo cp ${NEPI_CONFIG}/etc/hostname ${NEPI_ETC}/hostname
sudo ln -sf ${NEPI_ETC}/hostname /etc/hostname

###########################################
# Set up SSH
sudo cp ${NEPI_CONFIG}/etc/ssh/sshd_config ${NEPI_ETC}/sshd_config
sudo ln -sf ${NEPI_ETC}/sshd_config /etc/ssh/sshd_config


# And link default public key - Make sure all ownership and permissions are as required by SSH
sudo cp ${NEPI_CONFIG}/home/nepi/ssh/authorized_keys ${NEPI_ETC}/authorized_keys
sudo chown nepi:nepi ${NEPI_ETC}/authorized_keys
sudo chmod 0600 ${NEPI_ETC}/authorized_keys
ln -sf ${NEPI_ETC}/authorized_keys /home/nepi/.ssh/authorized_keys
sudo chown nepi:nepi /home/nepi/.ssh/authorized_keys
sudo chmod 0600 /home/nepi/.ssh/authorized_keys

mkdir -p /home/nepi/.ssh
sudo chown nepi:nepi /home/nepi/.ssh
chmod 0700 /home/nepi/.ssh

#############################################
# Set up some udev rules for plug-and-play hardware
  # IQR Pan/Tilt
sudo cp ${NEPI_CONFIG}/etc/udev/rules.d/56-iqr-pan-tilt.rules ${NEPI_ETC}/56-iqr-pan-tilt.rules
sudo ln -sf ${NEPI_ETC}/56-iqr-pan-tilt.rules /etc/udev/rules.d/56-iqr-pan-tilt.rules
  # USB Power Saving on Cameras Disabled
sudo cp ${NEPI_CONFIG}/etc/udev/rules.d/92-usb-input-no-powersave.rules ${NEPI_ETC}/92-usb-input-no-powersave.rules
sudo ln -sf ${NEPI_ETC}/92-usb-input-no-powersave.rules /etc/udev/rules.d/92-usb-input-no-powersave.rules


###########################################
# Set up Samba
sudo cp ${NEPI_CONFIG}/etc/samba/smb.conf ${NEPI_ETC}/smb.conf
sudo ln -sf ${NEPI_ETC}/smb.conf /etc/samba/smb.conf
printf "nepi\nepi\n" | sudo smbpasswd -a nepi


# Disable apport to avoid crash reports on a display
sudo systemctl disable apport

###########################################
# Set up baumer
sudo cp -R ${NEPI_CONFIG}/opt/baumer ${NEPI_ETC}/baumer
sudo ln -sf ${NEPI_ETC}/baumer /opt/baumer
sudo chown nepi:nepi /opt/baumer

##############
# Setup system env bash
sudo cp ${NEPI_CONFIG}/etc/sys_env.bash ${NEPI_HOME}/sys_env.bash

cp ${NEPI_CONFIG}/etc/roslaunch.service $SYSTEMD_SERVICE_PATH
systemctl enable roslaunch


##############
# Install Manager File
#sudo cp -R ${NEPI_CONFIG}/etc/license/nepi_check_license.py ${NEPI_ETC}/nepi_check_license.py
#sudo dos2unix ${NEPI_ETC}/nepi_check_license.py
sudo ${NEPI_CONFIG}/etc/license/setup_nepi_license.sh

sudo chown -R nepi:nepi /opt/nepi/config
sudo chown -R nepi:nepi /opt/nepi/etc


##############
# Fix USB Vidoe Rate Issue
sudo rmmod uvcvideo
sudo sudo modprobe uvcvideo nodrop=1 timeout=5000 quirks=0x80
