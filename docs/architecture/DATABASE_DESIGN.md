# Database Design

## Conventions

- MySQL/InnoDB, `utf8mb4`; UUIDv7 is stored consistently. Phase 1 uses native UUID/`CHAR(36)`-compatible columns for Laravel/MySQL/SQLite portability; `BINARY(16)` remains a future optimization after conversion/query tooling and migration risk are benchmarked.
- Tenant tables contain `organization_id`; farm-operational tables contain `farm_id` where meaningful. Index tenant first in common access paths.
- `created_at`, `updated_at` are UTC; synchronizable mutable rows also have integer `version`. Important rows record actor UUIDs.
- Money uses `DECIMAL(19,4)` plus ISO currency; milk/feed/weight use an agreed `DECIMAL(18,6)` canonical quantity plus unit metadata.
- Foreign keys, targeted unique constraints, and check constraints enforce invariants. Polymorphic links are limited to attachments/audit metadata where controlled.
- Ledger and movement tables are append-only. Corrections use reversal links; posted financial and stock facts are never overwritten or hard-deleted.

## Implemented foundation migration organization

Phase 1.1 replaces the original combined migration before production data exists. Foundation tables are grouped as tenancy (`000100`), access control (`000110`), authentication and hashed renewal history (`000120`), governance (`000130`), and synchronization (`000140`). Composite foreign keys prevent cross-organization shed/farm, membership/role, membership/farm, and session-context links. Default Laravel users, cache, and jobs remain in their original migrations.

## Implemented owner onboarding and family access

The owner-onboarding migration adds optional phone/profile-photo fields to
`users`, a `membership_type` plus same-organization inviter reference to
`organization_memberships`, and one `farm_invite_links` row per organization.
Primary owners have `membership_type = primary_owner`; invited relatives have
`membership_type = family_admin`. Membership removal changes status to
`removed` and preserves history.

`farm_invite_links` belongs to exactly one organization and farm. Composite
foreign keys prevent its farm or creator membership from crossing tenants.
The reusable secret is validated with `token_hash`; `token_ciphertext` is
application encrypted so the primary owner can copy the current link. Rotation
changes both values and increments `generation`, invalidating the old link.

## Implemented Phase 2A animal registry

Phase 2A adds:

| Table | Scope and key constraints |
|---|---|
| `animal_species` | System-controlled UUIDv7 code/name reference with active state |
| `animal_breeds` | Organization + species; unique code and normalized name per organization/species; versioned, actor-tracked, archived |
| `animal_groups` | Organization + farm; optional same-farm shed; unique code and normalized name per farm; versioned, actor-tracked, archived |
| `organization_sequences` | Organization + sequence key primary key; locked transactionally for human-readable numbering |
| `animals` | Organization identity/classification/current initial location/parentage/origin/status; organization-unique number/tag/RFID; versioned, actor-tracked, archived |

Composite foreign keys enforce breed/species, group/farm/shed, animal farm/shed/group, and parent organization consistency. Animal archive uses soft deletion while operational status remains `active`, `inactive`, or `missing`. See `docs/ANIMAL_REGISTRY.md` for field-level rules.

## Implemented Phase 2B animal movements

| Table | Scope and key constraints |
|---|---|
| `animal_movements` | Organization + animal, immutable source and destination farm/shed/group snapshots, requested/actual effective time, decision state/actors/reasons, approval-setting snapshot, version, timestamps |

The table uses composite foreign keys for animal/organization, source farm/organization, source shed/farm/organization, optional source group/farm/organization, and the equivalent destination hierarchy. Indexes support animal history/status/time, source/destination farm authorization, and incremental organization updates.

The request action locks the animal before validating the source snapshot and checking for an existing pending movement. Approval locks the movement and animal, verifies status/version/current source, then updates the movement and `animals` current-location projection atomically. Pending/rejected/cancelled rows never update the projection. Approved rows have no ordinary update route; corrections append a new movement.

## Implemented Phase 2C weights and status history

| Table | Scope and key constraints |
|---|---|
| `animal_weights` | Organization/farm/animal observation, exact entered decimal/unit, canonical kilograms, observed time/source, recorder, immutable single-correction links, superseded flag, timestamps |
| `animal_status_histories` | Organization/farm/animal previous/new status, effective time/reason/actor, unique per-animal sequence, timestamps |

Both tables use UUIDv7 identifiers and composite tenant/farm foreign keys. Weight corrections preserve the original observation farm/time/source, retain both rows, and enforce unique forward/back links. Status changes append history while atomically updating the versioned `animals.operational_status` projection. Indexes support authorized animal history, latest non-superseded weight selection, farm-scoped sync, and organization update cursors.

## Implemented inventory core

| Table | Scope and key constraints |
|---|---|
| `inventory_items` | Organization + farm + kind (`medicine`, `semen`, `feed`); scoped unique code/barcode; unit, reorder levels, active state, optimistic version, actors, soft deletion |
| `inventory_batches` | Organization + farm + item; batch number, supplier, purchase/expiry dates, unit cost, current-quantity projection, version |
| `stock_movements` | Organization + farm + item + batch; append-only movement type, signed quantity, unit cost, occurrence/reason/actor |

