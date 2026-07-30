# DairyCare Mobile

Flutter 3.41.9 / Dart 3.11.5 client for the Phase 1 foundation, Phase 2 animal
workflows, one-farm owner/family onboarding, medicine/semen/feed inventory, and
Phase 3A daily milk recording.
Implemented features include owner signup, reusable family-link signup,
editable profile/photo, owner-controlled family access,
authentication/context, responsive navigation, farm/shed data, animal
registry, movements, weights/status history, online inventory overviews and
receipts, daily milk entry and correction, persistent glass appearance themes,
Drift read caches, connectivity, sync, and diagnostics.

## Run

```powershell
C:\flutter\bin\flutter.bat pub get
C:\flutter\bin\flutter.bat pub run build_runner build
C:\flutter\bin\flutter.bat run --dart-define=APP_ENV=development --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1
```

For Chrome/web development:

```powershell
C:\flutter\bin\flutter.bat run -d chrome --dart-define=APP_ENV=development --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1
```

The web client uses the official `sqlite3.wasm` and `drift_worker.js` assets
published with Drift `2.34.2`. `AppDatabase` supplies matching
`DriftWebOptions`, allowing the authorized Drift cache to use the best durable
browser storage implementation available. When Drift is upgraded, update both
web assets from the same Drift release and rerun the web runtime configuration
test and manual browser smoke test.

The zero-byte `C:\Windows\System32\flutter` launcher on the inspected machine shadows the SDK; use the absolute SDK path shown above until the machine PATH is repaired.

## Quality

```powershell
C:\flutter\bin\cache\dart-sdk\bin\dart.exe format lib test --output=none --set-exit-if-changed
C:\flutter\bin\flutter.bat analyze
C:\flutter\bin\flutter.bat test --concurrency=1
C:\flutter\bin\flutter.bat build apk --debug --dart-define=APP_ENV=development --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
C:\flutter\bin\flutter.bat build web --release --dart-define=APP_ENV=production --dart-define=API_BASE_URL=https://api.example.invalid/api/v1
```

SQLite uses the operating-system native library via `pubspec.yaml` hooks because Windows Application Control blocks downloaded DLLs from this workspace drive. Reassess the hook before production mobile release if a bundled, pinned SQLite build is preferred.

The Phase 1.1 Android debug build passed with Android SDK/build-tools 36.1 and the Android Studio JDK 21. The manifest contains `INTERNET` and Connectivity Plus contributes network-state permission. Production signing is intentionally not configured.

Current analysis, test, and build evidence is recorded in
[`docs/PHASE_3A_COMPLETION.md`](../../docs/PHASE_3A_COMPLETION.md).
Manual Chrome checks cover authentication, farm selection, dashboard, animal
registry/profile, all three inventory areas, stock creation, and live
System/White/Dark theme switching.
Animal/breed/group/movement/weight/status writes require connectivity; Drift
caches only authorized read data. Inventory and milk corrections are also
online-only at this checkpoint. New milk entries can be queued atomically for
retry while offline. Offline animal/inventory mutations, QR, animal photos,
generic timeline, breeding, health, finance, payroll, employee loans, and all
later-phase screens remain excluded.
