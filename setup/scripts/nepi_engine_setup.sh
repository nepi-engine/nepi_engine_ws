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

echo "########################"
echo "NEPI ENGINE SETUP"
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

if [ 1 ]; then 
    echo ""
    echo "Setting up NEPI Engine"


    #####################################
    # Add nepi aliases to bashrc

    source nepi_etc_update.sh




    ###################################
    # Mod some system settings
    echo ""
    echo "Modifyging some system settings"

    # Fix gpu accessability
    #https://forums.developer.nvidia.com/t/nvrmmeminitnvmap-failed-with-permission-denied/270716/10
    sudo usermod -aG sudo,video,i2c nepi

    # Fix USB Vidoe Rate Issue
    sudo rmmod uvcvideo
    sudo modprobe uvcvideo nodrop=1 timeout=5000 quirks=0x80


    # Create System Folders
    echo ""
    echo "Creating system folders in ${NEPI_BASE}"
    sudo mkdir -p ${NEPI_BASE}
    sudo mkdir -p ${NEPI_RUI}
    sudo mkdir -p ${NEPI_ENGINE}
    sudo mkdir -p ${NEPI_ETC}
    sudo mkdir -p ${NEPI_SCRIPTS}

    echo "Creating dev folders"
    sudo mkdir -p ${NEPI_CODE}
    sudo mkdir -p ${NEPI_SRC}


    echo "Creating image install folders"
    sudo mkdir -p ${NEPI_IMAGE_INSTALL}
    sudo mkdir -p ${NEPI_IMAGE_ARCHIVE}


    echo "Creating config folders"
    sudo mkdir -p ${NEPI_USR_CONFIG}
    sudo mkdir -p ${NEPI_FACTORY_CONFIG}
    sudo mkdir -p ${NEPI_SYSTEM_CONFIG}

    # Create some backward compatable links
    #cd ${NEPI_BASE}
    #sudo ln -sf nepi_engine ros
    #sudo ln -sf nepi_engine engine
    #sudo ln -sf nepi_rui rui

    # Clear any old nepi engine files/folders
    #source ./nepi_engine_clear.sh

#############################################
# Setting up Baumer GenTL Producers (Genicam support)
echo " "
echo "Setting up Baumer GAPI SDK GenTL Producers"

if [ ! -f "/opt/baumer" ]; then
    sudo rm -r /opt/baumer
fi
sudo cp ${NEPI_ETC}/opt/baumer /opt/baumer
sudo chown ${NEPI_USER}:${NEPI_USER} /opt/baumer

# Disable apport to avoid crash reports on a display
echo "Disabling apport service"
sudo systemctl disable apport

# Set up the shared object links in case they weren't copied properly when this repo was moved to target
NEPI_BAUMER_PATH=${NEPI_ETC}/opt/baumer/gentl_producers
ln -sf $NEPI_BAUMER_PATH/libbgapi2_usb.cti.2.14.1 $NEPI_BAUMER_PATH/libbgapi2_usb.cti.2.14
ln -sf $NEPI_BAUMER_PATH/libbgapi2_usb.cti.2.14 $NEPI_BAUMER_PATH/libbgapi2_usb.cti
ln -sf $NEPI_BAUMER_PATH/libbgapi2_gige.cti.2.14.1 $NEPI_BAUMER_PATH/libbgapi2_gige.cti.2.14
ln -sf $NEPI_BAUMER_PATH/libbgapi2_gige.cti.2.14 $NEPI_BAUMER_PATH/libbgapi2_gige.cti


##############
# Install License Manager File
echo "Setting Up Lic Mgr"
sudo dos2unix ${NEPI_ETC}/license/nepi_check_license.py
sudo chmod +x ${NEPI_ETC}/license/nepi_check_license_start.py
sudo chmod +x ${NEPI_ETC}/license/nepi_check_license.py
sudo ln -sf ${NEPI_ETC}/license/nepi_check_license.service /etc/systemd/system/
sudo gpg --import ${NEPI_ETC}/license/nepi_license_management_public_key.gpg
sudo systemctl enable nepi_check_license
#gpg --import /opt/nepi/config/etc/nepi/nepi_license_management_public_key.gpg


#########################################
# Setup system scripts
NEPI_SCRIPTS_SOURCE=$(dirname "$(pwd)")/resources/scripts
echo ""
echo "Populating System Scripts from ${NEPI_SCRIPTS_SOURCE}"

