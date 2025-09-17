#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##


# This file sets up nepi bash aliases and util functions


echo "########################"
echo "NEPI BASH SETUP"
echo "########################"

SCRIPT_FOLDER=$(cd -P "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

source $(dirname "${SCRIPT_FOLDER}")/resources/bash/nepi_bash_utils 

# Load System Config File
source $(dirname ${SCRIPT_FOLDER})/config/load_system_config.sh
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

#####################################
# Add nepi aliases to bashrc
echo "Updating NEPI aliases file"
BASHRC=/home/${NEPI_USER}/.bashrc
RBASHRC=/root/.bashrc

### Backup USER BASHRC
source_path=$BASHRC
overwrite=0
path_backup $source_path ${source_path}.org $overwrite

# Update Bashrc and Nepi bash files
NEPI_UTILS_SOURCE=$(dirname "${SCRIPT_FOLDER}")/resources/bash/nepi_bash_utils
NEPI_UTILS_DEST=/home/${NEPI_USER}/.nepi_bash_utils
echo "Installing NEPI utils file ${NEPI_UTILS_DEST} "
if [ -f "$NEPI_UTILS_DEST" ]; then
    sudo rm $NEPI_UTILS_DEST
fi
sudo cp $NEPI_UTILS_SOURCE $NEPI_UTILS_DEST
sudo chown -R ${NEPI_USER}:${NEPI_USER} $NEPI_UTILS_DEST
#sudo ln -sfn ${NEPI_UTILS_DEST} /root/.nepi_bash_utils

NEPI_ALIASES_SOURCE=$(dirname "${SCRIPT_FOLDER}")/resources/bash/nepi_system_aliases
NEPI_ALIASES_DEST=/home/${NEPI_USER}/.nepi_system_aliases
echo ""
echo "Populating System Folders from ${NEPI_ALIASES_SOURCE}"
echo ""
echo "Installing NEPI aliases file to ${NEPI_ALIASES_DEST} "
if [ -f "$NEPI_ALIASES_DEST" ]; then
    sudo rm ${NEPI_ALIASES_DEST}
fi
sudo cp $NEPI_ALIASES_SOURCE $NEPI_ALIASES_DEST
sudo chown -R ${NEPI_USER}:${NEPI_USER} $NEPI_ALIASES_DEST
#sudo ln -sfn ${NEPI_ALIASES_DEST} /root/.nepi_system_aliases

#############
echo "Updating userbashrc files"

sudo cp -n $RBASHRC ${RBASHRC}.bak
sudo cp ${RBASHRC}.bak $BASHRC
sudo chown ${NEPI_USER}:${NEPI_USER} $BASHRC
sudo chmod 755 $BASHRC

if grep -qnw $BASHRC -e "##### System Config #####" ; then
    : #echo "Already Done"
else
    echo ' ' | sudo tee -a $BASHRC
    echo '##### System Config #####' | sudo tee -a $BASHRC
    echo '#export CMAKE_POLICY_VERSION_MINIMUM=3.5' | sudo tee -a $BASHRC
    echo 'export SETUPTOOLS_USE_DISTUTILS=stdlib' | sudo tee -a $BASHRC
    echo 'export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lib' | sudo tee -a $BASHRC
    echo 'export LD_PRELOAD=/usr/local/lib/libOpen3D.so' | sudo tee -a $BASHRC
fi

if grep -qnw $BASHRC -e "##### Python Config #####" ; then
    : #echo "Already Done"
else
    echo ' ' | sudo tee -a $BASHRC
    echo '##### Python Config #####' | sudo tee -a $BASHRC
    echo 'export PYTHONPATH=${PYTHONPATH}:'${NEPI_ENGINE}'/etc' | sudo tee -a $BASHRC
    echo 'export PYTHONPATH=${PYTHONPATH}:'${NEPI_ENGINE}'/lib/nepi_drivers' | sudo tee -a $BASHRC
    echo 'export PYTHONPATH=${PYTHONPATH}:/usr/local/lib/python'${NEPI_PYTHON}'/site-packages' | sudo tee -a $BASHRC
    echo 'export PYTHONPATH=${PYTHONPATH}:/home/${NEPI_USER}/.local/lib/python'${NEPI_PYTHON}'/site-packages' | sudo tee -a $BASHRC
fi

if [[ "$NEPI_HAS_CUDA" -eq 1 ]]; then
    if grep -qnw $BASHRC -e "##### CUDA SETUP #####" ; then
        : #echo "Already Done"
    else
        echo ' ' | sudo tee -a $BASHRC
        echo '##### CUDA SETUP #####' | sudo tee -a $BASHRC
        echo 'export CUDA_PATH=/usr/local/cuda-'${NEPI_CUDA_VERSION%.*} | sudo tee -a $BASHRC
        echo 'export CUDA_HOME=/usr/local/cuda-'${NEPI_CUDA_VERSION%.*} | sudo tee -a $BASHRC
        echo 'export CUPY_NVCC_GENERATE_CODE=current' | sudo tee -a $BASHRC
        echo 'export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:'${CUDA_HOME}'/bin/lib64:$CUDA_HOME/bin/extras/CUPTI/lib64' | sudo tee -a $BASHRC
        echo 'export PATH=${PATH}:'${CUDA_HOME}'/bin' | sudo tee -a $BASHRC
    fi
fi

# Copy the bashrc at this point to rooot
sudo cp $BASHRC $RBASHRC 
sudo chown root:root $RBASHRC
sudo chmod 644 $RBASHRC

# Add additional user bashrc statements

if grep -qnw $BASHRC -e "##### Source NEPI Aliases #####" ; then
    : #echo "Already Done"
else
    echo ' ' | sudo tee -a $BASHRC
    echo '##### Source NEPI Aliases #####' | sudo tee -a $BASHRC
    echo 'if [ -f '${NEPI_ALIASES_DEST}' ]; then' | sudo tee -a $BASHRC
    echo '    . '${NEPI_ALIASES_DEST} | sudo tee -a $BASHRC
    echo 'fi' | sudo tee -a $BASHRC
fi
sudo chmod 755 /home/${NEPI_USER}/.*

# Copy files to nepiadmin home
sudo cp /home/${NEPI_USER}/.* /home/${NEPI_ADMIN}/ >/dev/null 2>&1

### Backup NEPI BASHRC
source_path=$BASHRC
overwrite=1
path_backup $source_path ${source_path}.nepi $overwrite

#################################
sleep 1 & source $BASHRC
wait
# Print out nepi aliases
echo " "
echo "NEPI Bash Aliases Setup Complete"
echo " "
echo " "
. ${NEPI_ALIASES_DEST} && nepihelp



