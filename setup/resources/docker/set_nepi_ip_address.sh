#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##

# This script Stops a Running NEPI Container

########################
# Update NEPI Docker Variables from nepi_docker_config.yaml
refresh_nepi
wait
########################


########################
# Add NEPI IP Aliase
########################

sudo ip addr add ${IP_ADDRESS}/32 dev eth0