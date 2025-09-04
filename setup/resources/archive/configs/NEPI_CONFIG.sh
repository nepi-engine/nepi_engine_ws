####################################################
# NEPI USER AND DEVICE CONFIG
export NEPI_USER=nepi
export NEPI_USER_PW=nepi
export NEPI_ADMIN=nepiadmin
export NEPI_ADMIN_PW=nepiadmin
export NEPI_DEVICE_ID=device1

export NEPI_IP=192.168.179.103
export NEPI_NTP_IP=192.168.179.5
export NEPI_DHCP_ON_START=0



####################################################
# NEPI CONTAINER HOST Config
# These settings are used to configure the host OS 
# if NEPI is running in a container
export NEPI_IN_CONTAINER=0
export NEPI_CT_USER="${NEPI_USER^^}"
export NEPI_CT_DEVICE_ID="${NEPI_DEVICE_ID^^}"

#NEPI_CT_NETWORK_ID=$NEPI_NETWORK_ID
#NEPI_CT_HOST_ID=$((NEPI_HOST_ID - 1))
#export NEPI_CONTAINER_IP=${NEPI_CT_NETWORK_ID}:${NEPI_CT_HOST_ID}

####################################################
# NEPI MANAGED SERVICES Config
# NEPI Managed Resources. Set to 0 to turn off NEPI management of this resource
# Note, if enabled for a docker deployment, 
# these system services will be managed in the NEPI HOST OS environment.

export NEPI_MANAGES_NETWORK=1
export NEPI_MANAGES_TIME=1

####################################################
# NEPI HARDWERE CONFIG
# NEPI Hardware Host Options: JETSON,RPI,ARM64,AMD64
export NEPI_HW_TYPE=JETSON
# NEPI Hardware Host Model Options: ORIN, XAVIER, TX2, NANO, RPI4, GENERIC
export NEPI_HW_MODEL=ORIN

# NEPI FS Partition Info.  
export NEPI_AB_FS=1 # Enables NEPI File System backup, update, and archiving if enabled
export MAX_FAIL=3
export FAIL_COUNT=0
# Set to "CONTAINER" if running in container 
# Set to partition path if running directly on device's file system
export NEPI_BOOT_DEVICE=CONTAINER # /dev/mmcblk0p1    
export NEPI_FS_DEVICE=CONTAINER # /dev/mmcblk01           
export NEPI_STORAGE_DEVICE=CONTAINER # /dev/nvme0n1p3  

####################################################
# NEPI SOFTWARE Config
PYTHON_VERSION=3.8
ROS_VERSION=NOETIC
PYTORCH_VERSION=1.13.0
JETPACK_VERSION=5.0.2 # Set to 0 if no nvidia jetpack

export NEPI_PYTHON=$PYTHON_VERSION
export NEPI_ROS=$ROS_VERSION

export NEPI_HAS_CUDA=1
export NEPI_CUDA_VERSION=11.8
export NEPI_HAS_XPU=0

####################################################
# NEPI PARTITION CONFIG
# It is recommended that these folders be create as their own partitions
# so that these files are not affected by any device file system changes

# NEPI Docker Folder
# Set to DOCKER to use dockers native docker image storage location
# Set to custom path to configure a custom docker image storage loacation
export NEPI_DOCKER=/mnt/nepi_docker

# NEPI Storage and Config Folders
export NEPI_STORAGE=/mnt/nepi_storage
export NEPI_CONFIG=/mnt/nepi_config

export DOCKER_MIN_GB=100
export STORAGE_MIN_GB=250
export CONFIG_MIN_GB=1

####################################################
# NEPI FOLDERS CONFIG

# NEPI Folders
export NEPI_SOURCE=/home/${USER}

export NEPI_ENV=nepi_env
export NEPI_HOME=/home/${NEPI_USER}
export NEPI_BASE=/opt/nepi
export NEPI_RUI=${NEPI_BASE}/nepi_rui
export NEPI_ENGINE=${NEPI_BASE}/nepi_engine
export NEPI_ETC=${NEPI_BASE}/etc
export NEPI_SCRIPTS=${NEPI_BASE}/scripts

# NEPI Config Paths
export NEPI_DOCKER_CONFIG=${NEPI_CONFIG}/docker_cfg
export NEPI_FACTORY_CONFIG=${NEPI_CONFIG}/factory_cfg
export NEPI_SYSTEM_CONFIG=${NEPI_CONFIG}/system_cfg
export NEPI_USR_CONFIG=${NEPI_STORAGE}/user_cfg

# NEPI Image Paths
export NEPI_IMPORT_PATH=${NEPI_STORAGE}/nepi_images
export NEPI_EXPORT_PATH=${NEPI_STORAGE}/nepi_images

####################################################
# NEPI FILE SYSTEMS CONFIG
export ACTIVE_CONT=nepi_fs_a
export ACTIVE_VERSION=3p2p0-RC2
export ACTIVE_UPLOAD_DATE=0
export ACTIVE_TAG=jetson-3p2p0-RC2
export ACTIVE_ID=0
export ACTIVE_LABEL=unknown

export INACTIVE_CONT=nepi_fs_b
export INACTIVE_VERSION=3p2p0-RC2
export INACTIVE_UPLOAD_DATE=0
export INACTIVE_TAG=jetson-3p2p0-RC2
export INACTIVE_ID=0
export INACTIVE_LABEL=unknown

export RUNNING_CONT=unknown
export RUNNING_VERSION=unknown
export RUNNING_UPLOAD_DATE=unknown
export RUNNING_TAG=unknown
export RUNNING_ID=unknown
export RUNNING_LABEL=unknown

