# DairyCare

DairyCare is an offline-capable dairy farm management system under controlled phased development. The repository contains the Phase 1 foundation/hardening/MySQL gate, Phase 2A animal registry, Phase 2B online animal movement workflow, and Phase 2C online animal weights and operational-status history. Milk, breeding, health, inventory, finance, and other later modules remain intentionally excluded.

## Repository layout

```text
apps/
  mobile/   Flutter mobile, tablet, and responsive web client
  api/      Laravel REST API
docs/       Product and architecture documentation
scripts/    Repository helper documentation and future approved scripts
```

## Prerequisites

- Flutter 3.41.9 stable / Dart 3.11.5
- PHP and Composer compatible with the Laravel version recorded by `apps/api/composer.lock`
- MySQL 8.4 LTS for local/production persistence
- Git 2.x

See [environment setup](docs/ENVIRONMENT_SETUP.md), the [resolved dependency inventory](docs/DEPENDENCIES.md), and each application README before running the projects. The repository quality workflow repeats formatting, analysis, SQLite and MySQL test passes, migration/seed/rollback validation, Android and web builds, and dependency audit on pushes and pull requests.

Phase 2A provides the animal registry. Phase 2B adds controlled movements. Phase 2C adds exact decimal kg/lb weights, immutable corrections, latest-weight projection, dedicated versioned operational-status changes, responsive Flutter history/forms, and authorized Drift read caching. The subsequent UX/web stabilization adds a responsive visual system, real-data dashboard, polished authentication/context selection, safe error states, and a working Drift browser runtime. MySQL 8.4.9 passes all 67 backend tests with 677 assertions; Flutter passes 64 tests, analysis, release web compilation, and the Android debug build. See the [animal-registry guide](docs/ANIMAL_REGISTRY.md), [movement guide](docs/ANIMAL_MOVEMENTS.md), [weight/status guide](docs/ANIMAL_WEIGHTS_AND_STATUS.md), [Phase 2C completion record](docs/PHASE_2C_COMPLETION.md), and [UX/web stabilization record](docs/PHASE_2_UX_WEB_STABILIZATION_COMPLETION.md).

## Phase controls

Read `AGENTS.md`, the master specification, and `docs/IMPLEMENTATION_PLAN.md` before changes. Phase 2C and the UX/web stabilization are implemented; do not combine the remaining animal capabilities or begin another dairy domain without explicit project-owner approval for one controlled scope.
