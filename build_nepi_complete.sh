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

# Note, this script builds the components sequentially. It may be more efficient for you to
# run these steps in parallel in different terminals. Similarly, once everything has been built
# once for a system, it will be more efficient to build individual components that are modified.

# You can skip build/install of specific components with -s <component>
# where <component> is
#   sdk
#   rui
# Repeat -s <component> for additional components to skip

export SETUPTOOLS_USE_DISTUTILS=stdlib


NEPI_ENGINE_SRC_ROOTDIR=`pwd`
HIGHLIGHT='\033[1;34m' # LIGHT BLUE
ERROR='\033[0;31m' # RED
CLEAR='\033[0m'

DO_SDK=1
DO_RUI=1

# Parse args
while getopts s: arg 
do
  case $arg in
  s)  
    case ${OPTARG} in
      sdk | SDK)
        DO_SDK=0;;
      rui | RUI)
        DO_RUI=0;;
      *) 
        printf "${ERROR}Unknown component to skip: %s... exiting\n${CLEAR}" ${OPTARG}
        exit 1;;
    esac;;
  
  ?)  printf "${ERROR}Unexpected argument... exiting\n${CLEAR}"
      exit 1;;
  esac
done

printf "\n${HIGHLIGHT}***** Build/Install NEPI Engine *****${CLEAR}\n"

#####################################
###### NEPI Config Files #####
printf "\n${HIGHLIGHT}*** Copying NEPI Config folder to /opt/nepi/ ***${CLEAR}\n"
NEPI_RUI_TARGET_SRC_DIR="/opt/nepi/"
sudo cp -R ./src/nepi_engine/nepi_env/config ${NEPI_RUI_TARGET_SRC_DIR}
printf "\n${HIGHLIGHT}*** NEPI Config Deploy Finished *** \n"


#####################################
###### NEPI Engine #####
if [ "${DO_SDK}" -eq "1" ]; then
  printf "\n${HIGHLIGHT}*** Starting NEPI Engine Build ***${CLEAR}\n"
  catkin build --profile=release
  printf "\n${HIGHLIGHT} *** NEPI Engine Build Finished ***${CLEAR}\n"
else
  printf "\n${HIGHLIGHT}*** Skipping NEPI Engine SDK Build by User Request ***${CLEAR}\n"
fi


#####################################
######       NEPI Auto Scripts           #####
# Auto Scripts deploy
printf "\n${HIGHLIGHT}*** Copying NEPI Auto Scripts to NEPI config folder /opt/nepi/config/auto_scripts ***${CLEAR}\n"
NEPI_AUTO_TARGET_SRC_DIR="/opt/nepi/config/auto_scripts"
sudo cp -R ./src/nepi_engine/nepi_auto_scripts/ ${NEPI_AUTO_TARGET_SRC_DIR}
printf "\n${HIGHLIGHT}*** Copying NEPI Auto Scripts to NEPI user folder /mnt/nepi_storage/automation_scripts ***${CLEAR}\n"
NEPI_AUTO_TARGET_USER_DIR="/mnt/nepi_storage/automation_scripts"
sudo cp -R ./src/nepi_engine/nepi_auto_scripts/ ${NEPI_AUTO_TARGET_USER_DIR}
printf "\n${HIGHLIGHT}*** NEPI Auto Scripts Deploy Finished ***\n"


#####################################
######       NEPI RUI           #####\
# RUI deploy
NEPI_RUI_TARGET_SRC_DIR="/opt/nepi/"
sudo cp -R ./src/nepi_engine/nepi_rui/ ${NEPI_RUI_TARGET_SRC_DIR}
printf "\n${HIGHLIGHT}*** NEPI RUI Deploy Finished *** \n"

if [ "${DO_RUI}" -eq "1" ]; then 
  printf "\n${HIGHLIGHT}*** Starting NEPI RUI Build ***${CLEAR}\n"
  if ! [ -f /opt/nepi/nepi_rui/venv/bin/activate ]; then
    printf "\n${ERROR}Appears preliminary RUI build setup steps have not been completed... skipping this package\n"
    printf "See nepi_rui/README.md for setup instructions ${CLEAR}\n"
  else
    cd /opt/nepi/nepi_rui
    source ~/.nvm/nvm.sh
    source ./devenv.sh
    cd src/rui_webserver/rui-app/
    npm run build
    deactivate
    cd ${NEPI_ENGINE_SRC_ROOTDIR}
    printf "\n${HIGHLIGHT}*** NEPI RUI Build Finished *** ${CLEAR}\n"
  fi
else
  printf "\n${HIGHLIGHT}*** Skipping NEPI RUI Build by User Request ***${CLEAR}\n"
fi

#####################################


