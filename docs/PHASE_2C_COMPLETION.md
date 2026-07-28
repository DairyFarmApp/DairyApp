# Phase 2C Completion Report

Date: 2026-07-23

Branch: `phase/2-animal-management`

Starting commit: `fa3f00886c19d02afc3430bc24e6068f59498765`

Commit/push: Not performed, as required.

## Completed scope

Phase 2C implements only online animal weights and operational-status history:

- `animal_weights` and `animal_status_histories` migrations with UUIDv7 identity, tenant/farm composite integrity, history indexes, and actor/timestamp fields.
- Exact decimal weight entry in `kg` or `lb`, canonical six-place kilograms, configurable organization/farm maximum, source, observation time, and deterministic latest projection.
- Immutable, reasoned, row-locked weight corrections that retain the original, create one linked replacement, and reject correction chains/races.
- Dedicated, reasoned, versioned operational-status changes that append history and atomically update the animal projection.
- Five granular permissions, conservative seeded role defaults, representative seed histories, three audit events, and safe conflict errors.
- Six request-ID/envelope API operations using Form Requests, policies, resources, tenant-aware queries, pagination, and idempotency.
- Responsive Flutter weight/status forms, latest-weight display, histories, permission controls, and online-only repository commands.
- Drift schema version 4 authorized read caches, migration from version 3, incremental correction/status upserts, and access-removal concealment.

No QR, photo, generic timeline, offline mutation/background upload, or later dairy domain was introduced.

## Business and integrity rules

Weight values are JSON decimal strings and are converted through integer millionths, never binary floating point. Pounds use exact factor `0.45359237`; conversion rounds to the nearest kilogram millionth. Values must be positive, not exceed `animal_weight_max_kg` after conversion, and cannot be observed more than five minutes in the future.

Corrections preserve the original observation farm, time, and source. The original and replacement remain in history; unique links and row locks permit only one correction. Latest weight excludes superseded rows and orders by observation time, creation time, then UUID.

Initial registration may set operational status. Ordinary animal profile update cannot change status after creation. The dedicated command requires a distinct status, non-future effective time, reason, and current animal version. The appended history row, projected status/version, and audit event commit atomically.

## API and routes

Added:

- `GET /api/v1/animals/{animal}/weights`
- `POST /api/v1/animals/{animal}/weights`
- `GET /api/v1/animal-weights/{weight}`
- `POST /api/v1/animal-weights/{weight}/correct`
- `GET /api/v1/animals/{animal}/status-history`
- `POST /api/v1/animals/{animal}/status-changes`

The complete API inventory is 52 Laravel routes and 52 matching OpenAPI operations.

## Validation evidence

Backend:

- PHP syntax: 173 application/configuration/database/route/test PHP files passed.
- Pint apply and `--test`: passed; Pint corrected import ordering in one new test.
- MySQL 8.4.9 fresh migration and seed: passed.
- MySQL second seed, full rollback, remigration, and two further repeat seeds: passed.
- MySQL: 67/67 tests passed, 677 assertions.
- SQLite portability: 67 discovered, 59 passed, 555 assertions, 8 MySQL process-concurrency tests skipped.
- Composer strict validation: passed.
- Composer audit: no vulnerability advisories.
- Route inventory/contract parity: 52 Laravel operations exactly match 52 OpenAPI operations.
- Redocly 1.34.17 lint and reference bundle: valid; 20 recommended-rule warnings remain non-blocking.

Flutter:

- Build Runner: completed and generated the Drift schema code.
- Dart format: 75 files checked, no changes required.
- Flutter analyze: no issues.
- Flutter: 62/62 tests passed.
- Android debug APK: built successfully at the ignored `apps/mobile/build/app/outputs/flutter-apk/app-debug.apk`.

Repository:

- Reserved/invalid filename, tracked-secret, tracked-build-artifact, ignored-artifact, Markdown-link, UTF-8, trailing-whitespace, and later-phase scope checks were executed after implementation.
- `apps/api/NUL.yaml` is absent.
- No APK/build output, local environment credential, database, signing file, cache, vendor dependency, or IDE state is tracked.

## Tests added

Backend coverage includes decimal-safe conversion/bounds, time/source/archive validation, pagination, latest projection, idempotency, audit, immutable correction linkage, ordinary-update protection, atomic versioned status changes, invalid/no-op/stale transitions, permission/tenant/current-and-historical-farm concealment, sync bootstrap/incremental/access removal, physical schema/index/composite-foreign-key enforcement, and independent MySQL correction/status races.

Flutter coverage includes weight/status model serialization, exact string payloads, online idempotent commands, cached offline reads, correction/status cache projections without outbox writes, responsive incrementally loaded history/forms, permission controls, schema-3-to-4 migration, sync upserts, and permission/farm-access removal.

## Files

New backend files:

