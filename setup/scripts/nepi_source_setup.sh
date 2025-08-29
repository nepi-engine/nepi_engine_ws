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
source ./NEPI_CONFIG.sh
wait

echo ""
echo "Setting Up NEPI NEPI Source Code Repo"

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
            git clone git@github.com:nepi-engine/nepi_engine_ws.git
            cd nepi_engine_ws
            if [[ "$NEPI_BRANCH" == "main" ]]; then
                git checkout main
            else
                if [[ "$NEPI_ROS" == "NOETIC" ]]; then
                git checkout ros1_develop
                else
                git checkout ros2_develop
                fi
            fi
            git submodule update --init --recursive
        fi
    else
        echo "Failed to create source code folder at: ${NEPI_SOURCE}"
    fi

else
    echo "NEPI Source Folder Exists: ${SOURCE_FOLDER}"
fi