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
#   bot
#   link
# Repeat -s <component> for additional components to skip

NEPI_ENGINE_SRC_ROOTDIR=`pwd`
HIGHLIGHT='\033[1;34m' # LIGHT BLUE
ERROR='\033[0;31m' # RED
CLEAR='\033[0m'

DO_SDK=1
DO_RUI=1
DO_BOT=1
DO_LINK=1

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
      bot | BOT)
        DO_BOT=0;;
      link | LINK)
        DO_LINK=0;;
      *) 
        printf "${ERROR}Unknown component to skip: %s... exiting\n${CLEAR}" ${OPTARG}
        exit 1;;
    esac;;
  
  ?)  printf "${ERROR}Unexpected argument... exiting\n${CLEAR}"
      exit 1;;
  esac
done

printf "\n${HIGHLIGHT}***** Build/Install NEPI Engine *****${CLEAR}\n"

###### ROS-based SDK Components #####
if [ "${DO_SDK}" -eq "1" ]; then
  printf "\n${HIGHLIGHT}*** Starting NEPI Engine ROS SDK Build ***${CLEAR}\n"
  catkin build --profile=release
  printf "\n${HIGHLIGHT} *** NEPI Engine SDK Build Finished ***${CLEAR}\n"
else
  printf "\n${HIGHLIGHT}*** Skipping NEPI Engine ROS SDK Build by User Request ***${CLEAR}\n"
fi
#####################################

######       NEPI RUI           #####
if [ "${DO_RUI}" -eq "1" ]; then 
  printf "\n${HIGHLIGHT}*** Starting NEPI RUI Build ***${CLEAR}\n"
  if ! [ -f /opt/nepi/nepi_rui/venv/bin/activate ]; then
    printf "\n${ERROR}Appears preliminary RUI build setup steps have not been completed... skipping this package\n"
    printf "See nepi_rui/README.md for setup instructions ${CLEAR}\n"
  else
    cd /opt/nepi/nepi_rui
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

######       NEPI-BOT           #####
if [ "${DO_BOT}" -eq "1" ]; then
  printf "\n${HIGHLIGHT}*** Starting NEPI-BOT Build ***${CLEAR}\n"
  if ! [ -f src/nepi-bot/utilities/venv/bin/activate ]; then
    printf "\n${ERROR}Appears preliminary NEPI-BOT build setup steps have not been completed... skipping this package\n"
    printf "See nepi-bot/README.md for setup instructions${CLEAR}\n"
  else
    cd src/nepi-bot/utilities
    source ./venv/bin/activate
    python ./create_bot_installation.py -n UNSET --install_binary /opt/nepi/nepi_link/nepi-bot
    deactivate
    cd ${NEPI_ENGINE_SRC_ROOTDIR}
    printf "\n${HIGHLIGHT}*** NEPI-BOT Build Finished ***${CLEAR}\n"
  fi
else
  printf "\n${HIGHLIGHT}*** Skipping NEPI-BOT Build by User Request ***${CLEAR}\n"
fi
#####################################

#####    NEPI_EDGE_SDK_LINK     #####
if [ "${DO_LINK}" -eq "1" ]; then
  printf "\n${HIGHLIGHT}*** Starting NEPI_EDGE_SDK_LINK Build ***${CLEAR}\n"
  cd src/nepi_edge_sdk_link
  mkdir -p build && cd build
  cmake -DCMAKE_BUILD_TYPE=Release -DINSTALL_DESTINATION=/opt/nepi/nepi_link/nepi_edge_sdk_link ..
  make install
  cd ..
  rm -rf ./build
  cd ${NEPI_ENGINE_SRC_ROOTDIR}
  printf "\n${HIGHLIGHT}*** NEPI_EDGE_SDK_LINK Build Finished ***${CLEAR}\n"
else
  printf "\n${HIGHLIGHT}*** Skipping NEPI_EDGE_SDK_LINK by User Request ***${CLEAR}\n"
fi
#####################################

printf "\n${HIGHLIGHT}***** NEPI-ENGINE BUILD/INSTALL COMPLETE *****${CLEAR}\n"


