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
echo "NEPI ENGINE CLEAR"
echo "########################"

# Load System Config File
SCRIPT_FOLDER=$(pwd)
cd $(dirname $(pwd))/config
source load_system_config.sh
if [ $? -eq 1 ]; then
    echo "Failed to load ${SYSTEM_CONFIG_FILE}"
    cd $SCRIPT_FOLDER
    exit 1
fi
cd $SCRIPT_FOLDER


# This script deletes all nepi folders/files in the nepi system
cd /opt/nepi/nepi_engine
sudo find . -type d -name 'nepi_*' -exec rm -rf {} +
sudo chown -R nepi:nepi ./*
# Run Nepi deploy and build complete scripts to rebuild system

