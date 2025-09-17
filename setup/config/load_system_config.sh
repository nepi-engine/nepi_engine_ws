#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##


# This file loads the nepi_system_config.yaml values

SCRIPT_FOLDER=$(cd -P "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
echo "Looking for nepi_system_config.yaml in ${SCRIPT_FOLDER}"
export SYSTEM_CONFIG_FILE=${SCRIPT_FOLDER}/nepi_system_config.yaml
 
if [[ -f "$SYSTEM_CONFIG_FILE" ]]; then
    sudo echo "Updating NEPI Config file from: ${SYSTEM_CONFIG_FILE}"
    keys=($(yq e 'keys | .[]' ${SYSTEM_CONFIG_FILE}))
    for key in "${keys[@]}"; do
        value=$(yq e '.'"$key"'' $SYSTEM_CONFIG_FILE)
        export ${key}=$value
    done
else
    echo "Config file not found ${SYSTEM_CONFIG_FILE}"
    exit 1
fi
