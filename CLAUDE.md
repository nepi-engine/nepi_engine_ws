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

## MENURIC FRAMEWORK INTEGRATION

This repo uses the Menuric Framework for AI-assisted development governance. The framework adds persistent context, decision tracking, and session continuity across Claude AI and Claude Code sessions.

Framework documents in this repo:

- NEPI-LORE.md — Platform philosophy, voice guidelines, design principles, and development standards. Claude reads this before every substantive response.
- NEPI-FORGE.md — Lifecycle stages, release checklists, versioning conventions, and contributor workflow.
- NEPI-CODEX.md — Platform identity, target users, feature set, design decisions, and competitive position.

For deep pipeline and architecture details, this CLAUDE.md remains the authoritative source. The CODEX and LORE provide the why behind the architecture documented here.


## DECISION LOG

Format: YYYY-MM — Decision — Brief rationale

- 2026-03 — Adopted Menuric Framework — Added governance scaffolding for AI-assisted development. Framework documents (LORE, FORGE, CODEX) added to repo root. Existing CLAUDE.md preserved and extended rather than replaced.


## SESSION SUMMARY INSTRUCTIONS

Before committing at the end of any Claude Code session, write a summary to .claude/sessions/YYYY-MM-DD-brief-topic.md covering:

- Decisions made during this session
- Architectural discoveries or new constraints found
- Test results (what passed, what failed, what was unexpected)
- Unresolved issues or items for the next session

Session files are gitignored. They are supplementary context, not the authoritative source. The authoritative sources are this CLAUDE.md, NEPI-CODEX.md, and NEPI-LORE.md.

The session-start hook at .claude/hooks.json loads the most recent session summary automatically. Session files older than 7 days are ignored on load. Files older than 14 days are auto-pruned.


## REFERENCES

- NEPI-CODEX.md — Platform identity, features, and design decisions
- NEPI-LORE.md — Portfolio-wide philosophy, voice, and development standards
- NEPI-FORGE.md — Lifecycle stages and release checklists
