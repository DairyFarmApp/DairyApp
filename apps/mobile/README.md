# DairyCare Mobile

Flutter 3.41.9 / Dart 3.11.5 client for the Phase 1 foundation, Phase 2A registry, Phase 2B online animal movements, and Phase 2C online weights/status history. Implemented features include authentication/context, responsive permission-aware navigation, farm/shed foundation data, animal registry and breed/group management, movement history/request/decisions, weight/status forms and histories, Drift authorized read caches, connectivity, sync, and diagnostics.

## Run

```powershell
C:\flutter\bin\flutter.bat pub get
C:\flutter\bin\flutter.bat pub run build_runner build
C:\flutter\bin\flutter.bat run --dart-define=APP_ENV=development --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1
```

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

Phase 2C analysis and all 62 Flutter tests pass. The debug APK builds successfully. Animal/breed/group/movement/weight/status writes require connectivity; Drift caches only authorized read data. Offline animal mutations, QR, photos, generic timeline, milk, breeding, health, inventory, finance, and all later-phase screens remain excluded.
