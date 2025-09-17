#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##
sbrc

NEPI_STORAGE=/mnt/nepi_storage
NEPI_CONFIG=/mnt/nepi_config
NEPI_BASE=/opt/nepi
export NEPI_USER=nepi
export NEPI_DEVICE_ID=$NEPI_DEVICE_ID

export NEPI_MANAGES_NETWORK=$NEPI_MANAGES_NETWORK
export NEPI_IP=$NEPI_IP

export NEPI_ACTIVE_NAME=nepi_fs_b
export NEPI_ACTIVE_TAG=3p2p3-jetson-orin-5-5d
export NEPI_IP=192.168.179.103



sudo docker run -d --privileged -it -e UDEV=1 --gpus all \
    --mount type=bind,source=${NEPI_STORAGE},target=${NEPI_STORAGE} \
    --mount type=bind,source=${NEPI_CONFIG},target=${NEPI_CONFIG} \
    --mount type=bind,source=/dev,target=/dev \
    --cap-add=SYS_TIME --volume=/var/empty:/var/empty -v /etc/ntpd.conf:/etc/ntpd.conf \
    --net=host \
    -p 2222:22 \
    --runtime nvidia \
    -v /tmp/.X11-unix/:/tmp/.X11-unix \
    ${NEPI_ACTIVE_NAME}:${NEPI_ACTIVE_TAG} /bin/bash

export NEPI_RUNNING_NAME=$NEPI_ACTIVE_NAME
export NEPI_RUNNING_TAG=$NEPI_ACTIVE_TAG
export NEPI_RUNNING_ID=$(sudo docker container ls  | grep $NEPI_RUNNING_NAME | awk '{print $1}')

echo "NEPI Container Running with ID ${NEPI_RUNNING_ID}"
sudo docker exec -it -u $NEPI_USER $NEPI_RUNNING_ID /bin/bash -c "su ${NEPI_USER}"





sudo docker exec  $NEPI_RUNNING_ID /bin/bash -c "/opt/nepi/scripts/nepi_time_start"
sudo docker exec  $NEPI_RUNNING_ID /bin/bash -c "/opt/nepi/scripts/nepi_network_start"
sudo docker exec  $NEPI_RUNNING_ID /bin/bash -c "/opt/nepi/scripts/nepi_dhcp_start"
sudo docker exec  $NEPI_RUNNING_ID /bin/bash -c "/opt/nepi/scripts/nepi_ssh_start"
sudo docker exec  $NEPI_RUNNING_ID /bin/bash -c "/opt/nepi/scripts/nepi_samba_start"
sudo docker exec  $NEPI_RUNNING_ID /bin/bash -c "/opt/nepi/scripts/nepi_engine_start"
sudo docker exec  $NEPI_RUNNING_ID /bin/bash -c "/opt/nepi/scripts/nepi_license_start"



export NEPI_USER=$NEPI_USER
export NEPI_DEVICE_ID=$NEPI_DEVICE_ID

export NEPI_MANAGES_NETWORK=$NEPI_MANAGES_NETWORK
export NEPI_IP=$NEPI_IP

export NEPI_ACTIVE_NAME=nepi_fs_a
export NEPI_ACTIVE_TAG=3p2p3-jetson-orin-5-4
export NEPI_IP=192.168.179.103

export NEPI_RUNNING_NAME=$NEPI_ACTIVE_NAME
export NEPI_RUNNING_TAG=$NEPI_ACTIVE_TAG
export NEPI_RUNNING_ID=$(sudo docker container ls  | grep $NEPI_RUNNING_NAME | awk '{print $1}')
echo "NEPI Container Running with ID ${NEPI_RUNNING_ID}"

sudo docker exec -it -u $NEPI_USER $NEPI_RUNNING_ID /bin/bash -c "su ${NEPI_USER}"

#######################################

sudo docker commit $NEPI_RUNNING_ID ${NEPI_RUNNING_NAME}:${NEPI_RUNNING_TAG}-2

#################################

sudo docker stop $NEPI_RUNNING_ID

#################################
NEPI_STOPPED_ID=aeaf39348034
sudo docker start $NEPI_STOPPED_ID


#Create Docker Network
export DOCKER_IP=192.168.179.0/24
sudo docker network create --subnet=$DOCKER_IP nepi_network
sudo docker network create --subnet 172.18.179.0/16 --gateway 172.18.179.1 my-custom-network
sudo docker network inspect nepi_network


or 

    --net=host \
    --runtime nvidia \
'
export NEPI_TCP_PORTS=$NEPI_TCP_PORTS
echo $NEPI_TCP_PORTS
export NEPI_UDP_PORTS=$NEPI_UDP_PORTS
export NEPI_IP_ALIASES=($192.168.0.103 192.168.1.103)
export NEPI_IP_ADDRESSES=("NEPI_IP" "${IP_ALIASES[@]}")

# Configure NEPI Docker Network Settings
nepi_net='\'
if [[ "$NEPI_MANAGES_NETWORK" -eq 0 ]]; then
    # Use Host Network Stack
    nepi_net="${nepi_net}
        --net=host '\'"
else
    NEPI_IP_ALIASES=(${NEPI_IP} "${NEPI_IP_ALIASES[@]}")
    for ip in "${NEPI_IP_ALIASES[@]}"; do
        # Add IP Address to docker host
        #sudo ip addr add ${ip}/24 dev eth0
        for tport in "${NEPI_TCP_PORTS[@]}"; do
            nepi_net="${nepi_net}
                -p ${ip}:${tport}:${tport: -2} '\'"
        done
        for uport in "${NEPI_UPD_PORTS[@]}"; do
            nepi_net="${nepi_net}
                -p ${ip}:${uport}:${uport: -2}/udp '\'"
        done
    done
fi

echo $nepi_net
'