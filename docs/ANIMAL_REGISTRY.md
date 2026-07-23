# Animal Registry

Phase 2A implements the online animal-registry core. It is deliberately limited to controlled species, organization breeds, farm-scoped groups, animal identity/classification/initial location/parentage, search, profile editing, archive/restore, audit, and authorized read caching.

## Dairy terminology

- Species are controlled system records. Phase 2A seeds `CATTLE` and `BUFFALO`.
- Breed is organization-scoped and belongs to one species.
- Sex is `female` or `male`.
- Life stage is `calf`, `juvenile`, or `adult`.
- Operational status is `active`, `inactive`, or `missing`.
- Archive state is separate from operational status.
- Cow, bull, and calf are not species. Pregnancy, lactation, dry status, sickness, treatment, sale, culling, and death belong to later workflows.

## Architecture

Laravel code is grouped under `app/Domain/AnimalRegistry`:

- models hold persistence mappings;
- scoped queries enforce organization and authorized-farm visibility;
- policies enforce record-level permissions;
- Form Requests validate transport shape;
- support validators enforce classification, location, identifier, and parentage rules;
- transactional actions create, update, archive, restore, audit, and increment optimistic versions;
- API resources control output;
- controllers remain transport coordinators.

Flutter code is grouped under `features/animals` with separate `domain`, `data`, `application`, and `presentation` layers. Riverpod owns reference/detail/list state, Dio calls the real API, and Drift provides authorized read fallback. Animal mutations are online-only in Phase 2A.

## Database tables

### `animal_species`

System-controlled UUIDv7 reference records with `code`, `name`, active flag, and timestamps. Referenced species are never physically removed.

### `animal_breeds`

Contains organization/species ownership, code, display and normalized names, description, active flag, optimistic version, actor UUIDs, timestamps, archive metadata, and soft deletion.

The database enforces:

- `(organization_id, species_id, code)` uniqueness;
- `(organization_id, species_id, normalized_name)` uniqueness;
- composite organization/species ownership.

Inactive or archived breeds remain resolvable on existing animal profiles.

### `animal_groups`

Contains organization/farm ownership, optional same-farm default shed, code, display and normalized names, description, active flag, optimistic version, actor UUIDs, timestamps, archive metadata, and soft deletion.

The database enforces farm and shed tenant consistency plus farm-level code/name uniqueness. Archiving a group never archives its animals.

### `organization_sequences`

Stores `(organization_id, sequence_key)` and the next integer. It is the transaction-safe source for organization animal numbers.

### `animals`

Stores:

- identity: animal number, optional ear tag, RFID, name, and registration number;
- classification: species, breed, sex, life stage, optional birth date/estimated flag, colour, and identifying marks;
- current initial location projection: farm, shed, and optional group;
- parentage: optional mother, father, and external sire reference;
- origin: `born_on_farm`, `purchased`, `transferred_in`, or `other`;
- acquisition/source/notes;
- operational status, optimistic version, actors, timestamps, archive metadata, and soft deletion.

Composite foreign keys prevent cross-organization classification, location, group, and parent links. Organization-level unique indexes protect animal number, ear tag, and RFID, including archived records.

## Animal numbering

If the caller omits `animal_number`, Laravel:

1. starts the animal-create transaction;
2. creates the organization sequence row if necessary;
3. locks that sequence row with `SELECT ... FOR UPDATE`;
4. consumes and increments `next_value`;
5. formats the value as `AN-000001`;
6. inserts the animal under the database unique constraint.

`SELECT MAX(number) + 1` is not used. A MySQL test releases two independent PHP processes concurrently and verifies that both requests commit different consecutive numbers and leave the next sequence value correct.

A user-supplied number requires `animals.manage_identifiers`. Creation itself remains idempotent, so a committed retry with the same idempotency key returns the original animal rather than consuming another number.

## Identifier normalization

Normalization occurs before validation and uniqueness checks:

- animal numbers are trimmed, uppercased, and internal spaces become hyphens;
- ear tags are trimmed/uppercased and spacing around supported separators is normalized;
- RFID values are trimmed/uppercased and spaces/hyphens are removed.

