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

---

## Naming Conventions

Python functions and methods in nepi_api follow this convention:

Public functions and methods:
  snake_case — all lowercase, words separated by underscores.
  Example: goto_tilt_ratio, get_ready_state, publish_status
  These are part of the callable API surface and receive docstrings.

Private functions and methods:
  camelCase — no leading underscore, mixed case.
  Example: initCb, resetCb, publishStatusCb, getPanAdj
  These are internal implementation. No docstrings required.
  Some private methods also carry a leading underscore (_camelCase) for additional
  emphasis, but the underscore is not required — camelCase alone marks a method private.

This convention is the authoritative rule for determining docstring scope
during documentation passes. Any camelCase method (with or without a leading
underscore) is treated as private and does not receive docstrings.

The Cb suffix indicates a ROS callback. Methods with this suffix registered
as ROS subscribers, publishers, or timer callbacks carry rename risk and must
be audited for external call sites before any renaming pass proceeds.

---

## MENURIC FRAMEWORK INTEGRATION

This repo uses the Menuric Framework for AI-assisted development governance. The framework adds persistent context, decision tracking, and session continuity across Claude AI and Claude Code sessions.

Framework documents in this repo (located in `src/nepi_claude/`):

- src/nepi_claude/NEPI-LORE.md — Platform philosophy, voice guidelines, design principles, and development standards. Claude reads this before every substantive response.
- src/nepi_claude/NEPI-FORGE.md — Lifecycle stages, release checklists, versioning conventions, and contributor workflow.
- src/nepi_claude/NEPI-CODEX.md — Platform identity, target users, feature set, design decisions, and competitive position.
- src/nepi_claude/NEPI-PROMPT.md — Prompt generation mode instructions. See that file for the full "prompt:" trigger behavior.

For deep pipeline and architecture details, this CLAUDE.md remains the authoritative source. The CODEX and LORE provide the why behind the architecture documented here.


## DECISION LOG

Format: YYYY-MM — Decision — Brief rationale

2026-05 — Added RPi cam3 IDX driver (idx_rpi_cam3) using libcamera/picamera2 stack — CSI camera on RPi5 is not exposed via V4L2 (excluded as pispbe in idx_v4l2 discovery); dedicated driver required

2026-07 — Registry keys on a shared node_if must be domain-unique — register_pubs/subs/services and add_params do a keyed dict.update() on a NodeClassIF's internal registry. When a sub-IF (SettingsIF, SaveDataIF, Transform3DIF, NavPoseIF, image-IFs) shares a device's node_if, a generic key (e.g. status_pub, capabilities_query, disable, reset) silently overwrites the device's or a sibling's entry, orphaning the earlier publisher (topic stays advertised but never publishes; wrong-type publishes are swallowed by a throttled try/except). Fix is to prefix sub-IF keys with the sub-IF domain (settings_, save_data_, transform_, navpose_). The ROS wire name derives from namespace+topic/srv, NOT the key, so key renames are wire-safe — EXCEPT params, where the wire name IS namespace+param-key. Multi-instance IFs (image-IFs) need namespace-derived keys, not a per-class prefix. Sub-IFs currently build their own node_if (node_if=self.node_if is commented out in the device IFs), which also avoids the collision; unique keys keep the shared/un-shared toggle safe either way.

