# Phase 1.2 MySQL 8 Validation

Date: 2026-07-23. Scope: local MySQL 8 installation and validation of the existing Phase 1 foundation only. No Phase 2 product module was started.

## Installation and isolation

| Item | Verified value |
|---|---|
| Product | Oracle MySQL Community Server 8.4.9, MySQL Community Server - GPL |
| Installer | Official Oracle x64 MSI installed by WinGet package `Oracle.MySQL` |
| Installer URL | `https://cdn.mysql.com/Downloads/MySQL-8.4/mysql-8.4.9-winx64.msi` |
| Installer SHA-256 | `7c3caede97bb4af923505a92e0b9c9fab1e5074a841b632387af7fb059afbd1e` |
| Windows service | `MySQL84`, automatic, running as `LocalSystem` |
| Server configuration | `C:\ProgramData\MySQL\MySQL Server 8.4\my.ini` |
| Data directory | `C:\ProgramData\MySQL\MySQL Server 8.4\Data` |
| TCP | `127.0.0.1:3306` only |
| X Protocol | `127.0.0.1:33060` only |
| Firewall | No MySQL/3306 Windows Firewall rule was created |
| Character set/collation | `utf8mb4` / `utf8mb4_0900_ai_ci` |
| SQL mode | `STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION` |
| Default engine | InnoDB |

Pre-installation checks found no MySQL/MariaDB installation or service, no listener on port 3306, and no existing MySQL data directory. The workstation is 64-bit Windows 10 Pro Education build 26200. Administrator elevation was required for the MSI, ProgramData initialization, and Windows service registration. No PHP, Flutter, Android, web-server, production, customer, or remote database configuration was changed.

The first configuration run initialized the server and service but stopped before credential creation because Windows PowerShell 5.1 lacked a static random-number API used by the script. The compatible cryptographic API then completed bootstrap immediately. Root had an empty password only during this local-only bootstrap interval. No raw credential was printed or committed.

## Databases, account, and secrets

- `dairycare_dev`: local Laravel development and endpoint validation.
- `dairycare_test`: isolated MySQL migration and automated-test database.
- `dairycare_app@127.0.0.1`: dedicated application/migration account.

The application user has only `SELECT`, `INSERT`, `UPDATE`, `DELETE`, `CREATE`, `DROP`, `REFERENCES`, `INDEX`, and `ALTER` on the two DairyCare databases. It has no global administrative privilege and Laravel does not use root.

The generated application password is stored in the user-scoped `DAIRYCARE_MYSQL_PASSWORD` environment variable. The ignored `.env` and `.env.testing` files resolve that variable instead of containing its value. The generated local seeder password similarly uses `DAIRYCARE_LOCAL_SEED_PASSWORD`. The root secret is outside the repository at `%LOCALAPPDATA%\DairyCare\mysql84-root-password.txt` with inherited ACLs removed. No secret is present in `.env.example`, Git-visible files, command output, logs, audit records, or database token columns.

## Migration, seed, and endpoint results

Against `dairycare_dev`, the final schema passed:

1. `migrate:fresh`
2. seed
3. a second consecutive seed
4. full rollback
5. migration after rollback
6. seed twice after remigration
7. `migrate:fresh` over populated records
8. seed twice after the final fresh migration
9. migration status

The original seeder failed on a second run because permissions used unconditional inserts. It was changed to deterministic `firstOrCreate`, `updateOrCreate`, and pivot `sync` operations. Repeated runs now preserve exactly one organization, two farms, four sheds, four users, seventeen permissions, four roles, and four memberships.

The final schema also passed fresh migration and two consecutive seeds against `dairycare_test`. A real Laravel HTTP server connected to `dairycare_dev` successfully exercised login, renewal, organization listing, farm listing, farm creation, shed creation, and archive cleanup. That run produced the expected login, renewal, creation, archive, audit, and idempotency evidence before the required final fresh-migration reset.

## Schema inspection

Direct `information_schema` inspection of the final `dairycare_dev` schema confirms:

- 24 of 24 tables use InnoDB.
- 24 of 24 tables use `utf8mb4_0900_ai_ci`.
- 24 primary keys.
- 27 foreign keys, including 8 composite tenant foreign keys.
- 17 non-primary unique indexes.
- 39 secondary indexes.
- 48 UUID columns stored as `CHAR(36)`.
- 5 native JSON columns.
- 45 `TIMESTAMP(0)` columns; 40 are nullable.

Primary, unique, and secondary indexes cover UUID identities, tenant/code uniqueness, token hashes, renewal history, session expiry/revocation, audit lookup, farm/shed lookup, pivots, sync queries, and idempotency scope.

