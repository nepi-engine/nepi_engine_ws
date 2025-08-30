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
NEPI_DOCKER_CONFIG_FILE=${NEPI_CONFIG}/docker_cfg/nepi_config.yaml

##############################
# NEPI Settings
##############################
#export USER_NAME=nepi
read_yaml_value "NEPI_USER" "USER_NAME" "$NEPI_DOCKER_CONFIG_FILE"
#echo $USER_NAME
#export NEPI_DEVICE_ID=device1
read_yaml_value "NEPI_DEVICE_ID" "NEPI_DEVICE_ID" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_DEVICE_ID
#export NEPI_BOOT_DEVICE=container
read_yaml_value "NEPI_BOOT_DEVICE" "NEPI_BOOT_DEVICE" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_BOOT_DEVICE
#export NEPI_FS_DEVICE=container
read_yaml_value "NEPI_FS_DEVICE" "NEPI_FS_DEVICE" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_FS_DEVICE
#export NEPI_STORAGE_DEVICE=container
read_yaml_value "NEPI_STORAGE_DEVICE" "NEPI_STORAGE_DEVICE" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_STORAGE_DEVICE
#export NEPI_HW_TYPE=JETSON
read_yaml_value "NEPI_HW_TYPE" "NEPI_HW_TYPE" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_HW_TYPE
#export NEPI_HW_MODEL=ORIN
read_yaml_value "NEPI_HW_MODEL" "NEPI_HW_MODEL" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_HW_MODEL
#export NEPI_PYTHON=3.8
read_yaml_value "NEPI_PYTHON" "NEPI_PYTHON" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_PYTHON
#export NEPI_ROS=NOETIC
read_yaml_value "NEPI_ROS" "NEPI_ROS" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_ROS
#export NEPI_IN_CONTAINER=0
read_yaml_value "NEPI_IN_CONTAINER" "NEPI_IN_CONTAINER" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_IN_CONTAINER
#export NEPI_HAS_CUDA=1
read_yaml_value "NEPI_HAS_CUDA" "NEPI_HAS_CUDA" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_HAS_CUDA
#export NEPI_HAS_XPU=0
read_yaml_value "NEPI_HAS_XPU" "NEPI_HAS_XPU" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_HAS_XPU
#export NEPI_MANAGES_SSH=1
read_yaml_value "NEPI_MANAGES_SSH" "NEPI_MANAGES_SSH" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_MANAGES_SSH
#export NEPI_MANAGES_SHARE=1
read_yaml_value "NEPI_MANAGES_SHARE" "NEPI_MANAGES_SHARE" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_MANAGES_SHARE
##############################
# NEPI Network Config
##############################
#export NEPI_MANAGES_NETWORK=1
read_yaml_value "NEPI_MANAGES_NETWORK" "NEPI_MANAGES_NETWORK" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_MANAGES_NETWORK
#export NEPI_IP=192.168.179.103
read_yaml_value "NEPI_IP" "NEPI_IP" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_IP
#export NEPI_TCP_PORTS=[]
read_yaml_value "NEPI_TCP_PORTS" "NEPI_TCP_PORTS" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_TCP_PORTS
#export NEPI_UDP_PORTS=[]
read_yaml_value "NEPI_UDP_PORTS" "NEPI_UDP_PORTS" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_UDP_PORTS
#export NEPI_IP_ALIASES=
read_yaml_value "NEPI_IP_ALIASES" "NEPI_IP_ALIASES" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_IP_ALIASES
##############################
# NEPI TIME Config
##############################
#export NEPI_MANAGES_TIME=1
read_yaml_value "NEPI_MANAGES_TIME" "NEPI_MANAGES_TIME" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_MANAGES_TIME
#export NEPI_NTP_SOURCES=[]
read_yaml_value "NEPI_NTP_SOURCES" "NEPI_NTP_SOURCES" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_NTP_SOURCES
##############################
# NEPI Folder Config
##############################
#export NEPI_DOCKER=/mnt/nepi_docker
read_yaml_value "NEPI_DOCKER" "NEPI_DOCKER" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_DOCKER
#export NEPI_STORAGE=/mnt/nepi_storage
read_yaml_value "NEPI_STORAGE" "NEPI_STORAGE" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_STORAGE
#export NEPI_CONFIG=/mnt/nepi_config
read_yaml_value "NEPI_CONFIG" "NEPI_CONFIG" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_CONFIG
#export NEPI_ENV=nepi_env
read_yaml_value "NEPI_ENV" "NEPI_ENV" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_ENV
#export NEPI_HOME=/home/nepi
read_yaml_value "NEPI_HOME" "NEPI_HOME" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_HOME
#export NEPI_BASE=/opt/nepi
read_yaml_value "NEPI_BASE" "NEPI_BASE" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_BASE
#export NEPI_RUI=/opt/nepi/nepi_rui
read_yaml_value "NEPI_RUI" "NEPI_RUI" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_RUI
#export NEPI_ENGINE=/opt/nepi/nepi_engine
read_yaml_value "NEPI_ENGINE" "NEPI_ENGINE" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_ENGINE
#export NEPI_ETC=/opt/nepi/etc
read_yaml_value "NEPI_ETC" "NEPI_ETC" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_ETC
#export NEPI_SCRIPTS=/opt/nepi/scripts
read_yaml_value "NEPI_SCRIPTS" "NEPI_SCRIPTS" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_SCRIPTS
#export NEPI_CODE=/mnt/nepi_storage/code
read_yaml_value "NEPI_CODE" "NEPI_CODE" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_CODE
#export NEPI_SRC=/mnt/nepi_storage/nepi_src
read_yaml_value "NEPI_SRC" "NEPI_SRC" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_SRC
#export NEPI_IMAGE_INSTALL=
read_yaml_value "NEPI_IMAGE_INSTALL" "NEPI_IMAGE_INSTALL" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_IMAGE_INSTALL
#export NEPI_IMAGE_ARCHIVE=
read_yaml_value "NEPI_IMAGE_ARCHIVE" "NEPI_IMAGE_ARCHIVE" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_IMAGE_ARCHIVE
#export NEPI_USR_CONFIG=/mnt/nepi_storage/user_cfg
read_yaml_value "NEPI_USR_CONFIG" "NEPI_USR_CONFIG" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_USR_CONFIG
#export NEPI_DOCKER_CONFIG=/mnt/nepi_config/docker_cfg
read_yaml_value "NEPI_DOCKER_CONFIG" "NEPI_DOCKER_CONFIG" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_DOCKER_CONFIG
#export NEPI_FACTORY_CONFIG=/mnt/nepi_config/factory_cfg
read_yaml_value "NEPI_FACTORY_CONFIG" "NEPI_FACTORY_CONFIG" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_FACTORY_CONFIG
#export NEPI_SYSTEM_CONFIG=/mnt/nepi_config/system_cfg
read_yaml_value "NEPI_SYSTEM_CONFIG" "NEPI_SYSTEM_CONFIG" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_SYSTEM_CONFIG
#export NEPI_ALIASES_FILE=.nepi_system_aliases
read_yaml_value "NEPI_ALIASES_FILE" "NEPI_ALIASES_FILE" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_ALIASES_FILE
#export NEPI_AB_FS=1
read_yaml_value "NEPI_AB_FS" "NEPI_AB_FS" "$NEPI_DOCKER_CONFIG_FILE"
#echo $ACTIVENEPI_AB_FS_NAME
##############################
# NEPI Docker Docker System Variables
##############################
#export NEPI_ACTIVE_NAME=nepi_fs_a
read_yaml_value "NEPI_ACTIVE_NAME" "NEPI_ACTIVE_NAME" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_ACTIVE_NAME
#export NEPI_ACTIVE_VERSION=3p2p0
read_yaml_value "NEPI_ACTIVE_VERSION" "NEPI_ACTIVE_VERSION" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_ACTIVE_VERSION
#export NEPI_ACTIVE_TAG=JETSON-3p2p0}
read_yaml_value "NEPI_ACTIVE_TAG" "NEPI_ACTIVE_TAG" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_ACTIVE_TAG
#export NEPI_ACTIVE_ID=0
read_yaml_value "NEPI_ACTIVE_ID" "NEPI_ACTIVE_ID" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_ACTIVE_ID
#export NEPI_ACTIVE_LABEL=uknown
read_yaml_value "NEPI_ACTIVE_LABEL" "NEPI_ACTIVE_LABEL" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_ACTIVE_LABEL
#export NEPI_INACTIVE_NAME=nepi_fs_b
read_yaml_value "NEPI_INACTIVE_NAME" "NEPI_INACTIVE_NAME" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_INACTIVE_NAME
#export NEPI_INACTIVE_VERSION=uknown
read_yaml_value "NEPI_INACTIVE_VERSION" "NEPI_INACTIVE_VERSION" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_INACTIVE_VERSION
#export NEPI_INACTIVE_TAG=JETSON-uknown
read_yaml_value "NEPI_INACTIVE_TAG" "NEPI_INACTIVE_TAG" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_INACTIVE_TAG
#export NEPI_INACTIVE_ID=0
read_yaml_value "NEPI_INACTIVE_ID" "NEPI_INACTIVE_ID" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_INACTIVE_ID
#export NEPI_INACTIVE_LABEL=uknown
read_yaml_value "NEPI_INACTIVE_LABEL" "NEPI_INACTIVE_LABEL" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_INACTIVE_LABEL
#export NEPI_STAGING_NAME=nepi_fs_staging
read_yaml_value "NEPI_STAGING_NAME" "NEPI_STAGING_NAME" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_STAGING_NAME
##############################
# Running NEPI Container Info
##############################
#export NEPI_RUNNING=0
read_yaml_value "NEPI_RUNNING" "NEPI_RUNNING" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_RUNNING
#export NEPI_RUNNING_NAME=None
read_yaml_value "NEPI_RUNNING_NAME" "NEPI_RUNNING_NAME" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_RUNNING_NAME
#export NEPI_RUNNING_VERSION=uknown
read_yaml_value "NEPI_RUNNING_VERSION" "NEPI_RUNNING_VERSION" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_RUNNING_VERSION
#export NEPI_RUNNING_TAG=uknown
read_yaml_value "NEPI_RUNNING_TAG" "NEPI_RUNNING_TAG" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_RUNNING_TAG
#export NEPI_RUNNING_ID=0
read_yaml_value "NEPI_RUNNING_ID" "NEPI_RUNNING_ID" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_RUNNING_ID
#export NEPI_RUNNING_LABEL=0
read_yaml_value "NEPI_RUNNING_LABEL" "NEPI_RUNNING_LABEL" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_RUNNING_LABEL
##############################
# Boot Fail Config
##############################
#export NEPI_MAX_COUNT=3
read_yaml_value "NEPI_MAX_COUNT" "NEPI_MAX_COUNT" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_MAX_COUNT
#export NEPI_FAIL_COUNT=0
read_yaml_value "NEPI_FAIL_COUNT" "NEPI_FAIL_COUNT" "$NEPI_DOCKER_CONFIG_FILE"
#echo $NEPI_FAIL_COUNT

########################
