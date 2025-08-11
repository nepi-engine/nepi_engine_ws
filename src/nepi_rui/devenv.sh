#!/bin/bash
##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##

# Setup environment

# Use the correct python and npm
source ./venv/bin/activate || echo "Failed to load venv"
source ~/.nvm/nvm.sh
# Set environment variables
export RUI_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && nvm use )"
