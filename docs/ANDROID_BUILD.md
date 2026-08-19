# DairyCare Android build

## Verified development APK

The Android development APK is built with:

```powershell
C:\flutter\bin\flutter.bat build apk --debug `
  --dart-define=APP_ENV=development `
  --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

Artifact:

`apps/mobile/build/app/outputs/flutter-apk/app-debug.apk`

This URL is correct for an Android emulator reaching a Laravel API running on
the host PC. Start Laravel on port 8000 before using the app. Install with:

```powershell
adb install -r apps/mobile/build/app/outputs/flutter-apk/app-debug.apk
```

The debug manifest permits local HTTP traffic. The production manifest does
not opt into cleartext traffic; production must use an HTTPS API URL.

## Physical Android devices

`10.0.2.2` is emulator-only. For a physical phone/tablet, rebuild with an HTTPS
development endpoint or a LAN URL reachable from the device, ensure Laravel is
bound to the LAN interface, and restrict firewall access to the local network.
Do not expose MySQL or Ollama to the phone; only Laravel is a supported client
endpoint.

### Current LAN validation build

The current real-phone debug artifact is:

`apps/mobile/build/app/outputs/flutter-apk/DairyCare-phone-v1.0.7.apk`

It embeds `http://192.168.1.47:8001/api/v1` and was built with the DairyCare
cow launcher icon. Laravel must remain listening on `0.0.0.0:8001`, and the PC
and phone must remain on the same Wi-Fi. Because DHCP may change the PC address,
rebuild the APK or deploy an HTTPS API when the address changes.

## Production release

The current APK is signed with the Android debug certificate and must not be
uploaded to Google Play. A production release requires the owner's private
keystore, protected signing configuration, final package/application identity,
an HTTPS API deployment, and testing on at least one real phone and one tablet.
Signing secrets must remain outside source control.