Animal number and ear tag accept uppercase letters, digits, `.`, `_`, `/`, and `-` after normalization. RFID is stored as an uppercase alphanumeric token. Empty optional values become null. Database uniqueness is authoritative.

## Validation rules

Classification requires an active controlled species and a breed in that organization/species. An unchanged historical inactive breed remains readable during an unrelated edit.

Initial location requires:

- a farm in the active organization that the membership can access;
- a shed in that same farm and organization;
- an optional group in that same farm and organization.

The normal edit endpoint prohibits `current_farm_id`, `current_shed_id`, and `current_animal_group_id`. Post-registration location changes are reserved for the Phase 2B movement workflow.

Parentage requires:

- no self-parent;
- female mother and male father;
- same-organization parents without disclosing cross-tenant existence;
- parent birth date earlier than child birth date when both are known;
- no direct or indirect cycle;
- historical archived parents may remain referenced.

## API

Implemented under `/api/v1`:

- `GET /animal-species`
- breed list/create/show/update/archive
- group list/create/show/update/archive
- animal list/create/show/update/archive/restore

Important creates accept `Idempotency-Key`. Updates and archive/restore actions require the current integer `version`; a stale version returns `412 STALE_VERSION`. Cross-tenant and unauthorized farm records are concealed with 404 policy behavior.

Animal search matches number, ear tag, RFID, and name. Allowlisted filters cover species, breed, sex, life stage, farm, shed, group, operational status, and archive state. Allowlisted sorting and a maximum page size of 100 prevent arbitrary/unbounded queries. The canonical contract is `apps/api/openapi.yaml`.

## Permissions and audit

Phase 2A permissions are:

- `animals.view`, `animals.create`, `animals.update`, `animals.archive`, `animals.restore`, `animals.manage_identifiers`;
- `animal_breeds.view`, `animal_breeds.manage`;
- `animal_groups.view`, `animal_groups.manage`.

Owner receives all. Manager receives animal view/create/update and breed/group management, but not archive/restore/identifier administration by default. Worker and viewer receive registry/reference read access only.

Audit events record organization, user, entity type/UUID, old/new values, request ID, and timestamp for breed/group create/update/archive and animal create/update/identifier-update/archive/restore. Raw audit records are not exposed by the animal Flutter screens.

## Flutter and Drift

Implemented screens:

- responsive animal list with debounced search and complete filters;
- add animal;
- animal details;
- edit permitted profile fields;
- archive confirmation and restore action;
- breed management;
- animal-group management.

Controls are permission-aware. Mobile uses cards; wider layouts use a horizontally safe data table. Loading, empty, error, retry, cached-data, offline, and sync indicators use the existing foundation components.

Drift schema version 2 adds local species, breeds, groups, and animals with tenant/farm scope, server UUID/version/timestamp, cache timestamp, archive state, search fields, and accessibility state. Bootstrap and incremental sync upsert repeated rows and archive tombstones transactionally. Removed farm access marks cached groups/animals inaccessible, and offline reads query only accessible records. Phase 2A never queues animal, breed, or group mutations in the outbox.

## Development seed

The repeatable seeder creates:

- 2 species;
- 6 named breeds;
- 4 groups across both development farms;
- 20 animals across farms and sheds;
- both sexes and all three life stages;
- active, inactive, and missing operational states;
- valid parent/child relationships;
- organization animal sequence `next_value = 21`.

It does not seed milk, breeding events, pregnancy, health, treatment, sales, death, feed, inventory, or finance data.

## Known limitations

- Animal/breed/group writes require connectivity; offline mutation handling is reserved for Phase 2C.
- Location changes, movement history, and movement approval are not implemented.
- Weight history, status history, QR, photos, timeline, and later dairy domains are not implemented.
- The Flutter parent selector loads a bounded authorized reference page; large herds will need server-backed parent typeahead/search in a later approved phase.
- Physical-device operation and production SQLite-at-rest controls remain release gates.