Database enforcement was executed—not inferred—for:

- Cross-organization shed/farm combinations.
- Cross-organization farm grants.
- Cross-organization membership-role assignments.
- Cross-organization farm settings.
- Session organization membership.
- Duplicate membership-role and permission-role assignments.
- Duplicate idempotency scope hashes.
- Duplicate organization-level setting scopes.

The MySQL review found that the original nullable settings unique index could admit repeated organization-level keys and its farm foreign key was not tenant-composite. The final migration uses a deterministic 64-character setting scope hash plus `settings(farm_id, organization_id) -> farms(id, organization_id)`.

Referential actions are deliberate: owned tenant records generally cascade, audit user/organization references and optional sync actors become null, renewal history cascades with its session, and tenant-composite assignments cannot cross organizations.

## Authentication concurrency

`MySqlConcurrencyTest` starts two independent PHP/Laravel processes with separate database connections, waits until both are ready, and releases them together.

For renewal credential A:

- Exactly one contender initially rotates and returns 200.
- The second contender observes consumed A after the row lock and returns the generic 401.
- Reuse revokes the single session family and timestamps `renewal_reuse_detected_at`.
- The first contender's replacement access and renewal credentials are invalid after family revocation.
- One `auth.session_renewed` and one `auth.renewal_reuse_detected` audit event exist.
- Only two hashed renewal-history rows exist; exactly the original is consumed.
- Raw A and replacement credentials are absent from session rows, renewal rows, audits, and Laravel logs.
- No parallel session family is created.

This is the documented strict policy: a stale racing credential is treated as possible theft, so the entire family is revoked even though one rotation initially succeeded.

## Idempotency concurrency

Two independent processes sent semantically identical farm creates with the same key but different JSON object-key order.

- Both callers received the committed 201 representation.
- Both responses referenced the same farm UUID.
- Exactly one farm and one completed idempotency record were committed.
- The contender waited for the winning transaction; it did not receive an incomplete cached result.
- A later valid retry replayed the committed response.
- Reusing the key with different data returned `IDEMPOTENCY_KEY_REUSED`.
- A deliberately failed domain transaction left neither a farm nor an idempotency record.
- Organization, user, device, method, and endpoint variations produced distinct scope hashes.

## Test and build results

| Gate | Result |
|---|---|
| Laravel Pint | Passed |
| MySQL Laravel suite | 31 passed, 204 assertions |
| MySQL-only concurrency suite | 4 passed, 58 assertions in its focused run |
| SQLite portability suite | 27 passed, 146 assertions; 4 MySQL-only tests skipped |
| API routes | 23 |
| Composer validation | Passed |
| Composer audit | Zero advisories and zero abandoned packages |
| Flutter format | 42 files clean after formatting one test file |
| Flutter analysis | No issues |
| Flutter tests | 18 passed |
| Android debug APK | Passed |

APK: `apps/mobile/build/app/outputs/flutter-apk/app-debug.apk`, 158,342,541 bytes, SHA-256 `7EE74F9871E8F3FBA0DFF79F1EB6BCAB07116E7AC65ADE313C51901E42DF4C1E`.

## Service management and removal

Run service commands from an Administrator PowerShell:

```powershell
Get-Service MySQL84
Start-Service MySQL84
Stop-Service MySQL84
Restart-Service MySQL84
```

To uninstall after separately backing up any required local data:

```powershell
Stop-Service MySQL84
& 'C:\Program Files\MySQL\MySQL Server 8.4\bin\mysqld.exe' --remove MySQL84
winget uninstall --id Oracle.MySQL --exact
```

The MSI/service removal may leave `C:\ProgramData\MySQL\MySQL Server 8.4\Data`. Do not delete it until its absolute path, backup status, and lack of required databases have been verified. Remove the user-scoped DairyCare environment variables and local root-secret file separately only when the development environment is intentionally retired.

## Remaining limitations and readiness

- Hosted CI has not run because the repository has no remote.
- Physical-device behavior, production Android signing, production HTTPS/secrets, backup restoration, and SQLite-at-rest threat modeling remain later gates.
- The local server is a single Windows MySQL instance; replication, failover, load, production backup, and disaster recovery were not tested.
- MySQL timestamps currently have zero fractional precision. The sync cursor's overlap/upsert design protects current reference sync; high-frequency future modules should decide whether microsecond precision is required before introducing their migrations.

**Phase 2 readiness:** the Phase 1.2 MySQL gate passes. The existing foundation is technically ready for the project owner to approve a separately scoped Phase 2, but Phase 2 remains unapproved and no animal-management code was added.
