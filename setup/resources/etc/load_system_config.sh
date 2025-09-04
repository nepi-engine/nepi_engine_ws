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

FILE=$(pwd)/nepi_system_config.yaml
export NEPI_SYSTEM_CONFIG=$FILE
 
if [[ -f "$FILE" ]]; then
    sudo echo "Updating NEPI Config Yaml file from: ${FILE}"
    keys=($(yq e 'keys | .[]' ${FILE}))
    for key in "${keys[@]}"; do
        value=$(yq e '.'"$key"'' $FILE)
        export ${key}=$value
    done
else
    echo "Config file not found ${FILE}"
fi

