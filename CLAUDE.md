# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`g8_eccomerce_app` ("Kutuku") is a Flutter e-commerce app backed by Firebase
(Auth + Cloud Firestore). Targets Android, iOS, web, macOS, and Windows.
Requires Dart/Flutter SDK `^3.10.0`.

## Setup / install (step by step)

**Prerequisites:** Git, and the Flutter SDK (stable channel, bundles Dart
`>=3.10.0`). Platform toolchains as needed: Android Studio + SDK for Android,
Xcode for iOS/macOS, Visual Studio (Desktop C++) for Windows, Chrome for web.

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
4. **Add Firebase credentials.** Firebase is **required at startup**
   (`main.dart` calls `Firebase.initializeApp` before `runApp`, so the app will
   not boot without it). `lib/firebase_options.dart` and `firebase.json` are
   committed, but the platform credential files are git-ignored and must be
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
   (Authentication → Sign-in method). If it is off, login/register fail and
   `AuthService.messageFromError` shows a hint pointing here.
6. **Run the app** on a connected device or emulator:
   ```bash
   flutter devices    # list available targets
   flutter run        # launch on the default device
   ```

## Commands

### Run (debug)

```bash
flutter run                 # default connected device
flutter run -d chrome       # web
flutter run -d windows      # Windows desktop
flutter run -d <id>         # a specific device from `flutter devices`
```

### Build (release)

```bash
flutter build apk                    # Android APK -> build/app/outputs/flutter-apk/
flutter build appbundle              # Android App Bundle (.aab) for Play Store
flutter build ios                    # iOS (requires macOS + Xcode)
flutter build web                    # web bundle -> build/web/
flutter build windows                # Windows desktop -> build/windows/
```

### Analyze & test

```bash
flutter analyze                          # static analysis / lint (flutter_lints)
flutter test                             # run all tests
flutter test test/widget_test.dart       # run a single test file
flutter test --name "substring"          # run tests whose name matches
```

### Housekeeping

```bash
flutter clean                            # delete build/ and caches when builds go stale
flutter pub get                          # re-fetch deps after editing pubspec.yaml
flutter pub upgrade --major-versions     # bump dependency versions
```

## Architecture

Code is organized by **feature** under `lib/features/<feature>/`, each split into
`data/` (Firebase-facing services) and `presentation/` (`screens/`, `widgets/`,
`models/`). Features: `splash`, `auth`, `home`.

- **Entry / boot:** `lib/main.dart` initializes Firebase then shows
  `SplashScreen`. There is no routing table or auth gate — navigation is
  imperative via `Navigator.push`/`pushReplacement` with inline
  `MaterialPageRoute`s. The flow is hardcoded:
  `SplashScreen` → `OnboardingScreen` → (`LoginScreen` | `RegisterScreen`) →
  `HomeScreen`. Login does **not** check existing auth state on launch; the
  splash always advances to onboarding regardless of `currentUser`.

- **Data layer = thin Firebase wrappers.** `auth/data/auth_service.dart` wraps
  `FirebaseAuth` + Firestore (register also writes a `users/{uid}` doc);
  `home/data/product_service.dart` wraps the Firestore `products` collection.
  Both constructors accept injectable `FirebaseAuth`/`FirebaseFirestore` instances
  for testing, defaulting to `.instance`. Each screen instantiates its own
  service — there is no DI container or shared state management (no Provider/
  Riverpod/Bloc); UI consumes Firestore via `StreamBuilder`/`FutureBuilder`.

- **Firestore conventions** (see docstrings in the service files):
  - `products` docs: `name`, `seller`, `price` (num), `imageUrl` (hosted URL,
    e.g. Cloudinary), `createdAt` (Timestamp). Images are **URLs**, not uploaded
    blobs — there is no Firebase Storage usage.
  - Sorting and substring search are done **client-side** (Firestore has no
    substring query, and client sort tolerates docs missing `createdAt`). Keep
    new query/filter logic on the client to match this pattern.

- **Models & theming:** `home/presentation/models/shop_data.dart` holds the
  `Product` model (`Product.fromFirestore` tolerates both `createdAt` and the
  misspelled `createAt`), shared theme colors (`kPrimary`, `kDarkText`), and
  `k*` mock catalogue lists (`kNewArrivals`, `kCategories`, etc.) still used as
  fallback UI data alongside live Firestore products.

## Gotchas

- The legacy IML / module file is named `smart_student_attendance_system.iml`
  (project was scaffolded from another app) — the real package name is
  `g8_eccomerce_app`. Ignore the stale name.
- Image assets must be registered in `pubspec.yaml` under `flutter: assets:`
  (currently the onboarding images and `google_logo.png`).
- `test/widget_test.dart` is the default Flutter counter test and does not match
  this app — update it before relying on `flutter test` as a real signal.
