# NEPI ENGINE — FORGE: Lifecycle and Release Operations

This document defines how NEPI Engine features and releases move from idea to shipped and how they are maintained after release. It covers lifecycle stages, readiness checklists, versioning conventions, and release operations.

For philosophy and development standards, see NEPI-LORE.md. For product identity and feature decisions, see NEPI-CODEX.md.


## HOW THIS DOCUMENT WORKS

The lifecycle stages below are a mental model for identifying what should exist at each point in a feature or release cycle. When a conversation suggests a release is approaching a new stage, Claude checks the relevant checklist and surfaces anything not addressed.


## STAGE 1 — CONCEPT

A feature or capability is being explored in conversation. Grounded in the Lore and CODEX.

Checklist before moving to Stage 2:

- A clear user need (who specifically benefits and why)
- A clear purpose (one sentence, what the feature does)
- A rough MVP scope (3-5 things, not a full spec)
- Confirmation the feature fits the hardware-agnostic design principle
- Confirmation it does not introduce unnecessary cloud dependency
- Privacy review passed (no undisclosed data collection)


## STAGE 2 — SPECIFICATION

The feature has a written spec. Development has not yet begun.

Checklist before moving to Stage 3:

- Spec includes: what, user-facing behavior, technical approach, acceptance criteria, MVP boundary
- Deferred list exists and is explicit
- Security review surfaced in the spec
- Privacy review passed
- Relevant CLAUDE.md sections identified for update after implementation
- Test strategy identified (unit, integration, hardware validation)


## STAGE 3 — IMPLEMENTATION

Claude Code is building the feature.

Claude monitors throughout Stage 3:

- Explore-Plan-Code-Commit workflow followed
- Tests written alongside implementation
- No scope creep beyond the spec MVP boundary
- CLAUDE.md decision log updated as new constraints are discovered
- Session summaries written before every commit


## STAGE 4 — VALIDATION

Core implementation complete. Validation required before release.

Checklist:

- Automated tests pass
- Real-world hardware validation performed
- Edge cases tested: hardware failure, no connectivity, resource constraints
- Security considerations verified
- CHANGELOG.md Unreleased section updated
- NEPI-CODEX.md Feature Set updated to reflect shipped status
- CLAUDE.md current with all new constraints and decisions


## STAGE 5 — RELEASE

Checklist:

- Full test suite passes
- Version string updated per versioning convention below
- CHANGELOG.md Unreleased entries moved under new version heading
- Release tagged in git
- Submodule superproject updated to point to new commits
- GitHub release notes drafted
- community.nepi.com updated if user-facing changes
- Documentation updated at docs location


## STAGE 6 — LIVE

Ongoing maintenance after release:

- Community issues and pull requests reviewed regularly
- Crash reports and error logs reviewed
- Patch versions planned for critical bugs
- Feature versions planned from deferred list and community feedback
- CHANGELOG.md maintained with every release
- Contributor CLA process followed for external contributions


## VERSIONING CONVENTION

NEPI Engine follows semantic versioning: Major.Minor.Patch.

Patch versions (x.x.N) are bug fixes and minor corrections. Minor versions (x.N.0) are feature releases. Major versions (N.0.0) are reserved for fundamental architectural changes or breaking API changes.

The version string is documented in CLAUDE.md and updated by Claude Code as part of the release process.


## COMMIT AND PUSH PROTOCOL

Every Claude Code session that commits must also push before reporting the task as complete. A commit without a push is not a completed task. If the push fails, Claude Code must report the failure explicitly.


## SUBMODULE WORKFLOW

Changes to source code must be committed in the relevant submodule repo first, then the superproject updated:

  cd src/nepi_engine
  git add . && git commit -m "description"
  cd ../..
  git add src/nepi_engine && git commit -m "Update submodule: description"
  git push

This applies to all submodules: nepi_engine, nepi_drivers, nepi_apps, nepi_interfaces, nepi_rui, nepi_ai_frameworks, nepi_3rd_party.


## CONTRIBUTOR WORKFLOW

External contributions require a signed CLA before merging. Individual CLA and Organization CLA are available at numurus.com. Pull requests are accepted only after CLA confirmation.