sudo cp -R ${NEPI_SCRIPTS_SOURCE} $NEPI_BASE/
sudo chmod +x ${NEPI_SCRIPTS}/*

echo "NEPI Script Setup Complete"

#########
#- add Gieode databases to FileSystem

#egm2008-2_5.pgm  egm2008-2_5.pgm.aux.xml  egm2008-2_5.wld  egm96-15.pgm  egm96-15.pgm.aux.xml  egm96-15.wld
#from
#https://www.3dflow.net/geoids/
#to
#/opt/nepi/databases/geoids
#:'

#######################
# Install some premade python packages
#######################
USER_SITE_PACKAGES_PATH=$(python -m site --user-site)
NEPI_PYTHON_SOURCE=$(dirname "$(pwd)")/resources/software/python3


sudo cp -R ${NEPI_PYTHON_SOURCE}/* ${USER_SITE_PACKAGES_PATH}/


# Update NEPI_BASE owner
# Update NEPI_FOLDER owners
echo "All done.  Updating folder owners"
sudo chown -R ${NEPI_USER}:${NEPI_USER} ${NEPI_BASE}
sudo chown -R ${NEPI_USER}:${NEPI_USER} ${NEPI_STORAGE}
sudo chown -R ${NEPI_USER}:${NEPI_USER} ${NEPI_CONFIG}

###########################################
# Fix some NEPI package issues
###########################################

'
FILE=/usr/lib/python3/dist-packages/Cryptodome/Util/_raw_api.py
KEY=
LINE=69
UPDATE=
echo "Updating docker file ${FILE} line: ${Line}"
sed -i "/^$KEY/c\\$UPDATE" "$FILE"
'


'
DO THIS MAYBE
sudo vi /usr/lib/python3/dist-packages/Cryptodome/Util/_raw_api.py
## Comment out line 258 "#raise OSError("Cannot load native module '%s': %s" % (name, ", ".join(attempts)))"
sudo vi /usr/lib/python3/dist-packages/Cryptodome/Cipher/AES.py
## Line 69 Add "if _raw_cpuid_lib is not None:" before try, then indent try and except section
'


##############################################
# Populate factory config folder
##############################################
echo "Populating NEPI Factory Config Folder ${NEPI_FACTORY_CONFIG}"
sudo cp -R -p /opt/nepi/etc ${NEPI_FACTORY_CONFIG}/



##################################
# Setting Up NEPI Docker Host Services Links

echo "Setting up NEPI Docker Host services"

etc_dest=/etc
sudo cp -r ${NEPI_ETC}/lsyncd ${etc_dest}

echo "" | sudo tee -a $lsyncd_file
echo "sync {" | sudo tee -a $lsyncd_file
echo "    default.rsync," | sudo tee -a $lsyncd_file
echo '    source = "'${NEPI_ETC}'/",' | sudo tee -a $lsyncd_file
echo '    target = "'${etc_dest}'/",' | sudo tee -a $lsyncd_file
echo "}" | sudo tee -a $lsyncd_file


sudo systemctl enable lsyncd

    # Update NEPI_FOLDER owners
    sudo chown -R ${NEPI_USER}:${NEPI_USER} ${NEPI_BASE}
    sudo chown -R ${NEPI_USER}:${NEPI_USER} ${NEPI_STORAGE}
    sudo chown -R ${NEPI_USER}:${NEPI_USER} ${NEPI_CONFIG}

    #####################################
    # Update NEPI ETC files
    source nepi_etc_update.sh

    ################################
    # Misc Updates
    ###############################


    # Mavros requires some additional setup for geographiclib
    sudo /opt/ros/${ROS_VERSION}/lib/mavros/install_geographiclib_datasets.sh



    #########
    # Install Driver Support Libs
    cd $TMP

    #https://www.stereolabs.com/developers/release/4.1
    wget https://download.stereolabs.com/zedsdk/4.1/l4t35.1/jetsons
    sudo sudo apt install zstd -y



    ##############################################
    echo "NEPI Engine Setup Complete"
    ##############################################


    # Source nepi aliases before exit
    echo " "
    echo "Sourcing bashrc with nepi aliases"
    sleep 1 & source $BASHRC
    wait
    # Print out nepi aliases
    . ${NEPI_ALIASES_DEST} && helpn
else
    echo "Make sure you are logged in to the nepi device as nepi user, then try again"
fi