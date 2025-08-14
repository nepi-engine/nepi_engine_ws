#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##


# This file sets up NEPI File System on a device hosted a nepi file system 
# or inside a ubuntu docker container


# NEPI Hardware Host Options: GENERIC,JETSON,RPI
NEPI_HW=JETSON


###################################
# System Setup Variables
##################################
NEPI_IP=192.168.179.103
NEPI_USER=nepi

# NEPI PARTITIONS
NEPI_FS_A=/mnt/nepi_fs_a
NEPI_FS_B=/mnt/nepi_fs_b
NEPI_FS_STAGING=/mnt/nepi_staging
NEPI_STORAGE=/mnt/nepi_storage
NEPI_CONFIG=/mnt/nepi_config

DOCKER_MIN_GB=50
STORAGE_MIN_GB=150
CONFIG_MIN_GB=1

##########################
# Process Folders
CURRENT_FOLDER=$PWD

##########################
# NEPI File System 
NEPI_HOME=/home/${NEPI_USER}
NEPI_BASE=/opt/nepi
NEPI_RUI=${NEPI_BASE}/nepi_rui
NEPI_ENGINE=${NEPI_BASE}/engine
NEPI_ETC=${NEPI_BASE}/etc

SYSTEMD_SERVICE_PATH=/etc/systemd/system

