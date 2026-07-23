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

Phase 2A has 33 passing Flutter tests. In addition to foundation coverage, they test animal serialization, protected update payloads, repository create/update/archive/restore, breed/group management, cached search/archive filters, add-form validation, immutable edit location, permission-aware actions, responsive cards/table, registry bootstrap/incremental data, archive tombstones, and farm-access removal.

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

The MySQL suite has 44 passing tests with 366 assertions. The SQLite portability run discovers the same 44 tests, passes 39 with 294 assertions, and skips five MySQL process-concurrency tests. Phase 2A coverage includes opaque-session policy integration, unauthenticated/unauthorized/tenant/farm denial, species/reference lifecycle, tenant/farm/classification constraints, numbering and identifier normalization/uniqueness, independent-process numbering concurrency, parentage, profile/location permissions, optimistic versions, idempotency, audit, search/filter/pagination, archive/restore, permission-filtered sync, tombstones, and physical database constraints.

## Database validation status

SQLite remains a portability/fast-test gate, not a substitute for MySQL.

Official MySQL 8.4.9 passed Phase 2A fresh migration/seed, rollback/remigration, repeatable seed, the full suite, direct `information_schema` inspection, and separate-process renewal/idempotency/animal-number races. Tests directly prove identifier uniqueness and composite tenant constraints. Phase 1.2 foundation evidence remains in `docs/PHASE_1_2_MYSQL_VALIDATION.md`; current evidence is in `docs/PHASE_2A_COMPLETION.md`.

## Continuous integration

`.github/workflows/quality.yml` is internally structured for a clean Linux runner. It installs required PHP extensions, caches Composer downloads, creates the environment/key, runs SQLite tests, starts MySQL 8.4, performs fresh migration/rollback/migration/seed, reruns the complete suite against MySQL, audits Composer dependencies, runs Dart generation/format/analyze/tests, and builds Android plus web. The YAML was parsed locally; no hosted run is claimed by this validation.
