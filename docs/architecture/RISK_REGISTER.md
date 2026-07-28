# Risk Register

| ID | Risk | Likelihood / impact | Mitigation and verification | Owner/time |
|---|---|---|---|---|
| R1 | Cross-organization or unauthorized farm data leakage | M / Critical | Derived tenant context, scoped queries/policies, composite integrity checks, exhaustive isolation tests | Backend, Phase 1 onward |
| R2 | Offline retries duplicate milk, stock, or finance effects | H / Critical | UUIDv7, request hashes, durable idempotency, transactions, replay/concurrency tests | Sync/backend, Phase 1+ |
| R3 | Conflicts silently overwrite regulated/financial history | M / Critical | Versions, append/correction workflows, explicit conflict queue, audit preservation | All modules |
| R4 | Incorrect milk-withdrawal sale | M / Critical | Treatment-triggered restriction, sellable ledger separation, transaction locks, override approval/tests | Phases 3–4/6 |
| R5 | Derived balances drift from stock/milk/financial ledgers | M / High | Append-only movements/journals, atomic postings, reconciliation jobs and tests | Phases 3,5–7 |
| R6 | Repository/bootstrap choices drift across Flutter/Laravel | M / Medium | Root conventions, pinned supported versions, OpenAPI contract and CI | Phase 1 |
| R7 | Local device loss exposes farm/employee data | M / High | Secure tokens, minimized cache, device revocation, optional encrypted SQLite, remote session control | Phase 1+ |
| R8 | Unbounded sync/cache performs poorly on years of data | H / High | Cursor deltas, farm/feature windows, page limits, indexes, eviction and scale tests | Phase 1/8 |
| R9 | Backup exists but restore fails or files mismatch | M / Critical | Checksums, coordinated DB/files, immutable offsite copy, quarterly isolated restore drills | Ops/Phase 9 |
| R10 | Ambiguous local accounting/tax/payroll requirements cause redesign | H / High | Confirm jurisdiction and accounting policy before financial schema/posting | Before Phase 7 |
| R11 | Inconsistent units/timezones corrupt comparisons and business dates | M / High | Canonical units, explicit conversions, UTC instants, farm timezone/day service, boundary tests | Foundation+ |
| R12 | Permissions become broad and unreviewable | M / High | Capability catalog, conservative roles, separation of duties, permission diff/audit tests | Phase 1+ |
| R13 | Attachment malware, path traversal, or data leakage | M / High | Private storage, signature validation, safe names, scanning, authorized streams | First attachment phase |
| R14 | Audit logs leak sensitive values or can be altered | M / High | Redaction, append-only authorization/storage, integrity chaining/export controls | Phase 1+ |
| R15 | Large scope delays usable outcomes | H / High | Controlled vertical phases and per-feature definition of done; no placeholder modules | Every phase |
| R16 | Text encoding/mojibake damages documentation or localization | M / Medium | Standardize UTF-8/editorconfig in Phase 1; verify Urdu/RTL fixtures | Phase 1/9 |
| R17 | Concurrent or stale movement decisions corrupt current animal location | M / High | Animal/movement row locks, immutable source snapshots, optimistic versions, atomic projection/audit transaction, dedicated MySQL race test | Phase 2B onward |
| R18 | Approval setting or custom roles weaken movement separation of duties | M / High | Fail-safe approval default, per-request approval snapshot, distinct requester check, dual authority for immediate mode, role/setting review and tests | Phase 2B onward |
| R19 | Floating-point or inconsistent unit conversion corrupts longitudinal weights | M / High | Decimal-string API, integer millionths, exact lb factor, canonical kg, configurable maximum, boundary tests | Phase 2C onward |
| R20 | Concurrent corrections or status changes create multiple successors or stale projections | M / High | Row locks, unique supersession/sequence constraints, optimistic version, atomic projection/audit, MySQL race tests | Phase 2C onward |
| R21 | Revoked farm/permission access leaves sensitive weight/status data visible offline | M / High | Independent authorization flags, authorized farm reconciliation, inaccessible cache state, repository filtering and sync tests | Phase 2C onward |

Risk status is reviewed at each phase gate. Critical residual risks require owner acceptance before production deployment.
