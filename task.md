# Phase 2C Task Record

Status: Animal Weights and Operational-Status History implemented locally. Date: 2026-07-23. Validation and owner approval are required before any commit.

## Completed scope

- [x] Confirmed branch, upstream, clean preflight, committed/pushed Phase 2B baseline, and starting commit.
- [x] Read all required source-of-truth and existing implementation files.
- [x] Added tenant/farm-constrained `animal_weights` and `animal_status_changes` migrations without changing unrelated schema.
- [x] Added exact decimal kg/lb normalization, configured maximum, observation-time validation, and deterministic latest-weight projection.
- [x] Added immutable single-correction workflow with row locks, preserved source facts, supersession links, idempotency, and audit.
- [x] Moved post-registration status changes to a row-locked, versioned, reasoned append command with atomic animal projection.
- [x] Added five granular permissions with conservative seeded role defaults.
- [x] Added six tenant-aware API operations with pagination, resources, policies, Form Requests, and safe errors.
- [x] Added responsive Flutter weight/status forms, history, latest projection, and permission-aware controls using real APIs.
- [x] Added Drift schema version 4 read caches and authorized bootstrap/incremental synchronization.
- [x] Added backend and Flutter domain, cache, migration, permission, responsive, concurrency, sync, and schema tests.
- [x] Completed the final MySQL, SQLite, PHP, OpenAPI, Flutter, and Android validation matrix.
- [x] Completed the final repository hygiene matrix after documentation settled.
- [x] Updated the required Phase 2C design and API documentation.
- [x] Confirmed no Phase 2D or later-domain implementation was introduced.

## Excluded by design

- QR, photos, and combined timeline
- Offline animal/movement/weight/status/reference mutations and background upload
- Milk, breeding, pregnancy, calving, health, medicines, feed, inventory, sales, mortality, finance, payroll, equipment, AI, IoT, and reporting

## Next action

Stop after the completed Phase 2C validation and wait for owner approval. Do not commit or push.
