[CmdletBinding()]
param(
    [switch]$WithBuilds,
    [switch]$WithDependencyAudit,
    [switch]$WithMySql
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$apiRoot = Join-Path $repoRoot 'apps\api'
$mobileRoot = Join-Path $repoRoot 'apps\mobile'
$flutter = 'C:\flutter\bin\flutter.bat'
$dart = 'C:\flutter\bin\cache\dart-sdk\bin\dart.exe'
$failures = [System.Collections.Generic.List[string]]::new()
$startedAt = Get-Date

function Invoke-Stage {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$WorkingDirectory,
        [Parameter(Mandatory)][scriptblock]$Command
    )

    Write-Host "`n=== $Name ===" -ForegroundColor Cyan
    Push-Location $WorkingDirectory
    try {
        & $Command
        if ($LASTEXITCODE -is [int] -and $LASTEXITCODE -ne 0) {
            $failures.Add("$Name (exit $LASTEXITCODE)")
        }
    }
    catch {
        $failures.Add("$Name ($($_.Exception.Message))")
    }
    finally {
        Pop-Location
    }
}

if (-not (Test-Path $flutter) -or -not (Test-Path $dart)) {
    throw 'Flutter SDK was not found at C:\flutter. Update scripts\verify.ps1 for this workstation.'
}

Invoke-Stage 'API PHP syntax' $apiRoot {
    $bad = Get-ChildItem app,database,routes,tests -Recurse -Filter *.php |
        ForEach-Object {
            & php -l $_.FullName | Out-Null
            if ($LASTEXITCODE -ne 0) { $_.FullName }
        }
    if ($bad) { throw "PHP syntax errors: $($bad -join ', ')" }
}
Invoke-Stage 'API formatting' $apiRoot { & vendor\bin\pint --test }
Invoke-Stage 'API SQLite test suite' $apiRoot { & php artisan test --colors=never }
Invoke-Stage 'API route registration' $apiRoot { & php artisan route:list --path=api/v1 --except-vendor }
Invoke-Stage 'OpenAPI contract lint' $apiRoot {
    $lintOutput = (& npx --yes '@redocly/cli@1.34.17' lint openapi.yaml --format=stylish 2>&1) -join "`n"
    $lintExitCode = $LASTEXITCODE
    Write-Host $lintOutput
    if ($lintExitCode -ne 0) {
        throw "OpenAPI validation failed with exit code $lintExitCode."
    }
    $global:LASTEXITCODE = 0
}

if ($WithDependencyAudit) {
    Invoke-Stage 'Composer dependency audit' $apiRoot { & composer audit --locked --no-interaction }
    Invoke-Stage 'Flutter dependency report' $mobileRoot { & $flutter pub outdated }
}

if ($WithMySql) {
    if (-not $env:DB_DATABASE -or -not $env:DB_DATABASE.EndsWith('_test')) {
        throw 'MySQL verification requires DB_DATABASE ending in _test to protect development data.'
    }
    Invoke-Stage 'MySQL migration and test suite' $apiRoot {
        & php artisan migrate:fresh --force
        if ($LASTEXITCODE -ne 0) { return }
        & php artisan migrate:rollback --force
        if ($LASTEXITCODE -ne 0) { return }
        & php artisan migrate --force
        if ($LASTEXITCODE -ne 0) { return }
        & php artisan test --colors=never
    }
}

Invoke-Stage 'Flutter generated-code consistency' $mobileRoot {
    & $dart run build_runner build
}
Invoke-Stage 'Dart formatting' $mobileRoot {
    $before = @{}
    Get-ChildItem lib,test -Recurse -Filter *.dart | ForEach-Object {
        $before[$_.FullName] = (Get-FileHash $_.FullName -Algorithm SHA256).Hash
    }
    & $dart format lib test --output=none --set-exit-if-changed
    $changed = Get-ChildItem lib,test -Recurse -Filter *.dart | Where-Object {
        $before[$_.FullName] -ne (Get-FileHash $_.FullName -Algorithm SHA256).Hash
    }
    if ($changed) {
        throw "Dart formatting changed files: $($changed.FullName -join ', ')"
    }
    $global:LASTEXITCODE = 0
}
Invoke-Stage 'Flutter static analysis' $mobileRoot { & $flutter analyze }
Invoke-Stage 'Flutter complete test suite' $mobileRoot { & $flutter test --concurrency=1 }

if ($WithBuilds) {
    Invoke-Stage 'Android debug build' $mobileRoot {
        & $flutter build apk --debug '--dart-define=APP_ENV=development' '--dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1'
    }
    Invoke-Stage 'Web release build' $mobileRoot {
        & $flutter build web --release '--dart-define=APP_ENV=production' '--dart-define=API_BASE_URL=https://api.example.invalid/api/v1'
    }
}

$duration = (Get-Date) - $startedAt
Write-Host "`n=== Verification summary ===" -ForegroundColor Cyan
Write-Host ('Duration: {0:hh\:mm\:ss}' -f $duration)
if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Host "FAILED: $_" -ForegroundColor Red }
    exit 1
}

Write-Host 'All selected verification stages passed.' -ForegroundColor Green
