# API

The canonical machine-readable contract is `apps/api/openapi.yaml`. The base path is `/api/v1`; all responses include an `X-Request-ID` header and the configured envelope from `docs/architecture/API_CONVENTIONS.md`.

Farm and shed deletion endpoints archive with Laravel soft deletion and return an auditable `{archived: true}` response. Creation accepts optional client UUIDv7 identifiers and `Idempotency-Key`; identical committed retries replay the stored status/body, while different payload reuse returns `409 IDEMPOTENCY_KEY_REUSED`.

Cursor pagination is used for farm/shed lists. Sync cursors are opaque, versioned, and deliberately overlap the previous watermark so idempotent upserts cannot miss equal-timestamp changes. Sync responses include `authorized_farm_ids` so clients remove access to stale cached farms. Cross-tenant and unauthorized farm records are concealed as 404 where appropriate.

Phase 2A adds controlled species listing plus paginated breed, farm-group, and animal endpoints. Animals support bounded search by animal number/ear tag/RFID/name and allowlisted classification/location/status/archive filters and sorts. Create endpoints are idempotent; update/archive/restore requires `version` and returns `412 STALE_VERSION` on a lost update.

The normal animal edit route rejects farm, shed, and group changes. Initial registration validates them. Phase 2B owns later location transitions through six movement request/read/approve/reject/cancel operations. Movement creation and decisions are idempotent, decisions require optimistic `version`, and approval atomically changes the animal's current location. Both source and destination farm access are required; pending/rejected/cancelled records never change location.

Identifier, parentage, breed/species, tenant, and farm rules are documented in `docs/ANIMAL_REGISTRY.md`. Movement fields, approval configuration, safe conflicts, audit, and endpoint behavior are documented in `docs/ANIMAL_MOVEMENTS.md`. The current inventory is 46 API routes.
