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

### ADD TO nepi_docker_aliases #################################################################
HELPN="
#############################
## NEPI Help Info ##
#############################"

########################
# Variable Initailization
#########################

# HW OPTIONS [JETSON,ARM,AMD,RPI]
export NEPI_HW=JETSON

arch_hw=arm64
if [ $NEPI_HW -eq JETSON ]; then
  arch_hw=arm64
fi
if [ $NEPI_HW -eq ARM ]; then
  arch_hw=arm64
fi
if [ $NEPI_HW -eq AMD ]; then
  arch_hw=amd64
fi
if [ $NEPI_HW -eq RPI ]; then
  arch_hw=rpi
fi
export NEPI_ARCH=$arch_hw

# NEED TO: Set to $NEPI_DOCKER_CONFIG from ???
export NEPI_DOCKER_CONFIG=${PWD}/nepi_docker_config.yaml

## NEED TO: Read these from nepi_config.yaml file
export ACTIVE_CONT=nepi_fs_a
export ACTIVE_VERSION=3p2p0-RC2
#ACTIVE_TAG=$(create_tag $NEPI_HW $ACTIVE_VERSION)
export ACTIVE_TAG=jetson-3p2p0-rc2
export ACTIVE_ID=$(sudo docker images -q ${ACTIVE_CONT}:${ACTIVE_TAG})

export INACTIVE_CONT=nepi_fs_b
export INACTIVE_VERSION=uknown
export INACTIVE_TAG=$(create_tag $NEPI_HW $INACTIVE_VERSION)
export INACTIVE_ID=$(sudo docker images -q ${INACTIVE_CONT}:${INACTIVE_TAG})

export STAGING_CONT=nepi_staging

export IMPORT_PATH=/media/nepidev/NServer_Backup
export EXPORT_PATH=/mnt/nepi_storage/nepi_full_img_archive

######  NEED TO: Update from current docker status
export RUNNING_CONT=None
export RUNNING_VERSION=uknown
export RUNNING_TAG=uknown
export RUNNING_ID=0


#### Update Help Test
HELPN="${HELPN}

### NEPI DOCKER CONFIG

NEPI_HW=${NEPI_HW}
NEPI_ARCH=${NEPI_ARCH}
NEPI_DOCKER_CONFIG=${NEPI_DOCKER_CONFIG}

ACTIVE_CONT=${ACTIVE_CONT}
ACTIVE_VERSION-eq${ACTIVE_VERSION}
ACTIVE_TAG=${ACTIVE_TAG}
ACTIVE_ID=${ACTIVE_ID}

INACTIVE_CONT=${INACTIVE_CONT}
INACTIVE_VERSION=${INACTIVE_VERSION}
INACTIVE_TAG=${INACTIVE_TAG}
INACTIVE_ID=${INACTIVE_ID}

STAGING_CONT=${STAGING_CONT}
IMPORT_PATH=${IMPORT_PATH}
EXPORT_PATH=${EXPORT_PATH}

RUNNING_CONT=${RUNNING_CONT}
RUNNING_VERSION=${RUNNING_VERSION}
RUNNING_TAG=${RUNNING_TAG}
RUNNING_ID=${RUNNING_ID}"


######################
# Utility Functions
######################
function upate_yaml_value(){
    KEY=$1
    #echo $ELEMENT1
    VAL=$2
    #echo $ELEMENT2
    FILE=$3
    
    yq e -i '.'"$KEY"' = env(VAL)' $FILE
}

function create_tag(){
    HW_NAME=$1
    SW_VERSION=$2
    tag=${HW_NAME}-${SW_VERSION}
    ltag=sed -e 's/\(.*\)/\L\1/' <<< "$tag"
    echo "$ltag"
}   

#### Update Help Test
HELPN="${HELPN}

### NEPI FILE UTIL FUNCTIONS

write_to_yaml - Udates yaml key value given KEY VAL FILE
create_tag - Creates a nepi standardized tag given HW_NAME SW_VERSION"



#############################
# NEPI DOCKER FUNCTIONS
#############################

######################
# IMPORT_NEPI
######################
if [ "$IMPORT_NEPI" -eq 1 ]; then
    IMPORT_PATH=/media/nepidev/NServer_Backup
    ###### NEED TO GET LIST OF AVAILABLE TARS and Select Image
    IMAGE_FILE=nepi-jetson-3p2p0-rc2.tar
    ######  NEED TO: Update from IMPORT_PATH tar file
    IMAGE_VERSION=3p2p0
    
    ######
    INSTALL_IMAGE=${IMPORT_PATH}/${IMAGE_FILE}
    #1) Stop any processes for INACTIVE_CONT
    #2) Import INSTALL_IMAGE to STAGING_CONT
    #3) Remove INACTIVE_CONT
    #4) Rename STAGING_CONT to INACTIVE_CONT



    res=$(sudo docker import $INSTALL_IMAGE)
    hash=${res##*sha256:}
    ID=${hash:0:12}
    NAME=$(sudo docker name $ID)
    TAG=$(sudo docker tag $ID)
    NEW_NAME=$INACTIVE_CONT
    NEW_TAG=$TAG
    sudo docker tag ${NAME}:${TAG} ${NEW_NAME}:${NEW_TAG}
    sudo docker rmi ${NAME}:${TAG}
    
    INACTIVE_TAG=$NEW_TAG
    INACTIVE_ID=$(sudo docker images -q ${INACTIVE_CONT}:${INACTIVE_TAG})

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
    --mount type=bind,source=/dev,target=/dev \
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
f [ $RUN_DEV -eq 1 ]; then

    
    #Run NEPI in Dev Mode
    sudo docker run --privileged -e UDEV=1 --user nepi --gpus all \
    --mount type=bind,source=/mnt/nepi_storage,target=/mnt/nepi_storage \
    --mount type=bind,source=/dev,target=/dev \
    -it --net=host --runtime nvidia \
    -v /tmp/.X11-unix/:/tmp/.X11-unix \
    ${ACTIVE_CONT}:${ACTIVE_TAG} /bin/bash

fi


######################
# STOP_DEV
######################
f [ "$STOP_DEV" -eq 1 ]; then
    yq e '.NEPI_HW' nepi_docker_config.yaml

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

######################
# READ_DOCKER_CONFIG
######################
function ffile(){
    yq e -i '.' nepi_docker_config.yaml 
}


#### Update Help Test
HELPN="${HELPN}

### NEPI FILE UTIL FUNCTIONS

"


'
# Remove Image
sudo docker rmi <image_id>
or
sudo docker rmi <image_name>:<image_id>

NAME=nepi_fs_a
TAG=JETSON_3p2p0
sudo docker rmi ${NAME}:${TAG}


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

# export Flat Image as tar


# Change image name and tag
IMAGE_NAME=nepi_fs_b
IMAGE_TAG=3p2p0
NEW_NAME=nepi_fs_a
NEW_TAG=JETSON-3p2p0
sudo docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${NEW_NAME}:${NEW_TAG}
sudo docker rmi ${IMAGE_NAME}:${IMAGE_TAG}