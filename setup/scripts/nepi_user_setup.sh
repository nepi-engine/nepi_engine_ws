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

CONFIG_SOURCE=$(dirname "$(pwd)")/NEPI_CONFIG.sh
source ${CONFIG_SOURCE}
wait


echo ""
echo "Setting up NEPI User"


###################################
echo ""
echo "Setting up nepi user account"
group="nepi"
user="nepi"
if grep -q $group /etc/group;  then
        echo "group exists"
else
        echo "group $group does not exist, creating"
        addgroup nepi
fi

if id -u "$user" >/dev/null 2>&1; then
    echo "User $user exists."
else
    echo "User $user does not exist, creating"
    adduser --ingroup nepi nepi
    echo "nepi ALL=(ALL:ALL) ALL" >> /etc/sudoers

    su nepi
    passwd
    nepi
    nepi
    
fi
su nepi

# Add nepi user to dialout group to allow non-sudo serial connections
sudo adduser nepi dialout

#or //https://arduino.stackexchange.com/questions/74714/arduino-dev-ttyusb0-permission-denied-even-when-user-added-to-group-dialout-o
#Add your standard user to the group "dialout'
sudo usermod -a -G dialout nepi
#Add your standard user to the group "tty"
sudo usermod -a -G tty nepi

# Create USER python folder
mkdir -p ${HOME}/.local/lib/python${NEPI_PYTHON}/site-packages

# Clear the Desktop
sudo rm ${NEPI_HOME}/Desktop/*

echo "User Account Setup Complete"

