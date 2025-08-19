#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##


# This file installs the NEPI RUI File System installation

source ./_nepi_config.sh
echo "Starting with NEPI Home folder: ${NEPI_HOME}"


echo ""
echo "Setting up NEPI RUI"



##############################
# Install NEPI RUI
##############################


pip install --user -U pip
pip install --user virtualenv
mkdir $HOME/.nvm
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install 8.11.1 # RUI-required Node version as of this script creation
# Upgrade node version
nvm install 14.1.0
nvm use 14.1.0
npm install -S rtsp-relay express
npm install -g yarn
#sudo yarn add ffmpeg-kit-react-native

rm /opt/nepi/nepi_rui/.nvmrc
echo 14.1.0 >> /opt/nepi/nepi_rui/.nvmrc

cd /opt/nepi/nepi_rui
python -m virtualenv venv
source ./devenv.sh
pip install -r requirements.txt
npm install
deactivate


# Build RUI
cd /opt/nepi/nepi_rui
source ./devenv.sh
cd src/rui_webserver/rui-app
npm run build

npm install --save react-zoom-pan-pinch
deactivate

#########################################
# Setup system services
echo ""
echo "Setting up NEPI RUI Service"

sudo chmod +x ${NEPI_ETC}/services/*

sudo cp ${NEPI_ETC}/services/nepi_rui.service ${SYSTEMD_SERVICE_PATH}/nepi_rui.service
sudo systemctl enable nepi_rui

###########################################
# Fix some RUI package issues
###########################################
sudo vi /opt/nepi/nepi_rui/venv/lib/python3.10/site-packages/flask_cors/core.py
##REPLACE
# import collections
##WITH
# import collections
# collections.Iterable = collections.abc.Iterable

##############################
echo "NEPI RUI Setup Complete"
##############################


# Run RUI
#sudo /opt/nepi/nepi_rui/etc/start_rui.sh
#rosrun nepi_rui run_webserver.py
