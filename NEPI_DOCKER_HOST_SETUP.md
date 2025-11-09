# NEPI Docker Host Setup Instructions
This tutorial will walk you through setting up, configuring, and running a NEPI Docker production installation on a suitable edge processor.

**NOTE:** NEPI Docker production installation will make significant changes to your device's operating system configuration.  
If you choose to proceed, make sure you have a way to reflash the device, or backup and restore your device's existing file system if needed.

**NOTE:** NEPI Docker installation will require a minimum of 40 GB of available free hard drive space. 
See the 'Check Available Disk Space' section at the end of these instructions for more information on checking available space.

For a detailed tutorial on this process see the "NEPI Docker Host Setup" tutorial under the "NEPI Installation" section at:
[NEPI Tutorials](https://www.nepi.com/tutorials)

For additional support, visit the NEPI software community forum at:
[NEPI Community](https://www.community.nepi.com)


################################################################
### NEPI Docker User Setup

This step will create the 'nepihost' user account on your device

Log into a user account on the device with 'Adminstrator' privilages, or 'nepihost' if exists.

Open Terminal Window - Right click on the desktop and select the "Open in Terminal" option.

Make sure your system has internet access by running the following command:

    ping google.com # To exit press `CTRL C`

Update Git application (sudo password is #Nsetup4You):

    sudo apt update && sudo apt install -y git snap && sudo snap install mdview

Clone the NEPI Setup repo:

    cd /home/${USER}
    git clone https://github.com/nepi-engine/nepi_setup.git


Run the NEPI Docker user setup script (sudo password is #Nsetup4You):

    cd /home/${USER}/nepi_setup/scripts
    sudo su 

then

    ./docker_user_setup.sh


**POWER CYCLE YOUR SYSTEM WHEN COMPLETE**



################################################################
### NEPI Docker Environment Setup

This step will setup NEPI Docker required software environment.

Log into the `nepihost` user using password  'nepi'

Run the NEPI Docker environment setup script (sudo password is now 'nepi')

If prompted enter: `y` or 'yes' :

    /home/nepihost/nepi_setup/scripts/docker_env_setup.sh
    

**POWER CYCLE YOUR SYSTEM WHEN COMPLETE**



################################################################
### NEPI Docker Config Setup

This step will configure the NEPI Docker configuration using the defualt settings. 
You can change settings later in the 'NEPI Docker Customization' section.

Log into the `nepihost` user using password  'nepi'
(sudo password is 'nepi')


Run the NEPI Docker configuration setup script (sudo password is now 'nepi'):


    /home/nepihost/nepi_setup/scripts/docker_config_setup.sh


**NOTE:**  After this process, network IP addresses, internet connections, and clock sycn processes are managed by NEPI processes. If you need to connect to the internet you can run the command line shortcut 'ninet'


**POWER CYCLE YOUR SYSTEM WHEN COMPLETE**



################################################################
### NEPI Docker Storage Setup
This section will initialize the NEPI Docker User Storage folder (/mnt/nepi_storage). 

Log back into `nepihost` using password 'nepi' 

Enable internet connection and sync clocks:

    ninet

**NOTE:** Some additional NEPI Docker command line shortcuts are:

    pingi = ping internet test
    nipa= Echo NEPI set IP address
    naipa= Echo NEPI set IP alias addresses
    nnipa= Echo NEPI set NTP IP addresses
    nnet = Restart the network
    ndhcp = Enable DHCP Internet Client
    nclock = Sync clock
    ninet = Restart network, connect to internet, and sync clock
    sbrc = Source the current user's bashrc files
    cuda_version = Echo Cuda version number if cuda availble

Come back to this

    1) Download the lastest nepi_storage demo file to your PC from:

    drive
    wget https://www.dropbox.com/scl/fi/za3sz2q7e0pbcj6m89d8h/nepi_storage-latest.zip?rlkey=eq6u97w6qpqiqblcudqnwj8ud&st=aanpc7ah&dl=0


    Then, unzip and copy the folders from unzipped folder to the 'nepi_storage' shared drive.  Select 'Merge' if asked



################################################################
### NEPI Docker Initialization Setup
This section will initialize and test your NEPI Docker solution.  

**NOTE:** If you encounter any issues starting and running the NEPI Software container, 
see the debugging steps in the "NEPI Docker Debugging" section at the end of this document.

Initialize NEPI docker image installation by typing:

    nepiinit

After the initialization script completes, it will print the current installed NEPI Docker Images installed. 

Start your NEPI container running:

    nepistart

The start script will let you know if the installed NEPI Image started successfully. 

**NOTE:** Some additional NEPI Docker command line shortcuts are:

    nepistart = Start the NEPI docker container
    nepidev = Start the NEPI docker container in a dev mode with no processes running
    nepistop = Stop the running NEPI docker container
    nepilogin = Log into the running NEPI container
    nepiswitch = Switch to Inactive NEPI container on next boot or reststat
    nepicommit = Commit the running NEPI container
    nepiinit = Reset, clear, and import new NEPI Image
    nepiimport = Import a NEPI image tar file. Optional: Enter a file name or full file path.
    nepiexport = Export the running NEPI container to a tar file. Enter a file name or full file path.
    nepiconfig = Configure NEPI System settings
    nepiupdate = Reconfigure NEPI System settings using the stored System Config settings file
    nepienable = Enable NEPI Docker service on next boot
    nepidisable = Disable NEPI Docker service on next boot
    nepirestart = Restart NEPI docker service
    nepistatus = Show the systemctl status for nepi_docker service
    nepilogs = Show live NEPI Docker service journal file
    nepireset = Reset all NEPI Config Folders
    nepiupdate = Run update process on NEPI Docker config file
    nepisettings = Print current NEPI DOCKER and SYSTEM configuration settings

    #You can see all available NEPI Docker command line shortcut tools by typing: nepihelp

**OPEN CHROMIUM WEB BROSWER**
Check that the NEPI Resident User Interface (RUI) is running by opening the Chromium browser and entering the following in the search bar:

    localhost:5003 

This will take you to the NEPI RUI dashboard.  Once the NEPI core software system is running, you should see a blinking Green indicator and messages.
**NOTE:**  RUI Controls related to User, Device, Time, Network, and Software managemnt require the NEPI Docker service running.

If everthing is working, you can enable the NEPI Docker Service which will automatically start the NEPI Container and Software on boot:

    nepienable

**NOTE:** You can disable the NEPI Docker service with the command: nepidisable

**POWER CYCLE YOUR SYSTEM WHEN COMPLETE**

Log back into `nepihost` using password 'nepi' 

Check that your NEPI Container is running after reboot:

    dps

    #If your container is not running, try to debug the issue with the following commands:

        nepirestart
        nepistatus
        nepilogs


**NOTE:** You can debug any NEPI Docker Service issues by watching the live service logs using: nepilogs

################################################################
### NEPI Docker Remote PC Connections

Test that you can connect to your running conatiner from a network connected PC.
See a tutorial at [Connecting and Setup](https://nepi.com/nepi-tutorials/nepi-engine-connecting-and-setup/)

Test that you can connect your PC to NEPI Device's 'nepi_storage' folder using your PC's File Manager application. 
See a tutorial at [Accessing the User Storage Drive](https://nepi.com/nepi-tutorials/nepi-engine-user-storage-drive/)

Configure NEPI through the RUI interface.
See a tutorial at [NEPI Configuration](https:///)

SSH into either your NEPI Host device or NEPI running container following this tutorial.
See a tutorial at [NEPI SSH SETUP](https://nepi.com/nepi-tutorials/nepi-engine-accessing-the-nepi-file-system/)



################################################################
### NEPI Docker Customization




################################################################
### NEPI DOCKER INSTALLATION COMPLETE
################################################################



### NEPI Docker Installation Notes
The NEPI Docker system provides a full-featured AI and automation software environment that installs on top of your host device's native operating system.  To achieve this, the NEPI Docker solution interacts with the device's configuration. While the NEPI Docker installation privdes functions for reverting back to your orignal system configurations, it is recommended that you create a backup of your current device's hardrive to a seperate backup SSD card to ensure you are able to recover your original system if issues arise.  This can be done using a low cost SSD cloning device such as [Rosewill SSD Cloner](https://www.amazon.com/Duplicator-Enclosure-Clone-RS-N2-CL-PC-Mac-Android/dp/B0F51MMN7Q/?th=1) as long as you are cloning to the same SSD card type.


### Check Available Disk Space
Before proceeding, make sure you device has the minimum free space (60 GB) required for NEPI Docker installation and run-time processes.  

**NOTE:** If you don't have the minimum required free space to proceed, there are several options available:
1) Delete unneeded files and clean your current file system to open up additional free space.
3) Upgrade to a larger SSD by cloning your current SSD to a larger SSD hard drive using an SSD clone device that support's cloning to larger disks such as [StarTech SSD Cloner](https://www.amazon.com/StarTech-com-Duplicator-90GBpm-Standalone-Dual-Bay/dp/B0D37ZJFND/ref=sr_1_2_sspa).
Then run gparted to increase your file systems available space


### NEPI Docker Debugging

**********************
DEBUGGING NEPI Container Issues
**********************

If you NEPI Image failed to start, you can try to run it in a dev mode without any NEPI services started

    nepidev

    # Then log into to the running NEPI container check NEPI process statuses by typing:

    nepilogin

    # Once Inside the container, start the NEPI services running:

        /nepi_start_all

        # Once Inside the container, start and stop the NEPI software 

            nepi_status

            # Check if any of the NEPI services are not running in the printout. If any are not running, 
            # you can examine the process messages by running one of the following status commants:

            nepi_status_engine

            nepi_status_rui

            nepi_status_license

            nepi_status_ssh

            # To bug issues with the core NEPI Engine software process, you can start and stop NEPI Engine to visually look for run-time errors:

            nepistop
            nepistart

            **NOTE:** Some additional NEPI Software command line shortcuts are:

                nepihome = change to nepi home dir
                nepistart = start the nepi processes
                nepistop = stop the nepi processe
                nepiconfig = Configure NEPI System Settings
                nepibld = Build and deploy all nepi repos and RUI
                codebld = Build and deploy all nepi repos
                ruibld = Build and deploy rui system
                nepi_status = Print running status of all NEPI processes
                nepi_status_engine = Print tail of nepi_engine process
                nepi_status_rui = Print tail of nepi_rui process
                nepi_status_license = Print tail of nepi_license process
                nepi_status_ssh = Print tail of nepi_ssh process

**********************

