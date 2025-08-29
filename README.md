# NEPI-Engine
This repository contains documentation and tools for getting started with NEPI Engine, a full-featured edge-AI and automation software platform for NVIDIA Jetson and other embedded edge-compute hardware platforms.

**[Learn more about NEPI Engine](https://nepi.com/)**

## Clone the NEPI Engine Repo
Clone the 'main' branch:

    git clone git@github.com:nepi-engine/nepi_engine_ws.git 
    cd nepi_engine_ws
    git checkout main
    git submodule update --init --recursive

Or, clone the 'development' branch:

    git clone git@github.com:nepi-engine/nepi_engine_ws.git 
    cd nepi_engine_ws
    git checkout develop
    git submodule update --init --recursive

## NEPI Engine Architecture

A NEPI-enabled device provides the complete NEPI Engine suite of tools and applications. Most of these components can be enabled and disabled through system configuration, and many can also be started and stopped at run-time as needed.

The entire NEPI software source code, including the nepi engine system, nepi applications, ai frameworks, drivers, and build scripts, is available in the top-level "nepi_engine_ws" repository:

- [nepi_engine_ws](https://github.com/nepi-engine/nepi_engine_ws) - Superproject for all NEPI Engine source code, including hardware drivers, ROS-based SDK components, user interfaces, and edge-side NEPI Connect components. Source code is organized as a collection of git submodules below this superproject. Building and running this software depends on a properly prepared root filesystem, as covered by _nepi_rootfs_tools_.

The nepi_engine_ws includes the following nepi component repos
- [nepi_engine](https://github.com/nepi-engine/nepi_engine) - The complete NEPI engine operating environment including NEPI SDK, NEPI APIs, and NEPI Managers.
  
- [nepi_rui](https://github.com/nepi-engine/nepi_rui) -  NEPI's device-hosted Resident User Interface (RUI) system that provides browser-based js/react webserver interface to the NEPI Enging system.
  
- [nepi_interfaces](https://github.com/nepi-engine/nepi_interfaces) - Collection of NEPI Engine custom ROS or ROS2 messages and services depending on which branch you checkout. Included as part of _nepi_engine_ws_, but if you are only trying to interact with an existing NEPI Engine system via the ROS interface, this repository can be included in your own workspace, built, and sourced to provide these message and service objects to the rest of your application.

- [nepi_drivers](https://github.com/nepi-engine/nepi_drivers) - Collection of NEPI driver interfaces for sensors and control devices. These driver interfaces abstract the hardware interface into NEPI standard interfaces allowing downstream applications to interact with the hardware without needing to know any specific details about the specific hardware interfaces.

- [nepi_apps](https://github.com/nepi-engine/nepi_apps) - Collection of NEPI applications that expand the capabilities and features of the base NEPI software environment.

- [nepi_ai_frameworks](https://github.com/nepi-engine/nepi_ai_frameworks) - Collection of NEPI ai framework interfaces for loading and running ai detection models.

- [nepi_auto_scripts](https://github.com/nepi-engine/nepi_auto_scripts) - Collection of NEPI Engine automation scripts that provide useful functionality and examples for the powerful NEPI Engine Automation Manager. Typically these scripts are deployed as-is to the NEPI storage partition (i.e., user partition) and/or used as references when developing new scripts.

- [nepi_3rd_party](https://github.com/nepi-engine/nepi_3rd_party) - Collection of 3rd party provided repositories used by the NEPI Engine system.  


## Get Involved
The best way to get involved is to contribute to NEPI-Engine source code and documentation. While Numurus accepts community contributions to the NEPI Engine open-source project, contributors must submit a signed CLA before contributing code. Contributions in the form of pull requests are gladly accepted as long as we have a signed Contributor License Agreement from you or your organization. Just download the relevant agreement and follow the instructions:
- [Individual CLA](https://numurus.com/wp-content/uploads/NEPI-Engine-Individual-Contributor-License-Agreement.pdf)
- [Organization CLA](https://numurus.com/wp-content/uploads/NEPI-Engine-Organization-Contributor-License-Agreement.pdf)
