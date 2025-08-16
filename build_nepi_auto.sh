##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##

# NEPI Engine Build/Install Script
# This script is a convenience to build/install all nepi-engine components at once.
# Users can optionally skip specific components

# Note, this script assumes that basic NEPI engine filesystem setup and dependency installation
# has already been completed. See
# https://github.com/nepi-engine/nepi_rootfs_tools
# for details.


# Note, this script deploys the Auto Scripts to on host system


# Set NEPI folder variables if not configured by nepi aliases bash script
if [[ ! -v NEPI_USER ]]; then
    NEPI_USER=nepi
fi
if [[ ! -v NEPI_HOME ]]; then
    NEPI_HOME=/home/${NEPI_USER}
fi
if [[ ! -v NEPI_DOCKER ]]; then
    NEPI_DOCKER=/mnt/nepi_docker
fi
if [[ ! -v NEPI_STORAGE ]]; then
   NEPI_STORAGE=/mnt/nepi_storage
fi
if [[ ! -v NEPI_CONFIG ]]; then
    NEPI_CONFIG=/mnt/nepi_config
fi
if [[ ! -v NEPI_BASE ]]; then
    NEPI_BASE=/opt/nepi
fi
if [[ ! -v NEPI_RUI ]]; then
    NEPI_RUI=${NEPI_BASE}/nepi_rui
fi
if [[ ! -v NEPI_ENGINE ]]; then
    NEPI_ENGINE=${NEPI_BASE}/nepi_engine
fi
if [[ ! -v NEPI_ETC ]]; then
    NEPI_ETC=${NEPI_BASE}/etc
fi

# Auto Scripts build


NEPI_ENGINE_SRC_ROOTDIR=`pwd`
HIGHLIGHT='\033[1;34m' # LIGHT BLUE
ERROR='\033[0;31m' # RED
CLEAR='\033[0m'


#####################################
######       NEPI Auto Scripts           #####
printf "\n${HIGHLIGHT}*** Copying NEPI Auto Scripts to NEPI Storage ***${CLEAR}\n"
NEPI_AUTO_TARGET_USER_DIR="${NEPI_STORAGE}/automation_scripts"
sudo cp -R ./src/nepi_auto_scripts/ ${NEPI_AUTO_TARGET_USER_DIR}
printf "\n${HIGHLIGHT}*** NEPI Auto Scripts Deploy Finished ***\n"

#####################################


