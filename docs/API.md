# API

The canonical machine-readable contract is `apps/api/openapi.yaml`. The base path is `/api/v1`; all responses include an `X-Request-ID` header and the configured envelope from `docs/architecture/API_CONVENTIONS.md`.

Farm and shed deletion endpoints archive with Laravel soft deletion and return an auditable `{archived: true}` response. Creation accepts optional client UUIDv7 identifiers and `Idempotency-Key`; identical committed retries replay the stored status/body, while different payload reuse returns `409 IDEMPOTENCY_KEY_REUSED`.

Cursor pagination is used for farm/shed lists. Sync cursors are opaque, versioned, and deliberately overlap the previous watermark so idempotent upserts cannot miss equal-timestamp changes. Sync responses include `authorized_farm_ids` so clients remove access to stale cached farms. Cross-tenant and unauthorized farm records are concealed as 404 where appropriate.

Phase 2A adds controlled species listing plus paginated breed, farm-group, and animal endpoints. Animals support bounded search by animal number/ear tag/RFID/name and allowlisted classification/location/status/archive filters and sorts. Create endpoints are idempotent; update/archive/restore requires `version` and returns `412 STALE_VERSION` on a lost update.

The normal animal edit route rejects farm, shed, and group changes. Initial registration validates them. Phase 2B owns later location transitions through six movement request/read/approve/reject/cancel operations. Movement creation and decisions are idempotent, decisions require optimistic `version`, and approval atomically changes the animal's current location. Both source and destination farm access are required; pending/rejected/cancelled records never change location.

Phase 2C moves post-registration operational-status changes out of the ordinary animal update route and into a dedicated versioned command. It adds online recording and immutable correction of exact decimal animal weights, latest-weight projection, status history, five granular permissions, and authorized sync snapshots. Weight/status mutation uses the existing idempotency primitive and never enters the mobile outbox.

Owner onboarding adds public creation of one private farm, reusable family-link
signup, persistent family membership removal/restoration, and authenticated
profile/photo management. Only the primary owner can control the invitation or
family membership. Removal revokes the affected user's active sessions
immediately.

The inventory core adds farm-scoped medicine, semen, and feed summaries,
filtered item/batch overviews, versioned metadata changes, idempotent stock
receipts, and immutable movement history. Stock cannot be changed by an
ordinary item update. Zero-stock items can be archived without deleting their
history. Permission-scoped PDF receipts and two-sheet XLSX exports accept
selected item UUIDs and an inclusive farm-timezone movement date range.
Inventory behavior is documented in
`docs/INVENTORY_MANAGEMENT.md`.

Daily milk production adds three authenticated operations under `/milk`:
`GET /milk/daily`, idempotent `POST /milk/entries/bulk`, and idempotent
`POST /milk/entries/{entry}/correct`. They use the standard success/error
envelopes, organization/farm scope, decimal strings, UUIDv7 identifiers,
permission middleware, and append-only audit events. See
`docs/DAILY_MILK_PRODUCTION.md`.

Identifier, parentage, breed/species, tenant, and farm rules are documented in
`docs/ANIMAL_REGISTRY.md`. Movement behavior is documented in
`docs/ANIMAL_MOVEMENTS.md`; weight/status behavior is documented in
`docs/ANIMAL_WEIGHTS_AND_STATUS.md`; owner and family behavior is documented in
`docs/OWNER_ONBOARDING_AND_FAMILY_ACCESS.md`. The current contract contains 76
API operations, including nine inventory operations and 15 owner-onboarding,
profile, and family operations.
