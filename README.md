# DairyCare

DairyCare is an offline-capable dairy farm management system under controlled
phased development. The repository contains the Phase 1
foundation/hardening/MySQL gate, Phase 2 animal registry workflows,
self-service one-farm owner/family onboarding, the controlled medicine, semen,
and feed inventory core, Phase 3A daily milk recording, and Phase 7A employees,
monthly payroll, employee loans, and PKR finance. Breeding, health, attendance,
statutory payroll, and other later modules remain intentionally excluded.

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

## Run on Windows

After completing the one-time environment setup, double-click
`RUN_DAIRYCARE.bat` in the repository root. It starts MySQL when possible,
applies pending migrations, opens the Laravel API in one command window, and
launches Flutter in Chrome from another. It never resets or seeds the database.

For a preflight without starting anything:

```powershell
.\RUN_DAIRYCARE.bat --check
```

Phase 2A provides the animal registry. Phase 2B adds controlled movements. Phase
2C adds weights and status history. The UX/web stabilization provides the
responsive visual system and working Drift browser runtime. Owner onboarding
now lets a new owner name one private farm, invite multiple persistent family
accounts with a reusable link, and remove or restore their access. The inventory
core adds batch-backed opening stock and idempotent receipts, searchable
medicine/semen/feed overviews, expiry and low-stock indicators, and persistent
glass `System`, `White`, and `Dark` themes. Phase 3A adds morning, afternoon,
and evening milk entry, real daily summaries, immutable corrections, and
retryable offline creation. See the
[owner/family guide](docs/OWNER_ONBOARDING_AND_FAMILY_ACCESS.md) and
[inventory guide](docs/INVENTORY_MANAGEMENT.md), plus the
[daily milk guide](docs/DAILY_MILK_PRODUCTION.md) and
[workforce/finance guide](docs/WORKFORCE_FINANCE.md).

## Phase controls

Read `AGENTS.md`, the master specification, and `docs/IMPLEMENTATION_PLAN.md`
before changes. Phase 2C, UX/web stabilization, owner/family onboarding,
inventory core, Phase 3A daily milk, and Phase 7A workforce/finance core are
implemented; do not combine remaining capabilities or begin another domain
without explicit project-owner approval for one controlled scope.
