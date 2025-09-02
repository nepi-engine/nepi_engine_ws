#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##

echo "########################"
echo "UPDATING ETC FILES FROM NEPI CONFIG"
echo "########################"

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

