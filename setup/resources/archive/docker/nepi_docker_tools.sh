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

### ADD TO nepi_bash_utils #################################################################



######################
# FILE Functions
######################
function upate_yaml_value(){
    KEY=$1
    #echo $ELEMENT1
    VAL=$2
    #echo $ELEMENT2
    FILE=$3
    yq e -i '.'"$KEY"' = env(VAL)' $FILE
}
export -f upate_yaml_value

function read_yaml_value(){
    VARIABLE=$1
    #echo=$VARIABLE
    KEY=$2
    #echo=$KEY
    FILE=$3
    #echo=$FILE
    export $VARIABLE=$(yq e '.'"$KEY"'' $FILE)
    yq e '.NEPI_HW' nepi_docker_config.yaml
    #echo $VARIABLE
}
export -f read_yaml_value



#### Update Help Test
UTILSN="${UTILSN}

### NEPI FILE UTIL FUNCTIONS

write_to_yaml - Udates yaml key value given KEY VAL FILE"


### ADD TO nepi_docker_aliases #################################################################
#############################
# NEPI DOCKER FUNCTIONS
#############################

######################
# IMPORT_NEPI
######################

function create_tag(){
    HW_NAME=$1
    SW_VERSION=$2
    tag=${HW_NAME}-${SW_VERSION}
    ltag=sed -e 's/\(.*\)/\L\1/' <<< "$tag"
    echo "$ltag"
}
export -f create_tag

function import_nepi(){
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
}
export -f import_nepi


######################
# SWITCH_NEPI
######################
function switch_nepi(){

    #5) Switch active/inactive containers in nepi_docker_config.yaml 
    #6) Update active/inactive version,tags,ids in nepi_docker_config.yaml
    #7) Update Docker Compose

}
export -f switch_nepi

######################
# RUN_NEPI
######################
function run_nepi(){
    #Run NEPI Complete
    sudo docker run --rm --privileged -e UDEV=1 --user nepi --gpus all \
    --mount type=bind,source=/mnt/nepi_storage,target=/mnt/nepi_storage \
    --mount type=bind,source=/dev,target=/dev \
    -it --net=host --runtime nvidia -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix/:/tmp/.X11-unix \
    ${ACTIVE_CONT}:${ACTIVE_TAG} /bin/bash \
    -c "/nepi_engine_start.sh"
}
export -f run_nepi

######################
# LOGIN_NEPI
######################
function login_nepi(){
    # Connect to a Running Container
    sudo docker exec -it ${ACTIVE_ID} /bin/bash
}
export -f login_nepi



######################
# RUN_DEV
######################
function run_dev(){
    #Run NEPI in Dev Mode
    sudo docker run --privileged -e UDEV=1 --user nepi --gpus all \
    --mount type=bind,source=/mnt/nepi_storage,target=/mnt/nepi_storage \
    --mount type=bind,source=/dev,target=/dev \
    -it --net=host --runtime nvidia \
    -v /tmp/.X11-unix/:/tmp/.X11-unix \
    ${ACTIVE_CONT}:${ACTIVE_TAG} /bin/bash
}
export -f run_dev


######################
# STOP_DEV
######################
function stop_dev(){
    yq e '.NEPI_HW' nepi_docker_config.yaml
}
export -f stop_dev

######################
# START_DEV
######################
function start_dev(){

}
export -f start_dev

######################
# RESTART_DEV
######################
function restart_dev(){

}
export -f restart_dev

######################
# EXPORT_DEV
######################
function export_dev(){

}
export -f export_dev

######################
# READ_DOCKER_CONFIG
######################
function ffile(){
    yq e -i '.' nepi_docker_config.yaml 
}
export -f ffile


#### Update Help Test
HELPN="${HELPN}

### NEPI FILE DOCKER UTIL FUNCTIONS


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