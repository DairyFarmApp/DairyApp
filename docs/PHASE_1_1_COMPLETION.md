# Phase 1.1 Foundation Hardening Completion Record

Historical note: this record describes the state at Phase 1.1 completion. Its outstanding MySQL gate was completed successfully in `docs/PHASE_1_2_MYSQL_VALIDATION.md`.

Date: 2026-07-22. Scope: Phase 1 foundation hardening and platform validation only. Phase 2 was not started.

## Repository discrepancies corrected

- Renewal reuse previously returned 401 without detection, family revocation, or security audit; credential verification also occurred before the row lock.
- Login requests during a lock extended the lock indefinitely.
- Idempotency checked for an existing key before its transaction and hashed JSON in request-key order.
- Audit redaction covered only five exact key names.
- Tenant endpoint tests omitted sheds, spoofed context headers, inactive/revoked memberships, and database-level cross-organization assignments.
- Drift selected outbox rows across organizations, retried terminal errors, ignored dependency identifiers, did not persist conflict responses, and stored raw exception strings.
- Cursor/tombstone and cache-access reconciliation lacked explicit tests.
- One migration created five unrelated foundation groups.
- Android release-capable manifests lacked `INTERNET` permission.
- CI lacked Composer caching, MySQL test execution, rollback validation, and an Android build.
- The Phase 0 repository-baseline wording remained current-tense after initialization.

## MySQL validation status

PHP has `mysqli` and `pdo_mysql`, but this workstation has no MySQL installation/service/client, Docker/Podman runtime, approved remote connection, or listener on port 3306. Per the assignment, no infrastructure was installed or configured.

Therefore the following MySQL-specific results are **unperformed**, not passed:

- MySQL `migrate:fresh`, rollback, migration, and seed.
- Complete backend suite on MySQL.
- `information_schema` verification of foreign keys, unique constraints, indexes, UUID column types, and JSON types.
- Actual MySQL concurrent renewal locking and idempotency races.
- MySQL tenant-isolation test execution.

The exact setup and commands required are documented in `docs/ENVIRONMENT_SETUP.md`. CI is configured to perform this work against official MySQL 8.4, but no hosted CI run exists.

## Migration changes

The deleted `2026_07_22_000100_create_foundation_tables.php` was replaced before production data exists by:

1. `2026_07_22_000100_create_tenancy_tables.php`
2. `2026_07_22_000110_create_access_control_tables.php`
3. `2026_07_22_000120_create_authentication_tables.php`
4. `2026_07_22_000130_create_governance_tables.php`
5. `2026_07_22_000140_create_synchronization_tables.php`

The authentication group adds `api_session_renewal_tokens`, containing hashes only. Composite foreign keys enforce same-organization shed/farm, membership/role, membership/farm, and session context links. A disposable SQLite database passed fresh migration, seed, full rollback, migration, and seed after the split; that is portability evidence, not MySQL evidence.

## Session and login hardening

- Raw access and renewal secrets are never stored; current and historical renewal values are SHA-256 hashes.
- Renewal locks the session row and rechecks the credential under the lock.
- The current renewal hash is consumed before rotation.
- Reusing any consumed credential revokes the session family, timestamps the incident, and atomically audits `auth.renewal_reuse_detected`.
- Logout/session revocation invalidates access and renewal use immediately.
- User disable and password change revoke every active session.
- Server-side access and renewal expiry are tested.
- Login uses 10 attempts/minute per normalized identity and 30/minute per IP.
- Five failures inside a 15-minute counter window create a five-minute lock; locked requests do not extend it; expiry/success resets state.
- Generic authentication errors are retained.

The deterministic stale-credential test proves that only the first rotation succeeds and a subsequent contender revokes the family. An actual simultaneous two-connection race remains part of the pending MySQL run.

## Tenant, idempotency, audit, and sync hardening

