# Phase 2B Completion Report

Date: 2026-07-23

Branch: `phase/2-animal-management`

Starting commit: `d97657e340aadeb5b93696ec51f1d44c33e9c29f`

## Completed scope

Phase 2B implements only the online animal movement workflow:

- One `animal_movements` migration with UUIDv7 identity, source/destination snapshots, decision state, approval-setting snapshot, optimistic version, indexes, and tenant/farm composite foreign keys.
- Transactional request, immediate application, approve, reject, and cancel actions with animal/movement row locks.
- Source snapshot, destination hierarchy, same-location, pending-conflict, stale-location, self-approval, organization, permission, and both-farm authorization rules.
- Five movement permissions and conservative seeded role defaults.
- Six request-ID/envelope API operations using Form Requests, policies, resources, tenant-aware queries, pagination, idempotency, optimistic locking, and safe errors.
- Five movement/location audit events.
- Responsive Flutter history and request form using real APIs.
- Drift schema version 3 authorized movement read cache with bootstrap, incremental status updates, transient offline reads, and both-farm access removal.

No ordinary update endpoint exists for approved movements. Corrections require a new corrective movement.

## Approval behavior

The `animal_movement_requires_approval` organization setting defaults and fails safe to enabled. Enabled requests stay pending and require another authorized user. Disabled approval applies through the same request/action/audit path, but only for an actor holding both request and approval authority. Requested time records the business request time; actual time records server application/approval time. Future scheduling is excluded.

## API and routes

Added:

- `GET /api/v1/animals/{animal}/movements`
- `POST /api/v1/animals/{animal}/movements`
- `GET /api/v1/animal-movements/{movement}`
- `POST /api/v1/animal-movements/{movement}/approve`
- `POST /api/v1/animal-movements/{movement}/reject`
- `POST /api/v1/animal-movements/{movement}/cancel`

The complete API inventory is 46 routes, all represented in `apps/api/openapi.yaml`.

## Validation evidence

Backend:

- PHP syntax: 131 application/route/database/test PHP files passed.
- Pint apply and `--test`: passed.
- MySQL 8.4.9 fresh migration and repeatable seed: passed.
- MySQL: 56/56 tests passed, 501 assertions.
- Dedicated MySQL concurrent movement approval: 1 test, 20 assertions; one approval applied the location once and the stale concurrent attempt failed safely.
- SQLite portability: 56 discovered, 50 passed, 409 assertions, 6 MySQL process-concurrency tests skipped.
- Composer strict validation: passed.
- Composer audit: no vulnerability advisories.
- Route inventory: 46 routes.
- Redocly 1.34.17 lint and reference bundle: valid; 20 existing recommended-rule warnings remain non-blocking.

Flutter:

- Dart format check: 63 files, no changes required after formatting.
- Flutter analyze: no issues.
- Flutter: 46/46 tests passed.
- Android debug APK: built successfully at the ignored `apps/mobile/build/app/outputs/flutter-apk/app-debug.apk`.

Repository gates:

- Reserved/invalid filename, tracked-secret, tracked-build-artifact, ignored-artifact, Markdown-link, UTF-8, trailing-whitespace, and later-phase scope checks were executed after implementation.
- `apps/api/NUL.yaml` is absent.
- No APK/build output, local environment credential, database, signing file, cache, vendor dependency, or IDE state is tracked.

## Tests added

Backend movement coverage includes request/pending/immediate behavior, approval/rejection/cancellation, unchanged pending location, atomic projection updates, source and destination validation, stale/duplicate/concurrent decisions, conflicting pending requests, organization/farm concealment, self-approval, permission denials, idempotent requests/decisions, audit events, search/list scope, sync bootstrap/incremental/access removal, schema/index metadata, and MySQL foreign-key enforcement.

Flutter movement coverage includes model/status serialization, repository request/decision/cache/error behavior, history states, form validation, dependent destination selection, permissions and separation of duties, cached display, mobile cards/tablet table, sync status updates, and revoked farm access.

## Files

New backend files:

- `apps/api/database/migrations/2026_07_23_000250_create_animal_movements_table.php`
- `apps/api/app/Domain/AnimalMovements/**`
- `apps/api/app/Http/Controllers/Api/V1/AnimalMovementController.php`
- `apps/api/app/Http/Requests/Api/V1/AnimalMovement*Request.php`
- `apps/api/app/Http/Resources/Api/V1/AnimalMovementResource.php`
- `apps/api/tests/Feature/AnimalMovementTest.php`
- `apps/api/tests/Feature/AnimalMovementSchemaTest.php`

New Flutter files:

- `apps/mobile/lib/features/animals/domain/animal_movement_models.dart`
- `apps/mobile/lib/features/animals/data/animal_movement_repository.dart`
- `apps/mobile/lib/features/animals/application/animal_movement_providers.dart`
- `apps/mobile/lib/features/animals/presentation/animal_movement_form_screen.dart`
- `apps/mobile/lib/features/animals/presentation/animal_movement_history_section.dart`
- `apps/mobile/test/animal_movement_models_test.dart`
- `apps/mobile/test/animal_movement_repository_test.dart`
- `apps/mobile/test/animal_movement_screens_test.dart`

Modified integration files include the animal model/policy, provider registration, exception mapping, routes, sync controller, development seeder, MySQL concurrency test, OpenAPI contract, Flutter router/detail/edit text, Drift schema/generated code, sync service/tests/fixtures, and Phase 2B documentation.

## Known limitations

- Movement mutations require network access; no movement outbox/conflict-resolution UI exists.
- Future-dated scheduled execution is prohibited; Phase 2B applies immediately or at approval.
- Approval configuration has no management UI; it is an organization setting managed administratively.
- There is no movement correction/edit endpoint, generic animal timeline, weight/status history, QR, or photo workflow.
- Cached movement history is intentionally hidden when movement permission or either farm grant is removed.
- Redocly continues to report 20 recommended-rule warnings that predate or are outside the movement contract; the contract validates and bundles.

## Recommended Phase 2C

After separate owner approval, scope Phase 2C only to explicitly approved offline animal registry/movement commands: durable UUIDv7 operations, dependency ordering, server idempotency, base-version/source-snapshot conflicts, authorized resolution UI, replay/restart tests, and bounded cache/data-volume behavior. Do not combine it with weights, status history, QR/photos, milk, breeding, health, inventory, finance, or other later modules.

No commit or push was performed. Stop after Phase 2B and wait for approval.
