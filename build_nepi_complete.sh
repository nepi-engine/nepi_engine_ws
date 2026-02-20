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
# NEPI Engine Build/Install Script
# This script is a convenience to build/install all nepi-engine components at once.
# Users can optionally skip specific components

# Note, this script assumes that basic NEPI engine filesystem setup and dependency installation
# has already been completed. See
# https://github.com/nepi-engine/nepi_rootfs_tools
# for details.

# It also assumes that preliminary NEPI RUI and NEPI BOT build environment setup is complete. See
# https://github.com/nepi_rui
# for details

# Note, this script builds the components sequentially. It may be more efficient for you to
# run these steps in parallel in different terminals. Similarly, once everything has been built
# once for a system, it will be more efficient to build individual components that are modified.

# You can skip build/install of specific components with -s <component>
# where <component> is
#   sdk
#   rui
# Repeat -s <component> for additional components to skip

nepistop

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
        success=0
    esac;;
  
  ?)  printf "${ERROR}Unexpected argument... exiting\n${CLEAR}"
      success=0
  esac
done

printf "\n${HIGHLIGHT}***** Build/Install NEPI Engine *****${CLEAR}\n"


export CONFIG_USER=$(id -un 1000)





####################################
# Run NEPI Bash Setup Script

SCRIPT_FOLDER=$(cd -P "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
script_file=nepi_bash_setup.sh
script_path=${SCRIPT_FOLDER}/nepi_setup/scripts/${script_file}
if ! source_script $script_path; then
    script_error=$?
    echo "Script ${script_path} failed with error ${script_error}"
    success=0 
fi


####################################
# Run NEPI Folder Setup Script
SCRIPT_FOLDER=$(cd -P "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
script_file=nepi_folders_setup.sh
script_path=${SCRIPT_FOLDER}/nepi_setup/scripts/${script_file}
if ! source_script $script_path; then
    script_error=$?
    echo "Script ${script_path} failed with error ${script_error}"
    success=0 
fi


####################################
# Run NEPI Files Setup Script
SCRIPT_FOLDER=$(cd -P "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
script_file=nepi_files_setup.sh
script_path=${SCRIPT_FOLDER}/nepi_setup/scripts/${script_file}
if ! source_script $script_path; then
    script_error=$?
    echo "Script ${script_path} failed with error ${script_error}"
    success=0 
fi

####################################
# Run NEPI Config Setup Script
SCRIPT_FOLDER=$(cd -P "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
script_file=nepi_setup.sh
script_path=${SCRIPT_FOLDER}/nepi_setup/scripts/${script_file}
if ! source_script $script_path; then
    script_error=$?
    echo "Script ${script_path} failed with error ${script_error}"
    success=0 
fi


#####################################
###### NEPI Engine #####

if [[ -d ${NEPI_APPS} ]]; then
  sudo rm -r ${NEPI_APPS}/*
fi

if [[ -d ${NEPI_INTERFACES_BUILD} ]]; then
  sudo rm -r ${NEPI_INTERFACES_BUILD}/*
fi

if [ "${DO_RUI}" -eq "1" ]; then 
  sudo rm -r ${NEPI_RUI_APPS}/*

  system_rui_config="${NEPI_CONFIG}/system_cfg/nepi_rui"
  if [[ ! -d "${system_rui_config}" ]]; then
    sudo mkdir $system_rui_config
  fi
  if [[ ! -d "${system_rui_config}/assets" ]]; then
    sudo mkdir ${system_rui_config}/assets
  fi

  if [[ -d "${system_rui_config}" ]]; then
    sudo cp ${NEPI_RUI_SRC}/MainMenuDeploy.js ${system_rui_config}/
    if [[ -d "${system_rui_config}/assets" ]]; then
      sudo cp ${NEPI_RUI_SRC}/assets/logo.webp ${system_rui_config}/assets/
    fi
    sudo chown -R ${CONFIG_USER}:${CONFIG_USER} $system_rui_config
  fi

fi

if [ "${DO_SDK}" -eq "1" ]; then
  printf "\n${HIGHLIGHT}*** Starting NEPI Engine Build ***${CLEAR}\n"

  ncores=$(nproc)
  catkin build --profile=release --env-cache -j -p$ncores #-v
  printf "\n${HIGHLIGHT} *** NEPI Engine Build Finished ***${CLEAR}\n"
else
  printf "\n${HIGHLIGHT}*** Skipping NEPI Engine by User Request ***${CLEAR}\n"
fi


#####################################
######       NEPI RUI           #####\
# RUI build

if [ "${DO_RUI}" -eq "1" ]; then 

  SCRIPT_FOLDER=$(cd -P "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
  script_file=build_nepi_rui.sh
  script_path=${SCRIPT_FOLDER}/${script_file}
  if ! source_script $script_path; then
      script_error=$?
      echo "Script ${script_path} failed with error ${script_error}"
  fi

else
  printf "\n${HIGHLIGHT}*** Skipping NEPI RUI Build by User Request ***${CLEAR}\n"
fi

#####################################