2026-08 — Simulator contract owned by NEPI-core as nepi_app_sim_connector — The generic NEPI-to-simulator contract (SimDeviceIF, api/device_if_sim.py) ships as an app, per the 2026-08-05 division of labor in nepi_drones/docs/SIMULATION_INTERFACE_SPEC.md. The app is simulator-agnostic and hosts one well-known TCP/JSON listener that any simulator's own bridge script dials into; each simulator-specific driver (first: rbx_gazebo) owns its own transport and registers through RBXRobotIF. Simulator discovery matches on device type plus a declared capability — an RBX device whose data_source_description is 'simulator' — never on a simulator's product name, so a new simulator appears in the app's selector by setting one constructor argument. Named nepi_app_sim_connector rather than the spec's app_sim_connector because pkg_name is load-bearing three ways (catkin package, rosrun package, and the Python module for the msg import); the ROS node name stays app_sim_connector. Message/service types (SensorTopicInfo, SimInfo, SimStatus, SimCapabilitiesQuery) live in the app package, not nepi_interfaces — promote both the types and the IF class to nepi_engine/nepi_interfaces only when a second consumer needs the contract. Note that CMakeLists installs api/*.py into nepi_api and rui/*.js flat into nepi_rui's src, so at runtime both already sit beside their siblings; only the source home is app-local, and the RUI basenames share a global namespace across all app packages (a duplicate basename silently overwrites).

2026-08 — One sanctioned exception to decided-once capabilities — Device interface classes derive has_* flags from which constructor callbacks are non-None, once, cached, because that is what makes capability-flag-driven RUI rendering work. SimDeviceIF.apply_capability_profile() re-runs that derivation in place when an operator selects a robot config, because a robot's kind is exactly what those flags describe; the alternatives were rejected (rebuilding the instance re-advertises the same services and subscribers and starts a second status timer — note NodeClassIF DOES expose unregister_pub(s)/unregister_service(s)/unregister_sub(s)/unregister_class at node_if.py:1363-1440, so the objection is duplicate advertisement, not a missing teardown path; a node restart pushes an apps_mgr disable/enable cycle onto the operator for what looks like a dropdown). It is wire-safe ONLY because three properties hold: the full command surface registers once at construction regardless of any flag, every command callback independently guards on its own injected function being None, and ROS names derive from namespace not capability — so only the reported flags move. Profiles are applied whole, never merged, and a caps_lock keeps capabilities_query from reading a half-rewritten report. Registering any publisher or service conditionally on a capability flag breaks this. Do not generalize the pattern to other interface classes without the same three properties.


## PUSH EDITS WORKFLOW

When told "push edits", execute the full push workflow documented in nepi_claude/NEPI-FORGE.md under PUSH EDITS WORKFLOW. That document is the authoritative source for the procedure. The short version:

1. Audit all submodules for pending changes (git submodule status + git status inside each modified submodule)
2. Commit inside each submodule with a specific commit message (checkout main first if in detached HEAD)
3. Push each submodule to its own remote (origin main)
4. Update and commit superproject submodule pointers
5. Push nepi_engine_ws main to origin
6. Verify: no + prefixes in git submodule status


## SESSION SUMMARY INSTRUCTIONS

Before committing at the end of any Claude Code session, write a summary to .claude/sessions/YYYY-MM-DD-brief-topic.md covering:

- Decisions made during this session
- Architectural discoveries or new constraints found
- Test results (what passed, what failed, what was unexpected)
- Unresolved issues or items for the next session

Session files are gitignored. They are supplementary context, not the authoritative source. The authoritative sources are this CLAUDE.md, nepi_claude/NEPI-CODEX.md, and nepi_claude/NEPI-LORE.md.

The session-start hook at .claude/hooks.json loads the most recent session summary automatically. Session files older than 7 days are ignored on load. Files older than 14 days are auto-pruned.


## SUBMODULE DEVELOPER REFERENCES

Read these files only when working in the relevant submodule:

- src/nepi_engine/CLAUDE.md — core engine, managers, SDK, API
- src/nepi_apps/CLAUDE.md — application packages
- src/nepi_rui/CLAUDE.md — web UI (Flask + React)
- src/nepi_interfaces/CLAUDE.md — ROS message/service definitions
- src/nepi_drivers/CLAUDE.md — hardware driver packages
- src/nepi_ai_frameworks/CLAUDE.md — AI model framework adapters
- nepi_setup/CLAUDE.md — deployment and setup scripts


## PROMPT GENERATION MODE

When a user message begins with "prompt:", enter prompt generation mode. Full instructions are in src/nepi_claude/NEPI-PROMPT.md — read that file before generating any prompt.

If the user types "prompt:" with nothing after it, respond: Please describe the task after "prompt:" and include the target submodule if known.


## REFERENCES

- src/nepi_claude/NEPI-CODEX.md — Platform identity, features, and design decisions
- src/nepi_claude/NEPI-LORE.md — Portfolio-wide philosophy, voice, and development standards
- src/nepi_claude/NEPI-FORGE.md — Lifecycle stages and release checklists
- src/nepi_claude/NEPI-PROMPT.md — Prompt generation mode instructions
