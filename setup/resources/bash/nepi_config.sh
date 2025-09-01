#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##


# This File Loads and Exports NEPI Config Variables from a 
#echo "#################################"
#echo "STARTING NEPI CONFIG UPDATE"
#echo "#################################"

if [[ -v NEPI_UTILS_SOURCED ]]; then
    source /home/${USER}/.nepi_bash_utils
    wait
fi

#echo "Got NEPI Config Source File: ${NEPI_CONFIG_FILE}"
if [[ ! -v NEPI_CONFIG_FILE ]]; then
    export NEPI_CONFIG_FILE=$(pwd)/nepi_config.yaml
fi
#echo "Using NEPI Config Source File: ${NEPI_CONFIG_FILE}"
export SYSTEMD_SERVICE_PATH=/etc/systemd/system

########################
# Help Msg Initialization
#########################

CONFIGN="#############################
## NEPI Config Settings ##
#############################"


function update_config_val(){
    export_yaml_value "${1}" "${1}" "$NEPI_CONFIG_FILE"
}

keys=($(yq e 'keys | .[]' ${NEPI_CONFIG_FILE}))
for key in "${keys[@]}"; do
    update_config_val $key
    CONFIGN="${CONFIGN}
    ${key}=${!key}"
done

function confign(){
    echo "$CONFIGN"
}
export -f confign

#echo "NEPI Config Updated"
########################
