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

Owner onboarding, inventory, theme, and Phase 2C/UX stabilization have 80
passing Flutter tests. In addition to
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

The MySQL suite has 82 passing tests with 852 assertions. The SQLite portability
run discovers the same 82 tests, passes 74 with 730 assertions, and skips eight
MySQL process-concurrency tests. In addition to owner/family coverage, the
inventory regression proves authentication and permissions, cross-farm
concealment, ledger-backed opening stock, idempotent receipts, protected stock
fields, row-locked stale-version rejection, low/expiry summaries, safe archival,
binary export authorization/isolation, date filtering, and audit events.

## Database validation status

SQLite remains a portability/fast-test gate, not a substitute for MySQL.

Official MySQL 8.4.9 passed the inventory-core fresh migration/seed, full suite,
schema/foreign-key assertions, and separate-process
renewal/idempotency/animal-number/movement-approval/weight-correction/status
races. Current inventory/theme evidence is in
`docs/INVENTORY_GLASS_THEME_COMPLETION.md`.

## Continuous integration

`.github/workflows/quality.yml` is internally structured for a clean Linux runner. It installs required PHP extensions, caches Composer downloads, creates the environment/key, runs SQLite tests, starts MySQL 8.4, performs fresh migration/rollback/migration/seed, reruns the complete suite against MySQL, audits Composer dependencies, runs Dart generation/format/analyze/tests, and builds Android plus web. The YAML was parsed locally; no hosted run is claimed by this validation.
