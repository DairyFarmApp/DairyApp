# Animal Movement Workflow

Status: Phase 2B implemented on 2026-07-23. Movement mutations are online-only.

## Purpose and ownership

`animal_movements` is the immutable business history for post-registration animal location changes. The `animals.current_farm_id`, `current_shed_id`, and nullable `current_animal_group_id` fields remain the current-location projection. Only an approved movement action updates that projection; ordinary animal profile edits cannot change location.

Phase 2B supports request, view, approve, reject, and cancel. It does not implement offline movement mutation, scheduled future execution, correction-in-place, weights, status history, QR, photos, or a combined animal timeline.

## Data model

Each movement stores:

- UUIDv7 ID, organization and animal.
- Immutable source farm/shed/group snapshot.
- Destination farm/shed/group.
- Requested and actual effective timestamps.
- Reason, optional notes, and `pending`, `approved`, `rejected`, or `cancelled` status.
- An `approval_required` snapshot so later setting changes cannot alter the separation-of-duties rule for an existing request.
- Requester, decision maker/time, rejection or cancellation reason, version, and timestamps.

Composite foreign keys bind animal, source and destination farms, sheds, and optional groups to the same organization and correct farm. Approved records have no ordinary update endpoint. Corrections are new movements from the current approved location.

## Request and decision rules

1. Resolve the animal only inside the active organization and authorized farm scope.
2. Require the submitted source snapshot to equal the animal's locked current location.
3. Require access to both source and destination farms.
4. Require destination farm, shed, and optional group to share the active organization; shed/group must belong to the destination farm.
5. Reject an unchanged destination and archived animals.
6. Lock the animal while checking and creating a request, allowing at most one active pending movement.
7. A pending, rejected, or cancelled movement never changes current location.
8. Approval locks the movement and animal, checks movement version/status and the source snapshot again, then changes movement state and all three current-location fields in one transaction.
9. Duplicate decisions, stale movement versions, and a location changed by another approved movement fail without a partial update.
10. Rejection and cancellation require a non-empty reason; approved movement cancellation is prohibited.

The requested effective timestamp is a user-entered business timestamp at or before the request time. Phase 2B does not schedule future execution. `actual_effective_at` is the server commit time at immediate application or approval.

## Approval configuration

The organization-level typed setting is `animal_movement_requires_approval`. Missing or malformed values fail safe to approval required. The development seed stores `{ "enabled": true }`.

When enabled, a request remains pending and a different user with approval permission must approve it. The requester cannot self-approve.

When disabled, the same request action immediately applies the movement only if the requester has both `animals.move` and `animal_movements.approve`. It uses the same movement row, locking, location projection, and audit path; no second movement system exists.

## Permissions and scope

- `animals.move`: submit a movement for an animal in an authorized source farm.
- `animal_movements.view`: view history only when both source and destination farms are authorized.
- `animal_movements.approve`: approve and apply a pending request.
- `animal_movements.reject`: reject a pending request.
- `animal_movements.cancel`: cancel a pending request.

Organization Owner receives all permissions. Farm Manager receives request/view/approve/reject/cancel within granted farms. Farm Worker receives request/view. Viewer receives view. Permission never expands organization membership or farm grants.

Unauthorized and cross-organization movement identifiers are concealed as not found where appropriate. A user must retain access to both farms for movement history and decisions.

## API

All endpoints are under `/api/v1`, require an opaque authenticated session, active tenant context, policy authorization, request IDs, and the standard response envelope.

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/animals/{animal}/movements` | Paginated, searchable/filterable movement history |
| POST | `/animals/{animal}/movements` | Idempotent movement request or immediate application |
| GET | `/animal-movements/{movement}` | Read one authorized movement |
| POST | `/animal-movements/{movement}/approve` | Idempotent, versioned approval |
| POST | `/animal-movements/{movement}/reject` | Idempotent, versioned rejection with reason |
| POST | `/animal-movements/{movement}/cancel` | Idempotent, versioned cancellation with reason |

Create and decision commands accept `Idempotency-Key`. Replaying the same committed request returns the stored result; reusing the key for a different canonical payload returns `409 IDEMPOTENCY_KEY_REUSED`. Lost updates return `412 STALE_VERSION`; stable movement-state/source conflicts return a safe `409` code.

## Audit

The workflow writes:

- `animal.movement_requested`
- `animal.movement_approved`
- `animal.movement_rejected`
- `animal.movement_cancelled`
- `animal.location_changed`

Approval writes the movement approval and animal location-change entries inside the same transaction as the projection update. Audit values contain business source/destination state but no credentials or local environment data.

## Flutter and Drift

The animal detail screen includes responsive movement history: cards on mobile and a table on tablet widths. It exposes loading, empty, error/retry, cached, pending, approved, rejected, and cancelled states. Controls are permission-aware, and self-approval is hidden when separation is required. The request form shows the source as read-only and constrains shed/group choices by destination farm.

Drift schema version 3 adds `local_animal_movements`. Bootstrap and incremental pulls upsert authorized movement rows and status changes. Reads may fall back to cached history after a transient API failure. A movement is accessible only while the active membership has movement-view authority and both its source and destination farms remain authorized; revoked access marks it inaccessible.

All movement mutations call the real API directly. No movement operation is written to `sync_outbox` in Phase 2B.
