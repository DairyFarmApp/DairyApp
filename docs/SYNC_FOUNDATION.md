# Sync Foundation, Registry, and Movement Cache

The client caches organizations, farms, sheds, animal species, breeds, farm groups, animals, and authorized animal movements. Drift also stores non-secret session metadata, device identity, opaque cursors, an outbox, conflicts, and application settings.

Offline farm/shed creation writes the local row and outbox entry in one transaction with UUIDv7 aggregate/operation identifiers and a durable idempotency key. States are `pending`, `uploading`, `synced`, `failed`, and `conflict`. Processing is restricted to the authenticated active organization and waits for unsynchronized aggregate dependencies. Network failures plus HTTP 408/425/429/5xx use exponential backoff with full jitter. Validation/auth/authorization failures stop without looping; 409/412 creates a conflict record. Only stable error codes are persisted locally.

Uploads call ordinary domain endpoints so backend validation, permissions, audit, and idempotency remain authoritative. The client marks an operation synced only after server confirmation. Bootstrap and incremental endpoints return authorized foundation/registry/movement snapshots, `authorized_farm_ids`, and tombstones with an opaque versioned cursor. The server deliberately overlaps the cursor watermark by two seconds and the client upserts repeated rows, preventing same-timestamp gaps. A page and cursor are committed in one Drift transaction; cached farms removed from the authorized set are marked unavailable, and their groups/animals are excluded with `isAccessible = false`.

Phase 2B adds `local_animal_movements` in Drift schema version 3. Bootstrap and incremental pulls upsert movement status/version changes. Reads require `animal_movements.view` and access to both source and destination farms; permission or either farm-access removal marks cached movements inaccessible.

Registry and movement mutations are online-only and never enter the outbox. Offline animal create/edit/movement is reserved for separately approved Phase 2C. Attachments, background scheduling, and full conflict resolution also remain excluded; the diagnostic conflict list is read-only.
