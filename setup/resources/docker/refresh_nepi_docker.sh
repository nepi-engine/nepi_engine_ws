#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##


# This File Updates Variables from Docker Config
source /home/${USER}/.nepi_bash_utils
wait
NEPI_DOCKER_CONFIG_FILE=${NEPI_CONFIG}/docker_cfg/nepi_docker_config.yaml

########################
#export USER_NAME=nepi
read_yaml_value "NEPI_USER" "USER_NAME" "$NEPI_DOCKER_CONFIG_FILE"
#echo $USER_NAME
#export NEPI_DEVICE_ID=device1
read_yaml_value "NEPI_DEVICE_ID" "NEPI_DEVICE_ID" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_DEVICE_ID
#export NEPI_HW_TYPE=JETSON
read_yaml_value "NEPI_HW_TYPE" "NEPI_HW_TYPE" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_HW_TYPE
#export NEPI_HW_MODEL=ORIN
read_yaml_value "NEPI_HW_MODEL" "NEPI_HW_MODEL" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_HW_MODEL

#export NEPI_IP=192.168.179.103
read_yaml_value "NEPI_IP" "NEPI_IP" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_IP
#export NEPI_TPC_PORTS=(8080 2222 5003 9091)
read_yaml_value "NEPI_TPC_PORTS" "NEPI_TPC_PORTS" "$NEPI_DOCKER_CONFIG_FILE"
#export NEPI_UDP_PORTS=(123)
read_yaml_value "NEPI_UDP_PORTS" "NEPI_UDP_PORTS" "$NEPI_DOCKER_CONFIG_FILE"
#export NEPI_IP_ALIASES=[]
read_yaml_value "NEPI_IP_ALIASES" "NEPI_IP_ALIASES" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_IP_ALIASES

#export NEPI_MANAGES_CLOCK=1
read_yaml_value "NEPI_NEPI_MANAGES_CLOCK" "NEPI_MANAGES_CLOCK" "$NEPI_DOCKER_CONFIG_FILE"
#echo $MANAGES_CLOCK

#export SUPPORTS_AB_FS=1
read_yaml_value "SUPPORTS_AB_FS" "SUPPORTS_AB_FS" "$NEPI_DOCKER_CONFIG_FILE"
#echo $SUPPORTS_AB_FS
#IMPORT_PATH=/mnt/nepi_storage/nepi_images
read_yaml_value "IMPORT_PATH" "IMPORT_PATH" "$NEPI_DOCKER_CONFIG_FILE"
#echo $IMPORT_PATH
#EXPORT_PATH=/mnt/nepi_storage/nepi_images
read_yaml_value "EXPORT_PATH" "EXPORT_PATH" "$NEPI_DOCKER_CONFIG_FILE"
#echo $EXPORT_PATH

#export ACTIVE_NAME=nepi_fs_a
read_yaml_value "ACTIVE_NAME" "ACTIVE_NAME" "$NEPI_DOCKER_CONFIG_FILE"
#echo $ACTIVE_NAME
#export ACTIVE_VERSION=3p2p0-RC2
read_yaml_value "ACTIVE_VERSION" "ACTIVE_VERSION" "$NEPI_DOCKER_CONFIG_FILE"
#echo $ACTIVE_VERSION
#export ACTIVE_UPLOAD_DATE=0
read_yaml_value "ACTIVE_UPLOAD_DATE" "ACTIVE_UPLOAD_DATE" "$NEPI_DOCKER_CONFIG_FILE"
#echo $ACTIVE_UPLOAD_DATE
#export ACTIVE_TAG=jetson-3p2p0-rc2
read_yaml_value "ACTIVE_TAG" "ACTIVE_TAG" "$NEPI_DOCKER_CONFIG_FILE"
#echo $ACTIVE_TAG
#export ACTIVE_ID=0
read_yaml_value "ACTIVE_ID" "ACTIVE_ID" "$NEPI_DOCKER_CONFIG_FILE"
#echo $ACTIVE_ID

#export INACTIVE_NAME=nepi_fs_b
read_yaml_value "INACTIVE_NAME" "INACTIVE_NAME" "$NEPI_DOCKER_CONFIG_FILE"
#echo $INACTIVE_NAME
#export INACTIVE_VERSION=uknown
read_yaml_value "INACTIVE_VERSION" "INACTIVE_VERSION" "$NEPI_DOCKER_CONFIG_FILE"
#echo $INACTIVE_VERSION
#export INACTIVE_UPLOAD_DATE=0
read_yaml_value "INACTIVE_UPLOAD_DATE" "INACTIVE_UPLOAD_DATE" "$NEPI_DOCKER_CONFIG_FILE"
#echo $INACTIVE_UPLOAD_DATE
#export INACTIVE_TAG=jetson-uknown
read_yaml_value "INACTIVE_TAG" "INACTIVE_TAG" "$NEPI_DOCKER_CONFIG_FILE"
#echo $INACTIVE_TAG
#export INACTIVE_ID=0
read_yaml_value "INACTIVE_ID" "INACTIVE_ID" "$NEPI_DOCKER_CONFIG_FILE"
#echo $INACTIVE_ID

#export STAGING_NAME=nepi_fs_staging
read_yaml_value "STAGING_NAME" "STAGING_NAME" "$NEPI_DOCKER_CONFIG_FILE"
#echo $STAGING_NAME

#export RUNNING=0
read_yaml_value "RUNNING" "RUNNING" "$NEPI_DOCKER_CONFIG_FILE"
#echo $RUNNING
#export RUNNING_NAME=None
read_yaml_value "RUNNING_NAME" "RUNNING_NAME" "$NEPI_DOCKER_CONFIG_FILE"
#echo $RUNNING_NAME
#export RUNNING_VERSION=uknown
read_yaml_value "RUNNING_VERSION" "RUNNING_VERSION" "$NEPI_DOCKER_CONFIG_FILE"
#echo $RUNNING_VERSION
#export RUNNING_TAG=uknown
read_yaml_value "RUNNING_TAG" "RUNNING_TAG" "$NEPI_DOCKER_CONFIG_FILE"
#echo $RUNNING_TAG
#export RUNNING_ID=0
read_yaml_value "RUNNING_ID" "RUNNING_ID" "$NEPI_DOCKER_CONFIG_FILE"
#echo $RUNNING_ID

#export NEPI_REMOTE_SETUP=1
read_yaml_value "NEPI_REMOTE_SETUP" "NEPI_REMOTE_SETUP" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_REMOTE_SETUP

#export MAX_COUNT=3
read_yaml_value "MAX_COUNT" "MAX_COUNT" "$NEPI_DOCKER_CONFIG_FILE"
#echo $MAX_COUNT
#export FAIL_COUNT=0
read_yaml_value "FAIL_COUNT" "FAIL_COUNT" "$NEPI_DOCKER_CONFIG_FILE"
#echo $FAIL_COUNT

########################
