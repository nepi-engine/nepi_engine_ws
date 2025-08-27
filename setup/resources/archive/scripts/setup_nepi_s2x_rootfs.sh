#!/bin/bash

# S2X-specific NEPI rootfs setup steps. This is a specialization of the NEPI Jetson rootfs
# and calls that parent script as a pre-step.

# Run the parent script first
sudo ./setup_nepi_jetson_rootfs.sh

# The script is assumed to run from a directory structure that mirrors the Git repo it is housed in.
HOME_DIR=$PWD

# Copy the S2X-specialized Linux config files
sudo cp -r ${HOME_DIR}/config_s2x/* /opt/nepi/config


