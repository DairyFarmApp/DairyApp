# Inventory Core and Glass Appearance Task Record

Status: Complete on `codex/inventory-glass-theme`.

## Approved behavior

- [x] Manage inventory opens Medicine, Semen, and Feed choices.
- [x] Every inventory area shows stock, value, low, expiring, and expired
  summaries.
- [x] Users can search and filter by category, supplier, and low-stock state.
- [x] Authorized managers can add an item with its first batch.
- [x] Opening stock is recorded as a permanent ledger movement.
- [x] Later receipts are idempotent and append permanent movements.
- [x] Ordinary item metadata updates cannot change stock.
- [x] Inventory is isolated by organization, active farm, and permission.
- [x] Responsive cards/tables/forms work on browser and mobile layouts.
- [x] System, White, and Dark glass themes are selectable and persistent.
- [x] Theme preference survives sign-out without preserving auth credentials.
- [x] Inventory rows expose edit, receive, PDF receipt, and safe delete/archive
  actions according to permission.
- [x] Ordinary item edits remain metadata-only and cannot change stock.
- [x] Delete archives only a zero-stock item and retains its batch/movement
  history.
- [x] One item, a checkbox selection, or all filtered items can be exported as
  a combined PDF receipt.
- [x] Selected/all filtered inventory can be downloaded as a two-sheet XLSX
  workbook with an inclusive stock-movement date range.
- [x] Purchase, expiry, and export date fields use calendar popup controls.
- [x] Inventory exports are farm-scoped, separately permissioned, and audited.

## Explicit exclusions

- Stock issue/consumption, damage, expiry write-off, adjustment, and transfer
- Purchasing, supplier master data, treatment integration, and ration planning
- FIFO/weighted-average/accounting valuation
- Barcode scanning and low-stock notifications
- Offline inventory cache/outbox/conflict resolution
- Cursor pagination beyond the current bounded 200-item overview
- Production deployment, signing, or secrets

## Validation result

- MySQL fresh migration/seed: passed on isolated `dairycare_test`.
- Focused inventory regression: 8 tests, 92 assertions.
- MySQL full suite: 82 tests, 852 assertions.
- SQLite: 74 passed, 730 assertions, 8 MySQL-only skipped.
- Flutter: 80 tests passed; analysis clean.
- Release web and Android debug builds: passed.
- OpenAPI: valid and exactly matches all 76 Laravel operations.
- Composer validation/audit: passed; no advisories.
- Manual browser QA: all inventory choices, medicine creation, totals/table,
  and System/White/Dark switching passed with no browser errors.

## Next action

Stop and obtain approval before implementing inventory issue/adjustment/
transfer workflows or another dairy product capability.
