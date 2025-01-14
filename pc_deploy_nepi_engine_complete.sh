#!/bin/bash
##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##

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
#    NEPI_TARGET_USERNAME: Target username
#    NEPI_SSH_KEY: Private SSH key for SSH/Rsync to target (as applicable)
#    NEPI_TARGET_SRC_DIR: Directory to deploy source code to (except _nepi_rui_, which must be located 
#                         at _/opt/nepi/nepi_rui_ as described in that submodule's README)
#######################################################################################################
if [[ -z "${NEPI_REMOTE_SETUP}" ]]; then
  echo "Must have environtment variable NEPI_REMOTE_SETUP set"
  exit 1
fi

if [ "${NEPI_REMOTE_SETUP}" == "0" ]; then
  # Generate the top-level version file
  git describe --DEV > ./src/nepi_edge_sdk_base/etc/fw_version.txt

  # Only need to copy nepi_rui to destination -- others can remain right in place
  rsync ./src/nepi_rui/ /opt/nepi/nepi_rui 
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
  if [[ -z "${NEPI_TARGET_SRC_DIR}" ]]; then
    NEPI_TARGET_SRC_DIR="/mnt/nepi_storage/nepi_src"
    echo "No NEPI_TARGET_SRC_DIR environment variable... will use default ${NEPI_TARGET_SRC_DIR}"
  fi

  # Avoid pushing local build artifacts, git stuff, and a bunch of huge GPSD stuff
  RSYNC_EXCLUDES="--exclude deploy_nepi_engine_source.sh \
  --exclude deploy_nepi_engine_3rd_party.sh \
  --exclude .git* \
  --exclude .catkin_tools/profiles/*/packages \
  --exclude build_* --exclude devel_* --exclude logs_* --exclude install_* "

  #echo "Excluding ${RSYNC_EXCLUDES}"

  # Also generate the top-level version file here locally while we have a complete git repository
  git describe --dirty > ./src/nepi_edge_sdk_base/etc/fw_version.txt

# Push everything but the EXCLUDES to the specified source folder on the target
rsync -avzhe "ssh -i ${NEPI_SSH_KEY} -o StrictHostKeyChecking=no"  ${RSYNC_EXCLUDES} ../nepi_engine_ws/ ${NEPI_TARGET_USERNAME}@${NEPI_TARGET_IP}:${NEPI_TARGET_SRC_DIR}/nepi_engine_ws

fi
