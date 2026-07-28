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

Phase 2C has 62 passing Flutter tests. In addition to foundation/registry/movement coverage, they test weight/status serialization, decimal-string payloads, online idempotent commands, offline cached histories, immutable correction projections, status changes without outbox writes, validated responsive forms/tables, incremental loading, permission-aware controls, Drift schema-3-to-4 migration, sync upserts, and farm/permission removal.

The Android debug APK was built and inspected. It contains the expected application ID, `INTERNET`, and network-state permissions. Drift/system SQLite, Flutter Secure Storage, Connectivity Plus, Dio, and compile-time environment values all compiled successfully. A physical device is not required at this checkpoint.

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

The MySQL suite has 67 passing tests with 677 assertions. The SQLite portability run discovers the same 67 tests, passes 59 with 555 assertions, and skips eight MySQL process-concurrency tests. Phase 2C adds exact conversion/bounds, observation/source/archive rules, latest projection, immutable correction, dedicated atomic status change, ordinary-edit protection, permissions/tenant/historical-farm concealment, idempotency/audit, weight/status sync, physical constraints, and concurrent MySQL correction/status behavior to the complete foundation/registry/movement regression suite.

## Database validation status

SQLite remains a portability/fast-test gate, not a substitute for MySQL.

Official MySQL 8.4.9 passed the Phase 2C fresh migration/seed, full suite, schema/foreign-key assertions, and separate-process renewal/idempotency/animal-number/movement-approval/weight-correction/status-change races. Concurrent corrections create one replacement without loops; concurrent status commands create one history row and one valid projection. Phase 1.2 foundation evidence remains in `docs/PHASE_1_2_MYSQL_VALIDATION.md`; current evidence is in `docs/PHASE_2C_COMPLETION.md`.

## Continuous integration

`.github/workflows/quality.yml` is internally structured for a clean Linux runner. It installs required PHP extensions, caches Composer downloads, creates the environment/key, runs SQLite tests, starts MySQL 8.4, performs fresh migration/rollback/migration/seed, reruns the complete suite against MySQL, audits Composer dependencies, runs Dart generation/format/analyze/tests, and builds Android plus web. The YAML was parsed locally; no hosted run is claimed by this validation.
