# Phase 1 API

The canonical machine-readable contract is `apps/api/openapi.yaml`. The base path is `/api/v1`; all responses include an `X-Request-ID` header and the configured envelope from `docs/architecture/API_CONVENTIONS.md`.

Farm and shed deletion endpoints archive with Laravel soft deletion and return an auditable `{archived: true}` response. Creation accepts optional client UUIDv7 identifiers and `Idempotency-Key`; identical committed retries replay the stored status/body, while different payload reuse returns `409 IDEMPOTENCY_KEY_REUSED`.

Cursor pagination is used for farm/shed lists. Sync cursors are opaque, versioned, and deliberately overlap the previous watermark so idempotent upserts cannot miss equal-timestamp changes. Sync responses include `authorized_farm_ids` so clients remove access to stale cached farms. Cross-tenant and unauthorized farm records are concealed as 404 where appropriate.
