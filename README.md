# 🎲 RanJitzu

**Random BJJ Position Generator** — A Flutter app for Brazilian Jiu-Jitsu drilling and sparring sessions.

Randomly assigns positions and submissions to two fighters, with belt-level filtering, Gi/No-Gi modes, a round timer, live scoring, and match history.

---

## Features

- Belt-level filtering (White → Black) — technique difficulty scales with the user
- Gi & No-Gi modes with separate move pools
- Submission Hunt & Starting Position game types
- Round timer with buzzer
- Live +1 scoring per fighter
- Reroll individual fighter prompts before the timer starts
- Match history saved locally on device
- In-app feedback form (Formspree)
- No accounts, no ads, no data collected

---

## Tech Stack

- **Flutter** (Dart) — cross-platform mobile
- **shared_preferences** — local match history
- **audioplayers** — buzzer sound
- **http** — feedback form submissions
- **flutter_launcher_icons** — app icon generation
- **flutter_native_splash** — splash screen
- **google_fonts** — typography
- **Formspree** — feedback form backend (no server required)

---

## Project Structure

```
lib/
├── main.dart                  # App entry point, splash init
├── screens/
│   ├── setup_screen.dart      # Main setup UI
│   ├── result_screen.dart     # Fighter cards, timer, scoring
│   └── history_screen.dart    # Match history
├── widgets/
│   └── fighter_card.dart      # Individual fighter prompt card
├── services/
│   ├── moves_service.dart     # Loads and filters moves.json
│   └── history_service.dart   # SharedPreferences CRUD
└── models/
    └── match_result.dart      # Match data model

assets/
├── moves.json                 # 75 submissions + 69 positions
├── app_icon.png               # Source icon (1024x1024)
└── sounds/
    └── buzzer.wav             # Round end buzzer
```

---

## Getting Started

### Prerequisites

