import 'package:flutter_test/flutter_test.dart';

import 'package:smart_canteen_user_frontend/features/menu/data/datasources/menu_mock_datasource.dart';
import 'package:smart_canteen_user_frontend/features/menu/data/models/active_menu_dto.dart';
import 'package:smart_canteen_user_frontend/features/menu/data/repositories/menu_repository_impl.dart';

/// `GET /menus/active` — the shape from docs/features/student-menu-api.md.
void main() {
  Map<String, dynamic> response({Object? menu = const {}}) => {
    'date': '2026-10-22',
    'day_of_week': 2,
    'branch': {'id': 'branch-c', 'name': 'Branch C', 'school_id': 'school-a'},
    'menu': menu == const {}
        ? {'id': 'menu-1', 'name': 'Week of 2026-10-19'}
        : menu,
    'canteens': menu == null
        ? <dynamic>[]
        : [
            {
              'id': 'canteen-a',
              'name': 'Canteen A',
              'categories': [
                {
                  'id': null,
                  'name': 'Other',
                  'items': [
                    {
                      'composition_id': 'comp-1',
                      'menu_item_id': 'item-1',
                      'name': 'Amok Fish Curry + Rice',
                      'description': 'Traditional Khmer fish curry',
                      'price': '2.50',
                      'image_url': '/uploads/amok.jpg',
                      'calories': 380,
                      'quantity_available': 50,
                      'sold_out': true,
                    },
                  ],
                },
              ],
            },
          ],
  };

  test('maps canteens, categories and dishes to the entity', () {
    final menu = ActiveMenuDto.fromJson(
      response(),
    ).toEntity(imageHost: 'http://10.0.2.2:3000/api');

    expect(menu.isPublished, isTrue);
    expect(menu.branchName, 'Branch C');
    expect(menu.canteens.single.categories.single.id, isNull);

    final dish = menu.items.single;
    expect(dish.id, 'item-1'); // menu_item_id, used by cart and orders
    expect(dish.price, 2.5);
    expect(dish.soldOut, isTrue);
    expect(dish.canteenId, 'canteen-a');
    expect(dish.category, 'other');
    // Relative path resolved against the host, dropping the `/api` prefix.
    expect(dish.imageUrl, 'http://10.0.2.2:3000/uploads/amok.jpg');
  });

  test('a null menu means nothing is published', () {
    final menu = ActiveMenuDto.fromJson(response(menu: null)).toEntity();

    expect(menu.isPublished, isFalse);
    expect(menu.canteens, isEmpty);
    expect(menu.isEmpty, isTrue);
  });

  test('the mock repository filters by canteen', () async {
    final repo = MenuRepositoryImpl(MenuMockDatasource());

    final all = await repo.getActiveMenu(branchId: 'branch-1');
    final one = await repo.getActiveMenu(
      branchId: 'branch-1',
      canteenId: all.canteens.first.id,
    );

    expect(all.canteens.length, greaterThan(1));
    expect(one.canteens.single.id, all.canteens.first.id);
    expect(all.items.any((i) => i.soldOut), isTrue);
  });
}
