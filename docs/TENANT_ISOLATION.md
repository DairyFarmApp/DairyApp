# Tenant and Farm Isolation

`users` are global identities; `organization_memberships` define active tenant participation. Roles belong to organizations and attach to memberships. `user_farm_access` restricts memberships unless `all_farms` is explicitly true.

The authenticated server-side session is the sole authority for `organization_id` and `farm_id`. Organization/farm headers, query parameters, payload fields, and route UUIDs cannot establish authority. Tenant middleware reloads an active membership on every tenant request. Controllers scope every organization, farm, shed, sync, and mutation query by that organization. Farm object access additionally calls `canAccessFarm`; inaccessible and foreign resources consistently resolve as 404 when a resource UUID is being concealed, while invalid context switches and revoked membership return 403.

Route UUIDs are deliberately passed to explicit tenant-scoped lookup methods rather than implicit unscoped Eloquent binding. Database composite foreign keys also prevent a shed, setting, role assignment, farm grant, or session farm context from being connected across organizations. Setting scope hashes also enforce one organization/farm/key value when `farm_id` is nullable. Model relations repeat the organization predicate as defense in depth.

Inactive and revoked memberships immediately fail tenant middleware. Sync responses are scoped to the current membership and include `authorized_farm_ids`; Drift marks previously cached, no-longer-authorized farm data unavailable. Spoofed `X-Organization-ID` and `X-Farm-ID` values are ignored.

Queue jobs, caches, exports, attachments, and file paths added later must carry organization context explicitly and re-check authorization. MySQL has no PostgreSQL-style row security, so automated cross-tenant/farm tests are mandatory for every endpoint.

Phase 1.2 ran every tenant test against MySQL 8.4.9 and directly attempted invalid shed, setting, farm-grant, membership-role, and session-membership inserts. MySQL rejected them. Duplicate role/permission pivots, setting scopes, and idempotency scopes were also rejected by physical constraints.
