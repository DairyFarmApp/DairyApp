# Changelog

## 2026-07-23 — Phase 1.2 MySQL validation gate

- Installed official Oracle MySQL Community Server 8.4.9 as the automatic, localhost-only `MySQL84` Windows service.
- Created isolated `dairycare_dev` and `dairycare_test` databases plus a least-privilege `dairycare_app@127.0.0.1` account without committing credentials.
- Passed final fresh migration, rollback/remigration, fresh-over-data, migration status, repeatable seed, and real HTTP foundation endpoint checks.
- Made the development foundation seeder safely repeatable.
- Added separate-process MySQL renewal and idempotency concurrency tests.
- Verified direct MySQL rejection of cross-tenant sheds, settings, farm grants, role grants, invalid session membership, duplicate pivots, and duplicate idempotency/settings scopes.
- Corrected settings tenant enforcement and nullable-scope uniqueness discovered by MySQL metadata inspection.
- Passed the 31-test MySQL suite with 204 assertions, SQLite portability suite, Pint, Composer validation/audit, 18 Flutter tests, analysis, formatting, and Android debug build.

No Phase 2 code was added.

## 2026-07-22 — Phase 1.1 foundation hardening

- Split the combined foundation migration into tenancy, access-control, authentication, governance, and synchronization migrations.
- Added database-enforced organization consistency for membership-role, membership-farm, shed-farm, and session context relationships.
- Added hashed renewal history, strict renewal-reuse detection, session-family revocation, serialized rotation, password-change revocation, and broader audit redaction.
- Changed login protection to per-identity and per-IP rate limits with a non-extendable five-minute account lock.
- Made idempotency acquisition transaction-safe and request fingerprints recursively canonical.
- Scoped Drift outbox processing by organization; separated terminal, conflict, and retryable failures; enforced dependencies; reconciled farm access; and tested cursors/tombstones.
- Added Android networking permission, passed the debug APK build, and hardened CI with Composer caching, MySQL tests, rollback, seed, and Android build steps.

MySQL execution was not possible locally because no server/runtime or approved connection is available. No Phase 2 code was added.

## 2026-07-22 — Phase 1 application foundation

- Initialized Git and the `apps/mobile` / `apps/api` monorepo layout.
- Added UTF-8/LF repository policy, scoped CI quality gates, and environment documentation.
- Added Flutter authenticated foundation, responsive navigation, Drift cache/outbox/conflicts, reference sync, and tests.
- Added Laravel 13 opaque sessions, tenancy/farm access, foundation RBAC, organization/farm/shed APIs, audit, idempotency, sync, migrations, realistic seed data, and tests.
- Added Phase 1 API/OpenAPI, dependency, authentication, tenancy, sync, and testing documentation.

No Phase 2 or later product modules were added.
