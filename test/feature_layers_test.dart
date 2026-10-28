import 'package:flutter_test/flutter_test.dart';

import 'package:smart_canteen_user_frontend/features/menu/data/datasources/menu_mock_datasource.dart';
import 'package:smart_canteen_user_frontend/features/menu/data/repositories/menu_repository_impl.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/entities/food_item.dart';
import 'package:smart_canteen_user_frontend/features/menu/presentation/viewmodels/cart_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/menu/presentation/viewmodels/weekly_menu_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/notification/data/datasources/notification_mock_datasource.dart';
import 'package:smart_canteen_user_frontend/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:smart_canteen_user_frontend/features/notification/domain/entities/notification_item.dart';
import 'package:smart_canteen_user_frontend/features/order/data/datasources/order_mock_datasource.dart';
import 'package:smart_canteen_user_frontend/features/order/data/repositories/order_repository_impl.dart';
import 'package:smart_canteen_user_frontend/features/order/domain/entities/order.dart';
import 'package:smart_canteen_user_frontend/features/order/domain/entities/order_status.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/viewmodels/order_history_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/payment/data/datasources/payment_mock_datasource.dart';
import 'package:smart_canteen_user_frontend/features/payment/data/models/payment_dto.dart';
import 'package:smart_canteen_user_frontend/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:smart_canteen_user_frontend/features/payment/domain/entities/topup_session.dart';
import 'package:smart_canteen_user_frontend/features/wallet/data/datasources/wallet_mock_datasource.dart';
import 'package:smart_canteen_user_frontend/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:smart_canteen_user_frontend/features/wallet/domain/entities/wallet_transaction.dart';

/// Each feature's repository maps its datasource's DTOs into entities. These
/// run the dev mock datasources through the real repositories and view models.
void main() {
  group('menu', () {
    final repo = MenuRepositoryImpl(MenuMockDatasource());

    test('items map to entities with the fallback photo', () async {
      final items = await repo.getMenuItems();

      expect(items, isNotEmpty);
      // The mock seeds no photos, so every item gets the shared placeholder.
      expect(items.every((i) => i.imageUrl == kFallbackFoodImageUrl), isTrue);
      expect(items.first.schoolId, 'mock-school-cadt');
      expect(items.first.category, 'breakfast');
    });

    test('weekly menu keeps missing photos null and groups by day', () async {
      final vm = WeeklyMenuViewModel(repo);
      await vm.load();

      final monday = vm.entriesForDay(0);
      expect(vm.data!.entries.every((e) => e.item.imageUrl == null), isTrue);
      // Mock: Khmer Noodle pinned to Monday breakfast, drinks every day.
      expect(
        monday[MealSlot.breakfast]!.map((e) => e.item.name),
        contains('Khmer Noodle'),
      );
      expect(
        monday[MealSlot.lunch]!.map((e) => e.item.name),
        contains('Coconut Milk Tea'),
      );
    });
  });

  group('cart', () {
    const noodle = FoodItem(
      id: '1',
      name: 'Khmer Noodle',
      description: '',
      price: 2.0,
      rating: 0,
      tags: [],
      category: 'breakfast',
    );
    const tea = FoodItem(
      id: '5',
      name: 'Coconut Milk Tea',
      description: '',
      price: 1.0,
      rating: 0,
      tags: [],
      category: 'drinks',
    );

    test('add, increment and decrement keep totals right', () {
      final cart = CartViewModel()
        ..add(noodle)
        ..add(noodle)
        ..add(tea);

      expect(cart.quantityOf('1'), 2);
      expect(cart.totalItems, 3);
      expect(cart.total, 5.0);

      cart
        ..decrement('1')
        ..decrement('1');
      expect(cart.quantityOf('1'), 0);
      expect(cart.isAnytimeOnly, isTrue);
    });
  });

  group('order', () {
    final repo = OrderRepositoryImpl(OrderMockDatasource());

    test('placing an order returns a placed order with qr data', () async {
      final placed = await repo.placeOrder(
        menuId: 'mock-menu-id',
        mealSession: 'lunch',
        provider: 'CUTLUY',
        items: const [NewOrderItem(menuItemId: '2', quantity: 1)],
      );

      expect(placed.orderId, isNotEmpty);
      expect(placed.qrString, isNotEmpty);
      expect(placed.provider, 'CUTLUY');
    });

    test('history view model loads and labels past orders', () async {
      final vm = OrderHistoryViewModel(repo);
      await vm.loadFromBackend();

      expect(vm.error, isNull);
      expect(vm.orders, hasLength(3));
      expect(vm.orders.first.items, 'Chicken with Rice ×2, Pork with Rice');
      expect(
        vm.orders.map((o) => o.status),
        containsAll([
          OrderStatus.completed,
          OrderStatus.pendingPayment,
          OrderStatus.cancelled,
        ]),
      );
    });
  });

  test('wallet transactions map their type', () async {
    final txs = await WalletRepositoryImpl(
      WalletMockDatasource(),
    ).getTransactions();
    expect(txs.first.type, TransactionType.topup);
    expect(txs.last.type, TransactionType.purchase);
  });

  group('payment', () {
    test('status strings parse to TopupStatus', () {
      expect(parseTopupStatus('PAID'), TopupStatus.paid);
      expect(parseTopupStatus('not_found'), TopupStatus.notFound);
      expect(parseTopupStatus('whatever'), TopupStatus.pending);
    });

    test('mock top-up reports paid after a few polls', () async {
      final repo = PaymentRepositoryImpl(PaymentMockDatasource());
      final session = await repo.startTopUp(5);
      expect(session.amountUsd, 5);

      final statuses = [
        for (var i = 0; i < 4; i++) await repo.checkStatus(session.tranId),
      ];
      expect(statuses.last, TopupStatus.paid);
      expect(statuses.take(3).every((s) => s == TopupStatus.pending), isTrue);
    });
  });

  test('notifications map source and read state', () async {
    final feed = await NotificationRepositoryImpl(
      NotificationMockDatasource(),
    ).getNotifications();
    final announcement = feed.firstWhere(
      (n) => n.source == NotificationSource.announcement,
    );
    expect(announcement.isRead, isTrue);
    expect(
      feed.where((n) => n.source == NotificationSource.personal),
      isNotEmpty,
    );
  });
}
