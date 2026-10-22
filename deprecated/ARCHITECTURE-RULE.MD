# SCMS Mobile App

## Development & Implementation Guide

This document defines standard operational workflows for engineers starting development, structuring state handling with the AsyncValue utility, and adding new application features without breaking architectural integrity.

---

# Project Structure

```text
lib/
├── main_dev.dart                          # Dev-flavor entry: builds devProviders list (Mocks/Dev APIs)
├── main_prod.dart                         # Production flavor entry point: binds secure endpoints
├── main_common.dart                       # App root: MyApp, MultiProvider, bottom navigation setup
│
├── data/
│   ├── config/
│   │   └── api_config.dart                # Base URI + endpoints for SCMS NestJS Backend
│   ├── dtos/
│   │   ├── auth_dto.dart                  # AuthDto.fromJson / toJson (JWT tokens, profiles)
│   │   ├── menu_dto.dart                  # MenuDto.fromJson / toJson (Meals, sessions, tags)
│   │   ├── coupon_dto.dart                # CouponDto.fromJson / toJson (Plans, bundles, QR payloads)
│   │   ├── notification_dto.dart          # NotificationDto.fromJson / toJson (Alert items)
│   │   └── wallet_dto.dart                # WalletDto.fromJson / toJson (Subsidies, tracking records)
│   └── repositories/
│       ├── auth/
│       │   ├── auth_repository.dart        # Abstract interface for authentication contracts
│       │   ├── auth_repository_nestjs.dart # Production NestJS implementation via HTTP endpoints
│       │   └── auth_repository_mock.dart   # Mock implementation for offline/local sandbox testing
│       ├── menu/
│       │   ├── menu_repository.dart        # Abstract interface for menu data operations
│       │   ├── menu_repository_nestjs.dart # Production NestJS framework client interface
│       │   └── menu_repository_mock.dart   # Mock data feeding system for frontend design testing
│       ├── coupon/
│       │   ├── coupon_repository.dart      # Abstract interface for purchase operations & order flows
│       │   ├── coupon_repository_nestjs.dart # Production server repository for checkout requests
│       │   └── coupon_repository_mock.dart   # Stub mockup tracking bundle purchases without network
│       └── wallet/
│           ├── wallet_repository.dart      # Abstract interface for institutional wallet actions
│           ├── wallet_repository_nestjs.dart # Connects to live top-up microservices
│           └── wallet_repository_mock.dart   # Local mock repository preserving simulated ledger entries
│
├── model/                                 # Pure domain data entities
│   ├── user/
│   │   └── user.dart                      # User domain model (Metadata, institution roles)
│   ├── meal/
│   │   └── meal_item.dart                 # Meal domain entity (Calories, allergens, custom tags)
│   ├── coupon/
│   │   └── coupon_plan.dart               # Coupon configurations (Daily, weekly, monthly pricing structure)
│   └── transaction/
│       └── receipt.dart                   # Receipts mapping structure for historical reporting balances
│
└── ui/
    ├── screens/
    │   ├── login/
    │   │   ├── login_screen.dart          # Core login entry panel supporting traditional credentials
    │   │   └── view_model/auth_view_model.dart # Handles status operations (Unauthenticated, loading, error, success)
    │   ├── menu_browsing/
    │   │   ├── menu_browsing_screen.dart  # Canvas UI demonstrating institutional menus weekly
    │   │   ├── view_model/menu_view_model.dart # Controls time window tab shifts, filtering meals instantly
    │   │   └── widgets/
    │   │       ├── meal_session_tabs.dart # Top filter switches selecting Breakfast/Lunch/Dinner
    │   │       └── meal_item_card.dart     # Individual food listing template mapping labels
    │   ├── coupon_purchase/
    │   │   ├── purchase_screen.dart       # Bundle catalog matrix showcasing dynamic tier plans
    │   │   ├── view_model/purchase_view_model.dart # Controls operational pricing additions and batch discounts
    │   │   └── widgets/
    │   │       ├── discount_breakdown.dart # Element display panel sorting tiered savings metrics
    │   │       └── payment_selector.dart   # Payment gateway matrix choosing KHQR, ABA Pay, or Wallet
    │   ├── digital_wallet/
    │   │   ├── wallet_screen.dart         # Shows ticket counters, usage metrics, and live balances
    │   │   ├── view_model/wallet_view_model.dart # Encrypts active coupons locally for quick visual rendering
    │   │   └── widgets/
    │   │       ├── qr_ticket_display.dart  # Renders secure QR matrix safely under local offline modes
    │   │       └── history_tile.dart       # Filterable line rows tracking custom expenditures
    │   └── alerts/
    │       ├── notification_screen.dart   # Aggregated message boards detailing system announcements
    │       ├── view_model/notification_view_model.dart # Dispatches dynamic notifications and clears application badges
    │       └── widgets/
    │           └── alert_tile.dart        # Swipe-to-dismiss notification row for active alerts
    │
    ├── states/                            # Global multi-screen state providers via ChangeNotifiers
    │   ├── active_coupon_state.dart       # Global: Keeps tracking actively validated or scanned tokens
    │   ├── app_settings_state.dart        # Global: Toggles UI dark modes and targets current branch (CADT, ITC, MPTC)
    │   └── balance_state.dart             # Global: Listens to balance updates across views
    │
    ├── theme/
    │   └── theme.dart                     # Custom application design definitions (Shadcn/Tailwind style profiles)
    │
    ├── utils/
    │   ├── async_value.dart               # Generic pattern wrapping async events (AsyncLoading, AsyncData, AsyncError)
    │   ├── animation_utils.dart            # Custom physics handlers, fade setups, and custom transitions
    │   ├── qr_encryption_utils.dart       # Packages validation data into encrypted text vectors
    │   └── currency_formatter.dart        # Helper converting prices to custom institutional formats
    │
    └── widgets/                           # Reusable layout fragments across screens
        ├── low_balance_banner.dart        # Persistent warn bar prompting top-up
        ├── app_dialog.dart                # Modular payment verification popups
        ├── coupon_expired_overlay.dart    # Error splash view overlay if time expires
        └── quick_checkout_bottom_sheet.dart # Slide drawer drawer sheet matching order flow

```

