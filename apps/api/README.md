# DairyCare API

Laravel 13.21.1 / PHP 8.5 REST API for the Phase 1 foundation, Phase 2A animal registry, Phase 2B online animal movements, and Phase 2C animal weights/status history. MySQL 8.4 is the authoritative integration database; the fast portability suite also uses isolated in-memory SQLite.

## Setup

```powershell
Copy-Item .env.example .env
php artisan key:generate
# Set local DB_* values without committing secrets, then:
php artisan migrate
php artisan serve
```

The verified workstation configuration uses `dairycare_dev`, `dairycare_test`, and `dairycare_app@127.0.0.1` through local-only service `MySQL84`. Development seed data is opt-in and repeatable. Set `DAIRYCARE_SEED_PASSWORD` to a local-only password of at least 12 characters before `php artisan db:seed`; never reuse it in production.

## Security model

The API issues short-lived opaque access tokens and rotating renewal credentials. A token is `<session UUIDv7>.<random secret>`; only SHA-256 secret hashes and renewal-consumption history are stored. Rotation rechecks under a row lock. Reusing a consumed credential revokes that session family and writes a safe audit event. Sessions bind active organization/farm context and support listing/revocation. Tenant, permission, scoped-query, and composite-database constraints enforce access; client permissions and context headers are never trusted.

## Quality

```powershell
php artisan test
php artisan route:list --path=api/v1 --except-vendor
php artisan migrate --force
php vendor/bin/pint --test
```

Phase 2C passes 67 MySQL tests with 677 assertions, including separate-process renewal, idempotency, animal-number, movement-approval, weight-correction, and status-change concurrency. The SQLite run discovers 67 tests, passes 59 with 555 assertions, and skips only eight MySQL-specific concurrency cases. Composer validation and audit pass with no advisories.

Animal-registry behavior is documented in [`docs/ANIMAL_REGISTRY.md`](../../docs/ANIMAL_REGISTRY.md). Movement behavior is documented in [`docs/ANIMAL_MOVEMENTS.md`](../../docs/ANIMAL_MOVEMENTS.md). Exact weight storage/correction, status history, permissions, audit, and read caching are documented in [`docs/ANIMAL_WEIGHTS_AND_STATUS.md`](../../docs/ANIMAL_WEIGHTS_AND_STATUS.md).

API contract: [`openapi.yaml`](openapi.yaml).
