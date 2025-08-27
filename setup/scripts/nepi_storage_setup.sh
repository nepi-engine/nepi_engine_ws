#! /bin/bash
##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##

# This file initializes a NEPI Storage Drive Folder
source ./NEPI_CONFIG.sh
wait

echo ""
echo "Initializing NEPI Storage Drive"


CREATE_FOLDERS=0
echo "Checking for rerquired NEPI Folders"
check=0
while [ $check -eq 0 ]
do
    check = 0
    if [! -d ${NEPI_DOCKER} -a $NEPI_IN_CONTAINER -eq 1]; then
        check = 
        echo "Missing required folder: ${NEPI_DOCKER} with min size ${DOCKER_MIN_GB} GB"
        check=0
    else
        check=1
    fi

    if [! -d ${NEPI_STORAGE} ]; then
        check = 
        echo "Missing required folder: ${NEPI_STORAGE} with min size ${STORAGE_MIN_GB} GB"
        check=0
    else
        check=1
    fi

    if [! -d ${NEPI_CONFIG} ]; then
        check = 
        echo "Missing required folder: ${NEPI_CONFIG} with min size ${STORAGE_MIN_GB} GB"
        check=0
    else
        check=1
    fi

    if [ "$check" -eq 0]; then
        select yn in "Yes" "No"; do
            case $yn in
                Create NEPI Folders ) CREATE_FOLDERS=1;;
                Quit Setup ) exit 1;;
            esac
        done
    fi
done


if [[ "$CREATE_FOLDERS" -eq 1]]; then
    echo "Creating NEPI Folders at"
    sudo mkdir $NEPI_DOCKER
    ls -l $(dirname "$NEPI_DOCKER")
    sudo mkdir $NEPI_STORAGE
    sudo chown -R ${USER}:${USER} $NEPI_STORAGE
    ls -l $(dirname "$NEPI_STORAGE")
    sudo mkdir $NEPI_CONFIG
    sudo chown -R ${USER}:${USER} $NEPI_CONFIG
    ls -l $(dirname "$NEPI_CONFIG")
fi
    

'
########## Copy Init Files
wget # Add zip download
unzip # Unzip
sudo rm # Zipped file
rsync -ra nepi_storage ${NEPI_STORAGE}
sudo rm # Unzipped file
'

