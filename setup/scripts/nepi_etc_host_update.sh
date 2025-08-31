#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##


# This file installs the NEPI Engine File System installation


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


##############################################
echo "NEPI ETC Update Complete"
##############################################
