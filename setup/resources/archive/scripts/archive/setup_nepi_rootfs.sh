#!/bin/sh

# Set up the NEPI Standard ROOTFS (Typically on External Media (e.g SD, SSD, SATA))

# This script is tested to run from a fresh Ubuntu 18.04 install based on the L4T reference rootfs.
# Other base rootfs schemes may work, but should be tested.

# Preliminary checks
# Internet connectivity:
sudo dhclient
if ! ping -c 2 google.com; then
    echo "ERROR: System must have internet connection to proceed"
    exit 1
fi

# The script is assumed to run from a directory structure that mirrors the Git repo it is housed in.
HOME_DIR=$PWD

# Clear the Desktop
rm /home/nepi/Desktop/*

# Create the directory structure for NEPI -- lots of stuff gets installed here
sudo mkdir -p /opt/nepi
sudo mkdir -p /opt/nepi/ros
sudo mkdir -p /opt/nepi/nepi_link
# And hand all these over to nepi user
sudo chown -R nepi:nepi /opt/nepi

# Generate the entire config directory -- this is where all the targets of Linux config symlinks
# generated below land
sudo cp -r ${HOME_DIR}/config /opt/nepi

# Set up the default hostname
# Hostname Setup - the link target file may be updated by NEPI specialization scripts, but no link will need to move
sudo mv /etc/hostname /etc/hostname.bak
sudo ln -sf /opt/nepi/config/etc/hostname /etc/hostname

# Set up bash aliases
ln -sf /opt/nepi/config/home/nepi/nepi_bash_aliases /home/nepi/.bash_aliases

# Install any low-level drivers
sudo cp ${HOME_DIR}/resources/wifi_drivers/* /lib/firmware

# Update the Desktop background image
echo "Updating Desktop background image"
sudo mkdir -p /opt/nepi/resources
sudo cp ${HOME_DIR}/resources/nepi_wallpaper.png /opt/nepi/resources/
sudo chown nepi:nepi /opt/nepi/resources/nepi_wallpaper.png
gsettings set org.gnome.desktop.background picture-uri file:////opt/nepi/resources/nepi_wallpaper.png

# Update the login screen background image - handled by a sys. config file
# No longer works as of Ubuntu 20.04 -- there are some Github scripts that could replace this -- change-gdb-background
#echo "Updating login screen background image"
#sudo mv /usr/share/gnome-shell/theme/ubuntu.css /usr/share/gnome-shell/theme/ubuntu.css.bak
#sudo ln -sf /opt/nepi/config/usr/share/gnome-shell/theme/ubuntu.css /usr/share/gnome-shell/theme/ubuntu.css

# Set up static IP addr.
sudo mv /etc/network/interfaces.d /etc/network/interfaces.d.bak
sudo ln -sf /opt/nepi/config/etc/network/interfaces.d /etc/network/interfaces.d

# Set up DHCP
sudo mv /etc/dhcp/dhclient.conf /etc/dhcp/dhclient.conf.bak
sudo ln -sf /opt/nepi/config/etc/dhcp/dhclient.conf /etc/dhcp/dhclient.conf

# Set up SSH
sudo mv /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sudo ln -sf /opt/nepi/config/etc/ssh/sshd_config /etc/ssh/sshd_config
# And link default public key - Make sure all ownership and permissions are as required by SSH
mkdir -p /home/nepi/.ssh
sudo chown nepi:nepi /home/nepi/.ssh
chmod 0700 /home/nepi/.ssh
sudo chown nepi:nepi /opt/nepi/config/home/nepi/ssh/authorized_keys
chmod 0600 /opt/nepi/config/home/nepi/ssh/authorized_keys
ln -sf /opt/nepi/config/home/nepi/ssh/authorized_keys /home/nepi/.ssh/authorized_keys
sudo chown nepi:nepi /home/nepi/.ssh/authorized_keys
chmod 0600 /home/nepi/.ssh/authorized_keys

# Set up some udev rules for plug-and-play hardware
  # IQR Pan/Tilt
sudo ln -sf /opt/nepi/config/etc/udev/rules.d/56-iqr-pan-tilt.rules /etc/udev/rules.d/56-iqr-pan-tilt.rules
  # USB Power Saving on Cameras Disabled
sudo ln -sf /opt/nepi/config/etc/udev/rules.d/92-usb-input-no-powersave.rules /etc/udev/rules.d/92-usb-input-no-powersave.rules

# Disable apport to avoid crash reports on a display
sudo systemctl disable apport

# Now start installing stuff... first, update all base packages
sudo apt update
sudo apt upgrade

# Install static IP tools
echo "Installing static IP dependencies"
sudo apt install ifupdown net-tools

# Convenience applications
sudo apt install nano

# Install and configure chrony
echo "Installing chrony for NTP services"
sudo apt install chrony
sudo mv /etc/chrony/chrony.conf /etc/chrony/chrony.conf.bak
sudo ln -sf /opt/nepi/config/etc/chrony/chrony.conf.num_factory /etc/chrony/chrony.conf

# Install and configure samba with default passwords
echo "Installing samba for network shared drives"
sudo apt install samba
sudo mv /etc/samba/smb.conf /etc/samba/smb.conf.bak
sudo ln -sf /opt/nepi/config/etc/samba/smb.conf /etc/samba/smb.conf
printf "nepi\nnepi\n" | sudo smbpasswd -a nepi

# Install Baumer GenTL Producers (Genicam support)
echo "Installing Baumer GAPI SDK GenTL Producers"
# Set up the shared object links in case they weren't copied properly when this repo was moved to target
NEPI_BAUMER_PATH=/opt/nepi/config/opt/baumer/gentl_producers
ln -sf $NEPI_BAUMER_PATH/libbgapi2_usb.cti.2.14.1 $NEPI_BAUMER_PATH/libbgapi2_usb.cti.2.14
ln -sf $NEPI_BAUMER_PATH/libbgapi2_usb.cti.2.14 $NEPI_BAUMER_PATH/libbgapi2_usb.cti
ln -sf $NEPI_BAUMER_PATH/libbgapi2_gige.cti.2.14.1 $NEPI_BAUMER_PATH/libbgapi2_gige.cti.2.14
ln -sf $NEPI_BAUMER_PATH/libbgapi2_gige.cti.2.14 $NEPI_BAUMER_PATH/libbgapi2_gige.cti
# And the master link
sudo ln -sf /opt/nepi/config/opt/baumer /opt/baumer
sudo chown nepi:nepi /opt/baumer

# Install Base Python Packages
echo "Installing base python packages"
sudo apt install python3-pip
pip install --user -U pip
pip install --user virtualenv
sudo apt install libffi-dev # Required for python cryptography library

# NEPI runtime python3 dependencies. Must install these in system folders such that they are on root user's python path
sudo -H pip install python-gnupg websockets onvif_zeep geographiclib PyGeodesy onvif harvesters WSDiscovery pyserial

# Other general python utilities
pip install --user labelImg # For onboard training
pip install --user licenseheaders # For updating license files and source code comments

sudo apt install scons # Required for num_gpsd
sudo apt install zstd # Required for Zed SDK installer
sudo apt install dos2unix # Required for robust automation_mgr
sudo apt install libv4l-dev v4l-utils # V4L Cameras (USB, etc.)
sudo apt install hostapd # WiFi access point setup
sudo apt install curl # Node.js installation below
sudo apt install gparted
sudo apt-get install chromium-browser # At least once, apt-get seemed to work for this where apt did not, hence the command here

# Install Base Node.js Tools and Packages (Required for RUI, etc.)
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install 8.11.1 # RUI-required Node version as of this script creation

# Create the mountpoint for samba shares (now that sambashare group exists)
sudo mkdir /mnt/nepi_storage
sudo chown :sambashare /mnt/nepi_storage

# Add nepi user to dialout group to allow non-sudo serial connections
sudo adduser nepi dialout

#THERE MAY BE SOMETHING WRONG WITH THE FOLLOWING: FOR LOOP ERRORS OUT, NO ROS GETS INSTALLED
DISTRIBUTION_CODE_NAME=$( lsb_release -sc )
ROS_VERSION=""
case $DISTRIBUTION_CODE_NAME in
  "bionic" )
    ROS_VERSION=melodic
    # Install ROS Melodic (-desktop, which includes important packages)
    # This script should be useful even on non-Jetson (but ARM-based) systems,
    # hence included here rather than in the Jetson-specific setup script.
    sudo mkdir tmp && cd tmp
    sudo git clone https://github.com/jetsonhacks/installROS.git
    cd installROS
    sudo ./installROS.sh -p ros-melodic-desktop
    cd ../..
    rm -rf ./tmp

    # Update some .bashrc artifacts of the ROS install process
    sed -i 's:source /opt/ros/melodic/setup.bash:source /opt/nepi/ros/setup.bash:g' /home/nepi/.bashrc
    sed -i 's:export ROS_IP=:#export ROS_IP=:g' /home/nepi/.bashrc
  ;;
  "focal" )
    ROS_VERSION=noetic
    # Install ROS Noetic (-desktop, which includes important packages) using standard installation instructions
    sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
    sudo apt install curl
    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
    sudo apt update
    sudo apt install ros-noetic-desktop
    # Update some .bashrc settings
    echo "# Automatically source NEPI ROS environment" >> /home/nepi/.bashrc
    echo "source /opt/nepi/ros/setup.bash" >> /home/nepi/.bashrc
  ;;
  *)
    echo "The remainder of this script is not set up for this Ubuntu version: $DISTRIBUTION_CODE_NAME"
    exit 1
  ;;
esac

ADDITIONAL_ROS_PACKAGES="python3-catkin-tools \
    ros-${ROS_VERSION}-rosbridge-server \
    ros-${ROS_VERSION}-pcl-ros \
    ros-${ROS_VERSION}-web-video-server \
    ros-${ROS_VERSION}-camera-info-manager \
    ros-${ROS_VERSION}-tf2-geometry-msgs \
    ros-${ROS_VERSION}-mavros \
    ros-${ROS_VERSION}-mavros-extras \
    ros-${ROS_VERSION}-serial \
    python3-rosdep" 

    # Deprecated ROS packages?
    #ros-${ROS_VERSION}-tf-conversions
    #ros-${ROS_VERSION}-diagnostic-updater 
    #ros-${ROS_VERSION}-vision-msgs

sudo apt install $ADDITIONAL_ROS_PACKAGES

# Mavros requires some additional setup for geographiclib
sudo /opt/ros/${ROS_VERSION}/lib/mavros/install_geographiclib_datasets.sh

# Need to change the default .ros folder permissions for some reason
sudo mkdir /home/nepi/.ros
sudo chown -R nepi:nepi /home/nepi/.ros

# Setup rosdep
sudo rosdep init
rosdep update

# Install nepi-link dependencies
sudo apt install socat protobuf-compiler
pip install virtualenv


# Disable NetworkManager (for next boot)... causes issues with NEPI IP addr. management
sudo systemctl disable NetworkManager

# Clean-up unnecessary installed s/w
sudo apt autoremove

