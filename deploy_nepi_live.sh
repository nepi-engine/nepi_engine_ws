#!/bin/bash
#
# Copyright (c) 2024 Numurus <https://www.numurus.com>.
#
# This file is part of nepi engine ws (${NEPI_REPO_NAME}) repo
# (see https://github.com/nepi-engine/${NEPI_REPO_NAME})
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

dclean=$1
echo $dclean
DCLEAN=0
if [[ $dclean -eq 1 ]]; then
  DCLEAN=1
fi

CONFIG_USER=$(id -un)
buid_folder=$(pwd)

#######################################################################################################
# Usage: $ ./deploy_nepi_engine_complete.sh
#
# This script copies the complete nepi_engine source code to proper filesystem locations on target
# hardware in preparation for building nepi-engine from source. 
#
# It can be run from a development host or directly on the target hardware as described in this
# repository's README
#
build_folder=$(pwd)
# The script requires the following environment variable be set
#    NEPI_REMOTE_SETUP: Indicates whether running from development host or directly on target 
#                      (1 = Dev. Host, 0 = From Target)
# In the case that NEPI_REMOTE_SETUP == 1, some further environment variables must be set
#    NEPI_TARGET_IP: Target IP address/hostname
     NEPI_TARGET_IP=${NEPI_IP} #/${NEPI_DEVICE_ID}
     echo "Using target IP: ${NEPI_TARGET_IP}"
#    NEPI_DEPLOY_USERNAME: Target username

     if [[ "$NEPI_MODE" == 'HOST' ]]; then
        NEPI_DEPLOY_USERNAME=$CONFIG_USER
     else
        NEPI_DEPLOY_USERNAME=nepihost
     fi
    NEPI_LIVE_USER=nepi

#    NEPI_SSH_KEY: Private SSH key for SSH/Rsync to target (as applicable)
     NEPI_SSH_KEY=/home/${USER}/.ssh/nepi_default_ssh_key
#    NEPI_TARGET_SRC_DIR: Directory to deploy source code to
     NEPI_TARGET_SRC_DIR=/mnt/nepi_storage/nepi_src
#    NEPI_SETUP_SRC_DIR: Directory to deploy setup source to
     NEPI_SETUP_SRC_DIR=/home/${NEPI_DEPLOY_USERNAME}


#######################################################################################################
# # Clear known hosts keys
# sudo rm /home/${CONFIG_USER}/.ssh/known*
########################################




if [[ ! -v DEPLOY_3RD_PARTY ]]; then
  DEPLOY_3RD_PARTY=0
fi

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

if [[ ! -v NEPI_REPO_NAME  ]]; then
  NEPI_REPO_NAME='nepi_engine_ws'
fi

NEPI_SSH_KEY=/home/${CONFIG_USER}/.ssh/nepi_default_ssh_key
if [[ ! -v NEPI_SSH_KEY_PATH ]]; then
  NEPI_SSH_KEY_PATH=$NEPI_SSH_KEY
fi

if [[ ! -v NEPI_REPO_FOLDER ]]; then
  NEPI_REPO_FOLDER=/home/${CONFIG_USER}/${NEPI_REPO_NAME}
fi

if [[ -z "${NEPI_REMOTE_SETUP}" ]]; then
  echo "Must have environtment variable NEPI_REMOTE_SETUP set"
  return 
fi

if [ "${NEPI_REMOTE_SETUP}" == "0" ]; then
  echo "Running in Local Mode"

elif [ "${NEPI_REMOTE_SETUP}" == "1" ]; then

  if ! pingn; then
    echo ""NEPI Device Not Connected""
    return 
  fi
  echo $NEPI_TARGET_IP
  if [[ -z "${NEPI_TARGET_IP}" ]]; then
    echo "Remote setup requires env. variable NEPI_TARGET_IP be assigned"
    return 
  fi
  if [[ -z "${NEPI_DEPLOY_USERNAME}" ]]; then
    echo "Remote setup requires env. variable NEPI_DEPLOY_USERNAME be assigned"
    return 
  fi

  if [[ -z "${NEPI_SSH_KEY}" ]]; then
    echo "Remote setup requires env. variable NEPI_SSH_KEY be assigned"
    return 
  fi
  ssh-keygen -f "/home/${CONFIG_USER}/.ssh/known_hosts" -R "${NEPI_TARGET_IP}"
fi


if [ "${NEPI_REMOTE_SETUP}" == "0" ]; then
    sudo -v
elif [ "${NEPI_REMOTE_SETUP}" == "1" ]; then
    sshnhc
fi



echo "Starting NEPI source-code deploy process"
if [[ $NEPI_REMOTE_SETUP -eq 1 ]]; then
  echo "Running in REMOTE mode"
else
  echo "Running in LOCAL mode"
fi



cd $NEPI_REPO_FOLDER
fw_version=$(dev_version_string $(git tag --sort=v:refname | tail -1))
echo ${fw_version}
echo ${fw_version} > ${build_folder}/src/nepi_engine/nepi_env/etc/fw_version.txt 



echo ""
echo "--------------------------------------------"
echo "DEPLOYING LIVE UPDATES"
echo ""

