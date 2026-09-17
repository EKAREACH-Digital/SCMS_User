import '../../dtos/menu_dto.dart';
import 'menu_repository.dart';

class MenuRepositoryMock implements MenuRepository {
  static const _items = [
    MenuItemDto(id: '1', name: 'Khmer Noodle', description: 'Traditional Cambodian noodle soup with fresh herbs', price: 2.00, categoryName: 'Breakfast', availabilityStatus: 'available', schoolId: 'mock-school-cadt'),
    MenuItemDto(id: '2', name: 'Pork with Rice', description: 'Steamed jasmine rice with seasoned grilled pork', price: 1.75, categoryName: 'Lunch', availabilityStatus: 'available', schoolId: 'mock-school-cadt'),
    MenuItemDto(id: '3', name: 'Chicken with Rice', description: 'Tender chicken on fragrant jasmine rice with house sauce', price: 2.00, categoryName: 'Lunch', availabilityStatus: 'available', schoolId: 'mock-school-cadt'),
    MenuItemDto(id: '4', name: 'Fried Egg Rice', description: 'Sunny-side-up egg over warm jasmine rice with soy sauce', price: 1.25, categoryName: 'Breakfast', availabilityStatus: 'available', schoolId: 'mock-school-cadt'),
    MenuItemDto(id: '5', name: 'Coconut Milk Tea', description: 'Creamy iced milk tea with coconut jelly and brown sugar', price: 1.00, categoryName: 'Drinks', availabilityStatus: 'available', schoolId: 'mock-school-cadt'),
    MenuItemDto(id: '6', name: 'Sugarcane Juice', description: 'Freshly pressed sugarcane juice with a hint of lime', price: 0.75, categoryName: 'Drinks', availabilityStatus: 'available', schoolId: 'mock-school-cadt'),
    MenuItemDto(id: '7', name: 'Bai Sach Chrouk', description: 'Cambodian breakfast of marinated pork on rice', price: 1.50, categoryName: 'Breakfast', availabilityStatus: 'available', schoolId: 'mock-school-cadt'),
    MenuItemDto(id: '8', name: 'Beef Lok Lak', description: 'Stir-fried beef cubes with lime dipping sauce and fried egg', price: 3.00, categoryName: 'Lunch', availabilityStatus: 'available', schoolId: 'mock-school-cadt'),
  ];

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
      '1': 0, '7': 1, '4': 2,          // breakfasts, Mon/Tue/Wed
      '2': 0, '3': 2, '8': 4,          // lunches,    Mon/Wed/Fri
      '5': null, '6': null,            // drinks,     every day
    };
    return WeeklyMenuDto(
      menu: MenuDto(
        id: 'mock-menu-week',
        name: 'This Week Menu',
        validFrom: DateTime(monday.year, monday.month, monday.day),
        validTo: DateTime(monday.year, monday.month, monday.day)
            .add(const Duration(days: 6)),
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
