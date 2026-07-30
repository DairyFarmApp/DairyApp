# Scripts

Repository automation must remain reviewed, explicit, and free of embedded
credentials.

The root `RUN_DAIRYCARE.bat` is the supported Windows development launcher. It:

- verifies the repository, PHP, Flutter, Laravel dependencies, `.env`, and
  `APP_KEY`;
- reads the MySQL application password from the user environment without
  displaying or writing it;
- starts the local `MySQL84` service when Windows permissions allow;
- applies only pending migrations with `artisan migrate --force`;
- starts the Laravel API on `127.0.0.1:8000`; and
- starts Flutter in Chrome with the development API URL.

It deliberately does not run `migrate:fresh`, seed data, regenerate `APP_KEY`,
install Composer packages, or embed credentials. Run
`RUN_DAIRYCARE.bat --check` from a terminal for a non-launching preflight.
