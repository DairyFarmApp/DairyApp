# Phase 3A Daily Milk Production Completion

Date: 2026-07-30  
Branch: `phase/3-milk-management`  
Status: Implemented and validated; not committed or pushed

## Implemented scope

Phase 3A adds daily per-animal milk recording for the active organization and
farm. Authorized users can select a date and morning, afternoon, or evening
session; enter total and rejected litres; review real daily metrics; and create
an immutable correction with a mandatory reason.

The backend remains authoritative. One `milk_production_slots` row identifies
an organization/farm/animal/date/session combination.
`milk_entries` contains immutable revisions, with one current revision per
slot. An ordinary correction supersedes the current entry; it never overwrites
the original.

Eligible animals must be active adult females in the active farm. Exact decimal
strings are stored as `DECIMAL(18,3)`. Rejected milk cannot exceed total milk,
and a positive rejected quantity requires a reason. The sellable total is
calculated as total minus rejected milk.

## Database migrations

- `2026_07_30_000600_create_daily_milk_tables.php`
  creates scoped milk slots and immutable milk entry revisions, UUIDv7 keys,
  composite tenant/farm relationships, exact decimal columns, and duplicate
  protection.
- `2026_07_30_000610_add_daily_milk_permissions.php`
  adds `milk.view`, `milk.create`, and `milk.correct` and grants the approved
  role defaults.

The development seeder creates repeatable morning/evening history for eligible
animals over 30 days. A MySQL fresh migration and seed passed. Rolling back the
two Phase 3A migrations and applying them again also passed.

## API endpoints

- `GET /api/v1/milk/daily`
- `POST /api/v1/milk/entries/bulk`
- `POST /api/v1/milk/entries/{entry}/correct`

Bulk creation accepts up to 200 entries and uses both the HTTP
`Idempotency-Key` and database uniqueness constraints. Daily output includes
eligible animals, current entries, total/rejected/sellable litres, recorded
animals, yesterday's sellable total, and the seven-day daily average.

Correction creates a new current revision, links it to the superseded entry,
and records the reason and actor. Audit actions are
`milk.entries_recorded` and `milk.entry_corrected`.

## Organization, farm, and permission controls

The organization and active farm come from the authenticated session. Request
payloads cannot select another organization. Queries and foreign keys enforce
organization/farm scope; cross-organization and cross-farm records remain
concealed.

- Owner: view, create, and correct
- Farm manager: view, create, and correct
- Farm worker: view and create
- Viewer: view only

Laravel authorization is the security boundary. Flutter hides unavailable
actions only as a user-experience aid.

## Flutter and offline behavior

The Flutter feature is separated into domain models, application providers, a
repository, and a responsive presentation screen. It includes:

- date picker and three milking sessions;
- total, rejected, sellable, recorded-animal, yesterday, and seven-day cards;
- per-animal quick entry and validation;
- current-entry state and immutable correction dialog;
- permanent authenticated `Milk Production` menu entry with
  permission-aware actions;
- cached/offline indicators.

Drift schema version 5 adds `local_milk_entries`. Successful reads and writes
update the authorized local projection. When a create request fails because
the network is unavailable or transiently failing, the client atomically
stores pending local rows and the exact bulk command in the outbox, preserving
its UUIDs and idempotency key. The existing retry policy replays that command.
Authorized sync pulls upsert current revisions; lost permission or farm access
conceals local milk rows. Corrections intentionally remain online-only.

## Files created

- Laravel milk models, controller, requests, resource, migrations, seeder, and
  feature regression test under `apps/api`
- Flutter milk models, repository, providers, screen, and repository/widget
  tests under `apps/mobile`
- `docs/DAILY_MILK_PRODUCTION.md`
- `docs/PHASE_3A_COMPLETION.md`

## Files modified

- Laravel routes, permission catalog, sync controller, database seeder, and
  OpenAPI contract
- Flutter router, shell navigation, Drift database/generated schema, sync
  service, and migration regression tests
- Root and application READMEs, architecture documents, API/testing plans, and
  `task.md`

## Validation performed

Backend:

- MySQL 8.4.9 `migrate:fresh --seed`: passed
- MySQL full suite: 89 tests, 913 assertions, no skips
- SQLite portability suite: 89 discovered, 81 passed, 791 assertions, eight
  MySQL-only process-concurrency tests skipped
- Focused daily milk suite: 7 tests, 61 assertions
- Phase 3A rollback/reapply: passed
- Pint format and check: passed
- PHP syntax: 210 files passed
- Composer validation: passed
- Composer audit: no security advisories
- Laravel/OpenAPI parity: exactly 79 operations on both sides
- Redocly lint: valid with 22 existing recommendation warnings
- Redocly bundle/reference resolution: passed

Flutter:

- Dart format: 110 files, no changes required
- Flutter analysis: no issues
- Full suite: 86 tests passed
- Focused milk/repository/migration suite: 7 tests passed
- Android debug APK build: passed
- Release web build and WebAssembly dry run: passed

Repository:

- reserved Windows filename scan: passed
- tracked/unignored secret and generated-artifact scan: passed
- UTF-8 validation: passed
- local Markdown-link validation: passed
- trailing-whitespace/diff validation: passed
- later-phase application-path scan: passed
- generated APK ignore check: passed; no APK is tracked

No manual browser, emulator, physical-device, production deployment, or hosted
CI result is claimed for this phase.

## Known limitations

- Milk corrections require connectivity.
- Offline create replay depends on a later successful sync attempt.
- Phase 3A does not include milk sales, customer billing, quality-lab workflow,
  pricing, collection-center dispatch, bulk tank reconciliation, or advanced
  lactation analytics.
- Concurrent duplicate protection is implemented by MySQL constraints and
  idempotency; a dedicated separate-process duplicate-milk race test remains a
  possible hardening addition.
- The OpenAPI file is valid but retains 22 non-blocking recommendation warnings,
  mostly older operations without an explicit 4xx response.
- A manual responsive browser/device smoke test remains appropriate before a
  release candidate.

## Remaining controlled work

Stop after Phase 3A. Do not start breeding, health, finance, payroll, or
employee loans without a separately approved phase. The approved future
finance direction is PKR-only with no visible cash/bank/wallet setup. Monthly
payroll and employee loans with automatic payroll-installment recovery belong
to controlled Phase 7 subphases so their postings use the double-entry ledger.
