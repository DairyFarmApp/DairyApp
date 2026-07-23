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

## Modules and principal tables

| Module | Principal data | Key relationships/invariants |
|---|---|---|
| Tenancy/settings | organizations, farms, branches, sheds, pens, warehouses, milk_tanks, cost_centres, settings | All descendants belong to one organization; locations cannot cross-link tenants |
| Identity/access | users, organization_memberships, roles, permissions, role_permissions, membership_roles, user_farm_access, api_sessions, sync_devices | Roles are organization scoped; sessions bind active membership and device |
| Animals | Implemented: animal_species, animal_breeds, animal_groups, organization_sequences, animals. Future: memberships, movements, weights, purchases, sales, mortalities | Animal identity unique within organization; initial location is immutable through profile edit; a future approved movement owns location transitions |
| Milk | milk_sessions, milk_entries, milk_collection_batches, milk_batch_sources, milk_tank_movements, milk_quality_tests, milk_restrictions | Unique normal entry per animal/date/session; tank balance derives from movements; restricted quantity excluded from sellable stock |
| Breeding/calving | heat_records, breeding_services, pregnancy_checks, pregnancies, calving_events, calving_offspring | Female/age rules; calving closes pregnancy and links newly created animal records |
| Health | health_cases, treatments, medicines, treatment_medicines, vaccinations, vaccination_schedules, deworming_records | Medicine treatment can create withdrawal restriction; histories are retained |
| Feed/inventory | inventory_categories, inventory_items, inventory_batches, stock_movements, ration_plans, ration_plan_items, feed_issues | Stock is summed from movements; batches track expiry; negative-stock policy checked transactionally |
| Purchasing | suppliers, purchase_requests, purchase_orders/items, goods_receipts/items, supplier_invoices/items, supplier_payments, purchase_returns | Receipt posts stock movement; payable ledger derives from posted documents |
| Sales/delivery | customers, milk_sales/items, customer_payments, delivery_routes/stops, deliveries/items, sale_returns | Confirmed sale posts milk/customer ledger effects; cancellation uses reversal |
| Finance | accounts, journal_entries, journal_lines, expenses, income_records, account_transfers, fiscal_periods | Balanced double-entry journals; posted entries immutable; dimensions include farm/cost centre |
| Workforce | employees, attendance, leave_requests, payroll_periods, payroll_entries, employee_advances | Sensitive fields restricted; approved payroll posts finance transaction |
| Operations | tasks, task_checklists, assets, maintenance_work_orders | Maintenance parts post stock issues |
| Platform | alerts, notifications, attachments, approvals, audit_logs, idempotency_records, sync_operations, sync_cursors | Tenant scoped; audit append-only; idempotency stores request hash/result |

## Relationship and constraint notes

- User identity is platform-wide; `organization_memberships` gives tenant status. Employee may optionally link one membership without making every user an employee.
- Farm is the stable operational boundary. Branch is an optional administrative/site subdivision; shed, pen, warehouse, tank, and cost centre reference farm directly to simplify scoping.
- Phase 2A animals store their validated initial/current location projection. After Phase 2B approval, only an approved movement action may update it and movement history becomes the transition source of truth.
- Do not create a separate `calves` identity table: offspring are rows in `animals`; `calving_offspring` carries birth-event-specific facts.
- Inventory item definition is organization-wide; batches and movements are warehouse/farm scoped. Feed and medicines specialize/reference inventory items rather than duplicating stock.
- Customer/supplier balances and milk/tank quantities are projections of immutable ledgers, optionally cached with reconciliation controls.
- Settings use typed, whitelisted keys with organization defaults and farm overrides; a deterministic scope hash enforces one organization/farm/key value even when `farm_id` is null, and the composite farm/organization foreign key prevents cross-tenant overrides. Arbitrary settings must not replace proper relational fields.

## Index/uniqueness baseline

Examples: `(organization_id, animal_number)` unique; nullable tag identifiers unique per organization when present; `(organization_id, animal_id, milk_date, session_id)` unique for active normal milk entries; `(organization_id, idempotency_key, actor_id)` unique; indexes on `(organization_id, farm_id, occurred_at)`, sync `updated_at/uuid`, alert status/due date, ledger account/date, and foreign keys. Exact precision/indexes are finalized per migration in its implementation phase.

## Deletion and retention

Use soft deletes for editable master data where restoration is meaningful. Do not soft-delete immutable history as a substitute for reversal. Audit/idempotency retention and personal-data anonymization require approved retention policy. Attachments use tombstones and delayed physical cleanup only after authorization and backup-retention considerations.
