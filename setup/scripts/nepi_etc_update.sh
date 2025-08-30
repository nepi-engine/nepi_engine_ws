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

source /home/${USER}/.nepi_config
wait


echo ""
echo "Updating NEPI etc files"




###############
export CONFIG_DEST=${NEPI_ETC}/nepi_config.yaml
echo "Updating nepi config file ${CONFIG_DEST}"
source nepi_config_setup.sh
wait

##############################################
echo "NEPI ETC Update Complete"
##############################################

