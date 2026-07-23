# API

The canonical machine-readable contract is `apps/api/openapi.yaml`. The base path is `/api/v1`; all responses include an `X-Request-ID` header and the configured envelope from `docs/architecture/API_CONVENTIONS.md`.

Farm and shed deletion endpoints archive with Laravel soft deletion and return an auditable `{archived: true}` response. Creation accepts optional client UUIDv7 identifiers and `Idempotency-Key`; identical committed retries replay the stored status/body, while different payload reuse returns `409 IDEMPOTENCY_KEY_REUSED`.

Cursor pagination is used for farm/shed lists. Sync cursors are opaque, versioned, and deliberately overlap the previous watermark so idempotent upserts cannot miss equal-timestamp changes. Sync responses include `authorized_farm_ids` so clients remove access to stale cached farms. Cross-tenant and unauthorized farm records are concealed as 404 where appropriate.

Phase 2A adds controlled species listing plus paginated breed, farm-group, and animal endpoints. Animals support bounded search by animal number/ear tag/RFID/name and allowlisted classification/location/status/archive filters and sorts. Create endpoints are idempotent; update/archive/restore requires `version` and returns `412 STALE_VERSION` on a lost update.

The normal animal edit route rejects farm, shed, and group changes. Initial registration validates them, while later location transitions are reserved for the Phase 2B movement workflow. Identifier, parentage, breed/species, tenant, and farm rules are documented in `docs/ANIMAL_REGISTRY.md`.
