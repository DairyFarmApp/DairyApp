# Inventory Core, Actions, Exports, and Glass Appearance Completion

Date: 2026-07-29 through 2026-07-30
Branch: `codex/inventory-glass-theme`

## Implemented

- Medicine, semen, and feed inventory selector with separate responsive
  overviews.
- Total stock/value, low-stock, expiring-soon, and expired metrics.
- Name/code/barcode/brand search plus category, supplier, and low-stock
  filters.
- Responsive item table/cards, status badges, item creation, opening batch,
  and receive-stock dialog.
- Metadata edit controls that preserve ledger-owned stock fields.
- Safe delete/archive controls with optimistic version checks. Non-zero stock
  is rejected, while zero-stock archival retains batches and movements.
- Checkbox selection, one-item and combined PDF receipts, and two-sheet Excel
  exports for selected/all filtered items.
- Inclusive farm-timezone movement date filters and calendar popup controls for
  purchase, expiry, and export dates.
- UUIDv7 farm-scoped item, batch, and permanent movement records.
- Atomic opening-stock and idempotent receipt transactions.
- Versioned metadata updates with row-locked lost-update protection.
- `inventory.view`, `inventory.manage`, and `inventory.export` permissions,
  tenant/farm concealment, audit events, OpenAPI contract, and regression
  tests.
- Persistent `System`, `White`, and `Dark` choices with glass backgrounds,
  surfaces, navigation, forms, tables, dialogs, and authentication pages.
- Theme preference survives sign-out without retaining authentication secrets.

## Database migration

`2026_07_29_000400_create_inventory_core_tables.php` creates:

- `inventory_items`
- `inventory_batches`
- `stock_movements`

The migration also registers the first two inventory permissions and adds them to
the seeded role defaults. Composite keys enforce organization/farm/item/batch
relationships. No development database was reset; destructive validation used
only the isolated `dairycare_test` database and a temporary browser-QA SQLite
database.

`2026_07_30_000500_add_inventory_export_permission.php` adds the separately
enforced `inventory.export` permission to organization-owner and farm-manager
defaults without altering inventory records.

## API operations

The implementation adds nine operations:

- `GET /api/v1/inventory`
- `GET /api/v1/inventory/{kind}`
- `POST /api/v1/inventory/{kind}/items`
- `PATCH /api/v1/inventory/{kind}/items/{item}`
- `DELETE /api/v1/inventory/{kind}/items/{item}`
- `POST /api/v1/inventory/{kind}/items/{item}/receipts`
- `GET /api/v1/inventory/{kind}/items/{item}/movements`
- `GET /api/v1/inventory/{kind}/exports/receipt`
- `GET /api/v1/inventory/{kind}/exports/spreadsheet`

The complete inventory is 76 Laravel operations and 76 OpenAPI operations, with
zero missing and zero extra.

## Validation results

| Gate | Result |
|---|---|
| Focused inventory regression | 8 tests, 92 assertions |
| Complete MySQL 8.4.9 suite | 82 tests, 852 assertions |
| Complete SQLite portability suite | 74 passed, 730 assertions, 8 MySQL concurrency tests skipped |
| MySQL `migrate:fresh --seed` | Passed against isolated `dairycare_test` |
| PHP syntax | 199 files passed |
| Pint apply/check | Passed |
| Composer validate/audit | Valid; no advisories |
| Laravel/OpenAPI operation parity | 76/76, zero differences |
| OpenAPI lint/bundle | Valid; bundle passed; 22 existing recommendation warnings |
| Dart format | 104 files; final check clean |
| Flutter analyze | No issues |
| Flutter tests | 80 passed |
| Android debug build | Passed; `app-debug.apk` generated in ignored build output |
| Release web build | Passed; Wasm dry run also succeeded |

Earlier manual browser QA used a temporary SQLite API and synthetic
`inventory.qa@example.test` owner. It verified owner login, the three inventory
choices, medicine overview, item creation, permanent opening stock, value
calculation, filters/table rendering, and live System/White/Dark switching. No
browser errors or warnings were logged. Temporary API/web processes were
stopped after QA. The 2026-07-30 action/export extension was validated through
focused responsive widget tests, authenticated binary-response tests, release
web compilation, and Android compilation; no new interactive browser QA is
claimed for those controls.

## Security and data-integrity regression coverage

- Unauthenticated inventory reads are rejected.
- Users without `inventory.manage` cannot create stock.
- Cross-organization and cross-farm item UUIDs remain concealed.
- Opening stock creates exactly one batch and one permanent movement.
- Replaying an idempotent receipt does not duplicate stock or movement rows.
- Ordinary metadata updates cannot change stock.
- A stale metadata version returns `412 STALE_VERSION` and changes nothing.
- Low/expired summary values derive from authorized farm batches.
- Ordinary metadata update cannot set inactive state or change stock.
- Non-zero stock blocks archive; zero-stock archive preserves all ledger rows.
- PDF and XLSX exports require `inventory.export`, conceal other farms, validate
  selected UUIDs/dates, and write audit events.
- Date-filtered XLSX tests prove old movements are excluded while current
  selected movements remain.

## Known limitations and next inventory scope

Inventory is online-only and lists/exports are currently bounded to 200 items.
Flutter does not yet expose a dedicated movement-history screen. The current
stock core supports only positive opening stock and receipts.

The exact recommended next inventory phase is controlled issue/consumption,
damage/expiry write-off, adjustment approval, farm/warehouse transfer, negative
stock prevention, movement-history UI, cursor pagination, and reconciliation.
Purchasing, rations, treatment consumption, accounting valuation, barcode
scanning, notifications, cross-domain reports, and offline inventory sync remain separate
approval scopes.
