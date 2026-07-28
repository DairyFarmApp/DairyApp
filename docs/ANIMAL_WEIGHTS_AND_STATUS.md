# Animal Weights and Operational Status

## Phase 2C scope

Phase 2C adds online animal-weight recording and correction plus auditable operational-status changes. It adds six API operations, responsive Flutter forms/history, latest-weight projection, authorized Drift read caching, seeded examples, and regression coverage.

The phase deliberately excludes QR, photos, a combined animal timeline, offline animal mutations, background upload, and all milk, breeding, health, inventory, finance, workforce, equipment, AI, IoT, and reporting domains.

## Weight model

`animal_weights` is an append-oriented observation history. Every row is scoped by `organization_id`, the animal, and the farm where the observation was made. It records:

- the exact entered decimal value and `kg` or `lb` unit;
- a canonical kilogram value at six decimal places;
- observation time and `manual`, `scale`, `estimated`, or `imported` source;
- optional notes, recorder, and timestamps;
- immutable correction links and a required correction reason.

The backend does not use binary floating-point arithmetic. Values are parsed into integer millionths. Pounds are converted with the exact factor `1 lb = 0.45359237 kg`, rounded to the nearest kilogram millionth. API decimals are strings so JSON clients do not lose precision.

Weight must be positive and cannot exceed the organization/farm `animal_weight_max_kg` setting after conversion. Farm-specific settings take precedence over organization settings; the safe default is `3000.000000 kg`. Each create command supplies a current-farm snapshot, which must match the locked animal location. `observed_at` may be no more than five minutes ahead of server time to tolerate ordinary device clock skew.

The animal's latest weight is the non-superseded row with the greatest `observed_at`, then `created_at`, then UUID. It is returned as an authorized projection in animal resources and cached locally for list/detail display.

## Immutable correction workflow

There is no ordinary update or delete operation for weight rows. A correction:

1. locks the animal and original weight;
2. confirms the animal is not archived and the actor can access both its current farm and the observation farm;
3. rejects an original that already has a correction;
4. rejects correction-of-correction chains;
5. creates one linked replacement preserving the original observation farm, time, and source;
6. marks the original superseded and points it to the replacement in the same transaction;
7. writes an `animal.weight_corrected` audit event.

The original and replacement remain available in history. Concurrent correction attempts are serialized and at most one replacement succeeds.

## Operational-status workflow

The allowed operational statuses remain `active`, `inactive`, and `missing`. Initial animal registration may choose the initial status. After registration, the ordinary animal profile update route cannot change it; the dedicated status command is authoritative.

Each change requires a new status, effective time, reason, and the current animal version. Each appended row is stored in `animal_status_histories`. The command:

1. locks the animal;
2. rejects archived animals, stale versions, and no-op transitions;
3. appends an `animal_status_changes` row with previous/new status, farm snapshot, actor, and per-animal sequence;
4. updates `animals.operational_status` and increments the animal version atomically;
5. writes an `animal.status_changed` audit event in the transaction.

`effective_at` must not be in the future. Status history is immutable and ordered by sequence. There is no ordinary history update/delete route.

## API operations

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/api/v1/animals/{animal}/weights` | Paginated authorized history |
| `POST` | `/api/v1/animals/{animal}/weights` | Record a weight |
| `GET` | `/api/v1/animal-weights/{weight}` | Read one authorized weight |
| `POST` | `/api/v1/animal-weights/{weight}/correct` | Append one correction |
| `GET` | `/api/v1/animals/{animal}/status-history` | Paginated authorized status history |
| `POST` | `/api/v1/animals/{animal}/status-changes` | Append and project a status change |

Mutating operations accept `Idempotency-Key` and an optional client UUIDv7 `id`. They use the shared response/error conventions. Weight conflicts include `WEIGHT_ALREADY_CORRECTED` and `CORRECTION_CANNOT_BE_CORRECTED`; status conflicts include `STATUS_UNCHANGED`, and stale animal versions return `412 STALE_VERSION`.

## Authorization and isolation

The permissions are:

- `animals.record_weight`
- `animals.correct_weight`
- `animals.view_weight_history`
- `animals.change_status`
- `animals.view_status_history`

Every query is scoped to the authenticated organization. Weight and status operations require access to the applicable farm; unauthorized organization, animal, weight, and farm identifiers are concealed as `404`. Composite foreign keys prevent cross-organization/cross-farm references if application validation regresses.

Seeded defaults grant owners all five permissions; managers all five within authorized farms; workers weight recording and both history views; and viewers both history views.

## Flutter and Drift behavior

Flutter uses dedicated weight/status domain models, repository methods, Riverpod providers, validated responsive forms, incrementally loaded 25-row history pages, history sections, and permission-aware actions. The ordinary animal edit form shows operational status as read-only and directs authorized users to the dedicated workflow.

Drift schema version 4 adds `local_animal_weights`, `local_animal_status_changes`, and latest-weight projection columns on `local_animals`. Bootstrap and incremental sync upsert authorized rows. Permission removal or farm-access removal marks affected history inaccessible and removes it from ordinary reads. Offline history queries are capped at the newest 250 authorized rows per animal.

Phase 2C mutations are intentionally online-only. They never enter the existing outbox, do not claim background synchronization, and surface a clear online requirement. The server's idempotency record and client-generated UUID protect safe manual retry after an uncertain response.

## Audit events

The server writes:

- `animal.weight_recorded`
- `animal.weight_corrected`
- `animal.status_changed`

Audit rows carry the authenticated actor, organization, entity, request/operation context, and sanitized before/after data. They are created in the same transaction as the domain change and have no ordinary update/delete endpoint.

## Known boundaries

- There is no edit or deletion of historical weight/status facts.
- A correction cannot itself be corrected; a further data issue requires a separately approved policy.
- Weight maxima use current settings and are not a per-row settings snapshot.
- Cache reads are available offline, but record/correct/change commands require connectivity.
- No combined animal event timeline or analytics are introduced.
