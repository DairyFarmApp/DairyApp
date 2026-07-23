# DairyCare API

Laravel 13.21.1 / PHP 8.5 REST API for the Phase 1 foundation, Phase 2A animal registry, and Phase 2B online animal movements. MySQL 8.4 is the authoritative integration database; the fast portability suite also uses isolated in-memory SQLite.

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

Phase 2B passes 56 MySQL tests with 501 assertions, including separate-process renewal, idempotency, animal-number and movement-approval concurrency, and opaque-session policy regression coverage. The SQLite run discovers 56 tests, passes 50 with 409 assertions, and skips only six MySQL-specific concurrency cases. Composer validation and audit pass with no advisories or abandoned packages.

Animal-registry behavior is documented in [`docs/ANIMAL_REGISTRY.md`](../../docs/ANIMAL_REGISTRY.md). Movement locking, approval, permissions, audit, sync cache, and exclusions are documented in [`docs/ANIMAL_MOVEMENTS.md`](../../docs/ANIMAL_MOVEMENTS.md).

API contract: [`openapi.yaml`](openapi.yaml).
