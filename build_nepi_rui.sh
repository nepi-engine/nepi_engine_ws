##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##

# NEPI Engine Build/Install Script
# This script is a convenience to build/install all nepi-engine components at once.
# Users can optionally skip specific components

# Note, this script assumes that basic NEPI engine filesystem setup and dependency installation
# has already been completed. See
# https://github.com/nepi-engine/nepi_rootfs_tools
# for details.

# It also assumes that preliminary NEPI RUI and NEPI BOT build environment setup is complete. See
# https://github.com/nepi-engine/nepi_rui
# https://github.com/nepi-engine/nepi-bot
# for details

# Note, this script deploys the RUI to on host system and builds the components sequentially. It may be more efficient for you to
# run these steps in parallel in different terminals. Similarly, once everything has been built
# once for a system, it will be more efficient to build individual components that are modified.
sudo -v

CONFIG_USER=nepi
bfile=/home/${CONFIG_USER}/.bashrc
ufile=/home/${CONFIG_USER}/.nepi_bash_utils

if [[ -f "$ufile" ]]; then
    source $ufile
else
    echo "NEPI Utils bash file not found at: ${ufile}"
    exit 1
fi

# Set NEPI folder variables if not configured by nepi aliases bash script
if [[ ! -v NEPI_USER ]]; then
    NEPI_USER=nepi
fi
if [[ ! -v NEPI_HOME ]]; then
    NEPI_HOME=/home/${NEPI_USER}
fi
if [[ ! -v NEPI_DOCKER ]]; then
    NEPI_DOCKER=/mnt/nepi_docker
fi
if [[ ! -v NEPI_STORAGE ]]; then
   NEPI_STORAGE=/mnt/nepi_storage
fi
if [[ ! -v NEPI_CONFIG ]]; then
    NEPI_CONFIG=/mnt/nepi_config
fi
if [[ ! -v NEPI_BASE ]]; then
    NEPI_BASE=/opt/nepi
fi
if [[ ! -v NEPI_RUI ]]; then
    NEPI_RUI=${NEPI_BASE}/nepi_rui
fi
if [[ ! -v NEPI_ENGINE ]]; then
    NEPI_ENGINE=${NEPI_BASE}/nepi_engine
fi
if [[ ! -v NEPI_ETC ]]; then
    NEPI_ETC=${NEPI_BASE}/etc
fi

# RUI build



NEPI_ENGINE_SRC_ROOTDIR=`pwd`
HIGHLIGHT='\033[1;34m' # LIGHT BLUE
ERROR='\033[0;31m' # RED
CLEAR='\033[0m'


#####################################
######  NEPI RUI Install and Build
echo ""

SCRIPT_FOLDER=$(cd -P "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
echo "Installing NEPI RUI Base File System "
sudo rsync -arp ${SCRIPT_FOLDER}/src/nepi_rui/ ${NEPI_BASE}/nepi_rui/
echo "NEPI RUI Deploy Finished"


echo ""
echo "Updating NEPI RUI App File System"
NEPI_RUI_APPS=${NEPI_RUI}/src/rui_webserver/rui-app/src/apps
NEPI_RUI_APPS_IF=${NEPI_RUI}/src/rui_webserver/rui-app/src/Nepi_IF_Apps.js
cd $NEPI_RUI_APPS
directory=$NEPI_RUI_APPS
import_string=''
map_string=''

for file in "$directory"/*; do
  if [ -f "$file" ]; then
    echo "Processing file: $file"
    rui_main_file=''
    rui_main_class=''
    load_yaml_file $file
    if [[ -n "$rui_main_file" && -n "$rui_main_class" ]]; then
        echo $rui_main_file
        rui_filename="./${rui_main_file%.*}"
        echo $rui_main_class
        import_string="${import_string} \n import ${rui_main_class} from \"$rui_filename\" " 
        map_string="${map_string} \n [\"${rui_main_class}\", ${rui_main_class}]," 
    else
        echo "RUI info not found in file ${file}"
    fi
  fi
done

echo ""
echo "Updating App Map Lines in file ${NEPI_RUI_APPS_IF} with:"
if [[ "${map_string: -1}" == "," ]]; then
  map_string="${map_string%,}"
fi
echo -e $map_string
line_num=20
sed -i "${line_num}s/.*/${map_string}/" "$NEPI_RUI_APPS_IF"

echo ""
echo "Updating App Import Lines in file ${NEPI_RUI_APPS_IF} with:"
echo -e $import_string
line_num=16
sed -i "${line_num}s|.*|${import_string}|" "$NEPI_RUI_APPS_IF"

echo ""
echo "NEPI RUI Setup Finished"


######       NEPI RUI           #####
echo ""
echo "Starting NEPI RUI Build"
cd $NEPI_RUI
${NEPI_RUI}/venv/bin/activate 2>/dev/null
source ${NEPI_HOME}/.nvm/nvm.sh
source ./devenv.sh
cd src/rui_webserver/rui-app/
npm run build
deactivate 2>/dev/null
cd ${NEPI_ENGINE_SRC_ROOTDIR}
printf "\n${HIGHLIGHT}*** NEPI RUI Build Finished *** ${CLEAR}\n"


# #####################################


