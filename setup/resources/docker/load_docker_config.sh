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

# Load System Config File
SCRIPT_FOLDER=$(pwd)
cd $(dirname $(pwd))/etc
source load_system_config.sh
if [ $? -eq 1 ]; then
    echo "Failed to load ${SYSTEM_CONFIG_FILE}"
    cd $SCRIPT_FOLDER
    exit 1
fi
cd $SCRIPT_FOLDER


FILE=$(pwd)/nepi_docker_config.yaml
 
if [[ -f "$FILE" ]]; then
    #sudo echo "Updating Docker Config file from: ${FILE}"
    keys=($(yq e 'keys | .[]' ${FILE}))
    for key in "${keys[@]}"; do
        value=$(yq e '.'"$key"'' $FILE)
        export ${key}=$value
    done
else
    echo "Config file not found ${FILE}"
    exit 1
fi

