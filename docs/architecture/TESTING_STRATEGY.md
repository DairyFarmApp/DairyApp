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

## Phase 2B executed evidence

- MySQL 8.4.9: 56 tests, 501 assertions, including transactional movement rules, composite foreign keys, audit/idempotency, tenant and both-farm concealment, stale-source behavior, and a separate-process concurrent approval test.
- SQLite portability: 56 discovered, 50 passed, 409 assertions, 6 MySQL-only concurrency tests skipped.
- Flutter: 46 unit/repository/Drift/sync/widget tests covering movement models, online mutations, typed errors, cached reads, history states, request validation, dependent destinations, permissions/separation of duties, responsive cards/table, status upserts, and revoked farm access.
- PHP syntax, Pint, Composer validation/audit, Redocly lint/bundle, Dart format, Flutter analysis, and Android debug build passed.

The full evidence and known limitations are in `docs/PHASE_2B_COMPLETION.md`.

## Phase 2C executed evidence

- MySQL 8.4.9: 67 tests, 677 assertions, including exact decimal/unit rules, immutable correction/status workflows, composite constraints, authorization/concealment, idempotency/audit/sync, and separate-process correction/status races.
- SQLite portability: 67 discovered, 59 passed, 555 assertions, 8 MySQL-only concurrency tests skipped.
- Flutter: 62 unit/repository/Drift/sync/widget tests covering decimal models, online commands, offline cached histories, projections, responsive forms/history, incremental loading, permissions, migration, sync upserts, and revoked access.
- PHP syntax, Pint, Composer validation/audit, Redocly lint/bundle and 52-operation parity, Dart generation/format, Flutter analysis, and Android debug build passed.

The full evidence and known limitations are in `docs/PHASE_2C_COMPLETION.md`.

## Owner onboarding and family-access evidence

- MySQL 8: 74 tests and 760 assertions, including reusable invitations,
  multiple family signups, token-at-rest checks, link disable/rotation,
  primary-owner-only management, immediate session revocation, restoration,
  cross-farm concealment, profile/password protection, and private photo
  storage.
- SQLite portability: 66 passed with 638 assertions; the same eight
  process-concurrency tests remain MySQL-only.
- Flutter: 71 tests covering owner/family signup validation and routing,
  account repositories, profile UI, reusable-link language, removal controls,
  membership-aware navigation, and all prior product regressions.
- MySQL fresh migration/seed, Pint, PHP syntax, Composer validation/audit,
  67-operation OpenAPI parity, Redocly lint/bundle, Dart format, Flutter
  analysis, release web build, and Android debug build passed.

Full evidence is in `docs/OWNER_ONBOARDING_COMPLETION.md`.

## Inventory core and glass appearance executed evidence

- MySQL 8.4.9: 79 tests, 808 assertions, including stock-ledger creation,
  idempotent receipt replay, protected metadata updates, stale-version
  rejection, permission denial, and cross-farm concealment.
- SQLite portability: 79 discovered, 71 passed, 686 assertions, with the eight
  existing process-concurrency tests skipped.
- Flutter: 78 tests covering inventory transport, responsive screens, local
  decimal/date/order validation, permission-aware navigation, and persistent
  System/White/Dark choices.
- MySQL fresh migration/seed, PHP syntax for 180 files, Pint, Composer
  validation/audit, 73-operation OpenAPI parity, Redocly lint/bundle, Flutter
  analysis, Android debug, release web, and manual browser QA passed.

Full evidence is in `docs/INVENTORY_GLASS_THEME_COMPLETION.md`.

## Phase 3A daily milk executed evidence

- MySQL 8.4.9: 89 tests and 913 assertions, including eligible-animal
  enforcement, scoped authorization/concealment, exact quantity validation,
  idempotent bulk recording, immutable correction revisions, audit, sync, and
  all existing separate-process concurrency regressions.
- SQLite portability: 89 discovered, 81 passed, 791 assertions, with the eight
  MySQL-only process-concurrency tests skipped.
- Flutter: 86 unit/repository/Drift/sync/widget tests, including daily-summary
  transport, online idempotency, atomic offline row/outbox persistence,
  authorized sync pull, schema-4-to-5 migration, responsive quick entry,
  calendar selection, and overflow protection.
- PHP syntax for 210 files, Pint, Composer validation/audit, exact 79-operation
  OpenAPI parity, Redocly lint/bundle, Dart format, Flutter analysis, Android
  debug, and release web builds passed.

Full evidence and limitations are in `docs/PHASE_3A_COMPLETION.md`.

## Phase 7A workforce and PKR finance executed evidence

- MySQL 8.4.9: 95 tests and 1,021 assertions, including exact PKR amounts,
  employee optimistic versions, immutable loans, payroll state transitions,
  automatic loan recovery, balanced double-entry journals, idempotency, audit,
  permissions, and tenant/farm concealment.
- SQLite portability: 95 discovered, 87 passed, 899 assertions, with the eight
  MySQL-only process-concurrency tests skipped.
- Focused workforce/finance suite: 6 tests and 108 assertions on both MySQL and
  SQLite.
- Flutter: 92 tests, including repository transport, responsive Employees,
  Salary, Loans, and Finance screens, calendar selection, PKR presentation,
  permission-aware actions, and permanent navigation at wide and compact
  widths.
- PHP syntax for 237 files, Pint, Composer validation/audit, exact
  97-operation OpenAPI parity, Redocly lint/bundle, Dart format, Flutter
  analysis, Android debug, release web, and WebAssembly dry-run builds passed.

Full evidence and limitations are in `docs/PHASE_7A_COMPLETION.md`.
