#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##

# This file sets up a pc side nepi develoment environment

export CONFIG_SOURCE=$(dirname "$(pwd)")/nepi_system_config.yaml
source $(pwd)/load_system_config.sh
wait

SETUP_SCRIPTS_PATH=${PWD}/scripts
sudo chmod +x ${SETUP_SCRIPTS_PATH}/*