- Flutter SDK (stable channel) — [flutter.dev](https://flutter.dev)
- Dart SDK (comes with Flutter)
- Android Studio or VS Code with Flutter extension

```bash
flutter --version   # Should be 3.x stable
flutter doctor      # Fix any issues before proceeding
```

### Install dependencies

```bash
flutter pub get
```

### Run locally

```bash
flutter run         # Runs on connected device or emulator
flutter run -d chrome   # Runs as web app
```

---

## Building for Release

### Generate icons and splash screen

After any changes to `assets/app_icon.png`:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

---

## Android Release Build

### 1. Create a keystore

Run this once and store the output file safely — you need it for every future release:

```bash
keytool -genkey -v -keystore ~/ranjitzu-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias ranjitzu
```

### 2. Create `android/key.properties`

> ⚠️ This file is gitignored — never commit it

```
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=ranjitzu
storeFile=/home/YOUR_USERNAME/ranjitzu-release.jks
```

### 3. Configure `android/app/build.gradle`

At the top of the file, before the `android {` block:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

Inside the `android {` block, replace `buildTypes` with:

```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
buildTypes {
    release {
        signingConfig signingConfigs.release
        minifyEnabled true
        shrinkResources true
    }
}
```

### 4. Build the release

```bash
flutter clean
flutter pub get

# App Bundle for Google Play Store
flutter build appbundle --release

# APK for direct device testing
flutter build apk --release
```

Output locations:
- `build/app/outputs/bundle/release/app-release.aab` — upload to Google Play
- `build/app/outputs/flutter-apk/app-release.apk` — install directly for testing

### 5. Test on device before uploading

```bash
# Enable USB debugging on device:
# Settings → About Phone → tap Build Number 7 times
# Settings → Developer Options → USB Debugging ON

adb install build/app/outputs/flutter-apk/app-release.apk
```

### 6. Google Play Console

- Create app → Sports category → Free
- Upload `app-release.aab` to Production
- Fill in store listing, screenshots, privacy policy URL
- Submit for review (typically 1–3 days)

---

## iOS Release Build (via Codemagic)

iOS builds require macOS and Xcode. Since this project uses **Codemagic** for cloud builds, no Mac is needed locally.

### 1. Apple Developer Account

- Enroll at [developer.apple.com](https://developer.apple.com/programs/) — $99/year
- Register App ID: `com.ranjitzu.app`
- Create app record in [App Store Connect](https://appstoreconnect.apple.com)

### 2. App Store Connect API Key

This allows Codemagic to sign and upload builds without manual intervention:

1. Go to App Store Connect → Users and Access → Integrations → Keys
2. Click **+** to generate a new key
3. Name: `Codemagic`, Role: `App Manager`
4. Download the `.p8` file — **you can only download it once**
5. Note down the **Key ID** and **Issuer ID**

### 3. Codemagic Setup

1. Sign up at [codemagic.io](https://codemagic.io) using your GitHub account
2. Connect this repository
3. Go to your app settings → Environment variables and add:
   - `APP_STORE_CONNECT_PRIVATE_KEY` — contents of the `.p8` file
   - `APP_STORE_CONNECT_KEY_IDENTIFIER` — the Key ID
   - `APP_STORE_CONNECT_ISSUER_ID` — the Issuer ID

### 4. `codemagic.yaml`

The `codemagic.yaml` file in the project root defines the build workflow:

```yaml
workflows:
  ios-release:
    name: iOS App Store Release
    max_build_duration: 60
    environment:
      flutter: stable
      xcode: latest
      cocoapods: default
      ios_signing:
        distribution_type: app_store
        bundle_identifier: com.ranjitzu.app
    scripts:
      - name: Get packages
        script: flutter pub get
      - name: Install pods
        script: cd ios && pod install
      - name: Build IPA
        script: flutter build ipa --release
    artifacts:
      - build/ios/ipa/*.ipa
    publishing:
      app_store_connect:
        api_key: $APP_STORE_CONNECT_PRIVATE_KEY
        key_id: $APP_STORE_CONNECT_KEY_IDENTIFIER
        issuer_id: $APP_STORE_CONNECT_ISSUER_ID
        submit_to_testflight: true

  android-release:
    name: Android Play Store Release
    max_build_duration: 60
    environment:
      flutter: stable
    scripts:
      - name: Get packages
        script: flutter pub get
      - name: Build AAB
        script: flutter build appbundle --release
    artifacts:
      - build/app/outputs/bundle/release/*.aab
```

### 5. Trigger a build

Push to `main` or trigger manually from the Codemagic dashboard. The build will:
- Compile on a Mac in the cloud
- Sign with your App Store certificate automatically
- Push the `.ipa` directly to TestFlight

### 6. TestFlight testing

- Open **TestFlight** on your iPhone (free from App Store)
- Accept the invite email from Apple
- Install and test the app

### 7. App Store submission

In App Store Connect once the TestFlight build is ready:
- Fill in all metadata (description, keywords, screenshots, privacy policy)
- Select the build
- Submit for review (typically 1–3 days)

---

## iOS `Info.plist` Notes

The following key is set in `ios/Runner/Info.plist` to declare no custom encryption is used (required by Apple):

```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

---

## Environment & Secrets

The following files are gitignored and must be created locally:

| File | Purpose |
|------|---------|
| `android/key.properties` | Android keystore passwords |
| `*.jks` / `*.keystore` | Android keystore file |

Codemagic environment variables (set in dashboard, not in code):

| Variable | Purpose |
|----------|---------|
| `APP_STORE_CONNECT_PRIVATE_KEY` | App Store Connect API `.p8` key contents |
| `APP_STORE_CONNECT_KEY_IDENTIFIER` | API Key ID |
| `APP_STORE_CONNECT_ISSUER_ID` | App Store Connect Issuer ID |

---

## Assets

### Regenerating the app icon

Replace `assets/app_icon.png` with a new 1024×1024 PNG (full square, no transparency — iOS applies its own rounding), then run:

```bash
dart run flutter_launcher_icons
```

### Regenerating the splash screen

```bash
dart run flutter_native_splash:create
```

Splash config is in `pubspec.yaml` under `flutter_native_splash`.

---

## Move Database

All techniques are stored in `assets/moves.json` with the following structure:

```json
{
  "submissions": [
    {
      "name": "Rear Naked Choke",
      "description": "Classic choke from back control",
      "belt": "white",
      "gi": true,
      "nogi": true
    }
  ],
  "positions": [
    {
      "name": "Full Guard",
      "blue_role": "Full Guard — Sweeping or Submitting",
      "red_role": "Full Guard — Passing or Defending",
      "belt": "white",
      "gi": true,
      "nogi": true
    }
  ]
}
```

Current database: **75 submissions** and **69 positions** across all belt levels.

---

## Privacy

RanJitzu collects no personal data. Match history is stored locally on device only and is never transmitted. The optional feedback form sends only the text the user writes — no device information is attached.

Full privacy policy: [albertas159.github.io/ranjitzu/privacy-policy.html](https://albertas159.github.io/ranjitzu/privacy-policy.html)

---

## License

MIT License — see `LICENSE` file for details.

---

*Built by Albert Labs*