import 'package:smart_canteen_user_frontend/features/menu/data/datasources/menu_datasource.dart';
import 'package:smart_canteen_user_frontend/features/menu/data/models/active_menu_dto.dart';
import 'package:smart_canteen_user_frontend/features/menu/data/models/menu_dto.dart';

/// In-memory [MenuDatasource] for tests and offline work.
class MenuMockDatasource implements MenuDatasource {
  static const _items = [
    MenuItemDto(
      id: '1',
      name: 'Khmer Noodle',
      description: 'Traditional Cambodian noodle soup with fresh herbs',
      price: 2.00,
      categoryName: 'Breakfast',
      availabilityStatus: 'available',
      schoolId: 'mock-school-cadt',
    ),
    MenuItemDto(
      id: '2',
      name: 'Pork with Rice',
      description: 'Steamed jasmine rice with seasoned grilled pork',
      price: 1.75,
      categoryName: 'Lunch',
      availabilityStatus: 'available',
      schoolId: 'mock-school-cadt',
    ),
    MenuItemDto(
      id: '3',
      name: 'Chicken with Rice',
      description: 'Tender chicken on fragrant jasmine rice with house sauce',
      price: 2.00,
      categoryName: 'Lunch',
      availabilityStatus: 'available',
      schoolId: 'mock-school-cadt',
    ),
    MenuItemDto(
      id: '4',
      name: 'Fried Egg Rice',
      description: 'Sunny-side-up egg over warm jasmine rice with soy sauce',
      price: 1.25,
      categoryName: 'Breakfast',
      availabilityStatus: 'available',
      schoolId: 'mock-school-cadt',
    ),
    MenuItemDto(
      id: '5',
      name: 'Coconut Milk Tea',
      description: 'Creamy iced milk tea with coconut jelly and brown sugar',
      price: 1.00,
      categoryName: 'Drinks',
      availabilityStatus: 'available',
      schoolId: 'mock-school-cadt',
    ),
    MenuItemDto(
      id: '6',
      name: 'Sugarcane Juice',
      description: 'Freshly pressed sugarcane juice with a hint of lime',
      price: 0.75,
      categoryName: 'Drinks',
      availabilityStatus: 'available',
      schoolId: 'mock-school-cadt',
    ),
    MenuItemDto(
      id: '7',
      name: 'Bai Sach Chrouk',
      description: 'Cambodian breakfast of marinated pork on rice',
      price: 1.50,
      categoryName: 'Breakfast',
      availabilityStatus: 'available',
      schoolId: 'mock-school-cadt',
    ),
    MenuItemDto(
      id: '8',
      name: 'Beef Lok Lak',
      description:
          'Stir-fried beef cubes with lime dipping sauce and fried egg',
      price: 3.00,
      categoryName: 'Lunch',
      availabilityStatus: 'available',
      schoolId: 'mock-school-cadt',
    ),
  ];

  @override
  Future<ActiveMenuDto> getActiveMenu({
    required String branchId,
    String? canteenId,
    DateTime? date,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final day = date ?? DateTime.now();
    final canteens = [
      _canteen('mock-canteen-a', 'Canteen A', ['Breakfast', 'Lunch']),
      _canteen('mock-canteen-b', 'Canteen B', ['Drinks']),
    ];
    return ActiveMenuDto(
      date: day.toIso8601String().substring(0, 10),
      dayOfWeek: day.weekday - 1,
      branch: ActiveMenuBranchDto(
        id: branchId,
        name: 'Main Campus',
        schoolId: 'mock-school-cadt',
      ),
      menu: const ActiveMenuInfoDto(id: 'mock-menu-week', name: 'This Week'),
      canteens: [
        for (final c in canteens)
          if (canteenId == null || c.id == canteenId) c,
      ],
    );
  }

  /// A canteen serving [_items] of the given categories. Dish '8' is sold out
  /// so the greyed-out state can be tried.
  static ActiveMenuCanteenDto _canteen(
    String id,
    String name,
    List<String> categories,
  ) => ActiveMenuCanteenDto(
    id: id,
    name: name,
    categories: [
      for (final category in categories)
        ActiveMenuCategoryDto(
          id: 'mock-category-${category.toLowerCase()}',
          name: category,
          items: [
            for (final item in _items)
              if (item.categoryName == category)
                ActiveMenuItemDto(
                  compositionId: 'mock-composition-${item.id}',
                  menuItemId: item.id,
                  name: item.name,
                  description: item.description,
                  price: item.price,
                  quantityAvailable: 20,
                  soldOut: item.id == '8',
                ),
          ],
        ),
    ],
  );

  @override
  Future<MenuItemDto> getMenuItem(String menuItemId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _items.firstWhere((i) => i.id == menuItemId);
  }

  @override
  Future<List<MenuItemDto>> getMenuItems({String? schoolId}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _items;
  }

  @override
  Future<WeeklyMenuDto?> getCurrentWeeklyMenu({String? schoolId}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final monday = DateTime.now().subtract(
      Duration(days: DateTime.now().weekday - 1),
    );
    // A deliberate mix: some dishes pinned to a weekday, the drinks left
    // dayless so the "served every day" path is exercised too.
    const dayByItem = <String, int?>{
      '1': 0, '7': 1, '4': 2, // breakfasts, Mon/Tue/Wed
      '2': 0, '3': 2, '8': 4, // lunches,    Mon/Wed/Fri
      '5': null, '6': null, // drinks,     every day
    };
    return WeeklyMenuDto(
      menu: MenuDto(
        id: 'mock-menu-week',
        name: 'This Week Menu',
        validFrom: DateTime(monday.year, monday.month, monday.day),
        validTo: DateTime(
          monday.year,
          monday.month,
          monday.day,
        ).add(const Duration(days: 6)),
        status: 'published',
      ),
      entries: [
        for (final item in _items)
          MenuEntryDto(
            id: 'mock-entry-${item.id}',
            menuItem: item,
            dayOfWeek: dayByItem[item.id],
            quantityAvailable: 20,
          ),
      ],
    );
  }
}
