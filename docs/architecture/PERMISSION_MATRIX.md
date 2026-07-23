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

Use explicit abilities such as `animals.view`, `animals.create`, `animals.update`, `animals.transfer.request`, `animals.transfer.approve`, `animals.record_death`, `milk.create`, `milk.correct.request`, `milk.correct.approve`, `health.manage`, `withdrawals.override`, `inventory.issue`, `inventory.adjust.request`, `inventory.adjust.approve`, `sales.create`, `payments.receive`, `expenses.approve`, `payroll.process`, `reports.export`, `users.manage`, `audit_logs.view`, and `backups.restore`.

Approval requires a distinct ability and, by default, requester and approver separation. No role implicitly gains financial reporting from general farm access. Veterinarian and worker defaults deliberately exclude customer balances and payroll. Field-level filtering protects employee identity/bank data and confidential finance data even when a broader record is viewable.
