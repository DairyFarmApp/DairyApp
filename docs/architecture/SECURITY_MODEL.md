# Security Model

## Trust boundaries

Flutter and its local database are untrusted clients. Laravel revalidates identity, tenant, farm access, permission, workflow state, versions, and business rules. MySQL, Redis, queues, storage, backups, admin tooling, and third parties have separate least-privilege credentials.

## Authentication and sessions

- Use Laravel Sanctum-style opaque personal access/session tokens for mobile/tablet; store only in platform secure storage. If browser deployment uses cookies, use Secure/HttpOnly/SameSite cookies plus CSRF protection, not browser local storage tokens.
- Short-lived access token plus rotating refresh/session secret; store server-side hashes, device UUID/name, created/last-used/IP/user-agent, expiry, and revocation timestamps.
- Support session listing and individual/all-device revocation. Password reset and deactivation revoke applicable sessions. Never queue offline writes after logout under a new user.
- Public owner signup atomically creates one isolated tenant/farm and a
  `primary_owner` membership. Reusable family signup is possible only with a
  valid owner-controlled secret. Invitation secrets are hashed for verification
  and encrypted for retrieval; link regeneration invalidates the previous
  secret. Signup endpoints are rate-limited.
- Family accounts are persistent, separate identities. Removing a family
  membership immediately revokes its active sessions. Only the primary owner
  may rotate/disable invitations or remove/restore family access; normal family
  farm permissions do not grant membership administration.
- Phase 1.1 stores hashed renewal history. Rotation revalidates under a row lock; reuse of a consumed credential revokes the session family and writes a redacted security audit event. Password changes revoke all existing sessions.
- Passwords use Laravel's current recommended adaptive hash. Login/reset endpoints are rate-limited; failed attempts use progressive delay/lock policy without account enumeration. MFA is an extension, strongly recommended for owners, finance, and administrators.

## Authorization

Permissions are granular capabilities assigned through organization-scoped roles. Policies require both capability and resource scope. Farm grants further restrict operational access. UI hiding is convenience only. Sensitive actions require step-up/recent authentication where appropriate and always audit reason/approval.

Baseline roles are documented in `PERMISSION_MATRIX.md`; custom roles may combine permissions but cannot grant platform super-admin. Support access is time-bound and audited.

Phase 2B movement policies require active organization membership, the explicit operation permission, and access to both source and destination farms. Approval-required requests enforce requester/approver separation inside the locked transaction, not only in Flutter. When approval is disabled, immediate application still requires separate request and approval capabilities. Cross-organization and unauthorized-farm identifiers are concealed, and composite database keys prevent cross-tenant/farm location links even if application validation regresses.

Phase 2C weight/status policies require an explicit record/correct/change/view-history capability plus access to the applicable farm. A weight correction additionally requires access to its observation farm and the animal's current farm. Cross-organization and unauthorized-farm identifiers are concealed as not found. Ordinary animal profile updates cannot change operational status, and immutable histories have no ordinary update/delete routes. Row locks, unique correction links, optimistic animal versions, composite foreign keys, and same-transaction audit protect concurrent and database-level invariants.

Inventory policies require `inventory.view` or `inventory.manage` plus active
membership and access to the session farm. Queries bind organization, farm, and
kind before resolving an item, so unauthorized UUIDs remain concealed. Item
updates recheck optimistic version under a row lock. Opening stock and
idempotent receipts update the batch projection and append the permanent
movement in one transaction; an ordinary item update cannot submit stock.

## Tenant and data protection

- Resolve active organization from authenticated membership. Ignore/reject mismatched payload tenant IDs.
- Scope every query, route binding, export, queue job, notification, cache key, attachment path, and sync cursor.
- Profile photos use private local storage and authenticated streamed responses.
  Member-photo lookup requires the active organization and conceals
  cross-organization identifiers.
- Use private storage, allowlisted MIME signatures/extensions, size limits, malware scanning where available, generated names, checksum, and authorized streamed downloads.
- HTTPS/HSTS in production; secrets only in environment/secret manager; encrypted backups; sensitive identity/bank fields encrypted at application layer where searching is unnecessary.
- Logs redact tokens, passwords, reset codes, identification/bank values, and attachment contents. Production errors never expose stack traces.

## Audit logging

Audit security and domain events: auth success/failure/logout, session changes, permission changes, CRUD/restore, approval/rejection, imports/exports, financial posting/reversal, stock/milk corrections, withdrawal overrides, file access where sensitive, backup/restore, and support access.

Audit rows contain UUID, organization, actor (nullable system), action, entity type/UUID, sanitized before/after or change set, reason, request/operation/device IDs, IP/user-agent, UTC timestamp, and optional previous-entry hash. They are append-only with no ordinary update/delete endpoint. Audit creation occurs in the same transaction as critical changes; high-volume read/access events may use a durable separate stream with monitoring. Restrict audit viewing and export, and audit those actions too.

## Operational controls

Dependency/security scanning, secret scanning, protected CI variables, least-privilege database accounts, queue isolation, rate limits, request size limits, CSP for web, backup restoration tests, incident response, and production access logging are release gates. Exact retention and breach/legal requirements need jurisdictional confirmation.
