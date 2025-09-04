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
NEPI_SOURCE_PATH=/home/${USER}


echo ""
echo "Setting Up NEPI NEPI Source Code Repo"

SOURCE_FOLDER=${NEPI_SOURCE_PATH}/nepi_engine_ws
if [ ! -f "${SOURCE_FOLDER}" ]; then

    echo ""
    echo ""
    echo "Select NEPI Source Code Banch to Install:"
    select branch in 'main' 'develop'; do
        case $branch in
            main ) break;;
            develop ) break;;
        esac
        NEPI_BRANCH=${branch}
    done


    echo "Installing NEPI Branch: ${NEPI_BRANCH} at ${SOURCE_FOLDER}"
    if [ ! -d "${NEPI_SOURCE_PATH}" ]; then
        sudo mkdir $NEPI_SOURCE_PATH
        sudo chmod -R ${USER}:${USER} $NEPI_SOURCE_PATH
    fi

    if [ -d "${NEPI_SOURCE_PATH}" ]; then
 
        if [ -f "${SOURCE_FOLDER}" ]; then
            echo "NEPI Source Folder Exists: ${SOURCE_FOLDER}. Delete and try again"
        else
            cd ${NEPI_SOURCE_PATH}

            if [[ "$NEPI_BRANCH" == "main" ]]; then
                BRANCH=main
            else
                BRANCH=ros1_develop
            fi
            SUBBRANCH=ros1_main

             # Now Clone
            git clone git@github.com:nepi-engine/nepi_engine_ws.git
            cd ${SOURCE_FOLDER}
            git checkout $BRANCH
            git submodule update --init --recursive
            git submodule foreach git checkout $SUBBRANCH
            #git submodule foreach git pull origin $SUBBRANCH

            for dir in ${SOURCE_FOLDER}/src/*/; do
                if [ -d "$dir" ]; then # Checks if the item is a directory
                    cd $dir
                    if [ -f ".gitmodules" ]; then
                        echo "Updating Submodule Repos: ${dir}"
                        git submodule update --init --recursive
                        git submodule foreach git checkout $SUBBRANCH
                        #git submodule foreach git pull origin $SUBBRANCH
                    fi
                fi
            done
            cd $SOURCE_FOLDER
          
        fi
    else
        echo "Failed to create source code folder at: ${NEPI_SOURCE_PATH}"
    fi

else
    echo "NEPI Source Folder Exists: ${SOURCE_FOLDER}"
fi