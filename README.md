# DairyCare

DairyCare is an offline-capable dairy farm management system under controlled phased development. The repository currently contains the Phase 1 foundation, Phase 1.1 security/platform hardening, and the completed Phase 1.2 MySQL validation gate only; animal, milk, health, inventory, finance, and other product modules are intentionally excluded.

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

Local Phase 1.2 validation uses official Oracle MySQL Community Server 8.4.9 through the local-only `MySQL84` Windows service. Fresh migration, rollback/remigration, repeatable seed, real HTTP endpoints, direct schema inspection, tenant constraints, separate-process renewal/idempotency races, the 31-test MySQL backend suite, the SQLite portability suite, all 18 Flutter tests, and an Android debug build pass. See the [Phase 1.2 validation record](docs/PHASE_1_2_MYSQL_VALIDATION.md).

## Phase controls

Read `AGENTS.md`, the master specification, and `docs/IMPLEMENTATION_PLAN.md` before changes. Do not begin Phase 2 without explicit project-owner approval.
