# Testing Strategy

## Test pyramid

- Flutter unit tests: value objects, validators, use cases, permission evaluation, serialization, conflict/retry logic.
- Flutter Drift/repository tests: migrations, transactions, offline reads/writes, outbox ordering, tombstones, eviction protection, restart recovery.
- Flutter widget tests: responsive shell, forms, loading/empty/error/offline/conflict states, localization, accessibility semantics, permission-aware navigation.
- Laravel unit tests: domain rules and calculations.
- Laravel feature/API tests: validation, policies, tenant/farm isolation, idempotency, optimistic locking, transactions, response contracts, audit side effects.
- Integration tests: MySQL/Redis/storage/queue behavior using production-like services; OpenAPI contract compatibility.
- Critical end-to-end workflows follow the master specification, especially restricted milk, stock/ledger reversals, calving, and exactly-once observable offline milk creation.

## Mandatory cross-cutting suites

Every tenant-owned endpoint gets positive same-tenant and negative cross-tenant tests, including guessed UUIDs, nested relationships, exports, attachments, queue jobs, and sync. Every permission gets allowed/denied coverage. Important create commands test same-key replay and different-payload key reuse. Concurrent tests cover duplicate milk, negative stock, approval races, stale versions, and ledger balancing.

## Quality gates per phase

- Documentation: required files present, Markdown links and Mermaid syntax reviewed, contradiction/terminology scan, and scope check.
- Flutter once initialized: formatter check, `flutter analyze`, unit/widget/integration tests, Drift migration tests, and required platform builds.
- Laravel once initialized: Pint check, configured static analysis, PHPUnit/Pest suites, clean migrate/rollback/migrate and seeder verification, OpenAPI validation.
- Security: dependency and secret scans, authorization/tenant tests, upload abuse tests, and production configuration review.
- Performance: explain plans/index review and representative datasets; sync/page size, animal search, milk aggregation, and ledger reporting budgets established before release.

CI should run deterministic checks on every pull request and publish artifacts without secrets. Flaky tests are defects, not silently retried into acceptance. Builds/tests are reported only when executed.

## Phase 0 validation

No application tests/builds apply because no application exists and Phase 0 creates documentation only. Validation consists of repository inventory, required-file presence, content/search checks, and Git/diff checks where available.

## Phase 2A executed evidence

- MySQL 8.4.9: 44 tests, 366 assertions, including opaque-session policy regression, separate-process animal-number concurrency, and direct foreign-key/unique/composite-tenant failures.
- SQLite portability: 44 discovered, 39 passed, 294 assertions, 5 MySQL-only tests skipped.
- Flutter: 33 unit/repository/Drift/sync/widget tests covering serialization, protected edit payloads, idempotent online writes, local search/archive filters, management endpoints, form validation, permission controls, responsive cards/table, bootstrap/incremental tombstones, and access removal.
- PHP syntax, Pint, Composer validation/audit, Redocly OpenAPI validation, Dart format, Flutter analysis, and Android debug build passed.

The full evidence and known environmental gaps are in `docs/PHASE_2A_COMPLETION.md`.
