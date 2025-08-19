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
source ./_nepi_config.sh
echo "Starting with NEPI Home folder: ${NEPI_HOME}"

echo ""
echo "Initializing NEPI Storage Drive"

# Change to tmp install folder
TMP=${STORAGE["tmp"]}
mkdir $TMP
cd $TMP



########## Copy Init Files
wget # Add zip download
unzip # Unzip
sudo rm # Zipped file
rsync -ra nepi_storage ${NEPI_STORAGE}
sudo rm # Unzipped file

