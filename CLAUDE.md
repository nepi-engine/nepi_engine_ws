# NEPI Engine Workspace

## Project Overview

NEPI-Engine is an edge-AI and automation software platform for NVIDIA Jetson and embedded systems. This is a ROS 1 (Catkin) workspace organized as a git superproject with multiple submodules.

## Architecture

```
nepi_engine_ws/
├── src/
│   ├── nepi_engine/       # Core engine: nepi_api, nepi_env, nepi_managers, nepi_sdk
│   ├── nepi_drivers/      # Hardware driver interfaces
│   ├── nepi_apps/         # Application collection (app framework)
│   ├── nepi_interfaces/   # Custom ROS messages/services
│   ├── nepi_rui/          # Web-based Resident User Interface (Python backend + React frontend)
│   ├── nepi_ai_frameworks/# AI model framework interfaces
│   ├── nepi_3rd_party/    # Third-party dependencies
│   └── nepi_scripts/      # Automation and utility scripts
└── nepi_setup/            # Deployment and setup documentation/scripts
```

All `src/` subdirectories are independent git submodules tracking the `main` branch.

## Build System

- **Build tool**: catkin (`catkin_make` or `catkin build`)
- **Build scripts**: `build_nepi_code.sh`, `build_nepi_complete.sh`
- **RUI frontend**: Built separately with npm (`build_nepi_rui.sh`)
- **Language**: Primarily Python (ROS nodes), some C++, React/Node.js for RUI

## Key Environment Variables

Set by build scripts:
- `NEPI_USER`, `NEPI_HOME`, `NEPI_DOCKER`, `NEPI_STORAGE`, `NEPI_CONFIG`

## Submodule Workflow

Since all components are submodules, changes to source code must be committed in the submodule repo, then the superproject updated:
```bash
cd src/nepi_engine  # work in submodule
git add . && git commit -m "..."
cd ../..
git add src/nepi_engine && git commit -m "Update submodule"
```

## ROS Package Structure

Each app in `nepi_apps/` follows a consistent layout:
- `scripts/` - ROS node Python scripts
- `api/` - API definitions
- `params/` - Parameter files
- `msg/` / `srv/` - Custom messages/services
- `rui/` - React UI components for that app

## Driver Pattern

Drivers in `nepi_drivers/` implement hardware abstraction layers. Discovery scripts (e.g., `lsx_deepsea_sealite_discovery.py`) auto-detect and configure hardware.