- Session organization/farm context remains the only authority; spoof headers are ignored.
- Explicit scoped UUID lookup consistently conceals inaccessible organization/farm/shed resources as 404; invalid switches and invalid membership return 403.
- Inactive/revoked memberships immediately lose tenant access.
- Idempotency acquisition uses a unique insert inside the domain transaction, locks a competing record, and recursively canonicalizes object keys.
- Audit redaction recursively covers password, token, credential, authorization, cookie, API/private key, and reset-code variants.
- Drift processes only active-organization operations, waits on dependencies, retries only network/408/425/429/5xx failures, stops terminal failures, creates conflicts for 409/412, and stores stable safe codes.
- Sync returns authorized farm IDs, reconciles removed access, applies archive tombstones, and uses a versioned two-second-overlap cursor with transactional upserts/cursor advancement.

## Android result

`flutter build apk --debug` completed successfully after the initial Gradle dependency-resolution run warmed the cache. Artifact: `apps/mobile/build/app/outputs/flutter-apk/app-debug.apk` (158,342,541 bytes at validation). APK inspection confirmed application ID `com.dairycare.dairycare_mobile`, `android.permission.INTERNET`, and `android.permission.ACCESS_NETWORK_STATE`.

Environment: Android SDK/platform/build-tools 36.1, Android Studio bundled OpenJDK 21.0.10, accepted licenses. Drift/system SQLite, Flutter Secure Storage, Connectivity Plus, Dio, and compile-time environment configuration compiled. No physical device test was required or performed.

## CI review

The clean-Linux workflow now has correct application working directories, PHP 8.5 with `mbstring`, `pdo_mysql`, and `pdo_sqlite`, Composer cache, dependency install, environment/key creation, Pint, SQLite tests, MySQL 8.4 health service, fresh migration/rollback/migration/seed, complete MySQL tests, Composer audit, Flutter setup/cache, code generation, format, analysis, tests, Android debug build, and web release build. Embedded database values are isolated CI test credentials, not production secrets.

The workflow YAML parses locally. It has not executed on GitHub because no remote repository exists.

## Local verification results

- Laravel Pint: passed.
- Laravel tests: 27 passed, 139 assertions.
- Registered API routes: 23, unchanged.
- SQLite fresh migration/seed/rollback/migration/seed: passed.
- Flutter code generation: passed.
- Dart format: passed.
- Flutter analysis: no issues.
- Flutter tests: 18 passed.
- Android debug APK: passed.
- APK manifest inspection: passed.
- OpenAPI and CI YAML parse: passed after final validation.
- Composer advisory audit: passed with zero advisories and zero abandoned packages.

## Files created

- Five grouped foundation migration files listed above.
- `app/Models/ApiSessionRenewalToken.php`.
- `tests/Feature/FoundationSchemaTest.php`.
- `apps/mobile/test/sync_service_test.dart`.
- `docs/PHASE_1_1_COMPLETION.md`.

## Principal files modified

- Laravel session/auth, login limiting, audit, idempotency, tenant relationships, sync controller, seed/test helpers, environment, and CI files.
- Flutter API error mapping, Drift due-query, sync service/tests, Android manifest/build configuration, and application READMEs.
- Root README, changelog, task record, implementation plan, authentication, tenancy, sync, testing, environment, API, database, security, offline-sync, and architecture status documents.

## Known limitations and readiness

- MySQL execution is the only assignment validation block that could not be performed locally.
- Hosted CI, physical-device behavior, production signing, HTTPS/secrets, backup restoration, and SQLite encryption threat modeling remain unverified.
- User/role/audit administration, background sync, and interactive conflict resolution remain outside Phase 1.1.

**Phase 2 readiness: conditional, not unconditional.** The source-level Phase 1.1 hardening and available local gates pass, but the explicitly required MySQL 8 migration/seed/full-suite/locking/constraint validation remains outstanding. Do not begin Phase 2 until that gate runs successfully or the project owner explicitly accepts the residual risk.
