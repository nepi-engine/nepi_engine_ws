## CONNECT NEPI DEVICE TO INTERNET BEFORE PROCEEDING


bash_aliases ############################################
- update .bash_aliases
vi ~/.bash_aliases

# Some helpful aliases for NEPI

#NEPI folder shortcuts
export AUTO="/mnt/nepi_storage/automation_scripts"
export DATA="/mnt/nepi_storage/data"
export AI="/mnt/nepi_storage/ai_models"
export AIF="/opt/nepi/ros/share/nepi_ai_ifs"
export INSTALLS="/mnt/nepi_storage/installs"
export SRC="/mnt/nepi_storage/nepi_src"
export SRC_NEPI="/mnt/nepi_storage/nepi_src/nepi_engine_ws"
export TMP="/mnt/nepi_storage/tmp"
export NFI="/mnt/nepi_storage/nepi_full_img"
export NFIA="/mnt/nepi_storage/nepi_full_img_archive"
export NEPI="/opt/nepi/ros"
export LIB="/opt/nepi/ros/lib"
export SHARE="/opt/nepi/ros/share"
export LAUNCH="/opt/nepi/ros/share/nepi_edge_sdk_base/launch"
export NEPI_BASE="/opt/nepi/ros/lib/python3/dist-packages/nepi_edge_sdk_base"
export NUID="/opt/nepi/nepi_link/nepi-bot/devinfo"
export DRIVERS="/opt/nepi/ros/lib/nepi_drivers"
export CONNECT="/opt/nepi/nepi_link/nepi-bot/lb/data"
export RUI_ENV="/opt/nepi/nepi_rui"
export RUI_SRC="/opt/nepi/nepi_rui/src/rui_webserver/rui-app/src"

# NEPI navigation shortcuts
alias auto="cd $AUTO"
alias data="cd $DATA"
alias ai="cd $AI"
alias aif="cd $AIF"
alias installs="cd $INSTALLS"
alias src="cd $SRC"
alias src_nepi="cd $SRC_NEPI"
alias tmp="cd $TMP"
alias nfi="cd $NFI"
alias nfia="cd $NFIA"
alias nepi="cd $NEPI"
alias lib="cd $LIB"
alias share="cd $SHARE"
alias launch="cd $LAUNCH"
alias nepi_base="cd $NEPI_BASE"
alias nuid="cd $NUID"
alias drivers="cd $DRIVERS"
alias connect="cd $CONNECT"
alias rui_env="cd $RUI_ENV"
alias rui_src="cd $RUI_SRC"


# NEPI build shortcuts
alias nepibld="
cd $SRC/nepi_engine_ws/
./nepi_engine_build_complete.sh"

# NEPI build shortcuts
alias codebld="
cd $SRC/nepi_engine_ws/
./nepi_engine_build_code.sh"


alias ruibld="
cd $RUI_ENV
source devenv.sh
sleep 1
cd $RUI_SRC
npm run build
deactivate"

# NEPI ros stop and start shortcutsF
alias rosstop="sudo systemctl stop roslaunch"
alias rosstart="sudo /opt/nepi/ros/etc/roslaunch.sh"

# Inform that this is the target hardware
export NEPI_REMOTE_SETUP=0

# CUDA Helpers (Open3D, etc)
export CUDA_HOME=/usr/local/cuda-11
export CUPY_NVCC_GENERATE_CODE=current
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CUDA_HOME/bin/lib64:$CUDA_HOME/bin/extras/CUPTI/lib64
export PATH=$PATH:$CUDA_HOME/bin

export PYTHONPATH=$PYTHONPATH:/opt/nepi/ros/lib/nepi_drivers

export SETUPTOOLS_USE_DISTUTILS=stdlib

export LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libgomp.so.1


####################
Install cuda 11.8

Check version
nvcc --version

https://developer.nvidia.com/cuda-11-8-0-download-archive?target_os=Linux&target_arch=aarch64-jetson&Compilation=Native&Distribution=Ubuntu&target_version=20.04&target_type=deb_local


