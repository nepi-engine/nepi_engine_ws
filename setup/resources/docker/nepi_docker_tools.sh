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


########################
# Variable Initailization
#########################
export NEPI_HW=JETSON

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
    sudo docker run --privileged -e UDEV=1 --user nepi --gpus all \
    --mount type=bind,source=/mnt/nepi_storage,target=/mnt/nepi_storage \
    --mount type=bind,source=/dev,target=/dev -it --net=host --runtime nvidia \
    -v /tmp/.X11-unix/:/tmp/.X11-unix \
    ${ACTIVE_CONT}:${ACTIVE_TAG} \
    /bin/bash



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

######################
# Utility Functions
######################
function write_to_yaml(){
    ELEMENT1=$1
    #echo $ELEMENT1
    ELEMENT2=$2
    #echo $ELEMENT2

    yq e -i '.'"$ELEMENT1"' = env(ELEMENT2)' nepi_docker_config.yaml
}

function create_tag(){
    hw=$1
    ver=$2
    tag=${hw}-${ver}
    ltag=sed -e 's/\(.*\)/\L\1/' <<< "$tag"
    echo "$ltag"
}   



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