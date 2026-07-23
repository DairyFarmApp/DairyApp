# DairyCare

DairyCare is an offline-capable dairy farm management system under controlled phased development. The repository contains the Phase 1 foundation/hardening/MySQL gate and the completed Phase 2A animal-registry core. Milk, breeding, health, inventory, finance, and other later modules remain intentionally excluded.

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

Phase 2A provides controlled cattle/buffalo species, organization breeds, farm groups, animal registration/profile/search/filter/archive/restore, concurrency-safe numbering, parentage/location validation, permissions/audit, responsive Flutter screens, and authorized Drift read caching. MySQL 8.4.9 passes all 44 backend tests with 366 assertions; Flutter passes 33 tests, analysis, and the Android debug build. See the [animal-registry guide](docs/ANIMAL_REGISTRY.md) and [Phase 2A completion record](docs/PHASE_2A_COMPLETION.md).

## Phase controls

Read `AGENTS.md`, the master specification, and `docs/IMPLEMENTATION_PLAN.md` before changes. Phase 2A is complete; do not begin Phase 2B without explicit project-owner approval.
