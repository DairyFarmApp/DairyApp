# Inventory Management

## Scope

The approved inventory core manages three farm stock areas:

- Medicine inventory, including vaccines
- Semen inventory
- Feed inventory

The Flutter inventory selector opens a separate overview for each area. Every
overview provides total stock, current stock value, low-stock count, expiring
batches, expired batches, search, category and supplier filters, and a
responsive stock table/card list. Authorized managers can create an item with
its opening batch, edit metadata, receive later stock into an existing or new
batch, and archive an item after its stock reaches zero.

Authorized exporters can select one, several, or every item in the filtered
overview. They can download a PDF receipt for one item or a combined PDF
receipt, and a two-sheet Excel workbook containing current item summaries plus
date-filtered stock movements. Date fields use calendar pickers; movement date
ranges are inclusive and interpreted in the active farm timezone.

The same responsive application now supports persistent `System`, `White`, and
`Dark` appearance choices. Glass surfaces, navigation, dialogs, forms, metric
cards, and tables adapt to the selected brightness. The setting is local to the
device/browser and survives sign-out; it is not farm data.

## Data model

`inventory_items` is the farm-scoped master record. It stores the inventory
kind, code, optional barcode, name, category, brand, unit, minimum/maximum
levels, notes, active state, optimistic version, and actor metadata.

`inventory_batches` belongs to exactly one item in the same organization and
farm. It stores batch number, supplier, purchase/expiry dates, last receipt
unit cost, and the current-quantity projection.

`stock_movements` is the permanent stock ledger. Item creation appends one
`opening_stock` movement. Receiving stock appends one `purchase_receipt`
movement. The batch quantity changes only in the same transaction that appends
the movement. No ordinary item update accepts a stock field.

All identifiers use UUIDv7. Composite foreign keys and scoped queries prevent a
batch or movement from crossing its organization, farm, or item. A manager
cannot use another farm's UUID to discover or change inventory.

## Stock rules

1. Stock is never edited through item metadata.
2. Opening stock and every receipt require a batch and permanent movement.
3. Receipt commands require an `Idempotency-Key`; replaying the same committed
   command returns the original response without adding stock again.
4. Item metadata updates require the current integer `version`. A row lock
   rechecks it inside the transaction and returns `412 STALE_VERSION` on a lost
   update.
5. Quantity uses `DECIMAL(18,3)` and unit cost/value use `DECIMAL(19,4)` in the
   central database. API decimals remain strings.
6. Low stock means total positive batch quantity is less than or equal to the
   item's configured minimum.
7. Expiring soon means a positive-stock batch expires from today through the
   next 30 days. Expired means its expiry date is before today.
8. Current value is the sum of each positive batch quantity multiplied by that
   batch's recorded unit cost.
9. Delete is a soft archive, never a physical database deletion. An item with
   any non-zero batch quantity returns `409 INVENTORY_ITEM_HAS_STOCK`; users
   must first record a later approved stock usage/adjustment workflow.
10. Archive retains batches, movements, audit events, and UUID identity.

Only positive opening quantities and receipts exist in this controlled core,
so it cannot create negative stock. Issues, consumption, damage, expiry
write-off, adjustments, transfers, purchasing integration, and weighted/FIFO
costing require a later separately approved ledger phase.

## Authorization

- `inventory.view` allows the selector, overview, filters, and movement history.
- `inventory.manage` allows item creation, item metadata changes, and receipts.
- `inventory.export` allows authenticated PDF and Excel downloads.
- Organization owner and farm manager defaults receive all three permissions.
- Farm worker and viewer defaults receive view only.
- Organization membership, active session farm, explicit permission, and
  farm-access checks all apply. Permission alone never expands farm access.

Primary owners and active family admins receive the owner permission set for
ordinary work in their shared farm. Removing a family account revokes its
sessions, so inventory access ends immediately.

## API

| Method | Path | Permission | Purpose |
|---|---|---|---|
| `GET` | `/api/v1/inventory` | `inventory.view` | Summary for medicine, semen, and feed |
| `GET` | `/api/v1/inventory/{kind}` | `inventory.view` | Filtered overview and item list |
| `POST` | `/api/v1/inventory/{kind}/items` | `inventory.manage` | Create item, first batch, and opening movement |
| `PATCH` | `/api/v1/inventory/{kind}/items/{item}` | `inventory.manage` | Update versioned metadata only |
| `DELETE` | `/api/v1/inventory/{kind}/items/{item}` | `inventory.manage` | Archive a zero-stock item and retain history |
| `POST` | `/api/v1/inventory/{kind}/items/{item}/receipts` | `inventory.manage` | Append receipt movement and update batch projection |
| `GET` | `/api/v1/inventory/{kind}/items/{item}/movements` | `inventory.view` | Read the permanent stock ledger |
| `GET` | `/api/v1/inventory/{kind}/exports/receipt` | `inventory.export` | Download one/selected/all item receipt as PDF |
| `GET` | `/api/v1/inventory/{kind}/exports/spreadsheet` | `inventory.export` | Download item summary and date-filtered movements as XLSX |

`kind` is exactly `medicine`, `semen`, or `feed`. The canonical request and
response schemas are in `apps/api/openapi.yaml`.

The export query accepts up to 200 distinct `item_ids`, plus optional
`from_date` and `to_date` values in `YYYY-MM-DD` form. Omitting item IDs means
all active items of that kind in the active farm. Flutter sends the IDs of all
currently filtered rows when no checkbox is selected, so its “all” action
matches what the user can see. Binary success responses use `application/pdf`
or the standard XLSX content type and `Content-Disposition`; failures retain
the normal JSON error envelope.

## Audit and offline behavior

Item creation, metadata updates, archival, stock receipts, PDF downloads, and
Excel downloads write append-only audit events with the request ID, actor,
organization, farm, subject, selection count/date range, and safe before/after
context. Secrets are never part of inventory audit payloads.

Inventory reads and writes are online-only in this core. They are deliberately
not inserted into the existing mobile outbox and are not cached in Drift.
Extending inventory offline requires a dedicated schema, cursor/tombstone rules,
stock-command conflict handling, and reconciliation tests; a disconnected
device must never guess a stock balance.

## Known limitations

- Item lists are bounded to 200 rows and are not yet cursor paginated.
- Movement-history presentation remains an API capability; the exported
  workbook and receipt expose the selected period's movement rows.
- Stock value uses the current batch cost projection, not weighted-average,
  FIFO, or accounting valuation.
- Archival requires zero stock. The currently approved UI has no issue,
  consumption, or adjustment command, so positive-stock items remain protected
  until that separately approved ledger phase exists.
- No purchasing, supplier master, feed ration, treatment consumption, barcode
  scanning, notification, or inventory offline-sync workflow is included.
