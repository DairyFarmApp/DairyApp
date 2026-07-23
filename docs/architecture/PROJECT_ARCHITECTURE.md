# Project Architecture

Status: Phase 0 proposal updated through implemented Phase 2A, 2026-07-23. Later-domain sections remain guidance unless explicitly marked implemented.

## Repository baseline

The original Phase 0 inspection found only `AGENTS.md` and the master specification. That statement is historical. The current repository contains the Phase 1 foundation/hardening, verified MySQL 8.4 environment, and Phase 2A animal registry across Flutter, Laravel, Drift, migrations, tests, documentation, and CI.

Phase 2A follows the modular-monolith topology: `app/Domain/AnimalRegistry` owns registry rules, while Flutter `features/animals` owns the feature layers. No movement, weight, QR, photo, offline-mutation, timeline, or later dairy domain was initialized.

## Recommended topology

Use a modular monolith first:

```text
Flutter mobile/tablet/web client
  | HTTPS JSON REST /api/v1
  v
Laravel API modular monolith
  |-- MySQL (authoritative transactional store)
  |-- Redis (queues, cache, rate limits; optional locally)
  |-- private object/file storage
  |-- queue workers and scheduler
  `-- encrypted database/file backups
```

This deployment is simpler to transact, audit, test, and operate than early microservices. Domain boundaries must remain explicit so high-load reporting or integrations can later be extracted. The server is authoritative; clients never reconcile balances independently.

## Cross-cutting decisions

- UUIDv7 identifiers are generated client-side for sync-capable records and server-side otherwise; APIs expose UUIDs only.
- UTC is stored and exchanged as RFC 3339 timestamps; farm timezones control display and business-day boundaries.
- Money and measured quantities use explicit decimal precision and unit codes, never binary floating point.
- Tenant-owned rows carry `organization_id`; operational rows also carry `farm_id` when a farm context exists.
- Important transactional records are append-only or corrected by reversal/supersession. Soft deletion is reserved for appropriate master data and drafts.
- Laravel policies plus tenant-scoped query services enforce authorization. Flutter permission checks improve UX but are not security boundaries.
- Queues handle notifications, imports, exports, and expensive reports. Scheduled jobs generate due alerts and monitor backups.
- OpenAPI is the contract between backend and generated/typed Flutter DTOs.

## Flutter architecture

Feature-first clean boundaries, without pre-creating unused feature folders:

```text
apps/mobile/lib/
  app/                 # bootstrap, router, theme, localization, app shell
  core/
    api/               # Dio client, auth/request-id/error interceptors
    auth/              # secure session state
    database/          # Drift database and migrations
    errors/            # typed failures
    network/           # connectivity hints (not truth of reachability)
    permissions/       # UI capability evaluation
    sync/              # outbox/inbox orchestration
    storage/           # secure secrets and attachment cache
    widgets/           # genuinely shared UI only
  features/<feature>/
    domain/            # entities, value objects, repository contracts
    application/       # use cases and Riverpod providers/controllers
    data/              # API/local DTOs, mappers, repository implementation
    presentation/      # pages and feature widgets
  main.dart
```

Dependencies point inward: presentation -> application -> domain; data implements domain contracts. Widgets do not call Dio or Drift. Repositories coordinate local cache, remote API, and sync state. GoRouter routes are permission-aware. Localization is required from the first user-facing screen.

## Laravel architecture

Use standard Laravel conventions with domain modules inside `app/Domain`, avoiding a separate service deployment per module:

```text
apps/api/
  app/
    Domain/<Module>/
      Actions/          # transactional use cases
      Data/             # command/query DTOs
      Models/
      Policies/
      Queries/          # tenant-scoped reads
      Rules/
      Events/
    Http/
      Controllers/Api/V1/
      Requests/Api/V1/
      Resources/Api/V1/
      Middleware/
    Support/{Audit,Idempotency,Tenancy,Sync}/
    Jobs/ Listeners/ Console/
  routes/api.php
  database/{migrations,factories,seeders}/
  tests/{Feature,Unit}/
  openapi.yaml
```

Controllers remain thin: request validation -> action/query -> API resource. Multi-record state transitions execute in database transactions. Models are never serialized directly. Domain events trigger after commit where consumers depend on committed data.

## Organization and farm isolation

`organization_id` is derived from the authenticated membership/session, never trusted from arbitrary request input. A user may have memberships in multiple organizations, but every token/session has one active organization context. Farm access is the intersection of organization membership, role permissions, and `user_farm_access` grants. Organization owners may receive all-farm access explicitly.

Tenant-aware query builders/scopes are mandatory, but global scopes alone are insufficient: policies verify organization and farm ownership for every object operation. Composite foreign keys or validation guards prevent cross-tenant references. Queue jobs carry organization context explicitly and re-authorize access. Cache keys, exports, files, logs, and websocket channels are tenant namespaced. Super-administration is a separate platform capability with audited impersonation/support access, not a tenant role shortcut.

## Backup and restoration

- Automated encrypted MySQL full backups daily with point-in-time recovery via binary logs where hosting supports it.
- Private-file storage is versioned and replicated/backed up independently; database and file backup timestamps are coordinated.
- Suggested starting retention: 7 daily, 5 weekly, 12 monthly copies, subject to owner/legal approval.
- Store backups in a separate account/location with least-privilege credentials, immutable retention where available, checksums, and failure alerts.
- Restore only through a documented runbook: select recovery point, restore into isolated environment, verify checksums/schema/file links/tenant counts, obtain authorization, schedule downtime, restore production, rotate secrets if needed, and record an audit event.
- Perform a restoration drill at least quarterly and before release; a successful backup job alone is not evidence of recoverability.

## Assumptions and decisions requiring confirmation

Phase 1 can proceed with: one active organization per session; UUIDv7; Laravel token sessions appropriate for mobile clients; and PostgreSQL-style row security is unavailable because MySQL is prescribed, so isolation is application plus schema constraints. Business-policy values (currency, units, approval thresholds, numbering) are organization/farm configuration rather than hard-coded.

No question blocks Phase 1 foundation architecture. Before financial posting and production deployment, the owner must confirm jurisdiction/tax/accounting rules, required retention, target hosting/RPO/RTO, and whether organization membership can span multiple organizations.
