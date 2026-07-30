@echo off
setlocal EnableExtensions DisableDelayedExpansion

set "DAIRYCARE_ROOT=%~dp0"
set "DAIRYCARE_API_DIR=%DAIRYCARE_ROOT%apps\api"
set "DAIRYCARE_MOBILE_DIR=%DAIRYCARE_ROOT%apps\mobile"
set "DAIRYCARE_PHP=%USERPROFILE%\.config\herd-lite\bin\php.exe"
set "DAIRYCARE_FLUTTER=C:\flutter\bin\flutter.bat"
set "DAIRYCARE_API_URL=http://127.0.0.1:8000/api/v1"

if /I "%~1"=="--api" goto run_api
if /I "%~1"=="--app" goto run_app

title DairyCare Launcher
echo.
echo ============================================================
echo                    DairyCare Launcher
echo ============================================================
echo.

call :validate_installation
if errorlevel 1 goto failed

if /I "%~1"=="--check" (
    call :check_mysql_running
    if errorlevel 1 goto failed
    echo.
    echo All DairyCare launcher checks passed.
    exit /b 0
)

call :ensure_mysql_running
if errorlevel 1 goto failed

call :is_api_ready
if not errorlevel 1 (
    echo Laravel API is already running at %DAIRYCARE_API_URL%.
    goto start_flutter
)

call :is_api_port_in_use
if not errorlevel 1 (
    echo.
    echo ERROR: Port 8000 is being used by another program.
    echo Close that program, then run this file again.
    goto failed
)

echo Starting Laravel API...
start "DairyCare API" "%ComSpec%" /k call "%~f0" --api

echo Waiting for the API to finish migrations and start...
call :wait_for_api
if errorlevel 1 (
    echo.
    echo ERROR: The Laravel API did not start within 60 seconds.
    echo Read the error shown in the "DairyCare API" window.
    goto failed
)

:start_flutter
echo Starting Flutter in Chrome...
start "DairyCare Flutter" "%ComSpec%" /k call "%~f0" --app

echo.
echo DairyCare is starting successfully.
echo.
echo - Laravel API: %DAIRYCARE_API_URL%
echo - Flutter: Chrome will open automatically.
echo - To stop: press Ctrl+C in both DairyCare command windows,
echo   or close those two windows.
echo.
timeout /t 5 /nobreak >nul
exit /b 0

:run_api
title DairyCare API
call :validate_api_installation
if errorlevel 1 goto child_failed
call :load_mysql_password
cd /d "%DAIRYCARE_API_DIR%"
echo.
echo Applying pending DairyCare database migrations...
"%DAIRYCARE_PHP%" artisan migrate --force
if errorlevel 1 (
    echo.
    echo ERROR: Database migration failed. The API was not started.
    goto child_failed
)
echo.
echo Starting Laravel at http://127.0.0.1:8000 ...
"%DAIRYCARE_PHP%" artisan serve --host=127.0.0.1 --port=8000
goto child_finished

:run_app
title DairyCare Flutter
call :validate_mobile_installation
if errorlevel 1 goto child_failed
cd /d "%DAIRYCARE_MOBILE_DIR%"
echo.
echo Resolving Flutter packages...
call "%DAIRYCARE_FLUTTER%" pub get
if errorlevel 1 (
    echo.
    echo ERROR: Flutter package resolution failed.
    goto child_failed
)
echo.
echo Starting DairyCare in Chrome...
call "%DAIRYCARE_FLUTTER%" run -d chrome ^
    --dart-define=APP_ENV=development ^
    --dart-define=API_BASE_URL=%DAIRYCARE_API_URL%
goto child_finished

:validate_installation
call :validate_api_installation
if errorlevel 1 exit /b 1
call :validate_mobile_installation
if errorlevel 1 exit /b 1
exit /b 0

