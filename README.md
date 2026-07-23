# DairyCare

DairyCare is an offline-capable dairy farm management system under controlled phased development. The repository contains the Phase 1 foundation/hardening/MySQL gate, Phase 2A animal registry, and Phase 2B online animal movement workflow. Milk, breeding, health, inventory, finance, and other later modules remain intentionally excluded.

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

Phase 2A provides the animal registry. Phase 2B adds online movement request/approve/reject/cancel, atomic current-location projection updates, immutable movement history, both-farm authorization, audit, responsive Flutter workflows, and authorized Drift read caching. MySQL 8.4.9 passes all 56 backend tests with 501 assertions; Flutter passes 46 tests, analysis, and the Android debug build. See the [animal-registry guide](docs/ANIMAL_REGISTRY.md), [movement guide](docs/ANIMAL_MOVEMENTS.md), and [Phase 2B completion record](docs/PHASE_2B_COMPLETION.md).

## Phase controls

Read `AGENTS.md`, the master specification, and `docs/IMPLEMENTATION_PLAN.md` before changes. Phase 2B is complete; do not begin Phase 2C or another animal/domain capability without explicit project-owner approval.
