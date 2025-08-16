#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##


# This file sets up NEPI File System on a device hosted a nepi file system 
# or inside a ubuntu docker container


# NEPI Hardware Host Options: GENERIC,JETSON,RPI
if [[ ! -v NEPI_HW ]]; then
    # NEPI Hardware Host Options: GENERIC,JETSON,RPI
    NEPI_HW=JETSON


    ###################################
    # System Setup Variables
    ##################################
    NEPI_IP=192.168.179.103
    NEPI_USER=nepi

    # NEPI PARTITIONS
    NEPI_DOCKER=/mnt/nepi_docker
    NEPI_STORAGE=/mnt/nepi_storage
    NEPI_CONFIG=/mnt/nepi_config

    FS_MIN_GB=50
    STORAGE_MIN_GB=150
    CONFIG_MIN_GB=1

    ##########################
    # Process Folders
    CURRENT_FOLDER=$PWD

    ##########################
    # NEPI File System 
    NEPI_HOME=/home/${NEPI_USER}
    NEPI_BASE=/opt/nepi
    NEPI_RUI=${NEPI_BASE}/nepi_rui
    NEPI_ENGINE=${NEPI_BASE}/nepi_engine
    NEPI_ETC=${NEPI_BASE}/etc

    SYSTEMD_SERVICE_PATH=/etc/systemd/system

    #################
    # NEPI Storage Folders

    declare -A STORAGE
    STORAGE['data']=${NEPI_STORAGE}/data
    STORAGE['ai_models']=${NEPI_STORAGE}/ai_models
    STORAGE['ai_training']=${NEPI_STORAGE}/ai_training
    STORAGE['automation_scripts']=${NEPI_STORAGE}/automation_scripts
    STORAGE['databases']=${NEPI_STORAGE}/databases
    STORAGE['install']=${NEPI_STORAGE}/install
    STORAGE['nepi_src']=${NEPI_STORAGE}/nepi_src
    STORAGE['nepi_full_img']=${NEPI_STORAGE}/nepi_full_img
    STORAGE['nepi_full_img_archive']=${NEPI_STORAGE}/nepi_full_img_archive
    STORAGE['sample_data']=${NEPI_STORAGE}/sample_data
    STORAGE['user_cfg']=${NEPI_STORAGE}/user_cfg
    STORAGE['tmp']=${NEPI_STORAGE}/tmp

    STORAGE['nepi_cfg']=${NEPI_CONFIG}/nepi_cfg
    STORAGE['factory_cfg']=${NEPI_CONFIG}/factory_cfg

    NEPI_ETC_SOURCE=./../etc
    NEPI_ALIASES_SOURCE=./../aliases/.nepi_system_aliases
    NEPI_ALIASES=${NEPI_HOME}/.nepi_system_aliases
    BASHRC=${NEPI_HOME}/.bashrc
fi





