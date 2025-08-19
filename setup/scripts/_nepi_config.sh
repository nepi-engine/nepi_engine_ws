##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##


# This file sets up the setup variables for a NEPI file system


# NEPI Hardware Host Options: GENERIC,JETSON,RPI
NEPI_HW=JETSON

# PYTHON VERSION
PYTHON_VERSION=3.8

# NEPI HOST SETTINGS
NEPI_IN_CONTAINER=0
NEPI_HAS_CUDA=1
NEPI_HAS_XPU=0

# NEPI Managed Resources. Set to 0 to turn off NEPI management of this resouce
# Note, if enabled for a docker deployment, these system functions will be
# disabled in the host OS environment
NEPI_MANAGES_SSH=1
NEPI_MANAGES_SHARE=1
NEPI_MANAGES_TIME=1
NEPI_MAGAGES_NETWORK=1


###################################
# System Setup Variables
##################################
NEPI_IP=192.168.179.103
NEPI_USER=nepi

# NEPI PARTITIONS
NEPI_DOCKER=/mnt/nepi_docker
NEPI_STORAGE=/mnt/nepi_storage
NEPI_CONFIG=/mnt/nepi_config

DOCKER_MIN_GB=50
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
NEPI_SCRIPTS=${NEPI_BASE}/scripts

SYSTEMD_SERVICE_PATH=/etc/systemd/system

NEPI_ALIASES_FILE=.nepi_system_aliases

#################
# NEPI Storage Folders

declare -A STORAGE

STORAGE['nepi_docker']=${NEPI_DOCKER}
STORAGE['nepi_storage']=${NEPI_STORAGE}
STORAGE['nepi_config']=${NEPI_CONFIG}

STORAGE['data']=${NEPI_STORAGE}/data
STORAGE['ai_models']=${NEPI_STORAGE}/ai_models
STORAGE['ai_training']=${NEPI_STORAGE}/ai_training
STORAGE['automation_scripts']=${NEPI_STORAGE}/automation_scripts
STORAGE['databases']=${NEPI_STORAGE}/databases
STORAGE['install']=${NEPI_STORAGE}/install
STORAGE['license']=${NEPI_STORAGE}/install
STORAGE['nepi_src']=${NEPI_STORAGE}/nepi_srcacc
STORAGE['nepi_full_img']=${NEPI_STORAGE}/nepi_full_img
STORAGE['nepi_full_img_archive']=${NEPI_STORAGE}/nepi_full_img_archive
STORAGE['sample_data']=${NEPI_STORAGE}/sample_data
STORAGE['tmp']=${NEPI_STORAGE}/tmp

STORAGE['user_cfg']=${NEPI_STORAGE}/user_cfg
STORAGE['docker_cfg']=${NEPI_CONFIG}/docker_cfg
STORAGE['factory_cfg']=${NEPI_CONFIG}/factory_cfg
STORAGE['system_cfg']=${NEPI_CONFIG}/system_cfg

SETUP_SCRIPTS_PATH=./
sudo chmod +x ${SETUP_SCRIPTS_PATH}/*

