# Environment and Local Development

## Verified toolchain on 2026-07-22

| Tool | Version/status |
|---|---|
| Flutter | 3.41.9 stable, framework revision `00b0c91f...` |
| Dart | 3.11.5 |
| PHP | 8.5.0, installed through Laravel's official `php.new` Windows installer |
| Composer | 2.8.12 |
| Laravel installer | 5.31.0 |
| Laravel framework | 13.21.1 |
| Node.js | 24.15.0 |
| Git | 2.54.0.windows.1 |
| MySQL | Oracle MySQL Community Server 8.4.9; local `MySQL84` service |
| PHP MySQL extensions | `mysqli` and `pdo_mysql` available |
| Android SDK | 36.1.0; platform/build-tools 36.1 installed |
| Android Java | Android Studio bundled OpenJDK 21.0.10 |

PHP/Composer live at `%USERPROFILE%\.config\herd-lite\bin`. Restart the terminal to use its PATH entry, or invoke `php.exe` and `composer.phar` there directly. Flutter lives at `C:\flutter`; a zero-byte System32 `flutter` file currently shadows it.

## API environment

This workstation has official Oracle MySQL Community Server 8.4.9 installed as automatic service `MySQL84`. It listens only on `127.0.0.1:3306`; X Protocol listens only on `127.0.0.1:33060`. Configuration is in `C:\ProgramData\MySQL\MySQL Server 8.4\my.ini`. No public firewall rule exists.

Local databases are `dairycare_dev` and `dairycare_test`. Laravel uses `dairycare_app@127.0.0.1`, which has only application DML plus schema-migration privileges on those databases. It has no global administrative privileges.

The ignored `.env` targets `dairycare_dev`; ignored `.env.testing` targets `dairycare_test`. Both resolve the user-scoped `DAIRYCARE_MYSQL_PASSWORD` environment variable. The local development seed resolves `DAIRYCARE_LOCAL_SEED_PASSWORD`. Real values must never be copied to `.env.example`, CI configuration, documentation, or Git.

The root secret is outside the repository at `%LOCALAPPDATA%\DairyCare\mysql84-root-password.txt` with restricted ACLs. Laravel must not use root.

Production must use `APP_DEBUG=false`, HTTPS, protected secrets, durable queue/cache configuration, separate migration/runtime/backup credentials, and an approved backup/restore plan. The default fast PHPUnit configuration remains isolated SQLite; the MySQL gate explicitly supplies the `dairycare_test` connection.

Run the local development lifecycle from `apps/api`:

```powershell
php artisan migrate:fresh --force
php artisan db:seed --force
php artisan migrate:rollback --force
php artisan migrate --force
php artisan db:seed --force
```

Run the MySQL suite with `APP_ENV=testing`, `DB_CONNECTION=mysql`, `DB_DATABASE=dairycare_test`, the local host/user/password values, and:

```powershell
php artisan test
```

Service management requires Administrator PowerShell:

```powershell
Get-Service MySQL84
Start-Service MySQL84
Stop-Service MySQL84
Restart-Service MySQL84
```

Uninstall only after backing up any required local data:

```powershell
Stop-Service MySQL84
& 'C:\Program Files\MySQL\MySQL Server 8.4\bin\mysqld.exe' --remove MySQL84
winget uninstall --id Oracle.MySQL --exact
```

Do not delete the ProgramData data directory until its absolute path and backup status are verified. See `docs/PHASE_1_2_MYSQL_VALIDATION.md` for the complete installation and validation evidence.

## Mobile environment

Compile-time values:

- `APP_ENV`: `development`, `staging`, or `production`.
- `API_BASE_URL`: complete versioned base such as `http://127.0.0.1:8000/api/v1`.

Never commit production URLs or credentials. Access and renewal tokens are stored through `flutter_secure_storage`; Drift contains only non-secret session metadata.

Android debug builds require the installed Android SDK, accepted licenses, and JDK 17 or newer. Emulator access to a host API uses `http://10.0.2.2:8000/api/v1`; a physical device needs a reachable HTTPS development endpoint or an explicitly approved local-network configuration.
