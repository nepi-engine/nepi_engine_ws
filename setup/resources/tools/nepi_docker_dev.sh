export NEPI_USER=$NEPI_USER
export NEPI_DEVICE_ID=$NEPI_DEVICE_ID

export NEPI_MANAGES_NETWORK=$NEPI_MANAGES_NETWORK
export NEPI_IP=$NEPI_IP
export NEPI_TCP_PORTS=$NEPI_TCP_PORTS
export NEPI_UDP_PORTS=$NEPI_UDP_PORTS
export NEPI_IP_ALIASES=(192.168.0.103 192.168.1.103)
export NEPI_IP_ADDRESSES=("STATIC_IP" "${IP_ALIASES[@]}")

# Configure NEPI Docker Network Settings
nepi_net="\"
if [[ "$NEPI_MANAGES_NETWORK" -eq 0 ]]; then
    # Use Host Network Stack
    nepi_net="${nepi_net}
        --net=host \"
else
    for ip in "${NEPI_IP[@]}"; do
        # Add IP Address to docker host
        sudo ip addr add ${ip}/24 dev eth0
        for tport in "${NEPI_TCP_PORTS[@]}"; do
            nepi_net="${nepi_net}
                -p ${ip}:${tport}:"${tport: -2} \"
        done
        for uport in "${NEPI_UPD_PORTS[@]}"; do
            nepi_net="${nepi_net}
                -p ${ip}:${uport}:"${uport: -2}/udp \"
        done
    done
fi


export NEPI_ACTIVE_NAME=nepi
export NEPI_ACTIVE_TAG=3p2p3-jetson-orin-3
export NEPI_ACTIVE_ID=docker images --filter "reference=${NEPI_ACTIVE_NAME}:${NEPI_ACTIVE_TAG}" --format "{{.ID}}"

sudo docker run --rm -it --privileged -e UDEV=1 --user $NEPI_USER --gpus all \
    --mount type=bind,source=${NEPI_STORAGE},target=${NEPI_STORAGE} \
    --mount type=bind,source=${NEPI_CONFIG},target=${NEPI_CONFIG} \
    --mount type=bind,source=/dev,target=/dev \
    --cap-add=SYS_TIME --volume=/var/empty:/var/empty -v /etc/ntpd.conf:/etc/ntpd.conf \
    --hostname ${NEPI_DEVICE_ID} \
    ${nepi_net}
    --runtime nvidia \
    -v /tmp/.X11-unix/:/tmp/.X11-unix \
    ${NEPI_ACTIVE_NAME}:${NEPI_ACTIVE_TAG} /bin/bash




export NEPI_RUNNING_NAME=$NEPI_ACTIVE_NAME
export NEPI_RUNNING_TAG=$NEPI_ACTIVE_TAG
#export NEPI_RUNNING_ID=docker ps -q --filter "${NEPI_RUNNING_NAME}:${NEPI_RUNNING_TAG}"
export NEPI_RUNNING_ID=$(sudo docker inspect --format "{{.Id}}" ${NAME}:${TAG} | sed 's/^sha256://')
echo $ID
sudo docker exec -it $NEPI_RUNNING_ID /bin/bash


ID=668e300abe77
udo docker start -ai $NEPI_RUNNING_ID

ID=668e300abe77
sudo docker exec -it $NEPI_RUNNING_ID /bin/bash




    #network options
    --hostname nepi-device1 \
    -p ${STATIC_IP}:8080:80 \ 
    -p ${STATIC_IP}:2222:22 \ 
    -p ${STATIC_IP}:123:123/udp \
    -p ${STATIC_IP}:5003:3 \
    -p ${STATIC_IP}:9091:91 \
or
    --net=host \

sudo docker run -it --privileged -e UDEV=1 --user nepi --gpus all \
    --mount type=bind,source=/mnt/nepi_storage,target=/mnt/nepi_storage \
    --mount type=bind,source=/mnt/nepi_config,target=/mnt/nepi_config \
    --mount type=bind,source=/dev,target=/dev \
    --cap-add=SYS_TIME --volume=/var/empty:/var/empty -v /etc/ntpd.conf:/etc/ntpd.conf \
    --net=host \
    --runtime nvidia \
    -v /tmp/.X11-unix/:/tmp/.X11-unix \
    ${NAME}:${TAG} /bin/bash

    --hostname nepi-device1 \
    --publish ${STATIC_IP}:80:8080 \



    # Initialize Run Command
    DOCKER_RUN_COMMAND=" sudo docker run --privileged -e UDEV=1 --user nepi '\'
    --mount type=bind,source=/mnt/nepi_storage,target=/mnt/nepi_storage '\'
    --mount type=bind,source=/mnt/nepi_config,target=/mnt/nepi_config '\'
    --mount type=bind,source=/dev,target=/dev '\'
    -e DISPLAY=${DISPLAY} '\'"
    
    
    # Set Remove Mode
    if [[ ! -v RM_MODE || ( -v RM_MODE && "$RM_MODE" -eq 1 ) ]]; then
        echo "Setting Remove Mode TRUE"
    DOCKER_RUN_COMMAND="${DOCKER_RUN_COMMAND}
    --rm '\'"
    fi 
    
    # Set Interactive Mode
    if [[ ! -v IT_MODE || ( -v IT_MODE && "$IT_MODE" -eq 1 ) ]]; then
        echo "Setting Interactive Mode TRUE"
    DOCKER_RUN_COMMAND="${DOCKER_RUN_COMMAND}
    --it '\'"
    fi 
    
    
    # Set Clock Settings
    if [[ "$NEPI_MANAGES_CLOCK" -eq 1 ]]; then
        echo "Disabling Host Auto Clock Updating"
        sudo timedatectl set-ntp no
    
    DOCKER_RUN_COMMAND="${DOCKER_RUN_COMMAND}
    --cap-add=SYS_TIME --volume=/var/empty:/var/empty -v /etc/ntpd.conf:/etc/ntpd.conf '\'"
    
    fi 
    
    
    # Update Network Settings
    echo "Setting Static IP"
    echo "STATIC_IP"
    DOCKER_RUN_COMMAND="${DOCKER_RUN_COMMAND}
    --net=host '\'
    --hostname ${NEPI_DEVICE_ID} '\'
    --network my_custom_network --ip ${NEPI_IP} '\'"
    
    
    if [[ LENGTH OF $NEPI_IP_ALIASES > 0 ]]; then
        echo "Adding IP Aliases"
        echo $NEPI_IP_ALIASES
    
    
    DOCKER_RUN_COMMAND="${DOCKER_RUN_COMMAND}
    --net=host '\'
    
    "
    
    fi 
    
    
    # Set cuda support if needed
    if [[ "$NEPI_DEVICE_ID" == "JETSON" ]]; then
        echo "Enabling Jetson GPU Support TRUE"
    
    DOCKER_RUN_COMMAND="${DOCKER_RUN_COMMAND}
    --gpus all '\'
    --runtime nvidia '\'
    -v /tmp/.X11-unix/:/tmp/.X11-unix '\'"
    
    fi 
    
    
    
    
    # Finish Run Command
    DOCKER_RUN_COMMAND="${NEPI_DOCKER_RUN_COMMAND}
    ${NEPI_ACTIVE_NAME}:${ACTIVE_TAG} /bin/bash '\'
    -c '/opt/nepi/scripts/nepi_start_all.sh'"   


