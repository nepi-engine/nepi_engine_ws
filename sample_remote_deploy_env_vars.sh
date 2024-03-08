##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##

# This file contains a set of sample environment variables
# required for deploying nepi_engine_ws to a remote NEPI
# device via the deploy_nepi_engine_source.sh script
#
# You can copy this file and edit it as necessary, then
# source it into your shell environment prior to running
# the deploy script, e.g.:
#
#   $ source ./sample_remote_deploy_env_vars.sh
#
# Alternatively, you can add these definitions
# directly to your .bashrc file
#
# If not deploying to a remote target (i.e., doing development
# directly on a properly prepared NEPI device), the NEPI_REMOTE_SETUP=0 value is
# already in the environment and the other env. variables are ignored
# with the exception of NEPI_TARGET_SRC_DIR (which defaults to the standard
# NEPI device source code folder if not set), so typically you do not need to source
# anything into your environment in this case.

# NEPI Engine Deployment Env. Variables
export NEPI_REMOTE_SETUP=1
export NEPI_TARGET_IP=192.168.179.103
export NEPI_TARGET_USERNAME=nepi
export NEPI_SSH_KEY=~/.ssh/nepi_default_ssh_key_ed25519
export NEPI_TARGET_SRC_DIR=/mnt/nepi_storage/nepi_src # This is the default if unset, too