:validate_api_installation
if not exist "%DAIRYCARE_API_DIR%\artisan" (
    echo ERROR: Laravel was not found at:
    echo %DAIRYCARE_API_DIR%
    exit /b 1
)
if not exist "%DAIRYCARE_PHP%" (
    echo ERROR: PHP was not found at:
    echo %DAIRYCARE_PHP%
    exit /b 1
)
if not exist "%DAIRYCARE_API_DIR%\vendor\autoload.php" (
    echo ERROR: Laravel packages are missing.
    echo Run "composer install" inside apps\api, then try again.
    exit /b 1
)
if not exist "%DAIRYCARE_API_DIR%\.env" (
    echo ERROR: apps\api\.env is missing.
    echo Copy .env.example to .env and configure the local database first.
    exit /b 1
)
findstr /B /C:"APP_KEY=base64:" "%DAIRYCARE_API_DIR%\.env" >nul
if errorlevel 1 (
    echo ERROR: Laravel APP_KEY is missing.
    echo Run "php artisan key:generate" once inside apps\api.
    echo Do not regenerate the key after real encrypted data exists.
    exit /b 1
)
call :load_mysql_password
findstr /C:"${DAIRYCARE_MYSQL_PASSWORD}" "%DAIRYCARE_API_DIR%\.env" >nul
if not errorlevel 1 if not defined DAIRYCARE_MYSQL_PASSWORD (
    echo ERROR: The user environment variable DAIRYCARE_MYSQL_PASSWORD is missing.
    echo Configure it without placing the password in Git, then sign in again.
    exit /b 1
)
exit /b 0

:validate_mobile_installation
if not exist "%DAIRYCARE_MOBILE_DIR%\pubspec.yaml" (
    echo ERROR: Flutter project was not found at:
    echo %DAIRYCARE_MOBILE_DIR%
    exit /b 1
)
if not exist "%DAIRYCARE_FLUTTER%" (
    echo ERROR: Flutter was not found at:
    echo %DAIRYCARE_FLUTTER%
    exit /b 1
)
exit /b 0

:load_mysql_password
if defined DAIRYCARE_MYSQL_PASSWORD exit /b 0
for /f "usebackq delims=" %%P in (`powershell.exe -NoProfile -Command "[Environment]::GetEnvironmentVariable('DAIRYCARE_MYSQL_PASSWORD','User')"`) do set "DAIRYCARE_MYSQL_PASSWORD=%%P"
exit /b 0

:check_mysql_running
sc.exe query MySQL84 2>nul | findstr /I /C:"RUNNING" >nul
if errorlevel 1 (
    echo ERROR: The MySQL84 Windows service is not running.
    echo Run this launcher as Administrator once, or start MySQL84 manually.
    exit /b 1
)
echo MySQL84 is running.
exit /b 0

:ensure_mysql_running
sc.exe query MySQL84 2>nul | findstr /I /C:"RUNNING" >nul
if not errorlevel 1 (
    echo MySQL84 is running.
    exit /b 0
)
echo.
echo Trying to start MySQL84...
net.exe start MySQL84 >nul 2>&1
if errorlevel 1 (
    echo ERROR: Windows could not start MySQL84.
    echo Right-click this file, choose "Run as administrator", and try again.
    exit /b 1
)
echo MySQL84 started.
exit /b 0

:is_api_ready
powershell.exe -NoProfile -Command ^
    "try { Invoke-WebRequest -UseBasicParsing -TimeoutSec 2 -Uri '%DAIRYCARE_API_URL%/auth/me' | Out-Null; exit 0 } catch { if ($_.Exception.Response -and [int]$_.Exception.Response.StatusCode -eq 401) { exit 0 }; exit 1 }"
exit /b %errorlevel%

:is_api_port_in_use
powershell.exe -NoProfile -Command ^
    "$client = New-Object Net.Sockets.TcpClient; try { $client.Connect('127.0.0.1', 8000); exit 0 } catch { exit 1 } finally { $client.Dispose() }"
exit /b %errorlevel%

:wait_for_api
powershell.exe -NoProfile -Command ^
    "$deadline = (Get-Date).AddSeconds(60); while ((Get-Date) -lt $deadline) { try { Invoke-WebRequest -UseBasicParsing -TimeoutSec 2 -Uri '%DAIRYCARE_API_URL%/auth/me' | Out-Null; exit 0 } catch { if ($_.Exception.Response -and [int]$_.Exception.Response.StatusCode -eq 401) { exit 0 } }; Start-Sleep -Milliseconds 750 }; exit 1"
exit /b %errorlevel%

:failed
echo.
echo DairyCare was not started.
pause
exit /b 1

:child_failed
echo.
echo This DairyCare process stopped because of the error above.
pause
exit /b 1

:child_finished
echo.
echo This DairyCare process has stopped.
pause
exit /b 0
