#!/bin/bash
#
# Copyright (c) 2024 Numurus <https://www.numurus.com>.
#
# This file is part of nepi engine ws (nepi_engine_ws) repo
# (see https://github.com/nepi-engine/nepi_engine_ws)
#
# License: NEPI Engine WS Tools and NEPI software deployed and/or compiled with these tools
# are licensed under the "Numurus Software License", 
# which can be found at: <https://numurus.com/wp-content/uploads/Numurus-Software-License-Terms.pdf>
#
# Redistributions in source code must retain this top-level comment block.
# Plagiarizing this software to sidestep the license obligations is illegal.
#
# Contact Information:
# ====================
# - mailto:nepi@numurus.com
#

success=1


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
if [[ ! -v NEPI_INTERFACES_BUILD ]]; then
  NEPI_INTERFACES_BUILD=/mnt/nepi_storage/nepi_src/nepi_engine_ws/build_release/nepi_interfaces
fi
if [[ ! -v NEPI_CONFIG ]]; then
    NEPI_CONFIG=/mnt/nepi_config
fi
if [[ ! -v NEPI_BASE ]]; then
    NEPI_BASE=/opt/nepi
fi
if [[ ! -v NEPI_API ]]; then
    NEPI_API=/opt/nepi/nepi_engine/lib/python3/dist-packages/nepi_api
fi
if [[ ! -v NEPI_APPS ]]; then
    NEPI_APPS=/opt/nepi/nepi_engine/share/nepi_apps/params
fi
if [[ ! -v NEPI_RUI ]]; then
    NEPI_RUI=${NEPI_BASE}/nepi_rui
fi
if [[ ! -v NEPI_RUI_SRC ]]; then
    NEPI_RUI_SRC=${NEPI_BASE}/nepi_rui/src/rui_webserver/rui-app/src
fi
if [[ ! -v NEPI_RUI_APPS ]]; then
    NEPI_RUI_APPS=${NEPI_BASE}/nepi_rui/src/rui_webserver/rui-app/src/apps
fi
if [[ ! -v NEPI_ENGINE ]]; then
    NEPI_ENGINE=${NEPI_BASE}/nepi_engine
fi
if [[ ! -v NEPI_ETC ]]; then
    NEPI_ETC=${NEPI_BASE}/etc
fi


export SETUPTOOLS_USE_DISTUTILS=stdlib




NEPI_ENGINE_SRC_ROOTDIR=`pwd`
HIGHLIGHT='\033[1;34m' # LIGHT BLUE
ERROR='\033[0;31m' # RED
CLEAR='\033[0m'


printf "\n${HIGHLIGHT}***** Build/Install NEPI Engine *****${CLEAR}\n"


export CONFIG_USER=$(id -un 1000)


BUILD_FOLDER=$(cd -P "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)



#####################################
###### NEPI Engine #####
##################
system_source_config="${NEPI_CONFIG}/system_cfg/src"
build_src_folder="${BUILD_FOLDER}"



echo "Updating NEPI source from system config folder ${system_source_config}"

if [[ -d $system_source_config ]]; then
  echo "Clearing __pycache__ folders in ${system_source_config} "
  find ${system_source_config} -type d -name "__pycache__" -exec sudo rm -rf {} +
  for dir in "$system_source_config"/*/; do
      # Remove trailing slash for cleaner output
      dir=${dir%/}
      folder="${dir##*/}"
      source_path=${system_source_config}/${folder}
      dest_path=${build_src_folder}/${folder}
      echo "Copying system src files from ${source_path} to ${dest_path}"
      if [[ -d $dest_path ]]; then
        sudo cp -r -p ${source_path}/* ${dest_path}/
        sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $dest_path
        echo "Copied system src files from ${source_path} to ${dest_path}"
      fi
  done
fi




echo "Clearing __pycache__ folders in ${BUILD_FOLDER}/src/ "
find ${BUILD_FOLDER}/src/ -type d -name "__pycache__" -exec sudo rm -rf {} +



# if [[ -d ${NEPI_APPS} ]]; then
#   sudo rm -r ${NEPI_APPS}/* 2> /dev/null 
# fi

if [[ -d ${NEPI_INTERFACES_BUILD} ]]; then
  sudo rm -r ${NEPI_INTERFACES_BUILD}/* 2> /dev/null
fi

cd $BUILD_FOLDER

printf "\n${HIGHLIGHT}*** Starting NEPI Engine Build ***${CLEAR}\n"
sudo chmod 775 ${BUILD_FOLDER}/../nepi_engine_ws
sudo chmod 775 -R ${NEPI_BASE}/nepi_rui/src/rui_webserver/rui-app/src

ncores=$(nproc)
catkin build --profile=release --env-cache -j -p$ncores #-v
printf "\n${HIGHLIGHT} *** NEPI Engine Build Finished ***${CLEAR}\n"





echo "Updating firmware version file"
BUILD_DATE=$(date +%Y%m%d)
fwv=$(nfws)
fwv="${fwv%%-*}"
fwv="${fwv%%_*}"
fwv="${fwv//./p}"
fwv="${fwv}_${BUILD_DATE}"
nfwu "$fwv"


#####################################

