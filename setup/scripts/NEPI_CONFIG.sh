##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##


# This file sets up the setup variables for a NEPI file system
CURRENT_FOLDER=$PWD
SYSTEMD_SERVICE_PATH=/etc/systemd/system
PYTHON_VERSION=3.10
NUMPY_VERSION=
PYTORCH_VERSION=1.13.0

# NEPI Hardware Host Options: JETSON,RPI,ARM64,AMD64
export NEPI_HW_TYPE=JETSON
# NEPI Hardware Host Model Options: ORIN, XAVIER, TX2, NANO, RPI4, GENERIC
export NEPI_HW_MODEL=ORIN

# PYTHON VERSION
export NEPI_PYTHON=$PYTHON_VERSION

# NEPI HOST SETTINGS
export NEPI_IN_CONTAINER=0

export NEPI_HAS_CUDA=1
export NEPI_CUDA_VERSION=11.8
# Find Compatable PyTorch Version https://github.com/pytorch/pytorch/blob/main/RELEASE.md


export NEPI_HAS_XPU=0

# NEPI Managed Resources. Set to 0 to turn off NEPI management of this resouce
# Note, if enabled for a docker deployment, these system functions will be
# disabled in the host OS environment
export NEPI_MANAGES_SSH=1
export NEPI_MANAGES_SHARE=1
export NEPI_MANAGES_TIME=0
export NEPI_MANAGES_NETWORK=0

# System Setup Variables
export NEPI_IP=192.168.179.103
export NEPI_USER=nepi

# NEPI PARTITIONS
export NEPI_DOCKER=/mnt/nepi_docker
export NEPI_STORAGE=/mnt/nepi_storage
export NEPI_CONFIG=/mnt/nepi_config

DOCKER_MIN_GB=50
STORAGE_MIN_GB=150
CONFIG_MIN_GB=1

# NEPI File System 
export NEPI_ENV=nepi_env
export NEPI_HOME=/home/${NEPI_USER}
export NEPI_BASE=/opt/nepi
export NEPI_RUI=${NEPI_BASE}/nepi_rui
export NEPI_ENGINE=${NEPI_BASE}/nepi_engine
export NEPI_ETC=${NEPI_BASE}/etc
export NEPI_SCRIPTS=${NEPI_BASE}/scripts


export NEPI_DOCKER_CONFIG=${NEPI_CONFIG}/docker_cfg
export NEPI_FACTORY_CONFIG=${NEPI_CONFIG}/factory_cfg
export NEPI_SYSTEM_CONFIG=${NEPI_CONFIG}/system_cfg
export NEPI_USR_CONFIG=${NEPI_STORAGE}/user_cfg

export NEPI_CODE=${NEPI_STORAGE}/code
export NEPI_ALIASES_FILE=.nepi_system_aliases

export NEPI_AB_FS=1




