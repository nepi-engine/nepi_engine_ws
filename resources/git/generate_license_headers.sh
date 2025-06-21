#!/bin/bash

# Leverage licenseheaders Python module to update license headers
# Requires licenseheaders is on python3 path (e.g., pip3 install licenseheaders) 
# and the NEPI source header license text template file is passed in as first argument
# to this script

TEMPLATE_FILE=$1
TARGET_DIR='.'
EXCLUSIONS='*generate_license_headers.sh* 
    *catkin_tools*
	*package.xml*
	*zed-ros-wrapper*
	*nepi_darknet_ros*
	*nepi_gpsd*
	*num_factory*
	*yaml
	*__init__.py
	*setup.py
	*timestamp.proto*
	*wondershaper*
	*impl_c/frozen*
	*drivers/iqr_ros_pan_tilt*'
    
OWNER='Numurus, LLC <https://www.numurus.com>'
PROJECT='nepi-engine'
PROJECT_URL='https://github.com/nepi-engine'

# Create a dummy Python file to generate the LICENSE file
touch ${TARGET_DIR}/license_dummy.py

# Generate headers
python3 -m licenseheaders -t ${TEMPLATE_FILE} -d ${TARGET_DIR} -x ${EXCLUSIONS} -o "${OWNER}" -n ${PROJECT} -u ${PROJECT_URL} -cy

# Remove leading '#' to generate the LICENSE file
sed -i -e 's/^#//g' ${TARGET_DIR}/license_dummy.py
mv ${TARGET_DIR}/license_dummy.py LICENSE

# Add the license to all the NEPI-owned submodules
NEPI_SUBMODULES='nepi_automation_mgr    
	nepi_edge_sdk_link
	nepi_edge_sdk_v4l2
	nepi-bot
	nepi-bot/nepi-protobuf
	nepi-bot/src/nepi_edge_sw_mgr
	nepi_edge_sdk_lsx
	nepi_link_ros_bridge
	nepi_edge_sdk_ai
	nepi_edge_sdk_nav_pose
	nepi_ros_interfaces
	nepi_edge_sdk_base
	nepi_edge_sdk_onvif
	nepi_rui
	nepi_edge_sdk_genicam
	nepi_edge_sdk_ptx'

for submod in $NEPI_SUBMODULES; do
	cp LICENSE ./src/$submod
done
