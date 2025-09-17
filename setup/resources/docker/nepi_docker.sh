#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##

# This script is the NEPI Docker Container Management Service
source /home/${USER}/.nepi_bash_utils
wait

# Load NEPI SYSTEM CONFIG
SCRIPT_FOLDER=$(dirname "$(readlink -f "$0")")
ETC_FOLDER=${SCRIPT_FOLDER}/etc
if [ -d "$ETC_FOLDER" ]; then
    echo "Failed to find ETC folder at ${ETC_FOLDER}"
    exit 1
fi
source ${ETC_FOLDER}/load_system_config.sh
wait
if [ $? -eq 1 ]; then
    echo "Failed to load ${ETC_FOLDER}/load_system_config.sh"
    exit 1
fi

# Load NEPI DOCKER
CONFIG_SOURCE=$(pwd)/nepi_docker_config.yaml
source $(pwd)/load_docker_config.sh
wait
if [ $? -eq 1 ]; then
    echo "Failed to load ${CONFIG_SOURCE}"
    exit 1
fi

####################################
# Process Functions

function reset_update_vars(){
update_yaml_value "NEPI_FS_SWITCH" 0 $CONFIG_SOURCE
update_yaml_value "NEPI_FS_RESTART" 0 $CONFIG_SOURCE
update_yaml_value "NEPI_FS_IMPORT" 0 $CONFIG_SOURCE
update_yaml_value "NEPI_FS_EXPORT" 0 $CONFIG_SOURCE
update_yaml_value "NEPI_FAIL_COUNT" 0 $CONFIG_SOURCE

update_yaml_value "NEPI_WIRED" 0 $CONFIG_SOURCE
update_yaml_value "NEPI_WIFI" 0 $CONFIG_SOURCE
update_yaml_value "NEPI_DHCP" 0 $CONFIG_SOURCE
update_yaml_value "NEPI_NTP" 0 $CONFIG_SOURCE
}

function restart_nepi(){
    NEPI_FAIL_COUNT=$NEPI_FAIL_COUNT + 1
    update_yaml_value "NEPI_FAIL_COUNT" $NEPI_FAIL_COUNT $CONFIG_SOURCE
    while [[ ! "$NEPI_FAIL_COUNT" -eq 0 ]]; do
        source $(pwd)/nepi_docker_start.sh
        wait
        echo "Waiting ${NEPI_BOOT_TIME_SEC} for NEPI to load and update FAIL COUNT to 0"
        sleep $NEPI_BOOT_TIME_SEC
        source load_docker_config.sh

        if [[ "$NEPI_FAIL_COUNT" -gt "$NEPI_MAX_FAIL_COUNT" ]]; then # Switch to Backup
            echo "NEPI Start attempts have exceeded max tries of ${NEPI_MAX_FAIL_COUNT}"
            echo "Switching to Backup NEPI File System Container"
            source $(pwd)/nepi_docker_stop.sh
            source $(pwd)/nepi_docker_switch.sh
            update_yaml_value "NEPI_FAIL_COUNT" 1 $CONFIG_SOURCE
        elif [[ "$NEPI_FAIL_COUNT" -le "$NEPI_MAX_FAIL_COUNT" ]]; then # Try Again
            echo "NEPI Start has failed with attempt count ${NEPI_FAIL_COUNT} out of ${NEPI_MAX_FAIL_COUNT}"
            NEPI_FAIL_COUNT=$NEPI_FAIL_COUNT + 1
            update_yaml_value "NEPI_FAIL_COUNT" $NEPI_FAIL_COUNT $CONFIG_SOURCE
        elif [[ "$NEPI_FAIL_COUNT" -le 0 ]]; then
            echo "NEPI Started Successfully"
           fi
    done
    return 0

}


####################################
# Configure NEPI Managed Services

if [[ "$NEPI_DHCP_ON_START" -eq 1 && "$NEPI_MANAGES_NETWORK" -eq 1 ]]; then
    sdhcp
fi

####################################
# RESET NEPI DOCKER CONFIG Update Variables

reset_update_vars

#####################################
# Start NEPI CONTAINER

running=restart_nepi

#####################################
# Monitor NEPI Services

 echo "Starting NEPI Services Monitoring"
 while [[ "$running" -eq 1 ]]; do
    source load_docker_config.sh
    if [[ "$NEPI_RUNNING" -eq 1 ]]; then
        if [[ "$NEPI_FS_SWITCH" -eq 1 ]]; then
            source $(pwd)/nepi_docker_switch.sh
        fi
        if [[ "$NEPI_FS_RESTART" -eq 1 ]]; then
            running=restart_nepi
        fi
        if [[ "$NEPI_FS_IMPORT" -eq 1 ]]; then
            source $(pwd)/nepi_docker_import.sh
        fi
        if [[ "$NEPI_FS_EXPORT" -eq 1 ]]; then
            source $(pwd)/nepi_docker_export.sh
        fi
        if [[ "$NEPI_MANAGES_NETWORK" -eq 1 ]]; then
            if [[ "$NEPI_WIRED" -eq 1 ]]; then
                : # Do Something
            fi
            if [[ "$NEPI_WIFI" -eq 1 ]]; then
                : # Do Something
            fi
            if [[ "$NEPI_DHCP" -eq 1 ]]; then
                : # Do Something
            fi
        fi
        if [[ "$NEPI_MANAGES_TIME" -eq 1 ]]; then
            if [[ "$NEPI_NTP" -eq 1 ]]; then
                : # Do Something
            fi
        fi
        if [[ "$NEPI_MANAGES_SSH" -eq 1 ]]; then
            : # Maybe Do Something 
        fi
    fi
    reset_update_vars
    sleep 1
done

