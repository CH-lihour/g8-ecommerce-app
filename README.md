# g8_eccomerce_app

"Kutuku" — a Flutter e-commerce app backed by Firebase (Auth + Cloud
Firestore). Targets Android, iOS, web, macOS, and Windows. Requires
Dart/Flutter SDK `^3.10.0`.

## Prerequisites

- **Git**
- **Flutter SDK** (stable channel — bundles Dart `>=3.10.0`)
- Platform toolchains for whatever you intend to build:
  - Android → Android Studio + Android SDK
  - iOS / macOS → Xcode
  - Windows → Visual Studio (Desktop development with C++)
  - Web → Chrome

## Setup

1. **Clone the repo and enter it:**
   ```bash
   git clone <repo-url>
   cd g8-eccomerce-app
   ```

2. **Verify your toolchain** — every line should have a check mark for the
   platforms you intend to build:
   ```bash
   flutter doctor
   ```

3. **Install dependencies** (reads `pubspec.yaml`):
   ```bash
   flutter pub get
   ```

4. **Add Firebase credentials.** Firebase is **required at startup** — the app
   will not boot without it. `lib/firebase_options.dart` and `firebase.json`
   are committed, but the platform credential files are git-ignored and must be
   supplied locally:
   - Android → `android/app/google-services.json`
   - iOS / macOS → `ios/Runner/GoogleService-Info.plist`

   If they are missing (or you are pointing at a different Firebase project),
   regenerate everything with the FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli   # one-time, installs the CLI
   flutterfire configure --project=g8-eccomerce-app
   ```

5. **Enable Email/Password auth** in the Firebase console
   (Authentication → Sign-in method). If it is off, login and registration
   will fail.

6. **Run the app** on a connected device or emulator:
   ```bash
   flutter devices    # list available targets
   flutter run        # launch on the default device
   ```
   To target a specific platform:
   ```bash
   flutter run -d chrome      # web
   flutter run -d windows     # Windows desktop
   flutter run -d <id>        # a specific device from `flutter devices`
   ```

## Troubleshooting

- **App crashes immediately on launch:** the Firebase credential files from
  step 4 are missing or belong to a different project. Re-run
  `flutterfire configure`.
- **Login/registration fails:** Email/Password sign-in is not enabled in the
  Firebase console (step 5).
- **Build fails after pulling new changes:** re-run `flutter pub get`; if it
  still fails, clear caches with `flutter clean` then `flutter pub get`.
