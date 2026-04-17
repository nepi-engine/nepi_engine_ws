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

Framework documents in this repo (located in `nepi_claude/`):

- nepi_claude/NEPI-LORE.md — Platform philosophy, voice guidelines, design principles, and development standards. Claude reads this before every substantive response.
- nepi_claude/NEPI-FORGE.md — Lifecycle stages, release checklists, versioning conventions, and contributor workflow.
- nepi_claude/NEPI-CODEX.md — Platform identity, target users, feature set, design decisions, and competitive position.

For deep pipeline and architecture details, this CLAUDE.md remains the authoritative source. The CODEX and LORE provide the why behind the architecture documented here.


## DECISION LOG

Format: YYYY-MM — Decision — Brief rationale


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


## REFERENCES

- nepi_claude/NEPI-CODEX.md — Platform identity, features, and design decisions
- nepi_claude/NEPI-LORE.md — Portfolio-wide philosophy, voice, and development standards
- nepi_claude/NEPI-FORGE.md — Lifecycle stages and release checklists
