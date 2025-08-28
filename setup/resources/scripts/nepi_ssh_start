#! /bin/bash
##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##

# Start NEPI ssh service
if [[ -v NEPI_MANAGES_SSH ]]; then
  if [[ "$NEPI_MANAGES_SSH" -eq 1 ]]; then
    echo "Starting NEPI SSH Management Services."
    sudo /etc/init.d/sshd start
  else
    echo "NEPI SSH Management Disabled."
  fi

else
  echo "NEPI SSH Management Disabled."
fi