REPO_FOLDER=$(cd -P "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
DEPLOY_FOLDER=${NEPI_ENGINE}

function deploy_live_update() {
  source_path=$1
  dest_path=$2
  echo "Deploying ${source_name} from ${source_path}"
  #echo "  to NEPI live folder ${dest_path}:" 
  RSYNC_EXCLUDES=" --exclude .git --exclude .gitmodules --exclude empty.txt"
  rsync -avzhe "ssh -i ${NEPI_SSH_KEY} -o StrictHostKeyChecking=no -p 2222" ${RSYNC_EXCLUDES} ${source_path}/* ${NEPI_LIVE_USER}@${NEPI_TARGET_IP}:${dest_path}/ >/dev/null
  if [[ $? -ne 0 ]]; then
    if [ "${NEPI_REMOTE_SETUP}" == "0" ]; then
      host_ip="localhost"
    elif [ "${NEPI_REMOTE_SETUP}" == "1" ]; then
      host_ip=$NEPI_TARGET_IP
    fi
    echo "Failed connect to a running NEPI container on host: ${host_ip}"
    echo "Live Updates Failed"
    return 1
  fi
}


LIVE_SUCCESS=1
###############################################
# Live Deploy Nepi Managers
###############################################
DEPLOY_NAME=nepi_managers
SOURCE_PATH=$REPO_FOLDER/${DEPLOY_NAME}
DEST_PATH=${DEPLOY_FOLDER}/lib/${dest_name}
if [[ $LIVE_SUCCESS -eq 1 ]]; then
  if ! deploy_live_update $SOURCE_PATH $DEST_PATH; then
    LIVE_SUCCESS=0
  fi
fi

DEPLOY_NAME=nepi_sdk
SOURCE_PATH=$REPO_FOLDER/${DEPLOY_NAME}
DEST_PATH=${DEPLOY_FOLDER}/lib/python3/dist-packages/nepi_sdk
if [[ $LIVE_SUCCESS -eq 1 ]]; then
  if ! deploy_live_update $SOURCE_PATH $DEST_PATH; then
    LIVE_SUCCESS=0
  fi
fi

DEPLOY_NAME=nepi_api
SOURCE_PATH=$REPO_FOLDER/${DEPLOY_NAME}
DEST_PATH=${DEPLOY_FOLDER}/lib/python3/dist-packages/nepi_api
if [[ $LIVE_SUCCESS -eq 1 ]]; then
  if ! deploy_live_update $SOURCE_PATH $DEST_PATH; then
    LIVE_SUCCESS=0
  fi
fi


# ###############################################
# # Live Deploy Drivers
# ###############################################
DEPLOY_NAME=nepi_drivers
SOURCE_PATH=$REPO_FOLDER/${DEPLOY_NAME}
DEST_PATH=${DEPLOY_FOLDER}/lib/nepi_drivers
if [[ $LIVE_SUCCESS -eq 1 ]]; then
  for dir in "$SOURCE_PATH"/*/; do
      # Ensure the directory actually exists (handles empty folders safely)
      if [[ -d "$dir" && "$dir" != "${SOURCE_PATH}/src/"  && "$dir" != "${SOURCE_PATH}/scripts/" ]]; then
        deploy_live_update $dir $DEST_PATH
      fi
  done
fi



# ###############################################
# # Live Deploy AI Frameworks
# ###############################################
DEPLOY_NAME=nepi_ai_frameworks
SOURCE_PATH=$REPO_FOLDER/${DEPLOY_NAME}
if [[ $LIVE_SUCCESS -eq 1 ]]; then
  for dir in "$SOURCE_PATH"/*/; do
      # Ensure the directory actually exists (handles empty folders safely)
      if [[ -d "$dir" && "$dir" != "${SOURCE_PATH}/nepi_ai_training/" ]]; then
        source_path=${dir}scripts
        dest_name=$(basename ${dir})
        DEST_PATH=${DEPLOY_FOLDER}/lib/${dest_name}
        deploy_live_update $source_path $DEST_PATH

        source_path=${dir}api
        dest_name=$(basename ${dir})
        DEST_PATH=${DEPLOY_FOLDER}/lib/python3/dist-packages/nepi_api
        deploy_live_update $source_path $DEST_PATH

        source_path=${dir}params
        dest_name=$(basename ${dir})
        DEST_PATH=${DEPLOY_FOLDER}/share/nepi_aifs
        deploy_live_update $source_path $DEST_PATH
      fi
  done
fi

# ###############################################
# # Live Deploy Apps
# ###############################################
DEPLOY_NAME=nepi_apps
SOURCE_PATH=$REPO_FOLDER/${DEPLOY_NAME}
if [[ $LIVE_SUCCESS -eq 1 ]]; then
  for dir in "$SOURCE_PATH"/*/; do
      # Ensure the directory actually exists (handles empty folders safely)
      if [[ -d "$dir" && "$dir" != "${deploy_folder}/src/"  && "$dir" != "${deploy_folder}/scripts/" ]]; then
        source_path=${dir}scripts
        dest_name=$(basename ${dir})
        DEST_PATH=${DEPLOY_FOLDER}/lib/${dest_name}
        deploy_live_update $source_path $DEST_PATH

        source_path=${dir}api
        dest_name=$(basename ${dir})
        DEST_PATH=${DEPLOY_FOLDER}/lib/python3/dist-packages/nepi_api
        deploy_live_update $source_path $DEST_PATH

        source_path=${dir}params
        dest_name=$(basename ${dir})
        DEST_PATH=${DEPLOY_FOLDER}/share/nepi_apps/params
        deploy_live_update $source_path $DEST_PATH
      fi
  done
fi