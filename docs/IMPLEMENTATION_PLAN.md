# Controlled Implementation Plan

## Phase 0 — Discovery and architecture (completed)

Inventory the repository; document architecture, database/ERD, module boundaries, offline sync, security, API, permissions, testing, risks, backups, and controlled phases. No code, migrations, dependencies, or product modules.

## Phase 1 — Foundation (implemented 2026-07-22)

Initialize a deliberate monorepo with `apps/mobile/` and `apps/api/`; pin supported Flutter/Dart, PHP/Laravel, MySQL, and optional Redis versions; add environment examples, CI, formatting/static analysis, and test harnesses. Implement only:

- Laravel authentication/session lifecycle, user identity, organization membership, roles/permissions, farm access, organization, farm, and shed APIs.
- Tenant/farm middleware, policies, request IDs, response/error envelope, idempotency primitive, and append-only audit foundation.
- Flutter responsive authenticated shell, login/logout/session management, organization/farm context, Riverpod/GoRouter/Dio foundations, safe errors, localization foundation.
- Drift database schema/migration harness for foundation reference cache, outbox, conflicts, cursors, devices; a minimal sync handshake/reference pull proving idempotent transport without implementing product transactions.
- OpenAPI and automated authentication, authorization, tenant-isolation, API contract, Drift, repository, sync-foundation, and responsive widget tests.

Exclude animals, milk, health, inventory, finance, placeholder screens, demo data for future modules, advanced conflict UI, notifications, and deployment to production.

Phase 1 exit: clean initialization reproducible; authentication/session revocation works; organization/farm/shed CRUD respects permission and tenant isolation; Flutter uses the API and caches allowed foundation data; sync foundation demonstrates safe replay; audit is verified; relevant gates actually pass.

Completion evidence is recorded in `docs/PHASE_1_COMPLETION.md`.

## Phase 1.1 — Foundation hardening and platform validation (implemented 2026-07-22)

Re-audit and harden only Phase 1 authentication/session security, login protection, tenant/database boundaries, idempotency, audit redaction, Drift outbox/cursors/tombstones, migration organization, Android build configuration, CI, and documentation. The foundation migration is split into five domain groups, renewal reuse revokes its session family, context authority remains server-side, and Android debug compilation passes.

At Phase 1.1 completion, local MySQL execution remained pending because no approved MySQL 8 server or container runtime was present. That gate was subsequently completed in Phase 1.2. Phase 2 remained unapproved and was not started.

## Phase 1.2 — MySQL 8 validation gate (implemented 2026-07-23)

Install and isolate official MySQL Community Server 8.4, configure least-privilege development/test databases, execute migration/rollback/repeatable-seed and real endpoint checks, inspect physical metadata, prove tenant constraints, and exercise renewal/idempotency races with independent connections/processes. Correct only foundation defects exposed by MySQL, then rerun backend, Flutter, Android, and dependency gates.

Completion evidence is recorded in `docs/PHASE_1_2_MYSQL_VALIDATION.md`. The gate passes: MySQL has 31 passing tests with 204 assertions, SQLite portability remains green, Flutter has 18 passing tests, and Android debug compilation passes.

## Phase 2A — Animal Registry Core (implemented 2026-07-23)

Implement controlled species, organization breeds, farm groups, animal registration/numbering/profile/search/filter/archive/restore, initial location, parentage, permissions, audit, MySQL persistence, responsive Flutter workflows, and Drift authorized read caching.

Phase 2A explicitly excludes movements, weights, status history, QR, photos, offline animal mutation, timeline, milk, breeding, health, inventory, finance, and all later domains. MySQL has 44 passing tests with 366 assertions; SQLite portability has 294 assertions; Flutter has 33 passing tests; Android debug compilation passes.

Completion evidence is recorded in `docs/PHASE_2A_COMPLETION.md`.

## Phase 2B — Online animal movements (implemented 2026-07-23)

Implemented request/approve/reject/cancel movement commands, tenant/farm/shed/group validation, row-locked atomic current-location projection updates, immutable movement history, separation of duties, permissions, audit, responsive Flutter review/history UI, and authorized Drift read caching. MySQL has 56 passing tests with 501 assertions; SQLite portability has 409 assertions; Flutter has 46 passing tests; Android debug compilation passes.

Completion evidence is recorded in `docs/PHASE_2B_COMPLETION.md`.

## Phase 2C — Animal weights and operational-status history (implemented 2026-07-23)

Implement online weight recording, exact unit normalization, immutable correction links, latest-weight projection, dedicated operational-status changes, row-locked versioned projection updates, granular permissions, audit events, responsive Flutter forms/history, and authorized Drift read caching.

Phase 2C deliberately keeps all animal mutations online-only. It does not extend the outbox or implement QR, photos, a combined timeline, milk, breeding, health, inventory, or any later domain. Completion evidence is recorded in `docs/PHASE_2C_COMPLETION.md`.

