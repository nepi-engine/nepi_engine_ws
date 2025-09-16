#!/bin/bash

##
## Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
##
## This file is part of nepi-engine
## (see https://github.com/nepi-engine).
##
## License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
##


# This file configigues an installed NEPI File System


echo "########################"
echo "NEPI CUDA SETUP"
echo "########################"

# Load System Config File
source $(dirname $(pwd))/config/load_system_config.sh
if [ $? -eq 1 ]; then
    echo "Failed to load ${SYSTEM_CONFIG_FILE}"
    exit 1
fi

# Check User Account
CONFIG_USER=$NEPI_USER
if [[ "$USER" != "$CONFIG_USER" ]]; then
    echo "This script must be run by user account ${CONFIG_USER}."
    echo "Log in as ${CONFIG_USER} and run again"
    exit 2
fi

echo ""
echo "Installing CUDA Software Support"

# Create and change to tmp install folder
sudo chown -R nepi:nepi ${STORAGE}
TMP=${STORAGE}\tmp
mkdir $TMP
cd $TMP



#***************************************
# Run CMake with CUDA flags and other desired options. Adjust CUDA_ARCH_BIN to match your gpu architecture 
# CUDA_ARCH OPTIONS
#Jetson ORIN 8.7
#Jetson XAVIER 7.2
#Jetson TX2	6.2
#Jetson NANO 5.3

CUDA_ARCH=8.7

declare -A cuda_archs
cuda_archs["ORIN"]=8.7
cuda_archs["XAVIER"]=7.2
cuda_archs["TX2"]=6.2
cuda_archs["NANO"]=5.3

# Iterate through the dictionary to find a match
for key in "${!cuda_archs[@]}"; do
  if [[ "$key" == "$NEPI_HW_MODEL" ]]; then
    CUDA_ARCH="${cuda_archs[$key]}"
    break # Exit the loop once a match is found
  fi
done





####################################
# Create USER python folder
mkdir -p ${HOME}/.local/lib/python${NEPI_PYTHON}/site-packages
####################################

####################################
# Install Required Libriaries
####################################
sudo apt update
sudo apt install -y build-essential cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev python3-dev python3-numpy libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libdc1394-22-dev
sudo apt-get install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
sudo apt-get install -y python3.10-dev python-dev python-numpy python3-numpy
sudo apt-get install -y libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libdc1394-22-dev
sudo apt-get install -y libv4l-dev v4l-utils qv4l2 v4l2ucp    
sudo apt-get install -y libopenblas-base libopenmpi-dev libomp-dev 
sudo apt-get install -y ninja



####################################
# Unistall existing packages
####################################
echo "Will uninstall existing packages if exist"
sudo -H python${PYTHON_VERSION} -m pip uninstall --no-input opencv-python
sudo -H python${PYTHON_VERSION} -m pip uninstall --no-input open3d
sudo -H python${PYTHON_VERSION} -m pip uninstall --no-input tourch
sudo -H python${PYTHON_VERSION} -m pip uninstall --no-input tourchvision

#sudo -H python${PYTHON_VERSION} -m pip install -upgrade cython
sudo -H python${PYTHON_VERSION} -m pip install cupy-cuda${CUDA_ARCH}x





############################################
#Install cuda 11.8
############################################
echo "Installing Cuda ${NEPI_CUDA_VERSION}"


#Check version
string=$(nvcc --version)
key=release
value=$(echo "$string" | grep "${key}" | awk '{print $NF}' | cut -d'.' -f1-2)
### TO DO: Check if Cuda 11.8 installed


# https://developer.nvidia.com/cuda-11-8-0-download-archive?target_os=Linux&target_arch=aarch64-jetson&Compilation=Native&Distribution=Ubuntu&target_version=20.04&target_type=deb_local

####### TO DO: Get From NEPI Cuda Package Download
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/arm64/cuda-ubuntu2004.pin
####### 


sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/11.8.0/local_installers/cuda-tegra-repo-ubuntu2004-11-8-local_11.8.0-1_arm64.deb
sudo dpkg -i cuda-tegra-repo-ubuntu2004-11-8-local_11.8.0-1_arm64.deb
sudo cp /var/cuda-tegra-repo-ubuntu2004-11-8-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install cuda


# Source nepi aliases before exit
echo " "
echo "Sourcing bashrc with CUDA SETUP"
sleep 1 & source $BASHRC
wait