---

# 1. Quick Start

## 1.1 Install Dependencies

Flutter 3.22+ is required.

```bash
flutter clean
flutter pub get
```

## 1.2 Run Development Environment

Runs with mock repositories and no backend dependency.

```bash
flutter run -t lib/main_dev.dart
```

## 1.3 Run Production Environment

Runs using the live backend infrastructure.

```bash
flutter run -t lib/main_prod.dart
```

---

# 2. State Management Strategy

The application uses a lightweight asynchronous state wrapper called `AsyncValue` to handle:

- Loading states
- Successful data retrieval
- Error handling

## AsyncValue Utility

```dart
sealed class AsyncValue<T> {
  const AsyncValue();
}

class AsyncLoading<T> extends AsyncValue<T> {
  const AsyncLoading();
}

class AsyncData<T> extends AsyncValue<T> {
  final T data;
  const AsyncData(this.data);
}

class AsyncError<T> extends AsyncValue<T> {
  final Object error;
  final StackTrace? stackTrace;

  const AsyncError(this.error, [this.stackTrace]);
}
```

---

## Example ViewModel

```dart
class MenuViewModel extends ChangeNotifier {
  final MenuRepository _menuRepository;

  AsyncValue<List<MealItem>> _menuState =
      const AsyncLoading();

  MenuViewModel(this._menuRepository);

  AsyncValue<List<MealItem>> get menuState =>
      _menuState;

  Future<void> fetchWeeklyMenu() async {
    _menuState = const AsyncLoading();
    notifyListeners();

    try {
      final menuDtos =
          await _menuRepository.getWeeklyMenu();

      final domainMeals = menuDtos
          .map((dto) => MealItem.fromDto(dto))
          .toList();

      _menuState = AsyncData(domainMeals);
    } catch (e, stack) {
      _menuState = AsyncError(e, stack);
    }

    notifyListeners();
  }
}
```

---

## Example Screen Usage

```dart
class MenuBrowsingScreen extends StatelessWidget {
  const MenuBrowsingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel =
        context.watch<MenuViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Canteen Menu'),
      ),
      body: switch (viewModel.menuState) {
        AsyncLoading() =>
          const Center(
            child: CircularProgressIndicator(),
          ),

        AsyncError(error: final err) =>
          Center(
            child: Text('Error: $err'),
          ),

        AsyncData(data: final mealList) =>
          ListView.builder(
            itemCount: mealList.length,
            itemBuilder: (context, index) {
              final meal = mealList[index];

              return ListTile(
                title: Text(meal.name),
                subtitle: Text(
                  '${meal.calories} kcal',
                ),
              );
            },
          ),
      },
    );
  }
}
```

---

# 3. Adding a New Feature

Follow this process whenever introducing a new module such as Feedback, Pre-ordering, Reviews, etc.

---

## Phase A: Domain & Data Layer

### Create Domain Model

Location:

```text
lib/model/new_feature/
```

Example:

```text
new_feature.dart
```

Contains only business entities and logic.

---

### Create DTO

Location:

```text
lib/data/dtos/
```

Example:

```text
new_feature_dto.dart
```

Responsible for:

- fromJson()
- toJson()

---

### Create Repository Contract

```dart
abstract class NewFeatureRepository {
  Future<List<NewFeatureDto>> fetchPayload();
}
```

Location:

```text
lib/data/repositories/new_feature/
```

---

## Phase B: Repository Implementations

### Production Repository

```text
new_feature_repository_nestjs.dart
```

Uses:

- HTTP Client
- Dio
- Backend APIs

---

### Mock Repository

```text
new_feature_repository_mock.dart
```

Example:

```dart
await Future.delayed(
  const Duration(seconds: 1),
);
```

Provides fake data for UI testing.

---

## Phase C: UI Integration

### Create ViewModel

Location:

```text
lib/ui/screens/new_feature/view_model/
```

Uses:

- ChangeNotifier
- AsyncValue

---

### Create Widgets

Location:

```text
lib/ui/screens/new_feature/widgets/
```

Break large screens into reusable widgets.

---

### Register Dependencies

#### Development

```dart
Provider<NewFeatureRepository>(
  create: (_) =>
      NewFeatureRepositoryMock(),
)
```

Inside:

```text
main_dev.dart
```

#### Production

```dart
Provider<NewFeatureRepository>(
  create: (_) =>
      NewFeatureRepositoryNestjs(),
)
```

Inside:

```text
main_prod.dart
```

---

### Wire into Application

Expose ViewModels through MultiProvider in:

```text
main_common.dart
```

---

# 4. Architectural Standards

## Layer Isolation

UI and ViewModels must never:

- Call APIs directly
- Access endpoints directly
- Parse JSON directly

All communication must go through repositories.

---

## Pure Mapping Rule

Data flow:

```text
API Response
    ↓
DTO
    ↓
Domain Model
    ↓
ViewModel
    ↓
UI
```

UI should never consume DTOs directly.

---

## Animation Isolation

All animations, transitions, and physics configurations must remain inside:

```text
lib/ui/utils/animation_utils.dart
```

This ensures consistent behavior and reusable motion patterns throughout the application.