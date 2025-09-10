#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##

# This script Updates NEPI ETC Files

echo ""
echo "########################"
echo "STARTING NEPI ETC UPDATE PROCESS"
echo "########################"
echo ""

source /home/${USER}/.nepi_bash_utils
wait

################################################################
# Funcions
# function update_text_value(){
#   KEY=$2
#   UPDATE=$3
#   FILE=$1
#   if [ -f "$FILE" ]; then
#     sudo echo "Updating NEPI Config Yaml file from: ${FILE}"
#     if grep -q "$KEY" "$FILE"; then
#       sed -i "/^$KEY/c\\$UPDATE" "$FILE"
#     else
#       echo "$UPDATE" | sudo tee -a $FILE
#     fi
#   else
#     echo "File not found ${FILE}"
#   fi
# }
# export -f update_text_value

# function update_hostname(){
#     HOST_NAME_FILE=${ETC_FOLDER}/hostname
#     echo $HOST_NAME_FILE
#     KEY=$1
#     echo $KEY
#     UPDATE=$2
#     echo $UPDATE
#     if [ -f "$HOST_NAME_FILE" ]; then
#     if grep -q "$KEY" "$HOST_NAME_FILE"; then
#         sed -i "s/$KEY/$UPDATE/g" "$HOST_NAME_FILE"

#     else
#         echo "$UPDATE" | sudo tee -a $HOST_NAME_FILE
#     fi
#     else
#     echo "File not found ${HOST_NAME_FILE}"
#     fi
# }
# export -f update_hostname


#  function update_etc_files(){
#    #************** ADD UPDATE PROCESSES ****************
#    echo "TODO: Add ETC Update Processes"
#  }

################################################################
# Load the config file
if [ ! -f "$(pwd)/load_system_config.sh" ]; then
  echo  "Could not find system config file at: $(pwd)/load_system_config.sh"
else
  source load_system_config.sh
  wait

  if [ ! -d "/etc.nepi" ]; then
    echo "Backing Up ETC folder to /etc.bak"
    sudo cp -R /etc /etc.nepi
  fi
  sudo rsync -arp ../etc /etc.nepi/

  echo "Updating NEPI Factory and System Config files"
  #############
  # Sync with factory config first
  UPDATE_PATH=${NEPI_CONFIG}/factory_cfg
  cp nepi_system_config.yaml nepi_system_config.tmp
  cp update_etc_files.sh update_etc_files.tmp

  sudo mkdir -p ${UPDATE_PATH}/etc
  sudo rsync -arh ${UPDATE_PATH}/etc/ $(dirname "$(pwd)")/etc/

  mv nepi_system_config.tmp nepi_system_config.yaml
  mv update_etc_files.tmp update_etc_files.sh

  #update_etc_files
  
  sudo rsync -arh ../etc/ ${UPDATE_PATH}/etc/
  sudo chown -R ${USER}:${USER} $UPDATE_PATH

  #############
  # Sync with system config
  UPDATE_PATH=${NEPI_CONFIG}/system_cfg
  cp nepi_system_config.yaml nepi_system_config.tmp
  cp update_etc_files.sh update_etc_files.tmp

  sudo mkdir -p ${UPDATE_PATH}/etc
  sudo rsync -arh ${UPDATE_PATH}/etc/ $(dirname "$(pwd)")/etc/

  mv nepi_system_config.tmp nepi_system_config.yaml
  mv update_etc_files.tmp update_etc_files.sh

  #update_etc_files
  
  sudo rsync -arh ../etc/ ${UPDATE_PATH}/etc/
  sudo chown -R ${USER}:${USER} $UPDATE_PATH


  ########################
  # Configure NEPI Host Services
  ########################
#   if [[ "$NEPI_IN_CONTAINER" -eq 0 ]]; then
#     echo "Updating NEPI Managed Serices"
#     if [ "$NEPI_MANAGES_NETWORK" -eq 1 ]; then
#         sudo systemctl stop NetworkManager
#         sudo systemctl stop networking.service
#         sudo ip addr flush eth0 && \
#         sudo systemctl start networking.service && \
#         sudo ifdown --force --verbose eth0 && \
#         sudo ifup --force --verbose eth0
#         sleep 2

#         if [ "$NEPI_DHCP_ON_STARTUP" -eq 1 ]; then
#             #Remove and restart dhclient
#             sudo dhclient -r
#             sudo dhclient
#             sudo dhclient -nw
#             ps aux | grep dhcp
            
#         fi
#     fi

#     if [ "$NEPI_MANAGES_TIME" -eq 1 ]; then
#         sudo timedatectl set-ntp false
#         sudo systemctl start chrony
#     fi


#     if [ "$NEPI_MANAGES_SSH" -eq 1 ]; then
#         sudo systemctl restart sshd
        
#     fi
#   fi

fi

echo ""
echo "########################"
echo "NEPI ETC UPDATE COMPLETE"
echo "########################"
echo ""