Composite foreign keys prevent item, batch, and movement links from crossing
organization or farm boundaries. Item creation atomically appends the first
batch and `opening_stock` movement. A receipt locks the item and batch,
increments the quantity projection, appends `purchase_receipt`, and records the
audit event in one transaction. Item metadata updates never accept stock and
recheck optimistic version under a row lock.

## Modules and principal tables

| Module | Principal data | Key relationships/invariants |
|---|---|---|
| Tenancy/settings | organizations, farms, branches, sheds, pens, warehouses, milk_tanks, cost_centres, settings | All descendants belong to one organization; locations cannot cross-link tenants |
| Identity/access | users, organization_memberships, roles, permissions, role_permissions, membership_roles, user_farm_access, api_sessions, sync_devices | Roles are organization scoped; sessions bind active membership and device |
| Animals | Implemented: animal_species, animal_breeds, animal_groups, organization_sequences, animals, animal_movements, animal_weights, animal_status_histories. Future: memberships, purchases, sales, mortalities | Animal identity unique within organization; profile edits cannot change location/status; approved movements own location transitions; dedicated append commands own weight/status history |
| Milk | milk_sessions, milk_entries, milk_collection_batches, milk_batch_sources, milk_tank_movements, milk_quality_tests, milk_restrictions | Unique normal entry per animal/date/session; tank balance derives from movements; restricted quantity excluded from sellable stock |
| Breeding/calving | heat_records, breeding_services, pregnancy_checks, pregnancies, calving_events, calving_offspring | Female/age rules; calving closes pregnancy and links newly created animal records |
| Health | health_cases, treatments, medicines, treatment_medicines, vaccinations, vaccination_schedules, deworming_records | Medicine treatment can create withdrawal restriction; histories are retained |
| Feed/inventory | Implemented: inventory_items, inventory_batches, stock_movements. Future: inventory_categories, warehouses, ration_plans, ration_plan_items, feed_issues | Opening/receipt stock is ledger-backed; batch projection supports current totals and expiry; future issues/adjustments must block negative stock transactionally |
| Purchasing | suppliers, purchase_requests, purchase_orders/items, goods_receipts/items, supplier_invoices/items, supplier_payments, purchase_returns | Receipt posts stock movement; payable ledger derives from posted documents |
| Sales/delivery | customers, milk_sales/items, customer_payments, delivery_routes/stops, deliveries/items, sale_returns | Confirmed sale posts milk/customer ledger effects; cancellation uses reversal |
| Finance | accounts, journal_entries, journal_lines, expenses, income_records, account_transfers, fiscal_periods | Balanced double-entry journals; posted entries immutable; dimensions include farm/cost centre |
| Workforce | employees, attendance, leave_requests, payroll_periods, payroll_entries, employee_advances | Sensitive fields restricted; approved payroll posts finance transaction |
| Operations | tasks, task_checklists, assets, maintenance_work_orders | Maintenance parts post stock issues |
| Platform | alerts, notifications, attachments, approvals, audit_logs, idempotency_records, sync_operations, sync_cursors | Tenant scoped; audit append-only; idempotency stores request hash/result |

## Relationship and constraint notes

- User identity is platform-wide; `organization_memberships` gives tenant status. Employee may optionally link one membership without making every user an employee.
- Farm is the stable operational boundary. Branch is an optional administrative/site subdivision; shed, pen, warehouse, tank, and cost centre reference farm directly to simplify scoping.
- Phase 2A animals store their validated initial/current location projection. Phase 2B permits only an approved movement action to update it; `animal_movements` is the transition source of truth.
- Do not create a separate `calves` identity table: offspring are rows in `animals`; `calving_offspring` carries birth-event-specific facts.
- The implemented one-farm inventory item, batch, and movement rows are organization/farm scoped. If multi-warehouse stock is approved later, item definitions can be promoted to organization scope while stock remains warehouse/farm scoped; that migration must preserve the ledger.
- Customer/supplier balances and milk/tank quantities are projections of immutable ledgers, optionally cached with reconciliation controls.
- Settings use typed, whitelisted keys with organization defaults and farm overrides; a deterministic scope hash enforces one organization/farm/key value even when `farm_id` is null, and the composite farm/organization foreign key prevents cross-tenant overrides. Arbitrary settings must not replace proper relational fields.

## Index/uniqueness baseline

Examples: `(organization_id, animal_number)` unique; nullable tag identifiers unique per organization when present; movement indexes on `(organization_id, animal_id, status, requested_effective_at)`, `(organization_id, source_farm_id, destination_farm_id, status)`, and `(organization_id, updated_at)`; `(organization_id, animal_id, milk_date, session_id)` unique for future active normal milk entries; `(organization_id, idempotency_key, actor_id)` unique; indexes on tenant/time access paths and foreign keys. Exact precision/indexes are finalized per migration in its implementation phase.

## Deletion and retention

Use soft deletes for editable master data where restoration is meaningful. Do not soft-delete immutable history as a substitute for reversal. Audit/idempotency retention and personal-data anonymization require approved retention policy. Attachments use tombstones and delayed physical cleanup only after authorization and backup-retention considerations.
