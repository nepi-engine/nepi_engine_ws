# nepi_engine_ws
Top-level repository for nepi-engine development

You are in a _ROS 1_ branch. These is specifically for _ROS 1_ development. 

**If and only if you intend to run the _ROS 2_ variant of nepi-engine, switch to that branch now:**
```
$ git checkout ros2_main
```

At that point, follow the instructions in the top-level README to deploy code, build on the target hardware, etc.

## What about cross development for _ROS 1_ and _ROS 2_?
Generally, it will be a big headache to try to work on both branches from the same repository folder, so if you need to work on both, we recommend that you clone this repository twice and checkout different ROS-specific branches in each of the copies.

## Initial Repository Setup
There are two options for the location of the source repositories:
1. Source repository cloned on a Linux development host (virtual machine is fine)
2. Source repository cloned on target hardware

Generally, we recommend option 1 if you are going to be inspecting or modifying nepi-engine source code extensively, since it allows you to use your standard development environment and tools (editors, IDEs, etc.), which may not be available in the nepi-engine target filesystem.

Option 2 is convenient if you intend only to build the nepi-engine from source, not modify or inspect source, and your target hardware has a readily available internet connection (to allow initial cloning from GitHub). It is also a viable option if your target hardware and filesystem has a sufficient development environment.

In either case, source code is built on the target hardware from specific locations on the filesystem. Scripts are provided to deploy the source properly as later in this README.

### Selecting a _ROS 1_ Sub-branch
If you intend only to deploy and build a production-ready nepi-engine on target hardware, _ros1_main_ is the right branch:
```
$ git checkout ros1_main
```
If you would like to deploy and build the latest bleeding-edge version of nepi-engine or if you intend to add or modify nepi-engine source code, you should use the _ros1_develop_ branch as a starting point:
```
$ git checkout ros1_develop
```
### Submodule setup
This top-level nepi_engine_ws repository makes extensive use of git submodules. The following step ensures that the submodules are cloned and set to the proper commit.
```
$ git submodule update --init --recursive
```
#### Submodule Details ####
See individual submodule READMEs (as available)

## Deploying Source Code
This repository includes a shell script to deploy source code to the proper subdirectories on the target. The script works whether run from a development host with network connectivity to the target or run directly from the target (e.g., after repository clone and setup directly on the target hardware filesystem).
```
$ ./_deploy_nepi_engine_source.sh_
```
### Development host setup
The _deploy_nepi_engine_source.sh_ script relies on some environment variables that should be set in your _.bashrc_ or via your own setup script prior to running it.
1. **NEPI_REMOTE_SETUP**: 
Indicates whether running from development host or directly on target (1 = Dev. Host, 0 = From Target. Set to 0 automatically when on a prepared NEPI target 
filesystem)
1.  **NEPI_TARGET_IP**:
Target IP address/hostname (for remote operations, as applicable)
1. **NEPI_TARGET_USERNAME**:
Target username (as applicable)
1. **NEPI_SSH_KEY**
Private SSH key for SSH/Rsync to target (as applicable)
1. **NEPI_TARGET_SRC_DIR**:
Directory to deploy source code to (except _nepi_rui_, which must be located at _/opt/nepi/rui_ as described in that submodule's README). The usual
location is on the NEPI user partition (_/mnt/nepi_storage_) at _/mnt/nepi_storage/


