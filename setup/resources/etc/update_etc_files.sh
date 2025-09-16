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


#############################
# Load the config file

SCRIPT_FOLDER=$(cd -P "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

if [ ! -f "${SCRIPT_FOLDER}/load_system_config.sh" ]; then
  echo  "Could not find system config file at: ${SCRIPT_FOLDER}/load_system_config.sh"
else
  source ${SCRIPT_FOLDER}/load_system_config.sh
  if [ $? -eq 1 ]; then
    echo "Failed to load ${NEPI_SYSTEM_CONFIG_DEST}"
    exit 1
  fi

  #############################
  # Sync with existing configs
  #############################
  echo "Updating NEPI Factory and System Config files from etc folder ${SCRIPT_FOLDER})"
  #############

  # Sync with factory configs first
  SOURCE_PATH=$SCRIPT_FOLDER
  UPDATE_PATH=${NEPI_CONFIG}/factory_cfg
  cp ${SCRIPT_FOLDER}/nepi_system_config.yaml ${SCRIPT_FOLDER}/nepi_system_config.tmp
  cp ${SCRIPT_FOLDER}/update_etc_files.sh ${SCRIPT_FOLDER}/update_etc_files.tmp
  cp ${SCRIPT_FOLDER}/hosts ${SCRIPT_FOLDER}/hosts.tmp
  cp ${SCRIPT_FOLDER}/hostname ${SCRIPT_FOLDER}/hostname.tmp

  sudo mkdir -p ${UPDATE_PATH}/etc
  sudo rsync -arh ${UPDATE_PATH}/etc/ ${SOURCE_PATH}/

  mv ${SCRIPT_FOLDER}/nepi_system_config.tmp ${SCRIPT_FOLDER}/nepi_system_config.yaml
  mv ${SCRIPT_FOLDER}/update_etc_files.tmp ${SCRIPT_FOLDER}/update_etc_files.sh
  mv ${SCRIPT_FOLDER}/hosts.tmp ${SCRIPT_FOLDER}/hosts
  mv ${SCRIPT_FOLDER}/hostname.tmp ${SCRIPT_FOLDER}/hostname
  #update_etc_files
  
  SOURCE_PATH=$SCRIPT_FOLDER
  UPDATE_PATH=${NEPI_CONFIG}/factory_cfg
  sudo rsync -arh ${SOURCE_PATH}/ ${UPDATE_PATH}/etc/
  sudo chown -R ${USER}:${USER} $UPDATE_PATH

  #############
  # Sync with system config
  SOURCE_PATH=$SCRIPT_FOLDER
  UPDATE_PATH=${NEPI_CONFIG}/system_cfg
  cp ${SCRIPT_FOLDER}/nepi_system_config.yaml ${SCRIPT_FOLDER}/nepi_system_config.tmp
  cp ${SCRIPT_FOLDER}/update_etc_files.sh ${SCRIPT_FOLDER}/update_etc_files.tmp
  cp ${SCRIPT_FOLDER}/hosts ${SCRIPT_FOLDER}/hosts.tmp
  cp ${SCRIPT_FOLDER}/hostname ${SCRIPT_FOLDER}/hostname.tmp

  sudo mkdir -p ${UPDATE_PATH}/etc
  sudo rsync -arh ${UPDATE_PATH}/etc/ ${SOURCE_PATH}/

  mv ${SCRIPT_FOLDER}/nepi_system_config.tmp ${SCRIPT_FOLDER}/nepi_system_config.yaml
  mv ${SCRIPT_FOLDER}/update_etc_files.tmp ${SCRIPT_FOLDER}/update_etc_files.sh
  mv ${SCRIPT_FOLDER}/hosts.tmp ${SCRIPT_FOLDER}/hosts
  mv ${SCRIPT_FOLDER}/hostname.tmp ${SCRIPT_FOLDER}/hostname
  

  #update_etc_files
  SOURCE_PATH=$SCRIPT_FOLDER
  UPDATE_PATH=${NEPI_CONFIG}/system_cfg
  sudo rsync -arh ${SOURCE_PATH}/ ${UPDATE_PATH}/etc/
  sudo chown -R ${USER}:${USER} $UPDATE_PATH
  ########################
  # Configure NEPI Host Services
  ########################

    # First Backup original if needed
    if [[ "$NEPI_MANAGES_ETC" -eq 1 ]]; then
        back_ext=org
        overwrite=0

        ### Backup ETC folder if needed
        folder=/etc
        folder_back=${folder}.${back_ext}
        path_backup $folder $folder_back $overwrite

        ### Backup USR LIB SYSTEMD folder if needed
        folder=/usr/lib/systemd/system
        folder_back=${folder}.${back_ext}
        path_backup $folder $folder_back $overwrite

        ### Backup RUN SYSTEMD folder if needed
        folder=/run/systemd/system
        folder_back=${folder}.${back_ext}
        path_backup $folder $folder_back $overwrite

        ### Backup USR LIB SYSTEMD USER folder if needed
        folder=/usr/lib/systemd/user
        folder_back=${folder}.${back_ext}
        path_backup $folder $folder_back $overwrite
    fi





    #######################################
    ### Setup NEPI Docker Service

    if [[ "$NEPI_MANAGES_ETC" -eq 1 ]]; then
        ##################################
        # Setting Up NEPI Managed Services on Host


        echo "Setting Up NEPI Managed Serices"
        etc_source=$SCRIPT_FOLDER


        ###########################################
        if [ "$NEPI_MANAGES_HOSTNAME" -eq 1 ]; then

            #########################################
            # Update ETC HOSTS File
            file=${etc_source}/hosts
            if [ ! -f "$file" ]; then
                sudo rm $file
            fi
            sudo cp -a ${file}.blank $file

            entry="${NEPI_IP} ${NEPI_USER}"
            echo $entry
            echo "Updating NEPI IP in ${file}"
            if grep -qnw $file -e ${entry}; then
                echo "Found NEPI IP in ${file} ${entry} "
            else
                echo "Adding NEPI IP in ${file}"
                echo "${NEPI_IP} ${NEPI_DEVICE_ID}" | sudo tee -a $file
                echo $entry | sudo tee -a $file
                echo "${entry}-${NEPI_DEVICE_ID}" | sudo tee -a $file

                entry="${NEPI_IP} ${NEPI_ADMIN_USER}"
                echo $entry | sudo tee -a $file
                echo "${entry}-${NEPI_DEVICE_ID}" | sudo tee -a $file

                entry="${NEPI_IP} ${NEPI_HOST_USER}"
                echo $entry | sudo tee -a $file
                echo "${entry}-${NEPI_DEVICE_ID}" | sudo tee -a $file
            fi

            sudo rm -r /etc/hosts
            sudo cp -R -a $file /etc/hosts

            ######################
            # Update ETC HOSTNAME File
            file=${etc_source}/hostname
            if [ ! -f "$file" ]; then
                sudo rm $file
            fi
            sudo cp -a ${file}.blank $file
            
            entry="${NEPI_DEVICE_ID}"
            echo $entry
            echo "Updating NEPI IP in ${file}"
            if grep -qnw $file -e ${entry}; then
                echo "Found NEPI IP in ${file} ${entry} "
            else
                echo "Adding NEPI IP in ${file}"
                echo $entry | sudo tee -a $file
            fi

            #sudo cp -R -a ${NEPI_CONFIG}/docker_cfg/${file} $file
            sudo rm -r /etc/hostname
            sudo cp -R -a $file /etc/hostname


            echo "Restarting hostnamed service"
            sudo systemctl restart systemd-hostnamed
        fi

        ###########################################
        if [ "$NEPI_MANAGES_TIME" -eq 1 ]; then
            
            # Install NTP Sources
            echo " "
            echo "Configuring chrony.conf"
            sudo rm -r /etc/chrony/chrony.conf
            sudo cp ${etc_source}/chrony/chrony.conf /etc/chrony/chrony.conf
            ###
            sudo timedatectl set-ntp false
            sudo systemctl enable chrony
            sudo systemctl restart chrony
        fi


        ###########################################
        if [ "$NEPI_MANAGES_NETWORK" -eq 1 ]; then

            #sudo systemctl stop NetworkManager
            #sudo systemctl stop networking.service

            
            # Set up static IP addr.
            echo "Updating Network interfaces.d"
            sudo rm -r /etc/network/interfaces.d
            sudo cp -a -r ${etc_source}/network/interfaces.d /etc/network/

            echo "Updating Network interfaces"
            sudo rm -r /etc/network/interfaces
            sudo cp -a -r ${etc_source}/network/interfaces /etc/network/interfaces

            # Set up DHCP
            echo "Updating Network dhclient.conf"
            sudo rm -r /etc/dhcp/dhclient.conf
            sudo cp -a -r ${etc_source}/dhcp/dhclient.conf /etc/dhcp/dhclient.conf

            # Set up WIFI
            if [ ! -d "etc/wpa_supplicant" ]; then
                sudo mkdir ${etc_source}/wpa_supplicant
            fi
            
            sudo rm -r /etc/wpa_supplicant
            sudo cp -a -r ${etc_source}/wpa_supplicant /etc/


            # # RESTART NETWORK
            # #sudo ip addr flush eth0 && 
            # sudo systemctl enable -now networking.service
            # sudo ifdown --force --verbose eth0
            # sudo ifup --force --verbose eth0

            # # Remove and restart dhclient
            # sudo dhclient -r
            # sudo dhclient
            # sudo dhclient -nw
            # #ps aux | grep dhcp

            
        fi


        ###########################################
        if [ "$NEPI_MANAGES_SSH" -eq 1 ]; then
            # Set up SSH

            echo " "
            echo "Configuring SSH Keys"
            # And default public key - Make sure all ownership and permissions are as required by SSH
            sudo chown ${CONFIG_USER}:${CONFIG_USER} ${etc_source}/ssh/authorized_keys
            sudo chmod 0600 ${etc_source}/ssh/authorized_keys

            if [ ! -d "/home/${CONFIG_USER}/.ssh" ]; then
                sudo mkdir /home/${CONFIG_USER}/.ssh
            fi

            if [ -f "/home/${CONFIG_USER}/.ssh/authorized_keys" ]; then
                sudo rm /home/${CONFIG_USER}/.ssh/authorized_keys
            fi
            sudo cp ${etc_source}/ssh/authorized_keys /home/${CONFIG_USER}/.ssh/authorized_keys
            sudo chown ${CONFIG_USER}:${CONFIG_USER} /home/${CONFIG_USER}/.ssh/authorized_keys
            sudo chmod 0600 /home/${CONFIG_USER}/.ssh/authorized_keys

            # sudo chmod 0700 /home/${CONFIG_USER}/.ssh
            # sudo chown -R ${CONFIG_USER}:${CONFIG_USER} /home/${CONFIG_USER}/.ssh
            if [ "$USER" == "nepi" ]; then
                sudo rm -r /etc/ssh/sshd_config
                sudo cp ${etc_source}/ssh/sshd_config /etc/ssh/sshd_config
            fi

            if [ "$USER" == "nepi" ]; then
                sudo rm -r /etc/ssh/sshd_config
                sudo cp ${etc_source}/docker/ssh/sshd_config /etc/ssh/sshd_config
            fi
            ###

            # Unmask if needed  https://www.baeldung.com/linux/systemd-unmask-services
            service_name=sshd

            #service_file=$(sudo find /etc /usr/lib -name "${service_name}.service*")
            #if [[ "$service_file" != "" ]]; then
            #    sudo systemctl unmask ${service_name}
            #    sudo rm ${service_file}
            #    sudo systemctl daemon-reload
            #fi
            #sudo systemctl status ${service_name}
            sudo systemctl enable ${service_name}
            sudo systemctl restart ${service_name}
            #sudo systemctl status ${service_name}
        fi

        #########################################
        # Setup supervisor service
        #########################################
        if [[ "$NEPI_IN_CONTAINER" -eq 1 ]]; then

            echo ""
            echo "Setting up NEPI Supervisord"

            if [ -d "/etc/supervisor" ]; then
                if [ ! -f "/etc/supervisor/conf.d/supervisord_nepi.conf" ]; then
                    sudo cp -a -r /etc/supervisor/conf.d/supervisord_nepi.conf /etc/supervisor/conf.d/supervisord_nepi.conf.bak
                    sudo rm /etc/supervisor/conf.d/supervisord_nepi.conf
                fi
                sudo cp ${etc_source}/supervisor/conf.d/supervisord_nepi.conf /etc/supervisor/conf.d/supervisord_nepi.conf 
            fi
            #sudo systemctl enable supervisor.service
            #sudo systemctl restart supervisor.service
        fi

        ########################################
        # Setup NEPI etc sync process service
        ########################################
        # sudo cp -r ${etc_source}/lsyncd/lsyncd.blank /etc/lsyncd/lsyncd.conf
        # sudo chown -R ${USER}:${USER} /etc/lsyncd/lsyncd.conf

        # lsyncd_file=/etc/lsyncd/lsyncd.conf
        # etc_sync=$etc_source
        # etc_dest=${NEPI_CONFIG}/docker_cfg/etc
        # echo "" | sudo tee -a $lsyncd_file
        # echo "sync {" | sudo tee -a $lsyncd_file
        # echo "    default.rsync," | sudo tee -a $lsyncd_file
        # echo '    source = "'${etc_sync}'/",' | sudo tee -a $lsyncd_file
        # echo '    target = "'${etc_dest}'/",' | sudo tee -a $lsyncd_file
        # echo "}" | sudo tee -a $lsyncd_file
        # echo " " | sudo tee -a $lsyncd_file

        # Make sure lsyncd is only started manually by nepi_launch.sh script
        # sudo systemctl disable lsyncd

    


        # # Setup NEPI ETC to OS Host ETC Link Service
        # echo "Setting Up NEPI ETC Sycn service"
        # sudo cp -r ${etc_source}/lsyncd /etc/
        # sudo chown -R ${CONFIG_USER}:${CONFIG_USER} ${etc_source}/lsyncd


        #sudo systemctl enable lsyncd
        #sudo systemctl restart lsyncd
        
    fi

    ###########################################
    # Install Modeprobe Conf
    echo " "
    echo "Configuring nepi_modprobe.conf"
    etc_path=modprobe.d/nepi_modprobe.conf
    sudo rm /etc/${etc_path}
    sudo cp ${etc_source}/${etc_path} /etc/${etc_path}

    #############################################
    # Set up some udev rules for plug-and-play hardware
    echo " "
    echo "Setting up udev rules"
        # IQR Pan/Tilt
    sudo cp ${etc_source}/udev/rules.d/* /etc/udev/rules.d/
        
    ##############################################
    # Update the Desktop background image
    echo ""
    echo "Updating Desktop background image"
    # Update the login screen background image - handled by a sys. config file
    # No longer works as of Ubuntu 20.04 -- there are some Github scripts that could replace this -- change-gdb-background
    #echo "Updating login screen background image"
    #sudo cp ${NEPI_CONFIG}/usr/share/gnome-shell/theme/ubuntu.css ${NEPI_ETC}/ubuntu.css
    #sudo ln -sf ${NEPI_ETC}/ubuntu.css /usr/share/gnome-shell/theme/ubuntu.css
    gsettings set org.gnome.desktop.background picture-uri file:///${etc_source}/nepi/nepi_wallpaper.png


    # Backup NEPI folders
    if [[ "$NEPI_MANAGES_ETC" -eq 1 ]]; then
        back_ext=nepi
        overwrite=1

        ### Backup ETC folder
        folder=/etc
        folder_back=${folder}.${back_ext}
        path_backup $folder $folder_back $overwrite

        ### Backup USR LIB SYSTEMD folder
        folder=/usr/lib/systemd/system
        folder_back=${folder}.${back_ext}
        path_backup $folder $folder_back $overwrite

        ### Backup RUN SYSTEMD folder
        folder=/run/systemd/system
        folder_back=${folder}.${back_ext}
        path_backup $folder $folder_back $overwrite

        ### Backup USR LIB SYSTEMD USER folder
        folder=/usr/lib/systemd/user
        folder_back=${folder}.${back_ext}
        path_backup $folder $folder_back $overwrite
    fi

    #########################################
    # Sync back to system configs
    # #########################################
    SOURCE_PATH=$SCRIPT_FOLDER
    UPDATE_PATH=${NEPI_CONFIG}/system_cfg
    sudo rsync -arh ${SOURCE_PATH}/ ${UPDATE_PATH}/etc/
    sudo chown -R ${USER}:${USER} $UPDATE_PATH

    # sudo chown -R ${CONFIG_USER}:${CONFIG_USER} ${etc_source}
    # echo ""

fi

echo ""
echo "########################"
echo "NEPI ETC UPDATE COMPLETE"
echo "########################"
echo ""











