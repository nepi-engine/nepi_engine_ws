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

source ./NEPI_CONFIG.sh
wait

mkdir -p ${HOME}/.local/lib/python${NEPI_PYTHON}/site-packages

sudo ln -sfn /usr/bin/python${PYTHON_VERSION} /usr/bin/python3
sudo ln -sfn /usr/bin/python3 /usr/bin/python
sudo python${PYTHON_VERSION} -m pip --version

#####################################
# Add nepi aliases to bashrc
echo "Updating NEPI aliases file"

NEPI_CFG_SOURCE=${PWD}/NEPI_CONFIG.sh
NEPI_CFG_DEST=${HOME}/.nepi_config
echo "Installing NEPI utils file ${NEPI_CFG_DEST} "
sudo rm $NEPI_CFG_DEST
sudo cp $NEPI_CFG_SOURCE $NEPI_CFG_DEST
sudo chown -R ${NEPI_USER}:${NEPI_USER} $NEPI_CFG_DEST

NEPI_UTILS_SOURCE=$(dirname "$(pwd)")/resources/bash/nepi_bash_utils
NEPI_UTILS_DEST=${HOME}/.nepi_bash_utils
echo "Installing NEPI utils file ${NEPI_UTILS_DEST} "
sudo rm $NEPI_UTILS_DEST
sudo cp $NEPI_UTILS_SOURCE $NEPI_UTILS_DEST
sudo chown -R ${NEPI_USER}:${NEPI_USER} $NEPI_UTILS_DEST

NEPI_ALIASES_SOURCE=$(dirname "$(pwd)")/resources/bash/nepi_system_aliases
NEPI_ALIASES_DEST=/home/${NEPI_USER}/.nepi_system_aliases
echo ""
echo "Populating System Folders from ${NEPI_ALIASES_SOURCE}"
echo ""
echo "Installing NEPI aliases file to ${NEPI_ALIASES_DEST} "
sudo rm ${NEPI_ALIASES_DEST}

sudo cp $NEPI_ALIASES_SOURCE $NEPI_ALIASES_DEST
sudo chown -R ${NEPI_USER}:${NEPI_USER} $NEPI_ALIASES_DEST

#############
BASHRC=/home/${NEPI_USER}/.bashrc
echo "Updating bashrc file"

if grep -qnw $BASHRC -e "##### Source NEPI Aliases #####" ; then
    : #echo "Already Done"
else
    echo ' ' | sudo tee -a $BASHRC
    echo '##### Source NEPI Aliases #####' | sudo tee -a $BASHRC
    echo 'if [ -f '${NEPI_ALIASES_DEST}' ]; then' | sudo tee -a $BASHRC
    echo '    . '${NEPI_ALIASES_DEST} | sudo tee -a $BASHRC
    echo 'fi' | sudo tee -a $BASHRC
fi

if grep -qnw $BASHRC -e "##### NVM Config #####" ; then
    : #echo "Already Done"
else
    echo ' ' | sudo tee -a $BASHRC
    echo '##### NVM Config #####' | sudo tee -a $BASHRC
    echo 'export NVM_DIR='${HOME}'/.nvm' | sudo tee -a $BASHRC
    echo '[ -s ${NVM_DIR}/nvm.sh ] && \. ${NVM_DIR}/nvm.sh' | sudo tee -a $BASHRC
    echo '[ -s ${NVM_DIR}/bash_completion ] && \. ${NVM_DIR}/bash_completion' | sudo tee -a $BASHRC
fi


if grep -qnw $BASHRC -e "##### System Config #####" ; then
    : #echo "Already Done"
else
    echo ' ' | sudo tee -a $BASHRC
    echo '##### System Config #####' | sudo tee -a $BASHRC
    echo 'export CMAKE_POLICY_VERSION_MINIMUM=3.5' | sudo tee -a $BASHRC
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
    echo 'export PYTHONPATH=${PYTHONPATH}:${HOME}/.local/lib/python'${NEPI_PYTHON}'/site-packages' | sudo tee -a $BASHRC
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

sudo chmod 755 ${HOME}/.*

ROOTRC=/root/.bashrc
sudo cp $BASHRC /root/.bashrc


echo " "
echo "NEPI Bash Aliases Setup Complete"
echo " "

