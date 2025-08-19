https://developer.nvidia.com/embedded/jetson-cloud-native
https://gitlab.com/nvidia/container-images/l4t-jetpack

Resize image
sudo resize2fs /dev/nvme0n1p2
sudo resize2fs /dev/nvme0n1p3

On PC
git clone https://gitlab.com/nvidia/container-images/l4t-jetpack

Copy /home/engineering/Code/l4t-jetpack folder to nepi_storage/tmp

## CONNECT NEPI DEVICE TO INTERNET BEFORE PROCEEDING
sudo apt-get install apt-utils

cd /mnt/nepi_storage/tmp
sudo chown -R nepi:nepi l4t-jetpack/
cd l4t-jetpack/
sudo make image

#Install visual studio if not present
#https://unix.stackexchange.com/questions/765383/e-unable-to-locate-package-code
sudo apt install wget gpg apt-transport-https
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft-archive-keyring.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update
sudo apt install code




# Install chromium if not present
#https://forum.snapcraft.io/t/try-to-update-snapd-and-refresh-the-core-snap/20725
sudo install snap
sudo snap install core snapd
#https://www.cyberciti.biz/faq/install-chromium-browser-on-ubuntu-linux/#google_vignette
snap install chromium
_______________
# Install docker if not present
#https://www.forecr.io/blogs/installation/how-to-install-and-run-docker-on-jetson-nano

# Install nvidia toolkit
#https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html
sudo apt-get install -y nvidia-container-toolkit
sudo apt-get install nvidia-container-run
#runtime configure --runtime=docker --config=$HOME/.config/docker/daemon.json

#Stop docker
sudo systemctl stop docker
sudo systemctl stop docker.socket

# Set docker image location
#https://tienbm90.medium.com/how-to-change-docker-root-data-directory-89a39be1a70b

mkdir /mnt/nepi_storage/docker
sudo mv /var/lib/docker /mnt/nepi_storage/docker



sudo vim /etc/docker/daemon.json
#Add
{
    "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "runtimeArgs": []
        }
    }
    
}


