# Daily Milk Production

## Implemented Phase 3A scope

DairyCare records daily production for active adult female animals in the
currently selected farm. The responsive quick-entry screen supports Morning,
Afternoon, and Evening sessions, a calendar date picker, bulk entry, rejected
milk with a required reason, live farm totals, cached viewing, and safe offline
capture.

The dashboard values are calculated from saved milk records:

- Total milk
- Rejected milk
- Sellable milk
- Animals recorded
- Yesterday's sellable milk
- Seven-day daily average

No dashboard value is hard-coded.

If no animal is eligible, the screen now explains the required setup rather
than showing a dead end. It links directly to shed management, breed
management, and adding an adult female animal. Once that active adult female
animal belongs to the current farm and shed, it appears in Morning,
Afternoon, and Evening quick entry and its saved values immediately contribute
to the calculated totals.

## Data integrity

`milk_production_slots` owns the unique business identity of one animal, one
production date, and one session. The database unique constraint prevents
ordinary duplicates even when two devices submit concurrently.

`milk_entries` contains immutable measurement revisions. The current revision
is a projection; correcting an entry appends a new revision, links it to the
original, and marks the original as superseded. The original quantity and
reason remain available for audit and investigation.

All rows carry organization and farm scope. Composite foreign keys prevent an
entry from referring to an animal, shed, or slot in another tenant. Only active
adult female animals in the active farm are eligible in Phase 3A.

Quantities use `DECIMAL(18,3)` on the server and decimal strings in the API.
Rejected quantity cannot be negative or exceed total quantity. A rejection
reason is mandatory when rejected milk is greater than zero.

## API

| Method | Path | Permission | Purpose |
|---|---|---|---|
| `GET` | `/api/v1/milk/daily` | `milk.view` | Eligible animals, entries, and calculated daily totals |
| `POST` | `/api/v1/milk/entries/bulk` | `milk.create` | Idempotent quick entry for up to 200 animals |
| `POST` | `/api/v1/milk/entries/{entry}/correct` | `milk.correct` | Append a corrected revision with a mandatory reason |

The canonical contract is `apps/api/openapi.yaml`.

## Offline behavior

If the API is unavailable, Flutter atomically stores the new milk rows in
Drift and places the exact bulk command in the synchronization outbox. Client
UUIDv7 values and the same idempotency key are retained across retries. The
entry is visibly marked pending and contributes to the device's cached daily
view. The server still performs every eligibility, duplicate, quantity, tenant,
and permission check when synchronization resumes.

The sync pull returns only current milk revisions for authorized farms.
Removing `milk.view` or farm access makes the corresponding local rows
inaccessible. Corrections remain online-only in Phase 3A because resolving
concurrent correction history requires server serialization.

## Permissions and audit

- `milk.view`: see daily production and synchronized entries.
- `milk.create`: record new daily production online or offline.
- `milk.correct`: append a correction revision.

Owners and family admins receive all three. Farm managers receive all three,
workers receive view/create, and viewers receive view only.

Bulk entry and correction write append-only audit events containing the actor,
request ID, farm, date/session, safe totals, and correction reason.

## Controlled exclusions

Phase 3A does not yet implement:

- Custom session setup
- Lactation-period records
- Supervisor approval workflow
- Collection batches and milk tanks
- Medicine-withdrawal restrictions
- Quality laboratory tests
- Milk sales or delivery
- Production-drop alerts
- CSV/Excel import

These remain separate Phase 3 or later workflows and must use the implemented
daily production history rather than replacing it.
