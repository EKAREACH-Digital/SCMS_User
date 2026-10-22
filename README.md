# Smart Canteen — Student App

A Flutter app (iOS & Android) for students to browse the canteen menu, order meals and pick them up with a QR code, top up and pay from a digital wallet, and manage their profile and notifications.

It talks to the Smart Canteen NestJS backend (`/api/v1`).

---

## Prerequisites

| Tool | Version | Notes |
|---|---|---|
| Flutter SDK | Stable, bundling Dart `3.11.5` or newer | Developed on Flutter 3.47 stable. Check with `flutter --version` |
| Xcode | Recent stable | iOS builds; deployment target is **iOS 16.0** |
| CocoaPods | Latest | `sudo gem install cocoapods` (or `brew install cocoapods`) |
| Android Studio | Recent stable | Android SDK + an emulator, or a device with USB debugging |
| Smart Canteen backend | Running locally or deployed | The app reads its URL from `.env` |

Optional, for social sign-in:
- **Google**: an OAuth "Web application" client ID (the backend's `GOOGLE_CLIENT_ID`) and an iOS client ID.
- **Microsoft**: an Azure app registration (client ID, tenant ID, Android redirect URI).

Run `flutter doctor` and fix anything it reports before continuing.

---

## How to Run

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Create your `.env`

`.env` is bundled into the app as an asset, so **the app will not build without it**.

```bash
cp .env.example .env
```

Then set `API_BASE_URL` for where you run the app. Leave out the API version, because every route adds `/v1` itself:

| Running on | `API_BASE_URL` |
|---|---|
| iOS simulator | `http://localhost:3000/api` |
| Android emulator | `http://10.0.2.2:3000/api` |
| Physical phone | `http://<your-mac-lan-ip>:3000/api` (find it with `ipconfig getifaddr en0`) |

Fill in the Google and Microsoft keys only if you use those sign-ins. `.env` is git-ignored, and everything in it ships inside the app, so put **only public identifiers** in it, never a secret.

### 3. Run

```bash
flutter devices        # list simulators / connected phones
flutter run            # or: flutter run -d <device-id>
```

### Mock vs real backend

Each feature's data source is chosen in `lib/main.dart`. To work without a backend, inject the mock datasource instead of the remote one:

```dart
AuthRepositoryImpl(AuthMockDatasource(), c.read<StorageService>())   // mock
AuthRepositoryImpl(AuthRemoteDatasource(c.read<Dio>()), ...)          // real
```

There are no flavors and no `main_dev.dart`. `main.dart` is the only entry point.

### Checks before you push

```bash
flutter analyze
flutter test
bash tool/check_rules.sh   # project style rules (also runs as a Claude Code hook)
```

Format only the files you changed (`dart format path/to/file.dart`), never whole folders.

### Localization

Strings live in `lib/l10n/app_en.arb` and `app_km.arb` (English and Khmer). `AppLocalizations` is regenerated automatically on `flutter pub get` / `flutter run` (`generate: true` in `pubspec.yaml`, config in `l10n.yaml`).

---

## 🛠 Tech Stack

* **Language / UI**: [Flutter](https://flutter.dev) + Dart 3
* **State Management**: [Provider](https://pub.dev/packages/provider) (`ChangeNotifier` ViewModels)
* **Routing**: [GoRouter](https://pub.dev/packages/go_router)
* **Networking**: [Dio](https://pub.dev/packages/dio), with an auth interceptor that adds the Bearer token and refreshes it
* **Secure storage**: [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) for auth tokens
* **Config**: [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) (`.env` read through `AppConfig`)
* **Auth**: [google_sign_in](https://pub.dev/packages/google_sign_in), [msal_auth](https://pub.dev/packages/msal_auth) (Microsoft)
* **QR**: [qr_flutter](https://pub.dev/packages/qr_flutter) (show coupons), [mobile_scanner](https://pub.dev/packages/mobile_scanner) (scan)
* **Notifications**: [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) + [timezone](https://pub.dev/packages/timezone)
* **Logging**: [logger](https://pub.dev/packages/logger) through `AppLogger`
* **Localization**: `flutter_localizations` + `intl` (English and Khmer)
* **Architecture**: Layered MVVM + Domain + Repository, feature-first folders

---

## Architecture

Data flows one way:

```
View → ViewModel → Repository (domain, abstract) ⇐ RepositoryImpl (data) → Datasource → API
```

Dependency rule: `presentation → domain ← data`. The `domain/` layer is pure Dart and imports nothing from Flutter, Dio, `data/` or `presentation/`.

| Layer | Holds | Rule of thumb |
|---|---|---|
| **presentation** | Pages, widgets, ViewModels | Views talk only to ViewModels; ViewModels only to domain repositories |
| **domain** | Entities, abstract repositories | Pure Dart, immutable entities with `copyWith` |
| **data** | DTOs, datasources (remote + mock), repository impls | DTO → entity mapping happens here; `DioException` never leaves this layer |

All dependencies are wired once in `lib/main.dart` with `MultiProvider`: datasource → repository → ViewModel.

---

## 📁 Project Structure

```
lib/
├── main.dart                 # The only entry point; wires every provider
├── l10n/                     # .arb strings (en, km) + generated AppLocalizations
├── core/                     # Shared, feature-independent code
│   ├── config/               # AppConfig (.env), ApiConfig (backend routes), OAuth configs
│   ├── constants/            # ImageConst — every asset path
│   ├── error/                # ApiException, ErrorHandler (DioException → ApiException)
│   ├── network/              # DioClient, AuthInterceptor (token + refresh)
│   ├── routes/               # AppRouter (GoRouter + auth redirect), AppRoutes / AppPaths
│   ├── services/             # StorageService, local notification service
│   ├── theme/                # AppColors, AppFonts, AppTheme
│   ├── utils/                # AppLogger, ViewState, validators
│   └── widgets/              # Widgets shared across features
└── features/
    ├── auth/                 # Sign in/up, email OTP, Google/Microsoft, complete profile, passwords
    ├── home/                 # Dashboard and tabbed app shell
    ├── menu/                 # Menu by category, weekly menu, cart
    ├── order/                # Checkout, meal coupons (QR), order history
    ├── wallet/               # Balance and transactions
    ├── payment/              # Wallet top-up (ABA PayWay), saved payment methods
    ├── notification/         # Alerts feed and notification preferences
    └── settings/             # Settings, edit profile, language, dark mode, about
```

Every feature follows the same layout:

```
features/<feature>/
├── domain/
│   ├── entities/             # Pure Dart entities (copyWith)
│   └── repositories/         # Abstract repository contracts
├── data/
│   ├── datasources/          # Abstract interface + _remote (Dio) + _mock (fake data)
│   ├── models/               # DTOs (*_dto.dart) mirroring backend JSON, with a .md each
│   └── repositories/         # Repository impls (DTO → entity)
└── presentation/
    ├── viewmodels/           # ChangeNotifier state (idle / loading / success / error)
    └── views/                # Pages, plus widgets/ and widgets/<screen_name>/
```

Other folders:

| Path | What's there |
|---|---|
| `assets/` | Images, icons, fonts, `msal_config.json` |
| `test/` | Unit tests (DTO parsing, repositories, ViewModels, layer rules) |
| `tool/check_rules.sh` | Style-rule checker (no `print`, raw `TextStyle`, `Navigator.push`, …) |
| `docs/rules/` | `ARCHITECTURE.md`, `COMMENTS.md` — read these before contributing |
| `docs/features/` | Backend API guides per feature (auth, menu, order/payment, pickup) |
| `docs/chores/` | Records of larger refactors and migrations |
| `deprecated/` | Old code kept for reference — never import from it |

---

## 📚 Contributing

Before writing code, read [`docs/rules/ARCHITECTURE.md`](docs/rules/ARCHITECTURE.md) and [`docs/rules/COMMENTS.md`](docs/rules/COMMENTS.md). In short:

- Text styles come from `AppFonts.headingN.copyWith(...)` and colors from `AppColors`.
- Navigate with `context.go()` / `context.push()`, never `Navigator.push`.
- Log with `AppLogger`, never `print`.
- Every asset gets a constant in `ImageConst`.
- No `_buildX()` helpers; extract named widgets instead.
