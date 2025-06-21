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

REPOS=" nepi_engine nepi_drivers nepi_ai_frameworks nepi_apps nepi_3rd_party/nepi_gpsd_ros_client"

if [[ -z "${NEPI_REMOTE_SETUP}" ]]; then
  echo "Must have environtment variable NEPI_REMOTE_SETUP set"
  exit 1
fi

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
RSYNC_EXCLUDES=" --exclude pc_deploy_nepi_engine_complete.sh \
--exclude .git \
--exclude .gitmodules \
--exclude .catkin_tools/profiles/*/packages \
--exclude devel_* --exclude logs_* --exclude install_* "

echo "Excluding ${RSYNC_EXCLUDES}"

echo "Syncing NEPI build tools"
rsync -avzhe "ssh -i ${NEPI_SSH_KEY} -o StrictHostKeyChecking=no"  --exclude='*/' ${RSYNC_EXCLUDES} ./* ${NEPI_TARGET_USERNAME}@${NEPI_TARGET_IP}:${NEPI_TARGET_SRC_DIR}/nepi_engine_ws/

CATKIN=".catkin_tools"
echo "Syncing repo ${CATKIN}"
# Push everything but the EXCLUDES to the specified source folder on the target
rsync -avzhe "ssh -i ${NEPI_SSH_KEY} -o StrictHostKeyChecking=no"  ${RSYNC_EXCLUDES} ./${CATKIN} ${NEPI_TARGET_USERNAME}@${NEPI_TARGET_IP}:${NEPI_TARGET_SRC_DIR}/nepi_engine_ws/
rsync -avzhe "ssh -i ${NEPI_SSH_KEY} -o StrictHostKeyChecking=no"  ${RSYNC_EXCLUDES} ./${CATKIN} ${NEPI_TARGET_USERNAME}@${NEPI_TARGET_IP}:/opt/nepi/ros/

for REPO in $REPOS; do

  echo "Syncing repo ${REPO}"
  # Push everything but the EXCLUDES to the specified source folder on the target
  rsync -avzhe "ssh -i ${NEPI_SSH_KEY} -o StrictHostKeyChecking=no"  ${RSYNC_EXCLUDES} ./src/${REPO} ${NEPI_TARGET_USERNAME}@${NEPI_TARGET_IP}:${NEPI_TARGET_SRC_DIR}/nepi_engine_ws/src/

done
