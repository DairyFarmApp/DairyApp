# Testing and Quality Commands

## Flutter

```powershell
C:\flutter\bin\flutter.bat pub get
C:\flutter\bin\cache\dart-sdk\bin\dart.exe run build_runner build
C:\flutter\bin\cache\dart-sdk\bin\dart.exe format lib test --output=none --set-exit-if-changed
C:\flutter\bin\flutter.bat analyze
C:\flutter\bin\flutter.bat test --concurrency=1
C:\flutter\bin\flutter.bat build apk --debug --dart-define=APP_ENV=development --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

Owner onboarding, inventory, daily milk, workforce/finance, theme, and
Phase 2C/UX stabilization have automated Flutter coverage. In addition to
foundation/registry/movement coverage, they test weight/status serialization,
decimal-string payloads, online idempotent commands, offline cached histories,
immutable correction projections, status changes without outbox writes,
validated responsive forms/tables, incremental loading, permission-aware
controls, Drift schema-3-to-4 migration, sync upserts, farm/permission removal,
the version-matched Drift browser runtime assets, inventory repositories and
responsive screens, permission-aware inventory navigation, persistent
System/White/Dark appearance selection, and safe user-facing provider errors.
Inventory coverage also exercises metadata edits, versioned archive requests,
single/combined binary exports, selected UUID/date serialization, calendar
pickers, and responsive row actions.
Daily milk coverage exercises real summary parsing, idempotent bulk payloads,
atomic offline row/outbox storage, Drift schema migration, calendar selection,
responsive quick entry, and overflow protection.
Phase 7A coverage exercises employees, monthly PKR salaries, immutable employee
loans, automatic payroll recovery, draft/approved/paid payroll transitions,
balanced double-entry journals, idempotent income/expense posting, tenant/farm
concealment, responsive menu/screens, and permission-aware actions.

The Android debug APK and release web client were built successfully. The APK
contains the expected application ID, `INTERNET`, and network-state permissions.
Drift/system SQLite, Flutter Secure Storage, Connectivity Plus, Dio, and
compile-time environment values all compiled successfully. Manual Chrome smoke
tests at desktop and phone widths cover the polished login, context selection,
real-data dashboard, animal registry/profile, responsive navigation, all three
inventory areas, live medicine creation, and the three appearance choices with
no browser warnings or errors. A physical device is not required at this
checkpoint.

## Laravel

```powershell
php vendor/bin/pint --test
php artisan test
php artisan route:list --path=api/v1 --except-vendor
```

## OpenAPI

```powershell
npx --yes @redocly/cli@1.34.17 lint openapi.yaml --format=stylish
# Optional reference-resolution check without creating an output file:
npx --yes @redocly/cli@1.34.17 bundle openapi.yaml | Out-Null
```

On PowerShell, use `Out-Null` to discard command output. Do not use `--output NUL`: Redocly appends a YAML extension and creates the invalid Windows reserved-name artifact `NUL.yaml`.

The MySQL suite has 95 passing tests with 1,021 assertions. The SQLite
portability run discovers the same 95 tests, passes 87 with 899 assertions, and
skips eight MySQL process-concurrency tests. In addition to owner/family and
inventory coverage, daily milk regression proves authentication and
permissions, cross-organization/farm concealment, animal eligibility, exact
decimal/rejection validation, idempotent bulk creation, immutable correction
revisions, audit events, real daily summaries, sync output, atomic offline
outbox writes, and authorized sync pull upserts.
Workforce/finance regression additionally proves exact PKR validation, employee
version protection, loan immutability, payroll state enforcement, automatic
installments, balanced journals, idempotency, audit events, and confidential
cross-organization/farm concealment.

## Database validation status

SQLite remains a portability/fast-test gate, not a substitute for MySQL.

Official MySQL 8.4.9 passed the Phase 7A fresh migration/seed, full suite,
schema/foreign-key assertions, and separate-process
renewal/idempotency/animal-number/movement-approval/weight-correction/status
races. Current Phase 7A evidence is in `docs/PHASE_7A_COMPLETION.md`.

## Continuous integration

`.github/workflows/quality.yml` is internally structured for a clean Linux runner. It installs required PHP extensions, caches Composer downloads, creates the environment/key, runs SQLite tests, starts MySQL 8.4, performs fresh migration/rollback/migration/seed, reruns the complete suite against MySQL, audits Composer dependencies, runs Dart generation/format/analyze/tests, and builds Android plus web. The YAML was parsed locally; no hosted run is claimed by this validation.
