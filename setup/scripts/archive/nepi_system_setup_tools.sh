#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##


# This file sets up NEPI File System on a device hosted a file system 
# or inside a ubuntu docker container

source ./scripts/nepi_variales_setup.sh
echo "Starting with NEPI Home folder: ${NEPI_HOME}"

##############
# Requirments

INTERNET_REQ=0
FOLDERS_REQ=0
DOCKER_REQ=0

###############################
## NEPI Tool Options
###############################
NEPI_STORAGE_TOOLS=0
NEPI_DOCKER_TOOLS=0
NEPI_SOFTWARE_TOOLS=0
NEPI_CONFIG_Tools=0

OP_SELECTION='NEPI Config Tools'

echo ""
echo ""
echo "Select NEPI Tools option:"
select yn in 'NEPI Drive Tools' 'NEPI Docker Tools' 'NEPI Software Tools' 'NEPI Config Tools'; do
    case $yn in
        NEPI Drive Tools )  NEPI_STORAGE_TOOLS=1;;
        NEPI Docker Tools ) INTERNET_REQ=1; FOLDERS_REQ=1; NEPI_DOCKER_TOOLS=1;;
        NEPI Software Tools ) INTERNET_REQ=1; FOLDERS_REQ=1; NEPI_SOFTWARE_TOOLS=1;;
        NEPI Config Tools ) NEPI_CONFIG_Tools=1;;
    esac
    OP_SELECTION=${yn}
done


## Check Selection
echo ""
echo ""
echo "Confirm Selection: ${OP_SELECTION}"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) exit 1;;
    esac
done



#################################
## Run Required Checks
#################################

###################
## Check Internet
if [ "$INTERNET_REQ" -eq 1 ]; then
    echo "Checking for rerquired internet connection"
    check=0
    while [$check -eq 0]
    do
        if ! ping -c 2 google.com; then
            echo "No Internet Connection"
            check=0
        else
            echo "Internet Connected"
            check=1
        fi
        if [ "$check" -eq 0]; then
            echo "Connect to Internet and Try Again or Quit Setup"
            select option in "Try Again" "Quit Setup"; do
                case $option in
                    Try Again ) break;;
                    Quit Setup ) exit 1;;
                esac
            done
        fi
    done



###################
## Check NEPI Folders
if [ $FOLDERS_REQ -eq 1 ]; then
    . ./nepi_storage_setup.sh
fi

###################
## Check HARDWARE
if [ "$DOCKER_REQ" -eq 1 ]; then
    echo "Checking for rerquired internet connection"
    check=0
    if [ -f /.dockerenv ]; then
        echo "Running in Docker"
        check=1
    else
        echo "Internet Connected"
        check=1
    fi
    if [ "$check" -eq 0]; then
        echo "Connect to internet and Try Again or Quit Setup"
        select yn in "Yes" "No"; do
            case $yn in
                Try Again ) break;;
                Quit Setup ) exit 1;;
            esac
        done
    fi





#################################
## Docker Tools
#################################

SETUP_DOCKER=0
BUILD_CONTAINER=0

DK_SELECTION='Build New Container'

if [ "$NEPI_DOCKER_TOOLS" -eq 1 ]; then

    echo ""
    echo ""
    echo "Select the file system task, or select DO ALL to run all processes:"
    select yn in 'Setup Docker Env' 'Build New Container' ; do
        case $yn in            
            Setup Docker Env ) SETUP_DOCKER=1;;
            Build New Container ) BUILD_CONTAINER=1;;
        esac
        DK_SELECTION=${yn}
    done

    ## Check Selection
    echo ""
    echo ""
    echo "Confirm Selection: ${SELECTION}"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) break;;
            No ) exit 1;;
        esac
    done
fi






#################################
## NEPI_SOFTWARE_SETUP Options
#################################
SOFTWARE_ENV=0
CUDA_SOFTWARE=0
NEPI_STORAGE=0
NEPI_ENGINE=0
NEPI_RUI=0
NEPI_CONFIG=0
SYS_DO_ALL=0

SW_SELECTION='DO ALL'


if [ "$NEPI_SOFTWARE_TOOLS" -eq 1 ]; then

    echo ""
    echo ""
    echo "Select the file system task, or select DO ALL to run all processes:"
    select yn in 'Software Environment' 'Upgrade CUDA Software' 'NEPI Storage' 'NEPI Engine' 'NEPI RUI' 'NEPI Config' 'DO ALL'; do
        case $yn in
            Software Environment ) SOFTWARE_ENV=1;;
            Upgrade CUDA Software ) CUDA_SOFTWARE=1;;
            NEPI Storage ) NEPI_STORAGE=1;;
            NEPI Engine ) NEPI_ENGINE=1;;
            NEPI RUI ) NEPI_RUI=1;;
            NEPI CONFIG ) NEPI_CONFIG=1;;
            DO ALL )  SYS_DO_ALL=1;;
        esac
        SW_SELECTION=${yn}
    done

    ## Check Selection
    echo ""
    echo ""
    echo "Confirm Selection: ${SW_SELECTION}"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) break;;
            No ) exit 1;;
        esac
    done
fi



#######################################
## Configure NEPI Software Requirements

if [ "$SOFTWARE_ENV" -eq 1 -o "$SYS_DO_ALL" -eq 1 ]; then
 
    source ${SETUP_SCRIPTS_PATH}/nepi_software_setup.sh

fi


#############################
## Configure NEPI Environment
NEPI_ETC_SOURCE=./resources/etc
NEPI_ALIASES_SOURCE=./resources/aliases/.nepi_system_aliases 
NEPI_ALIASES=${NEPI_HOME}/.nepi_system_aliases


if [  "$NEPI_ENV" -eq 1 -o "$SYS_DO_ALL" -eq 1 ]; then

    source ${SETUP_SCRIPTS_PATH}/nepi_environment_setup.sh

fi





#################################
## System Config Options
#################################
INSTALL_CONTAINER=0
CONFIGURE_LAUNCH=0
CONFIGURE_FACTORY=0
CONFIGURE_SETTINGS=0

CF_SELECTION='Configure NEPI Settings'


if [ "$NEPI_CONFIG_TOOLS" -eq 1 ]; then

    echo ""
    echo ""
    echo "Select the file system task, or select DO ALL to run all processes:"
    select yn in 'Install NEPI Container' 'Configure NEPI Launch' 'Configure System Factory' 'Configure NEPI Settings' ; do
        case $yn in
            Install NEPI Container ) INSTALL_CONTAINER=1;;
            Configure NEPI Launch) CONFIGURE_LAUNCH=1;;
            Configure System Factory) CONFIGURE_FACTORY=1;;
            Configure NEPI Settings) CONFIGURE_SETTINGS=1;;
        esac
        CF_SELECTION=${yn}
    done

    ## Check Selection
    echo ""
    echo ""
    echo "Confirm Selection: ${CF_SELECTION}"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) break;;
            No ) exit 1;;
        esac
    done
fi
