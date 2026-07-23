# Phase 1 Sync Foundation

The client caches only organizations, farms, and sheds. Drift also stores non-secret session metadata, device identity, opaque cursors, an outbox, conflicts, and application settings.

Offline farm/shed creation writes the local row and outbox entry in one transaction with UUIDv7 aggregate/operation identifiers and a durable idempotency key. States are `pending`, `uploading`, `synced`, `failed`, and `conflict`. Processing is restricted to the authenticated active organization and waits for unsynchronized aggregate dependencies. Network failures plus HTTP 408/425/429/5xx use exponential backoff with full jitter. Validation/auth/authorization failures stop without looping; 409/412 creates a conflict record. Only stable error codes are persisted locally.

Uploads call ordinary domain endpoints so backend validation, permissions, audit, and idempotency remain authoritative. The client marks an operation synced only after server confirmation. Bootstrap and incremental endpoints return authorized organization/farm/shed snapshots, `authorized_farm_ids`, and tombstones with an opaque versioned cursor. The server deliberately overlaps the cursor watermark by two seconds and the client upserts repeated rows, preventing same-timestamp gaps. A page and cursor are committed in one Drift transaction; cached farms removed from the authorized set are marked unavailable.

Phase 1 intentionally excludes product transactions, attachments, background scheduling, and full conflict resolution. The diagnostic conflict list is read-only.
