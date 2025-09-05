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


echo " Must be run as sudo.  type "sudo su" then rerun"
CONFIG_SOURCE=$(dirname "$(pwd)")/nepi_system_config.yaml
source $(pwd)/load_system_config.sh
wait

if [ ! -v NEPI_USER ]; then
    echo "Failed to load ${CONFIG_SOURCE}"
    exit 1
fi


###################################
function new_nepi_user(){
    user=$1
    password=$2
    echo ""
    echo "Setting up nepi user account: ${user}"



    if id -u "$user" >/dev/null 2>&1; then
        echo "User $user exists."
        
    else
        echo "User $user does not exist, creating"
        if grep -q $user /etc/group;  then
                echo "group exists"
        else
                echo "group $user does not exist, creating"
                addgroup ${user}
        fi

        adduser --ingroup ${user} ${user}
        echo "${user} ALL=(ALL:ALL) ALL" >> /etc/sudoers


        echo "new_password" | ${password} --stdin ${user}

        # Add nepi user to dialout group to allow non-serial connections
        adduser ${user} dialout

        #or //https://arduino.stackexchange.com/questions/74714/arduino-dev-ttyusb0-permission-denied-even-when-user-added-to-group-dialout-o
        #Add your standard user to the group "dialout'
        usermod -a -G dialout ${user}
        #Add your standard user to the group "tty"
        usermod -a -G tty ${user}

        # Create USER python folder
        mkdir -p /home/${user}/.local/lib/python${NEPI_PYTHON}/site-packages

        # Clear the Desktop
        rm /home/${user}/Desktop/*

        echo "User Account Setup Complete"
        echo ""
    fi
}



new_nepi_user $NEPI_ADMIN $NEPI_ADMIN_PW
new_nepi_user $NEPI_USER $NEPI_USER_PW

