#! /bin/bash
##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##

# This file installs nepi engine workspace repo


echo "########################"
echo "NEPI SOURCE CODE SETUP"
echo "########################"

# Load System Config File
source $(dirname $(pwd))/config/load_system_config.sh
if [ $? -eq 1 ]; then
    echo "Failed to load ${SYSTEM_CONFIG_FILE}"
    exit 1
fi

# Check User Account
CONFIG_USER=$NEPI_USER
if [[ "$USER" != "$CONFIG_USER" ]]; then
    echo "This script must be run by user account ${CONFIG_USER}."
    echo "Log in as ${CONFIG_USER} and run again"
    exit 2
fi


SOURCE_FOLDER=${NEPI_SOURCE}/nepi_engine_ws
if [ ! -f "${SOURCE_FOLDER}" ]; then

    if [ !-v NEPI_BRANCH ]; then
        echo ""
        echo ""
        echo "Select NEPI Source Code Banch to Install:"
        select branch in 'dain' 'develop'; do
            case $branch in
                main ) break;;
                develop ) break;;
            esac
            NEPI_BRANCH=${branch}
        done
    fi

    echo "Installing NEPI Branch: ${NEPI_BRANCH} at ${SOURCE_FOLDER}"
    if [ ! -d "${NEPI_SOURCE}" ]; then
    sudo mkdir $NEPI_SOURCE
    sudo chmod -R ${USER}:${USER} $NEPI_SOURCE
    fi
    if [ -d "${NEPI_SOURCE}" ]; then
        if [ -f "${SOURCE_FOLDER}" ]; then
            echo "NEPI Source Folder Exists: ${SOURCE_FOLDER}. Delete and try again"
        else
            cd ${NEPI_SOURCE}
            git clone git@github.com:nepi-engine/nepi_engine_ws.git
            cd nepi_engine_ws
            if [[ "$NEPI_BRANCH" == "main" ]]; then
                BRANCH=main
                if [[ "$NEPI_ROS" == "NOETIC" ]]; then
                BRANCH=ros1_develop
                else
                BRANCH=ros2_develop
                fi
            fi
            if [[ "$NEPI_ROS" == "NOETIC" ]]; then
                SUBBRANCH=ros1_main
            else
                SUBBRANCH=ros2_main
            fi
            # Now Clone
            git clone git@github.com:nepi-engine/nepi_engine_ws.git
            cd nepi_engine_ws
            git checkout $BRANCH
            git submodule update --init --recursive
            git submodule foreach git checkout $SUBBRANCH
            git submodule foreach git pull origin $SUBBRANCH
            cd src
            for dir in /*/; do
            if [ -d "$dir" ]; then # Checks if the item is a directory
                cd $dir
                if [ -f ".gitmodules" ]; then
                git submodule update --init --recursive
                git submodule foreach git checkout $SUBBRANCH
                git submodule foreach git pull origin $SUBBRANCH
                fi
            fi
            fi
        fi
    else
        echo "Failed to create source code folder at: ${NEPI_SOURCE}"
    fi

else
    echo "NEPI Source Folder Exists: ${SOURCE_FOLDER}"
fi