Please ensure your device is configured per the CUDA Tegra Setup Documentation.
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/arm64/cuda-ubuntu2004.pin
sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/11.8.0/local_installers/cuda-tegra-repo-ubuntu2004-11-8-local_11.8.0-1_arm64.deb
sudo dpkg -i cuda-tegra-repo-ubuntu2004-11-8-local_11.8.0-1_arm64.deb
sudo cp /var/cuda-tegra-repo-ubuntu2004-11-8-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install cuda



####################
#install python tools


sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install python3.8
sudo apt install python3.8-distutils
sudo apt install python3.8-venv
sudo apt-get install python3-pip
python3 -m pip install --upgrade pip



############################
Install cv2 with cuda support
*****
Create an image backup before this step incase something goes wrong
****
a. Connect nepi device to internet

b. copy "install_opencv4.10.0_Jetson.sh" scrip from resources folder in repo nepi_rootfs_tools/nepi_main_rootfs/resources to nepi_storage/tmp folder

c. *** Check installed print(cv2.__version__) and change version as needed in script ***
python
import cv2
print(cv2.getBuildInformation())


d. ssh in and 
rosstop
cd /mnt/nepi_storage/tmp
sudo chmod +x install_opencv4.10.0_Jetson.sh
//sudo ./install_opencv4.10.0_Jetson.sh
** Yes to all questions
./install_opencv4.10.0_Jetson.sh
** Yes to all questions


e.  Make sure python is using 3.8.10
https://unix.stackexchange.com/questions/410579/change-the-python3-default-version-in-ubuntu
cd /usr/bin
sudo ln -sfn python3 python

python -V




f. remove and install cv_bridge
sudo apt remove ros-noetic-cv-bridge
sudo apt install ros-noetic-cv-bridge

g. fix web_video_server not launch error
sudo apt remove ros-noetic-web-video-server
sudo apt install ros-noetic-web-video-server

h. reboot

i. Check if cuda support
python
import cv2
print(cv2.cuda.getCudaEnabledDeviceCount())

############################################


- add Gieode databases to FileSystem'
egm2008-2_5.pgm  egm2008-2_5.pgm.aux.xml  egm2008-2_5.wld  egm96-15.pgm  egm96-15.pgm.aux.xml  egm96-15.wld
from
https://www.3dflow.net/geoids/
to
/opt/nepi/databases/geoids

############################################
- installed PyUSB
sudo pip3 install PyUSB

############################################
- upgrade python hdf5
sudo pip3 install --upgrade h5py

############################################
- installed scipy
sudo apt-get install python3-scipy
pip install --upgrade scipy
sudo pip install --upgrade scipy

############################################
Install cupy

# Ref https://forums.developer.nvidia.com/t/cupy-install-for-jetson-xavier-nx/210913

___________________________________________________________
1) Connect your NEPI device to the internet

___________________________________________________________
2) Modify .bashrc file. 
FROM REF https://github.com/jetsonhacks/buildLibrealsense2TX/issues/13
a) SSH into your NEPI device
b) Open your .bashrc file "vi ~/.bashrc", and add the following to the end 

# cupy for cuda


c) Save and exit
d) Re-source the file

source ~/.bashrc

__________________________________________________________
2) install cupy for cuda

a) upgrade scipy
pip install --upgrade scipy
sudo pip install --upgrade scipy

b) 
pip install cupy-cuda11x
sudo pip install cupy-cuda11x

c) check python open3d module import

python -c "import cupy; print(cupy)"
sudo python -c "import cupy; print(cupy)"





3.1############################################
- add drivers folder to python path in bashrc

# Add nepi_drivers folder to python path in bash_aliases
export PYTHONPATH=$PYTHONPATH:/opt/nepi/ros/lib/nepi_drivers



############################
- install nepi_gpsd.service 
from nepi_edge_ws repo on your pc, copy the 
/src/nepi_3rd_party/nepi_gpsd_ros_client/install_gpsd_startup_service.sh
to
/mnt/nepi_storage/tmp

then open ssh to /mnt/nepi_storage/tmp and run
sudo ./install_gpsd_startup_services.sh



rosstop
rostart

reboot


############################################
- installed pytorch for jetson
Follow these instructions:
https://docs.nvidia.com/deeplearning/frameworks/install-pytorch-jetson-platform/index.html
another reference
https://medium.com/@yixiaozengprc/set-up-pytorch-environment-on-nvidia-jetson-platform-9eda291db716
https://docs.nvidia.com/deeplearning/frameworks/pytorch-release-notes/index.html


