import 'package:flutter_test/flutter_test.dart';

import 'package:smart_canteen_user_frontend/core/error/exceptions.dart';
import 'package:smart_canteen_user_frontend/core/utils/view_state.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/entities/daily_menu.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/entities/food_item.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/entities/weekly_menu.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/repositories/menu_repository.dart';
import 'package:smart_canteen_user_frontend/features/menu/presentation/viewmodels/menu_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/notification/data/datasources/notification_mock_datasource.dart';
import 'package:smart_canteen_user_frontend/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:smart_canteen_user_frontend/features/notification/presentation/viewmodels/notification_viewmodel.dart';

/// A menu repository whose first call fails, then succeeds.
class _FlakyMenuRepository implements MenuRepository {
  int calls = 0;

  @override
  Future<List<FoodItem>> getMenuItems({String? schoolId}) async {
    calls++;
    if (calls == 1) throw const ApiException('Menu is down');
    return const [
      FoodItem(
        id: '1',
        name: 'Khmer Noodle',
        description: '',
        price: 2,
        rating: 0,
        tags: [],
        category: 'breakfast',
        schoolId: 'school-1',
      ),
    ];
  }

  @override
  Future<WeeklyMenu?> getCurrentWeeklyMenu({String? schoolId}) async => null;

  @override
  Future<DailyMenu> getActiveMenu({
    required String branchId,
    String? canteenId,
    DateTime? date,
  }) => throw UnimplementedError();

  @override
  Future<FoodItem> getMenuItem(String menuItemId) => throw UnimplementedError();
}

/// ViewModels expose an enum [ViewState] plus separate data and error fields.
void main() {
  test('MenuViewModel goes loading → error with message → success', () async {
    final vm = MenuViewModel(_FlakyMenuRepository());
    final seen = <ViewState>[];
    vm.addListener(() => seen.add(vm.state));

    expect(vm.state, ViewState.idle);
    await vm.load();
    expect(vm.state, ViewState.error);
    expect(vm.errorMessage, 'Menu is down');
    expect(vm.items, isEmpty);

    await vm.load(force: true);
    expect(seen, [
      ViewState.loading,
      ViewState.error,
      ViewState.loading,
      ViewState.success,
    ]);
    expect(vm.errorMessage, isNull);
    expect(vm.items.single.name, 'Khmer Noodle');
    expect(vm.schoolId, 'school-1');
  });

  test(
    'NotificationViewModel mark-all-read and dismiss update the feed',
    () async {
      final vm = NotificationViewModel(
        NotificationRepositoryImpl(NotificationMockDatasource()),
      );
      expect(vm.state, ViewState.loading);

      await vm.fetchNotifications();
      expect(vm.state, ViewState.success);
      expect(vm.unreadCount, greaterThan(0));

      await vm.markAllRead();
      expect(vm.unreadCount, 0);
      expect(vm.unreadBadge, 0);

      final first = vm.items.first;
      await vm.dismiss(first);
      expect(vm.items.map((n) => n.id), isNot(contains(first.id)));
    },
  );

  test('a local alert seeds the feed before it was ever fetched', () {
    final vm = NotificationViewModel(
      NotificationRepositoryImpl(NotificationMockDatasource()),
    )..addLocal(id: 'local-1', title: 'Order ready', body: 'Pick it up');

    expect(vm.state, ViewState.success);
    expect(vm.items.single.id, 'local-1');
    expect(vm.unreadBadge, 1);
  });
}
