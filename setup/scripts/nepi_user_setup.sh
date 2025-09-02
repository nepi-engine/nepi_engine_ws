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
echo "Setting up NEPI Accounts"



###################################
echo ""
echo "Setting up nepi admin account"
group="${NEPI_ADMIN}"
user="${NEPI_ADMIN}"
if grep -q $group /etc/group;  then
        echo "group exists"
else
        echo "group $group does not exist, creating"
        addgroup ${NEPI_ADMIN}
fi

if id -u "$user" >/dev/null 2>&1; then
    echo "User $user exists."
else
    echo "User $user does not exist, creating"
    adduser --ingroup ${NEPI_ADMIN} ${NEPI_ADMIN}
    echo "${NEPI_ADMIN} ALL=(ALL:ALL) ALL" >> /etc/sudoers

    
fi
su ${NEPI_ADMIN}
passwd
${NEPI_ADMIN}
${NEPI_ADMIN_PW}

su ${NEPI_ADMIN}

# Add nepi user to dialout group to allow non-sudo serial connections
sudo adduser ${NEPI_ADMIN} dialout

#or //https://arduino.stackexchange.com/questions/74714/arduino-dev-ttyusb0-permission-denied-even-when-user-added-to-group-dialout-o
#Add your standard user to the group "dialout'
sudo usermod -a -G dialout ${NEPI_ADMIN}
#Add your standard user to the group "tty"
sudo usermod -a -G tty ${NEPI_ADMIN}

# Create USER python folder
mkdir -p ${HOME}/.local/lib/python${NEPI_PYTHON}/site-packages

# Clear the Desktop
sudo rm ${NEPI_HOME}/Desktop/*

echo "User Account Setup Complete"




###################################

echo ""
echo "Setting up nepi user account"
group="${NEPI_USER}"
user="${NEPI_USER}"
if grep -q $group /etc/group;  then
        echo "group exists"
else
        echo "group $group does not exist, creating"
        addgroup ${NEPI_USER}
fi

if id -u "$user" >/dev/null 2>&1; then
    echo "User $user exists."
else
    echo "User $user does not exist, creating"
    adduser --ingroup ${NEPI_USER} ${NEPI_USER}
    echo "${NEPI_USER} ALL=(ALL:ALL) ALL" >> /etc/sudoers

    
fi
su ${NEPI_USER}
passwd
${NEPI_USER}
${NEPI_USER_PW}

su ${NEPI_USER}

# Add nepi user to dialout group to allow non-sudo serial connections
sudo adduser ${NEPI_USER} dialout

#or //https://arduino.stackexchange.com/questions/74714/arduino-dev-ttyusb0-permission-denied-even-when-user-added-to-group-dialout-o
#Add your standard user to the group "dialout'
sudo usermod -a -G dialout ${NEPI_USER}
#Add your standard user to the group "tty"
sudo usermod -a -G tty ${NEPI_USER}

# Create USER python folder
mkdir -p ${HOME}/.local/lib/python${NEPI_PYTHON}/site-packages

# Clear the Desktop
sudo rm ${NEPI_HOME}/Desktop/*

echo "User Account Setup Complete"

