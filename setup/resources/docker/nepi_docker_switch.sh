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

CONFIG_SOURCE=$(dirname "$(pwd)")/nepi_docker_config.yaml
source $(pwd)/load_docker_config.sh
wait

if [ $? -eq 1 ]; then
    echo "Failed to load ${CONFIG_SOURCE}"
    exit 1
fi



########################

  
### SET INACTIVE DATA AS ACTIVE DATA
update_yaml_value "ACTIVE_NAME" "${INACTIVE_NAME}" "${CONFIG_SOURCE}"
update_yaml_value "ACTIVE_VERSION" "${INACTIVE_VERSION}" "${CONFIG_SOURCE}"
update_yaml_value "ACTIVE_UPLOAD_DATE" "${INACTIVE_UPLOAD_DATE}" "${CONFIG_SOURCE}"
update_yaml_value "ACTIVE_TAG" "${INACTIVE_TAG}" "${CONFIG_SOURCE}"
update_yaml_value "ACTIVE_ID" "${INACTIVE_ID}" "${CONFIG_SOURCE}"
update_yaml_value "ACTIVE_ID" "${INACTIVE_LABEL}" "${CONFIG_SOURCE}"

### SET ACTIVE DATA AS INACTIVE DATA
update_yaml_value "INACTIVE_NAME" "${ACTIVE_NAME}" "${CONFIG_SOURCE}"
update_yaml_value "INACTIVE_VERSION" "${ACTIVE_VERSION}" "${CONFIG_SOURCE}"
update_yaml_value "INACTIVE_UPLOAD_DATE" "${ACTIVE_UPLOAD_DATE}" "${CONFIG_SOURCE}"
update_yaml_value "INACTIVE_TAG" "${ACTIVE_TAG}" "${CONFIG_SOURCE}"
update_yaml_value "INACTIVE_ID" "${ACTIVE_ID}" "${CONFIG_SOURCE}"
update_yaml_value "ACTIVE_ID" "${ACTIVE_LABEL}" "${CONFIG_SOURCE}"


########################
# Update NEPI Docker Variables from nepi_docker_config.yaml

########################

#######
# Start Switched Container
#  . ./start_nepi_docker


