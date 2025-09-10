#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##


# This file configigues an installed NEPI File System

echo "########################"
echo "NEPI SYSTEM CONFIG SETUP"
echo "########################"

# Load System Config File
SCRIPT_FOLDER=$(pwd)
cd $(dirname $(pwd))/config
source load_system_config.sh
wait
cd $SCRIPT_FOLDER

if [ $? -eq 1 ]; then
    echo "Failed to load ${SYSTEM_CONFIG_FILE}"
    exit 1
fi




