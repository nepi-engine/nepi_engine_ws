# This is the base sys_env.bash file that sets up the ROS namespace
# of the device and launch files.

# The ROOTNAME is used as the first namespace element. It is numurus by default, but can be overridden here
export ROOTNAME=nepi

# The DEVICE_TYPE represents the "name" of the device
export DEVICE_TYPE=S2X

# The DEVICE_SN must be set and should be a unique serial number/identifier for each system.
export DEVICE_SN=000000

# The DEVICE_ID is included in the device ROS namespace. If left unset, it will be assigned to the S/N
export DEVICE_ID=device1

# Controls logging for both ROS1 and ROS2
export ROS_LOG_DIR=/mnt/nepi_storage/logs/ros_log

# ROS1 Stuff - Leave it all "TBD" to avoid launching any ROS1 nodes
# The ROS1_PACKAGE must be set as the package that contains ROS1_LAUNCH_FILE
export ROS1_PACKAGE=nepi_env
# The launch file must be installed in the namespace of the ROS1_PACKAGE
export ROS1_LAUNCH_FILE=nepi_base.launch
# ROS_MASTER_URI may be modified for systems with a remote rosmaster
# Note, though, that there are other system file modifications required, so you
# should use the set_rosmaster ROS topic instead of editing ROS_MASTER_URI directly.
export ROS_MASTER_URI=http://localhost:11311

# ROS2 Stuff - Leave it all TBD to avoid launching any ROS2 nodes
export ROS2_PACKAGE=TBD
export ROS2_LAUNCH_FILE=TBD
export ROS2_LAUNCH_ARGS=TBD