## Phase 2 UX and web stabilization (implemented 2026-07-29)

Stabilize the implemented Phase 1 and Phase 2A-2C client before another product
capability. Add the version-matched Drift browser runtime, a responsive
DairyCare visual system, polished authentication and context selection,
permission-aware navigation, a real-data dashboard, and safe loading/error
states. Validate desktop and phone layouts in Chrome and rebuild web and
Android artifacts.

This stabilization introduces no API endpoint, migration, database module, or
later dairy feature. Completion evidence is recorded in
`docs/PHASE_2_UX_WEB_STABILIZATION_COMPLETION.md`.

## Owner onboarding and family access (implemented 2026-07-29)

Add self-service creation of one private named farm, direct single-farm login,
editable owner/family profiles and private photos, a reusable primary-owner
invitation link, multiple persistent family logins, and owner-controlled
removal/restoration with immediate session revocation. Keep family management
with the primary owner while granting family accounts the same implemented
farm-work capabilities.

This controlled phase excludes employee accounts, custom roles, email delivery,
password reset, email verification, MFA, ownership transfer, multi-farm
self-service accounts, and production deep links. Completion evidence is in
`docs/OWNER_ONBOARDING_COMPLETION.md`.

## Inventory core, actions, exports, and glass appearance (implemented 2026-07-29 through 2026-07-30)

Add controlled medicine, semen, and feed inventory selection and overviews,
batch-backed opening stock, idempotent stock receipts, low/expiry/value
summaries, search/category/supplier filters, role/farm isolation, audit,
OpenAPI, and responsive Flutter tables/cards/forms. Add persistent glass
`System`, `White`, and `Dark` appearance choices across authentication and the
authenticated shell. The approved extension adds metadata edit controls,
versioned zero-stock archival, single/combined PDF receipts, selected
date-filtered XLSX exports, calendar pickers, export authorization, and export
audit events.

This controlled core keeps inventory online-only and excludes issue,
consumption, damage, expiry write-off, adjustment, transfer, purchasing,
supplier master data, ration plans, accounting valuation, barcode scanning,
notifications, and offline inventory sync. Completion evidence is in
`docs/INVENTORY_GLASS_THEME_COMPLETION.md`.

## Later phases

1. **Remaining Phase 2 Animals:** only separately approved QR, photos, search-scale, lifecycle/death, or combined-timeline work; offline animal mutation remains a separate explicit decision.
2. **Phase 3A Daily Milk (implemented 2026-07-30):** morning/afternoon/evening quick entry, real daily totals, duplicate prevention, immutable correction revisions, permissions/audit, Drift cache, and idempotent offline outbox.
3. **Remaining Phase 3 Milk:** custom sessions, lactations, supervisor approval, collection batches, tanks/movement ledger, withdrawal, quality/balance, production reports and alerts.
4. **Phase 4 Health and breeding:** cases/treatments/withdrawals, vaccination/deworming, heat/service/pregnancy/calving/offspring.
5. **Phase 5 Feed and inventory expansion:** issue/consumption, transfer/adjustment, ration/feed workflows, purchasing integration, warehouse support, costing, and notifications on the implemented item/batch/movement core.
6. **Phase 6 Purchasing, customers, sales:** procure-to-receipt, supplier/customer ledgers, milk sales/delivery/returns/payments.
7. **Phase 7 Finance and workforce:** PKR-only income/expense double-entry using an internal Farm Funds balancing account with no user-facing cash/bank/wallet setup; monthly employees/payroll; and employee loans with payroll installment recovery and immutable financial posting.
8. **Phase 8 Equipment, reports, advanced offline:** assets/maintenance, cross-domain/financial reports and exports, broader offline operations and conflict resolution, backup monitoring.
9. **Phase 9 Hardening/release:** security/performance/data integrity/accessibility/localization, restore drill, production deployment and manuals.

## Approval gates

Each phase or subphase begins only after explicit approval of its exact scope, inspects the current implementation, adds no unrelated modules, and ends with the prescribed completion report. Database changes are introduced only in the phase owning them. Architecture decisions are updated as approved decisions, not silently changed.

## Genuinely blocking questions

None block Phase 1 foundation if its assumptions are accepted. These block later specialized work or production readiness:

1. Before Phase 7: country/jurisdiction, tax method, chart-of-accounts expectations, fiscal locking, payroll/statutory rules, and base/multi-currency policy.
2. Before production planning: hosting provider/topology, data residency, target RPO/RTO, retention periods, expected organization/farm/user/device/data volumes, and availability target.
3. Before organization membership UX is finalized: can one human belong to multiple customer organizations, and can a single device be shared by workers?
4. Before restricted-milk workflow finalization: applicable regulatory rules and whether any override is legally permitted.