#### Don't do
,

    "data-root": "/mnt/nepi_storage/docker"
}
''''


sudo vi /etc/default/docker
# Edit this line and uncomment
DOCKER_OPTS="--dns 8.8.8.8 --dns 8.8.4.4"  -g /mnt/nepi_storage/docker


# Set docker service root location
#https://stackoverflow.com/questions/44010124/where-does-docker-store-its-temp-files-during-extraction
sudo vi /usr/lib/systemd/system/docker.service
#Comment out ExecStart line and add below
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --data-root=/mnt/nepi_storage/docker
#Then reload
sudo systemctl daemon-reload

#start docker
sudo systemctl start docker.socket
sudo systemctl start docker
sudo docker info
____________________________________
https://phoenixnap.com/kb/how-to-commit-changes-to-docker-image

Some Tools
//sudo docker images -a
//sudo docker ps -a
//sudo docker start  `nepi_test ps -q -l` # restart it in the background
//sudo docker attach `nepi_test ps -q -l` # reattach the terminal & stdin


# run network config sciprt
sudo python /mnt/nepi_storage/tmp/nepi/config/etc/network/tune_ethernet_interfaces.py

# setup dhcp server

sudo mv /etc/dhcp/dhclient.conf /etc/dhcp/dhclient.conf.bak
sudo ln -sf /opt/nepi/config/etc/dhcp/dhclient.conf /etc/dhcp/dhclient.conf

###########################################
## Build nepi container

Run container
https://catalog.ngc.nvidia.com/orgs/nvidia/containers/l4t-jetpack

sudo docker run -it --net=host --runtime nvidia -e DISPLAY=$DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix nvcr.io/nvidia/l4t-jetpack:r35.1.0

Set root password
passwd
nepi
nepi


Add nepi user
https://stackoverflow.com/questions/27701930/how-to-add-users-to-docker-container
addgroup nepi
adduser --ingroup nepi nepi
visudo /etc/sudoers
nepi    ALL=(ALL:ALL) ALL

Save then 

su nepi
passwd
nepi
nepi

# Fix gpu accessability
#https://forums.developer.nvidia.com/t/nvrmmeminitnvmap-failed-with-permission-denied/270716/10
sudo usermod -aG sudo,video,i2c nepi

Stay in nepi user space


__________________
Create some nepi required folders

sudo mkdir -p /opt/nepi
sudo mkdir -p /opt/nepi/ros
sudo chown -R nepi:nepi /opt/nepi

____________
#Create nepi_storage folder

sudo mkdir /mnt/nepi_storage
sudo chown -R nepi:nepi /mnt/nepi_storage
______

# Copy "config" rootfs folder from nepi rootfs tools repo to 
#/opt/nepi/


# Add nepi user to dialout group to allow non-sudo serial connections
sudo adduser nepi dialout



# share this folder on your network using samba
echo "Installing samba for network shared drives"
sudo apt install samba
sudo mv /etc/samba/smb.conf /etc/samba/smb.conf.bak
sudo cp /opt/nepi/config/etc/samba/smb.conf /etc/samba/smb.conf
sudo chown :sambashare /mnt/nepi_storage
printf "nepi\nnepi\n" | sudo smbpasswd -a nepi
sudo smbd -D
#sudo systemctl start smbd


#_____________________________________________
# Install Baumer GenTL Producers (Genicam support)
echo "Installing Baumer GAPI SDK GenTL Producers"
# Set up the shared object links in case they weren't copied properly when this repo was moved to target
NEPI_BAUMER_PATH=/opt/nepi/config/opt/baumer/gentl_producers
ln -sf $NEPI_BAUMER_PATH/libbgapi2_usb.cti.2.14.1 $NEPI_BAUMER_PATH/libbgapi2_usb.cti.2.14
ln -sf $NEPI_BAUMER_PATH/libbgapi2_usb.cti.2.14 $NEPI_BAUMER_PATH/libbgapi2_usb.cti
ln -sf $NEPI_BAUMER_PATH/libbgapi2_gige.cti.2.14.1 $NEPI_BAUMER_PATH/libbgapi2_gige.cti.2.14
ln -sf $NEPI_BAUMER_PATH/libbgapi2_gige.cti.2.14 $NEPI_BAUMER_PATH/libbgapi2_gige.cti
# And the master link
sudo ln -sf /opt/nepi/config/opt/baumer /opt/baumer
sudo chown nepi:nepi /opt/baumer





# Set jetson power mode (look up options for your device online)
sudo nvpmodel -m 8

# Update bash files
cp /mnt/nepi_storage/tmp/nepi/config/home/nepi/bashrc_n3p0p4_jp5p0p2_cn ~/.bashrc
cp /mnt/nepi_storage/tmp/nepi/config/home/nepi/nepi_bash_aliases ~/.bash_aliases
#_________________________
####################

#___________________
#Install dependancies
sudo apt-get update
sudo apt-get install cmake


#Install python tools

sudo apt-get install software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install python3.8
sudo apt install python3.8-distutils
sudo apt install python3.8-venv
sudo apt-get install python3-pip
//python3 -m pip install --upgrade pip

cd /usr/bin
sudo ln -sfn python3 python


# NEPI runtime python3 dependencies. Must install these in system folders such that they are on root user's python path
sudo -H pip install pyserial 
sudo -H pip install websockets 
sudo -H pip install geographiclib 
sudo -H pip install PyGeodesy 
sudo -H pip install harvesters 
sudo -H pip install WSDiscovery 
sudo -H pip install python-gnupg 
sudo -H pip install onvif_zeep
sudo -H pip install onvif 

pip install --user labelImg # For onboard training
pip install --user licenseheaders # For updating license files and source code comments

sudo apt install scons # Required for num_gpsd
sudo apt install zstd # Required for Zed SDK installer
sudo apt install dos2unix # Required for robust automation_mgr
sudo apt install libv4l-dev v4l-utils # V4L Cameras (USB, etc.)
sudo apt install hostapd # WiFi access point setup
sudo apt install curl # Node.js installation below
sudo apt install v4l-utils
sudo apt install isc-dhcp-client
sudo apt install wpasupplicant
sudo apt install -y psmisc
sudo apt install scapy

- installed PyUSB
sudo pip install PyUSB

- installed scipy
sudo apt-get install python3-scipy
pip install --upgrade scipy
//sudo pip install --upgrade scipy

#create requirements file from normal install then run both as normal and sudo user
# https://stackoverflow.com/questions/31684375/automatically-create-file-requirements-txt
# pip3 freeze > requirements.txt
# Copy to /mnt/nepi_storage/tmp
# ssh into tmp folder on nepi
sudo su
cat requirements.txt | sed -e '/^\s*#.*$/d' -e '/^\s*$/d' | xargs -n 1 python3 -m pip install

Manual installs in sudo
apt-get install python-debian
apt-get install onboard
apt-get install setools
apt-get install ubuntu-advantage-tools
apt-get install dos2unix
apt-get install -y iproute2
exit

cat requirements.txt | sed -e '/^\s*#.*$/d' -e '/^\s*$/d' | xargs -n 1 python3 -m pip install

sudo pip install yap
pip install yap
sudo pip install yapf

# Add nepi user to dialout group to allow non-sudo serial connections
sudo adduser nepi dialout


# Work-around opencv path installation issue on Jetson (after jetpack installation)
sudo ln -s /usr/include/opencv4/opencv2/ /usr/include/opencv
sudo ln -s /usr/lib/aarch64-linux-gnu/cmake/opencv4 /usr/share/OpenCV

# setup dhcp server

sudo mv /etc/dhcp/dhclient.conf /etc/dhcp/dhclient.conf.bak
sudo ln -sf /opt/nepi/config/etc/dhcp/dhclient.conf /etc/dhcp/dhclient.conf
############################################


- add Gieode databases to FileSystem'
egm2008-2_5.pgm  egm2008-2_5.pgm.aux.xml  egm2008-2_5.wld  egm96-15.pgm  egm96-15.pgm.aux.xml  egm96-15.wld
from
https://www.3dflow.net/geoids/
to
/opt/nepi/databases/geoids


_________________________
Setup ROS

sudo apt-get install lsb-release -y

Install ros
https://wiki.ros.org/noetic/Installation/Ubuntu


//sudo apt-get install ros-noetic-catkin python-catkin-tools

ROS_VERSION=noetic

ADDITIONAL_ROS_PACKAGES="python3-catkin-tools \
    ros-${ROS_VERSION}-rosbridge-server \
    ros-${ROS_VERSION}-pcl-ros \
    ros-${ROS_VERSION}-web-video-server \
    ros-${ROS_VERSION}-camera-info-manager \
    ros-${ROS_VERSION}-tf2-geometry-msgs \
    ros-${ROS_VERSION}-mavros \
    ros-${ROS_VERSION}-mavros-extras \
    ros-${ROS_VERSION}-serial \
    python3-rosdep" 

    # Deprecated ROS packages?
    #ros-${ROS_VERSION}-tf-conversions
    #ros-${ROS_VERSION}-diagnostic-updater 
    #ros-${ROS_VERSION}-vision-msgs

sudo apt install $ADDITIONAL_ROS_PACKAGES


sudo apt install ros-noetic-cv-bridge
sudo apt install ros-noetic-web-video-server


# Mavros requires some additional setup for geographiclib
sudo /opt/ros/${ROS_VERSION}/lib/mavros/install_geographiclib_datasets.sh

# Need to change the default .ros folder permissions for some reason
//sudo mkdir /home/nepi/.ros
sudo chown -R nepi:nepi /home/nepi/.ros

# Setup rosdep
sudo rm -r /etc/ros/rosdep/sources.list.d/20-default.list
sudo rosdep init
rosdep update

source /opt/ros/noetic/setup.bash


############################################
//- upgrade python hdf5
//sudo pip3 install --upgrade h5py








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
sudo apt-cache show nvidia-jetpack


Dowload latest version for your jetpack version from
Find pytorch version for jetpack version
https://forums.developer.nvidia.com/t/pytorch-for-jetson/72048
another resource
https://developer.download.nvidia.com/compute/redist/jp/

Copy link address and 

wget <link to whl file>
export TORCH_INSTALL=<whl location>

Ex
5.0.2
wget https://developer.download.nvidia.com/compute/redist/jp/v502/pytorch/torch-1.13.0a0+410ce96a.nv22.12-cp38-cp38-linux_aarch64.whl

export TORCH_INSTALL=/mnt/nepi_storage/tmp/torch-1.13.0a0+410ce96a.nv22.12-cp38-cp38-linux_aarch64.whl

5.1.2
wget https://developer.download.nvidia.cn/compute/redist/jp/v512/pytorch/torch-2.1.0a0+41361538.nv23.06-cp38-cp38-linux_aarch64.whl

export TORCH_INSTALL=/mnt/nepi_storage/tmp/torch-2.1.0a0+41361538.nv23.06-cp38-cp38-linux_aarch64.whl


c. Setup Pytorch in NEPI device 3

sudo python3 -m pip install --upgrade pip
sudo pip3 install numpy=='1.24.4'
sudo pip3 install --no-cache $TORCH_INSTALL

d.test install
! python -c "import torch; print(torch.cuda.is_available())"

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

for torch 1.13
https://github.com/pytorch/vision/archive/refs/tags/v0.14.0.tar.gz


https://github.com/pytorch/vision/archive/refs/tags/v0.16.2.tar.gz


c. copy to your /mnt/nepi_storage/tmp/ folder and unzip 
connect NEPI to internet

sshn in

sudo apt-get install libjpeg-dev zlib1g-dev libpython3-dev libopenblas-dev libavcodec-dev libavformat-dev libswscale-dev
cd /mnt/nepi_storage/tmp/

Example
tar -xvzf vision-0.14.0.tar.gz
cd vision-0.14.0
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
! python -c "import torchvision; print(torchvision.__version__)"


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
export CUDA_PATH=/usr/local/cuda-11
export CUPY_NVCC_GENERATE_CODE=current

c) Save and exit
d) Re-source the file

source ~/.bashrc

__________________________________________________________
2) install cupy for cuda


pip install cupy-cuda11x
sudo pip install cupy-cuda11x

c) check python module import

python -c "import cupy; print(cupy)"
sudo python -c "import cupy; print(cupy)"




#################################
pip install open3d --ignore-installed
sudo pip install open3d --ignore-installed

OR 
From source

Install open3d with cuda support

# Ref https://www.open3d.org/docs/0.13.0/arm.html


___________________________________________________________
1) Connect your NEPI device to the internet

___________________________________________________________
2) Modify .bashrc file. 
FROM REF https://github.com/jetsonhacks/buildLibrealsense2TX/issues/13
a) SSH into your NEPI device
b) Open your .bashrc file "vi ~/.bashrc", and add the following to the end 

Update this line in the ~/.bashrc or ~/.bash_aliases file
export CUDA_HOME=/usr/local/cuda-11.4
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CUDA_HOME/bin/lib64:$CUDA_HOME/bin/extras/CUPTI/lib64
export PATH=$PATH:$CUDA_HOME/bin

c) Save and exit
d) Re-source the file

source ~/.bashrc
source ~/.bash_aliases


__________________________________________________________
3) Install CUDA 11.8

#### COULD NOT GET THIS TO WORK 

a) SSH into your NEPI device and type the following

rosstop

###No
#Needs cuda 11.5+ Use 11.8

#Download source from 
https://forums.developer.nvidia.com/t/how-to-manually-install-cuda-and-all-necessary-packages-on-my-jetson-nano-without-sdk-manager/284095/7
#https://developer.download.nvidia.com/compute/cuda/opensource/
# Copy to /mnt/nepi_storage/tmp


https://developer.nvidia.com/cuda-toolkit-archive




#https://forums.developer.nvidia.com/t/upgrading-cuda-11-4-to-cuda-11-8/305766
#https://developer.nvidia.com/cuda-11-8-0-download-archive?target_os=Linux&target_arch=aarch64-jetson&Compilation=Native&Distribution=Ubuntu&target_version=20.04&target_type=deb_local


wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/arm64/cuda-ubuntu2004.pin
sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/11.8.0/local_installers/cuda-tegra-repo-ubuntu2004-11-8-local_11.8.0-1_arm64.deb
sudo dpkg -i cuda-tegra-repo-ubuntu2004-11-8-local_11.8.0-1_arm64.deb
sudo cp /var/cuda-tegra-repo-ubuntu2004-11-8-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt upgrade

#sudo apt-get install aptitude
#sudo aptitude install cuda
sudo apt-get update
sudo apt-get -y install cuda-toolkit-11-8
#sudo apt-get -y install cuda


#Check
nvcc --version


#https://www.gpu-mart.com/blog/install-nvidia-cuda-11-on-ubuntu
wget https://developer.download.nvidia.com/compute/cuda/11.8.0/local_installers/cuda_11.8.0_520.61.05_linux.run
$ sudo sh cuda_11.8.0_520.61.05_linux.run


sudo dpkg -i cuda-tegra-repo-ubuntu2004-11-8-local_11.8.0-1_arm64.deb
sudo cp /var/cuda-tegra-repo-ubuntu2004-11-8-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install cuda

#Check
nvcc --version


#__________________________________________________________
#4) Install Open3d with Cuda support
NOTE: **The make process below took over an 5 hours to run. Maybe faster with rosstop
# Ref https://www.open3d.org/docs/0.13.0/arm.html
# Ref https://www.open3d.org/docs/0.11.0/compilation.html
# Ref https://groups.google.com/g/alembic-discussion/c/SVO3PEpzQvk?pli=1
# Ref https://stackoverflow.com/questions/72278881/no-cmake-cuda-compiler-could-be-found-when-installing-pytorch
# Ref https://www.open3d.org/docs/latest/tutorial/Advanced/headless_rendering.html


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

NEED TO get Open3d 18.0 from
https://github.com/isl-org/Open3D/tags
Download, unzip and move to /mnt/nepi_storage/tmp

b)Edit the CMakeLists.txt line 328. Change "find_package(Python3 3.6" line to
find_package(Python3 3.8 EXACT

d) Build Open3D cpp and python modules

cd /mnt/nepi_storage/tmp
sudo chown -R nepi:nepi Open3D-0.18.0
cd Open3D-0.18.0/
mkdir build
cd build

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

#IN python software us
#https://www.open3d.org/docs/latest/tutorial/visualization/cpu_rendering.html
#import os
#os.environ['EGL_PLATFORM'] = 'surfaceless'   # Ubuntu 20.04+
#import open3d as o3d



#Or compile HEADLESS (Untested)
#https://github.com/isl-org/Open3D/issues/5505


sudo CUDACXX=/usr/local/cuda-11/bin/nvcc cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_CUDA_MODULE=ON \
    -DENABLE_HEADLESS_RENDERING=ON \
    -DBUILD_GUI=ON \
    -DBUILD_TENSORFLOW_OPS=OFF \
    -DBUILD_PYTORCH_OPS=OFF \
    -DBUILD_UNIT_TESTS=OFF \
    -DPYTHON_EXECUTABLE=$(which python) \
    ..


#sudo make -j$(nproc)
#[JRM: $(nproc) is not defined on my system, so replace with an explicit CPU count
sudo make -j4
sudo make install
sudo make install-pip-package -j4
b) (Optional) test the install. Run Open3D GUI (optional, available on when -DBUILD_GUI=ON)

./Open3D/Open3D

7) make and install python package

a) exit python venv
# Skip this step if you want to install  in python venv
# If you deactivate, it will be installed in normal nepi python environment

deactivate


b) Upgrade pip
sudo python3.8 -m pip install --upgrade pip

c) First install the new cuda open3d package
# You will get an error on this step. Ignore it

cd lib/python_package/pip_package
sudo pip install open3d-0.18.0-cp38-cp38-manylinux_2_31_aarch64.whl --ignore-installed

[ That step seems strange to me... I don't think pip can find that whl file so I'm not sure what actual effect (if any) this has ]

# Check installed open3d module version

pip freeze | grep open3d

#Future Fix python gpu Package
#https://github.com/isl-org/Open3D/issues/3406
#https://github.com/CMU-cabot/cabot/issues/86
Modify /usr/local/lib/python3.8/dist-packages/open3d/__init__.py and check the details of the error. 
https://github.com/intel-isl/Open3D/blob/e7574588ab23cd97bc49353327a3dced4cf1ac18/python/open3d/__init__.py#L52-L72
https://stackoverflow.com/questions/74413921/how-to-project-a-point-cloud-to-a-depth-image-using-open3ds-project-to-depth-im
Modify __init__.py as follows to see the details.
line 71:	str(next((_Path(__file__).parent / 'cuda').glob('pybind*'))), winmode=0)



python -W default -c "import open3d as o3d"


d) Next install standard open3d-cpu without overwriting the cuda version to fix python import error
# You will get an error on this step. Ignore it

sudo pip install open3d --ignore-installed
pip freeze | grep open3d


# TEST Install

sudo python -c "import open3d; from open3d._build_config import _build_config; print(_build_config)"
python -c "import open3d; from open3d._build_config import _build_config; print(_build_config)"
python /examples/python/visualization_tools/headless_rendering.py
sudo python -c "from open3d import core; print(core.cuda_is_available())"

#ISSUES
https://github.com/isl-org/Open3D/issues/5505

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

! python -c "import cv2; print(cv2.cuda.getCudaEnabledDeviceCount())"


________________________________
Install Zed SDK from

#### This does not work, need to copy folder from normal system
#https://www.stereolabs.com/developers
#sudo chmod +x filename.run
#./filename.run

Copy /usr/local/zed from host to /usr/local/zed in container
then 
sudo chown -R nepi:nepi /usr/local/zed/







##############################
#Install NEPI code
#####


 Make sure your File System partition is fully sized by running

sudo resize2fs /dev/nvme0n1p1
sudo resize2fs /dev/nvme0n1p2
sudo resize2fs /dev/nvme0n1p3


Follow build from source instructions at
https://nepi.com/nepi-tutorials/nepi-engine-building-from-source-code/

- install nepi_gpsd.service 
from nepi_edge_ws repo on your pc, copy the 
/src/nepi_3rd_party/nepi_gpsd_ros_client/install_gpsd_startup_service.sh
to
/mnt/nepi_storage/tmp

then open ssh to /mnt/nepi_storage/tmp and run
sudo ./install_gpsd_startup_services.sh


sudo cp /opt/nepi/config/etc/udev/rules.d/* /etc/udev/rules.d/

Edit # Launch file package name at least
vi /opt/nepi/sys_env.bash



rosstop
rostart


#____________________
# Setup python path to 
vi ~/.bashrc 
# add

export PATH="/opt/nepi/ros/etc/"

# Add nepi user to dialout group to allow non-sudo serial connections
sudo adduser nepi dialout


reboot

#####
#1) Install RUI repo

#2) 
#a) remove Software from menu in apps.js file
#b) remove DHCP control from NepiMgrNetwork
#c) remove Time Sync button from NepiDashboard

#2)Then
cd /mnt/nepi_storage/tmp
sudo apt-get install python python3-wstool python3-catkin-tools python3-pip
pip install --user -U pip
pip install --user virtualenv
mkdir $HOME/.nvm
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install 8.11.1 # RUI-required Node version as of this script creation

cd /opt/nepi/nepi_rui
python -m virtualenv venv
source ./devenv.sh
pip install -r requirements.txt


cd src/rui_webserver/rui-app
npm install
npm run build



sudo /opt/nepi/nepi_rui/etc/start_rui.sh

//rosrun nepi_rui run_webserver.py



#Start service at runtime in docker file
https://stackoverflow.com/questions/25135897/how-to-automatically-start-a-service-when-running-a-docker-container
In your Dockerfile, add at the last line

ENTRYPOINT service nepi_rui.service restart && bash

# The normal method doesn't work doesn't work?
# After testing add startup service
sudo cp /opt/nepi/nepi_rui/etc/nepi_rui.service /etc/systemd/system
sudo chmod +x /etc/systemd/system/nepi_rui.service

#Once you have a unit file, you are ready to test the service:

sudo systemctl start nepi_rui.service
#Check the status of the service:

sudo systemctl status nepi_rui.service


########
# install license managers


sudo rm -R /opt/nepi/config
sudo cp -r /mnt/nepi_storage/tmp/nepi/config/ ./
sudo chown -R nepi:nepi /opt/nepi/config
sudo chown -R nepi:nepi /mnt/nepi_storage/tmp/nepi/config

sudo /opt/nepi/config/etc/license/setup_nepi_license.sh

######
# install ssh server
sudo apt-get install -y openssh-server
# Set up SSH
sudo mv /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sudo ln -sf /opt/nepi/config/etc/ssh/sshd_config /etc/ssh/sshd_config
# And link default public key - Make sure all ownership and permissions are as required by SSH
mkdir -p /home/nepi/.ssh
sudo chown nepi:nepi /home/nepi/.ssh
chmod 0700 /home/nepi/.ssh
sudo chown nepi:nepi /opt/nepi/config/home/nepi/ssh/authorized_keys
chmod 0600 /opt/nepi/config/home/nepi/ssh/authorized_keys
ln -sf /opt/nepi/config/home/nepi/ssh/authorized_keys /home/nepi/.ssh/authorized_keys
sudo chown nepi:nepi /home/nepi/.ssh/authorized_keys
chmod 0600 /home/nepi/.ssh/authorized_keys
sudo service ssh restart
#______________
# copy startup scripts
# Install nepi start scripts in root folder


sudo cp /opt/nepi/config/etc/supervisord/nepi_start_all.sh /
sudo chmod +x /nepi_start_all.sh

sudo cp /mnt/nepi_storage/nepi_src/nepi_engine_ws/src/nepi_edge_sdk_base/etc/nepi_engine_start.sh /
sudo chmod +x /nepi_engine_start.sh

sudo cp /mnt/nepi_storage/nepi_src/nepi_engine_ws/src/nepi_rui/etc/nepi_rui_start.sh /
sudo chmod +x /nepi_rui_start.sh

sudo cp /opt/nepi/config/etc/samba/nepi_storage_samba_start.sh /
sudo chmod +x /nepi_storage_samba_start.sh

sudo cp /opt/nepi/config/etc/storage/nepi_storage_init.sh /
sudo chmod +x /nepi_storage_init.sh

sudo cp /opt/nepi/config/etc/license/nepi_check_license_start.sh /
sudo dos2unix /opt/nepi/config/etc/license/nepi_check_license.py
sudo chmod +x /nepi_check_license_start.sh

sudo cp /opt/nepi/config/etc/storage/nepi_storage_init.sh /
sudo chmod +x /nepi_storage_init.sh




#-------------------
# Install setup supervisord
#https://www.digitalocean.com/community/tutorials/how-to-install-and-manage-supervisor-on-ubuntu-and-debian-vps
#https://test-dockerrr.readthedocs.io/en/latest/admin/using_supervisord/

sudo apt update && sudo apt install supervisor
sudo vi /etc/supervisor/conf.d/nepi.conf
# Add these lines
[supervisord]
nodaemon=false

[program:nepi_engine]
command=/bin/bash /nepi_engine_start.sh
autostart=true
autorestart=true


[program:nepi_rui]
command=/bin/bash /nepi_rui_start.sh
autostart=true
autorestart=true

[program:nepi_storage_samba]
command=/bin/bash /nepi_storage_samba_start.sh
autostart=true
autorestart=true


###

sudo /usr/bin/supervisord



##########
#____________
Clone the current container

"exit" twice


Clone container
sudo docker ps -a
Get <ID>
sudo docker commit <ID> nepi1

# Clean out <none> Images
sudo docker rmi $(sudo docker images -f “dangling=true” -q)

# Export/Import Flat Image as tar
sudo docker export a1e4e38c2162 > /mnt/nepi_storage/tmp/nepi3p0p4p1_jp5p0p2.tar
sudo docker import /mnt/nepi_storage/tmp/nepi3p0p4p1_jp5p0p2.tar 
docker tag <IMAGE_ID> nepi_ft1

# Save/Load Layered Image as tar
sudo docker save -o /mnt/nepi_storage/tmp/nepi1.tar a1e4e38c2162
sudo docker tag 7aa663d0a1e3 nepi_ft1

_________
#Clean the linux system
#https://askubuntu.com/questions/5980/how-do-i-free-up-disk-space
sudo apt-get clean
sudo apt-get autoclean
sudo apt-get autoremove


#_____________
Setup Host 

#(Recommended) Set your host ip address to nepi standard
Address: 192.168.179.103
Netmask: 255.255.255.0

#(Recommended) Setup dhcp service
apt install netplan.io

# Copy zed camera config files to 
/mnt/nepi_storage/usr_cfg/zed_cals/

#Install chromium on 
# On host machine open chromium and enter http://127.0.0.1:5003/ to access the RUI locally
# On 


#_____________
# setup nepi_storage folder

# Create a nepi_storage folder on mounted partition with at least 100 GB of free space
mkdir <path_to_nepi_parent_folder>/nepi_storage

# Run the nepi containers nepi_storage_init.sh script using the following command  
sudo docker run --rm --mount type=bind,source=/mnt/nepi_storage,target=/mnt/nepi_storage -it --net=host -v /tmp/.X11-unix/:/tmp/.X11-unix nepi /bin/bash -c "/nepi_storage_init.sh"

#then
exit


#_____________
# Run Nepi Engine
# Dev
sudo docker run --privileged -e UDEV=1 --user nepi --gpus all --mount type=bind,source=/mnt/nepi_storage,target=/mnt/nepi_storage --mount type=bind,source=/dev,target=/dev -it --net=host --runtime nvidia -v /tmp/.X11-unix/:/tmp/.X11-unix nepi1 /bin/bash

volumes - /dev:/dev

#Run
sudo docker run --rm --privileged -e UDEV=1 --user nepi --gpus all --mount type=bind,source=/mnt/nepi_storage,target=/mnt/nepi_storage -it --net=host --runtime nvidia -e DISPLAY=$DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix nepi1 /bin/bash -c "/nepi_engine_start.sh"


#_____________
# Run Nepi RUI

sudo docker run --rm -it --net=host -v /tmp/.X11-unix/:/tmp/.X11-unix nepi1 /bin/bash -c "/nepi_rui_start.sh"

sudo docker exec -it 32e4923a9fc6 /bin/bash -c "/nepi_rui.sh"

# /bin/sh -c "nepi_launch.sh"

su
