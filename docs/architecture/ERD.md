# ERD

## Implemented Phase 2A registry

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
  ORGANIZATION ||--o{ AUDIT_LOG : records
```

Every tenant relationship shown above is constrained or scoped by organization; farm/shed/group links additionally use composite keys so a valid UUID from another tenant/farm cannot be linked. Parent links preserve historical archived rows.

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
