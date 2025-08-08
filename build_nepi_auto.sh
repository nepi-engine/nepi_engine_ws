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

# Auto Scripts build


NEPI_ENGINE_SRC_ROOTDIR=`pwd`
HIGHLIGHT='\033[1;34m' # LIGHT BLUE
ERROR='\033[0;31m' # RED
CLEAR='\033[0m'


#####################################
######       NEPI Auto Scripts           #####
# Auto Scripts deploy
printf "\n${HIGHLIGHT}*** Copying NEPI Auto Scripts to NEPI config folder /opt/nepi/config/auto_scripts ***${CLEAR}\n"
NEPI_AUTO_TARGET_SRC_DIR="/opt/nepi/config/auto_scripts"
sudo cp -R ./src/nepi_auto_scripts/ ${NEPI_AUTO_TARGET_SRC_DIR}
printf "\n${HIGHLIGHT}*** Copying NEPI Auto Scripts to NEPI user folder /mnt/nepi_storage/automation_scripts ***${CLEAR}\n"
NEPI_AUTO_TARGET_USER_DIR="/mnt/nepi_storage/automation_scripts"
sudo cp -R ./src/nepi_auto_scripts/ ${NEPI_AUTO_TARGET_USER_DIR}
printf "\n${HIGHLIGHT}*** NEPI Auto Scripts Deploy Finished ***\n"

#####################################


