# ERD

## Implemented owner and family account relationships

```mermaid
erDiagram
  USER ||--o{ ORGANIZATION_MEMBERSHIP : has
  ORGANIZATION ||--o{ ORGANIZATION_MEMBERSHIP : admits
  ORGANIZATION ||--|| FARM_INVITE_LINK : owns
  FARM ||--|| FARM_INVITE_LINK : joins
  ORGANIZATION_MEMBERSHIP ||--o| FARM_INVITE_LINK : creates
  ORGANIZATION_MEMBERSHIP ||--o{ ORGANIZATION_MEMBERSHIP : invites
  USER ||--o{ API_SESSION : authenticates
  ORGANIZATION ||--o{ FARM : owns
```

One `primary_owner` creates and controls the reusable invite. Each accepted
invite creates another user with a persistent `family_admin` membership in the
same organization/farm. Removing access changes membership status and revokes
sessions; it does not delete identity or history.

## Implemented Phase 2A registry, Phase 2B movements, and Phase 2C measurements

```mermaid
erDiagram
  ORGANIZATION ||--o{ ANIMAL_BREED : owns
  ANIMAL_SPECIES ||--o{ ANIMAL_BREED : classifies
  ORGANIZATION ||--o{ ANIMAL_GROUP : owns
  FARM ||--o{ ANIMAL_GROUP : scopes
  SHED o|--o{ ANIMAL_GROUP : defaults
  ORGANIZATION ||--o{ ORGANIZATION_SEQUENCE : numbers
  ORGANIZATION ||--o{ ANIMAL : owns
  ANIMAL_SPECIES ||--o{ ANIMAL : classifies
  ANIMAL_BREED ||--o{ ANIMAL : classifies
  FARM ||--o{ ANIMAL : locates
  SHED ||--o{ ANIMAL : locates
  ANIMAL_GROUP o|--o{ ANIMAL : groups
  ANIMAL o|--o{ ANIMAL : mother
  ANIMAL o|--o{ ANIMAL : father
  USER ||--o{ ANIMAL : creates_or_updates
  ANIMAL ||--o{ ANIMAL_MOVEMENT : has_history
  ORGANIZATION ||--o{ ANIMAL_MOVEMENT : owns
  FARM ||--o{ ANIMAL_MOVEMENT : source
  FARM ||--o{ ANIMAL_MOVEMENT : destination
  SHED ||--o{ ANIMAL_MOVEMENT : source
  SHED ||--o{ ANIMAL_MOVEMENT : destination
  ANIMAL_GROUP o|--o{ ANIMAL_MOVEMENT : source
  ANIMAL_GROUP o|--o{ ANIMAL_MOVEMENT : destination
  USER ||--o{ ANIMAL_MOVEMENT : requests
  USER o|--o{ ANIMAL_MOVEMENT : decides
  ANIMAL ||--o{ ANIMAL_WEIGHT : has_history
  ORGANIZATION ||--o{ ANIMAL_WEIGHT : owns
  FARM ||--o{ ANIMAL_WEIGHT : observed_at
  USER ||--o{ ANIMAL_WEIGHT : records
  ANIMAL_WEIGHT o|--o| ANIMAL_WEIGHT : supersedes
  ANIMAL ||--o{ ANIMAL_STATUS_CHANGE : has_history
  ORGANIZATION ||--o{ ANIMAL_STATUS_CHANGE : owns
  FARM ||--o{ ANIMAL_STATUS_CHANGE : snapshots
  USER ||--o{ ANIMAL_STATUS_CHANGE : changes
  ORGANIZATION ||--o{ AUDIT_LOG : records
```

Every tenant relationship shown above is constrained or scoped by organization; operational farm links additionally use composite keys so a valid UUID from another tenant/farm cannot be linked. Parent links preserve historical archived rows. An approved movement atomically advances current location. A status command appends history and advances operational status/version atomically. Weight corrections retain and link both rows; latest weight excludes superseded observations.

## Implemented inventory core

```mermaid
erDiagram
  ORGANIZATION ||--o{ INVENTORY_ITEM : owns
  FARM ||--o{ INVENTORY_ITEM : stocks
  INVENTORY_ITEM ||--o{ INVENTORY_BATCH : has
  INVENTORY_ITEM ||--o{ STOCK_MOVEMENT : records
  INVENTORY_BATCH ||--o{ STOCK_MOVEMENT : posts
  USER ||--o{ INVENTORY_ITEM : creates_or_updates
  USER ||--o{ STOCK_MOVEMENT : records
  ORGANIZATION ||--o{ AUDIT_LOG : records
```

Item, batch, and movement rows repeat organization and farm identifiers so
composite foreign keys can reject cross-tenant or cross-farm links. The batch
quantity is a current projection; the append-only movement is the stock-event
history. Creating opening stock or receiving stock changes both atomically.