a. 
sudo apt-get -y update
sudo apt-get -y install python3-pip libopenblas-dev

b. Setup Pytorch in NEPI device
Go or create temp folder and install:
cd /mnt/nepi_storage/tmp

find cuda version
nvcc --version

find numpy version:
python -c "import numpy; print(numpy.__version__)"

find cuda version
sudo apt-cache show nvidia-jetpack


Dowload latest version for your jetpack version from
Find pytorch version for jetpack version
https://forums.developer.nvidia.com/t/pytorch-for-jetson/72048
another resource
https://developer.download.nvidia.com/compute/redist/jp/

Copy link address and 

downlowd <link to whl file>
export TORCH_INSTALL=<whl_file_path>

Ex
5.0.2
wget https://developer.download.nvidia.com/compute/redist/jp/v502/pytorch/torch-1.13.0a0+410ce96a.nv22.12-cp38-cp38-linux_aarch64.whl

export TORCH_INSTALL=/mnt/nepi_storage/tmp/torch-1.13.0a0+410ce96a.nv22.12-cp38-cp38-linux_aarch64.whl

5.1.2
wget https://developer.download.nvidia.cn/compute/redist/jp/v512/pytorch/torch-2.1.0a0+41361538.nv23.06-cp38-cp38-linux_aarch64.whl

export TORCH_INSTALL=/mnt/nepi_storage/tmp/torch-2.1.0a0+41361538.nv23.06-cp38-cp38-linux_aarch64.whl


c. Setup Pytorch in NEPI device 3

sudo python3 -m pip install --upgrade pip
sudo 
sudo pip3 install numpy=='1.24.4'
sudo pip3 install --no-cache $TORCH_INSTALL

d.test install
python 
import torch
print(torch.__version__)
print(str(torch.cuda.is_available()))
quit()
############################################
- install torchvision

f) Fix NEPI package versions

pip install setuptools==49.4.0
sudo pip install setuptools==49.4.0

Installing Torchvision
Instructions can be found https://forums.developer.nvidia.com/t/pytorch-forjetson/

https://forums.developer.nvidia.com/t/how-to-install-torchvision-with-torch1-14-0-with-cuda-11-4/245657/2
a. find compatable version to torch version https://pypi.org/project/torchvision/

python 
import torch
print(torch.__version__)
quit()

NOTE: You can find the torch and torchvision compatibility matrix here:
https://github.com/pytorch/vision 

then look under "Tags" find version, then click the "tar.gz" file link

b. download and install On your PC Download 
Example:

https://github.com/pytorch/vision/archive/refs/tags/v0.14.0.tar.gz


https://github.com/pytorch/vision/archive/refs/tags/v0.16.2.tar.gz


c. copy to your /mnt/nepi_storage/tmp/ folder and unzip 
connect NEPI to internet

sshn in

sudo apt-get install libjpeg-dev zlib1g-dev libpython3-dev libopenblas-dev libavcodec-dev libavformat-dev libswscale-dev
cd /mnt/nepi_storage/tmp/

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


Check Installed

python
import torchvision
print(torchvision.__version__)

rosstop
rosstart # Look for errors





###############################
- Install ultralytics for yolov5 ai model support
1) 
then add this to bashrc
vi ~/.bashrc

export SETUPTOOLS_USE_DISTUTILS=stdlib


1) connect nepi to internet

in nepi tmp folder
##git clone https://github.com/ultralytics/ultralytics.git
##cd ultralytics
##pip install -e '.[dev]'

pip install -U ultralytics


then reboot

*** Must Do ***

2) May need to do twice
power cycle

rosstop
rosstart

connect nepi to internet
connect camera

Connect NEPI to internet and start a yolov5 model from RUI AI detector

*****(







#################################
Install open3d with cuda support

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



##############################
 Make sure your File System partition is fully sized by running

sudo resize2fs /dev/nvme0n1p1
sudo resize2fs /dev/nvme0n1p2
sudo resize2fs /dev/nvme0n1p3
___________________________________________________________






