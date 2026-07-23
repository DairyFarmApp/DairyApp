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

Phase 1.2 has 18 passing Flutter tests covering validation, routing, API error types, secure-session abstraction, permission-aware responsive navigation, atomic outbox writes, retry policy, organization-scoped processing, terminal/retryable/conflict outcomes, dependencies, access reconciliation, cursor continuation, and tombstones.

The Android debug APK was built and inspected. It contains the expected application ID, `INTERNET`, and network-state permissions. Drift/system SQLite, Flutter Secure Storage, Connectivity Plus, Dio, and compile-time environment values all compiled successfully. A physical device is not required at this checkpoint.

## Laravel

```powershell
php vendor/bin/pint --test
php artisan test
php artisan route:list --path=api/v1 --except-vendor
```

The MySQL suite has 31 passing tests with 204 assertions. The SQLite portability run has 27 passing tests with 146 assertions; four process-concurrency tests intentionally skip outside MySQL. Coverage includes token hashing/history, rotation/reuse/family revocation, logout, expiry, user/password revocation, login protection, tenant/farm/shed/settings isolation, spoofed context headers, inactive/revoked memberships, permissions, database tenant constraints, UUIDv7, native JSON, indexes, foreign keys, canonical/concurrent idempotency, audit redaction, sync scope, cursors, and archive tombstones.

## Database validation status

SQLite remains a portability/fast-test gate, not a substitute for MySQL.

Official MySQL 8.4.9 passed fresh migration, repeatable seed, rollback/remigration, fresh-over-data, migration status, the full suite, direct `information_schema` inspection, and separate-process renewal/idempotency races. The tests also directly prove composite tenant and duplicate-scope constraints. Full evidence is in `docs/PHASE_1_2_MYSQL_VALIDATION.md`.

## Continuous integration

`.github/workflows/quality.yml` is internally structured for a clean Linux runner. It installs required PHP extensions, caches Composer downloads, creates the environment/key, runs SQLite tests, starts MySQL 8.4, performs fresh migration/rollback/migration/seed, reruns the complete suite against MySQL, audits Composer dependencies, runs Dart generation/format/analyze/tests, and builds Android plus web. The YAML was parsed locally, but no hosted run can be claimed because the repository has no remote.
