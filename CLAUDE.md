# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

NEPI Engine is a ROS-based edge-AI and automation platform for NVIDIA Jetson and embedded hardware. The workspace is a catkin superproject organized as nested git submodules.

## Repository Structure

This is a **git submodule superproject**. Each top-level directory under `src/` is a separate git repo. Always use `git submodule update --init --recursive` after cloning.

**Submodules:**
- `src/nepi_engine/` — Core engine (SDK, API, Managers, Environment)
- `src/nepi_interfaces/` — ROS custom message and service definitions (132+ msgs, 43+ srvs)
- `src/nepi_drivers/` — Hardware driver abstractions
- `src/nepi_rui/` — Resident User Interface (React web app)
- `src/nepi_apps/` — Optional pluggable applications
- `src/nepi_ai_frameworks/` — AI frameworks (YOLOv8, YOLOv11)
- `src/nepi_3rd_party/` — Third-party dependencies
- `src/nepi_scripts/` — Automation scripts
- `nepi_setup/` — Build configs, Docker setup, deployment docs

## Build Commands

The build system is **catkin** (ROS 1) with two profiles:

```bash
# Full build (engine + RUI)
./build_nepi_complete.sh

# Engine code only (no RUI)
./build_nepi_code.sh

# RUI only
./build_nepi_rui.sh

# Direct catkin build (release profile, all cores)
catkin build --profile=release --env-cache -j -p$(nproc)

# Debug build
catkin build --profile=debug --env-cache -j -p$(nproc)

# Build a single package
catkin build --profile=release <package_name>
```

**Catkin profiles** (configured in `.catkin_tools/profiles/`):
- `release` — installs to `/opt/nepi/nepi_engine`, uses `-DCMAKE_BUILD_TYPE=Release`
- `debug` — installs to `install_debug/`, uses `-DCMAKE_BUILD_TYPE=Debug`

**RUI build** (React frontend at `src/nepi_rui/src/rui_webserver/rui-app/`):
```bash
cd /opt/nepi/nepi_rui/src/rui_webserver/rui-app && npm run build
```

## Deployment

```bash
# Deploy source to target device (requires NEPI_REMOTE_SETUP env var)
./deploy_nepi_complete.sh

# Deploy automation scripts only
./build_nepi_auto.sh
```

## Architecture

### Layered Design (bottom-up)

1. **Interfaces** (`src/nepi_interfaces/`) — ROS msg/srv definitions shared across all packages. Changes here affect everything downstream.

2. **SDK** (`src/nepi_engine/nepi_sdk/src/nepi_sdk/`) — Python utility library. Key modules:
   - `nepi_ros.py` — ROS node, topic, service, parameter helpers
   - `nepi_devices.py` — Device abstraction base
   - `nepi_nav.py` — Navigation/pose
   - `nepi_aifs.py` — AI framework interfaces
   - `nepi_cfg.py` — Configuration management

3. **API** (`src/nepi_engine/nepi_api/src/nepi_api/`) — External connection interfaces. Each device type has a corresponding `device_if_*.py` and `connect_*_if.py` module.

4. **Managers** (`src/nepi_engine/nepi_managers/scripts/`) — ROS nodes that orchestrate the system: `system_mgr.py`, `drivers_mgr.py`, `ai_models_mgr.py`, `apps_mgr.py`, `config_mgr.py`, `network_mgr.py`, `navpose_mgr.py`, `time_mgr.py`, `scripts_mgr.py`, `targets_mgr.py`, `software_mgr.py`.

5. **Drivers** (`src/nepi_drivers/`) — Hardware abstractions organized by device type with a consistent pattern per driver:
   - `*_discovery.py` — Auto-discovery
   - `*_driver.py` — Core implementation
   - `*_node.py` — ROS node wrapper
   - `*_params.yaml` — Default parameters

6. **Applications** (`src/nepi_apps/`) — Each app follows: `scripts/` (ROS node), `api/` (interface), `rui/` (React component), `msg/`+`srv/`, `params/`.

7. **RUI** (`src/nepi_rui/`) — React 16 + MobX web app served by Python Flask. ROS bridge via roslib.

### Device Type Taxonomy

Drivers and interfaces use a standard prefix taxonomy:
- **IDX** — Image/camera devices (V4L2, ONVIF, GeniCAM, ZED)
- **PTX** — Pan-tilt devices
- **LSX** — Light/illumination devices
- **NPX** — Navigation/position devices
- **RBX** — Robotic platform devices

### Languages

- **Python** — Primary language for all ROS nodes, SDK, API, managers, drivers, apps
- **JavaScript/React** — RUI frontend (83 components in `src/nepi_rui/src/rui_webserver/rui-app/src/`)
- **C++** — Limited use for low-level hardware (I2C, ADC, DAC in `src/nepi_engine/nepi_env/`)

## Key Environment Variables

Build scripts expect these (with defaults if unset):
- `NEPI_BASE=/opt/nepi`
- `NEPI_ENGINE=/opt/nepi/nepi_engine`
- `NEPI_RUI=/opt/nepi/nepi_rui`
- `NEPI_STORAGE=/mnt/nepi_storage`
- `NEPI_CONFIG=/mnt/nepi_config`

## Important Notes

- When modifying ROS messages/services in `src/nepi_interfaces/`, rebuild the interfaces package first — all other packages depend on it.
- Each submodule has its own git history. Commits to code inside `src/*/` must be made within that submodule's context.
- The `SETUPTOOLS_USE_DISTUTILS=stdlib` env var is required during builds.
- Driver discovery scripts are launched by `drivers_mgr.py` and scan for connected hardware at runtime.
