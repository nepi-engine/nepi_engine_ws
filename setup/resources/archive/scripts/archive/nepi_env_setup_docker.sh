#!/bin/bash


############################################
# PRE FILE SYSTEM SETUP (docker File System Only)
############################################
# DO THIS BEFORE FILE SYSTEM SETUP


# Set up the NEPI docker ROOTFS (Typically on External Media (e.g SD, SSD, SATA))

# This script is tested to run from a fresh Ubuntu 18.04 install based on the L4T reference rootfs.
# Other base rootfs schemes may work, but should be tested.

# Run this script from anywhere on the device

# This is a specialization of the base NEPI rootfs
# and calls that parent script as a pre-step.

# Run the parent script first
sudo ./nepi_env_setup.sh


#########
# Define some system paths

HOME_DIR=/home/nepi
REPO_DIR=${HOME_DIR}/nepi_engine
CONFIG_DIR=${REPO_DIR}/nepi_env/config
ETC_DIR=${REPO_DIR}/nepi_env/etc

NEPI_DIR=/opt/nepi
NEPI_RUI=${NEPI_DIR}/nepi_rui
NEPI_CONFIG=${NEPI_DIR}/config
NEPI_ENV=${NEPI_DIR}/ros
NEPI_ETC=${NEPI_DIR}/etc

NEPI_DRIVE=/mnt/nepi_storage


#########
# Env Setup
#########
# Preliminary checks
# Internet connectivity:

if ! ping -c 2 google.com; then
    echo "ERROR: System must have internet connection to proceed"
    exit 1
fi





######################################################################
### Some Tools
# sudo docker images -a
# sudo docker ps -a
# sudo docker start  'nepi_test ps -q -l' # restart it in the background
# sudo docker attach 'nepi_test ps -q -l' # reattach the terminal & stdin
## https://phoenixnap.com/kb/how-to-commit-changes-to-docker-image
######################################################################





_________
#Clean the linux system
#https://askubuntu.com/questions/5980/how-do-i-free-up-disk-space
#sudo apt-get clean
#sudo apt-get autoclean
#sudo apt-get autoremove


#_____________
#Setup Host 

#(Recommended) Set your host ip address to nepi standard
Address: 192.168.179.103
Netmask: 255.255.255.0

##(Recommended) Setup dhcp service
###apt install netplan.io

# Configure NEPI fixed IP (192.168.179.103) and Google DNS (8.8.8.8)




#_____________
# setup nepi_storage folder

# Create a nepi_storage folder on mounted partition with at least 100 GB of free space
mkdir <path_to_nepi_parent_folder>/nepi_storage

# Run the nepi containers nepi_storage_init.sh script using the following command  
sudo docker run --rm --mount type=bind,source=/mnt/nepi_storage,target=/mnt/nepi_storage -it --net=host -v /tmp/.X11-unix/:/tmp/.X11-unix nepi /bin/bash 

#then
exit







#****
### Need to copy nepi_license.py to /opt/nepi/scripts


#______________
# copy startup scripts
# Install nepi start scripts in root folder


sudo cp ${NEPI_CONFIG}/etc/supervisord/nepi_start_all.sh ${NEPI_ETC}/nepi_start_all.sh
sudo chmod +x ${NEPI_ETC}/nepi_start_all.sh
sudo ln -sf ${NEPI_ETC}/nepi_start_all.sh /nepi_start_all.sh

sudo cp ${NEPI_CONFIG}/etc/docker/nepi_engine_start.sh ${NEPI_ETC}/nepi_engine_start.sh
sudo chmod +x ${NEPI_ETC}/nepi_engine_start.sh
sudo ln -sf ${NEPI_ETC}/nepi_engine_start.sh /nepi_engine_start.sh

sudo cp ${NEPI_CONFIG}/etc/docker/nepi_rui_start.sh ${NEPI_ETC}/nepi_rui_start.sh
sudo chmod +x ${NEPI_ETC}/nepi_rui_start.sh
sudo ln -sf ${NEPI_ETC}/nepi_rui_start.sh /nepi_rui_start.sh

sudo cp ${NEPI_CONFIG}/etc/docker/nepi_samba_start.sh ${NEPI_ETC}/nepi_samba_start.sh
sudo chmod +x ${NEPI_ETC}/nepi_samba_start.sh
sudo ln -sf ${NEPI_ETC}/nepi_samba_start.sh /nepi_samba_start.sh

sudo cp ${NEPI_CONFIG}/etc/docker/nepi_storage_init.sh ${NEPI_ETC}/nepi_storage_init.sh
sudo chmod +x ${NEPI_ETC}/nepi_storage_init.sh
sudo ln -sf ${NEPI_ETC}/nepi_storage_init.sh /nepi_storage_init.sh

sudo cp ${NEPI_CONFIG}/etc/docker/nepi_license_start.sh ${NEPI_ETC}/nepi_license_start.sh
sudo chmod +x ${NEPI_ETC}/nepi_license_start.sh
sudo ln -sf ${NEPI_ETC}/nepi_license_start.sh /nepi_license_start.sh

sudo chown -R nepi:nepi /opt/nepi/etc
cd $NEPI_DIR
sudo cp -R etc etc.factory

#-------------------
# Install setup supervisord
#https://www.digitalocean.com/community/tutorials/how-to-install-and-manage-supervisor-on-ubuntu-and-debian-vps
#https://test-dockerrr.readthedocs.io/en/latest/admin/using_supervisord/

sudo supervisorctl status
sudo supervisorctl stop all

sudo apt update && sudo apt install supervisor
sudo vi /etc/supervisor/conf.d/nepi.conf
# Add these lines
[supervisord]
nodaemon=false

[program:nepi_engine]
command=/bin/bash /nepi_engine_start.sh
autostart=true
autorestart=true


[program:nepi_rui]
command=/bin/bash /nepi_rui_start.sh
autostart=true
autorestart=true

[program:nepi_storage_samba]
command=/bin/bash /nepi_samba_start.sh
autostart=true
autorestart=true


###

sudo supervisorctl reload


