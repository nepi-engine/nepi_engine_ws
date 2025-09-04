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

CONFIG_SOURCE=$(pwd)/etc/nepi_system_config.yaml
source $(pwd)/etc/load_system_config.sh
#echo $CONFIG_SOURCE
wait

if [ $? -eq 1 ]; then
    echo "Failed to load ${CONFIG_SOURCE}"
    exit 1
fi


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

