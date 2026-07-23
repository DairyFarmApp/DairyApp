# API Conventions

## General

- Base path `/api/v1`; HTTPS only outside local development; JSON UTF-8.
- Resource URLs use plural kebab-case nouns. Commands that represent controlled transitions use explicit subresources/actions, e.g. the implemented `POST /animals/{uuid}/movements` and `POST /animal-movements/{uuid}/approve`, or a future `/sales/{uuid}/confirm`.
- UUIDs are canonical strings. Timestamps are RFC 3339 UTC. Decimal quantities/money are JSON strings with unit/currency to avoid floating-point loss.
- Clients send `Accept: application/json`, `X-Request-ID` (or server creates one), and `Idempotency-Key` for offline/important commands. Implemented registry and movement decisions send integer `version` in the JSON body; stale writes return `412 STALE_VERSION`. A future header-based convention must not be mixed into those endpoints without a versioned contract change.

## Success envelope

```json
{
  "data": {"id": "...", "version": 3},
  "meta": {"request_id": "..."}
}
```

Collections add `meta.pagination`. Registry and movement-history lists use bounded page-number metadata (`current_page`, `last_page`, `page_size`, `total`); sync continues to use opaque cursors. Prefer cursor pagination for changing/high-volume data. Creation returns `201`; accepted background work `202`. Permanent deletion without a body may return `204`; archive operations use `DELETE` and return `200` with explicit committed archive state for confirmation.

## Error envelope

```json
{
  "error": {
    "code": "VALIDATION_FAILED",
    "message": "The request could not be processed.",
    "fields": {"quantity": [{"code": "must_be_positive", "message": "Quantity must be positive."}]},
    "details": {},
    "request_id": "..."
  }
}
```

Stable machine codes are uppercase snake case. `details` contains safe structured context, never traces/SQL. Use `400` malformed command, `401` unauthenticated, `403` forbidden, `404` absent or intentionally concealed cross-tenant resource, `409` conflict/idempotency/state transition, `412` stale version, `422` validation/business rule, `429` limited, and `5xx` server/transient failure.

## Query conventions

Allowlisted `filter[field]`, `sort=field,-field`, `include=...`, `fields[type]=...`, `page[size]`, and cursor parameters. Reject unknown/unauthorized expensive filters and cap page size. Search semantics and timezone-based date filters are documented per endpoint. Never allow arbitrary SQL-style field/operator input.

## Contract and lifecycle

Request classes validate shape; actions validate domain state; policies authorize; resources control output. OpenAPI is updated with every endpoint and used for contract tests. Additive compatible fields stay in v1; breaking semantic/schema changes require a new API version and published deprecation window. Never serialize Eloquent models directly.

Phase 2A adds species, breed, group, and animal endpoints; Phase 2B adds six movement operations, all documented in `apps/api/openapi.yaml`. Animal and movement-list search/filter/sort input is allowlisted and bounded. Cross-tenant or unauthorized-farm entity UUIDs use the established concealed 404 behavior. Movement state/source conflicts use stable `409` codes; stale decision versions use `412`.

## Sync conventions

`POST /api/v1/sync/operations` accepts bounded ordered/batched commands with individual results; `GET /api/v1/sync/changes?cursor=...` returns authorized changes/tombstones and next cursor. Partial batch responses must identify each operation without treating a failed dependent operation as successful. See `OFFLINE_SYNC_STRATEGY.md`.
