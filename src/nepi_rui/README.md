<!--
Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.

This file is part of nepi-engine
(see https://github.com/nepi-engine).

License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
-->
# nepi_rui

Web server for the NEPI Resident User Interface. Served by a NEPI device, runs in user's browser.

Architecture:
![Alt text](/resources/architecture.png?raw=true "Architecture")


## Build/Install Preliminaries
The preliminary steps in this section are typically only required once during new system bring-up.

### NEPI Pre-installed Dependencies
**The setup steps in this subsection are typically already completed as part of the NEPI Rootfs bring-up or pre-installation. They are preserved here in case the NEPI RUI must be built on a non-conformant system.**

1. [Install ROS Melodic](http://wiki.ros.org/kinetic/Installation/Ubuntu) and the following Python and build tools:

        sudo apt-get install python python-wstool python-catkin-tools python-pip

1. Setup pip and a virtual environment:

        pip install --user -U pip
        pip install --user virtualenv

   Note: if you get the error ``ImportError: cannot import name main``, open a new terminal and retry the last command.        

1. Install nvm (node version manager):

        curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
        nvm install 8.11.1 # RUI-required Node version as of this script creation

### Python Virtualenv Setup Steps (One-time)
The following steps set up the python virtualenv for the RUI backend. This sequence typically only needs to be run once -- and always from the final install location for nepi_rui since virtualenv folders cannot be moved around the system.

        python -m virtualenv venv
        source ./devnev.sh
        pip install -r requirements.txt

where the final two steps should be rerun any time Python dependencies as specified in requirements.txt are altered.

### NPM Package Install Steps (One-time)
The following steps install the Node/React/etc. packages required for the RUI frontend. This sequence typically only needs to be run once -- and always from the final install location for nepi_rui.

        source ./devenv.sh
        cd src/rui_webserver/rui-app && npm install

where the final two steps should be rerun any time Node packages as specified in package.json are altered.

## Deprecation Warnings
1. The RUI relies on node.js 8.11.1, which has some noted vulnerabilities -- it should be updated to later node version.

## Development

When developing, always source the `devenv.sh` to ensure the correct versions of Python, node and define environment variables:

        cd /opt/nepi/rui
        source devenv.sh

>Note: If using the unified _nepi_engine_build_complete.sh_ build script in parent repository _nepi_engine_ws_, the devenv.sh file is properly sourced prior to the build, so you do not need to do that step manually.

### Frontend

To build the frontend run this command in `src/rui_webserver/rui-app/`:

        npm run build

Building the frontend is necessary after initial checkout (as the frontend build is not stored in the repo), but after that only necessary when making changes to frontend code.

>Note: If using the unified _nepi_engine_build_complete.sh_ 

### Backend

When changing backend code, run the webserver with:

    rosrun nepi_rui run_webserver.py

## Targets without internet access

Some targets do not have internet access, so installation of dependencies is best done in a QEMU environment on a development host in a `chroot` of the mounted root filesystem media of the target or a loopback device that cotains the complete rootfs of the target. Briefly, that involves the following steps on the host system (where we assume that the filesystem media/loopback is mounted at /mnt/nepi_rootfs)

        sudo apt install qemu-user-static
        sudo mount -t proc proc ~/mnt/nepi_rootfs/proc
        cp $(which qemu-arm-static) ~/mnt/nepi_rootfs
        cp etc/resolv.conf ~/mnt/nepi_rootfs/etc/resolv.conf
        sudo chroot ~/mnt/nepi_rootfs /bin/bash

Once this is complete, you can proceed to install dependencies and set up the Python virtual environment as described above. When finished unmount the rootfs media or loopback and load on the target.

## Running on the target

The web server backend can be manually started with

        /opt/nepi/rui/etc/start_rui.sh        

after which the webserver should be available on port 5003 of any IP address assigned to the device.

## Automate Start-up
A start-up script is provided at `nepi_rui/etc/start_rui.sh`. This can be automatically run by installing `systemd` services file `nepi_rui/launch/nepi_rui.service`:

        sudo cp /opt/nepi/rui/etc/nepi_rui.service /etc/systemd/system
        sudo systemctl enable nepi_rui

The `nepi_rui.service` unit requires the `roslaunch.service` provided in the `nepi_sdk` repository to guarantee that `rosbridge` is also launched, so ensure this is also installed and enabled on the taget device.

## Image Source Filter

The file `img_filter.json` located in the `rui-app` directory can be used to filter the image source topics visible in the UI.  The filter is a regular expression that is tested on the full topic string before adding the image topic to the drop down menus.

Examples:

        {
            "filter": "image_raw$"
        }

Only topics with the phrase `image_raw` at the end of the topic will show up in camera topic drop down menus.

        {
            "filter": "^/numurus"
        }

Only topics with the phrase `/numurus` at the beginning of the topic will show up in camera topic drop down menus.
