// Menu item model used by the menu/home screens and the cart. Populated from
// the backend at runtime via MenuState; the const kMenuItems below is only a
// fallback/reference sample.
import 'package:flutter/material.dart';

/// Stand-in photo for dishes the backend has no `image_url` for. Items that do
/// have one render it instead (see MenuItemDto.imageUrl / MenuState).
const String kFallbackFoodImageUrl =
    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80';

class FoodItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final double rating;
  final List<String> tags;
  final String category; // 'breakfast' | 'lunch' | 'drinks'
  final String? imagePath; // bundled asset (local)
  final String? imageUrl; // remote photo (network)
  final int colorSeed;

  const FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.rating,
    required this.tags,
    required this.category,
    this.imagePath,
    this.imageUrl,
    this.colorSeed = 0,
  });
}

const List<List<Color>> kFoodGradients = [
  [Color(0xFFF8DFAF), Color(0xFFF9F4D7)],
  [Color(0xFFFFCDD2), Color(0xFFFFEBEE)],
  [Color(0xFFB3E5FC), Color(0xFFE1F5FE)],
  [Color(0xFFC8E6C9), Color(0xFFE8F5E9)],
  [Color(0xFFE1BEE7), Color(0xFFF3E5F5)],
];

const List<IconData> kFoodIcons = [
  Icons.ramen_dining,
  Icons.lunch_dining,
  Icons.local_cafe,
  Icons.rice_bowl,
  Icons.egg_alt,
];

const List<FoodItem> kMenuItems = [
  FoodItem(
    id: '1',
    name: 'Khmer Noodle',
    description:
        'Traditional Cambodian noodle soup with fresh herbs and rich broth',
    price: 2.00,
    rating: 4.7,
    tags: ['Soup', 'Traditional'],
    category: 'breakfast',
    imagePath: 'asset/foods/khmer_noodle.png',
  ),
  FoodItem(
    id: '2',
    name: 'Pork with Rice',
    description: 'Steamed jasmine rice served with seasoned grilled pork cuts',
    price: 1.75,
    rating: 4.8,
    tags: ['Grilled', 'Sweet', 'Spicy'],
    category: 'lunch',
    imagePath: 'asset/foods/pork_with_rice.png',
  ),
  FoodItem(
    id: '3',
    name: 'Chicken with Rice',
    description: 'Tender chicken on fragrant jasmine rice with house sauce',
    price: 2.00,
    rating: 4.9,
    tags: ['Soft', 'Sweet'],
    category: 'lunch',
    imagePath: 'asset/foods/chicken_with_rice.png',
  ),
  FoodItem(
    id: '4',
    name: 'Fried Egg Rice',
    description: 'Sunny-side-up egg over warm jasmine rice with soy sauce',
    price: 1.25,
    rating: 4.5,
    tags: ['Simple', 'Quick'],
    category: 'breakfast',
    imagePath: 'asset/foods/fried_egg_rice.png',
  ),
  FoodItem(
    id: '5',
    name: 'Coconut Milk Tea',
    description: 'Creamy iced milk tea with coconut jelly and brown sugar',
    price: 1.00,
    rating: 4.6,
    tags: ['Cold', 'Sweet'],
    category: 'drinks',
    imagePath: 'asset/drinks/coconut_milk_tea.png',
  ),
  FoodItem(
    id: '6',
    name: 'Sugarcane Juice',
    description: 'Freshly pressed sugarcane juice with a hint of lime',
    price: 0.75,
    rating: 4.4,
    tags: ['Cold', 'Fresh'],
    category: 'drinks',
    imagePath: 'asset/drinks/sugarcane_juice.png',
  ),
  // FoodItem(
  //   id: '7',
  //   name: 'Bai Sach Chrouk',
  //   description:
  //       'Cambodian breakfast of marinated pork on rice with pickled veggies',
  //   price: 1.50,
  //   rating: 4.8,
  //   tags: ['Grilled', 'Traditional'],
  //   category: 'breakfast',
  //   colorSeed: 4,
  // ),
  FoodItem(
    id: '7',
    name: 'Beef Lok Lak',
    description: 'Stir-fried beef cubes with lime dipping sauce and fried egg',
    price: 3.00,
    rating: 4.9,
    tags: ['Stir-fried', 'Savory'],
    category: 'lunch',
    imagePath: 'asset/foods/beef_lok_lak.png',
  ),
];
