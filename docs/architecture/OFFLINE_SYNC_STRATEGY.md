# Offline Sync Strategy

## Scope and authority

Offline support is selective. Phase 1 establishes infrastructure; each later feature explicitly declares read cache, offline create/update, and attachment behavior. Server validation, authorization, canonical totals, and workflow state remain authoritative. Connectivity status is only a hint; actual request success determines online state.

Phase 2A explicitly adds read caching—but not offline mutation—for animal species, breeds, farm groups, and animals. Phase 2B adds authorized movement-history read caching and status updates, while movement requests and decisions remain online-only.

## Local Drift model

- Cached domain tables contain UUID, organization/farm scope, server version, server timestamps, cache timestamp, and tombstone marker.
- `sync_outbox`: operation UUID, idempotency key, aggregate type/UUID, command type, dependency UUIDs, canonical payload, base version, actor/device, local timestamp, state, attempts, `next_attempt_at`, and safe error summary.
- `sync_conflicts`: local operation/payload, server snapshot/version, reason, resolution state/actor/time.
- `sync_cursors`: organization + collection cursor and last successful pull.
- `attachment_queue`: local path/checksum/MIME/size, parent UUID, upload session/status.
- Secure storage holds tokens/device secret only; local business data stays in SQLite. Database-at-rest protection should use an approved encrypted SQLite option if threat modeling requires it.

## Write and synchronization flow

1. Validate locally for immediate feedback.
2. In one Drift transaction, save the local projection and immutable outbox operation using a client UUIDv7 and random idempotency key.
3. Process dependencies topologically (reference/parent before child); serialize writes per aggregate while allowing bounded concurrency across aggregates.
4. Send command with `Idempotency-Key`, operation UUID, device UUID, base version, and request ID.
5. Laravel authenticates, tenant-scopes, verifies request hash, runs normal domain validation in a transaction, records idempotent response, and returns canonical entity/version.
6. Mark synced only after committed server confirmation, then replace the local projection with the canonical response.
7. Pull incremental changes using opaque cursor, bounded pages, organization/farm authorization, versions, and tombstones. Apply a page atomically and advance cursor last.

Phase 1.1 implements organization-filtered due-operation selection, dependency blocking, conflict persistence, safe error codes, terminal-versus-retryable classification, authorized-farm reconciliation, and a two-second overlapping versioned cursor. Repeated overlap rows are safe because reference records are upserted transactionally.

Phase 2A extends the same bootstrap/incremental response with `animal_species`, `animal_breeds`, `animal_groups`, and `animals`. Drift schema version 2 stores server UUID/version/update marker, archive state, cache time, organization/farm scope, locally searchable identifiers, and an accessibility flag. Archive rows are applied as tombstones. If `authorized_farm_ids` removes a farm, cached groups/animals from that farm are immediately excluded from reads.

Phase 2B extends the response with `animal_movements`. Drift schema version 3 stores immutable source/destination snapshots, decision/status fields, server version/timestamp, cache time, and accessibility. Repeated bootstrap/incremental rows upsert status transitions safely. Movement visibility requires the view permission and access to both source and destination farms; revoked permission or either farm grant marks the row inaccessible.

## Idempotency and retries

Idempotency scope is organization + actor/device + key. Reusing a key with a different canonical request hash returns `409 IDEMPOTENCY_KEY_REUSED`; a completed identical request replays the stored status/body. In-progress duplicates return retry guidance. Retain records longer than the maximum offline/retry window.

Retry only network failures, `408`, `425`, `429`, and transient `5xx`, using exponential backoff with full jitter, server `Retry-After`, an upper delay, and manual retry. Authentication pauses for renewal; validation/authorization failures become user-visible failed items and do not loop. Local data is never deleted because upload failed.

Animal, breed, and group create/update/archive/restore plus every movement request/decision bypass the outbox and require an online API result. Phase 2C weight record/correction and status-change commands follow the same online-only rule. Clients still send UUIDv7 and a durable idempotency key so an uncertain online response can be retried without duplicating a committed command.

Drift schema version 4 caches authorized `animal_weights` and `animal_status_changes` and the current animal latest-weight projection. Bootstrap/incremental payloads carry separate history authorization flags. Upserts are UUID-based; correction rows update supersession links, and latest selection excludes superseded rows with `observed_at`, `created_at`, then UUID ordering. Farm or permission revocation makes stale cached rows inaccessible. None of these reads creates an outbox item.

## Conflict policy

- Creates with new UUIDs are naturally mergeable/idempotent.
- Mutable low-risk drafts use optimistic `version`; non-overlapping server-approved patches may be rebased.
- Master-data edits require explicit field comparison when base version is stale.
- Milk, health, breeding, inventory, approvals, and finance are never silently last-write-wins. Prefer append/correction/reversal commands; otherwise create a conflict for authorized resolution.
- Resolution choices are keep server, submit a new authorized correction, or merge allowed fields. Preserve both inputs and resolution in audit history.
- Deletions are tombstones; stale clients cannot resurrect them without a restore permission/action.

## Attachments and retention

Create/sync parent first, then initiate upload, stream checksum-verified content, and finalize attachment metadata idempotently. Missing local files remain failed and visible. Cache only farm-authorized working data and recent/reference windows; use cursor paging and eviction that never removes pending/conflicted records.
