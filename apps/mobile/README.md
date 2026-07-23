# DairyCare Mobile Foundation

Flutter 3.41.9 / Dart 3.11.5 client for Phase 1. Implemented features are authentication, secure session persistence, organization/farm context selection, responsive shell, permission-aware foundation navigation, farm/shed reference management, Drift reference cache/outbox/conflicts, connectivity state, manual sync, and diagnostics.

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

No animal, milk, health, inventory, finance, or other later-phase code exists.