- `apps/api/database/migrations/2026_07_23_000260_create_animal_weights_table.php`
- `apps/api/database/migrations/2026_07_23_000270_create_animal_status_histories_table.php`
- `apps/api/app/Domain/AnimalWeights/**`
- `apps/api/app/Domain/AnimalStatuses/**`
- `apps/api/app/Http/Controllers/Api/V1/AnimalWeightController.php`
- `apps/api/app/Http/Controllers/Api/V1/AnimalStatusController.php`
- `apps/api/app/Http/Requests/Api/V1/AnimalWeight*Request.php`
- `apps/api/app/Http/Requests/Api/V1/AnimalStatus*Request.php`
- `apps/api/app/Http/Resources/Api/V1/AnimalWeightResource.php`
- `apps/api/app/Http/Resources/Api/V1/AnimalStatusChangeResource.php`
- `apps/api/tests/Feature/AnimalWeightAndStatusTest.php`
- `apps/api/tests/Feature/AnimalWeightAndStatusSchemaTest.php`

New Flutter files:

- `apps/mobile/lib/features/animals/domain/animal_weight_models.dart`
- `apps/mobile/lib/features/animals/domain/animal_status_models.dart`
- `apps/mobile/lib/features/animals/data/animal_measurement_repository.dart`
- `apps/mobile/lib/features/animals/application/animal_measurement_providers.dart`
- `apps/mobile/lib/features/animals/presentation/animal_weight_form_screen.dart`
- `apps/mobile/lib/features/animals/presentation/animal_weight_history_section.dart`
- `apps/mobile/lib/features/animals/presentation/animal_status_change_form_screen.dart`
- `apps/mobile/lib/features/animals/presentation/animal_status_history_section.dart`
- `apps/mobile/test/animal_measurement_models_test.dart`
- `apps/mobile/test/animal_measurement_repository_test.dart`
- `apps/mobile/test/animal_measurement_screens_test.dart`
- `apps/mobile/test/app_database_migration_test.dart`

New documentation:

- `docs/ANIMAL_WEIGHTS_AND_STATUS.md`
- `docs/PHASE_2C_COMPLETION.md`

Modified integration files include the animal model/policy/query/request/resource, provider/exception registration, routes, sync controller, seeders, registry/movement/concurrency tests, OpenAPI contract, Flutter router/detail/edit/models/repositories, Drift schema/generated code, sync service/tests/fixtures, architecture documents, testing documents, implementation plan, changelog, and task record.

## Commands executed

Key final gates:

```powershell
php vendor/bin/pint
php vendor/bin/pint --test
php -l <173 project PHP files>
php artisan migrate:fresh --seed --force
php artisan db:seed --force
php artisan migrate:rollback --force
php artisan migrate --force
php artisan db:seed --force
php artisan test --colors=never
php artisan route:list --path=api/v1 --except-vendor
php composer.phar validate --strict --no-interaction
php composer.phar audit --locked --no-interaction
npx --yes @redocly/cli@1.34.17 lint openapi.yaml --format=stylish
npx --yes @redocly/cli@1.34.17 bundle openapi.yaml | Out-Null
dart run build_runner build
dart format lib test --output=none --set-exit-if-changed
flutter analyze
flutter test --concurrency=1
flutter build apk --debug --dart-define=APP_ENV=development --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

The first MySQL attempt incorrectly expanded the environment-variable reference while importing `.env.testing` manually and was rejected before any schema command ran. The final command inherited the existing user-scoped secret without printing it and passed. Two Composer launcher attempts did not run Composer because Composer/PHP were absent from PATH; the existing explicit PHP and `composer.phar` paths then passed.

## Known limitations

- Weight record/correction and status changes require network access; histories remain readable from authorized cache.
- A correction cannot itself be corrected and no history deletion/edit route exists.
- Weight maxima use the current organization/farm setting and do not snapshot setting provenance per row.
- A generic animal timeline, QR, photos, analytics, and lifecycle/death workflow remain unimplemented.
- Redocly reports 20 recommended-rule warnings inherited from the wider contract; lint and bundle pass.
- Physical-device behavior, production signing/HTTPS/secrets, hosted CI, performance/load testing, and backup restoration are later release gates.

## Deviations

- The requested central status-history concept is implemented with the exact table name `animal_status_histories`; API/domain objects use `AnimalStatusChange` because each row represents a transition command result.
- The supplied weight farm snapshot is mandatory and validated against the locked current animal location; the server remains authoritative for the stored farm.
- The task allowed an idempotency reference "where appropriate." No redundant idempotency column was added to immutable histories; the existing durable `idempotency_records` table stores the endpoint/action reference and replay result.
- No scope deviation or later-domain implementation was made.

## Recommended Phase 2D scope

If separately approved, make Phase 2D **Animal QR Identification only**:

- generate a non-secret QR payload referencing the animal UUID plus a versioned application namespace;
- provide authorized label preview/print data and Flutter scan-to-profile lookup;
- validate organization/farm access after every scan and conceal unauthorized identifiers;
- cache only the identifier-to-animal mapping needed for offline lookup of already authorized animals;
- add duplicate/invalid/tampered payload, permission, revocation, responsive UI, camera-denial, and Android-device tests.

Keep photos, generic timeline, offline animal mutation, lifecycle/death, body-condition scoring, milk, breeding, health, inventory, finance, and all other later domains excluded.

## Remaining work

Stop after Phase 2C and wait for explicit owner approval. Do not start Phase 2D, commit, push, merge, rebase, or rewrite history.