## Implemented Phase 3A daily milk production

```mermaid
erDiagram
  ORGANIZATION ||--o{ MILK_PRODUCTION_SLOT : owns
  FARM ||--o{ MILK_PRODUCTION_SLOT : scopes
  SHED ||--o{ MILK_PRODUCTION_SLOT : snapshots
  ANIMAL ||--o{ MILK_PRODUCTION_SLOT : produces
  MILK_PRODUCTION_SLOT ||--|{ MILK_ENTRY : revisions
  MILK_ENTRY o|--o| MILK_ENTRY : supersedes
  USER ||--o{ MILK_PRODUCTION_SLOT : creates
  USER ||--o{ MILK_ENTRY : records
  ORGANIZATION ||--o{ AUDIT_LOG : records
```

One slot uniquely identifies an animal, production date, and standard milking
session. Corrections append linked entry revisions; quantities on superseded
rows remain unchanged. Repeated organization, farm, shed, and animal scope is
protected by composite foreign keys.

## Product-wide preliminary ERD

This remaining module-level ERD is intentionally preliminary and does not imply that later tables exist.

```mermaid
erDiagram
  USER ||--o{ ORGANIZATION_MEMBERSHIP : has
  ORGANIZATION ||--o{ ORGANIZATION_MEMBERSHIP : admits
  ORGANIZATION_MEMBERSHIP }o--o{ ROLE : receives
  ROLE }o--o{ PERMISSION : grants
  ORGANIZATION_MEMBERSHIP ||--o{ USER_FARM_ACCESS : scoped_to
  ORGANIZATION ||--o{ FARM : owns
  FARM ||--o{ SHED : contains
  SHED ||--o{ PEN : contains
  FARM ||--o{ WAREHOUSE : contains
  FARM ||--o{ MILK_TANK : contains

  ORGANIZATION ||--o{ ANIMAL : owns
  FARM ||--o{ ANIMAL : locates
  ANIMAL ||--o{ ANIMAL_MOVEMENT : moves
  ANIMAL ||--o{ ANIMAL_WEIGHT : weighs
  ANIMAL ||--o{ ANIMAL_STATUS_CHANGE : status_history
  ANIMAL ||--o{ MILK_ENTRY : produces
  MILK_SESSION ||--o{ MILK_ENTRY : groups
  MILK_ENTRY }o--o{ MILK_COLLECTION_BATCH : contributes
  MILK_COLLECTION_BATCH ||--o{ MILK_TANK_MOVEMENT : posts
  MILK_TANK ||--o{ MILK_TANK_MOVEMENT : holds
  MILK_COLLECTION_BATCH ||--o{ MILK_QUALITY_TEST : tested_by

  ANIMAL ||--o{ BREEDING_SERVICE : receives
  ANIMAL ||--o{ PREGNANCY : has
  PREGNANCY ||--o| CALVING_EVENT : ends_with
  CALVING_EVENT ||--|{ CALVING_OFFSPRING : produces
  ANIMAL ||--o{ CALVING_OFFSPRING : is_offspring
  ANIMAL ||--o{ HEALTH_CASE : has
  HEALTH_CASE ||--o{ TREATMENT : receives
  TREATMENT ||--|{ TREATMENT_MEDICINE : uses
  MEDICINE ||--o{ TREATMENT_MEDICINE : prescribed
  TREATMENT ||--o{ MILK_RESTRICTION : causes

  INVENTORY_ITEM ||--o{ INVENTORY_BATCH : batched_as
  INVENTORY_BATCH ||--o{ STOCK_MOVEMENT : moved_by
  WAREHOUSE ||--o{ STOCK_MOVEMENT : source_or_destination
  SUPPLIER ||--o{ PURCHASE_ORDER : receives
  PURCHASE_ORDER ||--o{ GOODS_RECEIPT : fulfilled_by
  GOODS_RECEIPT ||--o{ STOCK_MOVEMENT : posts
  CUSTOMER ||--o{ MILK_SALE : buys
  MILK_SALE ||--o{ MILK_TANK_MOVEMENT : posts
  MILK_SALE ||--o{ JOURNAL_ENTRY : posts
  JOURNAL_ENTRY ||--|{ JOURNAL_LINE : contains
  ACCOUNT ||--o{ JOURNAL_LINE : classifies

  ORGANIZATION ||--o{ AUDIT_LOG : records
  ORGANIZATION ||--o{ APPROVAL : governs
  SYNC_DEVICE ||--o{ SYNC_OPERATION : submits
```

Cross-cutting attachments, alerts, approvals, and audit entries reference an allowlisted entity type plus UUID. Application services verify same-tenant ownership because ordinary foreign keys cannot enforce a polymorphic target.
