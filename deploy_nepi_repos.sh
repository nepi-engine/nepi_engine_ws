#!/bin/bash
##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##


if pingn; then


  #######################################################################################################
  # Usage: $ ./deploy_nepi_engine_complete.sh
  #
  # This script copies the complete nepi_engine source code to proper filesystem locations on target
  # hardware in preparation for building nepi-engine from source. 
  #
  # It can be run from a development host or directly on the target hardware as described in this
  # repository's README
  #
  # The script requires the following environment variable be set
  #    NEPI_REMOTE_SETUP: Indicates whether running from development host or directly on target 
  #                      (1 = Dev. Host, 0 = From Target)
  # In the case that NEPI_REMOTE_SETUP == 1, some further environment variables must be set
  #    NEPI_TARGET_IP: Target IP address/hostname
      NEPI_TARGET_IP=${NEPI_IP} #/${NEPI_DEVICE_ID}
  #    NEPI_TARGET_USERNAME: Target username
      nepihost=nepi
      if [[ "$NEPI_IN_CONTAINER" -eq 1 ]]; then
        nepihost=nepihost
      fi

      NEPI_TARGET_USERNAME=${nepihost}
  #    NEPI_SSH_KEY: Private SSH key for SSH/Rsync to target (as applicable)
      NEPI_SSH_KEY=/home/${USER}/ssh_keys/nepi_engine_default_private_ssh_key
  #    NEPI_TARGET_SRC_DIR: Directory to deploy source code to
      NEPI_TARGET_SRC_DIR=/mnt/nepi_storage/nepi_src
  #    NEPI_SETUP_SRC_DIR: Directory to deploy setup source to
      NEPI_SETUP_SRC_DIR=/home/${nepihost}
  #######################################################################################################
  # # Clear known hosts keys
  # sudo rm /home/${USER}/.ssh/known*
  ########################################


  REPOS="nepi_engine nepi_rui nepi_interfaces"  # nepi_ai_frameworks" #nepi_drivers nepi_apps"


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


  if [[ -z "${NEPI_REMOTE_SETUP}" ]]; then
    echo "Must have environtment variable NEPI_REMOTE_SETUP set"
    exit 1
  fi

  if [ "${NEPI_REMOTE_SETUP}" == "0" ]; then
      echo "Running in Local Mode"

  elif [ "${NEPI_REMOTE_SETUP}" == "1" ]; then

    if [[ -z "${NEPI_TARGET_IP}" ]]; then
      echo "Remote setup requires env. variable NEPI_TARGET_IP be assigned"
      exit 1
    fi
    if [[ -z "${NEPI_TARGET_USERNAME}" ]]; then
      echo "Remote setup requires env. variable NEPI_TARGET_USERNAME be assigned"
      exit 1
    fi
    if [[ -z "${NEPI_SSH_KEY}" ]]; then
      echo "Remote setup requires env. variable NEPI_SSH_KEY be assigned"
      exit 1
    fi
  fi



  cur_dir=$(pwd)
  cd /home/${USER}/nepi_engine_ws
  fw_version=$(dev_version_string $(git tag --sort=v:refname | tail -1))
  $fw_version > ./src/nepi_engine/nepi_env/etc/fw_version.txt


  echo $(pwd)
  RSYNC_EXCLUDES=" --exclude .git --exclude .gitmodules --exclude .catkin_tools/profiles/*/packages --exclude devel_* --exclude logs_* --exclude install_* --exclude nepi_3rd_party"

  echo "Excluding ${RSYNC_EXCLUDES}"



  for REPO in $REPOS; do
    REPO_PATH="$(pwd)/src/${REPO}"
    echo "Syncing repo ${REPO} from ${REPO_PATH} to"

    echo "${NEPI_TARGET_SRC_DIR}/nepi_engine_ws/src/"
    # Push everything but the EXCLUDES to the specified source folder on the target

    if [ "${NEPI_REMOTE_SETUP}" == "0" ]; then
      rsync -arh  ${RSYNC_EXCLUDES} $(pwd)/src/${REPO} ${NEPI_TARGET_SRC_DIR}/nepi_engine_ws/src/

    elif [ "${NEPI_REMOTE_SETUP}" == "1" ]; then
      rsync -azhe "ssh -i ${NEPI_SSH_KEY} -o StrictHostKeyChecking=no" ${RSYNC_EXCLUDES} $(pwd)/src/${REPO} ${NEPI_TARGET_USERNAME}@${NEPI_TARGET_IP}:${NEPI_TARGET_SRC_DIR}/nepi_engine_ws/src/

    fi
    

  done

  echo "0.0.0" > ./src/nepi_engine/nepi_env/etc/fw_version.txt


else
  echo "NEPI Device Not Connected"
fi
