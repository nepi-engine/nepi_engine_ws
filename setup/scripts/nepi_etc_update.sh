#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##

#######################
# Creating nepi_config.yaml file in docker config folder
if [[ ! -v NEPI_CONFIG_FILE ]]; then
    export NEPI_CONFIG_FILE=$(pwd)/nepi_config.yaml
fi
refresh_nepi_config
wait

if [ -v ETC_FOLDER ]; then
    export ETC_FOLDER=$(dirname "$(pwd)")/resources/etc
fi

echo "Updating NEPI etc folder ${ETC_FOLDER}"
if [ ! -d "${ETC_FOLDER}" ]; then
    echo "ETC folder ${ETC_FOLDER} not found"
    exit 1
fi


# This file installs the updates a value in an etc file


function update_text_value(){
  KEY=$2
  UPDATE=$3
  FILE=$1
  if [ -f "$FILE" ]; then
    if grep -q "$KEY" "$FILE"; then
      sed -i "/^$KEY/c\\$UPDATE" "$FILE"
    else
      echo "$UPDATE" | sudo tee -a $FILE
    fi
  else
    echo "File not found ${FILE}"
  fi
}
export -f update_text_value

function update_hostname(){
    HOST_NAME_FILE=${ETC_FOLDER}/hostname
    echo $HOST_NAME_FILE
    KEY=$1
    echo $KEY
    UPDATE=$2
    echo $UPDATE
    if [ -f "$HOST_NAME_FILE" ]; then
    if grep -q "$KEY" "$HOST_NAME_FILE"; then
        sed -i "s/$KEY/$UPDATE/g" "$HOST_NAME_FILE"

    else
        echo "$UPDATE" | sudo tee -a $HOST_NAME_FILE
    fi
    else
    echo "File not found ${HOST_NAME_FILE}"
    fi
}
export -f update_hostname


##############################################
echo "NEPI ETC Update Complete"
##############################################

