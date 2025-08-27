#!/bin/bash

# Open a terminal on the device to install on
# Or ssh in if available

# Jetson-specific NEPI rootfs setup steps. This is a specialization of the base NEPI rootfs
# and calls that parent script as a pre-step.

# Run the parent script first
sudo ./nepi_file_syustem_setup.sh

############################################
# NEPI File System Setup (Container)
############################################


#########
# Define some system paths
# NOTE: THESE SHOULD HAVE BEEN Created in one of the ENV setup scripts above


REPO_DIR=${HOME_DIR}/nepi_engine
CONFIG_DIR=${REPO_DIR}/nepi_env/config
ETC_DIR=${REPO_DIR}/nepi_env/etc

NEPI_DIR=/opt/nepi
NEPI_RUI=${NEPI_DIR}/nepi_rui
NEPI_CONFIG=${NEPI_DIR}/config
NEPI_ENV=${NEPI_DIR}/ros
NEPI_ETC=${NEPI_DIR}/etc

NEPI_DRIVE=/mnt/nepi_storage





# Copy zed camera config files to 
/mnt/nepi_storage/usr_cfg/zed_cals/

#Install chromium on 
# On host machine open chromium and enter http://127.0.0.1:5003/ to access the RUI locally
# On 


#_____________
# setup nepi_storage folder

# Create a nepi_storage folder on mounted partition with at least 100 GB of free space
mkdir <path_to_nepi_parent_folder>/nepi_storage

# Run the nepi containers nepi_storage_init.sh script using the following command  
sudo docker run --rm --mount type=bind,source=/mnt/nepi_storage,target=/mnt/nepi_storage -it --net=host -v /tmp/.X11-unix/:/tmp/.X11-unix nepi /bin/bash -c "/nepi_storage_init.sh"

#then
exit


#_____________
# Start Nepi Engine
sudo docker run --privileged -e UDEV=1 --user nepi --gpus all --mount type=bind,source=/mnt/nepi_storage,target=/mnt/nepi_storage --mount type=bind,source=/dev,target=/dev -it --net=host --runtime nvidia -v /tmp/.X11-unix/:/tmp/.X11-unix nepi1 /bin/bash -c '/

volumes - /dev:/dev

#Run