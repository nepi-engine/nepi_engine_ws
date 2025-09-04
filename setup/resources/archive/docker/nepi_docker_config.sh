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


#First Export the nepi_config.yaml entries

#Next Export the docker_config.yaml entries




        ########################
        # Help Msg Initialization
        #########################

        CONFIGD="#############################
        ## NEPI Config Settings ##
        #############################"


        function update_config_val(){
            export_yaml_value "${1}" "${1}" "$NEPI_CONFIG_FILE"
        }


        NEPI_CONFIG_FILE=$(pwd)/nepi_config.yaml
        DOCKER_CONFIG_FILE=$(pwd)/docker_config.yaml

        if [[ -f "$NEPI_CONFIG_FILE" ]]; then

            keys=($(yq e 'keys | .[]' ${NEPI_CONFIG_FILE}))
            for key in "${keys[@]}"; do
                update_config_val $key
                CONFIGN="${CONFIGN}
                ${key}=${!key}"
            done

            if [[ -f "$DOCKER_CONFIG_FILE" ]]; then

                keys=($(yq e 'keys | .[]' ${DOCKER_CONFIG_FILE}))
                for key in "${keys[@]}"; do
                    update_config_val $key
                    CONFIGN="${CONFIGN}
                    ${key}=${!key}"
                done
            fi

        function configd(){
            echo "$CONFIGD"
        }
        export -f configd


#echo "NEPI Config Updated"
########################