SETUP_SCRIPTS_PATH=./resources/scripts
sudo chmod +x ${SETUP_SCRIPTS_PATH}/*

#################
# NEPI Storage Folders

declare -A STORAGE

STORAGE['nepi_fs_a']=${NEPI_FS_A}
STORAGE['nepi_fs_b']=${NEPI_FS_B}
STORAGE['nepi_staging']=${NEPI_FS_STAGING}
STORAGE['nepi_storage']=${NEPI_STORAGE}
STORAGE['nepi_config']=${NEPI_CONFIG}

STORAGE['data']=${NEPI_STORAGE}/data
STORAGE['ai_models']=${NEPI_STORAGE}/ai_models
STORAGE['ai_training']=${NEPI_STORAGE}/ai_training
STORAGE['automation_scripts']=${NEPI_STORAGE}/automation_scripts
STORAGE['databases']=${NEPI_STORAGE}/databases
STORAGE['install']=${NEPI_STORAGE}/install
STORAGE['license']=${NEPI_STORAGE}/install
STORAGE['nepi_src']=${NEPI_STORAGE}/nepi_src
STORAGE['nepi_full_img']=${NEPI_STORAGE}/nepi_full_img
STORAGE['nepi_full_img_archive']=${NEPI_STORAGE}/nepi_full_img_archive
STORAGE['sample_data']=${NEPI_STORAGE}/sample_data
STORAGE['user_cfg']=${NEPI_STORAGE}/user_cfg
STORAGE['tmp']=${NEPI_STORAGE}/tmp

STORAGE['factory_cfg']=${NEPI_CONFIG}/factory_cfg
STORAGE['system_cfg']=${NEPI_CONFIG}/system_cfg



##############
# Requirments

INTERNET_REQ=false
PARTS_REQ=false
DOCKER_REQ=false

###############################
## NEPI Tool Options
###############################
NEPI_STORAGE_TOOLS=false
NEPI_DOCKER_TOOLS=false
NEPI_SOFTWARE_TOOLS=false
NEPI_CONFIG_Tools=false

OP_SELECTION='NEPI Config Tools'

echo ""
echo ""
echo "Select NEPI Tools option:"
select yn in 'NEPI Drive Tools' 'NEPI Docker Tools' 'NEPI Software Tools' 'NEPI Config Tools'; do
    case $yn in
        NEPI Drive Tools )  NEPI_STORAGE_TOOLS=true;;
        NEPI Docker Tools ) INTERNET_REQ=true; PARTS_REQ=true; NEPI_DOCKER_TOOLS=true;;
        NEPI Software Tools ) INTERNET_REQ=true; PARTS_REQ=true; NEPI_SOFTWARE_TOOLS=true;;
        NEPI Config Tools ) NEPI_CONFIG_Tools=true;;
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
if [ $INTERNET_REQ ]; then
    echo "Checking for rerquired internet connection"
    check=false
    while [$check == false]
    do
        if ! ping -c 2 google.com; then
            echo "No Internet Connection"
            check=false
        else
            echo "Internet Connected"
            check=true
        fi
        if [ $check == false]; then
            echo "Connect to internet and Try Again or Quit Setup"
            select yn in "Yes" "No"; do
                case $yn in
                    Try Again ) break;;
                    Quit Setup ) exit 1;;
                esac
            done
        fi
    done



###################
## Check Partitions

NEPI_DOCKER=/mnt/nepi_docker
NEPI_STORAGE=/mnt/nepi_storage
NEPI_CONFIG=/mnt/nepi_config

DOCKER_MIN_GB=100
STORAGE_MIN_GB=150
CONFIG_MIN_GB=1

if [ $PARTS_REQ ]; then
    echo "Checking for rerquired NEPI SSD Folders"
    check=false
    while [$check == false]
    do
        check = false
        if [! -d ${NEPI_DOCKER} ]; then
            check = 
            echo "Missing required folder: ${NEPI_DOCKER} with min size ${DOCKER_MIN_GB} GB"
            check=false
        else
            check=true
        fi

        if [! -d ${NEPI_STORAGE} ]; then
            check = 
            echo "Missing required folder: ${NEPI_STORAGE} with min size ${STORAGE_MIN_GB} GB"
            check=false
        else
            check=true
        fi

        if [! -d ${NEPI_CONFIG} ]; then
            check = 
            echo "Missing required folder: ${NEPI_CONFIG} with min size ${STORAGE_MIN_GB} GB"
            check=false
        else
            check=true
        fi

        if [ $check == false]; then
            echo "Please create missing nepi folders with required minumum space"
            select yn in "Yes" "No"; do
                case $yn in
                    Try Again ) break;;
                    Quit Setup ) exit 1;;
                esac
            done
        fi
    done

###################
## Check HARDWARE
if [ $DOCKER_REQ ]; then
    echo "Checking for rerquired internet connection"
    check=false
    if [ -f /.dockerenv ]; then
        echo "Running in Docker"
        check=true
    else
        echo "Internet Connected"
        check=true
    fi
    if [ $check == false]; then
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

SETUP_DOCKER=false
BUILD_CONTAINER=false

DK_SELECTION='Build New Container'

if [ $NEPI_DOCKER_TOOLS]; then

    echo ""
    echo ""
    echo "Select the file system task, or select DO ALL to run all processes:"
    select yn in 'Setup Docker Env' 'Build New Container' ; do
        case $yn in            
            Setup Docker Env ) SETUP_DOCKER=true;;
            Build New Container ) BUILD_CONTAINER=true;;
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
USER_ENV=false
SOFTWARE_ENV=false
CUDA_SOFTWARE=false
NEPI_ENV=false
NEPI_SOFTWARE=false
NEPI_STORAGE=false
SYS_DO_ALL=false

SW_SELECTION='DO ALL'


if [ $NEPI_SOFTWARE_TOOLS]; then

    echo ""
    echo ""
    echo "Select the file system task, or select DO ALL to run all processes:"
    select yn in 'User Environment'  'Software Environment' 'CUDA Software' 'NEPI Environment' 'NEPI Software' 'DO ALL'; do
        case $yn in
            User Environment ) USER_ENV=true;;
            Software Environment ) SOFTWARE_ENV=true;;
            NEPI Environment ) NEPI_ENV=true;;
            NEPI Software ) NEPI_SOFTWARE=true;;
            NEPI Storage ) NEPI_STORAGE=true;;
            DO ALL )  SYS_DO_ALL=true;;
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

##################
# Setup NEPI User

# Add nepi user and group if does not exist
if [ $USER_ENV == true -o $SYS_DO_ALL == true]; then
    echo ""
    echo "Setting up nepi user account"
    group="nepi"
    user="nepi"
    if grep -q $group /etc/group;  then
          echo "group exists"
    else
          echo "group $group does not exist, creating"
          addgroup nepi
    fi

    if id -u "$user" >/dev/null 2>&1; then
      echo "User $user exists."
    else
      echo "User $user does not exist, creating"
      adduser --ingroup nepi nepi
      echo "nepi ALL=(ALL:ALL) ALL" >> /etc/sudoers

      su nepi
      passwd
      nepi
      nepi
    fi

    # Add nepi user to dialout group to allow non-sudo serial connections
    sudo adduser nepi dialout

    #or //https://arduino.stackexchange.com/questions/74714/arduino-dev-ttyusb0-permission-denied-even-when-user-added-to-group-dialout-o
    #Add your standard user to the group "dialout'
    sudo usermod -a -G dialout nepi
    #Add your standard user to the group "tty"
    sudo usermod -a -G tty nepi

    # Clear the Desktop
    sudo rm /home/nepi/Desktop/*

    echo "User Account Setup Complete"
fi



#######################################
## Configure NEPI Software Requirements

if [ $SOFTWARE_ENV == true -o $SYS_DO_ALL == true ]; then
 
    sudo source ${SETUP_SCRIPTS_PATH}/nepi_software_setup.sh

fi


#############################
## Configure NEPI Environment
NEPI_ETC_SOURCE=./resources/etc
NEPI_ALIASES_SOURCE=./resources/aliases/.nepi_system_aliases 
NEPI_ALIASES=${NEPI_HOME}/.nepi_system_aliases


if [  $NEPI_ENV -o $SYS_DO_ALL ]; then

    sudo source ${SETUP_SCRIPTS_PATH}/nepi_environment_setup.sh

fi





#################################
## System Config Options
#################################
INSTALL_CONTAINER=false
CONFIGURE_LAUNCH=false
CONFIGURE_FACTORY=false
CONFIGURE_SETTINGS=false

CF_SELECTION='Configure NEPI Settings'


if [ $NEPI_CONFIG_TOOLS]; then

    echo ""
    echo ""
    echo "Select the file system task, or select DO ALL to run all processes:"
    select yn in 'Install NEPI Container' 'Configure NEPI Launch' 'Configure System Factory' 'Configure NEPI Settings' ; do
        case $yn in
            Install NEPI Container ) INSTALL_CONTAINER=true;;
            Configure NEPI Launch) CONFIGURE_LAUNCH=true;;
            Configure System Factory) CONFIGURE_FACTORY=true;;
            Configure NEPI Settings) CONFIGURE_SETTINGS=true;;
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
