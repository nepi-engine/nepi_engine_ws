#!/bin/bash

# Runs at startup, handles rootfs image updates and switches rootfs to the SD card
# This script lives in the init rootfs (typically in embedded flash), not in the full rootfs that
# resides on some removable media.

# 1. Check the boot failure count and if it exceeds the (customizable) threshold, switch ACTIVE and INACTIVE partition roles
# 2. Mount the ACTIVE partition and switch-root over to it

# (Upon successful switch-root, the ACTIVE partition init system will reset the boot failure count)

# For local testing, set the ROOTFS_AB_TESTING env. variable to any non-empty string before running this script. 
# This will use CWD paths rather than absolute system paths and avoid the final chroot

if [[ -z $ROOTFS_AB_TESTING ]]; then
    echo "NEPI ROOTFS A/B Handling"
    CUSTOMIZATION_FILE="/opt/nepi/nepi_rootfs_ab_custom_env.sh"
    BOOT_FAILURE_COUNT_FILE="/opt/nepi/nepi_boot_failure_count.txt"
    NEW_IMG_STAGING_MOUNTPOINT=/mnt/staging
    ACTIVE_IMG_MOUNTPOINT="/nepi_root"
else
    echo "NEPI ROOTFS A/B Testing Mode... Using CWD paths and skipping final installation"
    CUSTOMIZATION_FILE="./nepi_rootfs_ab_custom_env.sh"
    BOOT_FAILURE_COUNT_FILE="./nepi_boot_failure_count.txt"
    NEW_IMG_STAGING_MOUNTPOINT="./mnt_staging"
    ACTIVE_IMG_MOUNTPOINT="./nepi_root"
fi

NEW_IMG_COMPRESSED_FILE_SEARCH_STRING="${NEW_IMG_STAGING_MOUNTPOINT}/nepi_full_img/*img.raw.gz"

# The CUSTOMIZATION_FILE must exist and be valid for any of the rest of this to work.
if [ ! -f ${CUSTOMIZATION_FILE} ]; then
	echo "CRITICAL ERROR! Could not find ${CUSTOMIZATION_FILE}"
	exit 1
fi
source ${CUSTOMIZATION_FILE}

# Now check for previous boot failures and switch over to inactive partition when appropriate
# The NEPI full ROOTFS will reset this file back to zero whenever a successful boot occurs.
if [ -f ${BOOT_FAILURE_COUNT_FILE} ]; then
    BOOT_FAILURE_COUNT=`cat ${BOOT_FAILURE_COUNT_FILE}`
    if (( ${BOOT_FAILURE_COUNT} < ${MAX_BOOT_FAILURE_COUNT} )); then
        echo "Boot failure count threshold (${MAX_BOOT_FAILURE_COUNT}) not exceeded... attempting to boot from ACTIVE partition ${ACTIVE_PARTITION}"
        BOOT_FAILURE_COUNT=$((BOOT_FAILURE_COUNT+1))
        echo ${BOOT_FAILURE_COUNT} > ${BOOT_FAILURE_COUNT_FILE}
    else
        echo "Detected ${BOOT_FAILURE_COUNT} consecutive boot failures from ${ACTIVE_PARTITION}... switching to inactive partition ${INACTIVE_PARTITION}"
        # Must do the switch in stages using temporary strings
        sed -i 's/ ACTIVE_PARTITION=/ INACTIVE_PARTITION_TMP=/' ${CUSTOMIZATION_FILE}
        sed -i 's/ INACTIVE_PARTITION=/ ACTIVE_PARTITION=/' ${CUSTOMIZATION_FILE}
        sed -i 's/ INACTIVE_PARTITION_TMP=/ INACTIVE_PARTITION=/' ${CUSTOMIZATION_FILE}

        # And re-source the customization file to get the new values into this environment
        source ${CUSTOMIZATION_FILE}

        # Reset the BOOT_FAILURE_COUNT file
        echo "1" > ${BOOT_FAILURE_COUNT_FILE}
    fi
else
    echo "Warning... file ${BOOT_FAILURE_COUNT_FILE} is missing... creating a new one"
    echo "1" > ${BOOT_FAILURE_COUNT_FILE}
fi

# Now we are ready to mount and chroot into the ACTIVE partition
echo "Will now load ACTIVE rootfs from ${ACTIVE_PARTITION}"
EXT4_OPT="-o defaults -o errors=remount-ro -o discard"
modprobe ext4

mkdir -p ${ACTIVE_IMG_MOUNTPOINT}
if ! mount -t ext4 ${EXT4_OPT} ${ACTIVE_PARTITION} ${ACTIVE_IMG_MOUNTPOINT}; then
    echo "ERROR! Failed to mount ACTIVE partition ${ACTIVE_PARTITION} to ${ACTIVE_IMG_MOUNTPOINT}"
else
    if [[ -z $ROOTFS_AB_TESTING ]]; then
        echo "Switching to ACTIVE rootfs"
        cd ${ACTIVE_IMG_MOUNTPOINT}
        /bin/systemctl --no-block switch-root ${ACTIVE_IMG_MOUNTPOINT}
    fi
fi
