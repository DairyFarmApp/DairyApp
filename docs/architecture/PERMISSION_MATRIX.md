# Permission Matrix

## Implemented Phase 1 foundation roles

| Permission | Organization Owner | Farm Manager | Farm Worker | Viewer |
|---|---:|---:|---:|---:|
| `organizations.view` | Yes | Yes | Yes | Yes |
| `organizations.update` | Yes | No | No | No |
| `farms.view` | Yes | Yes, assigned | Yes, assigned | Yes, assigned |
| `farms.create` | Yes | Yes | No | No |
| `farms.update` | Yes | Yes | No | No |
| `farms.archive` | Yes | No | No | No |
| `sheds.view` | Yes | Yes, assigned | Yes, assigned | Yes, assigned |
| `sheds.create`, `sheds.update`, `sheds.archive` | Yes | Yes | No | No |
| `users.view`, `users.manage` | Yes | No | No | No |
| `roles.view`, `roles.manage` | Yes | No | No | No |
| `sessions.view_own`, `sessions.revoke_own` | Yes | Yes | Yes | Yes |
| `audit_logs.view` | Yes | No | No | No |

The seeder and this table share the same explicit catalog. API middleware applies implemented organization/farm permissions; user/role/audit management endpoints are intentionally not exposed until an approved workflow assigns them.

## Self-service owner and family accounts

| Capability | Primary owner | Family admin |
|---|---:|---:|
| Manage implemented farm data | Yes | Yes |
| Edit own profile/photo | Yes | Yes |
| View family membership list | Yes | No |
| Create/disable/regenerate family link | Yes | No |
| Remove/restore family accounts | Yes | No |
| Remove or replace primary owner | No | No |
| Create another farm | No | No |
| Archive the only farm | No | No |

Both membership types receive the single-farm organization-owner permission
set for ordinary farm work. Membership administration additionally requires
`membership_type = primary_owner`; `users.manage` alone is insufficient.

## Implemented Phase 2A permissions

| Permission | Organization Owner | Farm Manager | Farm Worker | Viewer |
|---|---:|---:|---:|---:|
| `animals.view` | Yes | Yes, authorized farms | Yes, authorized farms | Yes, authorized farms |
| `animals.create` | Yes | Yes, authorized farms | No by default | No |
| `animals.update` | Yes | Yes, authorized farms | No | No |
| `animals.archive` | Yes | No by default | No | No |
| `animals.restore` | Yes | No by default | No | No |
| `animals.manage_identifiers` | Yes | No by default | No | No |
| `animal_breeds.view` | Yes | Yes | Yes | Yes |
| `animal_breeds.manage` | Yes | Yes | No | No |
| `animal_groups.view` | Yes | Yes, authorized farms | Yes, authorized farms | Yes, authorized farms |
| `animal_groups.manage` | Yes | Yes, authorized farms | No | No |

An explicitly customized role may grant worker create or manager archive, but the seeded defaults remain conservative. Permission alone never expands organization membership or farm grants. Identifier management controls user-supplied animal numbers and edits to animal number/ear tag/RFID.

## Implemented Phase 2B movement permissions

| Permission | Organization Owner | Farm Manager | Farm Worker | Viewer |
|---|---:|---:|---:|---:|
| `animals.move` | Yes | Yes, both authorized farms | Yes, both authorized farms | No |
| `animal_movements.view` | Yes | Yes, both authorized farms | Yes, both authorized farms | Yes, both authorized farms |
| `animal_movements.approve` | Yes | Yes, both authorized farms | No | No |
| `animal_movements.reject` | Yes | Yes, both authorized farms | No | No |
| `animal_movements.cancel` | Yes | Yes, both authorized farms | No | No |

The seeded approval setting requires a requester and approver to be different users. Permission alone does not bypass this rule. When approval is disabled, immediate application still requires both `animals.move` and `animal_movements.approve`; it never grants a worker implicit approval. Every movement read/decision requires access to both its source and destination farms.

## Implemented Phase 2C weight and status permissions