############################################
# Install cv2 with cuda support
############################################
echo 'Installing CV2 with Cuda support'
cd $TMP
#############
### TO DO: DOWNLOAD and INSTALL From NEPI PREMADE BUILD PACKAGE
git clone https://github.com/opencv/opencv.git
git clone https://github.com/opencv/opencv_contrib.git

cd opencv
git checkout 4.x
cd ../opencv_contrib
git checkout 4.x

cd ../opencv
mkdir build



# https://stackoverflow.com/questions/42638342/cannot-install-opencv-3-1-0-with-python3-cmake-not-including-or-linking-python

cmake -D CMAKE_BUILD_TYPE=Release \
    -D ENABLE_CXX11=ON \
    -D FFMPEG=ON \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D WITH_TBB=ON \
    -D BUILD_NEW_PYTHON_SUPPORT=ON \
    -D WITH_V4L=ON \
    -D WITH_QT=ON \
    -D WITH_OPENGL=ON \
    -D WITH_GTK=ON \
    -D WITH_GTK_2_X=ON \
    -D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib/modules \
    -D WITH_CUDA=ON \
    -D WITH_CUDNN=ON \
    -D OPENCV_DNN_CUDA=ON \
    -D CUDA_ARCH_BIN="${CUDA_ARCH}" \
    -D CUDA_ARCH_PTX="" \
    -D OPENCV_GENERATE_PKGCONFIG=ON \
    -D WITH_GSTREAMER=ON \
    -D WITH_LIBV4L=ON \
    -D BUILD_opencv_python3=ON \
    -D BUILD_EXAMPLES=ON \
    -D PYTHON3_EXECUTABLE=$(which python3) \
    -D PYTHON_INCLUDE_DIR=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
    -D PYTHON_INCLUDE_DIR2=$(python3 -c "from os.path import dirname; from distutils.sysconfig import get_config_h_filename; print(dirname(get_config_h_filename()))") \
    -D PYTHON_LIBRARY=$(python3 -c "from distutils.sysconfig import get_config_var;from os.path import dirname,join ; print(join(dirname(get_config_var('LIBPC')),get_config_var('LDLIBRARY')))") \
    -D PYTHON3_NUMPY_INCLUDE_DIRS=$(python3 -c "import numpy; print(numpy.get_include())") \
    -D PYTHON3_PACKAGES_PATH=$(python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") \
    -D BUILD_TESTS=OFF \
    -D BUILD_PERF_TESTS=OFF \
    -D BUILD_EXAMPLES=OFF \
    ..

make -j$(nproc)
cd ./../..
###################

# Install CV2 Build
cd opencv/build
sudo make install
sudo ldconfig
cd ./../..

echo "Updating bashrc file with CV2 SETUP"
BASHRC=${HOME}/.bashrc
if grep -qnw $BASHRC -e "##### CV2 SETUP #####" ; then
    echo "Done"
else
    echo " " | sudo tee -a $BASHRC
    echo "##### CV2 SETUP #####" | sudo tee -a $BASHRC
    #echo '/usr/lib/python3/dist-packages/cv2/python-3.10
fi
sudo cp $BASHRC /root/.bashrc


## Fix no python cv2 issue
# https://github.com/opencv/opencv/issues/21359#issuecomment-1003005474
# https://github.com/dusty-nv/jetson-containers/issues/237


# Check if cuda support
python -c "import cv2; print(cv2.__version__); print(cv2.cuda.getCudaEnabledDeviceCount());print(cv2.getBuildInformation())"



############################################
# Install Pytorch 
############################################
echo 'Installing PyTorch with Cuda support'
# Find Compatable PyTorch Version https://github.com/pytorch/pytorch/blob/main/RELEASE.md
cd $TMP
git clone --recursive --branch v${PYTORCH_VERSION} https://github.com/pytorch/pytorch.git
cd pytorch

export USE_NCCL=0  # Disable NCCL if not using distributed training
export USE_DISTRIBUTED=0 # Disable distributed training if not needed
export TORCH_CUDA_ARCH_LIST="${CUDA_ARCH}" # Specify CUDA architecture for Host Device
export PYTORCH_BUILD_VERSION=$PYTORCH_VERSION # Match your chosen PyTorch version
export PYTORCH_BUILD_NUMBER=1

pip install -r requirements.txt
pip install scikit-build

MAX_JOBS=1 python setup.py bdist_wheel

pip install dist/*.whl

# test install
python -c "import torch; print(torch.__version__); print(str(torch.cuda.is_available()))"

############################################
# Install Torchvision 
############################################
echo 'Installing Torchvision with Cuda support'
cd $TMP
#Installing Torchvision
# find Numpy and Python compatable version to torch version https://pypi.org/project/torchvision/


#Instructions can be found https://forums.developer.nvidia.com/t/pytorch-forjetson/
#https://forums.developer.nvidia.com/t/how-to-install-torchvision-with-torch1-14-0-with-cuda-11-4/245657/2

# NOTE: You can find the torch and torchvision compatibility matrix here:
# https://github.com/pytorch/vision 
# then look under "Tags" find version, then click the "tar.gz" file link


wget https://files.pythonhosted.org/packages/25/44/ddd56d1637bac42a8c5da2c8c440d8a28c431f996dd9790f32dd9a96ca6e/torchvision-0.23.0-cp310-cp310-manylinux_2_28_aarch64.whl


'
Example
tar -xvzf vision-0.14.0.tar.gz
cd vision-0cd.14.0
export BUILD_VERSION=0.14.0
cd ..
sudo chown -R nepi:nepi vision-0.14.0
cd vision-0.14.0
sudo python setup.py install

tar -xvzf vision-0.16.2.tar.gz
cd vision-0.16.2
export BUILD_VERSION=0.16.2
cd ..
sudo chown -R nepi:nepi vision-0.16.2
cd vision-0.16.2
sudo python setup.py install
'

#Check Installed
python -c "import torchvision; print(torchvision.__version__)"

python
import torchvision
print(torchvision.__version__)


rosstop
rosstart # Look for errors




#################################
# Install open3d with cuda support
##################################
echo 'Installing Open3d with Cuda Support'

# Ref https://www.open3d.org/docs/0.13.0/arm.html


___________________________________________________________
1) Connect your NEPI device to the internet

___________________________________________________________
2) Modify .bashrc file. 
FROM REF https://github.com/jetsonhacks/buildLibrealsense2TX/issues/13
a) SSH into your NEPI device
b) Open your .bashrc file "vi ~/.bashrc", and add the following to the end 

# cuda
export CUDA_HOME=/usr/local/cuda-11
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CUDA_HOME/bin/lib64:$CUDA_HOME/bin/extras/CUPTI/lib64
export PATH=$PATH:$CUDA_HOME/bin

c) Save and exit
d) Re-source the file

source ~/.bashrc

__________________________________________________________
4) Build Open3D in a virtual python environment. 
NOTE: **The make process below took over an 5 hours to run. Maybe faster with rosstop
# Ref https://www.open3d.org/docs/0.13.0/arm.html
# Ref https://www.open3d.org/docs/0.11.0/compilation.html
# Ref https://groups.google.com/g/alembic-discussion/c/SVO3PEpzQvk?pli=1
# Ref https://stackoverflow.com/questions/72278881/no-cmake-cuda-compiler-could-be-found-when-installing-pytorch
# Ref https://www.open3d.org/docs/latest/tutorial/Advanced/headless_rendering.html

a) SSH into your NEPI device and type the following

rosstop

Needs cuda 11.5+
Check
nvcc --version

Download from
https://developer.download.nvidia.com/compute/cuda/opensource/
then install

tar -xzf archive-name.tar.gz
cd archive-name
./configure
make
sudo make install


b) Setup python virtual environment. SSH into your NEPI device and type the following

# Just run once, then use the source and deactivate to enter/exit venv

cd /mnt/nepi_storage/tmp
#sudo apt install python3.8-venv
python3.8 -m venv open3d_venv


# Run to enter venv

source open3d_venv/bin/activate


e.  Make sure python is using 3.#
https://unix.stackexchange.com/questions/410579/change-the-python3-default-version-in-ubuntu
cd /usr/bin
sudo ln -sfn python3 python


c)

pip install cmake
sudo pip install cmake

git clone --recursive https://github.com/intel-isl/Open3D
cd Open3D
git submodule update --init --recursive
util/
install_deps_ubuntu.sh




b)Edit the CMakeLists.txt 

# Open3D build options
option(BUILD_SHARED_LIBS          "Build shared libraries"                   ON )
option(BUILD_EXAMPLES             "Build Open3D examples programs"           ON )
option(BUILD_UNIT_TESTS           "Build Open3D unit tests"                  OFF)
option(BUILD_BENCHMARKS           "Build the micro benchmarks"               OFF)
option(BUILD_PYTHON_MODULE        "Build the python module"                  ON )
option(BUILD_CUDA_MODULE          "Build the CUDA module"                    ON )
option(BUILD_WITH_CUDA_STATIC     "Build with static CUDA libraries"         ON )


line 328. Change "find_package(Python3 3.6" line to
find_package(Python3 3.8 EXACT COMPONENTS


d) Build Open3D cpp and python modules

cd /mnt/nepi_storage/tmp/Open3D
mkdir build
cd build

python -V


sudo CUDACXX=/usr/local/cuda-11/bin/nvcc cmake ..

sudo make -j$(nproc)

sudo make install

# Install Open3D python package (optional)
sudo make install-pip-package -j$(nproc)




##f) For headless rendering, remake with the following options. Takes about 30min to rebuild.
sudo CUDACXX=/usr/local/cuda-11/bin/nvcc cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_CUDA_MODULE=ON \
    -DBUILD_GUI=OFF \
    -DENABLE_HEADLESS_RENDERING=ON \
    -DUSE_SYSTEM_GLEW=OFF \
    -DUSE_SYSTEM_GLFW=OFF \
    -DBUILD_TENSORFLOW_OPS=OFF \
    -DBUILD_PYTORCH_OPS=OFF \
    -DBUILD_UNIT_TESTS=OFF \
    -DPYTHON_EXECUTABLE=$(which python) \
    ..

sudo make -j$(nproc)

sudo make install

# Install Open3D python package (optional)
sudo make install-pip-package -j$(nproc)


OR************

# NOTE: If you want to jump to compiling with headless rendering support without
#  testing the build in the Open3D gui, jump to step f

sudo CUDACXX=/usr/local/cuda-11/bin/nvcc cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_CUDA_MODULE=ON \
    -DBUILD_GUI=ON \
    -DBUILD_TENSORFLOW_OPS=OFF \
    -DBUILD_PYTORCH_OPS=OFF \
    -DBUILD_UNIT_TESTS=OFF \
    -DPYTHON_EXECUTABLE=$(which python) \
    ..

sudo make -j$(nproc)

sudo make install

# Install Open3D python package (optional)
sudo make install-pip-package -j$(nproc)


e) test the install. Run Open3D GUI (optional, available on when -DBUILD_GUI=ON)
./Open3D/Open3D

*************************

___________________________________________________________
6) make and install python package

a) exit python venv
# Skip this step if you want to install  in python venv
# If you deactivate, it will be installed in normal nepi python environment

deactivate


b) Upgrad pip
//sudo python3.8 -m pip install --upgrade pip

c) First install the new cuda open3d package
# You will get an error on this step. Ignore it

cd /mnt/nepi_storage/tmp/Open3D/build/lib/python_package/pip_package/
pip install open3d-0.18.0+84b8e071e-cp38-cp38-manylinux_2_31_aarch64.whl --ignore-installedpyt
sudo pip install open3d-0.18.0+84b8e071e-cp38-cp38-manylinux_2_31_aarch64.whl --ignore-installed

# Check installed open3d module version

pip freeze | grep open3d

d) Next install standard open3d-cpu without overwriting the cuda version to fix python import error
# You will get an error on this step. Ignore it

pip install open3d --ignore-installed
sudo pip install open3d --ignore-installed

# Check installed open3d module version still the cuda version from step b

pip freeze | grep open3d


??????????????
//f) Fix NEPI package versions

//pip install setuptools==45.2.0
//sudo pip install setuptools==45.2.0

//e) check python open3d module import

//python -c "import open3d; print(open3d)"

reboot

python
import open3d
from open3d._build_config import _build_config
print(_build_config)









##################################
# FIX SOME JETSON ISSUES
##################################
# Work-around opencv path installation issue on Jetson (after jetpack installation)
# https://github.com/jetsonhacks/buildLibrealsense2TX/issues/13

echo 'Fixing Some Jetson Issues'
sudo ln -s /usr/include/opencv4/opencv2/ /usr/include/opencv
sudo ln -s /usr/lib/aarch64-linux-gnu/cmake/opencv4 /usr/share/OpenCV



##################################
echo 'Cuda Software Support Complete'
##################################