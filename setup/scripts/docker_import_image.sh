#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##


# This file configigues an installed NEPI File System


source ./NEPI_CONFIG.sh
echo "Starting with NEPI Home folder: ${NEPI_HOME}"

echo ""
echo "Import Docker Containers"

# Change to tmp install folder
#TMP=${STORAGE["tmp"]}
#mkdir $TMP
#cd $TMP

# Remove everything in the nepi_docker_file
sudo rm -rf /mnt/${NEPI_DOCKER}/*

# Make a temporary file in nepi storage
sudo mkdir -p /mnt/nepi_storage/tmp
cd /mnt/nepi_storage/tmp
# NOTE: Pull the tar file
# Extract the tar file to the stagging file
sudo docker import /mnt/${NEPI_DOCKER}/my-nginx.tar # NOTE: Change name to match the tar file
echo ""
echo ""
echo "Select file system to update"
select yn in 'nepi_fs_a' 'nepi_fs_b'; do
    case $yn in
        nepi_fs_a )
        sudo rm -rf /mnt/nepi_fs_a/*
        sudo mv /mnt/${NEPI_DOCKER}/* /mnt/nepi_fs_a/
        break
        ;;
        nepi_fs_b )
        sudo rm -rf /mnt/nepi_fs_b/*
        sudo mv /mnt/${NEPI_DOCKER}/* /mnt/nepi_fs_b/
        break
        ;;
    esac
done
sudo chown -R nepidev:nepidev *

##################################
echo 'Setup Complete'
##################################