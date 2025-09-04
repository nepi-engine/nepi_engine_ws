#!/bin/sh

# Update a nepi rootfs image to be a licensed pre-built image

# This script must be run from the rootdir of nepi_production_tools that has been deployed to the
# target system. 

# Set up nepi_check_license (license management, etc.)
chmod +x /opt/nepi/config/etc/license/nepi_check_license.py
cp /opt/nepi/config/etc/license/nepi_check_license.service /etc/systemd/system/
gpg --import /opt/nepi/config/etc/license/nepi_license_management_public_key.gpg
sudo systemctl enable nepi_check_license
#gpg --import /opt/nepi/config/etc/nepi/nepi_license_management_public_key.gpg

echo "***** nepi_check_license license manager is installed... you must still provide a valid license file in /mnt/nepi_storage/license *****"

# TODO: Update license files and source code comments per the nepi_commercial.tmpl license template
# Will use python "licenseheaders" package, probably via 
# /mnt/nepi_storage/src/nepi_engine_base/generate_license_headers.sh ./resources/license_templates/nepi_commercial.tmpl
# but then must rebuild the software to get new files installed to /opt/nepi.
