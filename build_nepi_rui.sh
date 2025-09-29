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

# It also assumes that preliminary NEPI RUI and NEPI BOT build environment setup is complete. See
# https://github.com/nepi-engine/nepi_rui
# https://github.com/nepi-engine/nepi-bot
# for details

# Note, this script deploys the RUI to on host system and builds the components sequentially. It may be more efficient for you to
# run these steps in parallel in different terminals. Similarly, once everything has been built
# once for a system, it will be more efficient to build individual components that are modified.


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

# RUI build



NEPI_ENGINE_SRC_ROOTDIR=`pwd`
HIGHLIGHT='\033[1;34m' # LIGHT BLUE
ERROR='\033[0;31m' # RED
CLEAR='\033[0m'


#####################################
######       NEPI RUI Files          #####\
# RUI deploy

sudo rsync -arp ./src/nepi_rui ${NEPI_BASE}
printf "\n${HIGHLIGHT}*** NEPI RUI Deploy Finished ***\n"

######       NEPI RUI           #####
printf "\n${HIGHLIGHT}*** Starting NEPI RUI Build ***${CLEAR}\n"
if ! [ -f ${NEPI_RUI}/venv/bin/activate ]; then
  printf "\n${ERROR}Appears preliminary RUI build setup steps have not been completed... skipping this package\n"
  printf "See nepi_rui/README.md for setup instructions ${CLEAR}\n"
else
  cd $NEPI_RUI
  source ${NEPI_HOME}/.nvm/nvm.sh
  source ./devenv.sh
  cd src/rui_webserver/rui-app/
  npm run build
  deactivate
  cd ${NEPI_ENGINE_SRC_ROOTDIR}
  printf "\n${HIGHLIGHT}*** NEPI RUI Build Finished *** ${CLEAR}\n"
fi

#####################################


