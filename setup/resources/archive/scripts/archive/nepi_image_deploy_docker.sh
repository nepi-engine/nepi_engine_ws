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

NEPI_IMAGE=nepi_3p2p0
ID=f1a0deb14733
######################################################################

# Setup nepi_docker folder

# Install nepi_docker_image

# Run nepi_start_docker.sh






### Some Tools

# Installed Images
# sudo docker images -a
# sudo docker rmi IMAGE:ID

# Run Nepi in Dev Mode
sudo docker run --privileged -e UDEV=1 --user nepi --gpus all --mount type=bind,source=/mnt/nepi_storage,target=/mnt/nepi_storage --mount type=bind,source=/dev,target=/dev -it --net=host --runtime nvidia -v /tmp/.X11-unix/:/tmp/.X11-unix $NEPI_IMAGE /bin/bash

#Run NEPI Complete
sudo docker run --rm --privileged -e UDEV=1 --user nepi --gpus all --mount type=bind,source=/mnt/nepi_storage,target=/mnt/nepi_storage -it --net=host --runtime nvidia -e DISPLAY=$DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix $NEPI_IMAGE /bin/bash -c "/nepi_start_all.sh"

# Run Nepi RUI
sudo docker run --rm -it --net=host -v /tmp/.X11-unix/:/tmp/.X11-unix $NEPI_IMAGE /bin/bash -c "/nepi_rui_start.sh"

# Running processes
sudo docker ps -a
sudo docker start ${ID} # restart it in the background
sudo docker start -a -i ${ID} # restart with terminal
sudo docker attach ${ID} # reattach the terminal & stdin
sudo docker remove ID

# Commit, Archive, Install
# sudo docker commit PS_IMAGE:ID $NEPI_IMAGE:ID
## https://phoenixnap.com/kb/how-to-commit-changes-to-docker-image
######################################################################


# Copy zed camera config files to 
/mnt/nepi_storage/usr_cfg/zed_cals/

#Install chromium on 
# On host machine open chromium and enter http://127.0.0.1:5003/ to access the RUI locally
# On 


#_____________
# setup nepi_storage folder

# Create a nepi_storage folder on mounted partition with at least 100 GB of free space
mkdir mnt/nepi_storage
cd mnt/nepi_storage
# Download the nepi_storage folders from ??? for docker images from:
# Extract and delete zip
# Add NEPI bash aliases to host and edit .bashrc to call it



#Run NEPI Complete
sudo docker run --rm --privileged -e UDEV=1 --user nepi --gpus all --mount type=bind,source=/mnt/nepi_storage,target=/mnt/nepi_storage -it --net=host --runtime nvidia -e DISPLAY=$DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix nepi_ft1c /bin/bash -c "/nepi_start_all.sh"


#_____________
# Run Nepi in Dev Mode
#_____________
# Run Nepi in Dev Mode
sudo docker run --privileged -e UDEV=1 --user nepi --gpus all --mount type=bind,source=/mnt/nepi_storage,target=/mnt/nepi_storage --mount type=bind,source=/dev,target=/dev -it --net=host --runtime nvidia -v /tmp/.X11-unix/:/tmp/.X11-unix nepi_ft1c /bin/bash

#volumes - /dev:/dev

#volumes - /dev:/dev

#_____________
# Run Nepi RUI
sudo docker run --rm -it --net=host -v /tmp/.X11-unix/:/tmp/.X11-unix nepi1 /bin/bash -c "/nepi_rui_start.sh"

sudo docker exec -it 32e4923a9fc6 /bin/bash -c "/nepi_rui.sh"