| Permission | Organization Owner | Farm Manager | Farm Worker | Viewer |
|---|---:|---:|---:|---:|
| `animals.record_weight` | Yes | Yes, authorized farm | Yes, authorized farm | No |
| `animals.correct_weight` | Yes | Yes, authorized farm | No | No |
| `animals.view_weight_history` | Yes | Yes, authorized farm | Yes, authorized farm | Yes, authorized farm |
| `animals.change_status` | Yes | Yes, authorized farm | No | No |
| `animals.view_status_history` | Yes | Yes, authorized farm | Yes, authorized farm | Yes, authorized farm |

Permission never expands organization membership or farm grants. Corrections require access to both the observation farm and the animal's current farm. Status changes require a current animal version and farm access.

## Implemented inventory permissions

| Permission | Organization Owner | Farm Manager | Farm Worker | Viewer |
|---|---:|---:|---:|---:|
| `inventory.view` | Yes | Yes, authorized farm | Yes, authorized farm | Yes, authorized farm |
| `inventory.manage` | Yes | Yes, authorized farm | No | No |
| `inventory.export` | Yes | Yes, authorized farm | No | No |

`inventory.view` covers the selector, summaries, filtered item lists, and stock
movement history. `inventory.manage` covers item creation, versioned metadata
changes, and receipt commands. Every route also requires active membership,
active session farm, and authorized farm access. `inventory.export` separately
controls PDF receipts and Excel downloads. Family admins inherit the
organization-owner work permissions while their membership is active, but
cannot manage the reusable family invitation.

## Product-wide proposed baseline

This is a conservative baseline. Organization owners can customize roles but cannot bypass platform boundaries. `Scope` is additionally restricted by membership and farm grants.

Legend: M = manage/create/update, V = view, A = approve/override, — = none by default.

| Capability | Owner | Farm manager | Vet | Breeding tech | Accountant | Storekeeper | Milking supervisor | Worker | Sales/driver | Auditor |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Organization/farm settings | M | V/M scoped | V | V | V | V | V | V | V | V |
| Users, roles, farm access | M | M scoped | — | — | — | — | — | — | — | V |
| Animals | M/A | M/A scoped | V/M health | V/M breeding | V | V | V | V/create assigned | V | V |
| Milk production/correction | M/A | M/A | V | V | V | — | M/A | create assigned | V | V |
| Health/withdrawal override | A | A | M/A | V | — | medicine issue | V | observation | — | V |
| Breeding/calving | A | M/A | M | M | — | — | V | assigned | — | V |
| Inventory issue/adjust | A | A | request | — | V | M/A | request | request | — | V |
| Purchasing | M/A | request/A scoped | — | — | M/A | M receipt | — | — | — | V |
| Sales/payments/delivery | M/A | A scoped | — | — | M/A | — | V | — | M scoped | V |
| Finance/expenses/payroll | M/A | expense scoped | — | — | M/A | — | — | draft own | collections only | V |
| Reports/export | all/A | operational | clinical | breeding | financial/A | inventory | milk | assigned only | route/sales | V/A per grant |
| Audit logs | V | V scoped | — | — | V financial | — | — | — | — | V |
| Backup/restore | request/A | — | — | — | — | — | — | — | — | V status |

## Permission naming

Use explicit abilities such as the implemented `animals.view`, `animals.create`, `animals.update`, `animals.move`, `animal_movements.view`, `animal_movements.approve`, `animal_movements.reject`, `animal_movements.cancel`, `animals.record_weight`, `animals.correct_weight`, `animals.view_weight_history`, `animals.change_status`, `animals.view_status_history`, `inventory.view`, `inventory.manage`, `inventory.export`, `milk.view`, `milk.create`, and `milk.correct`, plus future abilities such as `animals.record_death`, `milk.correct.request`, `milk.correct.approve`, `health.manage`, `withdrawals.override`, `inventory.issue`, `inventory.adjust.request`, `inventory.adjust.approve`, `sales.create`, `payments.receive`, `expenses.approve`, `payroll.process`, `reports.export`, `users.manage`, `audit_logs.view`, and `backups.restore`.

For Phase 3A, owners/family admins and farm managers can view, create, and
correct milk. Farm workers can view/create. Viewers can only view. Every role
still requires active organization membership and farm access.

Approval requires a distinct ability and, by default, requester and approver separation. No role implicitly gains financial reporting from general farm access. Veterinarian and worker defaults deliberately exclude customer balances and payroll. Field-level filtering protects employee identity/bank data and confidential finance data even when a broader record is viewable.
