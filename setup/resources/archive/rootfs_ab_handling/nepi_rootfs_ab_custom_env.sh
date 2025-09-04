# This file should be modified as needed for a particular NEPI installation
# It provides the runtime information for nepi_rootfs_ab_handling.sh

# The following define the device and partitions for the A/B switching scheme.
# They should be modified manually to match the particular NEPI installation and
# update scheme.

# TYPICAL SD CARD Setup:
#ROOTFS_A_PARTITION="/dev/mmcblk1p1"
#ROOTFS_B_PARTITION="/dev/mmcblk1p2"

# TYPICAL SSD Setup:
ROOTFS_A_PARTITION="/dev/nvme0n1p1"
ROOTFS_B_PARTITION="/dev/nvme0n1p2"

# The following controls how many consecutive boot failures for the active partition are allowed before falling back to 
# backup partition. Export it because it is used in scripts in the ACTIVE rootfs that require export
export MAX_BOOT_FAILURE_COUNT=3

# The following are updated automatically by nepi_rootfs_ab_handling.sh
# Export them because they are used in scripts in the ACTIVE rootfs that require export
export ACTIVE_PARTITION=${ROOTFS_A_PARTITION}
export INACTIVE_PARTITION=${ROOTFS_B_PARTITION}

