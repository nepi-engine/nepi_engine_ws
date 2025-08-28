#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##


# This file Switches a Running Containers
source /home/${USER}/.nepi_bash_utils
wait
NEPI_DOCKER_CONFIG_FILE=/mnt/nepi_config/docker_cfg/nepi_docker_config.yaml

########################
# Update NEPI Docker Variables from nepi_docker_config.yaml
refresh_nepi
wait
########################
  
### SET INACTIVE DATA AS ACTIVE DATA
update_yaml_value ACTIVE_CONT "$INACTIVE_CONT" $NEPI_DOCKER_CONFIG_FILE
update_yaml_value "ACTIVE_VERSION" "$INACTIVE_VERSION" "$NEPI_DOCKER_CONFIG_FILE"
update_yaml_value "ACTIVE_UPLOAD_DATE" "$INACTIVE_UPLOAD_DATE" "$NEPI_DOCKER_CONFIG_FILE"
update_yaml_value "ACTIVE_TAG" "$INACTIVE_TAG" "$NEPI_DOCKER_CONFIG_FILE"
update_yaml_value "ACTIVE_ID" "$INACTIVE_ID" "$NEPI_DOCKER_CONFIG_FILE"

### SET ACTIVE DATA AS INACTIVE DATA
update_yaml_value "INACTIVE_CONT" "$ACTIVE_CONT" "$NEPI_DOCKER_CONFIG_FILE"
update_yaml_value "INACTIVE_VERSION" "$ACTIVE_VERSION" "$NEPI_DOCKER_CONFIG_FILE"
update_yaml_value "INACTIVE_UPLOAD_DATE" "$ACTIVE_UPLOAD_DATE" "$NEPI_DOCKER_CONFIG_FILE"
update_yaml_value "INACTIVE_TAG" "$ACTIVE_TAG" "$NEPI_DOCKER_CONFIG_FILE"
update_yaml_value "INACTIVE_ID" "$ACTIVE_ID" "$NEPI_DOCKER_CONFIG_FILE"

########################
# Update NEPI Docker Variables from nepi_docker_config.yaml
refresh_nepi
wait
########################

#######
# Start Switched Container
#  . ./start_nepi_docker


