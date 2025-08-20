#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##


# This file contains tools for working with nepi docker system

# This file configigues an installed NEPI File System

NEPI_DOCKER_CONFIG=${PWD}/nepi_docker_config_config.yaml

########################
# Variable Setup
#########################

### NEED TO: Read these from nepi_config.yaml file
ACTIVE_CONT=nepi_fs_b
ACTIVE_VERSION=3p2p0
ACTIVE_TAG=${ACTIVE_VERSION}
ACTIVE_ID=12626ab028c1

INACTIVE_CONT=nepi_fs_a
INACTIVE_VERSION=uknown
INACTIVE_TAG=${INACTIVE_VERSION}
INACTIVE_ID=0

STAGING_CONT=nepi_staging

IMPORT_PATH=/media/nepidev/NServer_Backup
EXPORT_PATH=/mnt/nepi_storage/nepi_full_img_archive

######  NEED TO: Update from IMPORT_PATH tar file
IMAGE_FILE=nepi3p2p0-RC2A.tar
IMAGE_VERSION=3p2p0

######  NEED TO: Update from current docker status
RUNNING_CONT=None
RUNNING_VERSION=uknown
RUNNING_TAG=uknown
RUNNING_ID=0

#############################
# TOOL SELECTION
#############################

IMPORT_NEPI=0
SWITCH_NEPI=0

RUN_NEPI=0
LOGIN_NEPI=0


RUN_DEV=0
LOGIN_DEV=0
STOP_DEV=0
START_DEV=0
RESTART_DEV=0
EXPORT_DEV=0

##### NEED TO: Check if arg is passed or use default
TOOL_SELECTION=$RUN_NEPI

echo ""
echo ""
echo "Select NEPI Docker Tools option:"
select yn in 'NEPI Drive Tools' 'NEPI Docker Tools' 'NEPI Software Tools' 'NEPI Config Tools'; do
    case $yn in
        NEPI Drive Tools )  NEPI_STORAGE_TOOLS=1;;
        NEPI Docker Tools ) INTERNET_REQ=1; PARTS_REQ=1; NEPI_DOCKER_TOOLS=1;;
        NEPI Software Tools ) INTERNET_REQ=1; PARTS_REQ=1; NEPI_SOFTWARE_TOOLS=1;;
        NEPI Config Tools ) NEPI_CONFIG_Tools=1;;
    esac
    OP_SELECTION=${yn}
done

######################
# IMPORT_NEPI
######################
if [ "$IMPORT_NEPI" -eq 1 ]; then

    INSTALL_IMAGE=${IMPORT_PATH}/${IMAGE_FILE}

    #1) Stop any processes for INACTIVE_CONT
    #2) Import INSTALL_IMAGE to STAGING_CONT
    #3) Remove INACTIVE_CONT
    #4) Rename STAGING_CONT to INACTIVE_CONT

    #7) Reboot

    sudo cat $INSTALL_IMAGE | sudo docker import - ${INACTIVE_CONT}:${IMAGE_VERSION}
    NACTIVE_TAG=$IMAGE_VERSION
    INACTIVE_VERSION=$IMAGE_VERSION
    INACTIVE_ID=$(sudo docker images -q ${INACTIVE_CONT}:${IMAGE_VERSION})
    echo $INACTIVE_ID

    #6) Update inactive version,tags,ids in nepi_docker_config.yaml


    echo "  ADD SOME PRINT OUTS  "


fi


######################
# SWITCH_NEPI
######################
if [ "$SWITCH_NEPI" -eq 1 ]; then

    #5) Switch active/inactive containers in nepi_docker_config.yaml 
    #6) Update active/inactive version,tags,ids in nepi_docker_config.yaml
    #7) Update Docker Compose

fi

######################
# RUN_NEPI
######################
if [ "$RUN_NEPI" -eq 1 ]; then
    #Run NEPI Complete
    sudo docker run --rm --privileged -e UDEV=1 --user nepi --gpus all \
    --mount type=bind,source=/mnt/nepi_storage,target=/mnt/nepi_storage \
    -it --net=host --runtime nvidia -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix/:/tmp/.X11-unix \
    ${ACTIVE_CONT}:${ACTIVE_TAG} /bin/bash \
    -c "/nepi_engine_start.sh"
fi

######################
# LOGIN_NEPI
######################
f [ "$LOGIN_NEPI" -eq 1 ]; then
    # Connect to a Running Container
    sudo docker exec -it ${ACTIVE_ID} /bin/bash

fi



######################
# RUN_DEV
######################
f [ "$RUN_DEV" -eq 1 ]; then

#Run NEPI in Dev Mode
sudo docker run --privileged -e UDEV=1 --user nepi --gpus all --mount type=bind,source=/mnt/nepi_storage,target=/mnt/nepi_storage --mount type=bind,source=/dev,target=/dev -it --net=host --runtime nvidia -v /tmp/.X11-unix/:/tmp/.X11-unix ${ACTIVE_CONT}:${ACTIVE_TAG} /bin/bash



fi


######################
# STOP_DEV
######################
f [ "$STOP_DEV" -eq 1 ]; then


fi

######################
# START_DEV
######################
f [ "$START_DEV" -eq 1 ]; then


fi

######################
# RESTART_DEV
######################
f [ "$RESTART_DEV" -eq 1 ]; then


fi

######################
# EXPORT_DEV
######################
f [ "$EXPORT_DEV" -eq 1 ]; then


fi



'
# Run Nepi RUI
sudo docker run --rm -it --net=host -v /tmp/.X11-unix/:/tmp/.X11-unix ${ACTIVE_CONT}:${ACTIVE_TAG} /bin/bash -c "/nepi_rui_start.sh"

# Start a Singular Contanier with Docker Compose
sudo docker compose up ID...

# Remove Singular Contanier with Docker Compose
sudo docker rm ${ACTIVE_ID}

# Remove Singular Network with Docker Compose
sudo docker network rm ${ACTIVE_ID}

# How to See Running Docker Compose Containers
sudo docker compose ps -a

# How to See Running Docker Networks
sudo     docker network ls


//sudo docker images -a
//sudo docker ps -a

sudo docker start ${ACTIVE_ID}  # restart it in the background
//sudo docker attach nepi_test  # reattach the terminal & stdin




Clone container
sudo docker ps -a
Get <ID>
sudo docker commit <ID> nepi1

# Clean out <none> Images
sudo docker rmi $(sudo docker images -f “dangling=true” -q)

# Export/Import Flat Image as tar
sudo docker export a1e4e38c2162 > /mnt/nepi_storage/tmp/nepi3p0p4p1_jp5p0p2.tar
'